BATTLE ARENA BOT 
--------------

## ABOUT

Battle Arena is a text game written in mIRC's scripting language.  This is a game of good vs evil and was originally inspired heavily by the hit PS2/PS3 series "Devil May Cry".  The gist is that players will join to kill monsters and bosses while gaining new weapons, skills and techniques. Over time the bot has expanded and has become a light RPG with stats, NPCs and special boss battles.

As for the main purpose of the game.. well, the only real purpose is to see how long of a winning streak players can achieve.  The game is designed so that people can hop in and out easily at nearly any time, just as a way to basically kill some boredom.  There is no ultimate goal to obtain or defend.

Once set up the game is entirely automatic and does not need anyone to run it.

A full in-depth guide with commands and more in-depth information can be found on the Battle Arena wiki:  http://battlearena.heliohost.org/doku.php?id=start


## SETUP

Getting it set up is easy assuming you unpack the zip in a good location on your computer.

 1. Do a CLEAN install to C:\BattleArena\  with the complete zip package of the bot (either from this repository or from my website).
 2. Patch the bot to the latest versions if there are any patches. Don't skip versions unless I specifically say it's all right.  ALSO NOTE: DO NOT HAVE THE BOT RUNNING WHEN YOU APPLY PATCHES!
 3. Run the mirc.exe included with Complete Package.
 4. The bot will attempt to help you get things set up.  Set the bot owner's nick and the IRC channel you wish to game in.  Be sure to set a password for the bot that you'll register to nickserv with.
 5. (as with all mIRC programs) change the nickname and add a server
 6. Connect.
 7. Using another IRC connection as the bot owner's nick, use !new char (nick) without the () to get the character creation process started.
 8. Follow what the bot tells you to do.  Be sure to check out player_guide.txt as well.

Note, you do NOT have to install it to C:\BattleArena\ However, it's recommended.

   
## WHAT'S NEW?

If you have used this bot before and are updating you may be wondering what all has changed.  Well, the versions.txt in the documentation folder has a full list of changes. Listed below are some of the main highlights since version 3.0.1. 

ADDITIONS:
* Added Dungeons! Players can obtain keys and start special dungeon battles that take them through a zone full of monsters and bosses.
* Added Dragon Hunting.  Dragons can spawn and create lairs around the land and players need to hunt them down.
* Re-Added nearly every battle formula the bot has had since its inception. This can be toggled by bot owners to pick the one they like the most.
* Added more armor, items and new portal battles for everyone to enjoy
* Added new system.dat flags
* Added new bot admin commands
* Added new monster/boss flags

CHANGES:
* Changed PVP battles so that they can be level capped
* Changed the way the shop works with upgrading weapons to allow +weapon level items to be of use
* Changed the way HP healing items work so that it's a percent of a target's max HP
* Changed summons and clones so that outside of portal battles they are skipped on the first turn they're used
* Changed the armor equip command so that players do not need to !unequip armor before !equip armor

FIXES:
* Fixed errors with !misc info and !view-info
* Fixed errors with the enhancement point shop
* Fixed a bug with AI vs AI battles
* Fixed a bug with !flee not counting the number of times fled properly
* Fixed a bug in which provoked NPCs may try to attack dead targets that have been erased due to multiple waves
* Fixed a bug in which player clones would die if they were summoned before a no-trust or no-npc portal battle happened
* Fixed a bug in which NPCs who had mechs would try to use them in no-mech battlefield conditions.
* Fixed a bug with en-spells counting towards the elemental spell totals in misc info when they shouldn't have been
* Fixed an issue with !view-info and the pokeball summon item
* Fixed an issue with %enemy in a provoke skill description not showing the right name
* Fixed an issue with "Conserve TP" showing up in both status and skill lists.  It should only be in skills now.
* Fixed an issue where a person who was asleep would still get an extra turn occasionally
* Fixed an issue with charm not wearing off immediately if the charmer was erased due to multiple wave
* Fixed an issue with berserker NPCs 

REMOVALS:
* Removed the elements from NPC weapons
* Removed attack_Aettir.txt, and attack_ChatoyantStaff.txt as they are no longer needed

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
