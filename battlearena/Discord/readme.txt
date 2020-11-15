=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Getting the Game to Run on Discord
https://github.com/Iyouboushi/mIRC-BattleArena
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
This text file will help you get the bot running on Discord.  

===================================
Set up the Bridge
===================================
In order for BA to work on Discord there needs to be an IRC<->Discord bridge bot set up and running in the same channel as Battle Arena.  Setting up a bridge bot is really going to be up to you and will not be in the mIRC scripting language.  As such it's really beyond the scope of the BattleArena project.

Still, I have included one in this folder that I have modified from milandamen on Github (original project: https://github.com/milandamen/Discord-IRC-Python ) to work correctly for BA.  It is in Python so you will need to know how to run Python programs on your machine.

If you choose to modify a different bridge bot or create your own make sure that when someone types on Discord it shows up in your BA Channel as the following:

[Discord] <PersonTalking> text here

For example:

[Discord] <Iyouboushi> !shop list items


The Discord side of BattleArena will not work correctly if the text is not formatted in this fashion.

===================================
2) Set up BattleArena Correctly
===================================
Once you have a working bridge you are almost done and ready to roll.  Next up you need to configure BA to work correctly:

* Open system.dat and change BotType=   to BotType=Discord
* Open system.dat and change DiscordBridgeName=  to the bridge bot's IRC nick.
* Open system.dat and change AllowColors=true to AllowColors=false   While it will work with it set to true, it looks better off.
* Open BattleArena and go to Tools -> Script Editor -> File -> Load -> [path to BA]\Discord\discord.mrc

Everything should be syncing now between IRC and Discord for the game.


===================================
NOTES
===================================
Note as of 11/13/2020 there are only a few commands that are actually working.  This is still a major work in progress.

Also, I personally do not find playing BattleArena via Discord all that enjoyable. There are no colors which means players will be unable to tell if their attacks are resisted or not.  It also may cause the bridge to get flooded out on IRC if too many players are trying to play at the same time and are doing too many actions at once.


