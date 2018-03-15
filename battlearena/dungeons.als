;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; dungeons.als
;;;; Last updated: 03/15/18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dungeon.dungeonname { return $readini($dungeonfile($dungeon.dungeonfile), info, name) }
dungeon.currentroom {  return $readini($txtfile(battle2.txt), DungeonInfo, currentRoom) }
dungeon.dungeonfile { return $readini($txtfile(battle2.txt), DungeonInfo, DungeonFile) }
dungeon.bossroomcheck {
  if ($readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, bossroom) = true) { return true }
  else { return false }
}
dungeon.recommendedplayers {
  var %recommended.players $readini($dungeonfile($dungeon.dungeonfile), info, PlayersRecommended)
  if (%recommended.players = $null) { var %recommended.players 2 }
  else { return %recommended.players }
}

dungeon.start {
  ; Open the dungeon.
  set %battleis on | set %battleisopen on

  /.timerBattleStart off

  var %time.to.enter $readini(system.dat, system, TimeToEnterDungeon)
  if (%time.to.enter = $null) { var %time.to.enter 120 }
  /.timerBattleBegin 0 %time.to.enter /dungeon.begin

  set %battle.type dungeon

  var %dungeon.players.needed $readini($dungeonfile($3), info, PlayersNeeded)
  if (%dungeon.players.needed = $null) { var %dungeon.players.needed 1 }

  var %dungeon.players.recommended $readini($dungeonfile($3), Info, PlayersRecommended)
  if (%dungeon.players.recommended = $null) { var %dungeon.players.recommended 2 }

  var %dungeon.level $readini($dungeonfile($3), info, Level)
  if (%dungeon.level = $null) { var %dungeon.level 15 }

  writeini $txtfile(battle2.txt) DungeonInfo DungeonFile $3 
  writeini $txtfile(battle2.txt) DungeonInfo PlayersNeeded %dungeon.players.needed
  writeini $txtfile(battle2.txt) DungeonInfo DungeonLevel %dungeon.level


  writeini $txtfile(battle2.txt) BattleInfo TimeKeyUsed $fulldate

  ; Show the dungeon start message.
  if ($4 != true) { $display.message(2 $+ $get_chr_name($1)  $+ $readini($dungeonfile($3), info, StartBattleDesc), global) }
  if ($4 = true) { $display.message(2 $+ $readini($dungeonfile($3), info, StartBattleDesc), global) | writeini $txtfile(battle2.txt) DungeonInfo IgnoreWritingDungeonTime true }

  $display.message(4This dungeon is level12 %dungeon.level 4and requires12 %dungeon.players.needed $iif(%dungeon.players.needed = 1, player, players) 4to enter (12 $+ %dungeon.players.recommended 4 $iif(%dungeon.players.recommended = 1, player, players) recommended). The dungeon will begin in12 $duration(%time.to.enter) $+ 4. Use !enter if you wish to join the party. , global) 

}

dungeon.enter {
  $checkchar($1)
  if ((%battleisopen != on) && ($return.systemsetting(AllowLateEntries) != true)) { $set_chr_name($1)
    $display.message($readini(translation.dat, battle, BattleClosed), global)  | halt 
  }

  ; There's a player limit in IRC mode due to the potential for flooding..  There is no limit for DCCchat mode.
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {
    if ($readini($txtfile(battle2.txt), BattleInfo, Players) >= 8) { $display.message($readini(translation.dat, errors, PlayerLimit),private) | halt }
  }

  var %curbat $readini($txtfile(battle2.txt), Battle, List)
  if ($istok(%curbat,$1,46) = $true) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, AlreadyInBattle), private) | halt  }

  ; Is the player too low level to enter?
  if ($get.level($1) < $readini($txtfile(battle2.txt), DungeonInfo, DungeonLevel)) { $display.message($readini(translation.dat, errors, LevelTooLowForDungeon), private) | halt }

  ; For DCCchat mode we need to move the player into the battle room.
  writeini $char($1) DCCchat Room BattleRoom

  ; Add the player to the battle list.
  %curbat = $addtok(%curbat,$1,46)
  writeini $txtfile(battle2.txt) Battle List %curbat
  writeini $txtfile(battle2.txt) Dungeon List %curbat

  if ($readini($char($1), info, flag) = $null) {
    var %battleplayers $readini($txtfile(battle2.txt), BattleInfo, Players)
    inc %battleplayers 1 
    writeini $txtfile(battle2.txt) BattleInfo Players %battleplayers
    writeini $txtfile(battle2.txt) BattleInfo Difficulty 0
    writeini $char($1) info SkippedTurns 0
  }

  ; Restore the player
  $fulls($1)

  ; Add the player to the battle.txt
  write $txtfile(battle.txt) $1

  ; rem a few things
  remini $char($1) skills lockpicking.on
  remini $char($1) info levelsync 
  writeini $char($1) info NeedsFulls yes

  $set_chr_name($1) 
  $display.message($readini(translation.dat, battle, EnteredTheDungeon), global)
}

dungeon.begin {
  unset %monster.list
  set %battleisopen off

  /.timerBattleBegin off

  ; Write the time the dungeon begins
  writeini $txtfile(battle2.txt) BattleInfo TimeStarted $fulldate

  ; First, see if there's any players in the battle..
  var %number.of.players $readini($txtfile(battle2.txt), BattleInfo, Players)
  if (%number.of.players = $null) { var %number.of.players 0 }

  if ((%number.of.players = 0) || (%number.of.players < $readini($txtfile(battle2.txt), DungeonInfo, PlayersNeeded))) { $display.message($readini(translation.dat, errors, NotEnoughPartyMembersForDungeon), global) | $clear_battle | halt }

  ; Dungeon was created successfully so let's write the created time to the person who made it
  if ($readini($txtfile(battle2.txt), DungeonInfo, IgnoreWritingDungeonTime) != true) { 
    var %dungeon.creator $readini($txtfile(battle2.txt), DungeonInfo, DungeonCreator)
    writeini $char(%dungeon.creator) info LastDungeonStartTime $ctime
  }

  ; Levelsync everyone
  $display.message($readini(translation.dat, system, DungeonLevelSync), battle)
  $portal.sync.players($readini($txtfile(battle2.txt), DungeonInfo, DungeonLevel))

  ; move the dungeon to room 0 and show the opening message
  writeini $txtfile(battle2.txt) DungeonInfo CurrentRoom 0

  $display.message(2* $readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, desc) ,battle)

  ; The dungeon begins here. Everyone has 1 round to prepare.

  ; Get the battlefield
  $dungeon.battlefield

  ; Get a random weather from the battlefield
  $random.weather.pick

  ; Check to see if there's any battlefield limitations
  $battlefield.limitations

  ; Reset the empty rounds counter.
  writeini battlestats.dat battle emptyRounds 0

  ; Set the # of Turns Before Darkness
  set %darkness.turns 20

  $generate_battle_order
  set %who $read -l1 $txtfile(battle.txt) | set %line 1
  set %current.turn 1 | set %true.turn 1

  $battlelist(public)

  ; To keep someone from sitting and doing nothing for hours at a time, there's a timer that will auto-force the next turn.
  var %nextTimer $readini(system.dat, system, TimeForIdle)
  if (%nextTimer = $null) { var %nextTimer 180 }
  /.timerBattleNext 1 %nextTimer /next forcedturn

  $display.message($readini(translation.dat, battle, StepsUpFirst), battle)

  $aicheck(%who)
}

dungeon.dungeonovercheck {
  var %dungeon.finalroom $readini($dungeonfile($dungeon.dungeonfile), info, finalroom) 
  if ($dungeon.currentroom > %dungeon.finalroom) { return true }
  else { return false } 
}

dungeon.battlefield {
  var %dungeon.battlefield $readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, battlefield)
  if (%dungeon.battlefield = $null) { set %current.battlefield $dungeon.dungeonname Room }
  else { set  %current.battlefield %dungeon.battlefield }
}

dungeon.rewardorbs {
  var %dungeon.level $readini($txtfile(battle2.txt), dungeoninfo, dungeonlevel)
  var %boss.room.check $readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, bossroom)

  if (%boss.room.check = true) { var %dungeon.level $calc(%dungeon.level * 25) }
  else { var %dungeon.level $calc(%dungeon.level * 10) }

  if ($1 = dungeonclear) { var %dungeon.clear true | var %dungeon.level $calc(%dungeon.level + 75) }

  if ($1 = failure) {   
    $battle.calculate.redorbs(defeat, %dungeon.level)
    $battle.reward.redorbs(defeat )
    $battle.reward.killcoins
  } 
  else { 
    $battle.calculate.redorbs(victory, %dungeon.level, %dungeon.clear)
    $battle.reward.redorbs(victory, %dungeon.clear )
    $battle.reward.playerstylepoints
    $battle.reward.playerstylexp
    $battle.reward.ignitionGauge.all
    $battle.reward.killcoins
  }

  if (%dungeon.firsttime.clear = true) { 
    $display.message($readini(translation.dat, battle, FirstTimeDungeonReward), battle)
    unset %dungeon.firsttime.clear
  }

  if ($1 = dungeonclear) { $display.message($readini(translation.dat, battle, RewardOrbsDungeonClear), battle) }
  if ($1 = failure) { $display.message($readini(translation.dat, battle, RewardOrbsLoss), battle) }
  if (($1 != dungeonclear) && ($1 != failure)) { $display.message($readini(translation.dat, battle, RewardOrbsWin), battle) }
}


dungeon.clearroom { 
  ; reward orbs for killing monsters
  if ($readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, monsters) != $null) { $dungeon.rewardorbs }

  ; Clear dead monsters
  $multiple_wave_clearmonsters

  ; Increase the room #
  var %current.room $dungeon.currentroom
  inc %current.room 1
  writeini $txtfile(battle2.txt) DungeonInfo CurrentRoom %current.room

  if ($dungeon.dungeonovercheck = true) { $dungeon.end | halt } 

  $display.message(2* $readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, desc) ,battle)

  /.timerDungeonSlowDown2 1 5 /dungeon.nextroom
}

dungeon.end { 

  var %total.battle.duration $battle.calculateBattleDuration

  if ($1 = failure) { 
    $display.message(2 $+ $readini($dungeonfile($dungeon.dungeonfile), info, DungeonFail), global) 
    $dungeon.rewardorbs(failure) 
  }

  else { 
    $display.message(2 $+ $readini($dungeonfile($dungeon.dungeonfile), info, cleardungeondesc), global) 

    ; give orb rewards
    $dungeon.rewardorbs(dungeonClear)

    ; give out a reward
    $generate_style_order

    $battle.reward.blackorbs 
    if (%black.orb.winners != $null) { $display.message($readini(translation.dat, battle, BlackOrbWin), battle)   }
    $give_random_reward

    $dungeon.spoils.drop
    $show.random.reward

    $create_treasurechest
  }

  ; then do a $clear_battle
  set %battleis off | $clear_battle | halt
}

dungeon.spoils.drop {
  var %most.stylish.player $readini($txtfile(battle2.txt), battle, MostStylish)
  unset %item.drop.rewards

  var %boss.list $readini($txtfile(battle2.txt), BattleInfo, MonsterList)

  if (%boss.list = $null) { return }

  set %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)

    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 

      if (%who.battle != %most.stylish.player) { 

        var %random.boss.monster $gettok(%boss.list,$numtok(%boss.list, 46),46)
        var %reward.list $readini($dbfile(spoils.db), drops, %random.boss.monster)
        if (%reward.list = $null) { return }

        var %drop.reward $gettok(%reward.list,$rand(1,$numtok(%reward.list, 46)),46)
        var %player.amount $readini($char(%who.battle), Item_Amount, %drop.reward)
        if (%player.amount = $null) { var %player.amount 0 }

        var %item.reward.amount 1
        inc %player.amount %item.reward.amount

        writeini $char(%who.battle) item_amount %drop.reward %player.amount
        $set_chr_name(%who.battle) 

        var %drop.counter $readini($char(%who.battle), stuff, dropsrewarded)
        if (%drop.counter = $null) { var %drop.counter 0 }
        inc %drop.counter 1
        writeini $char(%who.battle) stuff DropsRewarded %drop.counter

        %item.drop.rewards = $addtok(%item.drop.rewards, %real.name $+  $+ $chr(91) $+ %drop.reward x $+ %item.reward.amount $+  $+ $chr(93) $+ , 46)

        inc %battletxt.current.line 1 
      }
      else { inc %battletxt.current.line 1 }

    }
  }

}

dungeon.nextroom {
  ; Get the battlefield
  $dungeon.battlefield

  ; Get a random weather from the battlefield
  $random.weather.pick(inbattle)

  ; Check to see if there's any battlefield limitations
  $battlefield.limitations

  ; Reset the empty rounds counter.
  writeini battlestats.dat battle emptyRounds 0

  ; Set the # of Turns Before Darkness
  set %darkness.turns 20

  remini $txtfile(battle2.txt) battle bonusitem
  remini $txtfile(battle2.txt) style

  if ($readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, RestoreRoom) = true) { $dungeon.restoreroom }
  else { 
    ; Generate dungeon monsters
    $dungeon.generatemonsters

    ; Generate dungeon npcs
    $dungeon.generatenpcs

    $generate_battle_order
    set %who $read -l1 $txtfile(battle.txt) | set %line 1
    set %current.turn 1

    $battlelist(public)

    ; To keep someone from sitting and doing nothing for hours at a time, there's a timer that will auto-force the next turn.
    var %nextTimer $readini(system.dat, system, TimeForIdle)
    if (%nextTimer = $null) { var %nextTimer 180 }
    /.timerBattleNext 1 %nextTimer /next forcedturn

    $turn(%who)

    unset %wait.your.turn
  }
}


dungeon.generatemonsters {
  ; Clear the old spoil list
  remini $txtfile(battle2.txt) BattleInfo MonsterList

  ; Get the list of monsters from the room
  var %monster.list $readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, monsters)
  var %dungeon.level $readini($txtfile(battle2.txt), DungeonInfo, DungeonLevel)

  ; Cycle through and summon each
  var %value 1 | var %multiple.monster.counter 2 | set %number.of.monsters $numtok(%monster.list,46)
  while (%value <= %number.of.monsters) { 
    unset %multiple.monster.found
    set %current.monster.to.spawn $gettok(%monster.list,%value,46)

    var %isboss $isfile($boss(%current.monster.to.spawn))
    var %ismonster $isfile($mon(%current.monster.to.spawn))

    if ((%isboss != $true) && (%ismonster != $true)) { inc %value }
    else { 
      set %found.monster true 
      var %current.monster.to.spawn.name %current.monster.to.spawn

      while ($isfile($char(%current.monster.to.spawn.name)) = $true) { 
        var %current.monster.to.spawn.name %current.monster.to.spawn $+ %multiple.monster.counter 
        inc %multiple.monster.counter 1 | var %multiple.monster.found true
      }
    }

    if ($isfile($boss(%current.monster.to.spawn)) = $true) { .copy -o $boss(%current.monster.to.spawn) $char(%current.monster.to.spawn.name)  }
    if ($isfile($mon(%current.monster.to.spawn)) = $true) {  .copy -o $mon(%current.monster.to.spawn) $char(%current.monster.to.spawn.name)  }

    if (%multiple.monster.found = true) {  
      var %real.name.spawn $readini($char(%current.monster.to.spawn), basestats, name) $calc(%multiple.monster.counter - 1)
      writeini $char(%current.monster.to.spawn.name) basestats name %real.name.spawn
    }

    ; increase the total # of monsters
    set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%current.monster.to.spawn.name,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
    write $txtfile(battle.txt) %current.monster.to.spawn.name
    var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters

    var %monster.level $readini($char(%current.monster.to.spawn.name), info, bosslevel)

    if (%monster.level = $null) { var %monster.level 15 }
    if (%monster.level < %dungeon.level) { var %monster.level %dungeon.level }
    ;   if (%monster.level > $calc(%dungeon.level + 10)) { var %monster.level $calc(%dungeon.level + 10) }

    ; display the description of the spawned monster
    $set_chr_name(%current.monster.to.spawn.name) 

    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      var %timer.delay $calc(%value - 1)

      if (%number.of.monsters > 2) { 
        dec %timer.delay 2
        if (%timer.delay <= 0) { var %timer.delay 0 }
      } 

      $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)

      var %bossquote $readini($char(%current.monster.to.spawn.name), descriptions, bossquote)
      if (%bossquote != $null) { 
        var %bossquote 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.monster.to.spawn), descriptions, BossQuote) $+ "
        $display.message(%bossquote, battle) 
      }
    }

    if ($readini(system.dat, system, botType) = DCCchat) {
      $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
      $display.message(12 $+ %real.name  $+ $readini($char(%current.monster.to.spawn.name), descriptions, char), battle)
      if (%bossquote != $null) {   $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.monster.to.spawn.name), descriptions, BossQuote) $+ ", battle) }
    }

    ; Boost the monster
    $levelsync(%current.monster.to.spawn.name, %monster.level)
    writeini $char(%current.monster.to.spawn.name) basestats str $readini($char(%current.monster.to.spawn.name), battle, str)
    writeini $char(%current.monster.to.spawn.name) basestats def $readini($char(%current.monster.to.spawn.name), battle, def)
    writeini $char(%current.monster.to.spawn.name) basestats int $readini($char(%current.monster.to.spawn.name), battle, int)
    writeini $char(%current.monster.to.spawn.name) basestats spd $readini($char(%current.monster.to.spawn.name), battle, spd)

    $boost_monster_hp(%current.monster.to.spawn.name, dungeon, $get.level(%current.monster.to.spawn.name))

    $fulls(%current.monster.to.spawn.name, yes)


    var %spoil.monster.list $readini($txtfile(battle2.txt), BattleInfo, MonsterList)
    var %spoil.monster.list $addtok(%spoil.monster.list, %current.monster.to.spawn.name, 46)
    writeini $txtfile(battle2.txt) BattleInfo MonsterList %spoil.monster.list

    set %multiple.wave.bonus yes
    set %first.round.protection yes
    set %darkness.turns 21
    unset %darkness.fivemin.warn
    unset %battle.rage.darkness

    ; Get the boss item.
    $check_drops(%current.monster.to.spawn.name)

    inc %value

  }
  unset %found.monster
}


dungeon.generatenpcs {
  ; Get the list of npcs from the room
  var %npc.list $readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, npcs)
  var %dungeon.level $readini($txtfile(battle2.txt), DungeonInfo, DungeonLevel)

  if (%npc.list = $null) { return }

  ; Cycle through and summon each
  var %value 1 | var %multiple.npc.counter 2 | set %number.of.npcs $numtok(%npc.list,46)
  while (%value <= %number.of.npcs) { 
    unset %multiple.npc.found
    set %current.npc.to.spawn $gettok(%npc.list,%value,46)

    var %isnpc $isfile($npc(%current.npc.to.spawn))

    if ((%isnpc != $true) && (%isnpc != $true)) { inc %value }
    else { 
      set %found.npc true 
      var %current.npc.to.spawn.name %current.npc.to.spawn

      while ($isfile($char(%current.npc.to.spawn.name)) = $true) { 
        var %current.npc.to.spawn.name %current.npc.to.spawn $+ %multiple.npc.counter 
        inc %multiple.npc.counter 1 | var %multiple.npc.found true
      }
    }

    if ($isfile($npc(%current.npc.to.spawn)) = $true) {  .copy -o $npc(%current.npc.to.spawn) $char(%current.npc.to.spawn.name)  }

    if (%multiple.npc.found = true) {  
      var %real.name.spawn $readini($char(%current.npc.to.spawn), basestats, name) $calc(%multiple.npc.counter - 1)
      writeini $char(%current.npc.to.spawn.name) basestats name %real.name.spawn
    }

    ; increase the total # of npcs
    set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%current.npc.to.spawn.name,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
    write $txtfile(battle.txt) %current.npc.to.spawn.name
    var %battlenpcs $readini($txtfile(battle2.txt), BattleInfo, npcs) | inc %battlenpcs 1 | writeini $txtfile(battle2.txt) BattleInfo npcs %battlenpcs

    var %npc.level $readini($char(%current.npc.to.spawn.name), info, npclevel)

    if (%npc.level = $null) { var %npc.level 15 }
    if (%npc.level < %dungeon.level) { var %npc.level %dungeon.level }
    ;   if (%npc.level > $calc(%dungeon.level + 10)) { var %npc.level $calc(%dungeon.level + 10) }

    ; display the description of the spawned npc
    $set_chr_name(%current.npc.to.spawn.name) 

    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      var %timer.delay $calc(%value - 1)

      if (%number.of.npcs > 2) { 
        dec %timer.delay 2
        if (%timer.delay <= 0) { var %timer.delay 0 }
      } 
      $display.message(12 $+ %real.name has entered the battle to help the forces of good!,battle)

      var %npcquote $readini($char(%current.npc.to.spawn.name), descriptions, bossquote)
      if (%npcquote != $null) { 
        var %npcquote 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.npc.to.spawn), descriptions, npcQuote) $+ "
        $display.message(%npcquote, battle) 
      }
    }

    if ($readini(system.dat, system, botType) = DCCchat) {
      $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
      $display.message(12 $+ %real.name  $+ $readini($char(%current.npc.to.spawn.name), descriptions, char), battle)
      if (%npcquote != $null) {   $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.npc.to.spawn.name), descriptions, npcQuote) $+ ", battle) }
    }

    ; Boost the npc
    $levelsync(%current.npc.to.spawn.name, %npc.level)
    writeini $char(%current.npc.to.spawn.name) basestats str $readini($char(%current.npc.to.spawn.name), battle, str)
    writeini $char(%current.npc.to.spawn.name) basestats def $readini($char(%current.npc.to.spawn.name), battle, def)
    writeini $char(%current.npc.to.spawn.name) basestats int $readini($char(%current.npc.to.spawn.name), battle, int)
    writeini $char(%current.npc.to.spawn.name) basestats spd $readini($char(%current.npc.to.spawn.name), battle, spd)

    $boost_monster_hp(%current.npc.to.spawn.name, dungeon, $get.level(%current.npc.to.spawn.name))

    $fulls(%current.npc.to.spawn.name, yes)

    inc %value

  }
  unset %found.npc
}


dungeon.restoreroom {
  ; Restores players to full health, tp, and clears their skill timers.

  $display.message(7* The party feels their health $+ $chr(44)  tp $+ $chr(44)  and power restored in this room)

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)

    if (%flag != monster) { $fulls(%who.battle, dungeon) |  $clear_skill_timers(%who.battle) |  writeini $char(%who.battle) info NeedsFulls yes }

    inc %battletxt.current.line
  }

  ; Resync everyone
  $portal.sync.players($readini($txtfile(battle2.txt), DungeonInfo, DungeonLevel))

  ; Move to the next room.
  var %current.room $dungeon.currentroom
  inc %current.room 1
  writeini $txtfile(battle2.txt) DungeonInfo CurrentRoom %current.room

  if ($dungeon.dungeonovercheck = true) { $dungeon.end | halt } 

  $display.message(2* $readini($dungeonfile($dungeon.dungeonfile), $dungeon.currentroom, desc) ,battle)

  /.timerDungeonSlowDown2 1 5 /dungeon.nextroom

}

;================================
; Aliases below this line are for special
; dungeons
;================================
dungeon.haukke.lampcount {
  var %haukke.lamps.lit 0
  if ($readini($char(Haukke_Lamp1), battle, hp) > 0) { inc %haukke.lamps.lit 1 }
  if ($readini($char(Haukke_Lamp2), battle, hp) > 0) { inc %haukke.lamps.lit 1 }
  if ($readini($char(Haukke_Lamp3), battle, hp) > 0) { inc %haukke.lamps.lit 1 }
  if ($readini($char(Haukke_Lamp4), battle, hp) > 0) { inc %haukke.lamps.lit 1 }
  return %haukke.lamps.lit
}


dungeon.pirate.bubblecount {
  ; $1 = red or blue

  var %bubble.count 0

  if ($1 = blue) { 
    if ($readini($char(Blue_Bubble), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble1), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble2), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble3), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble4), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble5), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble6), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble7), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble8), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble9), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Blue_Bubble10), battle, hp) > 0) { inc %bubble.count 1 }
  }

  if ($1 = red) { 
    if ($readini($char(Red_Bubble), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble1), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble2), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble3), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble4), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble5), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble6), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble7), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble8), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble9), battle, hp) > 0) { inc %bubble.count 1 }
    if ($readini($char(Red_Bubble10), battle, hp) > 0) { inc %bubble.count 1 }
  }

  return %bubble.count
}
