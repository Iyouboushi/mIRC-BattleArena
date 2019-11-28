;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TECHS COMMAND
;;;; Last updated: 11/28/19
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 3:ACTION:goes *:#: { 
  if ($3 != $null) { halt }
  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($nick)
  $set_chr_name($nick) 

  var %ignitions.list $ignitions.get.list($nick)

  if ($istok(%ignitions.list, $2, 46) = $true) { unset %ignitions.list | $ignition_cmd($nick, $2, $nick) | halt }
  else { $tech_cmd($nick , $2, $nick) | halt }
} 

ON 3:TEXT:!goes *:#:{
  if ($3 != $null) { halt }
  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($nick)
  $set_chr_name($nick) 

  var %ignitions.list $ignitions.get.list($nick)

  if ($istok(%ignitions.list, $2, 46) = $true) { unset %ignitions.list | $ignition_cmd($nick, $2, $nick) | halt }
  else { $tech_cmd($nick , $2, $nick) | halt }
}

ON 3:ACTION:reverts*:#: {
  $check_for_battle($nick) 
  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ($3 = $null) { halt }
  $no.turn.check($nick)
  $set_chr_name($nick) 

  var %ignition.name $readini($char($nick), status, ignition.name)
  if (%ignition.name = $3) {   
    $revert($nick, $3)  |   var %ignition.name $readini($dbfile(ignitions.db), $readini($char($nick), status, ignition.name), name)
    $display.message($readini(translation.dat, system, IgnitionReverted),battle)
    halt
  }
  else { $display.message($readini(translation.dat, errors, NotUsingThatIgnition),battle) | halt }
} 
ON 3:TEXT:!reverts*:#: {
  $check_for_battle($nick) 
  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ($2 = $null) { halt }
  $no.turn.check($nick)
  $set_chr_name($nick) 

  var %ignition.name $readini($char($nick), status, ignition.name)
  if (%ignition.name = $2) {   
    $revert($nick, $2)  |   var %ignition.name $readini($dbfile(ignitions.db), $readini($char($nick), status, ignition.name), name)
    $display.message($readini(translation.dat, system, IgnitionReverted),battle)
    halt
  }
  else { $display.message($readini(translation.dat, errors, NotUsingThatIgnition),battle) | halt }
} 
ON 50:TEXT:*reverts from *:*:{ 
  $check_for_battle($1) 
  if ($4 = $null) { halt }
  $no.turn.check($1,admin)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $set_chr_name($1) 
  var %ignition.name $readini($char($1), status, ignition.name)
  if (%ignition.name = $4) {   
    $revert($1, $4) 
    $display.message($readini(translation.dat, system, IgnitionReverted),battle)
    halt
  }
  else { $display.message($readini(translation.dat, errors, NotUsingThatIgnition),battle) | halt }
}
ON 3:TEXT:*reverts from *:*:{ 
  $check_for_battle($1) 
  if ($2 != reverts) { halt } 
  if ($4 = $null) { halt }
  if ($readini($char($1), stuff, redorbs) = $null) { halt }

  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($readini(translation.dat, errors, PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($readini(translation.dat, errors, PlayerAccessOffDueToLogin), private) | halt }
  $no.turn.check($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $set_chr_name($1) 
  var %ignition.name $readini($char($1), status, ignition.name)
  if (%ignition.name = $4) {   
    $revert($1, $4) 
    $display.message($readini(translation.dat, system, IgnitionReverted),battle)
    halt
  }
  else { $display.message($readini(translation.dat, errors, NotUsingThatIgnition),private) | halt }
}


ON 3:ACTION:limit breaks * with *:#:{
  if (%battleis = off) { halt }
  if ($3 = $null) { halt }
  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($nick) 
  $limitbreak_cmd($nick, $5, $3)
}

ON 50:TEXT:*limit breaks * with *:*:{ 
  $check_for_battle($1) 
  if ($4 = $null) { halt }
  $no.turn.check($1,admin)
  if (%battleis = off) { halt }
  if ($3 = $null) { halt }
  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $limitbreak_cmd($1, $6, $4)
}

alias limitbreak_cmd { 
  ; $1 = the person performing
  ; $2 = the limit break name
  ; $3 = the target

  ; Make sure some old attack variables are cleared.
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged 
  unset %techincrease.check | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on  | unset %lastaction.nerf

  $check_for_battle($1) 

  ; does the player own this limit break?
  if ($readini($char($1), LimitBreaks, $2) != 1) { $display.message($readini(translation.dat, errors, DoNotKnowLimitBreak), private) | halt }

  ; Does the player have enough limit break meter to perform the limit break?
  var %meter.needed $readini($dbfile(limitbreaks.db), $2, MeterNeeded)
  if ($readini($char($1), Battle, LimitBreakPercent) < %meter.needed) { $display.message($readini(translation.dat, errors, NotEnoughLimitMeter), private) | halt }

  ; Is there a no-limits battle condition?
  if (((no-limit isin %battleconditions) || (no-limitbreaks isin %battleconditions) || (no-limits isin %battleconditions))) { 
    $set_chr_name($1) | $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt 
  }

  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious),private)  | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFledTech),private) | unset %real.name | halt } 

  ; Perform the limit break
  $partial.name.match($1, $3)
  $limitbreak.attack($1, $2,  %attack.target)
}


ON 3:ACTION:sings *:#:{ 
  if (%battleis = off) { halt }
  if ($3 != $null) { halt }

  $set_chr_name($nick) 

  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($nick) 
  $sing.song($nick, $2)
}

ON 3:TEXT:!sing *:#:{ 
  if (%battleis = off) { halt }
  if ($3 != $null) { halt }

  $set_chr_name($nick) 

  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($nick) 
  $sing.song($nick, $2)
}

ON 50:TEXT:*sings *:*:{ 
  if (%battleis = off) { halt }
  if ($4 != $null) { halt }

  $set_chr_name($1) 

  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  $sing.song($1, $3)
}

ON 3:TEXT:*sings *:*:{ 
  if (%battleis = off) { halt }
  if ($3 = $null) { halt }
  if ($4 != $null) { halt }
  if ($readini($char($1), stuff, redorbs) = $null) { halt }
  if ($readini($char($1), info, flag) = monster) { halt }
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }

  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($readini(translation.dat, errors, PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($readini(translation.dat, errors, PlayerAccessOffDueToLogin), private) | halt }

  $set_chr_name($1) 


  $no.turn.check($1)
  $sing.song($1, $3)
}

ON 3:ACTION:uses * * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $5)
  $tech_cmd($nick , $3 , %attack.target, $7) | halt 
} 
ON 3:TEXT:!tech * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $tech_cmd($nick , $2 , %attack.target, $5) | halt 
} 
ON 50:TEXT:*uses * * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }

  $no.turn.check($1,admin)

  var %ignitions.list $ignitions.get.list($1)

  $partial.name.match($1, $6)

  if ($istok(%ignitions.list, $4, 46) = $true) { unset %ignitions.list | $ignition_cmd($1, $4, $nick) | halt }
  else { $tech_cmd($1 , $4,  %attack.target) | halt }
}
ON 3:TEXT:*uses * * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }
  if ($readini($char($1), stuff, redorbs) = $null) { halt }

  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($readini(translation.dat, errors, PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($readini(translation.dat, errors, PlayerAccessOffDueToLogin), private) | halt }

  $no.turn.check($1)

  var %ignitions.list $ignitions.get.list($1)

  $partial.name.match($1, $6)

  if ($istok(%ignitions.list, $4, 46) = $true) { unset %ignitions.list | $ignition_cmd($1, $4, $nick) | halt }
  else { $tech_cmd($1 , $4,  %attack.target) | halt }
}

alias tech_cmd {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  ; Make sure some old attack variables are cleared.
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged 
  unset %techincrease.check | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on  | unset %lastaction.nerf

  $check_for_battle($1) 

  set %ignition.list $readini($dbfile(ignitions.db), ignitions, list)
  if ($istok(%ignition.list, $2, 46) = $true) { unset %ignition.list | $ignition_cmd($1, $2, $1) | halt }

  set %tech.type $readini($dbfile(techniques.db), $2, Type) | $amnesia.check($1, tech) 

  if ($person_in_mech($1) = false) {

    if ($readini($char($1), techniques, $2) = $null) { 
      if ($readini($char($1), status, ignition.on) != on) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotKnowTech),private) | halt }

      ; Is it an ignition tech that we know?
      set %ignition.name $readini($char($1), status, ignition.name)
      set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
      if ($istok(%ignition.techs,$2,46) = $false) { unset %ignition.name | unset %ignition.techs | $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotKnowTech),private) | halt  }
    }
  }

  if ($person_in_mech($1) = true) {
    set %mech.weaponname $readini($char($1), mech, equippedWeapon)
    set %mech.techs $readini($dbfile(weapons.db), %mech.weaponname, abilities)
    if ($istok(%mech.techs,$2,46) = $false) { unset %mech.weaponname | unset %mech.techs | $set_chr_name($1) | %real.name = %real.name $+ 's $readini($char($1), mech, name) | $display.message($readini(translation.dat, errors, DoesNotKnowTech),private) | halt  }
  }

  unset %ignition.name | unset %ignition.techs

  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { 
    if (($readini($char($1), info, ai_type) != healer) && ($readini($char($1), info, ai_type) != techonly)) { 
      $set_chr_name($1) | $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt 
    }
  }

  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious),private)  | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFledTech),private) | unset %real.name | halt } 

  $person_in_battle($3) | $checkchar($3) 

  ; Get the weapon equipped
  $weapon_equipped($1)

  ; Check to see if the weapons require ammo to use this technique
  if ($readini($char($1), info, flag) = $null) { 
    var %ammo.amount.met false
    var %ammo.needed false

    ; Check right hand
    var %weapon.ammo $readini($dbfile(weapons.db), %weapon.equipped, AmmoRequired)
    if (%weapon.ammo != $null) { 
      var %ammo.needed true
      var %weapon.ammo.amount $readini($dbfile(weapons.db), %weapon.equipped, AmmoAmountNeeded)
      var %player.ammo.amount $readini($char($1), item_amount, %weapon.ammo)
      if (%player.ammo.amount = $null) { var %player.ammo.amount 0 }

      if (%player.ammo.amount >= %weapon.ammo.amount) { 
        dec %player.ammo.amount %weapon.ammo.amount
        writeini $char($1) item_amount %weapon.ammo %player.ammo.amount
        var %ammo.amount.met true 
      }
    }

    ; check the left hand
    if (%weapon.equipped.left != $null) { 
      var %weapon.ammo $readini($dbfile(weapons.db), %weapon.equipped.left, AmmoRequired)

      if ((%weapon.ammo != $null) && (%ammo.amount.met = false)) {
        var %ammo.needed true
        var %weapon.ammo.amount $readini($dbfile(weapons.db), %weapon.equipped.left, AmmoAmountNeeded)
        var %player.ammo.amount $readini($char($1), item_amount, %weapon.ammo)
        if (%player.ammo.amount = $null) { var %player.ammo.amount 0 }

        if (%player.ammo.amount >= %weapon.ammo.amount) { 
          dec %player.ammo.amount %weapon.ammo.amount
          writeini $char($1) item_amount %weapon.ammo %player.ammo.amount
          var %ammo.amount.met true 
        }
      }
    }

    if ((%ammo.needed = true) && (%ammo.amount.met = false))  { $display.message($readini(translation.dat, errors, NeedAmmoToDoThis), private) | unset %weapon.equipped | halt }

  }


  $tech.abilitytoperform($1, $2, %weapon.equipped)

  if ($person_in_mech($1) = false) { 
    ; Make sure the user has enough TP to use this in battle..
    set %tp.needed $readini($dbfile(techniques.db), p, $2, TP) | set %tp.have $readini($char($1), battle, tp)

    ; Check for ConserveTP
    if (($readini($char($1), status, conservetp) = yes) || ($readini($char($1), status, conservetp.on) = on)) { set %tp.needed 0 | writeini $char($1) status conserveTP no }
    if (($readini($char($1), skills, thinair.on) = on) && ($readini($dbfile(techniques.db), $2, spell) = yes)) { set %tp.needed 0 | writeini $char($1) skills thinair.on off }

    if (%tp.needed = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotKnowTech), private) | halt }
    if (%tp.needed > %tp.have) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, NotEnoughTPforTech),private) | halt }
  }

  ; If a person is in a mech, check to see if we have enough energy to use this tech.
  if ($person_in_mech($1) = true) { 
    var %energydrain $readini($dbfile(techniques.db), $2, energyCost)
    if (%energydrain = $null) { var %energydrain 100 }
    var %current.energy $readini($char($1), mech, EnergyCurrent)
    dec %current.energy %energydrain
    if (%current.energy <= 0) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, MechNotEnoughEnergyForTech), battle) | halt }
    if (%current.energy > 0) { $mech.energydrain($1, tech, $2) }
  }

  if (%covering.someone != on) {
    if (%mode.pvp != on) {
      if ($3 = $1) {
        if (($is_confused($1) = false) && ($is_charmed($1) = false))  { 
          if (%tech.type !isin boost.finalgetsuga.heal.heal-AOE.buff.ClearStatusNegative.ClearStatusPositive) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, Can'tAttackYourself),private) | unset %real.name | halt  }
        }
      }
    }
  }
  if (%tp.needed = $null) { var %tp.needed 0 }

  dec %tp.have %tp.needed | writeini $char($1) battle tp %tp.have | unset %tp.have | unset %tp.needed

  ; Check for a prescript
  if ($readini($dbfile(techniques.db), n, $2, PreScript) != $null) { $readini($dbfile(techniques.db), p, $2, PreScript) }

  if (%tech.type = boost) { 
    if (%battle.type = dungeon) { $display.message($readini(translation.dat, errors, Can'tBoostInDungeon), private) | halt }
    if ($readini($char($1), status, virus) = yes) { $display.message($readini(translation.dat, errors, Can'tBoostHasVirus),private) | halt }
    if (($readini($char($1), status, boosted) = yes) || ($readini($char($1), status, ignition.on) = on)) { 
      if ($readini($char($1), info, flag) = $null) {
        $set_chr_name($1) | $display.message($readini(translation.dat, errors, AlreadyBoosted), private) | halt 
      }
    }

    $tech.boost($1, $2, $3)
  } 

  if (%tech.type = finalgetsuga) { $tech.finalgetsuga($1, $2, $3) } 

  if (%tech.type = buff) {  $tech.buff($1, $2, $3) }
  if (%tech.type = ClearStatusPositive) {  $tech.clearstatus($1, $2, $3, positive) }
  if (%tech.type = ClearStatusNegative) {  $tech.clearstatus($1, $2, $3, negative) }

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($3), info, flag)
  var %ai.type $readini($char($1), info, ai_type)

  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster } 
  if (%tech.type = heal) { var %user.flag monster }
  if (%tech.type = heal-aoe) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }
  if (%ai.type = berserker) { var %user.flag monster }
  if ($readini($char($1), monster, berserk) = true) { var %user.flag monster }
  if (%covering.someone = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanOnlyAttackMonsters),private)  | halt }

  if (%tech.type = heal) { $tech.heal($1, $2, $3) }
  if (%tech.type = heal-aoe) { $tech.aoeheal($1, $2, $3) }
  if (%tech.type = single) {  $covercheck($3, $2) | $tech.single($1, $2, %attack.target )  }
  if (%tech.type = suicide) { $covercheck($3, $2) | $tech.suicide($1, $2, %attack.target )  }
  if (%tech.type = GiveEnmity) { $tech.giveenmity($1, $2, %attack.target) } 

  if (%tech.type = death) { $covercheck($3, $2) | $tech.death($1, $2, %attack.target) } 
  if (%tech.type = death-aoe) { 
    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $tech.deathaoe($1, $2, $3, player) | halt }
      if (%current.flag = monster) { $tech.deathaoe($1, $2, $3, monster) | halt }
    }
    else {
      ; check for confuse.
      if ($is_confused($1) = true) { 
        var %random.target.chance $rand(1,2)
        if (%random.target.chance = 1) { var %user.flag monster }
        if (%random.target.chance = 2) { unset %user.flag }
      }

      ; Determine if it's players or monsters
      if (%user.flag = monster) { $tech.deathaoe($1, $2, $3, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $tech.deathaoe($1, $2, $3, monster) | halt }
    }
  } 

  if (%tech.type = suicide-AOE) { 
    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $tech.aoe($1, $2, $3, player, suicide) | halt }
      if (%current.flag = monster) { $tech.aoe($1, $2, $3 , monster, suicide) | halt }
    }
    else {
      ; Determine if it's players or monsters
      if (%user.flag = monster) { $tech.aoe($1, $2, $3, player, suicide) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $tech.aoe($1, $2, $3, monster, suicide) | halt }
    }
  }

  if (%tech.type = status) { $covercheck($3, $2) | $tech.single($1, $2, %attack.target ) } 
  if (%tech.type = stealPower) { $covercheck($3, $2) | $tech.stealPower($1, $2, %attack.target ) }

  if (%tech.type = AOE) { 
    if ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction)) { set %lastaction.nerf true }

    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $tech.aoe($1, $2, $3, player) | halt }
      if (%current.flag = monster) { $tech.aoe($1, $2, $3, monster) | halt }
    }
    else {
      ; check for confuse.
      if ($is_confused($1) = true) { 
        var %random.target.chance $rand(1,2)
        if (%random.target.chance = 1) { var %user.flag monster }
        if (%random.target.chance = 2) { unset %user.flag }
      }

      ; Determine if it's players or monsters

      if ($readini($char($1), monster, berserk) = true) {  
        if ($readini($char(%ai.target), info, flag) = monster) { var %user.flag npc }
        else { var %user.flag monster } 
      }

      if (%user.flag = monster) { $tech.aoe($1, $2, $3, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $tech.aoe($1, $2, $3, monster) | halt }
    }
  }

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Can a tech be performed
; using the equipped weapon?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.abilitytoperform {
  ; $1 = user
  ; $2 = tech name
  ; $3 = weapon name

  if ($readini($char($1), info, ai_type) = healer) { return }

  if ($readini($char($1), status, ignition.on) = on) {
    set %ignition.name $readini($char($1), status, ignition.name)
    set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
    if ($istok(%ignition.techs,$2,46) = $true) { unset %ignition.name | unset %ignition.techs | return }
  }

  set %weapon.abilities $readini($dbfile(techniques.db), Techs, $3)
  if (%battle.type != cosmic) { 
    if (%weapon.equipped.left != $null) { %weapon.abilities = $addtok(%weapon.abilities, $readini($dbfile(techniques.db), Techs, %weapon.equipped.left), 46) } 
  }

  if ($istok(%weapon.abilities,$2,46) = $false) { unset %weapon.abilities |  $set_chr_name($1) | $display.message($readini(translation.dat, errors, Can'tPerformTechWithWeapon),private) | halt }

  unset %techs | unset %ignition.name |  unset %weapon.abilities | unset %ignition.techs | unset %equipped.weapon.left
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a give enmity tech
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.giveenmity {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name

  ; Decrease the action points
  $action.points($1, remove, 3)

  $display.message(03 $+ %user $+  $readini($dbfile(techniques.db), $2, desc), battle)

  var %enmity.gained $readini($dbfile(techniques.db), $2, EnmityGained)
  if (%enmity.gained = $null) { var %enmity.gained 100 }
  $enmity($3, add, %enmity.gained)

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a clear status tech
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.clearstatus {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  ; $4 = positive or negative

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name

  ; Decrease the action points
  $action.points($1, remove, 3)

  $display.message(03 $+ %user $+  $readini($dbfile(techniques.db), $2, desc), battle)

  if ($person_in_mech($1) = false) { 
    if ($4 = positive) { $clear_positive_status($3, tech) }
    if ($4 = negative) { $clear_negative_status($3) }
  }

  if ($person_in_mech($3) = true) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, NoWorkOnMech), battle) }

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }
}

alias tech.buff {
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name

  ; Decrease the action points
  $action.points($1, remove, 3)

  if ($person_in_mech($3) = false) { 

    set %buff.type $readini($dbfile(techniques.db), $2, status)

    ; If the user is a player and isn't confused or charmed, we should check to see if the target already has the buff on.  If so, why apply it again?
    if ($readini($char($1), info, flag) = $null) {
      if (($is_charmed($1) != true) && ($is_confused($1) != true))  { 
        if ($readini($char($3), status, %buff.type) = yes) { $set_chr_name($3) | $display.message($readini(translation.dat, errors, AlreadyHasThisBuff), private)
          var %tp.required $readini($dbfile(techniques.db), $2, tp)  
          $restore_tp($1, %tp.required) | unset %buff.type
          halt 
        }
      }
    }
  }

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  $display.message(03 $+ %user $+  $readini($dbfile(techniques.db), $2, desc), battle)

  if ($person_in_mech($3) = false) { 

    writeini $char($3) status %buff.type $+ .timer 0

    if (%buff.type != en-spell) {  

      writeini $char($3) status %buff.type yes 

      if ($readini($dbfile(techniques.db), $2, modifier) != $null) {
        ; This buff adds resistances to the target's file.
        var %modifier.type $readini($dbfile(techniques.db), $2, modifier)
        set %target.modifier $readini($char($3), modifiers, %modifier.type)
        if (%target.modifier = $null) { var %target.modifier 100 }
        dec %target.modifier 27 
        if (%target.modifier < 0) { var %target.modifier 0 }
        writeini $char($3) modifiers %modifier.type %target.modifier
        unset %target.modifier
      }

      $display.message($readini(translation.dat, status, GainedBuff), battle)
    }

    if (%buff.type = en-spell) {
      var %enspell.element $readini($dbfile(techniques.db), $2, element)
      if (%enspell.element != $null) {  writeini $char($3) status en-spell %enspell.element }
      $display.message($readini(translation.dat, status, GainedEnspell), battle)
    }
  }
  if ($person_in_mech($3) = true) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, BuffNotOnMech), battle) }

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }


  unset %buff.type


  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a regular tech
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.single {
  ; $3 = target

  ; Decrease the action points
  $action.points($1, remove, 4)

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  var %tech.element $readini($dbfile(techniques.db), $2, element)
  var %target.element.heal $readini($char($3), modifiers, heal)
  if ((%tech.element != none) && (%tech.element != $null)) {
    if ($istok(%target.element.heal,%tech.element,46) = $true) { 
      $tech.heal($1, $2, $3, %absorb)
      return
    }
  }

  if ($readini($dbfile(techniques.db), $2, absorb) = yes) { set %absorb absorb }
  else { set %absorb none }

  if (($readini($char($3), status, reflect) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) {
    $calculate_damage_techs($1, $2, $1)
    if (%attack.damage >= 4000) { set %attack.damage $rand(2800,3500) }
    unset %absorb
    $deal_damage($1, $1, $2, %absorb, tech)
  }
  else { 
    $calculate_damage_techs($1, $2, $3)
    $deal_damage($1, $3, $2, %absorb, tech)
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  $display_damage($1, $3, tech, $2, %absorb)
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a steal power tech
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.stealPower {
  ; $1 = user
  ; $2 = tech name
  ; $3 = target

  set %attack.damage 0

  ; Decrease the action points
  $action.points($1, remove, 4)

  $calculate_damage_techs($1, $2, $3)

  ; If it's the blood moon, increase the amount by a random amount.
  if (%bloodmoon = on) { inc %attack.damage $rand(1,100) }

  if (%attack.damage <= 0) { set %attack.damage 5 }

  ; Does the target have a guardian that has to be defeated first?  If so, check to see if guardian is dead.  
  ; If it isn't, set the attack damage to 0.
  var %guardian.target $readini($char($3), info, guardian)

  if (%guardian.target != $null) { 
    var %guardian.status $readini($char(%guardian.target), battle, hp)
    if (%guardian.status > 0) { set %attack.damage 0 }   
  }

  var %winning.streak $return_winningstreak
  if (%battle.type = ai) { var %winning.streak %ai.battle.level }
  if ((%battle.rage.darkness = on) && ($readini($char($1), info, flag) = monster)) { inc %winning.streak 5000 }

  var %stealpower.multiplier $round($calc(%winning.streak / 30),1)
  var %max.stealpower $round($calc(%stealpower.multiplier * 80),0) 
  unset %winning.streak

  if (%attack.damage > %max.stealpower) { set %attack.damage %max.stealpower }
  unset %max.stealpower

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name

  $display.message(03 $+ %user $+  $readini($dbfile(techniques.db), $2, desc), battle)

  if ($person_in_mech($3) = false) {  

    if (%guard.message = $null) {

      var %attacker.str $readini($char($1), battle, str)
      var %attacker.def $readini($char($1), battle, def)
      var %attacker.int $readini($char($1), battle, int)
      var %attacker.spd $readini($char($1), battle, spd)

      if ($calc($readini($char($3), battle, str) - %attack.damage) <= 1) { var %amount.of.str $readini($char($3), battle, str) | inc %attacker.str $readini($char($3), battle, str) | writeini $char($3) battle str 1 }
      if ($calc($readini($char($3), battle, str) - %attack.damage) >= 1) { var %amount.of.str %attack.damage | inc %attacker.str %attack.damage | writeini $char($3) battle str $calc($readini($char($3), battle, str) - %amount.of.str) }

      inc %attack.damage $rand(0,2)
      if ($calc($readini($char($3), battle, def) - %attack.damage) <= 1) { var %amount.of.def $readini($char($3), battle, def) | inc %attacker.def $readini($char($3), battle, def) | writeini $char($3) battle def 1 }
      if ($calc($readini($char($3), battle, def) - %attack.damage) >= 1) { var %amount.of.def %attack.damage | inc %attacker.def %attack.damage | writeini $char($3) battle def $calc($readini($char($3), battle, def) - %amount.of.def) }

      inc %attack.damage $rand(0,3)
      if ($calc($readini($char($3), battle, int) - %attack.damage) <= 1) { var %amount.of.int $readini($char($3), battle, int) | inc %attacker.int $readini($char($3), battle, int) | writeini $char($3) battle int 1 }
      if ($calc($readini($char($3), battle, int) - %attack.damage) >= 1) { var %amount.of.int %attack.damage | inc %attacker.int %attack.damage | writeini $char($3) battle int $calc($readini($char($3), battle, int) - %amount.of.int) }

      inc %attack.damage $rand(0,1)
      if ($calc($readini($char($3), battle, spd) - %attack.damage) <= 1) { var %amount.of.spd $readini($char($3), battle, spd) | inc %attacker.spd $readini($char($3), battle, spd) | writeini $char($3) battle spd 1 }
      if ($calc($readini($char($3), battle, spd) - %attack.damage) >= 1) { var %amount.of.spd %attack.damage | inc %attacker.spd %attack.damage | writeini $char($3) battle spd $calc($readini($char($3), battle, spd) - %amount.of.spd) }

      var %total.points.stolen $calc(%amount.of.str + %amount.of.def + %amount.of.int + %amount.of.spd)

      var %levels.gained $round($log(%total.points.stolen),0)
      var %current.level $get.level($1)
      inc %current.level %levels.gained
      $levelsync($1, %current.level)

      $set_chr_name($1) | $display.message($readini(translation.dat, tech, StolenPower), battle)

      ; Can the monster also steal status effects?
      if ($readini($dbfile(techniques.db), $2, StealStatus) = true) {
        unset %stolen.status.effects

        if ($readini($char($3), status, Regenerating) = yes) { writeini $char($1) status Regenerating yes | %stolen.status.effects = $addtok(%stolen.status.effects, Regen, 46) }
        if ($readini($char($3), status, TPRegenerating) = yes) { writeini $char($1) status TPRegenerating yes | %stolen.status.effects = $addtok(%stolen.status.effects, TP Regen, 46) }
        if ($readini($char($3), status, ConserveTP) = yes) { writeini $char($1) status ConserveTP yes | %stolen.status.effects = $addtok(%stolen.status.effects, Conserve TP, 46) }
        if ($readini($char($3), status, Protect) = yes) { writeini $char($1) status Protect yes | %stolen.status.effects = $addtok(%stolen.status.effects, Protect, 46) }
        if ($readini($char($3), status, Shell) = yes) { writeini $char($1) status Shell yes | %stolen.status.effects = $addtok(%stolen.status.effects, Shell, 46) }
        if ($readini($char($3), status, En-Spell) != none) { writeini $char($1) status en-spell $readini($char($3), status, En-Spell) | %stolen.status.effects = $addtok(%stolen.status.effects, En-Spell, 46) }
        if ($readini($char($3), status, Revive) = yes) { writeini $char($1) status revive yes | %stolen.status.effects = $addtok(%stolen.status.effects, Auto-Revive, 46) }

        $clear_positive_status($3)
        writeini $char($3) status revive no

        if (%stolen.status.effects != $null) {
          set %replacechar $chr(044) $chr(032)
          %stolen.status.effects = $replace(%stolen.status.effects, $chr(046), %replacechar)
          $set_chr_name($1) | $display.message($readini(translation.dat, tech, StolenStatus), battle)
        }

        unset %stolen.status.effects
      }


    }

    if (%guard.message != $null) { $display.message(%guard.message, battle) | unset %guard.message }
  }
  if ($person_in_mech($3) = true) {  $set_chr_name($1) | $display.message($readini(translation.dat, errors, NotWorkOnMech), battle) }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  return
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a steal power tech
; This is the pre 3.0 version
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.stealPower.old {
  ; $1 = user
  ; $2 = tech name
  ; $3 = target

  set %attack.damage 0

  $calculate_damage_techs($1, $2, $3)

  ; If it's the blood moon, increase the amount by a random amount.
  if (%bloodmoon = on) { inc %attack.damage $rand(1,100) }

  if (%attack.damage <= 0) { set %attack.damage 5 }

  ; Does the target have a guardian that has to be defeated first?  If so, check to see if guardian is dead.  
  ; If it isn't, set the attack damage to 0.
  var %guardian.target $readini($char($3), info, guardian)

  if (%guardian.target != $null) { 
    var %guardian.status $readini($char(%guardian.target), battle, hp)
    if (%guardian.status > 0) { set %attack.damage 0 }   
  }

  var %winning.streak $readini(battlestats.dat, battle, winningstreak)
  if (%battle.type = ai) { var %winning.streak %ai.battle.level }
  if (%portal.bonus = true) { var %winning.streak 1500 }
  if ((%battle.rage.darkness = on) && ($readini($char($1), info, flag) = monster)) { inc %winning.streak 5000 }


  var %stealpower.multiplier $round($calc(%winning.streak / 30),1)
  var %max.stealpower $round($calc(%stealpower.multiplier * 100),0) 
  unset %winning.streak

  if (%attack.damage > %max.stealpower) { set %attack.damage %max.stealpower }
  unset %max.stealpower

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name

  $display.message(03 $+ %user $+  $readini($dbfile(techniques.db), $2, desc), battle)

  if ($person_in_mech($3) = false) {  

    if (%guard.message = $null) {

      var %attacker.str $readini($char($1), battle, str)
      var %attacker.def $readini($char($1), battle, def)
      var %attacker.int $readini($char($1), battle, int)
      var %attacker.spd $readini($char($1), battle, spd)

      if ($calc($readini($char($3), battle, str) - %attack.damage) <= 1) { var %amount.of.str $readini($char($3), battle, str) | inc %attacker.str $readini($char($3), battle, str) | writeini $char($3) battle str 1 }
      if ($calc($readini($char($3), battle, str) - %attack.damage) >= 1) { var %amount.of.str %attack.damage | inc %attacker.str %attack.damage | writeini $char($3) battle str $calc($readini($char($3), battle, str) - %amount.of.str) }

      inc %attack.damage $rand(0,2)
      if ($calc($readini($char($3), battle, def) - %attack.damage) <= 1) { var %amount.of.def $readini($char($3), battle, def) | inc %attacker.def $readini($char($3), battle, def) | writeini $char($3) battle def 1 }
      if ($calc($readini($char($3), battle, def) - %attack.damage) >= 1) { var %amount.of.def %attack.damage | inc %attacker.def %attack.damage | writeini $char($3) battle def $calc($readini($char($3), battle, def) - %amount.of.def) }

      inc %attack.damage $rand(0,3)
      if ($calc($readini($char($3), battle, int) - %attack.damage) <= 1) { var %amount.of.int $readini($char($3), battle, int) | inc %attacker.int $readini($char($3), battle, int) | writeini $char($3) battle int 1 }
      if ($calc($readini($char($3), battle, int) - %attack.damage) >= 1) { var %amount.of.int %attack.damage | inc %attacker.int %attack.damage | writeini $char($3) battle int $calc($readini($char($3), battle, int) - %amount.of.int) }

      inc %attack.damage $rand(0,1)
      if ($calc($readini($char($3), battle, spd) - %attack.damage) <= 1) { var %amount.of.spd $readini($char($3), battle, spd) | inc %attacker.spd $readini($char($3), battle, spd) | writeini $char($3) battle spd 1 }
      if ($calc($readini($char($3), battle, spd) - %attack.damage) >= 1) { var %amount.of.spd %attack.damage | inc %attacker.spd %attack.damage | writeini $char($3) battle spd $calc($readini($char($3), battle, spd) - %amount.of.spd) }

      writeini $char($1) battle str %attacker.str | writeini $char($1) battle def %attacker.def | writeini $char($1) battle int %attacker.int | writeini $char($1) battle spd %attacker.spd

      $set_chr_name($1) | $display.message($readini(translation.dat, tech, StolenPower), battle)

      ; Can the monster also steal status effects?
      if ($readini($dbfile(techniques.db), $2, StealStatus) = true) {
        unset %stolen.status.effects

        if ($readini($char($3), status, Regenerating) = yes) { writeini $char($1) status Regenerating yes | %stolen.status.effects = $addtok(%stolen.status.effects, Regen, 46) }
        if ($readini($char($3), status, TPRegenerating) = yes) { writeini $char($1) status TPRegenerating yes | %stolen.status.effects = $addtok(%stolen.status.effects, TP Regen, 46) }
        if ($readini($char($3), status, ConserveTP) = yes) { writeini $char($1) status ConserveTP yes | %stolen.status.effects = $addtok(%stolen.status.effects, Conserve TP, 46) }
        if ($readini($char($3), status, Protect) = yes) { writeini $char($1) status Protect yes | %stolen.status.effects = $addtok(%stolen.status.effects, Protect, 46) }
        if ($readini($char($3), status, Shell) = yes) { writeini $char($1) status Shell yes | %stolen.status.effects = $addtok(%stolen.status.effects, Shell, 46) }
        if ($readini($char($3), status, En-Spell) != none) { writeini $char($1) status en-spell $readini($char($3), status, En-Spell) | %stolen.status.effects = $addtok(%stolen.status.effects, En-Spell, 46) }
        if ($readini($char($3), status, Revive) = yes) { writeini $char($1) status revive yes | %stolen.status.effects = $addtok(%stolen.status.effects, Auto-Revive, 46) }

        $clear_positive_status($3)
        writeini $char($3) status revive no

        if (%stolen.status.effects != $null) {
          set %replacechar $chr(044) $chr(032)
          %stolen.status.effects = $replace(%stolen.status.effects, $chr(046), %replacechar)
          $set_chr_name($1) | $display.message($readini(translation.dat, tech, StolenStatus), battle)
        }

        unset %stolen.status.effects
      }


    }

    if (%guard.message != $null) { $display.message(%guard.message, battle) | unset %guard.message }
  }
  if ($person_in_mech($3) = true) {  $set_chr_name($1) | $display.message($readini(translation.dat, errors, NotWorkOnMech), battle) }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  return
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a suicide tech
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.suicide {
  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  $set_chr_name($1)
  $display.message($readini(translation.dat, tech, SuicideUseAllHP), battle)

  set %attack.damage 0

  ; Decrease the action points
  $action.points($1, remove, 5)

  $calculate_damage_techs($1, $2, $3)

  ; If it's the blood moon, increase the amount.
  if (%bloodmoon = on) { inc %attack.damage $rand(10,50) } 

  writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $increase.death.tally($1) | $set_chr_name($1) 
  $deal_damage($1, $3, $2, tech)

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  $display_damage($1, $3, tech, $2)
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs an insta-death tech
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.death {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  set %attack.damage 0

  ; Decrease the action points
  $action.points($1, remove, 4)

  ; Check for Utsusemi
  $utsusemi.check($1, $2, $3)

  ; Check for wonderguard
  $wonderguard.check($3, $2, tech)

  if (%guard.message != $null) { set %attack.damage 0 }
  else {
    var %death.chance $readini($dbfile(techniques.db), $2, DeathChance)
    if (%death.chance = $null) { var %death.chance 15 }

    var %death.roll $rand(1,100)

    ; later will add the ability for accessories to increase or decrease death chance

    if (%death.roll <= %death.chance) { set %attack.damage $readini($char($3), battle, HP) }
  }

  $deal_damage($1, $3, $2, %absorb, tech)
  $display_damage($1, $3, tech, $2, %absorb)
}

alias tech.deathaoe {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Decrease the action points
  $action.points($1, remove, 4)


  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  var %enemy all targets

  $display.message(03 $+ %user  $+ $readini($dbfile(techniques.db), $2, desc), battle)
  set %showed.tech.desc true

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { 

        if ((%mode.pvp = on) && ($1 = %who.battle)) { var %can.hit no }
        if (($readini($char($1), status, confuse) != yes) && ($1 = %who.battle)) { var %can.hit no }

        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { var %can.hit no }

        if (%can.hit != no) { 
          if ($readini($char($1), battle, hp) > 0) {
            inc %number.of.hits 1

            $covercheck(%who.battle, $2, AOE)

            ; Check for Utsusemi
            $utsusemi.check($1, $2, %who.battle)

            ; Check for wonderguard
            $wonderguard.check(%who.battle, $2, tech)

            if (%guard.message != $null) { set %attack.damage 0 }
            else {
              var %death.chance $readini($dbfile(techniques.db), $2, DeathChance)
              if (%death.chance = $null) { var %death.chance 15 }

              var %death.roll $rand(1,100)

              ; later will add the ability for accessories to increase or decrease death chance

              if (%death.roll <= %death.chance) { set %attack.damage $readini($char(%who.battle), battle, HP) }
            }

            $deal_damage($1, %who.battle, $2, %absorb, tech)


            $display_aoedamage($1, %who.battle, $2, %absorb)
            unset %attack.damage

          }
        }
        unset %can.hit
        inc %battletxt.current.line 1 
      }
    }
  }


  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 | set %aoe.turn 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { 
        inc %number.of.hits 1
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          if ($readini($char($1), battle, hp) > 0) {


            $covercheck(%who.battle, $2, AOE)

            ; Check for Utsusemi
            $utsusemi.check($1, $2, %who.battle)

            ; Check for wonderguard
            $wonderguard.check(%who.battle, $2, tech)


            if (%guard.message != $null) { set %attack.damage 0 }
            else {
              var %death.chance $readini($dbfile(techniques.db), $2, DeathChance)
              if (%death.chance = $null) { var %death.chance 15 }

              var %death.roll $rand(1,100)

              ; later will add the ability for accessories to increase or decrease death chance

              if (%death.roll <= %death.chance) { set %attack.damage $readini($char(%who.battle), battle, HP) }
            }

            $deal_damage($1, %who.battle, $2, %absorb, tech)
            $display_aoedamage($1, %who.battle, $2, %absorb)

          }

          inc %battletxt.current.line 1 | inc %aoe.turn 1 | unset %attack.damage
        } 
      }
    }
  }

  unset %element.desc | unset %showed.tech.desc | unset %aoe.turn
  set %timer.time $calc(%number.of.hits * 1.1) 

  if ($readini($dbfile(techniques.db), $2, magic) = yes) {
    ; Clear elemental seal
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      writeini $char($1) skills elementalseal.on off 
    }
  }

  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    set %inflict.user $1 | set %inflict.techwpn $2 
    $self.inflict_status(%inflict.user, %inflict.techwpn, tech)
    if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }

  if (%timer.time > 20) { %timer.time = 20 }

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a healing tech
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.heal {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; Decrease the action points
  $action.points($1, remove, 4)

  $calculate_damage_techs($1, $2, $3, heal)

  if (%battle.type = dungeon) { 
    if (%attack.damage >= 1500) { set %attack.damage $round($calc(1500 + (%attack.damage * .01)),0) }
  }

  if ($augment.check($1, CuringBonus) = true) {
    set %healing.increase $calc(%augment.strength * .30)
    inc %attack.damage $round($calc(%attack.damage * %healing.increase),0) 
    unset %healing.increase
  }

  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  var %mon.status $readini($char($3), status, zombie) | var %mon.type $readini($char($3), monster, type)
  var %target.element.heal $readini($char($3), modifiers, heal)
  var %tech.element $readini($dbfile(techniques.db), $2, element)

  if (($istok(%target.element.heal,%tech.element,46) = $false) || (%target.element.heal = $null)) { 
    if ((%mon.status = yes) || (%mon.type = undead)) {
      $deal_damage($1, $3, $2, tech)
      $display_damage($1, $3, tech, $2)
      return
    } 
  }

  if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
    var %max.heal.amount $readini($dbfile(techniques.db), $2, cappedamount)
    if (%max.heal.amount = $null) { var %max.heal.amount 2000 }

    if (%attack.damage > %max.heal.amount) {  set %attack.damage $round($calc(%max.heal.amount + (%attack.damage / 100)),0) }
  }

  %attack.damage = $round(%attack.damage,0)
  if ($3 = demon_portal) { set %attack.damage 0 }
  if ($person_in_mech($3) = true) { set %attack.damage 0 }

  ; If the target has max hp we don't need to heal them 
  if ($readini($char($3), battle, hp) >= $readini($char($3), basestats, hp)) { set %attack.damage 0 } 

  ; If the amount being healed is more than the target's max HP, set the max to the HP max
  if (%attack.damage > $readini($char($3), basestats, hp)) { set %attack.damage $readini($char($3), basestats, hp) }

  $heal_damage($1, $3, $2)
  $display_heal($1, $3, tech, $2)

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs an AOE Heal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.aoeheal {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  set %wait.your.turn on

  ; Decrease the action points
  $action.points($1, remove, 5)

  unset %who.battle | set %number.of.hits 0

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name
  $display.message(03 $+ %user $+  $readini($dbfile(techniques.db), $2, desc), battle)

  var %caster.flag $readini($char($1), info, flag)
  if ($readini($char($1), status, confuse) = yes) { var %caster.flag monster }

  if (%caster.flag = $null) { set %target.healing.flag player }
  if (%caster.flag = npc) { set %target.healing.flag player }
  if (%caster.flag = monster) { set %target.healing.flag monster }

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    set %who.battle.flag $readini($char(%who.battle), info, flag)

    if ((%target.healing.flag = player) && (%who.battle.flag = $null)) {  $do_aoe_heal($1, $2, $3) }
    if ((%target.healing.flag = player) && (%who.battle.flag = npc)) { $do_aoe_heal($1, $2, $3) }
    if ((%target.healing.flag = monster) && (%who.battle.flag = monster)) { $do_aoe_heal($1, $2, $3) }

    inc %battletxt.current.line 1 
  }


  unset %statusmessage.display | unset %target.healing.flag
  if ($readini($char($1), battle, hp) > 0) {
    set %inflict.user $1 | set %inflict.techwpn $2 
    $self.inflict_status(%inflict.user, %inflict.techwpn , tech)
    if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 5 /check_for_double_turn $1
  halt
}

alias do_aoe_heal {
  var %current.status $readini($char(%who.battle), battle, status)
  if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 | return }
  else { 
    inc %number.of.hits 1

    set %attack.damage 0
    $calculate_aoe_heal($1, $2, $3)

    if (%battle.type = dungeon) { 
      if (%attack.damage >= 1500) { set %attack.damage $round($calc(1500 + (%attack.damage * .01)),0) }
    }


    ;If the target is a zombie, do damage instead of healing it.
    var %mon.status $readini($char(%who.battle), status, zombie) | var %mon.type $readini($char(%who.battle), monster, type)
    if ((%mon.status = yes) || (%mon.type = undead)) {
      $deal_damage($1, %who.battle, $2, tech)
      $display_damage($1, %who.battle, aoeheal, $2)
      unset %guard.message
    } 

    else {   

      ; If the target has max hp we don't need to heal them 
      if ($readini($char(%who.battle), battle, hp) >= $readini($char(%who.battle), basestats, hp)) { set %attack.damage 0 } 

      ; If the amount being healed is more than the target's max HP, set the max to the HP max
      if (%attack.damage > $readini($char(%who.battle), basestats, hp)) { set %attack.damage $readini($char(%who.battle), basestats, hp) }

      $heal_damage($1, %who.battle, $2)
      $display_heal($1, %who.battle ,aoeheal, $2)
      unset %guard.message
    }
  }
}


alias calculate_aoe_heal {
  ; First things first, let's find out the base power.
  $calculate_damage_techs($1, $2, $3)
  inc %attack.damage %item.base

  if ($augment.check($1, CuringBonus) = true) { 
    set %healing.increase $calc(%augment.strength * .30)
    inc %attack.damage $round($calc(%attack.damage * %healing.increase),0) 
    unset %healing.increase
  }

  if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
    var %max.heal.amount $readini($dbfile(techniques.db), $2, cappedamount)
    if (%max.heal.amount = $null) { var %max.heal.amount 2000 }

    if (%attack.damage > %max.heal.amount) {  set %attack.damage $round($calc(%max.heal.amount + (%attack.damage / 100)),0) }
  }


  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }
  if ($3 = demon_portal) { set %attack.damage 0 }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; For magic type techs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.magic {

  ; Decrease the action points
  $action.points($1, remove, 4)

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  if (($readini($char($3), status, reflect) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) {
    $calculate_damage_magic($1, $2, $1)
    if (%attack.damage >= 4000) { set %attack.damage $rand(2800,3500) }
    unset %absorb
    $deal_damage($1, $1, $2, tech)
  }
  else { 
    $calculate_damage_magic($1, $2, $3)
    $deal_damage($1, $3, $2, tech)
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  $display_damage($1, $3, tech, $2)
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Activates a weapon boost
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.boost {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  ; Decrease the action points
  $action.points($1, remove, 4)

  if ($readini($char($1), status, boosted) != no) { 
    $set_chr_name($1) | $display.message($readini(translation.dat, errors, AlreadyBoosted), battle)
    if ($readini($char($1), info, flag) = monster) { $check_for_double_turn($1) | halt }
    else { halt }
  }

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; Get the battle stats
  var %str $readini($char($1), Battle, Str)
  var %def $readini($char($1), Battle, Def)
  var %int $readini($char($1), Battle, Int)
  var %spd $readini($char($1), Battle, Spd)

  var %boost.base.amount $readini($dbfile(techniques.db), $2, BasePower)
  var %player.level.amount $round($calc($readini($char($1), techniques, $2) * .7),0)

  inc %boost.base.amount %player.level.amount

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  set %current.weapon.used $readini($char($1), weapons, equipped)

  if ($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %boost.base.amount 0 }
  }
  unset %current.weapon.used

  inc %str %boost.base.amount
  inc %def %boost.base.amount
  inc %int %boost.base.amount
  inc %spd %boost.base.amount

  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  $set_chr_name($1) | set %user %real.name
  var %description $readini($char($1), descriptions, $2)
  if (%description = $null) { $display.message(10 $+ %real.name  $+ $readini($dbfile(techniques.db), $2, desc), battle) }
  else { $display.message(10 $+ %real.name  $+ %description, battle) }
  writeini $char($1) status boosted yes

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Activates a Final Getsuga
; type tech.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.finalgetsuga {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  ; Decrease the action points
  $action.points($1, remove, 4)

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  if ($readini($char($1), status, FinalGetsuga) != no) { 
    $set_chr_name($1) | $display.message($readini(translation.dat, errors, AlreadyUsedFinalGetsuga), battle)
    if ($readini($char($1), info, flag) = monster) { $check_for_double_turn($1) | halt }
    else { halt }
  }

  ; Get the battle stats
  var %str $readini($char($1), Battle, Str)
  var %def $readini($char($1), Battle, Def)
  var %int $readini($char($1), Battle, Int)
  var %spd $readini($char($1), Battle, Spd)

  var %boost.base.amount $readini($dbfile(techniques.db), $2, BasePower)
  var %player.level.amount $round($calc($readini($char($1), techniques, $2) * 10),0)

  inc %boost.base.amount %player.level.amount
  inc %boost.base.amount $rand(25,50)

  if ($readini($char($1), info, flag) = $null) {
    inc %str $round($calc(%str * %boost.base.amount),0)
    inc %def $round($calc(%def * %boost.base.amount),0)
    inc %int $round($calc(%int * %boost.base.amount),0)
    inc %spd $round($calc(%spd * %boost.base.amount),0)
  }
  if ($readini($char($1), info, flag) != $null) {
    set %boost.base.amount $round($calc(%boost.base.amount / 2),0)
    inc %str $round($calc(%str + %boost.base.amount),0)
    inc %def $round($calc(%def + %boost.base.amount),0)
    inc %int $round($calc(%int + %boost.base.amount),0)
    inc %spd $round($calc(%spd + %boost.base.amount),0)
  }

  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  $set_chr_name($1) | $display.message(10 $+ %real.name  $+ $readini($dbfile(techniques.db), $2, desc), battle)
  writeini $char($1) status FinalGetsuga yes

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }


  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs an AOE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.aoe {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Decrease the action points
  $action.points($1, remove, 6)

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off


  if ($5 = suicide) {
    $set_chr_name($1)
    $display.message($readini(translation.dat, tech, SuicideUseAllHP), battle)
  }


  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  var %enemy all targets

  $display.message(03 $+ %user  $+ $readini($dbfile(techniques.db), $2, desc), battle)
  set %showed.tech.desc true

  if ($readini($dbfile(techniques.db), $2, absorb) = yes) { set %absorb absorb }

  var %tech.element $readini($dbfile(techniques.db), $2, element)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { 

        if ((%mode.pvp = on) && ($1 = %who.battle)) { var %can.hit no }
        if (($readini($char($1), status, confuse) != yes) && ($1 = %who.battle)) { var %can.hit no }

        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { var %can.hit no }

        if (%can.hit != no) { 
          if ($readini($char($1), battle, hp) > 0) {
            inc %number.of.hits 1
            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%tech.element != none) && (%tech.element != $null)) {
              if ($istok(%target.element.heal,%tech.element,46) = $true) { 
                $tech.heal($1, $2, %who.battle, %absorb)
                inc %battletxt.current.line 1 
              }
            }

            if (($istok(%target.element.heal,%tech.element,46) = $false) || (%tech.element = none)) { 

              $covercheck(%who.battle, $2, AOE)

              if (($readini($char(%who.battle), status, reflect) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) {
                $calculate_damage_techs($1, $2, $1, aoe)
                if (%attack.damage >= 5000) { set %attack.damage $rand(4000,5000) }
                unset %absorb
                $deal_damage($1, $1, $2, %absorb, tech)
              }
              else {
                $calculate_damage_techs($1, $2, %who.battle, aoe)
                $deal_damage($1, %who.battle, $2, %absorb, tech)
              }

              $display_aoedamage($1, %who.battle, $2, %absorb)
              unset %attack.damage

            }
          }
        } 
        unset %can.hit
        inc %battletxt.current.line 1 
      }
    }
  }


  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 | set %aoe.turn 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { 
        inc %number.of.hits 1
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          if ($readini($char($1), battle, hp) > 0) {

            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%tech.element != none) && (%tech.element != $null)) {
              if ($istok(%target.element.heal,%tech.element,46) = $true) { 
                $tech.heal($1, $2, %who.battle, %absorb)
              }
            }

            if (($istok(%target.element.heal,%tech.element,46) = $false) || (%tech.element = none)) { 
              $covercheck(%who.battle, $2, AOE)

              ; Check for Reflect
              if (($readini($char(%who.battle), status, reflect) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) {
                $calculate_damage_techs($1, $2, $1, aoe)
                if (%attack.damage >= 5000) { set %attack.damage $rand(4000,5000) }
                unset %absorb
                $deal_damage($1, $1, $2, %absorb)
                $display_aoedamage($1, %who.battle, $2, %absorb, tech)
              }

              else {
                $calculate_damage_techs($1, $2, %who.battle, aoe)
                $deal_damage($1, %who.battle, $2, %absorb, tech)
                $display_aoedamage($1, %who.battle, $2, %absorb)
              }
            }
          }

          inc %battletxt.current.line 1 | inc %aoe.turn 1 | unset %attack.damage
        } 
      }
    }
  }

  unset %element.desc | unset %showed.tech.desc | unset %aoe.turn
  set %timer.time $calc(%number.of.hits * 1.1) 

  if ($readini($dbfile(techniques.db), $2, magic) = yes) {
    ; Clear elemental seal
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      writeini $char($1) skills elementalseal.on off 
    }
  }

  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    set %inflict.user $1 | set %inflict.techwpn $2 
    $self.inflict_status(%inflict.user, %inflict.techwpn, tech)
    if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }

  if ($5 = suicide) { writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $set_chr_name($1) | $increase.death.tally($1) | $spawn_after_death($1)  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  if (%timer.time > 20) { %timer.time = 20 }

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates Tech Damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias calculate_damage_techs {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal" or "aoe")

  if ($readini($char($1), info, flag) = monster) { $formula.techdmg.monster($1, $2, $3, $4) }
  else { 
    if (%battle.type = dungeon) { $formula.techdmg.player.formula($1, $2, $3, $4) }
    if (%battle.type = torment) { $formula.techdmg.player.formula_2.5($1, $2, $3, $4)  }
    if (%battle.type = cosmic) { $formula.techdmg.player.formula_2.5($1, $2, $3, $4)  }

    if (((%battle.type != dungeon) && (%battle.type != cosmic) && (%battle.type != torment))) { 
      $formula.techdmg.player.formula($1, $2, $3, $4) 
    }
  }

  unset %tech.howmany.hits |  unset %enemy.defense | set %multihit.message.on on
  unset %attacker.level | unset %defender.level | unset %tech.count | unset %tech.power | unset %base.weapon
  unset %capamount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if a tech
; needs to be increased due
; to using it a lot.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias tech.points {
  ; $1 = person
  ; $2 = tech

  var %tech.points $readini($char($1), techniques, $2 $+ .points)
  if (%tech.points = $null) { writeini $char($1) techniques $2 $+ .points 1 | return }
  if (%aoe.turn > 1) { return }

  else { inc %tech.points 1 

    if ($readini($char($1), skills, Tensai) >= 1) { inc %tech.points 4 }

    var %tech.points.needed 500
    if ($readini($char($1), stuff, NumberOfResets) >= 1) { var %tech.points.needed 250 }

    if (%tech.points >= %tech.points.needed) { writeini $char($1) techniques $2 $+ .points 0
      var %tech.attack.power $readini($char($1), techniques, $2)
      if (%tech.attack.power <= 999) { inc %tech.attack.power 1 |  writeini $char($1) techniques $2 %tech.attack.power
        $display.private.message2($1, $readini(translation.dat, system, TechIncrease)) 
        if (%tech.attack.power = 1000) { $achievement_check($1, MasteredTechnique) }
        return  
      }
    } 
    else { writeini $char($1) techniques $2 $+ .points %tech.points | return }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for the weather
; and compares to spell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias spell.weather.check { 

  if ($return.playerstyle($1) != spellmaster) { return }

  var %spell.element $readini($dbfile(techniques.db), $3, element)
  if (%spell.element = $null) { return }
  var %current.weather $readini($dbfile(battlefields.db), weather, current)
  if ((%current.weather = calm) || (%current.weather = $null)) { return }
  if ((%spell.element = fire) && (%current.weather = hot)) { $spell.weather.increase }
  if ((%spell.element = water) && (%current.weather = rainy)) { $spell.weather.increase }
  if (%spell.element = ice) && (%current.weather = snowy) { $spell.weather.increase }
  if (%spell.element = lightning) && (%current.weather = stormy) { $spell.weather.increase }
  if (%spell.element = light) && (%current.weather = bright) { $spell.weather.increase }
  if (%spell.element = earth) && (%current.weather = dry) { $spell.weather.increase }
  if (%spell.element = wind) && (%current.weather = windy) { $spell.weather.increase }
  if (%spell.element = dark) && (%current.weather = gloomy) { $spell.weather.increase }
  else { return }
}

alias spell.weather.increase {
  var %weather.increase = $readini($dbfile(battlefields.db), weather, boost)
  if ((%weather.increase = $null) || (%weather.increase < 0)) { %increase = .25 }
  var %new.attack.damage = $round($calc(%attack.damage * %weather.increase),0)
  inc %attack.damage %new.attack.damage
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if a spell effect
; triggers or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias magic.effect.check {
  ; $1 = user
  ; $2 = target
  ; $3 = tech name for techs, 'nothing' if for melee
  ; $4 = blank for techs, en-spell if used by melee

  if ($person_in_mech($2) = true) { return }
  if ($readini($char($2), skills, utsusemi.on) = on) { return }
  if (%guard.message != $null) { return }

  var %attacker.level $get.level($1)
  var %defender.level $get.level($2)
  var %level.difference $round($calc(%attacker.level - %defender.level),0)

  var %difference.threshold -50
  if (%portal.bonus = true) { var %difference.threshold -25 }

  if (%attacker.level <= %defender.level) {
    if (%level.difference <= %difference.threshold) { 
      if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) { return }
    }
  }

  var %guardian.target $readini($char($2), info, guardian)
  var %guardian.target.count $numtok(%guardian.target,46)
  var %current.guardian.count 1

  while (%current.guardian.count <= %guardian.target.count) { 
    var %current.guardian.target $gettok(%guardian.target, %current.guardian.count, 46)
    var %guardian.status $readini($char(%current.guardian.target), battle, hp)  
    if (%guardian.status > 0) { var %guardian.alive true | break }
    inc %current.guardian.count
  }

  if (%guardian.alive = true) { return }

  if ($4 = $null) {
    set %current.element $readini($dbfile(techniques.db), $3, element)
    if ((%current.element != $null) && (%tech.element != none)) {
      set %target.element.null $readini($char($2), modifiers, %current.element)

      if (%target.element.null <= 0) { unset %current.element | unset %target.element.null | return }

      var  %target.element.heal $readini($char($2), modifiers, heal)
      if (%target.element.heal = %current.element) {  unset %current.element | unset %current.element  | return }
    }

    unset %spell.element | unset %element.desc | unset %current.element
    set %spell.element $readini($dbfile(techniques.db), $3, element)

  }
  if ($4 = en-spell) { set %spell.element $readini($char($1), status, en-spell) }

  var %target.element.heal $readini($char($2), element, heal)
  if ($istok(%target.element.heal,%spell.element,46) = $true) { return }

  var %resist-element $readini($char($2), status, resist- $+ %spell.element)
  $set_chr_name($2)

  if (%spell.element = $null) { return } 

  if (%spell.element  = light) {
    if (%aoe.turn > 1) { return }
    if ($4 = $null) {
      var %total.spell $readini($char($1), stuff, LightSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff LightSpellsCasted %total.spell
      $achievement_check($1, BlindedByTheLight)
      return 
    }
  }
  if (%spell.element  = dark) { 
    if (%aoe.turn > 1) { return }
    if ($4 = $null) {
      var %total.spell $readini($char($1), stuff, DarkSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff DarkSpellsCasted %total.spell
      $achievement_check($1, It'sAllDoomAndGloom)
      return 
    }
  }
  if (%spell.element  = fire) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status burning yes | set %element.desc $readini(translation.dat, element, fire) }

    if ($4 = $null) {
      if (%aoe.turn > 1) { return }
      var %total.spell $readini($char($1), stuff, FireSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff FireSpellsCasted %total.spell
      $achievement_check($1, DiscoInferno)
    }
    return 
  }
  if (%spell.element  = wind) { 
    if ((%resist-element = no) || (%resist-element = $null)) {  writeini $char($2) Status tornado yes | set %element.desc $readini(translation.dat, element, wind) }
    if (%aoe.turn > 1) { return }
    if ($4 = $null) {
      var %total.spell $readini($char($1), stuff, WindSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff WindSpellsCasted %total.spell
      $achievement_check($1, RockYouLikeAHurricane)
      return 
    }

  }
  if (%spell.element  = water) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status drowning yes | set %element.desc $readini(translation.dat, element, water) }
    if ($4 = $null) { 
      if (%aoe.turn > 1) { return } 
      var %total.spell $readini($char($1), stuff, WaterSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff WaterSpellsCasted %total.spell
      $achievement_check($1, TimeToBuildAnArk)
    }
    return 
  }
  if (%spell.element  = ice) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status frozen yes | set %element.desc $readini(translation.dat, element, ice) }
    if ($4 = $null) {
      if (%aoe.turn > 1) { return }
      var %total.spell $readini($char($1), stuff, IceSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff IceSpellsCasted %total.spell
      $achievement_check($1, IceIceBaby)
    }
    return 
  }
  if (%spell.element  = lightning) { 
    if ((%resist-element = no) || (%resist-element = $null)) {  writeini $char($2) Status shock yes | set %element.desc $readini(translation.dat, element, lightning) }
    if ($4 = $null) {
      if (%aoe.turn > 1) { return }
      var %total.spell $readini($char($1), stuff, LightningSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff LightningSpellsCasted %total.spell
      $achievement_check($1, 1.21gigawatts)
    }
    return
  }
  if (%spell.element  = earth) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status earthquake yes | set %element.desc $readini(translation.dat, element, earth) }
    if ($4 = $null) {
      if (%aoe.turn > 1) { return }
      var %total.spell $readini($char($1), stuff, EarthSpellsCasted) 
      if (%total.spell = $null) { var %total.spell 0 }
      inc %total.spell 1 
      writeini $char($1) stuff EarthSpellsCasted %total.spell
      $achievement_check($1, InTuneWithMotherEarth)
    }
    return
  }
}

; ======================
; Ignition Aliases
; ======================
alias ignition_cmd {  $set_chr_name($1)
  ; $1 = user
  ; $2 = boost name

  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently), battle) | halt }
  if (%battle.type = dungeon) { $display.message($readini(translation.dat, errors, Can'tBoostInDungeon), private) | halt }
  $check_for_battle($1) 
  $amnesia.check($1, ignition) 

  if ((no-ignition isin %battleconditions) || (no-ignitions isin %battleconditions)) { $set_chr_name($1) | $display.message($readini(translation.dat, battle, NotAllowedBattleCondition), battle) | halt }
  if ((no-playerignition isin %battleconditions) && ($readini($char($1), info, flag) = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, battle, NotAllowedBattleCondition), battle) | halt }

  if ($readini($char($1), status, virus) = yes) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, Can'tBoostHasVirus), battle) | halt }
  if (($readini($char($1), status, boosted) = yes) || ($readini($char($1), status, ignition.on) = on)) {  $set_chr_name($1) | $display.message($readini(translation.dat, errors, AlreadyBoosted), battle) | halt }

  ; Does the user know that ignition?
  var %ignition.level $readini($char($1), ignitions, $2)
  if ((%ignition.level = $null) || (%ignition.level <= 0)) {  $set_chr_name($1) | $display.message($readini(translation.dat, Errors, DoNotKnowThatIgnition), battle) |  halt }

  ; Check to see if the user has enough Ignition Gauge to boost
  set %ignition.cost $readini($dbfile(ignitions.db), $2, IgnitionTrigger)
  set %player.current.ig $readini($char($1), battle, ignitionGauge)

  if (%player.current.ig < %ignition.cost) { $display.message($readini(translation.dat, Errors, NotEnoughIgnitionGaugeToBoost), battle) | unset %ignition.cost | unset %player.current.ig | halt }

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; Decrease the ignition gauge the initial cost. 
  dec %player.current.ig %ignition.cost
  writeini $char($1) Battle IgnitionGauge %player.current.ig

  ; Decrease the action point cost
  $action.points($1, remove, 5)

  ; Display the description
  $set_chr_name($1) | var %user %real.name

  if ($readini($char($1), descriptions, $2) = $null) { set %ignition.description $readini($dbfile(ignitions.db), $2, desc) }

  else { set %ignition.description $readini($char($1), descriptions, $2) }
  $set_chr_name($1) | $display.message(10 $+ %real.name  $+ %ignition.description, battle)

  ; get the ignition level
  var %ignition.level $readini($char($1), Ignitions, $2)

  ; get the ignition increase based on level
  var %ignition.increase 0
  if (%ignition.level > 1) { var %ignition.increase $calc(.10 * %ignition.level) }

  ; get the stat values
  var %hp.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, hp))
  var %str.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, str))
  var %def.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, def))
  var %int.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, int))
  var %spd.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, spd))

  ; Increase the stats
  var %hp $round($calc($readini($char($1), Battle, Hp) * %hp.increase),0)
  var %str $round($calc($readini($char($1), Battle, Str) * %str.increase),0)
  var %def $round($calc($readini($char($1), Battle, def) * %def.increase),0)
  var %int $round($calc($readini($char($1), Battle, int) * %int.increase),0)
  var %spd $round($calc($readini($char($1), Battle, spd) * %spd.increase),0)

  writeini $char($1) Battle Hp %hp
  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  ; Turn on the Augment and perform the trigger effect
  writeini $char($1) status ignition.on on
  writeini $char($1) status ignition.name $2
  var %ignition.augment $readini($dbfile(ignitions.db), $2, augment)
  if (%ignition.augment != $null) { writeini $char($1) status ignition.augment %ignition.augment }

  $ignition.triggereffect($1, $2)

  var %number.of.ignitions $readini($char($1), stuff, IgnitionsUsed)
  if (%number.of.ignitions = $null) { var %number.of.ignitions 0 }
  inc %number.of.ignitions 1
  writeini $char($1) stuff IgnitionsUsed %number.of.ignitions
  $achievement_check($1, PartyIsGettingCrazy)


  ; Check to see if there's any additional code that needs to run
  if ($readini($dbfile(ignitions.db), n, $2, AdditionalCode) != $null) { $readini($dbfile(ignitions.db), p, $2, AdditionalCode) }

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

alias ignition.triggereffect {
  ; $1 = user
  ; $2 = ignition

  if ($readini($dbfile(ignitions.db), $2, Effect) = none) { return }

  if ($readini($dbfile(ignitions.db), $2, Effect) = status) { 

    set %number.of.effects $numtok($readini($dbfile(ignitions.db), $2, StatusType),46)
    set %current.effect.number 1
    while (%current.effect.number <= %number.of.effects) {

      set %status.type.name $gettok($readini($dbfile(ignitions.db), $2, StatusType),%current.effect.number,46)

      var %status.target $readini($dbfile(ignitions.db), $2, StatusTarget)

      if (%status.target = self) {  writeini $char($1) status %status.type.name yes }

      if (%status.target = enemy) { 
        var %current.flag $readini($char($1), info, flag)
        var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
        while (%battletxt.current.line <= %battletxt.lines) { 
          var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)

          if ($person_in_mech(%who.battle) = false) {

            var %flag $readini($char(%who.battle), info, flag)

            if ((%current.flag = $null) && (%flag = monster)) {
              writeini $char(%who.battle) status %status.type.name yes
            }
            if ((%current.flag = npc) && (%flag = monster)) {
              writeini $char(%who.battle) status %status.type.name yes
            }

            if ((%current.flag = monster) && (%flag = $null)) {
              writeini $char(%who.battle) status %status.type.name yes
            }
            if ((%current.flag = monster) && (%flag = npc)) {
              writeini $char(%who.battle) status %status.type.name yes
            }
          }

          inc %battletxt.current.line 1
        }
      }

      if (%status.target = all) { 
        var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
        while (%battletxt.current.line <= %battletxt.lines) { 
          var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)

          if ($person_in_mech(%who.battle) = false) {  
          writeini $char(%who.battle) status %status.type.name yes }

          inc %battletxt.current.line 1
        }
      }

      if (%status.target = allies) { 
        var %current.flag $readini($char($1), info, flag)
        var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
        while (%battletxt.current.line <= %battletxt.lines) { 
          var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
          if ($person_in_mech(%who.battle) = false) {

            var %flag $readini($char(%who.battle), info, flag)

            if ((%current.flag = $null) && (%flag = $null)) {
              writeini $char(%who.battle) status %status.type.name yes
            }
            if ((%current.flag = monster) && (%flag = monster)) {
              writeini $char(%who.battle) status %status.type.name yes
            }
            if ((%current.flag = $null) && (%flag = npc)) {
              writeini $char(%who.battle) status %status.type.name yes
            }
          }

          inc %battletxt.current.line 1
        }
      }

      inc %current.effect.number 1
    }

  }

  unset %status.type.name
  unset %current.effect.number
  unset %number.of.effects

  return
}

alias revert {
  ; $1 = person
  ; $2 = ignition name

  ; get the ignition level
  var %ignition.level $readini($char($1), Ignitions, $2)

  ; get the ignition increase based on level
  var %ignition.increase 0
  if (%ignition.level > 1) { var %ignition.increase $calc(.10 * %ignition.level) }

  ; get the stat values
  var %hp.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, hp))
  var %str.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, str))
  var %def.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, def))
  var %int.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, int))
  var %spd.increase $calc(%ignition.increase + $readini($dbfile(ignitions.db), $2, spd))

  ; Decrease the stats
  var %hp $round($calc($readini($char($1), Battle, Hp) / %hp.increase),0)
  var %str $round($calc($readini($char($1), Battle, Str) / %str.increase),0)
  var %def $round($calc($readini($char($1), Battle, def) / %def.increase),0)
  var %int $round($calc($readini($char($1), Battle, int) / %int.increase),0)
  var %spd $round($calc($readini($char($1), Battle, spd) / %spd.increase),0)

  if (%hp <= 5) { var %hp 5 }
  if (%str <= 5) { var %str 5 }
  if (%def <= 5) { var %def 5 }
  if (%int <= 5) { var %int 5 }
  if (%spd <= 5) { var %spd 5 }

  writeini $char($1) Battle Hp $round(%hp,0)
  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  remini $char($1) status ignition.name
  remini $char($1) status ignition.augment
  writeini $char($1) status ignition.on off
}

; ======================
; Singing Aliases
; ======================
alias sing.song {
  ; $1 = performer
  ; $2 = song

  $check_for_battle($1) 
  $set_chr_name($1) 

  set %songs.list $songs.get.list($1, return)

  if ($istok(%songs.list, $2, 46) = $true) {  
    unset %songs.list

    ; Check for the instrument of the song.
    var %instrument.needed $readini($dbfile(songs.db), $2, instrument)
    if (($readini($char($1), item_amount, %instrument.needed) = $null) || ($readini($char($1), item_amount, %instrument.needed) <= 0)) { $display.message($readini(translation.dat, errors, Don'tHaveInstrument), private) | halt }


    if ((no-songs isin %battleconditions) || (no-singing isin %battleconditions)) { 
      $set_chr_name($1) | $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt 
    }

    ; Does the player have enough TP?
    var %tp.needed $readini($dbfile(songs.db), p, $2, TP) | var %tp.have $readini($char($1), battle, tp)

    if (($readini($dbfile(songs.db), $2, Effect) = Battlefield) || ($readini($dbfile(songs.db), $2, Effect) = ChangeBattlefield)) { 
      ; If it's a portal battle or crystal warrior battle, don't allow.
      if ((%boss.type = CrystalShadow) || (%portal.bonus = true)) { $set_chr_name($1) | $display.message($readini(translation.dat, battle, SongNotAllowedThisBattle), private) | halt }
      if (%battle.type = dungeon) { $set_chr_name($1) | $display.message($readini(translation.dat, battle, SongNotAllowedThisBattle), private) | halt }
    }

    ; Check for ConserveTP
    if (($readini($char($1), status, conservetp) = yes) || ($readini($char($1), status, conservetp.on) = on)) { var %tp.needed $round($calc(%tp.needed / 2),0) }

    if (%tp.needed = $null) { var %tp.needed %tp.have }
    if (%tp.needed > %tp.have) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, NotEnoughTPforTech),private) | halt }

    dec %tp.have %tp.needed
    writeini $char($1) battle tp %tp.have

    writeini $char($1) status conserveTP no

    ; Decrease the action point cost
    $action.points($1, remove, 5)

    ; Clear the BattleNext timer until this action is finished
    /.timerBattleNext off

    ; Perform the song.
    $display.message(03 $+ %real.name $+  $readini($dbfile(songs.db), $2, Desc), battle)

    if ($readini($dbfile(songs.db), $2, Effect) = status) { 
      set %number.of.effects $numtok($readini($dbfile(songs.db), $2, Type),46)
      set %current.effect.number 1
      while (%current.effect.number <= %number.of.effects) {

        set %status.type.name $gettok($readini($dbfile(songs.db), $2, Type),%current.effect.number,46)

        var %status.target $readini($dbfile(songs.db), $2, Target)

        if (%status.target = self) { writeini $char($1) status %status.type.name yes }

        if ((%status.target = enemy) || (%status.target = enemies)) { 
          var %current.flag $readini($char($1), info, flag)
          var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1

          while (%battletxt.current.line <= %battletxt.lines) { 
            var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)

            if ((%who.battle != $1) && ($readini($char(%who.battle), battle, status) != dead)) {
              if ($person_in_mech(%who.battle) = false) {

                var %flag $readini($char(%who.battle), info, flag)
                var %resist.name resist- $+ %status.type.name
                var %resist.skill $readini($char(%who.battle), skills, %resist.name)
                if (%resist.skill = $null) { var %resist.skill 0 }

                if (%battle.type = torment) { inc %resist.skill $rand(20,25) }

                if (%resist.skill < 100) {
                  if ((%current.flag = $null) && (%flag = monster)) {
                    writeini $char(%who.battle) status %status.type.name yes
                  }
                  if ((%current.flag = npc) && (%flag = monster)) {
                    writeini $char(%who.battle) status %status.type.name yes
                  }

                  if ((%current.flag = monster) && (%flag != monster)) {
                    writeini $char(%who.battle) status %status.type.name yes
                  }
                }

                if (%flag = monster) { writeini $char(%who.battle) skills %resist.name %resist.skill }

                if ($readini($char(%who.battle), skills, %resist.name) >= 100) { $set_chr_name(%who.battle)
                  if (%current.flag = monster) && (%flag != monster) { $display.message(04 $+ %real.name is not affected by $set_chr_name($1) %real.name $+ 's song,battle) } 
                  if (%current.flag = $null) && (%flag = monster) { $display.message(04 $+ %real.name is not affected by $set_chr_name($1) %real.name $+ 's song,battle) }
                  if (%current.flag = npc) && (%flag = monster) { $display.message(04 $+ %real.name is not affected by $set_chr_name($1) %real.name $+ 's song,battle) }
                }
              }
            }

            inc %battletxt.current.line 1
          }
        }

        if (%status.target = all) { 
          var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
          while (%battletxt.current.line <= %battletxt.lines) { 
            var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)

            if (($person_in_mech(%who.battle) = false) && ($readini($char(%who.battle), battle, status) != dead)) {  
            writeini $char(%who.battle) status %status.type.name yes }

            inc %battletxt.current.line 1
          }
        }

        if (%status.target = allies) { 
          var %current.flag $readini($char($1), info, flag)
          var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
          while (%battletxt.current.line <= %battletxt.lines) { 
            var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)

            if (($person_in_mech(%who.battle) = false) && ($readini($char(%who.battle), battle, status) != dead)) {  

              var %flag $readini($char(%who.battle), info, flag)

              if ((%current.flag = $null) || (%current.flag = npc)) {
                if ((%flag = npc) || (%flag = $null)) { writeini $char(%who.battle) status %status.type.name yes }
              }

              if ((%current.flag = monster) && (%flag = monster)) { writeini $char(%who.battle) status %status.type.name yes  }

            }

            inc %battletxt.current.line 1
          }
        }

        inc %current.effect.number 1
      }

    }
    if ($readini($dbfile(songs.db), $2, Effect) = Battlefield) { 
      ; Get type
      var %effect.type $readini($dbfile(songs.db), $2, Type)
      if (%effect.type = $null) { var %effect.type invalid-type }

      ; Add it to the type of battlefield enhancements/restrictions
      %battleconditions = $addtok(%battleconditions, %effect.type, 46)
    }

    if ($readini($dbfile(songs.db), $2, Effect) = ChangeBattlefield) { 
      ; Get type
      var %effect.type $readini($dbfile(songs.db), $2, Type)
      if (%effect.type = $null) { var %effect.type field }

      ; Change the battlefield.
      set %current.battlefield %effect.type
    }

    unset %status.type.name
    unset %current.effect.number
    unset %number.of.effects

    $check_for_double_turn($1) | halt 

  }
  if ($istok(%songs.list, $2, 46) = $false) { unset %songs.list | $display.message($readini(translation.dat, errors, Don'tKnowThatSong), private) | unset %songs.list | halt } 
} 

; ======================
; Limit Break Aliases
; ======================
alias limitbreak.attack {
  ; $1 = the user
  ; $2 = the limit break name
  ; $3 = the target

  ; Increase how many times this player has done a limit break
  var %number.of.limitbreaks.used $readini($char($1), stuff, LimitBreaksPerformed)
  if (%number.of.limitbreaks.used = $null) { var %number.of.limitbreaks.used 0 }
  inc %number.of.limitbreaks.used 1
  writeini $char($1) stuff LimitBreaksPerformed %number.of.limitbreaks.used

  ; Set the user's limit break meter back to 0
  writeini $char($1) Battle LimitBreakPercent 0  

  ; Get the base damage
  $weapon_equipped($1)
  $calculate_damage_weapon($1, %weapon.equipped, $3, limitbreak)

  ; Get the multiplier of the limit break
  var %multiplier $readini($dbfile(limitbreaks.db), $2, Multiplier)

  ; Increase the damage
  set %attack.damage $round($calc(%attack.damage * %multiplier),0)

  ; Deal the damage
  $deal_damage($1, $3, %weapon.equipped, limitbreak)

  ; Display damage
  $display_damage($1, $3, limitbreak, $2)

  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
  unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on | unset %critical.hit.chance

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}
