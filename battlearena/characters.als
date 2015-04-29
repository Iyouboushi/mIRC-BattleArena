;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; characters.als
;;;; Last updated: 04/29/15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starting character checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
starting_character_checks {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = $null) { return }
  if (%name = new_chr) { return }
  if ($readini($char(%name), info, flag) = npc) { return }
  if ($readini($char(%name), info, flag) = monster) { return }

  if ($readini(system.dat, system, EnableDNSCheck) = true) { 
    var %last.ip $readini($char(%name), info, lastIP) 
    if (%last.ip = %ip.to.check) {  inc %duplicate.ips 1 }
  }

  var %temp.shoplevel $readini($char(%name), Stuff, ShopLevel)
  if (%temp.shoplevel = $null) { var %temp.shoplevel 1 }
  inc %current.shoplevel %temp.shoplevel

  inc %totalplayers 1

  unset %name | unset %file | unset %ip.address. [ $+ [ $1 ] ]
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allows chars to add/remove
; access to his/her characters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.access {
  if ($2 = add) { 
    $checkchar($3)
    var %player.access.list $readini($char($1), access, list)
    if (%player.access.list = $null) { writeini $char($1) access list $nick | var %player.access.list $nick }
    if ($istok(%player.access.list,$3,46) = $true) {  $display.private.message2($1, $readini(translation.dat, errors, AccessCommandAlreadyHasAccess)) | halt }
    var %player.access.list $addtok(%player.access.list, $3,46) | writeini $char($1) access list %player.access.list | $display.private.message2($1, $readini(translation.dat, system, AccessCommandAdd)) | halt 
  }

  if ($2 = remove) { 
    var %player.access.list $readini($char($1), access, list)
    if (%player.access.list = $null) { writeini $char($1) access list $nick | var %player.access.list $nick }
    if ($istok(%player.access.list,$3,46) = $true) {   
      if ($3 != $1) { var %player.access.list $remtok(%player.access.list, $3,46) | writeini $char($1) access list %player.access.list | $display.private.message2($1, $readini(translation.dat, system, AccessCommandRemove)) | halt }
      if ($3 = $1) { $display.private.message2($1, $readini(translation.dat, errors, AccessCommandCan'tRemoveSelf)) }
    }
  }

  if ($2 = list) {
    var %player.access.list $readini($char($1), access, list)
    if (%player.access.list = $null) { writeini $char($1) access list $nick | var %player.access.list $nick }
    set %replacechar $chr(044) $chr(032)
    %player.access.list = $replace(%player.access.list, $chr(046), %replacechar)  
    unset %replacechar
    $display.private.message2($1, $readini(translation.dat, system, AccessCommandList)) 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the character's real
; name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_chr_name {
  set %real.name $readini($char($1), BaseStats, Name)
  if (%real.name = $null) { set %real.name $1 | return }
  else { return }
}

get_chr_name {
  var %tmp.real.name $readini($char($1), BaseStats, Name)
  if (%tmp.real.name = $null) { return $1 }
  else { return %tmp.real.name }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the character's
; current potion effect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.potioneffect {
  var %potion.effect $readini($char($1), status, potioneffect)
  if (%potion.effect = $null) { return none }
  else { return %potion.effect }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns red orb amount
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_redorbs {
  ; $1 = the person you're checking

  var %tmp.redorbs $readini($char($1), stuff, redorbs)
  if (%tmp.redorbs = $null) { return 0 }
  else { return %tmp.redorbs }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns gender of char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gender { return $readini($char($1), Info, Gender) }
gender2 {
  if ($gender($1) = her) { return her }
  if ($gender($1) = its) { return it }
  else { return him }
}
gender3 {
  if ($gender($1) = her) { return she }
  if ($gender($1) = its) { return it }
  else { return he }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns level of char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get.level {
  var %str $readini($char($1),battle, str)
  var %def $readini($char($1), battle, def)
  var %int $readini($char($1), battle, int)
  var %spd $round($calc($readini($char($1), battle, spd) * .5),0)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %spd

  var %level $round($calc(%level / 18), 1)

  return $round(%level,0)
}
get.level.basestats {
  var %str $readini($char($1), BaseStats, str)
  var %def $readini($char($1), basestats, def)
  var %int $readini($char($1), basestats, int)
  var %spd $round($calc($readini($char($1), basestats, spd) * .5),0)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %spd

  var %level $round($calc(%level / 18), 1)
  return %level
}
get.level.old {
  var %str $readini($char($1),battle, str)
  var %def $readini($char($1), battle, def)
  var %int $readini($char($1), battle, int)
  var %spd $readini($char($1), battle, spd)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %spd

  var %level $round($calc(%level / 20), 1)

  return %level
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks & Clears a player's
; portal usage if enough time
; has passed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portal.clearusagecheck {
  ; $1 = person to check

  set %current.day $gettok($adate, 2, 47)
  set %current.month $gettok($adate, 1, 47)

  set %last.portal.used.month $gettok($readini($char($1), info, LastPortalDate), 1, 47)
  set %last.portal.used.day $gettok($readini($char($1), info, LastPortalDate), 2, 47)

  var %reset.usage false

  if ((%current.month = $null) || (%last.portal.used.day = $null)) { var %reset.usage true }

  if (%last.portal.used.month = %current.month) { 
    if (%last.portal.used.day != %current.day) { var %reset.usage true }
  }
  if (%current.month != %last.portal.used.month) { var %reset.usage true }

  if (%reset.usage = true) { writeini $char($1) info PortalsUsedTotal 0 }

  unset %current.day | unset %current.month | unset %last.portal.used.day | unset %last.portal.used.month
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See if the user $1 has
; the skill $2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
skillhave.check {
  if ($readini($char($1), skills, $2) > 0) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for the treasurehunter
; skill.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
treasurehunter.check {
  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1 | set %treasure.hunter.percent 0
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt) | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = dead) { inc %l 1 }
    else { 
      var %treasurehunter.skill $readini($char(%who.battle), skills, treasurehunter) 
      if (%treasurehunter.skill > 0) { inc %treasure.hunter.percent %treasurehunter.skill }
      if ($augment.check($1, EnhanceTreasureHunter) = true) { inc %treasure.hunter.percent %augment.strength }

      if ($accessory.check(%who.battle, IncreaseTreasureOdds) = true) {
        inc %treasure.hunter.percent %accessory.amount
        unset %accessory.amount
      }

      inc %l 1 
    } 
  }
  unset %lines | unset %l | unset %current.accessory | unset %current.accessory.type

  return %treasure.hunter.percent
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for the backguard
; skill.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
backguard.check {
  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt)
    if ($readini($char($1), info, flag) != $null) { inc %l 1 }
    else { 
      var %backguard.skill $readini($char(%who.battle), skills,backguard) 
      if (%backguard.skill > 0) { dec %surpriseattack.chance %backguard.skill }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for the divine blessing
; skill.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
divineblessing.check {
  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt)
    if ($readini($char($1), info, flag) != $null) { inc %l 1 }
    else { 
      var %divineblessing.skill $readini($char(%who.battle), skills,divineblessing) 
      if (%divineblessing.skill > 0) { inc %curse.chance %divineblessing.skill }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a person's item amount
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
item.amount { 
  ; $1 = person
  ; $2 = item name
  var %temp.item.amount $readini($char($1), item_amount, $2)
  if (%temp.item.amount = $null) { return 0 }
  else { return %temp.item.amount } 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Refills a char's natural armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fullNaturalArmor {
  if ($readini($char($1), info, flag) = $null) { return }
  var %naturalArmorMax $readini($char($1), NaturalArmor, Max)
  if (%naturalArmorMax != $null) { writeini $char($1) NaturalArmor Current %naturalArmorMax }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "looks" at a player
; Displays armor and weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lookat {
  $weapon_equipped($1) | $set_chr_name($1)
  var %equipped.accessory $readini($char($1), equipment, accessory) 
  if (%equipped.accessory = $null) { var %equipped.accessory nothing }
  var %equipped.armor.head $readini($char($1), equipment, head) 
  if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
  var %equipped.armor.body $readini($char($1), equipment, body) 
  if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
  var %equipped.armor.legs $readini($char($1), equipment, legs) 
  if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
  var %equipped.armor.feet $readini($char($1), equipment, feet) 
  if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
  var %equipped.armor.hands $readini($char($1), equipment, hands) 
  if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }

  if ($readini($char($1), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($1), info, CustomTitle) $+ " }

  if ($readini(system.dat, system, botType) = IRC) { 
    if ($2 = channel) {  $display.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped $iif(%weapon.equipped.left != $null, and %weapon.equipped.left weapons, weapon),private) }
    if ($2 != channel) { $display.private.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped $iif(%weapon.equipped.left != $null, and %weapon.equipped.left weapons, weapon)) }
  }
  if ($readini(system.dat, system, botType) = DCCchat) {
    var %look.message 3 $+ %real.name is wearing %equipped.armor.head on $gender($1) head, %equipped.armor.body on $gender($1) body, %equipped.armor.legs on $gender($1) legs, %equipped.armor.feet on $gender($1) feet, %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped weapon.
  $dcc.private.message($nick, %look.message) }
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a person's allied
; notes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check.allied.notes {
  var %allied.notes $readini($char($1), stuff, alliednotes) 
  if (%allied.notes = $null) { var %allied.notes no }
  $set_chr_name($1) 
  if ($readini(system.dat, system, botType) = IRC) {
    if ($2 = channel) {  $display.message($readini(translation.dat, system, ViewAlliedNotes),private) } 
    else { $display.private.message($readini(translation.dat, system, ViewAlliedNotes)) }
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, $readini(translation.dat, system, ViewAlliedNotes)) }

  unset %real.name | unset %hstats 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a person's
; double dollar amount
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check.doubledollars {
  var %doubledollars $readini($char($1), stuff, doubledollars) 
  if (%doubledollars = $null) { writeini $char($1) stuff doubledollars 100 | var %doubledollars 100 }
  var %currency.symbol $readini(system.dat, system, BetCurrency)
  if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }
  $set_chr_name($1) 
  if ($readini(system.dat, system, botType) = IRC) {
    if ($2 = channel) {  $display.message($readini(translation.dat, system, ViewDoubleDollars),private) } 
    else { $display.private.message($readini(translation.dat, system, ViewDoubleDollars)) }
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, $readini(translation.dat, system, ViewDoubleDollars)) }

  unset %real.name | unset %hstats 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds a list of all active
; statuses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
player.status { unset %all_status | unset %all_skills | $set_chr_name($1) 
  if ($readini($char($1), Battle, Status) = dead) { set %all_status dead | return } 
  else { 

    var %value 1 | var %status.lines $lines($lstfile(statuseffects.lst))

    while (%value <= %status.lines) {
      var %current.status $read -l $+ %value $lstfile(statuseffects.lst)
      if (($readini($char($1), Status, %current.status) = yes) || ($readini($char($1), Status, %current.status) = on)) { 

        if ((%current.status = poison) && ($readini($char($1), status, heavypoison) = yes)) { $status_message_check($readini(translation.dat, statuses, HeavyPoison)) }
        else { $status_message_check($readini(translation.dat, statuses, %current.status)) }
      } 
      inc %value 1 
    }


    $bar_check($1)
    unset %resists

    if ($readini($char($1), status, en-spell) != none) { var %enspell $readini($char($1), status, en-spell) | $status_message_check(12en- $+ %enspell) }

    $player.skills.list($1)

    if (%all_status = $null) { %all_status = 3Normal }
    if (%all_skills = $null) { %all_skills = 3None }
    return
  }
  unset %real.name | unset %status 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds a list of all active
; skills
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
player.skills.list {
  unset %all_skills
  if ($readini($char($1), status, conservetp.on) = on) { $skills_message_check(2conserving TP) }
  if ($readini($char($1), status, conservetp) = yes) { $skills_message_check(2conserving TP) }
  if ($readini($char($1), skills, utsusemi.on) = on) { $skills_message_check(2Utsusemi[ $+ $readini($char($1), skills, utsusemi.shadows) $+ ]) }
  if ($readini($char($1), skills, royalguard.on) = on) { $skills_message_check(2Royal Guard) }
  if ($readini($char($1), skills, manawall.on) = on) { $skills_message_check(2Mana Wall) }
  if ($readini($char($1), skills, mightystrike.on) = on) { $skills_message_check(2Mighty Strike) }
  if ($readini($char($1), skills, truestrike.on) = on) { $skills_message_check(2True Strike) }
  if ($readini($char($1), skills, elementalseal.on) = on) { $skills_message_check(2Elemental Seal) }
  if ($readini($char($1), skills, thirdeye.on) = on) { $skills_message_check(2Third Eye) }
  if ($readini($char($1), skills, retaliation.on) = on) { $skills_message_check(2Retaliation) }
  if ($readini($char($1), skills, konzen-ittai.on) = on) { $skills_message_check(2Konzen-Ittai) }
  if ($readini($char($1), skills, defender.on) = on) { $skills_message_check(2Defender) }
  if ($readini($char($1), skills, aggressor.on) = on) { $skills_message_check(2Aggressor) }
  if ($readini($char($1), skills, perfectcounter.on) = on) { $skills_message_check(2Will Perform a Perfect Counter) }
  if ($readini($char($1), skills, FormlessStrike.on) = on) { $skills_message_check(Formless Strikes) }
  if ($readini($char($1), skills, PerfectDefense.on) = on) { $skills_message_check(Perfect Defense) }
  if ($readini($char($1), skills, drainsamba.on) = on) { $skills_message_check(Drain Samba) }

  set %cover.target $readini($char($1), skills, CoverTarget)
  if ((%cover.target != $null) && (%cover.target != none)) { $skills_message_check(2Covered by %cover.target) }

  unset %cover.target
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sees if the char is charmed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
is_charmed {
  if ($readini($char($1), status, charmed) = yes) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sees if the char is confused
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
is_confused {
  if ($readini($char($1), status, confuse) = yes) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sees if the char has amnesia
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
amnesia.check {
  var %amnesia.check $readini($char($1), status, amnesia)
  if (%amnesia.check = no) { return }
  else { 
    $set_chr_name($1) 
    $display.message($readini(translation.dat, status, CurrentlyAmnesia),battle) 

    halt 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's weapon list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_weapon_lists {  $set_chr_name($1) 

  set %replacechar $chr(044) $chr(032) 
  %weapon.list1 = $replace(%weapon.list1, $chr(046), %replacechar)

  if ($2 = channel) { 
    $display.message($readini(translation.dat, system, ViewWeaponList),private)

    var %weapon.counter 2
    while ($weapons.returnlist(%weapon.counter) != $null) {
      set %display.weaponlist $weapons.returnlist(%weapon.counter)
      %display.weaponlist = $replace(%display.weaponlist, $chr(046), %replacechar)

      $display.message(3 $+ %display.weaponlist)
      $weapons.unsetlist(%weapon.counter) | unset %display.weaponlist
      inc %weapon.counter
      if (%weapon.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  if ($2 = private) {
    $display.private.message2($3,$readini(translation.dat, system, ViewWeaponList))

    var %weapon.counter 2
    while ($weapons.returnlist(%weapon.counter) != $null) {
      set %display.weaponlist $weapons.returnlist(%weapon.counter)
      %display.weaponlist = $replace(%display.weaponlist, $chr(046), %replacechar)

      $display.private.message2($3,3 $+ %display.weaponlist)
      $weapons.unsetlist(%weapon.counter) | unset %display.weaponlist
      inc %weapon.counter
      if (%weapon.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  if ($2 = dcc) { 
    $dcc.private.message($3, $readini(translation.dat, system, ViewWeaponList))

    var %weapon.counter 2
    while ($weapons.returnlist(%weapon.counter) != $null) {
      set %display.weaponlist $weapons.returnlist(%weapon.counter)
      %display.weaponlist = $replace(%display.weaponlist, $chr(046), %replacechar)

      $dcc.private.message($3,3 $+ %display.weaponlist)
      $weapons.unsetlist(%weapon.counter) | unset %display.weaponlist
      inc %weapon.counter
      if (%weapon.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  unset %wpn.lst.target | unset %base.weapon.list | unset %weapons
  unset %weapon.list1 | unset %weapon.counter | unset %replacechar
  unset %weaponlist.counter | unset %mech.weapon.list | unset %mech.weapon.list2
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's shield list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_shield_lists {  $set_chr_name($1) 
  set %replacechar $chr(044) $chr(032) 
  %shield.list1 = $replace(%shield.list1, $chr(046), %replacechar)

  if ($2 = channel) { 
    $display.message($readini(translation.dat, system, ViewshieldList),private)

    var %shield.counter 2
    while ($shields.returnlist(%shield.counter) != $null) {
      set %display.shieldlist $shields.returnlist(%shield.counter)
      %display.shieldlist = $replace(%display.shieldlist, $chr(046), %replacechar)

      $display.message(3 $+ %display.shieldlist,private)
      $shields.unsetlist(%shield.counter) | unset %display.shieldlist
      inc %shield.counter
      if (%shield.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  if ($2 = private) {
    $display.private.message2($3,$readini(translation.dat, system, ViewshieldList))

    var %shield.counter 2
    while ($shields.returnlist(%shield.counter) != $null) {
      set %display.shieldlist $shields.returnlist(%shield.counter)
      %display.shieldlist = $replace(%display.shieldlist, $chr(046), %replacechar)

      $display.private.message2($3,3 $+ %display.shieldlist)
      $shields.unsetlist(%shield.counter) | unset %display.shieldlist
      inc %shield.counter
      if (%shield.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  if ($2 = dcc) { 
    $dcc.private.message($3, $readini(translation.dat, system, ViewshieldList))

    var %shield.counter 2
    while ($shields.returnlist(%shield.counter) != $null) {
      set %display.shieldlist $shields.returnlist(%shield.counter)
      %display.shieldlist = $replace(%display.shieldlist, $chr(046), %replacechar)

      $dcc.private.message($3,3 $+ %display.shieldlist)
      $shields.unsetlist(%shield.counter) | unset %display.shieldlist
      inc %shield.counter
      if (%shield.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  unset %shld.lst.target | unset %base.shield.list | unset %shields
  unset %shield.list1 | unset %shield.counter | unset %replacechar
  unset %shieldlist.counter
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's style xp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
show.stylexp {
  ; Get and show the list
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.xp $readini($char($1), styles, %current.playerstyle $+ XP)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  var %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)
  $set_chr_name($1) 
  if (%current.playerstyle.level >= 10) {   
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewCurrentStyleMaxed),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewCurrentStyleMaxed)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyleMaxed)) }
  }
  if (%current.playerstyle.level < 10) {   
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewCurrentStyle),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewCurrentStyle)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyle)) }
  }
  unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's skils
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readskills {
  $checkchar($1) | $skills.list($1) | $set_chr_name($1) 

  if (%passive.skills.list != $null) { 
    if ($2 = channel) { 
      $display.message($readini(translation.dat, system, ViewPassiveSkills),private)
      if (%passive.skills.list2 != $null) { $display.message(3 $+ %passive.skills.list2,private) }
    }
    if ($2 = private) {
      $display.private.message($readini(translation.dat, system, ViewPassiveSkills))
      if (%passive.skills.list2 != $null) { $display.private.message(3 $+ %passive.skills.list2) }
    }
    if ($2 = dcc) {
      $dcc.private.message($nick, $readini(translation.dat, system, ViewPassiveSkills))
      if (%passive.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %passive.skills.list2) }
    }

  }
  if (%active.skills.list != $null) { 
    if ($2 = channel) { 
      $display.message($readini(translation.dat, system, ViewActiveSkills),private)
      if (%active.skills.list2 != $null) { $display.message(3 $+ %active.skills.list2,private) }
    }
    if ($2 = private) {
      $display.private.message($readini(translation.dat, system, ViewActiveSkills))
      if (%active.skills.list2 != $null) { $display.private.message(3 $+ %active.skills.list2) }
    }
    if ($2 = dcc) {
      $dcc.private.message($nick, $readini(translation.dat, system, ViewActiveSkills))
      if (%active.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %active.skills.list2) }
    }
  }

  if (%resists.skills.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewResistanceSkills),private)  }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewResistanceSkills))  }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewResistanceSkills))  }
  }

  if (%killer.skills.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewKillerTraitSkills),private)  }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewKillerTraitSkills))  }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewKillerTraitSkills))  }
  }

  if ((((%passive.skills.list = $null) && (%active.skills.list = $null) && (%killer.skills.list = $null) && (%resists.skills.list = $null)))) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoSkills),private)   }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNoSkills))   }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoSkills)) }
  }
  unset %passive.skills.list | unset %active.skills.list | unset %active.skills.list2 | unset %resists.skills.list | unset %killer.skills.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readkeys {
  if (%keys.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewKeysItems)) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewKeysItems)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewKeysItems)) }
  } 
  else { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoKeys),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNoKeys)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoKeys)) }
  }    
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's gems
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readgems {
  if (%gems.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewGemItems),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewGemItems)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewGemItems)) }
  } 
  else { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoGems),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, HasNoGems)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoGems)) }
  }    
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's seals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readseals {
  if (%seals.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewSealItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewSealItems)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewSealItems)) }
  } 
  else { 
    if ($2 = channel) {  $display.message($readini(translation.dat, system, HasNoSeals),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNoSeals)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoSeals)) }
  }    

  unset %seals.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's instruments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readinstruments {
  if (%instruments.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewInstruments),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewInstruments)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewInstruments)) }
  } 
  else { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoinstruments),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNoinstruments)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoinstruments)) }
  }    

  unset %instruments.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's trusts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readtrusts {
  if (%trust.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewTrustItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewTrustItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewTrustItems)) }
  } 
  else { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoTrusts),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNoTrusts)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoTrusts)) }
  }    

  unset %trust.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's potion ingredients
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readingredients {
  if (%Ingredients.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewIngredientItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewIngredientItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewIngredientItems)) }
  } 
  else { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoingredients),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNoingredients)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoingredients)) }
  }    

  unset %ingredients.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readitems { 
  if (%items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewItems)) }
  }
  if (%items.list2 != $null) { 
    if ($2 = channel) { $display.message( $+ %items.list2,private) }
    if ($2 = private) { $display.private.message( $+ %items.list2) }
    if ($2 = dcc) { $dcc.private.message($nick,  $+ %items.list2) }
  }
  if (%statplus.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewStatPlusItems),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewStatPlusItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewStatPlusItems)) }
  }
  if (%summons.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewSummonItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewSummonItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewSummonItems)) }
  }
  if (%summons.items.list2 != $null) { 
    if ($2 = channel) { $display.message( $+ %summons.items.list2,private) }
    if ($2 = private) {  $display.private.message( $+ %summons.items.list2) }
    if ($2 = dcc) { $dcc.private.message($nick,  $+ %summons.items.list2) }
  }
  if (%summons.items.list3 != $null) { 
    if ($2 = channel) { $display.message( $+ %summons.items.list3,private) }
    if ($2 = private) {  $display.private.message( $+ %summons.items.list3) }
    if ($2 = dcc) { $dcc.private.message($nick,  $+ %summons.items.list3) }
  }
  if (%reset.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewShopResetItems),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewShopResetItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewShopResetItems)) }
  }
  if (%portals.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewPortalItems),private) } 
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewPortalItems)) } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewPortalItems)) }
  }
  if (%misc.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewMiscItems),private) | if (%misc.items.list2 != $null) { $display.message( $+ %misc.items.list2,private) } | if (%misc.items.list3 != $null) { $display.message( $+ %misc.items.list3,private) } | if (%misc.items.list4 != $null) { $display.message( $+ %misc.items.list4,private) }  }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewMiscItems)) | if (%misc.items.list2 != $null) { $display.private.message(5 $+ %misc.items.list2) } | if (%misc.items.list3 != $null) { $display.private.message( $+ %misc.items.list3) } | if (%misc.items.list4 != $null) { $display.private.message( $+ %misc.items.list4) } }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMiscItems)) | if (%misc.items.list2 != $null) {  $dcc.private.message($nick,  $+ %misc.items.list2) } | if (%misc.items.list3 != $null) { $dcc.private.message($nick,  $+ %misc.items.list3) } | if (%misc.items.list4 != $null) { $dcc.private.message($nick,  $+ %misc.items.list4) } }
  }
  if (%mech.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewMechCoreItems),private) | if (%mech.items.list2 != $null) { $display.message( $+ %mech.items.list2) } } 
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewMechCoreItems)) | if (%mech.items.list2 != $null) { $display.private.message( $+ %mech.items.list2) } } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMechCoreItems)) | if (%mech.items.list2 != $null) {  $dcc.private.message($nick,  $+ %mech.items.list2) } }
  }
  if (%special.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewShopSpecialItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewShopSpecialItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewShopSpecialItems)) }
  }
  if (%trust.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewTrustItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewTrustItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewTrustItems)) }
  }
  if (%potioningredient.items.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewPotionIngredientItems),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewPotionIngredientItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewPotionIngredientItems)) }
  }

  if (((((((((((%items.list = $null) && (%statplus.items.list = $null) && (%summons.items.list = $null) && (%reset.items.list = $null) && (%gems.items.list = $null) && (%portals.items.list = $null) && (%mech.items.list = $null) && (%special.items.list = $null) && (%trust.items.list = $null) && (%potioningredient.items.list = $null) && (%misc.items.list = $null))))))))))) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoItems),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, HasNoItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoItems)) }
  }    

  unset %*.items.lis* | unset %items.lis*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's accessories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readaccessories {
  if (%accessories.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewAccessories),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewAccessories)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewAccessories)) }

    if (%accessories.list2 != $null) { 
      if ($2 = channel) {  $display.message(3 $+ %accessories.list2,private) }
      if ($2 = private) { $display.private.message(3 $+ %accessories.list2) }
      if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %accessories.list2) }
    }

    var %equipped.accessory $readini($char($1), equipment, accessory)
    if ((%equipped.accessory = $null) || (%equipped.accessory = none)) { 
      if ($2 = channel) {  $display.message($readini(translation.dat, system, HasNoEquippedAccessory),private) }
      if ($2 = private) {  $display.private.message($readini(translation.dat, system, HasNoEquippedAccessory)) }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoEquippedAccessory)) }
    }
    if ((%equipped.accessory != $null) && (%equipped.accessory != none)) {
      if ($2 = channel) { $display.message($readini(translation.dat, system, ViewEquippedAccessory),private) }
      if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewEquippedAccessory)) }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewEquippedAccessory)) }
    }
    unset %accessories.list 
  }
  else { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoAccessories),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, HasNoAccessories)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoAccessories)) } 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's songs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readsongs {
  if (%songs.list != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, Viewsongs),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, Viewsongs)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, Viewsongs)) }

    if (%songs.list2 != $null) { 
      if ($2 = channel) {  $display.message(3 $+ %songs.list2,private) }
      if ($2 = private) {  $display.private.message(3 $+ %songs.list2) }
      if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %songs.list2) }
    }
  }
  else { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNosongs),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNosongs)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNosongs)) } 
  }
  unset %songs.list 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readarmor {
  if (%armor.head != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewArmorHead),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewArmorHead)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorHead)) }
  }
  if (%armor.head2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.head2,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.head2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head2) }
  }
  if (%armor.head3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.head3,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.head3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head3) }
  }
  if (%armor.head4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.head4,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.head4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head4) }
  }

  if (%armor.body != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewArmorBody),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewArmorBody)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorBody)) }
  }
  if (%armor.body2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.body2,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.body2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body2) }
  }
  if (%armor.body3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.body3,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.body3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body3) }
  }
  if (%armor.body4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.body4,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.body4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body4) }
  }

  if (%armor.legs != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewArmorLegs),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewArmorLegs)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorLegs)) }
  }
  if (%armor.legs2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.legs2,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.legs2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs2) }
  }
  if (%armor.legs3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.legs3,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.legs3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs3) }
  }
  if (%armor.legs4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.legs4,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.legs4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs4) }
  }

  if (%armor.feet != $null) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, ViewArmorFeet),private) }
    if ($2 = private) {  $display.private.message($readini(translation.dat, system, ViewArmorFeet)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorFeet)) }
  }
  if (%armor.feet2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.feet2,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.feet2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet2) }
  }
  if (%armor.feet3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.feet3,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.feet3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet3) }
  }
  if (%armor.feet4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.feet4,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.feet4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet4) }
  }

  if (%armor.hands != $null) {
    if ($2 = channel) {  $display.message($readini(translation.dat, system, ViewArmorHands),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, ViewArmorHands)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorHands)) }
  }
  if (%armor.hands2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.hands2,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.hands2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands2) }
  }
  if (%armor.hands3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.hands3,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.hands3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands3) }
  }
  if (%armor.hands4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.hands4,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.hands4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands4) }
  }

  if (((((%armor.head = $null) && (%armor.body = $null) && (%armor.legs = $null) && (%armor.feet = $null) && (%armor.hands = $null))))) { 
    if ($2 = channel) { $display.message($readini(translation.dat, system, HasNoArmor),private) }
    if ($2 = private) { $display.private.message($readini(translation.dat, system, HasNoArmor)) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoArmor)) }
  }    

  unset %armor.head | unset %armor.body | unset %armor.legs | unset %armor.feet | unset %armor.hands | unset %armor.head2 | unset %armor.body2 | unset %armor.legs2 | unset %armor.feet2 | unset %armor.hands2
  unset %armor.head3 | unset %armor.body3 | unset %armor.legs3 | unset %armor.feet3 | unset %armor.hands3
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Equips a weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wield_weapon {
  if ($2 = right) { writeini $char($1) weapons equipped $3 }
  if ($2 = left) { writeini $char($1) weapons equippedLeft $3 }
  if ($2 = both) { writeini $char($1) weapons equipped $3 | remini $char($1) weapons equippedLeft }

  $set_chr_name($1) | $display.message($readini(translation.dat, system, EquipWeaponPlayer),private)

  $shadowclone.changeweapon($1, $2, $3)

  unset %weapon.equipped.right | unset %weapon.equipped.left | unset %weapon.equipped
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shadow Clone equips a wepon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shadowclone.changeweapon {
  var %cloneowner $readini($char($1 $+ _clone), info, cloneowner)

  if (%cloneowner = $null) { return }

  if ($readini($char($1 $+ _clone), battle, hp) = 0) { return }

  $set_chr_name($1 $+ _clone)
  if ($is_charmed($1 $+ _clone) = true) {  $display.message($readini(translation.dat, status, CurrentlyCharmed), battle) | halt }
  if ($is_confused($ $+ _clone) = true) { $display.message($readini(translation.dat, status, CurrentlyConfused), battle) | halt }
  if ($readini($char($1 $+ _clone), status, weapon.lock) != $null) { $display.message($readini(translation.dat, status, CurrentlyWeaponLocked), battle) | halt }

  if ($2 = both) {  writeini $char($1 $+ _clone) weapons equipped $3 | remini $char($1 $+ _clone) weapons equippedLeft }
  if ($2 = left) { writeini $char($1 $+ _clone) weapons equippedLeft $3 }
  if ($2 = right) { writeini $char($1 $+ _clone) weapons equipped $3 }

  $display.message($readini(translation.dat, system, EquipWeaponPlayer), battle) | halt 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Giving an item to a target
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gives.command {
  ; $1 = person giving item
  ; $2 = person receiving item
  ; $3 = amount being given
  ; $4 = item being given

  $set_chr_name($1)
  $check_for_battle($1) 
  $checkchar($2)

  if ($2 = $1) { $display.message($readini(translation.dat, errors, CannotGiveToYourself), private) | halt }


  if (((($4 = redorbs) || ($4 = currency) || ($4 = orb) || ($4 = orbs)))) { 
    $set_chr_name($1)
    ; If the target isn't an npc, we can't give orbs
    if ($readini($char($2), info, flag) != npc) { $display.message($readini(translation.dat, errors, CannotGiveOrbsToPlayers), private) | halt }

    ; If the target's AI isn't "PayToAttack" you can't give orbs to that npc.
    if ($readini($char($2), info, ai_type) != paytoattack) { $display.message($readini(translation.dat, errors, can'tGiveOrbsToThatChar), private) | halt }

    ; Does the player have enough orbs to give?
    var %player.orbs $readini($char($1), stuff, RedOrbs)
    if ((%player.orbs <= 0) || (%player.orbs = $null)) { $display.message($readini(translation.dat, errors, DoesNotHaveEnoughOrbsToTrade), private) | halt }
    if ($3 > %player.orbs) { $display.message($readini(translation.dat, errors, DoesNotHaveEnoughOrbsToTrade), private) | halt }

    ; check for the cap
    var %npc.orbs $readini($char($2), stuff, redorbs)
    if (($3 > 1000) || (%npc.orbs >= 1000)) {  $display.message($readini(translation.dat, errors, Can'tGiveMoreOrbsToNPC), private) | halt }

    ; give orbs to npcs
    if (%npc.orbs = $null) { var %npc.orbs 0 }
    inc %npc.orbs $3
    writeini $char($2) stuff redorbs %npc.orbs

    ; decrease player orbs
    dec %player.orbs $3
    writeini $char($1) stuff redorbs %player.orbs

    $display.message($readini(translation.dat, system, GiveOrbsToTarget), battle)
  }
  else { 
    var %flag $readini($char($2), Info, Flag)
    if (%flag != $null) { $display.message($readini(translation.dat, errors, Can'tGiveToNonChar), private) | halt }

    var %check.item.give $readini($char($1), Item_Amount, $4) 

    if ((%check.item.give <= 0) || (%check.item.give = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
    if ((. isin $3) || ($3 <= 0)) { $display.message($readini(translation.dat, errors, Can'tGiveNegativeItem), private) | halt }
    if ($3 > %check.item.give) { $display.message($readini(translation.dat, errors, CannotGiveThatMuchofItem), private) | halt }

    var %equipped.accessory $readini($char($1), equipment, accessory)
    if (%equipped.accessory = $4) {
      if (%check.item.give <= $3) { $display.message($readini(translation.dat, errors, StillWearingAccessory), private) | halt }
    }

    ; Check to see if it's a piece of armor that's equipped
    var %armor.equip.slot $readini($dbfile(equipment.db), $4, EquipLocation)

    var %equipped.armor $readini($char($1), equipment, %armor.equip.slot)
    if (%equipped.armor = $4) {
      if (%check.item.give = 1) { $display.private.message($readini(translation.dat, errors, StillWearingArmor)) | halt }
    }


    var %give.item.type $readini($dbfile(items.db), $4, type)
    if (%give.item.type != $null) { var %dbfile items.db }
    if (%give.item.type = $null) { var %dbfile equipment.db }

    var %exclusive.test $readini($dbfile(%dbfile), $4, exclusive)
    if (%exclusive.test = $null) { var %exclusive.test no }
    if (%exclusive.test = yes) { $display.message($readini(translation.dat, errors, CannotGiveItem), private) | halt }

    ; If so, decrease the amount
    dec %check.item.give $3
    writeini $char($1) item_amount $4 %check.item.give

    var %target.items $readini($char($2), item_amount, $4)
    inc %target.items $3 
    writeini $char($2) item_amount $4 %target.items

    var %item.to.give.correct $4
    if (($right($4, 1) = y) && ($3 > 1)) {  var %item.to.give.correct $replace(%item.to.give.correct, $right($4,1), ie)  } 

    $display.message($readini(translation.dat, system, GiveItemToTarget), global)

    var %number.of.items.given $readini($char($1), stuff, ItemsGiven)
    if (%number.of.items.given = $null) { var %number.of.items.given 0 }
    inc %number.of.items.given $3
    writeini $char($1) stuff ItemsGiven %number.of.items.given
    $achievement_check($1, Santa'sLittleHelper)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds a random augment
; to a weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reforge.weapon {
  ; $1 = user
  ; $2 = weapon

  $set_chr_name($1)
  ; Is it a battle?

  if ((%battleis = on) && ($istok($readini($txtfile(battle2.txt), Battle, List),$1,46) = $true))  { $display.message($readini(translation.dat, errors, Can'tReforgepInBattle), private) | halt }

  ; does the player own that weapon?
  var %player.weapon.check $readini($char($1), weapons, $2)

  if ((%player.weapon.check < 1) || (%player.weapon.check = $null)) {  $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveWeapon), private) | halt }

  ; does the player have enough black orbs to reforge it?
  var %reforge.cost $round($calc(2 * ($readini($dbfile(weapons.db), $2, cost))),0)
  var %player.blackorbs $readini($char($1), stuff, BlackOrbs)
  if (%player.blackorbs < %reforge.cost) { $display.message($readini(translation.dat, errors, NotEnoughBlackOrbs), private) | halt }

  ; Can we actually reforge this weapon?
  if ((%reforge.cost <= 0) || ($2 = fists)) { $display.message($readini(translation.dat, errors, Can'tReforgeThatWeapon), private) | halt }

  ; Does the player have enough RepairHammers?
  set %check.item $readini($char($1), Item_Amount, RepairHammer) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotHaveEnoughHammers), private) | halt }

  ; Augment the weapon
  set %total.augments $lines($lstfile(augments.lst))
  set %random.augment $rand(1, %total.augments)
  set %augment.name $read -l $+ %random.augment $lstfile(augments.lst)
  writeini $char($1) augments $2 %augment.name

  $set_chr_name($1)

  if (%battleis != on) { $display.message($readini(translation.dat, system, WeaponReforged), global) }
  if (%battleis = on) { $display.private.message($readini(translation.dat, system, WeaponReforged), global) }

  var %number.of.augments $readini($char($1), stuff, WeaponsReforged)
  if (%number.of.augments = $null) { var %number.of.augments 0 }
  inc %number.of.augments 1
  writeini $char($1) stuff WeaponsReforged %number.of.augments
  $achievement_check($1, HiHoHiHo)

  unset %augment.name | unset %total.augments | unset %random.augment

  ; Decrease the number of black orbs
  dec %player.blackorbs %reforge.cost
  writeini $char($1) stuff blackorbs %player.blackorbs
  $inc.blackorbsspent($1, %reforge.cost)

  ; Decrease the number of RepairHammers.
  $decrease_item($1, RepairHammer) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's augments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
augments.list {
  ; Check for augments
  unset %weapon.list | unset %augment.list |  unset %augment.list2 | unset %augment.list3 | unset %augment.list4
  $weapon.list($1)

  var %number.of.augments 0 | var %weapon.counter 1
  while ($weapons.returnlist(%weapon.counter) != $null) {
    set %display.weaponlist $weapons.returnlist(%weapon.counter)
    var %number.of.weapons $numtok(%display.weaponlist,46)
    var %value 1
    while (%value <= %number.of.weapons) {
      set %weapon.name $gettok(%display.weaponlist, %value, 46)
      set %weapon.name $gettok(%weapon.name,1, 40)
      set %weapon_augment $readini($char($1), augments, %weapon.name)

      if (%weapon_augment != $null) { 
        inc %number.of.augments 1
        var %weapon_to_add  %weapon.name $+ $chr(040) $+ %weapon_augment $+ $chr(041) $+ 

        if (%number.of.augments <= 13) {  %weapon.list = $addtok(%weapon.list,%weapon_to_add,46) }
        if ((%number.of.augments > 13) && (%number.of.augments <= 25)) { %augment.list2 = $addtok(%augment.list2, %weapon_to_add, 46) }
        if ((%number.of.augments > 25) && (%number.of.augments <= 40)) { %augment.list3 = $addtok(%augment.list3, %weapon_to_add, 46) }
        if (%number.of.augments > 40) { %augment.list4 = $addtok(%augment.list4, %weapon_to_add, 46) }
      }
      inc %value 1 
    }
    unset %value | unset %weapon.name | unset %weapon_level | unset %number.of.weapons

    $weapons.unsetlist(%weapon.counter) | unset %display.weaponlist
    inc %weapon.counter
    if (%weapon.counter > 100) { echo -a breaking to prevent a flood | break }
  }

  if (%weapon.list = $null) {
    if (($2 = $null) || ($2 = channel)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, NoAugments), private) } 
    if ($2 = private) {  $set_chr_name($1) | $display.private.message($readini(translation.dat, errors, NoAugments)) } 
    halt 
  }

  if ($chr(046) isin %weapon.list) { set %replacechar $chr(044) $chr(032)
    %weapon.list = $replace(%weapon.list, $chr(046), %replacechar)
    %augment.list2 = $replace(%augment.list2, $chr(046), %replacechar)
    %augment.list3 = $replace(%augment.list3, $chr(046), %replacechar)
    %augment.list4 = $replace(%augment.list4, $chr(046), %replacechar)
  }
  $set_chr_name($1) 

  if (($2 = $null) || ($2 = channel)) {
    $display.message($readini(translation.dat, system, ListOfAugments), private)
    if (%augment.list2 != $null) { $display.message(3 $+ %augment.list2, private) }
    if (%augment.list3 != $null) { $display.message(3 $+ %augment.list3, private) }
    if (%augment.list4 != $null) { $display.message(3 $+ %augment.list4, private) }
  }

  if ($2 = private) {  
    $display.private.message($readini(translation.dat, system, ListOfAugments))
    if (%augment.list2 != $null) { $display.private.message(3 $+ %augment.list2) }
    if (%augment.list3 != $null) { $display.private.message(3 $+ %augment.list3) }
    if (%augment.list4 != $null) { $display.private.message(3 $+ %augment.list4) }
  }
  unset %augment.list2 | unset %augment.list3 | unset %augment.list4
  unset %weapon.list | unset %base.weapon.list  | unset %weapons
  unset %weapon_augment | unset %mech.weapon.list | unset %mech.weaponlist2 | unset %replacechar

}

augments.strength {
  ; CHECKING AUGMENTS
  unset %augment.list | unset %augment.list.2 | unset %augment.list.3 | unset %weapon.list | unset %base.weapon.list  | unset %weapons
  unset %number.of.augments

  var %value 1 | var %augments.lines $lines($lstfile(augments.lst))
  if ((%augments.lines = $null) || (%augments.lines = 0)) { return }

  while (%value <= %augments.lines) {

    var %augment.name $read -l $+ %value $lstfile(augments.lst)

    if ($augment.check($1, %augment.name) = true) {

      inc %number.of.augments 1

      if (%number.of.augments <= 13) {  %augment.list = $addtok(%augment.list,%augment.name $+ [ $+ %augment.strength $+ ],46) }
      if ((%number.of.augments > 13) && (%number.of.augments <= 25)) { %augment.list.2 = $addtok(%augment.list.2, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
      if ((%number.of.augments > 25) && (%number.of.augments <= 40)) { %augment.list.3 = $addtok(%augment.list.3, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
      if (%number.of.augments > 40) { %augment.list.4 = $addtok(%augment.list.4, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
    }

    unset %augment.strength
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %augment.list ) { set %replacechar $chr(044) $chr(032)
    %augment.list = $replace(%augment.list, $chr(046), %replacechar)
  }
  if ($chr(046) isin %augment.list.2 ) { set %replacechar $chr(044) $chr(032)
    %augment.list.2 = $replace(%augment.list.2, $chr(046), %replacechar)
  }
  if ($chr(046) isin %augment.list.3 ) { set %replacechar $chr(044) $chr(032)
    %augment.list.3 = $replace(%augment.list.3, $chr(046), %replacechar)
  }
  if ($chr(046) isin %augment.list.4 ) { set %replacechar $chr(044) $chr(032)
    %augment.list.4 = $replace(%augment.list.4, $chr(046), %replacechar)
  }

  if (%augment.list != $null) { $set_chr_name($1) | $display.message($readini(translation.dat, system, augmentList), private)
    if (%augment.list.2 != $null) { $display.message(3 $+ %augment.list.2, private) }
    if (%augment.list.3 != $null) { $display.message(3 $+ %augment.list.3, private) }
    if (%augment.list.4 != $null) { $display.message(3 $+ %augment.list.4, private) }
  }
  if (%augment.list = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, system, Noaugments), private) }
  unset %augment.list | unset %augment.list.2 | unset %augment.list.3 | unset %augment.list.4
  unset %weapon.list | unset %base.weapon.list  | unset %weapons
}
