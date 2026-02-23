"""
NGM Game API - z/OSMF Interface
Handles communication between COBOL game and DB2 database via z/OSMF
"""
import sys
import os
import re
import requests
import time
import configparser
from urllib3.exceptions import InsecureRequestWarning


config = configparser.ConfigParser()
config.read('./config.ini')

try:
    host = config.get('zosmf', 'host')
    username = config.get('zosmf', 'username')
    password = config.get('zosmf', 'password')
except KeyError as e:
    raise KeyError(f"Missing config key: {e}. Check config.ini has [zosmf] section.")

if not host.startswith('http'):
    host = 'https://' + host

requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

def connect_to_zosmf():
    """Create authenticated session to z/OSMF"""
    session = requests.Session()
    session.auth = (username, password)
    session.verify = False
    session.headers.update({
        'Content-Type': 'application/json',
        'X-CSRF-ZOSMF-HEADER': 'true'
    })
    return session

def submit_job(session, jcl):
    """Submit JCL job to z/OS"""
    url = f"{host.rstrip('/')}/zosmf/restjobs/jobs"
    response = session.put(url, data=jcl, headers={'Content-Type': 'text/plain'})
    response.raise_for_status()
    return response.json()

def wait_for_completion(session, jobname, jobid, timeout=300):
    """Wait for job to complete"""
    url = f"{host.rstrip('/')}/zosmf/restjobs/jobs/{jobname}/{jobid}"
    elapsed = 0
    while elapsed < timeout:
        response = session.get(url)
        response.raise_for_status()
        status = response.json()
        if status['status'] in ['OUTPUT', 'ABEND']:
            return status
        time.sleep(5)
        elapsed += 5
    raise TimeoutError(f"Job did not complete within {timeout} seconds")

def get_job_output(session, jobname, jobid):
    """Retrieve spool output from completed job"""
    try:
        url = f"{host.rstrip('/')}/zosmf/restjobs/jobs/{jobname}/{jobid}/files"
        response = session.get(url)
        response.raise_for_status()
        output = ""
        for f in response.json():
            if f.get('ddname') in ['SYSTSPRT', 'SYSPRINT']:
                file_url = f"{host.rstrip('/')}/zosmf/restjobs/jobs/{jobname}/{jobid}/files/{f['id']}/records"
                file_response = session.get(file_url)
                if file_response.status_code == 200:
                    output += file_response.text
        return output
    except:
        return ""

PARAM_MAP = {
    'USERNAME': 'CRBNAME',
    'USERPASS': 'CRBPASS', 
    'AMOUNT': 'CRBAMT',
    'UPTBANK': 'CRBBANK',
    'UPTSTR': 'CRBSTR',
    'UPTSEC': 'CRBSEC',
    'UPTJOB': 'CRBJOB',
    'UPTMESS': 'CRBMESS'
}

def substitute_jcl_parameters(jcl_content, parameters):
    """Replace placeholders in JCL with actual values"""
    modified = jcl_content
    for param_name, param_value in parameters.items():
        modified = modified.replace(f'&{param_name}', str(param_value))
        placeholder = PARAM_MAP.get(param_name.upper())
        if placeholder:
            if param_name.upper() == 'UPTMESS':
                modified = modified.replace(placeholder, f"'{param_value}'")
            else:
                modified = modified.replace(placeholder, str(param_value))
    return modified

def submit_parameterized_job(job_name, parameters):
    """Submit JCL job with parameter substitution"""
    try:
        session = connect_to_zosmf()
        with open(f'./jcl/{job_name}.jcl', 'r') as f:
            jcl_content = f.read()
        modified_jcl = substitute_jcl_parameters(jcl_content, parameters)
        job_info = submit_job(session, modified_jcl)
        job_status = wait_for_completion(session, job_info['jobname'], job_info['jobid'])
        job_output = get_job_output(session, job_info['jobname'], job_info['jobid'])
        return {'success': True, 'output': job_output, 'jobid': job_info['jobid']}
    except Exception as e:
        return {'success': False, 'error': str(e), 'output': ''}

def get_row_count(output):
    """Extract row count from DB2 RETRIEVAL message"""
    if '0 ROW(S)' in output or 'RETRIEVAL OF          0' in output:
        return 0
    match = re.search(r'RETRIEVAL OF\s+(\d+)\s+ROW', output)
    return int(match.group(1)) if match else 0

def check_sql_success(output):
    """Check if SQL statement executed successfully"""
    if 'SQLCODE = -' in output:
        return False
    return 'SQLCODE = 000' in output or 'SUCCESSFUL EXECUTION' in output

def parse_piped_row(output):
    """Parse a DB2 result row with pipe-delimited format"""
    for line in output.split('\n'):
        if '|' in line and '_|' in line:
            return [p.strip() for p in line.split('|')]
    return []

def parse_user_stats(output):
    """Extract user stats from DB2 SELECT output"""
    stats = {'bank': 0, 'hacking': 1, 'security': 1, 'job': 1}
    parts = parse_piped_row(output)
    if len(parts) >= 5:
        try:
            stats['bank'] = int(parts[1]) if parts[1].lstrip('-').isdigit() else 0
            stats['hacking'] = int(parts[2]) if parts[2].isdigit() else 1
            stats['security'] = int(parts[3]) if parts[3].isdigit() else 1
            stats['job'] = int(parts[4]) if parts[4].isdigit() else 1
        except (ValueError, IndexError):
            pass
    return stats

def parse_highscores(output):
    """Extract highscores list from DB2 SELECT output"""
    scores = []
    for line in output.split('\n'):
        if '|' in line and '_|' in line:
            parts = line.split('|')
            if len(parts) >= 3:
                try:
                    username = parts[1].strip()
                    bank_str = parts[2].strip()
                    if username and bank_str.lstrip('-').isdigit():
                        scores.append((username, int(bank_str)))
                except (ValueError, IndexError):
                    continue
    return scores

def write_response(message):
    """Write response to file for COBOL to read"""
    try:
        response_file = "./logs/api_response.dat"
        if os.path.exists(response_file):
            os.remove(response_file)
        with open(response_file, "w") as f:
            f.write(message)
    except:
        pass

def handle_checkuser(args):
    if len(args) < 1:
        return write_response("ERROR:Missing username")
    result = submit_parameterized_job('CHECKUSER', {'USERNAME': args[0]})
    if result['success']:
        exists = get_row_count(result['output']) > 0
        write_response(f"SUCCESS:{'EXISTS' if exists else 'NOTEXISTS'}:{args[0]}")
    else:
        write_response(f"ERROR:{result['error']}")

def handle_register(args):
    if len(args) < 2:
        return write_response("ERROR:Missing username or password")
    check = submit_parameterized_job('CHECKUSER', {'USERNAME': args[0]})
    if check['success'] and get_row_count(check['output']) > 0:
        return write_response(f"ERROR:Username {args[0]} already exists")
    result = submit_parameterized_job('ADDUSER', {'USERNAME': args[0], 'USERPASS': args[1]})
    if result['success'] and check_sql_success(result['output']):
        write_response(f"SUCCESS:REGISTERED:{args[0]}")
    else:
        write_response("ERROR:Failed to register user")

def handle_login(args):
    if len(args) < 2:
        return write_response("ERROR:Missing username or password")
    result = submit_parameterized_job('LOGIN', {'USERNAME': args[0], 'USERPASS': args[1]})
    if result['success'] and get_row_count(result['output']) > 0:
        write_response(f"SUCCESS:LOGGEDIN:{args[0]}")
    else:
        write_response("ERROR:Invalid username or password")

def handle_adduser(args):
    if len(args) < 2:
        return write_response("ERROR:Missing username or password")
    result = submit_parameterized_job('ADDUSER', {'USERNAME': args[0], 'USERPASS': args[1]})
    if result['success'] and check_sql_success(result['output']):
        write_response(f"SUCCESS:User {args[0]} added")
    else:
        write_response("ERROR:Failed to add user")

def handle_getuser(args):
    if len(args) < 1:
        return write_response("ERROR:Missing username")
    result = submit_parameterized_job('GETUSER', {'USERNAME': args[0]})
    if result['success'] and get_row_count(result['output']) > 0:
        stats = parse_user_stats(result['output'])
        write_response(f"SUCCESS:STATS:{str(stats['bank']).zfill(7)}:"
                      f"{str(stats['hacking']).zfill(3)}:"
                      f"{str(stats['security']).zfill(3)}:"
                      f"{str(stats['job']).zfill(3)}")
    else:
        write_response("ERROR:User not found")

def handle_deposit(args):
    if len(args) < 2:
        return write_response("ERROR:Missing username or amount")
    result = submit_parameterized_job('DEPOSIT', {'USERNAME': args[0], 'AMOUNT': args[1]})
    if result['success'] and check_sql_success(result['output']):
        write_response(f"SUCCESS:DEPOSITED:{args[1]}")
    else:
        write_response("ERROR:Deposit failed")

def handle_withdraw(args):
    if len(args) < 2:
        return write_response("ERROR:Missing username or amount")
    result = submit_parameterized_job('WITHDRAW', {'USERNAME': args[0], 'AMOUNT': args[1]})
    if result['success'] and check_sql_success(result['output']):
        write_response(f"SUCCESS:WITHDRAWN:{args[1]}")
    else:
        write_response("ERROR:Withdraw failed - insufficient funds or user not found")

def handle_highscores(args):
    result = submit_parameterized_job('HIGHSCORES', {})
    if result['success']:
        scores = parse_highscores(result['output'])
        if scores:
            parts = [f"{u.ljust(8)[:8]}:{str(b).zfill(7)}:" for u, b in scores[:10]]
            write_response(f"SUCCESS:HIGHSCORES:{''.join(parts)}")
        else:
            write_response("SUCCESS:HIGHSCORES:NONE")
    else:
        write_response(f"ERROR:{result['error']}")

def handle_updateuser(args):
    if len(args) < 6:
        return write_response("ERROR:Missing parameters for update")
    params = {
        'USERNAME': args[0], 'UPTBANK': args[1], 'UPTSTR': args[2],
        'UPTSEC': args[3], 'UPTJOB': args[4], 'UPTMESS': args[5]
    }
    result = submit_parameterized_job('UPDUSER', params)
    if result['success'] and check_sql_success(result['output']):
        write_response(f"SUCCESS:User {args[0]} updated")
    else:
        write_response("ERROR:Failed to update user")

def handle_getusers(args):
    result = submit_parameterized_job('GETUSERS', {})
    if result['success']:
        write_response("SUCCESS:Users retrieved")
    else:
        write_response(f"ERROR:{result['error']}")
        
HANDLERS = {
    'CHECKUSER': handle_checkuser,
    'REGISTER': handle_register,
    'LOGIN': handle_login,
    'ADDUSER': handle_adduser,
    'GETUSER': handle_getuser,
    'DEPOSIT': handle_deposit,
    'WITHDRAW': handle_withdraw,
    'HIGHSCORES': handle_highscores,
    'UPDATEUSER': handle_updateuser,
    'GETUSERS': handle_getusers,
}

if __name__ == "__main__":
    if len(sys.argv) > 1:
        action = sys.argv[1].upper()
        args = sys.argv[2:] if len(sys.argv) > 2 else []
        handler = HANDLERS.get(action)
        if handler:
            handler(args)
        else:
            write_response(f"ERROR:Unknown action {action}")
    else:
        write_response("ERROR:No action specified")
