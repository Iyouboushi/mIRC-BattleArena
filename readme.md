BATTLE ARENA BOT 
--------------

## ABOUT

Battle Arena is a text game written in mIRC's scripting language.  This is a game of good vs evil and was originally inspired heavily by the hit PS2/PS3 series "Devil May Cry".  The gist is that players will join to kill monsters and bosses while gaining new weapons, skills and techniques. Over time the bot has expanded and has become a light RPG with stats, NPCs and special boss battles.

As for the main purpose of the game.. well, the only real purpose is to see how long of a winning streak players can achieve.  The game is designed so that people can hop in and out easily at nearly any time, just as a way to basically kill some boredom.  There is no ultimate goal to obtain or defend.

Once set up the game is entirely automatic and does not need anyone to run it.

A full in-depth guide with commands and more in-depth information can be found on the Battle Arena wiki:  https://github.com/Iyouboushi/mIRC-BattleArena/wiki


## SETUP

Getting it set up is easy.

 1. Clone this repository or download the ZIP.  If you download the zip, unzip it into a folder of your choice (I recommend C:\BattleArena)
 2. You can get mIRC at: https://www.mirc.co.uk/index.html  Then you can copy the exe over to the Battle Arena folder.
 3. The bot will attempt to help you get things set up.  Set the bot owner's nick and the IRC channel you wish to game in.  Be sure to set a password for the bot that you'll register to nickserv with.
 4. (as with all mIRC programs) change the nickname and add a server
 5. Connect.
 6. Using another IRC connection as the bot owner's nick, join the game channel you set and use !new char (nick) without the () to get the character creation process started.
 7. Follow what the bot tells you to do.  Be sure to check out guide - player's guide.txt or the game's Wiki (https://github.com/Iyouboushi/mIRC-BattleArena/wiki) as well.

Note, you do NOT have to install it to C:\BattleArena\ However, it's recommended to make life simple.

   
## WHAT'S NEW?

If you have used this bot before and are updating you may be wondering what all has changed.  Well, the versions.txt in the documentation folder has a full list of changes. Listed below are some of the main highlights since version 3.2. 

ADDITIONS:
* Added Kill Coins.  This new currency is used to purchase and upgrade skills and techniques. They accumulate when players kill monsters.
* Added the Mythic weapon system. Using OdinMarks (a special endgame currency) players can buy and upgrade a special weapon.
* Added a new battle type: Cosmic.  This is an endgame battle type.
* Added a minimum shop level for players who are level 100+
* Added the ability for monsters and NPCs to have multiple attacks per turn.

CHANGES:
* Changed the way multi-hit melee attacks are displayed
* Changed the amount of style points needed to achieve different ranks. It is harder on higher levels.
* Changed SpawnAfterDeath to allow multiple things to spawn.
* Changed active skills so that most need to be equipped to use. 

FIXES:
* Fixed a bug where water dragons were not spawning
* Fixed an issue with alchemy (thanks to Pentium320)
* Fixed an issue with +stat items (thanks to Pentium320)
* Fixed an issue where +portal usages weren't actually working correctly

Again, this IS NOT everything. Be sure to read the versions.txt in the documentation folder for a full list of everything as the list is quite extensive.


## THANKS

These are people who have helped me by helping me test, making monsters/weapons/etc, finding bugs, or just by giving me some ideas.  This bot would not as good/far along as it is without these fine folks.

* Scott "Smz" of Esper.net
* Andrio of Esper.net
* AuXFire of Hawkee
* Raiden of Esper.net
* Sealdrenxia of Twitter
* Rei_Hunter of Esper.net
* Roy of Esper.net
* Wims of mIRC's official forum
* W3TPantsu of Esper.net
* Pangaea from my forum
* Anthrax from my forum
* Karman from my forum
* Pentium320 from Esper.net
* baracouda from Esper.net
