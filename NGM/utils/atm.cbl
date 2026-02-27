       identification division.
       program-id. atm.
       
       environment division.
       input-output section.
           select api-response-file assign to 
           "./NGM/logs/api_response.dat"
                             organization is line sequential
                             access is sequential
                             file status is file-status.
       
       data division.
       file section.
           fd api-response-file.
           01 api-response-record pic x(1000).

       working-storage section.
       01 local-data.
           05 file-status   pic x(2).
           05 api-command   pic x(500).
           05 api-response  pic x(1000).
           05 user-input    pic x(1).
           05 transfer-amt   pic 9(6).
       01  display.
           05 disp-money pic -(4)9.
           05 disp-bank  pic -(6)9.

       linkage section.
              01 username pic x(20).
              01  user-money pic S9(5) value 0.
              01  user-bank pic S9(7) value 0.
              
       procedure division using username user-money user-bank.
           perform 300-atm.
         300-atm.
           display erase screen
           display '=== ATM ===' at 0202
           move user-money to disp-money
           display 'Wallet: $' at 0402 disp-money at 0415
           move user-bank to disp-bank
           display 'Bank Balance: $' at 0502 disp-bank at 0520
           display '1. Deposit Money' at 0802
           display '2. Withdraw Money' at 0902
           display '3. View Highscores' at 1002
           display '4. Return to Main Menu' at 1102
           display 'Enter choice: ' at 1402
           accept user-input at 1420
           evaluate user-input
               when '1' perform 341-deposit
               when '2' perform 342-withdraw
               when '3' perform 343-highscores
               when '4' perform goback
               when other perform 300-atm
           end-evaluate.

       341-deposit.
           display erase screen
           display '=== DEPOSIT ===' at 0202
           move user-money to disp-money
           display 'Wallet Balance: $' at 0402 disp-money at 0422
           display 'Enter amount to deposit: $' at 0602
           accept transfer-amt at 0630
           if transfer-amt > user-money or transfer-amt = 0
               display 'Invalid amount.' at 0802
               accept user-input at 0829
               perform 300-atm
           end-if
           display 'Processing deposit...' at 0802
           perform 540-api-deposit
           if api-response(1:7) = "SUCCESS"
               subtract transfer-amt from user-money
               add transfer-amt to user-bank
               display 'Deposit successful!' at 1002
               move user-money to disp-money
               display 'New Wallet: $' at 1102 disp-money at 1120
               move user-bank to disp-bank
               display 'New Bank: $' at 1202 disp-bank at 1215
           else
               display 'Deposit failed.' at 1002
           end-if
           display 'Press any key to continue...' at 1402
           accept user-input at 1429
           perform 300-atm.

       342-withdraw.
           display erase screen
           display '=== WITHDRAW ===' at 0202
           move user-bank to disp-bank
           display 'Bank Balance: $' at 0402 disp-bank at 0420
           display 'Enter amount to withdraw: $' at 0602
           accept transfer-amt at 0630
           if transfer-amt > user-bank or transfer-amt = 0
               display 'Invalid amount.' at 0802
               accept user-input at 0829
               perform 300-atm
           end-if
           display 'Processing withdrawal...' at 0802
           perform 550-api-withdraw
           if api-response(1:7) = "SUCCESS"
               add transfer-amt to user-money
               subtract transfer-amt from user-bank
               display 'Withdrawal successful!' at 1002
               move user-money to disp-money
               display 'New Wallet: $' at 1102 disp-money at 1120
               move user-bank to disp-bank
               display 'New Bank: $' at 1202 disp-bank at 1215
           else
               display 'Withdrawal failed.' at 1002
           end-if
           display 'Press any key to continue...' at 1402
           accept user-input at 1429
           perform 300-atm.

       343-highscores.
           call "./NGM/utils/highscores"
           perform 300-atm.

       540-api-deposit.
           move spaces to api-command
           string 'py ./NGM/api.py DEPOSIT ' delimited size
               function trim(username) delimited size
               ' ' delimited size
               transfer-amt delimited size
               ' > nul 2>&1' delimited size
               into api-command
           call "SYSTEM" using api-command
           call "C$SLEEP" using 2
           perform 590-read-response.

       550-api-withdraw.
           move spaces to api-command
           string 'py ./NGM/api.py WITHDRAW ' delimited size
               function trim(username) delimited size
               ' ' delimited size
               transfer-amt delimited size
               ' > nul 2>&1' delimited size
               into api-command
           call "SYSTEM" using api-command
           call "C$SLEEP" using 2
           perform 590-read-response.

       590-read-response.
           move spaces to api-response
           open input api-response-file
           if file-status = "00"
               read api-response-file into api-response
               close api-response-file
           else
               move "ERROR:Could not read response" to api-response
           end-if.