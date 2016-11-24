=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 3.2
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


Getting it set up is easy assuming you unpack the zip in a good location on
your computer.  


SETUP:

 1. Unzip the bot into a folder. I recommend C:\BattleArena\ just to make it easy
 2. Run the mIRC.exe that is included
 3. The bot will attempt to help you get things set up.  Set the bot owner's nick 
    and the IRC channel you wish to game in.  Be sure to set a password for the bot 
    that you'll register to nickserv with.
 4. (as with all mIRC programs) change the nickname and add a server
 5. Connect.
 6. Using another IRC connection as the bot owner's nick, use !new char (nick)
    without the () to get the character creation process started.
 7. Follow what the bot tells you to do.  Be sure to check out player_guide.txt as well.


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

* Added Legendary Armor
New Torment Rewards have been added!

* Added the Voucher System
Portal bosses now have the ability to give bronze/silver/gold vouchers to players who
don't win the stylish item. These vouchers can then be exchanged to obtain weapons
and armor pieces.  Use !voucher list and !voucher buy itemname

* Added new Augments and Accessory Types
Several new augments and accessory types have been added into the game.

* Added a Second Accessory Slot
Once Vasu the Jewler has arrived to the Allied Forces HQ players will be able to purchase
a second accessory slot with 10 enhancement points.

* Added a new player style: Wrestlemania
This style will allow players to use !wrestle on a target to do damage and attempt to
inflict stun. This style also increases damage done with HandToHand weapons.

* Added new dungeons
Added the level 20 dungeon: Antlion's Den, the level 50 dungeon Pirate's Cove,
thel evel 500 dungeon Impact Crater and the level 1000 dungeon: Tomb of Terror

* Added new Torment levels
Several new torment levels have been added to challenge players.

* Added Ammo
Several new weapons now require special ammo in order to use.

* Added Gear Sets
Creating a gearset will copy the currently equipped armor to a set that can quickly be 
re-equipped with one command. It is possible to create up to 3 sets to quickly swap between. 

Changes:
- Changed the max number of access-controlled characters players can enter into a battle. The max is now two per person.
- Changed the !add command to allow the ability for bot admins to add enhancement points
- Changed the !take command to allow the ability for bot admins to remove enhancement points and enhancement point skills
- Changed the shop stat ratio limits (1-50 have a .55 ratio, 50-1000 is .43 and 1000+ is .35)
- Changed the SSJ ignition
- Changed portal battles to make it easier for everyone to get a drop from the battle
- Changed crafting so that there's a 1% chance of doing a critical success in which the amount obtained will be doubled
- Changed the amount of HP monsters have
- Changed certain things in the battle formulas
- Changed utsusemi so that it no longer protects players when darkness hits
- Changed the amount of style points for the style ranking that are obtained with multi-hits.  
- Changed the way the skills keep track of the turn they are used and when they can be used again
- Changed the original "revive" type item to "AutoRevive"
- Changed the !equip and !wear accessory commands. Now use: !equip/wear accessory [1 or 2] accessoryname
- Changed the !unequip and !remove accessory commands. Now use: !unequip/remove accessory [1 or 2] accessoryname
- Changed capacity points so that they cannot be obtained from dungeons and torments
- Changed the Torment Orb recipes so that the max number of death's breath ever required is 5 (down from 10)
- Changed the amount of HP that torment monsters have in torments 10-15
- Changed the way the bot displays the weather changes so that it's customizeable by bot owners
- Changed the code for alchemy so that it is now possible to craft weapons directly
- Changed the code for the auction house so that is is now possible to bid on weapons directly
- Changed the dragonballs so that Shenron's Wish has to be activated with a command: !dragonballs summon


Fixes:
- Fixed a bug with Stoneskin in the enhancement shop
- Fixed a bug with the dynamic naming
- Fixed a bug with AI in dungeons
- Fixed a bug with clones being able to use items
- Fixed a bug that was preventing monsters from gaining more HP if more players entered the battle
- Fixed a bug in which enhancement skills (0 cost) would show up in !shop list skills
- Fixed a bug where using !misc items multiple times would cause duplicates to show up
- Fixed a bug where NPCs/trusts could survive no-npc/no-trust battle conditions on uncapped portals
- Fixed a bug that was preventing accessories with more than one type working correctly.
- Fixed a bug with the techonly AI types
- Fixed an issue where certain battle types could override mimic battles
- Fixed an issue where portal items were being cut off
- Fixed an issue with absorb inside of dungeons and torment
- Fixed an issue with clones being able to use skills multiple times without a cooldown
- Fixed a potential issue with certain items in the shop being cut off if there's too many
- Fixed a typo with Shenron's Wish
- Fixed a description issue with ToxicMelody



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