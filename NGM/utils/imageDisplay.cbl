
       identification division.
       program-id. imagedisplay.

       environment division.
       configuration section.
       
       data division.
       working-storage section.
       01  keypress     pic x(1).
       01  loop-counter pic 9(3).
       01  random-event  PIC 9(2).
       01  random-seed  PIC 9(8).
       01  max-wallet-change pic S9(5) value 0.
       01  work-timer.
           05  starttime     pic 9(7) value 0.
           05  endtime       pic 9(7) value 0.
           05  time-worked   pic 9(5) value 0.
       
       linkage section.
       01  programcall pic 9(1).
       01  dance-step   pic 9(3).
       01  wallet-change pic S9(5).
       01  job-level    pic 9(3).

       procedure division using programcall dance-step wallet-change
               job-level.

           perform 000-evaluate-programcall.

           000-random-number.
           accept random-seed from time
           compute random-event = function mod(random-seed, 4) + 1.
           000-evaluate-programcall.
           perform 000-random-number
           display erase screen
           if programcall = 0
               perform nextgensplash
               accept keypress
               goback
           else if programcall = 1
               perform 110-work
               goback
           else if programcall = 3
               perform 100-dance
           else if programcall = 4
               perform 120-hack
           end-if.

           050-random-work.
              if random-event = 1
                perform talk
              else if random-event = 2
                perform skate
              else if random-event = 3
                perform work2
              else
                perform work
              end-if.

           100-dance.
           move dance-step to loop-counter
           perform varying loop-counter by -1 until loop-counter = 0
           perform crabdance1
           call "C$SLEEP" using 1
           display erase screen 
           perform crabdance2
           call "C$SLEEP" using 1
           display erase screen
           end-perform
           goback.

           110-work.
              accept starttime from time
              perform 050-random-work
              accept keypress at 1540
              accept endtime from time
              display erase screen
              compute max-wallet-change = 480 * job-level
              compute time-worked = (endtime - starttime) / 6000
              compute wallet-change = (endtime - starttime) / 6000 
                   * job-level 
              if wallet-change > max-wallet-change
                  move max-wallet-change to wallet-change
              end-if
              display "You worked for " at 0202
              display time-worked at 0220
              display "minutes" at 0230
              display "You earned $" at 0302 
              display wallet-change at 0314 
              display "dollars on this shift" at 0416
              display "Press any key to continue..." at 0602
              accept keypress
              goback.

           120-hack.
             perform hacking
             accept keypress at 1540
             goback.
       
           nextgensplash.
           display "                             $$    $$         ", 
           display "                           $$    $$           ",
           display "                   $$    $$    $$    $$       ", 
           display "         $$      $$    $$    $$    $$         ", 
           display "           $$  $$    $$    $$    $$           ", 
           display "       $$   $$$    $$    $$    $$             ", 
           display "         $$      $$    $$    $$   $$          ", 
           display "           $$  $$    $$    $$   $$            ",
           display "                    $$    $$   $$             ",
           display "           $     $$     $$    $               ", 
           display "         $$    $$       $$    $$              ", 
           display "       $$    $$     $     $$    $$            ", 
           display "           $$     $$       $$                 ",
           display "         $$     $$           $$               ", 
           display "           NextGen Simulator 2026             ",
           display "            NorthWest Arkansas                ",
           display "         Press Any Key to Continue            ",  
           .

           work.
           display "===================================================" 
           display "|                __                               |" 
           display "|             __/__\                              |" 
           display "|              | oo |   ____                      |" 
           display "|               \__/   |-   |\                    |" 
           display "|                |__   |    | |                   |" 
           display "|                |  \o~|____|_|                   |" 
           display "|              | |_  |______| |                   |" 
           display "|              |__ \ |      | |                   |" 
           display "|                |  \|      | |                   |" 
           display "|               olo  |      | |                   |" 
           display "===================================================" 
           display "|                                                 |" 
           display "|                                                 |" 
           display "|        Press any key to stop working            |" 
           display "|                                                 |" 
           display "===================================================" 
           .

           skate.
           display "===================================================" 
           display "|                __                               |" 
           display "|             __/__\                              |" 
           display "|              | oo |   ____                      |" 
           display "|               \__/   |-   |\                    |" 
           display "|               _|__   |    | |                   |" 
           display "|              / |  o~~|____|_|                   |" 
           display "|                |   |______| |                   |" 
           display "|               / \  |      | |                   |" 
           display "|              /   | |      | |                   |" 
           display "|            o-----o |      | |                   |" 
           display "===================================================" 
           display "|                                                 |" 
           display "|                                                 |" 
           display "|        Press any key to stop working            |" 
           display "|                                                 |" 
           display "===================================================" 
           .

           work2.
           display "===================================================" 
           display "|                __                               |" 
           display "|             __/__\                              |" 
           display "|              | -- |   ____                      |" 
           display "|               \__/   |    |\                    |" 
           display "|                |__   |    | |                   |" 
           display "|                |   o~|____|_|                   |" 
           display "|              | |_  |______| |                   |" 
           display "|              |__ \ |      | |                   |" 
           display "|                |  \|      | |                   |" 
           display "|               olo  |      | |                   |" 
           display "===================================================" 
           display "|                                                 |" 
           display "|                                                 |" 
           display "|        Press any key to stop working            |" 
           display "|                                                 |" 
           display "===================================================" 
           .

           talk.
           display "===================================================" 
           display "|                __          __                   |" 
           display "|             __/__\        /  \                  |" 
           display "|              | -- |      | oo |                 |" 
           display "|               \__/       | v  |                 |" 
           display "|               _|__dU      \__/                  |" 
           display "|              / |        Ub__|_/                 |" 
           display "|                |            |                   |" 
           display "|               / \           |                   |" 
           display "|              |   |         / \                  |" 
           display "|              |   |        |   |                 |" 
           display "===================================================" 
           display "|                                                 |" 
           display "|                                                 |" 
           display "|        Press any key to stop working            |" 
           display "|                                                 |" 
           display "===================================================" 
           .

           hacking.
           display "===================================================" 
           display "|                   __           ____             |" 
           display "|                  /__\__       |    |\           |" 
           display "|              __ |o=o=|        |ATM | |          |" 
           display "|             /  /\\__/         |____|_|          |" 
           display "|            | $|\_\|   -       |____| |          |" 
           display "|            \__/   |   --      |    | |          |" 
           display "|                   |   -       |   .| |          |" 
           display "|                  / \          |    | |          |" 
           display "|                 /   \         |    | |          |" 
           display "|               o-----o         |____|_|          |" 
           display "===================================================" 
           display "|              HACK SUCCESSFUL                    |" 
           display "|    $500 dollars has been added to your bank     |" 
           display "|        Press any key to Continue                |" 
           display "|                                                 |" 
           display "===================================================" 
           .

           crabdance1.
           display "       $$                      $$                  " 
           display "      $$$  $                  $  $$$               " 
           display "     $$$   $$                $$   $$$              " 
           display "     $$$$$$$$                $$$$$$$$              " 
           display "      $$$$$$                  $$$$$$               " 
           display "       $$$$    $$0$$$$$0$$$    $$$$                " 
           display "         $$  $$$$$$$$$$$$$$$$  $$                  " 
           display "     $$   $$$$$$$$$$$$$$$$$$$$$$   $$              " 
           display "   $$  $$  $$$$$$$$$$$$$$$$$$$$  $$  $$            " 
           display "  $      $$$$$$$$$$$$$$$$$$$$$$$$      $           " 
           display "  $  $$$    $$$$$$$$$$$$$$$$$$    $$$  $           " 
           display "    $   $$$$ $$$$$$$$$$$$$$$$ $$$$   $             " 
           display "   $         $ $$$$$$$$$$$$ $         $            " 
           display "   $      $$$                $$$      $            " 
           display "         $                      $                  " 
           display "        $                        $                 " 
           display "  The Crabs Carry Away Funds/debt in your Wallet   " 
           .
           
           crabdance2.
           display "         $$                      $$                " 
           display "      $$$  $                  $  $$$               " 
           display "     $$$   $$                $$   $$$              " 
           display "     $$$$$$$                 $$$$$$$$              " 
           display "      $$$$$$                 $$$$$$                " 
           display "      $$$$   $$0$$$$$0$$$     $$$$                 " 
           display "       $$  $$$$$$$$$$$$$$$$  $$                    " 
           display "   $$   $$$$$$$$$$$$$$$$$$$$$$   $$                " 
           display " $$  $$  $$$$$$$$$$$$$$$$$$$$  $$  $$              " 
           display "$      $$$$$$$$$$$$$$$$$$$$$$$$      $$            " 
           display "$  $$$    $$$$$$$$$$$$$$$$$$    $$$    $           " 
           display "  $   $$$$ $$$$$$$$$$$$$$$$ $$$$   $               " 
           display " $         $ $$$$$$$$$$$$ $         $              " 
           display " $      $$$                $$$       $             " 
           display "       $                      $                    " 
           display "      $                        $                   " 
           display "  The Crabs Carry Away Funds/debt in your Wallet   " 
           .
        
       
       end program imagedisplay.