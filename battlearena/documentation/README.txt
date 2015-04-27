=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 3.0
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

* New Method of Doing Monster/Summon/NPC Stats Upon Summoning to Battlefield
The way the bot determines the stats for monsters, bosses, summons and npcs
when they're summoned to the battlefield has been changed quite a bit. It
should be more balanced now.

* Added a new battle type: Defend Outpost
In this battle type players will have to survive 5 waves of monsters in
order to successfully defend an Allied Forces HQ Outpost.

* Added a new battle type: Assault
In this type players will have to defeat monsters in order to 
weaken an enemy outpost's strength meter and capture it. 

* Added Capacity and Enhancement Points. 
10,000 Capacity Points will equal 1 Enhancement Point. Players gain capacity
points by being in battles that are higher than streak 100. Note that the 
player level has to be within 10 of the streak in order to gain capacity points. 
After streak 500, the amount is 500+(10% of streak level).   Enhancement
points can then be used in the shop to purchase additional skills and stat
enhancements.

* Added the ability for monsters and npcs to be able to use battle items.
Watch out players! Some monsters now have the ability to use items in
battle.

* Added NPC Trust Items
These special items will summon an NPC companion to fight alongside you
if you are playing solo.  NPC Trust Items can be purchased in the shop
using Login Points--a special currency that you get each new day that
you log into the game (using !id).  Login Points accumulate every day
and do not go away until they have been spent.

* Added the SPIRIT OF THE HERO buff
Are you tired of not being able to do anything in battle because your
friends are fighting in battle levels that are way higher than your 
own? Well, never fear.  With the Spirit of the Hero buff it will
automatically set you somewhat close to the current battle level
allowing you to participate! The trade off is that you will receive
a little bit less orbs at the end of battle compared to the others.



Changes:
- Changed the !augment commands to work in private or channel. 
- Changed the portal battles so that they have a level cap. 
- Changed the shop to allow players to view and buy techniques that are on the left-hand weapon.
- Changed the drops in the bot
- Changed the lockpicking skill to be 3% per level, up from 2%.
- Changed Evil Doppelgangers so that they are generated correctly if the user is level synced.
- Changed chests so that red chests can never spawn mimics.
- Changed the GIVES command so that players can now give red orbs to certain NPCs.  
- Changed the way the bot picks NPCs to have more settings like bosses/monsters
- Changed the scoreboard.html to include the level of the player
- Changed the drunk status to last 2 rounds
- Changed the GIVES message to hopefully show grammatically correct lines
- Changed the way the bot handles negative status effects on targets.
- Changed the way the bot does all of the status timers to make it consistent
- Changed the modifier checks so that they will also check for weapon names
- Changed the way the bot displays damage (purple = resisted, orange = enhanced)
- Changed the way the bot displays the "battle open" message 
- Changed the chance of a rescue allied president battle to 25% and lowered the streak from 100 to 20. 
- Changed how the allied forces president is generated slightly (stat-wise)
- Changed the chance of certain special boss types of occurring by a small amount.
- Changed the way the bot boosts portal monsters, hopefully keeping them closer to the synced levels
- Changed the way the bot does the stats for monsters, npcs and summons upon summoning to the battlefield.
- Changed the way the HP for monsters/summons/NPCs/bosses are boosted at the start of battle
- Changed demon portals so that monsters spawning out of them will be slightly less than the battle streak.
- Changed the code to allow partial target name matches on attacks and techs. 
- Changed the way players purchase stats; they must be kept somewhat close to each other now.

Fixes:
- Fixed an issue with songs showing resists on targets who shouldn't be affected by the song to begin with.
- Fixed an issue with counter attacks showing the wrong pronouns sometimes.
- Fixed an issue with lost souls appearing in gauntlet battles.
- Fixed an issue where instruments could be used with !use
- Fixed an issue with the mech shop so that cores and weapons that cost 0 won't show up for purchase.
- Fixed an issue with the snatch error message showing the wrong name
- Fixed an issue with monsters being unable to take action while charmed.
- Fixed an issue with techniques doing too much damage when a player was level synced.
- Fixed an issue in which Ghost Turkey could show up in other months besides November
- Fixed an issue with !view-info style doppelganger getting cut off
- Fixed an issue with the bot not checking left-handed weapons for augments
- Fixed a bug with !augment list that would say players had no augments even if they did.
- Fixed a bug with !fullbring when used with +TP items.
- Fixed a bug in which Inactive monsters would attack even while inactive if they went first in battle
- Fixed a bug with the drunk status effect
- Fixed a bug with !augments list not showing in private even if the command was used in private
- Fixed a bug with !unequip armor
- Fixed a bug with shadow clones attacking their owners in PVP mode
- Fixed a bug with shadow clones attacking themselves in PVP mode
- Fixed a bug with items occasionally not showing damage correctly 
- Fixed a bug in which players could trade armor they were still wearing
- Fixed multiple typos and errors found in weapons.db/items.db/techniques.db (courtesy of Andrio)

Removals:
- Removed the following monsters: Final_Guard, Prime_Vise, Excenmille, NajaSalaheem, Wind-UpShantotto
- Removed the following NPCs: Nauthima
- Removed the following bosses: Adlanna, Eldora, EldoraAdlanna, NauthimaTiranadel, RuneFencer_Nauthima
- Removed Battle Formulas 1 & 2. The bot now only has 1 battle formula
- Removed the !toggle battle formula bot admin command
- Removed the bot setting the user levels of bot owner/admins upon starting to prevent a security hole

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