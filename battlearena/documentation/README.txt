=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 3.1
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

ThereÅ's a bunch of weapons that can be bought and each weapon has a few techniques attached to them.
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

* Added the Dragon Hunt system
The game will now generate special dragon monsters that hide in lairs. Plaers
must use !dragon hunt to hunt for and discover these lairs to face the dragons
within.  Leaving the dragons alone is dangerous as they can kidnap NPCs for 
the evil forces.

* Added the Bounty System
The game will pick a random boss from any boss in the \bosses\ folder. If this
boss is defeated before the bot picks a new boss an orb bonus will be applied to
the battle. 

* Added the Torment Battle Type (aka Endgame)
Using Torment Orbs players can enter a 3-wave battle against any enemy in the game.
Winning will result in items that can be used to craft high level equipment and items.
Torment Orbs can be crafted using a new misc item, Death'sBreath and higher Torment Orbs
result in harder battles but more rewards.

* Added Dungeons
These are special battles that can be activated once per 24 hours by using special keys
bought in the shop once the new shop NPC shows up. The dungeons have a variety of monsters
and bosses within as well as unique accessory rewards.

* Added an October shop
During the month of October players can accumulate CandyCorn and spend it in a special
Halloween shop with unique items and armor.

* Added new Augments
Several new augments have been added into the game.

* Added a Resting Bonus
For every 1 hour that a player isn't in battle the player will receive +150 orbs to 
their next battle.  Note that at least one battle has to have happened before the 
player can start to accumulate this resting bonus.

* Added Breakable Objects to Battlefields
There's a 25% chance that one will spawn on certain battlefields. Although they are
technically monsters, they don't get turns and only have 1 HP. Just break them to 
help boost your style.

* Added Info Upon Logging In
Upon logging into the game players will be greeted with a bit of information including
the local bot time/date and how much of various currencies he/she has. A message of
the day (admin message) will also display if an admin has set one.

Changes:
- Changed the code for techs and items so that you can use ME as a valid target name to target yourself
- Changed the warmachine boss battle type to no longer spawn additional monsters alongside it
- Changed the boss "Magus" to "Maou_Magus" to stop an exploit with the trust NPC Magus.
- Changed the "TechBonus" augment so that it only applies to non-magic techs
- Changed the code for checking for an item drop so that it's centralized in one spot 
- Changed Player Access commands so that players must have logged in within the last week in order to be controlled.
- Changed PVP battles so that bot admins can specify a level cap for players to enter under. Use !startbat pvp # to set the cap
- Changed the skill Speed to consume 10-25% of a user's HP based on the skill's level
- Changed portal items so that they cannot be used if Shenron's Wish is on.
- Changed the maximum resist-skill that a player can have in a dungeon to 50, down from 100. This does not include accessories.
- Changed certain boss battles to hopefully give a slightly bigger orb reward
- Changed certain bosses/monsters/summons/npcs to have the ignore elemental message flag
- Changed some modifiers on certain monsters/bosses
- Changed gold chests to remove Big Whoop from them and to read from the black chests for portal items
- Changed ignitions to remove str/def/spd down as people were abusing that
- Changed the technique Torcleaver to not be magic and made its AoE damage and TP cost match the -jaII spells
- Changed the guardian style to be capped at level 5 in dungeons and portals
- Changed the streaks you can use a portal item on to 1-20. Anything higher will block portal usage.
- Changed the elemental weapon to use attack_elemental.txt since they don't technically use staves/wands
- Changed healing/battle items a little bit
- Changed elementals to use different techs based on streaks (a minor change)
- Changed the way the shop displays certain error messages and what it says when you use !shop by itself. 
- Changed the way summons and clones work when summoned outside of a portal battle. Now they are skipped 
  on the round they are summoned on and will only take action on the following round.
- Changed the "Battle open" message to show the current winning/losing battle streak at the end of the line.
- Changed HP healing items to work on a percent amount of a target's max HP rather than a static value.
- Changed portal battles so that the allied notes reward is split by the number of people who enter the battle
- Changed the shop so that the maximum amount play can upgrade a weapon via the shop to is level 250.
- Changed the armor equip command so that players do not need to !unequip armor before !equip armor 
  The bot will automatically remove the old armor before wearing the new one.
- Changed the shop so that shadow portals show up on their own line
- Changed the max amount of portal items players can use per 24 hours to 10 (up from 8)
- Changed the AI slightly to try and prevent NPCs from using techs that will heal monsters
- Changed the AI slightly to try and prevent NPCs from using techs that would inflict the same status a monster already has on
- Changed the code for how the bot generates the deathboards. 
- Changed the bot so that if the streak is automatically reset to 0 the next battle will be an AI vs AI battle
- Changed the max amount of enhancement points for HP
- Changed !npc status to be color-coded. Red means kidnapped, maroon means not found yet and green means at the HQ
- Changed code so that +1 accessories, weapons and armor all show up in blue. Legendary weapons and armor will show up in orange.
- Changed code so that Torment reward items (Horadric and crafting) show up in orange in the items list
- Changed the max level of the skill OrbHunter to 30. However, the base cost from 21+ is 2500 per level instead of 250.
- Changed the cost of the Orb Bonus potion effect
- Changed the chance of certain special bosses to occur
- Changed the orb penalty for Spirit of the Hero to be not as much
- Changed many lines in translation.dat to be consistent with equipment and weapon colors

Fixes:
- Fixed a typo that was preventing ignition augments from working right
- Fixed a typo in !misc info
- Fixed an issue with !view-info and the pokeball summon item
- Fixed an issue with %enemy in a provoke skill description not showing the right name
- Fixed an issue with "Conserve TP" showing up in both status and skill lists.  It should only be in skills now.
- Fixed an issue where a person who was asleep would still get an extra turn occasionally
- Fixed an issue with the DTrigger ignition description
- Fixed an issue with charm not wearing off immediately if the charmer was erased due to multiple wave
- Fixed an issue with berserker NPCs 
- Fixed minor issues with the various damage formulas
- Fixed a potential bug with the monster list
- Fixed a portal battlefield limitation issue that could be exploited
- Fixed the "On the Edge" achievement so that it actually gives the Super Potion item correctly
- Fixed the elemental spell totals in misc info being counted multiple times on AOEs
- Fixed a bug with orb rewards for players who are far under the streak and not using SotH
- Fixed a bug in which fists were being calculated wrong for their damage (being counted twice, basically)
- Fixed a bug in which NPCs who had mechs would try to use them in no-mech battlefield conditions.
- Fixed a bug with en-spells counting towards the elemental spell totals in misc info when they shouldn't have been
- Fixed a bug in which the elemental messages for en-spells were not showing upon melee hits
- Fixed a bug in which npcs and trusts weren't being killed in portals that had no-trust or no-npc set.
- Fixed a bug with AI vs AI battles when NPCs used shadow copy
- Fixed a bug with AI vs AI battles in which if the streak was less than 0 it wouldn't work properly
- Fixed a bug with !flee not counting the number of times fled properly
- Fixed a bug in which provoked NPCs may try to attack dead targets that have been erased due to multiple waves
- Fixed a bug in which player clones would die if they were summoned before a no-trust or no-npc portal battle happened
- Fixed a bug with the enhancement point shop that might prevent certain skills from showing up in the shop
- Fixed a bug that would prevent the wall of flesh from ever being chosen
- Fixed an exploit that allowed players to get around the melee penalty if the same weapon is used twice in a row


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

Anthrax from my forum
Helped to find bugs and offered suggestions on how to improve the bot.

Karman from my forum
Helped to find bugs and offered suggestions on how to improve the bot. 
Also gave me the idea for the Gremlins.


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