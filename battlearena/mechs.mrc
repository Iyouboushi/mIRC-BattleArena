;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; MECH COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 3:ACTION:activates * mech:#:{ $mech.activate($nick) } 
ON 3:ACTION:deactivates * mech:#:{ $mech.deactivate($nick) } 
ON 50:TEXT:* activates * mech:*:{ $mech.activate($1) } 
ON 50:TEXT:*deactivates * mech:*:{ $mech.deactivate($1) } 

ON 3:TEXT:* activates * mech:*:{ 
  if (($2 != activates) && ($4 != mech)) { halt }
  if ($readini($char($1), info, flag) = monster) { halt }
  $no.turn.check($1)
  $controlcommand.check($nick, $1)
  $mech.activate($1) 
} 
ON 3:TEXT:* deactivates * mech:*:{ 
  if (($2 != activates) && ($4 != mech)) { halt }
  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  $mech.deactivate($1)
} 

ON 3:TEXT:!mech repair*:*:{ $mech.repair($nick, $3) }
ON 3:TEXT:!mech fuel*:*:{ $mech.fuel($nick, $3) }
ON 3:TEXT:!mech energy*:*:{ $mech.fuel($nick, $3) }
ON 3:TEXT:!mech equip*:*:{ $mech.equip($nick, $3) }
ON 3:TEXT:!mech unequip*:*:{ $mech.unequip($nick, $3) }
ON 3:TEXT:!mech stats*:*:{ $mech.stats($nick) }
ON 3:TEXT:!mech status*:*:{ $mech.stats($nick) }
ON 3:TEXT:!mech items*:*:{  $mech.items($nick, channel) } 
ON 3:TEXT:!mech weapons*:*:{  $mech.weapons($nick, channel) } 
ON 3:TEXT:!mech upgrade*:*:{  
  var %amount.to.purchase $abs($4)
  if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }
  $mech.upgrade($nick, $2, $3, %amount.to.purchase) 
} 

on 3:TEXT:!mech desc *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), mech, HpMax) = $null) {  $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }
  writeini $char($nick) Descriptions mech $3- | $okdesc($nick ,Mech) 
}

on 3:TEXT:!mech name *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), mech, HpMax) = $null) {  $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }
  writeini $char($nick) Mech Name $3- 
  $display.private.message(3Mech name set to: %real.name $+ 's $3- ) 
}

alias mech.upgrade {
  var %valid.categories hp.health.energy.engine.cost.list

  if ($istok(%valid.categories, $3, 46) = $false) { $display.private.message(4Error: !mech upgrade <hp/health/engine/energy/cost> <amount>)  | halt }

  if (($3 = cost) || ($3 = list)) {
    var %health.cost $readini(system.dat, mech, HealthUpgradeCost)
    if (%health.cost = $null) { var %health.cost 200 }

    var %energy.cost $readini(system.dat, mech, EnergyUpgradeCost)
    if (%energy.cost = $null) { var %energy.cost 500 }

    var %engine.cost $readini(system.dat, mech, EngineUpgradeCost)
    if (%engine.cost = $null) { var %engine.cost 1000 }

    var %upgrade.cost Health( $+ %health.cost $+ ) $+ ,  Energy( $+ %energy.cost $+ ), Engine( $+ %engine.cost $+ )

    $display.private.message(2All prices are in Allied Notes)
    $display.private.message(4Cost to Upgrade2: %upgrade.cost)
    halt
  }

  if (($3 = hp) || ($3 = health)) { 
    set %cost $readini(system.dat, mech, HealthUpgradeCost)
    var %health.to.increase $calc(500 * $4)
    var %max.health $readini(system.dat, mech, MaxHP)
    if (%max.health = $null) { var %max.health 10000 }
    var %current.maxhp $readini($char($1), mech, HpMax)
    inc %current.maxHp %health.to.increase

    if (%current.maxHp > %max.health) { $display.private.message($readini(translation.dat, errors, MechMaxAmount)) | halt }

    if (%cost = $null) { set %cost 200 }
    $mech.calccost($1, $4)
    writeini $char($1) mech HpMax %current.maxHp

    $display.private.message($readini(translation.dat, system, MechUpgradeHealth)) 
  }

  if ($3 = engine) { 
    set %cost $readini(system.dat, mech, EngineUpgradeCost)
    var %engine.to.increase $calc(.1 * $4)
    var %max.engine $readini(system.dat, mech, MaxEngine)
    if (%max.engine = $null) { var %max.engine 5 }
    var %current.engine $readini($char($1), mech, EngineLevel)
    inc %current.engine %engine.to.increase

    if (%current.engine > %max.engine) { $display.private.message($readini(translation.dat, errors, MechMaxAmount)) | halt }

    if (%cost = $null) { set %cost 1000 }
    $mech.calccost($1, $4)
    writeini $char($1) mech EngineLevel %current.engine

    $display.private.message($readini(translation.dat, system, MechUpgradeEngine)) 
  }

  if ($3 = energy) { 
    set %cost $readini(system.dat, mech, EnergyUpgradeCost)
    var %energy.to.increase $calc(100 * $4)
    var %max.energy $readini(system.dat, mech, MaxEnergy)
    if (%max.energy = $null) { var %max.energy 5000 }
    var %current.maxenergy $readini($char($1), mech, EnergyMax)
    inc %current.maxEnergy %energy.to.increase

    if (%current.maxEnergy > %max.energy) { $display.private.message($readini(translation.dat, errors, MechMaxAmount)) | halt }

    if (%cost = $null) { set %cost 500 }
    $mech.calccost($1, $4)
    writeini $char($1) mech EnergyMax %current.maxEnergy

    $display.private.message($readini(translation.dat, system, MechUpgradeEnergy)) 
  }
  unset %cost | unset %player.currency | unset %total.price | unset %replacechar 
}

alias mech.calccost {
  ; do you have enough to buy it?
  set %player.currency $readini($char($1), stuff, alliednotes)
  set %total.price $calc(%cost * $2)

  if (%player.currency = $null) { set %player.currency 0 }

  if (%player.currency < %total.price) {  $display.private.message(4You do not have enough Allied Notes to purchase this upgrade!) | unset %currency | unset %cost | unset %player.currency | unset %total.price | halt }
  dec %player.currency %total.price
  writeini $char($1) stuff AlliedNotes %player.currency
}

alias mech.items { $set_chr_name($1)
  $items.mechcore($1)
  $weapons.mech($1)

  if (%mech.weapon.list != $null) { 
    if ($2 = channel) { $display.system.message($readini(translation.dat, system, ViewMechWeapons),private) | if (%mech.weapon.list2 != $null) { $display.system.message( $+ %mech.weapon.list2,battle)  } } 
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewMechWeapons)) | if (%mech.weapon.list2 != $null) {  $display.private.message( $+ %mech.weapon.list2) } } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMechWeapons)) | if (%mech.weapon.list2 != $null) {  $dcc.private.message($nick,  $+ %mech.weapon.list2) } }
  }

  if (%mech.items.list != $null) { 
    if ($2 = channel) { $display.system.message($readini(translation.dat, system, ViewMechCoreItems),battle) | if (%mech.items.list2 != $null) { $display.system.message( $+ %mech.items.list2,battle)  } } 
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewMechCoreItems)) | if (%mech.items.list2 != $null) {  $display.private.message( $+ %mech.items.list2)  } } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMechCoreItems)) | if (%mech.items.list2 != $null) {  $dcc.private.message($nick,  $+ %mech.items.list2) } }
  }

  if ((%mech.items.list = $null) && (%mech.weapon.list = $null)) { 
    if ($2 = channel) { $display.system.message($readini(translation.dat, system, HasNoMechItems),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, HasNoMechItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoMechItems)) }
  }

  unset %mech.weapon.list | unset %mech.weapon.list2 | unset %mech.items.list | unset %mech.items.list2
}

alias mech.weapons { $set_chr_name($1)
  $weapons.mech($1)

  if (%mech.weapon.list != $null) { 
    if ($2 = channel) { $display.system.message($readini(translation.dat, system, ViewMechWeapons),battle) | if (%mech.weapon.list2 != $null) { $display.system.message( $+ %mech.weapon.list2,battle) } } 
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewMechWeapons)) | if (%mech.weapon.list2 != $null) {  $display.private.message( $+ %mech.weapon.list2) } } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMechWeapons)) | if (%mech.weapon.list2 != $null) {  $dcc.private.message($nick,  $+ %mech.weapon.list2) } }
  }

  else {
    if ($2 = channel) { $display.system.message($readini(translation.dat, system, HasNoMechWeapons),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, HasNoMechWeapons)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoMechWeapons)) }
  }

  unset %mech.weapon.list | unset %mech.weapon.list2
}

alias mech.stats {
  $set_chr_name($1)
  var %mech.name $readini($char($1), mech, name)
  var %mech.maxHP $readini($char($1), mech, HpMax)

  if ((%mech.name = $null) && (%mech.maxHP = $null)) { $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }

  var %mech.currentHP $readini($char($1), mech, HpCurrent)
  var %mech.currentEnergy $readini($char($1), mech, EnergyCurrent)
  var %mech.maxEnergy $readini($char($1), mech, EnergyMax)
  set %mech.equippedWeapon $readini($char($1), mech, EquippedWeapon)
  var %mech.equippedCore $readini($char($1), mech, EquippedCore)
  var %mech.baseEnergyRequired $mech.baseenergycost($1)
  var %mech.engine $readini($char($1), mech, EngineLevel)

  set %techs.list $readini($dbfile(weapons.db), %mech.equippedWeapon, abilities)
  set %replacechar $chr(044) $chr(032)
  %techs.list = $replace(%techs.list, $chr(046), %replacechar)
  unset %replacechar
  if (%techs.list = $null) { var %techs.list none }

  ; Show the current mech information
  $display.private.message([4Name12 %mech.name $+ 1] [4HP12 %mech.currentHP $+ 1/ $+ 12 $+ %mech.maxHP $+ 1] [4Energy12 %mech.currentEnergy $+ 1/ $+ 12 $+ %mech.maxEnergy $+ 1] [4Engine Level12 %mech.engine $+ 1] [4Base Energy Requirement12 %mech.baseEnergyRequired $+ 1])  
  $display.private.message([4Equipped Weapon12 %mech.equippedWeapon $+ 1] [4Equipped Core Piece12 %mech.equippedCore $+ 1]  [4Techs Available12 %techs.list $+ 1]   ) 

  unset %mech.equippedWeapon | unset %tech.list 

}

alias mech.unequip {
  $set_chr_name($1)
  ; Check to see if the person owns a mech.
  if ($readini($char($1), mech, HpMax) = $null) {  $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }

  ; If a battle is ongoing, it can't be changed.
  if (%battleis = on) {  $display.system.message($readini(translation.dat, errors, Can'tEquipInBattle), private) | halt }

  ; Does the user have that item?
  var %item.amount $readini($char($1), item_amount, $2)
  if ((%item.amount <= 0) || (%item.amount = $null)) { $display.private.message($readini(translation.dat, errors, DoesNotHaveThatItem)) | halt }

  ; Determine what type of item it is (weapon or core)
  if ($readini($dbfile(items.db), $2, type) = $null) { var %item.type weapon }
  else { var %item.type core }

  if (%item.type = weapon) { 
    if ($2 = BasicMechGun) { $display.private.message($readini(translation.dat, errors, MechUnableToUnequipThatItem)) | halt }
    writeini $char($1) mech EquippedWeapon BasicMechGun
  }

  if (%item.type = core) { 
    if ($2 = BasicMechCore) { $display.private.message($readini(translation.dat, errors, MechUnableToUnequipThatItem)) | halt }
    writeini $char($1) mech EquippedCore BasicMechCore
    var %augments $readini($dbfile(items.db), $2, Augment)
    if (%augments = $null) { var %augments none }
    writeini $char($1) mech augments %augments
  }

  $display.system.message($readini(translation.dat, system, UnEquipMechItem), global) 
  halt
}

alias mech.equip { 
  $set_chr_name($1)
  ; Check to see if the person owns a mech.
  if ($readini($char($1), mech, HpMax) = $null) {  $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }

  ; If a battle is ongoing, it can't be changed.
  if (%battleis = on) {  $display.system.message($readini(translation.dat, errors, Can'tEquipInBattle), private) | halt }

  ; Does the user have that item?
  var %item.amount $readini($char($1), item_amount, $2)
  if ((%item.amount <= 0) || (%item.amount = $null)) { $display.private.message($readini(translation.dat, errors, DoesNotHaveThatItem)) | halt }

  ; Determine what type of item it is (weapon or core)
  if ($readini($dbfile(items.db), $2, type) = $null) { var %item.type weapon }
  else { var %item.type core }

  ; Determine the energy cost and see if the player has enough.
  var %base.amount $readini(system.dat, mech, EnergyCostConstant)
  if (%base.amount = $null) { var %base.amount 100 }

  var %mech.maxEnergy $readini($char($1), mech, energyMax)

  if (%item.type = weapon) { 
    var %core.cost $readini($dbfile(items.db), $readini($char($1), mech, EquippedCore), energyCost)
    inc %base.amount  %core.cost
    inc %base.amount $readini($dbfile(weapons.db), $2, energyCost)
    if (%base.amount >= %mech.maxEnergy) { $display.private.message($readini(translation.dat, errors, MechNotEnoughEnergyToEquip)) | halt }
  }
  if (%item.type = core) { 
    var %weapon.cost $readini($dbfile(weapons.db), $readini($char($1), mech, EquippedWeapon), energyCost)
    inc %base.amount %weapon.cost
    inc %base.amount $readini($dbfile(items.db), $2, energyCost)
    if (%base.amount >= %mech.maxEnergy) { $display.private.message($readini(translation.dat, errors, MechNotEnoughEnergyToEquip)) | halt }
  }

  ; Equip the piece.
  if (%item.type = weapon) { writeini $char($1) mech EquippedWeapon $2 }
  if (%item.type = core) { writeini $char($1) mech EquippedCore $2 
    var %augments $readini($dbfile(items.db), $2, Augment)
    if (%augments = $null) { var %augments none }
    writeini $char($1) mech augments %augments
  }

  $display.system.message($readini(translation.dat, system, EquipMechItem), global) 
  halt
}

alias mech.repair {
  $set_chr_name($1)

  if (%battleis = on) {
    set %temp.battle.list $readini($txtfile(battle2.txt), Battle, List)
    if ($istok(%temp.battle.list,$1,46) = $true) {   $check_for_battle($1) }
  }

  ; Check to see if the person owns a mech.
  if ($readini($char($1), mech, HpMax) = $null) {  $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }

  ; Does the mech need repair?
  if ($readini($char($1), mech, HpCurrent) >= $readini($char($1), mech, HpMax)) { $display.private.message($readini(translation.dat, errors, MechDoesNotNeedRepair)) | halt }

  ; check for the repairing item
  if ($2 != $null) { set %item.name $2 
    if ($readini($dbfile(items.db), $2, MechType) != RestoreHP) { unset %item.name }
  } 
  if ($2 = $null) { set %item.name $readini(system.dat, mech, RepairHPItem) }
  if (%item.name = $null) { set %item.name MetalScrap } 
  set %item.amount $readini($char($1), item_amount, %item.name)
  if ((%item.amount <= 0) || (%item.amount = $null)) { $display.private.message($readini(translation.dat, errors, MechNoRepairItem)) | unset %item.amount | unset %item.name | halt }

  ; perform the repair
  set %amount $readini($dbfile(items.db), %item.name, amount)
  if (%amount = $null) { var %amount 100 } 
  var %mech.hp $readini($char($1), mech, HpCurrent) | var %mech.maxhp $readini($char($1), mech, hpMax) 
  inc %mech.hp %amount
  if (%mech.hp > %mech.maxhp) { var %mech.hp %mech.maxhp }
  writeini $char($1) mech HpCurrent %mech.hp
  $display.private.message($readini(translation.dat, system, MechRestoredHP))

  dec %item.amount 1 | writeini $char($1) item_amount %item.name %item.amount
  unset %item.amount | unset %item.name | unset %amount
}

alias mech.fuel {
  $set_chr_name($1)

  if (%battleis = on) {
    set %temp.battle.list $readini($txtfile(battle2.txt), Battle, List)
    if ($istok(%temp.battle.list,$1,46) = $true) {   $check_for_battle($1) }
  }

  ; Check to see if the person owns a mech.
  if ($readini($char($1), mech, HpMax) = $null) {  $display.system.message($readini(translation.dat, errors, DoNotOwnAMech), private) | halt }

  ; Does the mech need energy?
  if ($readini($char($1), mech, EnergyCurrent) >= $readini($char($1), mech, EnergyMax)) { $display.system.message($readini(translation.dat, errors, MechDoesNotNeedEnergy), private) | halt }

  ; check for the fuel/energy item
  if ($2 != $null) { set %item.name $2 
    if ($readini($dbfile(items.db), $2, MechType) != RestoreEnergy) { unset %item.name }
  } 
  if ($2 = $null) { set %item.name $readini(system.dat, mech, RepairEnergyItem) } 
  if (%item.name = $null) { set %item.name E-tank } 
  set %item.amount $readini($char($1), item_amount, %item.name)
  if ((%item.amount <= 0) || (%item.amount = $null)) { $display.private.message($readini(translation.dat, errors, MechNoFuelItem)) | unset %item.amount | unset %item.name | halt }

  ; perform the fueling
  set %amount $readini($dbfile(items.db), %item.name, amount)
  if (%amount = $null) { var %amount 100 } 
  var %mech.energy $readini($char($1), mech, EnergyCurrent) | var %mech.energymax $readini($char($1), mech, EnergyMax) 
  inc %mech.energy %amount
  if (%mech.energy > %mech.energymax) { var %mech.energy %mech.energymax }
  writeini $char($1) mech EnergyCurrent %mech.energy
  $display.private.message($readini(translation.dat, system, MechRestoredEnergy))

  dec %item.amount 1 | writeini $char($1) item_amount %item.name %item.amount
  unset %amount | unset %item.amount | unset %item.name
}

alias mech.activate { 
  if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoBattleCurrently), battle) | halt }
  if ($readini(system.dat, system, AllowMechs) = false) { $display.system.message($readini(translation.dat, errors, MechsNotAllowed), private) | halt }

  if ((no-mech isin %battleconditions) && (no-mechs isin %battleconditions)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt  }

  $set_chr_name($1)
  $check_for_battle($1)

  ; Check to see if the person owns a mech.
  if ($readini($char($1), mech, HpMax) = $null) {  $display.system.message($readini(translation.dat, errors, DoNotOwnAMech), private) | halt }

  ; Is the person boosted or Ignitioned?  Can't use a mech then.
  if ($readini($char($1), status, ignition.on) = on) {  $display.system.message($readini(translation.dat, errors, Can'tDoThatWhileBoosted), private) | halt }
  if ($readini($char($1), status, boosted) = yes) {  $display.system.message($readini(translation.dat, errors, Can'tDoThatWhileBoosted), private) | halt }

  ; Check for charm/confuse
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }

  ; Check to see if we have enough energy to activate the mech
  var %base.energycost $round($calc($mech.baseenergycost($1) / 2),0)
  var %mech.currentenergy $readini($char($1), mech, energyCurrent)

  if (%base.energycost >= %mech.currentenergy) { $display.system.message($readini(translation.dat, errors, MechNotEnoughEnergyToUse),battle) | halt }

  ; Does the mech have any health?
  if ($readini($char($1), mech, hpCurrent) <= 0) { $display.system.message($readini(translation.dat, errors, MechNotEnoughHealthToUse),battle) | halt }

  dec %mech.currentenergy %base.energycost
  writeini $char($1) mech energyCurrent %mech.currentenergy

  ; Activate the mech and multiply the stats.
  set %mech.engineconstant $readini(system.dat, mech, StatMultiplier)
  set %mech.enginelevel $readini($char($1), mech, engineLevel)
  if (%mech.engineconstant = $null) { set %mech.engineconstant 2 }
  if (%mech.enginelevel = $null) { set %mech.enginelevel 1 }

  set %mech.power $calc(%mech.engineconstant * %mech.enginelevel)

  var %str $round($calc($readini($char($1), Battle, Str) * %mech.power),0)
  var %def $round($calc($readini($char($1), Battle, def) * %mech.power),0)
  var %int $round($calc($readini($char($1), Battle, int) * %mech.power),0)
  var %spd $round($calc($readini($char($1), Battle, spd) * %mech.power),0)

  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  var %mech.description $readini($char($1), descriptions, mech)
  if (%mech.description = $null) { var %mech.description $readini(translation.dat, battle, MechSummon) }

  $display.system.message(3 $+ %real.name  $+ %mech.description,battle)
  writeini $char($1) mech InUse true

  unset %mech.power | unset %mech.engineconstant | unset %mech.enginelevel

  var %total.mechuses $readini($char($1), stuff, TimesMechActivated) 
  if (%total.mechuses = $null) { var %total.mechuses 0 }
  inc %total.mechuses 1 
  writeini $char($1) stuff TimesMechActivated %total.mechuses
  $achievement_check($1, IAmIronMan)

  $check_for_double_turn($1)
  halt
}

alias mech.deactivate {
  if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoBattleCurrently), battle) | halt }

  $set_chr_name($1)
  if ($2 = $null) { $check_for_battle($1) }

  ; Is the person in the mech?
  if ($person_in_mech($1) = false) { $display.system.message($readini(translation.dat, errors, NotInAMech), private) | halt }

  ; Deactivate the mech.
  var %mech.engineconstant $readini(system.dat, mech, StatMultiplier)
  var %mech.enginelevel $readini($char($1), mech, engineLevel)
  if (%mech.engineconstant = $null) { var %mech.engineconstant 2 }
  if (%mech.enginelevel = $null) { var %mech.enginelevel 1 }

  set %mech.power $calc(%mech.engineconstant * %mech.enginelevel)

  var %str $round($calc($readini($char($1), Battle, Str) / %mech.power),0)
  var %def $round($calc($readini($char($1), Battle, def) / %mech.power),0)
  var %int $round($calc($readini($char($1), Battle, int) / %mech.power),0)
  var %spd $round($calc($readini($char($1), Battle, spd) / %mech.power),0)

  if (%str <= 5) { var %str 5 }
  if (%def <= 5) { var %def 5 }
  if (%int <= 5) { var %int 5 }
  if (%spd <= 5) { var %spd 5 }

  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  writeini $char($1) mech InUse false

  if ($2 = $null) { $display.system.message($readini(translation.dat, battle, MechDismiss),battle) }

  return
}

alias mech.statmultiplier { 
  var %engine.level $calc($readini(system.dat, mech, StatMultiplier) * $readini($char($1), mech, EngineLevel)) 

  if ($accessory.check($1, IncreaseMechEngineLevel) = true) {
    inc %engine.level %accessory.amount
    unset %accessory.amount
  }
  return %engine.level
}

alias mech.energydrain { 
  ; $1 = person
  ; $2 = melee, tech
  ; $3 = tech name

  if ($2 = melee) { 
    set %mech.weapon $readini($char($1), mech, EquippedWeapon)
    set %energydrain $readini($dbfile(weapons.db), %mech.weapon, energyCost)
    if (%energydrain = $null) { var %energydrain 100 }
  }
  if ($2 = tech) {  
    set %energydrain $readini($dbfile(techniques.db), $3, energyCost)
    if (%energydrain = $null) { var %energydrain 100 }
  }

  var %current.energylevel $readini($char($1), mech, energyCurrent)
  dec %current.energylevel %energydrain
  if (%current.energylevel < 0) { var %current.energylevel 0 }
  writeini $char($1) mech energyCurrent %current.energylevel

  unset %energydrain | unset %mech.weapon
}

alias mech.baseenergycost {
  var %base.amount $readini(system.dat, mech, EnergyCostConstant)
  if (%base.amount = $null) { var %base.amount 100 }
  var %mech.weaponenergy $readini($dbfile(weapons.db), $readini($char($1), mech, EquippedWeapon), energyCost)
  var %mech.corecost $readini($dbfile(items.db), $readini($char($1), mech, EquippedCore), energyCost)

  if (%mech.weaponenergy = $null) { var %mech.weaponenergy 0 }
  if (%mech.corecost = $null) { var %mech.corecost 0 }

  inc %base.amount %mech.weaponenergy
  inc %base.amount %mech.corecost 

  return %base.amount
}

alias mech.add {
  writeini $char($1) item_amount BasicMechCore 1
  writeini $char($1) item_amount BasicMechGun 1
  writeini $char($1) mech name Basic Mech
  writeini $char($1) mech inUse false
  writeini $char($1) mech EngineLevel 1
  writeini $char($1) mech HpMax 1000
  writeini $char($1) mech HpCurrent 1000
  writeini $char($1) mech EnergyMax 500
  writeini $char($1) mech EnergyCurrent 500
  writeini $char($1) mech EquippedCore BasicMechCore
  writeini $char($1) mech EquippedWeapon BasicMechGun
  writeini $char($1) mech Augments $readini($dbfile(items.db), BasicMechCore, augment)
}

alias mech.remove {
  remini $char($1) mech
  remini $char($1) item_amount BaiscMechGun
  remini $char($1) item_amount BasicMechCore
}
