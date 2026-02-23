NextGen Simulator
==================
<img width="564" height="491" alt="image" src="https://github.com/user-attachments/assets/02a007b8-3bd4-493c-8959-646c06b497ea" />

NextGen Simulator is a idlegame developed for Rocket NextGen Game Jam 2026.

I made this game as a review for multiple areas we covered within the NextGen Academy, and as a "personal capstone project".
It was developed for running on the z/Os system HL02 environment that we have been using in the program.

The game uses the following:
 - Cobol (the main language that handles the user interaction)
 - Python (run by cobol as a wrapper to engage the api calls)
 - JCL (written JCL code to send to db2 to run)
 - Db2 (used as the database for recording user scores)

SETUP:
If you have access to a z/os system you can rename the 'exconfig.ini' file to 'config.ini' and replace the placeholders with your IP and Post.
Each user will need to access to a username and password. (This is not convenient to play- but it is what it is)

Download and run NGM.cbl to play the game. Use numbers to navigate through the menus.

<img width="741" height="472" alt="image" src="https://github.com/user-attachments/assets/2836dc23-3f2c-41c7-ab9f-f8c7245f9f4a" />
<img width="729" height="482" alt="image" src="https://github.com/user-attachments/assets/4e248781-1ff5-4988-a605-48b3edb6a10a" />
<img width="818" height="233" alt="image" src="https://github.com/user-attachments/assets/d1596207-53cd-4caf-85f6-ab13b0e6d469" />

