;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BASIC CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

raw 421:*:echo -a 4,1Unknown Command: ( $+ $2 $+ ) | echo -a 4,1Location: %debug.location | halt
CTCP *:PING*:?:if ($nick == $me) haltdef
CTCP *:BOTVERSION*:ctcpreply $nick BOTVERSION $battle.version
on 1:QUIT: { 
  if ($nick = %bot.name) { /nick %bot.name | /.timer 1 15 /identifytonickserv } 
  .auser 1 $nick | .flush 1 
} 
on 1:EXIT: {  .auser 1 $nick | .flush 1 }
on 1:PART:%battlechan:.auser 1 $nick | .flush 1
on 1:KICK:%battlechan:.auser 1 $knick | .flush 1 
on 1:JOIN:%battlechan:{ 
  .auser 1 $nick | .flush 1 

  if ($readini(system.dat, system, botType) = TWITCH) {
    if ($isfile($char($nick)) = $true) { 
      $set_chr_name($nick) | $display.system.message(10 $+ %real.name %custom.title  $+  $readini($char($nick), Descriptions, Char), global) 
      var %bot.owners $readini(system.dat, botinfo, bot.owner)
      if ($istok(%bot.owners,$nick,46) = $true) {  .auser 50 $nick }

      mode %battlechan +v $nick
    }
  }

}
on 3:NICK: { .auser 1 $nick | mode %battlechan -v $newnick | .flush 1 }
on *:CTCPREPLY:PING*:if ($nick == $me) haltdef
on *:DNS: { 
  if ($isfile($char($nick)) = $true) { writeini $char($nick) info lastIP $iaddress  }
  set %ip.address. [ $+ [ $nick ] ] $iaddress
}

on 2:TEXT:!bot admin*:*: {  $bot.admin(list) }

alias bot.admin {
  if ($1 = list) { var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if (%bot.admins = $null) { $display.system.message(4There are no bot admins set., private) | halt }
    else {
      set %replacechar $chr(044) $chr(032)
      %bot.admins = $replace(%bot.admins, $chr(046), %replacechar)
      unset %replacechar
      $display.system.message(3Bot Admins:12 %bot.admins, private) | halt 
    }
  }

  if ($1 = add) { $checkchar($2) | var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if ($istok(%bot.admins,$2,46) = $true) { $display.system.message(4Error: $2 is already a bot admin, private) | halt }
    %bot.admins = $addtok(%bot.admins,$2,46) | $display.system.message(3 $+ $2 has been added as a bot admin., private) 
    writeini system.dat botinfo bot.owner %bot.admins | halt 
  }

  if ($1 = remove) { var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if ($istok(%bot.admins,$2,46) = $false) { $display.system.message(4Error: $2 is not a bot admin, private) | halt }

    ; The bot admin in the first position is considered to be the "bot owner" and cannot be removed via this command.
    var %bot.owner $gettok(%bot.admins,1,46)
    if ($2 = %bot.owner) { $display.system.message(4Error: $2 cannot be removed from the bot admin list using this command, private) | halt }

    %bot.admins = $remtok(%bot.admins,$2,46) | $display.system.message(3 $+ $2 has been removed as a bot admin., private) 
    writeini system.dat botinfo bot.owner %bot.admins | halt 
  }
}

on 1:START: {
  echo 12*** Welcome to Battle Arena Bot version $battle.version written by James "Iyouboushi" *** 

  /.titlebar Battle Arena version $battle.version written by James  "Iyouboushi" 

  if (%first.run = false) { 
    set %bot.owner $readini(system.dat, botinfo, bot.owner) 
    if (%bot.owner = $null) { echo 4*** WARNING: There is no bot admin set.  Please fix this now. 
    set %bot.owner $?="Please enter the bot admin's IRC nick" |  writeini system.dat botinfo bot.owner %bot.owner }
    else { echo 12*** The bot admin list is currently set to:4 %bot.owner 12***  |  

      var %value 1 | var %number.of.owners $numtok(%bot.owner, 46)
      while (%value <= %number.of.owners) {
        set %name.of.owner $gettok(%bot.owner,%value,46)
        .auser 50 %name.of.owner
        inc %value 1
      }
      unset %name.of.owner
    }

    set %battlechan $readini(system.dat, botinfo, questchan) 
    if (%battlechan = $null) { echo 4*** WARNING: There is no battle channel set.  Please fix this now. 
    set %battlechan $?="Please enter the IRC channel you're using (include the #)" |  writeini system.dat botinfo questchan %battlechan }
    else { echo 12*** The battle channel is currently set to:4 %battlechan 12*** }

    set %bot.name $readini(system.dat, botinfo, botname)
    if (%bot.name = $null) { echo 4*** WARNING: The bot's nick is not set in the system file.  Please fix this now.
    set %bot.name $?="Please enter the nick you wish the bot to use" | writeini system.dat botinfo botname %bot.name | /nick %bot.name }
    else { /nick %bot.name } 

    var %botpass $readini(system.dat, botinfo, botpass)
    if (%botpass = $null) { 
      echo 12*** Now please set the password you plan to register the bot with
      var %botpass $?="Enter a password that you will use for the bot on Nickserv"
      writeini system.dat botinfo botpass %botpass
      echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.
    }

    $system_defaults_check
  }

  if ((%first.run = true) || (%first.run = $null)) { 
    echo 12*** It seems this is the first time you've ever run the Battle Arena Bot!  The bot will now attempt to help you get things set up.
    echo 12*** Please set your bot's nick/name now.   Normal IRC nick rules apply (no spaces, for example) 
    set %bot.name $?="Please enter the nick you wish the bot to use"
    writeini system.dat botinfo botname %bot.name | /nick %bot.name
    echo 12*** Great.  The bot's nick is now set to4 %bot.name

    echo 12*** Please set a bot owner now.  
    set %bot.owner $?="Please enter the bot owner's IRC nick"
    writeini system.dat botinfo bot.owner %bot.owner
    echo 12*** Great.  The bot owner has been set to4 %bot.owner

    echo 12*** Now please set the IRC channel you plan to use the bot in
    set %battlechan $?="Enter an IRC channel (include the #)"
    writeini system.dat botinfo questchan %battlechan
    echo 12*** The battles will now take place in4 %battlechan

    echo 12*** Now please set the password you plan to register the bot with
    var %botpass $?="Enter a password"
    writeini system.dat botinfo botpass %botpass
    echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.

    set %first.run false
    .auser 50 %bot.owner

    $system_defaults_check

  }

  echo 12*** This bot is best used with mIRC version4 6.3 12 *** 
  echo 12*** You are currently using mIRC version4 $version 12 ***

  if ($version < 6.3) {   echo 4*** Your version is older than the recommended version for this bot. Some things may not work right.  It is recommended you update. 12 *** }
  if ($version > 6.3) {   echo 4*** Your version is newer than the recommended version for this bot. While it should work, it is currently untested and may have quirks or bugs.  It is recommended you downgrade if you run into any problems. 12 *** }

}

on 1:CONNECT: {
  ; Start a keep alive timer.
  /.timerKeepAlive 0 300 /.ctcp $!me PING 

  ; Join the channel
  /join %battlechan

  ; Get rid of a ghost, if necessary, and send password
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if ($me != %bot.name) { /.msg NickServ GHOST %bot.name %bot.pass | /nick %bot.name } 
  $identifytonickserv

  ; Recalculate how many battles have happened.
  $recalc_totalbattles

  ; Unset the key in use check.
  unset %keyinuse

  ; If a battle was on when the bot turned off, let's check it and do something with it.
  if (%battleis = on) { 
    if ($readini($txtfile(battle2.txt), BattleInfo, Monsters) = $null) { $clear_battle }
    else { $next }
  }
  if (%battleis = off) { $clear_battle } 
}

alias identifytonickserv {
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if (%bot.pass != $null) { /.msg nickserv identify %bot.pass }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admin Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admins have  the ability to zap/erase characters.
on 50:TEXT:!zap *:*: {  $set_chr_name($2) | $checkchar($2) | $zap_char($2) | $display.system.message($readini(translation.dat, system, zappedcomplete),global) | halt }

; Force the bot to quit
on 50:TEXT:!quit*:*:{ /quit $battle.version }

; Add or remove a bot admin (note: cannot remove the person in position 1 with this command)
on 50:TEXT:!bot admin*:*: {  
  if (($3 = $null) || ($3 = list)) { $bot.admin(list) }
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

  $display.system.message(4Variables File dumped as file: %debug.filename, private)
}

; Cleans out the main folder of .txt, .lst, and .db files.
on 50:TEXT:!main folder cleanup:*:{ 
  .echo -q $findfile( $mircdir , *.lst, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.db, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.txt, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir , *.html, 0, 0, clean_mainfolder $1-) 
  $display.system.message(4.db & .lst & .txt & .html files have been cleaned up from the main bot folder.)
}

alias clean_mainfolder { 

  if ($2 = $null) {  .remove $1 }
  if ($2 != $null) { 
    set %clean.file $nopath($1-) 
    .remove %clean.file
    unset %clean.file
  }
}

; Bot admins can toggle Players Must Die Mode
on 50:TEXT:!toggle mode playersmustdie*:*:{   
  if ($readini(system.dat, system,PlayersMustDieMode) = false) { 
    writeini system.dat system PlayersMustDieMode true
    $display.system.message($readini(translation.dat, system, PlayersMustDieModeOn), global)
  }
  else {
    writeini system.dat system PlayersMustDieMode false
    $display.system.message($readini(translation.dat, system, PlayersMustDieModeOff), global)
  }
}

; Bot admins can toggle if the bot uses colors
on 50:TEXT:!toggle bot colors*:*:{   
  if ($readini(system.dat, system,AllowColors) = false) { 
    writeini system.dat system AllowColors true
    $display.system.message($readini(translation.dat, system, AllowColorsOn), global)
    halt
  }
  else {
    writeini system.dat system AllowColors false
    $display.system.message($readini(translation.dat, system, AllowColorsOff), global)
    halt
  }
}

; Bot admins can toggle if the discount card message is shown or not.
on 50:TEXT:!toggle discountcard message*:*:{   
  if ($readini(system.dat, system,ShowDiscountMessage) = false) { 
    writeini system.dat system ShowDiscountMessage true
    $display.system.message($readini(translation.dat, system, DiscountMessageOn), global)
  }
  else {
    writeini system.dat system ShowDiscountMessage false
    $display.system.message($readini(translation.dat, system, DiscountMessageOff), global)
  }
}

; Toggles the battle throttle function.
on 50:TEXT:!toggle battle throttle*:*:{   
  if ($readini(system.dat, system,BattleThrottle) = false) { 
    writeini system.dat system BattleThrottle true
    $display.system.message($readini(translation.dat, system, BattleThrottleOn), global)
  }
  else {
    writeini system.dat system BattleThrottle false
    $display.system.message($readini(translation.dat, system, BattleThrottleOff), global)
  }
}


; Bot Admins can toggle the bonus event flag.  Bonus Events = double the currency at the end of battle.
on 50:TEXT:!toggle bonus event*:*:{   
  if ($readini(system.dat, system, BonusEvent) = false) { 
    writeini system.dat system BonusEvent true
    $display.system.message($readini(translation.dat, system, BonusEventOn), global)
  }
  else {
    writeini system.dat system BonusEvent false
    $display.system.message($readini(translation.dat, system, BonusEventOff), global)
  }
}

; Bot Admins can toggle if damage is capped or not.
on 50:TEXT:!toggle damage cap*:*:{   
  if ($readini(system.dat, system, IgnoreDmgCap) = false) { 
    writeini system.dat system IgnoreDmgCap true
    $display.system.message($readini(translation.dat, system, DamageNotCapped), global)
  }
  else {
    writeini system.dat system IgnoreDmgCap false
    $display.system.message($readini(translation.dat, system, DamageNowCapped), global)
  }
}

; Bot Admins can toggle the automated battle system to be on/off
on 50:TEXT:!toggle automated battle system*:*:{   
  if ($readini(system.dat, system, automatedbattlesystem) = off) { 
    writeini system.dat system automatedbattlesystem on
    $display.system.message($readini(translation.dat, system, AutomatedBattleOn), global)
    if (%battleis = off) { $clear_battle }
  }
  else {
    writeini system.dat system automatedbattlesystem off
    $display.system.message($readini(translation.dat, system, AutomatedBattleOff), global)
  }
}

; Bot Admins can toggle the automated battle system to be on/off
on 50:TEXT:!toggle automated ai battle*:*:{   
  if ($readini(system.dat, system, automatedaibattlecasino) = off) { 
    writeini system.dat system automatedaibattlecasino on
    $display.system.message($readini(translation.dat, system, AutomatedAIBattleCasinoOn), global)
  }
  else {
    writeini system.dat system automatedaibattlecasino off
    $display.system.message($readini(translation.dat, system, AutomatedAIBattleCasinoOff), global)
  }
}

; Bot Admins can toggle which battle formulas are used.
on 50:TEXT:!toggle battle formula*:*:{   
  if ($readini(system.dat, system, BattleDamageFormula) = 1) { 
    writeini system.dat system BattleDamageFormula 2
    $display.system.message($readini(translation.dat, system, NewDmgFormulaIsOn), global)
    halt
  }
  if ($readini(system.dat, system, BattleDamageFormula) = 2) { 
    writeini system.dat system BattleDamageFormula 3
    $display.system.message($readini(translation.dat, system, NewDmgFormulaIsOn3), global)
    halt
  }
  if ($readini(system.dat, system, BattleDamageFormula) = 3) { 
    writeini system.dat system BattleDamageFormula 1
    $display.system.message($readini(translation.dat, system, NewDmgFormulaIsOff), global)
    halt
  }
}

ON 50:TEXT:!mimic chance*:*: {
  if ($3 !isnum 1-100) { $display.private.message(4Invalid chance number. Valid numbers are 1-100) | halt }
  writeini system.dat system MimicChance $3 | $display.private.message(3Mimic chance set to: $3 percent)
}

ON 50:TEXT:!clear portal usage *:*: {
  $checkchar($4)
  writeini $char($4) info PortalsUsedTotal 0
  $display.system.message($readini(translation.dat, system, ClearedDailyPortalUsage), global)
}

; Bot admins can manually set the winning streak.
on 50:TEXT:!set streak*:*:{   
  if ($3 = $null) { $display.private.message(4!set streak number) | halt }
  if ($3 < 0) {  $display.private.message(4The streak cannot be negative.) | halt }
  if (. isin $3) { $display.private.message(4The streak must be a whole number.) | halt }
  writeini battlestats.dat battle LosingStreak 0
  writeini battlestats.dat battle winningstreak $3
  $display.system.message(3The winning streak has been set to: $3, global)
}

; Bot admins can toggle the AI system on/off.

on 50:TEXT:!toggle ai system*:*:{   
  if ($readini(system.dat, system, aisystem) = off) { 
    writeini system.dat system aisystem on
    $display.system.message($readini(translation.dat, system, AiSystemOn), global)
  }
  else {
    writeini system.dat system aisystem off
    $display.system.message($readini(translation.dat, system, AiSystemOff), global)
  }
}

; Bot admins can toggle the battlefield events
on 50:TEXT:!toggle battlefield events*:*:{   
  if ($readini(system.dat, system, EnableBattlefieldEvents) != true) { 
    writeini system.dat system EnableBattlefieldEvents true
    $display.system.message($readini(translation.dat, system, EnableBattlefieldEventsOn), global)
  }
  else {
    writeini system.dat system EnableBattlefieldEvents false
    $display.system.message($readini(translation.dat, system, EnableBattlefieldEventsOff), global)
  }
}

; Bot admins can adjust the "level adjust"
on 50:TEXT:!leveladjust*:*:{  
  if ($2 = $null) { $view.leveladjust }
  if ($2 != $null) {  

    if ($2 !isnum) {  $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber), private) | halt }
    if (. isin $2) {  $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber), private) | halt }
    if ($2 < 0) {   $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeNegative), private) | halt }

    writeini battlestats.dat battle leveladjust $2
    $display.system.message($readini(translation.dat, system, SaveLevelAdjust), global)
  }
}

; Bot owners can change the time between battles.
on 50:TEXT:!time between battles *:*:{  
  writeini system.dat System TimeBetweenBattles $4
  var %timebetween.time $calc($4 * 60)
  $display.system.message($readini(translation.dat, System, ChangeTime), global)
}
