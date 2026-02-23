       identification division.
       program-id. ngm.
       
       environment division.
       input-output section.
           select api-response-file assign to "./logs/api_response.dat"
               organization is line sequential
               file status is file-status.

       data division.
       file section.
           fd api-response-file.
           01 api-response-record pic x(1000).

       working-storage section.
       01  gamedata.
           05 user-input    pic x(1).
           05 wallet-change pic S9(5) value 0.
           05 programcall   pic x(1).
           05 user-money    pic S9(5) value 0.
           05 user-bank     pic S9(7) value 0.
           05 transfer-amt  pic 9(5) value 0.
           05 dance-step    pic 9(3) value 0.
       
       01  stats.
           05 hacking-level   pic 9(3) value 1.
           05 security-level  pic 9(3) value 1.
           05 job-level       pic 9(3) value 1.
       
       01  login.
           05 username      pic x(20).
           05 userpass      pic x(20).
           05 login-status  pic x(2) value "NL".
               88 logged-in value "LI".
               88 guest-mode value "GM".

       01  api.
           05 api-command   pic x(500).
           05 api-response  pic x(1000).
           05 file-status   pic x(2).

       01  store.
           05 upgrade-price pic 9(8) value 1000.
           05 total-level   pic 9(3) value 3.

       01  display.
           05 disp-money pic z(4)9.
           05 disp-bank  pic z(6)9.
           05 disp-price pic z(7)9.
           05 disp-level pic z(2)9.

       procedure division.
       
       000-main.
           perform 010-init
           perform 100-welcome-screen
           stop run.

       010-init.
           move 0 to wallet-change dance-step transfer-amt
           move 0 to user-money user-bank
           move 1 to hacking-level security-level job-level
           move spaces to programcall username userpass
           move "NL" to login-status.

       100-welcome-screen.
           display erase screen
           move 0 to programcall
           call "./utils/imagedisplay" using programcall 
               dance-step
           perform 110-login-menu.

       110-login-menu.
           display erase screen
           display '1. Login as Existing Player' at 0202
           display '2. Register as New Player' at 0302
           display '3. Play as Guest' at 0402
           display 'Enter number to continue: ' at 0802
           accept user-input at 0830
           evaluate user-input
               when '1' perform 120-login-screen
               when '2' perform 130-register-screen
               when '3' perform 140-guest-login
               when other perform 110-login-menu
           end-evaluate.

       120-login-screen.
           display erase screen
           display 'LOGIN' at 0102
           display 'Enter Username: ' at 0302
           accept username at 0320
           display 'Enter Password: ' at 0402
           accept userpass at 0420
           display "Connecting to server..." at 0602
           perform 500-api-login
           if api-response(1:7) = "SUCCESS"
               move "LI" to login-status
               display "Login successful!" at 0702
               display "Loading your stats..." at 0802
               perform 510-api-getuser
               accept user-input at 0929
               perform 200-main-menu
           else
               display "Login failed. Invalid credentials." at 0702
               display "Press any key to continue..." at 0902
               accept user-input at 0929
               perform 110-login-menu
           end-if.

       130-register-screen.
           display erase screen
           display 'REGISTER NEW ACCOUNT' at 0102
           display 'Enter Desired Username: ' at 0302
           accept username at 0330
           display 'Enter Desired Password: ' at 0402
           accept userpass at 0430
           display "Creating account..." at 0602
           perform 520-api-adduser
           if api-response(1:7) = "SUCCESS"
               move "LI" to login-status
               display "Registration successful!" at 0702
               accept user-input at 0829
               perform 200-main-menu
           else
               display "Registration failed." at 0702
               display "Username may already exist." at 0802
               display "Press any key to continue..." at 1002
               accept user-input at 1029
               perform 110-login-menu
           end-if.

       140-guest-login.
           move "Guest" to username
           move 1000 to user-money
           move "GM" to login-status
           perform 200-main-menu.

       200-main-menu.
           display erase screen
           display 'Welcome: ' at 0202 username at 0212
           move user-money to disp-money
           display 'Wallet: $' at 0302 disp-money at 0312
           display 'Stats' at 0230
           move job-level to disp-level
           display 'Job Level:' at 0330 disp-level at 0345
           move hacking-level to disp-level
           display 'Hacking Level:' at 0430 disp-level at 0448
           move security-level to disp-level
           display 'Security Level:' at 0530 disp-level at 0549
           display '1. Go to Work (Earn Money)' at 0702
           display '2. Event (Cost $100)' at 0802
           display '3. Store (Buy Upgrades)' at 0902
           display '4. Hacking Attempt (Coming Soon)' at 1002
           display '5. ATM (Deposit/Withdraw/Highscores)' at 1102
           display '6. Exit' at 1202
           if guest-mode
               display "Login required for features 4 & 5" at 1402
           end-if
           display 'Enter number to continue: ' at 1602
           accept user-input at 1630
           perform 210-main-nav.

       210-main-nav.
           display erase screen
           evaluate user-input
               when '1' perform 300-go-to-work
               when '2' perform 310-event
               when '3' perform 320-store
               when '4' perform 330-hacking
               when '5' perform 340-atm
               when '6' perform 999-exit
               when other perform 200-main-menu
           end-evaluate.

       300-go-to-work.
           move 1 to programcall
           call './utils/imagedisplay' using programcall 
               dance-step wallet-change job-level
           add wallet-change to user-money
           perform 200-main-menu.

       310-event.
           if user-money < 100
               display 'Not enough money for event ticket' at 0302
               display 'Press any key to continue.' at 0802
               accept user-input at 0829
               perform 200-main-menu
           else
               subtract 100 from user-money
               call './utils/event' using wallet-change
               add wallet-change to user-money
               perform 200-main-menu
           end-if.

       320-store.
           display erase screen
           display "Welcome to the store!" at 0202
           move user-money to disp-money
           display "Wallet: $" at 0302 disp-money at 0312
           compute total-level = job-level + hacking-level 
               + security-level
           compute upgrade-price = 300 * total-level
           move upgrade-price to disp-price
           display "Upgrade Price: $" at 0402 disp-price at 0420
           display "1. Increase Job Level" at 0602
           display "2. Increase Hacking Level" at 0702
           display "3. Increase Security Level" at 0802
           display "4. Return to Main Menu" at 0902
           display 'Enter number to continue: ' at 1102
           accept user-input at 1130
           perform 321-store-purchase.

       321-store-purchase.
           if user-input = '4'
               perform 200-main-menu
           end-if
           if user-money < upgrade-price
               display 'Not enough money in wallet.' at 1302
               accept user-input at 1130
               perform 320-store
           end-if
           subtract upgrade-price from user-money
           evaluate user-input
               when '1' add 1 to job-level
               when '2' add 1 to hacking-level
               when '3' add 1 to security-level
               when other perform 320-store
           end-evaluate
           if logged-in
               perform 530-api-updateuser
           end-if
           perform 320-store.

       330-hacking.
           if user-money < 500
               display 'Not enough money for hacking attempt' at 0302
               display 'Press any key to continue.' at 0802
               accept user-input at 0829
           else
               subtract 500 from user-money
           end-if
           perform 200-main-menu.

       340-atm.
           display erase screen
           if guest-mode
               display "You must be logged in to use the ATM." at 0302
               display "Press any key to continue..." at 0502
               accept user-input at 0529
               perform 200-main-menu
           end-if
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
               when '4' perform 200-main-menu
               when other perform 340-atm
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
               perform 340-atm
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
           perform 340-atm.

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
               perform 340-atm
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
           perform 340-atm.

       343-highscores.
           call "./utils/highscores"
           perform 340-atm.
       500-api-login.
           move spaces to api-command
           string 'py api.py LOGIN ' delimited size
               function trim(username) delimited size
               ' ' delimited size
               function trim(userpass) delimited size
               ' > nul 2>&1' delimited size
               into api-command
           call "SYSTEM" using api-command
           call "C$SLEEP" using 2
           perform 590-read-response.

       510-api-getuser.
           move spaces to api-command
           string 'py api.py GETUSER ' delimited size
               function trim(username) delimited size
               ' > nul 2>&1' delimited size
               into api-command
           call "SYSTEM" using api-command
           call "C$SLEEP" using 2
           perform 590-read-response
           if api-response(1:7) = "SUCCESS"
               move function numval(api-response(15:7)) 
                   to user-bank
               move function numval(api-response(23:3)) 
                   to hacking-level
               move function numval(api-response(27:3)) 
                   to security-level
               move function numval(api-response(31:3)) 
                   to job-level
               display "Stats loaded from server." at 0902
           else
               display "Could not load stats." at 0902
           end-if.

       520-api-adduser.
           move spaces to api-command
           string 'py api.py ADDUSER ' delimited size
               function trim(username) delimited size
               ' ' delimited size
               function trim(userpass) delimited size
               ' > nul 2>&1' delimited size
               into api-command
           call "SYSTEM" using api-command
           call "C$SLEEP" using 3
           perform 590-read-response.

       530-api-updateuser.
           display 'Saving to server...' at 1402
           move spaces to api-command
           string 'py api.py UPDATEUSER ' delimited size
               function trim(username) delimited size
               ' ' delimited size
               user-bank delimited size
               ' ' delimited size
               hacking-level delimited size
               ' ' delimited size
               security-level delimited size
               ' ' delimited size
               job-level delimited size
               ' 0 > nul 2>&1' delimited size
               into api-command
           call "SYSTEM" using api-command
           call "C$SLEEP" using 2
           perform 590-read-response
           if api-response(1:7) = "SUCCESS"
               display 'Upgrade saved!' at 1502
           else
               display 'Warning: Could not save.' at 1502
           end-if
           accept user-input at 1529.

       540-api-deposit.
           move spaces to api-command
           string 'py api.py DEPOSIT ' delimited size
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
           string 'py api.py WITHDRAW ' delimited size
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

       999-exit.
           move 3 to programcall
           call "./utils/imagedisplay" using programcall 
               dance-step
           display erase screen
           display "Thanks for playing!" at 0220
           display "NextGen Simulator: NWA Edition" at 0420
           display "Created by thedorktrain" at 0520
           accept user-input at 0602
           stop run.

       end program ngm.
