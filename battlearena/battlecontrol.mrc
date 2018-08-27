;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BATTLE CONTROL
;;;; Last updated: 08/27/18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 1:TEXT:!battle stats*:*: { $battle.stats }
on 1:TEXT:!battlestats*:*: { $battle.stats }

on 1:TEXT:!conquest*:*: { $conquest.display($1, $2) }

alias battle.stats {
  $recalc_totalbattles
  var %total.battles $bytes($readini(battlestats.dat, Battle, TotalBattles),b)
  var %total.wins $bytes($readini(battlestats.dat, Battle, TotalWins),b)
  var %total.losses $bytes($readini(battlestats.dat, Battle, TotalLoss),b)
  var %total.draws $bytes($readini(battlestats.dat, battle, TotalDraws),b)
  var %total.defendedoutposts $readini(battlestats.dat, battle, TotalOutpostsDefended)
  var %total.lostoutposts $readini(battlestats.dat, battle, TotalOutpostsLost)
  var %total.dragonhunts $readini(battlestats.dat, battle, TotalDragonHunts)

  if (%total.defendedoutposts = $null) { var %total.defendedoutposts 0 }
  if (%total.lostoutposts = $null) { var %total.lostoutposts 0 }
  if (%total.dragonhunts = $null) { writeini battlestats.dat battle TotalDragonHunts 0 | var %total.dragonhutns 0 }

  if (%total.draws = $null) { var %total.draws 0 } 
  var %winning.record $bytes($readini(battlestats.dat, Battle, WinningStreakRecord),b)
  var %total.gauntlet.wins $bytes($readini(battlestats.dat, Battle, GauntletRecord),b)

  if (%winning.record = $null) { unset %winning.record) }
  if (%winning.record != $null) { var %winning.record (Highest record is: %winning.record $+ ) }

  var %total.capturedpresidents $readini(battlestats.dat, Battle, CapturedPresidents)
  var %total.capturedpresidents.wins $readini(battlestats.dat, Battle, CapturedPresidents.Wins)
  var %total.capturedpresidents.fails $readini(battlestats.dat, Battle, CapturedPresidents.Fails)
  var %total.capturedpresidents.ignored %total.capturedpresidents
  dec %total.capturedpresidents.ignored %total.capturedpresidents.wins
  dec %total.capturedpresidents.ignored %total.capturedpresidents.fails

  $display.message($readini(translation.dat, system, BattleStatsData), private)

  if ($readini(battlestats.dat, Battle, WinningStreak) != 0) { $display.message($readini(translation.dat, system, BattleStatsWinningStreak), private) }
  if ($readini(battlestats.dat, Battle, LosingStreak) != 0) { $display.message($readini(translation.dat, system, BattleStatsLosingStreak), private) }
  if (%total.gauntlet.wins > 0) { $display.message($readini(translation.dat, system, BattleStatsGauntletRecord), private) } 
  if (%total.capturedpresidents > 0) { $display.message($readini(translation.dat, system, BattleStatsPresidentRecord), private) } 
  if (%total.dragonhunts > 0) { $display.message($readini(translation.dat, system, BattleStatsDragonHuntRecord), private) }

  $display.message($readini(translation.dat, system, BattleStatsOutposts), private)
  $display.message($readini(translation.dat, system, BattleStatsMoreInfo), private)
}

on 3:TEXT:!leveladjust:*:{ 
  if ($1 = !level) { halt }
  $view.leveladjust 
}

alias view.leveladjust {
  var %leveladjust $readini(battlestats.dat, battle, LevelAdjust)
  if (%leveladjust = $null) { var %leveladjust 0 }
  $display.message($readini(translation.dat, system, ViewLevelAdjust), private)
}

; Everyone can save and view a battle streak to their files.  Think of it like a quick save.

on 3:TEXT:!view battle save*:*:{ $set_chr_name($nick) | $checkchar($nick) 
  var %saved.streak $readini($char($nick), info, savedstreak)
  if (%saved.streak = $null) { var %saved.streak 0 }
  $display.message($readini(translation.dat, system, ViewBattleStreak), global)
}
on 3:TEXT:!save battle streak*:*:{   $save.battle.streak($nick, $1, $2, $3) }
on 3:TEXT:!save battle level*:*:{   $save.battle.streak($nick, $1, $2, $3) }

alias save.battle.streak { 
  $set_chr_name($1) | $checkchar($1) 
  if (%battleis = on) {   $display.message($readini(translation.dat, errors, Can'tDoThisInBattle), private) | halt }
  var %current.streak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.streak <= 0) {  $display.message($readini(translation.dat, errors, Can'tSaveALosingStreak), private) | halt }

  else { 
    if (%current.streak < 11) { $display.message($readini(translation.dat, errors, Can'tSaveStreakUnder11), private) | halt }

    if ($round($calc(($get.level($1) - %current.streak)),0) < -50) { $display.message($readini(translation.dat, errors, LevelTooLowTOSaveaStreak), private) | halt }

    var %last.saved $readini($char($1), info, savedstreak.time)
    var %current.time $ctime
    var %time.difference $calc(%current.time - %last.saved)

    var %time.between.save $return.systemsetting(TimeBetweenSave)
    if (%time.between.save = null) { var %time.between.save 3600 } 

    if ((%time.difference = $null) || (%time.difference > %time.between.save)) {
      var %saved.streak $readini($char($1), info, savedstreak)
      if (%saved.streak = $null) { var %saved.streak 0 }
      if (%current.streak < %saved.streak) {   $display.message($readini(translation.dat, errors, Can'tSaveALowerStreak), private) | halt }
      writeini $char($1) Info SavedStreak %current.streak
      writeini $char($1) Info SavedStreak.time $ctime
      $display.message($readini(translation.dat, system, SaveBattleStreak), global)
    }
    else {   $display.message($readini(translation.dat, errors, NotEnoughTimeToSave), private) | halt }
  }
}

on 3:TEXT:!reset battle streak*:*:{  $reset.battle.streak($nick) } 
alias reset.battle.streak {
  if (%battleis = on) { $display.message($readini(translation.dat, errors, Can'tDoThisInBattle), private) | halt }
  if (%battle.type != $null) { $display.message($readini(translation.dat, errors, Can'tDoThisInBattle), private) | halt }

  var %last.reloadby $readini(battlestats.dat, battle, LastReload)

  if (%last.reloadby != $1) { $display.message(4Only a person who reloads a battle save can reset the streak using this command) | halt }

  writeini battlestats.dat battle LosingStreak 0
  writeini battlestats.dat battle winningstreak 0
  remini battlestats.dat battle LastReload
  $display.message(3The winning streak has been reset to: 0, global)
}

on 3:TEXT:!reload battle streak*:*:{  $reload.battle.streak($nick, $1, $2, $3) } 
on 3:TEXT:!reload battle save*:*:{  $reload.battle.streak($nick, $1, $2, $3) } 
on 3:TEXT:!reload arena level*:*:{  $reload.battle.streak($nick, $1, $2, $3) } 
alias reload.battle.streak { 
  $set_chr_name($1) | $checkchar($1)
  if (%battleis = on) {   $display.message($readini(translation.dat, errors, Can'tDoThisInBattle), private) | halt }
  var %current.streak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.streak > 10) {   $display.message($readini(translation.dat, errors, Can'tReloadOnAWinningStreak), private) | halt }
  else { 

    var %last.reload $readini($char($1), info, reloadstreak.time)
    var %time.difference $calc($ctime - %last.reload)

    var %time.between.reload $return.systemsetting(TimeBetweenSaveReload)
    if (%time.between.reload = null) { var %time.between.reload 1200 } 

    if ((%time.difference = $null) || (%time.difference > %time.between.reload)) {
      var %saved.streak $readini($char($1), info, savedstreak)
      if (%saved.streak = $null) {  $display.message($readini(translation.dat, errors, NoWinningStreakSaved), private) | halt }
      if (%saved.streak = 0) {  $display.message($readini(translation.dat, errors, NoWinningStreakSaved), private) | halt }

      writeini battlestats.dat Battle WinningStreak %saved.streak
      writeini battlestats.dat Battle LosingStreak 0
      writeini $char($1) Info ReloadStreak.time $ctime
      writeini battlestats.dat battle LastReload $1
      $display.message($readini(translation.dat, system, ReloadBattleStreak), global)
    }
    else { $display.message($readini(translation.dat, errors, NotEnoughTimeToReload), private) | halt }
  }
}

on 3:TEXT:!clear battle save*:*:{ $clear.battle.save($nick) }
on 3:TEXT:!clear battle streak*:*:{  $clear.battle.save($nick) }

alias clear.battle.save {
  $set_chr_name($1) | $checkchar($1)
  if (%battleis = on) {  $display.message($readini(translation.dat, errors, Can'tDoThisInBattle), private) | halt }
  var %saved.streak $readini($char($1), info, savedstreak)
  if (%saved.streak = $null) { $display.message($readini(translation.dat, errors, NoWinningStreakSavedToErase), private) | halt }
  if (%saved.streak = 0) {   $display.message($readini(translation.dat, errors, NoWinningStreakSavedToErase), private) | halt }
  $display.message($readini(translation.dat, system, ClearedBattleSave), global)
  remini $char($1) info savedstreak 
}

; Bot Owners can have some control over battles
on 50:TEXT:!startbat*:*:{  
  if (%battleis = on) { $display.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off  | $startnormal($2, $3)   
}
on 50:TEXT:!start bat*:*:{   
  if (%battleis = on) { $display.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($3, $4) 
}
on 50:TEXT:!new bat*:*:{   
  if (%battleis = on) { $display.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($3, $4) 
}

on 50:TEXT:!bat go:*: {
  /.timerBattleBegin off
  $battlebegin
}
on 50:TEXT:!end bat*:*:{ $endbattle($3) } 
on 50:TEXT:!endbat*:*:{  $endbattle($2) } 

; Bot owners can force the next turn
ON 50:TEXT:!next*:*: { 
  if (%battleis = on)  { $check_for_double_turn(%who, forcenext) | halt }
  else { $display.message($readini(translation.dat, Errors, NoCurrentBattle), private) | halt }
}

; Bot owners can reset the battle stats.
on 50:TEXT:!clear battle stats*:*:{ 
  writeini battlestats.dat Battle TotalBattles 0
  writeini battlestats.dat Battle TotalWins 0
  writeini battlestats.dat Battle TotalLoss 0 
  writeini battlestats.dat Battle TotalDraws 0
  writeini battlestats.dat Battle LosingStreak 0
  writeini battlestats.dat Battle WinningStreak 0
  writeini battlestats.dat Battle GauntletRecord 0
  writeini battlestats.dat Battle WinningStreakRecord 0
  writeini battlestats.dat Battle CapturedPresidents.Fails 0
  writeini battlestats.dat Battle CapturedPresidents.Wins 0
  writeini battlestats.dat Battle CapturedPresidents 0
  writeini battlestats.dat Battle TotalOutpostsDefended 0
  writeini battlestats.dat Battle TotalAssaultWon 0
  writeini battlestats.dat Battle TotalAssaultLost 0
  writeini battlestats.dat Battle TotalOutpostsLost 0
  writeini battlestats.dat battle TotalDragonHunts 0  
  writeini battlestats.dat battle SupplyRuns 0
  writeini battlestats.dat battle SupplyRuns.Failed 0
  writeini battlestats.dat battle SupplyRuns.Won 0

  writeini battlestats.dat AIBattles totalBattles 0
  writeini battlestats.dat AIBattles npc 0
  writeini battlestats.dat AIBattles monster 0
  $display.message($readini(translation.dat, System, WipedBattleStats), global)
}

; Bot owners can summon npcs/monsters/bosses to the battlefield during the "entering" phase.
on 50:TEXT:!summon*:*:{
  if (%battle.type = ai) { $display.message($readini(translation.dat, errors, CannotSummonAIBattles), private) | halt } 

  if ($2 = npc) {
    if ($isfile($npc($3)) = $true) {
      .copy -o $npc($3) $char($3)
      $boost_monster_stats($3)  
      $enter($3)
    }
    else { $display.message($readini(translation.dat, errors, NPCDoesNotExist), private) | halt }
  }
  if ($2 = monster) {
    var %number.of.monsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
    if (%number.of.monsters >= 10) { $display.message($readini(translation.dat, errors, MonsterLimit), private) | halt }
    if ($isfile($mon($3)) = $true) {
      .copy -o $mon($3) $char($3)
      $enter($3)
      var %number.of.players $readini($txtfile(battle2.txt), battleinfo, players)
      if (%number.of.players = $null) { var %number.of.players 1 }
      $boost_monster_stats($3)  
      $fulls($3) |  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
    }
    else { $display.message($readini(translation.dat, errors, monsterdoesnotexist), private) | halt }
  }

  if ($2 = boss) {
    var %number.of.monsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
    if (%number.of.monsters >= 10) { $display.message($readini(translation.dat, errors, MonsterLimit), private) | halt }
    if ($isfile($boss($3)) = $true) {
      .copy -o $boss($3) $char($3)
      $enter($3)
      var %number.of.players $readini($txtfile(battle2.txt), battleinfo, players)
      if (%number.of.players = $null) { var %number.of.players 1 }
      $boost_monster_stats($3)  
      $fulls($3) |  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
    }
    else { $display.message($readini(translation.dat, errors, monsterdoesnotexist), private) | halt }
  }
}

; Use these commands to check to see who's in battle..
on 3:TEXT:!batlist*:#:battlelist
on 3:TEXT:!bat list*:#:battlelist
on 3:TEXT:!bat info*:#:battlelist

on 50:TEXT:!clear battle:*:{  $clear_battle }

; ==========================
; This is the alias that clears battles
; ==========================
alias clear_battle { 

  ; Kill any related battle timers..
  $clear_timers

  set %chest.time $readini(system.dat, system, ChestTime)
  if ((%chest.time = $null) || (%chest.time < 2)) { set %chest.time 45 }
  /.timerChestDestroy 1 %chest.time /destroy_treasurechest

  ; Check to see if a treasure goblin is in this battle. If so, a random chance that a treasure dungeon will begin.
  var %people.in.battle $readini($txtfile(battle2.txt), Battle, List)
  if (($istok(%people.in.battle,treasure_goblin,46) = $true) && ($1 = victory)) { 

    if ((%battle.type != cosmic) && (%battle.type != torment))  {
      if ($isfile($dungeonfile(treasure_vault)) = $true) { 
        ; a 10% chance of this happening
        if ($rand(1,100) <= 45) { var %open.treasuredungeon true }
      }
    }
  }

  ; Kill the battle info
  set %battleis off | set %battleisopen off 
  if ($lines($txtfile(temp_status.txt)) != $null) { .remove $txtfile(temp_status.txt) }

  unset %clear.flag | unset %chest.time

  set %ignore.clearfiles no

  if (%ignore.clearfiles != yes) {
    ; Search through the characters folder and find stray monsters/npcs.  Also full players.
    .echo -q $findfile( $char_path , *.char, 0, 0, clear_files $1-) 
    set %ignore.clearfiles yes
  }

  ; Clear battle variables
  $clear_variables

  ; Check to see if the bounty was claimed
  if ($readini($txtfile(battle2.txt), battleinfo, bountyclaimed) = true) { remini battlestats.dat bounty }

  ; Remove the battle text files
  .remove $txtfile(battle.txt) | .remove $txtfile(battle2.txt) | .remove MonsterTable.file
  .remove $txtfile(1vs1bet.txt) | .remove $txtfile(1vs1gamblers.txt)

  ; Announce the next battle, if the automated battle system is on
  $system.start.newbattle(%open.treasuredungeon) 

  ; Check for the conquest tally
  $conquest.tally

  ; Check for shop NPCs
  $shopnpc.status.check

  ; Check for bounty
  $bounty.select 

  ; Check for auction stuff.
  $auctionhouse.check 

  ; Check for dragon hunt stuff
  $dragonhunt.check

  ; Besieged check
  $besieged.check

  halt
}

alias clear_timers {
  /.timerBattleStart off
  /.timerBattleNext off
  /.timerBattleBegin off
  /.timerHolyAura off
  /.timerOrbTimer off
}

alias clear_files {
  set %name $remove($1-,.char)
  set %name $nopath(%name)

  if ($lines($txtfile(status $+ %name $+ .txt)) != $null) { .remove $txtfile(status $+ %name $+ .txt) }
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    var %clear.flag $readini($char(%name), Info, Flag)

    if ((%clear.flag = $null) && ($readini($char(%name), basestats, hp) = $null)) {
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: NULL HP }
      .remove $char(%name) 
    }
    if ((%clear.flag = monster) || (%clear.flag = npc)) {
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Monster or NPC at End of Battle }
      .remove $char(%name) 
    } 
    if (%name = !use) {
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Invalid User Name (!use) }
      .remove $char(%name)
    }
    if ($file($char(%name)).size = 0) { 
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Invalid File Size (the file's size is 0) }
      $zap_char(%name) 
    }

    ; If the person is a player, let's refill their hp/mp/stats to max.
    if (%battle.type != ai) { 
      if ((%clear.flag = $null) && ($readini($char(%name), basestats, hp) != $null)) { writeini $char(%name) DCCchat Room Lobby |  $oldchar.check(%name) }
    }
  }
}

; ==========================
; This is the alias that opens battles
; ==========================
alias startnormal { 
  if (%battleis = on) { $clear_battle | halt }
  if ($lines($txtfile(battle.txt)) != $null) { .remove $txtfile(battle.txt) }
  if ($lines($txtfile(battle2.txt)) != $null) { .remove $txtfile(battle2.txt) }

  ; Determine if we have a battle type yet
  var %start.battle.type $1

  if (%force.ai.battle = true) { var %start.battle.type ai | unset %force.ai.battle }

  if (($readini(battlestats.dat, conquest, MonsterInfluence) >= 100) && ($current.battlestreak > 20)) {
    if (%start.battle.type = $null) {  var %outpost.chance $rand(1,100) }
    if (%start.battle.type != $null) { var %outpost.chance 100 }
    if (%outpost.chance <= 20) { var %start.battle.type defendoutpost } 
  }

  if (($readini(battlestats.dat, conquest, AlliedInfluence) >= 100) && ($current.battlestreak > 20)) {
    if (%start.battle.type = $null) {  var %assault.chance $rand(1,100) }
    if (%start.battle.type != $null) { var %assault.chance 100 }
    if (%assault.chance <= 20) { var %start.battle.type assault } 
  }

  ; If we don't, let's pick one.
  if (%start.battle.type = $null) { 

    ; Check for a static chance of a boss battle
    set %boss.battle.numbers $readini(system.dat, system, GuaranteedBossBattles)
    if (%boss.battle.numbers = $null) { set %boss.battle.numbers 10.15.20.30.60.100.150.180.220.280.320.350.401.440.460.501.560.601.670.705.780.810.890.920.999.1100.1199.1260. 1305.1464.1500.1650.1720.1880.1999.2050.2250.9999  }
    if ($istok(%boss.battle.numbers,$return_winningstreak,46) = $true) { var %start.battle.type boss }

    var %guaranteed.boss.chance $readini(battlestats.dat, TempBattleInfo, BossChance)
    if ((%guaranteed.boss.chance >= 100) && ($return_winningstreak > 10)) { var %start.battle.type boss }

    ; Pick a random chance of boss, monster or orbfountain
    if ($istok(%boss.battle.numbers,$return_winningstreak, 46) = $false) {   
      if ($return_winningstreak < 10) { var %valid.battle.types monster.monster.orbfountain.monster.monster.monster }
      if (($return_winningstreak >= 10) && ($return_winningstreak < 50)) { var %valid.battle.types boss.monster.orbfountain.monster.monster }
      if (($return_winningstreak >= 50) && ($return_winningstreak < 100)) { var %valid.battle.types monster.boss.monster.monster.orbfountain.monster.monster }
      if ($return_winningstreak >= 100) {  var %valid.battle.types monster.boss.monster.monster.orbfountain.monster.monster.monster }

      if ($readini(battlestats.dat, TempBattleInfo, LastBattleType) = boss) { var %valid.battle.types $remtok(%valid.battle.types, boss, 46) }
      if ($readini(battlestats.dat, TempBattleInfo, LastBattleType) = orbfountain) { var %valid.battle.types $remtok(%valid.battle.types, orbfountain, 46) }
    }

    ; If we're not in a boss battle, let's pick one at random.
    if (%start.battle.type = $null) { var %start.battle.type $gettok(%valid.battle.types,$rand(1,$numtok(%valid.battle.types,46)),46) }
    unset %boss.battle.numbers
  }

  unset %previous.battle.type

  if (%start.battle.type = ai) {
    var %time.to.enter 60
    $display.message($readini(translation.dat, battle, BattleOpenAIBet), global)
    $ai.battle.generate($2)
  }

  if (%start.battle.type != ai) {
    var %time.to.enter $readini(system.dat, system, TimeToEnter)
    if (%time.to.enter = $null) { var %time.to.enter 120 }
    var %time.to.enter.minutes $round($calc(%time.to.enter / 60),1)

    unset %battle.type

    if ($2 = savethepresident) { 
      set %savethepresident on
      $display.message($readini(translation.dat, Events, KidnappedPresident),global) 
      var %presidents.captured $readini(battlestats.dat, battle, CapturedPresidents)
      if (%presidents.captured = $null) { var %presidents.captured 0 }
      inc %presidents.captured 1 
      writeini battlestats.dat battle CapturedPresidents %presidents.captured 
      set %battle.type boss
    } 

    if ($2 = supplyrun) { 
      set %supplyrun on
      $display.message($readini(translation.dat, Events, SupplyRun),global) 
      var %supply.runs $readini(battlestats.dat, battle, SupplyRuns)
      if (%supply.runs = $null) { var %supply.runs 0 }
      inc %supply.runs 1 
      writeini battlestats.dat battle SupplyRuns %supply.runs
      set %battle.type boss
    }

    if (%start.battle.type = besieged) { 
      set %besieged on
      set %besieged.squad 1
      $display.message($readini(translation.dat, Events, Besieged), global)
      var %besieged.times $readini(battlestats.dat, battle, BesiegedTimes)
      if (%besieged.times = $null) { var %besieged.times 0 }
      inc %besieged.times 1 
      writeini battlestats.dat battle BesiegedTimes %besieged.times
    }

    if ((((%start.battle.type = boss) && ($2 != supplyrun) && ($2 != besieged) && ($2 != savethepresident)))) { 
      set %battle.type boss 
      if ($2 != $null) { set %boss.type $2 }

      if ($return.systemsetting(showCustomBattleMessages) != true) { $display.message($readini(translation.dat, Battle, BattleOpen), global)  }
      if ($return.systemsetting(showCustomBattleMessages) = true) { $display.message($readini(translation.dat, Battle, BattleOpenBoss), global) }
    }
    if (%start.battle.type = monster) { set %battle.type monster | $display.message($readini(translation.dat, Battle, BattleOpen), global) }
    if ((%start.battle.type = orbfountain) || (%start.battle.type = orb_fountain)) { set %battle.type orbfountain 
      if ($return.systemsetting(showCustomBattleMessages) != true) { $display.message($readini(translation.dat, Battle, BattleOpen), global)  }
      if ($return.systemsetting(showCustomBattleMessages) = true) {  $display.message($readini(translation.dat, Battle, BattleOpenOrbFountain), global) }
    }
    if (%start.battle.type = orbbattle) { set %battle.type orbfountain 
      if ($return.systemsetting(showCustomBattleMessages) != true) { $display.message($readini(translation.dat, Battle, BattleOpen), global)  }
      if ($return.systemsetting(showCustomBattleMessages) = true) {  $display.message($readini(translation.dat, Battle, BattleOpenOrbFountain), global) }
    }
    if (%start.battle.type = pvp) { set %mode.pvp on 

      if ($2 isnum) { set %battle.level.cap $2 | $display.message($readini(translation.dat, Battle, BattleOpenPVPLevelCap), global) }
      else { $display.message($readini(translation.dat, Battle, BattleOpenPVP), global) }
    }
    if (%start.battle.type = gauntlet) { set %battle.type monster | set %mode.gauntlet on | set %nosouls true | set %mode.gauntlet.wave 1 | $display.message($readini(translation.dat, Battle, BattleOpenGauntlet), global)  }
    if (%start.battle.type = manual) { set %battle.type manual | $display.message($readini(translation.dat, Battle, BattleOpenManual), global)  }
    if (%start.battle.type = mimic) { set %battle.type mimic | $display.message($readini(translation.dat, Battle, BattleOpenMimic), global) }
    if (%start.battle.type = defendoutpost) { set %battle.type defendoutpost 
      $display.message($readini(translation.dat, Battle, BattleDefendOutpost), global) 
    }
    if (%start.battle.type = assault) { set %battle.type assault | $display.message($readini(translation.dat, Battle, BattleAssaultOpen), global) }
    if (%start.battle.type = DragonHunt) { 
      set %battle.type DragonHunt | $display.message($readini(translation.dat, system, DragonHunt.BeginHunt), global) 

      if ($readini(battlestats.dat, AlliedForces, DragonBombing) = true) { 
        $display.message($readini(translation.dat, events, DragonHunt.Bombing), global) 
        var %dragon.level $readini($dbfile(dragonhunt.db), %dragonhunt.file.name, age)
        var %dragon.level $floor($calc(%dragon.level * .75))

        writeini $dbfile(dragonhunt.db) %dragonhunt.file.name age %dragon.level
        writeini battlestats.dat AlliedForces DragonBombing false
      }
    }

    if (%start.battle.type = torment) { set %battle.type torment | $display.message($readini(translation.dat, system, TormentBattleStarted), global) }
    if (%start.battle.type = cosmic) { set %battle.type cosmic | $display.message($readini(translation.dat, system, CosmicBattleStarted), global) }

    var %valid.battle.types ai.boss.monster.orbbattle.orbfountain.orb_fountain.pvp.gauntlet.manual.mimic.defendoutpost.assault.dragonhunt.torment.cosmic.besieged.supplyrun
    if ($istok(%valid.battle.types,$lower(%start.battle.type),46) = $false) {
      $display.message(4Invalid battle type: %start.battle.type ,global) 
      $clear_battle 
      halt 
    }
  }

  writeini battlestats.dat TempBattleInfo LastBattleType %start.battle.type

  set %battleis on | set %battleisopen on | writeini $txtfile(battle2.txt) BattleInfo PortalOpened $fulldate

  /.timerBattleStart off

  if (%time.to.enter = $null) { var %time.to.enter 120 }

  /.timerBattleBegin 0 %time.to.enter /battlebegin
}


; ==========================
; This is entering the battle
; ==========================
on 3:TEXT:!enter:#: { 
  if ($readini(system.dat, system, automatedaibattlecasino) = on) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 
  if (%battle.type = ai) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 

  if (%battle.type = dungeon) { $dungeon.enter($nick) }
  else { $enter($nick) }
}
ON 3:TEXT:*enters the battle*:#:  { 
  if ($readini(system.dat, system, automatedaibattlecasino) = on) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 
  if ($2 != enters) { halt } 
  if ($readini($char($1), info, flag) = monster) { halt }
  if ($readini($char($1), stuff, redorbs) = $null) { halt }
  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($readini(translation.dat, errors, PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($readini(translation.dat, errors, PlayerAccessOffDueToLogin), private) | halt }

  ; Check to see if the person has entered the max # of characters allowed
  $access.enter.limit.check($nick)

  if (%battle.type = dungeon) { $dungeon.enter($1) }
  else { $enter($1) }
}
ON 50:TEXT:*enters the battle*:#:  { 
  if ($readini(system.dat, system, automatedaibattlecasino) = on) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 
  if (%battle.type = dungeon) { $dungeon.enter($1) }
  else { $enter($1) }
}

alias enter {
  if (%battle.type = dungeon) { $dungeon.enter($1) | halt }

  if (%battle.type = torment) {
    var %player.level $get.level.basestats($1) 

    if ((%torment.level = anguish) || (%torment.level = misery)) { var %min.playerlevel 5000 }
    else {  var %min.playerlevel $calc(%torment.level * 500) }

    if (%player.level < %min.playerlevel) { $display.message($readini(translation.dat, errors, Torment.LevelTooLow), global) | halt }
  }

  if (%battle.type = cosmic) {
    if ($get.level($1) < 500) { $display.message($readini(translation.dat, errors, Cosmic.levelTooLow), global) | halt }
  }

  $checkchar($1)

  if ($isfile($txtfile(battle2.txt)) = $false) { $set_chr_name($1) |  $display.message($readini(translation.dat, battle, BattleClosed), global)  | halt }


  if ((%battleisopen != on) && ($return.systemsetting(AllowLateEntries) != true)) { $set_chr_name($1)
    $display.message($readini(translation.dat, battle, BattleClosed), global)  | halt 
  }

  if ($readini(system.dat, system,BattleThrottle) = true) {
    var %battle.throttle.number $readini($char($1), info, battlethrottleturn)
    if (%battle.throttle.number = $null) { var %battle.throttle.number 0 }
    inc %battle.throttle.number 1
    if (%battle.throttle.number >= $readini(battlestats.dat, battle, TotalBattles)) { $display.message($readini(translation.dat, errors, CanNotEnterDueToBattleThrottle), private) | halt }
    else { writeini $char($1) info battlethrottleturn $readini(battlestats.dat, battle, totalbattles) }
  } 

  set %curbat $readini($txtfile(battle2.txt), Battle, List)
  if ($istok(%curbat,$1,46) = $true) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, AlreadyInBattle), private) | halt  }

  ; There's a player limit in IRC mode due to the potential for flooding..  There is no limit for DCCchat mode.
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {
    if ($readini($txtfile(battle2.txt), BattleInfo, Players) >= 8) { $display.message($readini(translation.dat, errors, PlayerLimit),private) | halt }
  }

  ; For DCCchat mode we need to move the player into the battle room.
  writeini $char($1) DCCchat Room BattleRoom

  ; Add the person into the battle.
  %curbat = $addtok(%curbat,$1,46)
  writeini $txtfile(battle2.txt) Battle List %curbat

  if ($readini($char($1), info, flag) = $null) {
    remini $char($1) skills lockpicking.on

    ; Is the player too weak for this streak level?
    if (($return.systemsetting(AllowSpiritOfHero) = true) && (%mode.pvp != on)) { 
      if (($return_winningstreak > 12) && (%battle.type != DragonHunt)) {
        if (%battle.type != Torment) { 
          if (($calc($return_winningstreak - $get.level($1)) > 35) || ($calc($get.level($1) / $return_winningstreak) < .35)) {
            writeini $char($1) info levelsync yes
            $levelsync($1, $calc($return_winningstreak - 3))

            if ($readini(system.dat, system, PlayersMustDieMode) != true) {
              var %temp.hp.needed $round($calc(150 + ((($return_winningstreak - 3)  / 5) * 50)),0)
              if (%temp.hp.needed > $return.systemsetting(maxHP)) { var %temp.hp.needed $return.systemsetting(maxHP) }
              if ($readini($char($1), battle, hp) < %temp.hp.needed) { writeini $char($1) battle hp %temp.hp.needed }
            }

            $display.message($readini(translation.dat, system, SpiritOfHeroSync), battle)
            writeini $char($1) status SpiritOfHero true
          }
        }
      }
    }

    var %battleplayers $readini($txtfile(battle2.txt), BattleInfo, Players)
    inc %battleplayers 1 
    writeini $txtfile(battle2.txt) BattleInfo Players %battleplayers

    var %current.shop.level $readini($txtfile(battle2.txt), BattleInfo, ShopLevel)
    if (%current.shop.level = $null) { var %current.shop.level 0 }
    var %player.shop.level $readini($char($1), stuff, shoplevel)
    inc %current.shop.level %player.shop.level
    writeini $txtfile(battle2.txt) BattleInfo ShopLevel %current.shop.level

    var %current.player.levels $readini($txtfile(battle2.txt), BattleInfo, PlayerLevels)
    if (%current.player.levels = $null) { var %current.player.levels 0 }
    var %player.level $get.level($1)
    inc %current.player.levels %player.level
    writeini $txtfile(battle2.txt) BattleInfo PlayerLevels %current.player.levels

    if ($return.systemsetting(AllowPersonalDifficulty) = true) {
      var %current.difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
      if (%current.difficulty = $null) { var %current.difficulty 0 }
      var %player.difficulty $readini($char($1), info, difficulty)
      if (%player.difficulty = $null) { var %player.difficulty 0 }
      inc %current.difficulty %player.difficulty
      writeini $txtfile(battle2.txt) BattleInfo Difficulty %current.difficulty
    }
    if ($return.systemsetting(AllowPersonalDifficulty) != true) { writeini $txtfile(battle2.txt) BattleInfo Difficulty 0 }

    var %average.levels $round($calc(%current.player.levels / $readini($txtfile(battle2.txt), BattleInfo, Players)),0)
    writeini $txtfile(battle2.txt) BattleInfo AverageLevel %average.levels

    var %highest.level $readini($txtfile(battle2.txt), BattleInfo, HighestLevel)
    if (%highest.level = $null) { var %highest.level 0 }
    if (%player.level > %highest.level) { writeini $txtfile(battle2.txt) BattleInfo HighestLevel %player.level } 

    writeini $char($1) info SkippedTurns 0
  }

  $set_chr_name($1) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle), global)

  write $txtfile(battle.txt) $1

  ; Full the person entering the battle.
  if (($readini($char($1), info, levelsync) = $null) && ($readini($char($1), status, SpiritOfHero) != true)) { 
    $fulls($1, yes)
  }

  if ($return.potioneffect($1) = DragonSkin)  { 
    if ($readini($char($1), NaturalArmor, Name) = $null) {
      writeini $char($1) NaturalArmor Max 500
      writeini $char($1) NaturalArmor Current 500
      writeini $char($1) NaturalArmor Name Dragonskin
    }
  }

  writeini $char($1) info NeedsFulls yes

  ; level sync for defend/assault outpost type battles
  if ((%battle.type = defendoutpost) || (%battle.type = assault)) { 

    if ($return_winningstreak >= 100) { 
      if (%battle.type = defendoutpost) {  var %battle.level.cap $return.levelcapsetting(DefendOutpost) }
      if (%battle.type = assault) { var %battle.level.cap $return.levelcapsetting(Assault) }
      if (%battle.level.cap = null) { var %battle.level.cap 105 } 
      if ($get.level($1) > %battle.level.cap) {  $levelsync($1, %battle.level.cap) | $display.message(4 $+ %real.name has been synced to level %battle.level.cap for this battle, battle) }
    }
    else { 
      if ($get.level($1) > $calc(3 + $return_winningstreak)) { 
        $levelsync($1, $calc(3 + $return_winningstreak)) 
        $display.message(4 $+ %real.name has been synced to level $calc(3 + $return_winningstreak) for this battle, battle)
      }
    }
  }

  ; Level sync the supply wagon battles
  if (%supplyrun = on) { var %battle.level.cap $return_winningstreak
    if ($get.level($1) > %battle.level.cap) {  $levelsync($1, $calc(%battle.level.cap + 5)) | $display.message(4 $+ %real.name has been synced to level $calc(%battle.level.cap +5) for this battle, battle) }
  }

  ; Level sync the besieged battles
  if (%besieged = on) { var %battle.level.cap $return_winningstreak
    if ($get.level($1) > %battle.level.cap) {  $levelsync($1, %battle.level.cap) | $display.message(4 $+ %real.name has been synced to level %battle.level.cap for this battle, battle) }
  }

  ; Level sync dragon hunt battles
  if (%battle.type = dragonhunt) {
    var %battle.level.cap $readini($dbfile(dragonhunt.db), %dragonhunt.file.name, BattleLevel)  
    if (%battle.level.cap = $null) { var %battle.level.cap $readini($dbfile(dragonhunt.db), %dragonhunt.file.name, Age) }
    var %battle.level.cap $calc(%battle.level.cap + 5)
    if ($get.level($1) > %battle.level.cap) { $levelsync($1, %battle.level.cap) |  $display.message(4 $+ %real.name has been synced to level %battle.level.cap for this battle, battle) }
  }

  ; level sync cosmic battles
  if (%battle.type = cosmic) {
    var %battle.level.cap 500
    if ($get.level($1) > %battle.level.cap) { $levelsync($1, %battle.level.cap) |  $display.message(4 $+ %real.name has been synced to level %battle.level.cap for this battle, battle) }
  }

  if ((%mode.pvp = on) && (%battle.level.cap != $null)) {
    if ($get.level($1) > %battle.level.cap) {  $levelsync($1, %battle.level.cap) | $display.message(4 $+ %real.name has been synced to level %battle.level.cap for this battle, battle) }
  }

  ; Check for the Warbound achievement
  var %total.battles $readini($char($1), stuff, TotalBattles)
  if (%total.battles = $null) { var %total.battles 0 }
  inc %total.battles 1
  writeini $char($1) stuff TotalBattles %total.battles
  $achievement_check($1, Warbound)

  if ((%battleisopen = off) && (%curse.night = true)) { writeini $char($1) battle TP 0 }
}

; ==========================
; Flee the battle!
; ==========================
on 3:TEXT:!flee*:#:/flee $nick
on 3:TEXT:!run away*:#:/flee $nick
ON 50:TEXT:*flees the battle*:#:/flee $1

alias flee {
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }
  $check_for_battle($1)

  if ($is_charmed($1) = true) { $set_chr_name($1) | $display.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }

  if ((no-flee isin %battleconditions) || (no-fleeing isin %battleconditions)) { 
    $set_chr_name($1) | $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt 
  }
  writeini $char($1) battle status runaway
  $set_chr_name($1) | $display.message($readini(translation.dat, battle, FleeBattle), battle)

  var %number.of.flees $readini($char($1), stuff, TimesFled)
  if (%number.of.flees = $null) { var %number.of.flees 0 }
  inc %number.of.flees 1
  writeini $char($1) stuff TimesFled %number.of.flees

  $achievement_check($1, ScardyCat)

  $next
}

; ==========================
; The battle begins
; ==========================
alias battlebegin {
  unset %monster.list
  set %battleisopen off

  /.timerBattleBegin off

  ; Write the time the battle begins
  writeini $txtfile(battle2.txt) BattleInfo TimeStarted $fulldate

  ; Write the Flawless Victory flag
  writeini $txtfile(battle2.txt) BattleInfo FlawlessVictory true

  if (%battle.type = ai) { $ai.battle.updateodds | unset %betting.period |  $display.message($readini(translation.dat, system, BettingPeriodClosed), global) }

  ; First, see if there's any players in the battle..
  set %number.of.players $readini($txtfile(battle2.txt), BattleInfo, Players)

  if (%battle.type != ai) { 
    if ((%number.of.players = 0) || (%number.of.players = $null)) {  
      $display.message($readini(translation.dat, battle, NoPlayersOnField), global) 

      ; If the total average player's level is 1000 or higher, let's give the monsters some conquest points
      ; this represents the increasing threat of evil across the world
      if ($total.player.averagelevel >= 1000) {  
        $conquest.points(players, -2)  
        $conquest.points(monsters, 3)  
      }

      ; Increase the empty rounds counter and check to see if the empty rounds is > the max allowed before resetting the streak.
      var %max.emptyrounds $readini(system.dat, system, EmptyRoundsBeforeStreakReset)
      var %current.emptyrounds $readini(battlestats.dat, battle, emptyRounds) 
      inc %current.emptyrounds 1
      writeini battlestats.dat battle emptyRounds %current.emptyrounds
      if (%current.emptyrounds >= %max.emptyrounds) { 
        if ($readini(battlestats.dat, battle, winningStreak) > 0) { $display.message($readini(translation.dat, system, StreakResetTo0),global) | set %force.ai.battle true }
        writeini battlestats.dat battle emptyRounds 0
        writeini battlestats.dat battle winningStreak 0
        writeini battlestats.dat battle losingStreak 0
        remini battlestats.dat battle LastReload
        writeini battlestats.dat TempBattleInfo BossChance 0 
      }

      $clear_battle 
      halt 
    }
  }

  if (%mode.pvp = on) { 
    set %number.of.players $readini($txtfile(battle2.txt), BattleInfo, Players)
    if ((%number.of.players < 2) || (%number.of.players = $null)) {
      $display.message($readini(translation.dat, battle, NotEnoughPlayersOnField), global)
      $clear_battle | halt 
    }
  }

  set %ignore.clearfiles no

  ; Get a random battlefield

  if (%battle.type != mimic) { 
    if (((%boss.type != bandits) && (%boss.type != pirates) && (%boss.type != FrostLegion))) { unset %current.battlefield | $random.battlefield.pick }
  }

  if (%battle.type = DragonHunt) { set %current.battlefield Dragon's Lair }

  if (%battle.type = Torment) {
    set %current.battlefield Fields of Torment 
    writeini $txtfile(battle2.txt) battle alliednotes 500
    set %nosouls true

    if (%torment.level = anguish) { set %torment.level $calc((850 + $return_playerlevelhighest)/500) }
    if (%torment.level = misery) { set %torment.level $calc(900 + $return_playerlevelhighest) }
  }

  if (%battle.type = Cosmic) {
    set %current.battlefield Fields of Eternity
    writeini $txtfile(battle2.txt) battle alliednotes 500
    set %nosouls true
  }

  if (%savethepresident = on) { set %current.battlefield Monster Dungeon }

  if (%supplyrun = on) { 
    set %current.battlefield Treacherous Path
    set %nosouls true
  }

  if (%besieged = on) { set %current.battlefield Allied Forces HQ }

  if (%battle.type = defendoutpost) { 
    set %current.battlefield Allied Forces Outpost 
    writeini battlestats.dat conquest MonsterInfluence 0
    writeini $txtfile(battle2.txt) battle alliednotes 50
    set %nosouls true
  }

  if (%battle.type = assault) { 
    set %current.battlefield Monster's Outpost 
    writeini battlestats.dat conquest AlliedInfluence 0
    writeini $txtfile(battle2.txt) battle alliednotes 150
    writeini $txtfile(battle2.txt) battle outpostStrength 10
    set %nosouls true
  }

  if (%current.battlefield = $null) { set %current.battlefield the void }

  ; Get a random weather from the battlefield
  $random.weather.pick

  if ((%battle.type != ai) && (%battle.type != dragonhunt)) {

    ; Check the moon phase.
    $moonphase

    ; Check the Time of Day
    $timeofday

    ; Generate the monsters
    $battle.getmonsters

    ; Check for an NPC Ally to join the battle.
    $random.battlefield.ally
  }

  if (%battle.type = dragonhunt) { 
    $dragonhunt.createfile
    if ($readini(battlestats.dat, AlliedForces, DragonKiller) = true) { $dragonhunt.createdragonkiller }
  }

  ; Check for a random back attack.
  $random.surpriseattack

  ; Check for a random battle field curse.
  $random.battlefield.curse

  ; Check to see if there's any battlefield limitations
  $battlefield.limitations

  if ((%battle.type != ai) && (%besieged != on)) {
    if (%bloodmoon = on) {  $display.message($readini(translation.dat, Events, BloodMoon), battle) }
    ; Check to see if players go first
    $random.playersgofirst
  }

  ; Reset the empty rounds counter.
  writeini battlestats.dat battle emptyRounds 0

  ; Set the # of Turns Before Darkness
  set %darkness.turns 16

  if ((%number.of.monsters.needed <= 2) && (%battle.type != boss)) { set %darkness.turns 16 }
  if ((%number.of.monsters.needed > 2) && (%battle.type != boss))  { 
    if ($readini(battlestats.dat, battle, winningstreak) >= 1000) { set %darkness.turns 21 }
    else { set %darkness.turns 21 }
  }

  if (%battle.type = boss) { 
    writeini battlestats.dat TempBattleInfo BossChance 0 
    set %darkness.turns 21

    if ((%demonwall.name = Demon Wall) || (%demonwall.name = Wall of Flesh)) { unset %darkness.turns  }
    if ((%demonwall.name = $null) && (%demonwall.fight = on)) { unset %darkness.turns } 
  }

  if (%battle.type = torment) { set %darkness.turns 71 }
  if (%battle.type = cosmic) { set %darkness.turns 100 }
  if (%battle.type = dragonhunt) { set %darkness.turns 35 }
  if (%battle.type = manual) { set %darkness.turns 21 }
  if (%battle.type = orbfountain) { set %darkness.turns 16 } 
  if (%battle.type = defendoutpost) { set %darkness.turns 5 }
  if (%battle.type = assault) { set %darkness.turns 35 }

  if (%boss.type = predator) { set %darkness.turns 30 }

  if (%besieged = on) { set %darkness.turns 100 | writeini battlestats.dat MonsterForces Strength 0 }

  if (%mode.pvp = on) { unset %darkness.turns }
  if (%mode.gauntlet = on) { unset %darkness.turns }
  if (%battle.type = ai) { set %darkness.turns 50 } 

  unset %winning.streak

  ; Turn on the first round protection
  if (%battle.type != ai) {
    set %first.round.protection yes
    set %first.round.protection.turn 1
  }

  if (%besieged = on) {  $display.message(4The first squad of monsters has arrived!, battle)  }

  ; Generate the battle turn order and display who's going first.
  $generate_battle_order
  set %who $read -l1 $txtfile(battle.txt) | set %line 1
  set %current.turn 1 | set %true.turn 1
  $battlelist(public)

  if (%savethepresident = on) {  $display.message($readini(translation.dat, battle, Don'tLetPresidentDie), battle)  }
  if (%supplyrun = on) {  $display.message($readini(translation.dat, battle, Don'tLetWagonDie), battle)  }
  if (%battle.type = defendoutpost) { $display.message($readini(translation.dat, battle, DefendOutpostForTurns), battle) }
  if (%battle.type = assault) { $display.message($readini(translation.dat, battle, AssaultOutpost), battle) }
  if (%besieged = on) { $display.message($readini(translation.dat, battle, BesiegedGoal), battle) } 

  $display.message($readini(translation.dat, battle, StepsUpFirst), battle)

  ; To keep someone from sitting and doing nothing for hours at a time, there's a timer that will auto-force the next turn.
  var %nextTimer $readini(system.dat, system, TimeForIdle)
  if (%nextTimer = $null) { var %nextTimer 180 }
  /.timerBattleNext 1 %nextTimer /next forcedturn

  unset %number.of.players

  if (%demonwall.fight = on) { $battle_rage_warning } 

  if (($readini(battlestats.dat, dragonballs, ShenronWish) = on) && (%mode.gauntlet != on)) { $display.message($readini(translation.dat, Dragonball, ShenronWishActive), battle) }

  $aicheck(%who)
}

alias battle.getmonsters {

  if (%besieged = on) { $generate_monster(besieged) }

  if ((%mode.pvp != on) && (%besieged != on)) {
    set %winning.streak $readini(battlestats.dat, battle, winningstreak)

    ; Okay, so now we need to determine how many monsters to pull.
    set %number.of.monsters.needed 1
    if (%battle.type = boss) { %number.of.monsters.needed = 1 } 

    if (%battle.type = orbfountain) { 
      %number.of.monsters.needed = 1 
      /.timerOrbTimer 1 3600 /endbattle draw
    }
    if ((%battle.type != boss) && (%battle.type != orbfountain)) { 
      %number.of.monsters.needed = $round($calc(%number.of.players / 2),0)
      if (%number.of.monsters.needed > 5) { %number.of.monsters.needed = 5 }
    }

    if ((%battle.type = defendoutpost) && (%darkness.turns > 1)) { %number.of.monsters.needed = 2 }
    if ((%battle.type = defendoutpost) && (%darkness.turns = 1)) { %number.of.monsters.needed = 1 }
    if (%battle.type = assault) { %number.of.monsters.needed = $rand(2,3) }
    if (%battle.type = torment) { %number.of.monsters.needed = 5 }

    $winningstreak.addmonster.amount

    if (%battle.type = cosmic) { %number.of.monsters.needed = 1 }

    ; Let's see if there's any monsters already in battle (via !summon).  If so, we don't want more than 10..
    var %number.of.monsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
    if (%number.of.monsters = $null) { var %number.of.monsters 0 } 

    ; Check to see if we're over the max number of monsters allowed.
    var %max.number.of.mons $readini(system.dat, system, MaxNumberOfMonsInBattle)
    if (%max.number.of.mons = $null) { var %max.number.of.mons 10 }
    if (%number.of.monsters >= %max.number.of.mons) { set %number.of.monsters.needed 0 }

    ; Generate the monsters..

    if (%battle.type = orbfountain) { 
      $generate_monster(orbfountain)
    }

    if (%battle.type = monster) {

      if ($return_winningstreak > 10) { 
        var %next.bosschance $readini(battlestats.dat, TempBattleInfo, BossChance)
        if (%next.bosschance = $null) { var %next.bosschance 0 }
        inc %next.bosschance $rand(1,6)
        inc %next.bosschance $log($return_winningstreak)
        writeini battlestats.dat TempBattleInfo BossChance %next.bosschance
      }

      $generate_monster(monster)
    }

    if (%battle.type = mimic) {
      $generate_monster_mimic
    }

    if (%battle.type = defendoutpost) { 
      $generate_monster(monster)
    }

    if (%battle.type = assault) { 
      $generate_monster(monster)
    }

    if (%battle.type = torment) { 
      $generate_monster(monster, torment) 
    }

    if (%battle.type = cosmic) { $generate_monster(boss, cosmic) } 

    if (%battle.type = boss) {
      $generate_monster(boss)

      var %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
      if (%difficulty > 0) { inc %winning.streak %difficulty }

      if (%battle.type != manual) { 
        if (%winning.streak >= 101) { 
          if (%demonwall.fight != on) {
            set %number.of.monsters.needed $round($calc($return_playersinbattle / 2),0)
            if (%number.of.monsters.needed = $null) { set %number.of.monsters.needed 2 }

            if (%boss.type = bandits) { set %number.of.monsters.needed 0 }
            if (%boss.type = pirates) { set %number.of.monsters.needed 0 }
            if (%boss.type = predator) { set %number.of.monsters.needed 0 }
            if (%boss.type = dinosaurs) { set %number.of.monsters.needed 0 }
            if (%boss.type = FrostLegion) { set %number.of.monsters.needed 0 }
            if (%boss.type = CrystalShadow) { set %number.of.monsters.needed 0 }
            if (%boss.type = gremlins) { set %number.of.monsters.needed 0 }
            if (%boss.type = warmachine) { set %number.of.monsters.needed 0 }

            if ((%supplyrun = on) && ($return_winningstreak > 500)) {  set %number.of.monsters.needed 1  }

            if (%number.of.monsters.needed > 0) { $generate_monster(monster)   }
          }
        }
      }

      if (%savethepresident = on) { $generate_president }
      if (%supplyrun = on) { 
        $generate_wagon
        $generate_monster(monster) 
      }

    }
  }

  return
}

alias generate_monster {
  if ($1 = besieged) {
    if (%besieged.squad = 1) { var %number.of.monsters.needed = $rand(11,15) | var %monster.line.file monsters_cr1.lst | var %monster.level 50 }
    if (%besieged.squad = 2) { var %number.of.monsters.needed = $rand(9,10) | var %monster.line.file monsters_cr2.lst | var %monster.level 70 }
    if (%besieged.squad = 3) { var %number.of.monsters.needed = $rand(6,8) | var %monster.line.file monsters_cr3.lst | var %monster.level 80 }
    if (%besieged.squad = 4) { var %number.of.monsters.needed = $rand(4,5) | var %monster.line.file monsters_cr4.lst | var %monster.level 90 }
    if (%besieged.squad = 5) { var %number.of.monsters.needed = $rand(2,4) | var %monster.line.file monsters_cr5.lst | var %monster.level 100 }

    var %value 1

    while (%value <= %number.of.monsters.needed) {
      var %current.monster.to.spawn $read -l $+ $rand(1, $lines($lstfile(%monster.line.file))) $lstfile(%monster.line.file)
      var %multiple.monster.counter 2

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

      ; Boost the monster
      $levelsync(%current.monster.to.spawn.name, %monster.level)
      writeini $char(%current.monster.to.spawn.name) basestats str $readini($char(%current.monster.to.spawn.name), battle, str)
      writeini $char(%current.monster.to.spawn.name) basestats def $readini($char(%current.monster.to.spawn.name), battle, def)
      writeini $char(%current.monster.to.spawn.name) basestats int $readini($char(%current.monster.to.spawn.name), battle, int)
      writeini $char(%current.monster.to.spawn.name) basestats spd $readini($char(%current.monster.to.spawn.name), battle, spd)

      $boost_monster_hp(%current.monster.to.spawn.name, dungeon, $get.level(%current.monster.to.spawn.name))

      $fulls(%current.monster.to.spawn.name, yes)

      unset %found.monster
      inc %value
    }
  }


  if ($1 = orbfountain) {
    .copy -o $mon(orb_fountain) $char(orb_fountain)  | set %curbat $readini($txtfile(battle2.txt), Battle, List) | %curbat = $addtok(%curbat,orb_fountain,46) | writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) orb_fountain
    $boost_monster_stats(orb_fountain) | $fulls(orb_fountain)
    var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
    $set_chr_name(orb_fountain) 
    $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
    $display.message(12 $+ %real.name  $+ $readini($char(orb_fountain), descriptions, char), battle)
  }

  if ($1 = monster) {
    $get_mon_list($2)
    var %monsters.total $numtok(%monster.list,46)

    if ((%monsters.total = 0) || (%monster.list = $null)) { $display.message($readini(translation.dat, Errors, NoMonsAvailable), global) | $endbattle(none) | halt }

    if (%mode.gauntlet != $null) { set %number.of.monsters.needed 2  }

    if (%monsters.total = 1) { set %number.of.monsters.needed 1 }

    set %value 1 

    if (%battle.type != boss) { var %first.mon.pick false }

    while (%value <= %number.of.monsters.needed) {
      if (%monster.list = $null) { inc %value 10 } 

      set %monsters.total $numtok(%monster.list,46)
      if ((%first.mon.pick = true) || (%first.mon.pick = $null)) {  set %random.monster $rand(1, %monsters.total) }
      if (%first.mon.pick = false) { set %random.monster 1 | var %first.mon.pick true }
      set %monster.name $gettok(%monster.list,%random.monster,46)
      if (%monsters.total = 0) { inc %value 1 }

      if ($readini($mon(%monster.name), battle, hp) != $null) { 

        ; Copy the chosen monster template file to the char directory
        .copy -o $mon(%monster.name) $char(%monster.name) 

        if (%battle.type != dungeon) {
          ; Check to see if the monster type has a dynamic name
          if ($readini($char(%monster.name), info, streak) >= 1) {
            var %monster.type $readini($mon(%monster.name), monster, type)
            var %monster.class $readini($mon(%monster.name), monster, class)

            var %dynamic.filename names_ $+ %monster.type
            if (%monster.class != $null) { var %dynamic.filename %dynamic.filename $+ _ $+ %monster.class } 

            var %dynamic.filename %dynamic.filename $+ .lst

            if (($lines($lstfile(%dynamic.filename)) > 0) && ($return_winningstreak >= 25)) {
              var %dynamic.name.chance $rand(1,100)

              if (%dynamic.name.chance <= 40) {
                var %replacement.line $read($lstfile(%dynamic.filename), $rand(1, $lines($lstfile(%dynamic.filename))))
                var %replacement.filename $gettok(%replacement.line, 1, 46)
                var %replacement.realname $gettok(%replacement.line, 2, 46)
                var %monster.number 1

                while ($isfile($char(%replacement.filename)) = $true) {
                  inc %monster.number 1
                  %replacement.filename = %replacement.filename $+ %monster.number
                  %replacement.realname = %replacement.realname %monster.number
                }

                .rename $char(%monster.name) $char(%replacement.filename)
                writeini $char(%replacement.filename) basestats name %replacement.realname
                set %monster.name %replacement.filename
              }
            }
          }
        }

        ; Add the monster into the battle
        set %curbat $readini($txtfile(battle2.txt), Battle, List) | %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat 
      }

      if (($2 = addactionpoints) || ($3 = addactionpoints)) {
        ; Initialize the action points 
        $action.points(%monster.name, initialize)
      }

      ; Show the description of the monster when it enters
      $set_chr_name(%monster.name) 
      if (%battle.type != ai) { 
        if ($readini($char(%monster.name), battle, hp) != $null) { 
          $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
          $display.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)
        }
      }
      if (%battle.type = ai) { set %ai.monster.name $set_chr_name(%monster.name) %real.name | writeini $txtfile(1vs1bet.txt) money monsterfile %monster.name }

      ; If the battle is a torment, assault or defendoutpost we need to make inactive monsters active
      if (((%battle.type = torment) || (%battle.type = assault) || (%battle.type = defendoutpost))) { writeini $char(%monster.name) battle status normal } 

      var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
      inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters 

      ; Check for a drop
      $check_drops(%monster.name)

      set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
      set %monster.list $deltok(%monster.list,%monster.to.remove,46)
      write $txtfile(battle.txt) %monster.name

      if (%boss.type = predator) { writeini $char(%monster.name) info SpawnAfterDeath Predator }

      if ($2 = portal) { $boost_monster_stats(%monster.name, demonportal)  }
      else { $boost_monster_stats(%monster.name) }

      $fulls(%monster.name) 
      if (%battlemonsters = 10) { set %number.of.monsters.needed 0 }
      inc %value 1
      else {  
        set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
        set %monster.list $deltok(%monster.list,%monster.to.remove,46)
        dec %value 1
      }
    }
  }

  if ($1 = boss) {
    if ((%boss.type = $null) && ($2 != cosmic)) { $get_boss_type }

    set %valid.boss.types normal.bandits.gremlins.doppelganger.warmachine.demonwall.wallofflesh.predator.pirates.frostlegion.crystalshadow.dinosaurs

    if (%boss.type = $null) { var %boss.type normal }
    if ((%battle.type = assault) || (%battle.type = defendoutpost)) { set %boss.type normal }
    if (%boss.type = torment) { var %boss.type normal }
    if ($istok(%valid.boss.types,%boss.type,46) = $false) { var %boss.type normal }

    unset %valid.boss.types

    if (%battle.type = cosmic) { 
      var %total.cosmic.bosses $lines($lstfile(cosmic_bosses.lst))
      var %boss.picked.number $rand(1, %total.cosmic.bosses)
      var %monster.name $read($lstfile(cosmic_bosses.lst), %boss.picked.number) 

      if ($isfile($boss(%monster.name)) = $null) { $display.message(4Error: Boss not found! Ending Now!) | $endbat | halt }

      ; Copy the file and increase the battle info
      .copy -o $boss(%monster.name) $char(%monster.name)
      var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
      set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat  |   $set_chr_name(%monster.name) 
      write $txtfile(battle.txt) %monster.name 
      var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters 

      ; Display the entering message and quote
      $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
      $display.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)
      if ($readini($char(%monster.name), descriptions, BossQuote) != $null) { $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle) }
      writeini $char(%monster.name) battle status normal 

      ; Boost the monster
      if (%cosmic.level > 1) {  $levelsync(%monster.name, $calc(500 + (5 * %cosmic.level))) }
      else { $levelsync(%monster.name, 500)  }

      writeini $char(%monster.name) basestats str $readini($char(%monster.name), battle, str)
      writeini $char(%monster.name) basestats def $readini($char(%monster.name), battle, def)
      writeini $char(%monster.name) basestats int $readini($char(%monster.name), battle, int)
      writeini $char(%monster.name) basestats spd $readini($char(%monster.name), battle, spd)
      $boost_monster_hp(%monster.name, cosmic, $get.level(%monster.name))
      $fulls(%monster.name, yes)
      return
    }


    if (%boss.type = normal) {

      if ($rand(1,2) = 1) {
        if (%battle.type != defendoutpost) { writeini $txtfile(battle2.txt) BattleInfo CanKidnapNPCs yes }
      }

      $get_boss_list($2)
      var %monsters.total $numtok(%monster.list,46)

      if ((%monsters.total = 0) || (%monster.list = $null)) { $display.message(4Error: There are no bosses in the boss folder.. Have the bot admin check to make sure there are bosses for players to battle!, global) | $endbattle(none) | halt }
      if (%mode.gauntlet != $null) { set %number.of.monsters.needed 2  }
      if (%battle.type = defendoutpost) { set %number.of.monsters.needed 1 }
      if (%battle.type = assault) { set %number.of.monsters.needed 1 }

      if (%monsters.total = 1) { set %number.of.monsters.needed 1 }

      set %value 1
      while (%value <= %number.of.monsters.needed) {
        if (%monster.list = $null) { inc %value 1 } 
        set %monsters.total $numtok(%monster.list,46)
        set %random.monster $rand(1, %monsters.total) 
        set %monster.name $gettok(%monster.list,%random.monster,46)

        var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
        if ($readini($char(%monster.name), battle, hp) = $null) { inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters }

        .copy -o $boss(%monster.name) $char(%monster.name) | set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat  |   $set_chr_name(%monster.name) 
        if (%battle.type != ai) { 
          $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
          $display.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)
          if ($readini($char(%monster.name), descriptions, BossQuote) != $null) { $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle) }
        }
        if (%battle.type = ai) { set %ai.monster.name $set_chr_name(%monster.name) %real.name | writeini $txtfile(1vs1bet.txt) money monsterfile %monster.name }


        ; If the battle is a torment, assault or defendoutpost we need to make inactive monsters active
        if (((%battle.type = torment) || (%battle.type = assault) || (%battle.type = defendoutpost))) { writeini $char(%monster.name) battle status normal } 

        ; Check for a drop
        $check_drops(%monster.name)

        set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
        set %monster.list $deltok(%monster.list,%monster.to.remove,46)
        write $txtfile(battle.txt) %monster.name
        $boost_monster_stats(%monster.name) 
        $fulls(%monster.name)
        if (%battlemonsters = 10) { set %number.of.monsters.needed 0 }

        if ($2 = addactionpoints) {
          ; Initialize the action points 
          $action.points(%monster.name, initialize)
        }
        inc %value 1
      }
    }

    if (%boss.type = doppelganger) { 
      $display.message($readini(translation.dat, events, DoppelgangerFight), battle)

      var %battle.level.cap $return.levelcapsetting(Doppelganger)
      if (%battle.level.cap = null) { var %battle.level.cap 50 } 

      if ($return_winningstreak >= 50) { $portal.sync.players(%battle.level.cap) }

      $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)

      $generate_evil_clones
    }

    if (%boss.type = crystalshadow) { 
      $generate_crystalshadow
    }

    if (%boss.type = warmachine) {
      if (%battle.type != ai) { 
        $display.message($readini(translation.dat, events, WarmachineFight), battle) 

        if ($return_winningstreak < 50) {  
          set %battle.level.cap $return.levelcapsetting(SmallWarMachine)
          if (%battle.level.cap = null) { set %battle.level.cap 20 } 
        }

        if (($return_winningstreak >= 50) && ($return_winningstreak < 75)) {  
          set %battle.level.cap $return.levelcapsetting(MediumWarMachine)
          if (%battle.level.cap = null) { set %battle.level.cap 50 } 
        }

        if ($return_winningstreak >= 75) {  
          set %battle.level.cap $return.levelcapsetting(LargeWarMachine)
          if (%battle.level.cap = null) { set %battle.level.cap 75 } 
        }

        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
        unset %battle.level.cap
      }
      $generate_monster_warmachine
    }

    if (%boss.type = bandits) {
      $display.message($readini(translation.dat, events, BanditsFight), battle)
      if (%battle.type != ai) { 
        var %battle.level.cap $return.levelcapsetting(Bandits)
        if (%battle.level.cap = null) { var %battle.level.cap 50 } 
        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
      }

      $generate_bandit_leader

      if ($return_winningstreak > 100) {  var %number.of.bandits.needed $rand(2,3) }
      else {  var %number.of.bandits.needed $rand(1,2) }
      var %i 1
      while (%i <= %number.of.bandits.needed) {
        $generate_bandit_minion(%i)
        inc %i 1
      }

      set %current.battlefield highway
    }


    if (%boss.type = gremlins) {
      $display.message($readini(translation.dat, events, GremlinsFight), battle)

      if (%battle.type != ai) { 
        var %battle.level.cap $return.levelcapsetting(Gremlins)
        if (%battle.level.cap = null) { var %battle.level.cap 50 } 
        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
      }

      .copy -o $boss(Stripe) $char(Stripe) | set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat  |  $set_chr_name(stripe) 
      set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,Stripe,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) Stripe
      writeini $char(Stripe) Techniques GremlinBite 50 | writeini $char(Stripe) Weapons GremlinAttack 50 | writeini $char(Stripe) BaseStats HP $rand(4000,5000) | writeini $char(Stripe) Battle HP $readini($char(Stripe), BaseStats, HP) 

      if (%battle.type != ai) { 
        $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
        $display.message(12 $+ %real.name  $+ $readini($char(Stripe), descriptions, char), battle)
        $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(stripe), descriptions, BossQuote) $+ ", battle)
      }

      if ($readini(battlestats.dat, Battle, WinningStreak) > 100) {  var %number.of.gremlins.needed $rand(2,3) }
      else {  var %number.of.gremlins.needed $rand(1,2) }
      var %i 1
      while (%i <= %number.of.gremlins.needed) {
        $generate_gremlin(%i)
        inc %i 1
      }

      set %current.battlefield school
    }


    if (%boss.type = pirates) {
      $display.message($readini(translation.dat, events, PiratesFight), battle)

      if (%battle.type != ai) { 
        var %battle.level.cap $return.levelcapsetting(Pirates)
        if (%battle.level.cap = null) { var %battle.level.cap 75 } 
        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
      }

      $generate_pirate_firstmatey

      if ($readini(battlestats.dat, Battle, WinningStreak) >= 100) {  var %number.of.pirates.needed $rand(2,3) }
      else {  var %number.of.pirates.needed $rand(1,2) }
      var %i 1
      while (%i <= %number.of.pirates.needed) {
        $generate_pirate_scallywag(%i)
        inc %i 1
      }

      set %current.battlefield ocean
    }


    if (%boss.type = FrostLegion) {
      $display.message($readini(translation.dat, events, FrostLegionFight), battle)

      if (%battle.type != ai) { 
        var %battle.level.cap $return.levelcapsetting(FrostLegion)
        if (%battle.level.cap = null) { var %battle.level.cap 20 } 
        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
      }

      if ($readini(battlestats.dat, Battle, WinningStreak) >= 50) {  var %number.of.frosties.needed $rand(4,5) }
      else { var %number.of.frosties.needed $rand(3,4) }

      if (%number.of.frosties.needed = $null) { var %number.of.frosties.needed 5 }

      var %i 1
      while (%i <= %number.of.frosties.needed) {
        $generate_frost_monster(%i)
        inc %i 1
      }

      set %current.battlefield South Pole
    }

    if (%boss.type = predator) {
      if (%battle.type != ai) { 
        var %battle.level.cap $return.levelcapsetting(Predator)
        if (%battle.level.cap = null) { var %battle.level.cap 200 } 
        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
      }

      $predator_fight(%battle.level.cap)
    }

    if (%boss.type = dinosaurs) {  $generate_dinosaur }

    if (%boss.type = demonwall) {
      set %demonwall.name Demon Wall

      if (%battle.type != ai) { 

        $display.message($readini(translation.dat, events, DemonWallFight), battle)

        var %battle.level.cap $return.levelcapsetting(DemonWall)
        if (%battle.level.cap = null) { var %battle.level.cap 75 } 
        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
      }
      $generate_demonwall
      set %demonwall.fight on
    }

    if (%boss.type = wallofflesh) {
      set %demonwall.name Wall of Flesh
      if (%battle.type != ai) {  

        $display.message($readini(translation.dat, events, DemonWallFight), battle)

        var %battle.level.cap $return.levelcapsetting(WallOfFlesh)
        if (%battle.level.cap = null) { var %battle.level.cap 200 } 
        $display.message($readini(translation.dat, system,BossLevelSyncedCustom), battle)
        $portal.sync.players(%battle.level.cap) 
      }
      $generate_wallofflesh
      set %demonwall.fight on
    }
  }
}

; ==========================
; Battle Rage alias
; ==========================
alias battle_rage_warning {
  ; This alias is just used to display a warning before the darkness overcomes the battlefield.

  if (%battle.type = defendoutpost) { return }
  if (%mode.gauntlet != $null) { return }
  if ((%darkness.turns = $null) && (%demonwall.name = $null)) { return }

  if (%demonwall.fight != on) {  $display.message($readini(translation.dat, battle, DarknessWarning), battle)  }
  if (%demonwall.fight = on) { 

    if (%demonwall.name = Demon Wall) { 
      set %max.demonwall.turns $readini(system.dat, system, MaxDemonWallTurns)
      if (%max.demonwall.turns = $null) {  set %darkness.turns 11 | set %max.demonwall.turns 11 }
    }

    if ((%demonwall.name = Wall of Flesh) || (%demonwall.name = $null)) {
      set %max.demonwall.turns $readini(system.dat, system, MaxWallOfFleshTurns)
      if (%max.demonwall.turns = $null) {  set %darkness.turns 16 | set %max.demonwall.turns 16 }
    }

    $display.message($readini(translation.dat, events, DemonWallFightWarning), battle)
  } 
  set %darkness.fivemin.warn true
}

alias battle_rage {
  ; When this alias is called all the monsters still alive in battle will become much harder to kill as all of their stats will be increased
  ; The idea is to make it so battles don't last forever (someone can't stall for 2 hours on one battle).  Players need to kill monsters fast.

  if (%battle.type = defendoutpost) { return }
  if (%battle.type = ai) { $endbattle(draw) | halt } 

  set %battle.rage.darkness on

  $display.message($readini(translation.dat, battle, DarknessCoversBattlefield), battle)

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)

    if (%flag = monster) { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }

      var %ignore.flag $readini($char(%who.battle), info, RageMode)
      if (%ignore.flag != ignore) {

        $boost_monster_stats(%who.battle, rage)
        writeini $char(%who.battle) Basestats HP $readini($char(%who.battle), Battle, HP)
        writeini $char(%who.battle) Battle Tp $readini($char(%who.battle), BaseStats, TP)
        writeini $char(%who.battle) Battle Str $readini($char(%who.battle), BaseStats, Str)
        writeini $char(%who.battle) Battle Def $readini($char(%who.battle), BaseStats, Def)
        writeini $char(%who.battle) Battle Int $readini($char(%who.battle), BaseStats, Int)
        writeini $char(%who.battle) Battle Spd $readini($char(%who.battle), BaseStats, Spd)

      }

      inc %battletxt.current.line 1
    }
    else { inc %battletxt.current.line 1 }
  }
}

; ==========================
; Generate the turn order
; ==========================
alias generate_battle_order {
  ; Is the battle over? Let's find out.
  if (%battle.type != dungeon) { $battle.check.for.end }
  if (%battle.type = dungeon) {
    if (($dungeon.currentroom = 0) && (%current.turn = 2)) { $battle.check.for.end }
    if ($dungeon.currentroom > 0) { $battle.check.for.end }
  }

  ; get rid of the Battle Table and the now un-needed file
  if ($isfile(BattleTable.file) = $true) { 
    hfree BattleTable
    .remove BattleTable.file
  }

  ; make the Battle List table
  hmake BattleTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    set %battle.speed $readini($char(%who.battle), battle, spd)
    inc %battle.speed $armor.stat(%who.battle, spd)
    if ($readini($char(%who.battle), status, slow) = yes) { %battle.speed = $calc(%battle.speed / 2) } 
    if ($readini($char(%who.battle), status, doll) = yes) { %battle.speed = $round($calc(%battle.speed / 5),0) } 
    if ($readini($char(%who.battle), skills, Retaliation.on) = on) { %battle.speed = -1000 }

    set %current.playerstyle $readini($char(%who.battle), styles, equipped)
    set %current.playerstyle.level $readini($char(%who.battle), styles, %current.playerstyle)

    if (%current.playerstyle = Trickster) {  inc %battle.speed $calc(2 * %current.playerstyle.level)  }
    if (%current.playerstyle = HitenMitsurugi-ryu) {  inc %battle.speed $calc(3 * %current.playerstyle.level)  }

    $speed_up_check(%who.battle)

    if ($skill.speed.status(%who.battle) = on) { inc %battle.speed $skill.speed.calculate(%who.battle) }

    ; increase action points
    var %action.points $action.points(%who.battle, check)

    if (%clearactionpoints = true) { var %action.points 0 }

    inc %action.points 1
    if (%battle.speed >= 1) { inc %action.points $round($log(%battle.speed),0) }
    if ($readini($char(%who.battle), info, flag) = monster) { inc %action.points 1 }
    if ($readini($char(%who.battle), info, ai_type) = defender) { var %action.points 0 } 
    if ($readini($char(%who.battle), info, ai_type) = egg) { var %action.points 1 } 
    var %max.action.points $round($log(%battle.speed),0)
    inc %max.action.points 1

    if (($readini($char(%who.battle), skills, doubleturn.on) = on) && ($return.systemsetting(TurnType) = action)) { writeini $char(%who.battle) skills doubleturn.on off | inc %action.points 5 | inc %max.action.points 5 } 

    if (%action.points > %max.action.points) { var %action.points %max.action.points }

    writeini $txtfile(battle2.txt) ActionPoints %who.battle %action.points

    ; continue with creating the turn list
    if ($accessory.check(%who.battle, IncreaseTurnSpeed) = true) {
      var %battle.speed.inc $round($calc(%battle.speed * (%accessory.amount / 100)),0)
      inc %battle.speed %battle.speed.inc
      unset %accessory.amount | unset %accessory.found
    }

    unset %current.playerstyle | unset %current.playerstyle.level

    if (%surpriseattack = on) {
      var %ai.type $readini($char(%who.battle), info, ai_type)
      if (((%ai.type != defender) && (%ai.type != egg) && ($readini($char(%who.battle), monster, type) != object))) { 
        if ($readini($char(%who.battle), info, flag) = monster) { inc %battle.speed 9999999999 }
      }
    }

    if (%playersgofirst = on) {
      if ($readini($char(%who.battle), info, flag) = $null) { inc %battle.speed 9999999999 }
    }

    if ($readini($char(%who.battle), battle, status) = inactive) {  inc %battle.speed -9999999999 }
    if ($readini($char(%who.battle), monster, type) = object) { inc %battle.speed -99999999999 }
    if ($readini($char(%who.battle), info, ai_type) = defender) { inc %battle.speed -999999999999 }
    if ($readini($char(%who.battle), info, ai_type) = egg) { inc %battle.speed -999999999999 }

    if (%battle.speed <= 0) { set %battle.speed 1 }

    ; Write the person to the table and increase the counter
    hadd BattleTable %who.battle %battle.speed
    inc %battletxt.current.line
  }

  unset %clearactionpoints

  ; save the BattleTable hashtable to a file
  hsave BattleTable BattleTable.file

  ; load the BattleTable hashtable (as a temporary table)
  hmake BattleTable_Temp
  hload BattleTable_Temp BattleTable.file

  ; sort the Battle Table
  hmake BattleTable_Sorted
  var %battletableitem, %battletabledata, %battletableindex, %battletablecount = $hget(BattleTable_Temp,0).item
  while (%battletablecount > 0) {
    ; step 1: get the lowest item
    %battletableitem = $hget(BattleTable_Temp,%battletablecount).item
    %battletabledata = $hget(BattleTable_Temp,%battletablecount).data
    %battletableindex = 1
    while (%battletableindex < %battletablecount) {
      if ($hget(BattleTable_Temp,%battletableindex).data < %battletabledata) {
        %battletableitem = $hget(BattleTable_Temp,%battletableindex).item
        %battletabledata = $hget(BattleTable_Temp,%battletableindex).data
      }
      inc %battletableindex
    }

    ; step 2: remove the item from the temp list
    hdel BattleTable_Temp %battletableitem

    ; step 3: add the item to the sorted list
    %battletableindex = sorted_ $+ $hget(BattleTable_Sorted,0).item
    hadd BattleTable_Sorted %battletableindex %battletableitem

    ; step 4: back to the beginning
    dec %battletablecount
  }

  ; get rid of the temp table
  hfree BattleTable_Temp

  ; Erase the old battle.txt and replace it with the new one.
  .remove $txtfile(battle.txt)

  var %index = $hget(BattleTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(BattleTable_Sorted,sorted_ $+ %index)
    write $txtfile(battle.txt) %tmp
  }

  ; get rid of the sorted table
  hfree BattleTable_Sorted

  ; get rid of the Battle Table and the now un-needed file
  hfree BattleTable
  .remove BattleTable.file

  ; unset the battle.speed
  unset %battle.speed

  ; increase the current turn.
  inc %current.turn 1 | inc %true.turn 1

  ; Count the total number of monsters in battle
  $count.monsters

  unset %surpriseattack | unset %playersgofirst

  if (%first.round.protection.turn = $null) { var %first.round.protection.turn 1 }
  if (%current.turn > %first.round.protection.turn) { unset %first.round.protection | unset %first.round.protection.turn }

  if (%current.turn > 1) { 
    $battlefield.event
    if ($rand(1,10) <= 4) {  $random.weather.pick(inbattle) }
  }

  if (%current.turn > %max.demonwall.turns) { 
    if (%demonwall.fight = on) { 
      $display.message($readini(translation.dat, events, DemonWallFightOver), battle)
      unset %demonwall.fight 
      if (%battle.type = ai) { set %ai.winner 2Winner:4 %ai.monster.name | writeini $txtfile(1vs1bet.txt) money winner monster  } 
      /endbattle defeat 
      halt 
    }
  }

  ; Check for darkness warning
  if (%battle.type != defendoutpost) { 
    if (%darkness.fivemin.warn != true) { 

      if (%holy.aura.turn != $null) {
        if (%holy.aura.turn = %current.turn) { unset %holy.aura.turn | $holy_aura_end }
      }

      if (($calc(%darkness.turns - %current.turn) <= 5) && (%darkness.fivemin.warn != true)) { $battle_rage_warning }
    }
    if (%darkness.fivemin.warn = true) { 
      ; Check for darkness
      if (%battle.rage.darkness != on) { 
        if (%current.turn >= %darkness.turns) { $battle_rage }
      }
    }
  }

}

; ==========================
; The battle ends
; ==========================
alias endbattle {
  ; $1 can be victory, defeat or draw.

  set %thisbattle.winning.streak $return_winningstreak

  $clear_timers

  if (%battleis = off) { halt }

  set %total.battle.duration $battle.calculateBattleDuration

  ; Let's increase the total number of battles that we've had so far.
  if (((%mode.pvp != on) && (%battle.type != ai) && (%mode.gauntlet != on))) { var %totalbattles $readini(battlestats.dat, Battle, TotalBattles) |  inc %totalbattles 1 | writeini battlestats.dat Battle TotalBattles %totalbattles }

  $display.message($readini(translation.dat, battle, BattleIsOver), global)

  if ($1 = victory) { $battle.end.victory }
  if (($1 = defeat) || ($1 = failure)) { $battle.end.failure }
  if ($1 = draw) {  $battle.end.draw }

  ; Check to see if Shenron's Wish is active and if we need to turn it off..
  $db.shenronwish.turncheck

  ; If the battle is a 1vs1 AI battle we need to do some payouts.
  if (%battle.type = ai) { $ai.battle.payout }

  ; Reward the monsters some influence
  $battle.reward.influence(monsterforces)

  ; then do a $clear_battle
  unset %total.battle.duration | unset %thisbattle.winning.streak | set %battleis off | $clear_battle($1) | halt
}

; Battle ends in a failure
alias battle.end.failure {

  if (%battle.type = dungeon) { $dungeon.end(failure) | halt  }

  if ((%mode.pvp = on) || (%battle.type = ai)) { return } 

  if (%mode.gauntlet = $null) {
    if (((%battle.type != assault) && (%battle.type != torment) && (%battle.type != defendoutpost))) { var %defeats $readini(battlestats.dat, battle, totalLoss) | inc %defeats 1 | writeini battlestats.dat battle totalLoss %defeats }
  }    
  if (%mode.gauntlet != $null) {
    var %gauntlet.record $readini(battlestats.dat, battle, GauntletRecord) 
    if (%gauntlet.record = $null) { var %gauntlet.record 0 }
    if (%mode.gauntlet.wave > %gauntlet.record) { writeini battlestats.dat battle GauntletRecord %mode.gauntlet.wave }

    $display.message($readini(translation.dat, battle, GauntletOver), global)

  }

  if (((((%portal.bonus != true) && (%battle.type != mimic) && (%battle.type != dragonhunt) && (%supplyrun != on) && (%savethepresident != on))))) {

    if (%mode.gauntlet = $null) { 
      if (((%battle.type != defendoutpost) && (%battle.type != torment) && (%battle.type != assault))) { $display.message($readini(translation.dat, battle, EvilHasWon), global) }
    }

    if (%mode.gauntlet = $null) {

      var %conquest.points $conquest.points.calculate(defeat, %winning.streak)
      $conquest.points(monsters, %conquest.points)

      var %losing.streak $readini(battlestats.dat, battle, LosingStreak) | inc %losing.streak 1 | writeini battlestats.dat battle LosingStreak %losing.streak
      writeini battlestats.dat battle WinningStreak 0
    }
  }

  if (%besieged = on) {
    $display.message($readini(translation.dat, battle, EvilHasWonBesieged), global) 
    var %total.besieged $readini(battlestats.dat, battle, TotalBesiegedLost)
    if (%total.besieged = $null) { var %total.besieged 0 }
    inc %total.besieged 1
    writeini battlestats.dat battle TotalBesiegedLost %total.besieged
    $conquest.points(players,-1000) |  $conquest.points(monsters,500) | $shopnpc.kidnap | $shopnpc.kidnap
  } 

  if (%battle.type = defendoutpost) {
    $display.message($readini(translation.dat, battle, OutpostBattleLost), global) 
    var %total.defendedoutposts $readini(battlestats.dat, battle, TotalOutpostsLost)
    if (%total.defendedoutposts = $null) { var %total.defendedoutposts 0 }
    inc %total.defendedoutposts 1
    writeini battlestats.dat battle TotalOutpostsLost %total.defendedoutposts
  } 

  if (%battle.type = assault) {
    $display.message($readini(translation.dat, battle, AssaultBattleLost), global) 
    var %total.assault $readini(battlestats.dat, battle, TotalAssaultLost)
    if (%total.assault = $null) { var %total.assault 0 }
    inc %total.assault 1
    writeini battlestats.dat battle TotalAssaultLost %total.assault
  } 

  if (%battle.type = torment) {
    $display.message($readini(translation.dat, battle, Torment.BattleLost), global)
  }

  if (%battle.type = dragonhunt) {
    $display.message($readini(translation.dat, battle, DragonHunt.BattleLost), global) 
    ; Level up the dragon
    var %current.dragonage $dragonhunt.dragonage(%dragonhunt.file.name)
    inc %current.dragonage $readini($txtfile(battle2.txt), BattleInfo, Players)  
    writeini $dbfile(dragonhunt.db) %dragonhunt.file.name Age %current.dragonage
  }

  if (%portal.bonus = true) { 
    var %portal.item $readini($txtfile(battle2.txt), BattleInfo, PortalItem)
    var %portal.defeat.message $readini($dbfile(items.db), %portal.item, Defeat)
    $display.message($readini(translation.dat, battle, EvilHasWonPortal), global) 
    if (%portal.defeat.message != $null) { $display.message(4 $+ %portal.defeat.message, global) }
  }
  if (%savethepresident = on) { $display.message($readini(translation.dat, battle, EvilHasWonPresident), global) 
    var %presidents.captured $readini(battlestats.dat, battle, CapturedPresidents.Fails)
    if (%presidents.captured = $null) { var %presidents.captured 0 }
    inc %presidents.captured 1 
    writeini battlestats.dat battle CapturedPresidents.Fails %presidents.captured 

    writeini shopnpcs.dat NPCStatus AlliedForcesPresident false
  }

  if (%supplyrun = on) { $display.message($readini(translation.dat, battle, EvilHasWonSupplyRun), global) 
    var %supplyruns.failed $readini(battlestats.dat, battle, SupplyRuns.Failed)
    if (%supplyruns.failed = $null) { var %supplyruns.failed 0 }
    inc %supplyruns.failed 1 
    writeini battlestats.dat battle SupplyRuns.Failed %supplyruns.failed 

    var %allied.influence $readini(battlestats.dat, conquest, AlliedInfluence)
    dec %allied.influence 50 
    if (%allied.influence <= 0) { var %allied.influence 0 }
    writeini battlestats.dat conquest AlliedInfluence %allied.influence
    writeini battlestats.dat conquest SupplyRunChance 0
  }

  $battle.calculate.redorbs(defeat, %thisbattle.winning.streak)
  $battle.reward.redorbs
  $battle.reward.killcoins
  $display.message($readini(translation.dat, battle, RewardOrbsLoss), battle)

  if (%battle.type != dragonhunt) { $shopnpc.kidnap }
}

; Battle ends in a victory
alias battle.end.victory {
  if ((%mode.pvp = on) || (%battle.type = ai)) { return } 

  if (%battle.type = DragonHunt) { 
    var %dragonhunts.dead $readini(battlestats.dat, Battle, DragonHuntDragons.Killed)
    if (%dragonhunts.dead = $null) { var %dragonhunts.dead 0 }

    inc %dragonhunts.dead 1 

    writeini battlestats.dat Battle DragonHuntDragons.Killed %dragonhunts.dead

  }

  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
  var %wins $readini(battlestats.dat, battle, totalWins) | inc %wins 1 | writeini battlestats.dat battle totalWins %wins

  if ((((((((%portal.bonus != true) && (%battle.type != torment) && (%besieged != on) && (%battle.type != mimic) && (%battle.type != defendoutpost) && (%battle.type != assault) && (%battle.type != dragonhunt) && (%supplyrun != on) && (%savethepresident != on)))))))) {

    var %winning.streak.increase 1 

    ; Check for Flawless Victory
    if ((%winning.streak > 50) && ($readini($txtfile(battle2.txt), BattleInfo, FlawlessVictory) = true))  { 
      $display.message($readini(translation.dat, Battle, FlawlessVictory), global)
      inc %winning.streak.increase 9 
    }

    inc %winning.streak %winning.streak.increase

    writeini battlestats.dat battle WinningStreak %winning.streak

    var %winning.streak.record $readini(battlestats.dat, battle, WinningStreakRecord)
    if (%winning.streak.record = $null) { var %winning.streak.record 0 }
    if (%winning.streak > %winning.streak.record) { writeini battlestats.dat battle WinningStreakRecord %winning.streak }

    writeini battlestats.dat battle LosingStreak 0
    $display.message($readini(translation.dat, battle, GoodHasWon), global)
  }

  if (%battle.type = assault) { 
    $display.message($readini(translation.dat, battle, assaultBattleWon), global) 
    var %total.assaults $readini(battlestats.dat, battle, TotalAssaultWon)
    if (%total.assaults = $null) { var %total.assaults 0 }
    inc %total.assaults 1
    writeini battlestats.dat battle TotalAssaultWon %total.assaults
  } 

  if (%battle.type = defendoutpost) { 
    $display.message($readini(translation.dat, battle, OutpostBattleWon), global) 
    var %total.outposts $readini(battlestats.dat, battle, TotalOutpostsDefended)
    if (%total.outposts = $null) { var %total.outposts 0 }
    inc %total.outposts 1
    writeini battlestats.dat battle TotalOutpostsDefended %total.outposts
  } 

  if (%besieged = on) {
    $display.message($readini(translation.dat, battle, GoodHasWonBesieged), global) 
    var %total.besieged $readini(battlestats.dat, battle, TotalBesiegedWon)
    if (%total.besieged = $null) { var %total.besieged 0 }
    inc %total.besieged 1
    writeini battlestats.dat battle TotalBesiegedWon %total.besieged
    $conquest.points(monsters,-1000) | $conquest.points(players,1000)
  } 

  if (%battle.type = torment) { $display.message($readini(translation.dat, battle, Torment.BattleWon), global)  }
  if (%battle.type = dragonhunt) {  $display.message($readini(translation.dat, battle, DragonHunt.BattleWon), global)  }

  if (%portal.bonus = true) { 
    var %portal.item $readini($txtfile(battle2.txt), BattleInfo, PortalItem)
    var %portal.defeat.message $readini($dbfile(items.db), %portal.item, Victory)
    $display.message($readini(translation.dat, battle, GoodHasWonPortal), battle)
    if (%portal.defeat.message != $null) { $display.message(4 $+ %portal.defeat.message, global) }
  }

  if (%savethepresident = on) { $display.message($readini(translation.dat, battle, GoodHasWonPresident), battle) 
    var %presidents.captured $readini(battlestats.dat, battle, CapturedPresidents.Wins)
    if (%presidents.captured = $null) { var %presidents.captured 0 }
    inc %presidents.captured 1 
    writeini battlestats.dat battle CapturedPresidents.Wins %presidents.captured 
    writeini shopnpcs.dat NPCStatus AlliedForcesPresident true
  }

  if (%supplyrun = on) { $display.message($readini(translation.dat, battle, GoodHasWonSupplyRun), global) 
    var %supplyruns.won $readini(battlestats.dat, battle, SupplyRuns.Won)
    if (%supplyruns.won = $null) { var %supplyruns.won 0 }
    inc %supplyruns.won 1 
    writeini battlestats.dat battle SupplyRuns.won %supplyruns.Won 

    var %allied.influence $readini(battlestats.dat, conquest, AlliedInfluence)
    inc %allied.influence 50
    if (%allied.influence <= 0) { var %allied.influence 0 }
    writeini battlestats.dat conquest AlliedInfluence %allied.influence
    writeini battlestats.dat conquest SupplyRunChance 0
  }

  $battle.alliednotes.check
  $battle.calculate.redorbs(victory, %thisbattle.winning.streak)
  $battle.reward.redorbs(victory)
  $battle.reward.killcoins
  $battle.reward.playerstylepoints
  $battle.reward.playerstylexp
  $battle.reward.ignitionGauge.all

  ; Erase the dragon if the battle was a dragon hunt
  if (%battle.type = DragonHunt) { remini $dbfile(dragonhunt.db) %dragonhunt.file.name }

  var %conquestpoints $conquest.points.calculate(victory, %winning.streak)
  $conquest.points(players, %conquestpoints)

  if (%battle.type = assault) {
    var %enemy.conquestpoints $readini(battlestats.dat, conquest, ConquestPointsMonsters)
    if (%enemy.conquestpoints != $null) { 
      var %enemy.conquestpoints $round($calc(%enemy.conquestpoints / 2),0)
      writeini battlestats.dat conquest ConquestPointsMonsters %enemy.conquestpoints
    }
  }

  $generate_style_order
  $display.message($readini(translation.dat, battle, RewardOrbsWin), battle)

  ; Check to see if allied notes are involved.
  if ((((%portal.bonus = true) || (%savethepresident = on) || (%supplyrun = on) || ($readini($txtfile(battle2.txt), battle, alliednotes) != $null)))) { $display.message($readini(translation.dat, battle, AlliedNotesGain), battle)  }

  ; Check for Allied Influence
  if (%supplyrun != on) { $battle.reward.influence(alliedforces) }

  ; If boss battle, do black orbs for select players.
  unset %black.orb.winners
  if ((((%battle.type = boss) || (%battle.type = assault) || (%battle.type = dragonhunt) || (%battle.type = defendoutpost)))) {
    $battle.reward.blackorbs 

    if (%black.orb.winners != $null) { $display.message($readini(translation.dat, battle, BlackOrbWin), battle) }
    $give_random_reward
    $db.dragonball.find

    ; Check for Santa's Elves
    if ($left($adate, 2) = 12) {
      var %elf.save.chance $rand(1,100)
      inc %elf.save.chance $left($date, 2)
      if (%elf.save.chance >= 70) { $shopnpc.event.saveelf }
    }
  }

  if ((((((%battle.type != defendoutpost) && (%besieged != on) && (%battle.type != torment) && (%supplyrun != on) && (%battle.type != cosmic) && (%battle.type != assault)))))) { $shopnpc.rescue }
  if (%boss.type = FrostLegion) { writeini shopnpcs.dat Events FrostLegionDefeated true }

  if (%battle.type = torment) { $torment.reward }
  if (%battle.type = cosmic) { $cosmic.reward } 
  if (%besieged = on) { $besieged.reward } 

  if (((%battle.type != orbfountain) && (%battle.type != cosmic) && (%battle.type != torment))) { 
    $give_random_reward

    if (%portal.bonus = true) { $portal.spoils.drop }

    ; Check for a small chance of saving one of Santa's Elves in Dec on streaks 1000+
    if ((%portal.bonus != true) && ($current.battlestreak >= 500)) { 
      if ($left($adate, 2) = 12) {
        var %elf.save.chance $rand(1,100)
        inc %elf.save.chance $left($date, 2)
        if (%elf.save.chance >= 80) { $shopnpc.event.saveelf }
      }
    }

    ; If the reward streak is > 15 then we can check for keys and if it's +25 then we can check for creating a chest
    if ($readini(system.dat, system, EnableChests) = true) {
      if ((%portal.bonus = true) || ($readini(battlestats.dat, dragonballs, ShenronWish) = on)) { $give_random_key_reward | $create_treasurechest  }
      else {

        if (%winning.streak >= 15) {  $give_random_key_reward }
        if (%winning.streak >= 25) { 
          if (%battle.type != mimic) {
            var %chest.chance $rand(1,100)
            if (%chest.chance >= 60) {  $create_treasurechest }
          }
        }
      }
    }


    $give.random.capsule

    $show.random.reward
  }

  $show.torment.reward
  $show.cosmic.reward
  $show.besieged.reward
}

; Battle ends in a draw
alias battle.end.draw { 
  $display.message($readini(translation.dat, battle, BattleIsOver), global)
  if ((%mode.pvp = on) || (%battle.type = ai)) { return } 

  if (%portal.bonus != true) { $display.message($readini(translation.dat, battle, BattleIsDraw), global) }

  if (%mode.gauntlet = $null) {
    var %totaldraws $readini(battlestats.dat, Battle, TotalDraws) 
    if (%totaldraws = $null) { var %totaldraws 0 } 
    inc %totaldraws 1 | writeini battlestats.dat Battle TotalDraws %totaldraws
  }

  if (%portal.bonus = true) { $display.message($readini(translation.dat, battle, DrawPortal), global) }

  $battle.calculate.redorbs(draw, %thisbattle.winning.streak)
  $battle.reward.redorbs
  $battle.reward.killcoins
  $display.message($readini(translation.dat, battle, RewardOrbsDraw), battle)
}

; ==========================
; The $next command.
; ==========================
alias next {
  set %debug.location alias next
  unset %skip.ai | unset %file.to.read.lines | unset %user.gets.second.turn

  ; Reset the Next timer.
  $system.timer.battlenext

  if ($1 = ForcedTurn) { 
    var %forced.turns $readini($char(%who), info, SkippedTurns)
    inc %forced.turns 1

    var %max.idle.turns $return.systemsetting(MaxIdleTurns)
    if (%max.idle.turns = null) { var %max.idle.turns 2 | writeini system.dat system MaxIdleTurns 2 }

    if ((%forced.turns >= %max.idle.turns) && ($readini($char(%who), info, flag) = $null)) { $display.message($readini(translation.dat, battle, DroppedOutofBattle), battle) |  writeini $char(%who) battle status runaway }
    writeini $char(%who) info SkippedTurns %forced.turns
  }

  if (%battleis = off) { $clear_battle | halt }

  if ($readini($char(%who), info, ai_type) = PayToAttack) { writeini $char(%who) stuff redorbs 0 }

  inc %line 1
  set %next.person $read -l $+ %line $txtfile(battle.txt)

  if (%next.person = $null) { set %line 1 | $generate_battle_order  } 
  set %who $read -l $+ %line $txtfile(battle.txt)
  $turn(%who)
}


; ==========================
; Controls the turn
; ==========================
alias turn {
  set %debug.location alias turn
  unset %all_status | unset %status.message
  unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %drainsamba.on | unset %absorb
  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone | unset %double.attack 
  unset %damage.display.color

  set %status $readini($char($1), Battle, Status)
  if ((%status = dead) || (%status = runaway)) { unset %status | $next | halt }

  if ($readini($char($1), info, ai_type) = defender) {
    if ($readini($char($1), descriptions, DefenderAI) != $null) { $set_chr_name($1) | $display.message(4 $+ $readini($char($1), descriptions, DefenderAI), battle) }
    $ai.monstersummon($1) 
    $next 
    halt
  }

  if (($1 = orb_fountain) || ($1 = lost_soul)) { 
    if (%current.turn < %darkness.turns) { $next | halt }
  }

  if ($readini($char($1), battle, status) = inactive) {  $next  |  halt  }

  if ($readini($char($1), info, FirstTurn) = true) { writeini $char($1) info FirstTurn false | $next | halt }

  ; Clear dead monsters
  $portal.clear.monsters

  ; Is the battle over? Let's find out.
  $battle.check.for.end

  set %wait.your.turn on

  if ($person_in_mech($1) = false) { $turn.statuscheck($1) }

  if ($person_in_mech($1) = true) {
    ; Check to see if we have enough energy to maintain the mech.

    var %current.energylevel $readini($char($1), mech, energyCurrent)
    var %base.energycost $mech.baseenergycost($1)

    ; Check for the DecreaseMechEnergyCost augment that will decrease the amount of energy needed to run a mech
    if ($augment.check($1, DecreaseMechEnergyCost) = true) {  dec %base.energycost $round($calc(%base.energycost *  (%augment.strength *.25)),0) }

    dec %current.energylevel %base.energycost
    if (%current.energylevel < 0) { var %current.energylevel 0 }

    writeini $char($1) mech energyCurrent %current.energylevel

    if (%current.energylevel = 0) {  
      ; Shut down the mech and force the person out.
      $mech.deactivate($1, true)
      $set_chr_name($1) | var %mech.name $readini($char($1), mech, name)
      $display.message($readini(translation.dat, errors, MechOutOfEnergy), battle)
      $turn.statuscheck($1) 
    }
  }

  set %debug.location alias turn

  $hp_status($1) | $set_chr_name($1)

  ; Does the person have any action points this round?
  if ($return.systemsetting(TurnType) = action) {
    if ($action.points($1, check) <= 0) { set %skip.ai on |  set %status.message $readini(translation.dat, battle, NoActionPoints) }
    else { set %status.message $readini(translation.dat, battle, TurnMessage) }
  }
  else { set %status.message $readini(translation.dat, battle, TurnMessage) }

  if ($person_in_mech($1) = true) { 
    $hp_mech_hpcommand($1)
    set %real.name %real.name $+ 's $readini($char($1), mech, name) 
    %all_status = none 
    %all_skills = none 
    var %energy.level $round($calc( 100 * ($readini($char($1), mech, energyCurrent) / $readini($char($1), mech, EnergyMax))),0) $+ $chr(37)
    set %status.message $readini(translation.dat, battle, TurnMessageMech)
  }

  $display.message.delay(%status.message, battle, 1)

  if (($lines($txtfile(temp_status.txt)) != $null) && ($lines($txtfile(temp_status.txt)) > 0)) { 
    /.timerThrottle $+ $rand(a,z) $+ $rand(1,1000) $+ $rand(a,z) 1 1 /display.statusmessages $1 
  } 

  if ($readini($char($1), status, curse) != yes) {
    ; Add some TP to the player if it's not at max.
    set %tp.have $readini($char($1), battle, tp)
    set %tp.max $readini($char($1), basestats, tp)
    inc %tp.have 5

    set %debug.location alias turn (zencheck)
    if ($readini($char($1), skills, zen) > 0) { 
      var %zen.tp.gain $calc($readini($char($1), skills, Zen) * 5)
      if ($augment.check($1, EnhanceZen) = true) {  inc %zen.tp.gain $round($calc(%augment.strength * 10),0) }
      inc %tp.have %zen.tp.gain
    }

    if (%tp.have >= %tp.max) { writeini $char($1) battle tp %tp.max }
    else { writeini $char($1) battle tp %tp.have }
    unset %tp.have | unset %tp.max
  }

  if ($lines($txtfile(temp_status.txt)) != $null) { 
    set %file.to.read.lines $lines($txtfile(temp_status.txt))
    inc %file.to.read.lines 2
  }

  ; If we're in gauntlet mode and the turn is a multiple of 15 we need to reset certain skills.
  if (%mode.gauntlet = on) {
    var %gauntlet.mode.streak.check $calc(%mode.gauntlet.wave % 15)
    if (%gauntlet.mode.streak.check = 0) { $clear_certain_skills($1) }
  }

  ; Decay some style points
  $stylepoints.decay($1)

  writeini $char($1) Status burning no | writeini $char($1) Status drowning no | writeini $char($1) Status earthquake no | writeini $char($1) Status tornado no 
  writeini $char($1) Status freezing no | writeini $char($1) status frozen no | writeini $char($1) status shock no

  if ($readini($char($1), status, staggered) = yes) { set %skip.ai on | writeini $char($1) status staggered no  | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }

  if ($readini($char($1), Status, Blind) = yes)  { var %skip.turn true }
  if ($readini($char($1), Status, Petrified) = yes) { var %skip.turn true }
  if ($readini($char($1), status, bored) = yes) { var %skip.turn true }
  if ($readini($char($1), Status, intimidate) = yes) { var %skip.turn true }
  if ($readini($char($1), Status, terrify) = yes) { var %skip.turn true }
  if (%too.drunk.to.fight = true) { var %skip.turn true }

  if (%skip.turn = true) { 
    unset %too.drunk.to.fight  | writeini $char($1) status petrified no | writeini $char($1) status intimidate no 
    writeini $char($1) status terrify no | writeini $char($1) Status blind no | writeini $char($1) status paralysis no
    writeini $char($1) status paralysis.timer 1 | writeini $char($1) status stun no | writeini $char($1) status stop no 
    set %skip.ai on | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt
  }

  if ($readini($char($1), Status, cocoon) = yes) { set %skip.ai on |  /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next  | halt }
  if ($readini($char($1), status, paralysis) = yes) { set %skip.ai on | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next  | halt }
  if ($readini($char($1), status, sleep) = yes) { set %skip.ai on | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt  }
  if ($readini($char($1), status, stun) = yes) { set %skip.ai on | writeini $char($1) status stun no | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }
  if ($readini($char($1), status, stop) = yes) { set %skip.ai on | writeini $char($1) status stop no | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }

  if (($return.systemsetting(TurnType) = action) && ($action.points($1, check) <= 0)) { /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }


  ; Reset the Current Action counter
  writeini $char($1) Battle CurrentAction 1

  if (%skip.ai != on) {
    ; Check for AI
    if (%file.to.read.lines > 0) { 
      /.timerSlowYouDown $+ $rand(a,z) $+ $rand(1,100) 1 %file.to.read.lines /set %wait.your.turn off 
      /.timerSlowYouDown2 $+ $rand(a,z) $+ $rand(1,100) 1 %file.to.read.lines /aicheck $1 | halt
    }
    else { set %wait.your.turn off | $aicheck($1) | halt }
  }
}

; ==========================
; See if all the players are dead.
; ==========================
alias battle.player.death.check {
  set %debug.location battle.player.death.check
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)  | var %summon.flag $readini($char(%who.battle), info, summon)
    if (%flag = monster) { inc %battletxt.current.line }
    else {
      if ((%flag = npc) && (%battle.type != ai)) { inc %battletxt.current.line }
      else if (%summon.flag = yes) { inc %battletxt.current.line }
      else { 
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %death.count 1 | inc %battletxt.current.line 1 }
        else { inc %battletxt.current.line 1 } 
      }
    }
  }

  if (%mode.pvp != on) {
    if (%death.count = $readini($txtfile(battle2.txt), BattleInfo, Players)) { return true } 
    else { return false }
  }
  if (%mode.pvp = on) {
    if (%death.count = $calc($readini($txtfile(battle2.txt), BattleInfo, Players) - 1)) { return true }
    else { return false }
  }
}

; ==========================
; See if all the monsters are dead
; ==========================
alias battle.monster.death.check {
  set %debug.location battle.monster.death.check
  if (%mode.pvp = on) { return }

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %summon.flag $readini($char(%who.battle), info, summon)
    var %clone.flag $readini($char(%who.battle), info, clone)
    var %doppel.flag $readini($char(%who.battle), info, Doppelganger)
    var %object.flag $readini($char(%who.battle), monster, type)

    if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
    else {
      var %increase.count yes

      if ((%clone.flag = yes) && (%doppel.flag != yes)) { var %increase.count no }
      if (%summon.flag = yes) { var %increase.count no }
      if (%object.flag = object) { var %increase.count no } 

      if (%increase.count = yes) { 
        var %current.status $readini($char(%who.battle), battle, status)
        if (((%current.status = dead) || (%current.status = runaway) || (%current.status = inactive))) { inc %death.count 1 }
      }

      inc %battletxt.current.line
    }
  }

  if (%death.count >= $readini($txtfile(battle2.txt), BattleInfo, Monsters)) { 
    if (%battle.player.death = false) { $multiple_wave_check }
    if (%multiple.wave = $null) { return true }
    if (%multiple.wave = yes) { unset %multiple.wave | return false }
  } 
  else { return false }
}

; ==========================
; Checks to see if anyone won yet
; ==========================
alias battle.check.for.end {
  set %debug.location battle.check.for.end

  set %wait.your.turn on

  if (%battle.type = dungeon) { 
    if (($dungeon.currentroom = 0) && (%current.turn = 1)) { unset %wait.your.turn | return }
  }

  if ((%savethepresident = on) && ($readini($char(alliedforces_president), battle, hp) <= 0)) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt  } 
  if ((%supplyrun = on) && ($readini($char(supply_wagon), battle, hp) <= 0)) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt  } 

  ; Count the total number of monsters in battle
  $count.monsters

  set %battle.player.death $battle.player.death.check
  set %battle.monster.death $battle.monster.death.check

  if ((%battle.monster.death = true) && (%battle.player.death = true)) {  writeini $txtfile(1vs1bet.txt) money winner none  | /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle draw | halt } 

  if (%battle.type != dungeon) { 
    if ((%battle.monster.death = true) && (%battle.player.death = false)) { 
      if (%battle.type = ai) { set %ai.winner 2Winner:12 %ai.npc.name | writeini $txtfile(1vs1bet.txt) money winner npc  } 
      .timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt 
    } 
    if ((%battle.monster.death = false) && (%battle.player.death = true)) { 
      if (%battle.type = ai) { set %ai.winner 2Winner:4 %ai.monster.name | writeini $txtfile(1vs1bet.txt) money winner monster  } 
      /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt
    } 
    if ((%battle.monster.death = $null) && (%battle.player.death = true)) {  /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt } 
  }

  if (%battle.type = dungeon) { 
    if ($dungeon.dungeonovercheck = true) { $dungeon.end | halt } 
    else {
      if ((%battle.monster.death = true) && (%battle.player.death = false)) { unset %wait.your.turn | $dungeon.clearroom | halt }
      if ((%battle.player.death = true) && (%battle.monster.death = false)) {  /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt }
    }
  }

  unset %battle.player.death | unset %battle.monster.death
  unset %wait.your.turn
}

; ==========================
; Get a list of people in battle
; ==========================
alias battlelist { 
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }
  if ($return_peopleinbattle = null) { $display.message($readini(translation.dat, battle, NoOneJoinedBattleYet), private) | halt }

  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt) | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = $null) { inc %l 1 }
    else { 
      if ((%status.battle = dead) || (%status.battle = runaway)) { 
        var %token.to.add 4 $+ %who.battle
        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      } 
      else { 
        if ($readini($char(%who.battle), info, flag) = monster) { 
          unset %action.points

          if (($return.systemsetting(TurnType) = action) && ($readini($char(%who.battle), info, ai_type) != defender)) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }

          var %token.to.add 5 $+ %who.battle $+ %action.points
          if ($readini($char(%who.battle), monster, type) = object) { var %token.to.add 14 $+ %who.battle }
          if (($readini($boss(%who.battle), basestats, hp) != $null) || ($readini($char(%who.battle), monster, boss) = true)) { 

            if ($return.systemsetting(TurnType) = action) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }
            var %token.to.add 6 $+ %who.battle $+ %action.points
          }
        }
        if ($readini($char(%who.battle), info, flag) = npc) { 
          if ($return.systemsetting(TurnType) = action) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }
          var %token.to.add 12 $+ %who.battle $+ %action.points
        }
        if ($readini($char(%who.battle), info, flag) = $null) { 
          if ($return.systemsetting(TurnType) = action) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }
          var %token.to.add 3 $+ %who.battle $+ %action.points
        }
        if ($readini($char(%who.battle), battle, hp) > 0) { var %token.to.add $replace(%token.to.add, %who.battle,  $+ %who.battle $+ ) }

        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      }
    } 
  }

  unset %lines | unset %l 
  $battlelist.cleanlist

  if (%battle.type = dungeon) { $dungeon.batinfo(%battle.list) }

  if (%current.turn = $null) { var %current.turn 0 }

  if ($1 = $null) {
    if (%battle.list = $null) { $display.message($readini(translation.dat, battle, NoOneJoinedBattleYet), private) | unset %battle.list | unset %who.battle | $endbattle(none) | halt }

    if (%battleconditions != $null) { var %batlist.battleconditions [Conditions:12 $replace(%battleconditions, $chr(046), $chr(044) $chr(032)) $+ 4] } 

    $display.message($readini(translation.dat, battle, BatListTitleMessage), private)
    $display.message(4[Turn #:12 %current.turn $+ 4] [Weather:12 $readini($dbfile(battlefields.db), weather, current) $+ 4] [Moon Phase:12 %moon.phase $+ 4] [Time of Day:12 $readini($dbfile(battlefields.db), TimeOfDay, CurrentTimeOfDay) $+ 4] [Battlefield:12 %current.battlefield $+ 4] %batlist.battleconditions, private)

    if ((%darkness.turns != $null) && (%battle.type != ai)) { 
      var %darkness.countdown $calc(%darkness.turns - %current.turn) 
      if (%battle.type = defendoutpost) {  
        if (%darkness.turns > 0) { $display.message(4[The Outpost will be defended in:12 %darkness.turns 4waves], private) }
      }
      if (%battle.type != defendoutpost)  {
        if (%darkness.countdown > 0) { $display.message(4[Darkness will occur in:12 %darkness.countdown 4turns], private) }
        if (%darkness.countdown <= 0) { $display.message(4[Darkness12 has overcome 4the battlefield], private) }
      }

      if (%battle.type = assault) {  $display.message(4[Outpost Strength: $monster.outpost(strengthbar) $+ 4], private) }

    }

    if (%battle.type != ai) { 
      $display.message(4[Battle Order: %battle.list $+ 4], private) 
    }

    if (%battle.type = ai) { 
      var %odds.npc $readini($txtfile(1vs1bet.txt), money, odds.npc)
      var %odds.monster $readini($txtfile(1vs1bet.txt), money, odds.monster)
      var %money.bet $readini($txtfile(1vs1bet.txt), money, total)

      var %currency.symbol $readini(system.dat, system, BetCurrency)
      if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }
      $display.message(4[Total Betting Amount:12 %currency.symbol $+ $bytes(%money.bet,b) $+ 4] [Odds:12 %odds.npc $+ $chr(58) $+ %odds.monster $+ 4], private)
    }

    unset %battle.list | unset %who.battle
  }
  if ($1 = public) { 
    if (%battle.list = $null) { $display.message($readini(translation.dat, battle, NoOneJoinedBattleYet), battle) | unset %battle.list | unset %who.battle | $endbattle(none) | halt }

    if (%battleconditions != $null) { var %batlist.battleconditions [Conditions:12 $replace(%battleconditions, $chr(046), $chr(044) $chr(032)) $+ 4] } 

    $display.message($readini(translation.dat, battle, BatListTitleMessage), battle)
    $display.message(4[Turn #:12 %current.turn $+ 4][Weather:12 $readini($dbfile(battlefields.db), weather, current) $+ 4] [Moon Phase:12 %moon.phase $+ 4] [Time of Day:12 $readini($dbfile(battlefields.db), TimeOfDay, CurrentTimeOfDay) $+ 4] [Battlefield:12 %current.battlefield $+ 4] %batlist.battleconditions, battle)

    if ((%darkness.turns != $null) && (%battle.type != ai)) { 
      var %darkness.countdown $calc(%darkness.turns - %current.turn) 

      if (%battle.type = defendoutpost) {  
        if (%darkness.turns > 0) { $display.message(4[The Outpost will be defended in:12 %darkness.turns 4waves], battle) }
      } 
      if (%battle.type != defendoutpost)  {
        if (%darkness.countdown > 0) { $display.message(4[Darkness will occur in:12 %darkness.countdown 4turns], battle) }
        if (%darkness.countdown <= 0) { $display.message(4[Darkness12 has overcome 4the battlefield], battle) }
      }

      if (%battle.type = assault) {  $display.message(4[Outpost Strength: $monster.outpost(strengthbar) $+ 4], battle) }
    }

    if (%battle.type != ai) { 
      $display.message(4[Battle Order: %battle.list $+ 4], battle) 
    }

    if (%battle.type = ai) { 
      var %odds.npc $readini($txtfile(1vs1bet.txt), money, odds.npc)
      var %odds.monster $readini($txtfile(1vs1bet.txt), money, odds.monster)
      var %money.bet $readini($txtfile(1vs1bet.txt), money, total)

      var %currency.symbol $readini(system.dat, system, BetCurrency)
      if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }
      $display.message(4[Total Betting Amount:12 %currency.symbol $+ $bytes(%money.bet,b)  $+ 4] [Odds:12 %odds.npc $+ $chr(58) $+ %odds.monster $+ 4], battle)
    }

    unset %battle.list | unset %who.battle
  }
}


alias battlelist.cleanlist {
  ; CLEAN UP THE LIST
  if ($chr(046) isin %battle.list) { set %replacechar $chr(044) $chr(032)
    %battle.list = $replace(%battle.list, $chr(046), %replacechar)
  }
}

; ==========================
; REWARD ORBS 
; ===========================
alias battle.calculate.redorbs {
  set %debug.location battle.calculate.redorbs
  ; $1 = victory, draw, defeat
  ; $2 = winning streak
  unset %base.redorbs

  ; Get base red orbs based on battle type
  if (%battle.type = monster) { set %base.redorbs $readini(system.dat, System, basexp) }
  if (%battle.type = manual) { set %base.redorbs $readini(system.dat, System, basexp) }
  if (%battle.type = orbfountain) { set %base.redorbs $readini(system.dat, System, basexp) | inc %base.redorbs $rand(400,500) }
  if (%battle.type = boss) { set %base.redorbs $readini(system.dat, System, basebossxp) } 
  if (%battle.type = mimic) { set %base.redorbs $readini(system.dat, System, basebossxp) } 
  if (%battle.type = dungeon) { set %base.redorbs $readini(system.dat, System, basebossxp) | inc %base.redorbs $2 }
  if (%battle.type = dragonhunt) { set %base.redorbs $calc($readini(system.dat, System, basebossxp) * 2) } 
  if (%battle.type = torment) {
    set %base.redorbs $calc($readini(system.dat, System, basebossxp) * %torment.level) 
    if (%base.redorbs > 10000) { set %base.redorbs 10000 }
  } 

  if (%number.of.monsters.needed = $null) { var %number.of.monsters.needed 1 }

  if ((((%boss.type = bandits) || (%boss.type = pirates) || (%boss.type = FrostLegion) || (%boss.type = gremlins)))) { inc %number.of.monsters.needed 2 }

  %base.redorbs = $round($calc(%base.redorbs * (1 + %number.of.monsters.needed)), 0)

  ; Get a multiplier based on win/draw/loss
  var %base.orb.multiplier 0
  if ($1 = victory) { inc %base.orb.multiplier 1.2 }
  if ($1 = defeat) { inc %base.orb.multiplier .30 }
  if ($1 = draw) { inc %base.orb.multiplier .75 }
  if ((%mode.gauntlet = on) || (%battle.type = dungeon)) { inc %base.orb.multiplier .25 }
  if ((%battle.type = defendoutpost) || (%battle.type = assault)) { inc %base.orb.multiplier .25 }

  ; If the winning streak is above 0, let's add some of it into the orb bonus.

  if ($1 = victory) { inc %base.redorbs $round($calc($2 / 1.1),0) }
  if (($1 = defeat) || ($1 = draw)) { inc %base.redorbs $round($calc($2 / 1.8),0) }

  ; Get the orb bonus that players earned by defeating monsters
  if (%battle.type != dungeon) { set %bonus.orbs $round($readini($txtfile(battle2.txt), BattleInfo, OrbBonus),0) }
  if ((%battle.type = dungeon) && ($3 = true)) { set %bonus.orbs $round($readini($txtfile(battle2.txt), BattleInfo, OrbBonus),0) }

  if ((%bonus.orbs = $null) || (%bonus.orbs < 0)) { set %bonus.orbs 0 }
  inc %base.redorbs %bonus.orbs

  ; Set the max reward and make sure the orb amount isn't above that.
  if (%mode.gauntlet = on) { var %max.orb.reward $readini(system.dat, system, MaxGauntletOrbReward) }
  if (%mode.gauntlet != on) {  var %max.orb.reward $readini(system.dat, system, MaxOrbReward) }
  if (%max.orb.reward = $null) { var %max.orb.reward 20000 }

  if (%battle.type = dungeon) { var %max.orb.reward $calc(%max.orb.reward * 2) }
  if (%battle.type = torment) { var %max.orb.reward $calc(%max.orb.reward * 2.3) }
  if (%battle.type = dragonhunt) { var %max.orb.reward $calc(%max.orb.reward * 1.5) }

  if (($readini(battlestats.dat, dragonballs, ShenronWish) = on) && (%mode.gauntlet != on)) { %max.orb.reward = $round($calc(%max.orb.reward * 1.2),0) }

  ; If we had a gauntlet battle or a multiple wave battle, let's increase the amount by this.
  if (%multiple.wave.bonus = yes) { 
    var %winning.streak $2
    if (%mode.gauntlet.wave != $null) { inc %winning.streak %mode.gauntlet.wave }      

    if (%winning.streak <= 100) { %max.orb.reward = $round($calc(%max.orb.reward * 2.1),0)  }
    if ((%winning.streak > 100) && (%winning.streak <= 200)) { %max.orb.reward = $round($calc(%max.orb.reward * 2.8),0)  }
    if ((%winning.streak > 200) && (%winning.streak <= 400)) { %max.orb.reward = $round($calc(%max.orb.reward * 3),0)  }
    if (%winning.streak > 400) { %max.orb.reward = $round($calc(%max.orb.reward * 3.5),0) }
  }

  if ($1 = defeat) { %max.orb.reward = $round($calc(%max.orb.reward * .4),0) }

  ; Find out how many red orbs we actually won
  %base.redorbs = $round($calc(%base.redorbs * %base.orb.multiplier),0) 

  ; If we went above the max, set the amount to max
  if (%base.redorbs > %max.orb.reward) { set %base.redorbs %max.orb.reward }

  ; Add some orbs for difficulty
  if (%difficulty != 0) {
    if ($1 = defeat) { inc %base.redorbs $round($calc(%difficulty * .2),0) }
    if ($1 != defeat) {  inc %base.redorbs $round($calc(%difficulty * 3.0),0) }
  }

  ; If a demon portal had appeared in battle, increase the bonus.
  var %bonus.orbs $readini($txtfile(battle2.txt), battleinfo, portalbonus)
  if (%bonus.orbs = $null) { var %bonus.orbs 0 }

  ; Add the Conquest bonus. 
  var %conquest.orbbonus $readini(battlestats.dat, conquest, ConquestBonus)
  if (%conquest.orbbonus > 1000) { var %conquest.orbbonus 1000 }
  if (%conquest.orbbonus <= 0) { var %conquest.orbbonus 0 }

  ; Get the orb bonus for the garden.
  var %garden.bonus $readini(garden.dat, GardenStats, Bonus)
  if (%garden.bonus = $null) { var %garden.bonus 0 }

  if ($1 = victory) {  inc %base.redorbs $calc(450 * %bonus.orbs) | inc %base.redorbs %conquest.orbbonus | inc %base.redorbs %garden.bonus }
  if (($1 = draw) || ($1 = defeat)) {  inc %base.redorbs $calc(100 * %bonus.orbs) | inc %base.redorbs $round($calc(%conquest.orbbonus * .10),0) | inc %base.redorbs $round($calc(%garden.bonus * .10),0)  }

  ; Finally, if the orb amount  is less than 200, let's add 200 to it.
  if (%base.redorbs <= 200) { inc %base.redorbs 200 }
  if (%base.redorbs <= 0) { set %base.redorbs 200 }

  ; If it's a bonus event, let's double the amount.
  if ($readini(system.dat, system, BonusEvent) = true) { %base.redorbs = $round($calc(%base.redorbs * 2),0) }

  return
}

; Rewards influence to allied forces or monster forces
; Think of Monster Force Influence as the monsters preparing at their home base for war
; When it hits 100 they can attack an outpost that players will have to defend.
; Allied Influence will result in an Assault type battle when it's high enough.
alias battle.reward.influence {
  if ($1 = alliedforces)  {
    var %current.influence $readini(battlestats.dat, conquest, alliedinfluence) 
    if (%current.influence = $null) { var %current.influence 0 }
    var %influence.gain 1
    if (%battle.type = defendoutpost) { var %influence.gain 40 }
    if (%battle.type = boss) { var %influence.gain 2 }
    inc %current.influence %influence.gain
    writeini battlestats.dat conquest AlliedInfluence %current.influence
  }
  if ($1 = monsterforces) { 
    var %influence.gain $rand(1,2)
    if (%battle.type = boss) { inc %influence.gain 1 } 

    var %current.influence $readini(battlestats.dat, conquest, MonsterInfluence) 
    if (%current.influence = $null) { var %current.influence 0 }
    inc %current.influence %influence.gain
    writeini battlestats.dat conquest MonsterInfluence %current.influence
  }

  ; increase the chance of a supply run happening
  var %supplyrun.chance $readini(battlestats.dat, conquest, SupplyRunChance)
  if (%supplyrun.chance = $null) { var %supplyrun.chance 0 }
  inc %supplyrun.chance $rand(1,3)
  writeini battlestats.dat conquest SupplyRunChance %supplyrun.chance
}

alias battle.reward.redorbs {
  set %debug.location battle.reward.redorbs
  unset %red.orb.winners 
  var %original.baseredorbs %base.redorbs

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 

      ; Nerf or boost the orbs based on the winning streak
      set %base.redorbs %original.baseredorbs

      if ((%base.redorbs <= 2000) && (%battle.type = defendoutpost)) { set %base.redorbs 2000 }
      if ((%base.redorbs <= 2000) && (%battle.type = assault)) { set %base.redorbs 2000 }
      if ((%base.redorbs <= 5000) && (%battle.type = dragonhunt)) { set %base.redorbs $rand(5000, 7000) }
      if ((%base.redorbs <= 1000) && (%battle.type = torment)) { set %base.redorbs 1000 }

      ; Dungeon clear bonus
      if ($2 = true) { 
        inc %base.redorbs 5000
        var %dungeonfile $readini($txtfile(battle2.txt), dungeoninfo, dungeonfile)
        if ($readini($char(%who.battle), dungeons,%dungeonfile) != true) { writeini $char(%who.battle) dungeons %dungeonfile true | set %dungeon.firsttime.clear true | inc %base.redorbs 25000 }

        var %total.dungeons.won $readini($char(%who.battle), stuff, DungeonsCleared) 
        if (%total.dungeons.won = $null) { var %total.dungeons.won 0 }
        inc %total.dungeons.won 1 

        writeini $char(%who.battle) stuff DungeonsCleared %total.dungeons.won

        ; TO DO: add an achievement  :: $achievement_check(%who.battle, DungeonCrawler)
      }


      ; Adjust the orbs
      $orb.adjust(%who.battle)

      if ($readini($char(%who.battle), battle, status) = runaway) { var %total.redorbs.reward $round($calc(%base.redorbs / 2.5),0) }
      if ($readini($char(%who.battle), battle, status) != runaway) { var %total.redorbs.reward %base.redorbs }

      if ($readini($char(%who.battle), battle, status) != runaway) {

        if ($1 = victory) { 
          if (%portal.bonus != true) { $get.random.reward(%who.battle) }
          ; Check for the OnTheEdge achievement (courtesy of Andrio)
          var %current.hp $readini($char(%who.battle), Battle, HP) |  var %max.hp $readini($char(%who.battle), BaseStats, HP) |  var %hp.percent $calc((%current.hp / %max.hp)*100)
          if ((%hp.percent <= 2) && (%hp.percent > 0)) { $achievement_check(%who.battle, OnTheEdge) }
        }

        if ($readini($char(%who.battle), battle, status) = alive) {
          var %battle.list.check $readini($txtfile(battle2.txt), battle, list)

          ; Check for the NoOne'sPuppet achievement
          if ($istok(%battle.list.check,puppet_master,46) = $true) { $achievement_check(%who.battle, NoOne'sPuppet) }

        }

        ; Check for the orb hunter passive skill.
        if ($readini($char(%who.battle), skills, OrbHunter) != $null) {
          var %orbhunter.inc.amount $readini($dbfile(skills.db), orbhunter, amount)
          if (%orbhunter.inc.amount = $null) { var %orbhunter.inc.amount 15 }
          inc %total.redorbs.reward $round($calc(%orbhunter.inc.amount * $readini($char(%who.battle), skills, OrbHunter)),0) 
        }

        ;  Check for the an accessory that increases red orbs
        if ($accessory.check(%who.battle, IncreaseRedOrbs) = true) {
          var %increase.orbs.amount $round($calc(%base.redorbs * %accessory.amount),0)
          inc %total.redorbs.reward %increase.orbs.amount
          unset %accessory.amount
        }

        ; Check for the orb bonus status.
        if ($readini($char(%who.battle), status, OrbBonus) = yes) {
          var %orb.bonus $round($calc(%base.redorbs / 100),0)
          if (%orb.bonus <= 100) { var %orb.bonus 100 }
          inc %total.redorbs.reward %orb.bonus
          writeini $char(%who.battle) status OrbBonus no
        }

        ; Check for a buff from the battle condition
        if ((more-orbs isin %battleconditions) || (enhance-orbs isin %battleconditions)) { 
          var %increase.orb.amount $round($calc(%total.redorbs.reward * 1.5),0)
          inc %total.redorbs.reward %increase.orb.amount
        }

        ; Check for enhancement capacity points
        if (%portal.bonus != true) { $reward.capacitypoints(%who.battle)  }
      }

      if ((%battle.type = defendoutpost) || (%battle.type = assault)) {  
        if ($current.battlestreak >= 100) { var %streak.level.difference $round($calc(100 - $get.level.basestats(%who.battle)),0) }
        else { var %streak.level.difference $round($calc($current.battlestreak - $get.level.basestats(%who.battle)),0) }
      }
      else { var %streak.level.difference $round($calc($current.battlestreak - $get.level.basestats(%who.battle)),0) }

      ; Check to see what level the winner is vs the current battlestreak.  If the streak is higher, nerf the orbs.
      if (%streak.level.difference >= 1000) { %total.redorbs.reward = $round($calc(%total.redorbs.reward * 0.15),0) }
      if ((%streak.level.difference > 500) && (%streak.level.difference < 1000)) { %total.redorbs.reward = $round($calc(%total.redorbs.reward * 0.25),0) }
      if ((%streak.level.difference > 100) && (%streak.level.difference <= 500)) { %total.redorbs.reward = $round($calc(%total.redorbs.reward * 0.40),0) }

      if (%total.redorbs.reward <= 5) { %total.redorbs.reward = 5 }


      ; For the first 24 hours that a player starts the game there will be a 20% bonus to orbs to help them out.
      var %player.created.time $ctime($readini($char(%who.battle), Info, Created))
      var %time.calculated $calc($ctime - %player.created.time)

      if (%time.calculated <= 86400) { inc %total.redorbs.reward $round($calc(%total.redorbs.reward * .25),0)  }

      ; For newer players let's increase their orb amount by 50% to help them with earlier streaks
      if ($return.totalorbs(%who.battle) < 10000) {
        var %orbs.increase $calc(%total.redorbs.reward * .50)
        inc %total.redorbs.reward %orbs.increase  
      }

      ; Calculate a "resting" bonus.  This is a bonus to orbs for people who have been out of battle for a while.
      var %resting.bonus $character.resting.bonus(%who.battle)
      inc %total.redorbs.reward %resting.bonus

      ; Add the orbs to the player
      var %current.orbs.onhand $readini($char(%who.battle), stuff, redorbs)
      inc %current.orbs.onhand %total.redorbs.reward
      writeini $char(%who.battle) stuff redorbs %current.orbs.onhand
      writeini $char(%who.battle) status orbbonus no

      ; Add the player and the orb amount to the list to be shown 
      %red.orb.winners = $addtok(%red.orb.winners, $+ %who.battle $+  $+ $chr(91) $+ $chr(43) $+ $bytes(%total.redorbs.reward,b) $+ $chr(93),46)

      if ((%portal.bonus = true) && ($1 = victory)) {
        var %total.portalbattles.won $readini($char(%who.battle), stuff, PortalBattlesWon) 
        if (%total.portalbattles.won = $null) { var %total.portalbattles.won 0 }
        inc %total.portalbattles.won 1 

        writeini $char(%who.battle) stuff PortalBattlesWon %total.portalbattles.won

        $achievement_check(%who.battle, AlliedScrub)
        $achievement_check(%who.battle, AlliedSoldier)
        $achievement_check(%who.battle, AlliedGeneral)
      }

      if (($readini($txtfile(battle2.txt), battle, alliednotes) != $null) && ($1 = victory)) { $give_alliednotes(%who.battle) }

      if (($1 = victory) && ($readini($char(%who.battle), skills, aggressor.on) = on)) {
        var %total.aggression.won $readini($char(%who.battle), stuff, BattlesWonWithAggressor) 
        if (%total.aggression.won = $null) { var %total.aggression.won 0 }
        inc %total.aggression.won 1
        writeini $char(%who.battle) stuff BattlesWonWithAggressor %total.aggression.won
        $achievement_check(%who.battle, GlassCannon)
      }

      if (($1 = victory) && ($readini($char(%who.battle), skills, defender.on) = on)) {
        var %total.defender.won $readini($char(%who.battle), stuff, BattlesWonWithDefender) 
        if (%total.defender.won = $null) { var %total.defender.won 0 }
        inc %total.defender.won 1
        writeini $char(%who.battle) stuff BattlesWonWithDefender %total.defender.won
        $achievement_check(%who.battle, StoneWall)
      }

      ; Check for the "Just Getting Started" achievement courtesy of Andrio
      if ((%battle.type = boss) && ($current.battlestreak = 11)) {
        if (($1 = victory) && ($readini($char(%who.battle), battle, status) = alive)) { $achievement_check(%who.battle, JustGettingStarted) }
      }

      ; Clear certain potion effects
      if ((($return.potioneffect(%who.battle) = Augment Bonus) || ($return.potioneffect(%who.battle) = Dragonskin) || ($return.potioneffect(%who.battle) = Utsusemi Bonus))) { 
        writeini $char(%who.battle) status PotionEffect none 
      }

      inc %battletxt.current.line 1 
    }
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %red.orb.winners) { set %replacechar $chr(044) $chr(032)
    %red.orb.winners = $replace(%red.orb.winners, $chr(046), %replacechar)
  }
}

alias battle.reward.blackorbs { 
  set %debug.location battle.reward.blackorbs
  unset %black.orb.winners
  set %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      set %current.status $readini($char(%who.battle), battle, status)
      if (%current.status = dead) { inc %battletxt.current.line 1 }
      else { 
        ; Increase black orbs
        var %current.blackorbs $readini($char(%who.battle), stuff, blackorbs)
        inc %current.blackorbs 1
        writeini $char(%who.battle) stuff blackorbs %current.blackorbs
        %black.orb.winners = $addtok(%black.orb.winners,%who.battle,46)
        inc %battletxt.current.line 1 
      } 
    }
  }
  ; CLEAN UP THE LIST
  if ($chr(046) isin %black.orb.winners) { set %replacechar $chr(044) $chr(032)
    %black.orb.winners = $replace(%black.orb.winners, $chr(046), %replacechar)
  }
  unset %current.status
}

alias battle.reward.killcoins {
  set %debug.location battle.reward.killcoins
  var %original.basecoins 10

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 

      ; Adjust the base coins based on battle type

      if ((%base.coins <= 5000) && (%battle.type = defendoutpost)) { set %base.coins 15 }
      if ((%base.coins <= 5000) && (%battle.type = assault)) { set %base.coins 15 }
      if ((%base.coins <= 8000) && (%battle.type = dragonhunt)) { set %base.coins 10 }
      if ((%base.coins <= 10000) && (%battle.type = torment)) { set %base.coins 1 }

      ; Adjust the coins

      if ($readini($char(%who.battle), battle, status) = runaway) { var %total.coins.reward $round($calc(%base.coins / 2.5),0) }
      if ($readini($char(%who.battle), battle, status) != runaway) { var %total.coins.reward %base.coins }

      ; inc coins reward by # of monsters killed
      var %monsters.killed $readini($txtfile(battle2.txt), Kills, %who.battle) 
      if (%monsters.killed = $null) { var %monsters.killed 0 }
      inc %total.coins.reward %monsters.killed

      ; inc coin reward by streak
      if ($return_winningstreak >= 10) { 
        var %coins.increase.amount $round($calc($return_winningstreak ^.5001),0)
        if (%coins.increase.amount >= 300) { var %coins.increase.amount 300 }
        inc %total.coins.reward %coins.increase.amount
      }

      ; inc coin reward by style
      var %style.points $readini($txtfile(battle2.txt), style, %who.battle)
      var %boss.modifier 0
      if (%battle.type = boss) { inc %boss.modifier 100 }
      if (%portal.bonus = true) { inc %boss.modifier 100 }

      if ((%style.points > $calc(30 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(50 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 1 }
      if ((%style.points > $calc(50 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(80 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 2 }
      if ((%style.points > $calc(80 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(100 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 3 }
      if ((%style.points > $calc(100 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(110 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 4 }
      if ((%style.points > $calc(110 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(120 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 5 }
      if ((%style.points > $calc(120 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(140 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 6 }
      if ((%style.points > $calc(140 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(180 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 7 }
      if ((%style.points > $calc(180 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(250 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 7 }
      if ((%style.points > $calc(250 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(350 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 7 }
      if ((%style.points > $calc(350 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(450 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 8 }
      if ((%style.points > $calc(450 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(550 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 8 }
      if ((%style.points > $calc(550 + %boss.modifier + $return_winningstreak)) && (%style.points <= $calc(750 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 8 }
      if ((%style.points > $calc(750 + %boss.modifier + $return_winningstreak)) && (%style.points <= $calc(1000 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 9 }
      if ((%style.points > $calc(1000 + %boss.modifier + $return_winningstreak)) && (%style.points <= $calc(3500 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 9  }
      if ((%style.points > $calc(3500 + %boss.modifier + $return_winningstreak)) && (%style.points < $calc(6000 + %boss.modifier + $return_winningstreak))) { inc %total.coins.reward 10 }
      if (%style.points >= $calc(6000 + %boss.modifier + $return_winningstreak)) { inc %total.coins.reward 11 }

      ; For the first 24 hours that a player starts the game there will be a 50% bonus to killcoins to help them out.
      var %player.created.time $ctime($readini($char(%who.battle), Info, Created))
      var %time.calculated $calc($ctime - %player.created.time)

      if (%time.calculated <= 86400) {  var %total.coins.reward $calc(%total.coins.reward * 2) }

      ;  Check for the an accessory that increases kill coins
      if ($accessory.check(%who.battle, IncreaseKillCoins) = true) {
        var %increase.coin.amount $round($calc(%total.coins.reward * %accessory.amount),0)
        inc %total.coins.reward %increase.coin.amount
        unset %accessory.amount
      }

      ; Check for a buff from the battle condition
      if ((more-coins isin %battleconditions) || (enhance-coins isin %battleconditions)) { 
        var %increase.coin.amount $round($calc(%total.coins.reward * 2),0)
        inc %total.coins.reward %increase.coin.amount
      }

      ; Check for bounty
      if ($readini($txtfile(battle2.txt), battleinfo, bountyclaimed) = true) { inc %total.coins.reward 20 }

      ; Check for a resting bonus
      var %resting.bonus $character.resting.bonus.killcoins(%who.battle)
      inc %total.coins.reward %resting.bonus

      ; Add the coins to the player
      var %current.coins.onhand $readini($char(%who.battle), stuff, killcoins)
      inc %current.coins.onhand %total.coins.reward
      writeini $char(%who.battle) stuff killcoins %current.coins.onhand

      ; Clear certain potion effects
      if ($return.potioneffect(%who.battle) = Kill Coin Bonus) { writeini $char(%who.battle) status PotionEffect none }

      ; Write the current time for the current battle
      writeini $char(%who.battle) Info LastBattleTime $ctime

      inc %battletxt.current.line 1 
    }
  }

}

; ===========================
; REWARD PLAYER STYLE XP
; ===========================
alias battle.reward.playerstylexp {
  set %debug.location battle.reward.playerstyleexp
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      set %playerstyle.xp.reward $rand(1,3)
      var %vogue.check $readini($char(%who.battle), skills, Vogue) 
      if (%vogue.check > 0) { 
        var %vogue.value $readini($char(%who.battle), skills, Vogue) * 1
        inc %playerstyle.xp.reward %vogue.value
      }

      $add.playerstyle.xp(%who.battle, %playerstyle.xp.reward)
      inc %battletxt.current.line 1 
    }
  }
  unset %playerstyle.xp | unset %playerstyle.xp.reward
}


;==========================
; REWARD IGNITION GAUGE
;==========================
alias battle.reward.ignitionGauge.all {
  set %debug.location battle.reward.ignition.all
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 | 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      set %player.ig.reward 1

      ; Check for an accessory to increase the IG Gain Rate
      if ($accessory.check(%who.battle, IncreaseIGGainRate) = true) {
        inc %player.ig.reward %accessory.amount
        unset %accessory.amount
      }

      ; Check for an augment to increase the IG Gain Rate
      if ($augment.check($1, EnhanceEnfeeble) = true) { 
        inc %player.ig.reward %augment.strength
      }


      $restore_ig(%who.battle, %player.ig.reward)
      inc %battletxt.current.line 1 
    }
  }
  unset %player.ig.current | unset %player.ig.max | unset %player.ig.reward
}

alias battle.reward.ignitionGauge.single {
  if ($readini($char($1), info, flag) = monster) { return }
  $restore_ig($1, 1)
}

;==========================
; Check the various status effects
;==========================
alias turn.statuscheck {
  set %debug.location turn.statuscheck
  unset %all_skills | unset %all_status

  if ($lines($txtfile(temp_status.txt)) != $null) {   /.remove $txtfile(temp_status.txt) }

  $ignition_check($1) 

  $flying.status.check($1)
  $poison_check($1) | $zombie_check($1) | $zombieregenerating_check($1) | $doll_check($1) | $virus_check($1) 
  $frozen_check($1) | $shock_check($1)  | $burning_check($1) | $tornado_check($1) | $drowning_check($1) | $earthquake_check($1)
  $staggered_check($1) | $intimidated_check($1) | $terrified_check($1) | $blind_check($1) | $curse_check($1) | unset %hp.percent  | $stopped_check($1) |  $charm_check($1) | $confuse_check($1) | $amnesia_check($1) | $paralysis_check($1)
  $drunk_check($1) | $slowed_check($1) | $asleep_check($1) | $stunned_check($1) | $defensedown_check($1) | $strengthdown_check($1)  | $intdown_check($1) | $ethereal_check($1) 
  $cocoon_check($1) | $weapon_locked($1) | $petrified_check($1)  | $bored_check($1) | $reflect.check($1)
  $invincible.status.check($1) 

  $regenerating_check($1) | $TPregenerating_check($1) | $protect_check($1) | $shell_check($1) 
  $enspell_check($1) | $speedup_check($1) | $defenseup_check($1) 

  ; Check for status and skills
  $player.status($1)

  if (%all_status = $null) { %all_status = none } 
  if (%all_skills = $null) { %all_skills = none } 

  return
}

alias display.statusmessages {
  set %debug.location display.statusmessages
  if (($lines($txtfile(temp_status.txt)) != $null) && ($lines($txtfile(temp_status.txt)) > 0)) { 
    var %file.to.read $txtfile(temp_status.txt)

    if ($readini(system.dat, system, botType) = IRC) {  /.play %battlechan %file.to.read }
    if ($readini(system.dat, system, botType) = TWITCH) {  /.play %battlechan %file.to.read }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.status.messages(%file.to.read) }

    /.remove $txtfile(temp_status.txt)
    /.timerReturnFromStatus $+ $rand(a,z) 1 2 /return 
  }
}
