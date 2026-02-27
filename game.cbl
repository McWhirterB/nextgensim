       identification division.
       program-id. game.
       
       environment division.
       input-output section.

       data division.
       file section.

       working-storage section.
           01 user-input pic x(20).

       procedure division.
           call "./NGM/NGM"

      *    UNCOMMENT WHEN JOBBER DEV IS READY 
      *    000-game-select.
      *    display erase screen
      *    perform select-screen.
      *    accept user-input at 1537
      *    if user-input = "1" then
      *        call "jobber"
      *        else if user-input = "2" then
      *        call "./NGM/NGM"
      *        else
      *            display "Invalid input. Please select 1 or 2."
      *            perform 000-game-select
      *    end-if.

      *    select-screen.
      *    display "===================================================" 
      *    display "|                       |                         |" 
      *    display "|       Jobber          |        NextGen          |" 
      *    display "|                       |       Simulator         |" 
      *    display "|                       |                         |" 
      *    display "|    A Single Player    |     A Multiplayer       |" 
      *    display "|   Cautionary Idler    |    Competitive Idler    |" 
      *    display "|   Written in Cobol    |(Requires a z/Os system) |" 
      *    display "|                       |                         |" 
      *    display "|                       |                         |" 
      *    display "|                       |                         |" 
      *    display "===================================================" 
      *    display "|        1 Jobber          2 NextGenSimulator     |" 
      *    display "|                                                 |" 
      *    display "|        Select Which Game you Want               |" 
      *    display "|                                                 |" 
      *    display "===================================================" 
      *    .