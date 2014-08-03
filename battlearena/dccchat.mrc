;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; DCC CHAT CMDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enter the DCC chat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:open:=: {
  var %p 1 | var %where $readini($char($nick), DCCchat, Room)
  if (%where = $null) { writeini $char($nick) DCCchat Room Lobby | var %where Lobby }
  if ((%where = BattleRoom) && (%battleis = off)) { writeini $char($nick) DCCchat Room Lobby | var %where Lobby }
  $set_chr_name($nick)
  while ($chat(%p) != $null) { 
    msg = $+ $chat(%p) 10 $+ %real.name  $+  $readini($char($nick), Descriptions, Char) 
    if ($chat(%p) == $nick) { inc %p 1 }
    else {  msg = $+ $chat(%p) 14###4 $nick has entered the %where $+ . | inc %p 1 }
  }

  $dcc.who'sonline($nick)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DCC chat, check for log in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.check.for.double.login {
  var %double.check 1
  while ($chat(%double.check) != $null) {
    if ($chat(%double.check) = $1) { .msg $nick 4You are already logged into the game elsewhere! | set %dcc.alreadyloggedin true }
    inc %double.check
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display who's online
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.who'sonline {
  var %who.online 1
  $dcc.private.message($1, 3Who's Online)
  while ($chat(%who.online) != $null) {
    var %online.location $readini($char($chat(%who.online)), DCCchat, Room)
    var %online.name 7[ $+ %online.location $+ ] 2 $+ $chat(%who.online)
    $dcc.private.message($1, %online.name)
    inc %who.online 1
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Leave the DCC chat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:close:=: { var %p 1
  while ($chat(%p) != $null) { 
    if ($chat(%p) == $nick) { inc %p 1 }
    else {  msg = $+ $chat(%p) 14###4 $nick has left the game. | inc %p 1 }
  }
  close -c $nick
  .auser 1 $nick | mode %battlechan -v $nick | .flush 1
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a System Message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.global.message {
  var %p 1
  while ($chat(%p) != $null) {  var %nick $chat(%p) | var %system.message $1
    msg = $+ $chat(%p) %system.message 
    inc %p 1 
  } 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a Battle Message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.battle.message {
  var %p 1 | var %battle.message $1
  while ($chat(%p) != $null) {  
    var %where $readini($char($chat(%p)), DCCchat, Room)
    if (%where = $null) { var %where Lobby }
    var %listen.to.battle.flag $readini($char($chat(%p)), DCCchat, ListenToBattleFlag)

    if ((%where = BattleRoom) || (%listen.to.battle.flag = true)) { msg = $+ $chat(%p) %battle.message  }
    inc %p 1
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display the status effects
; during battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.status.messages {
  ; $1 = the text file to read

  var %total.lines $lines($1)
  var %current.status.line 1
  while (%current.status.line <= %total.lines) {
    $dcc.battle.message($read($1, %current.status.line))
    inc %current.status.line
  }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a message to
; a single person
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.private.message {
  ; $1 = person
  ; $2 = message

  var %p 1
  while ($chat(%p) != $null) {  var %nick $chat(%p) | var %system.message $1
    if ($chat(%p) = $1) { msg = $+ $chat(%p) $2 }
    inc %p 1 
  } 
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player commands go here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 2:Chat:!who's online*: { $dcc.who'sonline($nick) }
on 2:Chat:!online list*: { $dcc.who'sonline($nick) }
on 2:Chat:!view-info*: { $view-info($1, $2, $3, $4) }
on 2:Chat:!help*: { $gamehelp($2, $nick) }
on 2:Chat:!shop*: { $shop.start($1, $2, $3, $4, $5) }
on 2:Chat:!sell*: { $shop.start(!shop, sell, $2, $3, $4, $5) }
on 2:Chat:!bet*: { $ai.battle.place.bet($nick, $2, $3) } 
on 2:Chat:!npc status: { $shopnpc.list(dcc, $nick) }
on 2:Chat:!portal usage: { $portal.usage.check(dcc, $nick) }

on 2:Chat:!access: {
  if ($2 = add) { $character.access($nick, add, $3) }
  if ($2 = remove) { $character.access($nick, remove, $3) }
  if ($2 = list) { $character.access($nick, list) }
  if ($2 !isin add.remove.list) { .mgs $nick $readini(translation.dat, errors, AccessCommandError) | halt } 
}

on 2:Chat:!recipe search*: { $view-recipe($nick, $3) }

on 2:Chat:!toggle battle chat*: { 
  var %listen.to.battle.flag $readini($char($nick), DCCchat, ListenToBattleFlag)
  if ((%listen.to.battle.flag = false) || (%listen.to.battle.flag = $null)) { writeini $char($nick) DCCchat ListenToBattleFlag true | $dcc.private.message($nick, 3Battle Chat has been enabled. You can now see the battle chat even if you are not in the battles.) | halt }
  if (%listen.to.battle.flag = true) { writeini $char($nick) DCCchat ListenToBattleFlag false | $dcc.private.message($nick, 3Battle Chat has been disabled. You will no longer see most battle chat messages unless you join the battles.) | halt }
}
on 2:Chat:!conquest*: { $conquest.display }
on 2:Chat:!battle stats*: { $battle.stats }
on 2:Chat:!battlestats*: { $battle.stats }
on 2:Chat:!hp*: { 
  $set_chr_name($nick) | $hp_status_hpcommand($nick) 
  $dcc.global.message($readini(translation.dat, system, ViewMyHP))

  if ($person_in_mech($nick) = true) { var %mech.name $readini($char($nick), mech, name) | $hp_mech_hpcommand($nick) 
    $dcc.global.message($readini(translation.dat, system, ViewMyMechHP))
  }

  unset %real.name | unset %hstats
}
on 2:Chat:!tp*: { 
  $set_chr_name($nick) 
  $dcc.global.message($readini(translation.dat, system, ViewMyTP))
  unset %real.name
}
on 2:Chat:!ig: { 
  $set_chr_name($nick)
  $dcc.global.message($readini(translation.dat, system, ViewMyIG))
  unset %real.name 
}
on 2:Chat:!orbs*: { 
  if ($2 != $null) { $checkchar($2) | var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $set_chr_name($2) 
    $dcc.private.message($readini(translation.dat, system, ViewOthersOrbs))
  }
  else { var %orbs.spent $bytes($readini($char($nick), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($nick), stuff, BlackOrbsSpent),b) | $set_chr_name($nick) 
    $dcc.private.message($readini(translation.dat, system, ViewMyOrbs))
  }
}
ON 2:Chat:!desc*: { 
  if ($2 != $null) { $checkchar($2) | $set_chr_name($2) | $dcc.private.message($nick,3 $+ %real.name  $+ $readini($char($2), Descriptions, Char))   | unset %character.description | halt }
  else { $set_chr_name($nick) | $dcc.private.message($nick,10 $+ %real.name  $+ $readini($char($nick), Descriptions, Char))  }
}
ON 2:Chat:!cdesc *: { $checkscript($2-)  | writeini $char($nick) Descriptions Char $2- | $okdesc($nick , Character) }
ON 2:Chat:!skill desc *: { $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), skills, $3) != $null) { 
    writeini $char($nick) Descriptions $3 $4- | $okdesc($nick , Skill) 
  }
  if ($readini($char($nick), skills, $3) = $null) { $dcc.private.message($nick, $readini(translation.dat, errors, YouDoNotHaveSkill)) | halt }
}
ON 2:Chat:!ignition desc *: { $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), ignitions, $3) != $null) { 
    writeini $char($nick) Descriptions $3 $4- | $okdesc($nick , Ignition) 
  }
  if ($readini($char($nick), ignitions, $3) = $null) { $dcc.private.message($nick, $readini(translation.dat, errors, DoNotKnowThatIgnition)) | halt }
}
ON 2:Chat:!clear desc *: { $checkscript($3-)  | $set_chr_name($nick) 
  if (($3 = character) || ($3 = char)) { var %description.to.clear char | writeini $char($nick) descriptions char needs to set a character description! | $dcc.private.message($nick, $readini(translation.dat, system, ClearDesc)) }
  else { remini $char($nick) descriptions $3 |  $dcc.private.message($nick, $readini(translation.dat, system, ClearDesc)) }
}
ON 2:Chat:!setgender *: { $checkscript($2-)
  if ($2 = neither) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | $dcc.private.message($nick, $readini(translation.dat, system, SetGenderNeither)) | unset %check | halt }
  if ($2 = none) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | $dcc.private.message($nick, $readini(translation.dat, system, SetGenderNeither))  | unset %check | halt }
  if ($2 = male) { writeini $char($nick) Info Gender his | writeini $char($nick) Info Gender2 him | $dcc.private.message($nick, $readini(translation.dat, system, SetGenderMale))  | unset %check | halt }
  if ($2 = female) { writeini $char($nick) Info Gender her | writeini $char($nick) Info Gender2 her | $dcc.private.message($nick, $readini(translation.dat, system, SetGenderFemale)) | unset %check | halt }
  else { $dcc.private.message($nick, $readini(translation.dat, errors, NeedValidGender)) | unset %check | halt }
}

on 2:Chat:!notes*: { 
  if ($2 = $null) { $check.allied.notes($nick) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2) }
}
on 2:Chat:!allied notes*: { 
  if ($3 = $null) { $check.allied.notes($nick) }
  if ($3 != $null) { $checkchar($3) | $check.allied.notes($3) }
}
on 2:Chat:!double dollars*: { 
  if ($2 = $null) { $check.doubledollars($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $check.doubledollars($2, channel) }
}

on 2:Chat:!look*: {
  if ($2 = $null) { $lookat($nick) }
  if ($2 != $null) { $checkchar($2) | $lookat($2) }
}
on 2:Chat:!level*: {
  if ($1 = !leveladjust) { halt }
  if ($2 = $null) { $set_chr_name($nick) | var %player.level $bytes($round($get.level($nick),0),b) | $dcc.private.message($nick, $readini(translation.dat, system, ViewLevel)) | unset %real.name }
  if ($2 != $null) { $checkscript($2-) | $checkchar($2) | $set_chr_name($2) | var %player.level $bytes($round($get.level($2),0),b) | $dcc.private.message($nick, $readini(translation.dat, system, ViewLevel)) | unset %real.name }
}

on 2:Chat:!stats*: { unset %all_status 
  if ($2 = $null) { 
    $battle_stats($nick) | $player.status($nick) | $weapon_equipped($nick) | $dcc.private.message($nick, $readini(translation.dat, system, HereIsYourCurrentStats))
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

    $dcc.private.message($nick, [4HP12 $readini($char($nick), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, HP) $+ 1] [4TP12 $readini($char($nick), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, TP) $+ 1] [4Ignition Gauge12 $readini($char($nick), Battle, IgnitionGauge) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, IgnitionGauge) $+ 1] [4Status12 %all_status $+ 1] [4Royal Guard Meter12 %blocked.meter $+ 1])
    $dcc.private.message($nick, [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1])
    $dcc.private.message($nick,  [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped.right $iif(%weapon.equipped.left != $null, 4and12 %weapon.equipped.left) $+ 1] [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1]  [4 $+ $readini(translation.dat, system, CurrentArmorHeadEquipped) 12 $+ %equipped.armor.head $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorBodyEquipped) 12 $+ %equipped.armor.body $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorLegsEquipped) 12 $+ %equipped.armor.legs $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorFeetEquipped) 12 $+ %equipped.armor.feet $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHandsEquipped) 12 $+ %equipped.armor.hands $+ 1])
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped)
  }
  else { 
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { $dcc.private.message($nick, $readini(translation.dat, errors, SkillCommandOnlyOnPlayers)) | halt }
    $battle_stats($2) | $player.status($2) | $weapon_equipped($2) | $dcc.private.message($nick, $readini(translation.dat, system, HereIsOtherCurrentStats))
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

    $dcc.private.message($nick, [4HP12 $readini($char($2), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, HP) $+ 1] [4TP12 $readini($char($2), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, TP) $+ 1] [4Ignition Gauge12 $readini($char($2), Battle, IgnitionGauge) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, IgnitionGauge) $+ 1] [4Status12 %all_status $+ 1] [4Royal Guard Meter12 %blocked.meter $+ 1])
    $dcc.private.message($nick, [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1])
    $dcc.private.message($nick,  [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped.right $iif(%weapon.equipped.left != $null, 4and12 %weapon.equipped.left) $+ 1] [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHeadEquipped) 12 $+ %equipped.armor.head $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorBodyEquipped) 12 $+ %equipped.armor.body $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorLegsEquipped) 12 $+ %equipped.armor.legs $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorFeetEquipped) 12 $+ %equipped.armor.feet $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHandsEquipped) 12 $+ %equipped.armor.hands $+ 1])
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped
  }
}
on 2:CHAT:!misc info*: { 
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

    var %misc.target your
    $dcc.private.message($nick, $readini(translation.dat, system, HereIsMiscInfo))
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

    var %misc.target $3 $+ 's
    $dcc.private.message($nick, $readini(translation.dat, system, HereIsMiscInfo))
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

  $dcc.private.message($nick, [4Total Battles Partcipated12 %misc.totalbattles $+ 1] [4Total Portal Battles Won12 %misc.portalswon $+ 1] [4Total Deaths12 %misc.totaldeaths $+ 1] [4Total Monster Kills12 %misc.totalmonkills $+ 1] [4Total Times Fled12 %misc.timesfled $+ 1][4Total Lost Souls Killed12 %misc.lostSoulsKilled $+ 1] [4Total Times Revived12 %misc.revivedtimes $+ 1] [4Total Times Character Has Been Reset12 %misc.resets $+ 1])
  $dcc.private.message($nick, [4Total Items Sold12 %misc.itemssold $+ 1] [4Total Discounts Used12 %misc.discountsUsed $+ 1] [4Total Items Given12 %misc.itemsgiven $+ 1] [4Total Keys Obtained12 %misc.totalkeys $+ 1] [4Total Chests Opened12 %misc.chestsopened $+ 1][4Total Monster->Gem Conversions12 %misc.monstersToGems $+ 1])
  $dcc.private.message($nick, [4Total Battlefield Events Experienced12 %misc.timeshitbybattlefield $+ 1]  [4Total Weapons Augmented12 %misc.augments $+ 1] [4Total Weapons Reforged12 %misc.reforges $+ 1] [4Total Ignitions Performed12 %misc.ignitionsused $+ 1] [4Total Dodges Performed12 %misc.timesdodged $+ 1] [4Total Parries Performed12 %misc.timesparried $+ 1] [4Total Counters Performed12 %misc.timescountered $+ 1])
  $dcc.private.message($nick, [4Total Light Spells Casted12 %misc.lightspells $+ 1] [4Total Dar Spells Casted12 %misc.darkspells $+ 1] [4Total Earth Spells Casted12 %misc.earthspells $+ 1] [4Total Fire Spells Casted12 %misc.firespells $+ 1] [4Total Wind Spells Casted12 %misc.windspells $+ 1] [4Total Water Spells Casted12 %misc.waterspells $+ 1] [4Total Ice Spells Casted12 %misc.icespells $+ 1] [4Total Lightning Spells Casted12 %misc.lightningspells $+ 1])
  $dcc.private.message($nick, [4Total Times Won Under Defender12 %misc.defenderwon $+ 1] [4Total Times Won Under Aggressor12 %misc.aggressorwon $+ 1] [4Total Blood Boosts Performed12 %misc.bloodboost $+ 1] [4Total Blood Spirits Performed12 %misc.bloodspirit $+ 1])
}

on 2:Chat:!weapons*: { unset %*.wpn.list | unset %weapon.list
  if ($2 = $null) { $weapon.list($nick) | set %wpn.lst.target $nick }
  else { $checkchar($2) | $weapon.list($2) | set %wpn.lst.target $2 }
  /.timerDisplayWeaponList $+ $nick 1 1 /display_weapon_lists %wpn.lst.target dcc $nick
}

on 2:Chat:!shields*: { unset %*.shld.list | unset %shield.list
  if ($2 = $null) { $shield.list($nick) | set %shld.lst.target $nick }
  else { $checkchar($2) | $shield.list($2) | set %shld.lst.target $2 }
  /.timerDisplayshieldList $+ $nick 1 1 /display_shield_lists %shld.lst.target dcc $nick
}

on 2:Chat:!techs*: {
  if ($2 = $null) { $weapon_equipped($nick) | $tech.list($nick, %weapon.equipped) | $set_chr_name($nick) 
    if (%techs.list != $null) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMyTechs)) }
    if (%ignition.tech.list != $null) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMyIgnitionTechs)) }
    if ((%techs.list = $null) && (%ignition.tech.list = $null)) { $dcc.private.message($nick, $readini(translation.dat, system, NoTechsForMe))  }
  }
  else { $checkchar($2) | $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) 
    if (%techs.list != $null) { $dcc.private.message($nick, $readini(translation.dat, system, ViewOthersTechs)) }
    if (%ignition.tech.list != $null) { $dcc.private.message($nick, $readini(translation.dat, system, ViewOthersIgnitionTechs)) }
    if ((%techs.list = $null) && (%ignition.tech.list = $null)) { $dcc.private.message($nick, $readini(translation.dat, system, NoTechsForOthers)) }
  }
}

on 2:Chat:!ignitions: {
  if ($2 = $null) { $ignition.list($nick) | $set_chr_name($nick) 
    if (%ignitions.list != $null) { $dcc.private.message($nick, $readini(translation.dat, system, ViewIgnitions)) | unset %ignitions.list }
    else { $dcc.private.message($nick, $readini(translation.dat, system, NoIgnitions))  }
  }
  else { $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
    if (%ignitions.list != $null) { $dcc.private.message($nick, $readini(translation.dat, system, ViewIgnitions)) | unset %ignitions.list }
    else { $dcc.private.message($nick, $readini(translation.dat, system, NoIgnitions))  }
  }
}

on 2:Chat:!skills*: {
  if ($2 != $null) { $checkchar($2) | $skills.list($2) | $set_chr_name($2) | $readskills($2, dcc)  }
  else { $skills.list($nick) | $set_chr_name($nick) | $readskills($nick, dcc) }
}

on 2:Chat:!keys*: {
  if ($2 != $null) { $checkchar($2) | $keys.list($2) | $set_chr_name($2) | $readkeys($2, dcc) }
  else {  $keys.list($nick) | $set_chr_name($nick) | $readkeys($nick, dcc) }
}

on 2:Chat:!gems*: {
  if ($2 != $null) { $checkchar($2) | $gems.list($2) | $set_chr_name($2) | $readgems($2, dcc) }
  else {  $gems.list($nick) | $set_chr_name($nick) | $readgems($nick, dcc) }
}

on 2:Chat:!seals*: {
  if ($2 != $null) { $checkchar($2) | $seals.list($2) | $set_chr_name($2) | $readseals($2, dcc) }
  else {  $seals.list($nick) | $set_chr_name($nick) | $readseals($nick, channel) }
}

on 2:Chat:!items*: {
  if ($2 != $null) { $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, dcc) }
  else {  $items.list($nick) | $set_chr_name($nick) | $readitems($nick, dcc) }
}

on 2:Chat:!accessories*: {
  if ($2 != $null) { $checkchar($2) | $accessories.list($2) | $set_chr_name($2) | $readaccessories($2, dcc) }
  else { $accessories.list($nick) | $set_chr_name($nick) | $readaccessories($nick, dcc) }
}

on 2:Chat:!armor*: {
  if ($2 != $null) { $checkchar($2) | $armor.list($2) | $set_chr_name($2) | $readarmor($2, dcc) }
  else {  $armor.list($nick) | $set_chr_name($nick) | $set_chr_name($nick) | $readarmor($nick, dcc) } 
}
on 2:Chat:!equip*: {
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($2 = accessory) { $wear.accessory($nick, $3) | halt }
  if ($2 = armor) { $wear.armor($nick, $3) | halt }

  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyWeaponLocked)) | halt  }

  if (($2 != right) && ($2 != left)) { 
    if ($readini($dbfile(weapons.db), $2, type) = shield) { 
      if ($skillhave.check($nick, DualWield) = false) { $dcc.private.message($readini(translation.dat, errors, Can'tDualWield)) | halt }
      var %equiphand left | var %weapon.to.equip $2
    }
    if ($readini($dbfile(weapons.db), $2, type) != shield) { 
      var %equiphand right | var %weapon.to.equip $2 
    }
  }
  if ($2 = right) {
    if ($readini($dbfile(weapons.db), $3, type) = shield) { 
      if ($skillhave.check($nick, DualWield) = false) { $dcc.private.message($readini(translation.dat, errors, Can'tDualWield)) | halt }
      var %equiphand left | var %weapon.to.equip $3
    }
    if ($readini($dbfile(weapons.db), $3, type) != shield) { 
      var %equiphand right | var %weapon.to.equip $3 
    }
  }
  if ($2 = left) {
    ; check for the dual-wield skill
    if ($skillhave.check($nick, DualWield) = false) { $dcc.private.message($readini(translation.dat, errors, Can'tDualWield)) | halt }

    ; Is the right-hand weapon a 2h weapon?
    if ($readini($dbfile(weapons.db), $readini($char($nick), weapons, equipped), 2Handed) = true) { $dcc.private.message($readini(translation.dat, errors, Using2HWeapon)) | halt }

    ; Set the variables.
    var %equiphand left | var %weapon.to.equip $3

    ; Is the left-hand weapon a 2h weapon?
    if ($readini($dbfile(weapons.db), %weapon.to.equip, 2Handed) = true) { var %equiphand both }
  }

  var %player.weapon.check $readini($char($nick), weapons, %weapon.to.equip)
  if ((%player.weapon.check = $null) || (%player.weapon.check < 1)) { $set_chr_name($nick) | $dcc.private.message($readini(translation.dat, errors, DoNotHaveWeapon)) | halt }

  if ($readini($dbfile(weapons.db), %weapon.to.equip, 2Handed) = true) { var %equiphand both }

  ; Is the weapon already equipped?
  if ((%weapon.to.equip = $readini($char($nick), weapons, equipped)) || (%weapon.to.equip = $readini($char($nick), weapons, equippedLeft))) { $set_chr_name($nick) | $dcc.private.message($readini(translation.dat, errors, WeaponAlreadyEquipped)) | halt }

  $wield_weapondcc($nick, %equiphand, %weapon.to.equip)

}

alias wield_weapondcc {
  if ($2 = right) { writeini $char($1) weapons equipped $3 }
  if ($2 = left) { writeini $char($1) weapons equippedLeft $3 }
  if ($2 = both) { writeini $char($1) weapons equipped $3 | remini $char($1) weapons equippedLeft }

  $set_chr_name($1) 
  if (%battleis = off) { $dcc.private.message($readini(translation.dat, system, EquipWeaponPlayer)) }
  if (%battleis = on) { $dcc.battle.message($readini(translation.dat, system, EquipWeaponPlayer)) }


  $shadowclone.changeweapon($1, $2, $3)

}


on 2:Chat:!unequip*: {
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($2 = accessory) { $remove.accessory($nick, $3) }
  if ($2 = armor) { $remove.armor($nick, $3) }

  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyWeaponLocked)) | halt  }

  $weapon_equipped($nick) 

  if (($2 = %weapon.equipped.left) || ($2 = %weapon.equipped.right)) { 
    if ($2 = fists) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDetachHands)) | halt }
    else { $set_chr_name($nick) | writeini $char($nick) weapons equipped Fists | remini $char($nick) weapons EquippedLeft 

      if (%battleis = off) { $dcc.private.message($nick, $readini(translation.dat, system, UnequipWeapon)) }
      if (%battleis = on) { $dcc.battle.message($readini(translation.dat, system, UnequipWeapon)) }

      halt 
    }
  }

  else {  $dcc.private.message($nick,$readini(translation.dat, errors, WrongEquippedWeapon)) | halt }

}

on 2:Chat:!wear*: { 
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($3 = $null) { $display.system.message(4Error: !wear <accessory/armor> <what to wear>, private) | halt }
  if ($2 = accessory) { $wear.accessory($nick, $3) }
  if ($2 = armor) { $wear.armor($nick, $3) }
}

on 2:Chat:!remove*: { 
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($3 = $null) { $display.system.message(4Error: !remove <accessory/armor> <what to remove>, private) | halt }
  if ($2 = accessory) { $remove.accessory($nick, $3) }
  if ($2 = armor) { $remove.armor($nick, $3) }
}

on 2:Chat:!style*: { unset %*.style.list | unset %style.list
  if ($2 = $null) { 
    ; Get and show the list
    $styles.list($nick)
    set %current.playerstyle $readini($char($nick), styles, equipped)
    set %current.playerstyle.xp $readini($char($nick), styles, %current.playerstyle $+ XP)
    set %current.playerstyle.level $readini($char($nick), styles, %current.playerstyle)
    var %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)
    if (%current.playerstyle.level >= 10) {   $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyleMaxed)) }
    if (%current.playerstyle.level < 10) {   $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyle)) }
    $dcc.private.message($nick, $readini(translation.dat, system, ViewStyleList))
    unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle
  }
  if ($2 = change) { $style.change($nick, $2, $3) }
}

on 2:Chat:!xp*: { unset %*.style.list | unset %style.list
  if ($2 != $null) { $checkchar($2) | $show.stylexp($2, dcc) }
  if ($2 = $null) { $show.stylexp($nick, dcc) }
}

on 2:Chat:!total deaths*: { 
  if ($3 = $null) { $dcc.private.message($nick,4Error: Use !total deaths target) | halt }
  if ($isfile($boss($3)) = $true) { set %total.deaths $readini($lstfile(monsterdeaths.lst), boss, $3) | set %real.name $readini($boss($3), basestats, name) }
  else if ($isfile($mon($3)) = $true) { set %total.deaths $readini($lstfile(monsterdeaths.lst), monster, $3) |  set %real.name $readini($mon($3), basestats, name) }
  else {
    if ($3 = demon_portal) { set %total.deaths $readini($lstfile(monsterdeaths.lst), monster, demon_portal) | set %real.name Demon Portal }
    else {   $checkchar($3) |  set %total.deaths $readini($char($3), stuff, totaldeaths) | $set_chr_name($3) }
  }
  if ((%total.deaths = $null) || (%total.deaths = 0)) { $dcc.private.message($nick,$readini(translation.dat, system, TotalDeathNone)) }
  if (%total.deaths > 0) { $dcc.private.message($nick,$readini(translation.dat, system, TotalDeathTotal))  }
  unset %total.deaths
}

on 2:Chat:!achievements*: {
  if ($2 != $null) { $checkchar($2) | $achievement.list($2) 
    if (%achievement.list != $null) { $set_chr_name($2) | $dcc.private.message($nick,$readini(translation.dat, system, AchievementList))
      if (%achievement.list.2 != $null) { $dcc.private.message($nick,3 $+ %achievement.list.2) }
      if (%achievement.list.3 != $null) { $dcc.private.message($nick,3 $+ %achievement.list.3) }
    }
    if (%achievement.list = $null) { $set_chr_name($2) | $dcc.private.message($nick,$readini(translation.dat, system, NoAchievements)) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3 | unset %totalachievements | unset %totalachievements.unlocked

  }
  if ($2 = $null) {
    $achievement.list($nick) 
    if (%achievement.list != $null) { $set_chr_name($nick) | $dcc.private.message($nick,$readini(translation.dat, system, AchievementList))
      if (%achievement.list.2 != $null) { $dcc.private.message($nick,3 $+ %achievement.list.2) }
      if (%achievement.list.3 != $null) { $dcc.private.message($nick,3 $+ %achievement.list.3) }

    }
    if (%achievement.list = $null) { $set_chr_name($nick) | $dcc.private.message($nick,$readini(translation.dat, system, NoAchievements)) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3 | unset %totalachievements | unset %totalachievements.unlocked

  }
}

on 2:Chat:!dragonballs*: { $db.display($nick) }

on 2:Chat:ACTION gives *: {
  if ($3 !isnum) {  $gives.command($nick, $5, 1, $3)  }
  else { $gives.command($nick, $6, $3, $4) }
}
on 2:Chat:gives *: {
  if ($2 !isnum) {  $gives.command($nick, $4, 1, $3)  }
  else { $gives.command($nick, $5, $2, $3) }
}

on 2:Chat:!view difficulty*: { $set_chr_name($nick) | $checkchar($nick) 
  var %saved.difficulty $readini($char($nick), info, difficulty)
  if (%saved.difficulty = $null) { var %saved.difficulty 0 }
  $display.system.message($readini(translation.dat, system, ViewDifficulty), private)
}
on 2:Chat:!save difficulty*: {  $set_chr_name($nick) | $checkchar($nick) 
  if ($3 !isnum) { $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber),private) | halt }
  if (. isin $3) { $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber),private) | halt }
  if ($3 < 0) { $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeNegative),private) | halt }
  if ($3 > 200) { $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeOver200),private) | halt }

  writeini $char($nick) info difficulty $3
  $display.system.message($readini(translation.dat, system, SaveDifficulty), global)
}
on 2:Chat:!runes*: {
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
on 2:Chat:!reforge*: { $reforge.weapon($nick, $2) }
on 2:Chat:!augment*: {
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
on 2:Chat:!scoreboard*: {
  if (%battleis != on) { $generate.scoreboard }
  else { $display.system.message($readini(translation.dat, errors, ScoreBoardNotDuringBattle), private) | halt }
}
on 2:Chat:!score*: {
  if ($2 = $null) { 
    $get.score($nick,null)
    var %score $readini($char($nick), scoreboard, score)
    $set_chr_name($nick) | $display.system.message($readini(translation.dat, system, CurrentScore), private)
  }
  else {
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { display.system.message($readini(translation.dat, errors, SkillCommandOnlyOnPlayers), private) | halt }
    var %score $get.score($2,null)
    var %score $readini($char($2), scoreboard, score)
    $set_chr_name($2) | $display.system.message($readini(translation.dat, system, CurrentScore), private)
  }
}
on 2:Chat:!deathboard*: {
  if (%battleis != on) { 
    if ((($2 = monster) || ($2 = mon) || ($2 = monsters))) { $generate.monsterdeathboard }
    if (($2 = boss) || ($2 = bosses)) { $generate.bossdeathboard } 
    if ($2 = $null) { $display.system.message(4!deathboard <monster/boss>, private) | halt }
  }
  else { $display.system.message($readini(translation.dat, errors, DeathBoardNotDuringBattle), private) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Battle-related commands 
; go here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!weather*: {  $dcc.private.message($nick, $readini(translation.dat, battle, CurrentWeather)) }
on 2:Chat:!moon*: {  $dcc.private.message($nick, $readini(translation.dat, battle, CurrentMoon)) }
on 2:Chat:!time*: {  $dcc.private.message($nick, $readini(translation.dat, battle, CurrentTime)) }
on 2:Chat:!status*: {   $player.status($nick) 
  if (%battleis = off) { $dcc.private.message($nick, $readini(translation.dat, system, ViewStatus)) }
  if (%battleis = on) { $dcc.battle.message($readini(translation.dat, system, ViewStatus)) }

  unset %all_status 
} 
on 2:Chat:!battle hp*: { 
  if (%battleis != on) { $dcc.private.message($nick, $readini(translation.dat, errors, NoBattleCurrently)) | halt }
  $build_battlehp_list
  $dcc.battle.message(%battle.hp.list)  | unset %real.name | unset %hstats | unset %battle.hp.list
}
on 2:Chat:!batlist*: { $battlelist }
on 2:Chat:!bat list*: { $battlelist }
on 2:Chat:!battle list*: { $battlelist }
on 2:Chat:!bat info*: { $battlelist }
ON 2:Chat:!enter*: { 
  if ($readini(system.dat, system, automatedaibattlecasino) = on) { $display.system.message($readini(translation.db, errors, CannotJoinAIBattles), private) | halt } 
  $enter($nick)
}
ON 2:Chat:!flee*: {  $flee($nick) }

on 2:Chat:ACTION activates *: { $mech.activate($nick) } 
on 2:Chat:ACTION deactivates *: { $mech.deactivate($nick) } 
on 2:Chat:!mech repair*: { $mech.repair($nick, $3) }
on 2:Chat:!mech fuel*: { $mech.fuel($nick, $3) }
on 2:Chat:!mech energy*: { $mech.fuel($nick, $3) }
on 2:Chat:!mech equip*: { $mech.equip($nick, $3) }
on 2:Chat:!mech unequip*: { $mech.unequip($nick, $3) }
on 2:Chat:!mech stats*: { $mech.stats($nick) }
on 2:Chat:!mech status*: { $mech.stats($nick) }
on 2:Chat:!mech items*: { $mech.items($nick, dcc) }
on 2:Chat:!mech weapons*: { $mech.weapons($nick, dcc) }
on 2:Chat:!mech name *: { $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), mech, HpMax) = $null) {  $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }
  writeini $char($nick) Mech Name $3- 
  $display.private.message(3Mech name set to: %real.name $+ 's $3- ) 
}
on 2:Chat:!mech desc *: {  $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), mech, HpMax) = $null) {  $display.private.message($readini(translation.dat, errors, DoNotOwnAMech)) | halt }
  writeini $char($nick) Descriptions mech $3- | $okdesc($nick ,Mech) 
}
on 2:Chat:!mech upgrade *: { 
  var %amount.to.purchase $abs($4)
  if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }
  $mech.upgrade($nick, $2, $3, %amount.to.purchase) 
} 

on 2:Chat:ACTION attacks *: { 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) | set %attack.target $3 | $covercheck($3)
  $attack_cmd($nick , %attack.target) 
}
on 2:Chat:attacks *: { 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) | set %attack.target $2 | $covercheck($2)
  $attack_cmd($nick , %attack.target) 
}
on 2:Chat:ACTION goes *: { 
  if ($4 != $null) { halt }
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) 

  set %ignition.list $readini($dbfile(ignitions.db), ignitions, list)
  if ($istok(%ignition.list, $3, 46) = $true) { unset %ignition.list | $ignition_cmd($nick, $3, $nick) | halt }
  else { $tech_cmd($nick , $3, $nick) | halt }
}
on 2:Chat:goes *: { 
  if ($3 != $null) { halt }
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) 

  set %ignition.list $readini($dbfile(ignitions.db), ignitions, list)
  if ($istok(%ignition.list, $2, 46) = $true) { unset %ignition.list | $ignition_cmd($nick, $2, $nick) | halt }
  else { $tech_cmd($nick , $2, $nick) | halt }
}
on 2:Chat:ACTION reverts *: {
  $check_for_battle($nick) 
  if ($3 = $null) { halt }
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) 

  var %ignition.name $readini($char($nick), status, ignition.name)
  if (%ignition.name = $3) {   
    $revert($nick, $3) 
    $revertignition.msg($nick)
    halt
  }
  else { $dcc.private.message($nick, $readini(translation.dat, errors, NotUsingThatIgnition)) | halt }
} 
on 2:Chat:reverts *: {
  $check_for_battle($nick) 
  if ($2 = $null) { halt }
  if ($person_in_mech($nick) = true) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) 

  var %ignition.name $readini($char($nick), status, ignition.name)
  if (%ignition.name = $2) {   
    $revert($nick, $2) 
    $revertignition.msg($nick)
    halt
  }
  else { $dcc.private.message($nick, $readini(translation.dat, errors, NotUsingThatIgnition)) | halt }
}
alias revertignition.msg { $dcc.battle.message($readini(translation.dat, system, IgnitionReverted)) } 
on 2:Chat:ACTION uses * * on *: {
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) | set %attack.target $6 | $covercheck($6, $4)
  $tech_cmd($nick , $4 , %attack.target, $7) | halt 
} 
on 2:Chat:uses * * on *: {
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $set_chr_name($nick) | set %attack.target $5 | $covercheck($5, $3)
  $tech_cmd($nick , $3 , %attack.target, $6) | halt 
} 
on 2:Chat:ACTION sings *: {
  if (%battleis = off) { halt }
  if ($4 != $null) { halt }

  $set_chr_name($nick) 

  if ($person_in_mech($nick) = true) { $dcc.private.message($nick,$readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick,$readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick,$readini(translation.dat, status, CurrentlyConfused)) | halt }
  $sing.song($nick, $3)
}
on 2:Chat:sings *: {
  if (%battleis = off) { halt }
  if ($3 != $null) { halt }

  $set_chr_name($nick) 

  if ($person_in_mech($nick) = true) { $dcc.private.message($nick,$readini(translation.dat, errors, Can'tDoThatInMech)) | halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick,$readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick,$readini(translation.dat, status, CurrentlyConfused)) | halt }
  $sing.song($nick, $2)
}
ON 2:Chat:!use*: {  unset %real.name | unset %enemy
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { $dcc.private.message($nick, $readini(translation.dat, battle, NotAllowedBattleCondition))  | halt }
  if (($person_in_mech($nick) = true) && ($4 = $nick)) { $display.system.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }

  $uses_item($nick, $2, $3, $4)
}
ON 2:Chat:!taunt*: { $set_chr_name($nick)
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $taunt($nick, $2) | halt 
}
on 2:Chat:ACTION taunts *: {
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $taunt($nick , $3) | halt 
}
on 2:Chat:taunts *: {
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyCharmed)) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $dcc.private.message($nick, $readini(translation.dat, status, CurrentlyConfused)) | halt }
  $taunt($nick , $2) | halt 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Auction House Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!auction info*: { $auction.status($nick) }
on 2:Chat:!auction winner*: { $auctionhouse.winners($nick, $3) }
on 2:Chat:!auction bid*: { $auctionhouse.bid($nick, $3) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Skills
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:Chat:!speed*: {  $skill.speedup($nick) }
ON 2:Chat:!elemental seal*: { $skill.elementalseal($nick) }
ON 2:Chat:!elementalseal*: { $skill.elementalseal($nick) }
ON 2:Chat:!mighty strike*: { $skill.mightystrike($nick) }
ON 2:Chat:!mightystrike*: { $skill.mightystrike($nick) }
ON 2:Chat:!truestrike*: { $skill.truestrike($nick) }
ON 2:Chat:!true strike*: { $skill.truestrike($nick) }
ON 2:Chat:!mana wall*: { $skill.manawall($nick) }
ON 2:Chat:!manawall*: { $skill.manawall($nick) }
ON 2:Chat:!royal guard*: { $skill.royalguard($nick) }
ON 2:Chat:!royalguard*: { $skill.royalguard($nick) }
ON 2:Chat:!perfect defense*: { $skill.perfectdefense($nick) }
ON 2:Chat:!perfectdefense*: { $skill.perfectdefense($nick) }
ON 2:Chat:!utsusemi*: { $skill.utsusemi($nick) }
ON 2:Chat:!fullbring*: { $skill.fullbring($nick, $2) }
ON 2:Chat:!double turn*: { $skill.doubleturn($nick) }
ON 2:Chat:!doubleturn*: { $skill.doubleturn($nick) }
ON 2:Chat:!sugitekai*: { $skill.doubleturn($nick) }
ON 2:Chat:!meditate*: { $skill.meditate($nick) }
ON 2:Chat:!conserve TP*: { $skill.conserveTP($nick) }
ON 2:Chat:!conserveTP*: { $skill.conserveTP($nick) }
ON 2:Chat:!bloodboost*: { $skill.bloodboost($nick) }
ON 2:Chat:!blood boost*: { $skill.bloodboost($nick) }
ON 2:Chat:!bloodspirit*: { $skill.bloodspirit($nick) }
ON 2:Chat:!blood spirit*: { $skill.bloodspirit($nick) }
ON 2:Chat:!drainsamba*: { $skill.drainsamba($nick) }
ON 2:Chat:!drain samba*: { $skill.drainsamba($nick) }
ON 2:Chat:!regen*: { $skill.regen($nick) }
ON 2:Chat:!regeneration*: { $skill.regen($nick) }
ON 2:Chat:!stop regen*:{ $skill.regen.stop($nick) } 
ON 2:Chat:!kikouheni*: { $skill.kikouheni($nick, $2) }
ON 2:Chat:!clone*: { $skill.clone($nick) }
ON 2:Chat:!shadowcopy*: { $skill.clone($nick) }
ON 2:Chat:!shadow copy*: { $skill.clone($nick) }
ON 2:Chat:!shadow *: { $skill.clonecontrol($nick, $2, $3, $4) }
ON 2:Chat:!steal*: { $skill.steal($nick, $2, !steal) }
ON 2:Chat:!analyze*: { $skill.analysis($nick, $2) }
ON 2:Chat:!analysis*: { $skill.analysis($nick, $2) }
ON 2:Chat:!quicksilver*: { $skill.quicksilver($nick) }
ON 2:Chat:!cover*: { $skill.cover($nick, $2) }
ON 2:Chat:!snatch*: { $skill.snatch($nick, $2) }
ON 2:Chat:!aggressor*: { $skill.aggressor($nick) }
ON 2:Chat:!defender*: { $skill.defender($nick) }
ON 2:Chat:!alchemy*: { $skill.alchemy($nick, $2) }
ON 2:Chat:!craft*: { $skill.alchemy($nick, $2) }
ON 2:Chat:!holy aura*: { $skill.holyaura($nick) }
ON 2:Chat:!holyaura*: { $skill.holyaura($nick) }
ON 2:Chat:!provoke*: { $skill.provoke($nick, $2) }
ON 2:Chat:!weaponlock*: { $skill.weaponlock($nick, $2) }
ON 2:Chat:!weapon lock*: { $skill.weaponlock($nick, $3) }
ON 2:Chat:!disarm*: { $skill.disarm($nick, $2) }
ON 2:Chat:!konzen-ittai*: { $skill.konzen-ittai($nick) }
ON 2:Chat:!sealbreak*: { $skill.sealbreak($nick) }
ON 2:Chat:!seal break*: { $skill.sealbreak($nick) }
ON 2:Chat:!magicmirror*: { $skill.magicmirror($nick) }
ON 2:Chat:!gamble*: { $skill.gamble($nick) }
ON 2:Chat:!third eye*: { $skill.thirdeye($nick) }
ON 2:Chat:!thirdeye*: { $skill.thirdeye($nick) }
ON 2:Chat:!scavenge*: { $skill.scavenge($nick, $2, !scavenge) }
ON 2:Chat:!perfectcounter*: { $skill.perfectcounter($nick) }
ON 2:Chat:!perfect counter*: { $skill.perfectcounter($nick) }
ON 2:Chat:!justrelease*: { $skill.justrelease($nick, $2, !justrelease) }
ON 2:Chat:!just release*: { $skill.justrelease($nick, $3, !justrelease) }
ON 2:Chat:!retaliation*: { $skill.retaliation($nick) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admin commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 50:Chat:!summon*: { 
  if ($2 = npc) {
    if ($isfile($npc($3)) = $true) {
      .copy -o $npc($3) $char($3)
      $boost_monster_stats($3)  
      $enter($3)
    }
    else { $dcc.private.message($nick,$readini(translation.dat, errors, NPCDoesNotExist)) | halt }
  }
  if ($2 = monster) {
    var %number.of.monsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
    if ($isfile($mon($3)) = $true) {
      .copy -o $mon($3) $char($3)
      $enter($3)
      var %number.of.players $readini($txtfile(battle2.txt), battleinfo, players)
      if (%number.of.players = $null) { var %number.of.players 1 }
      $boost_monster_stats($3)  
      $fulls($3) |  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
    }
    else { $dcc.private.message($nick,$readini(translation.dat, errors, monsterdoesnotexist)) | halt }
  }

  if ($2 = boss) {
    var %number.of.monsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
    if ($isfile($boss($3)) = $true) {
      .copy -o $boss($3) $char($3)
      $enter($3)
      var %number.of.players $readini($txtfile(battle2.txt), battleinfo, players)
      if (%number.of.players = $null) { var %number.of.players 1 }
      $boost_monster_stats($3)  
      $fulls($3) |  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
    }
    else { $dcc.private.message($nick,$readini(translation.dat, errors, monsterdoesnotexist)) | halt }
  }
}
ON 50:Chat:!zap*: { $set_chr_name($2) | $checkchar($2) | $zap_char($2) | $dcc.global.message($readini(translation.dat, system, zappedcomplete)) | halt }

ON 50:Chat:!next*: {
  if (%battleis = on)  { $check_for_double_turn(%who) }
  else { $display.system.message($readini(translation.dat, Errors, NoCurrentBattle), private) | halt }
}
ON 50:Chat:!startbat*: {
  if (%battleis = on) { $display.system.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($2) 
}
ON 50:Chat:!start bat*: {
  if (%battleis = on) { $display.system.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($3) 
}
ON 50:Chat:!new bat*: {
  if (%battleis = on) { $display.system.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($3) 
}
ON 50:Chat:!end bat*: { $endbattle($3) } 
ON 50:Chat:!endbat*: { $endbattle($2) } 
ON 50:Chat:!clear battle*: { $clear_battle }
ON 50:Chat:* enters the battle*: { $enter($1) }
ON 50:Chat:* flees the battle*: { $flee($1) }
ON 50:Chat:* taunts*: { 
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  if ($readini($char($1), Battle, HP) = $null) { halt }
  $set_chr_name($1) | $taunt($1, $3)
}
ON 50:Chat:!set streak*: { 
  if ($3 = $null) { .msg $nick 4!set streak # | halt }
  if ($3 <= 0) { .msg $nick the streak cannot be negative or 0. | halt }
  if (. isin $3) { .msg $nick the streak must be a whole number. | halt }
  writeini battlestats.dat battle LosingStreak 0
  writeini battlestats.dat battle winningstreak $3
  $display.system.message(3The winning streak has been set to: $3, global)
}

ON 50:Chat:!toggle ai system*: { 
  if ($readini(system.dat, system, aisystem) = off) { 
    writeini system.dat system aisystem on
    $display.system.message($readini(translation.dat, system, AiSystemOn), global)
  }
  else {
    writeini system.dat system aisystem off
    $display.system.message($readini(translation.dat, system, AiSystemOff), global)
  }
}
ON 50:Chat:!toggle automated battle system*: { 
  if ($readini(system.dat, system, automatedbattlesystem) = off) { 
    writeini system.dat system automatedbattlesystem on
    $display.system.message($readini(translation.dat, system, AutomatedBattleOn), global)
    if (%battleis = off) { $clear_battle }
  }
  else {
    writeini system.dat system automatedbattlesystem off
    $display.system.message($readini(translation.dat, system, AutomatedBattleOff), global)
  }
}
ON 50:Chat:!toggle battle formula*: { 
  if ($readini(system.dat, system, BattleDamageFormula) = 1) { 
    writeini system.dat system BattleDamageFormula 2
    $display.system.message($readini(translation.dat, system, NewDmgFormulaIsOn), global)
  }
  else { 
    writeini system.dat system BattleDamageFormula 1
    $display.system.message($readini(translation.dat, system, NewDmgFormulaIsOff), global)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; For normal actions let's
; do the command emote 
; instead.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:emote *: {  $dcc.emote($2-) }

alias dcc.emote {
  var %p 1
  var %emotion 12 $+ $1-

  while ($chat(%p) != $null) { 
    var %nick $chat(%p)
    if (%nick == $nick) {  inc %p 1 } 
    else { 
      var %where $readini($char($nick), DCCchat, Room)
      if (%where = $null) { writeini $char($nick) DCCchat Room Lobby | var %where Lobby }
      if ((%where = BattleRoom) && (%battleis = off)) { writeini $char($nick) DCCchat Room Lobby | var %where Lobby }
      msg = $+ $chat(%p) 13*4[ $+ %where $+ ]7 $nick %emotion $+ 13 $+  *  | inc %p 1
    }
  }
  unset %emotion | halt
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is how the bot can do
; regular chatting, non-cmds.
; It has to go at the bottom 
; of the file to work right. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:CHAT:*:{ unset %^p

  if ($1 = ACTION) { $dcc.emote($2-) }
  var %where $readini($char($nick), DCCchat, Room)
  if (%where = $null) { writeini $char($nick) DCCchat Room Lobby | var %where Lobby }
  if ((%where = BattleRoom) && (%battleis = off)) { writeini $char($nick) DCCchat Room Lobby | var %where Lobby }

  var %p 1
  while ($chat(%p) != $null) {  var %nick $chat(%p) 
    if (%nick = $nick) { inc %p 1 }
    else {  msg = $+ $chat(%p) 4[ $+ %where $+ ] < $+ $nick $+ > 12 $+ $1-   | inc %p 1 } 
  }
  unset %p |  halt 
}
