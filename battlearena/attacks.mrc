;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ATTACKS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 3:ACTION:attacks *:#:{ 
  $no.turn.check($nick)
  $set_chr_name($nick) | set %attack.target $2 | $covercheck($2)
  $attack_cmd($nick , %attack.target) 
} 
on 3:TEXT:!attack *:#:{ 
  $no.turn.check($nick)
  $set_chr_name($nick) | set %attack.target $2
  $attack_cmd($nick , %attack.target) 
} 

ON 50:TEXT:*attacks *:*:{ 
  if ($2 != attacks) { halt } 
  else { 
    $no.turn.check($1)
    if ($readini($char($1), Battle, HP) = $null) { halt }
    $set_chr_name($1) | set %attack.target $3 | $covercheck($3)
    $attack_cmd($1 , %attack.target) 
  }
}

ON 3:TEXT:*attacks *:*:{ 
  if ($2 != attacks) { halt } 
  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  $no.turn.check($1)
  unset %real.name 
  if ($readini($char($1), Battle, HP) = $null) { halt }
  $set_chr_name($1) | set %attack.target $3 | $covercheck($3)
  $attack_cmd($1 , %attack.target) 
}

alias attack_cmd { 
  set %debug.location alias attack_cmd
  $check_for_battle($1) | $person_in_battle($2) | $checkchar($2) | var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster } 
  if (%mode.pvp = on) { var %user.flag monster }

  var %ai.type $readini($char($1), info, ai_type)

  if ((%ai.type != berserker) && (%covering.someone != on)) {
    if (%mode.pvp != on) {
      if ($2 = $1) {
        if (($is_confused($1) = false) && ($is_charmed($1) = false))  { $display.system.message($readini(translation.dat, errors, Can'tAttackYourself), private) | unset %real.name | halt  }
      }
    }
  }

  if (%covering.someone = on) { var %user.flag monster }

  if ((%user.flag = $null) && (%target.flag != monster)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanOnlyAttackMonsters),private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious),private)  | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFled),private) | unset %real.name | halt } 

  ; Make sure the old attack damages have been cleared, and clear a few variables.
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %target.flag | unset %trickster.dodged | unset %covering.someone
  unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on | unset %critical.hit.chance | unset %drainsamba.on | unset %absorb | unset %counterattack
  unset %shield.block.line | unset %inflict.meleewpn

  ; Get the weapon equipped
  if ($person_in_mech($1) = false) {  $weapon_equipped($1) }
  if ($person_in_mech($1) = true) { set %weapon.equipped $readini($char($1), mech, equippedweapon) }


  ; If it's an AOE attack, perform that here.  Else, do a single hit.

  if ($readini($dbfile(weapons.db), %weapon.equipped, target) != aoe) {

    ; Calculate, deal, and display the damage..
    $calculate_damage_weapon($1, %weapon.equipped, $2)

    if ($person_in_mech($1) = true) { $mech.energydrain($1, melee) }

    set %wpn.element $readini($dbfile(weapons.db), %weapon.equipped, element)
    if ((%wpn.element != none) && (%wpn.element != $null)) { 
      var %target.element.heal $readini($char($2), modifiers, heal)
      if ($istok(%target.element.heal,%wpn.element,46) = $true) { 
        unset %wpn.element
        unset %counterattack
        $heal_damage($1, $2, %weapon.equipped)
        $display_heal($1, $2, weapon, %weapon.equipped)
        if (%battleis = on)  { $check_for_double_turn($1) | halt } 
      }
    }
    unset %wpn.element

    if ((%counterattack != on) && (%counterattack != shield)) { 
      $drain_samba_check($1)
      $deal_damage($1, $2, %weapon.equipped)
      $display_damage($1, $2, weapon, %weapon.equipped)
    }

    if (%counterattack = on) { 
      $deal_damage($2, $1, %weapon.equipped)
      $display_damage($1, $2, weapon, %weapon.equipped)
    }

    if (%counterattack = shield) { 
      $deal_damage($2, $1, $readini($char($2), weapons, equippedLeft))
      $display_damage($1, $2, weapon, $readini($char($2), weapons, equippedLeft))
    }


    unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
    unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
    unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
    unset %multihit.message.on | unset %critical.hit.chance

    $formless_strike_check($1)

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if ($readini($dbfile(weapons.db), %weapon.equipped, target) = aoe) {

    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $melee.aoe($1, %weapon.equipped, $2, player) | halt }
      if (%current.flag = monster) { $melee.aoe($1, %weapon.equipped, $2, monster) | halt }
    }
    else {
      ; check for confuse.
      if ($is_confused($1) = true) { 
        var %random.target.chance $rand(1,2)
        if (%random.target.chance = 1) { var %user.flag monster }
        if (%random.target.chance = 2) { unset %user.flag }
      }

      ; Determine if it's players or monsters
      if (%user.flag = monster) { $melee.aoe($1, %weapon.equipped, $2, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $melee.aoe($1, %weapon.equipped, $2,monster) | halt }
    }

  }

}

alias calculate_damage_weapon {
  set %debug.location alias calculate_damage_weapon
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 
  ; $4 = a special flag for mugger's belt.

  unset %absorb
  set %attack.damage 0
  var %random.attack.damage.increase $rand(1,10)

  var %base.weapon.power $readini($dbfile(weapons.db), $2, basepower)
  if (%base.weapon.power = $null) { var %base.weapon.power 1 }

  var %base.stat $readini($char($1), battle, str)
  $strength_down_check($1)

  var %attack.rating $round($calc(%base.stat / 2),0)

  if ($readini(system.dat, system, BattleDamageFormula) = 1) {
    if (%base.stat > 10) {  
      if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(%base.stat / 2.5),0) }
      if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(%base.stat / 5),0) }
    }
  }

  if ($readini(system.dat, system, BattleDamageFormula) = 2) {
    if (%base.stat > 999) {  
      if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(999 + %base.stat / 10),0) }
      if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(999 + %base.stat / 5),0) }
    }
  }

  if ($readini(system.dat, system, BattleDamageFormula) = 3) {
    if (%attack.rating >= 1000) {  
      var %base.stat.cap .10
      if ($get.level($1) > $get.level($3)) { inc %base.stat.cap .10 }
      if ($get.level($3) > $get.level($1)) { dec %base.stat.cap .02 }
      set %base.stat $round($calc(1000 + (%attack.rating * %base.stat.cap)),0) 
    }
  }


  set %true.base.stat %attack.rating

  var %weapon.base $readini($char($1), weapons, $2)
  ;  inc %weapon.base $round($calc(%weapon.base * 1.5),0)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if ($readini($dbfile(weapons.db), $2, type) = HandToHand) {  inc %weapon.base $readini($char($1), weapons, fists) }

  inc %weapon.base %base.weapon.power

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; Let's add the mastery bonus to the weapon base
  inc %weapon.base %mastery.bonus

  ; Let's add that to the base power and set it as the attack damage.
  inc %attack.damage %weapon.base
  inc %attack.damage %base.stat

  if ($person_in_mech($1) = false) { 
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, melee)
  }

  ;If the element is Light and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%weapon.element = light) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
    if (%weapon.element = fire) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
  } 

  ; Check to see if we have an accessory or augment that enhances the weapon type
  $melee.weapontype.enhancements($1)
  unset %weapon.type

  ; Check for Killer Traits
  $killer.trait.check($1, $3)

  if ($person_in_mech($1) = false) { 
    ; Check for the skill "MightyStrike"
    if ($mighty_strike_check($1) = true) { 
      ; Double the attack.
      %attack.damage = $calc(%attack.damage * 2)
    }

    ; Check for the "DesperateBlows" skill.
    if ($desperate_blows_check($1) = true) {
      var %hp.percent $calc(($readini($char($1), Battle, HP) / $readini($char($1), BaseStats, HP)) *100)
      if ((%hp.percent >= 10) && (%hp.percent <= 25)) { %attack.damage = $round($calc(%attack.damage * 1.5),0) }
      if ((%hp.percent > 2) && (%hp.percent < 10)) { %attack.damage = $round($calc(%attack.damage * 2),0) }
      if ((%hp.percent > 0) && (%hp.percent <= 2)) { %attack.damage = $round($calc(%attack.damage * 2.5),0) }
    }

  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage %random.attack.damage.increase
  unset %current.playerstyle | unset %current.playerstyle.level

  if ($person_in_mech($1) = false) { 
    ;  Check for the miser ring accessory

    if ($accessory.check($1, IncreaseMeleeDamage) = true) {
      var %redorb.amount $readini($char($1), stuff, redorbs)
      var %miser-ring.increase $round($calc(%redorb.amount * %accessory.amount),0)

      if (%miser-ring.increase <= 0) { var %miser-ring.increase 1 }
      if (%miser-ring.increase > 1000) { var %miser-ring.increase 1000 }
      inc %attack.damage %miser-ring.increase
      unset %accessory.amount
    }

    ;  Check for the fool's tablet accessory
    if ($accessory.check($1, IncreaseMeleeAddPoison) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }
  }

  if ($augment.check($1, MeleeBonus) = true) { 
    set %melee.bonus.augment $calc(%augment.strength * .25)
    var %augment.power.increase.amount $round($calc(%melee.bonus.augment * %attack.damage),0)
    inc %attack.damage %augment.power.increase.amount
    unset %melee.bonus.augment
  }

  unset %current.accessory.type

  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  $weapon_parry_check($3, $1, $2)
  $trickster_dodge_check($3, $1, physical)
  $royalguard.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)

  ; Check to see if the melee attack will hurt an ethereal monster
  $melee.ethereal.check($1, $2, $3)

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(weapons.db), $2, StatusType)

  if (%status.type.list != $null) { 
    set %number.of.statuseffects $numtok(%status.type.list, 46) 

    if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list) | unset %number.of.statuseffects | unset %status.type.list }
    if (%number.of.statuseffects > 1) {
      var %status.value 1
      while (%status.value <= %number.of.statuseffects) { 
        set %current.status.effect $gettok(%status.type.list, %status.value, 46)
        $inflict_status($1, $3, %current.status.effect)
        inc %status.value 1
      }  
      unset %number.of.statuseffects | unset %current.status.effect
    }
  }
  unset %status.type.list


  var %weapon.element $readini($dbfile(weapons.db), $2, element)
  if ((%weapon.element != $null) && (%weapon.element != none)) {
    $modifer_adjust($3, %weapon.element)
  }

  ; Check for weapon type weaknesses.
  set %weapon.type $readini($dbfile(weapons.db), $2, type)
  $modifer_adjust($3, %weapon.type)

  ; Elementals are strong to melee
  if ($readini($char($3), monster, type) = elemental) { %attack.damage = $round($calc(%attack.damage - (%attack.damage * .30)),0) } 

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(weapons.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  var %flag $readini($char($1), info, flag) 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 1) {

    ; Set the level ratio

    if (%flag = monster) { 
      set %temp.strength %base.stat
      if (%temp.strength > 800) { set %temp.strength $calc(700 + (%temp.strength / 40))
        set %temp.strength $round(%temp.strength,0)
        set %level.ratio $calc(%temp.strength / %enemy.defense)
      }
      if (%temp.strength <= 800) {  set %level.ratio $calc(%temp.strength / %enemy.defense) }
    }

    if ((%flag = $null) || (%flag = npc))  { 
      set %temp.strength %base.stat
      if (%temp.strength > 6000) { set %temp.strength $calc(6000 + (%temp.strength / 3))
        set %temp.strength $round(%temp.strength,0)
        set %level.ratio $calc(%temp.strength / %enemy.defense)
        unset %temp.strength
      }
      if (%temp.strength <= 6000) {  set %level.ratio $calc(%temp.strength / %enemy.defense) }
    }

    ; Calculate the Level Ratio
    set %level.ratio $calc($readini($char($1), battle, str) / %enemy.defense)

    var %attacker.level $get.level($1)
    var %defender.level $get.level($3)

    if (%attacker.level > %defender.level) { inc %level.ratio .3 }
    if (%attacker.level < %defender.level) { dec %level.ratio .3 }

    if (%level.ratio > 2) { set %level.ratio 2 }
    if (%level.ratio <= .02) { set %level.ratio .02 }

    unset %temp.strength

    ; And let's get the final attack damage..
    %attack.damage = $round($calc(%attack.damage * %level.ratio),0)
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 2) { 
    $calculate_pDIF($1, $3, melee)
    if (%flag != $null) { 
      if ($get.level($1) >= $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 3.5),0)  }
      if ($get.level($1) < $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 4.2),0)  }
    }
    if (%flag = $null) {
      if ($get.level($1) >= $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 2.8),0)  }
      if ($get.level($1) < $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 3.9),0)  }
    }

    %attack.damage = $round($calc(%attack.damage  * %pDIF),0)
    unset %pdif 
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 3
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if ($readini(system.dat, system, BattleDamageFormula) = 3) { 
    %attack.def.ratio = $calc(%base.stat / %enemy.defense)
    %attack.damage = $round($calc(%attack.damage * %attack.def.ratio),0)
    if ($mighty_strike_check($1) = true) { inc %attack.damage %attack.damage }
    unset %attack.def.ratio
  }


  $calculate_attack_leveldiff($1, $3)

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }


  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  $cap.damage($1, $3, melee)

  if ((%flag = $null) || (%flag = npc)) {
    if (%attack.damage <= 1) {
      var %base.weapon $readini($dbfile(weapons.db), $2, BasePower)
      var %str.increase.amount $round($calc(%true.base.stat * .10),0)
      inc %base.weapon %str.increase.amount
      var %min.damage %base.weapon
      set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)

      var %attacker.level $get.level($1)
      var %defender.level $get.level($3)
      var %level.difference $calc(%defender.level - %attacker.level)

      if (%level.difference >= 300) { 
        set %attack.damage 1
        if (%flag = $null) { set %min.damage $round($calc(%min.damage / 8),0) }
        else {  set %min.damage $round($calc(%min.damage / 2),0) }
      }
      set %attack.damage $rand(%min.damage, %attack.damage)
    }

    inc %attack.damage $rand(1,10)
  }

  if ((%flag = monster) && ($readini($char($3), info, flag) = $null)) {

    var %min.damage $readini($dbfile(weapons.db), $2, BasePower)
    inc %min.damage $round($calc(%attack.rating * .10),0)

    if (%attack.damage <= 1) { 
      set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)

      if ($calc($get.level($3) - $get.level($1))  <= -300) { 
        set %attack.damage 1
        set %min.damage $round($calc(%min.damage / 1.5),0)
      }
    }

    if (%battle.rage.darkness = on) { var %min.damage %attack.damage }

    if (%battle.rage.darkness != on) { 
      if ((%attack.damage >= 1) && ($get.level($1) <= $get.level($3))) {
        var %level.difference $calc($get.level($1) - $get.level($3)) 
        if (%level.difference <= 0) && (%level.difference >= -500) { var %min.damage $round($calc(%min.damage / 2),0) }
        if (%level.difference < -500) { var %min.damage $round($calc(%min.damage / 10),0) }
      }

      if ((%attack.damage >= 1) && ($get.level($1) <= $get.level($3))) {
        var %level.difference $calc($get.level($1) - $get.level($3)) 
        if (%level.difference >= 0) && (%level.difference <= 500) { inc %min.damage $round($calc(%min.damage * .20),0) }
        if (%level.difference > 500) { inc %min.damage $round($calc(%min.damage * .50),0) }
      }

    }

    set %attack.damage $rand(%attack.damage, %min.damage)
    if ($readini(battlestats.dat, battle, winningstreak) <= 0) { %attack.damage = $round($calc(%attack.damage / 2),0) }
  }

  unset %true.base.stat

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; Check for metal defense.  If found, set the damage to 1.
  $metal_defense_check($3, $1)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances...  
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)


  ; Check for a critical hit.
  var %critical.hit.chance $rand(1,100)

  ; check for the Impetus Passive Skill
  var %impetus.check $readini($char($1), skills, Impetus)
  if (%impetus.check != $null) { inc %critical.hit.chance %impetus.check }

  ; If the user is using a h2h weapon, increase the critical hit chance by 1.
  if ($readini($dbfile(weapons.db), $2, type) = HandToHand) { inc %critical.hit.chance 1 }

  if ($accessory.check($1, IncreaseCriticalHits) = true) {
    if (%accessory.amount = 0) { var %accessory.amount 1 }
    inc %critical.hit.chance %accessory.amount
    unset %accessory.amount
  }


  unset %player.accessory | unset %accessory.type | unset %accessory.amount

  if ($augment.check($1, EnhanceCriticalHits) = true) { inc %critical.hit.chance %augment.strength }

  if (%critical.hit.chance >= 97) {
    $set_chr_name($1) |  $display.system.message($readini(translation.dat, battle, LandsACriticalHit), battle)
    set %attack.damage $round($calc(%attack.damage * 1.5),0)
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if (($readini($dbfile(weapons.db), $2, cost) = 0) && ($readini($dbfile(weapons.db), $2, SpecialWeapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }

  if ($accessory.check($1, CurseAddDrain) = true) { unset %accessory.amount | set %absorb absorb }
  if ($augment.check($1, Drain) = true) {  set %absorb absorb }

  unset %current.accessory | unset %current.accessory.type 

  if ($person_in_mech($1) = false) { writeini $char($1) skills mightystrike.on off }

  ; Is the weapon a multi-hit weapon?  
  set %weapon.howmany.hits $readini($dbfile(weapons.db), $2, hits)

  if ($augment.check($1, AdditionalHit) = true) { inc %weapon.howmany.hits %augment.strength }

  ; Are we dual-wielding?  If so, increase the hits by the # of hits of the second weapon.
  if ($readini($char($1), weapons, equippedLeft) != $null) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2)

  ; Check for the weapon bash skill
  $weapon_bash_check($1, $3)

  var %current.element $readini($dbfile(weapons.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 
    }
    unset %target.element.null
  }

  var %weapon.type $readini($dbfile(weapons.db), $2, type)
  if (%weapon.type != $null) {
    set %target.weapon.null $readini($char($3), modifiers, %weapon.type)
    if (%target.weapon.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToWeaponType) 
      set %attack.damage 0 
    }
    unset %target.weapon.null
  }

  ; If the target has Protect on, it will cut  melee damage in half.
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; Check for the En-Spell Buff
  if ($readini($char($1), status, en-spell) != none) { 
    $magic.effect.check($1, $3, nothing, en-spell) 
    $modifer_adjust($3, $readini($char($1), status, en-spell))
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  $guardianmon.check($1, $2, $3)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CHECK FOR MULTI-HITS
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if (%attack.damage = 0) { return }

  if (%weapon.howmany.hits = $null) || (%weapon.howmany.hits <= 0) { set %weapon.howmany.hits 1
    if ((%counterattack != on) && ($readini($dbfile(weapons.db), %weapon.equipped, target) != aoe)) { $double.attack.check($1, $3, $rand(1,100)) }
  }
  if (%weapon.howmany.hits = 1) {  
    if ((%counterattack != on) && ($readini($dbfile(weapons.db), %weapon.equipped, target) != aoe)) { $double.attack.check($1, $3, $rand(1,100)) }
  }

  if (%weapon.howmany.hits = 2) {  $double.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 3) { $triple.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 4) { set %weapon.howmany.hits 4 | $fourhit.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 5) { set %weapon.howmany.hits 5 | $fivehit.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits >= 6) { set %weapon.howmany.hits 6 | $sixhit.attack.check($1, $3, 100) }
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a melee AOE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias melee.aoe {
  ; $1 = user
  ; $2 = weapon name
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Display the weapon type description
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  var %enemy all targets

  var %weapon.type $readini($dbfile(weapons.db), $2, type) |  var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt) 

  $display.system.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)
  set %showed.melee.desc true

  if ($readini($dbfile(weapons.db), $2, absorb) = yes) { set %absorb absorb }

  var %melee.element $readini($dbfile(weapons.db), $2, element)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { 

        if (($readini($char($1), status, confuse) != yes) && ($1 = %who.battle)) { inc %battletxt.current.line 1 }

        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 

          if ($readini($char($1), battle, hp) > 0) {
            inc %number.of.hits 1
            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%melee.element != none) && (%melee.element != $null)) {
              if ($istok(%target.element.heal,%melee.element,46) = $true) { 
                $heal_damage($1, %who.battle, %weapon.equipped)
                inc %battletxt.current.line 1 
              }
            }

            if (($istok(%target.element.heal,%melee.element,46) = $false) || (%melee.element = none)) { 

              $covercheck(%who.battle, $2, AOE)

              $calculate_damage_weapon($1, %weapon.equipped, %who.battle)
              $deal_damage($1, %who.battle, %weapon.equipped)

              $display_aoedamage($1, %who.battle, $2, %absorb, melee)
              unset %attack.damage

            }
          }


          unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
          unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
          unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
          unset %multihit.message.on | unset %critical.hit.chance

          inc %battletxt.current.line 1 | inc %aoe.turn 1
        } 
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
            if ((%melee.element != none) && (%melee.element != $null)) {
              if ($istok(%target.element.heal,%melee.element,46) = $true) { 
                $heal_damage($1, %who.battle, %weapon.equipped)
              }
            }

            if (($istok(%target.element.heal,%melee.element,46) = $false) || (%melee.element = none)) { 
              $covercheck(%who.battle, $2, AOE)


              $calculate_damage_weapon($1, %weapon.equipped, %who.battle)
              $deal_damage($1, %who.battle, %weapon.equipped)
              $display_aoedamage($1, %who.battle, $2, %absorb, melee)

            }
          }

          unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
          unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
          unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
          unset %multihit.message.on | unset %critical.hit.chance

          inc %battletxt.current.line 1 | inc %aoe.turn 1 | unset %attack.damage
        } 
      }
    }
  }

  unset %element.desc | unset %showed.melee.desc | unset %aoe.turn
  set %timer.time $calc(%number.of.hits * 1.1) 

  if ($readini($dbfile(weapons.db), $2, magic) = yes) {
    ; Clear elemental seal
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      writeini $char($1) skills elementalseal.on off 
    }
  }

  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    set %inflict.user $1 | set %inflict.meleewpn $2 
    $self.inflict_status(%inflict.user, %inflict.meleewpn, melee)
    if (%statusmessage.display != $null) { $display.system.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }


  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  if (%timer.time > 20) { %timer.time = 20 }

  unset %melee.element | $formless_strike_check($1)

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Skill and Mastery checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias mastery_check {
  var %type.of.weapon $readini($dbfile(weapons.db), $2, type)
  set %mastery.type nonexistant 
  if (%type.of.weapon = handtohand) { set %mastery.type MartialArts }
  if (%type.of.weapon = nunchuku) { set %mastery.type MartialArts }
  if (%type.of.weapon = katana) { set %mastery.type Swordmaster }
  if (%type.of.weapon = sword) { set %mastery.type Swordmaster }
  if (%type.of.weapon = greatsword) { set %mastery.type Swordmaster }
  if (%type.of.weapon = gun) { set %mastery.type Gunslinger }
  if (%type.of.weapon = rifle) { set %mastery.type Gunslinger }
  if (%type.of.weapon = wand) { set %mastery.type Wizardry }
  if (%type.of.weapon = stave) { set %mastery.type Wizardry }
  if (%type.of.weapon = glyph) { set %mastery.type Wizardry }
  if (%type.of.weapon = spear) { set %mastery.type Polemaster }
  if (%type.of.weapon = bow) { set %mastery.type Archery }
  if (%type.of.weapon = axe) { set %mastery.type Hatchetman }
  if (%type.of.weapon = scythe) { set %mastery.type Harvester }
  if (%type.of.weapon = dagger) { set %mastery.type SleightOfHand }
  if (%type.of.weapon = whip) { set %mastery.type Whipster }

  set %mastery.bonus $readini($char($1), skills, %mastery.type) 
  if (%mastery.bonus = $null) { set %mastery.bonus 0 }
  unset %mastery.type
}

alias mighty_strike_check {
  var %mightystrike $readini($char($1), skills, mightystrike.on)
  if (%mightystrike = on) { return true }
  else { return false }
}

alias desperate_blows_check {
  if ($readini($char($1), skills, desperateblows) != $null) { return true }
  else { return false }
}

alias weapon_bash_check {
  if (%counterattack = on) { return }
  if (%attack.damage = 0) { return }

  if ($readini($char($1), skills, WeaponBash) > 0) {

    set %resist.skill $readini($char($2), skills, resist-stun)
    $ribbon.accessory.check($2)
    if (%resist.skill >= 100) { return }
    unset %resist.skill

    if (%guard.message != $null) { return }
    if ($readini($char($2), skills, royalguard.on) = on) { return }
    if ($readini($char($2), skills, perfectdefense.on) = on) { return }
    if ($readini($char($2), skills, utsusemi.on) = on) { return }
    if (%trickster.dodged = on) { return }
    if ($readini($char($2), NaturalArmor, Current) > 0) { return }

    var %stun.chance $rand(1,100)
    var %weapon.bash.chance $calc($readini($char($1), skills, weaponbash) * 10)

    if ($augment.check($1, EnhanceWeaponBash) = true) { inc %weapon.bash.chance %augment.strength  } 

    if (%stun.chance <= %weapon.bash.chance) {
      writeini $char($2) status stun yes | $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name has been stunned by the blow!
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Drain Samba check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias drain_samba_check {
  unset %drainsamba.on
  if ($readini($char($1), skills, drainsamba.on) = on) {
    ; Check to see how many turns its been..  
    set %drainsamba.turns $readini($char($1), skills, drainsamba.turn)
    if (%drainsamba.turns = $null) { set %drainsamba.turns 0 }
    set %drainsamba.turn.max $readini($char($1), skills, drainsamba)
    inc %drainsamba.turns 1 
    if (%drainsamba.turns > %drainsamba.turn.max) { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, DrainSambaWornOff), battle) | writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on off | return }
    writeini $char($1) skills drainsamba.turn %drainsamba.turns   
    set %drainsamba.on on
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Formless Strike check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias formless_strike_check {
  if ($readini($char($1), skills, formlessstrike.on) = on) {
    ; Check to see how many turns its been..  
    set %fstrike.turns $readini($char($1), skills, formlessstrike.turn)
    if (%fstrike.turns = $null) { set %fstrike.turns 0 }
    set %fstrike.turn.max $readini($char($1), skills, formlessstrike)
    inc %fstrike.turns 1 

    if (%fstrike.turns > %fstrike.turn.max) { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, FormlessStrikeWornOff), battle) | writeini $char($1) skills formlessstrike.turn 0 | writeini $char($1) skills formlessstrike.on off | return }
    writeini $char($1) skills formlessstrike.turn %fstrike.turns   
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for augments and accessories
; that enhance weapon types.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias melee.weapontype.enhancements {

  ; Hand To Hand
  if (%weapon.type = HandToHand) {

    ;  Check for a +h2h damage accessory
    if ($accessory.check($1, IncreaseH2HDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceHandtoHand) = true) {  inc %attack.damage $round($calc(%attack.damage + (%augment.strength * 50)),0)  } 
  }


  ; Spears
  if (%weapon.type = spear) {

    ;  Check for a +spear damage accessory
    if ($accessory.check($1, IncreaseSpearDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceSpear) = true) {  inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  ; Swords

  if (%weapon.type = sword) {

    ; Check for a +sword damage accessory
    if ($accessory.check($1, IncreaseSwordDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceSword) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = greatsword) {

    ; Check for a +greatsword damage accessory
    if ($accessory.check($1, IncreaseGreatSwordDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceSword) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = whip) {

    if ($accessory.check($1, IncreaseWhipDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceWhip) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = gun) {
    if ($accessory.check($1, IncreaseGunDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = bow) {
    if ($accessory.check($1, IncreaseBowDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = glyph) {
    if ($accessory.check($1, IncreaseGlyphDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceGlyph) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Katana) {
    if ($accessory.check($1, IncreaseKatanaDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceKatana) = true) {  inc %attack.damage $calc(%augment.strength * 100)   } 
  }

  if (%weapon.type = Wand) {
    if ($accessory.check($1, IncreaseWandDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceWand) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }
  if (%weapon.type = Staff) {
    if ($accessory.check($1, IncreaseStaffDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceStaff) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Stave) {
    if ($accessory.check($1, IncreaseStaffDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceStaff) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Scythe) {
    if ($accessory.check($1, IncreaseScytheDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceScythe) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Axe) {
    if ($accessory.check($1, IncreaseAxeDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }
    ; Check for an augment
    if ($augment.check($1, EnhanceAxe) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Dagger) {
    if ($accessory.check($1, IncreaseDaggerDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }
    ; Check for an augment
    if ($augment.check($1, EnhanceDagger) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

}
