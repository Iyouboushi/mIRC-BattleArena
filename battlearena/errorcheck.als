; A Battle Arena error checking script
; version 1.4.1 (Sunday 22 February 2015)
; by Andrio Celos
;
; Changelog:
;   Version 1.4.1:
;     Updated for Battle Arena 3.0 beta 02/21/15.
;     Added some error handlers.
;   Version 1.4:
;     Most commands in this script can no longer be used as a function by default.
;     Added checks for weapons.
;     Added /check everything. This may take about a minute to run.
;     Updated for Battle Arena 3.0 beta 02/11/15.
;     Changed a few messages.
;   Version 1.3:
;     Updated for Battle Arena 2.6 beta 01/31/15.
;   Version 1.2:
;     Updated for Battle Arena 2.6 beta 10/07/14.
;     Expressions in character files containing references to $char or battle txt files are no longer checked fully.
;     Removed messages about major issues, as I don't know of any that get that rating.
;     Other message changes.

check {
  ; The main command for the script. To prevent abuse, this alias cannot be used as a function.
  ;   $1 : What to check: techs, items, monsters, weapons or everything.
  ;   $2 : Set to 'ignoreversion' to skip the Arena version check.

  if ($isid) return
  if (($version < 7) && (!$isalias(noop))) {
    ; Older versions of mIRC lack the noop command, which this script uses. If we're running on such a platform, write an alias to emulate /noop.
    echo 12 Writing alias noop to $nopath($script) $+ .
    write " $+ $script $+ " noop return
    .timer -do 1 0 reload -a " $+ $script $+ "
    .timer -do 1 1 check $1-
    halt
  }
  if (($2 != ignoreversion) && ($3 != ignoreversion)) {
    ; Do a quick check on the Arena version.
    if ($regex($battle.version(), ^(\d\.\d)$) > 0) {
      if ($regml(1) > 3.0) { echo 4 This script appears to be out of date. Use /check $1 ignoreversion to ignore this. | halt }
      else if ($regml(1) < 3.0) set -u0 %old $true
    }
    else if ($regex($battle.version(), ^(\d\.\d)beta_(\d\d)(\d\d)(\d\d)$) > 0) {
      if ($regml(1) > 3.0) { echo 4 This script appears to be out of date. Use /check $1 ignoreversion to ignore this. | halt }
      else if ($regml(1) < 3.0) set -u0 %old $true
      else if ($regml(4) > 15) { echo 4 This script appears to be out of date. Use /check $1 ignoreversion to ignore this. | halt }
      else if ($regml(4) < 15) set -u0 %old $true
      else if ($regml(2) > 3) { echo 4 This script appears to be out of date. Use /check $1 ignoreversion to ignore this. | halt }
      else if ($regml(2) < 2) set -u0 %old $true
      else if (($regml(2) == 2) && ($regml(3) < 21)) set -u0 %old $true
    }
    else {
      echo 4 Could not parse the Arena version ($battle.version).
    }
  }

  if ($0 < 1) { echo 2 Usage: /check category [subcategory] [ignoreversion] | echo 2 The following can be checked: techs, items, NPCs, weapons, all. Subcategories for NPCs are monsters, allies and bosses. | halt }

  var %old_title = $titlebar
  set %issues_total 0
  set %issues_major 0
  if ($window(@issues) != $null) aline @issues ----------------

  if (($1 == all) || ($1 == everything)) {
    window @issues
    echo 12 Checking all known entries. This may take a minute or so.
    aline @issues Checking all known entries. This may take a minute or so.
    check_techs new_chr DoublePunch new_chr
    set %issues_total 0 | set %issues_major 0
    check_items
    set %issues_total 0 | set %issues_major 0
    check_monsters
    set %issues_total 0 | set %issues_major 0
    check_weapons
  }
  else if (($1 == techs) || ($1 == techniques)) check_techs new_chr DoublePunch new_chr
  ; Those parameters are there in case of techniques like Asura Strike that need to reference a character.
  else if (($1 == items)) check_items
  else if (($1 == monsters) || ($1 == npcs)) {
    if (($2 == monsters) || ($2 == mons)) set -u0 %subcategory monsters
    else if (($2 == allies) || ($2 == npcs)) set -u0 %subcategory allies
    else if ($2 == bosses) set -u0 %subcategory bosses
    else if (($2 != null) && ($2 != ignoreversion)) { echo 2 ' $+ $2 $+ ' isn't a known subcategory. Use monsters, allies or bosses. | halt }
    check_monsters
  }
  else if (($1 == weapons)) check_weapons
  else { echo 2 Usage: /check category [subcategory] [ignoreversion] | echo 2 The following can be checked: techs, items, NPCs, weapons, all. Subcategories for NPCs are monsters, allies and bosses. | halt }

  titlebar %old_title
}

check_techs {
  ; Checks techniques
  ;   No parameters
  if ($isid) return

  window @issues

  set %total_techniques $ini($dbfile(techniques.db), 0)
  var %current_technique = 0

  while (%current_technique < %total_techniques) {
    inc %current_technique

    var %technique_name = $ini($dbfile(techniques.db), %current_technique)
    if (%technique_name == techs) continue
    if (%technique_name == ExampleTech) continue
    titlebar Battle Arena $battle.version — Checking technique %current_technique / %total_techniques : %technique_name ...

    ; Spaces and = can't be in technique names.
    if (($chr(32) isin %technique_name) || (= isin %technique_name)) log_issue Moderate Technique %technique_name has an invalid name: technique will be unusable.

    ; Either a TP or mech energy cost must be specified.
    var %tp.needed = $readini($dbfile(techniques.db), p, %technique_name, TP)
    var %energydrain = $readini($dbfile(techniques.db), $2, energyCost)
    if (%tp.needed != $null) {
      if (%tp.needed !isnum) log_issue Moderate Technique %technique_name $+ 's TP cost ( $+ %tp.needed $+ ) is not a number: technique will cost 0 TP.
    }
    if (%energydrain != $null) {
      if (%energydrain !isnum) log_issue Minor Technique %technique_name $+ 's energy cost ( $+ %tp.needed $+ ) is not a number: technique will cost 100 energy.
    }
    if ((%tp.needed == $null) && (%energydrain == $null)) log_issue Moderate Technique %technique_name has no TP or energy cost; the technique may be unusable.

    var %tech.type = $readini($dbfile(techniques.db), %technique_name, Type)

    if (%tech.type == boost) { 
      ; Check that the base power is a number.
      var %tech.base = $readini($dbfile(techniques.db), p, %technique_name, BasePower)
      if (%tech.base !isnum) log_issue Moderate Technique %technique_name $+ 's power is not a number: power will be zeroed.
      continue
    } 

    if (%tech.type == finalgetsuga) {
      ; Check that the base power is a number.
      var %tech.base = $readini($dbfile(techniques.db), p, %technique_name, BasePower)
      if (%tech.base !isnum) log_issue Moderate Technique %technique_name $+ 's power is not a number: power will be zeroed.
      continue
    } 

    if (%tech.type == Buff) {
      ; Not really much to check for here. We either have a resist buff, or a status effect.
      var %buff.type = $readini($dbfile(techniques.db), %technique_name, status)
      if (%buff.type == en-spell) {
        var %enspell.element = $readini($dbfile(techniques.db), %technique_name, element)
        if ((. isin %enspell.element) || (%enspell.element !isin Earth.Fire.Wind.Water.Ice.Lightning.Light.Dark.HandToHand.Whip.Sword.Gun.Rifle.Katana.Wand.Stave.Spear.Scythe.Glyph.GreatSword.Bow)) $&
          log_issue Moderate Technique %technique_name uses an invalid modifier: technique will have no effect.
      }
      else {
        var %modifier.type = $readini($dbfile(techniques.db), %technique_name, modifier)
        if (%modifier.type != $null) {
          if ((. isin %modifier.type) || (%modifier.type !isin Earth.Fire.Wind.Water.Ice.Lightning.Light.Dark.HandToHand.Whip.Sword.Gun.Rifle.Katana.Wand.Stave.Spear.Scythe.Glyph.GreatSword.Bow)) $&
            log_issue Moderate Technique %technique_name uses an invalid modifier: technique will have no effect.
        }
      }
      continue
    }

    if (%tech.type == ClearStatusPositive) continue
    if (%tech.type == ClearStatusNegative) continue

    if (%tech.type == Heal) { 
      goto damage_checks
    }

    if (%tech.type == Heal-AoE) { 
      goto damage_checks
    }

    if (%tech.type = single || %tech.type = status) {  
      ; Check the absorb setting.
      var %technique_absorb = $readini($dbfile(techniques.db), %technique_name, Absorb)
      if ((%technique_absorb != $null) && (%technique_absorb != yes) && (%technique_absorb != no)) log_issue Minor Technique %technique_name $+ 's absorb field is specified, but not as 'yes': field will be ignored.
      goto damage_checks
    }

    if (%tech.type == Suicide) { 
      goto damage_checks
    }

    if (%tech.type == Suicide-AoE) { 
      goto damage_checks
    } 

    if (%tech.type == StealPower) { 
      ; Check that the base power is a number.
      goto damage_checks
    }

    if (%tech.type == AoE) { 
      ; Check the absorb setting.
      var %technique_absorb = $readini($dbfile(techniques.db), %technique_name, Absorb)
      if ((%technique_absorb != $null) && (%technique_absorb != yes) && (%technique_absorb != no)) log_issue Minor Technique %technique_name $+ 's absorb field is specified, but not as 'yes': field will be ignored.
      goto damage_checks
    }

    log_issue Moderate Technique %technique_name has an unrecognised type ( $+ %tech.type $+ ).
    continue

    :damage_checks
    ; The base stat needed must actually exist.
    var %base.stat.needed = $readini($dbfile(techniques.db), %technique_name, stat)
    if (%base.stat.needed == $null) { var %base.stat.needed int }
    if ((. isin %base.stat.needed) || (%base.stat.needed !isin STR.DEF.INT.SPD.HP.TP.IgnitionGauge)) $&
      log_issue Moderate Technique %technique_name uses an invalid attribute: technique will do very little damage.

    ; Check that the base power is a number.
    var %tech.base = $readini($dbfile(techniques.db), p, %technique_name, BasePower)
    if (%tech.base !isnum) log_issue Moderate Technique %technique_name $+ 's power is not a number: power will be zeroed.

    ; Check the magic setting.
    var %technique_magic = $readini($dbfile(techniques.db), %technique_name, magic)
    if ((%technique_magic != $null) && (%technique_magic != yes) && (%technique_magic != no)) log_issue Minor Technique %technique_name $+ 's magic field is specified, but not as 'yes': field will be ignored.

    ; Check the element.
    var %tech.elements = $readini($dbfile(techniques.db), %technique_name, element)
    if ((%tech.elements != $null) && (%tech.elements != none) && (%tech.elements != no)) {
      var %count = $numtok(%tech.elements, 46) 

      if (%count >= 1) {
        var %i = 1
        while (%i <= %count) { 
          var %element = $gettok(%tech.elements, %i, 46)
          if (%element !isin fire.water.ice.lightning.wind.earth.light.dark) $&
            log_issue Minor Technique %technique_name uses an unknown element ( $+ %element $+ ): it will be unaffected by weather.
          inc %i
        }  
      }
    }

    ; Check that the ignore defense percent is a number and not a decimal.
    var %ignore.defense.percent = $readini($dbfile(techniques.db), %technique_name, IgnoreDefense)
    if ((%ignore.defense.percent) && (%ignore.defense.percent !isnum)) log_issue Moderate Technique %technique_name $+ 's ignore defense is not a number: it will be zeroed.
    else if (%ignore.defense.percent > 0 && %ignore.defense.percent < 1) log_issue Minor Technique %technique_name $+ 's ignore defense is a decimal where a percentage (0-100) is expected.

    ; Check that the status types are valid.
    var %status.type.list = $readini($dbfile(techniques.db), %technique_name, StatusType)
    if (%status.type.list != $null) check_statuseffects %status.type.list Technique  $+ %technique_name $+ 
    var %selfstatus.type.list = $readini($dbfile(techniques.db), %technique_name, SelfStatus)
    if (%selfstatus.type.list != $null) check_statuseffects %selfstatus.type.list Technique  $+ %technique_name $+ 's SelfStatus field

    ; Check the number of hits.
    var %tech.howmany.hits = $readini($dbfile(techniques.db), %technique_name, hits)
    if ((%tech.howmany.hits) && (%tech.howmany.hits !isnum)) /log_issue Minor Technique %technique_name $+ 's number of hits is not a number: it will be zeroed.

    continue
    :error
    log_issue Critical Checking technique %technique_name failed: $error
    reseterror
  }
  if (%issues_total == 0) echo -a 12Checked $calc(%current_technique - 1) techniques and found no issues. Yay!
  else echo -a 12Checked $calc(%current_technique - 1) techniques and found %issues_total  $+ $iif(%issues_total = 1, issue, issues) $+ .
}

check_items {
  ; Checks items
  ;    No parameters
  if ($isid) return

  window @issues
  titlebar Battle Arena $battle.version — Checking item lists...

  ; Read in the lists at the top of the database, and make sure there are no broken references there.
  check_db_item_lists Gems gem
  check_db_item_lists Keys key
  check_db_item_lists Runes rune

  ; Read in the item list files, and make sure there are no broken references there.
  check_item_lists items_accessories.lst accessory
  check_item_lists items_battle.lst status.damage.snatch
  check_item_lists items_consumable.lst consume
  check_item_lists items_food.lst food
  check_item_lists items_gems.lst gem
  check_item_lists items_healing.lst heal.tp.revive.ignitiongauge.curestatus
  check_item_lists items_misc.lst misc.trade
  check_item_lists items_portal.lst portal
  check_item_lists items_random.lst random
  check_item_lists items_reset.lst shopreset
  check_item_lists items_summons.lst summon

  ; Now go through the database checking for errors in each item.
  set %total_items $ini($dbfile(items.db), 0)
  var %current_item = 0
  while (%current_item < %total_items) {
    inc %current_item

    var %item_name = $ini($dbfile(items.db), %current_item)
    if (%item_name == Items) continue
    titlebar Battle Arena $battle.version � Checking item %current_item / %total_items : %item_name ...

    check_item new_chr %item_name on new_chr
  }

  if (%issues_total == 0) echo -a 12Checked $calc(%current_item - 1) items and found no issues. Yay!
  else echo -a 12Checked $calc(%current_item - 1) items and found %issues_total  $+ $iif(%issues_total = 1, issue, issues) $+ .
}
check_db_item_lists {
  ; Ensures that all of the items in an items.db list are the correct type.
  ;  $1 : The header of the list in items.db
  ;  $2 : The type of item that is considered valid.
  if ($isid) return

  var %db_list = $readini($dbfile(items.db), Items, $1)
  set %total_items $numtok(%db_list, 46)
  var %current_item = 0
  while (%current_item < %total_items) {
    inc %current_item

    var %item_name = $gettok(%db_list, %current_item, 46)
    var %item_type = $readini($dbfile(items.db), %item_name, Type)

    if (%item_type) {
      if (%item_type != $2) log_issue Moderate Item %item_name is listed under ' $+ $1 $+ ' but isn't a $2 $+ .
    }
    else log_issue Moderate Missing item %item_name is listed under ' $+ $1 $+ '.
  }
}
check_item_lists {
  ; Checks an item .lst file to ensure all items listed are of the correct type.
  ;  $1 : The filename to check, relative to the /lsts folder.
  ;  $2 : One of more types of items that are considered valid. Can be a single type or a period-delimited list.
  if ($isid) return

  var %total_items = $lines($lstfile($1))
  var %current_item = 0

  while (%current_item < %total_items) {
    inc %current_item

    set %item_name $read($lstfile($1), %current_item)
    var %item_type = $readini($dbfile(items.db), %item_name, Type)

    if (%item_type) {
      if ((. isin %item_type) || (%item_type !isin $2)) log_issue Moderate Item %item_name is listed in $1 but isn't a $+ $iif($left($2, 1) isin aeiou,n,$null) $2 $+ .
    }
    else /log_issue Moderate Missing item %item_name is listed in $1 $+ .

  } 
}
check_item {
  ; Checks an individual item definition for errors.
  ;   $1 : A character name. new_chr is recommended as all bots should have it.
  ;   $2 : The item to check.
  ;   $3 : 'on'
  ;   $4 : A character name. new_chr is recommended as all bots should have it.
  if ($isid) return

  var %item_type = $readini($dbfile(items.db), $2, Type)

  ; Check for the exclusive tag.
  var %exclusive = $readini($dbfile(items.db), $2, exclusive)
  if ((%exclusive != $null) && (%exclusive != yes) && (%exclusive != no)) /log_issue Minor Item %item_name $+ 's exclusive field is specified, but not as 'yes': field will be ignored.

  if (%item_type == Food) {
    ; Food items must use a valid attribute and amount. The amount MAY be negative.
    var %food.type = $readini($dbfile(items.db), $2, target)
    var %food.bonus = $readini($dbfile(items.db), $2, amount)

    if ((. isin %food.type) || (%food.type !isin HP.TP.STR.DEF.INT.SPD.IgnitionGauge.Style.RedOrbs.BlackOrbs)) $&
      log_issue Moderate Item $2 $+ 's attribute is invalid; it will have no effect. Use one of: HP, TP, STR, DEF, INT, SPD, IgnitionGauge, Style, RedOrbs, BlackOrbs.
    if (%food.bonus !isnum) log_issue Moderate Item $2 $+ 's bonus amount is not a number; it will have no effect.

    return
  }

  if (%item_type == Portal) {
    ; Portal items must refer to existing monsters.
    var %monster.to.spawn = $readini($dbfile(items.db), $2, Monster)
    var %battlefield = $readini($dbfile(items.db), $2, Battlefield)
    var %weather = $readini($dbfile(items.db), $2, weather)
    var %allied.notes = $readini($dbfile(items.db), $2, alliednotes)

    var %value = 1 | var %number.of.monsters $numtok(%monster.to.spawn,46)
    while (%value <= %number.of.monsters) {
      set %current.monster.to.spawn $gettok(%monster.to.spawn,%value,46)

      var %isboss = $isfile($boss(%current.monster.to.spawn))
      var %ismonster = $isfile($mon(%current.monster.to.spawn))

      if ((%isboss != $true) && (%ismonster != $true)) log_issue Moderate Item $2 $+  references missing monster %current.monster.to.spawn  $+ ; it will be skipped.
      inc %value
    }

    ; Portal items must use an existing battlefield.
    var %battlefield = $readini($dbfile(items.db), $2, Battlefield)
    if ($ini($dbfile(battlefields.db), %battlefield) = $null) log_issue Moderate Item $2 $+  references missing battlefield %battlefield  $+ .

    return
  }

  if (%item_type == Key) {
    var %unlocks = $readini($dbfile(items.db), $2, Unlocks)
    ; Keys must use a valid chest colour.
    if ((%unlocks != Red) && (!$isfile($lstfile(chest_ $+ %unlocks $+ .lst)))) $&
      log_issue Moderate Item $2 $+  references a non-existent colour of treasure chest; it will be useless.
    return
  }

  if (%item_type == Consume) {
    ; Skill items should reference an existing skill.
    var %skill = $readini($dbfile(items.db), $2, Skill)
    if ((!$read($lstfile(skills_active.lst), w, %skill)) && (!$read($lstfile(skills_active2.lst), w, %skill))) $&
      log_issue Minor Item $2 $+  references a non-existent skill; its !view-info entry will be invalid.
    return
  }

  if ((%item_type == Gem) || (%item_type == Misc) || (%item_type == Trade)) {
    return
  }

  if (%item_type == Rune) {
    var %augment.name = $readini($dbfile(items.db), $2, augment)
    if (!%augment.name) log_issue Moderate Item $2  is missing an augment.
    return
  }

  if (%item_type == Accessory) {
    ; Accessories must be of a valid type.
    var %i = 1
    var %types = $readini($dbfile(items.db), $2, accessoryType)
    var %total_types = $numtok(%types, 46)
    while (%i <= %total_types) {
      var %type = $gettok(%types, %i, 46)
      if (%type isin IncreaseMeleeAddPoison.IncreaseH2HDamage.IncreaseSpearDamage.IncreaseSwordDamage.IncreaseGreatSwordDamage.IncreaseWhipDamage.IncreaseGunDamage.IncreaseBowDamage.IncreaseGlyphDamage.IncreaseKatanaDamage.IncreaseWandDamage.IncreaseStaffDamage.IncreaseScytheDamage.IncreaseAxeDamage.IncreaseDaggerDamage.IncreaseHealing.ElementalDefense.IncreaseRedOrbs.IncreaseSpellDamage.IncreaseMeleeDamage.IncreaseMagic, %i, 46) {
        var %amount = $readini($dbfile(items.db), $2, %type $+ .amount)
        if (%amount = $null) log_issue Moderate Accessory $2 has no %type amount; it will have no effect.
        else if (%amount !isnum) log_issue Moderate Accessory $2 $+ 's %type amount is not a number; it will have no effect.
        else if (%amount >= 10) log_issue Moderate Accessory $2 $+ 's %type amount is very high. It should be a fractional factor instead of a percentage.
      }
      else if (%type isin IncreaseCriticalHits.BlockAllStatus.IncreaseSteal.IncreaseTreasureOdds.IncreaseMimicOdds.EnhanceBlocking, %i, 46) {
        var %amount = $readini($dbfile(items.db), $2, %type $+ .amount)
        if (%amount = $null) log_issue Moderate Accessory $2 has no %type amount; it will have no effect.
        else if (%amount !isnum) log_issue Moderate Accessory $2 $+ 's %type amount is not a number; it will have no effect.
        else if ((%amount > -0.5) && (%amount < 0.5) && (%amount != 0)) log_issue Moderate Accessory $2 $+ 's %type amount is very low. It should be a percentage instead of a fraction.
      }
      else if (%type isin IncreaseMechEngineLevel.ReduceShopLevel, %i, 46) {
        var %amount = $readini($dbfile(items.db), $2, %type $+ .amount)
        if (%amount = $null) log_issue Moderate Accessory $2 has no %type amount; it will have no effect.
        else if (%amount !isnum) log_issue Moderate Accessory $2 $+ 's %type amount is not a number; it will have no effect.
        else if ((%amount > -0.5) && (%amount < 0.5) && (%amount != 0)) log_issue Moderate Accessory $2 $+ 's %type amount is very low. It should be a number to add directly instead of a fraction.
      }
      else if (%type !isin CurseAddDrain.Mug.Stylish.IgnoreQuicksilver) $&
        log_issue Moderate Accessory $2 has unrecognised type %type $+ .
      inc %i
    }
    return
  }

  if (%item_type == Random) {
    return
  }

  if (%item_type == ShopReset) {
    ; Discount items must define a valid amount.
    var %shop.reset.amount = $readini($dbfile(items.db), $2, amount)
    if (%shop.reset.amount !isnum) log_issue Moderate Item $2 $+ 's discount amount is not a number; it will have no effect.
    return
  }

  if (%item_type == Damage) {
    var %fullbring_item.base = $readini($dbfile(items.db), $2, FullbringAmount)
    var %item.base = $readini($dbfile(items.db), $2, Amount)
    if (%item.base !isnum) log_issue Moderate Item $2 $+ 's damage amount is not a number; its power will be zeroed.

    var %current.element = $readini($dbfile(items.db), $2, element)
    if ((%current.element) && (. isin %current.element || %current.element !isin none.fire.water.ice.lightning.wind.earth.light.dark)) $&
      log_issue Minor Item $2 uses an unknown element ( $+ %tech.element $+ ).

    return
  }

  if (%item_type == Snatch) {
    return
  }

  if (%item_type == Heal) {
    ; Healing items must define a valid amount.
    var %item.base = $readini($dbfile(items.db), $2, Amount)
    if (%item.base !isnum) log_issue Moderate Item $2 $+ 's healing amount is not a number; its power will be zeroed.
    return
  }

  if (%item_type == CureStatus) {
    return
  }

  if (%item_type == TP) {
    ; TP items must define a valid amount.
    var %tp.amount = $readini($dbfile(items.db), $2, amount)
    if (%tp.amount !isnum) log_issue Moderate Item $2 $+ 's TP amount is not a number; it will have no effect.
    return
  }

  if (%item_type == IgnitionGauge) {
    ; Ignition charge items must define a valid amount.
    var %IG.amount = $readini($dbfile(items.db), $2, amount)
    if (%IG.amount !isnum) log_issue Moderate Item $2 $+ 's charge amount is not a number; it will have no effect.
    return
  }

  if (%item_type == Status) {
    var %status.type.list = $readini($dbfile(items.db), $2, StatusType) 
    if (%status.type.list != $null) check_statuseffects %status.type.list Item  $+ $2 $+ 

    var %fullbring_item.base = $readini($dbfile(items.db), $2, FullbringAmount)
    var %item.base = $readini($dbfile(items.db), $2, Amount)
    if (%item.base !isnum) /log_issue Moderate Item $2 $+ 's damage amount is not a number; its power will be zeroed.

    var %current.element = $readini($dbfile(items.db), $2, element)
    if ((%current.element) && ((. isin %current.element) || (%current.element !isin none.fire.water.ice.lightning.wind.earth.light.dark))) $&
      log_issue Minor Item $2 uses an unknown element ( $+ %tech.element $+ ).

    return
  }

  if (%item_type == Revive) {
    return
  }

  if (%item_type == Summon) {
    ; Summon items must define an existing summon.
    var %summon.name = $readini($dbfile(items.db), $2, summon)
    if (!$isfile($summon(%summon.name))) log_issue Moderate Item $2 $+  references missing summon %summon.name $+ ; it will have no effect.
    return
  }

  if (%item_type == MechCore) {
    ; Mech cores must define an energy cost and augments.
    var %energy.cost = $readini($dbfile(items.db), $2, energyCost)
    if (%energy.cost = $null) log_issue Moderate Item $2 $+  has no energy cost; it will cost 100 energy.
    else if (%energy.cost !isnum) log_issue Moderate Item $2 $+ 's energy cost is not a number.

    ;var %augments $readini($dbfile(items.db), $2, augment)
    ;var %total_augments $numtok(%augments, 46)
    ;var %augment 1
    ;while (%augment <= %total_augments) {
    ;  var %current_augment $gettok(%augments, %augment, 46)
    ;}
    return
  }

  if (%item_type == Instrument) {
    return
  }

  if (%item_type == Special) {
    var %special_type = $readini($dbfile(items.db), $2, SpecialType)

    if (%special_type == GainWeapon) {
      var %weapon =  $readini($dbfile(items.db), $2, Weapon)
      if (!$ini($dbfile(weapons.db), %weapon)) /log_issue Moderate Item $2 references missing weapon ( $+ %weapon $+ ).
      return
    }

    if (%special_type == GainSong) {
      var %song =  $readini($dbfile(items.db), $2, Song)
      if (!$ini($dbfile(songs.db), %song)) /log_issue Moderate Item $2 references missing song ( $+ %song $+ ).
      return
    }

    log_issue Moderate Item $2 $+  has an unrecognised special type ( $+ %special_type $+ ). If it's a mod, this script will need to be edited. Otherwise, the item will have no effect.
    return
  }

  if (%item_type == Trust) {
    ; The Ally must actually exist.
    var %trust.npc = $readini($dbfile(items.db), $2, NPC)
    if (!$isfile($npc(%trust.npc))) log_issue Moderate Item $2 $+  references missing Ally %trust.npc $+ ; it cannot be used.
    return
  }

  log_issue Moderate Item $2 $+  has an unrecognised type ( $+ %item_type $+ ). If it's a mod, this script will need to be edited. Otherwise, the item will have no effect.

  return
  :error
  log_issue Critical Checking item $2 failed: $error
  reseterror
}

check_monsters {
  ; Checks monsters (including bosses and NPCs)
  ;    No parameters
  if ($isid) return

  window @issues
  set %monster_count 0

  if ((%subcategory == $null) || (%subcategory == monsters)) {
    set -u0 %category Monster
    noop $findfile($mon_path, *, 0, 0, check_monster_file $1-)
  }
  if ((%subcategory == $null) || (%subcategory == bosses)) {
    set -u0 %category Boss
    noop $findfile($boss_path, *, 0, 0, check_monster_file $1-)
  }
  if ((%subcategory == $null) || (%subcategory == allies)) {
    set -u0 %category NPC
    noop $findfile($npc_path, *, 0, 0, check_monster_file $1-)
  }

  ; Make sure that the orb fountain is present.
  if (!$isfile($mon(orb_fountain))) log_issue Critical The Red Orb Fountain is missing! ( $+ $mon(orb_fountain) $+ )

  if (%issues_total == 0) echo -a 12Checked %monster_count characters and found no issues. Yay!
  else echo -a 12Checked %monster_count characters and found %issues_total  $+ $iif(%issues_total = 1, issue, issues) $+ .
}
check_monster_file {
  ; Ensures that all files in the /monsters and /bosses folders have a .char extension.
  ;   $1-: The file path to check, relative to the working directory.
  if ($isid) return

  inc %monster_count
  set -u0 %file_path $1-
  var %file = $nopath($1-)
  if (%file == Note.txt) return
  titlebar Battle Arena $battle.version — Checking $lower(%category) %file ...

  ; Check the file extension.
  noop $regex(%file, ^.*\.([^.]+)$)
  if ($regml(1) != char) { /log_issue Minor Found file %file in the monsters folder without a .char extension; it will be ignored. | return }

  var %name = $remove(%file, .char)
  if ((%name == new_mon) || (%name == new_boss) || (%name == $null)) return

  check_monster %name
}
check_monster {
  ; Checks a monster's character file for errors.
  ;   $1 : The monster's name.
  ;   %file.path : The path to their character file.
  if ($isid) return

  ; Check the monster's attributes.
  set %hp $readini(%file_path, BaseStats, HP)
  noop $monster_get_hp($1, $null, 1)
  set %tp $readini(%file_path, BaseStats, TP)
  if (!$validate_expression($readini(%file_path, n, BaseStats, TP))) set %tp 0
  set %str $readini(%file_path, BaseStats, Str)
  set %def $readini(%file_path, BaseStats, Def)
  set %int $readini(%file_path, BaseStats, Int)
  set %spd $readini(%file_path, BaseStats, Spd)
  noop $monster_get_attributes($1, 1, $null)

  if (%hp !isnum) log_issue Moderate %category $+  $1 $+ 's base HP is not a number; their HP will be zeroed.
  if (%tp !isnum) log_issue $iif($readini(%file_path, info, BattleStats) = ignore, Moderate, Minor) %category $+  $1 $+ 's base TP is not a number; their TP will be zeroed.
  if (%str !isnum) log_issue Moderate %category $+  $1 $+ 's base STR is not a number; their STR will be zeroed.
  if (%def !isnum) log_issue Moderate %category $+  $1 $+ 's base DEF is not a number; their DEF will be zeroed.
  if (%int !isnum) log_issue Moderate %category $+  $1 $+ 's base INT is not a number; their INT will be zeroed.
  if (%spd !isnum) log_issue Moderate %category $+  $1 $+ 's base SPD is not a number; their SPD will be zeroed.

  unset %hp %tp %str %def %int %spd

  if ((%category != NPC) && ($readini(%file_path, Info, Flag) != monster)) log_issue Moderate %category $+  $1 $+ 's info flag is not set as 'monster'.
  if ((%category == NPC) && ($readini(%file_path, Info, Flag) != npc)) log_issue Moderate %category $+  $1 $+ 's info flag is not set as 'npc'.

  if (($readini(%file_path, Info, Streak) != $null) && ($readini(%file_path, Info, Streak) !isnum)) log_issue Moderate %category $+  $1 $+ 's Streak field is not a number; the value will be zeroed.
  if (($readini(%file_path, Info, StreakMax) != $null) && ($readini(%file_path, Info, StreakMax) !isnum)) log_issue Moderate %category $+  $1 $+ 's StreakMax field is not a number; the value will be zeroed.
  if (($readini(%file_path, Info, BossLevel) != $null) && ($readini(%file_path, Info, BossLevel) !isnum)) log_issue Moderate %category $+  $1 $+ 's BossLevel field is not a number; the value will be zeroed.
  if ($readini(%file_path, Info, Month) != $null) {
    if ($readini(%file_path, Info, Month) !isnum) log_issue Moderate %category $+  $1 $+ 's Month field is not a number.
    else if ($readini(%file_path, Info, Month) < 1 || $readini(%file_path, Info, Month) > 12) log_issue Moderate %category $+  $1 $+ 's Month field is not within the valid range (01-12).
  }
  if ($readini(%file_path, Info, AI-Type) != $null) {
    if ((. isin $readini(%file_path, Info, AI-Type)) || ($readini(%file_path, Info, AI-Type) !isin Berserker.Defender)) log_issue Minor %category $+  $1 $+ 's AI-Type field is invalid. Use one of: Berserker, Defender
  }
  if (($readini(%file_path, Info, OrbBonus) != $null) && ($readini(%file_path, Info, OrbBonus) !isin yes.no.false)) log_issue Minor %category $+  $1 $+ 's OrbBonus field is specified, but not as 'yes'; the field will be ignored.
  if (($readini(%file_path, Info, CanFlee) != $null) && ($readini(%file_path, Info, CanFlee) !isin true.no.false)) log_issue Minor %category $+  $1 $+ 's CanFlee field is specified, but not as 'yes'; it will not flee.
  if (($readini(%file_path, Info, MetalDefense) != $null) && ($readini(%file_path, Info, MetalDefense) !isin true.no.false)) log_issue Moderate %category $+  $1 $+ 's MetalDefense field is specified, but not as 'true'; it will not take effect.

  ; Check the biome.
  var %biome.list = $readini(%file_path, Info, Biome)
  if (%biome.list != $null) {
    var %number.of.biomes = $numtok(%biome.list, 46) 
    var %i = 1
    while (%i <= %number.of.statuseffects) { 
      var %current.biome = $gettok(%biome.list, %i, 46)
      if (!$read($lstfile(battlefields.lst), w, %current.biome)) var %bad_biomes $addtok(%bad_biomes, %current.biome, 46)
      inc %i
    }  
  }
  if (%bad_biomes) log_issue Moderate %category $+  $1 $+ 's Biome list includes unlisted battlefield(s) $replace(%bad_biomes, ., $chr(44) $+ $chr(32)) $+ .

  ; Check the weapons.
  if ($readini(%file_path, n, weapons, $readini(%file_path, weapons, equipped)) = $null) log_issue Minor %category $+  $1 is missing $readini(%file_path, Info, Gender) equipped weapon ( $+ $readini(%file_path, weapons, equipped) $+ ); its power will be zeroed.
  if (($readini(%file_path, weapons, equippedleft) != $null) && ($readini(%file_path, n, weapons, $readini(%file_path, weapons, equippedleft)) = $null)) {
    if ($readini($dbfile(weapons.db), $readini(%file_path, weapons, equippedleft), type) != shield) log_issue Minor %category $+  $1 is missing $readini(%file_path, Info, Gender) equipped weapon ( $+ $readini(%file_path, weapons, equippedleft) $+ ); its power will be zeroed.
  }
  var %ai_type = $readini(%file_path, info, ai_type) 

  var %i = 0
  var %count = $ini(%file_path, weapons, 0)
  while (%i < %count) {
    inc %i
    var %weapon = $ini(%file_path, weapons, %i)
    if (;* iswm %weapon) continue
    if ((. !isin %weapon) && (%weapon isin Equipped.EquippedLeft.Weakness.Strong)) continue
    if ((%weapon == none) && (%ai_type = defender)) continue
    if (!$ini($dbfile(weapons.db), %weapon)) /log_issue Minor %category $+  $1 uses missing weapon ( $+ %weapon $+ ).
    if (!$validate_expression($readini(%file_path, n, weapons, %weapon))) continue
    if ($readini(%file_path, weapons, %weapon) !isnum) /log_issue Minor %category $+  $1 $+ 's weapon level for %weapon is not a number; it will be zeroed.
  }

  ; Check the skills.
  var %i = 0
  var %count = $ini(%file_path, skills, 0)
  while (%i < %count) {
    inc %i
    var %skill = $ini(%file_path, skills, %i)
    if (;* iswm %skill) continue
    if ((. isin %skill) || (%skill isin CoverTarget.shadowcopy_name.Summon.resist-weaponlock.Singing.Resist-Disarm)) continue
    if (%skill isin CocoonEvolve.MonsterConsume.Snatch.MagicShift.DemonPortal.MonsterSummon.RepairNaturalArmor.ChangeBattlefield.Quicksilver) noop
    else if (%skill == Resist-Paralyze) continue
    else if (%skill == Wizardy) continue
    else if (Resist- isin %skill) {
      var %status_resisted = $gettok(%skill, 2-, 45)
      if (%status_resisted !isin stop.poison.silence.blind.drunk.virus.amnesia.paralysis.zombie.slow.stun.curse.charm.intimidate.defensedown.strengthdown.intdown.petrify.bored.confuse.sleep) $&
        var %missing_resists = $addtok(%missing_resists, Resist- $+ %status_resisted, 46)
    }
    else if (-killer isin %skill) continue
    else if ((!$read($lstfile(skills_passive.lst), w, %skill)) && (!$read($lstfile(skills_active.lst), w, %skill)) && (!$read($lstfile(skills_killertraits.lst), w, %skill))) $& 
      var %missing_skills = $addtok(%missing_skills, %skill, 46)
    if (!$validate_expression($readini(%file_path, n, skills, %weapon))) continue
    if ($readini(%file_path, skills, %skill) !isnum) log_issue Minor %category $+  $1 $+ 's skill level for %skill is not a number; it will be zeroed.
  }
  if (%missing_skills) log_issue Moderate %category $+  $1 uses missing skill(s) $replace(%missing_skills, ., $chr(44) $+ $chr(32)) $+ ; it might not work.
  if (%missing_resists) log_issue Moderate %category $+  $1 uses invalid resistance(s) $replace(%missing_resists, ., $chr(44) $+ $chr(32)) $+ ; it will not work.
  unset %missing_skills | unset %missing_resists
  if ($readini(%file_path, skills, CoverTarget)) log_issue Moderate %category $+  $1 has an initial Cover target. This is inadvisable.
  if ($readini(%file_path, skills, provoke.target)) log_issue Moderate %category $+  $1 has an initial Provoke target. This is inadvisable.
  if ($readini(%file_path, skills, royalguard.on)) if ($readini(%file_path, skills, royalguard.on) !isin on.off) log_issue Minor %category $+  $1  has an initial royalguard.on field, but it isn't 'on'; it will be ignored.
  if ($readini(%file_path, skills, manawall.on)) if ($readini(%file_path, skills, manawall.on) !isin on.off) log_issue Minor %category $+  $1  has an initial manawall.on field, but it isn't 'on'; it will be ignored.
  if ($readini(%file_path, skills, doubleturn.on)) if ($readini(%file_path, skills, doubleturn.on) !isin on.off) log_issue Minor %category $+  $1  has an initial doubleturn.on field, but it isn't 'on'; it will be ignored.
  if ($readini(%file_path, skills, mightystrike.on)) if ($readini(%file_path, skills, mightystrike.on) !isin on.off) log_issue Minor %category $+  $1  has an initial mightystrike.on field, but it isn't 'on'; it will be ignored.
  if ($readini(%file_path, skills, konzen-ittai.on)) if ($readini(%file_path, skills, konzen-ittai.on) !isin on.off) log_issue Minor %category $+  $1  has an initial konzen-ittai.on field, but it isn't 'on'; it will be ignored.
  if ($readini(%file_path, skills, elementalseal.on)) if ($readini(%file_path, skills, elementalseal.on) !isin on.off) log_issue Minor %category $+  $1  has an initial elementalseal.on field, but it isn't 'on'; it will be ignored.
  if ($readini(%file_path, skills, utsusemi.on)) if ($readini(%file_path, skills, utsusemi.on) !isin on.off) log_issue Minor %category $+  $1  has an initial utsusemi.on field, but it isn't 'on'; it will be ignored.
  ; Make sure its Monster Summon data is valid.
  if ($readini(%file_path, skills, monstersummon)) {
    if (!$readini(%file_path, skills, monstersummon.chance)) log_issue Moderate %category $+  $1 has no monstersummon.chance field; it won't use the skill.
    if (!$readini(%file_path, skills, monstersummon.numberspawn)) log_issue Moderate %category $+  $1 has no monstersummon.numberspawn field; it won't use the skill.
    if (!$readini(%file_path, skills, monstersummon.monster)) log_issue Moderate %category $+  $1 has no monstersummon.monster field; it won't use the skill.
  }
  if ($readini(%file_path, skills, monstersummon.chance)) {
    if ($!char !isin $readini(%file_path, n, skills, monstersummon.chance)) {
      if ($readini(%file_path, skills, monstersummon.chance) !isnum) log_issue Moderate %category $+  $1 $+ 's monstersummon.chance field is not a number; it won't use the skill.
      else if ($readini(%file_path, skills, monstersummon.chance) < 1) log_issue Moderate %category $+  $1 $+ 's monstersummon.chance field is not within the valid range (1-100); it won't use the skill.
      else if ($readini(%file_path, skills, monstersummon.chance) > 100) log_issue Minor %category $+  $1 $+ 's monstersummon.chance field is not within the valid range (1-100).
    }
    if ($readini(%file_path, n, skills, monstersummon) = $null) log_issue Moderate %category $+  $1 has a monstersummon.chance field, but does not know the Monster Summon skill.
  }
  if ($readini(%file_path, skills, monstersummon.numberspawn)) {
    if ($!char !isin $readini(%file_path, n, skills, monstersummon.numberspawn)) {
      if ($readini(%file_path, skills, monstersummon.numberspawn) !isnum) log_issue Moderate %category $+  $1 $+ 's monstersummon.numberspawn field is not a number; it won't use the skill.
    }
    if ($readini(%file_path, n, skills, monstersummon) = $null) log_issue Moderate %category $+  $1 has a monstersummon.numberspawn field, but does not know the Monster Summon skill.
  }
  if ($readini(%file_path, skills, monstersummon.monster)) if (!$isfile($mon($readini(%file_path, skills, monstersummon.monster)))) log_issue Moderate %category $+  $1 's monstersummon.monster field references missing monster $readini(%file_path, skills, monstersummon.monster) $+ ; the skill won't work.
  ; Make sure the Change Battlefield data is valid.
  if ($readini(%file_path, skills, ChangeBattlefield.chance)) {
    if ($!char !isin $readini(%file_path, n, skills, ChangeBattlefield.chance)) {
      if ($readini(%file_path, skills, ChangeBattlefield.chance) !isnum) log_issue Moderate %category $+  $1 $+ 's ChangeBattlefield.chance field is not a number; it won't use the skill.
      else if ($readini(%file_path, skills, ChangeBattlefield.chance) < 1) log_issue Moderate %category $+  $1 $+ 's ChangeBattlefield.chance field is not within the valid range (1-100); it won't use the skill.
      else if ($readini(%file_path, skills, ChangeBattlefield.chance) > 100) log_issue Minor %category $+  $1 $+ 's ChangeBattlefield.chance field is not within the valid range (1-100).
    }
    if ($readini(%file_path, n, skills, ChangeBattlefield) = $null) log_issue Moderate %category $+  $1 has a ChangeBattlefield.chance field, but does not know the Change Battlefield skill.
  }
  if ($readini(%file_path, skills, ChangeBattlefield.battlefields)) {
    var %battlefields = $readini(%file_path, skills, ChangeBattlefield.battlefields)
    var %total_battlefields = $numtok(%battlefields,46)
    var %battlefield = 1
    while (%battlefield <= %total_battlefields) {
      var %battlefield_name = $gettok(%battlefields, %battlefield, 46)
      if (!$ini($dbfile(battlefields.db), %battlefield_name)) log_issue Moderate %category $+  $1 $+ 's ChangeBattlefield.battlefields field includes undefined battlefield %battlefield_name $+ .
      inc %battlefield
    }
  }
  else if ($readini(%file_path, n, Skills, ChangeBattlefield) != $null) log_issue Moderate %category $+  $1 has the Change Battlefield skill, but no ChangeBattlefield.battlefields list.
  if ($readini(%file_path, n, Skills, RepairNaturalArmor) != $null) {
    if (!$ini(%file_path, NaturalArmor)) log_issue Moderate %category $+  $1 has the Repair Natural Armor skill, but no natural armor.
  }

  ; Check the techniques.
  var %i = 0
  var %count = $ini(%file_path, Techniques, 0)
  while (%i < %count) {
    inc %i
    var %technique = $ini(%file_path, Techniques, %i)
    if (;* iswm %technique) continue
    if (!$ini($dbfile(techniques.db), %technique)) log_issue Minor %category $+  $1 has missing technique %technique $+ .
    if (!$validate_expression($readini(%file_path, n, Techniques, %technique))) continue
    if ($readini(%file_path, Techniques, %technique) !isnum) log_issue Minor %category $+  $1 $+ 's technique level for %technique is not a number; it won't use the technique.
  }

  ; Check the modifiers.
  var %absorb = $readini(%file_path, Modifiers, Heal)
  if ((%absorb != $null) && (%absorb != none)) {
    var %i = 0
    var %count = $numtok(%absorb, 46)
    while (%i < %count) {
      inc %i
      var %modifier = $gettok(%absorb, %i, 46)
      if ((. isin %modifier) || (%modifier !isin fire.ice.earth.wind.lightning.water.light.dark)) var %bad_absorbs $addtok(%bad_absorbs, %modifier, 46)
    }
  }
  var %weakness = $readini(%file_path, Weapons, Weakness)
  if ((%weakness != $null) && (%weakness != none)) {
    var %i = 0
    var %count = $numtok(%weakness, 46)
    while (%i < %count) {
      inc %i
      var %modifier = $gettok(%weakness, %i, 46)
      if (. isin %modifier) noop
      else if (%modifier isin fire.ice.earth.wind.lightning.water.light.dark.HandToHand.Whip.Sword.Gun.Rifle.Katana.Wand.Stave.Spear.Scythe.Glyph.Greatsword.Bow.Axe.Dagger) continue
      else if ($ini($dbfile(weapons.db), %modifier)) continue
      else if ($ini($dbfile(techniques.db), %modifier)) continue
      else if ($ini($dbfile(items.db), %modifier)) continue
      var %bad_weaknesses = $addtok(%bad_weaknesses, %modifier, 46)
    }
  }
  var %strong = $readini(%file_path, Weapons, Strong)
  if ((%strong != $null) && (%strong != none)) {
    var %i = 0
    var %count = $numtok(%strong, 46)
    while (%i < %count) {
      inc %i
      var %modifier = $gettok(%strong, %i, 46)
      if (. isin %modifier) noop
      else if (%modifier isin fire.ice.earth.wind.lightning.water.light.dark.HandToHand.Whip.Sword.Gun.Rifle.Katana.Wand.Stave.Spear.Scythe.Glyph.Greatsword.Bow.Axe.Dagger) continue
      else if ($ini($dbfile(weapons.db), %modifier)) continue
      else if ($ini($dbfile(techniques.db), %modifier)) continue
      else if ($ini($dbfile(items.db), %modifier)) continue
      var %bad_strengths = $addtok(%bad_strengths, %modifier, 46)
    }
  }
  if (%bad_absorbs) log_issue Minor %category $+  $1 $+ 's absorb list includes unrecognised element(s) $replace(%bad_absorbs, ., $chr(44) $+ $chr(32)) $+ . (Only elements can be used here.)
  if (%bad_weaknesses) log_issue Minor %category $+  $1 $+ 's weakness list includes unrecognised modifier(s) $replace(%bad_weaknesses, ., $chr(44) $+ $chr(32)) $+ .
  if (%bad_strengths) log_issue Minor %category $+  $1 $+ 's strength list includes unrecognised modifier(s) $replace(%bad_strengths, ., $chr(44) $+ $chr(32)) $+ .
  unset %bad_*

  var %i = 0
  var %count = $ini(%file_path, Modifiers, 0)
  while (%i < %count) {
    inc %i
    var %modifier = $ini(%file_path, Modifiers, %i)
    if (;* iswm %modifier) continue
    if (%modifier == Heal) continue

    if ($validate_expression($readini(%file_path, n, Modifiers, %modifier))) {
      var %modifier_value = $readini(%file_path, Modifiers, %modifier)
      if (%modifier_value !isnum) log_issue Minor %category $+  $1 $+ 's %modifier modifier value is not a number; these attacks will have no effect.
      else if (%modifier_value < 0) log_issue Minor %category $+  $1 $+ 's %modifier modifier value is less than 0; these attacks will have no effect.
    }

    if ((. !isin %modifier) && (%modifier isin fire.ice.earth.wind.lightning.water.light.dark.HandToHand.Whip.Sword.Gun.Rifle.Katana.Wand.Stave.Spear.Scythe.Glyph.Greatsword.Bow.Axe.Dagger)) continue
    if ($ini($dbfile(techniques.db), %modifier)) continue
    if ($ini($dbfile(weapons.db), %modifier)) continue
    if ($ini($dbfile(items.db), %modifier)) continue
    log_issue Minor %category $+  $1 references unrecognised modifier %modifier $+ . Use an element, weapon type, weapon or technique name.
  }  

  return
  :error
  log_issue Critical Checking %category $+  $1 failed: $error
  reseterror
}
monster_get_hp {
  ; Retrieves a monster's HP.
  ;   $1 : The monster's name.
  ;   $2 : $null
  ;   $3 : 1
  ; Output to %hp : The monster's base HP.

  ; Check the BattleStats flag.
  if ($readini(%file_path, info, BattleStats) = ignoreHP) return
  ; Further checking will be done in $monster_get_attributes
  set %hp $readini(%file_path, BaseStats, HP)
  if (!$validate_expression($readini(%file_path, n, BaseStats, HP))) set %hp 0
}
monster_get_attributes {
  ; Retrieves a monster's attributes (STR, DEF, INT, SPD).
  ;   $1 : The monster's name.
  ;   $2 : 1
  ;   $3 : $null
  ; Output to %str, %def, %int, %spd : The attributes.

  ; Check the BattleStats flag.
  if ($readini(%file_path, info, BattleStats) = ignore) return
  if ($readini(%file_path, info, BattleStats) != $null && $readini(%file_path, info, BattleStats) != ignoreHP) /log_issue Moderate %category $+  $1 $+ 's Info-BattleStats field is specified, but not as 'ignore'; the monster will be boosted as normal.

  ; We ignore the check if the value contains $char
  set %str $readini(%file_path, BaseStats, Str)
  if (!$validate_expression($readini(%file_path, n, BaseStats, Str))) set %str 0
  set %def $readini(%file_path, BaseStats, Def)
  if (!$validate_expression($readini(%file_path, n, BaseStats, Def))) set %def 0
  set %int $readini(%file_path, BaseStats, Int)
  if (!$validate_expression($readini(%file_path, n, BaseStats, Int))) set %int 0
  set %spd $readini(%file_path, BaseStats, Spd)
  if (!$validate_expression($readini(%file_path, n, BaseStats, Spd))) set %spd 0
}
validate_expression {
  ; Checks whether an expression can be checked. If the expression contains the $char function
  ;   or references any battle txt files, it cannot be checked fully.
  ;   $1-: The expression to check.

  if ($!char isin $1-) return $false
  if (battle isin $1-) return $false
  return $true
}

check_weapons {
  ; Checks weapons.
  ;   No parameters.
  if ($isid) return
  window @issues

  ; Check the weapon lists and make sure there's nothing missing.
  titlebar Battle Arena $battle.version — Checking weapon lists...
  var %i = 0
  var %lcount = $ini(weapons.db, weapons, 0)
  while (%i < %lcount) {
    inc %i
    var %list = $ini(weapons.db, weapons, %i)
    var %j = 0
    var %count = $numtok($readini(weapons.db, weapons, %list),46)
    while (%j < %count) {
      inc %j
      var %weapon = $gettok($readini(weapons.db, weapons, %list), %j, 46)
      if (!$ini(weapons.db, %weapon)) var %missing_weapons $addtok(%missing_weapons, %weapon, 46)
    }
    if (%missing_weapons) log_issue Moderate Weapon list %list references missing weapon(s) %missing_weapons $+ .
    unset %missing_weapons
  }

  ; Check the technique lists in techniques.db.
  titlebar Battle Arena $battle.version � Checking weapon technique lists...
  var %i = 0
  var %count = $ini($dbfile(techniques.db), Techs, 0)
  while (%i < %count) {
    inc %i
    var %weapon_name = $ini($dbfile(techniques.db), Techs, %i)
    var %weapon_techniques = $readini($dbfile(techniques.db), Techs, %weapon_name)
    if (;* iswm %weapon_name) continue

    var %total_techniques2 = $numtok(%weapon_techniques, 46)
    var %current_technique = 0

    while (%current_technique < %total_techniques2) {
      inc %current_technique
      var %technique_name = $gettok(%weapon_techniques, %current_technique, 46)
      if (!$ini($dbfile(techniques.db), %technique_name)) log_issue Minor Technique list for %weapon_name has missing technique %technique_name $+ .
    }
  }

  ; Now check each weapon.
  set %total_weapons $ini($dbfile(weapons.db), 0)
  var %current_weapon = 0

  while (%current_weapon < %total_weapons) {
    inc %current_weapon

    var %weapon_name = $ini($dbfile(weapons.db), %current_weapon)
    if (%weapon_name == Weapons) continue
    if (%weapon_name == Shields) continue
    if (%weapon_name == ExampleWeapon) continue
    titlebar Battle Arena $battle.version � Checking weapon %current_weapon / %total_weapons : %weapon_name ...


    ; Spaces and = can't be in weapon names.
    if (($chr(32) isin %weapon_name) || (= isin %weapon_name)) log_issue Moderate Weapon %weapon_name has an invalid name: the weapon will be unusable.

    ; Weapon cost
    var %weapon_cost = $readini($dbfile(weapons.db), %weapon_name, Cost)
    if (%weapon_cost !isnum) log_issue Moderate Weapon %weapon_name $+ 's cost is not a number; it cannot be bought or used by players.

    ; Base power    
    var %weapon_power = $readini($dbfile(weapons.db), p, %weapon_name, BasePower)
    if (%weapon_power !isnum) log_issue Moderate Weapon %weapon_name $+ 's power is not a number: power will be zeroed.

    ; Weapon type
    var %weapon_type = $readini($dbfile(weapons.db), %weapon_name, Type)
    if (%weapon_type == Shield) {
      check_shield %weapon_name
      continue
    }
    if (!$isfile($txtfile(attack_ $+ %weapon_type $+ .txt))) $&
      log_issue Minor Weapon %weapon_name has an unknown type ( $+ %weapon_type $+ ).

    ; Special flag
    var %weapon_special = $readini($dbfile(weapons.db), %weapon_name, SpecialWeapon)
    if (%weapon_special != $null && %weapon_special != true && %weapon_special != false) log_issue Moderate Weapon %weapon_name $+ 's special field is specified, but not as 'true': the weapon will be treated as one-handed.

    ; Weapon techniques
    var %weapon_techniques = $readini($dbfile(weapons.db), %weapon_name, Abilities)
    var %total_techniques2 = $numtok(%weapon_techniques, 46)
    var %current_technique = 0

    while (%current_technique < %total_techniques2) {
      inc %current_technique
      var %technique_name = $gettok(%weapon_techniques, %current_technique, 46)
      if (!$ini($dbfile(techniques.db), %technique_name)) log_issue Minor Weapon %weapon_name has missing technique %technique_name $+ .
    }

    ; Make sure the weapon is in techniques.db if it has techniques.
    if ((%total_techniques2 > 0) && (!$ini($dbfile(techniques.db), Techs, %weapon_name))) $&
      log_issue Moderate Weapon %weapon_name is missing from techniques.db!

    ; Element
    var %weapon_element = $readini($dbfile(weapons.db), %weapon_name, Element)
    if ((%weapon_element) && (. isin %weapon_element || %weapon_element !isin none.fire.water.ice.lightning.wind.earth.light.dark)) $&
      log_issue Minor Weapon %weapon_name uses an unknown element ( $+ %weapon_element $+ ): it will be unaffected by weather.

    ; Number of hits
    var %weapon_hits = $readini($dbfile(weapons.db), %weapon_name, Hits)
    if ((%weapon_hits) && (%weapon_hits !isnum)) log_issue Minor Weapon %weapon_name $+ 's number of hits is not a number: it will be zeroed.

    ; Upgrade cost
    if ((!$read($lstfile(items_mech.lst), w, %weapon_name)) && (%weapon_cost isnum) && (%weapon_cost != 0)) {
      var %weapon_upgradecost = $readini($dbfile(weapons.db), p, %weapon_name, Upgrade)
      if (%weapon_upgradecost !isnum) log_issue Major Weapon %weapon_name $+ 's upgrade cost is not a number: it will cost zero.
      else if (%weapon_upgradecost <= 0) log_issue Major Weapon %weapon_name $+ 's upgrade cost is not positive!
    }

    ; Piercing ability
    var %weapon_piercing = $readini($dbfile(weapons.db), %weapon_name, IgnoreDefense)
    if ((%weapon_piercing) && (%weapon_piercing !isnum)) log_issue Moderate Weapon %weapon_name $+ 's ignore defense is not a number: it will be zeroed.
    else if (%weapon_piercing > 0 && %weapon_piercing < 1) log_issue Minor Weapon %weapon_name $+ 's ignore defense is a decimal where a percentage (0-100) is expected.

    ; Hurt ethereal flag
    var %weapon_ethereal = $readini($dbfile(weapons.db), %weapon_name, HurtEthereal)
    if (%weapon_ethereal != $null && %weapon_ethereal != true && %weapon_ethereal != false) log_issue Minor Weapon %weapon_name $+ 's hurt ethereal field is specified, but not as 'true': field will be ignored.

    ; Two-handed flag
    var %weapon_twohanded = $readini($dbfile(weapons.db), %weapon_name, 2Handed)
    if (%weapon_twohanded != $null && %weapon_twohanded != true && %weapon_twohanded != false) log_issue Minor Weapon %weapon_name $+ 's two-handed field is specified, but not as 'true': the weapon will be treated as one-handed.

    ; Mech energy cost        
    var %weapon_energycost = $readini($dbfile(weapons.db), %weapon_name, EnergyCost)
    if ((%weapon_energycost) && (%weapon_energycost !isnum)) log_issue Moderate Weapon %weapon_name $+ 's energy cost is not a number; it will use 100 energy per turn.

    ; Reflect flag
    var %weapon_reflect = $readini($dbfile(weapons.db), %weapon_name, CanShieldReflect)
    if (%weapon_reflect != $null && %weapon_reflect != true && %weapon_reflect != false) log_issue Minor Weapon %weapon_name $+ 's reflect field is specified, but not as 'true': field will be ignored.

    ; Counter flag
    var %weapon_counter = $readini($dbfile(weapons.db), %weapon_name, CanCounter)
    if (%weapon_counter != $null && %weapon_counter != true && %weapon_counter != false) log_issue Minor Weapon %weapon_name $+ 's counter field is specified, but not as 'true': field will be ignored.

    ; Special effect
    var %weapon_specialeffect = $readini($dbfile(weapons.db), %weapon_name, Special)
    if (%weapon_specialeffect != $null && %weapon_specialeffect != GemConvert) log_issue Minor Weapon %weapon_name has an unknown special effect ( $+ %weapon_specialeffect $+ ).

    ; Target type
    var %weapon_target = $readini($dbfile(weapons.db), %weapon_name, Target)
    if (%weapon_target != $null && %weapon_target != AoE) log_issue Minor Weapon %weapon_name has an unknown target type ( $+ %weapon_target $+ ).

    ; Status effect
    var %weapon_status = $readini($dbfile(weapons.db), %weapon_name, StatusType)
    if (%weapon_status != $null) check_statuseffects %weapon_status Weapon  $+ %weapon_name $+ 

    continue
    :error
    log_issue Critical Checking weapon %weapon_name failed: $error
    reseterror
  } 
  if (%issues_total == 0) echo -a 12Checked $calc(%current_weapon - 1) weapons and found no issues. Yay!
  else echo -a 12Checked $calc(%current_weapon - 1) weapons and found %issues_total  $+ $iif(%issues_total == 1, issue, issues) $+ .
}
check_shield {
  ; Checks an individual shield definition for errors.
  ;   $1 : The name of the shield.
  if ($isid) return

  ; Block chance
  var %weapon_blockchance = $readini($dbfile(weapons.db), $1, BlockChance)
  if (%weapon_blockchance !isnum) log_issue Moderate Shield $1 $+ 's block chance is not a number: it will be useless.
  else if (%weapon_blockchance > 0 && %weapon_blockchance < 1) log_issue Minor Shield $1 $+ 's block chance is a decimal where a percentage (0-100) is expected.

  ; Block amount
  var %weapon_blockamount = $readini($dbfile(weapons.db), $1, AbsorbAmount)
  if (%weapon_blockamount !isnum) log_issue Moderate Shield $1 $+ 's block amount is not a number: it will be useless.
  else if (%weapon_blockamount > 0 && %weapon_blockamount < 1) log_issue Minor Shield $1 $+ 's block amount is a decimal where a percentage (0-100) is expected.
}

check_statuseffects {
  ; Checks a list of status effects, to make sure that they all exist.
  ;   $1 : the list of effects
  ;   $2-: the entry being checked
  if ($isid) return
  if ($1 != $null) { 
    var %count = $numtok($1, 46) 

    if (%count >= 1) {
      var %i = 1
      while (%i <= %count) { 
        var %current.status.effect = $gettok($1, %i, 46)
        if ((%current.status.effect == sleep) && (%old)) $&
          log_issue Minor $2- uses the sleep status effect, which may not work in this version of Battle Arena.
        else if (%current.status.effect !isin stop.poison.silence.blind.drunk.virus.amnesia.paralysis.zombie.slow.stun.curse.charm.intimidate.defensedown.strengthdown.intdown.petrify.bored.confuse.sleep.random) $&
          log_issue Minor $2- uses an invalid status effect ( $+ %current.status.effect $+ )! Use one of: stop, poison, silence, blind, drunk, virus, amnesia, paralysis, zombie, slow, stun, curse, charm, intimidate, defensedown, strengthdown, intdown, petrify, bored, confuse, sleep, random.
        inc %i
      }  
    }
  }
}

log_issue {
  ; Records an issue message to the window @issues.
  ;   $1 : The severity of the issue: 'Minor', 'Moderate', 'Major' or 'Critical'.
  ;        'Minor': Something might be missing, but it shouldn't have any significant consequences.
  ;        'Moderate': Something that will impact players, or that can be exploited.
  ;        'Major': Something that could potentially have serious side effects, or create a security hole.
  ;        'Critical': Something that could hang, freeze or crash the bot, or worse.
  ;   $2-: A user-friendly description of the problem.
  if ($isid) return

  inc %issues_total
  if ($1 == Minor   ) { aline -p 8 @issues [Minor]    $2- }
  if ($1 == Moderate) { aline -p 7 @issues [Moderate] $2- }
  if ($1 == Major   ) { aline -p 4 @issues [Major]    $2- | inc %issues_major }
  if ($1 == Critical) { aline -p 5 @issues [Critical] $2- | inc %issues_major }
}
