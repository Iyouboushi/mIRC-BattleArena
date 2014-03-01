=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 2.4
Programmed by James "Iyouboushi" (Iyouboushi@gmail.com)
FREEWARE!
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Table of Contents:
 About
 Setup
 What's New?
 Patches
 Scripters
 Thanks
 Contact

 _______________________________________________________________________
/                                                                       \
|                                ABOUT                                  |
\_______________________________________________________________________/


This bot is an mIRC game in which you join and kill monsters and bosses to gain orbs and new
weapons/skills/techniques.  It's similar to the hit PS2/PS3 series "Devil May Cry", as that's 
really the inspiration I drew from when I started working on it, but it includes more than just 
DMC monsters/bosses/weapons/items.   The whole purpose was to make an mIRC game that is completely
automated in terms of the battle system. There doesnÅft need to be a DM around to do !next and control
monsters, like in my other major mIRC bot ("Kaiou").

Here players join the battle when the bot announces an open battle. After a few minutes, it will
generate monsters/bosses and have them join the battle and the battle will start. When itÅfs a
monsterÅfs or bossÅf turn, they will automatically do their things. When itÅfs the playerÅfs turn,
thereÅfs a few commands you can do (attack with a weapon, attack with a technique, do a skill, use an
item). If the player idles for too long the bot will force their turn and skip over them. This is
done so that someone canÅft disappear for an hour and cause the battle to drag on forever.

ThereÅfs a bunch of weapons that can be bought and each weapon has a few techniques attached to them.
Unlike in Kaiou, you canÅft make your own techniques but rather have to buy them using red orbs that you
earn from battle. You buy weapons using black orbs when you obtain via winning boss fights and being alive
at the end of one.

As for the main purpose of the game.. well, the only real purpose is to see how long of a winning streak
players can achieve.  The game is designed so that people can hop in and out easily at nearly any time,
just as a way to basically kill some boredom.  There is no ultimate goal to obtain or defend.


 _______________________________________________________________________
/                                                                       \
|                                 SETUP                                 |
\_______________________________________________________________________/


Getting it set up is easy this time around assuming you unpack the zip in a good location on
your computer.  


SETUP:

 1. Do a CLEAN install to C:\BattleArena\  with the complete zip package of the bot.
 2. Patch the bot to the latest versions if there are any patches.
    don't skip versions unless I specifically say it's all right.  
    ALSO NOTE: DO NOT HAVE THE BOT RUNNING WHEN YOU APPLY PATCHES!
 3. Run the mirc.exe included with Complete Package.
 4. The bot will attempt to help you get things set up.  Set the
    bot owner's nick and the IRC channel you wish to game in.  Be sure to set a 
    password for the bot that you'll register to nickserv with.
 5. (as with all mIRC programs) change the nickname and add a server
 6. Connect.
 7. Using another IRC connection as the bot owner's nick, use !new char (nick)
    without the () to get the character creation process started.
 8. Follow what the bot tells you to do.  Be sure to check out player_guide.txt as well.


Note, you do NOT have to install it to C:\BattleArena\ However, it's recommended.

With version 2.4 the bot SHOULD work if you put the bot in a folder that has spaces 
(such as C:\Program Files\BattleArena)  but it is still recommended to not do that if 
you can avoid it.

   
 _______________________________________________________________________
/                                                                       \
|                             WHAT'S NEW?                               |
\_______________________________________________________________________/


As usual be sure to read the versions.txt in the documentation folder
for a full list of everything this version does.  Listed below are some 
of the highlights.


* Added the ability to allow players to let other players control their characters.
This is a handy way for people who have multiple characters to control them easier
or allow friends to control their characters for them while AFK (or whatever reason).
The commands: 
 !access add playername - Adds a player to the access list
 !access remove playername - Removes a player from the access list.
 !access list - Lists who can control your character
To actually control the character, use the same commands as the bot admin commands, 
such as: name attacks target or name does skillname   ** This does not change 
anything with bot admins. They can still control everything like they did prior.  
This also does not work in DCC mode due to the way DCC mode works.

* Added a bunch of new items, accessories and armor pieces.

* Added more monster abilities
Monsters can now use Quicksilver and can have auto-regen.

* Added Shop NPCs
If you are running your own copy of the game for the first time you might notice 
that there's not that many items in the shop.  Well this is because there are 
Shop Merchants who will arrive as certain requirements are filled.  When the 
merchants arrive more items will appear in the store.  These merchants can also
be kidnapped when players lose certain battles and rescued when they win certain
battles.

* Added a damage modifier in which size of the weapon vs monster size plays a part.
Small weapons are +40% damage against small monsters, neutral against medium 
monsters and -40% damage on large monsters.

Medium weapons are +40% damage on medium monsters, neutral against small monsters 
and -30% damage on large monsters.

Large weapons are +40% damage on large monsters, neutral on medium monsters 
and -40% damage on small monsters.


Changes:
- Changed portal items so that only 8 per character can be used a day (resets at midnight bot's time).
- Changed the way the bot does a few timers to try to prevent an error in mIRC from killing the game.
- Changed the first round protection so that it includes the Allied Forces President.
- Changed !count to work in a query message/private.
- Changed the GIVES command to no longer allow exclusive items to be traded.
- Changed !techs to show techs in a maroon color if you don't have enough TP to perform that technique.
- Changed the shop for listing techs to show techs in a maroon if you don't have enough base TP to use
  the tech if purchased.
- Changed !reload battle streak to not clear the streak from the player's file.
- Changed !save battle streak to not allow players to save streaks that are greater than 50 levels higher 
  than their levels.
- Changed the way the !speed skill works slightly.
- Changed !reforge to not work inside battles
- Changed the way red orbs are rewarded to people whose levels are way lower than the current battle streak.
  If the streak is 1000+ levels higher than the current level, the orbs are nerfed down to 1.5% of the orb total.
  If the streak is 500-1000 levels it's nerfed down to 2% of the orb total.
  If the streak is 100-500 levels higher it's 4.5% of the orb total.  Players leveled above or within 100 have no penalty.
- Changed the battle list to show monsters/players who have fled in red to help identify them.
- Changed some code to hopefully make it so the bot can be run in folders that have spaces in them. I'd still recommend the
  bot be run in a non-space folder (such as C:\BattleArena\) but it shouldn't come to a grinding halt any more if you don't.

Fixes:
- Fixed the "Save the President" battle types so that ignored captures will actually be counted correctly now.
- Fixed an issue with certain armor pieces.
- Fixed an issue in which the WeaponLock skill timer was not resetting after each battle.
- Fixed an issue where mimics could spawn on portal battles.
- Fixed an issue with certain lists being cut off.
- Fixed an issue with staggering monsters.
- Fixed an issue where players could absorb more IG than a monster had with the AbsorbIG augment.
- Fixed an issue in which healer and portal type monsters can counter melee attacks.
- Fixed an issue in which clones wouldn't die if the owner died via magic effect or poison. 
- Fixed countless mistakes in monster and boss files.
- Fixed an error with weapon boosts.
- Fixed a bug with certain ignitions not reverting properly when the user runs out of IG.

Again, this isn't everything. Be sure to read the versions.txt in the documentation folder for a full 
list of everything 

 _______________________________________________________________________
/                                                                       \
|                               PATCHES                                 |
\_______________________________________________________________________/



Patches are made when I feel there are enough errors or new 
ideas to implement that it deserves to be done.  In other words, you shouldn't 
ask when a patch will be made and released.  Just keep an eye on the website or
message board occasionally and see if I've added a topic about a patch in development 
or if there has been one released recently.  


 _______________________________________________________________________
/                                                                       \
|                              SCRIPTERS                                |
\_______________________________________________________________________/


If you're a scripter who likes to play around or might want to add
something new, this section is for you.

First off, although a lot of the code is new, or improved from Kaiou's source,
there are still tons of code that could probably be rewritten and improved.

If you want to recode stuff, feel free.  I've got nothing against it.  I really
wish you luck.  If you manage to vastly improve anything, I'd love to see it.
Just send me a quick email (listed at the bottom of this document).  


 _______________________________________________________________________
/                                                                       \
|                                THANKS                                 |
\_______________________________________________________________________/


These are people who have helped me by helping me test, making monsters/weapons/etc,
finding bugs, or just by giving me some ideas.


Scott "Smz" of Esper.net
He helped me with a bunch of ideas, made monsters, made bosses, made tons
of armor.  Not only that, he was the first beta tester of version 1.0; 
Without him, I don't think I could have done this.

Andrio of Esper.net 
Helped me test out the bot and found a few glitches that needed to be fixed. 
Not to mention created a debug script that helped find many errors in 
monster/npc/boss files.

AuXFire of Hawkee
Caught a major bug with the passwords which made changing your password 
from the default impossible.

Raiden of Esper.net
This guy has helped me almost as much as Smz has. He's found countless 
bugs, gave me ideas for several accessories and skills and helped host 
the bot on Esper.net.

Sealdrenxia of Twitter
Discovered a huge bug with !new char that let players use the 
command over and over to get free orbs.

Rei_Hunter of Esper.net
Helped give me a ton of ideas for the bot (including, but not limited to, 
moving cooldown timers to the skills.db, monsters being able to absorb 
elements for healing, AOE healing, and the ability for monsters to 
ignore darkness/rage mode).

Trunks on Esper.net
Since he was translating the bot into German, it sparked the idea of 
the translation.dat file to try and make the bot a little more friendly for translation.

Roy of Esper.net
He helped test a few things, found a few bugs and suggested 
the scoreboard.

Wims of mIRC's official forum
Helped push me into the correct direction for improving many 
blocks of code to make them faster and more efficient.

W3TPantsu of Esper.net
Helped find countless bugs that have been fixed.

Pangaea from my forum
Had the idea for the scoreboard generating an HTML file to
make it easier to post scores and stats online.


 _______________________________________________________________________
/                                                                       \
|                               CONTACT                                 |
\_______________________________________________________________________/


If, for whatever reason, you need to contact me.. my email address is
provided:  Iyouboushi@gmail.com  or you can contact me via twitter:
twitter.com/Iyouboushi

PLEASE, PLEASE, PLEASE, PLEASE, PLEASE, PLEASE, do NOT contact me about HELP
running this bot.  I seriously do not have enough time to help everyone. If
you're really having trouble, check out the message board:

http://iyouboushi.com/forum/index.php?/topic/890-battle-arena-help-thread/

You'll have to make an account (free) to post. But you're more likely to
receive help with the bot there.

HOWEVER, if you run into a serious error, DO (PLEASE) email me about the error.  
I will try to correct all errors for a later patch.  So definitely let me know
about errors.