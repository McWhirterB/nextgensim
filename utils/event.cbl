       identification division.
       program-id. event.
       
       environment division.
       input-output section.

       configuration section.
       
       data division.
       file section.

       working-storage section.
       01 EventDatabase.
           05 event-text   PIC X(200) OCCURS 33 TIMES.
           05 event-cost   PIC S9(5) OCCURS 33 TIMES.
           05 random-event  PIC 9(2).
           05 random-seed  PIC 9(8).
           05 user-input   PIC X(1).
       01 display-fields.
           05 disp-amount  PIC -(4)9.

       linkage section.
       01  wallet-change pic S9(5).

       procedure division using wallet-change.
           perform 000-random-number.
           perform 010-setup-events.
           perform 020-display-event.


       000-random-number.
           accept random-seed from time
           compute random-event = function mod(random-seed, 25) + 1.

       020-display-event.
            display erase screen
            display event-text(random-event)(1:59) at line 2 column 2
            display event-text(random-event)(60:59) at line 3 column 2
            display event-text(random-event)(119:59) at line 4 column 2
            move event-cost(random-event) to wallet-change
            move event-cost(random-event) to disp-amount
            display "Wallet Change: $" at line 6 column 2
            display disp-amount at line 6 column 18
            display "Press any key to continue..." at line 8 column 2
            accept user-input at line 8 column 32.
            goback.
      
       010-setup-events.
           string 
           "You decide to go to Wrights BBQ with the boss.             " 
           "As you chow down on some banana pudding you find...        " 
           "$50 worth of Quarters                                      " 
           delimited by size into event-text(1)
           move 50 to event-cost(1).

           string 
           "An extradimensional imp name BlaCleighton appears          " 
           "'iF yoU hAd tO eAt a DiRt bUrGeR wOuLd yOu?' he asks       "
           "as you muse over his question... you realize.. he is gone  "
           delimited by size into event-text(2)
           move 0 to event-cost(2).

           string 
           "Leadership invites you to a high stakes game of            "
           "top golf. You are nervouse but immediately give the best   "
           "game of golf in your life and win $2000                    " 
           delimited by size into event-text(3). 
           move 2000 to event-cost(3).

           string 
           "You are asked to help stock the breakroom....              "
           "You find $200 stashed in between the Quinoa chips          "
           "and you return it because you are a good person +1 Karma   "
           delimited by size into event-text(4).
           move 0 to event-cost(4).

           string 
           "UH OH! Team Yellow has caught you after hours alone!       "
           "'Give us all your code' they say menacingly.               "
           "You give in... 'Ew is this High Level Assembler?' they say "
           delimited by size into event-text(5).
           move -200 to event-cost(5).

           string 
           "The Z Team has been montoring your activity.               "
           "'You've been a good boy/girl' they say proudly.            "
           "'Take this $500 as a reward!'                              "
           delimited by size into event-text(6).
           move 500 to event-cost(6).

           string 
           "Raunit appears and says 'INVEST IN NEXTGENCOIN NOW'        "
           "You invest your event ticket in hopefully.....             "
           "NEXTGENCOIN STOCKS ARE.... UP Take $400                    "
           delimited by size into event-text(7).
           move 400 to event-cost(7).

           string 
           "A horde of zombies have appeard in Rogers Arkansas.        "
           "'6 7' '6 7' they mumble as they walk towards you.          "
           "You board your magic school bus and sail to New Zealand    "
           delimited by size into event-text(8).
           move 300 to event-cost(8).

           string 
           "You feel like you are being watched...                     "
           "A rogue agent from Fraudcom appears. He means business.    "
           "'You are the future of rocket?' he laughs and steals $200  "
           delimited by size into event-text(9).
           move -200 to event-cost(9).

           string 
           "You fall asleep during a lecture... oh no                  "
           "You've woken up in the Five Nights at Rockets Universe.    "
           "You run around scared... losing your wallet on the way out."
           delimited by size into event-text(10).
           move -100 to event-cost(10).

           string 
           "while(1) print('crab crab crab crab')                      "
           "while(1) print('crab crab crab crab')                      "
           "while(1) print('$600')                                     "
           delimited by size into event-text(11).
           move 600 to event-cost(11).

           string 
           "Uh Oh... The Elevator is stuck with you in it!             "
           "You contemplate your life choices while you wait for help. "
           "You survive in the elevator for 2 weeks. Nothing Happens.  "
           delimited by size into event-text(12).
           move 0 to event-cost(12).

           string 
           "Presentation Time! Stand up irl and give one random fact   "
           "about yourself. Do It. Stand up and Shout it. Cmon.        "
           "Did you actually do it? Take $300 if you did.              "
           delimited by size into event-text(13).
           move 300 to event-cost(13).

           string 
           "Your Booster is calling on microsoft teams....             "
           "'Can you wire me $100? I need it for a thing' they say     "
           "You wire them the money and they say 'Thanks bro!'         "
           delimited by size into event-text(14).
           move -100 to event-cost(14).

           string 
           "Angel descends from above.                                 "
           "'What were you doing in the ceiling angel' you ask.        "
           "'Shh you didn't see anything' he says as he hands you $600 "
           delimited by size into event-text(15).
           move 600 to event-cost(15).

           string 
           "OH NO CRABS HAVE DESCENDED ON YOUR BANK ACCOUNT!           "
           "You get pinched. They get pinched. You lose aLOT of Money. "
           "The Crabs make off with $1000. Every Coders nightmare.     "
           delimited by size into event-text(16).
           move -1000 to event-cost(16).

           string 
           "HLASM QUIZ TIME! What is in R2?? You Panic.                "
           "'Is it.... $400?' you ask. YOU ARE CORRECT!                "
           "You earn $400 and the respect of everyone you care about.  "
           delimited by size into event-text(17).
           move 400 to event-cost(17).

           string 
           "You gamble on a chess match being held in Pettigrew.       "
           "You know these matches are illegal but Darrian is your boy."
           "Cameron puts him in check. You Sweat. Darrian wins though. "
           delimited by size into event-text(18).
           move 300 to event-cost(18).

           string 
           "You take a Udemy course on HOW TO MAKE MONEY FAST.         "
           "You watch a few 45 minutes videos and then:                "
           "It prints out $600 in cash. Nice.                          "
           delimited by size into event-text(19).
           move 600 to event-cost(19).

           string 
           "You accidentally entered the WextGen Dimension.            "
           "Wedrick says: 'WAAA- Make sure you have healthy code!'     "
           "Do we have the wrong Fredrick? Anyway you get $110         "
           delimited by size into event-text(20).
           move 110 to event-cost(20).

           string 
           "A Magical Tophat salesman appears.                         "
           "'The hat of your dreams COULD BE YOURS!' He Says'          "
           "How can you refuse?? You buy 3. Each for $100.             "
           delimited by size into event-text(21).
           move -300 to event-cost(21).

           string 
           "You discover NextGen is a hidden camera show.              "
           "You don't have a job. It was all a prank.                  "
           "You go mildly viral and cash in on the success for $600.   "
           delimited by size into event-text(22).
           move 600 to event-cost(22).

           string 
           "You develop the best app ever seen to man: Roxcz           "
           "Rocket Software rebrands as Roxczet Softare.               "
           "You get promoted and get a massive bonus of $5000          "
           delimited by size into event-text(23).
           move 5000 to event-cost(23).

           string 
           "You develop an app for simulating nextgen.                 "
           "You hare it to other nextgenners and compete for virtual $."
           "You wrote this event in to get more money. Nice. $500      "
           delimited by size into event-text(24).
           move 500 to event-cost(24).

           string 
           "You work very hard typing a joke in NextGen Chat.          "
           "You retype it and retype it unti it is perfect.            "
           "Sebastian replies 'It's okay we cant all be funny' - $400  "
           delimited by size into event-text(25).
           move -400 to event-cost(25).

           string 
           "You go to the panda meeting room for a big interview.      "
           "Green Team bursts into the room mid interview.             "
           "'WE HAVE THIS ROOM RESEVED' THEY SCREAM. Interview Failed. "
           delimited by size into event-text(26).
           move -200 to event-cost(26).

           string 
           "You are called into a teams meeting with Josh and Brennen. "
           "'There has been a mix up. You were suppose to go to Perth.'"
           "You have to start NextGen over again womp womp.            "
           delimited by size into event-text(27).
           move -300 to event-cost(27).

           string 
           "Mrs.Rocket the CEO of the company calls you in.            "
           "'We saw what you wrote in NextGen Casual.' She says.       "
           "'IT WAS SO FUNNY. HAHA HERES A BONUS. FOR MAKING US LAUGH.'"
           delimited by size into event-text(28).
           move 700 to event-cost(28).

           string 
           "Not really an event but- its rocket related I guess.       "  
           "Right now the Artemis Rocket is preparing for its launch.  "            
           "If you are not following the Artemis program- you should!  "
           delimited by size into event-text(29).
           move 200 to event-cost(29).

           string 
           "You are invited to headline a concert at the Walmert AMP.  "  
           "You perform your hit single 'You Git Pull at my Heart'     "            
           "Everyone agrees its- pretty good like a 6/10.              "
           delimited by size into event-text(30).
           move 400 to event-cost(30).

           string 
           "You are asked to give a speech at the end of NextGen       "            
           "'183 days. That's how many days we were given to learn the "  
           "Technology and skills to be successful.' you say proudly.  "
           delimited by size into event-text(31).
           move 300 to event-cost(31).

           string 
           "Its Presentation Day. Fred says he made a last minute push."            
           "The whole product explodes. Everyone is sad. You are sad.  "  
           "You refund everyone for their time. -$1000.                "
           delimited by size into event-text(32).
           move -1000 to event-cost(32).

           string
           "The office is setting up for Halloween. You are excited.   "
           "You love putting together obscure costumes!                "  
           "No one understands your Miami Vice Ace Hellboy mashup      "
           delimited by size into event-text(33).
           move -200 to event-cost(33).

           

       end program event.