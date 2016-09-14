BATTLE ARENA BOT 
--------------

## ABOUT

Battle Arena is a text game written in mIRC's scripting language.  This is a game of good vs evil and was originally inspired heavily by the hit PS2/PS3 series "Devil May Cry".  The gist is that players will join to kill monsters and bosses while gaining new weapons, skills and techniques. Over time the bot has expanded and has become a light RPG with stats, NPCs and special boss battles.

As for the main purpose of the game.. well, the only real purpose is to see how long of a winning streak players can achieve.  The game is designed so that people can hop in and out easily at nearly any time, just as a way to basically kill some boredom.  There is no ultimate goal to obtain or defend.

Once set up the game is entirely automatic and does not need anyone to run it.

A full in-depth guide with commands and more in-depth information can be found on the Battle Arena wiki:  http://battlearena.heliohost.org/doku.php?id=start


## SETUP

Getting it set up is easy.

 1. Clone this repository or download the ZIP.  If you download the zip, unzip it into a folder of your choice (I recommend C:\BattleArena)
 2. Run the mirc.exe that is included.
 3. The bot will attempt to help you get things set up.  Set the bot owner's nick and the IRC channel you wish to game in.  Be sure to set a password for the bot that you'll register to nickserv with.
 4. (as with all mIRC programs) change the nickname and add a server
 5. Connect.
 6. Using another IRC connection as the bot owner's nick, join the game channel you set and use !new char (nick) without the () to get the character creation process started.
 7. Follow what the bot tells you to do.  Be sure to check out guide - player's guide.txt or the game's Wiki (http://battlearena.heliohost.org/doku.php?id=start) as well.

Note, you do NOT have to install it to C:\BattleArena\ However, it's recommended to make life simple.

   
## WHAT'S NEW?

If you have used this bot before and are updating you may be wondering what all has changed.  Well, the versions.txt in the documentation folder has a full list of changes. Listed below are some of the main highlights since version 3.1. 

ADDITIONS:
* Added the Supply Run type battle. In this battle type players need to protect a wagon against a wave of monsters.
* Added new augments
* Added new monsters and new monster dynamic names
* Added new enhancement point shop items/skills
* Added new items
* Added new achievements
* Added new Torment levels to challenge players
* Added new dungeons
* Added the ability for players to obtain a second accessory slot
* Added a new (optional) battle system that uses Action Points to perform actions.

CHANGES:
* Changed the max number of access-controlled characters players can enter into battle
* Changed portal battles to make it easier for everyone to get a drop
* Changed the amount of HP monsters have
* Changed the way the bot displays the weather changes so that it's customizeable by bot owners
* Changed maximum amounts of certain skills and styles for players who use Final Getsuga and are reset
* Changed what !items displays and moved several other item types to their own commands
* Changed alchemy so that it is now possible to craft weapons directly
* Changed armor so that it no longer adds the stats directly to the player's file (except HP and TP)
* Changed armor so that it no longer affects players' levels
* Changed a few things with dragon hunting for when players' average level hits a certain amount
* Changed capacity point gain rate to be increased by the number of achievements the player has
* Changed the dynamic naming system slightly

FIXES:
* Fixed a bug with Stoneskin in the enhancement shop
* Fixed a bug with AI in dungeons
* Fixed a bug with clones being able to use items
* Fixed a bug in which enhancement skills (0 cost) would show up in !shop list skills
* Fixed a bug where using !misc items multiple times would cause duplicates to show up
* Fixed a bug where NPCs/trusts could survive no-npc/no-trust battle conditions on uncapped portals
* Fixed a bug where it was possible to get infinite HP while using an ignition
* Fixed a bug that was preventing accessories with more than one type working correctly.
* Fixed a bug with the techonly AI types
* Fixed two bugs with the Predator fight
* Fixed an issue where certain battle types could override mimic battles
* Fixed an issue with absorb inside of dungeons and torment
* Fixed an issue with clones being able to use skills multiple times without a cooldown
* Fixed a description issue with ToxicMelody

REMOVALS:
* Removed certain monsters (their names have been added to dynamic naming lists)

Again, this IS NOT everything. Be sure to read the versions.txt in the documentation folder for a full list of everything as the list is quite extensive.


## THANKS

These are people who have helped me by helping me test, making monsters/weapons/etc, finding bugs, or just by giving me some ideas.  This bot would not as good/far along as it is without these fine folks.

* Scott "Smz" of Esper.net
* Andrio of Esper.net
* AuXFire of Hawkee
* Raiden of Esper.net
* Sealdrenxia of Twitter
* Rei_Hunter of Esper.net
* Trunks of Esper.net
* Roy of Esper.net
* Wims of mIRC's official forum
* W3TPantsu of Esper.net
* Pangaea from my forum
* Anthrax from my forum
* Karman from my forum
* Pentium320 from Esper.net
* baracouda from Esper.net
