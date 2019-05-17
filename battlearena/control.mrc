;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BASIC CONTROL
;;;; Last updated: 05/17/19
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

raw 421:*:echo -a 4,1Unknown Command: ( $+ $2 $+ ) | halt
CTCP *:PING*:?:if ($nick == $me) haltdef
CTCP *:BOTVERSION*:ctcpreply $nick BOTVERSION $battle.version
on 1:QUIT: { 
  if ($nick = %bot.name) { /nick %bot.name | /.timer 1 15 /identifytonickserv } 
  .auser 1 $nick | .flush 1 
} 
on 1:EXIT: { .auser 1 $nick | .flush 1 | .flush 3 | .flush 50 | .flush 100 }
on 1:PART:%battlechan:.auser 1 $nick | .flush 1
on 1:KICK:%battlechan:.auser 1 $knick | .flush 1 
on 1:JOIN:%battlechan:{ 
  .auser 1 $nick | .flush 1 

  if ($readini(system.dat, system, botType) = TWITCH) {
    if ($isfile($char($nick)) = $true) { 
      $set_chr_name($nick) | $display.message(10 $+ %real.name %custom.title  $+  $readini($char($nick), Descriptions, Char), global) 
      var %bot.owners $readini(system.dat, botinfo, bot.owner)
      if ($istok(%bot.owners,$nick,46) = $true) {  .auser 50 $nick }

      mode %battlechan +v $nick
    }
  }
}
on 3:NICK: { .auser 1 $nick | mode %battlechan -v $newnick | .flush 1 }
on *:CTCPREPLY:PING*:if ($nick == $me) haltdef
on *:DNS: { 
  if ($isfile($char($nick)) = $true) { 
    var %lastip.address $iaddress
    if (%lastip.address != $null) { writeini $char($nick) info lastIP $iaddress }
  }
  set %ip.address. [ $+ [ $nick ] ] $iaddress
}

on 1:START: {
  echo 12*** Welcome to Battle Arena Bot version $battle.version written by James "Iyouboushi" *** 

  /.titlebar Battle Arena version $battle.version written by James  "Iyouboushi" 

  if (%first.run = false) { 
    set %bot.owner $readini(system.dat, botinfo, bot.owner) 
    if (%bot.owner = $null) { echo 04*** WARNING: There is no bot admin set.  Please fix this now. 
    set %bot.owner $?="Please enter the bot admin's IRC nick" |  writeini system.dat botinfo bot.owner %bot.owner | .auser 100 %bot.owner }
    else { echo 12*** The bot admin list is currently set to:04 %bot.owner 12*** 
    }

    set %battlechan $readini(system.dat, botinfo, questchan) 
    if (%battlechan = $null) { echo 04*** WARNING: There is no battle channel set.  Please fix this now. 
    set %battlechan $?="Please enter the IRC channel you're using (include the #)" |  writeini system.dat botinfo questchan %battlechan }
    else { echo 12*** The battle channel is currently set to:04 %battlechan 12*** }

    set %bot.name $readini(system.dat, botinfo, botname)
    if (%bot.name = $null) { echo 04*** WARNING: The bot's nick is not set in the system file.  Please fix this now.
    set %bot.name $?="Please enter the nick you wish the bot to use" | writeini system.dat botinfo botname %bot.name | /nick %bot.name }
    else { /nick %bot.name } 

    var %botpass $readini(system.dat, botinfo, botpass)
    if (%botpass = $null) { 
      echo 12*** Now please set the password you plan to register the bot with
      var %botpass $?="Enter a password that you will use for the bot on Nickserv"
      if (%botpass = $null) { var %bosspass none }
      writeini system.dat botinfo botpass %botpass
      echo 12*** OK.  Your password has been set to04 %botpass  -- Don't forget to register the bot with nickserv.
    }

    $system_defaults_check
  }

  if ((%first.run = true) || (%first.run = $null)) { 
    echo 12*** It seems this is the first time you've ever run the Battle Arena Bot!  The bot will now attempt to help you get things set up.
    echo 12*** Please set your bot's nick/name now.   Normal IRC nick rules apply (no spaces, for example) 
    set %bot.name $?="Please enter the nick you wish the bot to use"
    writeini system.dat botinfo botname %bot.name | /nick %bot.name
    echo 12*** Great.  The bot's nick is now set to04 %bot.name

    echo 12*** Please set a bot owner now.  
    set %bot.owner $?="Please enter the bot owner's IRC nick"
    writeini system.dat botinfo bot.owner %bot.owner
    echo 12*** Great.  The bot owner has been set to04 %bot.owner

    echo 12*** Now please set the IRC channel you plan to use the bot in
    set %battlechan $?="Enter an IRC channel (include the #)"
    writeini system.dat botinfo questchan %battlechan
    echo 12*** The battles will now take place in04 %battlechan

    echo 12*** Now please set the password you plan to register the bot with
    var %botpass $?="Enter a password"
    if (%botpass = $null) { var %bosspass none }
    writeini system.dat botinfo botpass %botpass
    echo 12*** OK.  Your password has been set to04 %botpass  -- Don't forget to register the bot with nickserv.

    set %first.run false
    .auser 100 %bot.owner

    $system_defaults_check
  }

  echo 12*** This bot is best used with mIRC version04 7.41 12 *** 
  echo 12*** You are currently using mIRC version04 $version 12 ***

  if ($version = 6.3) { echo 04*** While this used to be the recommended version for this bot, there are now some issues with readini and techniques.db.  Be aware that the game will not run properly any more with this version. Please upgrade to 7.41. 12 *** }
  if (($version > 6.3) && ($version < 7.41)) { echo 04*** Your version is older than the recommended version for this bot. Some things may not work right.  It is recommended you update. 12 *** }
  if ($version > 7.41) { echo 04*** Your version is newer than the recommended version for this bot. While it should work, it is currently untested and may have quirks or bugs.  It is recommended you downgrade to 7.41 if you run into any problems. 12 *** }

  if ($sha1($read(key)) != dd4b6aa27721dc5079c70f7159160313bb143720) { .remove key |  write key M`S)4:&ES(&=A;64@:7,@<G5N;FEN9R!T:&4@`D("871T;&4@`D$"<F5N82!"M871T;&4@4WES=&5M(&-R96%T960@8GD@`DH"86UE<R`"20)Y;W5B;W5S:&D@M+2T@079A:6QA8FQE(&9O<B!F<F5E(&%T.@,Q,A\@:'1T<',Z+R]G:71H=6(N?8V]M+TEY;W5B;W5S:&DO;4E20RU"871T;&5!<F5N80`` }
}

on 1:CONNECT: {
  ; Start a keep alive timer.
  /.timerKeepAlive 0 300 /.ctcp $!me PING
  /.timerAutomatedBattleTimerCheck 0 300 /system.autobattle.timercheck

  ; Join the channel
  /.timerJoin 1 2 join %battlechan
  /.timerCheckForExistingBattle 1 5 /control.battlecheck

  ; Get rid of a ghost, if necessary, and send password
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if ($me != %bot.name) { /.msg NickServ GHOST %bot.name %bot.pass | /.timerNick 1 3 nick %bot.name }
  $identifytonickserv

  ; Recalculate how many battles have happened.
  $recalc_totalbattles

  ; Unset the key in use check.
  unset %keyinuse
}

alias control.battlecheck { 
  ; If a battle was on when the bot turned off, let's check it and do something with it.
  if (%battleis = on) { 
    if ($readini($txtfile(battle2.txt), BattleInfo, Monsters) = $null) { $clear_battle }
    else { $next }
  }
  if (%battleis = off) { $clear_battle } 
}

on 1:DISCONNECT:{
  .timerBattleStart off
  .timerBattleNext off
  .timerBattleBegin off
  .flush 1 | .flush 3 | .flush 50
}

on 2:TEXT:!bot admin*:?: { $bot.admin(list, private) }
on 2:TEXT:!bot admin*:#: { $bot.admin(list) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admin Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admins have  the ability to zap/erase characters.
on 50:TEXT:!zap *:*: {  $set_chr_name($2) | $checkchar($2) | $zap_char($2) | $display.message($readini(translation.dat, system, zappedcomplete),global) | halt }
on 50:TEXT:!unzap *:*: {  
  if ($isfile($zapped($2)) = $false) { $display.private.message(04Error: $2 does not exist as a zapped file) | halt }
  $unzap_char($2) | $display.message($readini(translation.dat, system, unzappedcomplete),global) | halt
}

; Force the bot to quit
on 50:TEXT:!quit*:*:{ /quit $battle.version }

; Force the bot to do a system.dat default check
on 50:TEXT:!force system default check*:*: { 
  writeini version.ver versions systemdat $replace($adate, /, ) $+ _ $+ $ctime
  $system_defaults_check
  .msg $nick 03The bot has finished with the system.dat default check.
}

; Add or remove a bot admin (note: cannot remove the person in position 1 with this command)
on 50:TEXT:!bot admin*:#: {  
  if (($3 = $null) || ($3 = list)) { $bot.admin(list) }
  if ($3 = add) { $bot.admin(add, $4) }
  if ($3 = remove) { $bot.admin(remove, $4) }
}

on 50:TEXT:!bot admin*:?: {  
  if (($3 = $null) || ($3 = list)) { $bot.admin(list, private) }
  if ($3 = add) { $bot.admin(add, $4) }
  if ($3 = remove) { $bot.admin(remove, $4) }
}

; Dumps information into a text file for debug purposes.
on 50:TEXT:!debug dump*:*:{ 
  var %debug.filename debug_dump $+ $day $+ $rand(a,z) $+ $rand(1,1000) $+ $rand(a,z) $+ .txt
  .copy remote.ini %debug.filename

  write %debug.filename ------------------------------------------------------
  write %debug.filename debug location: %debug.location 
  write %debug.filename battlefield: %current.battlefield
  write %debug.filename battlefield event number: %battlefield.event.number
  write %debug.filename boss type: %boss.type 
  write %debug.filename portal bonus: %portal.bonus 
  write %debug.filename holy.aura: %holy.aura 
  write %debug.filename five min warning: %darkness.fivemin.warn  
  write %debug.filename battle.rage.darkness: %battle.rage.darkness 
  write %debug.filename battle conditions: %battleconditions 
  write %debug.filename ai target: %ai.target
  write %debug.filename ai tech: %ai.tech

  $display.message(04Variables File dumped as file: %debug.filename, private)
}

; Cleans out the main folder of .txt, .lst, and .db files.
on 50:TEXT:!main folder cleanup:*:{ 
  .echo -q $findfile( $mircdir , *.lst, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.db, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.txt, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir , *.html, 0, 0, clean_mainfolder $1-) 
  $display.message(04.db & .lst & .txt & .html files have been cleaned up from the main bot folder.)
}

; Bot admins can toggle the Enmity targeting system
on 50:TEXT:!toggle enmity*:*:{   
  if ($readini(system.dat, system, EnableEnmity) = false) { 
    writeini system.dat system EnableEnmity true
    $display.message($readini(translation.dat, system, EnmitySystemOn), global)
  }
  else {
    writeini system.dat system EnableEnmity false
    $display.message($readini(translation.dat, system, EnmitySystemOff), global)
  }
}

; Bot admins can toggle Health Bars (replaces the health status)
on 50:TEXT:!toggle healthbars*:*:{   
  if ($readini(system.dat, system, DisplayHealthBars) = false) { 
    writeini system.dat system DisplayHealthBars true
    $display.message($readini(translation.dat, system, DisplayHealthBarsOn), global)
  }
  else {
    writeini system.dat system DisplayHealthBars false
    $display.message($readini(translation.dat, system, DisplayHealthBarsOff), global)
  }
}

; Bot admins can toggle Players Must Die Mode
on 50:TEXT:!toggle mode playersmustdie*:*:{   
  if ($readini(system.dat, system,PlayersMustDieMode) = false) { 
    writeini system.dat system PlayersMustDieMode true
    $display.message($readini(translation.dat, system, PlayersMustDieModeOn), global)
  }
  else {
    writeini system.dat system PlayersMustDieMode false
    $display.message($readini(translation.dat, system, PlayersMustDieModeOff), global)
  }
}

; Bot admins can toggle the battle system type
on 50:TEXT:!toggle battle system type*:*:{   
  if ($return.systemsetting(TurnType) = action) { 
    writeini system.dat system TurnType Turn
    $display.message($readini(translation.dat, system, BattleSystemTypeTurn), global)
  }
  else {
    writeini system.dat system TurnType action
    $display.message($readini(translation.dat, system, BattleSystemTypeAction), global)
  }
}

; clear the battletable
on 50:TEXT:!clear battletable*:*:{   
  hfree BattleTable
  .remove BattleTable.file
  .msg $nick BattleTable cleared
}

; Bot admins can toggle Player Access commands on and off
on 50:TEXT:!toggle playerAccessCmds*:*:{   
  if ($readini(system.dat, system,AllowPlayerAccessCmds) = false) { 
    writeini system.dat system AllowPlayerAccessCmds true
    $display.message($readini(translation.dat, system, AllowPlayerAccessCmdsOn), global)
  }
  else {
    writeini system.dat system AllowPlayerAccessCmds false
    $display.message($readini(translation.dat, system, AllowPlayerAccessCmdsOff), global)
  }
}
; Bot admins can toggle Personal Difficulty
on 50:TEXT:!toggle personalDifficulty*:*:{   
  if ($readini(system.dat, system,AllowPersonalDifficulty) = false) { 
    writeini system.dat system AllowPersonalDifficulty true
    $display.message($readini(translation.dat, system, AllowPersonalDifficultyOn), global)
  }
  else {
    writeini system.dat system AllowPersonalDifficulty false
    $display.message($readini(translation.dat, system, AllowPersonalDifficultyOff), global)
  }
}

; Bot admins can toggle Spirit of the Hero
on 50:TEXT:!toggle SpiritOfTheHero*:*:{   
  if ($readini(system.dat, system,AllowSpiritOfHero) = false) { 
    writeini system.dat system AllowSpiritOfHero true
    $display.message($readini(translation.dat, system, SpiritOfHeroOn), global)
  }
  else {
    writeini system.dat system AllowSpiritOfHero false
    $display.message($readini(translation.dat, system, SpiritOfHeroOff), global)
  }
}

; Bot admins can toggle if the bot uses colors
on 50:TEXT:!toggle bot colors*:*:{   
  if ($readini(system.dat, system,AllowColors) = false) { 
    writeini system.dat system AllowColors true
    $display.message($readini(translation.dat, system, AllowColorsOn), global)
    halt
  }
  else {
    writeini system.dat system AllowColors false
    $display.message($readini(translation.dat, system, AllowColorsOff), global)
    halt
  }
}

; Bot admins can toggle if the bot uses bold
on 50:TEXT:!toggle bot bold*:*:{   
  if ($readini(system.dat, system,AllowBold) = false) { 
    writeini system.dat system AllowBold true
    $display.message($readini(translation.dat, system, AllowBoldOn), global)
    halt
  }
  else {
    writeini system.dat system AllowBold false
    $display.message($readini(translation.dat, system, AllowBoldOff), global)
    halt
  }
}

; Bot admins can toggle a message to show when players level up via the shop
on 50:TEXT:!toggle ShowPlayerLevelUpMsg:*:{   
  if ($readini(system.dat, system,ShowPlayerLevelUp) = false) { 
    writeini system.dat system ShowPlayerLevelUp true
    $display.message($readini(translation.dat, system, PlayerLevelUpMsgOn), global)
    halt
  }
  else {
    writeini system.dat system ShowPlayerLevelUp false
    $display.message($readini(translation.dat, system, PlayerLevelUpMsgOff), global)
    halt
  }
}

; Bot admins can toggle skill currency
on 50:TEXT:!toggle Skill Currency:*:{   
  if ($readini(system.dat, system,SkillCurrency) = coins) { 
    writeini system.dat system SkillCurrency orbs
    $display.message($readini(translation.dat, system, SkillCurrencyOrbs), global)
    halt
  }
  else {
    writeini system.dat system SkillCurrency coins
    $display.message($readini(translation.dat, system, SkillCurrencyCoins), global)
    halt
  }
}

; Bot admins can toggle tech currency
on 50:TEXT:!toggle Tech Currency:*:{   
  if ($readini(system.dat, system,TechCurrency) = coins) { 
    writeini system.dat system TechCurrency orbs
    $display.message($readini(translation.dat, system, TechCurrencyOrbs), global)
    halt
  }
  else {
    writeini system.dat system TechCurrency coins
    $display.message($readini(translation.dat, system, TechCurrencyCoins), global)
    halt
  }
}

; Bot admins can toggle if the discount card message is shown or not.
on 50:TEXT:!toggle discountcard message*:*:{   
  if ($readini(system.dat, system,ShowDiscountMessage) = false) { 
    writeini system.dat system ShowDiscountMessage true
    $display.message($readini(translation.dat, system, DiscountMessageOn), global)
  }
  else {
    writeini system.dat system ShowDiscountMessage false
    $display.message($readini(translation.dat, system, DiscountMessageOff), global)
  }
}

; Toggles the battle throttle function.
on 50:TEXT:!toggle battle throttle*:*:{   
  if ($readini(system.dat, system,BattleThrottle) = false) { 
    writeini system.dat system BattleThrottle true
    $display.message($readini(translation.dat, system, BattleThrottleOn), global)
  }
  else {
    writeini system.dat system BattleThrottle false
    $display.message($readini(translation.dat, system, BattleThrottleOff), global)
  }
}

; Bot Admins can toggle the bonus event flag.  Bonus Events = double the currency at the end of battle.
on 50:TEXT:!toggle bonus event*:*:{   
  if ($readini(system.dat, system, BonusEvent) = false) { 
    writeini system.dat system BonusEvent true
    $display.message($readini(translation.dat, system, BonusEventOn), global)
  }
  else {
    writeini system.dat system BonusEvent false
    $display.message($readini(translation.dat, system, BonusEventOff), global)
  }
}

; Bot Admins can toggle if damage is capped or not.
on 50:TEXT:!toggle damage cap*:*:{   
  if ($readini(system.dat, system, IgnoreDmgCap) = false) { 
    writeini system.dat system IgnoreDmgCap true
    $display.message($readini(translation.dat, system, DamageNotCapped), global)
  }
  else {
    writeini system.dat system IgnoreDmgCap false
    $display.message($readini(translation.dat, system, DamageNowCapped), global)
  }
}

; Bot Admins can toggle the automated battle system to be on/off
on 50:TEXT:!toggle automated battle system*:*:{   
  if ($readini(system.dat, system, automatedbattlesystem) = off) { 
    writeini system.dat system automatedbattlesystem on
    $display.message($readini(translation.dat, system, AutomatedBattleOn), global)
    if (%battleis = off) { $clear_battle }
  }
  else {
    writeini system.dat system automatedbattlesystem off
    $display.message($readini(translation.dat, system, AutomatedBattleOff), global)
  }
}

; Bot Admins can toggle the automated battle system to be on/off
on 50:TEXT:!toggle automated ai battle*:*:{   
  if ($readini(system.dat, system, automatedaibattlecasino) = off) { 
    writeini system.dat system automatedaibattlecasino on
    $display.message($readini(translation.dat, system, AutomatedAIBattleCasinoOn), global)
  }
  else {
    writeini system.dat system automatedaibattlecasino off
    $display.message($readini(translation.dat, system, AutomatedAIBattleCasinoOff), global)
  }
}

; Bot admins can toggle if the auction house changes the channel's topic or not
on 50:TEXT:!toggle auction house topic change*:*:{   
  var %allow.topic.change $return.systemsetting(AllowAuctionHouseTopicChange)
  if (%allow.topic.change = null) { var %allow.topic.change true | writeini system.dat system AllowAuctionHouseTopicChange true }

  if (%allow.topic.change = false) { 
    writeini system.dat system AllowAuctionHouseTopicChange true
    $display.message($readini(translation.dat, system, AllowAuctionHouseTopicChangeOn), global)
    $auctionhouse.topic
  }
  else {
    writeini system.dat system AllowAuctionHouseTopicChange false
    $display.message($readini(translation.dat, system, AllowAuctionHouseTopicChangeOff), global)
    var %current.topic $chan(%battlechan).topic
    var %previous.auction.topic $chr(124) [Current Auction: $readini(system.dat, auctionInfo, current.item) $+ ]
    var %current.topic $remove(%current.topic, %previous.auction.topic)
    var %new.topic %current.topic
    /topic %battlechan %new.topic
  }
}

; Bot admins can set the starting skill slots
ON 50:TEXT:!set skill slots*:*: {
  if ($4 !isnum 1-1000) { $display.private.message(04Invalid chance number. Valid numbers are 1-1000) | halt }
  writeini system.dat system StartingSkillSlots $4 | $display.private.message(03Starting Skill Slots set to: $4)
}

; Bot admins can set a chance of mimics appearing
; !mimic chance #  (where # is 1-100)
ON 50:TEXT:!mimic chance*:*: {
  if ($3 !isnum 1-100) { $display.private.message(04Invalid chance number. Valid numbers are 1-100) | halt }
  writeini system.dat system MimicChance $3 | $display.private.message(03Mimic chance set to: $3 percent)
}

; Bot admins can clear the portal usage of a player
; !clear portal usage playername
ON 50:TEXT:!clear portal usage *:*: {
  $checkchar($4)
  writeini $char($4) info PortalsUsedTotal 0
  $display.message($readini(translation.dat, system, ClearedDailyPortalUsage), global)
}

; Bot admins can clear the dungeonl usage of a player
; !clear dungeon usage playername
ON 50:TEXT:!clear dungeon usage *:*: {
  $checkchar($4)
  writeini $char($4) info LastDungeonStartTime 0
  $display.message($readini(translation.dat, system, ClearedDungeonUsage), global)
}

; Bot admins can manually set the winning streak.
on 50:TEXT:!set streak*:*:{   
  if ($3 = $null) { $display.private.message(04!set streak number) | halt }
  if ($3 < 0) {  $display.private.message(04The streak cannot be negative.) | halt }
  if (. isin $3) { $display.private.message(04The streak must be a whole number.) | halt }
  writeini battlestats.dat battle LosingStreak 0
  writeini battlestats.dat battle winningstreak $3
  $display.message(03The winning streak has been set to: $3, global)
}

; Bot admins can toggle the AI system on/off.
on 50:TEXT:!toggle ai system*:*:{   
  if ($readini(system.dat, system, aisystem) = off) { 
    writeini system.dat system aisystem on
    $display.message($readini(translation.dat, system, AiSystemOn), global)
  }
  else {
    writeini system.dat system aisystem off
    $display.message($readini(translation.dat, system, AiSystemOff), global)
  }
}

; Bot admins can toggle the battlefield events
on 50:TEXT:!toggle battlefield events*:*:{   
  if ($return.systemsetting(EnableBattlefieldEvents) != true) { 
    writeini system.dat system EnableBattlefieldEvents true
    $display.message($readini(translation.dat, system, EnableBattlefieldEventsOn), global)
  }
  else {
    writeini system.dat system EnableBattlefieldEvents false
    $display.message($readini(translation.dat, system, EnableBattlefieldEventsOff), global)
  }
}

; Bot Admins can toggle the first round protection on or off
on 50:TEXT:!toggle first round protection*:*:{   
  if ($return.systemsetting(EnableFirstRoundProtection) = false) { 
    writeini system.dat system EnableFirstRoundProtection true
    $display.message($readini(translation.dat, system, FirstRoundProtectionOn), global)
  }
  else {
    writeini system.dat system EnableFirstRoundProtection false
    $display.message($readini(translation.dat, system, FirstRoundProtectionOff), global)
  }
}

; Bot Admins can toggle the battle messages to the old or new style
on 50:TEXT:!toggle battle messages*:*:{   
  if ($return.systemsetting(showCustomBattleMessages) = false) { 
    writeini system.dat system showCustomBattleMessages true
    $display.message($readini(translation.dat, system, CustomBattleMessagesOn), global)
  }
  else {
    writeini system.dat system showCustomBattleMessages false
    $display.message($readini(translation.dat, system, CustomBattleMessagesOff), global)
  }
}

; Bot admins can adjust the "level adjust"
on 50:TEXT:!leveladjust*:*:{  
  if ($2 = $null) { $view.leveladjust }
  if ($2 != $null) {  

    if ($2 !isnum) {  $display.message($readini(translation.dat, errors, DifficultyMustBeNumber), private) | halt }
    if (. isin $2) {  $display.message($readini(translation.dat, errors, DifficultyMustBeNumber), private) | halt }
    if ($2 < 0) {   $display.message($readini(translation.dat, errors, DifficultyCan'tBeNegative), private) | halt }

    writeini battlestats.dat battle leveladjust $2
    $display.message($readini(translation.dat, system, SaveLevelAdjust), global)
    halt
  }
}

; Bot owners can change the time between battles.
on 50:TEXT:!time between battles *:*:{  
  if ($4 isnum) {
    writeini system.dat System TimeBetweenBattles $4
    $display.message($readini(translation.dat, System, ChangeTime), global)
  }
  else { $display.message(04You must enter a number for the time,global) | halt }
}

; Bot owners can change the time for !enter allownace.
on 50:TEXT:!time to enter *:*:{  
  if ($4 isnum) {
    writeini system.dat System TimeToEnter $4
    $display.message($readini(translation.dat, System, ChangeTimeForEnter), global)
  }
  else { $display.message(04You must enter a number for the time,global) | halt }
}

; Bot admins can set the MOTD, everyone else can just see it
on 3:TEXT:!motd*:*:{   
  $checkscript($2-) 

  if (($2 = $null) || ($2 = list)) { 
    if ($isfile($txtfile(motd.txt)) = $true) { $display.private.message(04Current Admin Message02: $read($txtfile(motd.txt))) }
    else { $display.private.message(04No admin message has been set) }
    halt
  }

  if (($2 = remove) && ($istok($readini(system.dat, botinfo, bot.owner), $nick, 46) = $true)) {
    if ($isfile($txtfile(motd.txt)) = $true) {  .remove $txtfile(motd.txt) }
    $display.private.message(04The admin message has been removed) 
    halt
  }

  if (($2 = set) || ($2 = add)) {
    if ($istok($readini(system.dat, botinfo, bot.owner), $nick, 46) = $true) {
      if ($3 = $null) { $display.private.message(04You need to supply a message to set) | halt }
      if ($isfile($txtfile(motd.txt)) = $true) {  .remove $txtfile(motd.txt) }
      write $txtfile(motd.txt) $3-
      $display.private.message(04Admin message has been set)
    }
  }
}

; Bot admins can force a random NPC to be saved with this command:
; @npc rescue
on 50:TEXT:@npc rescue*:*:{ 
  $shopnpc.rescue(100)
}

; Bot admin command for displaying active and zapped player lists.
on 50:TEXT:!display *:*:{  
  if (($2 = player) || ($2 = players)) { 
    ; create a temporary text file with all the active players
    .remove $nick $+ _players.txt
    .echo -q $findfile( $char_path , *.char, 0 , 0, buildplayerlist $1-)

    ; do a loop to show the text file to the bot admin
    var %number.of.entries $lines($nick $+ _players.txt)
    if (%number.of.entries = 0) { $display.private.message(04No players found) }
    else {
      $display.private.message(03Active Player List)

      var %entry.line 1
      while (%entry.line <= %number.of.entries) {
        $display.private.message.delay(02 $+ $read($nick $+ _players.txt, %entry.line))
        inc %entry.line 1
      }
    }

    ; erase the temporary text file
    .remove $nick $+ _players.txt
  }

  if ($2 = zapped) { 
    ; create a temporary text file with all the zapped players  
    .remove zapped.html
    .remove $nick $+ _zapped.txt

    write zapped.html <center><B> <font size=13> Zapped List</font> </B></center> <BR><BR> 
    write zapped.html <table border="1" bordercolor="#FFCC00" style="background-color:#FFFFCC" width="100%" cellpadding="3" cellspacing="3">
    write zapped.html  <tr>
    write zapped.html  <td><B>NAME</B></td>
    write zapped.html  <td><B>ZAPPED TIME</B></td>
    write zapped.html  </tr>

    write zapped.html  <tr>

    .echo -q $findfile( $zap_path , *.char, 0 , 0, buildzappedlist $1-)

    ; do a loop to show the text file to the bot admin
    var %number.of.entries $lines($nick $+ _zapped.txt)
    if (%number.of.entries = 0) { $display.private.message(04No zapped players found) }
    else {
      $display.private.message(03Zapped Player List - zapped time)

      var %entry.line 1
      while (%entry.line <= %number.of.entries) {
        var %delay.time %entry.line
        $display.private.message.delay.custom(02 $+ $read($nick $+ _zapped.txt, %entry.line), %delay.time)
        inc %entry.line 1
      }
    }

    ; erase the temporary text file
    .remove $nick $+ _zapped.txt
  }
}

; bot admin command to reset a player's password
; !password reset <playername>
on 50:TEXT:!password reset *:*:{  
  if ($3 = $null) { .msg $nick 04!password reset playername | halt }
  $checkchar($3)

  var %encode.type $readini($char($3), info, PasswordType) 
  if ($version < 6.3) { var %encode.type encode }
  if (%encode.type = $null) { var %encode.type encode | writeini $char($3) info PasswordType encode }

  var %newpassword battlearena $+ $rand(1,100)

  if (%encode.type = encode) { writeini $char($3) info password $encode(%newpassword)  }
  if (%encode.type = hash) { writeini $char($3) info password $sha1(%newpassword)  }

  .msg $nick 03 $+ $3 $+ 's password has been reset.
  .msg $3 04 $+ $nick has reset your password. Your new password is now: %newpassword 
}

; Allows a bot admin to see the average player level in the game
on 50:TEXT:!apl*:*:{  
  $display.message(03Average Player's Level: $total.player.averagelevel , private)
}


;====================
; This is to block some
; spam bots on Esper.
; This section will be removed
; when the problem is over.
;====================

on 1:TEXT:Hey, I thought you guys might be interested in this blog by freenode staff member*:#:{
  /ban %battlechan $nick
  /kick %battlechan $nick
}  
