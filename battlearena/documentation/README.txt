=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 2.5
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
automated in terms of the battle system. There doesnft need to be a DM around to do !next and control
monsters, like in my other major mIRC bot ("Kaiou").

Here players join the battle when the bot announces an open battle. After a few minutes, it will
generate monsters/bosses and have them join the battle and the battle will start. When itfs a
monsterfs or bossf turn, they will automatically do their things. When itfs the playerfs turn,
therefs a few commands you can do (attack with a weapon, attack with a technique, do a skill, use an
item). If the player idles for too long the bot will force their turn and skip over them. This is
done so that someone canft disappear for an hour and cause the battle to drag on forever.

Therefs a bunch of weapons that can be bought and each weapon has a few techniques attached to them.
Unlike in Kaiou, you canft make your own techniques but rather have to buy them using red orbs that you
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

* Added Instruments and Songs!
Spoony the Bard is no longer a useless NPC.  Now he sells instruments and songsheets. Use the
songsheets on yourself to learn a song that you can then use in battle with a proper instrument.
Songs offer some bonuses to your team and status effects to your opponents.

* Added a new special boss fight: Wall of Flesh
It's basically an enhanced Demon Wall.  Bring your A-game and take out the wall.

* Added Dualwielding
This skill will allow a player to equip two weapons and use techniques from either
of the weapons without needing to switch. For melee attacks, the # of hits for the 
attack will be both weapon's # of hits combined.  For example, a 1 hit weapon + a 2 hit
weapon will give your attack 3 hits. Use !equip left weaponname and !equip right weaponname
If the weapon is a 2 handed weapon it will automatically adjust what you have equipped in
your hands.

* Added Shields
Shields are an extra way to protect yourself while using one-handed weapons. Shields are broken
into three size categories: small, medium and large.  Small shields will block more often but
will absorb less damage, medium is middle of the road and large will block the least but will
absorb the most.  Shields can be purchased from the shield merchant after he arrives at the
Allied Forces HQ.  Note that players need the dual wield skill in order to use a shield.

* Added "Players Must Die" Mode
Inspired by Dante Must Die mode in DMC, this mode makes monsters harder and makes it so
players will not restore full hp/tp at the end of battle.  Bot admins can use 
!toggle mode playersmustdie  to turn this mode on/off.

* Added the "Time of Day" and # of days to the bot.
The bot will cycle through morning->noon->evening->night at 2 battles per time.
Also added code for the bot to keep track of the number of days that the heroes 
have been fighting. Remember that the "day" it is is based on the cycle of 
morning to morning (every 8 battles by default).
With these additions, it is now possible for certain monsters to only appear
at certain times of the "day".

* Added the Allied Forces HQ Garden
The garden is an optional minigame that everyone can (and should!) contribute to. 
Basically you find seed and flower items from monsters and then plant them in the garden.
Check the garden once every 24 hours for the seeds to grow.  The garden has levels and
will level up after reaching a certain xp amount (which it obtains by people planting).
Read the section in PLAYER'S GUIDE for more information on this.'

* Added Death Conditions to Monsters
Certain monsters and bosses will only die if the right type of attack is used to kill them 
otherwise they will be revived with half HP. The conditions are: melee, magic, tech, item, 
renkei, status, and magic effect.


Changes:
- Changed the Auto Next so that it will boot anyone who misses 3 turns in a single battle out of the battle 
- Changed Lost Souls and Orb Fountains to explode once darkness hits.
- Changed !styles to allow the viewing of other player's styles (such as !styles Iyouboushi)
- Changed !view-info tech to show the stat modifier of techs.
- Changed NPCs to not show up during boss battles
- Changed the code for !weapons to be a little more efficient.
- Changed the code for !shop list weapons to be a little more efficient.
- Changed the max conquest points for players and monsters to be 6000.
- Changed the AI code for healer type AI. 
- Changed battlefields so that there's a 40% chance that the weather will randomly change.
- Changed Kikouheni so that it now adds the "weatherlock" condition to the battlefield. 
- Changed how the bot pulls the drop list for monsters/bosses to read from a drops.db file.  
- Changed how red orbs in chests works. 
- Changed the Guardian monsters to allow multiple targets that have to be killed in order to hurt the target
- Changed the level difference a player can be to a target and still have the magic effect work.


Fixes:
- Fixed a bug with !speed
- Fixed a bug in which Spoony the Bard could not be kidnapped.
- Fixed a bug in which techs done with weapons obtained via special items would do the wrong amount of damage.
- Fixed a bug where a target that dies and is revived and dies again will count as 2 deaths instead of 1. 
- Fixed an issue where weapons that have 0 cost (i.e. can't buy) are showing up in the shop
- Fixed an issue with chests being able to be opened multiple times if the bot is lagging.
- Fixed an issue where dead cover targets will still be shown being tossed by monsters.
- Fixed an issue with the shop where sometimes the skills would not be displayed correctly. 
- Fixed an issue in which !npc status wouldn display in the channel when used in a private message instead of private.
- Fixed an issue where doing 0 damage should no longer be able to stagger an enemy
- Fixed an issue where a target could be staggered even if the target was dodging/blocking/parrying/etc 
- Fixed an issue where targets protected by a guardian could still be hurt by magic effect damage
- Fixed an issue where it was possible to do actions while blinded/stunned/other turn-skipping statuses
- Fixed a potential issue with AI battles in which two healing types could be in battle together, thus never ending.


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