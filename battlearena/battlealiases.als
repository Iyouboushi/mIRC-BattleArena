;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if it's a
; person's turn or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_battle { 
  if (%wait.your.turn = on) { $display.system.message($readini(translation.dat, errors, WaitYourTurn), private) | halt }
  if ((%battleis = on) && (%who = $1)) { return }
  if ((%battleis = on) && (%who != $1)) { $display.system.message($readini(translation.dat, errors, WaitYourTurn), private) | halt }
  else { return  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if someone
; is in the battle or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
person_in_battle {
  set %temp.battle.list $readini($txtfile(battle2.txt), Battle, List)
  if ($istok(%temp.battle.list,$1,46) = $false) {  unset %temp.battle.list | $set_chr_name($1) 
    $display.system.message($readini(translation.dat, errors, NotInbattle),private) 
    unset %real.name | halt 
  }
  else { return }
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
; Checks for things that would
; stop a person from having
; a turn.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
no.turn.check {
  $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.system.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if ($readini($char($1), status, blind) != no) { $display.system.message($readini(translation.dat, status, TooBlindToFight),private) | halt }
  if ($readini($char($1), status, intimidated) != no) { $display.system.message($readini(translation.dat, status, TooIntimidatedToFight),private) | halt }
  if ($readini($char($1), status, paralysis) != no) { $display.system.message($readini(translation.dat, status, CurrentlyParalyzed),private) | halt }
  if ($readini($char($1), status, drunk) != no) { $display.system.message($readini(translation.dat, status, TooDrunkToFight2),private) | halt }
  if ($readini($char($1), status, petrified) != no) { $display.system.message($readini(translation.dat, status, TooPetrifiedToFight),private) | halt }
  if ($readini($char($1), status, stun) != no) { $display.system.message($readini(translation.dat, status, TooStunnedToFight),private) | halt }
  if ($readini($char($1), status, stop) != no) { $display.system.message($readini(translation.dat, status, CurrentlyStopped),private) | halt }
  if ($readini($char($1), status, sleep) != no) { $display.system.message($readini(translation.dat, status, CurrentlyAsleep),private) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the current streak
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
current.battlestreak {

  if (%battle.type = ai) { return  %ai.battle.level  }

  if (%portal.bonus != true) {
    var %temp.current.battlestreak $readini(battlestats.dat, battle, WinningStreak)
    if (%temp.current.battlestreak <= 0) { return $readini(battlestats.dat, battle, LosingStreak) }
    else { return %temp.current.battlestreak }
  }

  if (%portal.bonus = true) {
    var %current.portal.level $readini($txtfile(battle2.txt), battleinfo, portallevel)
    if (%current.portal.level = $null) { return 500 } 
    else { return %current.portal.level }
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two functions are for
; Checking for Double Turns
; And randomly giving one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_double_turn {  $set_chr_name($1)
  set %debug.location alias check_for_double_turn

  $battle.check.for.end

  unset %wait.your.turn

  $random.doubleturn.chance($1)
  if ($readini($char($1), skills, doubleturn.on) = on) { 
    if ($readini($char($1), info, flag) != $null) {   /.timerBattleNext 1 45 /next }
    if ($readini($char($1), info, flag) = $null) {
      var %nextTimer $readini(system.dat, system, TimeForIdle)
      if (%nextTimer = $null) { var %nextTimer 180 }
      /.timerBattleNext 1 %nextTimer /next
    }

    if ($readini($char($1), battle, hp) <= 0) { $next | halt }

    $checkchar($1) | writeini $char($1) skills doubleturn.on off | $set_chr_name($1) 

    if ($person_in_mech($1) = true) { %real.name = %real.name $+ 's $readini($char($1), mech, name) }

    $display.system.message(12 $+ %real.name gets another turn.,battle) 

    set %user.gets.second.turn true

    $aicheck($1) | halt 
  }

  else { $next | halt }
}

random.doubleturn.chance {
  set %debug.location alias doubleturn.chance
  if (%battleis = off) { return }
  if ($1 = demon_portal) { return }
  if ($1 = !use) { return }
  if (%multiple.wave.noaction = yes) { unset %multiple.wave.noaction | return }
  if ($readini($char($1), battle, hp) <= 0) { return }
  if ($readini($char($1), Status, cocoon) = yes) { return }

  $battle.check.for.end

  if ($readini($char($1), skills, doubleturn.on) != on) {
    var %double.turn.chance $rand(1,100)
    if ($augment.check($1, EnhanceDoubleTurnChance) = true) {  inc %double.turn.chance $calc(2 * %augment.strength) }
    if ($readini($char($1), info, flag) = monster) { inc %double.turn.chance $rand(1,5) }

    if (%double.turn.chance >= 99) { writeini $char($1) skills doubleturn.on on | $set_chr_name($1) 
      $display.system.message($readini(translation.dat, system, RandomChanceGoesAgain),battle) 
    }
  }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function boosts
; summons
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
  if (%m.flag = $null) { inc %summon.level $round($calc($get.level($1) / 1.5),0) }

  $monster_spend_points($1 $+ _summon, %summon.level, bloodpact, $3)
  $monster_boost_hp($1 $+ _summon, bloodpact, %summon.level, $3)

  var %tp $readini($char($1 $+ _summon), BaseStats, TP)
  inc %tp $round($calc(%tp * %summon.level),0) 
  writeini $char($1 $+ _summon) BaseStats TP %tp

  $fulls($1 $+ _summon)

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function boosts
; monsters and npcs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boost_monster_stats {
  set %debug.location alias boost_monster_stats
  ; $1 = monster
  ; $2 = type (rage, warmachine, demonwall, etc)

  if ($readini($char($1), info, BattleStats) = ignore) { return }

  var %hp $readini($char($1), BaseStats, HP)
  var %tp $readini($char($1), BaseStats, TP)
  var %str $readini($char($1), BaseStats, Str)
  var %def $readini($char($1), BaseStats, Def)
  var %int $readini($char($1), BaseStats, Int)
  var %spd $readini($char($1), BaseStats, Spd)

  var %winning.streak $readini(battlestats.dat, battle, winningstreak)
  var %level.boost $readini(battlestats.dat, battle, LevelAdjust)
  var %number.of.players.in.battle $readini($txtfile(battle2.txt), battleinfo, players)
  var %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
  var %current.player.levels $readini($txtfile(battle2.txt), battleinfo, playerlevels)  
  var %monster.level 0

  if (%battle.type = ai) { set %winning.streak %ai.battle.level }

  if ($readini(system.dat, system, PlayersMustDieMode) = true) { inc %level.boost $rand(5,10) }

  if (%number.of.players.in.battle = $null) { var %number.of.players.in.battle 1 }

  if (%winning.streak <= 0) { var %winning.streak $calc($readini(battlestats.dat, battle, losingstreak) * -1) }

  inc %monster.level %level.boost
  inc %monster.level %difficulty
  inc %monster.level %winning.streak

  var %boss.level $readini($char($1), info, bosslevel) 
  if (%boss.level != $null) { 
    if (%boss.level > %winning.streak) { var %monster.level %boss.level }
  }


  if (%monster.level <= 0) { var %monster.level 1 }

  if ($2 = warmachine) { 
    var %boss.level $readini($char($1), info, bosslevel) 
    if (%boss.level = $null) { var %boss.level %winning.streak }
    if (%winning.streak < %boss.level) { var %winning.streak %boss.level }
  }

  if ($2 = mimic) { 
    var %boss.level $readini($char($1), info, bosslevel) 
    if (%boss.level = $null) { var %boss.level %winning.streak }
    if (%winning.streak < %boss.level) { var %winning.streak %boss.level }
  }

  if ($2 = elderdragon) { 
    var %boss.level $readini($char($1), info, bosslevel) 
    if (%boss.level = $null) { var %boss.level %winning.streak }
    if (%winning.streak < %boss.level) { var %winning.streak %boss.level }
  }

  ; $2 = portal is for the portal item boss fights.
  if ($2 = portal) { 
    var %boss.level $readini($char($1), info, bosslevel) 

    if (%boss.level = $null) { var %boss.level 500 }

    inc %boss.level $rand(1,3)
    var %monster.level %boss.level
  }

  ; $2 = monstersummon is for the monster summon special skill
  if ($2 = monstersummon) { 
    var %temp.level $get.level($3)
    var %monster.level $round($calc(%temp.level / 2),0)

    if (%monster.level <= 1) { var %monster.level 2 }
  }

  if (%mode.gauntlet.wave != $null) {  
    if (%mode.gauntlet.wave <= 50) { inc %monster.level $round($calc(%mode.gauntlet.wave * 2.1),0) }
    if ((%mode.gauntlet.wave > 50) && (%mode.gauntlet.wave <= 100)) {  inc %monster.level $round($calc(%mode.gauntlet.wave * 2.5),0) }
    if (%mode.gauntlet.wave > 100) {  inc %monster.level $round($calc(%mode.gauntlet.wave * 3),0) }
    inc %winning.streak %mode.gauntlet.wave
  }

  if ($readini($char($1), info, BattleStats) = hp) {  $monster_boost_hp($1, $2, %monster.level) |  return }
  if ($1 = demon_portal) { $monster_boost_hp($1, $2, %monster.level) |  return }
  if ($1 = orb_fountain) { $monster_boost_hp($1, $2, %winning.streak) |  return }
  if ($1 = lost_soul) { $monster_boost_hp($1, $2, %winning.streak) |  return }

  if ($2 = evolve) { 
    if ($isfile($boss($1)) = $false) { inc %monster.level $rand(5,10) }
    if ($isfile($boss($1)) = $true) { inc %monster.level $rand(10,20)  }
  }

  if ($2 = rage) { %monster.level = $calc(%monster.level * 10) }

  $monster_spend_points($1, %monster.level, $2) 
  $monster_boost_hp($1, $2, %monster.level)

  if ($2 != doppelganger) { 
    if (%monster.level >= 1000) { %tp = $round($calc(%tp + (%monster.level * 1)),0) }
    if (%monster.level < 1000) {  %tp = $round($calc(%tp + (%monster.level * 5)),0) }
    writeini $char($1) BaseStats TP %tp
  }

  if (($2 != doppelganger) && ($readini($char($1), info, IgnoreWeaponBoost) != true)) {
    ; Set the weapon's power based on the streak if it's higher than the monster's current weapon level
    set %current.monster.weapon $readini($char($1), weapons, equipped)
    set %current.monster.weapon.level $readini($char($1), weapons, %current.monster.weapon)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Formula 1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ($readini(system.dat, system, BattleDamageFormula) = 1) { 
      if (%current.monster.weapon.level < %winning.streak) { set %current.monster.weapon.level $round($calc(%winning.streak / 2),0) | writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level }
    }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Formula 2 & 3
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ($readini(system.dat, system, BattleDamageFormula) >= 2) { 
      if (%current.monster.weapon.level < %winning.streak) { set %current.monster.weapon.level.temp $round($calc(%winning.streak / 5),0) 
        if (%current.monster.weapon.level.temp < %current.monster.weapon.level) { writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level }
        else { writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level.temp }
      }
    }


  }
  unset %increase.amount | unset %current.monster.weapon | unset %current.monster.weapon.level
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for boosting
; monster's/npcs's total hp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
monster_boost_hp {
  ; $1 = monster
  ; $2 = same as in the boost mon alias
  ; $3 = monster level
  ; $4 = used for summons (original summon's name)

  if ($readini($char($1), info, BattleStats) = ignoreHP) { return }

  set %hp $readini($char($1), BaseStats, HP)
  var %increase.amount 0

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; FORMULA 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 1) { 

    if ($2 = doppelganger) {  var %increase.amount $calc($3 * 2) }
    if ($2 = warmachine) {  var %increase.amount $calc($3 * 5) }
    if ($2 = demonwall) {  var %increase.amount $calc($3 * 3) }
    if ($2 = evolve) { var %increase.amount $calc($3 * 2) }
    if ($2 = bloodpact) { var %increase.amount $calc($3 * 15) }
    if ($2 = elderdragon) {  var %increase.amount $calc($3 * 15) }

    if (($2 = $null) || ($2 = monstersummon)) { 
      if ($isfile($boss($1)) = $true) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 30) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 35) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 40) }
        if ($3 > 600) { var %increase.amount $calc($3 * 45) }

      }
      if ($isfile($boss($1)) = $false) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 10) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 15) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 20) }
        if ($3 > 600) { var %increase.amount $calc($3 * 25) }
      }
      if ($isfile($npc($1)) = $true) {  var %increase.amount $calc($3 * 15) }
      if ($isfile($summon($4)) = $true) {   var %increase.amount $calc($3 * 15) }
    }


    if (%increase.amount = 0) { inc %increase.amount $rand(1,10) }

    %hp = $round($calc(%hp + %increase.amount),0)

    var %winning.streak $readini(battlestats.dat, battle, winningstreak)
    if (%winning.streak < 10000) {
      if (%hp > 100000) { %hp = 100000 }
    }

    if (%hp <= 0) { %hp = 10 }

    if ($2 = portal) {
      var %boss.level $readini($char($1), info, bosslevel) 
      if (%boss.level = $null) { var %boss.level 500 }

      if (%boss.level <= 10) { inc %hp $rand(1000,2000) }
      if ((%boss.level > 10) && (%boss.level <= 50)) { inc %hp $rand(2500,5000) }
      if ((%boss.level > 50) && (%boss.level <= 100))  { inc %hp 10000 }
      if ((%boss.level > 100) && (%boss.level <= 200)) { inc %hp 15000 }
      if ((%boss.level > 200) && (%boss.level <= 500)) { inc %hp 40000 }
      if ((%boss.level > 500) && (%boss.level <= 800)) { inc %hp 50000 }
      if ((%boss.level > 800) && (%boss.level < 1000)) { inc %hp 80000 }
      if (%boss.level > 1000) { inc %hp 100000 }
    }

    %hp = $round($calc(%hp + %increase.amount),0)
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; FORMULAS 2 & 3
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) >= 2) { 

    if ($2 = doppelganger) {  var %increase.amount $calc($3 * 1.5) }
    if ($2 = warmachine) {  var %increase.amount $calc($3 * 2) }
    if ($2 = elderdragon) {  var %increase.amount $calc($3 * 3) }
    if ($2 = demonwall) {  var %increase.amount $calc($3 * 2) }
    if ($2 = evolve) { var %increase.amount $calc($3 * 1.5) }
    if ($2 = monstersummon) { var %increase.amount $calc($3 * 1.5) }

    if (($2 = $null) || ($2 = monstersummon)) { 
      if ($isfile($boss($1)) = $true) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 16) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 19) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 20) }
        if ($3 > 600) { var %increase.amount $calc($3 * 25) }

        if (%portalbonus = true) { inc %increase.amount $rand(100,1000) }

        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        if (%hp > 15000) { %hp = $rand(15000,16000) }
        if (%hp <= 0) { %hp = 10 }
      }

      if ($isfile($boss($1)) = $false) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 3) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 4) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 5) }
        if ($3 > 600) { var %increase.amount $calc($3 * 6) }
        if (%increase.amount = 0) { inc %increase.amount $rand(1,10) }

        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        var %winning.streak $readini(battlestats.dat, battle, winningstreak)
        if (%winning.streak < 10000) {
          if (%hp > 6000) { %hp = $rand(6000,6100) }
        }
        if (%hp <= 0) { %hp = 10 }
      }
      if ($isfile($npc($1)) = $true) {  
        var %increase.amount $calc($3 * 5)
        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        if (%hp > 10000) { %hp = 10000 }
        if (%hp <= 0) { %hp = 10 }
        %hp = $round($calc(%hp + %increase.amount),0)

      }
      if ($isfile($summon($4)) = $true) {   

        var %increase.amount $calc($3 * 3)
        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        if (%hp > 8000) { %hp = 8000 }
        if (%hp <= 0) { %hp = 10 }
      }

    }

    if ($2 = bloodpact) { var %increase.amount $calc($3 * 5) 
      if (%increase.amount = 0) { inc %increase.amount $rand(1,10) }

      %hp = $round($calc(%hp + %increase.amount),0) 

      if (%hp > 8000) { %hp = 8000 }
      if (%hp <= 0) { %hp = 10 }
    }

    if ($2 = portal) {
      var %boss.level $readini($char($1), info, bosslevel) 
      if (%boss.level = $null) { var %boss.level 500 }

      if (%boss.level <= 10) { inc %hp $rand(300,400) }
      if ((%boss.level > 10) && (%boss.level <= 50)) { inc %hp $rand(500,800) }
      if ((%boss.level > 50) && (%boss.level <= 100))  { inc %hp $rand(1000,1500) }
      if ((%boss.level > 100) && (%boss.level <= 200)) { inc %hp $rand(1200,1800) }
      if ((%boss.level > 200) && (%boss.level <= 500)) { inc %hp $rand(2000,2500) }
      if ((%boss.level > 500) && (%boss.level <= 800)) { inc %hp $rand(3000,3500) }
      if ((%boss.level > 800) && (%boss.level <= 1000)) { inc %hp $rand(7000,7500) }
      if (%boss.level > 1000) { inc %hp $rand(10000,15000) }

      %hp = $round($calc(%hp + %increase.amount),0)
      inc %hp $round($calc($readini($txtfile(battle2.txt), BattleInfo, PlayerLevels) * .10),0)

    }
  }

  if ($2 = rage) { %hp = $rand(120000,150000) }


  if (%battle.type = ai) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { var %hp $rand(2000,2500) }
    if ($readini(system.dat, system, IgnoreDmgCap) = true) { var %hp $rand(10000,15000) }

    var %increase.multiplier $round($calc(%ai.battle.level / 100),1)
    var %more.hp $round($calc(150 * %increase.multiplier),0)
    inc %hp %more.hp
  }


  if ($readini(system.dat, system, BattleDamageFormula) = 3) { 
    if ($2 != portal) { inc %hp $readini(battlestats.dat, battle, WinningStreak) }
  }

  writeini $char($1) BaseStats HP %hp  
  unset %hp
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function lets monsters
; and npcs spend points
; to make them be the right
; level.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
monster_spend_points {
  ; $1 = monster
  ; $2 = monster's level 
  ; $3 = type of battle
  ; $4 = is used for the original summon's name

  var %str $readini($char($1), basestats, str)
  var %def $readini($char($1), basestats, def)
  var %int $readini($char($1), basestats, int)
  var %spd $readini($char($1), basestats, spd)

  var %unspent.monster.points $get.unspentpoints($1, $2, $3, $4)

  if ($3 = rage) { inc %unspent.monster.points 9999999 }
  if ($3 = Doppelganger) { var %unspent.monster.points 200 }
  if ($3 = DemonWall) { inc %unspent.monster.points 200 }
  if ($3 = Warmachine) { inc %unspent.monster.points 200 }
  if ($3 = ElderDragon) { inc %unspent.monster.points 400 }
  if ($3 = evolve) { inc %unspent.monster.points $rand(100,500) } 
  if ($3 = monstersummon) { inc %unspent.monster.points $rand(20,50) } 

  if ($readini(system.dat, system, PlayersMustDieMode) = true) { inc %unspent.monster.points $rand(200,400) }

  if (%unspent.monster.points <= 0) { return }

  var %total.percent 100

  var %str.percent $rand(40,45)
  dec %total.percent %str.percent

  var %def.percent $rand(30,35)
  dec %total.percent %def.percent

  var %int.percent $rand(25,35)
  dec %total.percent %int.percent

  var %spd.percent %total.percent
  if (%spd.percent <= 0) { var %spd.percent 1 }

  var %str.points $round($calc((%str.percent * .01) * %unspent.monster.points),0)
  dec %unspent.monster.points %str.points

  var %def.points $round($calc((%def.percent * .01) * %unspent.monster.points),0)
  dec %unspent.monster.points %def.points

  var %int.points $round($calc((%int.percent * .01) * %unspent.monster.points),0)
  dec %unspent.monster.points %int.points

  var %spd.points %unspent.monster.points
  dec %unspent.monster.points %spd.points

  %str = $round($calc(%str + %str.points),0) 
  %def = $round($calc(%def + %def.points),0) 
  %int = $round($calc(%int + %int.points),0) 
  %spd = $round($calc(%spd + %spd.points),0) 

  writeini $char($1) BaseStats Str %str
  writeini $char($1) BaseStats Def %def
  writeini $char($1) BaseStats Int %int
  if ($3 != doppelganger) { writeini $char($1) BaseStats Spd %spd }

  var %level.difference $calc($2 - $get.level.basestats($1))
  if ((%level.difference > 0) && ($readini($char($1), info, flag) = monster)) {
    inc %spd $round($calc(%level.difference * 36),0)
    if ($3 != doppelganger) { writeini $char($1) BaseStats Spd %spd }
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function lets players
; sync their level to another
; level.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
levelsync {
  ; $1 = player
  ; $2 = level to sync to

  var %str $readini($char($1), battle, str)
  var %def $readini($char($1), battle, def)
  var %int $readini($char($1), battle, int)
  var %spd $readini($char($1), battle, spd)

  var %unspent.player.points $calc(20 * $2)
  var %total.percent 100

  var %str.percent $rand(30,35)
  dec %total.percent %str.percent

  var %def.percent $rand(30,35)
  dec %total.percent %def.percent

  var %int.percent $rand(30,35)
  dec %total.percent %int.percent

  var %spd.percent %total.percent
  if (%spd.percent <= 0) { var %spd.percent 1 }

  var %str.points $round($calc((%str.percent * .01) * %unspent.player.points),0)
  dec %unspent.player.points %str.points

  var %def.points $round($calc((%def.percent * .01) * %unspent.player.points),0)
  dec %unspent.player.points %def.points

  var %int.points $round($calc((%int.percent * .01) * %unspent.player.points),0)
  dec %unspent.player.points %int.points

  var %spd.points %unspent.player.points
  dec %unspent.player.points %spd.points

  %str = $round($calc(%str + %str.points),0) 
  %def = $round($calc(%def + %def.points),0) 
  %int = $round($calc(%int + %int.points),0) 
  %spd = $round($calc(%spd + %spd.points),0) 

  writeini $char($1) battle Str %str
  writeini $char($1) battle Def %def
  writeini $char($1) battle Int %int
  writeini $char($1) battle Spd %spd

  if ($get.level($1) != $2) {
    var %level.difference $round($calc($2 - $get.level($1)),0)
    var %str.points $calc(18 * %level.difference)
    inc %str %str.points
    writeini $char($1) battle Str %str
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

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  set %attack.damage $round(%attack.damage, 0)

  if (%guard.message != $null) { set %attack.damage 0 }

  if ((%attack.damage > 0) && ($readini($char($2), Status, Sleep) = yes)) { 
    $display.system.message($readini(translation.dat, status, WakesUp), battle) 
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

    if ($readini($char($2), info, flag) != $null) {
      var %naturalArmorCurrent $readini($char($2), NaturalArmor, Current)

      if ((%naturalArmorCurrent != $null) && (%naturalArmorCurrent > 0)) {
        set %naturalArmorName $readini($char($2), NaturalArmor, Name) 
        set %difference $calc(%attack.damage - %naturalArmorCurrent)
        dec %naturalArmorCurrent %attack.damage | writeini $char($2) NaturalArmor Current %naturalArmorCurrent

        if (%naturalArmorCurrent <= 0) { set %attack.damage %difference | writeini $char($2) naturalarmor current 0
          if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {  $display.system.message($readini(translation.dat, battle, NaturalArmorBroken),battle) }
          if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, NaturalArmorBroken)) }
          unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
        }
        if (%naturalArmorCurrent > 0) { set %guard.message $readini(translation.dat, battle, NaturalArmorAbsorb) | set %attack.damage 0 }

        unset %difference
      }
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
  if ($3 != renkei) { $add.stylepoints($1, $2, %attack.damage, $3) }

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
      writeini $char($2) battle status dead 
      writeini $char($2) battle hp 0

      ; give some ignition points if necessary
      $battle.reward.ignitionGauge.single($2)

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
      }
    }
  }

  $ai.learncheck($2, $3)

  if (%guard.message = $null) { $renkei.calculate($1, $2, $3) }

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

  unset %overkill |  unset %style.rating | unset %target
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  ; Show a random attack description
  if ($3 = weapon) { 

    if (%counterattack != shield) {

      if (%counterattack != on ) {   var %weapon.type $readini($dbfile(weapons.db), $4, type) |  var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)  }

      if (%counterattack = on) { 
        set %weapon.equipped $readini($char($2), weapons, equipped)
        set  %weapon.type $readini($dbfile(weapons.db), %weapon.equipped, type)
        var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)
        unset %weapon.equipped | unset %weapon.type
        $display.system.message($readini(translation.dat, battle, MeleeCountered), battle)
        $set_chr_name($1) | set %enemy %real.name | set %target $1 | $set_chr_name($2) | set %user %real.name 
      }

    $display.system.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)  }
  }

  if (%counterattack = shield) {
    var %weapon.equipped $readini($char($1), weapons, equipped)
    set  %weapon.type $readini($dbfile(weapons.db), %weapon.equipped, type)
    var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)

    $display.system.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)  

    $display.system.message($readini(translation.dat, battle, ShieldCountered), battle)
    $set_chr_name($1) | set %enemy %real.name | set %target $1 | $set_chr_name($2) | set %user %real.name 
  }

  if (%shield.block.line != $null) { $display.system.message(%shield.block.line, battle) | unset %shield.block.line }

  if ($3 = tech) {
    if (%showed.tech.desc != true) { $display.system.message(3 $+ %user $+  $readini($dbfile(techniques.db), $4, desc), battle) }

    if ($readini($dbfile(techniques.db), $4, magic) = yes) {
      ; Clear elemental seal
      if ($readini($char($1), skills, elementalseal.on) = on) {  writeini $char($1) skills elementalseal.on off   }
      if ($readini($char($2), status, reflect) = yes) { 
        if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {  $display.system.message($readini(translation.dat, skill, MagicReflected),battle) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, skill, MagicReflected)) }

      $set_chr_name($1) | set %enemy %real.name | set %target $1 | writeini $char($2) status reflect no | writeini $char($2) status reflect.timer 0  }
    }
  }

  if ($3 = item) {
    $display.system.message(3 $+ %user $+  $readini($dbfile(items.db), $4, desc), battle)
  }

  if ($3 = fullbring) { $display.system.message(3 $+ %user $+  $readini($dbfile(items.db), $4, fullbringdesc), battle) } 

  if ($3 = renkei) { $display.system.message($readini(translation.dat, system, RenkeiPerformed) 3 $+ %renkei.description, battle) |  unset %style.rating  }

  ; Show the damage
  if ((($3 != item) && ($3 != renkei) && ($1 != battlefield))) { 

    if (%counterattack = on) { $calculate.stylepoints($2) }
    if (%counterattack != on) { 

      if (($readini($char($1), info, flag) != monster) && (%target != $1)) { 
        if ($1 != $2) { $calculate.stylepoints($1)  }
      }

    }

  }

  if (((((((%double.attack = $null) && (%triple.attack = $null) && (%fourhit.attack = $null) && (%fivehit.attack = $null) && (%sixhit.attack = $null) && (%sevenhit.attack = $null) && (%eighthit.attack = $null))))))) { 

    if ($3 != aoeheal) {
      if (%guard.message = $null) {  $display.system.message(The attack did4 $bytes(%attack.damage,b) damage to %enemy %style.rating, battle) 
      }
      if (%guard.message != $null) { $display.system.message(%guard.message,battle) 
      }
      if (%element.desc != $null) {  $display.system.message(%element.desc, battle) 
        unset %element.desc 
      }
    }
    if ($3 = aoeheal) { 
      if (%guard.message = $null) {  $display.system.message(The attack did4 $bytes(%attack.damage,b) damage to %enemy %style.rating, battle)    }
      if (%guard.message != $null) { $display.system.message(%guard.message,battle)  }
      if (%element.desc != $null) {  $display.system.message(%element.desc,battle) 
        unset %element.desc 
      }
    }
  }

  if (%double.attack = true) { 
    if (%guard.message = $null) {  var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating 
      $display.system.message(%damage.message,battle)
    }
    if (%guard.message != $null) { $display.system.message(%guard.message,battle)  }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }
  if (%triple.attack = true) {  
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      $display.system.message(%damage.message,battle) 
    }
    if (%guard.message != $null) { $display.system.message(%guard.message,battle)  }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%fourhit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      $display.system.message(%damage.message,battle) 
    }
    if (%guard.message != $null) {  $display.system.message(%guard.message,battle)   }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%fivehit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating 
      $display.system.message(%damage.message,battle) 
    }
    if (%guard.message != $null) { $display.system.message(%guard.message,battle)  }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%sixhit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. The sixth attack did4 $bytes(%attack.damage6,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      $display.system.message(%damage.message,battle) 
    }
    if (%guard.message != $null) { $display.system.message(%guard.message,battle)   }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%sevenhit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. The sixth attack did4 $bytes(%attack.damage6,b) damage. The seventh attack did4 $bytes(%attack.damage7,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating 
      $display.system.message(%damage.message,battle) 
    }
    if (%guard.message != $null) { $display.system.message(%guard.message,battle) 
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%eighthit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. The sixth attack did4 $bytes(%attack.damage6,b) damage. The seventh attack did4 $bytes(%attack.damage7,b) damage.  The eight attack did4 $bytes(%attack.damage8,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      $display.system.message(%damage.message,battle) 
    }
    if (%guard.message != $null) { $display.system.message(%guard.message,battle)  }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%target = $null) { set %target $2 }

  if (%statusmessage.display != $null) { 
    if ($readini($char(%target), battle, hp) > 0) { $display.system.message(%statusmessage.display,battle) 
      unset %statusmessage.display 
    }
  }

  if (%absorb = absorb) {
    if (%guard.message = $null) {
      ; Show how much the person absorbed back.
      var %absorb.amount $round($calc(%attack.damage / 3),0)
      if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
      $display.system.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.,battle) 
      unset %absorb
    }
  }

  if (%drainsamba.on = on) {
    if (%guard.message = $null) {
      if (($readini($char(%target), monster, type) != undead) && ($readini($char(%target), monster, type) != zombie)) { 
        var %absorb.amount $round($calc(%attack.damage / 3),0)
        if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
        if (%absorb.amount <= 0) { var %absorb.amount 1 }
        $display.system.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.,battle) 
        set %life.target $readini($char($1), Battle, HP) | set %life.max $readini($char($1), Basestats, HP)
        inc %life.target %absorb.amount
        if (%life.target >= %life.max) { set %life.target %life.max }
        writeini $char($1) battle hp %life.target
        unset %life.target | unset %life.target | unset %absorb.amount 
      }
    }
  }
  if (%absorb.message != $null) { 
    if (%guard.message = $null) { $display.system.message(%absorb.message,battle) 
      unset %absorb.message
    }
  }

  unset %guard.message


  ; Check for inactive..
  if ($readini($char(%target), battle, status) = inactive) {
    if ($readini($char(%target), battle, hp) > 0) { 
      if ($readini($char($1), info, flag) != monster) { 
        writeini $char(%target) battle status alive
        $display.system.message($readini(translation.dat, battle, inactivealive),battle)       
      }
    }
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char(%target), battle, HP) <= 0) { 

    $increase_death_tally(%target)
    $achievement_check(%target, SirDiesALot)
    $gemconvert_check($1, %target, $3, $4)
    if (%attack.damage > $readini($char(%target), basestats, hp)) { set %overkill 7<<OVERKILL>> }

    $display.system.message($readini(translation.dat, battle, EnemyDefeated),private)

    ; check to see if a clone or summon needs to die with the target
    $check.clone.death(%target)

    if ($readini($char(%target), info, flag) != $null) {  $random.healing.orb($1,%target)  }

    if ($readini($dbfile(techniques.db), $4, magic) = yes) { $goldorb_check(%target, magic)  }
    if ($readini($dbfile(techniques.db), $4, magic) != yes) { $goldorb_check(%target, $3) }

    if ($readini($char($1), info, flag) = $null) {
      ; increase the death tally of the target
      if ($readini($char(%target), battle, status) = dead) {  $increase.death.tally(%target)  }
    }

    $spawn_after_death(%target)
    remini $char(%target) Renkei
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
        $display.system.message($readini(translation.dat, status, StaggerHappens),battle) 
      }

      unset %stagger.amount.needed
    }

    if ($3 = tech) { unset %attack.damage | $renkei.check($1, %target) }
  }

  if ($person_in_mech($2) = true) { 
    ; Is the mech destroyed?
    if ($readini($char($2), mech, HpCurrent) <= 0) {  var %mech.name $readini($char($2), mech, name)
      $display.system.message($readini(translation.dat, battle, DisabledMech), battle)
      $mech.deactivate($2, true)
    }
  }



  unset %target | unset %user | unset %enemy | unset %counterattack |  unset %statusmessage.display

  if ($3 = weapon) {
    if ($readini($char($1), battle, hp) > 0) {
      set %inflict.user $1 | set %inflict.techwpn $4
      $self.inflict_status(%inflict.user, %inflict.techwpn ,weapon)
      if (%statusmessage.display != $null) { $display.system.message(%statusmessage.display, battle) | unset %statusmessage.display }
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

  unset %overkill | unset %target |  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  ; Show the damage
  if ($person_in_mech($2) = false) { 
    if ($4 = $null) { 
      if (($readini($char($2), status, reflect) = yes) && ($readini($dbfile(techniques.db), $3, magic) = yes)) { $display.system.message($readini(translation.dat, skill, MagicReflected), battle) | $set_chr_name($1) | set %enemy %real.name | set %target $1 | writeini $char($2) status reflect no | writeini $char($2) status reflect.timer 1  }
    }
  }

  if ($3 != battlefield) {
    if (($readini($char($1), info, flag) != monster) && (%target != $1)) { $calculate.stylepoints($1) }
  }

  if (%guard.message = $null) { $display.system.message($readini(translation.dat, tech, DisplayAOEDamage), battle)  }
  if (%guard.message != $null) { $display.system.message(%guard.message, battle) | unset %guard.message }

  if (%target = $null) { set %target $2 }

  if ($4 = absorb) { 
    ; Show how much the person absorbed back.
    var %absorb.amount $round($calc(%attack.damage / 2),0)
    $display.system.message($readini(translation.dat, tech, AbsorbHPBack), battle)
  }

  if (%absorb.message != $null) { 
    if (%guard.message = $null) { 
      $display.system.message(%absorb.message,battle) 
      unset %absorb.message
    }
  }

  set %target.hp $readini($char(%target), battle, hp)

  if ((%target.hp > 0) && ($person_in_mech($2) = false)) {

    ; Check for inactive..
    if ($readini($char($2), battle, status) = inactive) {
      if ($readini($char($1), info, flag) != monster) { 
        writeini $char(%target) battle status alive
        $display.system.messages($readini(translation.dat, battle, inactivealive),battle)
      }
    }

    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char(%target), info, CanStagger)
    if ((%stagger.check = $null) || (%stagger.check = no)) { return }

    ; Do the stagger if the damage is above the threshold.
    var %stagger.amount.needed $readini($char(%target), info, StaggerAmount)
    dec %stagger.amount.needed %attack.damage | writeini $char(%target) info staggeramount %stagger.amount.needed
    if (%stagger.amount.needed <= 0) { writeini $char(%target) status staggered yes |  writeini $char(%target) info CanStagger no
      $display.system.message($readini(translation.dat, status, StaggerHappens), battle)
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
    $display.system.message($readini(translation.dat, battle, EnemyDefeated), battle)

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
      $display.system.message($readini(translation.dat, battle, DisabledMech), battle)
      writeini $char($2) mech inuse false
    }
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
      $display.system.message(3 $+ %real.name $+  $readini($dbfile(techniques.db), $4, desc),battle) 
    }
  }

  if ($3 = item) {
    $display.system.message(3 $+ %user $+  $readini($dbfile(items.db), $4, desc),battle) 
  }

  if ($3 = weapon) { 
    var %weapon.type $readini($dbfile(weapons.db), $4, type) | var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)
    $display.system.message(3 $+ %user $+  $read %attack.file  $+ 3.,battle) 
  }

  ; Show the damage healed
  if (%guard.message = $null) {  $set_chr_name($2) |  $set_chr_name($2)
    $set_chr_name($2) | set %enemy %real.name
    if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
    $display.system.message(3 $+ %enemy has been healed for $bytes(%attack.damage,b) health!, battle) 
  }
  if (%guard.message != $null) { 
    $set_chr_name($2) | set %enemy %real.name
    if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
    $display.system.message(%guard.message,battle) 
    unset %guard.message
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    $set_chr_name($2) 
    $display.system.message(4 $+ %enemy has been defeated by %user $+ !  %overkill,battle) 
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
      $display.system.message($readini(translation.dat, battle, ObtainGreenOrb),battle)
    }

    if ((%healing.orb.chance > 80) && (%healing.orb.chance < 98)) {
      ; TP orb
      var %orb.restored $rand(5,20)
      $restore_tp($1, %orb.restored)
      $display.system.message($readini(translation.dat, battle, ObtainWhiteOrb),battle) 
    }

    if (%healing.orb.chance >= 98) { 
      ; Ignition Orb
      var %max.ig $readini($char($1), basestats, IgnitionGauge)
      if (%max.ig > 0) {
        var %orb.restored $rand(1,2)
        $restore_ig($1, %orb.restored)
        $display.system.message($readini(translation.dat, battle, ObtainOrangeOrb),battle) 
      }
    }

  }
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

  $display.system.message($readini(translation.dat, system, ConvertToGem),battle) 

  set %current.item.total $readini($char($1), Item_Amount, %gem) 
  if (%current.item.total = $null) { var %current.item.total 0 }
  inc %current.item.total 1 | writeini $char($1) Item_Amount %gem %current.item.total 

  var %monsters.converted $readini($char($1), stuff, MonstersToGems)
  if (%monsters.converted = $null) { var %monsters.converted 0 }
  inc %monsters.converted 1 | writeini $char($1) stuff MonstersToGems %monsters.converted

  $achievement_check($2, PrettyGemCollector)

  unset %gem.list | unset %total.gems | unset %random.gem | unset %gem
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomly pick the weather
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.weather.pick {
  if (%current.battlefield = Dead-End Hallway) { return }
  if ((weatherlock isin %battleconditions) || (weather-lock isin %battleconditions)) { return }

  set %weather.list $readini($dbfile(battlefields.db), %current.battlefield, weather)
  set %random $rand(1, $numtok(%weather.list,46))
  if (%random = $null) { var %random 1 }
  set %new.weather $gettok(%weather.list,%random,46)
  var %old.weather $readini($dbfile(battlefields.db), weather, current)
  if (%new.weather = $null) { set %new.weather calm }
  writeini $dbfile(battlefields.db) weather current %new.weather

  if (($1 = inbattle) && (%new.weather = %old.weather)) { return }

  $display.system.message(10The weather changes.  It is now %new.weather, battle) 

  unset %number.of.weather | unset %new.weather | unset %random | unset %weather.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Controls the phase of the
; moon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moonphase {
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
  if ($readini(battlestats.dat, battle, WinningStreak) <= 50) { return }
  var %timeofday $readini($dbfile(battlefields.db), TimeOfDay, CurrentTimeOfDay)
  if ((%timeofday = morning) || (%timeofday = noon)) { return }

  if ($readini(battlestats.dat, TempBattleInfo, Event) != $null) { remini battlestats.dat TempBattleInfo Event | return }
  set %curse.chance $rand(1,100)
  if (%battle.type = boss) { set %curse.chance $rand(1,80) }

  $divineblessing.check

  if (%curse.chance <= 15) { 
    $display.system.message($readini(translation.dat, Events, CurseNight), battle)
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

  if (($return_winningstreak <= 10) && (%portal.bonus != true)) { return }

  set %battleconditions $readini($dbfile(battlefields.db), %current.battlefield, limitations)
  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { $display.system.message($readini(translation.dat, Events, AncientMeleeOnlySeal), battle)  }
  if ((no-skill isin %battleconditions) || (no-skills isin %battleconditions)) { $display.system.message($readini(translation.dat, Events, AncientNoSkillsSeal), battle)  }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { $display.system.message($readini(translation.dat, Events, AncientNoItemsSeal), battle)  }
  if ((no-ignition isin %battleconditions) || (no-ignitions isin %battleconditions)) { $display.system.message($readini(translation.dat, Events, AncientNoIgnitionsSeal), battle)  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks to see
; if monsters go first in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.surpriseattack {
  if (%savethepresident = on) { return }
  if ($readini(battlestats.dat, TempBattleInfo, SurpriseAttack) != $null) { remini battlestats.dat TempBattleInfo SurpriseAttack | return } 

  set %surpriseattack.chance $rand(1,105)

  $backguard.check

  if (%surpriseattack.chance >= 88) { set %surpriseattack on | writeini battlestats.dat TempBattleInfo SurpriseAttack true }
  if (%surpriseattack = on) { $display.system.message($readini(translation.dat, Events, SurpriseAttack), battle)  }
  unset %surpriseattack.chance
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks
; to see if players go first
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.playersgofirst {
  if (%surpriseattack = on) { return }
  set %playersfirst.chance $rand(1,100)

  if (%playersfirst.chance <= 8) { set %playersgofirst on }
  if (%playersgofirst = on) { 
    $display.system.message($readini(translation.dat, Events, PlayersGoFirst), battle) 
  }
  unset %playersfirst.chance
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a random NPC 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.battlefield.ally {
  if (%battle.type = manual) { return }
  if (%battle.type = orbfountain) { return }
  if (%battle.type = boss) { return }

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
      $display.system.message(4Error: There are no NPCs in the NPC folder.. Have the bot admin check to make sure there are npcs there!,battle) 
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

        if (%battle.type != ai) { 
          $display.system.message(4 $+ %real.name has entered the battle to help the forces of good!,battle)
          $display.system.message(12 $+ %real.name  $+ $readini($char(%npc.name), descriptions, char),battle)
        }

        if (%battle.type = ai) { set %ai.npc.name %real.name | writeini $txtfile(1vs1bet.txt) money npcfile %npc.name }

        set %npc.to.remove $findtok(%npc.list, %npc.name, 46)
        set %npc.list $deltok(%npc.list,%npc.to.remove,46)
        write $txtfile(battle.txt) %npc.name
        $boost_monster_stats(%npc.name)
        $fulls(%npc.name) | var %battlenpcs $readini($txtfile(battle2.txt), BattleInfo, npcs) | inc %battlenpcs 1 | writeini $txtfile(battle2.txt) BattleInfo npcs %battlenpcs
        inc %value 1
      }
      else {  %npc.list = $deltok(%npc.list,%npc.name,46) | dec %value 1 }
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

  if ($readini($char($1), info, flag) != monster) { return }

  ; Check for death conditions.  If the death condition isn't met, turn on revive.
  var %death.conditions $readini($char($1), info, DeathConditions)
  if (%death.conditions = $null) { return }

  if ($istok(%death.conditions,$2,46) = $false) { writeini $char($1) status revive yes }
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
    var %max.hp $readini($char($1), basestats, hp)
    set %revive.current.hp $round($calc(%max.hp / 2),0)
    if (%revive.current.hp <= 0) { set %revive.current.hp 1 }
    writeini $char($1) battle hp %revive.current.hp
    writeini $char($1) battle status normal
    writeini $char($1) status revive no
    $set_chr_name($1)

    $set_chr_name($1)
    if ($readini($char($1), descriptions, revive) != $null) {  var %revive.message 7 $+ %real.name  $+ $readini($char($1), descriptions, revive) }
    if ($readini($char($1), descriptions, revive) = $null) { var %revive.message $readini(translation.dat, battle, GoldOrbUsed) }

    $display.system.message.delay(%revive.message, battle, 1) 

    writeini $txtfile(battle2.txt) style $1 0
    unset %revive.current.hp

    var %number.of.revives $readini($char($1), stuff, RevivedTimes)
    if (%number.of.revives = $null) { var %number.of.revives 0 }
    inc %number.of.revives 1
    writeini $char($1) stuff RevivedTimes %number.of.revives
    $achievement_check($1, Can'tKeepAGoodManDown)

    writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no
    writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no 
    writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 1 | writeini $char($1) status intimidate no
    writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
    writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no
    writeini $char($1) status boosted no  | writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1
    writeini $char($1) status zombieregenerating no | writeini $char($1) status charmer noOneThatIKnow | writeini $char($1) status charm.timer 1 | writeini $char($1) status charmed no 
    writeini $char($1) status charm no | writeini $char($1) status bored no | writeini $char($1) status bored.timer 1 | writeini $char($1) status confuse no 
    writeini $char($1) status confuse.timer 1 | writeini $char($1) status defensedown no | writeini $char($1) status defensedown.timer 0 | writeini $char($1) status strengthdown no 
    writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown no | writeini $char($1) status intdown.timer 1
    writeini $char($1) status defenseup no | writeini $char($1) status defenseup.timer 0 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks for
; the guardian style
; and reduces damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guardian_style_check {
  if ($augment.check($1, IgnoreGuardian) = true) { return }

  set %current.playerstyle $readini($char($1), styles, equipped)
  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.

  if ($person_in_mech($1) = true) { set %current.playerstyle Guardian }

  if (%current.playerstyle = Guardian) { 
    set %current.playerstyle.level $readini($char($1), styles, Guardian)

    if ($person_in_mech($1) = true) {  set %current.playerstyle.level 12 }

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
  writeini $char(%monster.name) basestats def $calc(%current.battlestreak * 2)
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
  $display.system.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
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
  ; get a random monster and summon the monster to the battelfield

  set %number.of.monsters.needed 1
  set %multiple.wave.bonus yes

  var %bonus.orbs $readini($txtfile(battle2.txt), battleinfo, portalbonus)
  if (%bonus.orbs = $null) { var %bonus.orbs 0 }
  inc %bonus.orbs 10
  writeini $txtfile(battle2.txt) battleinfo portalbonus %bonus.orbs
  $display.system.message($readini(translation.dat, system,PortalReinforcements),battle) 
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
    var %random.status.type $rand(1,16)
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

  if (%status.grammar = $null) { echo -a 4Invalid status type: $3 | return }

  var %chance $rand(1,140) | $set_chr_name($1) 
  if ($readini($char($2), skills, utsusemi.on) = on) { set %chance 0 } 

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

    $ribbon.accessory.check($2)
  }

  if (%status.type != paralysis) {  var %enfeeble.timer $rand(0,1) }
  if (%status.type = paralysis) {  var %enfeeble.timer $rand(1,2) }

  if (%status.type = $null) { var %enfeeble.timer $rand(1,2) }

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

      if (%status.type = poison) && ($readini($char($2), status, poison) = yes) { writeini $char($2) status poison no | writeini $char($2) status poison-heavy yes | writeini $char($2) status poison.timer %enfeeble.timer }
      if (%status.type = poison) && ($readini($char($2), status, poison-heavy) != yes) { writeini $char($2) status poison yes | writeini $char($2) status poison.timer %enfeeble.timer }
      if (%status.type = charm) { writeini $char($2) status charmed yes | writeini $char($2) status charmer $1 | writeini $char($2) status charm.timer %enfeeble.timer }
      if (%status.type = curse) { writeini $char($2) Status %status.type yes | writeini $char($2) battle tp 0 }
      if (%status.type = petrify) { writeini $char($2) status petrified yes }

      if ((((%status.type != poison) && (%status.type != charm) && (%status.type != petrify) && (%status.type != removeboost)))) { writeini $char($2) Status %status.type yes | writeini $char($2) status %status.type $+ .timer %enfeeble.timer   }
    }
  }

  ; If a monster, increase the resistance.
  if ($readini($char($2), info, flag) = monster) {
    if (%resist.skill = $null) { set %resist.skill 20 }
    else { inc %resist.skill 20 }
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

  if (%status.grammar = $null) { echo -a 4Invalid status type: %self.status.type | return }

  if (%statusmessage.display != $null) {  set %statusmessage.display %statusmessage.display and %status.grammar $+ ! } 
  if (%statusmessage.display = $null) {   $set_chr_name(%inflict.user) | set %statusmessage.display 4 $+ %real.name is now %status.grammar $+ ! }

  if (%status.type != paralysis) {  var %enfeeble.timer $rand(0,1) }
  if (%status.type = paralysis) {  var %enfeeble.timer $rand(1,2) }

  if (%status.type = poison) && ($readini($char(%inflict.user), status, poison) = yes) { writeini $char(%inflict.user) status poison no | writeini $char(%inflict.user) status poison-heavy yes | writeini $char(%inflict.user) status poison.timer %enfeeble.timer }
  if (%status.type = poison) && ($readini($char(%inflict.user), status, poison-heavy) != yes) { writeini $char(%inflict.user) status poison yes | writeini $char(%inflict.user) status poison.timer %enfeeble.timer }
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Figure out how many monsters
; To add based on streak #.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
winningstreak.addmonster.amount {
  if (%battle.type = orbfountain) { return }
  if (%battle.type = demonwall) { return }
  if (%battle.type = doppelganger) { return }
  if (%battle.type = monster) { 
    ; If the players have been winning a lot then we need to make things more interesting/difficult for them.
    if ((%winning.streak >= 50) && (%winning.streak <= 300)) { inc %number.of.monsters.needed 1 }
    if ((%winning.streak > 300) && (%winning.streak <= 500)) { inc %number.of.monsters.needed 2 }
    if ((%winning.streak > 500) && (%winning.streak <= 1000)) { inc %number.of.monsters.needed 3 }
    if (%winning.streak > 1000) { inc %number.of.monsters.needed 4 }

    if (%bloodmoon = on) { inc %number.of.monsters.needed 2 }
  }

  if (%battle.type = boss) {
    if ((%winning.streak > 300) && (%winning.streak <= 500)) { inc %number.of.monsters.needed 1 }
    if (%winning.streak > 500) { inc %number.of.monsters.needed 2 }
  }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if a monster
; would one-shot a player
; on the first round. If so,
; nerf the damage.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
first_round_dmg_chk {
  if ((%current.turn = 1) || (%first.round.protection = yes)) { 
    if (%attack.damage <= 5) { return }


    if ($readini($char($1), info, flag) = monster) {

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
  if ($readini($char($2), status, stun) = yes) { return }
  if ($readini($char($2), status, paralysis) = yes) { return }
  if ($readini($char($2), status, petrified) = yes) { return }
  if ($readini($char($2), skills, truestrike.on) = on) { return }

  if ((%battle.rage.darkness = on) && ($readini($char($3), info, flag) = monster)) { return }

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (((%current.playerstyle != Trickster) && ($augment.check($1, EnhanceDodge) = false) && ($readini($char($1), skills, thirdeye.on) != on))) { unset %current.playerstyle | unset %current.playerstyle.level | return }
  if (%guard.message != $null) { return }

  var %dodge.chance $rand(1,110)

  if ($augment.check($1, EnhanceDodge) = true) { inc %current.playerstyle.level $calc(20* %augment.strength) | dec %dodge.chance 5
    if (%current.playerstyle.level > 65) { set %current.playerstyle.level 65 }
  }

  if ($readini($char($2), battle, spd) > $readini($char($1), battle, spd)) { inc %dodge.chance $rand(5,10) } 

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
  if ($readini($char($2), skills, truestrike.on) = on) { return }

  if ((%battle.rage.darkness = on) && ($readini($char($2), info, flag) = monster)) { return }

  var %parry.weapon $readini($char($1), weapons, equipped)
  $mastery_check($1, %parry.weapon)
  var %parry.chance $rand(1,100)

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
  if (%counterattack = on) { return }
  if ($person_in_mech($1) = true) { return }
  if ($readini($char($2), status, stun) = yes) { return }
  if ($readini($char($2), status, paralysis) = yes) { return }
  if ($readini($char($2), skills, truestrike.on) = on) { return }
  if (%guard.message != $null) { return }
  if ((%battle.rage.darkness = on) && ($readini($char($2), info, flag) = monster)) { return }

  ; Is the defender using a shield?
  var %left.hand.weapon $readini($char($1), weapons, equippedLeft)
  if (%left.hand.weapon = $null) { return }
  var %left.hand.weapon.type $readini($dbfile(weapons.db), %left.hand.weapon, type)
  if (%left.hand.weapon.type != shield) { return }

  ; Get the blocking chance of the shield
  var %shield.blocking.chance $readini($dbfile(weapons.db), %left.hand.weapon, BlockChance)
  if ($augment.check($1, EnhanceBlocking) = true) { inc %shield.blocking.chance $calc(1 * %augment.strength) }
  if ($accessory.check($1, EnhanceBlocking) = true) {
    inc %shield.blocking.chance %accessory.amount
    unset %accessory.amount
  }

  ; Attempt to block using the shield.
  var %block.chance $rand(1,100)
  if (%block.chance > %shield.blocking.chance) { return }

  ; Determine how much damage is absorbed via the shield.
  var %shield.blocking.amount $readini($dbfile(weapons.db), %left.hand.weapon, AbsorbAmount)
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

  if ($readini($char($1), status, ethereal) = yes) { return }
  if (%guard.message != $null) { return }

  if ($readini($char($2), info, MetalDefense) = true) { return }

  if ($readini($char($2), info, ai_type) = counteronly) { $counter_melee_action($1, $2, $3) | return }
  if ($readini($char($2), info, ai_type) = defender) { return }
  if ($readini($char($2), info, ai_type) = portal) { return }
  if ($readini($char($2), info, ai_type) = healer) { return }

  if ($2 = orb_fountain) { return }
  if ($2 = lost_soul) { return }
  if ($readini($char($1), skills, truestrike.on) = on) { return }
  if ($person_in_mech($2) = true) { return }

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
  if (%current.playerstyle = CounterStance) { inc %counter.chance %current.playerstyle.level }

  unset %current.playerstyle | unset %current.playerstyle.level 

  ; Check for the EnhanceCounter augment.
  if ($augment.check($2, EnhanceCounter) = true) { inc %counter.chance $calc(2 * %augment.strength)  }

  ; If we have a skill that sets the chance to 100%, check it here.
  ; this is to be added later. :P

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
; Check for a multiple wave
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multiple_wave_check {
  if (%multiple.wave = yes) { return }
  if (%battleis = off) { return }
  if (%demonwall.fight = on) { return } 
  if (%portal.bonus = true) { return }
  if (%portal.multiple.wave = on) { return }
  if (%battle.type = mimic) { return }
  if (%boss.type = bandits) { return }
  if (%battle.type = ai) { return }
  if (%savethepresident = on) { return }

  unset %number.of.monsters.needed

  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
  if (%winning.streak <= 0) { return }

  if (%winning.streak <= 100) { var %multiple.wave.chance $rand(1,2) }
  if ((%winning.streak > 100) && (%winning.streak <= 200)) { var %multiple.wave.chance $rand(2,4) }
  if ((%winning.streak > 200) && (%winning.streak <= 400)) { var %multiple.wave.chance $rand(4,7) }
  if ((%winning.streak > 400) && (%winning.streak <= 700)) { var %multiple.wave.chance $rand(8,11) }
  if (%winning.streak > 700) { var %multiple.wave.chance $rand(4,8) }

  var %random.wave.chance $rand(1,100)
  if (%mode.gauntlet = on) { var %random.wave.chance 1 | inc %mode.gauntlet.wave 1 }
  if (%random.wave.chance > %multiple.wave.chance) { return }

  set %multiple.wave yes |  set %multiple.wave.bonus yes | set %multiple.wave.noaction yes

  ; Clear out the old monsters.
  $multiple_wave_clearmonsters

  ; Create the next wave
  if (%mode.gauntlet = $null) {  
    $display.system.message($readini(translation.dat, system,AnotherWaveArrives),battle) 
  }
  set %number.of.monsters.needed $rand(2,3)

  set %first.round.protection yes
  set %first.round.protection.turn $calc(%current.turn + 1)

  if ($readini($txtfile(battle2.txt), battleinfo, players) > 1) { inc %number.of.monsters.needed 1 }
  if (%mode.gauntlet = $null) { $winningstreak.addmonster.amount | $generate_monster(monster) }
  if (%mode.gauntlet != $null) { 

    $display.system.message($readini(translation.dat, system,AnotherWaveArrives) [Gauntlet Round: %mode.gauntlet.wave $+ ], battle) 
    set %number.of.monsters.needed 2  

    var %m.boss.chance $rand(1,100)
    if (%m.boss.chance > 15) { $generate_monster(monster) }
    if (%m.boss.chance <= 15) { $generate_monster(boss) }
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
  set %monster.to.spawn $readini($char($1), info, SpawnAfterDeath)

  if (%monster.to.spawn = $null) { return }

  var %isboss $isfile($boss(%monster.to.spawn))
  var %ismonster $isfile($mon(%monster.to.spawn))
  var %isnpc $isfile($npc(%monster.to.spawn))

  if (((%isboss != $true) && (%isnpc != $true) && (%ismonster != $true))) { return }  

  if ($isfile($boss(%monster.to.spawn)) = $true) {  .copy -o $boss(%monster.to.spawn) $char(%monster.to.spawn)  }
  if ($isfile($mon(%monster.to.spawn)) = $true) {  .copy -o $mon(%monster.to.spawn) $char(%monster.to.spawn)  }
  if ($isfile($npc(%monster.to.spawn)) = $true) { .copy -o $npc(%monster.to.spawn) $char(%monster.to.spawn) }

  ; increase the total # of monsters
  set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%monster.to.spawn,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
  write $txtfile(battle.txt) %monster.to.spawn
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters

  ; display the description of the spawned monster
  $set_chr_name(%monster.to.spawn) 

  var %bossquote $readini($char(%monster.to.spawn), descriptions, bossquote)

  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
    $display.system.message.delay($readini(translation.dat, battle, EnteredTheBattle),battle, 0)
    $display.system.message.delay(12 $+ %real.name  $+ $readini($char(%monster.to.spawn), descriptions, char), battle, 0)
    $display.system.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.to.spawn), descriptions, BossQuote) $+ ", battle, 0) 
  }
  if ($readini(system.dat, system, botType) = DCCchat) {
    $dcc.battle.message($readini(translation.dat, battle, EnteredTheBattle))
    $dcc.battle.message(12 $+ %real.name  $+ $readini($char(%monster.to.spawn), descriptions, char))
    $dcc.battle.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.to.spawn), descriptions, BossQuote) $+ ")
  }

  ; Boost the monster
  $boost_monster_stats(%monster.to.spawn) 
  $fulls(%monster.to.spawn)

  set %multiple.wave.bonus yes
  set %first.round.protection yes
}

metal_defense_check {
  if ($augment.check($2, IgnoreMetalDefense) = true) { return }
  else { 
    if ($readini($char($1), info, MetalDefense) = true) {  set %attack.damage 0  }
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
  if (%current.battlefield != $null) { return }

  set %battlefields.total $lines($lstfile(battlefields.lst))
  if ((%battlefields.total = $null) || (%battlefields.total = 0)) { set %current.battlefield none | unset %battlefields.total | return }

  set %battlefield.random $rand(1,%battlefields.total)
  set %current.battlefield $read($lstfile(battlefields.lst), %battlefield.random)

  unset %battlefield.random | unset %battlefields.total
}
battlefield.damage {
  set %attack.damage $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ amount)
  var %current.streak $return_winningstreak
  var %streak.increase $calc(%current.streak / 100)
  if (%streak.increase < 1) { var %streak.increase 1 }

  set %attack.damage $round($calc(%attack.damage * %streak.increase),0)
  if (%attack.damage > 1000) { set %attack.damage 1000 }
}
battlefield.event {
  set %debug.location alias battlefield.event
  if ($readini(battlestats.dat, battle, winningstreak) < 15) { return }
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
    $display.system.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)

    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), battle, status) = dead) { inc %battletxt.current.line }
      else {
        if (%event.status.type != $null) { 
          if ($person_in_mech(%who.battle) = false) {   writeini $char(%who.battle) status %event.status.type yes }
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
      if ((($readini($char(%who.battle), battle, hp) <= 0) || ($person_in_mech(%who.battle) = true) || ($readini($char(%who.battle), battle, status) = runaway))) { inc %battletxt.current.line }
      else {  %alive.members = $addtok(%alive.members, %who.battle, 46)  }
      inc %battletxt.current.line
    }

    set %number.of.members $numtok(%alive.members, 46)

    if (%number.of.members = $null) { unset %number.of.members | unset %alive.members | return }

    set %random.member $rand(1,%number.of.members)
    set %member $gettok(%alive.members,%random.member,46)

    unset %random.member | unset %alive.members | unset %number.of.members

    if ($readini($char(%member), battle, hp) = $null) { return }

    $set_chr_name(%member) 
    $display.system.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)

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
      $guardianmon.check(battlefield, battlefield, %who.battle)
      if ($readini($char(%who.battle), info, HurtByTaunt) = true) { set %attack.damage 0 }
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
    $display.system.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), battle, hp) <= 0)  { inc %battletxt.current.line }
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
    $display.system.message(4 $+ $readini($dbfile(battlefields.db), %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)
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
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (%current.playerstyle = WeaponMaster) { 
    if (($3 = melee) || ($3 = tech)) {
      $mastery_check($1, $2)

      var %amount.to.increase $calc(.05 * %current.playerstyle.level)
      if (%amount.to.increase >= .70) { var %amount.to.increase .70 }
      var %wpnmst.increase $round($calc(%amount.to.increase * %attack.damage),0)
      inc %attack.damage %wpnmst.increase
      var %playerstyle.bonus $round($calc(%current.playerstyle.level * 1.5),0)
      inc %mastery.bonus %playerstyle.bonus
      inc %attack.damage %mastery.bonus
    }
  }

  if (($3 = melee) || ($3 = tech)) {
    if (%current.playerstyle = HitenMitsurugi-ryu) {
      if ($readini($dbfile(weapons.db), $2, type) = Katana) {
        var %amount.to.increase $calc(.05 * %current.playerstyle.level)
        if (%amount.to.increase >= .80) { var %amount.to.increase .80 }
        var %hmr.increase $round($calc(%amount.to.increase * %attack.damage),0)
        inc %attack.damage %hmr.increase
      }    
    }
  }

  if ($3 = magic) {
    if (%current.playerstyle = SpellMaster) { inc %magic.bonus.modifier $calc(%current.playerstyle.level * .115)
      if (%magic.bonus.modifier >= 1) { set %magic.bonus.modifier .90 }
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if an
; Ethereal monster can be
; hurt.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
melee.ethereal.check {
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

  if (($readini($char($3), status, ethereal) = yes) && ($readini($dbfile(techniques.db), $2, magic) != yes)) {
    $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
  }
}

tech.ethereal.check {
  ; $1 = attacker
  ; $2 = technique
  ; $3 = target

  var %weapon.hurt.ethereal $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), HurtEthereal)

  if ($readini($char($3), status, ethereal) = yes) {
    if ((($augment.check($1, HurtEthereal) = false) && (%weapon.hurt.ethereal != true) && ($readini($dbfile(techniques.db), $2, magic) != yes))) {
      $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
    }
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

  if ($readini($dbfile(techniques.db), $2, Type) = heal) { set %attack.target $1 | return }
  if ($readini($dbfile(techniques.db), $2, Type) = heal-AOE) { set %attack.target $1 | return }

  if ($3 != AOE) {  set %attack.target %cover.target 
    set %covering.someone on
  }
  if ($3 = AOE) { set %who.battle %cover.target }
  writeini $char($1) skills CoverTarget none
  $display.system.message($readini(translation.dat, battle, TargetCovered),battle) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These functions are for
; Battle Formula 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate_pDIF {
  ; $1 = attacker
  ; $2 = defender
  ; $3 = melee, tech, magic

  %cRatio = $calc(%attack.damage / %enemy.defense)

  var %attacker.level $get.level($1)
  var %defender.level $get.level($2)
  var %level.difference $calc(%attacker.level - %defender.level)

  if (($readini($char($1), info, flag) = $null) && ($readini($char($2), info, flag) = monster)) { 
    if (%level.difference >= 50) { var %level.difference 50 }
    if (%level.difference <= -500) { var %level.difference -500 }
  }
  else { 
    if (%level.difference >= 50) { var %level.difference 50 }
    if (%level.difference <= -40) { var %level.difference -40 }
  }

  var %cRatio.modifier $calc(0.05 * %level.difference)

  inc %cRatio %cRatio.modifier

  if (%cRatio > 2) { %cRatio = 2 }
  else { %cRatio = $round(%cRatio, 3) }

  $calculate_maxpDIF
  $calculate_minpDIF

  set %pDIF.max $round($calc(10 * %maxpDIF),0)
  set %pDIF.min $round($calc(10 * %minpDIF),0)
  set %pDIF $rand(%pDIF.min, %pDIF.max)

  %pDIF = $round($calc(%pDIF / 10),3)

  if (%pDIF <= 0) { 
    if ($isfile($boss($1)) = $true) { %pDIF = .005 }
    if (%battle.type = boss) { %pDIF = .005 }
  }

  unset %pDIF.max | unset %pDIF.min | unset %cRatio
  unset %maxpDIF | unset %minpDIF 

  if ($3 = melee) {
    if ($mighty_strike_check($1) = true) {
      if (%pDIF > 0) {  inc %pDIF .8 }
      if (%pDIF <= 0) { set %pDIF .5 }
    }
  }

  if ($3 = magic) {
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      if (%pDIF > 0) {  inc %pDIF .8 }
      if (%pDIF <= 0) { set %pDIF .5 }
    }
  }

  if (%enemy.defense <= 5) {
    if (%pDIF > 0) {  inc %pDIF .5 }
    if (%pDIF <= 0) { set %pDIF .5 }
  }
}

calculate_maxPDIF {
  if (%cRatio <= 0.5) { set %maxpDIF $calc(0.4 + (1.2 * %cRatio)) }
  if ((%cRatio > 0.5) && (%cRatio <= 0.833)) { set %maxpDIF 1 }
  if ((%cRatio > 0.833) && (%cRatio <= 2)) { set %maxpDIF $calc(1 + (1.2 * (%cRatio - .833))) }
}

calculate_minPDIF {
  if (%cRatio <= 1.25) { set %minpDIF $calc(-.5 + (%cRatio * 1.2)) }
  if ((%cRatio > 1.25) && (%cRatio <= 1.5)) {  set %minpDIF 1 }
  if ((%cRatio > 1.5) && (%cRatio <= 2)) { set %minpDIF $calc(-.8 + (1.2 * %cRatio)) }

  if (%minpDIF <= 0) { set %minpDIF 1 }
}

calculate_attack_leveldiff {
  ; $1 = attacker
  ; $2 = defender

  var %attacker.level $get.level($1)
  var %defender.level $get.level($2)
  var %level.difference $calc(%attacker.level - %defender.level)

  if (($readini($char($1), info, flag) = $null) && ($readini($char($2), info, flag) = monster)) {
    if (%level.difference <= 0) { 
      if ((%level.difference <= 0) && (%level.difference >= -10)) { dec %attack.damage $round($calc(%attack.damage * .10),0) }
      if ((%level.difference < -10) && (%level.difference >= -50)) { dec %attack.damage $round($calc(%attack.damage * .15),0) }
      if ((%level.difference <= -50) && (%level.difference >= -100)) { dec %attack.damage $round($calc(%attack.damage * .25),0) }
      if ((%level.difference < -100) && (%level.difference >= -150)) { dec %attack.damage $round($calc(%attack.damage * .30),0) }
      if ((%level.difference < -150) && (%level.difference >= -300)) { dec %attack.damage $round($calc(%attack.damage * .50),0) }
      if ((%level.difference < -300) && (%level.difference >= -500)) { dec %attack.damage $round($calc(%attack.damage * .60),0) }
      if (%level.difference < -500)  { dec %attack.damage $round($calc(%attack.damage * .85),0) }
    }
  }

  if (($readini($char($1), info, flag) != $null) && ($readini($char($2), info, flag) = $null)) {
    if (%level.difference >= 11) { 
      if ((%level.difference >= 10) && (%level.difference >= 50)) { inc %attack.damage $round($calc(%attack.damage * .10),0) }
      if ((%level.difference > 50) && (%level.difference >= 100)) { inc %attack.damage $round($calc(%attack.damage * .15),0) }
      if ((%level.difference > 100) && (%level.difference >= 150)) { inc %attack.damage $round($calc(%attack.damage * .20),0) }
      if ((%level.difference > 150) && (%level.difference >= 300)) { inc %attack.damage $round($calc(%attack.damage * .25),0) }
      if ((%level.difference > 300) && (%level.difference >= 500)) { inc %attack.damage $round($calc(%attack.damage * .28),0) }
      if (%level.difference > 500)  { inc %attack.damage $round($calc(%attack.damage * .30),0) }
    }

    if (%level.difference <= 0) { 
      if ((%level.difference <= 0) && (%level.difference >= -10)) { dec %attack.damage $round($calc(%attack.damage * .10),0) }
      if ((%level.difference < -10) && (%level.difference >= -50)) { dec %attack.damage $round($calc(%attack.damage * .15),0) }
      if ((%level.difference <= -50) && (%level.difference >= -100)) { dec %attack.damage $round($calc(%attack.damage * .18),0) }
      if ((%level.difference < -100) && (%level.difference >= -150)) { dec %attack.damage $round($calc(%attack.damage * .20),0) }
      if ((%level.difference < -150) && (%level.difference >= -300)) { dec %attack.damage $round($calc(%attack.damage * .22),0) }
      if ((%level.difference < -300) && (%level.difference >= -1000)) { dec %attack.damage $round($calc(%attack.damage * .25),0) }
      if (%level.difference < -1000)  { dec %attack.damage $round($calc(%attack.damage * .30),0) }
    }

  }

}

cap.damage {
  ; $1 = attacker
  ; $2 = defender
  ; $3 = tech, melee, etc

  if (($readini(system.dat, system, IgnoreDmgCap) = true) || ($readini($char($2), info, IgnoreDmgCap) = true)) { return }

  if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
    if ($3 = melee) { var %damage.threshold 10000 }
    if ($3 = tech) { var %damage.threshold 38000 }

    if ($readini(system.dat, system, PlayersMustDieMode) = true)  { dec %damage.threshold 3000 }

    var %attacker.level $get.level($1)
    var %defender.level $get.level($2)
    var %level.difference $calc(%attacker.level - %defender.level)
    if (%level.difference < 0) { dec %damage.threshold $round($calc($abs(%level.difference) * 1.5),0)  }

    if ((%level.difference >= 0) && (%level.difference <= 100)) { inc %damage.threshold $round($calc(%level.difference * .05),0)  }
    if ((%level.difference > 100) && (%level.difference <= 500)) { inc %damage.threshold $round($calc(%level.difference * .07),0)  }
    if ((%level.difference > 500) && (%level.difference <= 1000)) { inc %damage.threshold $round($calc(%level.difference * 1),0)  } 
    if (%level.difference > 1000) { inc %damage.threshold $round($calc(%level.difference * 1.5),0)  } 

    if (%damage.threshold <= 0) { var %damage.threshold 10 }

    if (%attack.damage > %damage.threshold) {
      if ($person_in_mech($1) = false) {  set %temp.damage $calc(%attack.damage / 100)  | set %capamount 50000 }
      if ($person_in_mech($1) = true) { set %temp.damage $calc(%attack.damage / 90) | set %capamount 70000 }
      set %attack.damage $round($calc(%damage.threshold + %temp.damage),0)

      if (%attack.damage >= %capamount) { 
        if ($person_in_mech($1) = false) {  inc %attack.damage $round($calc(%attack.damage * 0.01),0) }
        if ($person_in_mech($1) = true) { inc %attack.damage $round($calc(%attack.damage * 0.05),0) }
      }

      unset %temp.damage | unset %capamount

    }
  }

  if ($readini($char($1), info, flag) = monster) {
    if (%battle.rage.darkness = on) { return }

    if ($3 = melee) { var %damage.threshold 2000 }
    if ($3 = tech) { var %damage.threshold 3000 }

    if ($readini(system.dat, system, PlayersMustDieMode) = true)  { inc %damage.threshold 7000 }

    set %attacker.level $get.level($1)
    set %defender.level $get.level($2)

    var %level.difference $calc(%attacker.level - %defender.level)

    if (%level.difference < 0) { dec %damage.threshold $round($calc($abs(%level.difference) * 1.1),0)  }
    if ((%level.difference >= 0) && (%level.difference <= 100)) { inc %damage.threshold $round($calc(%level.difference * 1.5),0)  }
    if ((%level.difference > 100) && (%level.difference <= 500)) { inc %damage.threshold $round($calc(%level.difference * 2),0)  }
    if ((%level.difference > 500) && (%level.difference <= 1000)) { inc %damage.threshold $round($calc(%level.difference * 3),0)  } 
    if (%level.difference > 1000) { inc %damage.threshold $round($calc(%level.difference * 3.5),0)  } 
    if (%damage.threshold <= 0) { var %damage.threshold 10 }

    if (%attack.damage > %damage.threshold) {
      if ($person_in_mech($1) = false) {  set %temp.damage $calc(%attack.damage / 85)  | set %capamount 3000 }
      if ($person_in_mech($1) = true) { set %temp.damage $calc(%attack.damage / 60) | set %capamount 70000 }
      set %attack.damage $round($calc(%damage.threshold + %temp.damage),0)

      if (%attack.damage >= %capamount) { 
        if ($person_in_mech($1) = false) {  inc %attack.damage $round($calc(%attack.damage * 0.04),0) }
        if ($person_in_mech($1) = true) { inc %attack.damage $round($calc(%attack.damage * 0.08),0) }
      }

    }
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Boost a Demon Wall's
; attack based on the current
; turn.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

demon.wall.boost {
  set %demonwall.turnpercent $calc(%current.turn / %max.demonwall.turns)
  inc %demonwall.turnpercent 1  
  set %attack.damage $round($calc(%demonwall.turnpercent * %attack.damage),0)
  unset %demonwall.turnpercent
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Multiple Hits Calculations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
double.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %original.attackdmg %attack.damage

  set %double.attack.chance $3
  if (%double.attack.chance >= 90) { set %double.attack true

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
        $display.system.message($readini(translation.dat, battle, PerformsADoubleAttack)) 
      } 
    }
    unset %double.attack.chance | unset %original.attackdmg 
  }
  else { unset %double.attack.chance | return }
}
triple.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %triple.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage %attack.damage.total 

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 

  if (%multihit.message.on != on) {
    $display.system.message($readini(translation.dat, battle, PerformsATripleAttack),battle) 
  }

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

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage %attack.damage.total

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 

  if (%multihit.message.on != on) { $display.system.message($readini(translation.dat, battle, PerformsA4HitAttack),battle)   }

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

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)
  set %attack.damage %attack.damage.total 

  set %enemy $set_chr_name($2)  %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
  $set_chr_name($1) 

  if (%multihit.message.on != on) { $display.system.message($readini(translation.dat, battle, PerformsA5HitAttack),battle) }

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

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
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

  if (%multihit.message.on != on) { $display.system.message($readini(translation.dat, battle, PerformsA6HitAttack),battle) }
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

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)

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

  if (%multihit.message.on != on) { $display.system.message($readini(translation.dat, battle, PerformsA7HitAttack),battle) }
  unset %original.attackdmg
}
eighthit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %eighthit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)

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

  if (%multihit.message.on != on) { $display.system.message($readini(translation.dat, battle, PerformsA8HitAttack),battle) }
  unset %original.attackdmg
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modifier Checks for
; elements and weapon types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modifer_adjust {
  ; $1 = target
  ; $2 = element or weapon type

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

    unset %current.accessory | unset %current.accessory.type | unset %accessory.amount
  }
  unset %elements


  ; Turn it into a deciminal
  var %modifier.adjust.value $calc(%modifier.adjust.value / 100) 

  ; If it's over 1, then it means the target is weak to the element/weapon so we can adjust the target's def a little as an extra bonus.
  if (%modifier.adjust.value > 1) {
    var %mon.temp.def $readini($char($1), battle, def)
    var %mon.temp.def = $round($calc(%mon.temp.def - (%mon.temp.def * .10)),0)
    if (%mon.temp.def < 0) { var %mon.temp.def 0 }
    writeini $char($1) battle def %mon.temp.def
  }

  ; If it's under 1, it means the target is resistant to the element/weapon.  Let's make the monster stronger for using something it's resistant to.

  if (%modifier.adjust.value < 1) {
    var %mon.temp.str $readini($char($1), battle, str)
    var %mon.temp.str = $round($calc(%mon.temp.str + (%mon.temp.str * .10)),0)
    if (%mon.temp.str < 0) { var %mon.temp.str 0 }
    writeini $char($1) battle str %mon.temp.str
  }

  ; Adjust the attack damage.
  set %attack.damage $round($calc(%attack.damage * %modifier.adjust.value),0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for Killer Traits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
killer.trait.check {
  var %monster.type $readini($char($2), monster, type)
  if (%monster.type = $null) { return }
  set %killer.trait.name %monster.type $+ -killer
  set %killer.trait.amount $readini($char($1), skills, %killer.trait.name)
  if ((%killer.trait.amount = $null) || (%killer.trait.amount <= 0)) { unset %killer.trait.name | unset %killer.trait.amount | return }

  inc %attack.damage $round($calc(%attack.damage * (%killer.trait.amount / 100)),0)
  unset %killer.trait.name | unset %killer.trait.amount 
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

  ; Start a battle using the mimic type
  $startnormal(mimic)
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
; Checks for Allied Notes reward
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
battle.alliednotes.check {
  var %notes.reward $readini($txtfile(battle2.txt), battle, alliednotes)
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
