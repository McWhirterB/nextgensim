       identification division.
       program-id. highscores.
       
       environment division.
       input-output section.
           select api-response-file assign to "./logs/api_response.dat"
                             organization is line sequential
                             access is sequential
                             file status is file-status.
       
       data division.
       file section.
           fd api-response-file.
           01 api-response-record pic x(1000).

       working-storage section.
       01  local-data.
           05 file-status   pic x(2).
           05 api-command   pic x(100).
           05 api-response  pic x(1000).
           05 user-input    pic x(1).
           05 idx           pic 9(2).
           05 pos           pic 9(3).
           05 disp-bank     pic z(6)9.
       
       01  highscore-table.
           05 hs-entry occurs 9 times.
               10 hs-name      pic x(8).
               10 hs-amount    pic 9(7).

       procedure division.
       000-main.
           perform 100-load-highscores
           perform 200-display-highscores
           goback.

       100-load-highscores.
           move spaces to api-command
           string 'py api.py HIGHSCORES > nul 2>&1' delimited size
               into api-command
           end-string
           call "SYSTEM" using api-command
           call "C$SLEEP" using 2
           perform 110-read-response.

       110-read-response.
           move spaces to api-response
           open input api-response-file
           if file-status = "00"
               read api-response-file into api-response
               close api-response-file
           else
               move "ERROR:Could not read response" to api-response
           end-if.

       200-display-highscores.
           display erase screen
           display '=== TOP 10 RICHEST PLAYERS ===' at 0202
           display 'Rank  Username      Bank Balance' at 0402
           display '----  --------      ------------' at 0502
           if api-response(1:7) = "SUCCESS"
               perform 210-parse-entries
           else
               display 'Could not load highscores.' at 0702
           end-if
           display 'Press any key to continue...' at 1802
           accept user-input at 1829.

       210-parse-entries.
      *    Response: SUCCESS:HIGHSCORES:NAME____:BANK___:...
      *    Each entry: 8 char name + : + 7 char bank + : = 17 chars
      *    First entry starts at position 20
           move 20 to pos
           perform varying idx from 1 by 1 until idx > 9
               if api-response(pos:8) not = spaces
                   move api-response(pos:8) to hs-name(idx)
                   add 9 to pos
                   move function numval(api-response(pos:7)) 
                       to hs-amount(idx)
                   add 8 to pos
                   perform 220-display-entry
               end-if
           end-perform.

       220-display-entry.
           move hs-amount(idx) to disp-bank
           evaluate idx
               when 1
                   display '1.    ' at 0702
                       function trim(hs-name(1)) at 0708
                       '$' at 0720 disp-bank at 0721
               when 2
                   display '2.    ' at 0802
                       function trim(hs-name(2)) at 0808
                       '$' at 0820 disp-bank at 0821
               when 3
                   display '3.    ' at 0902
                       function trim(hs-name(3)) at 0908
                       '$' at 0920 disp-bank at 0921
               when 4
                   display '4.    ' at 1002
                       function trim(hs-name(4)) at 1008
                       '$' at 1020 disp-bank at 1021
               when 5
                   display '5.    ' at 1102
                       function trim(hs-name(5)) at 1108
                       '$' at 1120 disp-bank at 1121
               when 6
                   display '6.    ' at 1202
                       function trim(hs-name(6)) at 1208
                       '$' at 1220 disp-bank at 1221
               when 7
                   display '7.    ' at 1302
                       function trim(hs-name(7)) at 1308
                       '$' at 1320 disp-bank at 1321
               when 8
                   display '8.    ' at 1402
                       function trim(hs-name(8)) at 1408
                       '$' at 1420 disp-bank at 1421
               when 9
                   display '9.    ' at 1502
                       function trim(hs-name(9)) at 1508
                       '$' at 1520 disp-bank at 1521
           end-evaluate.

       end program highscores.
