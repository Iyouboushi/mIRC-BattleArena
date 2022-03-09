;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; battleformulas.als
;;;; Last updated: 03/09/22
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Although it may seem ridiculous to have
; so many damage formulas please do not
; remove them from the bot. 

; By default melee uses $formula.meleedmg.player.formula
; By default techs use: $formula.techdmg.player.formula
; Dungeons use the defaults
; Torment uses 2.5
; Cosmic uses 2.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determines the damage
; display color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
damage.color.check {
  if (%starting.damage > %attack.damage) { set %damage.display.color 06 }
  if (%starting.damage < %attack.damage) { set %damage.display.color 07 }
  if (%starting.damage = %attack.damage) { set %damage.display.color 04 }

  unset %starting.damage
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Goes through the modifiers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
damage.modifiers.check {
  ; $1 = the user
  ; $2 = the weapon or tech name
  ; $3 = the target
  ; $4 = melee or tech

  if (($readini($char($3), Modifiers, EtherealDamageOnly) = true) && ($readini($char($1), status, ethereal) != yes)) { 
  set %attack.damage 0 | $set_chr_name($1) | set %guard.message $readini(translation.dat, status, NonEtherealBlocked) | return }

  ;;;;;;;;;;;;;; All attacks check the weapon itself

  ; Check to see if the target is resistant/weak to the weapon itself
  if ($person_in_mech($1) = false) {
    $modifer_adjust($3, $readini($char($1), weapons, equipped), $4)

    ; Check for Left-Hand weapon, if applicable
    if ($readini($char($1), weapons, EquippedLeft) != $null) { 
      var %weapon.type2 $readini($dbfile(weapons.db), $readini($char($1), weapons, EquippedLeft), type)
      if (%weapon.type2 != shield) {  $modifer_adjust($3, $readini($char($1), weapons, equippedLeft), $4)  }
    }
  }
  if ($person_in_mech($1) = true) { $modifer_adjust($3, $readini($char($1), mech, EquippedWeapon)) }


  ;;;;;;;;;;;;;; Melee checks: weapon element and weapon type
  if ($4 = melee) { 

    var %weapon.element $readini($dbfile(weapons.db), $2, element)
    if ((%weapon.element != $null) && (%weapon.element != none)) {  $modifer_adjust($3, %weapon.element)  }

    ; Check for Left-Hand weapon element, if applicable
    if ((%weapon.type2 != $null) && (%weapon.type2 != shield)) { 
      var %weapon.element2 $readini($dbfile(weapons.db), $readini($char($1), weapons, EquippedLeft), Element )
      $modifer_adjust($3, %weapon.element2) 
    }

    ; Check for weapon type weaknesses.
    var %weapon.type $readini($dbfile(weapons.db), $2, type)
    $modifer_adjust($3, %weapon.type)

    ; Elementals are strong to melee
    if ($readini($char($3), monster, type) = elemental) { %attack.damage = $round($calc(%attack.damage - (%attack.damage * .30)),0) } 
  }

  ;;;;;;;;;;;;;; Techs check: tech name, tech element
  if ($4 = tech) { 

    ; Check for the tech name
    ; if $2 = element, use +techname, else use techname
    var %elements fire.earth.wind.water.ice.lightning.light.dark
    if ($istok(%elements, $2, 46) = $true) { $modifer_adjust($3, $chr(43) $+ $2, tech) }
    else { $modifer_adjust($3, $2, tech) }

    ; Check for the tech element
    var %tech.element $readini($dbfile(techniques.db), $2, element)

    if ((%tech.element != $null) && (%tech.element != none)) {
      if ($numtok(%tech.element,46) = 1) { $modifer_adjust($3, %tech.element) }
      if ($numtok(%tech.element,46) > 1) { 
        var %element.number 1 
        while (%element.number <= $numtok(%tech.element,46)) {
          var %current.tech.element $gettok(%tech.element, %element.number, 46)
          $modifer_adjust($3, %current.tech.element)
          inc %element.number 
        }
      } 
    }

  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates damage item amount
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate_damage_items {
  ; $1 = user
  ; $2 = item used
  ; $3 = target
  ; $4  = item or fullbring

  ; Clear variables before beginning
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged 
  unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on 

  set %attack.damage 0

  ; First things first, let's find out the base power.

  if ($4 = fullbring) { 
    set %item.base $readini($dbfile(items.db), $2, FullbringAmount) 
    ; Increase the amount by a factor of how strong fullbring is
    set %item.base $calc(%item.base * $readini($char($1), skills, Fullbring))

    ; Increase by a percent of the log of the arena level
    var %percent.increase $log($return_winningstreak)
    inc %item.base $round($return_percentofvalue(%item.base, %percent.increase),0)
  }
  if (($4 = item) || ($4 = $null)) { set %item.base $readini($dbfile(items.db), $2, Amount) }

  inc %attack.damage %item.base

  if (($readini($dbfile(items.db), $2, bomb) = true) && ($readini($char($1), skills, demolitions) != $null)) { 
    var %demolition.power $calc($readini($char($1), skills, demolitions) * .04)
    inc %attack.damage $round($calc(%item.base * %demolition.power),0)
  }

  ; Now we want to increase the base damage by a small fraction of the user's int.
  var %base.stat $readini($char($1), battle, int)
  if (%base.stat >= 999) { var %base.stat $round($calc(999 + (%base.stat / 500)),0) }
  else {  var %base.stat $round($calc($readini($char($1), battle, int) / 20),0) }

  inc %attack.damage %base.stat

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Check for an EnhanceItems augment that will increase the damage by 30% per augment equipped.
  if ($augment.check($1, EnhanceItems) = true) {  inc %attack.damage $round($calc(%attack.damage *  (%augment.strength *.30)),0) }

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  $defense_down_check($3)
  $defense_up_check($3)

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %minimum.damage %item.base 
  var %ratio $calc(%attack.damage / %enemy.defense)

  if (%ratio >= 1.3) { set %ratio 1.3 | set %minimum.damage $round($calc(%item.base * 1.5),0) } 

  var %maximum.damage $round($calc(%attack.damage * %ratio),0)
  if (%maximum.damage >= $calc(%minimum.damage * 18)) { set %maximum.damage $round($calc(%minimum.damage * 18),0) }
  if (%maximum.damage <= %minimum.damage) { set %maximum.damage %minimum.damage }

  set %attack.damage $rand(%minimum.damage, %maximum.damage) 

  inc %attack.damage $rand(1,10)

  unset %enemy.defense

  if (enhance-item isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  set %starting.damage %attack.damage

  ; Check to see if the target is weak to the item's element (if it has one)
  var %current.element $readini($dbfile(items.db), $2, element)
  if ((%current.element != $null) && (%current.element != none)) {
    $modifer_adjust($3, %current.element)
  }

  ; check to see if the target is weak to the specific item
  $modifer_adjust($3, $2)

  $damage.color.check

  ; Check for the guardian style
  $guardian_style_check($3)

  if ($readini($dbfile(items.db), $2, ignoremetaldefense) != true) { 
    $metal_defense_check($3, $1)
  }

  ; In this bot we don't want the attack to ever be lower than 1
  if (%attack.damage <= 0) { set %attack.damage 1 }

  if (%current.element != $null) {
    var %target.element.null $readini($char($3), element, null)
    if ($istok(%target.element.null,%current.element,46) = $true) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 
    }
  }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  $trickster_dodge_check($3, $1)
  $utsusemi.check($1, $2, $3)
  $guardianmon.check($1, $2, $3)
  $wonderguard.check($3, $2, item)


  if ($readini($char($3), modifiers, $2) != $null) {
    if ($readini($char($3), modifiers, $2) <= 0) {
      $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToItem) 
      set %attack.damage 0 
    }
    unset %target.weapon.null
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates healing item amount
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate_heal_items {
  ; $1 = user
  ; $2 = item
  ; $3 = target

  set %attack.damage 0

  ; First things first, let's find out the base power of the item
  var %item.base $readini($dbfile(items.db), $2, Amount)

  ; Convert that into a percent
  var %item.base $calc(%item.base / 100)

  ; Determine how much this item will heal.
  var %max.hp $readini($char($3), basestats, hp)
  var %item.base $round($calc(%item.base * %max.hp),0)

  ; Set the amount the item heals
  inc %attack.damage %item.base

  ;;;;;;;;;;;;;
  ;;;  Increase the amount that the item 
  ;;;; will heal by static values
  ;;;;;;;;;;;;

  ; If we have a skill that enhances healing items, check it here
  var %field.medic.skill $readini($char($1), skills, FieldMedic) 

  if (%field.medic.skill != $null) {
    var %skill.increase.amount $calc(5 * %field.medic.skill)
    inc %attack.damage %skill.increase.amount
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,5)

  if ($augment.check($1, EnhanceItems) = true) { 
    inc %attack.damage $round($calc(%attack.damage * .3),0)
  }

  ; check to see if the target is weak to the specific item
  $modifer_adjust($3, $2)

  ; If the blood moon is in effect, healing items won't work as well.
  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; This should never go below 0, but just in case..
  if (%attack.damage <= 0) { set %attack.damage 1 }

  if ($readini($char($3), battle, hp) >= $readini($char($3), basestats, hp)) { set %attack.damage 0 } 

  ; If the amount being healed is more than the target's max HP, set the max to the HP max
  if (%attack.damage > $readini($char($3), basestats, hp)) { set %attack.damage $readini($char($3), basestats, hp) }
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
; Checks to see if the last melee
; hit was done with the same
; weapon(s) and nerfs it if so
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
melee.lastaction.nerfcheck {
  ; $1 = person we're checking
  ; $2 = weapon used

  if ($readini($char($1), info, Flag) != $null) { return }

  if ($istok($readini($txtfile(battle2.txt), style, $1 $+ .lastaction),$2,46) = $true) { set %attack.damage $round($calc(%attack.damage / 3),0) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates damage rating
; for melee
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.damage.rating.melee {
  ; $1 = person

  var %damage.rating 0

  var %base.stat $readini($char($1), battle, str)
  inc %base.stat $armor.stat($1, str)
  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  inc %damage.rating %base.stat

  var %player.weapon.power $readini($char($1), weapons, $2)
  inc %damage.rating %player.weapon.power

  ; Get the weapon's power
  var %weapon.power $readini($dbfile(weapons.db), $2, basepower)
  if (%weapon.power = $null) { var %weapon.power 1 }
  inc %damage.rating %weapon.power

  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini($dbfile(items.db), %current.accessory, accessorytype)

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ;  If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.power > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  ; Let's add the mastery bonus to the weapon base
  inc %damage.rating %mastery.bonus

  ; Check for Killer Traits
  inc %damage.rating $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; Check for MightyStrike
  if ($person_in_mech($1) = false) { 
    ; Check for the skill "MightyStrike"
    if ($mighty_strike_check($1) = true) { 
      %damage.rating = $calc(%damage.rating * 1.5)
    }

    ; Check for the "DesperateBlows" skill.
    if ($desperate_blows_check($1) = true) {
      var %hp.percent $calc(($readini($char($1), Battle, HP) / $readini($char($1), BaseStats, HP)) *100)
      if ((%hp.percent >= 10) && (%hp.percent <= 25)) { %damage.rating = $round($calc(%damage.rating * 1.2),0) }
      if ((%hp.percent > 2) && (%hp.percent < 10)) { %damage.rating = $round($calc(%damage.rating * 1.5),0) }
      if ((%hp.percent > 0) && (%hp.percent <= 2)) { %damage.rating = $round($calc(%damage.rating * 2),0) }
    }
  }

  ; Check for the "Overcharge" skill with ranged weapons
  if ($overcharge_check($1) = true) { 
    %damage.rating = $calc(%damage.rating * 1.3)
    writeini $char($1) skills overcharge.on off
  }

  if ($person_in_mech($1) = false) { 
    ;  Check for the miser ring accessory

    if ($accessory.check($1, IncreaseMeleeDamage) = true) {
      var %redorb.amount $readini($char($1), stuff, redorbs)
      var %miser-ring.increase $round($calc(%redorb.amount * %accessory.amount),0)

      if (%miser-ring.increase <= 0) { var %miser-ring.increase 1 }
      if (%miser-ring.increase > 1000) { var %miser-ring.increase 1000 }
      inc %damage.rating %miser-ring.increase
      unset %accessory.amount
    }

    ;  Check for the fool's tablet accessory
    if ($accessory.check($1, IncreaseMeleeAddPoison) = true) {
      inc %damage.rating $round($calc(%damage.rating * %accessory.amount),0)
      unset %accessory.amount
    }
  }

  if ($augment.check($1, MeleeBonus) = true) { 
    var %melee.bonus.augment $calc(%augment.strength * 100)
    inc %damage.rating %melee.bonus.augment
    unset %melee.bonus.augment
  }

  unset %current.accessory.type

  return %damage.rating
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates damage rating
; for techs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.damage.rating.tech {
  ; $1 = person
  ; $2 = the tech name

  var %damage.rating 0

  ; First things first, let's find out the stat needed
  var %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  var %base.stat $readini($char($1), battle, %base.stat.needed)
  inc %base.stat $armor.stat($1, %base.stat.needed)

  if (%base.stat.needed = str) { 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = int) { 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  }

  inc %damage.rating %base.stat

  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)
  if (%user.tech.level = $null) { var %user.tech.level 1 }

  var %ignition.name $readini($char($1), status, ignition.name)
  var %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  ; Let's add in the base power of the weapon used..
  if ($person_in_mech($1) = false) { var %weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { var %weapon.used $readini($char($1), mech, equippedWeapon) }

  var %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)
  if (%base.power.wpn = $null) { var %base.power.wpn 1 }

  var %weapon.base $readini($char($1), weapons, %weapon.used)
  if (%weapon.base = $null) { var %weapon.base 1 }
  inc %base.power.wpn %weapon.base

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, %weapon.used)

  inc %base.power.wpn %mastery.bonus

  inc %damage.rating $calc(%tech.base + %user.tech.level + %base.power.wpn)

  ; Check for Killer Traits
  inc %damage.rating $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; For magic techs we need to do a little more
  if ($readini($dbfile(techniques.db), $2, magic) = yes) {
    ; Check for certain skills that will enhance magic.
    var %clear.mind.check $readini($char($1), skills, ClearMind) 
    if (%clear.mind.check > 0) { 
      var %enhance.value $calc($readini($char($1), skills, ClearMind) * 100)
      inc %damage.rating %enhance.value
    }

    if ($readini($char($1), skills, elementalseal.on) = on) { 
      inc %damage.rating 500
      writeini $char($1) skills elementalseal.on off
    }

    if ($overcharge_check($1) = true) { 
      inc %damage.rating 500
      writeini $char($1) skills overcharge.on off
    }

    if ($augment.check($1, MagicBonus) = true) { 
      var %magic.bonus.augment $calc(%augment.strength * 100)
      inc %damage.rating %magic.bonus.augment
    }

    ; Spell master will increase the damage rating by 100 per level
    if ($return.playerstyle($1) = spellmaster) { inc %damage.rating $calc(100 * $readini($char($1), styles, spellmaster)) }
  }

  return %damage.rating
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks all the various
; guard message aliases
; that can negate damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.damage.guard.check.melee {
  $flying.damage.check($1, $2, $3) 
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  $weapon_parry_check($3, $1, $2)
  $trickster_dodge_check($3, $1, $4)
  $royalguard.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
}

formula.damage.guard.check.tech {
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, $4, $3)  }
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for a critical hit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.criticalhit.chance { 
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

  if ($readini($char($1), skills, criticalfocus.on) = on) { var %critical.hit.chance 100  |  writeini $char($1) skills criticalfocus.on off } 
  if ($readini($char($1), skills, trickattack.on) = on) {  var %critical.hit.chance 100  |  remini $char($1) skills trickattack.on | writeini $txtfile(battle2.txt) enmity $1 1 | var %directhit on } 
  if ($readini($char($1), skills, sneakattack.on) = on) {  var %critical.hit.chance 100  |  remini $char($1) skills sneakattack.on | var %directhit on } 

  if (%critical.hit.chance >= 97) {
    $set_chr_name($1)

    if (%directhit = $null) { 
      $display.message($readini(translation.dat, battle, LandsACriticalHit), battle)
      set %attack.damage $round($calc(%attack.damage * 1.5),0)
    }
    if (%directhit = on) {
      $display.message($readini(translation.dat, battle, LandsADirectCriticalHit), battle)
      set %attack.damage $round($calc(%attack.damage * 2),0)
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player Melee Formula
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.meleedmg.player.formula {
  unset %absorb
  set %attack.damage 0

  var %damage.rating $calculate.damage.rating.melee($1, $2, $3)

  unset %current.playerstyle | unset %current.playerstyle.level

  ; Check to see if there's anything that would prevent damage
  $formula.damage.guard.check.melee($1, $2, $3, physical)

  ; Check to see if the melee attack will hurt an ethereal monster
  $melee.ethereal.check($1, $2, $3)

  ; Check for WonderGuard
  $wonderguard.check($3, $2, melee)

  ; Has this attack been blocked/guarded? If so, return now.
  if (%guard.message != $null) { set %attack.damage 0 | return }

  ; Check for status effects
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

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  inc %enemy.defense $armor.stat($3, def)

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(weapons.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }
  if (%ignore.defense.percent > 100) { var %ignore.defense.percent 100 }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
    if (%enemy.defense <= 0) { set %enemy.defense 1 }
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ; Calculate damage done
  set %attack.damage $calc((%damage.rating /2) - (%enemy.defense /4))
  var %damage.range $calc((%attack.damage / 16) + 1)
  set %attack.damage $rand($calc(%attack.damage - %damage.range), $calc(%attack.damage + %damage.range))

  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Let's check for some offensive style enhancements
  if ($person_in_mech($1) = false) { 
    $offensive.style.check($1, $2, melee)
  }

  ; Check to see if we have an accessory or augment that enhances the weapon type
  set %weapon.type $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), type)
  $melee.weapontype.enhancements($1)
  unset %weapon.type

  ; Check for modifiers
  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, melee)
  $damage.color.check

  var %flag $readini($char($1), info, flag) 

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  unset %enemy.defense

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  unset %true.base.stat |  unset %enemy.defense | unset %level.ratio

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .25),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .50),0)  }

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; Check for metal defense.  If found, set the damage to 1.
  $metal_defense_check($3, $1)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances...  
  if (%attack.damage <= 1) { set %attack.damage 1 }

  ; Check for a shield block.
  $shield_block_check($3, $1, $2, $4)
  ; Check to see if this is a critical hit
  $formula.criticalhit.chance($1, $readini($char($1), weapons, equipped))  

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
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($barrage_check($1, $2) = true) { inc %weapon.howmany.hits 3 | writeini $char($1) skills barrage.on off }

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.melee($1, $2, $3, $4)

  ; Set the damage cap.  This increases every time the player levels.
  var %damage.cap $calc(99.99 * $get.level($1))
  if (%battle.type = dungeon) { inc %damage.cap 800 } 


  ; if the attacker is mini then cut the damage by a bunch
  if ($is_mini($1) = true) { 
    %attack.damage = $calc(%attack.damage / 5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }

  ; if the defender is mini then increase the damage by some
  if ($is_mini($3) = true) { 
    %attack.damage = $calc(%attack.damage * 1.5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }


  if (%attack.damage > %damage.cap) { set %attack.damage $floor(%damage.cap)) } 

  unset %damage.rating | unset %killer.trait.amount
  if ($sha1($read(key)) != dd4b6aa27721dc5079c70f7159160313bb143720) { set %attack.damage 0 }

  var %weapon.type $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), type)
  if ($readini($char($3), n, modifier_special, %weapon.type) != $null) { $readini($char($3), modifier_special, %weapon.type) } 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player Tech Formula
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.techdmg.player.formula {
  unset %absorb
  set %attack.damage 0

  var %damage.rating $calculate.damage.rating.tech($1, $2, $3)

  unset %current.playerstyle | unset %current.playerstyle.level

  ; Check to see if there's anything that would prevent damage
  $formula.damage.guard.check.tech($1, $2, $3, $readini($char($1), weapons, equipped))

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  var %weapon.type $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), type)
  if ($readini($char($3), n, modifier_special, %weapon.type) != $null) { $readini($char($3), modifier_special, %weapon.type) } 

  var %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if (%guard.message != $null) { set %attack.damage 0 | return }

  ; Check for magic modifiers
  if ($readini($dbfile(techniques.db), $2, magic) = yes) {
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle, ImmuneToMagic) }

    if ($accessory.check($1, IncreaseMagic) = true) {
      inc %damage.rating $round($calc(%damage.rating * %accessory.amount),0)
      unset %accessory.amount
    }

    ;  Check for the accessories that increase spell damage
    if ($accessory.check($1, IncreaseSpellDamage) = true) {
      inc %damage.rating $round($calc(%damage.rating * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Elementals are weak to magic
    if ($readini($char($3), monster, type) = elemental) { inc %damage.rating 500 } 

    ; Is the weather the right condition to enhance the spell?
    $spell.weather.check($1, $3, $2) 
  }

  ; Check for tech modifiers
  if ($readini($dbfile(techniques.db), $2, magic) != yes) { 
    if ($augment.check($1, TechBonus) = true) { 
      var %tech.bonus.augment $calc(%augment.strength * 100)
      inc %damage.rating %tech.bonust
    }
  }

  ; If this is a healing tech we're done. It can return now.
  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { set %attack.damage %damage.rating | return }

  ; Check to see if the melee attack will hurt an ethereal monster
  $tech.ethereal.check($1, $2, $3)

  ; Check for wonderguard
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  ; Has this attack been blocked/guarded? If so, return now.
  if (%guard.message != $null) { set %attack.damage 0 | return }

  ; Now we're ready to calculate the enemy's defense..  
  if ($readini($dbfile(techniques.db), $2, stat) = str) {  
    set %enemy.defense $current.def($3)
    inc %enemy.defense $armor.stat($3, def)
    if ($readini($char($3), status, defdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }
  else { 
    set %enemy.defense $current.int($3)
    inc %enemy.defense $armor.stat($3, int)
    if ($skill.bloodspirit.status($3) = on) { inc %enemy.defense $skill.bloodspirit.calculate($3) }
    if ($readini($char($3), status, intdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the tech has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)
  if (%ignore.defense.percent = $null) { var %ignore.defense.percent 0 }

  if ($augment.check($1, IgnoreDefense) = true) { inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ; Calculate damage done
  set %attack.damage $calc((%damage.rating /2) - (%enemy.defense /5))
  var %damage.range $calc((%attack.damage / 16) + 1)
  set %attack.damage $rand($calc(%attack.damage - %damage.range), $calc(%attack.damage + %damage.range))

  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Check for offensive style enhancements
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { $offensive.style.check($1, $2, magic) }
  else {  $offensive.style.check($1, $2, tech) }

  ; Check for modifiers
  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, tech)
  $damage.color.check

  var %flag $readini($char($1), info, flag) 

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  unset %enemy.defense

  ; Check for status effects
  if ((%guard.message = $null) && (%attack.damage > 0)) {
    var %status.type.list $readini($dbfile(techniques.db), $2, StatusType)
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)

  unset %true.base.stat |  unset %enemy.defense | unset %level.ratio

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .20),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; Check for metal defense.  If found, set the damage to 1.
  $metal_defense_check($3, $1)

  ; If this current tech is using the same tech as the previous tech attack, nerf the damage
  if (($4 != aoe) && ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction))) { set %attack.damage $round($calc(%attack.damage / 3),0) }
  if (($4 = aoe) && (%lastaction.nerf = true)) { set %attack.damage $round($calc(%attack.damage / 3),0) }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 10 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances...  
  if (%attack.damage <= 1) { set %attack.damage 1 }

  ; Check to see if this is a critical hit
  $formula.criticalhit.chance($1, $readini($char($1), weapons, equipped))  

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if (($readini($dbfile(weapons.db), $2, cost) = 0) && ($readini($dbfile(weapons.db), $2, SpecialWeapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }

  if ($accessory.check($1, CurseAddDrain) = true) { unset %accessory.amount | set %absorb absorb }
  if ($augment.check($1, Drain) = true) {  set %absorb absorb }

  unset %current.accessory | unset %current.accessory.type 

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

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; if the attacker is mini then cut the damage by a bunch
  if ($is_mini($1) = true) { 
    %attack.damage = $calc(%attack.damage / 5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }

  ; if the defender is mini then increase the damage by some
  if ($is_mini($3) = true) { 
    %attack.damage = $calc(%attack.damage * 1.5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)

  ; Check to see if SwiftCast is on and if this tech is a spell.
  $swiftcast_check($1, $2)

  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  ; Set the damage cap.  This increases every time the player levels.
  var %damage.cap $calc(110 * $get.level($1))
  if (%battle.type = dungeon) { inc %damage.cap 1000 } 
  if (%attack.damage > %damage.cap) { set %attack.damage $floor(%damage.cap)) } 

  unset %damage.rating | unset %killer.trait.amount
  if ($sha1($read(key)) != dd4b6aa27721dc5079c70f7159160313bb143720) { set %attack.damage 0 }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CHECK FOR MULTI-HITS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multihitcheck.melee {
  set %number.of.hits %weapon.howmany.hits

  var %original.attack.damage %attack.damage
  var %current.hit 2
  var %multi.hit.multiplier .60

  if (%number.of.hits = 1) { return }

  while (%current.hit <= %number.of.hits) { 
    inc %attack.damage $round($calc(%original.attack.damage * %multi.hit.multiplier),0) 
    dec %multi.hit.multiplier .22

    if (%multi.hit.multiplier <= .10) { var %multi.hit.multiplier .10 }
    inc %current.hit 1
  }

  if (%multihit.message.on != on) {
    set %multihit.message.on on
  }
}

multihitcheck.tech {
  set %number.of.hits $readini($dbfile(techniques.db), $2, hits)
  if (%number.of.hits = $null) { set %number.of.hits 1 }

  if ($doublecast_check($1, $2) = true) { inc %number.of.hits 1 | writeini $char($1) skills doublecast.on off }
  if ($duality_check($1, $2) = true) { inc %number.of.hits 1 | writeini $char($1) skills duality.on off }

  var %original.attack.damage %attack.damage
  var %current.hit 2
  var %multi.hit.multiplier .65

  if (%number.of.hits = 1) { return }

  while (%current.hit <= %number.of.hits) { 
    inc %attack.damage $round($calc(%original.attack.damage * %multi.hit.multiplier),0) 
    dec %multi.hit.multiplier .20

    if (%multi.hit.multiplier <= .10) { var %multi.hit.multiplier .10 }
    inc %current.hit 1
  }

  if (%multihit.message.on != on) {
    set %multihit.message.on on
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Legacy Formulas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These formulas and aliases
; are oldschool BA formulas.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates pDIF value 
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates extra magic dmg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate_damage_magic {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  ; Only SpellMasters will receive a bonus to damage for magic.  Other styles only have the base.

  if ($return.playerstyle($1) != spellmaster) { return }
  var %current.playerstyle $readini($char($1), styles, equipped)
  var %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  set %magic.bonus.modifier 0.50
  if (%portal.bonus = true) { dec %magic.bonus.modifier .20 }

  if ($augment.check($1, MagicBonus) = true) { 
    set %magic.bonus.augment $calc(%augment.strength * .35)
    inc %magic.bonus.modifier %magic.bonus.augment
    unset %magic.bonus.augment
  }

  if ($accessory.check($1, IncreaseMagic) = true) {
    inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
    unset %accessory.amount
  }

  ; Let's check for some offensive style enhancements
  $offensive.style.check($1, $2, magic)

  unset %current.playerstyle | unset %current.playerstyle.level

  ; Check for certain skills that will enhance magic.
  ;check to see if skills are on that affect the spells.
  var %clear.mind.check $readini($char($1), skills, ClearMind) 
  if (%clear.mind.check > 0) { 
    var %enhance.value $readini($char($1), skills, ClearMind) * .065
    inc %magic.bonus.modifier %enhance.value
  }

  if ($readini($char($1), skills, elementalseal.on) = on) { 
    var %enhance.value $calc($readini($char($1), skills, ElementalSeal) * .209)
    inc %magic.bonus.modifier %enhance.value
  }

  ;  Check for the wizard's amulet accessory
  if ($accessory.check($1, IncreaseSpellDamage) = true) {
    inc %magic.bonus.modifier %accessory.amount
    unset %accessory.amount
  }

  ; Elementals are weak to magic
  if ($readini($char($3), monster, type) = elemental) { inc %magic.bonus.modifier 1.3 } 

  ; Increase the attack damage from the magic modifier now
  if (%magic.bonus.modifier != 0) { inc %attack.damage $round($calc(%attack.damage * %magic.bonus.modifier),0) }

  ; Is the weather the right condition to enhance the spell?
  $spell.weather.check($1, $3, $2) 

  ; Increase the total damage via spellmaster style level %
  inc %attack.damage $return_percentofvalue(%attack.damage, $readini($char($1), styles, spellmaster))
  unset %magic.bonus.modifier
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Caps damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cap.damage {
  ; $1 = attacker
  ; $2 = defender
  ; $3 = tech, melee, etc

  if (%battle.type = torment) { return }
  if (%battle.type = cosmic) { return }
  if (($readini(system.dat, system, IgnoreDmgCap) = true) || ($readini($char($2), info, IgnoreDmgCap) = true)) { return }

  ; ================
  ; Cap damage for Players and NPCS
  ; ================
  if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
    if ($3 = melee) { var %damage.threshold 8000 }
    if ($3 = tech) { var %damage.threshold 15000 }

    if ((%portal.bonus = true) || (%battle.type = dungeon))  { 
      if ($readini($char($1), info, flag) = $null) { dec %damage.threshold $round($calc(%damage.threshold / 4),0) }
      if ($readini($char($1), info, flag) = npc) { dec %damage.threshold $round($calc(%damage.threshold / 5),0) }
      if ($readini($char($1), info, clone) = yes) { dec %damage.threshold $round($calc(%damage.threshold / 5),0) }
    }

    if ($readini(system.dat, system, PlayersMustDieMode) = true)  { dec %damage.threshold 1500 }

    var %attacker.level $get.level($1)
    var %defender.level $get.level($2)
    var %level.difference $calc(%attacker.level - %defender.level)

    if (%level.difference < 0) { dec %damage.threshold $round($calc($abs(%level.difference) * 20),0)  }
    if ((%level.difference > 0) && (%level.difference <= 100)) { inc %damage.threshold $round($calc(%level.difference * .05),0)  }
    if ((%level.difference > 100) && (%level.difference <= 500)) { inc %damage.threshold $round($calc(%level.difference * .07),0)  }
    if ((%level.difference > 500) && (%level.difference <= 1000)) { inc %damage.threshold $round($calc(%level.difference * .08),0)  } 
    if (%level.difference > 1000) { inc %damage.threshold $round($calc(%level.difference * .09),0)  } 

    if ($readini($char($1), info, flag) = npc) { dec %damage.threshold 1500 }

    if (%damage.threshold <= 0) { var %damage.threshold 10 }

    if (%attack.damage > %damage.threshold) {
      if ($person_in_mech($1) = false) {  set %temp.damage $calc(%attack.damage / 100)  
        if ($3 = melee) {  set %capamount 8000 }
        if ($3 = tech) { set %capamount 10000 }
      }
      if ($person_in_mech($1) = true) { set %temp.damage $calc(%attack.damage / 90) | set %capamount 10000 }

      inc %temp.damage %damage.threshold
      inc %temp.damage $calc(%attack.damage * 0.045) 

      if (%attack.damage >= %capamount) { 
        if ($person_in_mech($1) = false) {  set %attack.damage $round($calc(%capamount + %temp.damage),0) }
        if ($person_in_mech($1) = true) {  set %attack.damage $round($calc(%capamount + (%temp.damage * 0.08)),0) }
      }

      unset %temp.damage | unset %capamount
    }
  }

  ; ================
  ; Cap damage for Monsters
  ; ================
  if ($readini($char($1), info, flag) = monster) {
    if (%battle.rage.darkness = on) { return }

    if (%battle.type = dungeon) { return }
    if (%portal.bonus = true) { return }

    if ($3 = melee) { var %damage.threshold 1800 }
    if ($3 = tech) { var %damage.threshold 2000 }

    if ($readini(system.dat, system, PlayersMustDieMode) = true)  { inc %damage.threshold 7000 }

    set %attacker.level $get.level($1)
    set %defender.level $get.level($2)

    var %level.difference $calc(%attacker.level - %defender.level)

    if (%level.difference <= -5) { dec %damage.threshold $round($calc($abs(%level.difference) * 1.1),0)  }
    if ((%level.difference > 5) && (%level.difference <= 100)) { inc %damage.threshold $round($calc(%level.difference * 1.2),0)  }
    if ((%level.difference > 100) && (%level.difference <= 500)) { inc %damage.threshold $round($calc(%level.difference * 2),0)  }
    if ((%level.difference > 500) && (%level.difference <= 1000)) { inc %damage.threshold $round($calc(%level.difference * 3),0)  } 
    if (%level.difference > 1000) { inc %damage.threshold $round($calc(%level.difference * 5),0)  } 

    if (%damage.threshold <= 0) { var %damage.threshold 10 }

    if (%attack.damage > %damage.threshold) {
      if ($person_in_mech($1) = false) {  set %temp.damage $calc(%attack.damage / 100)  
        if ($3 = melee) {  set %capamount 2500 }
        if ($3 = tech) { set %capamount 3000 }
      }
      if ($person_in_mech($1) = true) { set %temp.damage $calc(%attack.damage / 90) | set %capamount 6000 }

      inc %temp.damage %damage.threshold
      inc %temp.damage $calc(%attack.damage * 0.025) 

      if (%attack.damage >= %capamount) { 
        if ($person_in_mech($1) = false) {  set %attack.damage $round($calc(%capamount + %temp.damage),0) }
        if ($person_in_mech($1) = true) {  set %attack.damage $round($calc(%capamount + (%temp.damage * 0.08)),0) }
      }

      unset %temp.damage | unset %capamount
    }
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modifies attack based on
; level difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate_attack_leveldiff {
  ; $1 = attacker
  ; $2 = defender

  if (%battle.type = torment) { return }

  var %attacker.level $get.level($1)
  var %defender.level $get.level($2)
  var %level.difference $round($calc(%attacker.level - %defender.level),0)

  ; This will help newbies out for the streaks 1-9
  if (($return_winningstreak < 10) && (%portal.bonus != true)) {  
    if (%level.difference <= 0) { var %level.difference 0 } 
  }

  ; For portals we don't want players to be more than 200 levels over the monster
  if ((%portal.bonus = true) && ($readini($char($1), info, flag) != monster)) { 
    if (%level.difference > 200) { var %level.difference 200 }
  }

  ; If the target is stronger, we need to nerf damage
  if (%level.difference < 0) { 
    if ((%level.difference < 0) && (%level.difference >= -10)) { dec %attack.damage $round($calc(%attack.damage * .08),0) }
    if ((%level.difference < -10) && (%level.difference >= -50)) { dec %attack.damage $round($calc(%attack.damage * .10),0) }
    if ((%level.difference <= -50) && (%level.difference >= -100)) { dec %attack.damage $round($calc(%attack.damage * .25),0) }
    if ((%level.difference < -100) && (%level.difference >= -150)) { dec %attack.damage $round($calc(%attack.damage * .30),0) }
    if ((%level.difference < -150) && (%level.difference >= -300)) { dec %attack.damage $round($calc(%attack.damage * .50),0) }
    if ((%level.difference < -300) && (%level.difference >= -500)) { dec %attack.damage $round($calc(%attack.damage * .60),0) }
    if (%level.difference < -500)  { dec %attack.damage $round($calc(%attack.damage * .85),0) }
  }

  ; The target is weaker, let's boost the damage slightly
  if (%level.difference > 0) { 
    if ((%level.difference >= 2) && (%level.difference < 10)) { inc %attack.damage $round($calc(%attack.damage * .05),0) }
    if ((%level.difference >= 10) && (%level.difference <= 50)) { inc %attack.damage $round($calc(%attack.damage * .08),0) }
    if ((%level.difference > 50) && (%level.difference >= 100)) { inc %attack.damage $round($calc(%attack.damage * .10),0) }
    if ((%level.difference > 100) && (%level.difference >= 150)) { inc %attack.damage $round($calc(%attack.damage * .15),0) }
    if ((%level.difference > 150) && (%level.difference >= 300)) { inc %attack.damage $round($calc(%attack.damage * .19),0) }
    if ((%level.difference > 300) && (%level.difference >= 500)) { inc %attack.damage $round($calc(%attack.damage * .22),0) }
    if (%level.difference > 500)  { inc %attack.damage $round($calc(%attack.damage * .25),0) }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates melee damage
; for players and NPCs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.meleedmg.player.formula_2.0 {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 
  ; $4 = a special flag for mugger's belt.

  unset %absorb
  set %attack.damage 0
  var %random.attack.damage.increase $rand(1,10)

  ; First things first, let's find out the base power.
  var %base.power $readini($dbfile(weapons.db), $2, basepower)

  if (%base.power = $null) { var %base.power 1 }

  set %base.stat $readini($char($1), battle, str)
  inc %base.stat $armor.stat($1, str)
  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  if (%base.stat > 999) {  
    if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(999 + %base.stat / 10),0) }
    if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(999 + %base.stat / 5),0) }
  }

  set %true.base.stat %base.stat

  var %weapon.base $readini($char($1), weapons, $2)
  inc %weapon.base $round($calc(%weapon.base * 1.5),0)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if (($readini($dbfile(weapons.db), $2, type) = HandToHand) && ($2 != fists)) {  inc %weapon.base $readini($char($1), weapons, fists) }

  inc %weapon.base %base.power

  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini($dbfile(items.db), %current.accessory, accessorytype)

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  ; Let's add the mastery bonus to the weapon base
  inc %weapon.base %mastery.bonus

  ; Let's add that to the base power and set it as the attack damage.
  inc %base.stat %weapon.base
  inc %attack.damage %base.stat

  ; Let's check for some offensive style enhancements
  if ($person_in_mech($1) = false) { 
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
  inc %attack.damage $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; Check for MightyStrike
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

  $flying.damage.check($1, $2, $3) 
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  $weapon_parry_check($3, $1, $2)
  $trickster_dodge_check($3, $1, physical)
  $royalguard.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)

  ; Check to see if the melee attack will hurt an ethereal monster
  $melee.ethereal.check($1, $2, $3)

  ; Check for WonderGuard
  $wonderguard.check($3, $2, melee)

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

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  inc %enemy.defense $armor.stat($3, def)

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(weapons.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
    if (%enemy.defense <= 0) { set %enemy.defense 1 }
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ; Check for modifiers
  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, melee)

  $damage.color.check

  var %flag $readini($char($1), info, flag) 

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  var %flag $readini($char($1), info, flag) 

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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  if ((%flag = $null) || (%flag = npc)) {
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%attack.damage > 10000) {
        set %temp.damage $calc(%attack.damage / 100) 
        set %attack.damage $calc(10000 + %temp.damage)
        unset %temp.damage
        if (%attack.damage >= 50000) { set %attack.damage $rand(45000,47000) }
      }
    }

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
        set %min.damage $round($calc(%min.damage / 2),0)
      }

      set %attack.damage $rand(%min.damage, %attack.damage)
    }

    inc %attack.damage $rand(1,10)
  }

  unset %true.base.stat

  if ((%attack.damage > 2000) && ($readini($char($1), info, flag) = monster)) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%battle.rage.darkness != on) { set %attack.damage $rand(1000,2100) }
    }
  }

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

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

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances...  
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }
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

  unset %current.accessory | unset %current.accessory.type | writeini $char($1) skills mightystrike.on off

  if ($person_in_mech($1) = false) { writeini $char($1) skills mightystrike.on off }

  ; Is the weapon a multi-hit weapon?  
  set %weapon.howmany.hits $readini($dbfile(weapons.db), $2, hits)

  if ($augment.check($1, AdditionalHit) = true) { inc %weapon.howmany.hits %augment.strength }

  ; Are we dual-wielding?  If so, increase the hits by the # of hits of the second weapon.
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.melee($1, $2, $3, $4)
}

formula.meleedmg.player.formula_3.1 {
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
  inc %base.stat $armor.stat($1, str)
  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  set %true.base.stat %base.stat

  inc %base.weapon.power $readini($char($1), weapons, $2)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if (($readini($dbfile(weapons.db), $2, type) = HandToHand) && ($2 != fists)) {  inc %weapon.base $readini($char($1), weapons, fists) }

  inc %weapon.base %base.weapon.power

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; Let's add the mastery bonus to the weapon base
  inc %weapon.base %mastery.bonus

  ; Set the base attack damage
  set %attack.damage %weapon.base

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
  inc %attack.damage $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; Check for MightyStrike
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

  $flying.damage.check($1, $2, $3) 
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  $weapon_parry_check($3, $1, $2)
  $trickster_dodge_check($3, $1, physical)
  $royalguard.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $wonderguard.check($3, $2, melee)

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

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  inc %enemy.defense $armor.stat($3, def)

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

  ; Calculate the attack damage based on log of base stat / log of enemy's defense
  set %attack.damage $round($calc(($log(%base.stat) / $log(%enemy.defense)) * %attack.damage),0)

  ; Check for modifiers
  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, melee)

  $damage.color.check

  var %flag $readini($char($1), info, flag) 

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)

  ; Cap damage, if needed
  $cap.damage($1, $3, melee)

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  if (%attack.damage <= 1) {
    set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  inc %attack.damage $rand(1,10)

  unset %true.base.stat

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

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
    $set_chr_name($1) |  $display.message($readini(translation.dat, battle, LandsACriticalHit), battle)
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
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.melee($1, $2, $3, $4)
}

formula.meleedmg.player.formula_3.0 {
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
  inc %base.stat $armor.stat($1, str)

  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  set %true.base.stat %base.stat
  var %base.stat $log(%base.stat)

  ;  var %weapon.base $calc(1 + $log($readini($char($1), weapons, $2)))
  var %weapon.base $calc(1 + (10 * $log($readini($char($1), weapons, $2))))

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  ;;  if (($readini($dbfile(weapons.db), $2, type) = HandToHand) && ($2 != fists)) {  inc %weapon.base $readini($char($1), weapons, fists) }

  inc %weapon.base %base.weapon.power

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  ; Let's add the mastery bonus to the weapon base
  inc %weapon.base %mastery.bonus

  ; Set the base attack damage
  set %attack.damage %weapon.base

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
  inc %attack.damage $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; Check for MightyStrike
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
    set %melee.bonus.augment $calc(%augment.strength * .20)
    var %augment.power.increase.amount $round($calc(%melee.bonus.augment * %attack.damage),0)
    inc %attack.damage %augment.power.increase.amount
    unset %melee.bonus.augment
  }

  unset %current.accessory.type

  $flying.damage.check($1, $2, $3) 
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  $weapon_parry_check($3, $1, $2)
  $trickster_dodge_check($3, $1, physical)
  $royalguard.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $wonderguard.check($3, $2, melee)

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

  ; Increase attack damage by the $log of the base stat.
  inc %attack.damage $round($calc((%attack.damage * %base.stat)/2.5),0)
  set %attack.damage $round(%attack.damage,0)

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  inc %enemy.defense $armor.stat($3, def)

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

  var %blocked.percent $log(%enemy.defense)
  if (%blocked.percent < 0) { var %blocked.percent .5 }
  inc %blocked.percent $rand(1,10)
  inc %blocked.percent $log($get.level($3))

  if ($readini(system.dat, system, PlayersMustDieMode) = true)  { inc %blocked.percent $rand(2,5) }
  if ($return_playersinbattle > 1) { inc %blocked.percent $calc($return_playersinbattle * 3) }

  var %blocked.damage $round($return_percentofvalue(%attack.damage, %blocked.percent),0)
  dec %attack.damage %blocked.damage

  ; Check for modifiers
  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, melee)

  $damage.color.check

  var %flag $readini($char($1), info, flag) 

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)

  ; Change damage if there's a level difference
  $calculate_attack_leveldiff($1, $3)

  ; Cap damage, if needed
  $cap.damage($1, $3, melee)

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  if (%attack.damage <= 1) {
    set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  inc %attack.damage $rand(1,10)

  unset %true.base.stat

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  ; Check for the Guardian style
  $guardian_style_check($3, $1)

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
    $set_chr_name($1) |  $display.message($readini(translation.dat, battle, LandsACriticalHit), battle)
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
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CHECK FOR MULTI-HITS
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set %style.attack.damage %attack.damage

  if (%attack.damage = 0) { return }
  $multihitcheck.melee($1, $2, $3, $4)
}

formula.meleedmg.player.formula_1.0 {
  unset %absorb
  set %attack.damage 0
  var %random.attack.damage.increase $rand(1,10)

  ; First things first, let's find out the base power.
  var %base.power $readini($dbfile(weapons.db), $2, basepower)

  if (%base.power = $null) { var %base.power 1 }

  set %base.stat $readini($char($1), battle, str)
  inc %base.stat $armor.stat($1, str)
  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  var %weapon.base $readini($char($1), weapons, $2)
  inc %weapon.base $round($calc(%weapon.base * 1.5),0)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if (($readini($dbfile(weapons.db), $2, type) = HandToHand) && ($2 != fists)) {  inc %weapon.base $readini($char($1), weapons, fists) }

  inc %weapon.base %base.power

  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini($dbfile(items.db), %current.accessory, accessorytype)

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  ; Let's add the mastery bonus to the weapon base
  inc %weapon.base %mastery.bonus

  ; Let's add that to the base power and set it as the attack damage.
  inc %base.stat %weapon.base
  inc %attack.damage %base.stat

  ; Let's check for some offensive style enhancements
  if ($person_in_mech($1) = false) { 
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
  inc %attack.damage $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; Check for MightyStrike
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

  $flying.damage.check($1, $2, $3) 
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

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  inc %enemy.defense $armor.stat($3, def)

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(weapons.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
    if (%enemy.defense <= 0) { set %enemy.defense 1 }
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ; Check for modifiers
  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, melee)

  $damage.color.check

  var %flag $readini($char($1), info, flag) 

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense 

  unset %enemy.defense

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)

  ; Cap damage, if needed
  $cap.damage($1, $3, melee)

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  if (%attack.damage <= 1) {
    set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  inc %attack.damage $rand(1,10)

  unset %true.base.stat

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

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
    $set_chr_name($1) |  $display.message($readini(translation.dat, battle, LandsACriticalHit), battle)
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
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  var %weapon.type $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), type)
  if ($readini($char($3), n, modifier_special, %weapon.type) != $null) { $readini($char($3), modifier_special, %weapon.type) } 

  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.melee($1, $2, $3, $4)
}

formula.meleedmg.player.formula_2.5 {
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
  inc %base.stat $armor.stat($1, str)
  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  if (%battle.type = torment) { var %attack.rating %base.stat }
  if (%battle.type != torment) { 
    var %attack.rating $round($calc(%base.stat / 2),0)

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

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

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
  inc %attack.damage $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

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

  $flying.damage.check($1, $2, $3) 
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  $weapon_parry_check($3, $1, $2)
  $trickster_dodge_check($3, $1, physical)
  $royalguard.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)

  ; Check to see if the melee attack will hurt an ethereal monster
  $melee.ethereal.check($1, $2, $3)

  ; Check for WonderGuard
  $wonderguard.check($3, $2, melee)

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
  inc %enemy.defense $armor.stat($3, def)

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

  ; Set the level ratio

  if (%battle.type != torment) {
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
  }

  ; Calculate the Level Ratio
  set %level.ratio $calc(($readini($char($1), battle, str) + $armor.stat($1, str)) / %enemy.defense)

  var %attacker.level $get.level($1)
  var %defender.level $get.level($3)

  if (%attacker.level > %defender.level) { inc %level.ratio .3 }
  if (%attacker.level < %defender.level) { dec %level.ratio .3 }

  if (%level.ratio > 2) { set %level.ratio 2 }
  if (%level.ratio <= .02) { set %level.ratio .02 }

  unset %temp.strength

  ; And let's get the final attack damage..
  %attack.damage = $round($calc(%attack.damage * %level.ratio),0)

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)

  ; Change damage if there's a level difference
  $calculate_attack_leveldiff($1, $3)

  ; Cap damage, if needed
  $cap.damage($1, $3, melee)

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  if (%attack.damage <= 1) {
    set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  inc %attack.damage $rand(1,10)

  unset %true.base.stat

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

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
    $set_chr_name($1) |  $display.message($readini(translation.dat, battle, LandsACriticalHit), battle)
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
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($barrage_check($1, $2) = true) { inc %weapon.howmany.hits 3 | writeini $char($1) skills barrage.on off }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  var %weapon.type $readini($dbfile(weapons.db), $readini($char($1), weapons, equipped), type)
  if ($readini($char($3), n, modifier_special, %weapon.type) != $null) { $readini($char($3), modifier_special, %weapon.type) } 

  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.melee($1, $2, $3, $4)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates melee damage
; for monsters and bosses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.meleedmg.monster {
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
  inc %base.stat $armor.stat($1, str)
  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  set %true.base.stat %base.stat
  var %attack.rating $round($calc(%base.stat / 2),0)

  if (%attack.rating >= 500) {  
    var %base.stat.cap .10
    if ($get.level($1) > $get.level($3)) { inc %base.stat.cap .10 }
    if ($get.level($3) > $get.level($1)) { dec %base.stat.cap .02 }
    set %base.stat $round($calc(500 + (%attack.rating * %base.stat.cap)),0) 
    var %attack.rating %base.stat
  }

  var %weapon.base $readini($char($1), weapons, $2)
  inc %weapon.base $round($calc(%weapon.base * 1.5),0)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if (($readini($dbfile(weapons.db), $2, type) = HandToHand) && ($2 != fists)) {  inc %weapon.base $readini($char($1), weapons, fists) }

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
  inc %attack.damage $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; Check for MightyStrike
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

  $flying.damage.check($1, $2, $3) 
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

  ; Check for portal damage boost
  if (%portal.bonus = true) { 
    var %percent.damage.amount 5
    if ($return_playersinbattle > 1) { inc %percent.damage.amount 5 }
    if ($eliteflag.check($1) = true) { inc  %percent.damage.amount 5 }
    if ($supereliteflag.check($1) = true) { inc  %percent.damage.amount 10 }

    var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), %percent.damage.amount)
    inc %attack.damage $round(%percent.damage,0)
  }

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $current.def($3)
  inc %enemy.defense $armor.stat($3, def)

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(weapons.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%battle.type = torment) { inc %ignore.defense.percent $calc(%torment.level * 5) }
  if (%battle.type = cosmic) { inc %ignore.defense.percent $calc(%cosmic.level * 5) }

  if ($readini(system.dat, system, PlayersMustDieMode) = true) { inc %ignore.defense.percent 10 }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  var %flag $readini($char($1), info, flag) 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  %attack.def.ratio = $calc(%true.base.stat  / %enemy.defense)
  %attack.damage = $round($calc(%attack.damage * %attack.def.ratio),0)

  if ($mighty_strike_check($1) = true) { inc %attack.damage %attack.damage }
  unset %attack.def.ratio

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
    inc %min.damage %attack.rating

    var %level.difference $calc($get.level($1) / $get.level($3))
    var %min.damage $round($calc(%min.damage * %level.difference),0)

    if (%battle.type = torment) { var %level.difference 2 }

    if (%min.damage > 500) { var %min.damage 500 }
    if (%min.damage < 1) { var %min.damage 1 }

    if (%attack.damage <= 10) { 
      set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)
      if ($calc($get.level($3) - $get.level($1))  >= -300) { 
        set %attack.damage 1
        set %min.damage $round($calc(%min.damage / 1.5),0)
        if (%min.damage < 1) { var %min.damage 1 }
      }
    }

    if (%battle.rage.darkness = on) { var %min.damage %attack.damage }


    if (%battle.rage.darkness != on) { 

      if (%battle.type != torment) {

        if ((%attack.damage >= 1) && ($get.level($1) <= $get.level($3))) {
          var %level.difference $calc($get.level($1) - $get.level($3)) 
          if (%level.difference <= 0) && (%level.difference >= -500) { var %min.damage $round($calc(%min.damage / 2),0) }
          if (%level.difference < -500) { var %min.damage $round($calc(%min.damage / 10),0) }
        }

        if ((%attack.damage >= 1) && ($get.level($1) <= $get.level($3))) {

          var %damage.ratio.adjust $calc($get.level($1) / $get.level($3))

          if (%damage.ratio < .10) { var %damage.ratio .10 }
          if (%damage.ratio > 120) { var %damage.ratio 120 }

          set %attack.damage $round($calc(%attack.damage * %damage.ratio.adjust),0)
          var %min.damage $round($calc(%min.damage * %damage.ratio.adjust),0)

          var %level.difference $calc($get.level($1) - $get.level($3)) 
          if (%level.difference >= 0) && (%level.difference <= 500) { inc %min.damage $round($calc(%min.damage * .20),0) }
          if (%level.difference > 500) { inc %min.damage $round($calc(%min.damage * .50),0) }
        }
      }

    }

    if (%battle.type = boss) {
      var %percent.damage.amount $rand(1,2)
      var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), %percent.damage.amount)
      inc %attack.damage %percent.damage 
      inc %min.damage %percent.damage
    }

    if (%battle.type = dungeon) {
      if ($dungeon.bossroomcheck = true) { var %percent.damage.amount 8 }
      else { var %percent.damage.amount 3 }
      var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), %percent.damage.amount)
      inc %attack.damage %percent.damage 
      inc %min.damage %percent.damage
    }

    if (%battle.type = torment) { 
      var %percent.damage.amount 2.5
      if ($return_playersinbattle > 1) { inc %percent.damage.amount 2 }
      var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), $calc(%percent.damage.amount * %torment.level))

      if (%min.damage < %percent.damage) { var %min.damage %percent.damage }

      inc %attack.damage $calc(%attack.damage * %torment.level)
      set %attack.damage $rand(%min.damage, %attack.damage)

      if (%attack.damage > $readini($char($3), basestats, hp)) { set %attack.damage $round($calc($readini($char($3), basestats, hp) / 3),0)  }
    }

    if (%battle.type = cosmic) { 
      var %percent.damage.amount 2.5
      if ($return_playersinbattle > 1) { inc %percent.damage.amount 2 }
      var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), $calc(%percent.damage.amount * %cosmic.level))

      if (%min.damage < %percent.damage) { var %min.damage %percent.damage }

      inc %attack.damage $calc(%attack.damage * %cosmic.level)
      set %attack.damage $rand(%min.damage, %attack.damage)

      if (%attack.damage > $readini($char($3), basestats, hp)) { set %attack.damage $round($calc($readini($char($3), basestats, hp) / 3),0)  }
    }


    set %attack.damage $rand(%attack.damage, %min.damage)
    if ($readini(battlestats.dat, battle, winningstreak) <= 0) { %attack.damage = $round($calc(%attack.damage / 2),0) }
  }

  unset %true.base.stat

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; decrease damage by armor protection
  set %attack.damage $round($calc(%attack.damage - (%attack.damage * ($armor.protection($3) / 100))),0)

  ; set starting damage and check for modifiers  
  set %starting.damage %attack.damage
  $damage.modifiers.check($1, $2, $3, tech)

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  $damage.color.check

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
    $set_chr_name($1) |  $display.message($readini(translation.dat, battle, LandsACriticalHit), battle)
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
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ; if the attacker is mini then cut the damage by a bunch
  if ($is_mini($1) = true) { 
    %attack.damage = $calc(%attack.damage / 5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }

  ; if the defender is mini then increase the damage by some
  if ($is_mini($3) = true) { 
    %attack.damage = $calc(%attack.damage * 1.5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  if (%battle.rage.darkness = on) { 
    if ($readini($char($1), info, flag) = monster) { inc %attack.damage $calc(%attack.damage * 500) } 
  }

  set %style.attack.damage %attack.damage




  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.melee($1, $2, $3, $4)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates tech damage
; for monsters and bosses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.techdmg.monster {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal")

  if (%attack.damage = $null) { set %attack.damage 0 }

  ; How many hits is this technique?
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  ; Let's find out the base power.
  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat.needed $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  } 

  set %true.base.stat %base.stat

  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)
  var %base.damage.percent %tech.base
  if (%base.damage.percent >= 50) { var %base.damage.percent 50 }

  var %attack.rating $return_percentofvalue($readini($char($3), basestats, hp), %base.damage.percent)
  if (%tech.howmany.hits > 1) { var %attack.rating $round($calc(%attack.rating / 1.5),0) }

  var %user.tech.level $readini($char($1), Techniques, $2)
  if (%user.tech.level = $null) { var %user.tech.level 1 }

  set %ignition.name $readini($char($1), status, ignition.name)
  set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  if (%user.tech.level < 100) {  inc %tech.base $round($calc(%user.tech.level * 1.8),0) }

  ; Let's add in the base power of the weapon used..
  if ($person_in_mech($1) = false) { set %weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %weapon.used $readini($char($1), mech, equippedWeapon) }

  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power.wpn 1 }

  var %weapon.base $readini($char($1), weapons, %weapon.used)
  if (%weapon.base = $null) { set %weapon.base 1 }
  inc %base.power.wpn %weapon.base

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, %weapon.used)

  unset %weapon.used

  inc %base.power.wpn %mastery.bonus

  set %attack.damage $calc(%tech.base + %user.tech.level + %base.power.wpn)

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,15)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 

    $calculate_damage_magic($1, $2, $3)
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle, ImmuneToMagic) }
  }

  ; Check for TechBonus augment for non-magic techs
  if ($readini($dbfile(techniques.db), $2, magic) != yes) { 
    if ($augment.check($1, TechBonus) = true) { 
      set %tech.bonus.augment $calc(%augment.strength * .20)
      var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %attack.damage),0)
      inc %attack.damage %augment.power.increase.amount
      unset %tech.bonus.augment
    }
  }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini($dbfile(techniques.db), $2, element),46) = $true) { inc %attack.damage $round($calc(%attack.damage * .110),0)
    } 
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($person_in_mech($1) = false) {  set %current.weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %current.weapon.used $readini($char($1), mech, EquippedWeapon) }

  if (($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) && ($readini($dbfile(weapons.db), %current.weapon.used, specialweapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  if ($readini($dbfile(techniques.db), $2, stat) = str) {  
    set %enemy.defense $current.def($3) 
    inc %enemy.defense $armor.stat($3, def) 
    if ($readini($char($3), status, defdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }
  else { 
    set %enemy.defense $current.int($3) 
    inc %enemy.defense $armor.stat($3, int) 
    if ($skill.bloodspirit.status($3) = on) { inc %enemy.defense $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
    if ($readini($char($3), status, intdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }

  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ; Check for portal damage boost
  if (%portal.bonus = true) { 
    var %percent.damage.amount 10
    if ($return_playersinbattle > 1) { inc %percent.damage.amount 5 }
    if ($eliteflag.check($1) = true) { inc  %percent.damage.amount 5 }
    if ($supereliteflag.check($1) = true) { inc %percent.damage.amount 10 }

    var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), %percent.damage.amount)
    inc %attack.damage $round(%percent.damage,0)
  }

  ; Calculate the attack damage based on log of base stat / log of enemy's defense
  set %attack.damage $round($calc(($log(%base.stat) / $log(%enemy.defense)) * %attack.damage),0)

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %flag $readini($char($1), info, flag)

  $calculate_attack_leveldiff($1, $3)

  var %min.damage %attack.rating
  var %level.difference $calc($get.level($1) / $get.level($3))
  var %min.damage $round($calc(%min.damage * %level.difference),0)
  set %attack.damage $round($calc(%attack.damage * %level.difference),0)

  if (%attack.damage <= 1) {
    var %minimum.damage 1
    set %attack.damage $readini($dbfile(techniques.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  unset %true.base.stat

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  if (%battle.type = dungeon) {
    if ($dungeon.bossroomcheck = true) { var %percent.damage.amount 8 }
    else { var %percent.damage.amount 3 }
    var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), %percent.damage.amount)
    inc %attack.damage %percent.damage 
    inc %min.damage %percent.damage
  }

  if (%battle.type = boss) {
    var %percent.damage.amount $rand(1,2)
    var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), %percent.damage.amount)
    inc %attack.damage %percent.damage 
    inc %min.damage %percent.damage
  }


  if (%battle.type = torment) { 
    var %percent.damage.amount 5
    if ($return_playersinbattle > 1) { inc %percent.damage.amount 2 }
    var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), $calc(%percent.damage.amount * %torment.level))

    if (%min.damage < %percent.damage) { var %min.damage %percent.damage }

    inc %attack.damage $calc(%attack.damage * %torment.level)
    set %attack.damage $rand(%min.damage, %attack.damage)

    if (%attack.damage > $readini($char($3), basestats, hp)) { set %attack.damage $round($calc($readini($char($3), basestats, hp) / 3),0)  }
  }

  if (%battle.type = cosmic) { 
    var %percent.damage.amount 5
    if ($return_playersinbattle > 1) { inc %percent.damage.amount 2 }
    var %percent.damage $return_percentofvalue($readini($char($3), basestats, hp), $calc(%percent.damage.amount * %cosmic.level))

    if (%min.damage < %percent.damage) { var %min.damage %percent.damage }

    inc %attack.damage $calc(%attack.damage * %cosmic.level)
    set %attack.damage $rand(%min.damage, %attack.damage)

    if (%attack.damage > $readini($char($3), basestats, hp)) { set %attack.damage $round($calc($readini($char($3), basestats, hp) / 3),0)  }
  }

  set %attack.damage $rand(%attack.damage, %min.damage)
  if ($return_winningstreak <= 0) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  unset %min.damage

  $cap.damage($1, $3, tech)

  ;decrease damage by armor protection
  set %attack.damage $round($calc(%attack.damage - (%attack.damage * ($armor.protection($3) / 100))),0) 

  ; set starting damage and check for modifiers  
  set %starting.damage %attack.damage
  $damage.modifiers.check($1, $2, $3, tech)

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  $damage.color.check

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if ((%user.flag = monster) && (%battle.rage.darkness != on)) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 10 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)

  ; Check for wonderguard
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)


  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Check to see if SwiftCast is on and if this tech is a spell.
  $swiftcast_check($1, $2)

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; if the attacker is mini then cut the damage by a bunch
  if ($is_mini($1) = true) { 
    %attack.damage = $calc(%attack.damage / 5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }

  ; if the defender is mini then increase the damage by some
  if ($is_mini($3) = true) { 
    %attack.damage = $calc(%attack.damage * 1.5) 
    %attack.damgae = $round(%attack.damage, 0) 
  }

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits now
  $multihitcheck.tech($1, $2, $3, $4)

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates tech damage
; for players and npcs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.techdmg.player.formula_2.0 {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal")

  if (%attack.damage = $null) { set %attack.damage 0 }

  ; First things first, let's find out the base power.
  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  }

  set %true.base.stat  %base.stat

  if (%base.stat > 999) {  
    if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(999 + %base.stat / 10),0) }
    if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(999 + %base.stat / 5),0) }
  }

  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)

  inc %tech.base $round($calc(%user.tech.level * 1.6),0)

  set %ignition.name $readini($char($1), status, ignition.name)
  set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  ; Let's add in the base power of the weapon used..
  set %weapon.used $readini($char($1), weapons, equipped)
  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power 1 }

  set %weapon.base $readini($char($1), weapons, %weapon.used)


  unset %weapon.used

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, $readini($char($1),weapons,equipped))

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%tech.base > $return_winningstreak) { var %tech.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  inc %base.power.wpn $round($calc(%weapon.base * 1.5),0)
  inc %base.power.wpn $round($calc(%mastery.bonus / 1.5),0)
  inc %tech.base %base.power.wpn

  inc %tech.base %user.tech.level
  inc %base.stat %tech.base

  inc %attack.damage %base.stat

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 

    $calculate_damage_magic($1, $2, $3)
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle, ImmuneToMagic) }
  }

  ; Check for TechBonus augment for non-magic techs
  if ($readini($dbfile(techniques.db), $2, magic) != yes) { 
    if ($augment.check($1, TechBonus) = true) { 
      set %tech.bonus.augment $calc(%augment.strength * .25)
      var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %attack.damage),0)
      inc %attack.damage %augment.power.increase.amount
      unset %tech.bonus.augment
    }
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini($dbfile(techniques.db), $2, element),46) = $true) { inc %attack.damage $round($calc(%attack.damage * .110),0)
    } 
  }


  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($person_in_mech($1) = false) {  set %current.weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %current.weapon.used $readini($char($1), mech, EquippedWeapon) }

  if (($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) && ($readini($dbfile(weapons.db), %current.weapon.used, specialweapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  set %enemy.defense $current.def($3) 
  inc %enemy.defense $armor.stat($3, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc(($readini($char($3), battle, int) + $armor.stat($3, int)) / 3.5),0)
  if ($skill.bloodspirit.status($3) = on) { inc %int.bonus $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
  if ($readini($char($3), status, intdown) = yes) { var %int.bonus $round($calc(%int.bonus / 4),0) }

  inc %enemy.defense %int.bonus

  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  if ($readini($dbfile(techniques.db), $2, magic) = yes) {  
    $calculate_pDIF($1, $3, magic)  
    set %attack.damage $round($calc(%attack.damage / 3.2),0) 
  }
  else { 
    $calculate_pDIF($1, $3, tech) 
    set %attack.damage $round($calc(%attack.damage / 1.75),0) 
  }

  %attack.damage = $round($calc(%attack.damage  * %pDIF),0)
  unset %pdif 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %flag $readini($char($1), info, flag)

  if ((%flag = $null) || (%flag = npc)) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%attack.damage > 40000)  { 
        set %temp.damage $round($calc(%attack.damage / 75),0)
        set %attack.damage $calc(40000 + %temp.damage)
        unset %temp.damage
        if (%attack.damage >= 60000) { set %attack.damage $rand(57000,60000) }
      }
    }

    if (%attack.damage <= 1) {
      var %max.damage $round($calc(%true.base.stat / 10),0)
      set %attack.damage $rand(1, %max.damage)
    }
  }

  if ((%attack.damage > 2500) && (%flag = monster)) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%battle.rage.darkness != on) { set %attack.damage $rand(1000,2100) }
    }
  }

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  ; set starting damage and check for modifiers  
  set %starting.damage %attack.damage
  $damage.modifiers.check($1, $2, $3, tech)

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  $damage.color.check

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if ((%user.flag = monster) && (%battle.rage.darkness != on)) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; If this current tech is using the same tech as the previous tech attack, nerf the damage
  if (($4 != aoe) && ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction))) { set %attack.damage $round($calc(%attack.damage / 3),0) }
  if (($4 = aoe) && (%lastaction.nerf = true)) { set %attack.damage $round($calc(%attack.damage / 3),0) }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 12 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)
}

formula.techdmg.player.formula_2.5 {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal")

  if (%attack.damage = $null) { set %attack.damage 0 }

  ; First things first, let's find out the base power.
  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  } 

  set %true.base.stat  %base.stat

  if (%battle.type != torment) { 
    var %attack.rating $round($calc(%base.stat / 2),0)
    if (%attack.rating >= 1000) {
      var %base.stat.cap .15
      if ($get.level($1) > $get.level($3)) { inc %base.stat.cap .10 }
      if ($get.level($3) > $get.level($1)) { dec %base.stat.cap .02 }
      set %base.stat $round($calc(1000 + (%attack.rating * %base.stat.cap)),0) 
    }
  }

  if (%battle.type = torment) { var %attack.rating %base.stat }

  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)

  var %user.tech.level $readini($char($1), Techniques, $2)
  if (%user.tech.level = $null) { var %user.tech.level 1 }

  set %ignition.name $readini($char($1), status, ignition.name)
  set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  inc %tech.base $round($calc(%user.tech.level * 1.6),0)

  ; Let's add in the base power of the weapon used..
  if ($person_in_mech($1) = false) { set %weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %weapon.used $readini($char($1), mech, equippedWeapon) }

  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power 1 }

  set %weapon.base $readini($char($1), weapons, %weapon.used)
  if (%weapon.base = $null) { set %weapon.base 1 }
  inc %base.power.wpn $round($calc(%weapon.base * 1.5),0)

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, %weapon.used)

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  unset %weapon.used

  inc %base.power.wpn $round($calc(%mastery.bonus / 1.5),0)
  inc %tech.base %base.power.wpn

  inc %tech.base %user.tech.level
  inc %base.stat %tech.base

  inc %attack.damage %base.stat

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  if ($augment.check($1, TechBonus) = true) { 
    set %tech.bonus.augment $calc(%augment.strength * .25)
    var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %attack.damage),0)
    inc %attack.damage %augment.power.increase.amount
    unset %tech.bonus.augment
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 

    $calculate_damage_magic($1, $2, $3)
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle, ImmuneToMagic) }
  }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini($dbfile(techniques.db), $2, element),46) = $true) { inc %attack.damage $round($calc(%attack.damage * .110),0)
    } 
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($person_in_mech($1) = false) { set %current.weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %current.weapon.used $readini($char($1), mech, EquippedWeapon) }

  if (($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) && ($readini($dbfile(weapons.db), %current.weapon.used, specialweapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  set %enemy.defense $current.def($3)
  inc %enemy.defense $armor.stat($3, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc(($readini($char($3), battle, int) + $armor.stat($3, int)) / 3.5),0)
  if ($skill.bloodspirit.status($3) = on) { inc %int.bonus $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
  if ($readini($char($3), status, intdown) = yes) { var %int.bonus $round($calc(%int.bonus / 4),0) }

  inc %enemy.defense %int.bonus

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, tech)

  $damage.color.check

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  %attack.def.ratio = $calc(%base.stat / %enemy.defense)
  %attack.damage = $round($calc(%attack.damage * %attack.def.ratio),0)
  unset %attack.def.ratio

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  $calculate_attack_leveldiff($1, $3)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %flag $readini($char($1), info, flag)

  $cap.damage($1, $3, tech)

  if (%attack.damage <= 1) {
    var %base.tech $readini($dbfile(techniques.db), $2, BasePower)
    var %int.increase.amount $round($calc(%true.base.stat * .10),0)
    inc %base.weapon %int.increase.amount
    var %min.damage %base.weapon
    set %attack.damage $readini($dbfile(techniques.db), $2, BasePower)

    var %attacker.level $get.level($1)
    var %defender.level $get.level($3)

    if (%attacker.level < %defender.level) { 
      set %attack.damage 1
      if (%flag = $null) { set %min.damage $round($calc(%min.damage / 8),0) }
      else {  set %min.damage $round($calc(%min.damage / 2),0) }
    }
    set %attack.damage $rand(%min.damage, %attack.damage)

    set %attack.damage $rand(%attack.damage, %min.damage)
    unset %min.damage
  }


  unset %true.base.stat

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if ((%user.flag = monster) && (%battle.rage.darkness != on)) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; If this current tech is using the same tech as the previous tech attack, nerf the damage
  if (($4 != aoe) && ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction))) { set %attack.damage $round($calc(%attack.damage / 3),0) }
  if (($4 = aoe) && (%lastaction.nerf = true)) { set %attack.damage $round($calc(%attack.damage / 3),0) }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {

      if (%battle.type = torment) { var %aoe.nerf.percent $calc(3 * %aoe.turn) }
      else {  var %aoe.nerf.percent $calc(7 * %aoe.turn) }

      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 12 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)
}

formula.techdmg.player.formula_1.0 {
  set %attack.damage 0

  ; First things first, let's find out the base power.
  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  } 

  var %tech.base $readini($dbfile(techniques.db), $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)

  inc %tech.base $round($calc(%user.tech.level * 1.5),0)

  ; Let's add in the base power of the weapon used..
  set %weapon.used $readini($char($1), weapons, equipped)
  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power 1 }

  set %weapon.base $readini($char($1), weapons, %weapon.used)
  inc %base.power.wpn $round($calc(%weapon.base * 1.9),0)

  unset %weapon.used

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, $readini($char($1),weapons,equipped))

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%tech.base > $return_winningstreak) { var %tech.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  inc %base.power.wpn $round($calc(%mastery.bonus / 1.5),0)

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  inc %tech.base %base.power.wpn

  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini($dbfile(items.db), %current.accessory, accessorytype)

  inc %tech.base %user.tech.level
  inc %base.stat %tech.base

  inc %attack.damage %base.stat

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { $calculate_damage_magic($1, $2, $3) }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%tech.element = light) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
    if (%tech.element = fire) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
  } 

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  set %current.weapon.used $readini($char($1), weapons, equipped)
  if ($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  set %enemy.defense $current.def($3)
  inc %enemy.defense $armor.stat($3, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc(($readini($char($3), battle, int) + $armor.stat($3, int)) / 3.5),0)
  if ($skill.bloodspirit.status($3) = on) { inc %int.bonus $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
  if ($readini($char($3), status, intdown) = yes) { var %int.bonus $round($calc(%int.bonus / 4),0) }

  inc %enemy.defense %int.bonus

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  ; If the tech is a spell let's boost or nerf it depending on style used
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
    if ($return.playerstyle($1) != spellmaster) { dec %attack.damage $return_percentofvalue(%attack.damage, 40) }
    else { inc %attack.damage $return_percentofvalue(%attack.damage, $readini($char($1), styles, spellmaster))  }
  }

  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, tech)

  $damage.color.check

  ; if the tech is the same as what was used in the last round, nerf the damage
  if ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction)) { set %attack.damage $round($calc(%attack.damage / 3),0) }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 5 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%attack.damage <= 0) { set %attack.damage 1 } 

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }


  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)

  ; Check for wonderguard
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Check to see if SwiftCast is on and if this tech is a spell.
  $swiftcast_check($1, $2)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)
}

formula.techdmg.player.formula_3.1 {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal")

  if (%attack.damage = $null) { set %attack.damage 0 }

  ; First things first, let's find out the base power.
  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  } 

  set %true.base.stat %base.stat

  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)

  var %user.tech.level $readini($char($1), Techniques, $2)
  if (%user.tech.level = $null) { var %user.tech.level 1 }

  set %ignition.name $readini($char($1), status, ignition.name)
  set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  if (%user.tech.level < 100) {  inc %tech.base $round($calc(%user.tech.level * 1.8),0) }

  ; Let's add in the base power of the weapon used..
  if ($person_in_mech($1) = false) { set %weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %weapon.used $readini($char($1), mech, equippedWeapon) }

  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power.wpn 1 }

  var %weapon.base $readini($char($1), weapons, %weapon.used)
  if (%weapon.base = $null) { set %weapon.base 1 }
  inc %base.power.wpn %weapon.base

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, %weapon.used)

  unset %weapon.used

  inc %base.power.wpn %mastery.bonus

  set %attack.damage $calc(%tech.base + %user.tech.level + %base.power.wpn)

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,15)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 

    $calculate_damage_magic($1, $2, $3)
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle, ImmuneToMagic) }
  }

  ; Check for TechBonus augment for non-magic techs
  if ($readini($dbfile(techniques.db), $2, magic) != yes) { 
    if ($augment.check($1, TechBonus) = true) { 
      set %tech.bonus.augment $calc(%augment.strength * .25)
      var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %attack.damage),0)
      inc %attack.damage %augment.power.increase.amount
      unset %tech.bonus.augment
    }
  }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini($dbfile(techniques.db), $2, element),46) = $true) { inc %attack.damage $round($calc(%attack.damage * .110),0)
    } 
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($person_in_mech($1) = false) {  set %current.weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %current.weapon.used $readini($char($1), mech, EquippedWeapon) }

  if (($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) && ($readini($dbfile(weapons.db), %current.weapon.used, specialweapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  if ($readini($dbfile(techniques.db), $2, stat) = str) {  
    set %enemy.defense $current.def($3) 
    inc %enemy.defense $armor.stat($3, def) 
    if ($readini($char($3), status, defdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }
  else { 
    set %enemy.defense $current.int($3) 
    inc %enemy.defense $armor.stat($3, int) 
    if ($skill.bloodspirit.status($3) = on) { inc %enemy.defense $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
    if ($readini($char($3), status, intdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }

  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ; Calculate the attack damage based on log of base stat / log of enemy's defense
  set %attack.damage $round($calc(($log(%base.stat) / $log(%enemy.defense)) * %attack.damage),0)

  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, tech)

  $damage.color.check

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %flag $readini($char($1), info, flag)
  $cap.damage($1, $3, tech)

  if (%attack.damage <= 1) {
    var %minimum.damage 1
    set %attack.damage $readini($dbfile(techniques.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  unset %true.base.stat

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if ((%user.flag = monster) && (%battle.rage.darkness != on)) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; If this current tech is using the same tech as the previous tech attack, nerf the damage
  if (($4 != aoe) && ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction))) { set %attack.damage $round($calc(%attack.damage / 3),0) }
  if (($4 = aoe) && (%lastaction.nerf = true)) { set %attack.damage $round($calc(%attack.damage / 3),0) }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 10 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)

  ; Check for wonderguard
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)
}
formula.techdmg.player.formula_3.0 {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal")

  if (%attack.damage = $null) { set %attack.damage 0 }

  ; First things first, let's find out the base power.
  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  }

  set %true.base.stat %base.stat
  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)

  var %user.tech.level $readini($char($1), Techniques, $2)
  if (%user.tech.level = $null) { var %user.tech.level 1 }

  set %ignition.name $readini($char($1), status, ignition.name)
  set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  if (%user.tech.level < 100) {  inc %tech.base $round($calc(%user.tech.level * 1.8),0) }

  ; Let's add in the base power of the weapon used..
  if ($person_in_mech($1) = false) { set %weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %weapon.used $readini($char($1), mech, equippedWeapon) }

  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power.wpn 1 }

  set %weapon.base $readini($char($1), weapons, %weapon.used)
  if (%weapon.base = $null) { set %weapon.base 1 }
  inc %base.power.wpn $calc(1 + (2 * $log(%weapon.base)))

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, %weapon.used)

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%tech.base > $return_winningstreak) { var %tech.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  unset %weapon.used

  inc %base.power.wpn %mastery.bonus

  set %attack.damage $calc(%tech.base + %user.tech.level + %base.power.wpn)

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,15)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 

    $calculate_damage_magic($1, $2, $3)
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle, ImmuneToMagic) }
  }

  ; Check for TechBonus augment for non-magic techs
  if ($readini($dbfile(techniques.db), $2, magic) != yes) { 
    if ($augment.check($1, TechBonus) = true) { 
      set %tech.bonus.augment $calc(%augment.strength * .25)
      var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %attack.damage),0)
      inc %attack.damage %augment.power.increase.amount
      unset %tech.bonus.augment
    }
  }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini($dbfile(techniques.db), $2, element),46) = $true) { inc %attack.damage $round($calc(%attack.damage * .110),0)
    } 
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($person_in_mech($1) = false) {  set %current.weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %current.weapon.used $readini($char($1), mech, EquippedWeapon) }

  if (($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) && ($readini($dbfile(weapons.db), %current.weapon.used, specialweapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  ; Increase attack damage by the $log of the base stat.
  set %attack.damage $round($calc(%attack.damage * $log(%base.stat)),0)

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  if ($readini($dbfile(techniques.db), $2, stat) = str) {  
    set %enemy.defense $current.def($3)
    inc %enemy.defense $armor.stat($3, def)
    if ($readini($char($3), status, defdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }
  else { 
    set %enemy.defense $current.int($3)
    inc %enemy.defense $armor.stat($3, int)
    if ($skill.bloodspirit.status($3) = on) { inc %enemy.defense $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
    if ($readini($char($3), status, intdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }

  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  var %blocked.percent $log(%enemy.defense)
  if (%blocked.percent < 0) { var %blocked.percent .5 }
  inc %blocked.percent $rand(1,10)
  inc %blocked.percent $log($get.level($3))

  if ($readini(system.dat, system, PlayersMustDieMode) = true)  { inc %blocked.percent $rand(2,5) }
  if ($return_playersinbattle > 1) { inc %blocked.percent $calc($return_playersinbattle * 3) }

  var %blocked.damage $round($return_percentofvalue(%attack.damage, %blocked.percent),0)
  dec %attack.damage %blocked.damage

  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, tech)
  $damage.color.check

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %flag $readini($char($1), info, flag)

  $calculate_attack_leveldiff($1, $3)
  $cap.damage($1, $3, tech)

  if (%attack.damage <= 1) {
    var %minimum.damage 1
    set %attack.damage $readini($dbfile(techniques.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }


  unset %true.base.stat

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if ((%user.flag = monster) && (%battle.rage.darkness != on)) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; If this current tech is using the same tech as the previous tech attack, nerf the damage
  if (($4 != aoe) && ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction))) { set %attack.damage $round($calc(%attack.damage / 3),0) }
  if (($4 = aoe) && (%lastaction.nerf = true)) { set %attack.damage $round($calc(%attack.damage / 3),0) }


  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 10 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)

  ; Check for wonderguard
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The formulas below this line are either old or
; experimental. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.meleedmg.player.formula_4.0 {
  unset %absorb
  set %attack.damage 0

  var %damage.rating 0

  var %base.stat $readini($char($1), battle, str)
  inc %base.stat $armor.stat($1, str)
  if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
  $strength_down_check($1)

  inc %damage.rating %base.stat
  inc %damage.rating $readini($char($1), weapons, $2)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if (($readini($dbfile(weapons.db), $2, type) = HandToHand) && ($2 != fists)) {  inc %damage.rating $readini($char($1), weapons, fists) }

  ; Get the weapon's power
  var %weapon.power $readini($dbfile(weapons.db), $2, basepower)
  if (%weapon.power = $null) { var %weapon.power 1 }


  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini($dbfile(items.db), %current.accessory, accessorytype)

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; If it's a portal battle this might need to be adjusted to make portal battles easier to balance
  if (%portal.bonus = true) {
    if (%weapon.base > $return_winningstreak) { var %weapon.base $return_winningstreak }
    if (%mastery.bonus > $calc($return_winningstreak + 10)) { var %mastery.bonus $calc($return_winningstreak + 10) }
  }

  ; Let's add the mastery bonus to the weapon base
  inc %damage.rating %mastery.bonus

  ; Let's check for some offensive style enhancements
  if ($person_in_mech($1) = false) { 
    $offensive.style.check($1, $2, melee)
  }

  ;If the element is Light and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%weapon.element = light) {  inc %damage.rating $round($calc(%damage.rating * .110),0) } 
    if (%weapon.element = fire) {  inc %damage.rating $round($calc(%damage.rating * .110),0) } 
  } 

  ; Check to see if we have an accessory or augment that enhances the weapon type
  $melee.weapontype.enhancements($1)
  unset %weapon.type

  ; Check for Killer Traits
  inc %attack.damage $round($calc(%damage.rating * ($killer.trait.check($1, $3) / 100)),0)

  ; Check for MightyStrike
  if ($person_in_mech($1) = false) { 
    ; Check for the skill "MightyStrike"
    if ($mighty_strike_check($1) = true) { 
      ; Double the attack.
      %damage.rating = $calc(%attack.damage * 1.5)
    }

    ; Check for the "DesperateBlows" skill.
    if ($desperate_blows_check($1) = true) {
      var %hp.percent $calc(($readini($char($1), Battle, HP) / $readini($char($1), BaseStats, HP)) *100)
      if ((%hp.percent >= 10) && (%hp.percent <= 25)) { %damage.rating = $round($calc(%damage.rating * 1.5),0) }
      if ((%hp.percent > 2) && (%hp.percent < 10)) { %damage.rating = $round($calc(%damage.rating * 2),0) }
      if ((%hp.percent > 0) && (%hp.percent <= 2)) { %damage.rating = $round($calc(%damage.rating * 2.5),0) }
    }
  }

  unset %current.playerstyle | unset %current.playerstyle.level

  if ($person_in_mech($1) = false) { 
    ;  Check for the miser ring accessory

    if ($accessory.check($1, IncreaseMeleeDamage) = true) {
      var %redorb.amount $readini($char($1), stuff, redorbs)
      var %miser-ring.increase $round($calc(%redorb.amount * %accessory.amount),0)

      if (%miser-ring.increase <= 0) { var %miser-ring.increase 1 }
      if (%miser-ring.increase > 1000) { var %miser-ring.increase 1000 }
      inc %damage.rating %miser-ring.increase
      unset %accessory.amount
    }

    ;  Check for the fool's tablet accessory
    if ($accessory.check($1, IncreaseMeleeAddPoison) = true) {
      inc %damage.rating $round($calc(%damage.rating * %accessory.amount),0)
      unset %accessory.amount
    }
  }

  if ($augment.check($1, MeleeBonus) = true) { 
    set %melee.bonus.augment $calc(%augment.strength * .25)
    var %augment.power.increase.amount $round($calc(%melee.bonus.augment * %damage.rating),0)
    inc %damage.rating %augment.power.increase.amount
    unset %melee.bonus.augment
  }

  unset %current.accessory.type

  $flying.damage.check($1, $2, $3) 
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

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  inc %enemy.defense $armor.stat($3, def)

  $defense_down_check($3)
  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(weapons.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
    if (%enemy.defense <= 0) { set %enemy.defense 1 }
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  set %attack.damage $calc((100 + (%damage.rating - %enemy.defense))/100 * %weapon.power)

  ; Check for modifiers
  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, melee)

  $damage.color.check

  var %flag $readini($char($1), info, flag) 

  if (enhance-melee isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense 

  unset %enemy.defense

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Adjust the damage based on weapon size vs monster size
  $monstersize.adjust($3,$2)

  ; If this current melee attack is using the same weapon as the previous melee attack, nerf the damage
  $melee.lastaction.nerfcheck($1, $2)

  if (%attack.damage <= 1) {
    set %attack.damage $readini($dbfile(weapons.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  inc %attack.damage $rand(1,10)

  unset %true.base.stat

  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

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
    $set_chr_name($1) |  $display.message($readini(translation.dat, battle, LandsACriticalHit), battle)
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
  if (($readini($char($1), weapons, equippedLeft) != $null) && ($person_in_mech($1) = false)) {
    var %left.hits $readini($dbfile(weapons.db), $readini($char($1), weapons, equippedLeft), hits)
    if (%left.hits = $null) { var %left.hits 1 }
    inc %weapon.howmany.hits %left.hits 
  }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for countering an attack using a shield
  $shield_reflect_melee($1, $3, $2, $4)

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
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  ; If we came here via mugger's belt, we need to cut the damage in half.
  if ($4 = mugger's-belt) {  %attack.damage = $round($calc(%attack.damage / 2),0) |  set %damage.display.color 06 }

  if (%counterattack != on) { 
    ; Check for the En-Spell Buff
    if ($readini($char($1), status, en-spell) != none) { 
      $magic.effect.check($1, $3, nothing, en-spell) 
      $modifer_adjust($3, $readini($char($1), status, en-spell))
    }
  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  if (%attack.damage = 0) { return }

  ; Check for multiple hits
  $multihitcheck.melee($1, $2, $3, $4)
}


formula.techdmg.player.formula_4.0 {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal")

  set %attack.damage 0 
  var %damage.rating 0

  ; First things first, let's find out the base power.

  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  } 

  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)

  var %user.tech.level $readini($char($1), Techniques, $2)
  if (%user.tech.level = $null) { var %user.tech.level 1 }

  set %ignition.name $readini($char($1), status, ignition.name)
  set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  if (%user.tech.level < 100) {  inc %tech.base $round($calc(%user.tech.level * 1.8),0) }

  ; Let's add in the base power of the weapon used..
  if ($person_in_mech($1) = false) { set %weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %weapon.used $readini($char($1), mech, equippedWeapon) }

  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power.wpn 1 }

  var %weapon.base $readini($char($1), weapons, %weapon.used)
  if (%weapon.base = $null) { set %weapon.base 1 }
  inc %base.power.wpn %weapon.base

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, %weapon.used)

  unset %weapon.used

  inc %base.power.wpn %mastery.bonus

  inc %damage.rating $calc(%tech.base * (%user.tech.level + %base.power.wpn))
  inc %damage.rating %base.stat

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  ; Let's increase the attack by a random amount.
  inc %damage.damage $rand(1,15)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
    set %attack.damage %damage.rating
    $calculate_damage_magic($1, $2, $3)
    set %damage.rating %attack.damage
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle, ImmuneToMagic) }
  }

  ; Check for TechBonus augment for non-magic techs
  if ($readini($dbfile(techniques.db), $2, magic) != yes) { 
    if ($augment.check($1, TechBonus) = true) { 
      set %tech.bonus.augment $calc(%augment.strength * .25)
      var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %damage.rating),0)
      inc %damage.rating %augment.power.increase.amount
      unset %tech.bonus.augment
    }
  }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini($dbfile(techniques.db), $2, element),46) = $true) { inc %damage.rating $round($calc(%damage.rating * .110),0)
    } 
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($person_in_mech($1) = false) {  set %current.weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %current.weapon.used $readini($char($1), mech, EquippedWeapon) }

  if (($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) && ($readini($dbfile(weapons.db), %current.weapon.used, specialweapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %damage.rating 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  if ($readini($dbfile(techniques.db), $2, stat) = str) {  
    set %enemy.defense $current.def($3) 
    inc %enemy.defense $armor.stat($3, def) 
    if ($readini($char($3), status, defdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }
  else { 
    set %enemy.defense $current.int($3) 
    inc %enemy.defense $armor.stat($3, int) 
    if ($skill.bloodspirit.status($3) = on) { inc %enemy.defense $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
    if ($readini($char($3), status, intdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }

  $defense_up_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ; Calculate the attack damage
  set %attack.damage $calc((100 + (%damage.rating - %enemy.defense))/100 * %tech.base)

  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, tech)
  $damage.color.check

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  if (enhance-tech isin %battleconditions) { inc %attack.damage $return_percentofvalue(%attack.damage, 10) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %flag $readini($char($1), info, flag)

  if (%attack.damage <= 1) {
    var %minimum.damage 1
    set %attack.damage $readini($dbfile(techniques.db), $2, BasePower)
    set %attack.damage $rand(1, %attack.damage)
  }

  unset %true.base.stat

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  ; Elite monsters take less damage
  if ($eliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .30),0)  }
  if ($supereliteflag.check($3) = true) { dec %attack.damage $round($calc(%attack.damage *  .45),0)  }

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if ((%user.flag = monster) && (%battle.rage.darkness != on)) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; If this current tech is using the same tech as the previous tech attack, nerf the damage
  if (($4 != aoe) && ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction))) { set %attack.damage $round($calc(%attack.damage / 3),0) }
  if (($4 = aoe) && (%lastaction.nerf = true)) { set %attack.damage $round($calc(%attack.damage / 3),0) }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 10 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)

  ; Check for wonderguard
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  ; Check for a shield block.
  $shield_block_check($3, $1, $2)

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)
}


formula.techdmg.player.percent {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target
  ; $4 = optional flag ("heal")

  var %base.percent 0 | var %max.enemy.hp $readini($char($3), basestats, hp)
  if (%attack.damage = $null) { set %attack.damage 0 }

  ; First things first, let's find out the base power.
  set %base.stat.needed $readini($dbfile(techniques.db), $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat.needed = str) { inc %base.stat $armor.stat($1, str) 
    if ($skill.bloodboost.status($1) = on) { inc %base.stat $skill.bloodboost.calculate($1) }
    $strength_down_check($1) 
  } 
  if (%base.stat.needed = def) { inc %base.stat $armor.stat($1, def) } 
  if (%base.stat.needed = int) { inc %base.stat $armor.stat($1, int) 
    if ($skill.bloodspirit.status($1) = on) { inc %base.stat $skill.bloodspirit.calculate($1) }
    $int_down_check($1)
  } 
  if (%base.stat.needed = spd) {
    inc %base.stat.needed $armor.stat($1, spd) 
    if ($skill.speed.status($1) = on) { inc %base.stat $skill.speed.calculate($1) }
  }

  if (%base.stat > 9999) { set %base.stat $round($calc(9999 + ((%base.stat - 9999) * .10)),0) }

  ; Get the tech base and user's tech level
  var %tech.base $readini($dbfile(techniques.db), p, $2, BasePower)

  var %user.tech.level $readini($char($1), Techniques, $2)
  if (%user.tech.level = $null) { var %user.tech.level 1 }

  set %ignition.name $readini($char($1), status, ignition.name)
  set %ignition.techs $readini($dbfile(ignitions.db), %ignition.name, techs)
  if ($istok(%ignition.techs,$2,46) = $true) { var %user.tech.level 50 }
  unset %ignition.name | unset %ignition.techs

  var %attack.power $calc((%base.stat / 1.5) + (%tech.base + ((%tech.base * %user.tech.level) / 500)))

  ; Let's add in the base power of the weapon used..
  if ($person_in_mech($1) = false) { set %weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %weapon.used $readini($char($1), mech, equippedWeapon) }

  set %base.power.wpn $readini($dbfile(weapons.db), %weapon.used, basepower)
  if (%base.power.wpn = $null) { var %base.power 1 }

  set %weapon.base $readini($char($1), weapons, %weapon.used)
  if (%weapon.base = $null) { set %weapon.base 1 }
  inc %base.power.wpn $round($calc(%weapon.base / 10),0)

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, %weapon.used)

  unset %weapon.used

  if (%mastery.bonus != $null) {  inc %base.power.wpn %mastery.bonus }

  inc %attack.power %base.power.wpn

  ; Increase the base percent
  inc %base.percent $calc(%attack.power / 10)
  if (%base.percent > 50) { var %base.percent 50 }

  ; Set the attack damage
  var %minimum.damage $return_percentofvalue(%max.enemy.hp, %base.percent)
  set %attack.damage $return_percentofvalue(%max.enemy.hp, %base.percent)

  if ($person_in_mech($1) = false) {
    ; Let's check for some offensive style enhancements
    $offensive.style.check($1, $2, tech)
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini($dbfile(techniques.db), $2, magic) = yes) { 

    $calculate_damage_magic($1, $2, $3)
    if ($readini($char($3), info, ImmuneToMagic) = true) {  $set_chr_name($3) | set %guard.message $readini(translation.dat, battle,  ImmuneToMagic) }
  }

  ; Check for TechBonus augment for non-magic techs
  if ($readini($dbfile(techniques.db), $2, magic) != yes) { 
    if ($augment.check($1, TechBonus) = true) { 
      set %tech.bonus.augment $calc(%augment.strength * .25)
      var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %attack.damage),0)
      inc %attack.damage %augment.power.increase.amount
      unset %tech.bonus.augment
    }
  }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini($dbfile(techniques.db), $2, element),46) = $true) { inc %attack.damage $round($calc(%attack.damage  * .110),0)
    } 
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($person_in_mech($1) = false) {  set %current.weapon.used $readini($char($1), weapons, equipped) }
  if ($person_in_mech($1) = true) { set %current.weapon.used $readini($char($1), mech, EquippedWeapon) }

  if (($readini($dbfile(weapons.db), %current.weapon.used, cost) = 0) && ($readini($dbfile(weapons.db), %current.weapon.used,  specialweapon) != true)) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini($dbfile(techniques.db), $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  if ($readini($dbfile(techniques.db), $2, stat) = str) {  
    set %enemy.defense $current.def($3)
    inc %enemy.defense $armor.stat($3, def)
    if ($readini($char($3), status, defdown) = yes) {  var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }
  else { 
    set %enemy.defense $current.int($3)
    inc %enemy.defense $armor.stat($3, int)
    if ($skill.bloodspirit.status($3) = on) { inc %enemy.defense $round($calc($skill.bloodspirit.calculate($3) /3.5),0) }
    if ($readini($char($3), status, intdown) = yes) { var %enemy.defense $round($calc(%enemy.defense / 4),0) }
  }

  $defense_up_check($3)

  ; Check to see if the tech has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini($dbfile(techniques.db), $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) { inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }
  if (%enemy.defense > 9999) { set %enemy.defense $round($calc(9999 + ((%enemy.defense - 9999)* .10)),0) }
  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  set %starting.damage %attack.damage

  $damage.modifiers.check($1, $2, $3, tech)

  $damage.color.check

  ; Modify the attack damage.
  $calculate_attack_leveldiff($1, $3)

  var %level.percent.modifier $calc($get.level($1) / $get.level($3))
  var %stat.percent.modifier $calc(%base.stat / %enemy.defense)

  if (%level.percent.modifier > 2) { var %level.percent.modifier 2 }
  if (%stat.percent.modifier > 2) { var %stat.percent.modifier 2 }

  %attack.damage = $calc(%attack.damage * %level.percent.modifier)
  %attack.damage = $calc(%attack.damage * %stat.percent.modifier)

  %minimum.damage = $calc(%minimum.damage * %level.percent.modifier)
  %minimum.damage = $calc(%minimum.damage * %stat.percent.modifier)

  var %minimum.damage $round($abs($calc(%attack.damage - %minimum.damage)),0)

  set %attack.damage $round($rand(%minimum.damage, %attack.damage),0)

  ; Cap the damage
  $cap.damage($1, $3, tech)

  if ($readini($char($3), info, ai_type) = counteronly) { set %attack.damage 0 | return }

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if ((%user.flag = monster) && (%battle.rage.darkness != on)) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; If the tech is the same as the last round, nerf the damage
  if (($4 != aoe) && ($2 = $readini($txtfile(battle2.txt), style, $1 $+ .lastaction))) { set %attack.damage $round($calc(%attack.damage / 3),0) }
  if (($4 = aoe) && (%lastaction.nerf = true)) { set %attack.damage $round($calc(%attack.damage / 3),0) }

  ; AOE nerf check for players
  if (($readini($char($1), info, flag) = $null) ||  ($readini($char($1), info, clone) = yes)) {

    if (%aoe.turn > 1) {
      var %aoe.nerf.percent $calc(8 * %aoe.turn)
      if ($readini($dbfile(techniques.db), $2, hits) > 1) { inc %aoe.nerf.percent 5 }
      if (%aoe.nerf.percent > 93) { var %aoe.nerf.percent 93 }
      var %aoe.nerf.percent $calc(%aoe.nerf.percent / 100) 
      var %aoe.nerf.amount $round($calc(%attack.damage * %aoe.nerf.percent),0)
      dec %attack.damage %aoe.nerf.amount
    }

  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  if ($readini($dbfile(techniques.db), $2, magic) != yes) {  $flying.damage.check($1, %weapon.used, $3)  }
  $invincible.check($1, $2, $3)
  $perfectdefense.check($1, $2, $3)
  if ($readini($dbfile(techniques.db), $2, canDodge) != false) {  $trickster_dodge_check($3, $1, tech) }
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $tech.ethereal.check($1, $2, $3)
  $wonderguard.check($3, $2, tech, $readini($char($1), weapons, equipped))

  ; Check for the skill "Overwhelm" and increase the damage if so
  $skill.overwhelm($1)

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(techniques.db), $2, StatusType)

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini($dbfile(techniques.db), $2, hits)

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  var %current.element $readini($dbfile(techniques.db), $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 

      ; This is mostly just for gremlins but might be useful for other things down the road.
      $readini($char($3), modifier_special, %current.element)
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)

  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if ((%guard.message = $null) && (%attack.damage > 0)) {
    if (%status.type.list != $null) { 
      set %number.of.statuseffects $numtok(%status.type.list, 46) 

      if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset  %status.type.list }
      if (%number.of.statuseffects > 1) {
        var %status.value 1
        while (%status.value <= %number.of.statuseffects) { 
          set %current.status.effect $gettok(%status.type.list, %status.value, 46)
          $inflict_status($1, $3, %current.status.effect, $2)
          inc %status.value 1
        }  
        unset %number.of.statuseffects | unset %current.status.effect
      }
    }
  }
  unset %status.type.list

  if (%guard.message = $null) {
    if ($readini($dbfile(techniques.db), $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) { %attack.damage = $round ($calc(%attack.damage / 2),0) }

  ; If the attacker is a doll, cut the damage in half
  if ($readini($char($1), status, doll) = yes) { %attack.damage = $calc(%attack.damage / 2) } 

  ; Check for a guardian monster
  $guardianmon.check($1, $2, $3, $4)

  ; Set the style amount to the attack damage
  set %style.attack.damage %attack.damage

  ; Check for multiple hits
  $multihitcheck.tech($1, $2, $3, $4)

  unset %tech.howmany.hits |  unset %enemy.defense | set %multihit.message.on on

  ; Check to see if we need to increase the proficiency of a technique.
  $tech.points($1, $2)

  unset %attacker.level | unset %defender.level | unset %tech.count | unset %tech.power | unset %base.weapon | unset %random
  unset %capamount
}
