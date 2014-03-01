;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CHARACTER COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Create a new character

on 1:TEXT:!new char*:*: {  $checkscript($2-)
  if ($isfile($char($nick)) = $true) { query $nick $readini(translation.dat, system, PlayerExists) | halt }
  if ($isfile($char($nick $+ _clone)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($char(evil_ $+ $nick)) = $true)  { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($mon($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($boss($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt  }
  if ($isfile($npc($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($summon($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = $nick $+ _clone) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = evil_ $+ $nick) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = monster_warmachine) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = demon_wall) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = pirate_scallywag) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = pirate_firstmatey) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = bandit_leader) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = bandit_minion) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = crystal_shadow) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = alliedforces_president) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ((($nick = frost_monster) || ($nick = frost_monster1) || ($nick = frost_monster2))) { query $nick $readini(translation.dat, system, NameReserved) | halt }

  ; Check to see if the person already has multiple characters and get the total shop level at the same time
  /.dns $nick

  set %duplicate.ips 0
  set %current.shoplevel 0
  set %totalplayers 0
  set %current.shoplevel 0

  .echo -q $findfile( $char_path , *.char, 0 , 0, starting_character_checks $1-)

  var %max.chars $readini(system.dat, system, MaxCharacters) 
  if (%max.chars = $null) { var %max.chars 2 }
  if (%duplicate.ips >= %max.chars) { query %battlechan $readini(translation.dat, errors, Can'tHaveMoreThanTwoChars) | unset %ip.address. [ $+ [ $1 ] ] | halt }

  unset %ip.address. [ $+ [ $nick ] ]

  if (%current.shoplevel > 0) {  %current.shoplevel = $round($calc(%current.shoplevel / %totalplayers),1) 
    if (%current.shoplevel > 1.0) {  inc %current.shoplevel 1 }
  }
  else { inc %current.shoplevel 1 }

  var %starting.orbs $readini(system.dat, system, startingorbs)
  if (%starting.orbs = $null) { starting.orbs = 1000 } 
  %starting.orbs = $round($calc(%starting.orbs * %current.shoplevel),0) 

  ; Create the new character now
  .copy $char(new_chr) $char($nick)
  writeini $char($nick) BaseStats Name $nick 
  writeini $char($nick) Info Created $fulldate

  ;  Add the starting orbs to the new character..
  writeini $char($nick) Stuff RedOrbs %starting.orbs

  query %battlechan $readini(translation.dat, system, CharacterCreated)

  ; Generate a password
  set %password battlearena $+ $rand(1,100) $+ $rand(a,z)

  writeini $char($nick) info password $encode(%password)

  query $nick $readini(translation.dat, system, StartingCharOrbs)
  query $nick $readini(translation.dat, system, StartingCharPassword)

  ; Give voice
  mode %battlechan +v $nick

  if ($readini(system.dat, system, botType) = DCCchat) {  .auser 2 $nick | dcc chat $nick }
  if ($readini(system.dat, system, botType) = IRC) { .auser 3 $nick }

  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$nick,46) = $true) {  .auser 50 $nick }

  unset %ip.address. [ $+ [ $nick ] ] 
  unset %current.shoplevel |  unset %totalplayers | unset %password
  unset %duplicate.ips | unset %file | unset %name | unset %current.shoplevel | unset %totalplayers
}

alias starting_character_checks {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = $null) { return }
  if (%name = new_chr) { return }
  if ($readini($char(%name), info, flag) = npc) { return }
  if ($readini($char(%name), info, flag) = monster) { return }

  var %last.ip $readini($char(%name), info, lastIP) 
  if (%last.ip = %ip.address. [ $+ [ $nick ] ]) { inc %duplicate.ips 1 }

  var %temp.shoplevel $readini($char(%name), Stuff, ShopLevel)
  if (%temp.shoplevel = $null) { var %temp.shoplevel 1 }
  inc %current.shoplevel %temp.shoplevel

  inc %totalplayers 1

  unset %name | unset %file | unset %ip.address. [ $+ [ $1 ] ]
}


ON 2:TEXT:!newpass *:?:{ $checkscript($2-) | $password($nick) 
  if ($encode($2) = %password) {  writeini $char($nick) info password $encode($3) | .msg $nick $readini(translation.dat, system, newpassword) | unset %password | halt }
  if ($encode($2) != %password) { .msg $nick $readini(translation.dat, errors, wrongpassword) | unset %password | halt }
}

ON 1:TEXT:!id*:?:{ 
  $idcheck($nick , $2) | mode %battlechan +v $nick |  /.dns $nick |  /close -m* 
  if ($readini($char($nick), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($nick), info, CustomTitle) $+ " }
  if ($readini(system.dat, system, botType) = IRC) { $set_chr_name($nick) | query %battlechan 10 $+ %real.name %custom.title  $+  $readini($char($nick), Descriptions, Char) }
}
ON 1:TEXT:!quick id*:?:{ $idcheck($nick , $3, quickid) | mode %battlechan +v $nick |   /.dns $nick
  if ($readini(system.dat, system, botType) = IRC) { $set_chr_name($nick) }
  /close -m* 
}
on 3:TEXT:!logout*:*:{ .auser 1 $nick | mode %battlechan -v $nick | .flush 1 }
on 3:TEXT:!log out*:*:{ .auser 1 $nick | mode %battlechan -v $nick | .flush 1 }

alias idcheck { 
  if ($readini($char($1), info, flag) != $null) { .msg $nick $readini(translation.dat, errors, Can'tLogIntoThisChar) | halt }
  if ($readini($char($1), info, banned) = yes) { .msg $nick 4This character has been banned and cannot be used to log in. | halt }
  $passhurt($1) | $password($1)
  if (%password = $null) { unset %passhurt | unset %password |  .msg $nick $readini(translation.dat, errors, NeedToMakeACharacter) | halt }
  if ($2 = $null) { halt }
  else { 
    if ($encode($2) == %password) { $id_login($1) | unset %password | return }
    if ($encode($2) != %password)  { 
      if ((%passhurt = $null) || (%passhurt < 3)) {  .msg $1 $readini(translation.dat, errors, WrongPassword2) | inc %passhurt 1 | writeini $char($1) info passhurt %passhurt | unset %password | unset %passhurt | halt }
      else { kick %battlechan $1 $readini(translation.dat, errors, TooManyWrongPass)  | unset %passhurt | unset %password | writeini $char($1) Info passhurt 0 | halt } 
    }
  }
}

alias id_login {
  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$1, 46) = $true) {  .auser 50 $1
    if ($readini(system.dat, system, botType) = DCCchat) { 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }
  else { 
    if ($readini(system.dat, system, botType) = IRC) { .auser 3 $1 }
    if ($readini(system.dat, system, botType) = DCCchat) { .auser 2 $1 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }
  writeini $char($1) Info LastSeen $fulldate
  writeini $char($1) info passhurt 0 
  return
}

on 3:TEXT:!weather*:#: {  query %battlechan $readini(translation.dat, battle, CurrentWeather) }
on 3:TEXT:!weather*:?: {  .msg $nick $readini(translation.dat, battle, CurrentWeather) }

on 3:TEXT:!moon*:#: {  query %battlechan $readini(translation.dat, battle, CurrentMoon) }
on 3:TEXT:!moon*:?: {  .msg $nick $readini(translation.dat, battle, CurrentMoon) }

on 3:TEXT:!access *:*: {  
  if ($2 = add) { $character.access($nick, add, $3) }
  if ($2 = remove) { $character.access($nick, remove, $3) }
  if ($2 = list) { $character.access($nick, list) }
  if ($2 !isin add.remove.list) { .msg $nick $readini(translation.dat, errors, AccessCommandError) | halt } 
}

alias character.access {
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
      if ($3 != $1) { var %player.access.list $deltok(%player.access.list, $3,46) | writeini $char($1) access list %player.access.list | $display.private.message2($1, $readini(translation.dat, system, AccessCommandRemove)) | halt }
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

on 3:TEXT:!desc*:#: {  
  if ($2 != $null) { $checkchar($2) | $set_chr_name($2) | query %battlechan 3 $+ %real.name  $+ $readini($char($2), Descriptions, Char)   | unset %character.description | halt }
  else { $set_chr_name($nick) | query %battlechan 10 $+ %real.name  $+ $readini($char($nick), Descriptions, Char)  }
}
on 3:TEXT:!desc*:?: {  
  if ($2 != $null) { $checkchar($2) | $set_chr_name($2) | .msg $nick 3 $+ %real.name  $+ $readini($char($2), n, Descriptions, Char)   | unset %character.description | halt }
  else { $set_chr_name($nick) | .msg $nick 10 $+ %real.name  $+ $readini($char($nick), Descriptions, Char)  }
}
on 3:TEXT:!rdesc *:*:{ $checkchar($2) | $set_chr_name($2) | var %character.description $readini($char($2), Descriptions, Char) | query %battlechan 3 $+ %real.name $+ 's desc: %character.description | unset %character.description | halt }
on 3:TEXT:!cdesc *:*:{ $checkscript($2-)  | writeini $char($nick) Descriptions Char $2- | $okdesc($nick , Character) }
on 3:TEXT:!sdesc *:*:{ $checkscript($2-)  
  if ($readini($char($nick), skills, $2) != $null) { 
    writeini $char($nick) Descriptions $2 $3- | $okdesc($nick , Skill) 
  }
  if ($readini($char($nick), skills, $2) = $null) { .msg $nick $readini(translation.dat, errors, YouDoNotHaveSkill) | halt }
}
on 3:TEXT:!skill desc *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), skills, $3) != $null) { 
    writeini $char($nick) Descriptions $3 $4- | $okdesc($nick , Skill) 
  }
  if ($readini($char($nick), skills, $3) = $null) { .msg $nick $readini(translation.dat, errors, YouDoNotHaveSkill) | halt }
}

on 3:TEXT:!ignition desc *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), ignitions, $3) != $null) { 
    writeini $char($nick) Descriptions $3 $4- | $okdesc($nick , Ignition) 
  }
  if ($readini($char($nick), ignitions, $3) = $null) { .msg $nick $readini(translation.dat, errors, DoNotKnowThatIgnition) | halt }
}

on 3:TEXT:!clear desc *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if (($3 = character) || ($3 = char)) { var %description.to.clear char | writeini $char($nick) descriptions char needs to set a character description! | .msg $nick $readini(translation.dat, system, ClearDesc) }
  else { remini $char($nick) descriptions $3 | .msg $nick $readini(translation.dat, system, ClearDesc) }
}

on 3:TEXT:!set desc *:*:{ $checkscript($2-)  | writeini $char($nick) Descriptions Char $3- | $okdesc($nick , Character) }
on 3:TEXT:!setgender*:*: { $checkscript($2-)
  if ($2 = neither) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | .msg $nick $readini(translation.dat, system, SetGenderNeither) | unset %check | halt }
  if ($2 = none) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | .msg $nick $readini(translation.dat, system, SetGenderNeither)  | unset %check | halt }
  if ($2 = male) { writeini $char($nick) Info Gender his | writeini $char($nick) Info Gender2 him | .msg $nick $readini(translation.dat, system, SetGenderMale)  | unset %check | halt }
  if ($2 = female) { writeini $char($nick) Info Gender her | writeini $char($nick) Info Gender2 her | .msg $nick $readini(translation.dat, system, SetGenderFemale) | unset %check | halt }
  else { .msg $nick $readini(translation.dat, errors, NeedValidGender) | unset %check | halt }
}

on 3:TEXT:!level*:#: { $checkscript($2-)
  if ($1 = !leveladjust) { halt }
  if ($2 = $null) { $set_chr_name($nick) | var %player.level $bytes($round($get.level($nick),0),b) | query %battlechan $readini(translation.dat, system, ViewLevel) | unset %real.name }
  if ($2 != $null) { $checkscript($2-) | $checkchar($2) | $set_chr_name($2) | var %player.level $bytes($round($get.level($2),0),b) | query %battlechan $readini(translation.dat, system, ViewLevel) | unset %real.name }
}
on 3:TEXT:!level*:?: { 
  if ($1 = !leveladjust) { halt }
  if ($2 = $null) { $set_chr_name($nick) | var %player.level $bytes($round($get.level($nick),0),b) | .msg $nick $readini(translation.dat, system, ViewLevel) | unset %real.name }
  if ($2 != $null) { $checkscript($2-) | $checkchar($2) | $set_chr_name($2) | var %player.level $bytes($round($get.level($2),0),b) | .msg $nick $readini(translation.dat, system, ViewLevel) | unset %real.name }
}

on 3:TEXT:!hp:#: { 
  $set_chr_name($nick) | $hp_status_hpcommand($nick) 
  query %battlechan $readini(translation.dat, system, ViewMyHP) 

  if ($person_in_mech($nick) = true) { var %mech.name $readini($char($nick), mech, name) | $hp_mech_hpcommand($nick) 
    query %battlechan $readini(translation.dat, system, ViewMyMechHP) 
  }
  unset %real.name | unset %hstats 

}
on 3:TEXT:!hp:?: { 
  $set_chr_name($nick) | $hp_status_hpcommand($nick) 
  .msg $nick $readini(translation.dat, system, ViewMyHP) | unset %real.name | unset %hstats 

  if ($person_in_mech($nick) = true) { var %mech.name $readini($char($nick), mech, name) | $hp_mech_hpcommand($nick) 
    .msg $nick $readini(translation.dat, system, ViewMyMechHP) 
  }

}
on 3:TEXT:!battle hp:#: { 
  if (%battleis != on) { query %battlechan $readini(translation.dat, errors, NoBattleCurrently) }
  $build_battlehp_list
  query %battlechan %battle.hp.list  | unset %real.name | unset %hstats | unset %battle.hp.list
}
on 3:TEXT:!battle hp:?: { 
  if (%battleis != on) { query %battlechan $readini(translation.dat, errors, NoBattleCurrently) }
  $build_battlehp_list
  .msg $nick %battle.hp.list  | unset %real.name | unset %hstats | unset %battle.hp.list
}

on 3:TEXT:!tp:#:$set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewMyTP) | unset %real.name
on 3:TEXT:!tp:?:$set_chr_name($nick) | .msg $nick $readini(translation.dat, system, ViewMyTP) | unset %real.name
on 3:TEXT:!ig:#:$set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!ignition gauge:#:$set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!ig:?:$set_chr_name($nick) | .msg $nick $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!ignition gauge:?:$set_chr_name($nick) | .msg $nick $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!orbs*:#: { 
  if ($2 != $null) { $checkchar($2) | var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $set_chr_name($2) 

    var %showorbsinchannel $readini(system.dat, system,ShowOrbsCmdInChannel)
    if (%showorbsinchannel = $null) { var %showorbsinchannel true }
    if (%showorbsinchannel = true) { query %battlechan $readini(translation.dat, system, ViewOthersOrbs)  }
    else {  .msg $nick $readini(translation.dat, system, ViewOthersOrbs) }
  }
  else { var %orbs.spent $bytes($readini($char($nick), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($nick), stuff, BlackOrbsSpent),b) | $set_chr_name($nick) 

    var %showorbsinchannel $readini(system.dat, system,ShowOrbsCmdInChannel)
    if (%showorbsinchannel = $null) { var %showorbsinchannel true }
    if (%showorbsinchannel = true) { query %battlechan $readini(translation.dat, system, ViewMyOrbs)  }
    else {  .msg $nick $readini(translation.dat, system, ViewMyOrbs) }
  }
}
on 3:TEXT:!orbs*:?: { 
  if ($2 != $null) { $checkchar($2) | var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $set_chr_name($2) 
    .msg $nick $readini(translation.dat, system, ViewOthersOrbs) 
  }
  else { var %orbs.spent $bytes($readini($char($nick), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($nick), stuff, BlackOrbsSpent),b) | $set_chr_name($nick) 
    .msg $nick $readini(translation.dat, system, ViewMyOrbs)
  }
}

on 3:TEXT:!rorbs*:#: { var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $checkchar($2) | $set_chr_name($2) 
  var %showorbsinchannel $readini(system.dat, system,ShowOrbsCmdInChannel)
  if (%showorbsinchannel = $null) { var %showorbsinchannel true }
  if (%showorbsinchannel = true) { query %battlechan $readini(translation.dat, system, ViewOthersOrbs)  }
  else {  .msg $nick $readini(translation.dat, system, ViewOthersOrbs) }
}
on 3:TEXT:!rorbs*:?: { var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $checkchar($2) | $set_chr_name($2) 
  .msg $nick $readini(translation.dat, system, ViewOthersOrbs)
}

on 3:TEXT:!alliednotes*:#: {  
  if ($2 = $null) { $check.allied.notes($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, channel) }
}
on 3:TEXT:!allied notes*:#: {  
  if ($3 = $null) { $check.allied.notes($nick, channel) }
  if ($3 != $null) { $checkchar($3) | $check.allied.notes($3, channel) }
}
on 3:TEXT:!notes*:#: {  
  if ($2 = $null) { $check.allied.notes($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, channel) }
}
on 3:TEXT:!alliednotes*:?: {  
  if ($2 = $null) { $check.allied.notes($nick, private) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, private) }
}
on 3:TEXT:!allied notes*:?: {  
  if ($3 = $null) { $check.allied.notes($nick, private) }
  if ($3 != $null) { $checkchar($2) | $check.allied.notes($2, private) }
}
on 3:TEXT:!notes*:?: {  
  if ($2 = $null) { $check.allied.notes($nick, private) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, private) }
}

on 3:TEXT:!doubledollars*:#: {  
  if ($2 = $null) { $check.doubledollars($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $check.doubledollars($2, channel) }
}
on 3:TEXT:!doubledollars*:?: {  
  if ($2 = $null) { $check.doubledollars($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $check.doubledollars($2, channel) }
}

on 3:TEXT:!bet*:*: { $ai.battle.place.bet($nick, $2, $3) } 

on 3:TEXT:!stats*:*: { unset %all_status 
  if ($2 = $null) { 
    $battle_stats($nick) | $player.status($nick) | $weapon_equipped($nick) | .msg $nick $readini(translation.dat, system, HereIsYourCurrentStats) 
    var %equipped.accessory $readini($char($nick), equipment, accessory) 
    if (%equipped.accessory = $null) { var %equipped.accessory nothing }
    var %equipped.armor.head $readini($char($nick), equipment, head) 
    if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
    var %equipped.armor.body $readini($char($nick), equipment, body) 
    if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
    var %equipped.armor.legs $readini($char($nick), equipment, legs) 
    if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
    var %equipped.armor.feet $readini($char($nick), equipment, feet) 
    if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
    var %equipped.armor.hands $readini($char($nick), equipment, hands) 
    if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }

    var %blocked.meter $readini($char($nick), skills, royalguard.dmgblocked)
    if (%blocked.meter = $null) { var %blocked.meter 0 }

    /.timerDisplayStats1 $+ $nick 1 1  .msg $nick [4HP12 $readini($char($nick), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, HP) $+ 1] [4TP12 $readini($char($nick), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, TP) $+ 1] [4Ignition Gauge12 $readini($char($nick), Battle, IgnitionGauge) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, IgnitionGauge) $+ 1] [4Status12 %all_status $+ 1] [4Royal Guard Meter12 %blocked.meter $+ 1] 
    /.timerDisplayStats2 $+ $nick 1 1  .msg $nick [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1]
    /.timerDisplayStats3 $+ $nick 1 1  .msg $nick [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped $+ 1]  [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1]  [4 $+ $readini(translation.dat, system, CurrentArmorHeadEquipped) 12 $+ %equipped.armor.head $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorBodyEquipped) 12 $+ %equipped.armor.body $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorLegsEquipped) 12 $+ %equipped.armor.legs $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorFeetEquipped) 12 $+ %equipped.armor.feet $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHandsEquipped) 12 $+ %equipped.armor.hands $+ 1]
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped
  }
  else { 
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { query %battlechan $readini(translation.dat, errors, SkillCommandOnlyOnPlayers) | halt }
    $battle_stats($2) | $player.status($2) | $weapon_equipped($2) | .msg $nick $readini(translation.dat, system, HereIsOtherCurrentStats) 
    var %equipped.accessory $readini($char($2), equipment, accessory) 
    if (%equipped.accessory = $null) { var %equipped.accessory nothing }
    var %equipped.armor.head $readini($char($2), equipment, head) 
    if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
    var %equipped.armor.body $readini($char($2), equipment, body) 
    if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
    var %equipped.armor.legs $readini($char($2), equipment, legs) 
    if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
    var %equipped.armor.feet $readini($char($2), equipment, feet) 
    if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
    var %equipped.armor.hands $readini($char($2), equipment, hands) 
    if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }

    var %blocked.meter $readini($char($2), skills, royalguard.dmgblocked)
    if (%blocked.meter = $null) { var %blocked.meter 0 }

    /.timerDisplayStats1 $+ $nick 1 1  .msg $nick [4HP12 $readini($char($2), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, HP) $+ 1] [4TP12 $readini($char($2), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, TP) $+ 1] [4Ignition Gauge12 $readini($char($2), Battle, IgnitionGauge) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, IgnitionGauge) $+ 1] [4Status12 %all_status $+ 1] [4Royal Guard Meter12 %blocked.meter $+ 1] 
    /.timerDisplayStats2 $+ $nick 1 1  .msg $nick [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1]
    /.timerDisplayStats3 $+ $nick 1 1  .msg $nick [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped $+ 1]  [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHeadEquipped) 12 $+ %equipped.armor.head $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorBodyEquipped) 12 $+ %equipped.armor.body $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorLegsEquipped) 12 $+ %equipped.armor.legs $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorFeetEquipped) 12 $+ %equipped.armor.feet $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHandsEquipped) 12 $+ %equipped.armor.hands $+ 1]
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped
  }
}

on 3:TEXT:!misc info*:*: { 
  if ($3 = $null) { 
    var %misc.totalbattles $readini($char($nick), stuff, TotalBattles) |  var %misc.totaldeaths $readini($char($nick), stuff, TotalDeaths)
    var %misc.totalmonkills $readini($char($nick), stuff, MonsterKills) | var %misc.timesfled $readini($char($nick), stuff, timesFled)
    var %misc.discountsUsed $readini($char($nick), stuff, DiscountsUsed)  | var %misc.itemsgiven $readini($char($nick), stuff, ItemsGiven)
    var %misc.chestsopened $readini($char($nick), stuff, ChestsOpened) | var %misc.totalkeys $readini($char($nick), stuff, TotalNumberOfKeys)
    var %misc.revivedtimes $readini($char($nick), stuff, RevivedTimes) | var %misc.monstersToGems $readini($char($nick), stuff, MonstersToGems)
    var %misc.lostSoulsKilled $readini($char($nick), stuff, lostSoulsKilled) | var %misc.itemssold $readini($char($nick), stuff, ItemsSold)
    var %misc.resets $readini($char($nick), stuff, NumberOfResets) | var %misc.augments $readini($char($nick), stuff, WeaponsAugmented)
    var %misc.portalswon $readini($char($nick), stuff, PortalBattlesWon) |  var %misc.timeshitbybattlefield $readini($char($nick), stuff, TimesHitByBattlefieldEvent)
    var %misc.ignitionsused $readini($char($nick), stuff, IgnitionsUsed) |  var %misc.timesdodged $readini($char($nick), stuff, TimesDodged)
    var %misc.timescountered $readini($char($nick), stuff, TimesCountered) |  var %misc.timesparried $readini($char($nick), stuff, TimesParried)
    var %misc.lightspells $readini($char($nick), stuff, LightSpellsCasted) |   var %misc.darkspells $readini($char($nick), stuff, DarkSpellsCasted)
    var %misc.earthspells $readini($char($nick), stuff, EarthSpellsCasted) |   var %misc.firespells $readini($char($nick), stuff, FireSpellsCasted)
    var %misc.windspells $readini($char($nick), stuff, WindSpellsCasted) |  var %misc.waterspells $readini($char($nick), stuff, WaterSpellsCasted)
    var %misc.icespells $readini($char($nick), stuff, IceSpellsCasted)  |  var %misc.lightningspells $readini($char($nick), stuff, LightningSpellsCasted)
    var %misc.bloodspirit $readini($char($nick), stuff, BloodSpiritTimes) | var %misc.bloodboost $readini($char($nick), stuff, BloodBoostTimes) 
    var %misc.defenderwon $readini($char($nick), stuff, BattlesWonWithDefender) | var %misc.aggressorwon $readini($char($nick), stuff, BattlesWonWithAggressor)
    var %misc.reforges $readini($char($nick), stuff, WeaponsReforged) | var %misc.totalbets $readini($char($nick), stuff, totalBets) | var %misc.totalbetamount $readini($char($nick), stuff, TotalBetAmount) 
    var %misc.totalauctionbids $readini($char($nick), stuff, AuctionBids) | var %misc.totalauctionswon $readini($char($nick), stuff, AuctionWins)

    var %misc.target your
    .msg $nick $readini(translation.dat, system, HereIsMiscInfo) 
  }

  if ($3 != $null) {
    $checkchar($3) 
    var %misc.totalbattles $readini($char($3), stuff, TotalBattles) |  var %misc.totaldeaths $readini($char($3), stuff, TotalDeaths)
    var %misc.totalmonkills $readini($char($3), stuff, MonsterKills) | var %misc.timesfled $readini($char($3), stuff, timesFled)
    var %misc.discountsUsed $readini($char($3), stuff, DiscountsUsed)  | var %misc.itemsgiven $readini($char($3), stuff, ItemsGiven)
    var %misc.chestsopened $readini($char($3), stuff, ChestsOpened) | var %misc.totalkeys $readini($char($3), stuff, TotalNumberOfKeys)
    var %misc.revivedtimes $readini($char($3), stuff, RevivedTimes) | var %misc.monstersToGems $readini($char($3), stuff, MonstersToGems)
    var %misc.lostSoulsKilled $readini($char($3), stuff, lostSoulsKilled) | var %misc.itemssold $readini($char($3), stuff, ItemsSold)
    var %misc.resets $readini($char($3), stuff, NumberOfResets) | var %misc.augments $readini($char($3), stuff, WeaponsAugmented)
    var %misc.portalswon $readini($char($3), stuff, PortalBattlesWon) |  var %misc.timeshitbybattlefield $readini($char($3), stuff, TimesHitByBattlefieldEvent)
    var %misc.ignitionsused $readini($char($3), stuff, IgnitionsUsed) |  var %misc.timesdodged $readini($char($3), stuff, TimesDodged)
    var %misc.timescountered $readini($char($3), stuff, TimesCountered) |  var %misc.timesparried $readini($char($3), stuff, TimesParried)
    var %misc.lightspells $readini($char($3), stuff, LightSpellsCasted) |   var %misc.darkspells $readini($char($3), stuff, DarkSpellsCasted)
    var %misc.earthspells $readini($char($3), stuff, EarthSpellsCasted) |   var %misc.firespells $readini($char($3), stuff, FireSpellsCasted)
    var %misc.windspells $readini($char($3), stuff, WindSpellsCasted) |  var %misc.waterspells $readini($char($3), stuff, WaterSpellsCasted)
    var %misc.icespells $readini($char($3), stuff, IceSpellsCasted)  |  var %misc.lightningspells $readini($char($3), stuff, LightningSpellsCasted)
    var %misc.bloodspirit $readini($char($3), stuff, BloodSpiritTimes) | var %misc.bloodboost $readini($char($3), stuff, BloodBoostTimes) 
    var %misc.defenderwon $readini($char($3), stuff, BattlesWonWithDefender) | var %misc.aggressorwon $readini($char($3), stuff, BattlesWonWithAggressor)
    var %misc.reforges $readini($char($3), stuff, WeaponsReforged) | var %misc.totalbets $readini($char($3), stuff, totalBets) | var %misc.totalbetamount $readini($char($3), stuff, TotalBetAmount) 
    var %misc.totalauctionbids $readini($char($3), stuff, AuctionBids) | var %misc.totalauctionswon $readini($char($3), stuff, AuctionWins)

    var %misc.target $3 $+ 's
    .msg $nick $readini(translation.dat, system, HereIsMiscInfo) 
  }

  if (%misc.totalbattles = $null) { var %misc.totalbattles 0 }
  if (%misc.totaldeaths = $null) { var %misc.totaldeaths 0 }
  if (%misc.totalmonkills = $null) { var %misc.totalmonkills 0 }
  if (%misc.timesfled = $null) { var %misc.timesfled 0 }
  if (%misc.lostSoulsKilled = $null) { var %misc.lostSoulsKilled 0 }
  if (%misc.discountsUsed = $null) { var %misc.discountsUsed 0 }
  if (%misc.itemsgiven = $null) { var %misc.itemsgiven 0 }
  if (%misc.chestsopened = $null) { var %misc.chestsopened 0 }
  if (%misc.totalkeys = $null) { var %misc.totalkeys 0 }
  if (%misc.revivedtimes = $null) { var %misc.revivedtimes 0 }
  if (%misc.monstersToGems = $null) { var %misc.monstersToGems 0 }
  if (%misc.itemssold = $null) { var %misc.itemssold 0 }
  if (%misc.resets = $null) { var %misc.resets 0 }
  if (%misc.augments = $null) { var %misc.augments 0 }
  if (%misc.reforges = $null) { var %misc.reforges 0 }
  if (%misc.portalswon = $null) { var %misc.portalswon 0 }
  if (%misc.timeshitbybattlefield = $null) { var %misc.timeshitbybattlefield 0 }
  if (%misc.ignitionsused = $null) { var %misc.ignitionsused 0 } 
  if (%misc.timesdodged = $null) { var %misc.timesdodged 0 }
  if (%misc.timescountered = $null) { var %misc.timescountered 0 }
  if (%misc.timesparried = $null) { var %misc.timesparried 0 }
  if (%misc.lightspells = $null) { var %misc.lightspells 0 }
  if (%misc.darkspells = $null) { var %misc.darkspells 0 }
  if (%misc.earthspells = $null) { var %misc.earthspells 0 }
  if (%misc.firespells = $null) { var %misc.firespells 0 }
  if (%misc.windspells = $null) { var %misc.windspells 0 }
  if (%misc.waterspells = $null) { var %misc.waterspells 0 }
  if (%misc.icespells = $null) { var %misc.icespells 0 }
  if (%misc.lightningspells = $null) { var %misc.lightningspells 0 }
  if (%misc.bloodspirit = $null) { var %misc.bloodspirit 0 }
  if (%misc.bloodboost = $null) { var %misc.bloodboost 0 }
  if (%misc.defenderwon = $null) { var %misc.defenderwon 0 }
  if (%misc.aggressorwon = $null) { var %misc.aggressorwon 0 }
  if (%misc.totalbets = $null) { var %misc.totalbets 0 }
  if (%misc.totalbetamount = $null) { var %misc.totalbetamount 0 }
  if (%misc.totalauctionbids = $null) { var %misc.totalauctionbids 0 }
  if (%misc.totalauctionswon = $null) { var %misc.totalauctionswon 0 }

  var %currency.symbol $readini(system.dat, system, BetCurrency)
  if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }

  /.timerDisplayStats1 $+ $nick 1 1  .msg $nick [4Total Battles Participated In12 %misc.totalbattles $+ 1] [4Total Portal Battles Won12 %misc.portalswon $+ 1] [4Total Deaths12 %misc.totaldeaths $+ 1] [4Total Monster Kills12 %misc.totalmonkills $+ 1] [4Total Times Fled12 %misc.timesfled $+ 1][4Total Lost Souls Killed12 %misc.lostSoulsKilled $+ 1] [4Total Times Revived12 %misc.revivedtimes $+ 1] [4Total Times Character Has Been Reset12 %misc.resets $+ 1]
  /.timerDisplayStats2 $+ $nick 1 1  .msg $nick [4Total Items Sold12 %misc.itemssold $+ 1] [4Total Discounts Used12 %misc.discountsUsed $+ 1] [4Total Items Given12 %misc.itemsgiven $+ 1] [4Total Keys Obtained12 %misc.totalkeys $+ 1] [4Total Chests Opened12 %misc.chestsopened $+ 1][4Total Monster->Gem Conversions12 %misc.monstersToGems $+ 1]
  /.timerDisplayStats3 $+ $nick 1 1  .msg $nick [4Total Battlefield Events Experienced12 %misc.timeshitbybattlefield $+ 1]  [4Total Weapons Augmented12 %misc.augments $+ 1] [4Total Weapons Reforged12 %misc.reforges $+ 1] [4Total Ignitions Performed12 %misc.ignitionsused $+ 1] [4Total Dodges Performed12 %misc.timesdodged $+ 1] [4Total Parries Performed12 %misc.timesparried $+ 1] [4Total Counters Performed12 %misc.timescountered $+ 1] 
  /.timerDisplayStats4 $+ $nick 1 1  .msg $nick [4Total Light Spells Casted12 %misc.lightspells $+ 1] [4Total Dar Spells Casted12 %misc.darkspells $+ 1] [4Total Earth Spells Casted12 %misc.earthspells $+ 1] [4Total Fire Spells Casted12 %misc.firespells $+ 1] [4Total Wind Spells Casted12 %misc.windspells $+ 1] [4Total Water Spells Casted12 %misc.waterspells $+ 1] [4Total Ice Spells Casted12 %misc.icespells $+ 1] [4Total Lightning Spells Casted12 %misc.lightningspells $+ 1]
  /.timerDisplayStats4 $+ $nick 1 1  .msg $nick [4Total Times Won Under Defender12 %misc.defenderwon $+ 1] [4Total Times Won Under Aggressor12 %misc.aggressorwon $+ 1] [4Total Blood Boosts Performed12 %misc.bloodboost $+ 1] [4Total Blood Spirits Performed12 %misc.bloodspirit $+ 1]
  /.timerDisplayStats4 $+ $nick 1 1  .msg $nick [4Total 1vs1 NPC Bets Placed12 %misc.totalbets $+ 1] [4Total Amount of Double Dollars Bet12 %currency.symbol $bytes(%misc.totalbetamount,b) $+ 1]  [4Total Bids Placed12 %misc.totalauctionbids $+ 1] [4Total Auctions Won12 %misc.totalauctionswon $+ 1]
}


on 3:TEXT:!look*:#: { unset %all_status 
  if ($2 = $null) { $lookat($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $lookat($2, channel) }
}
on 3:TEXT:!look*:?: { unset %all_status 
  if ($2 = $null) { $lookat($nick, private) }
  if ($2 != $null) { $checkchar($2) | $lookat($2, private) }
}

on 3:TEXT:!weapons*:#: {  unset %*.wpn.list | unset %weapon.list
  if ($2 = $null) { $weapon.list($nick) | set %wpn.lst.target $nick }
  else { $checkchar($2) | $weapon.list($2) | set %wpn.lst.target $2 }
  /.timerDisplayWeaponList $+ $nick 1 3 /display_weapon_lists %wpn.lst.target channel
}
on 3:TEXT:!rweapons*:#: { $checkchar($2) | $weapon.list($2)  | $set_chr_name($2) 
  /.timerDisplayWeaponList $+ $2 1 3 /display_weapon_lists $2 channel
}
on 3:TEXT:!weapons*:?: {  unset %*.wpn.list | unset %weapon.list
  if ($2 = $null) { $weapon.list($nick) | set %wpn.lst.target $nick }
  else { $checkchar($2) | $weapon.list($2) | set %wpn.lst.target $2 }
  /.timerDisplayWeaponList $+ $nick 1 3 /display_weapon_lists %wpn.lst.target private $nick
}
on 3:TEXT:!rweapons*:?: { $checkchar($2) | $weapon.list($2)  | $set_chr_name($2) 
  /.timerDisplayWeaponList $+ $nick 1 3 /display_weapon_lists $2 private $nick
}
alias display_weapon_lists {  $set_chr_name($1) 
  if ($2 = channel) { 
    query %battlechan $readini(translation.dat, system, ViewWeaponList)
    if (%weapon.list2 != $null) { query %battlechan 3 $+ %weapon.list2 }
    if (%weapon.list3 != $null) { query %battlechan 3 $+ %weapon.list3 }
    if (%weapon.list4 != $null) { query %battlechan 3 $+ %weapon.list4 }
  }
  if ($2 = private) {
    .msg $3 $readini(translation.dat, system, ViewWeaponList)
    if (%weapon.list2 != $null) { .msg $3 3 $+ %weapon.list2 }
    if (%weapon.list3 != $null) { .msg $3 3 $+ %weapon.list3 }
    if (%weapon.list4 != $null) { .msg $3 3 $+ %weapon.list4 }
  }
  if ($2 = dcc) { 
    $dcc.private.message($3, $readini(translation.dat, system, ViewWeaponList))
    if (%weapon.list2 != $null) { $dcc.private.message($3, 3 $+ %weapon.list2) }
    if (%weapon.list3 != $null) { $dcc.private.message($3, 3 $+ %weapon.list3) }
    if (%weapon.list4 != $null) { $dcc.private.message($3, 3 $+ %weapon.list4) }
  }
  unset %wpn.lst.target | unset %base.weapon.list | unset %weapons | unset %weapon.list  | unset %weapon.list2 | unset %weapon.list3
}

on 3:TEXT:!style*:*: {  unset %*.style.list | unset %style.list
  if ($2 = $null) { 
    ; Get and show the list
    $styles.list($nick)
    set %current.playerstyle $readini($char($nick), styles, equipped)
    set %current.playerstyle.xp $readini($char($nick), styles, %current.playerstyle $+ XP)
    set %current.playerstyle.level $readini($char($nick), styles, %current.playerstyle)
    var %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)
    if (%current.playerstyle.level >= 10) {   $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewCurrentStyleMaxed) }
    if (%current.playerstyle.level < 10) {   $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewCurrentStyle) }
    query %battlechan $readini(translation.dat, system, ViewStyleList)
    unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle
  }
  if ($2 = change) { $style.change($nick, $2, $3) }
}

ON 50:TEXT:*style change to *:*:{ 
  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  $style.change($1, $3, $5)
} 

ON 3:TEXT:*style change to *:*:{ 
  if ($2 != style) { halt }
  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  $style.change($1, $3, $5)
} 
alias style.change { 
  if ($2 = change) && ($3 = $null) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, SpecifyStyle) | halt }
  if ($2 = change) && ($3 != $null) {  
    var %valid.styles.list $readini($dbfile(playerstyles.db), styles, list)
    if ($istok(%valid.styles.list, $3, 46) = $false) { query %battlechan $readini(translation.dat, errors, InvalidStyle) | halt }
    var %current.playerstylelevel $readini($char($1), styles, $3)
    if ((%current.playerstylelevel = $null) || (%current.playerstylelevel = 0)) { $set_chr_name($1) 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, errors, DoNotKnowThatStyle) }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.private.message($nick, $readini(translation.dat, errors, DoNotKnowThatStyle)) }
      halt
    }

    $check_for_battle($1)

    ; finally, switch to it.
    $set_chr_name($1) | writeini $char($1) styles equipped $3 
    if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, system, SwitchStyles) }
    if ($readini(system.dat, system, botType) = DCCchat) {  
      if (%battleis = off) { $dcc.private.message($nick, $readini(translation.dat, system, SwitchStyles)) }
      if (%battleis = on) { $dcc.battle.message($readini(translation.dat, system, SwitchStyles)) }
    }

    unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle

    ; if the battle is on..
    if (%battleis = on) {  $check_for_double_turn($1)   }
  }
}
on 3:TEXT:!xp*:#: {  unset %*.style.list | unset %style.list
  if ($2 != $null) { $checkchar($2) | $show.stylexp($2, channel) }
  if ($2 = $null) { $show.stylexp($nick, channel) }
}
on 3:TEXT:!xp*:?: {  unset %*.style.list | unset %style.list
  if ($2 != $null) { $checkchar($2) | $show.stylexp($2, private) }
  if ($2 = $null) { $show.stylexp($nick, private) }
}

alias show.stylexp {
  ; Get and show the list
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.xp $readini($char($1), styles, %current.playerstyle $+ XP)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  var %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)
  $set_chr_name($1) 
  if (%current.playerstyle.level >= 10) {   
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewCurrentStyleMaxed) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewCurrentStyleMaxed) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyleMaxed)) }
  }
  if (%current.playerstyle.level < 10) {   
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewCurrentStyle) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewCurrentStyle) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyle)) }
  }
  unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle
}

on 3:TEXT:!techs*:#: { 
  if ($2 = $null) { $weapon_equipped($nick) | $tech.list($nick, %weapon.equipped) | $set_chr_name($nick) 
    if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewMyTechs) }
    if (%ignition.tech.list != $null) { query %battlechan $readini(translation.dat, system, ViewMyIgnitionTechs) }
    if ((%techs.list = $null) && (%ignition.tech.list = $null)) { query %battlechan $readini(translation.dat, system, NoTechsForMe)  }
  }
  else { $checkchar($2) | $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) 
    if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
    if (%ignition.tech.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersIgnitionTechs) }
    if ((%techs.list = $null) && (%ignition.tech.list = $null)) { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
  }

  unset %tech.count | unset %tech.power | unset %replacechar | unset %tech.list | unset %techs.list
}
on 3:TEXT:!techs*:?: { 
  if ($2 = $null) { $weapon_equipped($nick) | $tech.list($nick, %weapon.equipped) | $set_chr_name($nick) 
    if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewMyTechs) }
    if (%ignition.tech.list != $null) { .msg $nick $readini(translation.dat, system, ViewMyIgnitionTechs) }
    if ((%techs.list = $null) && (%ignition.tech.list = $null)) { .msg $nick $readini(translation.dat, system, NoTechsForMe)  }
  }
  else { $checkchar($2) | $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) 
    if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewOthersTechs) }
    if (%ignition.tech.list != $null) {  .msg $nick $readini(translation.dat, system, ViewOthersIgnitionTechs) }
    if ((%techs.list = $null) && (%ignition.tech.list = $null)) { .msg $nick $readini(translation.dat, system, NoTechsForOthers) }
  }
  unset %tech.count | unset %tech.power | unset %replacechar | unset %tech.list | unset %techs.list
}

on 3:TEXT:!readtechs*:#: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
  if (%ignition.tech.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersIgnitionTechs) }
  if ((%techs.list = $null) && (%ignition.tech.list = $null)) { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
  unset %tech.count | unset %tech.power | unset %replacechar | unset %tech.list | unset %techs.list
}
on 3:TEXT:!rtechs*:#: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
  if (%ignition.tech.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersIgnitionTechs) }
  if ((%techs.list = $null) && (%ignition.tech.list = $null)) { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
  unset %tech.count | unset %tech.power | unset %replacechar | unset %tech.list | unset %techs.list
}
on 3:TEXT:!readtechs*:?: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewOthersTechs) }
  if (%ignition.tech.list != $null) {  .msg $nick $readini(translation.dat, system, ViewOthersIgnitionTechs) }
  if ((%techs.list = $null) && (%ignition.tech.list = $null)) { .msg $nick $readini(translation.dat, system, NoTechsForOthers) }
  unset %tech.count | unset %tech.power | unset %replacechar | unset %tech.list | unset %techs.list
}
on 3:TEXT:!rtechs*:?: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewOthersTechs) }
  if (%ignition.tech.list != $null) {  .msg $nick $readini(translation.dat, system, ViewOthersIgnitionTechs) }
  if ((%techs.list = $null) && (%ignition.tech.list = $null)) { .msg $nick $readini(translation.dat, system, NoTechsForOthers) }
  unset %tech.count | unset %tech.power | unset %replacechar | unset %tech.list | unset %techs.list
}

on 3:TEXT:!ignitions*:#:{ 
  if ($2 = $null) { $ignition.list($nick) | $set_chr_name($nick) 
    if (%ignitions.list != $null) { query %battlechan $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { query %battlechan $readini(translation.dat, system, NoIgnitions)  }
  }
  else { $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
    if (%ignitions.list != $null) { query %battlechan $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { query %battlechan $readini(translation.dat, system, NoIgnitions)  }
  }
}
on 3:TEXT:!readignitions*:#: {
  $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
  if (%ignitions.list != $null) { query %battlechan $readini(translation.dat, system, ViewIgnitions) }
  else { query %battlechan $readini(translation.dat, system, NoIgnitions)  }
}
on 3:TEXT:!ignitions*:?:{ 
  if ($2 = $null) { $ignition.list($nick) | $set_chr_name($nick) 
    if (%ignitions.list != $null) { .msg $nick $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { .msg $nick $readini(translation.dat, system, NoIgnitions)  }
  }
  else { $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
    if (%ignitions.list != $null) { .msg $nick $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { .msg $nick $readini(translation.dat, system, NoIgnitions)  }
  }
}
on 3:TEXT:!readignitions*:?: {
  $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
  if (%ignitions.list != $null) { .msg $nick $readini(translation.dat, system, ViewIgnitions) }
  else { .msg $nick $readini(translation.dat, system, NoIgnitions)  }
}

on 3:TEXT:!skills*:#: { 
  if ($2 != $null) { $checkchar($2) | $skills.list($2) | $set_chr_name($2) | $readskills($2, channel)  }
  else { $skills.list($nick) | $set_chr_name($nick) | $readskills($nick, channel) }
}
on 3:TEXT:!skills*:?: { 
  if ($2 != $null) { $checkchar($2) | $skills.list($2) | $set_chr_name($2) | $readskills($2, private)  }
  else { $skills.list($nick) | $set_chr_name($nick) | $readskills($nick, private) }
}
on 3:TEXT:!rskills*:#: { $readskills($2, channel) }
on 3:TEXT:!readskills*:#: { $readskills($2,private) }
on 3:TEXT:!rskills*:?: { $readskills($2, channel) }
on 3:TEXT:!readskills*:?: { $readskills($2,private) }

alias readskills {
  $checkchar($1) | $skills.list($1) | $set_chr_name($1) 

  if (%passive.skills.list != $null) { 
    if ($2 = channel) { 
      query %battlechan $readini(translation.dat, system, ViewPassiveSkills) 
      if (%passive.skills.list2 != $null) { query %battlechan 3 $+ %passive.skills.list2 }
    }
    if ($2 = private) {
      .msg $nick $readini(translation.dat, system, ViewPassiveSkills) 
      if (%passive.skills.list2 != $null) { .msg $nick 3 $+ %passive.skills.list2 }
    }
    if ($2 = dcc) {
      $dcc.private.message($nick, $readini(translation.dat, system, ViewPassiveSkills))
      if (%passive.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %passive.skills.list2) }
    }

  }
  if (%active.skills.list != $null) { 
    if ($2 = channel) { 
      query %battlechan $readini(translation.dat, system, ViewActiveSkills) 
      if (%active.skills.list2 != $null) { query %battlechan 3 $+ %active.skills.list2 }
    }
    if ($2 = private) {
      .msg $nick $readini(translation.dat, system, ViewActiveSkills)
      if (%active.skills.list2 != $null) { .msg $nick 3 $+ %active.skills.list2 }
    }
    if ($2 = dcc) {
      $dcc.private.message($nick, $readini(translation.dat, system, ViewActiveSkills))
      if (%active.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %active.skills.list2) }
    }
  }

  if (%resists.skills.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewResistanceSkills)  }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewResistanceSkills)  }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewResistanceSkills))  }
  }

  if (%killer.skills.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewKillerTraitSkills)  }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewKillerTraitSkills)  }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewKillerTraitSkills))  }
  }

  if ((((%passive.skills.list = $null) && (%active.skills.list = $null) && (%killer.skills.list = $null) && (%resists.skills.list = $null)))) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoSkills)   }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoSkills)   }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoSkills)) }
  }
  unset %passive.skills.list | unset %active.skills.list | unset %active.skills.list2 | unset %resists.skills.list | unset %killer.skills.list
}
on 3:TEXT:!keys*:#:{ 
  if ($2 != $null) { $checkchar($2) | $keys.list($2) | $set_chr_name($2) | $readkeys($2, channel) }
  else {  $keys.list($nick) | $set_chr_name($nick) | $readkeys($nick, channel) }
}
on 3:TEXT:!keys*:?:{ 
  if ($2 != $null) { $checkchar($2) | $keys.list($2) | $set_chr_name($2) | $readkeys($2, private) }
  else {  $keys.list($nick) | $set_chr_name($nick) | $readkeys($nick, private) }
}

alias readkeys {
  if (%keys.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewKeysItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewKeysItems) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewKeysItems)) }
  } 
  else { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoKeys) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoKeys) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoKeys)) }
  }    
}

on 3:TEXT:!gems*:#:{ 
  if ($2 != $null) { $checkchar($2) | $gems.list($2) | $set_chr_name($2) | $readgems($2, channel) }
  else {  $gems.list($nick) | $set_chr_name($nick) | $readgems($nick, channel) }
}
on 3:TEXT:!gems*:?:{ 
  if ($2 != $null) { $checkchar($2) | $gems.list($2) | $set_chr_name($2) | $readgems($2, private) }
  else {  $gems.list($nick) | $set_chr_name($nick) | $readgems($nick, private) }
}

alias readgems {
  if (%gems.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewGemItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewGemItems) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewGemItems)) }
  } 
  else { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoGems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoGems) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoGems)) }
  }    
}

on 3:TEXT:!seals*:#:{ 
  if ($2 != $null) { $checkchar($2) | $seals.list($2) | $set_chr_name($2) | $readseals($2, channel) }
  else {  $seals.list($nick) | $set_chr_name($nick) | $readseals($nick, channel) }
}
on 3:TEXT:!seals*:?:{ 
  if ($2 != $null) { $checkchar($2) | $seals.list($2) | $set_chr_name($2) | $readseals($2, private) }
  else {  $seals.list($nick) | $set_chr_name($nick) | $readseals($nick, private) }
}

alias readseals {
  if (%seals.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewSealItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewSealItems) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewSealItems)) }
  } 
  else { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoSeals) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoSeals) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoSeals)) }
  }    

  unset %seals.items.list
}

on 3:TEXT:!items*:#:{ 
  if ($2 != $null) { $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, channel) }
  else {  $items.list($nick) | $set_chr_name($nick) | $readitems($nick, channel) }
}
on 3:TEXT:!ritems*:#:{ $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, channel) }
on 3:TEXT:!items*:?:{ 
  if ($2 != $null) { $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, private) }
  else {  $items.list($nick) | $set_chr_name($nick) | $readitems($nick, private) }
}
on 3:TEXT:!ritems*:?:{ $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, private) }

alias readitems {
  if (%items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewItems)) }
  }
  if (%items.list2 != $null) { 
    if ($2 = channel) { query %battlechan %items.list2 }
    if ($2 = private) { .msg $nick %items.list2 }
    if ($2 = dcc) { $dcc.private.message($nick, %items.list2) }
  }
  if (%statplus.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewStatPlusItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewStatPlusItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewStatPlusItems)) }
  }
  if (%summons.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewSummonItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewSummonItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewSummonItems)) }
  }
  if (%summons.items.list2 != $null) { 
    if ($2 = channel) { query %battlechan %summons.items.list2 }
    if ($2 = private) { .msg $nick %summons.items.list2 }
    if ($2 = dcc) { $dcc.private.message($nick, %summons.items.list2) }
  }
  if (%reset.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewShopResetItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewShopResetItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewShopResetItems)) }
  }
  if (%portals.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewPortalItems) } 
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewPortalItems) } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewPortalItems)) }
  }
  if (%misc.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewMiscItems) | if (%misc.items.list2 != $null) { query %battlechan  $+ %misc.items.list2 } | if (%misc.items.list3 != $null) { query %battlechan  $+ %misc.items.list3 } }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewMiscItems) | if (%misc.items.list2 != $null) { .msg $nick 5 $+ %misc.items.list2 } | if (%misc.items.list3 != $null) { .msg $nick  $+ %misc.items.list3 } } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMiscItems)) | if (%misc.items.list2 != $null) {  $dcc.private.message($nick,  $+ %misc.items.list2) } | if (%misc.items.list3 != $null) { $dcc.private.message($nick,  $+ %misc.items.list3) } }
  }
  if (%mech.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewMechCoreItems) | if (%mech.items.list2 != $null) { query %battlechan  $+ %mech.items.list2 } } 
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewMechCoreItems) | if (%mech.items.list2 != $null) { .msg $nick  $+ %mech.items.list2 } } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMechCoreItems)) | if (%mech.items.list2 != $null) {  $dcc.private.message($nick,  $+ %mech.items.list2) } }
  }
  if (%special.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewShopSpecialItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewShopSpecialItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewShopSpecialItems)) }
  }

  if (((((((((%items.list = $null) && (%statplus.items.list = $null) && (%summons.items.list = $null) && (%reset.items.list = $null) && (%gems.items.list = $null) && (%portals.items.list = $null) && (%mech.items.list = $null) && (%special.items.list = $null) && (%misc.items.list = $null))))))))) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoItems)) }
  }    
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list | unset %statplus.items.list | unset %portals.items.list | unset %misc.items.list2
  unset %mech.items.list | unset %mech.items.list2 | unset %reset.items.list | unset %items.list2 | unset %summons.items.list2 | unset %portals.items.list2
  unset %misc.items.list2 | unset %special.items.list
}

on 3:TEXT:!accessories*:#:{ 
  if ($2 != $null) { $checkchar($2) | $accessories.list($2) | $set_chr_name($2) | $readaccessories($2, channel) }
  else { $accessories.list($nick) | $set_chr_name($nick) | $readaccessories($nick, channel) }
}
on 3:TEXT:!accessories*:?:{ 
  if ($2 != $null) { $checkchar($2) | $accessories.list($2) | $set_chr_name($2) | $readaccessories($2, private) }
  else { $accessories.list($nick) | $set_chr_name($nick) | $readaccessories($nick, private) }
}

alias readaccessories {
  if (%accessories.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewAccessories) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewAccessories) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewAccessories)) }

    if (%accessories.list2 != $null) { 
      if ($2 = channel) { query %battlechan 3 $+ %accessories.list2 }
      if ($2 = private) { .msg $nick 3 $+ %accessories.list2 }
      if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %accessories.list2) }
    }

    var %equipped.accessory $readini($char($1), equipment, accessory)
    if ((%equipped.accessory = $null) || (%equipped.accessory = none)) { 
      if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoEquippedAccessory) }
      if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoEquippedAccessory) }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoEquippedAccessory)) }
    }
    if ((%equipped.accessory != $null) && (%equipped.accessory != none)) {
      if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewEquippedAccessory) }
      if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewEquippedAccessory) }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewEquippedAccessory)) }
    }
    unset %accessories.list 
  }
  else { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoAccessories) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoAccessories) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoAccessories)) } 
  }
}

on 3:TEXT:!armor*:#:{ 
  if ($2 != $null) { $checkchar($2) | $armor.list($2) | $set_chr_name($2) | $readarmor($2, channel) }
  else {  $armor.list($nick) | $set_chr_name($nick) | $set_chr_name($nick) | $readarmor($nick, channel) } 
}
on 3:TEXT:!armor*:?:{ 
  if ($2 != $null) { $checkchar($2) | $armor.list($2) | $set_chr_name($2) | $readarmor($2, private) }
  else {  $armor.list($nick) | $set_chr_name($nick) | $set_chr_name($nick) | $readarmor($nick, private) } 
}

alias readarmor {
  if (%armor.head != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorHead) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorHead) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorHead)) }
  }
  if (%armor.head2 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.head2 }
    if ($2 = private) { .msg $nick 3 $+ %armor.head2 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head2) }
  }
  if (%armor.head3 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.head3 }
    if ($2 = private) { .msg $nick 3 $+ %armor.head3 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head3) }
  }

  if (%armor.body != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorBody) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorBody) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorBody)) }
  }
  if (%armor.body2 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.body2 }
    if ($2 = private) { .msg $nick 3 $+ %armor.body2 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body2) }
  }
  if (%armor.body3 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.body3 }
    if ($2 = private) { .msg $nick 3 $+ %armor.body3 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body3) }
  }

  if (%armor.legs != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorLegs) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorLegs) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorLegs)) }
  }
  if (%armor.legs2 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.legs2 }
    if ($2 = private) { .msg $nick 3 $+ %armor.legs2 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs2) }
  }
  if (%armor.legs3 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.legs3 }
    if ($2 = private) { .msg $nick 3 $+ %armor.legs3 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs3) }
  }

  if (%armor.feet != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorFeet) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorFeet) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorFeet)) }
  }
  if (%armor.feet2 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.feet2 }
    if ($2 = private) { .msg $nick 3 $+ %armor.feet2 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet2) }
  }
  if (%armor.feet3 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.feet3 }
    if ($2 = private) { .msg $nick 3 $+ %armor.feet3 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet3) }
  }

  if (%armor.hands != $null) {
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorHands) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorHands) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorHands)) }
  }
  if (%armor.hands2 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.hands2 }
    if ($2 = private) { .msg $nick 3 $+ %armor.hands2 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands2) }
  }
  if (%armor.hands3 != $null) { 
    if ($2 = channel) { query %battlechan 3 $+ %armor.hands3 }
    if ($2 = private) { .msg $nick 3 $+ %armor.hands3 }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands3) }
  }


  if (((((%armor.head = $null) && (%armor.body = $null) && (%armor.legs = $null) && (%armor.feet = $null) && (%armor.hands = $null))))) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoArmor) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoArmor) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoArmor)) }
  }    

  unset %armor.head | unset %armor.body | unset %armor.legs | unset %armor.feet | unset %armor.hands | unset %armor.head2 | unset %armor.body2 | unset %armor.legs2 | unset %armor.feet2 | unset %armor.hands2
  unset %armor.head3 | unset %armor.body3 | unset %armor.legs3 | unset %armor.feet3 | unset %armor.hands3
}

ON 50:TEXT:*equips *:*:{ 
  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  var %player.weapon.check $readini($char($1), weapons, $3)

  if (%player.weapon.check >= 1) {   writeini $char($1) weapons equipped $3 | $set_chr_name($1) | $display.system.message($readini(translation.dat, system, EquipWeaponGM), battle)  }
  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon) , private) | halt }
} 

ON 3:TEXT:*equips *:*:{ 
  if ($2 != equips) { halt }
  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  var %player.weapon.check $readini($char($1), weapons, $3)

  if (%player.weapon.check >= 1) {   writeini $char($1) weapons equipped $3 | $set_chr_name($1) | $display.system.message($readini(translation.dat, system, EquipWeaponGM), battle)  }
  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon) , private) | halt }
} 

on 3:TEXT:!equip *:*: { 
  if ($person_in_mech($nick) = true) { $display.system.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ($2 = mech) { $mech.equip($nick, $3) }
  if ($2 = accessory) { $wear.accessory($nick, $3) | halt }
  if ($2 = armor) { $wear.armor($nick, $3) | halt }

  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyWeaponLocked) | halt  }

  var %player.weapon.check $readini($char($nick), weapons, $2)
  if (%player.weapon.check >= 1) {   writeini $char($nick) weapons equipped $2 | $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, EquipWeaponPlayer) }
  else { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon) , private) }

  $shadowclone.changeweapon($nick, $2)
}

alias shadowclone.changeweapon {
  var %cloneowner $readini($char($1 $+ _clone), info, cloneowner)

  if (%cloneowner = $null) { return }

  if ($readini($char($1 $+ _clone), battle, hp) = 0) { return }

  var %current.weapon $readini($char($1 $+ _clone), weapons, equipped)
  var %new.weapon $readini($char(%cloneowner), weapons, equipped)

  if (%new.weapon = %current.weapon) { return }

  $set_chr_name($1 $+ _clone)
  if ($is_charmed($1 $+ _clone) = true) {  $display.system.message($readini(translation.dat, status, CurrentlyCharmed), battle) | halt }
  if ($is_confused($ $+ _clone) = true) { $display.system.message($readini(translation.dat, status, CurrentlyConfused), battle) | halt }
  if ($readini($char($1 $+ _clone), status, weapon.lock) != $null) { $display.system.message($readini(translation.dat, status, CurrentlyWeaponLocked), battle) | halt }
  writeini $char($1 $+ _clone) weapons equipped %new.weapon | $display.system.message($readini(translation.dat, system, EquipWeaponPlayer), battle) | halt 
}

on 3:TEXT:!unequip *:*: { 
  if ($person_in_mech($1) = true) { $display.system.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ($2 = mech) { $mech.unequip($nick, $3) }
  if ($2 = accessory) { $remove.accessory($nick, $3) }
  if ($2 = armor) { $remove.armor($nick, $3) }

  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyWeaponLocked) | halt  }

  $weapon_equipped($nick) 
  if ($2 != %weapon.equipped) { .msg $nick $readini(translation.dat, system, WrongEquippedWeapon) | halt }
  else {
    if ($2 = fists) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, Can'tDetachHands) | halt }
    else { $set_chr_name($nick) | writeini $char($nick) weapons equipped Fists | query %battlechan $readini(translation.dat, system, UnequipWeapon) | halt }
  }
}

on 3:TEXT:!status:#: { $player.status($nick) | query %battlechan $readini(translation.dat, system, ViewStatus) | unset %all_status } 
on 3:TEXT:!status:?: { $player.status($nick) | .msg $nick $readini(translation.dat, system, ViewStatus) | unset %all_status }

on 3:TEXT:!total deaths *:#: { 
  if ($3 = $null) { .msg $nick 4!total deaths target | halt }
  if ($isfile($boss($3)) = $true) { set %total.deaths $readini($lstfile(monsterdeaths.lst), boss, $3) | set %real.name $readini($boss($3), basestats, name) }
  else  if ($isfile($mon($3)) = $true) { set  %total.deaths $readini($lstfile(monsterdeaths.lst), monster, $3) |  set %real.name $readini($mon($3), basestats, name) }
  else {
    if ($3 = demon_portal) { set %total.deaths $readini($lstfile(monsterdeaths.lst), monster, demon_portal) | set %real.name Demon Portal }
    else {   $checkchar($3) |  set %total.deaths $readini($char($3), stuff, totaldeaths) | $set_chr_name($3) }
  }
  if ((%total.deaths = $null) || (%total.deaths = 0)) { query %battlechan $readini(translation.dat, system, TotalDeathNone) }
  if (%total.deaths > 0) { query %battlechan $readini(translation.dat, system, TotalDeathTotal)  }
  unset %total.deaths
}
on 3:TEXT:!total deaths *:?: { 
  if ($3 = $null) { .msg $nick 4!total deaths target | halt }
  if ($isfile($boss($3)) = $true) { set %total.deaths $readini($lstfile(monsterdeaths.lst), boss, $3) | set %real.name $readini($boss($3), basestats, name) }
  else  if ($isfile($mon($3)) = $true) { set  %total.deaths $readini($lstfile(monsterdeaths.lst), monster, $3) |  set %real.name $readini($mon($3), basestats, name) }
  else {
    if ($3 = demon_portal) { set %total.deaths $readini($lstfile(monsterdeaths.lst), monster, demon_portal) | set %real.name Demon Portal }
    else {   $checkchar($3) |  set %total.deaths $readini($char($3), stuff, totaldeaths) | $set_chr_name($3) }
  }
  if ((%total.deaths = $null) || (%total.deaths = 0)) { .msg $nick $readini(translation.dat, system, TotalDeathNone) }
  if (%total.deaths > 0) { .msg $nick $readini(translation.dat, system, TotalDeathTotal)  }
  unset %total.deaths
}

on 3:TEXT:!achievements*:#: { 
  if ($2 != $null) { $checkchar($2) | $achievement.list($2) 
    if (%achievement.list != $null) { $set_chr_name($2) | query %battlechan $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { query %battlechan 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { query %battlechan 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($2) | query %battlechan $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3 | unset %totalachievements | unset %totalachievements.unlocked
  }
  if ($2 = $null) {
    $achievement.list($nick) 
    if (%achievement.list != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { query %battlechan 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { query %battlechan 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3 |  unset %totalachievements | unset %totalachievements.unlocked
  }
}
on 3:TEXT:!achievements*:?: { 
  if ($2 != $null) { $checkchar($2) | $achievement.list($2) 
    if (%achievement.list != $null) { $set_chr_name($2) | .msg $nick $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { .msg $nick 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { .msg $nick 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($2) | .msg $nick $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3 |  unset %totalachievements | unset %totalachievements.unlocked
  }
  if ($2 = $null) {
    $achievement.list($nick) 
    if (%achievement.list != $null) { $set_chr_name($nick) | .msg $nick $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { .msg $nick 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { .msg $nick 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($nick) | .msg $nick $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3 | unset %totalachievements | unset %totalachievements.unlocked
  }
}

; Bot admins can manually give an item and orbs to a player..
on 50:TEXT:!add*:*:{
  $checkchar($2) | $set_chr_name($2) 
  if ($4 = $null) { .msg $nick 4!add <person> <item name/redorbs/blackorbs/ignition> <ignition name or amount> | halt }
  if ($4 <= 0) { .msg $nick 4cannot add negative amount | halt }

  if ((($3 != redorbs) && ($3 != blackorbs) && ($3 != ignition))) {
    var %item.type $readini($dbfile(items.db), $3, type)
    if (%item.type = $null) { 
      var %item.type $readini($dbfile(equipment.db), $3, EquipLocation)
      if (%item.type = $null) { .msg $nick 4invalid item | halt }
    }
    var %player.amount $readini($char($2), item_amount, $3) 
    if (%player.amount = $null) { var %player.amount 0 }
    inc %player.amount $4 | writeini $char($2) item_amount $3 %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has gained $4 $3 $+ $iif($4 > 1, s)
    halt
  }

  if ($3 = redorbs) { 
    var %player.amount $readini($char($2), stuff, RedOrbs) 
    if (%player.amount = $null) { var %player.amount 0 }
    inc %player.amount $4 | writeini $char($2) stuff  RedOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has gained $4 $readini(system.dat, system, currency) 
    halt
  }

  if ($3 = blackorbs) {
    var %player.amount $readini($char($2), stuff, blackorbs) 
    if (%player.amount = $null) { var %player.amount 0 }
    inc %player.amount $4 | writeini $char($2) stuff  BlackOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has gained $4 Black Orbs
    halt
  }

  if ($3 = ignition) {
    var %player.ignition.amount $readini($char($2), ignitions, $4)
    if (%player.ignition.amount >= 1) {  .msg $nick 4 $+ $2 already knows the ignition $4 | halt }
    else {
      if ($readini($dbfile(ignitions.db), $4, cost) >= 1) { writeini $char($2) ignition $4 1 | query %battlechan 4 $+ %real.name has gained the ignition $4 | halt }
      if ($readini($dbfile(ignitions.db), $4, cost) <= 0) { .msg $nick 4Error: players cannot have this ignition. | halt } 
    }

  }
}

; Bot admins can remove stuff from players..
on 50:TEXT:!take *:*:{
  $checkchar($2) | $set_chr_name($2) 
  if ($4 = $null) { .msg $nick 4!take <person> <item name/redorbs/blackorbs/ignition> <ignition name or amount> | halt }
  if ($4 <= 0) { .msg $nick 4cannot remove negative amount | halt }

  if ((($3 != redorbs) && ($3 != blackorbs) && ($3 != ignition))) {
    var %item.type $readini($dbfile(items.db), $3, type)
    if (%item.type = $null) {
      var %item.type $readini($dbfile(equipment.db), $3, EquipLocation)
      if (%item.type = $null) { .msg $nick 4invalid item | halt }
    }
    var %player.amount $readini($char($2), item_amount, $3) 
    if (%player.amount = $null) { var %player.amount 0 | .msg $nick 4 $+ $2 doesn't have any of this item to remove! | halt }
    dec %player.amount $4 
    if (%player.amount < 0) { var %player.amount 0 }
    writeini $char($2) item_amount $3 %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has lost $4 $3 $+ (s)
    halt
  }

  if ($3 = redorbs) { 
    var %player.amount $readini($char($2), stuff, RedOrbs) 
    if (%player.amount = $null) { var %player.amount 0 | .msg $nick 4 $+ $2 doesn't have any red orbs to remove! | halt }
    dec %player.amount $4 
    if (%player.amount < 0) { var %player.amount 0 }
    writeini $char($2) stuff  RedOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has lost $4 $readini(system.dat, system, currency) 
    halt
  }

  if ($3 = blackorbs) {
    var %player.amount $readini($char($2), stuff, BlackOrbs) 
    if (%player.amount = $null) { var %player.amount 0 | .msg $nick 4 $+ $2 doesn't have any black orbs to remove! | halt }
    dec %player.amount $4 
    if (%player.amount < 0) { var %player.amount 0 }
    writeini $char($2) stuff  BlackOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has lost $4 Black Orbs 
    halt
  }

  if ($3 = ignition) {
    var %player.ignition.amount $readini($char($2), ignitions, $4)
    if (%player.ignition.amount >= 1) { remini $char($2) ignitions $4 | query %battlechan 4 $+ %real.name has lost the ignition $4 | halt }
    else { .msg $nick 4 $+ $2 does not know the ignition $4 | halt } 
  }
}

on 1:TEXT:!dragonballs*:*: { $db.display($nick) }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CUSTOM TITLE CMDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:!customtitle *:*:{
  if (($2 != add) && ($2 != remove)) { .msg $nick 4!customtitle add/remove person custom title | halt }
  if ($3 = $null) {  .msg $nick 4!customtitle add/remove person custom title | halt }
  if ($4 = $null) {  .msg $nick 4!customtitle add/remove person custom title | halt }

  $checkchar($3) | $checkscript($4-)

  if ($2 = add) {
    writeini $char($3) info CustomTitle $4-
    .msg $nick 3The custom title for $3 has been set to: $4- 
  }

  if ($2 = remove) {
    remini $char($3) info CustomTitle
    .msg $nick 3The custom title for $3 has been removed.
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TAUNT COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!taunt *:*: { $set_chr_name($nick)
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  $taunt($nick, $2) | halt 
}
ON 3:ACTION:taunt*:#:{ 
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  $taunt($nick , $2) | halt 
} 
ON 50:TEXT:*taunts *:*:{ $set_chr_name($1)
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if ($readini($char($1), Battle, HP) = $null) { halt }
  $set_chr_name($1) | $taunt($1, $3)
}
ON 3:TEXT:*taunts *:*:{ 
  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  $set_chr_name($1)
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if ($readini($char($1), Battle, HP) = $null) { halt }
  $set_chr_name($1) | $taunt($1, $3)
}
alias taunt {
  ; $1 = taunter
  ; $2 = target

  if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoCurrentBattle), private) | halt  }
  $check_for_battle($1) 
  $person_in_battle($2) 

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, OnlyTauntMonsters), private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, Can'tTauntWhiledead), private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, Can'tTauntSomeoneWhoIsDead), private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $display.system.message($readini(translation.dat, errors, Can'tTauntSomeoneWhoFled), private) | unset %real.name | halt } 

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

  $display.system.message(2 $+ %real.name looks at $set_chr_name($2) %real.name and says " $+ %taunt $+ "  %style.rating, battle) 


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

    if (%taunt.effect = 1) { var %taunt.str $readini($char($2), battle, str) | inc %taunt.str $rand(1,2) | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntRage), battle) }
    if (%taunt.effect = 2) { var %taunt.def $readini($char($2), battle, def) | inc %taunt.def $rand(1,2) | writeini $char($2) battle def %taunt.def | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntDefensive), battle) }
    if (%taunt.effect = 3) { var %taunt.int $readini($char($2), battle, int) | dec %taunt.int 1 | writeini $char($2) battle int %taunt.int | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntClueless), battle) }
    if (%taunt.effect = 4) { var %taunt.str $readini($char($2), battle, str) | dec %taunt.str 1 | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntTakenAback), battle) }
    if (%taunt.effect = 5) { $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntBored), battle) }
    if (%taunt.effect = 6) { $restore_hp($2, $rand(1,10)) | $set_chr_name($2) |  $display.system.message($readini(translation.dat, battle, TauntLaugh), battle) | unset %taunt.hp }
    if (%taunt.effect = 7) { $restore_tp($2, 5) | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntSmile), battle) }
    if (%taunt.effect = 8) { $display.system.message($readini(translation.dat, battle, TauntAngry), battle) 
      if ($readini($char($2), info, flag) != $null) { writeini $char($2) skills provoke.target $1 } 
    }

  }

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GIVES COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:ACTION:gives *:*:{  
  if ($2 !isnum) {  $gives.command($nick, $4, 1, $2)  }
  else { $gives.command($nick, $5, $2, $3) }
}
alias gives.command {
  ; $1 = person giving item
  ; $2 = person receiving item
  ; $3 = amount being given
  ; $4 = item being given

  $set_chr_name($1)

  $checkchar($2)

  if ($2 = $1) { $display.system.message($readini(translation.dat, errors, CannotGiveToYourself), private) | halt }

  var %flag $readini($char($2), Info, Flag)
  if (%flag != $null) { $display.system.message($readini(translation.dat, errors, Can'tGiveToNonChar), private) | halt }

  var %check.item.give $readini($char($1), Item_Amount, $4) 

  if ((%check.item.give <= 0) || (%check.item.give = $null)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
  if ((. isin $3) || ($3 <= 0)) { $display.system.message($readini(translation.dat, errors, Can'tGiveNegativeItem), private) | halt }
  if ($3 > %check.item.give) { $display.system.message($readini(translation.dat, errors, CannotGiveThatMuchofItem), private) | halt }

  var %equipped.accessory $readini($char($1), equipment, accessory)
  if (%equipped.accessory = $4) {
    if (%check.item.give <= $3) { $display.system.message($readini(translation.dat, errors, StillWearingAccessory), private) | halt }
  }

  var %give.item.type $readini($dbfile(items.db), $4, type)
  if (%give.item.type != $null) { var %dbfile items.db }
  if (%give.item.type = $null) { var %dbfile equipment.db }

  var %exclusive.test $readini($dbfile(%dbfile), $4, exclusive)
  if (%exclusive.test = $null) { var %exclusive.test no }
  if (%exclusive.test = yes) { $display.system.message($readini(translation.dat, errors, CannotGiveItem), private) | halt }

  ; If so, decrease the amount
  dec %check.item.give $3
  writeini $char($1) item_amount $4 %check.item.give

  var %target.items $readini($char($2), item_amount, $4)
  inc %target.items $3 
  writeini $char($2) item_amount $4 %target.items

  $display.system.message($readini(translation.dat, system, GiveItemToTarget), global)

  var %number.of.items.given $readini($char($1), stuff, ItemsGiven)
  if (%number.of.items.given = $null) { var %number.of.items.given 0 }
  inc %number.of.items.given $3
  writeini $char($1) stuff ItemsGiven %number.of.items.given
  $achievement_check($1, Santa'sLittleHelper)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SCOREBOARD COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:!toggle scoreboard type*:*:{   
  if ($readini(system.dat, system, ScoreBoardType) = 1) { 
    writeini system.dat system ScoreBoardType 2 | var %scoreboard.type 2
    $display.system.message($readini(translation.dat, system, ScoreBoardTypeToggle), global)
  }
  else {
    writeini system.dat system ScoreBoardType 1 | var %scoreboard.type 1
    $display.system.message($readini(translation.dat, system, ScoreBoardTypeToggle), global)
  }
}
on 50:TEXT:!toggle scoreboard html*:*:{   
  if (($readini(system.dat, system, GenerateHTML) = false) || ($readini(system.dat, system, GenerateHTML) = $null)) { 
    writeini system.dat system GenerateHTML true
    $display.system.message($readini(translation.dat, system, ScoreBoardHTMLTrue), global)
  }
  else {
    writeini system.dat system GenerateHTML false
    $display.system.message($readini(translation.dat, system, ScoreBoardHTMLFalse), global)
  }
}


on 3:TEXT:!scoreboard:*: {
  if (%battleis != on) { $generate.scoreboard }
  else { $display.system.message($readini(translation.dat, errors, ScoreBoardNotDuringBattle), private) | halt }
}

on 3:TEXT:!score*:*: {
  if ($2 = $null) { 
    $get.score($nick, null)
    var %score $readini($char($nick), scoreboard, score)
    $set_chr_name($nick) | $display.system.message($readini(translation.dat, system, CurrentScore), private)
  }
  else {
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { display.system.message($readini(translation.dat, errors, SkillCommandOnlyOnPlayers), private) | halt }
    var %score $get.score($2, null)
    var %score $readini($char($2), scoreboard, score)
    $set_chr_name($2) | $display.system.message($readini(translation.dat, system, CurrentScore), private)
  }
}

on 3:TEXT:!deathboard*:*: {
  if (%battleis != on) { 
    if ((($2 = monster) || ($2 = mon) || ($2 = monsters))) { $generate.monsterdeathboard($3) }
    if (($2 = boss) || ($2 = bosses)) { $generate.bossdeathboard($3) } 
    if ($2 = $null) { $display.system.message(4!deathboard <monster/boss>, private) | halt }
  }
  else { $display.system.message($readini(translation.dat, errors, DeathBoardNotDuringBattle), private) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; DIFFICULTY CMNDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!view difficulty*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  var %saved.difficulty $readini($char($nick), info, difficulty)
  if (%saved.difficulty = $null) { var %saved.difficulty 0 }
  $display.system.message($readini(translation.dat, system, ViewDifficulty), private)
}

on 3:TEXT:!save difficulty*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  if ($3 !isnum) { $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber),private) | halt }
  if (. isin $3) { $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber),private) | halt }
  if ($3 < 0) { $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeNegative),private) | halt }
  if ($3 > 200) { $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeOver200),private) | halt }

  writeini $char($nick) info difficulty $3
  $display.system.message($readini(translation.dat, system, SaveDifficulty), global)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AUGMENT CMNDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!reforge*:#:{ $reforge.weapon($nick, $2) }

alias reforge.weapon {
  ; $1 = user
  ; $2 = weapon

  $set_chr_name($1)
  ; Is it a battle?

  if ((%battleis = on) && ($istok($readini($txtfile(battle2.txt), Battle, List),$1,46) = $true))  { $display.system.message($readini(translation.dat, errors, Can'tReforgepInBattle), private) | halt }

  ; does the player own that weapon?
  var %player.weapon.check $readini($char($1), weapons, $2)

  if ((%player.weapon.check < 1) || (%player.weapon.check = $null)) {  $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon), private) | halt }

  ; does the player have enough black orbs to reforge it?
  var %reforge.cost $round($calc(2 * ($readini($dbfile(weapons.db), $2, cost))),0)
  var %player.blackorbs $readini($char($1), stuff, BlackOrbs)
  if (%player.blackorbs < %reforge.cost) { $display.system.message($readini(translation.dat, errors, NotEnoughBlackOrbs), private) | halt }

  ; Can we actually reforge this weapon?
  if ((%reforge.cost <= 0) || ($2 = fists)) { $display.system.message($readini(translation.dat, errors, Can'tReforgeThatWeapon), private) | halt }

  ; Does the player have enough RepairHammers?
  set %check.item $readini($char($1), Item_Amount, RepairHammer) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotHaveEnoughHammers), private) | halt }

  ; Augment the weapon
  set %total.augments $lines($lstfile(augments.lst))
  set %random.augment $rand(1, %total.augments)
  set %augment.name $read -l $+ %random.augment $lstfile(augments.lst)
  writeini $char($1) augments $2 %augment.name

  $set_chr_name($1)

  if (%battleis != on) { $display.system.message($readini(translation.dat, system, WeaponReforged), global) }
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

on 3:TEXT:!runes*:#:{ 
  if ($2 != $null) { $checkchar($2)
    $runes.list($2) | $set_chr_name($2) 
    if (%runes.list != $null) { $display.system.message($readini(translation.dat, system, ViewRunes), private) |  unset %runes.list }
    else { $display.system.message($readini(translation.dat, system, HasNoRunes), private) }
  }
  else { 
    $runes.list($nick) | $set_chr_name($nick) 
    if (%runes.list != $null) { $display.system.message($readini(translation.dat, system, ViewRunes), private) | unset %runes.list }
    else { $display.system.message($readini(translation.dat, system, HasNoRunes), private) }
  }
}
on 3:TEXT:!runes*:?:{ 
  if ($2 != $null) { $checkchar($2)
    $runes.list($2) | $set_chr_name($2) 
    if (%runes.list != $null) { .msg $nick $readini(translation.dat, system, ViewRunes) |  unset %runes.list }
    else { .msg $nick $readini(translation.dat, system, HasNoRunes) }
  }
  else { 
    $runes.list($nick) | $set_chr_name($nick) 
    if (%runes.list != $null) { .msg $nick $readini(translation.dat, system, ViewRunes) | unset %runes.list }
    else { .msg $nick $readini(translation.dat, system, HasNoRunes) }
  }
}
on 3:TEXT:!augment*:*:{ 
  if ($2 = $null) { $augments.list($nick) }

  if ($2 = list) { 
    if ($3 = $null) { $augments.list($nick) }
    if ($3 != $null) { $checkchar($3) | $augments.list($3) }
  }

  if ($2 = strength) { 
    if ($3 = $null) { $augments.strength($nick) }
    if ($3 != $null) { $checkchar($3) |  $augments.strength($3) }
  }

  if ($2 = add) { 
    if ($3 = $null) { $display.system.message($readini(translation.dat, errors, AugmentAddCmd), private) | halt }
    if ($4 = $null) {  $display.system.message($readini(translation.dat, errors, AugmentAddCmd), private) | halt }

    ; does the player own that weapon?
    var %player.weapon.check $readini($char($nick), weapons, $3)

    if ((%player.weapon.check < 1) || (%player.weapon.check = $null)) {  $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon), private) | halt }

    ; Check to see if weapon is already augmented.  
    var %current.augment $readini($char($nick), augments, $3)

    if (%current.augment != $null) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, AugmentWpnAlreadyAugmented), private) | halt }

    ; Check to see if person has rune
    var %rune.amount $readini($char($nick), item_amount, $4) 

    if ((%rune.amount < 1) || (%rune.amount = $null)) { $set_chr_name($nick) |  $display.system.message($readini(translation.dat, errors, DoNotHaveRune), private) | halt }

    ; Augment the weapon
    set %augment.name $readini($dbfile(items.db), $4, augment)
    writeini $char($nick) augments $3 %augment.name
    dec %rune.amount 1 | writeini $char($nick) item_amount $4 %rune.amount

    $set_chr_name($nick) | $display.system.message($readini(translation.dat, system, WeaponAugmented), global)

    var %number.of.augments $readini($char($nick), stuff, WeaponsAugmented)
    if (%number.of.augments = $null) { var %number.of.augments 0 }
    inc %number.of.augments 1
    writeini $char($nick) stuff WeaponsAugmented %number.of.augments
    $achievement_check($nick, NowYou'rePlayingWithPower)

    unset %augment.name
  }

  if ($2 = remove) { 
    if ($3 = $null) { $display.system.message($readini(translation.dat, errors, AugmentRemoveCmd), private) | halt }

    var %player.weapon.check $readini($char($nick), weapons, $3)
    if ((%player.weapon.check < 1) || (%player.weapon.check = $null)) {  $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon), private) | halt }

    ; Check to see if weapon is augmented or not.  
    var %current.augment $readini($char($nick), augments, $3)
    if (%current.augment = $null) {  $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, AugmentWpnNotAugmented), private) | halt }

    ; Remove augment.
    remini $char($nick) augments $3 
    $set_chr_name($nick) | $display.system.message($readini(translation.dat, system, WeaponDeAugmented), global)
  }
}

alias augments.list {
  ; Check for augments
  $weapons.get.list($1)
  unset %weapon.list | var %number.of.weapons $numtok(%base.weapon.list, 46) | unset %augment.list2 | unset %augment.list3 | unset %augment.list4

  var %value 1 | var %number.of.augments 0
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%base.weapon.list, %value, 46)
    set %weapon_augment $readini($char($1), augments, %weapon.name)

    if (%weapon_augment != $null) { 
      inc %number.of.augments 1
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_augment $+ $chr(041) $+   
      if (%number.of.augments <= 13) {  %weapon.list = $addtok(%weapon.list,%weapon_to_add,46) }
      if (%number.of.augments > 13) { 
        if (%number.of.augments >= 25) { %augment.list3 = $addtok(%augment.list3, %weapon_to_add, 46) } 
        else { %augment.list2 = $addtok(%augment.list2, %weapon_to_add, 46) }
      }
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %number.of.weapons

  if (%weapon.list = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, NoAugments), private) | halt }

  if ($chr(046) isin %weapon.list) { set %replacechar $chr(044) $chr(032)
    %weapon.list = $replace(%weapon.list, $chr(046), %replacechar)
    %augment.list2 = $replace(%augment.list2, $chr(046), %replacechar)
    %augment.list3 = $replace(%augment.list3, $chr(046), %replacechar)
  }
  $set_chr_name($1) | $display.system.message($readini(translation.dat, system, ListOfAugments), private)
  if (%augment.list2 != $null) { $display.system.message(3 $+ %augment.list2, private) }
  if (%augment.list3 != $null) { $display.system.message(3 $+ %augment.list3, private) }
  unset %augment.list2 | unset %augment.list3
  unset %weapon.list | unset %base.weapon.list  | unset %weapons
}

alias augments.strength {
  ; CHECKING AUGMENTS
  unset %augment.list | unset %augment.list.2 | unset %augment.list.3 |   unset %weapon.list | unset %base.weapon.list  | unset %weapons

  var %value 1 | var %augments.lines $lines($lstfile(augments.lst))
  if ((%augments.lines = $null) || (%augments.lines = 0)) { return }

  while (%value <= %augments.lines) {

    var %augment.name $read -l $+ %value $lstfile(augments.lst)

    if ($augment.check($1, %augment.name) = true) {
      if ($numtok(%augment.list,46) <= 11) { %augment.list = $addtok(%augment.list, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
      if ($numtok(%augment.list,46) > 11) {
        if ($numtok(%augment.list.2,46) <= 10) { %augment.list.2 = $addtok(%augment.list.2, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
        if ($numtok(%augment.list.2,46) > 10) { 
          if ($numtok(%augment.list.3,46) <= 10) { %augment.list.3 = $addtok(%augment.list.3, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
          else { %augment.list.4 = $addtok(%augment.list.3, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
        }

      }
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
  if ($chr(046) isin %augment.list.3 ) { set %replacechar $chr(044) $chr(032)
    %augment.list.4 = $replace(%augment.list.4, $chr(046), %replacechar)
  }

  if (%augment.list != $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, system, augmentList), private)
    if (%augment.list.2 != $null) { $display.system.message(3 $+ %augment.list.2, private) }
    if (%augment.list.3 != $null) { $display.system.message(3 $+ %augment.list.3, private) }
    if (%augment.list.4 != $null) { $display.system.message(3 $+ %augment.list.4, private) }
  }
  if (%augment.list = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, system, Noaugments), private) }
  unset %augment.list | unset %augment.list.2 | unset %augment.list.3 | unset %augment.list.4
  unset %weapon.list | unset %base.weapon.list  | unset %weapons
}
