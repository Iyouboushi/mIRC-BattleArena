;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; battlealiases.als
;;;; Last updated: 06/18/18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if it's a
; person's turn or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_battle { 
  if (%wait.your.turn = on) { $display.message($readini(translation.dat, errors, WaitYourTurn), private) | halt }
  if ((%battleis = on) && (%who = $1)) { return }
  if ((%battleis = on) && (%who != $1)) { $display.message($readini(translation.dat, errors, WaitYourTurn), private) | halt }
  else { return  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if someone
; is in the battle or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
person_in_battle {
  set %temp.battle.list $readini($txtfile(battle2.txt), Battle, List)
  if ($istok(%temp.battle.list,$1,46) = $false) {  unset %temp.battle.list | $set_chr_name($1) 
    $display.message($readini(translation.dat, errors, NotInbattle),private) 
    unset %real.name | halt 
  }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns how long a battle
; lasted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
battle.calculateBattleDuration {
  var %total.time $readini($txtfile(battle2.txt), BattleInfo, TimeStarted)
  if (%total.time != $null) {
    var %total.battle.time $ctime(%total.time)
    var %total.battle.duration $duration($calc($ctime - %total.battle.time))
  }
  if (%total.time = $null) { var %total.battle.duration unknown time }


  return %total.battle.duration
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attempts to match a partial
; target name to someone in
; the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
partial.name.match {
  ; $1 = person using the command
  ; $2 = person they're trying to attack

  if ((($2 = me) || ($2 = himself) || ($2 = herself))) { set %attack.target $1 | return }

  if ($istok($return_peopleinbattle, $2, 46) = $true) { set %attack.target $2 }
  else { 
    set %attack.target $matchtok($return_peopleinbattle, $2, 1, 46)
    if (%attack.target = $null) { set %attack.target $2 }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This alias just counts how
; many monsters are in
; the battle. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count.monsters {
  set %monsters.in.battle 0 

  var %count.battletxt.lines $lines($txtfile(battle.txt)) | var %count.battletxt.current.line 1 
  while (%count.battletxt.current.line <= %count.battletxt.lines) { 
    var %count.who.battle $read -l $+ %count.battletxt.current.line $txtfile(battle.txt)
    if (%count.who.battle = $null) { write -d $+ %count.battletxt.current.line $txtfile(battle.txt) | inc %count.battletxt.current.line }

    else { 
      var %count.flag $readini($char(%count.who.battle), info, flag)

      if (%count.flag = monster) { 
        var %summon.flag $readini($char(%count.who.battle), info, summon)
        var %clone.flag $readini($char(%count.who.battle), info, clone)
        var %doppel.flag $readini($char(%count.who.battle), info, Doppelganger)
        var %object.flag $readini($char(%count.who.battle), monster, type)

        if (((%summon.flag != yes) && (%object.flag != object) && (%clone.flag != yes))) {  inc %monsters.in.battle 1 }
        if (%doppel.flag = yes) { inc %monsters.in.battle 1 }
      }

      inc %count.battletxt.current.line 1
    }
  }
  writeini $txtfile(battle2.txt) battleinfo monsters %monsters.in.battle
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns total player levels
; that are in the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playerlevelstotal {
  var %total.playerlevels $readini($txtfile(battle2.txt), BattleInfo, PlayerLevels)
  if (%total.playerlevels = $null) { var %total.playerlevels 0 }
  return %total.playerlevels
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns highest player level
; in the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playerlevelhighest {
  var %highest.level $readini($txtfile(battle2.txt), BattleInfo, HighestLevel)
  if (%highest.level = $null) { return 0 }
  return %highest.level
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns average player level
; in the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playerlevelaverage {
  var %average.level $readini($txtfile(battle2.txt), BattleInfo, AverageLevel)
  if (%average.level = $null) { return 0 }
  return %average.level
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns # of players in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playersinbattle {
  var %total.playersinbattle $readini($txtfile(battle2.txt), BattleInfo, Players)
  if (%total.playersinbattle = $null) { return 0 }

  var %total.npcsinbattle $readini($txtfile(battle2.txt), BattleInfo, NPCs) 
  if (%total.npcsinbattle != $null) { inc %total.playersinbattle %total.npcsinbattle }

  return %total.playersinbattle
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns list of battle participants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_peopleinbattle {
  var %temp.peopleinbattle $readini($txtfile(battle2.txt), battle, list)
  if (%temp.peopleinbattle = $null) { return null }
  else { return %temp.peopleinbattle }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns # of monsters in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_monstersinbattle {
  var %total.monsinbattle $readini($txtfile(battle2.txt), BattleInfo, Monsters)
  if (%total.monsinbattle = $null) { return 0 }
  else { return %total.monsinbattle }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns max # of monsters in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_maxmonstersinbattle {
  if ($return.systemsetting(botType) = DCCchat) { return 50 }

  var %max.monsters.allowed $return.systemsetting(MaxNumberOfMonsInBattle)
  if (%max.monsters.allowed = null) { return 6 }
  else { return %max.monsters.allowed }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if someone
; is in a mech or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
person_in_mech {
  if ($readini($char($1), mech, InUse) = true) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds a random monster
; drop to the item pool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
check_drops {
  var %boss.item $readini($dbfile(drops.db), drops, $1)
  if (%boss.item = $null) { var %boss.item $readini($char($1), stuff, drops) } 

  if ($left($adate, 2) = 10) { 
    if ((%battle.type = monster) && ($readini($dbfile(items.db), CandyCorn, amount) != $null)) { 
      if (%portal.bonus != true) {  var %boss.item $addtok(%boss.item, CandyCorn, 46) }
    }
  }

  if (%boss.item != $null) {
    var %temp.drops.list $readini($txtfile(battle2.txt), battle, bonusitem)
    var %number.of.items $numtok(%temp.drops.list, 46)
    if (%number.of.items <= 20) {
      if (%temp.drops.list != $null) { writeini $txtfile(battle2.txt) battle bonusitem %temp.drops.list $+ . $+ %boss.item }
      if (%temp.drops.list = $null) { writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Action Point alias
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
action.points {
  ; $1 = person
  ; $2 = check, add, remove or initialize
  ; $3 = amount to add or remove

  if ($2 = check) {
    var %current.actionpoints $readini($txtfile(battle2.txt), ActionPoints, $1)
    if (%current.actionpoints = $null) { writeini $txtfile(battle2.txt) ActionPoints $1 0 | return 0 }
    else { return %current.actionpoints }
  }

  if ($2 = add) { 
    var %current.actionpoints $readini($txtfile(battle2.txt), ActionPoints, $1)
    if (%current.actionpoints = $null) { var %current.actionpoints 0 }
    inc %current.actionpoints $3
    writeini $txtfile(battle2.txt) ActionPoints $1 %current.actionpoints
  }

  if ($2 = remove) {
    var %current.actionpoints $readini($txtfile(battle2.txt), ActionPoints, $1)
    if (%current.actionpoints = $null) { var %current.actionpoints 0 }
    dec %current.actionpoints $3
    writeini $txtfile(battle2.txt) ActionPoints $1 %current.actionpoints
  }

  if ($2 = initialize) {
    var %battle.speed $readini($char($1), battle, speed)
    var %action.points $action.points($1, check)
    var %max.action.points $round($log(%battle.speed),0)
    inc %max.action.points 1

    inc %action.points 1
    if (%battle.speed >= 1) { inc %action.points $round($log(%battle.speed),0) }
    if ($readini($char($1), info, flag) = monster) { 
      if (%portal.bonus = true) { inc %action.points 1 | inc %max.action.points 1 }
      if (%battle.type = dungeon) { inc %action.points 1 | inc %max.action.points 1 }
      inc %action.points 1 | inc %max.action.points 1
    }
    if ($readini($char($1), info, ai_type) = defender) { var %action.points 0 } 

    ; If the person gains more action ponits than they have, cap it to their max
    if (%action.points > %max.action.points) { var %action.points %max.action.points }

    writeini $txtfile(battle2.txt) ActionPoints $1 %action.points
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for things that would
; stop a person from having
; a turn.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
no.turn.check {
  if ((%battleis = off) && ($2 != return)) { halt }
  if ($readini($char($1), basestats, hp) = $null) { halt }
  if ($readini($char($1), info, flag) = monster) { return }
  if ($readini($char($1), info, flag) = npc) { return }
  $set_chr_name($1)

  if ($is_charmed($1) = true) { $display.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $display.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if ($statuseffect.check($1, petrified) != no) { $display.message($readini(translation.dat, status, TooPetrifiedToFight),private) | halt }
  if ($statuseffect.check($1, blind) != no) { $display.message($readini(translation.dat, status, TooBlindToFight),private) | halt }
  if ($statuseffect.check($1, intimidated) != no) { $display.message($readini(translation.dat, status, TooIntimidatedToFight),private) | halt }
  if ($statuseffect.check($1, paralysis) != no) { $display.message($readini(translation.dat, status, CurrentlyParalyzed),private) | halt }
  if ($statuseffect.check($1, drunk) != no) { $display.message($readini(translation.dat, status, TooDrunkToFight2),private) | halt }
  if ($statuseffect.check($1, stun) != no) { $display.message($readini(translation.dat, status, TooStunnedToFight),private) | halt }
  if ($statuseffect.check($1, stop) != no) { $display.message($readini(translation.dat, status, CurrentlyStopped),private) | halt }
  if ($statuseffect.check($1, sleep) != no) { $display.message($readini(translation.dat, status, CurrentlyAsleep),private) | halt }
  if ($statuseffect.check($1, terrified) != no) { $display.message($readini(translation.dat, status, TooTerrifiedToFight),private) | halt }
}

no.mech.check {
  if (($person_in_mech($1) = true) && ($2 != admin)) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the current streak
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
current.battlestreak {
  var %temp.current.battlestreak $readini(battlestats.dat, battle, WinningStreak)

  if (%battle.type = ai) { return  %ai.battle.level  }
  if (%battle.type = DragonHunt) { return $dragonhunt.dragonage(%dragonhunt.file.name) }
  if (%battle.type = torment) { return $calc(500 * %torment.level) }
  if (%battle.type = cosmic) { return 500 }
  if (%portal.bonus = true) {
    var %current.portal.level $readini($txtfile(battle2.txt), battleinfo, portallevel)
    if (%current.portal.level = $null) { return 500 } 
    else { return %current.portal.level }
  }
  if (%battle.type = dungeon) { return $readini($txtfile(battle2.txt), dungeoninfo, dungeonlevel) }
  if ((%battle.type = assault) || (%battle.type = defendoutpost)) {
    if (%temp.current.battlestreak > 100) { return 100 }
  }

  if (%temp.current.battlestreak <= 0) { return $readini(battlestats.dat, battle, LosingStreak) }
  else { return %temp.current.battlestreak }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns yes/no depending
; on if the status effect is on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
statuseffect.check {
  ; $1 = person we're checking
  ; $2 = the status effect we're checking

  var %status.effect.check $readini($char($1), status, $2)
  if (%status.effect.check = $null) { return no }
  else { return %status.effect.check }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the number of turns
; that status effects last.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status.effects.turns {
  var %negative.status.effects flying.confuse.poison.curse.cocoon.weaponlock.drunk.zombie.doll.virus.slow.defensedown.strdown.intdown.charm.paralysis.bored

  if ($istok(%negative.status.effects,$1,46) = $true) { 
    if ($return_playersinbattle <= 1) { return 1 }
    if ($1 = confuse) { return 3 }
    if ($1 = poison) { return 3 }
    if ($1 = curse) { return 3 }
    if ($1 = cocoon) { return 3 }
    if ($1 = weaponlock) { return 4 }
    if ($1 = drunk) { return 3 }
    if ($1 = zombie) { return 3 }
    if ($1 = doll) { return 3 }
    if ($1 = virus) { return 3 }
    if ($1 = slow) { return 3 }
    if ($1 = defensedown) { return 3 }
    if ($1 = strdown) { return 3 }
    if ($1 = intdown) { return 3 }
    if ($1 = amnesia) { return 3 }
    if ($1 = charm) { return 3 }
    if ($1 = paralysis) { return 3 }
    if ($1 = bored) { return 2 }
    if ($1 = flying) { return 4 }
  }
  else { 
    if ($1 = defup) { return 3 }
    if ($1 = speedup) { return 3 }
    if ($1 = shell) { return 10 }
    if ($1 = protect) { return 10 }
    if ($1 = enspell) { return 5 }
    if ($1 = reflect) { return 2 }
    if ($1 = invincible) { return 2 }
    if ($1 = flying) { return 5 }
    if ($1 = ethereal) { return 3 }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reward capacity points
; when needed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reward.capacitypoints {
  if (((%battle.type = dungeon) || (%battle.type = cosmic) || (%battle.type = torment))) { return }

  var %temp.player.level $get.level($1)
  if (%temp.player.level < 100) { return }

  var %temp.current.battlestreak $current.battlestreak
  if (%temp.current.battlestreak < 100) { return }

  dec %temp.current.battlestreak 10
  if (%temp.player.level < %temp.current.battlestreak) { return }

  var %capacitypoints $current.battlestreak
  if (%capacitypoints > 500) { 
    var %capacitypoints $round($calc(500 + ($current.battlestreak * .10)),0)
  }

  ; For every 1 acheivement obtained the person will gain a + 2 to the capacity points gained
  inc %capacitypoints $calc($ini($char($1), achievements, 0) * 2)

  var %current.cappoints $readini($char($1), stuff, CapacityPoints)
  if (%current.cappoints = $null) { var %current.cappoints 0 }
  inc %current.cappoints %capacitypoints

  if (%current.cappoints >= 10000) {
    dec %current.cappoints 10000
    if (%current.cappoints < 0) {  var %current.cappoints 0 }

    var %current.EnhancementPoints $readini($char($1), stuff, EnhancementPoints)
    if (%current.EnhancementPoints = $null) { var %current.EnhancementPoints 0 }
    inc %current.EnhancementPoints 1
    writeini $char($1) stuff EnhancementPoints %current.EnhancementPoints
    $display.private.message2($1, $readini(translation.dat, system, GainedEnhancementPoint))
  }

  writeini $char($1) stuff CapacityPoints %current.cappoints
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two functions are for
; Checking for Double Turns
; And randomly giving one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_double_turn {  $set_chr_name($1)
  set %debug.location alias check_for_double_turn

  ; Check for the end of battle

  if (%battle.type = dungeon) {
    if (($dungeon.currentroom = 0) && (%current.turn = 2)) { $battle.check.for.end }
    if ($dungeon.currentroom > 0) { $battle.check.for.end }
  }
  if (%battle.type != dungeon) { $battle.check.for.end }

  unset %wait.your.turn

  ; If the person is dead, blind or sleeping, move to the next turn
  if ($readini($char($1), battle, hp) <= 0) { $next | halt }
  if (($statuseffect.check($1, blind) = yes) || ($statuseffect.check($1, sleep) = yes)) { $next | halt }

  ; Monsters that are in cocoons can't get another turn
  if ($statuseffect.check($1, cocoon) = yes) { $next | halt }

  if ($readini($char($1), info, SkipDoubleTurns) = true) { $next | halt }

  ; Check for a double turn chance for turn based
  if ($return.systemsetting(TurnType) != action) {

    var %actioncounter.current $readini($char($1), Battle, CurrentAction)
    var %actioncounter.max $readini($char($1), Info, ActionsPerTurn)

    if (%actioncounter.current = $null) { var %actioncounter.current 1 }
    if (%actioncounter.max = $null) { var %actioncounter.max 1 }

    if (%actioncounter.max = 1) { $random.doubleturn.chance($1)  }
    if (%actioncounter.current < %actioncounter.max) { writeini $char($1) skills doubleturn.on on }

    ; Increase the Current Action counter
    inc %actioncounter.current 1
    writeini $char($1) Battle CurrentAction %actioncounter.current

    if ($readini($char($1), skills, doubleturn.on) = on) { 
      if ($readini($char($1), info, flag) != $null) {   /.timerBattleNext 1 45 /next }
      if ($readini($char($1), info, flag) = $null) { $system.timer.battlenext }

      $checkchar($1) | writeini $char($1) skills doubleturn.on off | $set_chr_name($1) 

      if ($person_in_mech($1) = true) { %real.name = %real.name $+ 's $readini($char($1), mech, name) }

      $display.message(12 $+ $get_chr_name($1) gets another turn.,battle) 

      set %user.gets.second.turn true

      $aicheck($1) | halt 
    }

    else { $next | halt }
  }

  if ($return.systemsetting(TurnType) = action) {
    var %action.points.left $action.points($1, check)
    if ($2 = forcenext) { var %action.points.left 0 }
    if ($dungeon.currentroom = 0) { var %action.points.left 0 } 

    ; If the person has no action points left, time to move to the next turn
    if (%action.points.left <= 0) { $next | halt }
    else { 
      if ($person_in_mech($1) = true) { %real.name = %real.name $+ 's $readini($char($1), mech, name) }
    $display.message(12 $+ $get_chr_name($1) gets another action this turn $chr(91) $+  $+ %action.points.left action points left $+ $chr(93),battle) } 

    ; Fresh timers
    if ($readini($char($1), info, flag) != $null) {   /.timerBattleNext 1 45 /next }
    if ($readini($char($1), info, flag) = $null) { $system.timer.battlenext  }

    ; Check for AI action
    $aicheck($1) | halt 
  }

}

random.doubleturn.chance {
  set %debug.location alias doubleturn.chance
  if (%battleis = off) { return }
  if ($1 = demon_portal) { return }
  if ($1 = !use) { return }
  if (%multiple.wave.noaction = yes) { unset %multiple.wave.noaction | return }
  if ($readini($char($1), battle, hp) <= 0) { return }

  if ($statuseffect.check($1, cocoon) = yes) { return }
  if ($statuseffect.check($1,  blind) = yes) { return }
  if ($statuseffect.check($1, sleep) = yes) { return }

  if ((%battle.type = dungeon) && ($dungeon.currentroom = 0)) { return }

  $battle.check.for.end

  if ($readini($char($1), skills, doubleturn.on) != on) {
    var %double.turn.chance $rand(1,100)
    if ($augment.check($1, EnhanceDoubleTurnChance) = true) { inc %double.turn.chance $calc(2 * %augment.strength) }
    if ($readini($char($1), info, flag) = monster) { inc %double.turn.chance $rand(1,5) }

    if ($return.playerstyle($1) != HighRoller) { inc %double.turn.chance $rand(1,2) }     

    if (%double.turn.chance >= 99) { writeini $char($1) skills doubleturn.on on | $set_chr_name($1) 
      $display.message($readini(translation.dat, system, RandomChanceGoesAgain),battle) 
    }
  }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function boosts
; summons
; Updated for version 3.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boost_summon_stats {
  set %debug.location alias boost_summon_stats
  ; $1 = person who used the summon
  ; $2 = bloodpact level
  ; $3 = original summon name

  var %summon.level 1
  inc %summon.level $2

  if ($augment.check($1, EnhanceSummons) = true) {  inc %summon.level $calc(%augment.strength * 11)    } 
  if ($augment.check($1, EnhanceBloodpact) = true) {  inc %summon.level $calc(%augment.strength * 11)    } 

  var %m.flag $readini($char($1), info, flag)

  if ((%m.flag = monster) || (%m.flag = npc)) { inc %summon.level $round($calc($get.level($1) / 2),0) }
  if (%m.flag = $null) { inc %summon.level $round($calc($get.level($1) / 1.35),0) }

  ; Adjust the stats
  $levelsync($1 $+ _summon, %summon.level)

  ; Write the new basestats (due to the way level sync works)
  writeini $char($1 $+ _summon) basestats str $readini($char($1 $+ _summon), battle, str)
  writeini $char($1 $+ _summon) basestats def $readini($char($1 $+ _summon), battle, def)
  writeini $char($1 $+ _summon) basestats int $readini($char($1 $+ _summon), battle, int)
  writeini $char($1 $+ _summon) basestats spd $readini($char($1 $+ _summon), battle, spd)

  $boost_monster_hp($1 $+ _summon, bloodpact, %summon.level, $3)

  var %tp $readini($char($1 $+ _summon), BaseStats, TP)
  inc %tp $round($calc(%tp * %summon.level),0) 

  if (%tp > 500) { var %tp 500 }

  writeini $char($1 $+ _summon) BaseStats TP %tp

  $fulls($1 $+ _summon)

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function boosts
; monsters and npcs
; Updated for version 3.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boost_monster_stats {
  set %debug.location alias boost_monster_stats
  ; $1 = monster
  ; $2 = type (rage, warmachine, demonwall, etc)

  if ($readini($char($1), info, BattleStats) = ignore) { return }

  ; Set the starting monster level
  var %monster.level 0

  ; These are things that will affect the monster level
  var %winning.streak $return_winningstreak
  var %level.boost $readini(battlestats.dat, battle, LevelAdjust)
  var %number.of.players.in.battle $readini($txtfile(battle2.txt), battleinfo, players)
  var %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
  var %current.player.levels $readini($txtfile(battle2.txt), battleinfo, playerlevels)  
  var %boss.level $readini($char($1), info, bosslevel) 

  ; Increase the monster level to the winning streak
  inc %monster.level %winning.streak

  if ($readini(system.dat, system, PlayersMustDieMode) = true) { inc %level.boost $rand(5,10) }
  if (%number.of.players.in.battle = $null) { var %number.of.players.in.battle 1 }
  if (%number.of.players.in.battle > 3) { inc %level.boost %number.of.players.in.battle }

  ; Check for special boss types

  if ($2 = mimic) { 
    if (%boss.level = $null) { var %boss.level %winning.streak }
  }

  if ($2 = doppelganger) { 
    var %monster.level $get.level($1)
    dec %monster.level $rand(2,5)
    if (%monster.level <= 0) { var %monster.level $get.level($1) }
  }

  ; Does the monster/boss have a 'boss level' that it spawns at? If so, see if it's below and set it to that level
  if (%boss.level != $null) && (%monster.level < %boss.level) { var %monster.level %boss.level }
  if (%boss.level = $null) && (%battle.type = boss) {
    if ($isfile($mon($1)) = $false) { inc %monster.level $rand(1,2) }
  }

  inc %monster.level %level.boost
  inc %monster.level %difficulty

  ; Certain battles will have set monster levels.
  if (%battle.type = ai) { var %monster.level %ai.battle.level }

  if (%battle.type = defendoutpost) {
    if (%winning.streak >= 100) { var %monster.level 100 }
    if (%winning.streak < 100) { var %monster.level %winning.streak }

    if ((%darkness.turns = 5) || (%darkness.turns = $null)) { dec %monster.level 1 }
    if ((%darkness.turns = 3) || (%darkness.turns = 2)) { inc %monster.level 1 }
    if (%darkness.turns <= 1) { inc %monster.level 3 }
  }

  if (%battle.type = assault) {
    if (%winning.streak >= 100) { var %monster.level 100 }
    if (%winning.streak < 100) { var %monster.level %winning.streak }

    if ($monster.outpost(status) = 10) { dec %monster.level 5 }
    if ($monster.outpost(status) = 9) { dec %monster.level 3 }
    if (($monster.outpost(status) <= 8) && ($monster.outpost(status) >= 5)) { dec %monster.level 2 }
  }

  if ($2 = demonportal) { dec %monster.level 2 }

  ; Is it a losing streak? If so, set all monsters to level 1
  if ((%winning.streak <= 0) && (%battle.type != ai)) { var %monster.level 1 }

  ; $2 = monstersummon is for the monster summon special skill
  if ($2 = monstersummon) { 
    var %temp.level $get.level($3)
    var %monster.level $round($calc(%temp.level / 1.3),0)
    if (%monster.level <= 1) { var %monster.level 2 }
  }

  ; Adjust the monster level if it's a gauntlet
  if (%mode.gauntlet.wave != $null) {  
    if (%mode.gauntlet.wave <= 50) { inc %monster.level $round($calc(%mode.gauntlet.wave * 2.1),0) }
    if ((%mode.gauntlet.wave > 50) && (%mode.gauntlet.wave <= 100)) {  inc %monster.level $round($calc(%mode.gauntlet.wave * 2.5),0) }
    if (%mode.gauntlet.wave > 100) {  inc %monster.level $round($calc(%mode.gauntlet.wave * 3),0) }
  }

  ; Is the monster evolving?
  if ($2 = evolve) { 
    if ($isfile($boss($1)) = $false) { inc %monster.level $rand(3,5) }
    if ($isfile($boss($1)) = $true) { inc %monster.level $rand(5,10)  }
  }

  if (%portal.bonus = true) { 
    if (%boss.level = $null) { var %monster.level $return_winningstreak }
    else { var %monster.level %boss.level } 
  }

  if ((%battle.type = orbfountain) && ($1 != orb_fountain)) {  dec %monster.level 10  }

  ; Is it darkness hitting the monsters?
  if ($2 = rage) { %monster.level = $calc(%monster.level + 99999) }

  if (%monster.level <= 0) { var %monster.level 1 }

  ; If the monster is set to only boost it's hp, do that and return
  if ($readini($char($1), info, BattleStats) = hp) { $boost_monster_hp($1, $2, %monster.level) |  return }

  ; Make sure the [battle] stats are set to what the [basestats] should start off with
  var %basestats.str $readini($char($1), basestats, str)
  var %basestats.def $readini($char($1), basestats, def)
  var %basestats.int $readini($char($1), basestats, int)
  var %basestats.spd $readini($char($1), basestats, spd)

  if (%basestats.str = $null) { writeini $char($1) basestats str 5 }
  if (%basestats.def = $null) { writeini $char($1) basestats def 5 }
  if (%basestats.int = $null) { writeini $char($1) basestats int 5 }
  if (%basestats.spd = $null) { writeini $char($1) basestats spd 5 }

  writeini $char($1) battle str $readini($char($1), basestats, str)
  writeini $char($1) battle def $readini($char($1), basestats, def)
  writeini $char($1) battle int $readini($char($1), basestats, int)
  writeini $char($1) battle spd $readini($char($1), basestats, spd)

  ; Adjust the stats
  $levelsync($1, %monster.level)

  ; Write the new basestats (due to the way level sync works)
  writeini $char($1) basestats str $readini($char($1), battle, str)
  writeini $char($1) basestats def $readini($char($1), battle, def)
  writeini $char($1) basestats int $readini($char($1), battle, int)
  writeini $char($1) basestats spd $readini($char($1), battle, spd)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Adjust the HP and TP of the monsters
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($1 = demon_portal) { $boost_monster_hp($1, $2, %monster.level) | return }
  if ($1 = orb_fountain) { $boost_monster_hp($1, $2, %monster.level) | return }
  if ($1 = lost_soul) { $boost_monster_hp($1, $2, %monster.level) | return }

  $boost_monster_hp($1, $2, %monster.level)

  if ($2 != doppelganger) {  $boost_monster_tp($1, $2, %monster.level)  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Adjust the monster's weapon
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (($2 != doppelganger) && ($readini($char($1), info, IgnoreWeaponBoost) != true)) {
    ; Set the weapon's power based on the streak if it's higher than the monster's current weapon level
    set %current.monster.weapon $readini($char($1), weapons, equipped)
    set %current.monster.weapon.level $readini($char($1), weapons, %current.monster.weapon)

    if (%current.monster.weapon.level < %winning.streak) { set %current.monster.weapon.level.temp $round($calc(%winning.streak / 5),0) 
      if (%current.monster.weapon.level.temp < %current.monster.weapon.level) { writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level }
      else { writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level.temp }
    }
  }
  unset %increase.amount | unset %current.monster.weapon | unset %current.monster.weapon.level
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for boosting
; monster's/npcs's total tp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boost_monster_tp {
  ; $1 = monster
  ; $2 = same as in the boost mon alias
  ; $3 = monster level

  ; If the target is set to ignore tp, don't adjusting
  if (ignoreTP isin $readini($char($1), info, BattleStats)) { return }
  if ($readini($char($1), info, IgnoreTP) = true) { return }

  var %tp $readini($char($1), basestats, tp)

  if ($3 >= 1000) { %tp = $round($calc(%tp + (%monster.level * 1)),0) }
  if ($3 < 1000) {  %tp = $round($calc(%tp + (%monster.level * 5)),0) }

  ; Cap TP at 500 if it's over
  if (%tp > 500) { writeini $char($1) BaseStats TP 500 }

  writeini $char($1) BaseStats TP %tp 
  writeini $char($1) Battle TP %tp
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for boosting
; monster's/npcs's total hp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boost_monster_hp {
  ; $1 = monster
  ; $2 = same as in the boost mon alias
  ; $3 = monster level
  ; $4 = used for summons (original summon's name)

  ; If the target is set to ignore hp, return without adjusting it
  if ((ignoreHP isin $readini($char($1), info, BattleStats)) && (%battle.type != cosmic)) { return }
  if (($readini($char($1), info, IgnoreHP) = true) && (%battle.type != cosmic)) { return }

  set %hp $readini($char($1), BaseStats, HP)

  var %temp.level $return_winningstreak
  var %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
  if (%difficulty != $null) { inc %temp.level %difficulty } 

  var %temp.hp.needed $round($calc(%hp + (((%temp.level - 2)  / 5) * 50)),0)

  if ($2 = portal) { 
    if (%temp.hp.needed > %hp) { writeini $char($1) basestats hp %temp.hp.needed | writeini $char($1) battle hp %temp.hp.needed | return }
  }

  if (%hp < %temp.hp.needed) { var %hp %temp.hp.needed } 

  var %increase.amount 1
  var %hp.modifier 1

  if ($return_playersinbattle > 1) { inc %increase.amount $calc($return_playersinbattle * .25) }

  if ($2 = rage) { %hp = $rand(120000,150000) }

  if (%battle.type = ai) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { var %hp $rand(5000,7500) }
    if ($readini(system.dat, system, IgnoreDmgCap) = true) { var %hp $rand(20000,25000) }

    var %increase.multiplier $round($calc(%ai.battle.level / 100),1)
    var %more.hp $round($calc(150 * %increase.multiplier),0)
    inc %hp %more.hp
    writeini $char($1) BaseStats HP $round(%hp,0)
    writeini $char($1) Battle HP $round(%hp,0)
    return
  }

  if ($return_winningstreak <= 10) { inc %hp.modifier $calc(.03 * $return_winningstreak) }
  if (($return_winningstreak > 10) && ($return_winningstreak <= 200)) { inc %hp.modifier $calc(.015 * $return_winningstreak) }
  if (($return_winningstreak > 200) && ($return_winningstreak <= 500)) { inc %hp.modifier $calc(.0020 * $return_winningstreak) }
  if (($return_winningstreak > 500) && ($return_winningstreak <= 1000)) {  inc %hp.modifier $calc(.0035 * $return_winningstreak) }
  if (($return_winningstreak > 1000) && ($return_winningstreak <= 5000)) {  inc %hp.modifier $calc(.0045 * $return_winningstreak) }
  if ($return_winningstreak > 5000) { var %hp.modifier .0055 }

  if (%battle.type = boss) {
    inc %hp.modifier .08 
    if (%hp < 600) { var %hp $round(600,650) } 
  }
  if ((%battle.type = defendoutpost) && (%darkness.turns = 1)) { inc %hp.modifier 1.01 }
  if (%battle.type = assault) { dec %hp.modifier .06 }

  if (%battle.type = dungeon) { inc %hp.modifier .05 }

  if (%battle.type = ai) {  
    if (%ai.battle.level > 500) { inc %hp.modifier 1 }
  }

  if (%battle.type = orbfountain) { 
    if (%hp.modifier > 1.12) { var %hp.modifier 1.12 } 
  }

  if (%battle.type = dragonhunt) { inc %hp.modifier 3 }
  if (%battle.type = cosmic) { inc %hp.modifier 10 }

  ; Increase the hp modifier if more than 1 player is in battle..
  if ($return_playersinbattle > 1) {
    var %increase.amount $round($calc($return_playersinbattle / 2),0)
    inc %hp.modifier $calc(%increase.amount * .20)
  }

  if ($readini(system.dat, system, PlayersMustDieMode) = true)  { inc %hp.modifier .5 }

  if (%besieged = on) {
    if (%besieged.squad < 3) { var %hp.modifier 1.5 }  
    if ((%besieged.squad >= 3) && (%besieged.squad < 5)) { var %hp.modifier 2 }
    if (%besieged.squad >= 5) { var %hp.modifier 2.55 }
  }

  var %hp $round($calc(%hp + (%hp * %hp.modifier)),0)

  if ((%hp > 25000) && (%battle.type != dragonhunt)) { var %hp $round($calc(25000 + (%hp * .025)),0) }
  if ((%hp > 35000) && (%battle.type = dragonhunt)) { var %hp $round($calc(35000 + (%hp * .25)),0) }


  if (%battle.type = torment) {
    var %torment.hp.multiplier %torment.level
    if (%torment.hp.multiplier >= 20) { var %torment.hp.multiplier 20 }
    inc %hp $calc(%torment.hp.multiplier * 500000)

    if ($return_playersinbattle > 1) { inc %hp $calc($return_playersinbattle * 22000) }
  }


  if (%battle.type = cosmic) {
    var %cosmic.hp.multiplier %cosmic.level
    if (%cosmic.hp.multiplier >= 20) { var %cosmic.hp.multiplier 20 }

    if ($return_playersinbattle > 1) { var %cosmic.hp 900000 } 
    else { var %cosmic.hp 500000 } 

    inc %hp $calc(%cosmic.hp.multiplier * %cosmic.hp)

    if ($return_playersinbattle > 1) { inc %hp $calc($return_playersinbattle * 22000) }
  }


  if (($return.systemsetting(BattleDamageFormula) = 2) || ($return.systemsetting(BattleDamageFormula) = 4)) { var %hp $calc(%hp * 2) }

  ; boost the HP of monsters by 20% per extra player past 1 (for non-torment battles)
  if (%battle.type != torment) {
    if ($return_playersinbattle > 1) {
      inc %hp $calc(%hp * (.2 * $return_playersinbattle))
    }
  }

  if ($2 = bloodpact) {
    var %summon.owner $readini($char($1), info, owner)
    var %max.summon.hp $calc($readini($char(%summon.owner), skills, bloodpact) * 500)

    if ($augment.check($1, EnhanceBloodpact) = true) {  inc %max.summon.hp $calc(%augment.strength * 100) }

    if (%hp > %max.summon.hp) { var %hp %max.summon.hp }
  }

  if ((((%battle.type != dungeon) && (%battle.type != cosmic) && (%portal.bonus != true) && (%battle.type != torment)))) {
    if (((%battle.type = boss) || (%battle.type = dragonhunt) || ($isfile($boss($1) = $true)))) { var %max.multiplier 3 }
    else { var %max.multiplier 2 }

    var %hp.per.level 50
    if (%battle.type = dragonhunt) { var %hp.per.level 20 } 
    if ($return_playersinbattle > 1) { inc %hp.per.level 15 }

    var %maximum.hp $calc((%hp.per.level * $return_winningstreak) * %max.multiplier))
    if (%maximum.hp = 0) { var %maximum.hp 50 }

    if (%hp > %maximum.hp) { var %hp %maximum.hp }
  }

  ; Write the monster's HP
  writeini $char($1) BaseStats HP $round(%hp,0)
  writeini $char($1) Battle HP $round(%hp,0)

  ; Clear certain variables and return
  unset %hp | unset %augment.strength

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function lets players
; sync their level to another
; level.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
levelsync {
  ; $1 = player/monster/target
  ; $2 = level to sync to

  var %str $readini($char($1),battle, str)
  var %def $readini($char($1), battle, def)
  var %int $readini($char($1), battle, int)
  var %spd $readini($char($1), battle, spd)

  inc %str $armor.stat($1, str)
  inc %def $armor.stat($1, def)
  inc %int $armor.stat($1, int)
  inc %spd $armor.stat($1, spd)

  if (%str <= 5) { var %str 5 | writeini $char($1) battle str 5 }
  if (%def <= 5) { var %def 5 | writeini $char($1) battle def 5 }
  if (%int <= 5) { inc %int 5 | writeini $char($1) battle int 5 }
  if (%spd <= 5) { inc %spd 5 | writeini $char($1) battle spd 5 }

  var %level.difference $round($calc($2 - $get.full.level($1)),0)
  var %difference.ratio $calc($2 / $get.full.level($1))
  var %current.loop 0 

  while (%level.difference != 0) {
    if (%current.loop > 10) { break }

    %str = $round($calc(%str * %difference.ratio),0) 
    %def = $round($calc(%def * %difference.ratio),0) 
    %int = $round($calc(%int * %difference.ratio),0) 
    %spd = $round($calc(%spd * %difference.ratio),0) 

    if (%str <= 5) { var %str 5  }
    if (%def <= 5) { var %def 5 }
    if (%int <= 5) { inc %int 5 }
    if (%spd <= 5) { inc %spd 5 }

    writeini $char($1) battle Str %str
    writeini $char($1) battle Def %def
    writeini $char($1) battle Int %int
    writeini $char($1) battle Spd %spd

    var %current.level $get.full.level($1)
    var %level.difference $round($calc($2 - $get.level($1)),0)
    var %difference.ratio $calc($2 / $get.level($1))

    writeini $char($1) info levelsync yes
    inc %current.loop 1
  }

  ; Monsters and Bosses need their stats copied from the synced level to the basestats portion
  if (($readini($char($1), info, flag) = monster) || ($readini($char($1), info, flag) = boss)) { 
    writeini $char($1) basestats str $readini($char($1), battle, str)
    writeini $char($1) basestats def $readini($char($1), battle, def)
    writeini $char($1) basestats int $readini($char($1), battle, int)
    writeini $char($1) basestats spd $readini($char($1), battle, spd)
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function actually deals
; the damage to the target.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deal_damage {
  ; $1 = person dealing damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)
  ; $4 = absorb or none

  unset %diehard.message
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  set %attack.damage $round(%attack.damage, 0)

  if (%guard.message != $null) { set %attack.damage 0 }

  ; Is the target a TRUE metal defense target? If so, this will always be 1 damage max.
  if ((%attack.damage > 0) && ($readini($char($2), info, TrueMetalDefense) = true)) { 
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
    set %attack.damage 1 
  }

  ; Check to see if we need to remove flawless victory
  if (%attack.damage > 0) {
    if (($readini($char($2), info, flag) = npc) || ($readini($char($2), info, flag) = $null)) { writeini $txtfile(battle2.txt) BattleInfo FlawlessVictory false }
  }

  ; Do we need to wake up a sleeping target?
  if ((%attack.damage > 0) && ($readini($char($2), Status, Sleep) = yes)) { 
    $display.message($readini(translation.dat, status, WakesUp), battle) 
    writeini $char($2) status sleep no
  }

  unset %absorb.message

  if ($3 != JustRelease) {
    if ($readini($char($2), Status, cocoon) = yes) { 
      set %attack.damage 0 
      $set_chr_name($2) | set %guard.message $readini(translation.dat, skill, CocoonBlock)
    }
  }

  ; Check for natural armor.

  if (%attack.damage > 0) {

    var %naturalArmorCurrent $readini($char($2), NaturalArmor, Current)

    if ((%naturalArmorCurrent != $null) && (%naturalArmorCurrent > 0)) {

      if ($readini($char($1), Info, DragonKiller) = true) { inc %attack.damage $round($calc($readini($char($2), NaturalArmor, Max) * .35),0) }

      set %naturalArmorName $readini($char($2), NaturalArmor, Name) 
      set %difference $calc(%attack.damage - %naturalArmorCurrent)
      dec %naturalArmorCurrent %attack.damage | writeini $char($2) NaturalArmor Current %naturalArmorCurrent

      if (%naturalArmorCurrent <= 0) { set %attack.damage %difference | writeini $char($2) naturalarmor current 0
        if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {  $display.message($readini(translation.dat, battle, NaturalArmorBroken),battle) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, NaturalArmorBroken)) }
        unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
      }
      if (%naturalArmorCurrent > 0) { set %guard.message $readini(translation.dat, battle, NaturalArmorAbsorb) | set %attack.damage 0 }

      unset %difference
    }

  }

  if ($readini($char($2), info, IgnoreDrain) = true) { unset %absorb | unset %drainsamba.on | unset %absorb.amount }

  if ($person_in_mech($2) = true) { 
    var %life.target $readini($char($2), mech, HpCurrent)
    dec %life.target %attack.damage
    if (%life.target < 0) { var %life.target 0 }
    writeini $char($2) mech HpCurrent %life.target
    unset %absorb | unset %drainsamba.on | unset %absorb.amount
  }

  if ($person_in_mech($2) = false) {   
    var %life.target $readini($char($2), Battle, HP) 
    dec %life.target %attack.damage
    writeini $char($2) battle hp %life.target
  }

  ; Add some style points to the user
  if ($3 != renkei) { 
    if (%style.attack.damage = $null) { set %style.attack.damage 0 }
    $add.stylepoints($1, $2, %style.attack.damage, $3) 
  }

  ; If it's an Absorb HP type, we need to add the hp to the person.
  if ($person_in_mech($2) = false) { 
    if (($4 = absorb) || (%absorb = absorb)) { 

      if ($readini($char($2), info, IgnoreDrain) != true) {

        if (%guard.message = $null) {
          if ($readini($char($2), monster, type) != undead) {
            var %absorb.amount $round($calc(%attack.damage / 3),0)
            if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.4),0) }

            if ($accessory.check($1, CurseAddDrain) = true) {
              var %absorb.amount $round($calc(%attack.damage / 1.7),0)
              unset %accessory.amount
            }

            unset %current.accessory | unset %current.accessory.type

            if (%absorb.amount > 500) { var %absorb.amount 500 }

            if (((%battle.type = torment)  || (%battle.type = cosmic) || (%battle.type = dungeon))) { 
              if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
                if (%absorb.amount > 350) { var %absorb.amount 350 }
              }
            }

            set %life.target $readini($char($1), Battle, HP) | set %life.max $readini($char($1), Basestats, HP)
            inc %life.target %absorb.amount
            if (%life.target >= %life.max) { set %life.target %life.max }
            writeini $char($1) battle hp %life.target
          }
          if ($readini($char($2), monster, type) = undead) { unset %absorb | unset %absorb.amount }
        }

      }
      if (%guard.message != $null) { unset %absorb | unset %absorb.amount }
    }

    if (($augment.check($1, AbsorbTP) = true) && (%guard.message = $null)) {
      var %tp.absorb.amount $calc(%augment.strength * 10)
      set %tp.target $readini($char($2), battle, tp) 

      if (%tp.target > 0) {
        set %tp.user $readini($char($1), battle, tp) | set %tp.max $readini($char($1), basestats, tp) 
        inc %tp.user %tp.absorb.amount
        if (%tp.user >= %tp.max) { writeini $char($1) battle tp %tp.max }
        if (%tp.user < %tp.max) { writeini $char($1) battle tp %tp.user }

        $set_chr_name($1) | set %absorb.message 3 $+ %real.name absorbs %tp.absorb.amount TP from $set_chr_name($2) %real.name $+ !
        set %tp.max $readini($char($2), basestats, tp) 
        dec %tp.target %tp.absorb.amount
        if (%tp.target <= 0) { writeini $char($2) battle tp 0 }
        if (%tp.target > 0) { writeini $char($2) battle tp %tp.target }
      }
      unset %tp.user | unset %tp.target | unset %tp.max
    } 

    if (($augment.check($1, AbsorbIG) = true) && (%guard.message = $null)) {
      if ((%aoe.turn <= 1) || (%aoe.turn = $null)) {
        var %ig.absorb.amount $calc(%augment.strength * 5)
        if ($readini($char($1), info, flag) = monster) { var %ig.absorb.amount $calc(%augment.strength * 10) }

        set %ig.target $readini($char($2), battle, IgnitionGauge)
        if (%ig.target < %ig.absorb.amount) { var %ig.absorb.amount %ig.target }

        if (%ig.target > 0) { 
          set %ig.user $readini($char($1), battle, IgnitionGauge)
          set %ig.max $readini($char($1), basestats, IgnitionGauge) 
          inc %ig.user %ig.absorb.amount
          if (%ig.user >= %ig.max) { writeini $char($1) battle IgnitionGauge %ig.max }
          if (%ig.user < %ig.max) { writeini $char($1) battle IgnitionGauge %ig.user }

          $set_chr_name($1) | set %absorb.message 3 $+ %real.name absorbs %ig.absorb.amount Ignition Gauge from $set_chr_name($2) %real.name $+ !

          set %ig.max $readini($char($2), basestats, IgnitionGauge) 
          dec %ig.target %ig.absorb.amount
          if (%ig.target <= 0) { writeini $char($2) battle IgnitionGauge 0 }
          if (%ig.target > 0) { writeini $char($2) battle IgnitionGauge %ig.target }
        }
        unset %ig.user | unset %ig.target | unset %ig.max
      }
    }
  }

  if ($person_in_mech($2) = false) { 
    if ($readini($char($2), battle, HP) <= 0) { 

      ; If the target has the DieHard skill there is a chance that he/she/it won't actually die and be revived..
      var %diehard.chance 0
      if ($readini($char($2), Skills, DieHard) != $null) { var %diehard.chance $readini($char($2), Skills, DieHard) }

      if ((%diehard.chance = 0) || ($rand(1,100) > %diehard.chance)) {

        if (($readini(battlestats.dat, Bounty, BossName) = $2) && (%battle.type != ai)) {
          writeini $txtfile(battle2.txt) battleinfo bountyclaimed true 
          writeini $txtfile(battle2.txt) battleinfo bountyclaimedby $get_chr_name($1)
        }

        writeini $char($2) battle status dead 
        writeini $char($2) battle hp 0
        remini $txtfile(battle2.txt) enmity $2

        if ((%battle.type = assault) && ($readini($char($2), info, flag) = monster)) { 
          if ($isfile($boss($2)) = $true) { $monster.outpost(remove, $rand(2,3)) }
          if ($isfile($mon($2)) = $true) { $monster.outpost(remove, 1) }
        }

        ; give some ignition points if necessary
        $battle.reward.ignitionGauge.single($2)

        ; check for an item drop
        $add.monster.drop($1, $2)

        ; if the attacker isn't a monster we need to increase the total # of kills
        if (($readini($char($1), info, flag) != monster) && ($readini($char($1), battle, hp) > 0)) {
          $inc_monster_kills($1)

          ; increase lost soul count if that's what the monster is
          if ($2 = Lost_Soul) { 
            var %total.souls $readini($char($1), stuff, LostSoulsKilled)
            if (%total.souls = $null) { var %total.souls 0 }
            inc %total.souls 1
            writeini $char($1) stuff LostSoulsKilled %total.souls
          }

          ; add style points
          if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
          if (%battle.type = manual) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
          if (%battle.type = orbfountain) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
          if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) }
          if (%battle.type = defendoutpost) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) }
          if (%battle.type = assault) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) }
          if (%portal.bonus = true) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) }
          if (%battle.type = dungeon) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) } 
          if (%battle.type = torment) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) } 
          if (%battle.type = cosmic) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) } 
        }

      }
      else {
        var %life.restored $return_percentofvalue($readini($char($2), basestats, hp), $readini($char($2), skills, DieHard))
        writeini $char($2) Battle HP %life.restored
        writeini $char($2) Battle Status Alive
        set %diehard.message true
      }

    }
  }

  $ai.learncheck($2, $3)

  if (%guard.message = $null) { $renkei.calculate($1, $2, $3) }

  ; Increase total damage that we're keeping track of
  if ((($4 = tech) || ($4 = melee) || ($5 = tech))) {
    if (($person_in_mech($1) = false) && (%guard.message = $null)) {
      if (($4 = tech) || ($5 = tech)) { var %totalstat tech }
      else { var %totalstat melee }

      var %current.totaldamage $readini($char($1), stuff, totalDmg. $+ %totalstat) 
      var %current.totalhits $readini($char($1), stuff, %totalstat $+ Hits)
      if (%current.totaldamage = $null) { var %current.damage 0 }
      if (%current.totalhits = $null) { var %current.totalhits 0 }
      inc %current.totalhits 1
      inc %current.totaldamage %attack.damage

      writeini $char($1) stuff totalDmg. $+ %totalstat %current.totaldamage
      writeini $char($1) stuff %totalstat $+ Hits %current.totalhits
    } 
  }

  ; Increase enmity
  if ($readini($char($1), info, flag) != monster) {  $enmity($1, add, %attack.damage) }

  ; Unset the attack damage used for calculating style meter
  unset %style.attack.damage 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for healing
; damage done to a target
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
heal_damage {
  ; $1 = person heal damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)

  ;  Check for the blessed-ankh accessory
  if ($accessory.check($1, IncreaseHealing) = true) {
    var %health.increase $round($calc(%attack.damage * %accessory.amount),0)
    inc %attack.damage %health.increase
    unset %accessory.amount
  }

  if ($person_in_mech($2) = true) { set %attack.damage 0 }

  ; Increase enmity
  if ($readini($char($1), info, flag) != monster) { $enmity($1, add, $calc(%attack.damage * 2)) }

  $restore_hp($2, %attack.damage)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function actually shows
; the damage to the channel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_damage {
  ; $1 = person attacking
  ; $2 = person defending
  ; $3 = type of display needs to be done
  ; $4 = weapon/tech/item name

  ; A valid command was done, so let's turn the next timer off before we do this
  /.timerBattleNext off

  ; Begin displaying the damage
  unset %overkill |  unset %style.rating | unset %target | unset %attacker 
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  if (%damage.display.color = $null) { var %damage.display.color 4 }

  ; Show a random attack description
  if ($3 = weapon) { 

    if (%counterattack != shield) {

      if (%counterattack != on ) {   set %attacker $1 | set %target $2 | var %weapon.type $readini($dbfile(weapons.db), $4, type) |  var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)  }

      if (%counterattack = on) { 
        set %weapon.equipped $readini($char($2), weapons, equipped)
        set  %weapon.type $readini($dbfile(weapons.db), %weapon.equipped, type)
        var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)
        unset %weapon.equipped | unset %weapon.type
        $display.message($readini(translation.dat, battle, MeleeCountered), battle)
        $set_chr_name($1) | set %enemy %real.name | set %target $1 | set %attacker $2 | $set_chr_name($2) | set %user %real.name 
      }

    $display.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)  }
  }

  if (%counterattack = shield) {
    var %weapon.equipped $readini($char($1), weapons, equipped)
    set  %weapon.type $readini($dbfile(weapons.db), %weapon.equipped, type)
    var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)

    $display.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)  

    $display.message($readini(translation.dat, battle, ShieldCountered), battle)
    $set_chr_name($1) | set %enemy %real.name | set %target $1 | set %attacker $2 | $set_chr_name($2) | set %user %real.name 
  }

  if (%shield.block.line != $null) { 
    if (%counterattack != on) { $display.message(%shield.block.line, battle) | unset %shield.block.line }
  }

  if ($3 = tech) {
    if (%showed.tech.desc != true) { $display.message(3 $+ %user $+  $readini($dbfile(techniques.db), $4, desc), battle) }

    if ($readini($dbfile(techniques.db), $4, magic) = yes) {
      ; Clear elemental seal
      if ($readini($char($1), skills, elementalseal.on) = on) {  writeini $char($1) skills elementalseal.on off   }
      if ($readini($char($2), status, reflect) = yes) { 
        if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {  $display.message($readini(translation.dat, skill, MagicReflected),battle) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, skill, MagicReflected)) }

      $set_chr_name($1) | set %enemy %real.name | set %target $1 | set %attacker $2 | writeini $char($2) status reflect no | writeini $char($2) status reflect.timer 0  }
    }
  }

  if ($3 = item) {
    $display.message(3 $+ %user $+  $readini($dbfile(items.db), $4, desc), battle)
  }

  if ($3 = fullbring) { $display.message(3 $+ %user $+  $readini($dbfile(items.db), $4, fullbringdesc), battle) } 

  if ($3 = renkei) { $display.message($readini(translation.dat, system, RenkeiPerformed) 3 $+ %renkei.description, battle) |  unset %style.rating  }

  ; Show the damage
  if ((($3 != item) && ($3 != renkei) && ($1 != battlefield))) { 

    if (%counterattack = on) { $calculate.stylepoints($2) }
    if (%counterattack != on) { 

      if (($readini($char($1), info, flag) != monster) && (%target != $1)) { 
        if ($1 != $2) { $calculate.stylepoints($1)  }
      }

    }

  }

  ; Set the damage message
  if (%number.of.hits > 1) { var %damage.message The attack hits4 %number.of.hits times and does %damage.display.color $+  $+ $bytes(%attack.damage,b) total damage to %enemy $+ . %style.rating }
  else { var %damage.message The attack does %damage.display.color $+  $+ $bytes(%attack.damage,b) damage to %enemy $+ . %style.rating }

  ; Display the damage or guard message
  if (%number.of.hits > 1) { 
    if (%guard.message != $null) { $display.message(%guard.message,battle)  }
    if (%guard.message = $null) { $display.message(%damage.message,battle) }
  }
  else { 

    if ($3 != aoeheal) {
      if (%guard.message = $null) {  $display.message(%damage.message, battle) 
      }
      if (%guard.message != $null) { $display.message(%guard.message,battle) 
      }
      if (%element.desc != $null) {  $display.message(%element.desc, battle) 
        unset %element.desc 
      }
    }
    if ($3 = aoeheal) { 
      if (%guard.message = $null) {  $display.message(%damage.message, battle)    }
      if (%guard.message != $null) { $display.message(%guard.message,battle)  }
      if (%element.desc != $null) {  $display.message(%element.desc,battle) 
        unset %element.desc 
      }
    }
  }


  unset %number.of.hits | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 

  if (%element.desc != $null) {  $display.message(%element.desc, battle) }

  if (%target = $null) { set %target $2 }
  if (%attacker = $null) { set %attacker $1 }

  if (%statusmessage.display != $null) { 
    if ($readini($char(%target), battle, hp) > 0) { $display.message(%statusmessage.display,battle) 
      unset %statusmessage.display 

      if (($readini($char(%target), status, flying) = yes) && ($readini($char(%target), status, heavy) = yes)) { 
        ; if the target is flying, send it back to the ground
        writeini $char(%target) status flying no 
        if ($readini($char(%target), info, flag) != $null) { remini $char(%target) skills flying }
        $set_chr_name(%target)
        $display.message($readini(translation.dat, Status, FlyingCrash), battle)
      }


    }
  }

  if (%absorb = absorb) {
    if (%guard.message = $null) {
      ; Show how much the person absorbed back.
      var %absorb.amount $round($calc(%attack.damage / 3),0)
      if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }

      if (%absorb.amount > 500) { var %absorb.amount 500 }

      if (((%battle.type = torment)  || (%battle.type = cosmic) || (%battle.type = dungeon))) { 
        if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
          if (%absorb.amount > 350) { var %absorb.amount 350 }
        }
      }

      $display.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.,battle) 
      unset %absorb
    }
  }

  if (%drainsamba.on = on) {
    if (%guard.message = $null) {
      if (($readini($char(%target), monster, type) != undead) && ($readini($char(%target), monster, type) != zombie)) { 
        var %absorb.amount $round($calc(%attack.damage / 3),0)
        if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
        if (%absorb.amount <= 0) { var %absorb.amount 1 }

        if (%absorb.amount > 500) { var %absorb.amount 500 }

        if (((%battle.type = torment)  || (%battle.type = cosmic) || (%battle.type = dungeon))) { 
          if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
            if (%absorb.amount > 350) { var %absorb.amount 350 }
          }
        }

        $display.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.,battle) 
        set %life.target $readini($char($1), Battle, HP) | set %life.max $readini($char($1), Basestats, HP)
        inc %life.target %absorb.amount
        if (%life.target >= %life.max) { set %life.target %life.max }
        writeini $char($1) battle hp %life.target
        unset %life.target | unset %life.target | unset %absorb.amount 
      }
    }
  }
  if (%absorb.message != $null) { 
    if (%guard.message = $null) { $display.message(%absorb.message,battle) 
      unset %absorb.message
    }
  }

  unset %guard.message


  ; Check for inactive..
  if ($readini($char(%target), battle, status) = inactive) {
    if ($readini($char(%target), battle, hp) > 0) { 
      if ($readini($char($1), info, flag) != monster) { 
        writeini $char(%target) battle status alive

        if ($readini($char(%target), descriptions, Awaken) != $null) { $display.message(4 $+ %enemy  $+ $readini($char(%target), descriptions, Awaken), battle) }
        if ($readini($char(%target), descriptions, Awaken) = $null) { $display.message($readini(translation.dat, battle, inactivealive),battle)    }
        $next 
      }
    }
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char(%target), battle, HP) <= 0) { 

    $increase_death_tally(%target)
    $achievement_check(%target, SirDiesALot)
    $gemconvert_check($1, %target, $3, $4)
    if (%attack.damage > $readini($char(%target), basestats, hp)) { set %overkill 7<<OVERKILL>> }

    $display.message($readini(translation.dat, battle, EnemyDefeated), battle)
    unset %overkill

    ; check to see if a clone or summon needs to die with the target
    $check.clone.death(%target)

    if ($readini($char(%target), info, flag) != $null) {  $random.healing.orb($1,%target)  }

    if ($readini($dbfile(techniques.db), $4, magic) = yes) { $goldorb_check(%target, magic)  }
    if ($readini($dbfile(techniques.db), $4, magic) != yes) { $goldorb_check(%target, $3) }

    if ($readini($char($1), info, flag) = $null) {
      ; increase the death tally of the target
      if ($readini($char(%target), battle, status) = dead) {  $increase.death.tally(%target)  }
    }

    ; Check to see if a bounty was claimed
    if ($readini($txtfile(battle2.txt), battleinfo, bountyclaimed) = true) { $display.message($readini(translation.dat, system, BountyClaimed), battle) } 

    $spawn_after_death(%target)
    remini $char(%target) Renkei

    ; Check for the achievement A Light in the Dark coutesty of Andrio
    $achievement_check($1, ALightInTheDark)

    ; Check for the achievement Fill Your Dark Soul With Light
    $achievement_check($1, FillYourDarkSoulWithLight)
  }


  if (($readini($char(%target), battle, HP) > 0) && ($person_in_mech($2) = false)) {

    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char(%target), info, CanStagger)
    if ((%guard.message != $null) || (%attack.damage <= 0)) { var %stagger.check false }
    if ((%stagger.check = yes) || (%stagger.check = true)) {

      ; Do the stagger if the damage is above the threshold.
      set %stagger.amount.needed $readini($char(%target), info, StaggerAmount)

      dec %stagger.amount.needed %attack.damage | writeini $char(%target) info staggeramount %stagger.amount.needed
      if (%stagger.amount.needed <= 0) { writeini $char(%target) status staggered yes |  writeini $char(%target) info CanStagger no
        $display.message($readini(translation.dat, status, StaggerHappens),battle) 
      }

      unset %stagger.amount.needed
    }

    if ($3 = tech) { unset %attack.damage | $renkei.check($1, %target) }

    if (%battle.type = orbfountain) { 
      if (($readini($char(%target), battle, status) != dead) && ($return_winningstreak >= 50)) { 
        if ($rand(1,100) < 30) {
          if (($1 != battlefield) && (%target = orb_fountain)) { 
            $display.message($readini(translation.dat, system, MonstersDefendOrbFountain), battle)
            $portal.clear.monsters
            $generate_monster(monster)
          }
        }
      }
    }

    ; If Diehard triggered, let's show a message
    if (%diehard.message = true) { 
      $display.message($readini(translation.dat, skill, DieHardTriggered), battle)
      unset %diehard.message
    }

    ; Check for weaknessshift
    $skill.weaknessshift(%target)

  }

  if ($person_in_mech($2) = true) { 
    ; Is the mech destroyed?
    if ($readini($char($2), mech, HpCurrent) <= 0) {  var %mech.name $readini($char($2), mech, name)
      if ($readini($char($2), Descriptions, MechDestroyed) = $null) { $display.message($readini(translation.dat, battle, DisabledMech), battle) }
      else { $display.message(4 $+ $get_chr_name($2)  $+ $readini($char($2), Descriptions, MechDestroyed), battle) }
      $mech.deactivate($2, true)
    }
  }



  unset %target | unset %attacker | unset %user | unset %enemy | unset %counterattack |  unset %statusmessage.display

  if ($3 = weapon) {
    if ($readini($char($1), battle, hp) > 0) {
      set %inflict.user $1 | set %inflict.techwpn $4
      $self.inflict_status(%inflict.user, %inflict.techwpn ,weapon)
      if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
    }
  }

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays AOE damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_aoedamage {
  ; $1 = user
  ; $2 = target
  ; $3 = tech name
  ; $4 = flag for if it's a melee

  if (%damage.display.color = $null) { var %damage.display.color 4 }

  unset %overkill | unset %target |  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  ; Show the damage
  if ($person_in_mech($2) = false) { 
    if ($4 = $null) { 
      if (($readini($char($2), status, reflect) = yes) && ($readini($dbfile(techniques.db), $3, magic) = yes)) { $display.message($readini(translation.dat, skill, MagicReflected), battle) | $set_chr_name($1) | set %enemy %real.name | set %target $1 | writeini $char($2) status reflect no | writeini $char($2) status reflect.timer 1  }
    }
  }

  if ($3 != battlefield) {
    if (($readini($char($1), info, flag) != monster) && (%target != $1)) { $calculate.stylepoints($1) }
  }

  if (%guard.message = $null) { $display.message($readini(translation.dat, tech, DisplayAOEDamage), battle)  }
  if (%guard.message != $null) { $display.message(%guard.message, battle) | unset %guard.message }

  unset %statusmessage.display

  if (%target = $null) { set %target $2 }


  if ($4 = absorb) { 
    if (%guard.message = $null) {
      ; Show how much the person absorbed back.
      var %absorb.amount $round($calc(%attack.damage / 3),0)
      if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }

      if (%absorb.amount > 500) { var %absorb.amount 500 }

      if (((%battle.type = torment)  || (%battle.type = cosmic) || (%battle.type = dungeon))) { 
        if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
          if (%absorb.amount > 350) { var %absorb.amount 350 }
        }
      }

      $display.message($readini(translation.dat, tech, AbsorbHPBack), battle)
      unset %absorb
    }
  }
  if (%absorb.message != $null) { 
    if (%guard.message = $null) { 
      $display.message(%absorb.message,battle) 
      unset %absorb.message
    }
  }

  set %target.hp $readini($char(%target), battle, hp)

  if ((%target.hp > 0) && ($person_in_mech(%target) = false)) {

    ; Check for inactive..
    if ($readini($char(%target), battle, status) = inactive) {
      if ($readini($char($1), info, flag) != monster) { 
        writeini $char(%target) battle status alive
        if ($readini($char(%target), descriptions, Awaken) != $null) { $display.message(4 $+ %enemy  $+ $readini($char(%target), descriptions, Awaken), battle) }
        if ($readini($char(%target), descriptions, Awaken) = $null) { $display.message($readini(translation.dat, battle, inactivealive),battle)    }
      }
    }

    if (%battle.type = orbfountain) { 
      if (($readini($char(%target), battle, status) != dead) && ($return_winningstreak >= 50)) { 
        if ($rand(1,100) < 30) {
          if (($1 != battlefield) && (%target = orb_fountain)) { 
            $display.message($readini(translation.dat, system, MonstersDefendOrbFountain), battle)
            $portal.clear.monsters
            $generate_monster(monster)
          }
        }
      }
    }

    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char(%target), info, CanStagger)
    if ((%stagger.check = $null) || (%stagger.check = no)) { return }

    ; Do the stagger if the damage is above the threshold.
    var %stagger.amount.needed $readini($char(%target), info, StaggerAmount)
    dec %stagger.amount.needed %attack.damage | writeini $char(%target) info staggeramount %stagger.amount.needed
    if (%stagger.amount.needed <= 0) { writeini $char(%target) status staggered yes |  writeini $char(%target) info CanStagger no
      $display.message($readini(translation.dat, status, StaggerHappens), battle)
    }


    ; If Diehard triggered, let's show a message
    if (%diehard.message = true) { 
      $display.message($readini(translation.dat, skill, DieHardTriggered), battle)
      unset %diehard.message
    }

  }


  ; Did the person die?  If so, show the death message.

  if ((%target.hp  <= 0) && ($person_in_mech($2) = false)) { 
    writeini $char(%target) battle status dead 
    writeini $char(%target) battle hp 0
    $check.clone.death(%target)
    $increase_death_tally(%target)
    $achievement_check(%target, SirDiesALot)
    if (%attack.damage > $readini($char(%target), basestats, hp)) { set %overkill 7<<OVERKILL>> }
    $display.message($readini(translation.dat, battle, EnemyDefeated), battle)

    if ($readini($dbfile(techniques.db), $3, magic) = yes) {  $goldorb_check(%target, magic)  }
    if ($readini($dbfile(techniques.db), $3, magic) != yes) { $goldorb_check(%target, tech) }

    if ($readini($char($1), info, flag) = $null) {
      ; increase the death tally of the target
      if ($readini($char(%target), battle, status) = dead) {  $increase.death.tally(%target)  }
    }

    $spawn_after_death(%target)
    $achievement_check($1, FillYourDarkSoulWithLight)
  }

  if ($person_in_mech($2) = true) { 
    ; Is the mech destroyed?
    if ($readini($char($2), mech, HpCurrent) <= 0) {  var %mech.name $readini($char($2), mech, name)
      $display.message($readini(translation.dat, battle, DisabledMech), battle)
      writeini $char($2) mech inuse false
    }
  }

  ; If Diehard triggered, let's show a message
  if (%diehard.message = true) { 
    $display.message($readini(translation.dat, skill, DieHardTriggered), battle)
    unset %diehard.message
  }



  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  unset %attack.damage | unset %target
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function displays the
; healing to the channel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_heal {
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }

  if ($3 = tech) {
    if (%showed.tech.desc != true) {
      $set_chr_name($1)
      $display.message(3 $+ %real.name $+  $readini($dbfile(techniques.db), $4, desc),battle) 
    }
  }

  if ($3 = item) {
    $display.message(3 $+ %user $+  $readini($dbfile(items.db), $4, desc),battle) 
  }

  if ($3 = weapon) { 
    var %weapon.type $readini($dbfile(weapons.db), $4, type) | var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)
    $display.message(3 $+ %user $+  $read %attack.file  $+ 3.,battle) 
  }

  ; Show the damage healed
  if (%guard.message = $null) {  $set_chr_name($2) |  $set_chr_name($2)
    $set_chr_name($2) | set %enemy %real.name
    if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
    $display.message(3 $+ %enemy has been healed for $bytes(%attack.damage,b) health!, battle) 
  }
  if (%guard.message != $null) { 
    $set_chr_name($2) | set %enemy %real.name
    if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
    $display.message(%guard.message,battle) 
    unset %guard.message
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    $set_chr_name($2) 
    $display.message(4 $+ %enemy has been defeated by %user $+ !  %overkill,battle) 
    $achievement_check($1, FillYourDarkSoulWithLight)
  }

  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %drainsamba.on | unset %absorb
  unset %element.desc | unset %spell.element | unset %real.name  |  unset %trickster.dodged | unset %covering.someone

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks to see
; if enemies drop a random
; healing type of orb like in
; the Devil May Cry games
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.healing.orb {
  if ($person_in_mech($1) = true) { return }
  if (%battle.type = ai) { return }
  ; check to see if a random healing orb appears.
  if ($1 != $2) {
    var %healing.orb.chance $rand(0,100)

    if (%healing.orb.chance < 65) { return }

    if ((%healing.orb.chance >= 65) && (%healing.orb.chance <= 80)) {
      ; health orb
      var %orb.restored $rand(50,100)
      $restore_hp($1, %orb.restored)
      $display.message($readini(translation.dat, battle, ObtainGreenOrb),battle)
    }

    if ((%healing.orb.chance > 80) && (%healing.orb.chance < 98)) {
      ; TP orb
      var %orb.restored $rand(5,20)
      $restore_tp($1, %orb.restored)
      $display.message($readini(translation.dat, battle, ObtainWhiteOrb),battle) 
    }

    if (%healing.orb.chance >= 98) { 
      ; Ignition Orb
      var %max.ig $readini($char($1), basestats, IgnitionGauge)
      if (%max.ig > 0) {
        var %orb.restored $rand(1,2)
        $restore_ig($1, %orb.restored)
        $display.message($readini(translation.dat, battle, ObtainOrangeOrb),battle) 
      }
    }

  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; the taunt command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
taunt {
  ; $1 = taunter
  ; $2 = target

  unset %attack.target
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoCurrentBattle), private) | halt  }
  $check_for_battle($1) 
  $person_in_battle($2) 

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, OnlyTauntMonsters), private) | halt }
  if (($readini($char($2), monster, type) = object) && (%user.flag != monster)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, OnlyTauntMonsters), private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, Can'tTauntWhiledead), private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, Can'tTauntSomeoneWhoIsDead), private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $display.message($readini(translation.dat, errors, Can'tTauntSomeoneWhoFled), private) | unset %real.name | halt } 

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; Add some style to the taunter.
  set %stylepoints.to.add $rand(60,80)
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (%current.playerstyle = Trickster) { %stylepoints.to.add = $calc((10 * %current.playerstyle.level) + %stylepoints.to.add) }

  $add.stylepoints($1, $2, %stylepoints.to.add, taunt)  

  unset %current.playerstyle | unset %current.playerstyle.level

  ; Pick a random taunt and show it.
  $calculate.stylepoints($1)
  $set_chr_name($2) | set %enemy %real.name
  $set_chr_name($1) 

  var %taunt.file $readini($char($1), info, TauntFile)
  if ($isfile($txtfile(%taunt.file)) = $false) { var %taunt.file taunts.txt } 
  if (%taunt.file = $null) {  var %taunt.file taunts.txt }

  var %taunt $read($txtfile(%taunt.file))

  $display.message(2 $+ %real.name looks at $set_chr_name($2) %real.name and says " $+ %taunt $+ "  %style.rating, battle) 

  : If the monster is HurtByTaunt, do damage.  Else, do a random effect.

  if ($readini($char($2), info, HurtByTaunt) = true) { 
    remini $txtfile(battle2.txt) style $1 $+ .lastaction
    set %attack.damage $return_percentofvalue($readini($char($2), basestats, hp) ,$rand(25,35))
    $deal_damage($1, $2, taunt)
    $display_aoedamage($1, $2, taunt)
    unset %attack.damage
    remini $txtfile(battle2.txt) style $1 $+ .lastaction
  }

  if ($readini($char($2), info, HealByTaunt) = true) { 
    remini $txtfile(battle2.txt) style $1 $+ .lastaction
    set %attack.damage $return_percentofvalue($readini($char($2), basestats, hp) ,$rand(25,35))
    $heal_damage($1, $2, taunt)
    $display_heal($1, $2, taunt)
    unset %attack.damage
    remini $txtfile(battle2.txt) style $1 $+ .lastaction
  }

  else { 

    ; Now do a random effect to the monster.
    var %taunt.effect $rand(1,8)

    if (%taunt.effect = 1) { var %taunt.str $readini($char($2), battle, str) | inc %taunt.str $rand(1,2) | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | $display.message($readini(translation.dat, battle, TauntRage), battle) }
    if (%taunt.effect = 2) { var %taunt.def $readini($char($2), battle, def) | inc %taunt.def $rand(1,2) | writeini $char($2) battle def %taunt.def | $set_chr_name($2) | $display.message($readini(translation.dat, battle, TauntDefensive), battle) }
    if (%taunt.effect = 3) { var %taunt.int $readini($char($2), battle, int) | dec %taunt.int 1 | writeini $char($2) battle int %taunt.int | $set_chr_name($2) | $display.message($readini(translation.dat, battle, TauntClueless), battle) }
    if (%taunt.effect = 4) { var %taunt.str $readini($char($2), battle, str) | dec %taunt.str 1 | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | $display.message($readini(translation.dat, battle, TauntTakenAback), battle) }
    if (%taunt.effect = 5) { $set_chr_name($2) | $display.message($readini(translation.dat, battle, TauntBored), battle) }
    if (%taunt.effect = 6) { $restore_hp($2, $rand(1,10)) | $set_chr_name($2) |  $display.message($readini(translation.dat, battle, TauntLaugh), battle) | unset %taunt.hp }
    if (%taunt.effect = 7) { $restore_tp($2, 5) | $set_chr_name($2) | $display.message($readini(translation.dat, battle, TauntSmile), battle) }
    if (%taunt.effect = 8) { $display.message($readini(translation.dat, battle, TauntAngry), battle) 
      if ($readini($char($2), info, flag) != $null) { writeini $char($2) skills provoke.target $1 } 
    }
  }

  ; Decrease the action points
  $action.points($1, remove, 1)

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function sees if 
; a gem is given to the user
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gemconvert_check { 
  ; $1 = user
  ; $2 = target
  ; $3 = what was used (check for "weapon")
  ; $4 = weapon name
  if ($3 != weapon) { return }
  if (($readini($dbfile(weapons.db), $4, special) != gemconvert) && ($augment.check($1, GemConvert) = false)) { return }
  if ($readini($char($2), info, flag) != monster) { return }
  if ($readini($char($1), info, flag) != $null) { return }

  set %gem.list $readini($dbfile(items.db), items, gems)

  ; pick a random gem
  set %total.gems $numtok(%gem.list, 46)
  set %random.gem $rand(1,%total.gems)
  set %gem $gettok(%gem.list, %random.gem, 46)

  $display.message($readini(translation.dat, system, ConvertToGem),battle) 

  set %current.item.total $readini($char($1), Item_Amount, %gem) 
  if (%current.item.total = $null) { var %current.item.total 0 }
  inc %current.item.total 1 | writeini $char($1) Item_Amount %gem %current.item.total 

  var %monsters.converted $readini($char($1), stuff, MonstersToGems)
  if (%monsters.converted = $null) { var %monsters.converted 0 }
  inc %monsters.converted 1 | writeini $char($1) stuff MonstersToGems %monsters.converted

  $achievement_check($1, PrettyGemCollector)

  unset %gem.list | unset %total.gems | unset %random.gem | unset %gem
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomly pick the weather
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.weather.pick {
  if (%current.battlefield = Dead-End Hallway) { return }
  if (%current.battlefield = Dragon's Lair) { return }
  if ((weatherlock isin %battleconditions) || (weather-lock isin %battleconditions)) { return }

  set %weather.list $readini($dbfile(battlefields.db), %current.battlefield, weather)
  set %random $rand(1, $numtok(%weather.list,46))
  if (%random = $null) { var %random 1 }
  set %new.weather $gettok(%weather.list,%random,46)
  var %old.weather $readini($dbfile(battlefields.db), weather, current)
  if (%new.weather = $null) { set %new.weather calm }
  writeini $dbfile(battlefields.db) weather current %new.weather

  if (($1 = inbattle) && (%new.weather = %old.weather)) { unset %weather.list | unset %new.weather | return }

  var %weather.line $read($txtfile(weather_ $+ %new.weather $+ .txt))
  if (%weather.line = $null) {   $display.message(10The weather changes.  It is now %new.weather, battle) }
  else { $display.message(10 $+ %weather.line, battle) }


  unset %number.of.weather | unset %new.weather | unset %random | unset %weather.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Controls the phase of the
; moon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moonphase {
  if (%battle.type = torment) { return }
  if (%battle.type = cosmic) { return }

  set %moonphase $readini($dbfile(battlefields.db), moonphase, CurrentMoonPhase)
  if (%moonphase = $null) { var %moonphase New | remini $dbfile(battlefields.db) moonphase CurrentMoonTurn | writeini $dbfile(battlefields.db) moonphase currentMoonPhase New }

  var %moonphase.turn $readini($dbfile(battlefields.db), MoonPhase, CurrentMoonTurn)
  if (%moonphase.turn = $null) { var %moonphase.turn 0 }
  inc %moonphase.turn 1
  writeini $dbfile(battlefields.db) MoonPhase CurrentMoonTurn %moonphase.turn

  set %moonphase.turn.max $readini($dbfile(battlefields.db), moonphasetime, %moonphase)
  if (%moonphase.turn.max = $null) { var %moonphase.turn.max 1 }

  if (%moonphase.turn > %moonphase.turn.max) { $moonphase.increase | writeini $dbfile(battlefields.db) moonphase CurrentMoonPhase %moonphase }
  if (%moonphase = New) { $moonphase.bloodmoon }

  set %moon.phase %moonphase Moon

  unset %moonphase | unset %moonphase.turn.max 
}
moonphase.increase {
  writeini $dbfile(battlefields.db) moonphase currentMoonTurn 1

  if (%moonphase = Full) { set %moonphase New | return }
  if (%moonphase = New) { set %moonphase Crescent | return }
  if (%moonphase = Blood) { set %moonphase Crescent | return }
  if (%moonphase = Crescent) { set %moonphase Quarter | return }
  if (%moonphase = Quarter) { set %moonphase Gibbous | return }
  if (%moonphase = Gibbous) { set %moonphase Full | return }
}

moonphase.bloodmoon {
  var %bloodmoon.chance $readini($dbfile(battlefields.db), MoonPhaseTime, BloodMoonChance)
  if (%bloodmoon.chance = $null) { var %bloodmoon.chance 40 }

  var %curse.chance $rand(1,100)

  if (%curse.chance <= %bloodmoon.chance) { 
    set %bloodmoon on 
    set %moonphase Blood
    writeini battlestats.dat TempBattleInfo Event BloodMoon
    writeini $dbfile(battlefields.db) moonphase CurrentMoonPhase Blood
    writeini $dbfile(battlefields.db) moonphase currentMoonTurn 1
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Controls the time of day
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
timeofday {
  set %timeofday $readini($dbfile(battlefields.db), timeofday, CurrentTimeofDay)
  if (%timeofday = $null) { var %timeofday Morning | remini $dbfile(battlefields.db) timeofday CurrentTimeOfDayTurn | writeini $dbfile(battlefields.db) timeofday currentTimeOfDay Morning }

  if (%battle.type = ai) { return }

  var %timeofday.turn $readini($dbfile(battlefields.db), timeofday, CurrentTimeOfDayTurn)
  if (%timeofday.turn = $null) { var %timeofday.turn 0 }
  inc %timeofday.turn 1
  writeini $dbfile(battlefields.db) timeofday CurrentTimeOfDayTurn %timeofday.turn

  set %timeofday.turn.max $readini($dbfile(battlefields.db), timeofdaytime, %timeofday)
  if (%timeofday.turn.max = $null) { var %timeofday.turn.max 2 }

  if (%timeofday.turn > %timeofday.turn.max) { $timeofday.increase | writeini $dbfile(battlefields.db) timeofday Currenttimeofday %timeofday }

  unset %timeofday | unset %timeofday.turn.max 
}
timeofday.increase {
  writeini $dbfile(battlefields.db) timeofday currentTimeOfDayTurn 1

  if (%timeofday = Morning) { set %timeofday Noon | return }
  if (%timeofday = Noon) { set %timeofday Evening | return }
  if (%timeofday = Evening) { set %timeofday Night | return }
  if (%timeofday = Night) { 
    set %timeofday Morning 
    var %number.of.gamedays $readini(battlestats.dat, battle, GameDays)
    if (%number.of.gamedays = $null) { var %number.of.gamedays 1  }
    inc %number.of.gamedays 1
    writeini battlestats.dat battle GameDays %number.of.gamedays
    return
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if there's a
; battlefield curse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.battlefield.curse {
  if (%besieged = on) { return }
  if (%battle.type = DragonHunt) { return }
  if (%battle.type = torment) { return }
  if (%battle.type = cosmic) { return }
  if ($readini(battlestats.dat, battle, WinningStreak) <= 50) { return }
  var %timeofday $readini($dbfile(battlefields.db), TimeOfDay, CurrentTimeOfDay)
  if ((%timeofday = morning) || (%timeofday = noon)) { return }

  if ($readini(battlestats.dat, TempBattleInfo, Event) != $null) { remini battlestats.dat TempBattleInfo Event | return }
  set %curse.chance $rand(1,100)
  if (%battle.type = boss) { set %curse.chance $rand(1,80) }

  $divineblessing.check

  if (%curse.chance <= 15) { 
    $display.message($readini(translation.dat, Events, CurseNight), battle)
    writeini battlestats.dat TempBattleInfo Event CurseNight
    set %curse.night true
    ; curse everyone
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      writeini $char(%who.battle) status curse yes
      writeini $char(%who.battle) battle tp 0
      inc %battletxt.current.line 1  
    }
  }

  unset %curse.chance
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if there's a
; battlefield limitation.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
battlefield.limitations {
  if ($return_winningstreak <= 10) {
    if ((((%battle.type != dungeon) && (%battle.type != torment) && (%battle.type != cosmic) && (%portal.bonus != true)))) { return }
  }

  set %battleconditions $readini($dbfile(battlefields.db), %current.battlefield, limitations)
  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { $display.message($readini(translation.dat, Events, AncientMeleeOnlySeal), battle)  }
  if ((no-skill isin %battleconditions) || (no-skills isin %battleconditions)) { $display.message($readini(translation.dat, Events, AncientNoSkillsSeal), battle)  }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { $display.message($readini(translation.dat, Events, AncientNoItemsSeal), battle)  }
  if ((no-ignition isin %battleconditions) || (no-ignitions isin %battleconditions)) { $display.message($readini(translation.dat, Events, AncientNoIgnitionsSeal), battle)  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks to see
; if monsters go first in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.surpriseattack {
  if (%besieged = on) { return }
  if (%battle.type = Torment) { return }
  if (%battle.type = cosmic) { return }
  if (%battle.type = DragonHunt) { return }
  if (%savethepresident = on) { return }
  if (%battle.type = dungeon) { return }
  if ($readini(battlestats.dat, TempBattleInfo, SurpriseAttack) != $null) { remini battlestats.dat TempBattleInfo SurpriseAttack | return } 

  set %surpriseattack.chance $rand(1,105)

  $backguard.check

  if (%surpriseattack.chance >= 88) { set %surpriseattack on | writeini battlestats.dat TempBattleInfo SurpriseAttack true }
  if (%surpriseattack = on) { $display.message($readini(translation.dat, Events, SurpriseAttack), battle)  }
  unset %surpriseattack.chance
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks
; to see if players go first
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.playersgofirst {
  if (%battle.type = torment) { return }
  if (%battle.type = cosmic) { return }
  if (%battle.type = DragonHunt) { return }
  if (%surpriseattack = on) { return }
  if (%battle.type = dungeon) { return }
  set %playersfirst.chance $rand(1,100)

  if (%supplyrun = on) { var %playersfirst.chance 1 }

  if (%playersfirst.chance <= 8) { set %playersgofirst on }
  if (%playersgofirst = on) { 
    $display.message($readini(translation.dat, Events, PlayersGoFirst), battle) 
  }
  unset %playersfirst.chance
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a random NPC 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.battlefield.ally {
  if ((no-npc isin %battleconditions) || (no-npcs isin %battleconditions)) { return }
  if (%battle.type = manual) { return }
  if (%battle.type = orbfountain) { return }
  if (%battle.type = boss) { return }
  if (%battle.type = DragonHunt) { return }
  if (%battle.type = torment) { return }
  if (%battle.type = cosmic) { return }
  if (%battle.type = defendoutpost) { 
    if (%number.of.players < 5) { $generate_allied_troop }
    return
  }

  var %npc.chance $rand(1,100) 
  var %losing.streak $readini(battlestats.dat, battle, LosingStreak)
  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)

  if (%battle.type = ai) { var %npc.chance 1
    var %battleplayers $readini($txtfile(battle2.txt), BattleInfo, Players)
    if (%battleplayers = $null) { var %battleplayers 0 }
    inc %battleplayers 1 
    writeini $txtfile(battle2.txt) BattleInfo Players %battleplayers 
  }

  if (%losing.streak >= 2) { var %npc.chance 1 }
  if ((%winning.streak >= 30) && (%number.of.players = 1)) { var %npc.chance $rand(1,45) }

  if (%npc.chance <= 10) { 
    $get_npc_list
    var %npcs.total $numtok(%npc.list,46)
    if ((%npcs.total = 0) || (%npc.list = $null)) { 
      $display.message(4Error: There are no NPCs in the NPC folder.. Have the bot owner check to make sure there are npcs there!,battle) 
      return 
    }

    set %value 1
    while (%value <= 1) {
      if (%npc.list = $null) { inc %value 1 } 
      set %npcs.total $numtok(%npc.list,46)
      set %random.npc $rand(1, %npcs.total) 
      set %npc.name $gettok(%npc.list,%random.npc,46)

      if (%npcs.total = 0) { inc %value 1 }

      if ($isfile($char(%npc.name)) = $false) { 
        .copy -o $npc(%npc.name) $char(%npc.name) | set %curbat $readini($txtfile(battle2.txt), Battle, List) | %curbat = $addtok(%curbat,%npc.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat 
        $set_chr_name(%npc.name) 
        writeini $txtfile(battle2.txt) battleinfo npcs 1

        if (%battle.type != ai) { 
          $display.message(4 $+ %real.name has entered the battle to help the forces of good!,battle)
          $display.message(12 $+ %real.name  $+ $readini($char(%npc.name), descriptions, char),battle)
        }

        if (%battle.type = ai) { set %ai.npc.name %real.name | writeini $txtfile(1vs1bet.txt) money npcfile %npc.name }

        set %npc.to.remove $findtok(%npc.list, %npc.name, 46)
        set %npc.list $deltok(%npc.list,%npc.to.remove,46)
        write $txtfile(battle.txt) %npc.name
        $boost_monster_stats(%npc.name)
        $fulls(%npc.name) | var %battlenpcs $readini($txtfile(battle2.txt), BattleInfo, npcs) | inc %battlenpcs 1 | writeini $txtfile(battle2.txt) BattleInfo npcs %battlenpcs
        inc %value 1
      }
      else {  
        set %npc.to.remove $findtok(%npc.list, %npc.name, 46)
        set %npc.list $deltok(%npc.list,%npc.to.remove,46)
        if (%npc.list = $null) { inc %value 100 }
        else {  dec %value 1 }
      }
    }
  }
  else { return }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This checks for Death
; Conditions on monsters.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
death.conditions.check {
  ; $1 = person
  ; $2 = melee, item, tech, renkei, magic, magiceffect, status

  if ($readini($char($1), info, flag) = $null) { return }

  ; Check for death conditions.  If the death condition isn't met, turn on revive.
  var %death.conditions $readini($char($1), info, DeathConditions)
  if (%death.conditions = $null) { return }

  if ($istok(%death.conditions,$2,46) = $false) { writeini $char($1) status revive yes }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Revives a character with
; half health
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.revive {
  ; $1 = player to revive
  ; $2 = revive amount (50% if missing)

  var %character.revive.percent $2 
  if (%character.revive.percent = $null) { var %character.revive.percent .50 }

  var %max.hp $readini($char($1), basestats, hp)
  set %revive.current.hp $round($calc(%max.hp * %character.revive.percent),0)
  if (%revive.current.hp <= 0) { set %revive.current.hp 1 }
  writeini $char($1) battle hp %revive.current.hp
  writeini $char($1) battle status normal
  writeini $char($1) status revive no
  $set_chr_name($1)

  writeini $txtfile(battle2.txt) style $1 0
  unset %revive.current.hp

  var %number.of.revives $readini($char($1), stuff, RevivedTimes)
  if (%number.of.revives = $null) { var %number.of.revives 0 }
  inc %number.of.revives 1
  writeini $char($1) stuff RevivedTimes %number.of.revives
  $achievement_check($1, Can'tKeepAGoodManDown)

  writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no
  writeini $char($1) Status HeavyPoison no | writeini $char($1) status HeavyPoison no | writeini $char($1) Status curse no 
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 1 | writeini $char($1) status intimidate no
  writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
  writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no
  writeini $char($1) status boosted no  | writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1
  writeini $char($1) status zombieregenerating no | writeini $char($1) status charmer noOneThatIKnow | writeini $char($1) status charm.timer 1 | writeini $char($1) status charmed no 
  writeini $char($1) status charm no | writeini $char($1) status bored no | writeini $char($1) status bored.timer 1 | writeini $char($1) status confuse no 
  writeini $char($1) status confuse.timer 1 | writeini $char($1) status defensedown no | writeini $char($1) status defensedown.timer 0 | writeini $char($1) status strengthdown no 
  writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown no | writeini $char($1) status intdown.timer 1
  writeini $char($1) status defenseup no | writeini $char($1) status defenseup.timer 0  | writeini $char($1) status speedup no | writeini $char($1) status speedup.timer 0
  writeini $char($1) status flying no | writeini $char($1) status doll no | writeini $char($1) status doll.timer 0

  return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is the automatic-revival
; function.. it's named after the 
; Gold Orbs in Devil May Cry
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
goldorb_check {
  ; $1 = person
  ; $2 = type of attack

  if ($2 = weapon) { $death.conditions.check($1, melee) }
  if ($2 != weapon) { $death.conditions.check($1, $2) }

  if ($readini($char($1), status, revive) = yes) {

    $character.revive($1)

    if ($readini($char($1), descriptions, revive) != $null) {  var %revive.message 7 $+ %real.name  $+ $readini($char($1), descriptions, revive) }
    if ($readini($char($1), descriptions, revive) = $null) { var %revive.message $readini(translation.dat, battle, GoldOrbUsed) }

    $display.message.delay(%revive.message, battle, 1) 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks for
; the guardian style
; and reduces damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guardian_style_check {
  if ($augment.check($2, IgnoreGuardian) = true) { return }

  set %current.playerstyle $readini($char($1), styles, equipped)
  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.

  if ($person_in_mech($1) = true) { set %current.playerstyle Guardian }

  if (%current.playerstyle = Guardian) { 
    set %current.playerstyle.level $readini($char($1), styles, Guardian)

    if ($person_in_mech($1) = true) { set %current.playerstyle.level 12 }

    if ((%battle.type = dungeon) || (%portal.bonus = true)) {
      if ((%current.playerstyle.level > 5) && ($person_in_mech($1) != true)) { set %current.playerstyle.level 5 } 
    }

    var %block.value $calc(%current.playerstyle.level / 15.5)
    if (%block.value > .60) { var %block.value .60 }

    if ($person_in_mech($1) = true) { inc %block.value .10 }

    var %amount.to.block $round($calc(%attack.damage * %block.value),0)
    dec %attack.damage %amount.to.block
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a demon portal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_demonportal {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  set %monster.name Demon_Portal | set %monster.realname Demon Portal

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info BattleStats ignoreHP
  writeini $char(%monster.name) info ai_type portal
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its

  var %base.hp.tp $calc(7 * %current.battlestreak)
  if (%portal.bonus = true) { set %current.battlestreak 400 }

  if (%current.battlestreak <= 100) {  writeini $char(%monster.name) basestats hp $rand(300,600) }
  if ((%current.battlestreak > 100) && (%current.battlestreak <= 300)) {  writeini $char(%monster.name) basestats hp $rand(600,1000) }
  if ((%current.battlestreak > 300) && (%current.battlestreak <= 500)) {  writeini $char(%monster.name) basestats hp $rand(1000,2000) }
  if ((%current.battlestreak > 500) && (%current.battlestreak <= 1000)) {  writeini $char(%monster.name) basestats hp $rand(3000,5000) }
  if (%current.battlestreak > 500) {   writeini $char(%monster.name) basestats hp $rand(5000,7000) }

  writeini $char(%monster.name) basestats tp 0
  writeini $char(%monster.name) basestats str 0
  writeini $char(%monster.name) basestats def $round($calc(5 * ($return_winningstreak - 10)),0)
  writeini $char(%monster.name) basestats int 0
  writeini $char(%monster.name) basestats spd 0

  writeini $char(%monster.name) weapons equipped none
  writeini $char(%monster.name) weapons none %current.battlestreak
  remini $char(%monster.name) weapons none

  writeini $char(%monster.name) skills manawall.on on
  writeini $char(%monster.name) skills royalguard.on on
  writeini $char(%monster.name) skills resist-charm 100
  writeini $char(%monster.name) skills resist-poison 100
  writeini $char(%monster.name) skills resist-confuse 100
  writeini $char(%monster.name) skills resist-stun 100
  writeini $char(%monster.name) skills resist-bored 100
  writeini $char(%monster.name) skills resist-blind 100
  writeini $char(%monster.name) skills Resist-Paralysis 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian $rand(6,10)

  if (%current.battlestreak > 300) {
    var %reflect.chance $rand(1,100)
    if (%reflect.chance <= 50) { writeini $char(%monster.name) status reflect yes | writeini $char(%monster.name) status reflect.timer 1 }
  }

  $fulls(%monster.name) 

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  if (%mode.gauntlet != on) { set %portal.multiple.wave on }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear dead monsters
; for portals.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portal.clear.monsters {
  set %monsters.alive 0 | set %old.monster.total $readini($txtfile(battle2.txt), battleinfo, monsters)

  var %waves.battletxt.lines $lines($txtfile(battle.txt)) | var %waves.battletxt.current.line 1 
  while (%waves.battletxt.current.line <= %waves.battletxt.lines) { 
    var %waves.who.battle $read -l $+ %waves.battletxt.current.line $txtfile(battle.txt)
    var %waves.flag $readini($char(%waves.who.battle), info, flag)
    if (%waves.flag != monster) {  write $txtfile(battle3.txt) %waves.who.battle | %waves.battle.list = $addtok(%waves.battle.list,%waves.who.battle,46)  }
    if ((%waves.flag = monster) && ($readini($char(%waves.who.battle), battle, hp) > 0)) { inc %monsters.alive 1 | write $txtfile(battle3.txt) %waves.who.battle | %waves.battle.list = $addtok(%waves.battle.list,%waves.who.battle,46)  }

    inc %waves.battletxt.current.line 1
  }

  writeini $txtfile(battle2.txt) battle list %waves.battle.list
  unset %waves.battle.list

  ; Erase the old battle.txt, erase the bat list out of battle2.txt.
  .remove $txtfile(battle.txt)
  .rename $txtfile(battle3.txt) $txtfile(battle.txt)

  ; Set the # of monsters
  writeini $txtfile(battle2.txt) battleinfo monsters %monsters.alive

  if (%monsters.alive < %old.monster.total) {
    ; Clear out the char folder of dead monsters
    .echo -q $findfile( $char_path , *.char, 0 , 0, clear_dead_monsters $1-)
  }

  var %turn.lines $lines($txtfile(battle.txt)) | var %current.turn.line 0
  while (%current.turn.line <= %turn.lines) { 
    var %turn.person $read -l $+ %current.turn.line $txtfile(battle.txt)
    if (%turn.person = %who) { set %line %current.turn.line | inc %current.turn.line }
    else { inc %current.turn.line }
  }

  unset %monsters.alive | unset %old.monster.total
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Summon a monster
; For portals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portal.summon.monster {
  ; get a random monster and summon the monster to the battlelfield

  set %number.of.monsters.needed 1
  set %multiple.wave.bonus yes

  var %bonus.orbs $readini($txtfile(battle2.txt), battleinfo, portalbonus)
  if (%bonus.orbs = $null) { var %bonus.orbs 0 }
  inc %bonus.orbs 10
  writeini $txtfile(battle2.txt) battleinfo portalbonus %bonus.orbs
  $display.message($readini(translation.dat, system,PortalReinforcements),battle) 
  set %number.of.monsters.needed 1
  $generate_monster(monster, portal)

  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for applying
; status effects on targets.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inflict_status {
  ; $1 = user
  ; $2 = target
  ; $3 = status type
  ; $4 = optional flag

  if (($readini($char($2), status, ethereal) = yes) && ($readini($dbfile(techniques.db), $4, magic) != yes)) { return }
  if ($person_in_mech($2) = true) { return }

  if (%guard.message != $null) { return }

  if ($3 = random) { 
    var %random.status.type $rand(1,17)
    if (%random.status.type = 1) { set %status.type poison | var %status.grammar poisoned }
    if (%random.status.type = 2) { set %status.type stop | var %status.grammar frozen in time }
    if (%random.status.type = 3) { set %status.type blind | var %status.grammar blinded }
    if (%random.status.type = 4) { set %status.type virus | var %status.grammar inflicted with a virus }
    if (%random.status.type = 5) { set %status.type amnesia | var %status.grammar inflicted with amnesia }
    if (%random.status.type = 6) { set %status.type paralysis | var %status.grammar paralyzed }
    if (%random.status.type = 7) { set %status.type zombie | var %status.grammar a zombie }
    if (%random.status.type = 8) { set %status.type slow | var %status.grammar slowed }
    if (%random.status.type = 9) { set %status.type stun | var %status.grammar stunned }
    if (%random.status.type = 10) { set %status.type intimidate | var %status.grammar intimidated }
    if (%random.status.type = 11) { set %status.type defensedown | var %status.grammar inflicted with defense down }
    if (%random.status.type = 12) { set %status.type strengthdown | var %status.grammar inflicted with strength down }
    if (%random.status.type = 13) { set %status.type intdown | var %status.grammar inflicted with int down }
    if (%random.status.type = 14) { set %status.type petrify | var %status.grammar petrified }
    if (%random.status.type = 15) { set %status.type bored | var %status.grammar bored of the battle  }
    if (%random.status.type = 16) { set %status.type confuse | var %status.grammar confused  }
    if (%random.status.type = 17) { set %status.type sleep | var %status.grammar asleep  }
    if (%random.status.type = 18) { set %status.type terrify | var %status.grammar terrified }
  }

  if ($3 = stop) { set %status.type stop | var %status.grammar frozen in time }
  if ($3 = poison) { set %status.type poison | var %status.grammar poisoned }
  if ($3 = silence) { set %status.type silence | var %status.grammar silenced }
  if ($3 = blind) { set %status.type blind | var %status.grammar blind }
  if ($3 = drunk) { set %status.type drunk | var %status.grammar drunk }
  if ($3 = virus) { set %status.type virus | var %status.grammar inflicted with a virus }
  if ($3 = amnesia) { set %status.type amnesia | var %status.grammar inflicted with amnesia }
  if ($3 = paralysis) { set %status.type paralysis | var %status.grammar paralyzed }
  if ($3 = zombie) { set %status.type zombie | var %status.grammar a zombie }
  if ($3 = doll) { set %status.type doll | var %status.grammar a small doll }
  if ($3 = slow) { set %status.type slow | var %status.grammar slowed }
  if ($3 = stun) { set %status.type stun | var %status.grammar stunned }
  if ($3 = curse) { set %status.type curse | var %status.grammar cursed }
  if ($3 = charm) { set %status.type charm | var %status.grammar charmed }
  if ($3 = intimidate) { set %status.type intimidate | var %status.grammar intimidated }
  if ($3 = defensedown) { set %status.type defensedown | var %status.grammar inflicted with defense down }
  if ($3 = strengthdown) { set %status.type strengthdown | var %status.grammar inflicted with strength down }
  if ($3 = intdown) { set %status.type intdown | var %status.grammar inflicted with int down }
  if ($3 = petrify) { set %status.type petrify  | var %status.grammar petrified }
  if ($3 = bored) { set %status.type bored | var %status.grammar bored of the battle  }
  if ($3 = confuse) { set %status.type confuse  | var %status.grammar confused }
  if ($3 = removeboost) { set %status.type removeboost | var %status.grammar no longer boosted }
  if ($3 = defenseup) { set %status.type defenseup | var %status.grammar gains defense up }
  if ($3 = speedup) { set %status.type speedup | var %status.grammar faster }
  if ($3 = sleep) { set %status.type sleep  | var %status.grammar asleep }
  if ($3 = terrify) { set %status.type terrify | var %status.grammar terrified }
  if ($3 = freezing) { set %status.type frozen | var %status.grammar freezing }
  if ($3 = heavy) { set %status.type heavy | var %status.grammar weighed down }

  if (%status.grammar = $null) { echo -a 4Invalid status type: $3 | return }

  var %chance $rand(1,140) | $set_chr_name($1) 
  if ($readini($char($2), skills, utsusemi.on) = on) { set %chance 0 } 

  if ($3 = heavy) { var %chance 255 }

  if ($4 != IgnoreResistance) { 
    ; Check for resistance to that status type.
    set %resist.have resist- $+ %status.type
    set %resist.skill $readini($char($2), skills, %resist.have)
    if (%resist.skill = $null) { set %resist.skill 0 }

    set %current.style $readini($char($1), styles, equipped) 
    if (%current.style = Doppelganger) {
      if (($readini($char($2), info, clone) = yes) || ($readini($char($1), info, clone) = yes)) {
        set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
        set %decrease.skill.amount $calc(5 * %current.playerstyle.level)
        dec %resist.skill %decrease.skill.amount
        unset %current.playerstyle.level | unset %decrease.skill.amount
      }

    }
    unset %current.style 

    if ((%resist.skill >= 100) && (%battle.type = dungeon)) { 
      if ($readini($char($2), info, flag) != monster) { set %resist.skill 50 }
    }

    $ribbon.accessory.check($2)
  }

  var %enfeeble.timer 0

  if ($augment.check($1, EnhanceEnfeeble) = true) { 
    dec %enfeeble.timer %augment.strength
    inc %chance $calc(2 * %augment.strength)
  }

  if (%status.type = charm) {
    if ($readini($char($2), status, zombie) != no) { set %resist.skill 100 }
    if ($readini($char($2), monster, type) = undead) { set %resist.skill 100 }
  }

  if ((%resist.skill <= 100) || (%resist.skill = $null)) {
    if ((%resist.skill != $null) && (%resist.skill > 0)) { dec %chance %resist.skill }
  }

  if (%resist.skill >= 100) { $set_chr_name($2) 
    if (%statusmessage.display != $null) { set %statusmessage.display %statusmessage.display :: %real.name is immune to the %status.type status! }
    if (%statusmessage.display = $null) { set %statusmessage.display 4 $+ %real.name is immune to the %status.type status! }
  }
  if ((%resist.skill < 100) || (%resist.skill = $null)) {

    if (%status.type = removeboost) { 
      if ($readini($char($2), status, ignition.on) != on) { var %chance 0 }
      if ($readini($char($2), status, ignition.on) = on) { var %chance 100 | var %ignition.name $readini($char($2), status, ignition.name) | $revert($2,%ignition.name) }
    }

    if (%chance <= 0) { $set_chr_name($2) 
      if (%statusmessage.display != $null) { set %statusmessage.display %statusmessage.display :: %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect! }
      if (%statusmessage.display = $null) { set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect! }
    }
    if ((%chance > 0) && (%chance <= 45)) { $set_chr_name($1)
      if (%statusmessage.display != $null) { set %statusmessage.display %statusmessage.display :: $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect has failed }
      if (%statusmessage.display = $null) {  set %statusmessage.display 4 $+ %real.name $+ 's $lower(%status.type) status effect has failed against $set_chr_name($2) %real.name $+ ! }
    }
    if (%chance > 45) { $set_chr_name($2) 
      if (%statusmessage.display != $null) {  set %statusmessage.display %statusmessage.display :: $set_chr_name($2) %real.name is now %status.grammar $+ ! } 
      if (%statusmessage.display = $null) {   $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is now %status.grammar $+ ! }

      if (%status.type = poison) && ($readini($char($2), status, poison) = yes) { writeini $char($2) status poison no | writeini $char($2) status HeavyPoison yes | writeini $char($2) status poison.timer %enfeeble.timer }
      if (%status.type = poison) && ($readini($char($2), status, HeavyPoison) != yes) { writeini $char($2) status poison yes | writeini $char($2) status poison.timer %enfeeble.timer }
      if (%status.type = charm) { writeini $char($2) status charmed yes | writeini $char($2) status charmer $1 | writeini $char($2) status charm.timer %enfeeble.timer }
      if (%status.type = curse) { writeini $char($2) Status %status.type yes | writeini $char($2) battle tp 0 }
      if (%status.type = petrify) { writeini $char($2) status petrified yes }
      if ((%status.type = slow) && ($readini($char($2), status, speedup) != no)) { writeini $char($2) status speedup no }

      if ((((%status.type != poison) && (%status.type != charm) && (%status.type != petrify) && (%status.type != removeboost)))) { writeini $char($2) Status %status.type yes | writeini $char($2) status %status.type $+ .timer %enfeeble.timer   }

    }
  }

  ; If a monster, increase the resistance.
  if ($readini($char($2), info, flag) = monster) {
    if (%resist.skill = $null) { set %resist.skill 45 }
    else { inc %resist.skill 45 }
    writeini $char($2) skills %resist.have %resist.skill
  }
  unset %resist.have | unset %chance
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is for the selfstatus
; option for weapons/techs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
self.inflict_status {
  ; $1 = person
  ; $2 = weapon/technique name
  ; $3 = type (weapon / technique)

  if (%inflict.user = $null) { set %inflict.user $1 }
  if (%inflict.techwpn = $null) { set %inflict.techwpn $2 }

  if ($3 = weapon) {  set %self.status.type $readini($dbfile(weapons.db) , %inflict.techwpn , selfstatus) }
  if ($3 = tech) {  set %self.status.type $readini($dbfile(techniques.db) , %inflict.techwpn , selfstatus) }


  if (%self.status.type = random) { 
    var %random.status.type $rand(1,16)
    if (%random.status.type = 1) { set %self.status.type poison }
    if (%random.status.type = 2) { set %self.status.type stop  }
    if (%random.status.type = 3) { set %self.status.type blind }
    if (%random.status.type = 4) { set %self.status.type virus  }
    if (%random.status.type = 5) { set %self.status.type amnesia  }
    if (%random.status.type = 6) { set %self.status.type paralysis }
    if (%random.status.type = 7) { set %self.status.type zombie  }
    if (%random.status.type = 8) { set %self.status.type slow }
    if (%random.status.type = 9) { set %self.status.type stun  }
    if (%random.status.type = 10) { set %self.status.type intimidate }
    if (%random.status.type = 11) { set %self.status.type defensedown  }
    if (%random.status.type = 12) { set %self.status.type strengthdown  }
    if (%random.status.type = 13) { set %self.status.type intdown  }
    if (%random.status.type = 14) { set %self.status.type petrify  }
    if (%random.status.type = 15) { set %self.status.type bored  }
    if (%random.status.type = 16) { set %self.status.type confuse   }
  }


  if (%self.status.type = $null) { unset %self.status.type | unset %inflict.user | unset %inflict.techwpn | return }
  if (%self.status.type = none) { unset %self.status.type | unset %inflict.user | unset %inflict.techwpn | return }

  unset %statusmessage.display

  if (%self.status.type != $null) { 
    set %number.of.statuseffects $numtok(%self.status.type, 46) 
    set %status.types.list %self.status.type
    if (%number.of.statuseffects = 1) { $do.self.inflict.status | unset %number.of.statuseffects | unset %status.type.list }
    if (%number.of.statuseffects > 1) {
      var %status.value 1
      while (%status.value <= %number.of.statuseffects) { 
        set %self.status.type $gettok(%status.types.list, %status.value, 46)
        $do.self.inflict.status
        inc %status.value 1
      }  
      unset %number.of.statuseffects | unset %current.status.effect
    }
  }
  unset %status.types.list |  unset %self.status.type | unset %inflict.user | unset %inflict.techwpn
}

do.self.inflict.status {
  if (%self.status.type = $null) { echo -a 4Null status type! Invalid. | return }

  if (%self.status.type = charm) { unset %self.status.type | unset %inflict.user | unset %inflict.techwpn | return }
  if (%self.status.type = stop) { set %status.type stop | var %status.grammar frozen in time }
  if (%self.status.type = poison) { set %status.type poison | var %status.grammar poisoned }
  if (%self.status.type = silence) { set %status.type silence | var %status.grammar silenced }
  if (%self.status.type = blind) { set %status.type blind | var %status.grammar blind }
  if (%self.status.type = virus) { set %status.type virus | var %status.grammar inflicted with a virus }
  if (%self.status.type = amnesia) { set %status.type amnesia | var %status.grammar inflicted with amnesia }
  if (%self.status.type = paralysis) { set %status.type paralysis | var %status.grammar paralyzed }
  if (%self.status.type = zombie) { set %status.type zombie | var %status.grammar a zombie }
  if (%self.status.type = doll) { set %status.type doll | var %status.grammar a small doll }
  if (%self.status.type = slow) { set %status.type slow | var %status.grammar slowed }
  if (%self.status.type = stun) { set %status.type stun | var %status.grammar stunned }
  if (%self.status.type = curse) { set %status.type curse | var %status.grammar cursed }
  if (%self.status.type = intimidate) { set %status.type intimidate | var %status.grammar intimidated }
  if (%self.status.type = defensedown) { set %status.type defensedown | var %status.grammar inflicted with defense down }
  if (%self.status.type = strengthdown) { set %status.type strengthdown | var %status.grammar inflicted with strength down }
  if (%self.status.type = intdown) { set %status.type intdown | var %status.grammar inflicted with int down }
  if (%self.status.type = petrify) { set %status.type petrify  | var %status.grammar petrified }
  if (%self.status.type = bored) { set %status.type bored | var %status.grammar bored of the battle  }
  if (%self.status.type = confuse) { set %status.type confuse  | var %status.grammar confused }
  if (%self.status.type = terrify) { set %status.type terrify | var %status.grammar terrified }

  if (%status.grammar = $null) { echo -a 4Invalid status type: %self.status.type | return }

  if (%statusmessage.display != $null) {  set %statusmessage.display %statusmessage.display and %status.grammar $+ ! } 
  if (%statusmessage.display = $null) {   $set_chr_name(%inflict.user) | set %statusmessage.display 4 $+ %real.name is now %status.grammar $+ ! }

  if (%status.type != paralysis) {  var %enfeeble.timer $rand(0,1) }
  if (%status.type = paralysis) {  var %enfeeble.timer $rand(1,2) }

  if (%status.type = poison) && ($readini($char(%inflict.user), status, poison) = yes) { writeini $char(%inflict.user) status poison no | writeini $char(%inflict.user) status HeavyPoison yes | writeini $char(%inflict.user) status poison.timer %enfeeble.timer }
  if (%status.type = poison) && ($readini($char(%inflict.user), status, HeavyPoison) != yes) { writeini $char(%inflict.user) status poison yes | writeini $char(%inflict.user) status poison.timer %enfeeble.timer }
  if (%status.type = curse) { writeini $char(%inflict.user) Status %status.type yes | writeini $char(%inflict.user) battle tp 0 }
  if (%status.type = petrify) { writeini $char(%inflict.user) status petrified yes }

  if (((%status.type != poison) && (%status.type != charm) && (%status.type != petrify))) { writeini $char(%inflict.user) Status %status.type yes | writeini $char(%inflict.user) status %status.type $+ .timer %enfeeble.timer   }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for ribbon or other
; accessories that make
; people immune to statuses.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ribbon.accessory.check { 
  if ($accessory.check($1, BlockAllStatus) = true) {
    if (%accessory.amount = 0) { var %accessory.amount 100 }
    inc %resist.skill %accessory.amount
  }
  unset %accessory.amount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for stat-down effects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
defense_down_check {
  if ($readini($char($1), status, defensedown) = yes) {
    %enemy.defense = $round($calc(%enemy.defense / 4),0)
  }
}

strength_down_check {
  if ($readini($char($1), status, strengthdown) = yes) {
    %base.stat = $round($calc(%base.stat / 4),0)
  }
}

int_down_check {
  if ($readini($char($1), status, intdown) = yes) {
    %base.stat = $round($calc(%base.stat / 4),0)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for stat-up effects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
defense_up_check {
  if ($readini($char($1), status, defenseup) = yes) {
    %enemy.defense = $round($calc(%enemy.defense * 2),0)
  }
}

speed_up_check {
  if ($readini($char($1), status, speedup) = yes) {
    %battle.speed = $round($calc(%battle.speed * 2),0)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Figure out how many monsters
; To add based on streak #.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
winningstreak.addmonster.amount {
  if (%battle.type = torment) { return }
  if (%battle.type = cosmic) { return }
  if (%battle.type = orbfountain) { return }
  if (%battle.type = demonwall) { return }
  if (%battle.type = assault) { return }
  if (%battle.type = warmachine) { return }
  if (%battle.type = doppelganger) { return }
  if (%battle.type = monster) { 
    ; If the players have been winning a lot then we need to make things more interesting/difficult for them.
    if ((%winning.streak >= 50) && (%winning.streak <= 300)) { inc %number.of.monsters.needed 1 }
    if ((%winning.streak > 300) && (%winning.streak <= 500)) { inc %number.of.monsters.needed 2 }
    if ((%winning.streak > 500) && (%winning.streak <= 1000)) { inc %number.of.monsters.needed 3 }
    if ((%winning.streak > 1000) && (%winning.streak <= 5000)) { inc %number.of.monsters.needed 4 }
    if (%winning.streak > 5000) { inc %number.of.monsters.needed 5 }

    if (%bloodmoon = on) { inc %number.of.monsters.needed 2 }
  }

  if (%battle.type = boss) {
    if ((%winning.streak > 500) && (%winning.streak <= 800)) { inc %number.of.monsters.needed 1 }
    if ((%winning.streak > 800) && (%winning.streak <= 2000)) { inc %number.of.monsters.needed 2 }
    if (%winning.streak > 2000) { inc %number.of.monsters.needed 3 }
  }

  if (($return_winningstreak <= 10) && (%number.of.monsters > 3)) { set %number.of.monsters.needed 3 }

  if ((%supplyrun = on) && ($return_winningstreak > 500)) {  set %number.of.monsters.needed 1  }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if a monster
; would one-shot a player
; on the first round. If so,
; nerf the damage.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
first_round_dmg_chk {
  if (%battle.type = defendoutpost) { return }
  if (%battle.type = assault) { return }
  if (%portal.bonus = true) { return } 

  if ($return.systemsetting(EnableFirstRoundProtection) = false) { return }
  if ((%battle.type = dungeon) && (%true.turn > 1)) { return }



  if ((%current.turn = 1) || (%first.round.protection = yes)) { 
    if (%attack.damage <= 5) { return }

    if ($readini($char($1), info, flag) = monster) {

      if (%battle.type = torment) { 
        var %monster.level $get.level($1)
        var %player.level $get.level($2)
        if (%monster.level > $calc(100 + %player.level)) { return }
      }

      if (($readini($char($2), info, flag) = $null) || ($2 = alliedforces_president)) {
        var %max.health $readini($char($2), basestats, hp) 

        if (%attack.damage >= %max.health) {
          set %attack.damage $round($calc(%max.health * .05),0)
        }
        if ((%weapon.howmany.hits > 1) && (%attack.damage < %max.health)) { 
          if (%attack.damage > 2000) { set %attack.damage $round($calc(%max.health * .05),0) }
        }
        if ((%weapon.howmany.hits > 1) && (%attack.damage >= %max.health)) { 
          set %attack.damage $round($calc(%max.health * .05),0) 
        }
      }
    }
  }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; dodges an attack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trickster_dodge_check {
  ; $1 = person dodging
  ; $2 = person attacking

  if ($2 = $1) { return }
  if ($person_in_mech($1) = true) { return }

  ; Check to see if the person dodging can't dodge due to status effects
  if ($statuseffect.check($1, sleep) = yes) { return }
  if ($statuseffect.check($1, stun) = yes) { return }
  if ($statuseffect.check($1, paralysis) = yes) { return }
  if ($statuseffect.check($1, petrified) = yes) { return }

  ; If the attacker has true strike on then the person can't dodge
  if ($readini($char($2), skills, truestrike.on) = on) { return }

  ; Monsters that are in darkness can't miss
  if ((%battle.rage.darkness = on) && ($readini($char($2), info, flag) = monster)) { return }


  ; Get the status of the person dodging
  var %current.playerstyle $return.playerstyle($1)
  var %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (((%current.playerstyle != Trickster) && ($augment.check($1, EnhanceDodge) = false) && ($readini($char($1), skills, thirdeye.on) != on))) { unset %current.playerstyle | unset %current.playerstyle.level | return }
  if (%guard.message != $null) { return }

  if (%battle.type = cosmic) { var %dodge.chance $rand(1,250) } 
  else { var %dodge.chance $rand(1,110) }

  if ($augment.check($1, EnhanceDodge) = true) { inc %current.playerstyle.level $calc(20* %augment.strength) | dec %dodge.chance 5
    if (%current.playerstyle.level > 65) { set %current.playerstyle.level 65 }
  }

  var %attacker.speed $current.spd($2) 
  inc %attacker.speed $armor.stat($2, spd)
  if ($skill.speed.status($2) = on) { inc %attacker.speed $skill.speed.calculate($2) }

  var %target.speed $current.spd($1)
  inc %target.speed $armor.stat($1, spd)
  if ($skill.speed.status($1) = on) { inc %target.speed $skill.speed.calculate($1) }

  if (%attacker.speed > %target.speed) { inc %dodge.chance $rand(5,10) } 

  if ((%battle.type = torment) && ($readini($char($1), info, flag) = $null)) { inc %dodge.chance $rand(10,15) }
  if ((%battle.type = cosmic) && ($readini($char($1), info, flag) = $null)) { inc %dodge.chance $rand(10,15) }
  if ((%battle.type = dungeon) && ($readini($char($1), info, flag) = $null)) { inc %dodge.chance $rand(5,10) }

  if (($readini($char($1), skills, thirdeye.on) = on) && ($3 = physical)) {
    var %thirdeye.turns $readini($char($1), status, thirdeye.turn)
    if (%thirdeye.turns = $null) { var %thirdeye.turns 1 }
    dec %thirdeye.turns 1
    writeini $char($1) status thirdeye.turn %thirdeye.turns
    if (%thirdeye.turns <= 0) { writeini $char($1) skills thirdeye.on off | writeini $char($1) status thirdeye.turn 0 }
    var %dodge.chance 0
    var %third.eye.dodge yes
  }

  if (%current.playerstyle.level = $null) { var %current.playerstyle.level 0 }

  if (%dodge.chance <= %current.playerstyle.level) {
    set %attack.damage 0 | $set_chr_name($1)
    unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance | unset %absorb

    ; Add some style to the person who dodged.
    set %stylepoints.to.add $rand(50,80)
    %stylepoints.to.add = $calc((10 * %current.playerstyle.level) + %stylepoints.to.add) 

    $add.stylepoints($1, $2, %stylepoints.to.add,dodge)  
    unset %stylepoints.to.add 

    $calculate.stylepoints($1)

    if (%current.playerstyle = Trickster) {  set %guard.message $readini(translation.dat, battle, TricksterDodged) }
    if (%current.playerstyle != Trickster) { set %guard.message $readini(translation.dat, battle, NormalDodge) }

    if (%third.eye.dodge = yes) { set %guard.message $readini(translation.dat, battle, ThirdEyeDodge) }

    unset %current.playerstyle | unset %current.playerstyle.level
    set %trickster.dodged on

    remini $txtfile(battle2.txt) style $1 $+ .lastaction

    var %number.of.dodges $readini($char($1), stuff, TimesDodged)
    if (%number.of.dodges = $null) { var %number.of.dodges 0 }
    inc %number.of.dodges 1
    writeini $char($1) stuff TimesDodged %number.of.dodges
    $achievement_check($1, Can'tTouchThis)
  }

  unset %current.playerstyle | unset %current.playerstyle.level | return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; parries an attack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
weapon_parry_check {
  ; $1 = defending target (the one who will parry)
  ; $2 = attacker
  ; $3 = weapon used

  if ($person_in_mech($1) = true) { return }
  if ($readini($char($2), status, stun) = yes) { return }
  if ($readini($char($2), status, paralysis) = yes) { return }
  if ($person_in_mech($2) = true) { return }
  if ($readini($char($2), skills, truestrike.on) = on) { return }

  if ((%battle.rage.darkness = on) && ($readini($char($2), info, flag) = monster)) { return }

  var %parry.weapon $readini($char($1), weapons, equipped)
  $mastery_check($1, %parry.weapon)

  if (%battle.type = cosmic) { var %parry.chance $rand(1,250) } 
  else { var %parry.chance $rand(1,100) }

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if ($augment.check($1, EnhanceParry) = true) { set %mastery.bonus 100 | inc %current.playerstyle.level $calc(10* %augment.strength) | dec %parry.chance %current.playerstyle.level }

  if ((%mastery.bonus = $null) || (%mastery.bonus < 100)) {  unset %current.playerstyle | unset %current.playerstyle.level  | return }

  if (%current.playerstyle = WeaponMaster) { 
    dec %parry.chance %current.playerstyle.level
  }
  unset %current.playerstyle | unset %current.playerstyle.level 

  ; If the target is using a second weapon, increase the chance of parrying.
  var %left.hand.weapon $readini($char($1), weapons, equippedLeft)
  if (%left.hand.weapon != $null) {
    var %left.hand.weapon.type $readini($dbfile(weapons.db), %left.hand.weapon, type)
    if (%left.hand.weapon.type != shield) { dec %parry.chance $rand(1,2) }
  }



  if (%parry.chance >= 3) { return }

  set %attack.damage 0 | $set_chr_name($1) 
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance | set %attack.damage 0 | unset %absorb

  ; Add some style to the person who dodged.
  set %stylepoints.to.add $rand(70,100)
  %stylepoints.to.add = $calc(%stylepoints.to.add) 

  $add.stylepoints($1, $2, %stylepoints.to.add,parry)  
  unset %stylepoints.to.add 

  remini $txtfile(battle2.txt) style $1 $+ .lastaction

  $calculate.stylepoints($1)
  $set_chr_name($1) | set %guard.message $readini(translation.dat, battle, WeaponParry)

  var %number.of.parries $readini($char($1), stuff, TimesParried)
  if (%number.of.parries = $null) { var %number.of.parries 0 }
  inc %number.of.parries 1
  writeini $char($1) stuff TimesParried %number.of.parries
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; blocks an attack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shield_block_check {
  ; $1 = defending target (the one who will block)
  ; $2 = attacker
  ; $3 = weapon used

  unset %shield.block.line

  ; Is the defender using a shield?
  var %left.hand.weapon $readini($char($1), weapons, equippedLeft)
  if (%left.hand.weapon = $null) { return }
  var %left.hand.weapon.type $readini($dbfile(weapons.db), %left.hand.weapon, type)
  if (%left.hand.weapon.type != shield) { return }

  if (%counterattack = on) { return }
  if ($person_in_mech($1) = true) { return }
  if ($readini($char($2), status, stun) = yes) { return }
  if ($readini($char($2), status, paralysis) = yes) { return }
  if ($readini($char($2), skills, truestrike.on) = on) { return }
  if (%guard.message != $null) { return }
  if ((%battle.rage.darkness = on) && ($readini($char($2), info, flag) = monster)) { return }

  ; Get the blocking chance of the shield
  var %shield.blocking.chance $readini($dbfile(weapons.db), %left.hand.weapon, BlockChance)
  if ($augment.check($1, EnhanceBlocking) = true) { inc %shield.blocking.chance $calc(1 * %augment.strength) }
  if ($accessory.check($1, EnhanceBlocking) = true) {
    inc %shield.blocking.chance %accessory.amount
    unset %accessory.amount
  }

  if ($readini($char($1), skills, ShieldFocus.on) = on) { var %shield.blocking.chance 100  }

  ; Attempt to block using the shield.
  var %block.chance $rand(1,100)
  if (%block.chance > %shield.blocking.chance) { return }

  ; Determine how much damage is absorbed via the shield.
  var %shield.blocking.amount $readini($dbfile(weapons.db), %left.hand.weapon, AbsorbAmount)

  if ($readini($char($1), skills, ShieldFocus.on) = on) { var %shield.blocking.amount 100 | writeini $char($1) skills ShieldFocus.on off  }

  var %percent.blocked $round($return_percentofvalue(%attack.damage,%shield.blocking.amount),0)
  if (%percent.blocked <= 0) { var %percent.blocked 1 }

  dec %attack.damage %percent.blocked
  $set_chr_name($1) 

  set %stylepoints.to.add $rand(10,20)
  if (%attack.damage <= 0) { inc %stylepoints.to.add $rand(20,50) }

  if (%attack.damage > 0) { 
    ; Set a message showing that some damage was blocked.
    set %shield.block.line $readini(translation.dat, battle, ShieldAbsorb)
  }

  %stylepoints.to.add = $calc(%stylepoints.to.add) 
  $add.stylepoints($1, $2, %stylepoints.to.add, blocking)  
  unset %stylepoints.to.add 

  $calculate.stylepoints($1)

  if (%attack.damage <= 0) { var %attack.damage 0 | set %guard.message $readini(translation.dat, battle, ShieldBlock) }
  remini $txtfile(battle2.txt) style $1 $+ .lastaction

  var %number.of.blocks $readini($char($1), stuff, TimesBlocked)
  if (%number.of.blocks = $null) { var %number.of.blocks 0 }
  inc %number.of.blocks 1
  writeini $char($1) stuff TimesBlocked %number.of.blocks
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; counters an attack using
; a shield.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shield_reflect_melee {
  ; $1 = attacker
  ; $2 = defender
  ; $3 = weapon name

  ; This is a special kind of counter attack used for monsters like the Deku Scrubs, whose normal attacks
  ; can be countered by having a shield equipped.  Only certain weapons can be countered this way.

  if ($readini($dbfile(weapons.db), $3, CanShieldReflect) != true) { return }
  if (%counterattack = on) { return }

  if ($readini($char($1), status, ethereal) = yes) { return }
  if (%guard.message != $null) { return }
  if ($readini($char($2), info, MetalDefense) = true) { return }
  if ($readini($char($2), info, ai_type) = defender) { return }
  if ($readini($char($2), info, ai_type) = portal) { return }
  if ($readini($char($2), info, ai_type) = healer) { return }
  if ($2 = orb_fountain) { return }
  if ($2 = lost_soul) { return }
  if ($readini($char($1), skills, truestrike.on) = on) { return }
  if ($person_in_mech($2) = true) { return }

  ; Does the target have a guardian that has to be defeated first?  If so, it can't be countered.
  var %guardian.target $readini($char($1), info, guardian)
  if (%guardian.target != $null) { 
    var %guardian.status $readini($char(%guardian.target), battle, hp)
    if (%guardian.status > 0) { return }   
  }
  var %guardian.target $readini($char($2), info, guardian)
  if (%guardian.target != $null) { 
    var %guardian.status $readini($char(%guardian.target), battle, hp)
    if (%guardian.status > 0) { return }   
  }

  if ($is_charmed($2) = true) { return }
  if ($is_confused($2) = true) { return }

  ; Is the defender using a shield?
  var %left.hand.weapon $readini($char($2), weapons, equippedLeft)
  if (%left.hand.weapon = $null) { return }
  var %left.hand.weapon.type $readini($dbfile(weapons.db), %left.hand.weapon, type)
  if (%left.hand.weapon.type != shield) { return }

  $shield_reflect_melee_action($1, $2, $3)
}

shield_reflect_melee_action {
  set %counterattack shield 
  ; Counters will be single-hits.
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %weapon.howmany.hits
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb | unset %wpn.element 

  if ($readini($char($2), info, flag) = $null) { 
    if (($readini($char($1), info, flag) = npc) || ($readini($char($1), info, flag) = monster)) {
    %attack.damage = $round($calc(%attack.damage * 100),0) }
    inc %attack.damage $rand(1,25)
    if (%attack.damage >= 999) { set %attack.damage $rand(900,1500) }
  }

  if ($readini($char($2), info, flag) = monster) { 
    if ($readini($char($2), info, ai_type) = counteronly) { set %attack.damage $rand(2000,3000) }
    if (($readini($char($1), info, flag) = npc) || ($readini($char($1), info, flag) = $null)) {
      if ((%attack.damage >= 1000) && ($readini($char($2), info, ai_type) != counteronly)) { set %attack.damage $rand(900,1500) }
    }
  }

  var %number.of.counters $readini($char($2), stuff, TimesCountered)
  if (%number.of.counters = $null) { var %number.of.counters 0 }
  inc %number.of.counters 1
  writeini $char($2) stuff TimesCountered %number.of.counters

  unset %weapon.type

  $add.stylepoints($2, $1, %attack.damage, counter $+ $rand(1,1000) $+ a $rand(a,d))
  return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; counters an attack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
counter_melee {
  ; $1 = attacker
  ; $2 = defender
  ; $3 = weapon name

  if ($readini($dbfile(weapons.db), $3, CanCounter) = false) { return }

  ; If the attacker or defender is in a mech we can't counter, so return
  if ($person_in_mech($2) = true) { return }
  if ($person_in_mech($1) = true) { return }

  if ($readini($char($1), status, ethereal) = yes) { return }
  if (%guard.message != $null) { return }
  if ($readini($char($2), info, ai_type) = techonly) { return }

  if ($readini($char($2), info, MetalDefense) = true) { return }

  if ($readini($char($2), info, ai_type) = counteronly) { $counter_melee_action($1, $2, $3) | return }
  if ($readini($char($2), info, ai_type) = defender) { return }
  if ($readini($char($2), info, ai_type) = portal) { return }
  if ($readini($char($2), info, ai_type) = healer) { return }

  if ($2 = orb_fountain) { return }
  if ($2 = lost_soul) { return }
  if ($readini($char($1), skills, truestrike.on) = on) { return }

  if ((%battle.rage.darkness = on) && ($readini($char($2), info, flag) = monster)) { return }

  ; Does the target have a guardian that has to be defeated first?  If so, it can't be countered.
  ; If it isn't, set the attack damage to 0.
  var %guardian.target $readini($char($1), info, guardian)
  if (%guardian.target != $null) { 
    var %guardian.status $readini($char(%guardian.target), battle, hp)
    if (%guardian.status > 0) { return }   
  }
  var %guardian.target $readini($char($2), info, guardian)
  if (%guardian.target != $null) { 
    var %guardian.status $readini($char(%guardian.target), battle, hp)
    if (%guardian.status > 0) { return }   
  }

  if ($is_charmed($2) = true) { return }
  if ($is_confused($2) = true) { return }

  ; Is the attacker immune to the defender's weapon type? If so, return.
  var %weapon.name $readini($char($2), weapons, equipped)
  set %weapon.type $readini($dbfile(weapons.db), %weapon.name, type)
  if (%weapon.type != $null) { 
    set %target.weapon.null $readini($char($1), modifiers, %weapon.type)
    if (%target.weapon.null <= 0) { unset %weapon.type | return }
  }

  ; If the counter would normally heal the defender, return.
  set %wpn.element $readini($dbfile(weapons.db), %weapon.name, element)
  if ((%wpn.element != none) && (%wpn.element != $null)) { 
    var %target.element.heal $readini($char($1), modifiers, heal)
    if ($istok(%target.element.heal,%wpn.element,46) = $true) { unset %wpn.element | unset %weapon.type | return }
  }

  var %counter.chance 2

  ; Check for the CounterStance style
  set %current.playerstyle $readini($char($2), styles, equipped)
  set %current.playerstyle.level $readini($char($2), styles, %current.playerstyle)
  if (%current.playerstyle = CounterStance) { inc %counter.chance $calc(2 * %current.playerstyle.level) }

  unset %current.playerstyle | unset %current.playerstyle.level 

  ; Check for the EnhanceCounter augment.
  if ($augment.check($2, EnhanceCounter) = true) { inc %counter.chance $calc(2 * %augment.strength)  }

  ; Now let's see if we countered.
  var %random.chance $rand(1,100)

  if ($readini($char($2), skills, PerfectCounter.on) = on) { var %random.chance 1 | writeini $char($2) skills PerfectCounter.on off }
  if ($readini($char($2), skills, Retaliation.on) = on) { var %random.chance 1 | writeini $char($2) skills Retaliation.on off }

  if (%random.chance <= %counter.chance) { 
    $counter_melee_action($1, $2, $3)

    unset %weapon.type
  }
}

counter_melee_action {
  set %counterattack on 
  ; Counters will be single-hits.
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %weapon.howmany.hits
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb | unset %wpn.element 
  unset %damage.display.color

  set %weapon.element $readini($dbfile(weapons.db), %weapon.name, element)
  if ((%weapon.element != $null) && (%weapon.element != none)) {
    $modifer_adjust($1, %weapon.element)
  }

  unset %weapon.element

  ; Check for weapon type weaknesses.
  set %weapon.type $readini($dbfile(weapons.db), %weapon.name, type)
  $modifer_adjust($1, %weapon.type)

  unset %weapon.type

  if ($readini($char($2), info, flag) = $null) { 
    if (($readini($char($1), info, flag) = npc) || ($readini($char($1), info, flag) = monster)) {
    %attack.damage = $round($calc(%attack.damage * .30),0) }
    inc %attack.damage $rand(1,25)
    if (%attack.damage >= 500) { set %attack.damage $rand(450,550) }
    if (%attack.damage < 1) { set %attack.damage 1 }
  }

  if ($readini($char($2), info, flag) = monster) { 
    if ($readini($char($2), info, ai_type) = counteronly) { set %attack.damage $rand(2000,3000) }
    if (($readini($char($1), info, flag) = npc) || ($readini($char($1), info, flag) = $null)) {
      if ((%attack.damage >= 1000) && ($readini($char($2), info, ai_type) != counteronly)) { set %attack.damage $rand(900,1500) }
    }
  }

  var %number.of.counters $readini($char($2), stuff, TimesCountered)
  if (%number.of.counters = $null) { var %number.of.counters 0 }
  inc %number.of.counters 1
  writeini $char($2) stuff TimesCountered %number.of.counters

  unset %weapon.type

  $add.stylepoints($2, $1, %attack.damage, counter $+ $rand(1,1000) $+ a $rand(a,d))
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for a multiple wave
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multiple_wave_check {
  if (%besieged != on) { 
    if ((%battle.type = defendoutpost) || (%battle.type = assault)) { unset %multiple.wave }
    if (%battle.type = torment)  { unset %multiple.wave }
    if (%battle.type = cosmic) { return }

    if (%battle.type = dragonhunt) { return }
    if (%battle.type = dungeon) { return }
    if (%multiple.wave = yes) { return }
    if (%battleis = off) { return }
    if (%battle.type = boss) { return }
    if (%demonwall.fight = on) { return } 
    if (%portal.bonus = true) { return }
    if (%portal.multiple.wave = on) { return }
    if (%battle.type = mimic) { return }
    if (%battle.type = ai) { return }
    if (%boss.type = warmachine) { return }
    if (%boss.type = elderdragon) { return }
    if (%boss.type = predator) { return }
    if (%savethepresident = on) { return }
    if (%supplyrun = on) { return }
  }

  unset %number.of.monsters.needed

  if (((((%besieged != on) && (%battle.type != defendoutpost) && (%battle.type != assault) && (%battle.type != torment) && (%mode.gauntlet != on))))) {  

    var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
    if (%winning.streak <= 0) { return }

    if (%winning.streak <= 100) { var %multiple.wave.chance $rand(1,2) }
    if ((%winning.streak > 100) && (%winning.streak <= 200)) { var %multiple.wave.chance $rand(2,4) }
    if ((%winning.streak > 200) && (%winning.streak <= 400)) { var %multiple.wave.chance $rand(4,7) }
    if ((%winning.streak > 400) && (%winning.streak <= 700)) { var %multiple.wave.chance $rand(8,11) }
    if (%winning.streak > 700) { var %multiple.wave.chance $rand(4,8) }

    var %random.wave.chance $rand(1,100)
  }

  if (%mode.gauntlet = on) { var %random.wave.chance 1 | inc %mode.gauntlet.wave 1 }

  if ((%battle.type = torment) && (%torment.wave <= 3)) { inc %torment.wave 1 | var %random.wave.chance 1 }
  if ((%battle.type = torment) && (%torment.wave > 3)) { $endbattle(victory) | halt }

  if ((%battle.type = defendoutpost) && (%darkness.turns > 0)) {  var %random.wave.chance 1 | dec %darkness.turns 1 }
  if ((%battle.type = defendoutpost) && (%darkness.turns <= 0)) { $endbattle(victory) | halt }

  if ((%battle.type = assault) && ( $monster.outpost(status) >= 1)) {  var %random.wave.chance 1 }
  if ((%battle.type = assault) && ( $monster.outpost(status) <= 0)) {  $endbattle(victory) | halt }

  if ((%besieged = on) && (%besieged.squad <= 5)) { var %random.wave.chance 1 }
  if ((%besieged = on) && (%besieged.squad > 5)) { $endbattle(victory) | halt }  

  if (%random.wave.chance > %multiple.wave.chance) { return }

  set %multiple.wave yes | set %multiple.wave.bonus yes | set %multiple.wave.noaction yes

  ; Clear out the old monsters.
  $multiple_wave_clearmonsters

  ; besieged type
  if (%besieged = on) {
    inc %besieged.squad 1
    $generate_monster(besieged)

    if (%besieged.squad < 5) { $display.message(4The next squad of monsters has arrived!,battle) }
    if (%besieged.squad = 5) { $display.message(4The final squad of monsters has arrived!,battle) }

    $generate_battle_order
    set %who $read -l1 $txtfile(battle.txt) | set %line 1
    set %current.turn 1 | set %true.turn 1
    $battlelist(public)

    $next
    halt
  }

  ; Create the next wave
  if (%mode.gauntlet = $null) {  
    if ((%battle.type = defendoutpost) && (%darkness.turns > 1)) { $display.message($readini(translation.dat, system,AnotherWaveOutpost),battle)  }
    if ((%battle.type = defendoutpost) && (%darkness.turns = 1)) { $display.message($readini(translation.dat, system,AnotherWaveOutpostBoss),battle)  }
    if ((%battle.type != defendoutpost) && (%battle.type != assault)) { $display.message($readini(translation.dat, system,AnotherWaveArrives),battle) }
    if (%battle.type = assault) { $display.message($readini(translation.dat, system,AnotherWaveAssault),battle)  }
  }

  set %number.of.monsters.needed $rand(2,3)

  if (%battle.type = torment) { 
    var %total.monsters.needed 5

    if ($rand(1,100) <= 50) { set %number.of.monsters.needed 1 | $generate_monster(boss, addactionpoints) | dec %total.monsters.needed 1 }

    set %number.of.monsters.needed %total.monsters.needed

    $generate_monster(monster, addactionpoints) 
  }

  if (%battle.type != defendoutpost) {
    set %first.round.protection yes
    set %first.round.protection.turn $calc(%current.turn + 1)
  }

  if ($readini($txtfile(battle2.txt), battleinfo, players) > 1) { inc %number.of.monsters.needed 1 }

  if (%mode.gauntlet = $null) {
    if (((%battle.type != defendoutpost) && (%battle.type != torment) && (%battle.type != assault))) { $winningstreak.addmonster.amount | $generate_monster(monster) }
  }

  if (%battle.type = defendoutpost) { 
    if (%darkness.turns > 1) {  $winningstreak.addmonster.amount | $generate_monster(monster, addactionpoints) } 
    if (%darkness.turns <= 1) { $generate_monster(boss, defendoutpost, addactionpoints) }
  }

  if (%battle.type = assault) { 
    set %number.of.monsters.needed $rand(1,2)
    if ($monster.outpost(status) <= 5) { var %m.boss.chance $rand(1,20) }
    else {  var %m.boss.chance $rand(1,100) }
    if (%m.boss.chance > 15) { $generate_monster(monster, addactionpoints) }
    if (%m.boss.chance <= 15) { set %number.of.monsters.needed 1 | $generate_monster(boss, addactionpoints) | set %number.of monsters.needed $rand(1,2) | $generate_monster(monster)  }
  }

  if (%mode.gauntlet != $null) { 
    var %m.boss.chance $rand(1,100)
    $display.message($readini(translation.dat, system,AnotherWaveArrives) [Gauntlet Round: %mode.gauntlet.wave $+ ], battle) 
    set %number.of.monsters.needed 2  
    if (%m.boss.chance > 15) { $generate_monster(monster, addactionpoints) }
    if (%m.boss.chance <= 15) { $generate_monster(boss, addactionpoints) }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear out old dead monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multiple_wave_clearmonsters {
  ; Get a list of players and store them
  var %waves.battletxt.lines $lines($txtfile(battle.txt)) | var %waves.battletxt.current.line 1 
  while (%waves.battletxt.current.line <= %waves.battletxt.lines) { 
    var %waves.who.battle $read -l $+ %waves.battletxt.current.line $txtfile(battle.txt)
    var %waves.flag $readini($char(%waves.who.battle), info, flag)
    if (%waves.flag != monster) {
      write $txtfile(battle3.txt) %waves.who.battle
      %waves.battle.list = $addtok(%waves.battle.list,%waves.who.battle,46) 
    }
    inc %waves.battletxt.current.line 1
  }
  writeini $txtfile(battle2.txt) battle list %waves.battle.list
  unset %waves.battle.list

  ; Erase the old battle.txt, erase the bat list out of battle2.txt.
  .remove $txtfile(battle.txt)
  .rename $txtfile(battle3.txt) $txtfile(battle.txt)

  ; Set the # of monsters to 0.
  writeini $txtfile(battle2.txt) battleinfo monsters 0

  ; Clear out the char folder of dead monsters
  .echo -q $findfile( $char_path , *.char, 0 , 0, clear_dead_monsters $1-)

  var %turn.lines $lines($txtfile(battle.txt)) | var %current.turn.line 0
  while (%current.turn.line <= %turn.lines) { 
    var %turn.person $read -l $+ %current.turn.line $txtfile(battle.txt)
    if (%turn.person = %who) { set %line %current.turn.line | inc %current.turn.line }
    else { inc %current.turn.line }
  }


  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spawn another monster
; after one dies.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spawn_after_death {
  ; $1 = the monster or npc we're checking

  var %monster.list.to.spawn $readini($char($1), info, SpawnAfterDeath)
  if (%monster.list.to.spawn = $null) { return }

  var %monster.to.spawn.amount $numtok(%monster.list.to.spawn, 46)



  ; Cycle through and summon each
  var %value 1 | var %multiple.monster.counter 2 | set %number.of.monsters $numtok(%monster.list.to.spawn,46)
  while (%value <= %number.of.monsters) { 
    unset %multiple.monster.found
    set %current.monster.to.spawn $gettok(%monster.list.to.spawn,%value,46)

    var %isboss $isfile($boss(%current.monster.to.spawn))
    var %ismonster $isfile($mon(%current.monster.to.spawn))
    var %isnpc $isfile($npc(%current.monster.to.spawn))

    if (((%isboss != $true) && (%isnpc != $true) && (%ismonster != $true))) { inc %value }
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
    if ($isfile($npc(%current.monster.to.spawn)) = $true) {  .copy -o $npc(%current.monster.to.spawn) $char(%current.monster.to.spawn.name)  }

    if (%multiple.monster.found = true) {  
      var %real.name.spawn $readini($char(%current.monster.to.spawn), basestats, name) $calc(%multiple.monster.counter - 1)
      writeini $char(%current.monster.to.spawn.name) basestats name %real.name.spawn
    }

    ; increase the total # of monsters
    set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%current.monster.to.spawn.name,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
    write $txtfile(battle.txt) %current.monster.to.spawn.name
    var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters

    var %monster.level $readini($char(%current.monster.to.spawn.name), Info, bosslevel)
    if (%monster.level = $null) { var %monster.level $get.level($1) }
    if ($get.level(%current.monster.to.spawn.name) > %monster.level) { var %monster.level $get.level($1) }

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


    ; Get the spoil list
    var %spoil.monster.list $readini($txtfile(battle2.txt), BattleInfo, MonsterList)
    var %spoil.monster.list $addtok(%spoil.monster.list, %current.monster.to.spawn.name, 46)
    writeini $txtfile(battle2.txt) BattleInfo MonsterList %spoil.monster.list

    ; Get the boss item.
    $check_drops(%current.monster.to.spawn.name)

    inc %value

  }
  unset %found.monster

  set %multiple.wave.bonus yes
  set %first.round.protection yes

  ; Remove the monster to spawn from the original monster to prevent some silly potential bugs
  remini $char($1) info SpawnAfterDeath
}

metal_defense_check {
  if ($augment.check($2, IgnoreMetalDefense) = true) { return }
  else { 
    if ($readini($char($1), info, MetalDefense) = true) { set %attack.damage 0  }
    return
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RENKEI functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
renkei.check {
  var %renkei.techs.total $readini($char($2), renkei, NumberOfTechs)
  if ((%renkei.techs.total <= 1) || (%renkei.techs.total = $null)) { return }

  var %renkei.tech.value $readini($char($2), renkei, TotalRenkeiValue)  

  if (%renkei.techs.total > 2) { inc %renkei.tech.value $rand(5,10) }

  writeini $char($2) renkei NumberOfTechs 0

  var %renkei.tech.damage $readini($char($2), renkei, TotalTechDamage)

  if (%renkei.tech.value < 3) { set %renkei.tech.percent .10 | set %renkei.name Impaction | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large vaccum of air that sucks %real.name inwards before exploding with energy! }
  if ((%renkei.tech.value >= 3) && (%renkei.tech.value <= 5)) { set %renkei.tech.percent .15 | set %renkei.name Scission | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large cut across %real.name $+ 's chest! }
  if ((%renkei.tech.value >= 5) && (%renkei.tech.value < 10)) { set %renkei.tech.percent .20 | set %renkei.name Distortion | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large amount of green energy that surrounds and then slams into %real.name $+ ! }
  if ((%renkei.tech.value >= 10) && (%renkei.tech.value < 15)) { set %renkei.tech.percent .25 | set %renkei.name Fragmentation | $set_chr_name($2) | set %renkei.description The techniques combine together and cause large silver crystals to grow out of %real.name $+ 's body.  The crystals then explode, dealing damage. }
  if ((%renkei.tech.value >= 15) && (%renkei.tech.value <= 20)) { set %renkei.tech.percent .35 | set %renkei.name Darkness | $set_chr_name($2) | set %renkei.description The techniques combine together and the sky grows dark. A huge orb of dark energy appears above %real.name $+ 's head.  The orb grows bigger and bigger before exploding violently ontop of %real.name dealing damage. }
  if (%renkei.tech.value > 20)  { set %renkei.tech.percent .40 | set %renkei.name Light | $set_chr_name($2) | set %renkei.description The techniques combine together and the sky grows bright. A huge orb of pure light energy appears above %real.name $+ 's head.  The orb grows bigger and bigger before exploding violently ontop of %real.name dealing damage. }

  if (%renkei.tech.damage < 100) { inc %renkei.tech.percent .05 }

  set %attack.damage $round($calc(%renkei.tech.damage * %renkei.tech.percent),0) 

  $deal_damage($1, $2, renkei)
  $display_damage($1,$2, renkei)
}

renkei.calculate {
  if ($readini($dbfile(techniques.db), $3, magic) = yes) { return }
  var %renkei.tech.value $readini($char($2), renkei, TotalRenkeiValue)  
  var %renkei.tech.amount $readini($dbfile(techniques.db), $3, Renkei)

  if ((%renkei.tech.amount = $null) || (%renkei.tech.amount = 0)) { return }

  if ((%portal.bonus = true) || (%battle.type = dungeon)) { var %renkei.tech.value $round($calc(%renkei.tech.value / 2),0) } 

  if ($augment.check($1, RenkeiBonus) = true) { 
    var %bonus $calc(%augment.strength * 2)
    %renkei.tech.amount = $calc(%renkei.tech.amount * %bonus)
  }

  if (%renkei.tech.value = $null) { writeini $char($2) renkei TotalRenkeiValue %renkei.tech.amount }
  if (%renkei.tech.value != $null) { inc %renkei.tech.value %renkei.tech.amount | writeini $char($2) renkei TotalRenkeiValue %renkei.tech.value }

  var %renkei.techs.total $readini($char($2), renkei, NumberOfTechs)
  if (%renkei.techs.total = $null) { var %renkei.techs.total 0 }

  if ($readini($char($1), skills, konzen-ittai.on) = on) { inc %renkei.techs.total 2 | writeini $char($1) skills konzen-ittai.on off }
  if ($readini($char($1), skills, konzen-ittai.on) != on) { inc %renkei.techs.total 1 }

  writeini $char($2) renkei NumberOfTechs %renkei.techs.total 

  var %renkei.tech.damage $readini($char($2), renkei, TotalTechDamage)
  if (%renkei.tech.damage = $null) { writeini $char($2) renkei TotalTechDamage %attack.damage }
  if (%renkei.tech.damage != $null) { inc %renkei.tech.damage %attack.damage | writeini $char($2) renkei TotalTechDamage %renkei.tech.damage }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BATTLEFIELD stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.battlefield.pick {
  if (%battle.type = torment) { return }
  if (%battle.type = cosmic) { return }

  if (%warp.battlefield != $null) {
    %current.battlefield = %warp.battlefield
    unset %warp.battlefield

    $battlefield.object
    return
  }

  if (%current.battlefield != $null) { return }

  set %battlefields.total $lines($lstfile(battlefields.lst))
  if ((%battlefields.total = $null) || (%battlefields.total = 0)) { set %current.battlefield none | unset %battlefields.total | return }

  set %battlefield.random $rand(1,%battlefields.total)
  set %current.battlefield $read($lstfile(battlefields.lst), %battlefield.random)

  $battlefield.object

  unset %battlefield.random | unset %battlefields.total
}

battlefield.object {
  if (%battle.type = ai) { return }

  var %breakable.objects $readini($dbfile(battlefields.db), %current.battlefield, objects)
  if (%breakable.objects = $null) { return }

  var %object.chance $rand(1,100)

  if (%object.chance <= 25) {
    var %object.chosen $gettok(%breakable.objects, $rand(1, $numtok(%breakable.objects, 46)), 46)

    .copy -o $char(new_chr) $char(%object.chosen)
    writeini $char(%object.chosen) info flag monster 
    writeini $char(%object.chosen) Basestats name %object.chosen
    writeini $char(%object.chosen) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
    writeini $char(%object.chosen) info gender its
    writeini $char(%object.chosen) info gender2 its
    writeini $char(%object.chosen) info bosslevel 1
    writeini $char(%object.chosen) info CanTaunt false
    writeini $char(%object.chosen) basestats HP 1
    writeini $char(%object.chosen) battle HP 1
    writeini $char(%object.chosen) descriptions DeathMessage crumbles into pieces all over the ground
    writeini $char(%object.chosen) descriptions char is a breakable object
    writeini $char(%object.chosen) info ai_type defender
    writeini $char(%object.chosen) monster type object

    set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%object.chosen,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %object.chosen
  }
}
battlefield.damage {
  set %attack.damage $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ amount)
  var %current.streak $return_winningstreak
  var %streak.increase $calc(%current.streak / 100)
  if (%streak.increase < 1) { var %streak.increase 1 }

  if (%battle.type != dungeon) { 
    set %attack.damage $round($calc(%attack.damage * %streak.increase),0)
    if (%attack.damage > 800) { set %attack.damage 800 }
  }

  set %damage.display.color 4 
}
battlefield.event {
  set %debug.location alias battlefield.event

  if (($return_winningstreak < 15) && (%portal.bonus != true)) { return }
  if ($readini(system.dat, system, EnableBattlefieldEvents) != true) { return }
  if (%battle.type = ai) { return }
  if (no-battlefieldeffect isin %battleconditions) { return }

  set %number.of.events $readini($dbfile(battlefields.db), %current.battlefield, NumberOfEvents)

  if ((%number.of.events = $null) || (%number.of.events = 0)) { unset %number.of.events | return }

  set %battlefield.event.number $rand(1,%number.of.events)

  var %random.chance $rand(1,100)

  if (%random.chance > $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ chance)) { unset %battlefield.event.number | unset %number.of.events | return }

  set %battlefield.event.target $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ target)
  if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ statusType) != $null) { set %event.status.type $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ statusType) }

  if (%battlefield.event.target = all) {
    $display.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)

    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if (($readini($char(%who.battle), battle, status) = dead) || ($readini($char(%who.battle), monster, type) = object)) { inc %battletxt.current.line }
      else {
        if (%event.status.type != $null) { 
          if ($person_in_mech(%who.battle) = false)  {  writeini $char(%who.battle) status %event.status.type yes }
        }
        if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = damage) { 

          var %number.of.bfevents $readini($char(%who.battle), stuff, TimesHitByBattlefieldEvent)
          if (%number.of.bfevents = $null) { var %number.of.bfevents 0 }
          inc %number.of.bfevents 1
          writeini $char(%who.battle) stuff TimesHitByBattlefieldEvent %number.of.bfevents
          $achievement_check(%who.battle, NeverAskedForThis)
          $battlefield.damage
          $metal_defense_check(%who.battle, battlefield)
          if (%attack.damage <= 0) { set %attack.damage 1 }
          $guardianmon.check(battlefield, battlefield, %who.battle)
          if ($readini($char(%who.battle), info, HurtByTaunt) = true) { set %attack.damage 0 }

          $deal_damage(battlefield, %who.battle, battlefield)
          $display_aoedamage(battlefield, %who.battle, battlefield)
        }
        if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = heal) {
          $heal_damage($1, %who.battle, $2)
          $display_heal(battlefield, %who.battle ,aoeheal, battlefield)
        }
        inc %battletxt.current.line
      }
    }
  }

  if (%battlefield.event.target = random) {
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if (((($readini($char(%who.battle), battle, hp) <= 0) || ($readini($char(%who.battle), monster, type) = object) || ($person_in_mech(%who.battle) = true) || ($readini($char(%who.battle), battle, status) = runaway)))) { inc %battletxt.current.line }
      else {  %alive.members = $addtok(%alive.members, %who.battle, 46)  }
      inc %battletxt.current.line
    }

    set %number.of.members $numtok(%alive.members, 46)

    if (%number.of.members = $null) { unset %number.of.members | unset %alive.members | return }

    set %random.member $rand(1,%number.of.members)
    set %member $gettok(%alive.members,%random.member,46)

    unset %random.member | unset %alive.members | unset %number.of.members

    if (($readini($char(%member), battle, hp) = $null) || ($readini($char(%member), monster, type) = object)) { return }

    $set_chr_name(%member) 
    $display.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)

    if (%event.status.type != $null) { 
      if ($person_in_mech(%member) = false) {  writeini $char(%member) status %event.status.type yes }
    }
    if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = damage) { 
      var %number.of.bfevents $readini($char(%member), stuff, TimesHitByBattlefieldEvent)
      if (%number.of.bfevents = $null) { var %number.of.bfevents 0 }
      inc %number.of.bfevents 1
      writeini $char(%member) stuff TimesHitByBattlefieldEvent %number.of.bfevents
      $achievement_check(%member, NeverAskedForThis)
      $battlefield.damage
      $metal_defense_check(%member, battlefield)
      if (%attack.damage <= 0) { set %attack.damage 1 }
      $guardianmon.check(battlefield, battlefield, %member)
      if ($readini($char(%,member), info, HurtByTaunt) = true) { set %attack.damage 0 }
      if ($readini($char(%member), info, IgnoreBattlefieldDamage) = true) { set %attack.damage 0 }
      $deal_damage(battlefield, %member, battlefield)
      $display_aoedamage(battlefield, %member, battlefield)
    }
    if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = heal) {
      set %attack.damage $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ amount)
      $heal_damage($1, %member, $2)
      $display_heal(battlefield, %member, aoeheal, battlefield)
    }

    unset %member
  }

  if (%battlefield.event.target = monsters) {
    $display.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if (($readini($char(%who.battle), battle, hp) <= 0)  || ($readini($char(%who.battle), monster, type) = object)) { inc %battletxt.current.line }
      else if ((($readini($char(%who.battle), info, flag) = $null) || ($person_in_mech(%who.battle) = true) || ($readini($char(%who.battle), info, flag) = npc))) { inc %battletxt.current.line }
      else if ($readini($char(%who.battle), battle, status) = runaway) { inc %battletxt.current.line }
      else {
        if (%event.status.type != $null) { 
          if ($person_in_mech(%who.battle) = false) {  writeini $char(%who.battle) status %event.status.type yes }
        }
        if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = damage) { 
          $battlefield.damage

          $metal_defense_check(%who.battle, battlefield)
          if (%attack.damage <= 0) { set %attack.damage 1 }

          $guardianmon.check(battlefield, battlefield, %who.battle)
          if ($readini($char(%who.battle), info, HurtByTaunt) = true) { set %attack.damage 0 }
          if ($readini($char(%who.battle), info, IgnoreBattlefieldDamage) = true) { set %attack.damage 0 }
          $deal_damage(battlefield, %who.battle, battlefield)
          $display_aoedamage(battlefield, %who.battle, battlefield)
        }
        if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = heal) {
          set %attack.damage $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ amount)
          $heal_damage($1, %who.battle, $2)
          $display_heal(battlefield, %who.battle ,aoeheal, battlefield)
        }
        inc %battletxt.current.line
      }
    }
  }

  if (%battlefield.event.target = players) {
    $display.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ((($readini($char(%who.battle), battle, hp) <= 0) || ($person_in_mech(%who.battle) = true) || ($readini($char(%who.battle), info, flag) = monster))) { inc %battletxt.current.line }
      else if ($readini($char(%who.battle), battle, status) = runaway) { inc %battletxt.current.line }
      else {

        if (%event.status.type != $null) { writeini $char(%who.battle) status %event.status.type yes }
        if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = damage) { 

          var %number.of.bfevents $readini($char(%who.battle), stuff, TimesHitByBattlefieldEvent)
          if (%number.of.bfevents = $null) { var %number.of.bfevents 0 }
          inc %number.of.bfevents 1
          writeini $char(%who.battle) stuff TimesHitByBattlefieldEvent %number.of.bfevents
          $achievement_check(%who.battle, NeverAskedForThis)

          $battlefield.damage
          $metal_defense_check(%who.battle, battlefield)
          if (%attack.damage <= 0) { set %attack.damage 1 }

          $guardianmon.check(battlefield, battlefield, %who.battle)
          if ($readini($char(%who.battle), info, IgnoreBattlefieldDamage) = true) { set %attack.damage 0 }

          $deal_damage(battlefield, %who.battle, battlefield)
          $display_aoedamage(battlefield, %who.battle, battlefield)
        }

        if ($readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number) = heal) {
          set %attack.damage $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ amount)
          $heal_damage(battlefield, %who.battle, battlefield)
          $display_heal(battlefield, %who.battle, aoeheal, battlefield)
        }
        inc %battletxt.current.line
      }
    }
  }

  unset %battlefield.event.number | unset %number.of.events | unset %battlefield.event.target
  unset %battlefield.event.target | unset %event.status.type

  $battle.check.for.end 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for boosts to
; attack damage based on
; several offensive styles.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
offensive.style.check {
  ; $1 = attacker
  ; $2 = weapon/tech name
  ; $3 = flag: melee, tech, magic

  if ($person_in_mech($1) = true) { return }

  var %current.playerstyle $return.playerstyle($1)
  var %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (($3 = melee) || ($3 = tech)) {

    ; Check for Hiten Mitsurugi-ryu for katana damage
    if (%current.playerstyle = HitenMitsurugi-ryu) {
      if ($readini($dbfile(weapons.db), $2, type) = Katana) {
        var %amount.to.increase $calc(.05 * %current.playerstyle.level)
        if (%amount.to.increase >= .80) { var %amount.to.increase .80 }
        var %hmr.increase $round($calc(%amount.to.increase * %attack.damage),0)
        inc %attack.damage %hmr.increase
      }    
    }

    ; Check for Wrestlemania for HandToHand damage
    if (%current.playerstyle = Wrestlemania) {
      if ($readini($dbfile(weapons.db), $2, type) = HandToHand) {
        var %amount.to.increase $calc(.05 * %current.playerstyle.level)
        if (%amount.to.increase >= .80) { var %amount.to.increase .80 }
        var %wrestlemania.increase $round($calc(%amount.to.increase * %attack.damage),0)
        inc %attack.damage %wrestlemania.increase
      }    
    }

  }

  if ($3 = magic) {
    if (%current.playerstyle = SpellMaster) { inc %magic.bonus.modifier $calc(%current.playerstyle.level * .30)
      if (%magic.bonus.modifier >= 1) { set %magic.bonus.modifier .95 }
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if an
; Ethereal monster can be
; hurt.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
melee.ethereal.check {
  if (%guard.message != $null) { return } 
  if ($readini($char($3), status, ethereal) = yes) {
    if ((($readini($dbfile(weapons.db), $2, HurtEthereal) != true) && ($augment.check($1, HurtEthereal) = false) && ($readini($char($1), skills, FormlessStrike.on) != on))) {
      $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
    }
  }
}

magic.ethereal.check {
  ; $1 = attacker
  ; $2 = technique
  ; $3 = target

  if (%guard.message != $null) { return } 
  if (($readini($char($3), status, ethereal) = yes) && ($readini($dbfile(techniques.db), $2, magic) != yes)) {
    $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
  }
}

tech.ethereal.check {
  ; $1 = attacker
  ; $2 = technique
  ; $3 = target

  if (%guard.message != $null) { return } 

  var %weapon.hurt.ethereal $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), HurtEthereal)

  if ($readini($char($3), status, ethereal) = yes) {
    if ((($augment.check($1, HurtEthereal) = false) && (%weapon.hurt.ethereal != true) && ($readini($dbfile(techniques.db), $2, magic) != yes))) {
      $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if the barrage
; skill is on and if the weapon is
; a ranged weapon or not
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
barrage_check {
  ; $1 = the person we're checking
  ; $2 = the weapon name

  var %weapon.type.check $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), type)

  var %ranged.types bow.gun.rifle
  if ($istok(%ranged.types, %weapon.type.check, 46) = $false) { return false }

  if ($readini($char($1), skills, barrage.on) = on) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if the doublecast
; skill is on and if the tech is
; magic or not
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
doublecast_check {
  ; $1 = the person we're checking
  ; $2 = the tech name

  var %magic.check $readini($dbfile(techniques.db), $2, spell)
  if ((%magic.check = no) || (%magic.check = $null)) { return false }

  if ($readini($char($1), skills, doublecast.on) = on) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if the duality
; skill is on and if the tech is
; a single non-spell type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
duality_check {
  ; $1 = the person we're checking
  ; $2 = the tech name

  if ($readini($dbfile(techniques.db), $2, spell) = yes) { return false }
  if ($readini($dbfile(techniques.db), $2, type) != single) { return false }

  if ($readini($char($1), skills, duality.on) = on) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if the user
; has the SwiftCast skill
; and if the technique is magic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
swiftcast_check {
  ; $1 = the person we're checking
  ; $2 = the tech name

  if (($readini($char($1), skills, swiftcast) = $null) || ($readini($char($1), skills, swiftcast) = 0)) { return }
  set %attack.damage $round($calc(%attack.damage + (%attack.damage * .10)),0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns true if a weapon
; is a ranged weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
weapon.ranged.check {
  if ($readini($dbfile(weapons.db), $1, ranged) = true) { return true }

  var %weapon.type $readini($dbfile(weapons.db), $1, type)

  if (%weapon.type = bow) { return true }
  if (%weapon.type = gun) { return true }
  if (%weapon.type = rifle) { return true }
  if (%weapon.type = Glyph) { return true }

  return false
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if flying
; monster can be hurt.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; It is assumed that a ranged
; weapon will hit a flying target
; and all techs under
; the ranged weapon. Also
; magic will. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flying.damage.check {
  ; $1 = the person who is attacking
  ; $2 = the weapon the person is using
  ; $3 = the target

  if ($readini($char($3), status, flying) = yes) { 
    var %israngedweapon $weapon.ranged.check($2)
    if (%israngedweapon != true) { $set_chr_name($1) | set %guard.message $readini(translation.dat, status, FlyingBlocked) | set %attack.damage 0 | return }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if Utsusemi 
; is on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utsusemi.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if (($readini($dbfile(weapons.db), $2, ignoreShadows) = true) || ($readini($dbfile(techniques.db), $2, ignoreShadows) = true)) { return } 

  if (($readini($char($1), info, flag) = monster) && (%battle.rage.darkness = on)) { return }


  if ($person_in_mech($3) = true) { return }

  if (%guard.message != $null) { return }
  if ($readini($dbfile(techniques.db), $2, type) = heal) { return }

  var %utsusemi.flag $readini($char($3), skills, utsusemi.on)

  if (%utsusemi.flag = on) {
    var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
    set %shadows.blocked 1

    if ($readini($dbfile(techniques.db), $2, DestroyShadows) != $null) { inc %shadows.blocked $readini($dbfile(techniques.db), $2, DestroyShadows) }
    if ($readini($dbfile(weapons.db), $2, DestroyShadows) != $null) { inc %shadows.blocked $readini($dbfile(weapons.db), $2, DestroyShadows) }

    if ((%battle.rage.darkness = on) && ($readini($char($1), info, flag) = monster)) { inc %shadows.blocked 5 }

    if (($get.level($1) > $get.level($3)) && ($readini($char($1), info, flag) = monster)) { inc %shadows.blocked 1 }

    if (%shadows.blocked > %number.of.shadows) { set %shadows.blocked %number.of.shadows }

    dec %number.of.shadows %shadows.blocked 
    writeini $char($3) skills utsusemi.shadows %number.of.shadows
    if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
    $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, UtsusemiBlocked) | set %attack.damage 0 | unset %shadows.blocked | return 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if Royal
; Guard is on.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
royalguard.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if ($person_in_mech($3) = true) { return }
  if (%guard.message != $null) { return }
  if (($readini($char($1), info, flag) = monster) && (%battle.rage.darkness = on)) { return }

  ; does the target have RoyalGuard on?  If so, reduce the damage to 0.
  if ($readini($char($3), skills, royalguard.on) = on) { 
    writeini $char($3) skills royalguard.on off 
    var %total.blocked.damage $readini($char($3), skills, royalguard.dmgblocked)
    if (%total.blocked.damage = $null) { var %total.blocked.damage 0 }

    if (%attack.damage > 4000) {  var %blocked.damage $round($calc(4000 + (%attack.damage * .10)),0) } 
    if (%attack.damage <= 4000) { var %blocked.damage %attack.damage }

    if (%battle.rage.darkness = on) { var %blocked.damage 0 }

    inc %total.blocked.damage %blocked.damage
    writeini $char($3) skills royalguard.dmgblocked %total.blocked.damage
    set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, RoyalGuardBlocked) | return 
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if Mana Wall
; is on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
manawall.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if ($person_in_mech($3) = true) { return }

  if (%guard.message != $null) { return }
  if ($readini($dbfile(techniques.db), $2, type) = heal) { return }

  if (($readini($char($3), skills, manawall.on) = on) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { 
    writeini $char($3) skills manawall.on off | set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, ManaWallBlocked) | return 
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if Perfect
;Defense is on.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
perfectdefense.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if ($person_in_mech($3) = true) { return }
  if (%guard.message != $null) { return }

  ; does the target have PerfectDefense on?  If so, reduce the damage to 0.
  if ($readini($char($3), skills, perfectdefense.on) = on) { 
    writeini $char($3) skills perfectdefense.on off 
    set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, PerfectDefenseBlocked) | return 
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if the
;Invincible Status is on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
invincible.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if ($person_in_mech($3) = true) { return }
  if (%guard.message != $null) { return }

  ; does the target have Invincible on?  If so, reduce the damage to 0.
  if ($readini($char($3), status, invincible) = yes) { 
    set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, status, InvincibleDamage) | return 
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks to
; see if someone is being
; protected by someone else.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
covercheck {
  ; $3 = AOE for AOE stuff
  unset %covering.someone

  var %cover.target $readini($char($1), skills, CoverTarget)

  if ((%cover.target = none) || (%cover.target = $null)) { set %attack.target $1 | return } 

  var %cover.status $readini($char(%cover.target), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { writeini $char($1) skills CoverTarget none | set %attack.target $1 | return } 
  if ($readini($char(%cover.target), Battle, HP) <= 0) { writeini $char($1) skills CoverTarget none | set %attack.target $1 | return } 

  if ($readini($dbfile(techniques.db), $2, Type) = heal) { set %attack.target $1 | return }
  if ($readini($dbfile(techniques.db), $2, Type) = heal-AOE) { set %attack.target $1 | return }

  if ($3 != AOE) {  set %attack.target %cover.target 
    set %covering.someone on
  }
  if ($3 = AOE) { set %who.battle %cover.target }
  writeini $char($1) skills CoverTarget none
  $display.message($readini(translation.dat, battle, TargetCovered),battle) 
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Multiple Hits Calculations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
double.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %original.attackdmg %attack.damage

  set %double.attack.chance $3
  if (%double.attack.chance >= 90) { set %double.attack true
    set %number.of.hits 2

    set %attack.damage1 %attack.damage
    set %attack.damage2 $abs($round($calc(%original.attackdmg  / 2.1),0))

    if (%attack.damage2 <= 0) { set %attack.damage2 1 }

    var %attack.damage3 $calc(%attack.damage1 + %attack.damage2)
    if (%attack.damage3 > 0) {   
      set %attack.damage %attack.damage3 

      set %enemy $set_chr_name($2)  %real.name
      if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
      $set_chr_name($1) 

      if (%multihit.message.on != on) {
        set %multihit.message.on on
      } 
    }
    unset %double.attack.chance | unset %original.attackdmg 
  }
  else { set %number.of.hits 1 | unset %double.attack.chance | return }
}
triple.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %triple.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.5),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage %attack.damage.total 

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 

  unset %original.attackdmg
}
fourhit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %fourhit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.5),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.5),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage %attack.damage.total

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 

  unset %original.attackdmg
}
fivehit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %fivehit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.5),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.5),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 5.2),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)
  set %attack.damage %attack.damage.total 

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 

  unset %original.attackdmg
}
sixhit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total  set %sixhit.attack true

  set %sixhit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.5),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.5),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 5.2),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)
  set %attack.damage %attack.damage.total 

  set %attack.damage6 $abs($round($calc(%original.attackdmg / 6.9),0))
  if (%attack.damage6 <= 0) { set %attack.damage6 1 }
  var %attack.damage.total $calc(%attack.damage6 + %attack.damage.total)

  set %attack.damage %attack.damage.total 

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 
  unset %original.attackdmg
}
sevenhit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %sevenhit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.5),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.5),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 5.2),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)
  set %attack.damage %attack.damage.total 

  set %attack.damage6 $abs($round($calc(%original.attackdmg / 6.9),0))
  if (%attack.damage6 <= 0) { set %attack.damage6 1 }
  var %attack.damage.total $calc(%attack.damage6 + %attack.damage.total)

  set %attack.damage7 $abs($round($calc(%original.attackdmg / 8.9),0))
  if (%attack.damage7 <= 0) { set %attack.damage7 1 }
  var %attack.damage.total $calc(%attack.damage7 + %attack.damage.total)

  set %attack.damage %attack.damage.total

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 
  unset %original.attackdmg
}
eighthit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %eighthit.attack true

  set %number.of.hits 8
  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.5),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.5),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 5.2),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)
  set %attack.damage %attack.damage.total 

  set %attack.damage6 $abs($round($calc(%original.attackdmg / 6.9),0))
  if (%attack.damage6 <= 0) { set %attack.damage6 1 }
  var %attack.damage.total $calc(%attack.damage6 + %attack.damage.total)

  set %attack.damage7 $abs($round($calc(%original.attackdmg / 8.9),0))
  if (%attack.damage7 <= 0) { set %attack.damage7 1 }
  var %attack.damage.total $calc(%attack.damage7 + %attack.damage.total)

  set %attack.damage8 $abs($round($calc(%original.attackdmg / 9.9),0))
  if (%attack.damage8 <= 0) { set %attack.damage8 1 }
  var %attack.damage.total $calc(%attack.damage8 + %attack.damage.total)

  set %attack.damage %attack.damage.total

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 

  unset %original.attackdmg
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wonderguard Check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wonderguard.check {
  ; $1 = target
  ; $2 = weapon/technique/item name
  ; $3 = type (melee, tech or item)
  ; $4 = the weapon name, if the type is tech

  if (%guard.message != $null) { return }
  if ($readini($char($1), info, WonderGuard) != true) { return }

  var %wonderguard.immune false

  if (%battle.type = cosmic) { 
    ;  only torment weapons will work

    if ($readini($dbfile(weapons.db), $2, TormentWeapon) = true) { return }
    if ($readini($dbfile(weapons.db), $4, TormentWeapon) = true) { return }

    set %attack.damage 0 
    set %damage.display.color 6 
    set %guard.message $readini(translation.dat, battle, ImmuneToAttack) 
    return
  }

  ; Check for immunity of the weapon/tech/item name
  var %immunity.name $readini($char($1), modifiers, $2)
  if (%immunity.name = $null) { var %immunity.name 0 }

  ; Items only need to check the names
  if ($3 = item) {
    if (%immunity.name = 0) { var %wonderguard.immune true }
  }

  ; Techs need to check tech name and tech element

  if ($3 = tech) {
    ; Get the technique element
    var %tech.element $readini($dbfile(techniques.db), $2, element)
    if (%tech.element != $null) { var %immunity.element $readini($char($1), modifiers, %tech.element)
      if (%immunity.element = $null) { var %immunity.element 0 }
    }

    if ((%immunity.element = 0) && (%immunity.name = 0)) { var %wonderguard.immune true }
  }

  ; Melee needs to check weapon name and weapon element

  if ($3 = melee) {
    ; Get the weapon type
    var %weapon.type $readini($dbfile(weapons.db), $2, type)
    var %immunity.type $readini($char($1), modifiers, %weapon.type) 
    if (%immunity.type = $null) { var %immunity.type 0 }

    if ((%immunity.type = 0) && (%immunity.name = 0)) { var %wonderguard.immune true }
  }

  ; Is the monster immune?
  if (%wonderguard.immune = true) {
    set %attack.damage 0 
    set %damage.display.color 6 
    set %guard.message $readini(translation.dat, battle, ImmuneToAttack) 
    return
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modifier Checks for
; elements and weapon types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modifer_adjust {
  ; $1 = target
  ; $2 = element or weapon type
  ; $3 = tech or melee

  if (%guard.message != $null) { return }

  ; Let's get the adjust value.
  var %modifier.adjust.value $readini($char($1), modifiers, $2)
  if (%modifier.adjust.value = $null) { var %modifier.adjust.value 100 }

  ; Check for accessories that cut elemental damage down.
  set %elements earth.fire.wind.water.ice.lightning.light.dark
  if ($istok(%elements,$2,46) = $true) {   
    if ($accessory.check($1, ElementalDefense) = true) {
      if (%accessory.amount = 0) { var %accessory.amount .50 }
      %modifier.adjust.value = $round($calc(%modifier.adjust.value * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for augment to cut elemental damage down
    if ($augment.check($1, EnhanceElementalDefense) = true) { dec %modifier.adjust.value $calc(%augment.strength * 10) } 

    unset %current.accessory | unset %current.accessory.type | unset %accessory.amount
  }
  unset %elements

  ; Turn it into a deciminal
  var %modifier.adjust.value $calc(%modifier.adjust.value / 100) 

  if (($readini($char($1), info, flag) != $null) && ($readini($char($1), info, clone) != yes)) {
    ; If it's over 1, then it means the target is weak to the element/weapon so we can adjust the target's def a little as an extra bonus.
    if (%modifier.adjust.value > 1) {
      if ((%portal.bonus != true) && (%battle.type != dungeon)) {
        var %mon.temp.def $readini($char($1), battle, def)
        var %mon.temp.def = $round($calc(%mon.temp.def - (%mon.temp.def * .05)),0)
        if (%mon.temp.def < 0) { var %mon.temp.def 0 }
        writeini $char($1) battle def %mon.temp.def
      }
      writeini $char($1) modifiers HitWithWeakness true
      set %damage.display.color 7
    }

    ; If it's under 1, it means the target is resistant to the element/weapon.  Let's make the monster stronger for using something it's resistant to.

    if (%modifier.adjust.value < 1) {
      var %mon.temp.str $readini($char($1), battle, str)
      var %mon.temp.str = $round($calc(%mon.temp.str + (%mon.temp.str * .05)),0)
      if (%mon.temp.str < 0) { var %mon.temp.str 0 }
      writeini $char($1) battle str %mon.temp.str
      set %damage.display.color 6
    }
  }

  ; Adjust the attack damage.
  set %attack.damage $round($calc(%attack.damage * %modifier.adjust.value),0)


  ; Adjust further if necessary
  if (($readini($char($1), modifiers, ResistTechs) >= 1) && ($3 = tech)) { 
    var %resist.tech.amount $readini($char($1), modifiers, ResistTechs) 
    var %resist.percent $calc(%resist.tech.amount / 100) 
    dec %attack.damage $round($calc(%attack.damage * %resist.percent),0)
    if (%attack.damage <= 0) { set %attack.damage 0 }
  }
  if (($readini($char($1), modifiers, ResistMelee) >= 1) && ($3 = melee)) { 
    var %resist.melee.amount $readini($char($1), modifiers, ResistMelee) 
    var %resist.percent $calc(%resist.melee.amount / 100) 
    dec %attack.damage $round($calc(%attack.damage * %resist.percent),0)
    if (%attack.damage <= 0) { set %attack.damage 0 }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for Killer Traits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
killer.trait.check {
  var %monster.type $readini($char($2), monster, type)
  if (%monster.type = $null) { return }
  var %killer.trait.name %monster.type $+ -killer
  var %killer.trait.amount $readini($char($1), skills, %killer.trait.name)
  if (%killer.trait.amount = $null) { var %killer.trait.amount 0 }

  ; Check for an augment to enhance killer traits
  if ($augment.check($1, EnhanceKillerTraits) = true) {
    inc %killer.trait.amount %augment.strength
  }

  if ($augment.check($1, Hurt $+ %monster.type) = true) {
    inc %killer.trait.amount $calc(%augment.strength * 2)
  }

  if ((%killer.trait.amount = $null) || (%killer.trait.amount <= 0)) { return 0 }

  return %killer.trait.amount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starts a Mimic Battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start.mimic.battle {
  ; Stop old battle timer
  $clear_timers

  ; Clear the chest timer/old chest
  /.timerChestDestroy off
  .remove $txtfile(treasurechest.txt)
  unset %keyinuse

  ; Start a battle using the mimic type
  if (%battleis != on) { $startnormal(mimic) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for a Guardian Mon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guardianmon.check {
  ; Does the target have a guardian that has to be defeated first?  If so, check to see if guardian is dead.  
  ; If it isn't, set the attack damage to 0.
  if ($4 = heal) { return }

  var %guardian.target $readini($char($3), info, guardian)
  if (%guardian.target = $null) { return }

  var %guardian.target.count $numtok(%guardian.target,46)
  var %current.guardian.count 1

  while (%current.guardian.count <= %guardian.target.count) { 
    var %current.guardian.target $gettok(%guardian.target, %current.guardian.count, 46)
    var %guardian.status $readini($char(%current.guardian.target), battle, hp)  
    if (%guardian.status > 0) { set %attack.damage 0 | set %tech.howmany.hits 1 | break }

    inc %current.guardian.count
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for a Elite flag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
eliteflag.check {
  var %eliteflag $readini($char($1), monster, elite)
  if (%eliteflag = $null) { return false }
  else { return %eliteflag }
}

supereliteflag.check {
  var %eliteflag $readini($char($1), monster, SuperElite)
  if (%eliteflag = $null) { return false }
  else { return %eliteflag }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for Allied Notes reward
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
battle.alliednotes.check {
  var %notes.reward $readini($txtfile(battle2.txt), battle, alliednotes)

  if (%portal.bonus = true) {
    ; divide the # of notes by the # of players who entered the portal
    var %temp.num.of.players $readini($txtfile(battle2.txt), battleinfo, players)
    var %notes.reward $round($calc(%notes.reward / %temp.num.of.players),0)
    if (%notes.reward < 10) { var %notes.reward 10 }
    writeini $txtfile(battle2.txt) battle alliednotes %notes.reward
  }

  if (%notes.reward = $null) {
    if (($readini(battlestats.dat, Battle, WinningStreak) >= 2000) && ($readini(battlestats.dat, Battle, WinningStreak) < 3000)) { writeini $txtfile(battle2.txt) battle alliednotes 25 }
    if ($readini(battlestats.dat, Battle, WinningStreak) >= 3000)  { writeini $txtfile(battle2.txt) battle alliednotes 50 }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aliases for weapon and mon
; size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.weaponsize {
  ; $1 = weapon name

  var %temp.weapon.type $readini($dbfile(weapons.db), $1, type)

  if (%temp.weapon.type = HandToHand) { return medium }
  if (%temp.weapon.type = Sword) { return medium }
  if (%temp.weapon.type = GreatSword) { return large }
  if (%temp.weapon.type = whip)  { return medium }
  if (%temp.weapon.type = gun) { return small }
  if (%temp.weapon.type = rifle) { return medium }
  if (%temp.weapon.type = energyblaster) { return medium }
  if (%temp.weapon.type = axe) { return medium }
  if (%temp.weapon.type = dagger) { return small }
  if (%temp.weapon.type = bow) { return small }
  if (%temp.weapon.type = katana) { return medium }
  if (%temp.weapon.type = wand) { return small }
  if (%temp.weapon.type = stave) { return medium }
  if (%temp.weapon.type = staff) { return medium }
  if (%temp.weapon.type = glyph) { return medium }
  if (%temp.weapon.type = spear) { return large }
  if (%temp.weapon.type = scythe) { return large }
  if (%temp.weapon.type = greataxe) { return large }
  if (%temp.weapon.type = hammer) { return medium }
  if (%temp.weapon.type = lightsaber) { return medium }
  if (%temp.weapon.type = chainsaw) { return medium }
  if (%temp.weapon.type = ParticleAccelerator) { return medium }
}

monstersize.adjust {
  ; $1 = monster name
  ; $2 = weapon used against monster

  if ($readini($char($1), info, flag) != monster) { return }

  var %monster.size $readini($char($1), monster, size) 
  if (%monster.size = $null) { return }

  var %weapon.size $return.weaponsize($2)
  if (%weapon.size = $null) { var %weapon.size medium }

  if (%weapon.size = small) {
    if (%monster.size = small) { inc %attack.damage $round($calc(%attack.damage * .40),0) }
    if (%monster.size = large) { dec %attack.damage $round($calc(%attack.damage * .40),0) }
  }

  if (%weapon.size = medium) { 
    if (%monster.size = medium) { inc %attack.damage $round($calc(%attack.damage * .40),0) }
    if (%monster.size = large) { dec %attack.damage $round($calc(%attack.damage * .30),0) }
  }

  if (%weapon.size = large) { 
    if (%monster.size = small) { dec %attack.damage $round($calc(%attack.damage * .40),0) }
    if (%monster.size = large) { inc %attack.damage $round($calc(%attack.damage * .40),0) }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds a random monster
; drop to the item pool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
add.monster.drop {
  ; $1 = the player who killed the monster
  ; $2 = the monster's name

  var %drop.items $readini($dbfile(spoils.db), drops, $2)

  if ((%battle.type = boss) && (%portal.bonus != true)) {
    if (($return_winningstreak > 500) && ($rand(1,100) <= 10)) { var %drop.items $addtok(%drop.items, Death'sBreath, 46) } 
  }

  if (%drop.items = $null) { return }

  var %random.chance.reward 40

  if ($readini($char($1), skills, SpoilSeeker) != $null) {
    inc %random.chance.reward $calc(2 * $readini($char($1), skills, SpoilSeeker))
  }

  if ($return.potioneffect($1) = Bonus Spoils) { inc %random.chance.reward 100 }

  if ($rand(1,100) <= %random.chance.reward) { 
    var %drop.reward $gettok(%drop.items,$rand(1,$numtok(%drop.items, 46)),46)
    var %temp.player.list $readini($txtfile(battle2.txt), drops, $1)
    var %temp.player.list $addtok(%temp.player.list, %drop.reward, 46)

    if ($numtok(%temp.player.list, 46) <= 20) {  writeini $txtfile(battle2.txt) drops $1 %temp.player.list }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spoil drops for portals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portal.spoils.drop {
  var %most.stylish.player $readini($txtfile(battle2.txt), battle, MostStylish)
  unset %item.drop.rewards

  var %boss.list $readini($dbfile(items.db), $readini($txtfile(battle2.txt), BattleInfo, PortalItem), Monster)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gives everyone a 
; Horadric Cache item
; if the player is alive
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
torment.reward {

  if (%torment.level <= 10) { var %torment.reward.item HoradricCache | var %torment.reward.amount %torment.level }
  else { var %torment.reward.item HoradricStash 
    if (%torment.level <= 15) {  var %torment.reward.amount $calc(%torment.level - 10) }
    if (%torment.level > 15) { var %torment.reward.amount $round($calc(5 + (%torment.level / 20)),0) }

    if (%torment.reward.amount > 10) { var %torment.reward.amount 10 }

  }

  unset %torment.drop.rewards
  set %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 

      if ($readini($char(%who.battle), battle, hp) >= 1) { 
        var %player.amount $readini($char(%who.battle), item_amount, %torment.reward.item)
        if (%player.amount = $null) { var %player.amount 0 }
        inc %player.amount %torment.reward.amount
        writeini $char(%who.battle) item_amount %torment.reward.item %player.amount
        %torment.drop.rewards = $addtok(%torment.drop.rewards,  $+ $get_chr_name(%who.battle) $+  $+ $chr(91) $+ %torment.reward.item x $+ %torment.reward.amount  $+  $+ $chr(93) $+ , 46)
      }

      inc %battletxt.current.line 1 
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gives everyone a 
; Odin Mark
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cosmic.reward {
  unset %cosmic.drop.rewards

  var %cosmic.reward.amount %cosmic.level
  if (%cosmic.reward.amount = $null) { vra %cosmic.reward.amount 1 }

  set %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 

      var %player.amount $readini($char(%who.battle), item_amount, OdinMark)
      if (%player.amount = $null) { var %player.amount 0 }
      inc %player.amount %cosmic.reward.amount
      writeini $char(%who.battle) item_amount OdinMark %player.amount
      %cosmic.drop.rewards = $addtok(%cosmic.drop.rewards,  $+ $get_chr_name(%who.battle) $+  $+ $chr(91) $+ OdinMark x $+ %cosmic.reward.amount  $+  $+ $chr(93) $+ , 46)

      inc %battletxt.current.line 1 
    }
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gives everyone an 
; AlliedLockBox
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
besieged.reward {  
  unset %besieged.drop.rewards

  var %besieged.reward.amount 1

  set %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 

      var %player.amount $readini($char(%who.battle), item_amount, AlliedLockBox)
      if (%player.amount = $null) { var %player.amount 0 }
      inc %player.amount %besieged.reward.amount
      writeini $char(%who.battle) item_amount AlliedLockBox %player.amount
      %besieged.drop.rewards = $addtok(%besieged.drop.rewards,  $+ $get_chr_name(%who.battle) $+  $+ $chr(91) $+ AlliedLockBox x $+ %besieged.reward.amount  $+  $+ $chr(93) $+ , 46)

      inc %battletxt.current.line 1 
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; rewards a random drop
; from the player's item pool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get.random.reward {
  ; $1 = the player to reward

  var %reward.list $readini($txtfile(battle2.txt), drops, $1)
  if (%reward.list = $null) { return }

  var %drop.reward $gettok(%reward.list,$rand(1,$numtok(%reward.list, 46)),46)
  var %player.amount $readini($char($1), Item_Amount, %drop.reward)
  if (%player.amount = $null) { var %player.amount 0 }

  var %item.reward.amount 1

  if ($return.potioneffect($1) = Bonus Spoils) { inc %item.reward.amount 2 | writeini $char($1) status potioneffect none } 

  inc %player.amount %item.reward.amount

  writeini $char($1) item_amount %drop.reward %player.amount
  $set_chr_name($1) 

  var %drop.counter $readini($char($1), stuff, dropsrewarded)
  if (%drop.counter = $null) { var %drop.counter 0 }
  inc %drop.counter 1
  writeini $char($1) stuff DropsRewarded %drop.counter

  %item.drop.rewards = $addtok(%item.drop.rewards, %real.name $+  $+ $chr(91) $+ %drop.reward x $+ %item.reward.amount $+  $+ $chr(93) $+ , 46)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays who gets the drops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
show.random.reward {
  if (%item.drop.rewards = $null) { return }
  var %replacechar $chr(044) $chr(032)
  %item.drop.rewards = $replace(%item.drop.rewards, $chr(046), %replacechar)
  $display.message($readini(translation.dat, battle, DropItemWin),battle) 
  unset %item.drop.rewards
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays torment rewards
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
show.torment.reward {
  if (%torment.drop.rewards = $null) { return }
  var %replacechar $chr(044) $chr(032)
  %torment.drop.rewards = $replace(%torment.drop.rewards, $chr(046), %replacechar)
  $display.message($readini(translation.dat, battle, Torment.DropWin),battle) 
  unset %item.drop.rewards
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays Cosmic rewards
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
show.cosmic.reward {
  if (%cosmic.drop.rewards = $null) { return }
  var %replacechar $chr(044) $chr(032)
  %cosmic.drop.rewards = $replace(%cosmic.drop.rewards, $chr(046), %replacechar)
  $display.message($readini(translation.dat, battle, Cosmic.DropWin),battle) 
  unset %item.drop.rewards
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays Besieged rewards
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
show.besieged.reward {
  if (%besieged.drop.rewards = $null) { return }
  var %replacechar $chr(044) $chr(032)
  %besieged.drop.rewards = $replace(%besieged.drop.rewards, $chr(046), %replacechar)
  $display.message($readini(translation.dat, battle, Besieged.DropWin),battle) 
  unset %item.drop.rewards | unset %besieged.drop.rewards
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STATUS EFFECTS checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
poison_check { 
  set %debug.location poison_check
  ;  Check for the an accessory that poisons the user
  if ($accessory.check($1, IncreaseMeleeAddPoison) = true) {
    writeini $char($1) status poison yes
    writeini $char($1) status poison.timer 0
    unset %accessory.amount
  }

  if (($readini($char($1), status, poison) = yes) || ($readini($char($1), status, HeavyPoison) = yes)) {
    set %poison.timer $readini($char($1), status, poison.timer)  
    if (%poison.timer >= $status.effects.turns(poison)) {  
      writeini $char($1) status poison no
      writeini $char($1) status HeavyPoison no 
      writeini $char($1) status poison.timer 0
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, PoisonWornOff) 
      return 
    }
    if (%poison.timer < $status.effects.turns(poison)) {
      %poison.timer = $calc(%poison.timer + 1) | writeini $char($1) status poison.timer %poison.timer 
      if ($readini($char($1), Status, HeavyPoison) = yes) { $HeavyPoison($1) | return }
      set %max.hp $readini($char($1), basestats, hp)
      set %poison $round($calc(%max.hp * .10),0)
      set %hp $readini($char($1), Battle, HP)  |   unset %max.hp
      if (%poison >= %hp) { $display.message(%status.message, battle) | $set_chr_name($1) | $display.message($readini(translation.dat, status, PoisonKills), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead |  $increase.death.tally($1)  | $add.style.effectdeath | $check.clone.death($1)
      $goldorb_check($1,status) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
      if (%poison < %hp) {
        $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, PoisonMessage) | dec %hp %poison | writeini $char($1) Battle HP %hp |  unset %hp | unset %poison 

        if ($readini($char($1), Status, Sleep) = yes) { 
          var %enemy %real.name
          write $txtfile(temp_status.txt) $readini(translation.dat, status, WakesUp)
          writeini $char($1) status sleep no
        }

        return 

      }
    }
  }
  else { return }
}

HeavyPoison { 
  set %debug.location HeavyPoison
  set %max.hp $readini($char($1), basestats, hp)
  set %poison $round($calc(%max.hp * .20),0)
  set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
  unset %max.hp
  if (%poison >= %hp) { $display.message(%status.message, battle) | $display.message($readini(translation.dat, status, PoisonKills), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1) | $add.style.effectdeath | $check.clone.death($1)
  $goldorb_check($1, status) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
  if (%poison < %hp) { $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, PoisonMessage) | dec %hp %poison | writeini $char($1) Battle HP %hp | unset %hp | unset %poison 

    if ($readini($char($1), Status, Sleep) = yes) { 
      var %enemy %real.name
      write $txtfile(temp_status.txt) $readini(translation.dat, status, WakesUp)
      writeini $char($1) status sleep no
    }

    return  

  }
}

curse_check {
  set %debug.location curse_check

  if ($accessory.check($1, CurseAddDrain) = true) {
    writeini $char($1) status curse yes
    writeini $char($1) status curse.timer 0
    writeini $char($1) battle tp 0
    unset %accessory.amount
  }

  if ($readini($char($1), status, curse) = yes) { 
    set %curse.timer $readini($char($1), status, curse.timer)  
    if (%curse.timer < $status.effects.turns(curse)) { %curse.timer = $calc(%curse.timer + 1) | writeini $char($1) status curse.timer %curse.timer
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyCursed) | unset %curse.timer | return 
    }
    else {
      writeini $char($1) status curse no | writeini $char($1) status curse.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurseWornOff) | unset %curse.timer | return 
    }
  }
  else { return } 
}

regenerating_check { 
  set %debug.location regenerating_check
  if (($readini($char($1), Status, zombieregenerating) = yes) || ($readini($char($1), Status, ZombieRegenerating) = on)) { return }

  var %regen.check $readini($char($1), status, regenerating)
  if (%regen.check = $null) { var %regen.check no }
  if (($readini($char($1), status, auto-regen) = yes) || ($readini($char($1), status, auto-regen) = on)) { var %regen.check yes }

  if ((%regen.check = yes) || (%regen.check = on)) { 
    var %howmuch $skill.regen.calculate($1) | $set_chr_name($1)
    var %current.hp $readini($char($1), battle, HP) | inc %current.hp %howmuch | writeini $char($1) Battle HP %current.hp 
    $regen_done_check($1, %howmuch, HP)
  }
  else { return }
}

TPregenerating_check {
  set %debug.location TPregenerating_check
  if (($readini($char($1), Status, TPRegenerating) = yes) || ($readini($char($1), Status, TPRegenerating) = on)) { 
    var %howmuch $skill.TPregen.calculate($1) | $set_chr_name($1)
    var %current.tp $readini($char($1), battle, TP) | inc %current.tp %howmuch | writeini $char($1) Battle TP %current.tp 
    $regen_done_check($1, %howmuch, TP)
  }
  else { return }
}

regen_done_check { 
  set %debug.location regen_done_check
  var %current.regen.hp $readini($char($1), Battle, $3) | var %max.regen.hp $readini($char($1), BaseStats, $3)

  if ($readini($char($1), status, ignition.on) = on) {

    var %ignition.name $readini($char($1), status, ignition.name)

    ; get the ignition level
    var %ignition.level $readini($char($1), Ignitions, %ignition.name)

    ; get the ignition increase based on level
    var %ignition.increase 0
    if (%ignition.level > 1) { var %ignition.increase $calc(.10 * %ignition.level) }

    ; get the stat values
    var %hp.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), %ignition.name, hp))
    var %max.regen.hp $round($calc($readini($char($1), BaseStats, Hp) * %hp.increase),0)
  }

  if ($readini($char($1), Status, PotionEffect) = Double Life) { set %max.regen.hp $calc(%max.regen.hp * 2) } 

  if (($3 = hp) || ($3 = tp)) {
    if (%current.regen.hp >= %max.regen.hp) { 
      $set_chr_name($1) | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, skill, FinishedRegen)
      if ($3 = TP) { writeini $char($1) Status TPRegenerating no }
      if ($3 = HP) { writeini $char($1) Status Regenerating no }
      writeini $char($1) Battle $3 %max.regen.hp | return 
    }
    else { $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, skill, RegenerationMessage)  | return } 
  }

  else { $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, skill, RegenerationMessage) | return } 
}

zombieregenerating_check { 
  set %debug.location zombieregenerating_check
  if (($readini($char($1), Status, zombieregenerating) = yes) || ($readini($char($1), Status, ZombieRegenerating) = on)) { 
    var %howmuch $skill.zombieregen.calculate($1) | $set_chr_name($1)
    var %current.hp $readini($char($1), battle, HP) | inc %current.hp %howmuch | writeini $char($1) Battle HP %current.hp 

    var %current.zombie.hp $readini($char($1), Battle, hp) | var %max.zombie.hp $readini($char($1), BaseStats, hp)
    if (%current.zombie.hp >= %max.zombie.hp) {  writeini $char($1) Battle hp %max.zombie.hp }

    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, skill, ZombieRegeneration)  | return
  }
  else { return }
}

cocoon_check { 
  var %cocoon.timer $readini($char($1), status, cocoon.timer)  
  if (%cocoon.timer < $status.effects.turns(cocoon)) { 
    if ($readini($char($1), Status, cocoon) = yes) {
      %cocoon.timer = $calc(%cocoon.timer + 1) | writeini $char($1) status cocoon.timer %cocoon.timer
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyCocoonEvolve) | return 
    }
  }
  else { 
    if ($readini($char($1), Status, cocoon) = yes) {   

      if ($readini($char($1), descriptions, EvolveEnd) = $null) { set %skill.description $readini(translation.dat, status, CocoonWornOff) }
      else { set %skill.description $readini($char($1), descriptions, EvolveEnd) }
      $set_chr_name($1) | write $txtfile(temp_status.txt) 12 $+ %real.name  $+ %skill.description
      writeini $char($1) status cocoon no | writeini $char($1) status cocoon.timer 0
      unset %cocoon.timer | unset %skill.description $boost_monster_stats($1, evolve) | $fulls($1) | return
    }
  }
  return
}

weapon_locked {
  if ($readini($char($1), Status, weapon.locked) != $null) { 
    set %weaponlock.timer $readini($char($1), status, weaponlock.timer)  
    if (%weaponlock.timer < $status.effects.turns(weaponlock)) { %weaponlock.timer = $calc(%weaponlock.timer + 1) | writeini $char($1) status weaponlock.timer %weaponlock.timer
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyWeaponLocked) | unset %weaponlock.timer | return 
    }
    else {
      remini $char($1) status weapon.locked | writeini $char($1) status weaponlock.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, WeaponLockWornOff) | unset %weaponlock.timer | return 
    }
  }
  else { return } 
}

drunk_check {
  if ($readini($char($1), Status, drunk) = yes) { 
    set %drunk.timer $readini($char($1), status, drunk.timer)  
    if (%drunk.timer < $status.effects.turns(drunk)) { %drunk.timer = $calc(%drunk.timer + 1) | writeini $char($1) status drunk.timer %drunk.timer
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyDrunk) | unset %drunk.timer
      write $txtfile(temp_status.txt) $readini(translation.dat, status, TooDrunkToFight)  | set %too.drunk.to.fight true 
      return
    }
    else {
      writeini $char($1) status drunk no | writeini $char($1) status drunk.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, DrunkWornOff) | unset %drunk.timer | return 
    }
  }
  else { return } 
}

zombie_check { 
  if ($readini($char($1), monster, type) = zombie) { 
    writeini $char($1) status zombieregenerating on
    return 
  }
  var %zombie.timer $readini($char($1), status, zombie.timer)  
  if (%zombie.timer < $status.effects.turns(zombie)) { 
    if ($readini($char($1), Status, zombie) = yes) { %zombie.timer = $calc(%zombie.timer + 1) | writeini $char($1) status zombie.timer %zombie.timer |  writeini $char($1) status zombieregenerating on
    $set_chr_name($1) | return }
  }
  else { 
    if ($readini($char($1), Status, zombie) = yes) {   writeini $char($1) status zombie no | writeini $char($1) status zombie.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, ZombieWornOff) |  writeini $char($1) status zombieregenerating off | unset %zombie.timer | return  }
  }
  return
}

doll_check { 
  var %doll.timer $readini($char($1), status, doll.timer)  
  if (%doll.timer < $status.effects.turns(doll)) { 
    if ($readini($char($1), Status, doll) = yes) { %doll.timer = $calc(%doll.timer + 1) | writeini $char($1) status doll.timer %doll.timer |  writeini $char($1) status dollregenerating on
    $set_chr_name($1) | return }
  }
  else { 
    if ($readini($char($1), Status, doll) = yes) {   writeini $char($1) status doll no | writeini $char($1) status doll.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, dollWornOff) |  writeini $char($1) status dollregenerating off | unset %doll.timer | return  }
  }
  return
}

virus_check { 
  var %virus.timer $readini($char($1), status, virus.timer)  
  if (%virus.timer < $status.effects.turns(virus)) { 
    if ($readini($char($1), Status, virus) = yes) { %virus.timer = $calc(%virus.timer + 1) | writeini $char($1) status virus.timer %virus.timer
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyHasVirus) | return }
  }
  else { 
    if ($readini($char($1), Status, virus) = yes) {  writeini $char($1) status virus no | writeini $char($1) status virus.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, virusWornOff) |  writeini $char($1) status virusregenerating off | unset %virus.timer | return  }
  }
  return
}

slowed_check { 
  var %slow.timer $readini($char($1), status, slow.timer)  
  if (%slow.timer < $status.effects.turns(slow)) { 
    if ($readini($char($1), Status, slow) = yes) {  %slow.timer = $calc(%slow.timer + 1) | writeini $char($1) status slow.timer %slow.timer
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlyslowed) | return }
  }
  else { 
    if ($readini($char($1), Status, slow) = yes) {   writeini $char($1) status slow no | writeini $char($1) status slow.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, SlowWornOff)  | unset %slow.timer | return  }
  }
  return
}

ethereal_check {
  var %ethereal.timer $readini($char($1), status, ethereal.timer)  
  if (%ethereal.timer = $null) { var %ethereal.timer 0 }

  if (%ethereal.timer < $status.effects.turns(ethereal)) { 
    if ($readini($char($1), Status, Ethereal) = yes) { %ethereal.timer = $calc(%ethereal.timer + 1) | writeini $char($1) status ethereal.timer %ethereal.timer
    $set_chr_name($1) | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlyethereal) | unset %ethereal.timer | return }
  }
  else { 
    if ($readini($char($1), Status, Ethereal) = yes) {   writeini $char($1) status Ethereal no | writeini $char($1) status ethereal.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, EtherealWornOff)  | unset %ethereal.timer | return  }
  }
  return
}

amnesia_check {
  if ($readini($char($1), status, amnesia) = yes) { 
    set %amnesia.timer $readini($char($1), status, amnesia.timer)  
    if (%amnesia.timer < $status.effects.turns(amnesia)) { %amnesia.timer = $calc(%amnesia.timer + 1) | writeini $char($1) status amnesia.timer %amnesia.timer 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyHasAmensia) | unset %amnesia.timer | return 
    }
    else {
      writeini $char($1) status amnesia no | writeini $char($1) status amnesia.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, AmnesiaWornOff) | unset %amnesia.timer | return 
    }
  }
  else { return } 
}

charm_check {
  if ($readini($char($1), status, charmed) = yes) { 
    set %charm.timer $readini($char($1), status, charm.timer) | set %charmer $readini($char($1), status, charmer)
    var %charmer.status $readini($char(%charmer), battle, status)
    if ((%charmer.status = dead) || (%charmer.status = $null)) {  writeini $char($1) status charm.timer 1 | writeini $char($1) status charmed no | $set_chr_name(%charmer) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CharmerDeathWornOff) | unset %charm.timer | unset %charmer | return  }

    if (%charm.timer < $status.effects.turns(charm)) { %charm.timer = $calc(%charm.timer + 1) | writeini $char($1) status charm.timer %charm.timer 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyCharmedMessage) | unset %charm.timer | unset %charmer | return 
    }
    else {
      writeini $char($1) status charmed no | writeini $char($1) status charm.timer 0 | writeini $char($1) status charmer nooneIknowlol
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CharmWornOff) | unset %charm.timer | unset %charmer | return 
    }
  }
  else { return } 
}

confuse_check {
  if ($readini($char($1), status, confuse) = yes) { 
    set %confuse.timer $readini($char($1), status, confuse.timer) 
    if ((%confuse.timer = $null) || (%confuse.timer < $status.effects.turns(confuse))) {
      inc %confuse.timer 1 | writeini $char($1) status confuse.timer %confuse.timer 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyConfusedMessage) | unset %confuse.timer | return 
    }
    else {
      writeini $char($1) status confuse no | writeini $char($1) status confuse.timer 0
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, ConfuseWornOff) | unset %confuse.timer | return 
    }
  }
  else { return } 
}

paralysis_check {
  if ($readini($char($1), status, paralysis) = yes) { 
    var %paralysis.timer $readini($char($1), status, paralysis.timer)  
    if (%paralysis.timer = $null) { var %paralysis.timer 0 }
    if (%paralysis.timer < $status.effects.turns(paralysis)) { %paralysis.timer = $calc(%paralysis.timer + 1) | writeini $char($1) status paralysis.timer %paralysis.timer
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyParalyzed) | unset %paralysis.timer | return 
    }
    else {
      writeini $char($1) status paralysis no | writeini $char($1) status paralysis.timer 0
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, ParalysisWornOff) | unset %paralysis.timer | return 
    }
  }
  else { return } 
}

bored_check {
  if ($readini($char($1), status, bored) = yes) { 
    set %bored.timer $readini($char($1), status, bored.timer)  
    if (%bored.timer = $null) { set %bored.timer 0 }
    if (%bored.timer < $status.effects.turns(bored)) { %bored.timer = $calc(%bored.timer + 1) | writeini $char($1) status bored.timer %bored.timer
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyBored) | unset %bored.timer | return 
    }
    else {
      writeini $char($1) status bored no | writeini $char($1) status bored.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, BoredWornOff) | unset %bored.timer | return 
    }
  }
  else { return } 
}

reflect.check {
  if ($readini($char($1), status, reflect) = yes) { 
    set %reflect.timer $readini($char($1), status, reflect.timer)  
    if (%reflect.timer = $null) { set %reflect.timer 0 }
    if (%reflect.timer < $status.effects.turns(reflect)) { %reflect.timer = $calc(%reflect.timer + 1) | writeini $char($1) status reflect.timer %reflect.timer
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyReflected) | unset %reflect.timer | return 
    }
    else {
      writeini $char($1) status reflect no | writeini $char($1) status reflect.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, reflectWornOff) | unset %reflect.timer | return 
    }
  }
  else { return } 
}

invincible.status.check {
  if ($readini($char($1), status, invincible) = yes) { 
    set %invincible.timer $readini($char($1), status, invincible.timer)  

    if (%invincible.timer = $null) { set %invincible.timer 0 }
    if (%invincible.timer < $status.effects.turns(invincible)) { %invincible.timer = $calc(%invincible.timer + 1) | writeini $char($1) status invincible.timer %invincible.timer 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, Currentlyinvincible) | unset %invincible.timer | return 
    }
    else {
      writeini $char($1) status invincible no | writeini $char($1) status invincible.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, invincibleWornOff) | unset %invincible.timer | return 
    }
  }
  else { return } 
}

flying.status.check {
  if ($readini($char($1), status, flying) = yes) { 
    set %flying.timer $readini($char($1), status, flying.timer)  

    if (%flying.timer = $null) { set %flying.timer 0 }
    if (%flying.timer < $status.effects.turns(flying)) { %flying.timer = $calc(%flying.timer + 1) | writeini $char($1) status flying.timer %flying.timer 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyFlying) | unset %flying.timer | return 
    }
    else {
      writeini $char($1) status flying no | writeini $char($1) status flying.timer 0 
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, FlyingLand) | unset %flying.timer | return 
    }
  }
  else { return } 
}

; Statuses that skip turns but wear off after 1 turn
intimidated_check { 
  if ($readini($char($1), Status, intimidate) = yes) { 
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, TooIntimidatedToFight)
  }
  else { return } 
}

terrified_check { 
  if ($readini($char($1), Status, terrify) = yes) { 
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, TooTerrifiedToFight)
  }
  else { return } 
}

asleep_check {
  if ($readini($char($1), Status, Sleep) = yes) {
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyAsleep)
  }
  else { return } 
}

stunned_check {
  if ($readini($char($1), Status, Stun) = yes) {
  $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyStunned)  }
  else { return } 
}

stopped_check {
  if ($readini($char($1), Status, Stop) = yes) {
  $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, CurrentlyStopped)  }
  else { return } 
}

weight_check { 
  if ($readini($char($1), Status, weight) = yes) {
  $set_chr_name($1) | write $txtfile(temp_status.txt) $display.message($readini(translation.dat, status, CurrentlyWeighed),private) | return }
  else { return } 
}

staggered_check { 
  if ($readini($char($1), Status, staggered) = yes) {
    $set_chr_name($1) | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, TooStaggeredToFight)
    writeini $char($1) info CanStagger no
  }
  else { return } 
}

blind_check { 
  if ($readini($char($1), Status, blind) = yes) { 
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, TooBlindToFight)
  }
  else { return } 
}

petrified_check { 
  if ($readini($char($1), Status, petrified) = yes) { 
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, TooPetrifiedToFight)
  }
  else { return } 
}


; Magic status effects
frozen_check { 
  if ($readini($char($1), Status, frozen) = yes) { 
    set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    set %max.hp $readini($char($1), basestats, hp)
    set %freezing $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    if (%freezing >= %hp) { $display.message($readini(translation.dat, status, FrozenDeath), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  | $add.style.effectdeath | $check.clone.death($1)
    $goldorb_check($1, magiceffect) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    if (%freezing < %hp) { $set_chr_name($1) 
      if ($readini($char($1), info, IgnoreElementalMessage) != true) { write $txtfile(temp_status.txt) $readini(translation.dat, status, FrozenMessage) }
      dec %hp %freezing |  writeini $char($1) Battle HP %hp | return 
    }
  }
  else { return }
}

shock_check { 
  if ($readini($char($1), Status, shock) = yes) { 
    set %max.hp $readini($char($1), basestats, hp)
    set %shock $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%shock >= %hp) { $display.message($readini(translation.dat, status, ShockDeath), battle)  | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1) | $add.style.effectdeath | $check.clone.death($1)
    $goldorb_check($1,magiceffect) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) 
    if ($readini($char($1), info, IgnoreElementalMessage) != true) { write $txtfile(temp_status.txt) $readini(translation.dat, status, ShockMessage) }
    dec %hp %shock |  writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

burning_check { 
  if ($readini($char($1), Status, burning) = yes) {
    set %max.hp $readini($char($1), basestats, hp)
    set %burning $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%burning >= %hp) { $display.message($readini(translation.dat, status, BurningDeath), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  | $add.style.effectdeath | $check.clone.death($1)
    $goldorb_check($1,magiceffect) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) 
    if ($readini($char($1), info, IgnoreElementalMessage) != true) { write $txtfile(temp_status.txt) $readini(translation.dat, status, BurningMessage) }
    dec %hp %burning | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

tornado_check { 
  if ($readini($char($1), Status, tornado) = yes) { 
    set %max.hp $readini($char($1), basestats, hp)
    set %tornado $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%tornado >= %hp) { $display.message($readini(translation.dat, status, TornadoDeath), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  | $add.style.effectdeath | $check.clone.death($1)
    $goldorb_check($1,magiceffect) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) 
    if ($readini($char($1), info, IgnoreElementalMessage) != true) { write $txtfile(temp_status.txt) $readini(translation.dat, status, TornadoMessage) }
    dec %hp %tornado | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

drowning_check { 
  if ($readini($char($1), Status, drowning) = yes) {
    set %max.hp $readini($char($1), basestats, hp)
    set %drowning $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%drowning >= %hp) { $display.message($readini(translation.dat, status, DrowningDeath), battle)  | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  |  $add.style.effectdeath | $check.clone.death($1)
    $goldorb_check($1,magiceffect) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1)
    if ($readini($char($1), info, IgnoreElementalMessage) != true) {  write $txtfile(temp_status.txt) $readini(translation.dat, status, DrowningMessage) }
    writeini $char($1) Battle Status normal | dec %hp %drowning | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

earthquake_check { 
  if ($readini($char($1), Status, earthquake) = yes) { 
    set %max.hp $readini($char($1), basestats, hp)
    set %shaken $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%shaken >= %hp) { $display.message($readini(translation.dat, status, EarthquakeDeath),battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1) | $add.style.effectdeath | $check.clone.death($1)
    $goldorb_check($1,magiceffect) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) 
    if ($readini($char($1), info, IgnoreElementalMessage) != true) { write $txtfile(temp_status.txt) $readini(translation.dat, status, EarthquakeMessage)  }
    writeini $char($1) Battle Status normal | dec %hp %shaken | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

; stats status effects
defensedown_check { 
  var %defensedown.timer $readini($char($1), status, defensedown.timer)  
  if (%defensedown.timer = $null) { var %defensedown.timer 0 }
  if (%defensedown.timer < $status.effects.turns(defensedown)) { 
    if ($readini($char($1), Status, DefenseDown) = yes) {  %defensedown.timer = $calc(%defensedown.timer + 1) | writeini $char($1) status defensedown.timer %defensedown.timer
    $set_chr_name($1)  | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlydefensedown) | unset %defensedown.timer | return }
  }
  else { 
    if ($readini($char($1), Status, DefenseDown) = yes) { writeini $char($1) status DefenseDown no | writeini $char($1) status defensedown.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, DefenseDownWornOff)  | unset %defensedown.timer | return  }
  }
  return
}

strengthdown_check { 
  var %strengthdown.timer $readini($char($1), status, strengthdown.timer)  
  if (%strengthdown.timer = $null) { var %strengthdown.timer 0 }
  if (%strengthdown.timer < $status.effects.turns(strdown)) { 
    if ($readini($char($1), Status, strengthDown) = yes) {  %strengthdown.timer = $calc(%strengthdown.timer + 1) | writeini $char($1) status strengthdown.timer %strengthdown.timer
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlystrengthdown) | unset %strengthdown.timer | return }
  }
  else { 
    if ($readini($char($1), Status, strengthDown) = yes) {   writeini $char($1) status strengthDown no | writeini $char($1) status strengthdown.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, StrengthDownWornOff)  | unset %strengthdown.timer | return  }
  }
  return
}

intdown_check { 
  var %intdown.timer $readini($char($1), status, intdown.timer)  
  if (%intdown.timer = $null) { var %intdown.timer 0 }
  if (%intdown.timer < $status.effects.turns(intdown)) { 
    if ($readini($char($1), Status, intDown) = yes) { %intdown.timer = $calc(%intdown.timer + 1) | writeini $char($1) status intdown.timer %intdown.timer
    $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlyintdown) | unset %intdown.timer | return }
  }
  else { 
    if ($readini($char($1), Status, intDown) = yes) {   writeini $char($1) status intDown no | writeini $char($1) status intdown.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, intDownWornOff)  | unset %intdown.timer | return  }
  }
  return
}

intup_check { 
  var %intup.timer $readini($char($1), status, intup.timer)  
  if (%intup.timer = $null) { var %intup.timer 0 }
  if (%intup.timer < $status.effects.turns(intup)) { 
    if (($readini($char($1), Status, intup) = yes) || ($readini($char($1), Status, intup) = on)) { 
      if (($readini($char($1), status, intdown) = yes) || ($readini($char($1), status, intdown) = on)) { writeini $char($1) status intdown no | writeini $char($1) status intup no | return }
      %intup.timer = $calc(%intup.timer + 1) | writeini $char($1) status intup.timer %intup.timer
    $set_chr_name($1)  | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlyintup) | unset %intup.timer | return }
  }
  else { 
    if ($readini($char($1), Status, intup) = yes) {   writeini $char($1) status intup no | writeini $char($1) status intup.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, intupWornOff)  | unset %intup.timer | return  }
  }
  return
}

defenseup_check { 
  var %defenseup.timer $readini($char($1), status, defenseup.timer)  
  if (%defenseup.timer = $null) { var %defenseup.timer 0 }
  if (%defenseup.timer < $status.effects.turns(defup)) { 
    if (($readini($char($1), Status, defenseup) = yes) || ($readini($char($1), Status, defenseup) = on)) { 
      if (($readini($char($1), status, defensedown) = yes) || ($readini($char($1), status, defensedown) = on)) { writeini $char($1) status defensedown no | writeini $char($1) status defenseup no | return }
      %defenseup.timer = $calc(%defenseup.timer + 1) | writeini $char($1) status defenseup.timer %defenseup.timer
    $set_chr_name($1)  | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlydefenseup) | unset %defenseup.timer | return }
  }
  else { 
    if ($readini($char($1), Status, defenseup) = yes) {   writeini $char($1) status defenseup no | writeini $char($1) status defenseup.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, defenseupWornOff)  | unset %defenseup.timer | return  }
  }
  return
}

speedup_check { 
  var %speedup.timer $readini($char($1), status, speedup.timer)  
  if (%speedup.timer = $null) { var %speedup.timer 0 }
  if (%speedup.timer < $status.effects.turns(speedup)) { 
    if (($readini($char($1), Status, speedup) = yes) || ($readini($char($1), Status, speedup) = on)) { 
      if ($readini($char($1), status, slow) = yes) { writeini $char($1) status slow no | writeini $char($1) status speedup no | return }
      %speedup.timer = $calc(%speedup.timer + 1) | writeini $char($1) status speedup.timer %speedup.timer
    $set_chr_name($1)  | write $txtfile(temp_status.txt) $readini(translation.dat, status, currentlyspeedup) | unset %speedup.timer | return }
  }
  else { 
    if ($readini($char($1), Status, speedup) = yes) {   writeini $char($1) status speedup no | writeini $char($1) status speedup.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, speedupWornOff)  | unset %speedup.timer | return  }
  }
  return
}

; Shell & Protect
shell_check {
  var %shell.timer $readini($char($1), status, shell.timer)  
  if (%shell.timer = $null) { var %shell.timer 0 }
  if (%shell.timer < $status.effects.turns(shell)) { 
    if ($readini($char($1), Status, shell) = yes) { %shell.timer = $calc(%shell.timer + 1) | writeini $char($1) status shell.timer %shell.timer | unset %shell.timer | return }
  }
  else { 
    if ($readini($char($1), Status, shell) = yes) {   writeini $char($1) status shell no | writeini $char($1) status shell.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, shellWornOff)  | unset %shell.timer | return  }
  }
  return
}

protect_check {
  var %protect.timer $readini($char($1), status, protect.timer)  
  if (%protect.timer = $null) { var %protect.timer 0 }
  if (%protect.timer < $status.effects.turns(protect)) { 
    if ($readini($char($1), Status, Protect) = yes) { %protect.timer = $calc(%protect.timer + 1) | writeini $char($1) status protect.timer %protect.timer | unset %protect.timer | return }
  }
  else { 
    if ($readini($char($1), Status, Protect) = yes) {   writeini $char($1) status protect no | writeini $char($1) status protect.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, ProtectWornOff)  | unset %protect.timer | return  }
  }
  return
}

; Bar spells
bar_check {
  if ($readini($char($1), status, resist-fire) = yes) { %resists = $addtok(%resists, fire, 46)  }
  if ($readini($char($1), status, resist-earth) = yes) { %resists = $addtok(%resists, earth, 46) }
  if ($readini($char($1), status, resist-wind) = yes) { %resists = $addtok(%resists, wind, 46) }
  if ($readini($char($1), status, resist-ice) = yes) { %resists = $addtok(%resists, ice, 46) }
  if ($readini($char($1), status, resist-water) = yes) { %resists = $addtok(%resists, water, 46) }
  if ($readini($char($1), status, resist-lightning) = yes) { %resists = $addtok(%resists, lightning, 46) }
  if ($readini($char($1), status, resist-light) = yes) { %resists = $addtok(%resists, light, 46) }
  if ($readini($char($1), status, resist-dark) = yes) { %resists = $addtok(%resists, dark, 46) }

  if (%resists != $null) {
    ; CLEAN UP THE LIST
    if ($chr(046) isin %resists) { set %replacechar $chr(044) $chr(032)
      %resists = $replace(%resists, $chr(046), %replacechar)

      var %resists.bar Elemental Resists[ $+ %resists $+ ]
      $status_message_check(%resists.bar) 
    }
  }

  unset %resists
}

; En-spells
enspell_check {
  var %enspell.timer $readini($char($1), status, en-spell.timer)  
  if (%enspell.timer = $null) { var %enspell.timer 0 }
  if (%enspell.timer < $status.effects.turns(enspell)) { 
    if (($readini($char($1), Status, En-spell) != none) && ($readini($char($1), Status, En-Spell) != $null)) { var %enspell $readini($char($1), status, en-spell) | %enspell.timer = $calc(%enspell.timer + 1) | writeini $char($1) status en-spell.timer %enspell.timer | unset %enspell.timer | return }
  }
  else { 
    if ($readini($char($1), Status, En-Spell) != none) {   writeini $char($1) status en-spell none | writeini $char($1) status en-spell.timer 0 | $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, status, EnspellWornOff)  | unset %enspell.timer | return  }
  }
  return
}

; Boosts and Ignitions
ignition_check {
  if ($readini($char($1), Status, ignition.on) = on) { 
    set %original.ignition.name $readini($char($1), status, ignition.name)
    set %ignition.cost $readini($dbfile(ignitions.db), %original.ignition.name, IgnitionConsume)
    set %player.current.ig $readini($char($1), battle, ignitionGauge)

    ; You can uncomment the next line if you want ignitions to only consume half their IG cost if the player misses a turn due to a status effect.
    ;   if ((((($readini($char($1), status, blind) = yes) || ($readini($char($1), status, petrified) = yes) || ($readini($char($1), status, intimidated) = yes) || ($readini($char($1), status, stun) = yes) || ($readini($char($1), status, stop) = yes))))) { %ignition.cost = $round($calc(%ignition.cost / 2),0) }

    if (%player.current.ig < %ignition.cost) {  
      var %ignition.name $readini($dbfile(ignitions.db), $readini($char($1), status, ignition.name), name)
      $set_chr_name($1) | write $txtfile(temp_status.txt) $readini(translation.dat, system, IgnitionReverted) 
      writeini $char($1) status ignition.on off
      remini $char($1) status ignition.name | remini $char($1) status ignition.augment 
      $revert($1, %original.ignition.name)
      unset %ignition.name | unset %original.ignition.name | unset %ignition.cost | unset %player.current.ig
      return
    }

    dec %player.current.ig %ignition.cost
    writeini $char($1) battle IgnitionGauge %player.current.ig
    unset %ignition.name | unset %ignition.cost | unset %player.current.ig
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enmity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enmity {
  ; $1 = person
  ; $2 = add/remove/return
  ; $3 = amount for add/remove

  if ($1 = $null) { return }

  if ($2 = add) { 

    if ($1 = battlefield)  { return }

    if ($readini($char($1), skills, softblows.on) = on) { writeini $char($1) skills softblows.on off | return }

    var %current.enmity $readini($txtfile(battle2.txt), Enmity, $1)
    if (%current.enmity = $null) { var %current.enmity 0 }

    inc %current.enmity $3
    writeini $txtfile(battle2.txt) Enmity $1 %current.enmity
  }

  if ($2 = remove) { 
    var %current.enmity $readini($txtfile(battle2.txt), Enmity, $1)
    if (%current.enmity = $null) { var %current.enmity 0 }

    dec %current.enmity $3
    if (%current.enmity < 0) { var %current.enmity 0 }
    writeini $txtfile(battle2.txt) Enmity $1 %current.enmity
  }

  if ($2 = return) { 
    var %current.enmity $readini($txtfile(battle2.txt), Enmity, $1)
    if (%current.enmity = $null) { return 0 }
    else { return %current.enmity }
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Monster Outpost Alias
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
monster.outpost {
  if ($1 = status) {
    var %outpost.strength $readini($txtfile(battle2.txt), battle, outpostStrength)
    if (%outpost.strength = $null) { writeini $txtfile(battle2.txt) battle outpostStrength 10 | return 10 }
    else { return %outpost.strength }
  }
  if ($1 = remove) { 
    var %outpost.strength $readini($txtfile(battle2.txt), battle, outpostStrength)
    if (%outpost.strength = $null) { writeini $txtfile(battle2.txt) battle outpostStrength 10 | var %outpost.strength 10 }
    dec %outpost.strength $2
    writeini $txtfile(battle2.txt) battle OutpostStrength %outpost.strength
  }

  if ($1 = strengthbar) {
    var %outpost.strength $readini($txtfile(battle2.txt), battle, outpostStrength)
    if (%outpost.strength = $null) { var %outpost.strength 10 }

    if (%outpost.strength = 10) { return 3|||||||||| }
    if (%outpost.strength = 9) { return 3|||||||||5| }
    if (%outpost.strength = 8) { return 3||||||||5|| }
    if (%outpost.strength = 7) { return 3|||||||5||| }
    if (%outpost.strength = 6) { return 3||||||5|||| }
    if (%outpost.strength = 5) { return 3|||||5||||| }
    if (%outpost.strength = 4) { return 3||||5|||||| }
    if (%outpost.strength = 3) { return 3|||5||||||| }
    if (%outpost.strength = 2) { return 3||5|||||||| }
    if (%outpost.strength = 1) { return 3|5||||||||| }
    if (%outpost.strength <= 0) { return 5|||||||||| }
  }
}

;================================
; Aliases below this line are for special
; bosses/portals/monsters
;================================
portal.nailcount {
  var %infernal.nails.alive 0
  if ($readini($char(InfernalNail), battle, hp) > 0) { inc %infernal.nails.alive 1 }
  if ($readini($char(InfernalNail1), battle, hp) > 0) { inc %infernal.nails.alive 1 }
  if ($readini($char(InfernalNail2), battle, hp) > 0) { inc %infernal.nails.alive 1 }
  if ($readini($char(InfernalNail3), battle, hp) > 0) { inc %infernal.nails.alive 1 } 
  if ($readini($char(InfernalNail4), battle, hp) > 0) { inc %infernal.nails.alive 1 }  
  if ($readini($char(InfernalNail5), battle, hp) > 0) { inc %infernal.nails.alive 1 }  
  return %infernal.nails.alive
}

portal.ifritprime.aitype {
  var %ai.type normal
  if (%current.turn = 2) { var %ai.type techonly }
  if ((%current.turn = 5) && ($portal.nailcount > 0)) { var %ai.type techonly }
  if ((%current.turn = 5) && ($portal.nailcount <= 0)) { var %ai.type normal }
  if (%current.turn = 10) { var %ai.type techonly }

  return %ai.type
}

portal.calcabrina.calcasummon {
  var %calca.count 0
  var %brina.count 0

  if ($readini($char(Calca), battle, hp) > 0) { inc %calca.count 1 }
  if ($readini($char(Calca2), battle, hp) > 0) { inc %calca.count 1 }
  if ($readini($char(Calca3), battle, hp) > 0) { inc %calca.count 1 }
  if ($readini($char(Calca4), battle, hp) > 0) { inc %calca.count 1 }
  if ($readini($char(Brina), battle, hp) > 0) { inc %brina.count 1 }
  if ($readini($char(Brina2), battle, hp) > 0) { inc %brina.count 1 }
  if ($readini($char(Brina3), battle, hp) > 0) { inc %brina.count 1 }
  if ($readini($char(Brina4), battle, hp) > 0) { inc %brina.count 1 }

  if ((%calca.count = 0) && (%brina.count = 0)) { return Calcabrina }
}

hydra.head.calculate {
  ; The # of heads a hydra has is dependent on its health %
  ; Every 20% damage it loses 1 head.  At 20% or less it only has 1 max.

  var %current.hp.percent $round($calc(100 * ($current.hp($1) / $readini($char($1), BaseStats, HP))),0)

  var %max.heads $readini($char($1), Info, MaxHeads)
  if (%max.heads = $null) { var %max.heads 5 }

  if (%current.hp.percent >= 100) { return %max.heads }
  if ((%current.hp.percent < 100) && (%current.hp.percent >= 80)) {
    dec %max.heads 1
    if (%max.heads <= 0) { var %max.heads 1 }
    return %max.heads 
  }
  if ((%current.hp.percent < 80) && (%current.hp.percent >= 60)) {
    dec %max.heads 2
    if (%max.heads <= 0) { var %max.heads 1 }
    return %max.heads 
  }
  if ((%current.hp.percent < 60) && (%current.hp.percent >= 40)) {
    dec %max.heads 3
    if (%max.heads <= 0) { var %max.heads 1 }
    return %max.heads 
  }
  if ((%current.hp.percent < 40) && (%current.hp.percent >= 20)) {
    dec %max.heads 4
    if (%max.heads <= 0) { var %max.heads 1 }
    return %max.heads 
  }
  if (%current.hp.percent < 20) { return 1 }

}
