;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AI COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias aicheck { 
  set %debug.location aicheck
  unset %statusmessage.display | unset %action.bar | unset %song.name
  remini $char($1) renkei

  ; Determine if the current person in battle is a monster or not.  If so, they need to do a turn.  If not, return.
  if (($is_charmed($1) = true) || ($is_confused($1) = true)) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 6 /ai_turn $1 | halt }

  ; Check to see if it's a defender type. If so, next turn it.  This is needed for surprise attacks on certain monsters..
  if ($readini($char($1), info, ai_type) = defender) {
    if ($readini($char($1), descriptions, DefenderAI) != $null) { $set_chr_name($1) | $display.system.message(4 $+ $readini($char($1), descriptions, DefenderAI), battle) }
    $next 
    halt
  }

  ; Is the person a shadow clone? If so, is the original user using doppelganger style? If not, continue onto the AI..but if so, stop it.

  if ($readini($char($1), info, clone) = yes) {
    var %cloneowner $readini($char($1), info, cloneowner)
    var %style.equipped $readini($char(%cloneowner), styles, equipped)
    if (%style.equipped = doppelganger) {  return  }
  }

  ; Is the person a summon and is the original user using the beastmaster style? If not, continue onto the AI.. but stop if so.
  if ($readini($char($1), info, summon) = yes) {
    var %owner $readini($char($1), info, owner)
    var %style.equipped $readini($char(%owner), styles, equipped)
    if (%style.equipped = beastmaster) {  return  }
  }



  ; Now we check for the AI system to see if it's turned on or not.
  var %ai.system $readini(system.dat, system, aisystem)
  if ((%ai.system = $null) || (%ai.system = on)) { var %ai.wait.time 6
    if (%battle.type = ai) { inc %ai.wait.time 4 }

    if ($readini($char($1), info, flag) = monster) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 %ai.wait.time /ai_turn $1 | halt }
    if ($readini($char($1), info, flag) = npc) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 %ai.wait.time /ai_turn $1 | halt }
    else { return }
  }
  else { return }
}

alias ai_turn {
  set %debug.location ai_turn
  ; Is it the AI's turn?  This is to prevent some bugs showing up..
  if (%who != $1) { return }

  ; If it's an AI's turn, give the AI 45 seconds to make an action.. in case it hangs up.
  /.timerBattleNext 1 45 /next

  ; For now the AI will be very, very basic and random.  Later on I'll try to make it more complicated.
  unset %ai.target | unset %ai.targetlist | unset %ai.tech | unset %opponent.flag | unset %ai.skill | unset %ai.skilllist | unset %ai.type | unset %ai.ignition
  unset %ai.action

  set %ai.type $readini($char($1), info, ai_type) 

  if (%ai.type = portal) { 
    $portal.clear.monsters

    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      var %max.number.of.mons $readini(system.dat, system, MaxNumberOfMonsInBattle)
      if (%max.number.of.mons = $null) { var %max.number.of.mons 6 }
    }
    if ($readini(system.dat, system, botType) = DCCchat) { var %max.number.of.mons 30 }

    if ($readini($txtfile(battle2.txt), battleinfo, Monsters) >= %max.number.of.mons) { 
      $display.system.message(12The Demon Portal glows quietly., battle)
      $check_for_double_turn($1) | halt 

    }
    else {  $portal.summon.monster($1) |  halt }
  }

  if (($readini($char($1), info, flag) = NPC) || ($readini($char($1), info, flag) = monster)) { 
    ; Release snatched targets, if any
    var %cover.target $readini($char($1), skills, CoverTarget)
    if ((%cover.target != none) && (%cover.target != $null)) {
      if ($readini($char($1), info, flag) = monster) { 
        remini $char($1) skills covertarget
        $set_chr_name($1) 

        if ($readini($char(%cover.target), battle, hp) > 0) { 
          $display.system.message($readini(translation.dat, battle, ReleaseSnatchedTarget), battle)
        }
      }
    }

    if ($person_in_mech($1) = false) {
      ; Possibly change weapons.
      $ai.changeweapon($1) 
    }
  }

  ; If a monster has the skill "magicshift" it can use it here at random.
  $ai.magicshift($1)

  ;  If a monster can build a demon portal, then it can use it here at random.
  if (%curse.night != true) {  $ai.buildportal($1) }

  ; If the monster can change the battlefield, try to do it at random here.
  if ($readini($char($1), skills, ChangeBattlefield) >= 1) { $ai.changebattlefield($1) }

  ; Check to see if the monster can summon other monsters
  $ai.monstersummon($1)

  ; Get the type of opponent we need to search for
  if ($readini($char($1), info, flag) = monster) { set %opponent.flag player }
  if ($readini($char($1), info, flag) = npc) { set %opponent.flag monster }

  if ($readini($char($1), status, charmed) = yes) { 
    if ($readini($char($1), info, flag) = monster) { set %opponent.flag monster } 
    else { set %opponent.flag player }
  }
  if ($readini($char($1), status, confuse) = yes) { 
    var %random.target $rand(1,2)
    if (%random.target = 1) { set %opponent.flag monster }
    if (%random.target = 2) { set %opponent.flag player }
  }

  if (%mode.pvp = on) { set %opponent.flag player }

  ; Now that we have the target type, we need to figure out what kind of action to do.
  $ai.buildactionbar($1)

  ; Choose something from the action bar
  set %total.actions $numtok(%action.bar, 46)
  set %random.action $rand(1,%total.actions)
  set %ai.action $gettok(%action.bar,%random.action,46)

  unset %total.actions |  unset %random.action 

  if ($readini($char($1), info, ai_type) = counteronly) { set %ai.action taunt }
  if ($readini($char($1), info, ai_type) = tauntonly) { set %ai.action taunt }
  if ($readini($char($1), info, ai_type) = techonly) {
    if ($readini($char($1), battle, tp) <= 100) { writeini $char($1) battle tp 500 } 

    if (($1 = orb_fountain) || ($1 = lost_soul)) { writeini $char($1) status curse no }

    ; Can the monster use an ignition?
    if ($readini($char($1), status, ignition.on) != on) {
      if ($readini($char($1), info, flag) != $null) { 
        if ($ai_ignitioncheck($1) = true) { %action.bar = tech.ignition }
      }
    }

    if ($readini($char($1), status, curse) = yes) { set %ai.action taunt }
    if ($readini($char($1), status, curse) != yes) {
      if ($istok(%action.bar,ignition,46) = $true) { set %ai.action $iif($rand(1,2) = 1, tech, ignition) }
      else { set %ai.action tech }
    }


  }

  ; do an action
  if (%ai.action = $null) { var %ai.action attack | echo -a 4ERORR: AI ACTION WAS NULL!  }
  writeini $txtfile(battle2.txt) BattleInfo $1 $+ .lastactionbar %ai.action

  if (%ai.action = attack) { $ai_gettarget($1) | $attack_cmd($1, %ai.target) | halt }
  if (%ai.action = tech) { $ai_gettarget($1) |  $tech_cmd($1, %ai.tech, %ai.target) | halt } 
  if (%ai.action = taunt) { set %taunt.action true | $ai_gettarget($1) | $taunt($1 , %ai.target) | halt } 
  if (%ai.action = flee) { $ai.flee($1) | halt }
  if (%ai.action = skill) { $ai_chooseskill($1) | halt }
  if (%ai.action = ignition) { $ignition_cmd($1, %ai.ignition) | halt } 
  if (%ai.action = mech) { $mech.activate($1) } 
}

alias ai.buildactionbar {
  ; This alias builds a list of actions the user is able to do.
  var %last.actionbar.action  $readini($txtfile(battle2.txt), Battleinfo, $1 $+ .lastactionbar)


  if (%ai.type = healer) { 
    if ($ai_techcheck($1) = true) { set %action.bar tech }
    else { set %action.bar flee }
    return
  }

  set %action.bar attack

  ; If the monster is under amnesia, just attack.
  if ($readini($char($1), status, amnesia) = yes) { return }

  ; Can the monster taunt?
  if (($person_in_mech($1) = false) && ($readini($char($1), status, ignition.on) != on)) {
    if ($readini($char($1), info, CanTaunt) != false) { 
      if (%last.actionbar.action != taunt) {  %action.bar = %action.bar $+ .taunt }
    }
  }

  ; Can the monster use skills?
  if ($person_in_mech($1) = false) {  $ai_skillcheck($1) }
  if (%ai.skilllist != $null) { %action.bar = %action.bar $+ .skill }

  ; Can the monster use an ignition?
  if ($readini($char($1), status, ignition.on) != on) {
    if ($readini($char($1), info, flag) != $null) { 
      if ($ai_ignitioncheck($1) = true) { %action.bar = %action.bar $+ .ignition.ignition }
    }
  }

  ; can the monster use a mech?
  if ($person_in_mech($1) = false) {
    if (($readini($char($1), info, flag) != $null) && ($readini($char($1), info, clone) != yes)) {
      if ($ai_mechcheck($1) = true) { %action.bar = %action.bar $+ .mech.mech }
    }
  }

  ; can the monster flee?
  if ($readini($char($1), info, CanFlee) = true) { 
    if (%battle.type != ai) { %action.bar = %action.bar $+ .flee } 
  }

  ; finally, can the monster use a tech?
  if ($ai_techcheck($1) = true) { 
    %action.bar = %action.bar $+ .tech
    if (%last.actionbar.action != tech) {  %action.bar = %action.bar $+ .tech }
  }

  ; Adding attack on there once more for good measure if it wasn't the last action
  if (%last.actionbar.action != attack) {  %action.bar = %action.bar $+ .attack }
}

alias ai_techcheck {
  unset %ai.tech | unset %tech.list | unset %techs | unset %number.of.techs
  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { return }
  $weapon_equipped($1)

  set %techs $readini($dbfile(techniques.db), techs, %weapon.equipped)

  if ($readini($char($1), status, ignition.on) = on) {
    set %ignition.techs $readini($dbfile(ignitions.db), $readini($char($1), status, ignition.name), techs)
    if (%ignition.techs != $null) { %techs = $addtok(%techs, %ignition.techs,46) }
  }

  if (%techs = $null) { return false }

  if ($person_in_mech($1) = false) {  var %current.tp $readini($char($1), battle, tp) }
  if ($person_in_mech($1) = true) { var %current.tp $readini($char($1), mech, energyCurrent) }

  set %number.of.techs $numtok(%techs, 46)
  var %value 1
  while (%value <= %number.of.techs) {
    set %tech.name $gettok(%techs, %value, 46)
    set %tech_level $readini($char($1), techniques, %tech.name)
    if ($person_in_mech($1) = true) {  set %tech_level 1 }
    if ($istok(%ignition.techs,%tech.name,46) = $true) { set %tech_level 1 }

    if ((%tech_level != $null) && (%tech_level >= 1)) { 
      ; add the tech level to the tech list if we have enough tp

      if ($person_in_mech($1) = false) { set %tp.needed $readini($dbfile(techniques.db), %tech.name, tp) }
      if ($person_in_mech($1) = true) { set %tp.needed $readini($dbfile(techniques.db), %tech.name, energyCost) }

      if (%current.tp >= %tp.needed) {
        var %flag $readini($char($1), info, flag)
        if (%flag != $null) { 

          if (%ai.type != healer) { 
            if (($readini($char($1), status, boosted) = no) && ($readini($dbfile(techniques.db), %tech.name, type) = boost)) { %tech.list = $addtok(%tech.list,%tech.name,46) }
            ;;;        if (($readini($char($1), status, FinalGetsuga) = no) && ($readini($dbfile(techniques.db), %tech.name, type) = FinalGetsuga)) { %tech.list = $addtok(%tech.list,%tech.name,46) }
            if (($readini($dbfile(techniques.db), %tech.name, type) != boost) && ($readini($dbfile(techniques.db), %tech.name, type) != FinalGetsuga)) { %tech.list = $addtok(%tech.list,%tech.name,46) }
          }

          if (%ai.type = healer) {
            if ($readini($dbfile(techniques.db), %tech.name, type) = heal) { %tech.list = $addtok(%tech.list,%tech.name,46) }
          }
        }

        if (%flag = $null) {
          if ($readini($dbfile(techniques.db), %tech.name, Type) != FinalGetsuga) { 
            if (($readini($char($1), status, boosted) = no) && ($readini($dbfile(techniques.db), %tech.name, type) = boost)) { %tech.list = $addtok(%tech.list,%tech.name,46) }
            if ($readini($dbfile(techniques.db), %tech.name, type) != boost) { %tech.list = $addtok(%tech.list,%tech.name,46) }
          }
        }
      }
    }
    inc %value 1 
  }

  unset %tp.needed | unset %ignition.techs

  if ((%tech.list = $null) && (%ai.type = healer)) { 
    writeini $char($1) techniques FirstAid 10
    %tech.list = FirstAid
  }

  if (%tech.list = $null) { return false }

  $ai_choosetech

  if (%ai.tech = $null) { return false }

  unset %random.tech | unset %total.techs | unset %weapon.equipped | unset %techs | unset %number.of.techs

  return true
}

alias ai_mechcheck {
  if ($readini($char($1), mech, HpMax) = $null) {  return false }
  if ($readini($char($1), status, ignition.on) = on) { return false }
  if ($readini($char($1), status, boosted) = yes) { return false }
  if ($person_in_mech($1) = true) { return false }
  if ((no-mech isin %battleconditions) && (no-mechs isin %battleconditions)) { return false }

  var %base.energycost $round($calc($mech.baseenergycost($1) / 2),0)
  var %mech.currentenergy $readini($char($1), mech, energyCurrent)

  if (%base.energycost >= %mech.currentenergy) { return false }
  if ($readini($char($1), mech, hpCurrent) <= 0) { return false }

  return true
}

alias ai_ignitioncheck {
  if ($readini($char($1), status, boosted) = yes) { return false }
  if ($person_in_mech($1) = true) { return false }
  if ($readini($char($1), status, virus) = yes)  { return false }
  if ((no-ignition isin %battleconditions) || (no-ignitions isin %battleconditions)) { return false }
  if ((no-playerignition isin %battleconditions) && ($readini($char($1), info, flag) = $null)) { return false }

  unset %ignitions.list | unset %ignitions | unset %number.of.ignitions
  var %value 1 | var %items.lines $lines($lstfile(ignitions.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(ignitions.lst)
    set %item_amount $readini($char($1), ignitions, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      var %flag $readini($char($1), info, clone)  
      if (%flag = $null) { %ignitions.list = $addtok(%ignitions.list,%item.name,46) }
    }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  if (%ignitions.list = $null) { return false }

  set %total.ignitions $numtok(%ignitions.list, 46)
  set %random.ignition $rand(1,%total.ignitions)
  set %ai.ignition $gettok(%ignitions.list,%random.ignition,46)

  unset %total.ignitions | unset %random.ignition

  set %ignition.cost $readini($dbfile(ignitions.db), %ai.ignition, IgnitionTrigger)
  var %player.current.ig $readini($char($1), battle, ignitionGauge)

  if (%player.current.ig <= %ignition.cost) { unset %ignition.cost | return false }

  return true
}

alias ai.flee {
  set %debug.location alias ai.flee
  var %flee.chance $rand(1,100)
  if (%flee.chance <= 60) { $flee($1) | halt }
  if (%flee.chance > 60) {  
    $set_chr_name($1)

    $display.system.message($readini(translation.dat, battle, CannotFleeBattle), battle)

    /.timerCheckForDoubleTurnWait 1 1 /check_for_double_turn $1 | halt 
  }
}

alias ai_gettarget {
  set %debug.location alias ai.gettarget
  unset %ai.targetlist | unset %tech.type

  var %provoke.target $readini($char($1), skills, provoke.target)

  if (%provoke.target != $null) { 
    if ($readini($char(%provoke.target), battle, status) = dead) { unset %provoke.target | remini $char($1) skills provoke.target }
  }


  if (%ai.action = tech) { 
    set %tech.type $readini($dbfile(techniques.db), %ai.tech, type)
  }

  if ((((%tech.type = heal) || (%tech.type = aoeheal) || (%tech.type = ClearStatusNegative) || (%tech.type = buff)))) {
    unset %provoke.target
    if (%opponent.flag = player) { set %opponent.flag monster | goto gettarget }
    if (%opponent.flag = monster) { set %opponent.flag player | goto gettarget }
  }
  else { goto gettarget }

  ; As much as I hate using the goto command, it's the only way I can think of to make the above flag change work right so that healing techs work right.

  :gettarget

  if (%provoke.target != $null) { 
    set %ai.target %provoke.target
    remini $char($1) skills provoke.target
    return
  }

  set %battletxt.lines $lines($txtfile(battle.txt)) | set %battletxt.current.line 1 | unset %tech.type

  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle.ai $read -l $+ %battletxt.current.line $txtfile(battle.txt)

    if (%ai.type = berserker) { 
      if (%who.battle.ai = $1) { 
        if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
      }
      if (%who.battle.ai != $1) { $add_target }   
    }

    if (%ai.type != berserker) { 

      ; The AI is targeting a player or npc.
      if (%opponent.flag = player) {
        if ($readini($char(%who.battle.ai), info, flag) != monster) {
          if (($readini($char($1), info, ai_type) = healer) && ($readini($char(%who.battle.ai), status, zombie) = no)) { $add_target }
          if ($readini($char($1), info, ai_type) != healer) { 
            if (%who.battle.ai = $1) { 
              if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
            }
            if (%who.battle.ai != $1) { $add_target }   
          }
        }
      }

      ; The AI is targeting a monster.
      if (%opponent.flag = monster) {
        if ($readini($char(%who.battle.ai), info, flag) = monster) {
          if ($readini($char($1), info, ai_type) = healer) {     
            if ((%who.battle.ai != demon_portal) && ($readini($char(%who.battle.ai), status, zombie) = no)) { $add_target }   
          }
          else { 
            if (%who.battle.ai = $1) { 
              if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
            }
            if (%who.battle.ai != $1) { $add_target }   
          }
        }
      }

    }

    inc %battletxt.current.line 1
  }

  set %total.targets $numtok(%ai.targetlist, 46)
  set %random.target $rand(1,%total.targets)
  set %ai.target $gettok(%ai.targetlist,%random.target,46)

  if (%ai.target = $null) { 

    if ($readini($char($1), info, ai_type) = healer) { set %ai.target $1 }
    if ($readini($char($1), info, ai_type) != healer) { 
      ; Try a second time.
      set %total.targets $numtok(%ai.targetlist, 46)
      set %random.target $rand(1,%total.targets)
      set %ai.target $gettok(%ai.targetlist,%random.target,46)
    }

    if (%ai.target = $null) { echo -a 4NULL TARGET. SWITCHING TO BERSERK TYPE | set %ai.target $1 | writeini $char($1) info ai_type berserk  }
  }

  if (%ai.action != tech) { 
    $covercheck(%ai.target, $1) 
    set %ai.target %attack.target 
  }

  unset %random.target | unset %total.targets | unset %taunt.action
}

alias ai_getmontarget {
  set %debug.location alias ai_getmontarget
  ; $1 = AI user

  unset %ai.targetlist

  set %battletxt.lines $lines($txtfile(battle.txt)) | set %battletxt.current.line 1

  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle.ai $read -l $+ %battletxt.current.line $txtfile(battle.txt)

    if (($readini($char(%who.battle.ai), battle, status) != runaway) && ($readini($char(%who.battle.ai), battle, hp) > 0)) {
      if (($readini($char(%who.battle.ai), info, flag) = monster) && (%who.battle.ai != $1)) {

        if ($isfile($boss(%who.battle.ai)) != $true) {  $add_target }
      }
    }

    inc %battletxt.current.line 
  } 
}

alias add_target {
  if (%who.battle.ai = $null) { return }

  var %current.status $readini($char(%who.battle.ai), battle, status)
  if ((%current.status = dead) || (%current.status = runaway)) { return }

  else { 
    %ai.targetlist = $addtok(%ai.targetlist, %who.battle.ai, 46)
  }
  return
}

alias ai_choosetech {
  set %total.techs $numtok(%tech.list, 46)
  set %random.tech $rand(1,%total.techs)
  set %ai.tech $gettok(%tech.list,%random.tech,46)
}

alias ai_skillcheck {
  if ($readini($char($1), info, flag) = $null) { return }
  if ($is_confused($1) = true) { return }
  if ((no-skill isin %battleconditions) || (no-skills isin %battleconditions)) { return }
  if ($person_in_mech($1) = true) { return }

  ; Check to see if a monster knows certain skills..
  if ($readini($char($1), skills, royalguard) != $null) { 
    if ($readini($char($1), skills, royalguard.on) != on) {
      writeini $char($1) skills royalguard.time 0 | %ai.skilllist = $addtok(%ai.skilllist, royalguard, 46) 
    }
  }
  if ($readini($char($1), skills, manawall) != $null) { 
    if ($readini($char($1), skills, manawall.on) != on) {
      writeini $char($1) skills manawall.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, manawall, 46) 
    }
  }
  if ($readini($char($1), skills, bloodboost) != $null) { 
    if ($readini($char($1), status, ignition.on) != on) {
      if ($readini($char($1), skills, bloodboost.time) = $null) { %ai.skilllist  = $addtok(%ai.skilllist, bloodboost, 46) }
    }
  }
  if ($readini($char($1), skills, bloodspirit) != $null) { 
    if ($readini($char($1), status, ignition.on) != on) {
      if ($readini($char($1), skills, bloodspirit.time) = $null) { %ai.skilllist  = $addtok(%ai.skilllist, bloodspirit, 46) }
    }
  }
  if ($readini($char($1), skills, sugitekai) != $null) { 
    if ($readini($char($1), skills, doubleturn.on) != on) { remini $char($1) skills doubleturn.time | %ai.skilllist  = $addtok(%ai.skilllist, sugitekai, 46) }
  }
  if ($readini($char($1), skills, mightystrike) != $null) { 
    if ($readini($char($1), skills, mightystrike.on) != on) {
      remini $char($1) skills mightystrike.time | %ai.skilllist  = $addtok(%ai.skilllist, mightystrike, 46) 
    }
  }
  if ($readini($char($1), skills, truestrike) != $null) { 
    if ($readini($char($1), skills, truestrike.on) != on) {
      remini $char($1) skills truestrike.time | %ai.skilllist  = $addtok(%ai.skilllist, truestrike, 46) 
    }
  }
  if ($readini($char($1), skills, konzen-ittai) != $null) { 
    if ($readini($char($1), skills, konzen-ittai.on) != on) {
      writeini $char($1) skills konzen-ittai.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, konzen-ittai, 46) 
    }
  }
  if ($readini($char($1), skills, elementalseal) != $null) { 
    if ($readini($char($1), skills, elementalseal.on) != on) {
      writeini $char($1) skills elementalseal.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, elementalseal, 46) 
    }
  }
  if ($readini($char($1), skills, drainsamba) != $null) {
    ; check to make sure drain samba isn't already on
    if ($readini($char($1), skills, drainsamba.on) != on) {
      writeini $char($1) skills drainsamba.turn 0 | %ai.skilllist  = $addtok(%ai.skilllist, drainsamba, 46)
    }
  }
  if ($readini($char($1), skills, utsusemi) != $null) { 
    if ($readini($char($1), skills, utsusemi.shadows) <= 1) {
      writeini $char($1) skills utsusemi.time 0 | writeini $char($1) item_amount shihei 100 | %ai.skilllist  = $addtok(%ai.skilllist, utsusemi, 46) 
    }
  }
  if ($readini($char($1), skills, shadowcopy) >= 1) {
    if ($isfile($char($1 $+ _clone)) = $false) { %ai.skilllist  = $addtok(%ai.skilllist, shadowcopy, 46)  }
  }
  if ($readini($char($1), skills, cocoonevolve) >= 1) { 
    %ai.skilllist  = $addtok(%ai.skilllist,cocoonevolve, 46) 
  }
  if ($readini($char($1), skills, magicmirror) != $null) { 
    if ($readini($char($1), status, reflect) != yes) {
      writeini $char($1) skills magicmirror.time 0 | writeini $char($1) item_amount mirrorshard 100 | %ai.skilllist  = $addtok(%ai.skilllist, magicmirror, 46) 
    }
  }
  if ($readini($char($1), skills, bloodpact) != $null) { 
    if ($readini($char($1), skills, Summon) != $null) {
      %ai.skilllist  = $addtok(%ai.skilllist, bloodpact, 46) 
    }
  }
  if ($readini($char($1), skills, snatch) != $null) { 
    var %cover.target $readini($char($1), skills, CoverTarget)
    if ((%cover.target = none) || (%cover.target = $null)) {
      writeini $char($1) skills snatch.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, snatch, 46) 
    }
  }
  if ($readini($char($1), skills, MonsterConsume) != $null) { 
    $ai_getmontarget($1)
    if (($numtok(%ai.targetlist, 46) = 0) || ($numtok(%ai.targetlist, 46) = $null)) { return }
    else { %ai.skilllist  = $addtok(%ai.skilllist, monsterconsume, 46) }
  }

  if ($readini($char($1), skills, JustRelease) >= 1) {
    if ($readini($char($1), skills, royalguard.dmgblocked) >= 100) { 
      var %flag $readini($char($1), info, clone)  
      if (%flag = $null) { %ai.skilllist  = $addtok(%ai.skilllist, justrelease, 46) }
    }
  }
  if ($readini($char($1), skills, Cover) >= 1) { 
    if ($readini($char($1), info, flag) != monster) { return }

    %ai.skilllist  = $addtok(%ai.skilllist, cover, 46) 
  }

  if ($readini($char($1), skills, RepairNaturalArmor) >= 1) { 
    if ($readini($char($1), info, flag) = $null) { return }
    if ($readini($char($1), NaturalArmor, current) = 0) {  %ai.skilllist  = $addtok(%ai.skilllist, repairnaturalarmor, 46)  }
  }

  if ($readini($char($1), skills, QuickSilver) >= 1) { 
    if ($readini($char($1), skills, quicksilver.used) = $null) { %ai.skilllist = $addtok(%ai.skilllist, quicksilver, 46) } 
  }

  if ($readini($char($1), skills, Singing) >= 1) { 
    if ($readini($char($1), battle, tp) >= 200) { %ai.skilllist = $addtok(%ai.skilllist, singing, 46) } 
  }

}

alias ai_chooseskill {
  set %total.skills $numtok(%ai.skilllist, 46)
  set %random.skill $rand(1,%total.skills)
  set %ai.skill $gettok(%ai.skilllist,%random.skill,46)
  unset %total.skills | unset %random.skill | unset %ai.skilllist
  if (%ai.skill = royalguard) { $skill.royalguard($1) }
  if (%ai.skill = manawall) { $skill.manawall($1) }
  if (%ai.skill = bloodboost) { $skill.bloodboost($1) }
  if (%ai.skill = bloodspirit) { $skill.bloodspirit($1) }
  if (%ai.skill = sugitekai) { $skill.doubleturn($1)  }
  if (%ai.skill = mightystrike) { $skill.mightystrike($1) }
  if (%ai.skill = truestrike) { $skill.truestrike($1) }
  if (%ai.skill = konzen-ittai) { $skill.konzen-ittai($1) }
  if (%ai.skill = elementalseal) { $skill.elementalseal($1) }
  if (%ai.skill = drainsamba) { $skill.drainsamba($1) } 
  if (%ai.skill = utsusemi) { $skill.utsusemi($1)  }
  if (%ai.skill = magicmirror) { $skill.magicmirror($1)  }
  if (%ai.skill = cocoonevolve) { $skill.cocoon.evolve($1) }
  if (%ai.skill = quicksilver) { $skill.quicksilver($1) } 
  if (%ai.skill = RepairNaturalArmor) { $skill.monster.repairnaturalarmor($1) }
  if (%ai.skill = bloodpact) { $skill.bloodpact($1, $readini($char($1), skills, summon)) | $check_for_double_turn($1)  }
  if (%ai.skill = shadowcopy) {  
    var %shadowcopy.name $readini($char($1), skills, shadowcopy_name)
    if (%shadowcopy.name != $null) { $skill.clone($1, %shadowcopy.name) }
    if (%shadowcopy.name = $null) { $skill.clone($1) } 
  }

  if (%ai.skill = snatch) { 
    ; Get target
    $ai_gettarget($1) 
    $set_chr_name(%ai.target) | set %enemy %real.name
    $set_chr_name($1) | set %user %real.name

    ; Show description
    if ($readini($char($1), descriptions, snatch) = $null) { set %skill.description grabs onto %enemy and tries to use $gender2(%ai.target) as a shield! }
    else { set %skill.description $readini($char($1), descriptions, snatch) }
    $set_chr_name($1) 

    $display.system.message(12 $+ %real.name  $+ %skill.description, battle)

    ; Try to grab the target.
    $do.snatch($1 , %ai.target) 

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  if (%ai.skill = monsterconsume) {
    set %debug.location ai.skill.monsterconsume
    $ai_getmontarget$1)
    set %total.targets $numtok(%ai.targetlist, 46)
    set %random.target $rand(1,%total.targets)
    set %ai.target $gettok(%ai.targetlist,%random.target,46)

    if (%ai.target = $null) { 
      ; Try a second time.
      set %total.targets $numtok(%ai.targetlist, 46)
      set %random.target $rand(1,%total.targets)
      set %ai.target $gettok(%ai.targetlist,%random.target,46)

      ; If it's still null, let's just taunt someone at random.
      if (%ai.target = $null) {
        echo -a 4AI WAS UNABLE TO FIND A TARGET, TAUNTING AT RANDOM
        unset %random.target | unset %total.targets 
        set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt 
      } 
    }
    unset %random.target | unset %total.targets | unset %taunt.action
    $skill.monster.consume($1, %ai.target)
    halt
  }

  if (%ai.skill = singing) {
    ; Get a list of songs the monster knows..

    var %value 1 | var %items.lines $lines($lstfile(songs.lst))
    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(songs.lst)
      set %item_amount $readini($char($1), songs, %item.name)

      if ((%item_amount = 0) && ($readini($char($1), info, flag) = $null)) { remini $char($1) songs %item.name }
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        %songs.list = $addtok(%songs.list, %item.name, 46) 
      }

      unset %item.name | unset %item_amount
      inc %value 1 
    }

    ; Get the random song..
    set %total.songs $numtok(%songs.list, 46)
    set %random.song $rand(1,%total.songs)
    set %song.name $gettok(%songs.list,%random.song,46)
    unset %total.songs | unset %random.song

    ; Make sure the AI has enough TP
    var %tp.needed $readini($dbfile(songs.db), %song.name, tp)
    if ($readini($char($1), battle, tp) < %tp.needed) { writeini $char($1) battle tp %tp.needed }

    ; Make sure the AI has the instrument
    var %instrument.needed $readini($dbfile(songs.db), %song.name, instrument)
    if (($readini($char($1), item_amount, %instrument.needed) = $null) || ($readini($char($1), item_amount, %instrument.needed) <= 0)) { writeini $char($1) item_amount %instrument.needed 1 }

    ; Perform the song.
    $sing.song($1, %song.name)
    halt
  }

  if (%ai.skill = $null) {
    echo -a 4AI TRYING TO USE A NULL SKILL, taunting instead
    unset %random.target | unset %total.targets 
    set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt 
  }

  if (%ai.skill = JustRelease) {
    $ai_gettarget($1)

    ; If it's still null, let's just taunt someone at random.
    if (%ai.target = $null) {
      unset %random.target | unset %total.targets 
      set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt 
    } 
  }

  if (%ai.skill = cover) {
    remini $char($1) skills cover
    var %monster.master $readini($char($1), info, master) 
    set %ai.target %monster.master

    if (((%monster.master = $null) || ($readini($char(%monster.master), battle, status) = dead) || ($readini($char(%monsters.master), battle, status) = runaway))) {
      $ai_getmontarget($1)
      set %total.targets $numtok(%ai.targetlist, 46)
      set %random.target $rand(1,%total.targets)
      set %ai.target $gettok(%ai.targetlist,%random.target,46)

      if (%ai.target = $null) { 
        ; Try a second time.
        set %total.targets $numtok(%ai.targetlist, 46)
        set %random.target $rand(1,%total.targets)
        set %ai.target $gettok(%ai.targetlist,%random.target,46)
      }

      ; If it's still null, let's just taunt someone at random.
      if (%ai.target = $null) {
        unset %random.target | unset %total.targets 
        set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt 
      } 
    }
    unset %random.target | unset %total.targets | unset %taunt.action
    $skill.cover($1, %ai.target)
    halt
  }

  unset %random.target | unset %total.targets | unset %taunt.action
  $skill.justrelease($1, %ai.target, !justrelease)
  halt
}

alias ai.changeweapon {
  if ($readini($char($1), status, weapon.locked) != $null) { return }

  if ($readini($char($1), info, clone) = yes) { return }
  if ($readini($char($1), info, clone) != yes) {
    var %changeweapon.chance $rand(1,100)
    if (%changeweapon.chance > 70) { unset %changeweapon.chance | return }
  }

  $weapons.get.list($1)

  if (%base.weapon.list = $null) {  unset %weaponlist.counter | unset %weapons | unset %weapons.list1 | return }

  if ($readini($char($1), weapons, fists) = $null) { %base.weapon.list = $deltok(%base.weapon.list,Fists,46) }

  var %current.weapon $readini($char($1), weapons, equipped)
  set %weapons.total $numtok(%base.weapon.list,46)
  set %random.weapon $rand(1, %weapons.total) 
  set %weapon.name $gettok(%base.weapon.list,%random.weapon,46)

  unset %weapons.total | unset %random.weapon | unset %base.weapon.list

  if (%weapon.name = %current.weapon) { unset %weaponlist.counter | unset %weapons | unset %weapons.list1 | unset %weapon.name | return }

  writeini $char($1) weapons equipped %weapon.name | $set_chr_name($1) 

  $display.system.message($readini(translation.dat, system, EquipWeaponMonster), battle)

  unset %weapon.name | unset %weaponlist.counter | unset %weapons | unset %weapons.list1
}

alias ai.magicshift {
  set %debug.location ai.magicshift 
  if ($is_charmed($1) = true) { return }
  if ($readini($char($1), skills, magicshift) >= 1) { 
    var %magicshift.chance $rand(1,100)
    if (%magicshift.chance <= 45) { $skill.magic.shift($1) }
  }
}

alias ai.buildportal {
  set %debug.location ai.buildportal
  if (%battle.type = ai) { return } 

  if ($is_charmed($1) = true) { return }
  if ($readini($char($1), skills, demonportal) >= 1) { 
    var %portal.chance $rand(1,110)
    if (%portal.chance <= 25) { $skill.demonportal($1) }
  }
}

alias ai.changebattlefield {
  var %change.chance $readini($char($1), skills, ChangeBattlefield.chance)
  if (%change.chance = $null) { var %change.chance 15 }

  var %random.chance $rand(1,100)

  if (%random.chance > %change.chance) { return }
  set %battlefields $readini($char($1), skills, ChangeBattlefield.battlefields)
  set %number.of.battlefields $numtok(%battlefields,46)

  if (%number.of.battlefields >= 1) {
    set %random.battlefield $rand(1,%number.of.battlefields)
    set %battlefield.tochange $gettok(%battlefields,%random.battlefield,46)

    if (%battlefield.tochange = %current.battlefield) { unset %battlefields | unset %number.of.battlefields | unset %random.battlefield | unset %battlefield.tochange | return }

    set %current.battlefield %battlefield.tochange

    $set_chr_name($1)
    var %skill.message $readini($char($1), Descriptions, ChangeBattlefield)
    if (%skill.message = $null) { var %skill.message channels a powerful energy to teleport everyone to a new battlefield. Everyone finds themselves now on the %current.battlefield battlefield. }
    $display.system.message(12 $+ %real.name  $+ %skill.message, battle)
  }

  unset %battlefields | unset %number.of.battlefields | unset %random.battlefield | unset %battlefield.tochange

}

alias ai.monstersummon {
  set %debug.location ai.monstersummon
  if ($is_charmed($1) = true) { return }
  if ($readini($char($1), skills, monstersummon) >= 1) { 
    $portal.clear.monsters
    var %summon.chance $rand(1,100)
    if (%summon.chance <= $readini($char($1), skills, monstersummon.chance)) {

      if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
        var %max.number.of.mons $readini(system.dat, system, MaxNumberOfMonsInBattle)
        if (%max.number.of.mons = $null) { var %max.number.of.mons 6 }
      }

      if ($readini(system.dat, system, botType) = DCCchat) { var %max.number.of.mons 50 }

      var %current.number.of.mons $readini($txtfile(battle2.txt), battleinfo, Monsters)
      var %number.of.monsters.to.spawn $readini($char($1), skills, monstersummon.numberspawn)
      inc %current.number.of.mons %number.of.monsters.to.spawn

      if (%current.number.of.mons <= %max.number.of.mons) { 
        var %monster.name $readini($char($1), skills, monstersummon.monster)
        if (%monster.name != $null) { $skill.monstersummon($1, %monster.name) }
      }
    }
  }
}

alias ai.learncheck {
  if ($readini($char($1), info, flag) = $null) { return }
  if ($readini($char($1), monster, techlearn) != true) { return }
  if ($readini($dbfile(techniques.db), $2, type) = $null) { return }
  writeini $char($1) modifiers $2 0
}
