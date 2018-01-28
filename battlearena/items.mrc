;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ITEMS COMMAND
;;;; Last updated: 01/27/18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 3:TEXT:!portal*:#: {
  if ($2 = usage) { $portal.usage.check(channel, $nick) }
  if ($2 = dropcheck) { $portal.dropcheck.check($3) }
}

on 3:TEXT:!portal*:?: {
  if ($2 = usage) { $portal.usage.check(private, $nick) }
  if ($2 = dropcheck) { $portal.dropcheck.check($3) }
}

on 3:TEXT:!dungeon usage:#: { $dungeon.usage.check(channel, $nick) }
on 3:TEXT:!dungeon usage:?: { $dungeon.usage.check(private, $nick) }

alias dungeon.usage.check {
  $set_chr_name($2)

  var %player.laststarttime $readini($char($2), info, LastDungeonStartTime)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %player.laststarttime)

  var %dungeon.time.setting 86400 

  if ((%time.difference = $null) || (%time.difference < %dungeon.time.setting)) { 
    if ($1 = channel) { $display.message($readini(translation.dat, errors, DungeonUsageNotReady), private) }
    if ($1 = private) { $display.private.message($readini(translation.dat, errors, DungeonUsageNotReady)) }
    if ($1 = dcc) { $dcc.private.message($2, $readini(translation.dat, errors, DungeonUsageNotReady)) }
    halt 
  }

  if ($1 = channel) { $display.message($readini(translation.dat, system, DungeonUsageOK), private) }
  if ($1 = private) { $display.private.message($readini(translation.dat, system, DungeonUsageOK)) }
  if ($1 = dcc) { $dcc.private.message($2, $readini(translation.dat, system, DungeonUsageOK)) }
}

alias portal.usage.check { 
  $set_chr_name($2)

  if (($readini(system.dat, system, LimitPortalBattles) = true) ||  ($readini(system.dat, system, LimitPortalBattles) = $null)) {

    $portal.clearusagecheck($2)

    var %base.portal.usage.amount $portal.dailymaxlimit
    var %last.portal.number.used $readini($char($2), info, PortalsUsedTotal)
    var %enhancements.portalusage $readini($char($2), enhancements, portalusage)
    if (%last.portal.number.used = $null) { var %last.portal.number.used 0 }
    if (%enhancements.portalusage = $null) { var %enhancements.portalusage 0 }

    inc %base.portal.usage.amount %enhancements.portalusage

    if (%last.portal.number.used = $null) { var %last.portal.number.used 0 }
    var %portal.uses.left $calc(%base.portal.usage.amount - %last.portal.number.used)

    if ($1 = channel) { $display.message($readini(translation.dat, system, PortalUsageCheck), private) }
    if ($1 = private) { $display.private.message($readini(translation.dat, system, PortalUsageCheck)) }
    if ($1 = dcc) { $dcc.private.message($2, $readini(translation.dat, system, PortalUsageCheck)) }
  }
  else {
    if ($1 = channel) { $display.message($readini(translation.dat, system, PortalUsageCheckUnlimited), private) }
    if ($1 = private) { $display.private.message($readini(translation.dat, system, PortalUsageCheckUnlimited)) }
    if ($1 = dcc) { $dcc.private.message($2, $readini(translation.dat, system, PortalUsageCheckUnlimited)) }
  }
}

alias portal.dropcheck.check {
  ; Alias searches for portals, that drop certain items

  ; $1 = item

  var %drops.lines $lines($dbfile(drops.db))
  var %portals.lines $lines($lstfile(items_portal.lst))
  var %drops.line.counter 1
  while (%drops.line.counter < %drops.lines) {
    var %drops.line = $read($dbfile(drops.db), n, %drops.line.counter)
    if ($istok($gettok(%drops.line, 2, 61), $1, 46)) {
      var %drops.monster $gettok(%drops.line, 1, 61)
      var %portals.line.counter 1
      while (%portals.line.counter < %portals.lines) {
        var %portal.line $read($lstfile(items_portal.lst), n, %portals.line.counter)
        var %portal.monster $readini($dbfile(items.db), n, %portal.line, Monster)
        if (%drops.monster isin %portal.monster) {
          if (!%dropcheck.result) { var %dropcheck.result %portal.line }
          else { %dropcheck.result = $addtok(%dropcheck.result,%portal.line,46) }
        }
        inc %portals.line.counter
      }
    }
    inc %drops.line.counter
  }
  var %dropcheck.amount $numtok(%dropcheck.result, 46)
  if (!%dropcheck.result) { $display.private.message($readini(translation.dat, system, PortalDropCheckNoResults)) }
  else { $display.private.message($readini(translation.dat, system, PortalDropCheckResults)) }
}

on 3:TEXT:!count*:#: {  
  if ($3 = $null) { $item.countcmd($nick, $2, public) }
  if ($3 != $null) { $checkchar($2) | $item.countcmd($2, $3, public) }
}
on 3:TEXT:!count*:?: {  
  if ($3 = $null) { $item.countcmd($nick, $2, private) }
  if ($3 != $null) { $checkchar($2) | $item.countcmd($2, $3, private) }
}

alias item.countcmd {
  var %player.count.amount $item.amount($1, $2)
  $set_chr_name($1) 

  if (($3 = public) || ($3 = $null)) { 
    if (%player.count.amount > 0) { $display.message($readini(translation.dat, system, CountItem), private) | halt }
    if ((%player.count.amount <= 0) || (%player.count.amount = $null)) { $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
  }
  if ($3 = private) {
    if (%player.count.amount > 0) { $display.private.message($readini(translation.dat, system, CountItem)) | halt }
    if ((%player.count.amount <= 0) || (%player.count.amount = $null)) { $display.private.message($readini(translation.dat, errors, DoesNotHaveThatItem)) | halt }
  }
}

on 3:TEXT:!use*:*: {  unset %real.name | unset %enemy | $set_chr_name($nick)
  $no.turn.check($nick, return)
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { 
    if ((%battleis = on) && ($istok($readini($txtfile(battle2.txt), Battle, List),$nick,46) = $true)) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition), private) | halt }
  }
  if ((no-item isin $readini($dbfile(battlefields.db), %current.battlefield, limitations)) && (%battleis = on)) { 
    if ($istok($readini($txtfile(battle2.txt), Battle, List), $nick, 46) = $true) { $display.message($readini(translation.dat, battle, NotAllowedBattlefieldCondition), private) | halt }
  }

  if ($person_in_mech($nick) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }

  if ($readini($dbfile(items.db), $2, type) = cosmic) { $item.cosmic($nick, $3, $2) | halt }

  if ($4 = $null) { 
    if ($readini($dbfile(items.db), $2, type) = tormentreward) { $uses_item($nick, $2, on, $nick, $3) }
    else { $uses_item($nick, $2, on, $nick) }
  }
  else {  
    $partial.name.match($nick, $4)
    $uses_item($nick, $2, $3, %attack.target)
  }
}

ON 50:TEXT:*uses item * on *:*:{  $set_chr_name($1)
  if ($1 = uses) { halt }
  if ($5 != on) { halt }

  if ($readini($dbfile(items.db), $4, type) != key) {  $no.turn.check($1) }

  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { 
    if ((%battleis = on) && ($istok($readini($txtfile(battle2.txt), Battle, List),$1,46) = $true)) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition), private) | halt }
  }
  if ((no-item isin $readini($dbfile(battlefields.db), %current.battlefield, limitations)) && (%battleis = on)) { 
    if ($istok($readini($txtfile(battle2.txt), Battle, List), $1, 46) = $true) { $display.message($readini(translation.dat, battle, NotAllowedBattlefieldCondition), private) | halt }
  }  

  $partial.name.match($1, $6)
  $uses_item($1, $4, $5, %attack.target)
}

ON 3:TEXT:*uses item * on *:*:{  $set_chr_name($1)
  if ($1 = uses) { halt }
  if ($5 != on) { halt }

  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($readini(translation.dat, errors, PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($readini(translation.dat, errors, PlayerAccessOffDueToLogin), private) | halt }

  if ($readini($dbfile(items.db), $4, type) != key) { $no.turn.check($1) }
  if ($readini($dbfile(items.db), $4, type) = portal) { $display.message($readini(translation.dat, errors, Can'tUseOtherPlayers Portals), private) | halt }

  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { 
    if ((%battleis = on) && ($istok($readini($txtfile(battle2.txt), Battle, List),$1,46) = $true)) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition), private) | halt }
  }
  if ((no-item isin $readini($dbfile(battlefields.db), %current.battlefield, limitations)) && (%battleis = on)) { 
    if ($istok($readini($txtfile(battle2.txt), Battle, List), $1, 46) = $true) { $display.message($readini(translation.dat, battle, NotAllowedBattlefieldCondition), private) | halt }
  }  

  if ($readini($char($1), info, clone) = yes) {  $display.message($readini(translation.dat, errors, CloneCannotUseItem), private) | halt }

  $partial.name.match($1, $6)
  $uses_item($1, $4, $5, %attack.target)
}
alias uses_item {
  unset %attack.target
  var %item.type $readini($dbfile(items.db), $2, type)

  if (%item.type = dungeon) { $item.dungeon($1, $2) | halt }
  if (%item.type = torment) { $item.torment($1, $2) | halt }

  if (((((((((%item.type != summon) && (%item.type != key) && (%item.type != shopreset) && (%item.type != food) && (%item.type != trust) && (%item.type != increaseWeaponLevel) && (%item.type != increaseTechLevel) && (%item.type != revive) && (%item.type != portal))))))))) {
    if (($3 != on) || ($3 = $null)) {  $display.message($readini(translation.dat, errors, ItemUseCommandError), private) | halt }
    if ($4 = me) {  $display.message($1 $readini(translation.dat, errors, MustSpecifyName), private) | halt }
    if ($readini($char($4), battle, status) = dead) { $display.message($readini(translation.dat, errors, CannotUseItemOnDead), private) | halt }
    $checkchar($4) 
    if (%battleis = on) { $person_in_battle($4) }
  }

  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($4), info, flag)

  if (%item.type = instrument) { $display.message($readini(translation.dat, errors,ItemIsUsedForSinging), private) | halt }

  if ((%item.type = misc) || (%item.type = gem)) { $display.message($readini(translation.dat, errors,ItemIsUsedForCrafting), private) | halt }


  if (%item.type = food) { 
    $checkchar($4)
    if ($4 = $null) { $item.food($1, $1, $2) }
    else {  $item.food($1, $4, $2) }
    $decrease_item($1, $2) | halt 
  }

  if (%item.type = increaseWeaponLevel) { $set_chr_name($1) 
    if ($4 = $null) { $display.message($readini(translation.dat, errors, MustSpecifyWeaponname), private) | halt }
    if (($readini($char($1), weapons, $4) = $null) || ($readini($char($1), weapons, $4) = 0)) { $display.message($readini(translation.dat, errors, MustSpecifyWeaponname), private) | halt }
    if ($4 = mythic) { $display.message($readini(translation.dat, errors, CannotUpgradeMythicWithItem), private) | halt }


    $item.increasewpnlvl($1, $4, $2) 
    $decrease_item($1, $2) | halt
  }

  if (%item.type = increaseTechLevel) { 
    $set_chr_name($1) 
    if ($4 = $null) { $display.message($readini(translation.dat, errors, MustSpecifyTechname), private) | halt }
    if (($readini($char($1), techniques, $4) = $null) || ($readini($char($1), techniques, $4) = 0)) { $display.message($readini(translation.dat, errors, MustSpecifyTechname), private) | halt }
    $item.increasetechlvl($1, $4, $2) 
    $decrease_item($1, $2) | halt
  }

  if (%item.type = portal) {
    if (%battleis = on) { $check_for_battle($1) }
    if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }
    if (%portal.bonus = true) { $display.message($readini(translation.dat, errors, AlreadyInPortal), private) | halt }
    if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { $display.message($readini(translation.dat, errors, NoPortalsDuringShenron), private) | halt }

    if (%mode.gauntlet = on) { $display.message($readini(translation.dat, errors, PortalItemNotWorking) , private) | halt  }  
    if (%battle.type = boss) { $display.message($readini(translation.dat, errors, PortalItemNotWorking) , private) | halt  }  

    if ($return_winningstreak >= 20) { $display.message($readini(translation.dat, errors, StreakTooHighForPortals), private) | halt }

    ; Check to see if a portal battle can be done via the limiting..

    if (($readini(system.dat, system, LimitPortalBattles) = true) ||  ($readini(system.dat, system, LimitPortalBattles) = $null)) {

      $portal.clearusagecheck($1)

      var %last.portal.number.used $readini($char($1), info, PortalsUsedTotal)
      if (%last.portal.number.used = $null) { var %last.portal.number.used 0 }

      var %daily.portal.cap 10

      var %enhancements.portalusage $readini($char($1), enhancements, portalusage)
      if (%enhancements.portalusage != $null) { inc %daily.portal.cap %enhancements.portalusage }

      if (%last.portal.number.used >= %daily.portal.cap) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, MaxPortalItemsAllowed), private) | halt }

      inc %last.portal.number.used 1 
      writeini $char($1) info PortalsUsedTotal %last.portal.number.used
      writeini $char($1) info LastPortalDate $adate
    }

    ; Turn on the portal flag
    set %portal.bonus true

    ; Remove old drop items
    remini $txtfile(battle2.txt) Battle bonusitem

    ; Write the portal item
    writeini $txtfile(battle2.txt) battleinfo PortalItem $2

    ; Write the portal's level
    var %portal.level $readini($dbfile(items.db), $2, PortalLevel)
    if (%portal.level != $null) { writeini $txtfile(battle2.txt) battleinfo Portallevel %portal.level }
    if (%portal.level = $null) {
      var %boss.level.monster $gettok($readini($dbfile(items.db), $2, Monster), 1, 46)
      if ($isfile($boss(%boss.level.monster)) = $true) { 
        var %boss.level $readini($boss(%boss.level.monster), info, bosslevel)  
        if (%boss.level != $null) { writeini $txtfile(battle2.txt) battleinfo PortalLevel %boss.level }
      }
      else {
        if ($isfile($mon(%boss.level.monster)) = $true) { 
          var %boss.level $readini($mon(%boss.level.monster), info, bosslevel)  
          if (%boss.level != $null) { writeini $txtfile(battle2.txt) battleinfo PortalLevel %boss.level }
        }
      }
    }


    ; Change the battlefield
    unset %battleconditions
    set %current.battlefield $readini($dbfile(items.db), $2, Battlefield)
    writeini $dbfile(battlefields.db) weather current $readini($dbfile(items.db), $2, weather)

    ; check for limitations
    $battlefield.limitations

    if (($readini(system.dat, system, ForcePortalSync) = true) && ($readini($dbfile(items.db), $2, PortalLevel) != $null)) {
      $portal.sync.players(%portal.level)
      $display.message($readini(translation.dat, system, PortalLevelsSynced), battle)
      writeini $txtfile(battle2.txt) battleinfo averagelevel %portal.level 
      writeini $txtfile(battle2.txt) battleinfo highestlevel %portal.level 
      writeini $txtfile(battle2.txt) battleinfo PlayerLevels %portal.level 
    } 

    if ($readini($dbfile(items.db), $2, PortalLevel) = $null) { $portal.uncapped.battleconditionscheck }


    ; Show the description
    $set_chr_name($1) | $display.message( $+ %real.name  $+ $readini($dbfile(items.db), $2, desc), battle)

    set %monster.to.spawn $readini($dbfile(items.db), $2, Monster)

    if ($numtok(%monster.to.spawn,46) = 1) { $portal.item.onemonster }
    if ($numtok(%monster.to.spawn,46) > 1) { $portal.item.multimonsters }

    ; Set the allied notes value
    var %allied.notes $readini($dbfile(items.db), $2, alliednotes)   
    if (%allied.notes = $null) { var %allied.notes 100 }
    writeini $txtfile(battle2.txt) battle alliednotes %allied.notes

    ; Reduce the item
    $decrease_item($1, $2) 

    ; set the current turn back to 1
    set %current.turn 1

    ; Set a flag for portal battles
    set %previous.battle.type portal
    set %clearactionpoints true

    ; check for custom darkness turns
    var %custom.darkness.turns $readini($dbfile(items.db), $2, DarknessTurns)
    if (%custom.darkness.turns != $null) { set %darkness.turns %custom.darkness.turns }

    if ($readini(system.dat, system, botType) = DCCchat) {  
      $battlelist(public) 
      if (%battleis = on)  { $check_for_double_turn($1, forcenext) | halt }
    }
    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      /.timerSlowDown $+ $rand(1,1000) $+ $rand(a,z) 1 3 /battlelist public
      /.timerSlowDown2 $+ $rand(1,1000) $+ $rand(a,z) 1 5 /check_for_double_turn $1 forcenext
      halt
    }

  }

  if (%item.type = key) { $item.key($1, $4, $2) |  $decrease_item($1, $2)  | halt }
  if (%item.type = consume) { $display.message($readini(translation.dat, errors, ItemIsUsedInSkill), private) | halt }
  if (%item.type = ammo) { $display.message($readini(translation.dat, errors, ItemIsUsedAsAmmo), private) | halt }
  if (%item.type = accessory) { $display.message($readini(translation.dat, errors, ItemIsAccessoryEquipItInstead), private) | halt }
  if (%item.type = random) { $item.random($1, $4, $2) | $decrease_item($1, $2) | halt }
  if (%item.type = TormentReward) { 
    var %amount.to.open $abs($5)

    if ((%amount.to.open = $null) || (%amount.to.open !isnum 1-10)) { var %amount.to.open 1 }
    if (%amount.to.open > $readini($char($1), Item_Amount, $2)) { var %amount.to.open 1 }

    $item.tormentreward($1, $1, $2, %amount.to.open) | $decrease_item($1, $2, %amount.to.open) | halt 
  }
  if (%item.type = special) { $item.special($1, $4, $2) | $decrease_item($1, $2) | halt }
  if (%item.type = trust) { 
    if ((no-trust isin %battleconditions) || (no-trusts isin %battleconditions)) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition), private) | halt }
    else { $item.trust($1, $4, $2) | halt }
  }

  if (%item.type = shopreset) {
    if (%target.flag = monster) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }

    if ($4 = $null) { $item.shopreset($1, $1, $2) }
    if ($4 != $null) { 
      if ($4 != $1) { $display.message($readini(translation.dat, errors, CannotUseDiscountCardOnOthers), private) | halt }
      $item.shopreset($1, $4, $2)
    }

    $decrease_item($1, $2) 
    halt  
  }

  $check_for_battle($1) 
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }

  if (%mode.pvp = on) { var %target.flag monster | var %user.flag monster }

  if (%item.type = damage) {
    if ((%target.flag != monster) && (%user.flag = $null)) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters), private) | halt }

    ; Decrease the action points
    $action.points($1, remove, 2)

    $item.damage($1, $4, $2)
  }

  if (%item.type = snatch) {
    if (%target.flag != monster) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters), private) | halt }

    ; Decrease the action points
    $action.points($1, remove, 2)

    $item.snatch($1, $4, $2)
  }

  if (%item.type = heal) {
    $checkchar($4)
    if ((%target.flag = monster) && ($readini($char($4), monster, type) != zombie)) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }

    ; Decrease the action points
    $action.points($1, remove, 2)

    $item.heal($1, $4, $2)
  }
  if (%item.type = CureStatus) {
    if ((%target.flag = monster) && ($readini($char($4), monster, type) != zombie)) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    $set_chr_name($4) | var %enemy %real.name
    $item.curestatus($1, $4, $2)
    $decrease_item($1, $2)

    ; Decrease the action points
    $action.points($1, remove, 1)

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = tp) { 
    if ($person_in_mech($4) = true) { $display.message($readini(translation.dat, errors, ItemNotWorkOnMech), private) | halt }
    if (%target.flag = monster) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    ; Show the desc
    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($1) 
    $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $2, desc), battle)
    $item.tp($1, $4, $2)
    $decrease_item($1, $2) 

    ; Decrease the action points
    $action.points($1, remove, 2)

    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = ignitiongauge) { 
    if (%target.flag = monster) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    ; Show the desc
    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($1) 
    $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $2, desc), battle)
    $item.ig($1, $4, $2)
    $decrease_item($1, $2) 

    ; Decrease the action points
    $action.points($1, remove, 2)

    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = status) {
    if ($readini($dbfile(items.db), $2, amount) = 0) { 
      ; Decrease the action points
      $action.points($1, remove, 2)
      $item.status($1, $4, $2) 
    }
    else { 
      if ((%target.flag != monster) && (%user.flag = $null)) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters), private) | halt }

      ; Decrease the action points
      $action.points($1, remove, 2)

      $item.status($1, $4, $2)
    }
  }

  if (%item.type = autorevive) {  
    $check_for_battle($1)
    if (%target.flag = monster) {  $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers),private) | halt }
    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious), private)  | unset %real.name | halt }
    if ($readini($char($4), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead), private) | unset %real.name | halt }


    var %clone.flag $readini($char(%count.who.battle), info, clone)
    var %doppel.flag $readini($char(%count.who.battle), info, Doppelganger)
    var %object.flag $readini($char(%count.who.battle), monster, type)

    if (((%clone.flag = true) || (%doppel.flag = true) || (%object.flag = true))) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers),private) | halt }

    var %total.goldorbs.used $readini($txtfile(battle2.txt), GoldOrbs, $1)
    if (%total.goldorbs.used = $null) { var %total.goldorbs.used 0 }

    if (%total.goldorbs.used  >= 4) { $display.message($readini(translation.dat, errors, GoldOrbNoLongerWorks), private) | halt }

    inc %total.goldorbs.used 1
    writeini $txtfile(battle2.txt) GoldOrbs $1 %total.goldorbs.used

    ; Decrease the action points
    $action.points($1, remove, 2)

    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($1) 
    $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $2, desc), battle)
    $item.autorevive($1, $4, $2) 

    $decrease_item($1, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = revive) {  
    $check_for_battle($1)
    var %target.flag $readini($char($4), info, flag)

    if (%target.flag = monster) {  $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers),private) | halt }
    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious), private)  | unset %real.name | halt }
    if ($readini($char($4), Battle, Status) != dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotUseOnLivePerson), private) | unset %real.name | halt }

    var %summon.flag $readini($char($4), info, summon)
    var %clone.flag $readini($char($4), info, clone)
    var %doppel.flag $readini($char($4), info, Doppelganger)
    var %object.flag $readini($char($4), monster, type)

    if (((%clone.flag = true) || (%doppel.flag = true) || (%object.flag = object))) { $display.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers),private) | halt }

    ; Decrease the action points
    $action.points($1, remove, 2)

    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($1) 
    $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $2, desc), battle)
    $decrease_item($1, $2) 

    var %revive.amount $readini($dbfile(items.db), $2, ReviveAmount)

    $character.revive($4, %revive.amount)

    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = summon) { 
    if ((no-summon isin %battleconditions) || (no-summons isin %battleconditions)) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition), private) | halt }
    if ($readini($char($1 $+ _clone), battle, hp) != $null) { $display.message($readini(translation.dat, errors, CanOnlyUseSummonOrDoppel), private) | halt }

    ; Decrease the action points
    $action.points($1, remove, 2)

    $item.summon($1, $2) 
  }

  $decrease_item($1, $2)

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

alias decrease_item {
  ; $3 = the amount to remove

  var %amount.to.remove $3
  if ($3 = $null) { var %amount.to.remove 1 }

  ; Subtract the item and tell the new total
  var %check.item $readini($char($1), item_amount, $2)
  dec %check.item %amount.to.remove 
  writeini $char($1) item_amount $2 %check.item
}

alias item.increasewpnlvl {
  ; $1 = person using the item
  ; $2 = weapon name
  ; $3 = item name

  var %current.weapon.level $readini($char($1), weapons, $2)
  var %weapon.increase.amount $readini($dbfile(items.db), $3, IncreaseAmount)
  if (%weapon.increase.amount = $null) { var %weapon.increase.amount 1 }

  inc %current.weapon.level %weapon.increase.amount
  if (%current.weapon.level > 500) {  $display.message($readini(translation.dat, errors, Can'tLevelWeaponOver500),private) | halt }

  writeini $char($1) weapons $2 %current.weapon.level

  $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $3, desc), global)
  $display.message($readini(translation.dat, system, WeaponLevelIncreasedItem), global)
}

alias item.increasetechlvl {
  ; $1 = person using the item
  ; $2 = tech name
  ; $3 = item name

  var %current.tech.level $readini($char($1), techniques, $2)
  var %tech.increase.amount $readini($dbfile(items.db), $3, IncreaseAmount)
  if (%tech.increase.amount = $null) { var %tech.increase.amount 1 }

  inc %current.tech.level %tech.increase.amount
  if (%current.tech.level > 500) {  $display.message($readini(translation.dat, errors, Can'tLevelTechOver500),private) | halt }

  writeini $char($1) techniques $2 %current.tech.level

  $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $3, desc), global)
  $display.message($readini(translation.dat, system, TechLevelIncreasedItem), global)
}

alias item.summon {
  ; $1 = user
  ; $2 = item used

  ; Check to make sure the monster isn't already summoned and the user has the skill needed.
  if ($skillhave.check($1, BloodPact) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkillNeeded), private) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { $set_chr_name($1) | $display.message($readini(translation.dat, skill, AlreadyUsedBloodPact), private)  | halt }

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; Get the summon via the item.
  set %summon.name $readini($dbfile(items.db), p, $2, summon)

  ; Check to see if the item itself has a description.
  if ($readini($dbfile(items.db), $2, desc) != $null) {  $set_chr_name($1)  | $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $2, desc), battle) }

  $skill.bloodpact($1, %summon.name, $2)

  unset %summon.name
}

alias item.key {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  $set_chr_name($1)

  var %chest.color $readini($txtfile(treasurechest.txt), ChestInfo, Color)
  if (%chest.color = $null) { $display.message($readini(translation.dat, errors, NoChestExists), private) | halt }
  if ($readini($dbfile(items.db), $3, Unlocks) != %chest.color) { $display.message($readini(translation.dat, errors, WrongChestKey), private) | halt }

  ; Check to see if the chest is already being unlocked.
  if (%keyinuse = true) { $display.message($readini(translation.dat, errors, ChestAlreadyBeingOpened), private) | halt }

  set %keyinuse true
  $item.open.chest($1, $2, $3)
}

alias item.open.chest {

  ; Get the chest contents and amount.
  set %chest.item $readini($txtfile(treasurechest.txt), ChestInfo, Contents)
  set %chest.amount $readini($txtfile(treasurechest.txt), ChestInfo, Amount)

  if (%chest.item = $null) { $display.message(4ERROR: Chest item is null. Alert the bot admin to check the chest .lst file) | halt }

  ; Check for a mimic chance if streak is greater than 50
  var %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak >= 50) {
    var %mimic.chance $readini(system.dat, system, MimicChance)
    if (%mimic.chance = $null) { var %mimic.chance 5 }

    var %random.mimic.chance $rand(1,100)

    ; Contrary to reason, decreasing the chance increases the odds.
    if ($accessory.check($1, IncreaseMimicOdds) = true) {
      if (%accessory.amount = 0) { var %accessory.amount 1 }
      dec %random.mimic.chance %accessory.amount
      unset %accessory.amount
    }

    if (%chest.item = RedOrbs) { var %mimic.chance -1000 }
    if (%previous.battle.type = portal) { var %mimic.chance -1000 }
    if (%supplyrun = on) { var %mimic.chance -1000 }
    if (%random.mimic.chance <= %mimic.chance) { $display.message($readini(translation.dat, system, ChestMimic), global) | $start.mimic.battle | return }
  }

  if (%chest.item = BlackOrb) { 
    set %chest.item Black Orb
    var %current.orbs $readini($char($1), stuff, BlackOrbs)
    inc %current.orbs %chest.amount
    writeini $char($1) stuff BlackOrbs %current.orbs
    remini $char($1) item_amount Black
  }
  else if (%chest.item = RedOrbs) {
    set %chest.item $readini(system.dat, system, currency)
    var %current.orbs $readini($char($1), stuff, RedOrbs)

    var %open.level $get.level($1)
    if (%open.level >= $readini(battlestats.dat, battle, WinningStreak)) {  $chest.adjustredorbs }

    inc %current.orbs %chest.amount
    writeini $char($1) stuff RedOrbs %current.orbs
    remini $char($1) item_amount Red
  }

  else {
    set %current.player.items $readini($char($1), item_amount, %chest.item)
    if (%current.player.items = $null) { set %current.player.items 0 }
    inc %current.player.items %chest.amount
    if (%chest.item = $null) { echo -a 4,1ERROR Chest Item is NULL }
    if (%chest.item != $null) { writeini $char($1) item_amount %chest.item %current.player.items }
  }

  $set_chr_name($1)
  $display.message($readini(translation.dat, system, ChestOpened), global)
  /.timerChestDestroy off
  .remove $txtfile(treasurechest.txt)
  unset %keyinuse

  var %number.of.chests $readini($char($1), stuff, ChestsOpened)
  if (%number.of.chests = $null) { var %number.of.chests 0 }
  inc %number.of.chests 1
  writeini $char($1) stuff ChestsOpened %number.of.chests
  $achievement_check($1, MasterOfUnlocking)

  unset %chest.item | unset %current.items | unset %chest.amount | unset %previous.battle.type
  return
}

alias item.trust {
  ; $1 = user
  ; $2 = target
  ; $3 = item name

  $check_for_battle($1) 
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }

  ; is the battle level too low to use a trust?
  if ($return_winningstreak < 11) {  $display.message($readini(translation.dat, errors, StreakTooLowForTrusts), private) | halt }

  ; Trusts can only be used if the person is alone
  var %number.of.players.in.battle $readini($txtfile(battle2.txt), battleinfo, players)
  if (%number.of.players.in.battle != 1) { $display.message($readini(translation.dat, errors, TrustsOnlyForOnePlayer), battle) | halt }

  ; Only one Trust can be used at a time
  var %number.of.trusts.in.battle $readini($txtfile(battle2.txt), battleinfo, npcs)
  if (%number.of.trusts.in.battle != $null) { $display.message($readini(translation.dat, errors, TrustAlreadyUsed), battle) | halt }

  ; Is this a valid trust NPC?
  var %trust.npc $readini($dbfile(items.db), $3, NPC)
  if ($isfile($npc(%trust.npc)) = $false) { $display.message($readini(translation.dat, errors, TrustNPCDoesn'tExist), battle) | halt }

  ; Decrease the action points
  $action.points($1, remove, 1)

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  .copy -o $npc(%trust.npc) $char(%trust.npc) | var %curbat $readini($txtfile(battle2.txt), Battle, List) | %curbat = $addtok(%curbat,%trust.npc,46) |  writeini $txtfile(battle2.txt) Battle List %curbat 
  write $txtfile(battle.txt) %trust.npc

  var %trust.level $get.level($1)

  if ($accessory.check($1, IncreaseTrustFriendship) = true) {
    inc %trust.level %accessory.amount
    unset %accessory.amount
  }

  $boost_monster_hp(%trust.npc)
  $fulls(%trust.npc) 
  $levelsync(%trust.npc, %trust.level)

  if ($readini($char(%trust.npc), basestats, hp) > 10000) { writeini $char(%trust.npc) basestats hp 10000 | writeini $char(%trust.npc) battle hp 10000 }
  writeini $char(%trust.npc) info TrustNPC true

  $set_chr_name(%trust.npc) 

  var %custom.summon.desc $readini($dbfile(items.db), $3, SummonDesc)
  if (%custom.summon.desc != $null) { $display.message(4 $+ %custom.summon.desc) }
  else { $display.message(4 $+ %real.name has been summoned to the battlefield to help $get_chr_name($1) $+ !,battle) }


  $display.message(12 $+ %real.name  $+ $readini($char(%trust.npc), descriptions, char),battle)

  writeini $txtfile(battle2.txt) battleinfo npcs 1

  var %number.of.trusts $readini($char($1), stuff, TrustsUsed)
  if (%number.of.trusts = $null) { var %number.of.trusts 0 }
  inc %number.of.trusts 1
  writeini $char($1) stuff TrustsUsed %number.of.trusts
  $achievement_check($1, You'veGotAFriendInMe)

  writeini $char($1) skills doubleturn.on on
  $check_for_double_turn($1)

  halt 
}

alias item.special {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  $set_chr_name($1)

  var %exclusive.test $readini($dbfile(items.db), $3, exclusive)
  if (%exclusive.test = $null) { var %exclusive.test no }
  if ((%exclusive.test = yes) && ($2 != $1)) { $display.message($readini(translation.dat, errors, CannotUseItemOnSomeoneElse), private) | halt }

  var %special.type $readini($dbfile(items.db), $3, SpecialType)
  if (%special.type = GainWeapon) { 
    set %weapon.to.gain  $readini($dbfile(items.db), $3, Weapon)

    ; Check to see if the user already has this weapon
    set %user.weapon.level $readini($char($2), weapons, %weapon.to.gain)
    if (%user.weapon.level != $null) {  unset %user.weapon.level | $set_chr_name($2) | $display.message($readini(translation.dat, errors, AlreadyLearnedThisWeapon), private) | unset %weapon.to.gain | halt }

    writeini $char($2) weapons %weapon.to.gain 1

    $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $3, desc), global)
    unset %weapon.to.gain | unset %user.weapon.level
    return
  }

  if (%special.type = GainSong) { 
    set %song.to.gain  $readini($dbfile(items.db), $3, Song)

    ; Check to see if the user already has this song
    set %user.song.level $readini($char($2), songs, %song.to.gain)
    if (%user.song.level != $null) {  unset %user.song.level | $set_chr_name($2) | $display.message($readini(translation.dat, errors, AlreadyLearnedThisSong), private) | unset %song.to.gain | halt }

    writeini $char($2) songs %song.to.gain 1

    $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $3, desc), global)
    unset %song.to.gain | unset %user.song.level
    return
  }

}

alias item.tormentreward {
  ; $1 = user
  ; $2 = target
  ; $3 = item used
  ; $4 = the amount we're opening

  var %reward.list items_tormentreward.lst

  var %items.lines $lines($lstfile(%reward.list))
  if (%items.lines = $null) { $display.message(4ERROR: items_tormentrewad.lst is missing or empty!, private) | halt }


  if ($4 = 1) { 
    var %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    var %random.item.contents $read -l $+ %random $lstfile(%reward.list)
    var %random.item.name %random.item.contents
    var %random.item.amount $readini($dbfile(items.db), $3, ItemsInside)
    if (%random.item.amount = $null) { var %random.item.amount $rand(1,10) }

    var %current.reward.items $readini($char($1), item_amount, %random.item.name)
    if (%current.reward.items = $null) { set %current.reward.items 0 }
    inc %current.reward.items %random.item.amount
    writeini $char($1) item_amount %random.item.contents %current.reward.items
    unset %current.reward.items

    ; Display the desc of the item
    $set_chr_name($2) | var %enemy %real.name | $set_chr_name($1) 
    $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $3, desc), global) 
  }

  else {
    var %lifeshards.count 0
    var %reusableparts.count 0
    var %forgottensouls.count 0
    var %arcanedust.count 0

    var %opening.current.item 1
    while (%opening.current.item <= $4) { 

      var %random $rand(1, %items.lines)
      if (%random = $null) { var %random 1 }
      var %random.item.contents $read -l $+ %random $lstfile(%reward.list)
      var %random.item.name %random.item.contents
      var %random.item.amount $readini($dbfile(items.db), $3, ItemsInside)
      if (%random.item.amount = $null) { var %random.item.amount $rand(1,10) }

      var %current.reward.items $readini($char($1), item_amount, %random.item.name)
      if (%current.reward.items = $null) { set %current.reward.items 0 }
      inc %current.reward.items %random.item.amount
      writeini $char($1) item_amount %random.item.contents %current.reward.items
      unset %current.reward.items

      if (%random.item.name = lifeshard) { inc %lifeshards.count %random.item.amount }
      if (%random.item.name = ReusablePart) { inc %reusableparts.count %random.item.amount }
      if (%random.item.name = ForgottenSoul) { inc %forgottensouls.count %random.item.amount }
      if (%random.item.name = ArcaneDust) { inc %arcanedust.count %random.item.amount }

      inc %opening.current.item 1
    }

    set %real.name $1

    ; The display message is temporary and will be fixed later
    $display.message(3 $+ %real.name  $+ has obtained: %lifeshards.count lifeshards $+ $chr(44)  $+ %reusableparts.count resuable parts $+ $chr(44)  $+ %forgottensouls.count forgotten souls $+ $chr(44) and %arcanedust.count arcane dust  , global) 
  }


}

alias item.random {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  if (($readini($dbfile(items.db), $3, exclusive) = yes) && ($2 != $1)) { $display.message($readini(translation.dat, errors, CannotUseRandomItemOnOthers), private) | halt }


  ; This type of item will pick a list at random and then pick a random item from inside that list.

  var %present.list $readini($dbfile(items.db), $3, ItemList)
  if (%present.list = $null) { 
    var %random.list $rand(1,11)
    if (%random.list = 1) { set %present.list items_accessories.lst }
    if (%random.list = 2) { set %present.list items_battle.lst }
    if (%random.list = 3) { set %present.list items_consumable.lst }
    if (%random.list = 4) { set %present.list items_food.lst }
    if (%random.list = 5) { set %present.list items_gems.lst }
    if (%random.list = 6) { set %present.list items_healing.lst }
    if (%random.list = 7) { set %present.list items_misc.lst }
    if (%random.list = 8) { set %present.list items_portal.lst }
    if (%random.list = 9) { set %present.list items_reset.lst }
    if (%random.list = 10) { set %present.list items_summons.lst }
    if (%random.list = 11) { set %random.item.contents blackorb }
  }

  if (%random.item.contents = blackorb) { 
    set %random.item.name Black Orb
    var %current.orbs $readini($char($2), stuff, BlackOrbs)
    inc %current.orbs %chest.amount
    writeini $char($2) stuff BlackOrbs %current.orbs
  }

  else {
    var %items.lines $lines($lstfile(%present.list))
    if (%items.lines = $null) { $display.message(4ERROR: %present.list is missing or empty!, private) | halt }

    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(%present.list)
    set %random.item.name %random.item.contents
    set %current.reward.items $readini($char($1), item_amount, %random.item.name)
    if (%current.reward.items = $null) { set %current.reward.items 0 }
    inc %current.reward.items %chest.amount
    writeini $char($1) item_amount %random.item.contents %current.reward.items
    unset %current.reward.items
  }

  ; Display the desc of the item
  $set_chr_name($2) | var %enemy %real.name | $set_chr_name($1) 
  $display.message(3 $+ %real.name  $+ $readini($dbfile(items.db), $3, desc), global) 

  unset %total.summon.items | unset %random | unset %random.item.contents | unset %present.list
  unset %random.item.name | unset %enemy 
  return

}

alias item.damage {
  ; $1 = user
  ; $2 = target
  ; $3 = item used
  unset %shield.block.line


  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  $calculate_damage_items($1, $3, $2)
  set %style.attack.damage %attack.damage
  $deal_damage($1, $2, $3)
  $display_damage($1, $2, item, $3)

  return
}


alias item.snatch {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  var %cover.status $readini($char($2), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { $display.message($readini(translation.dat, skill, SnatchTargetDead), private) | halt }

  var %user.flag $readini($char($1), info, flag) 
  if (%user.flag = $null) { var %user.flag player }
  var %target.flag $readini($char($2), info, flag)

  if (%user.flag = player) && (%target.flag != monster) { 
    if (%mode.pvp != on) { $display.message($readini(translation.dat, errors, CannotSnatchPlayers), private) | halt }
  }

  if ($isfile($boss($2)) = $true) { $display.message($readini(translation.dat, errors, CannotSnatchBosses), private) | halt }

  $set_chr_name($2) | var %enemy %real.name

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; Display the item's description
  $set_chr_name($1) | $display.message(10 $+ %real.name  $+ $readini($dbfile(items.db), $3, desc), battle)

  ; Try to grab the target
  $do.snatch($1 , $2) 

  return
}

alias item.status {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  unset %statusmessage.display
  set %status.type.list $readini($dbfile(items.db), $3, StatusType) 

  if (%status.type.list != $null) { 
    set %number.of.statuseffects $numtok(%status.type.list, 46) 

    if (%number.of.statuseffects = 1) { $inflict_status($1, $2, %status.type.list) | unset %number.of.statuseffects | unset %status.type.list }
    if (%number.of.statuseffects > 1) {
      var %status.value 1
      while (%status.value <= %number.of.statuseffects) { 
        set %current.status.effect $gettok(%status.type.list, %status.value, 46)
        $inflict_status($1, $2, %current.status.effect)
        inc %status.value 1
      }  
      unset %number.of.statuseffects | unset %current.status.effect
    }
  }
  unset %status.type.list
  if ($readini($dbfile(items.db), $2, amount) != 0) {
    $calculate_damage_items($1, $3, $2)
    set %style.attack.damage %attack.damage
    $deal_damage($1, $2, $3)
  }
  $display_Statusdamage_item($1, $2, item, $3) 
  return
}

alias display_Statusdamage_item {
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name


  ; Show the damage
  $calculate.stylepoints($1)
  if ($3 != fullbring) {
    $display.message(3 $+ %user $+  $readini($dbfile(items.db), $4, desc), battle)
  }

  if ($readini($dbfile(items.db), $2, amount) != 0) {
    if (%guard.message = $null) { $display.message(The attack did4 $bytes(%attack.damage,b) damage %style.rating, battle) }
    if (%guard.message != $null) { $display.message(%guard.message, battle) | unset %guard.message }

    ; Did the person die?  If so, show the death message.
    if ($readini($char($2), battle, HP) <= 0) { 
      writeini $char($2) battle status dead 
      writeini $char($2) battle hp 0
      $check.clone.death($2)
      $increase_death_tally($2)
      $achievement_check($2, SirDiesALot)
      $display.message($readini(translation.dat, battle, EnemyDefeated), battle)
      $increase.death.tally($2) 
      $goldorb_check($2) 
      $spawn_after_death($2)
      if ($readini($char($1), info, flag) != monster) {
        if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster) }
        if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss) }
      }
    }
  }
  ; If the person isn't dead, display the status message.
  if ($readini($char($2), battle, hp) >= 1) {  $display.message(%statusmessage.display, battle) }

  ; If the target is flying and the status was heavy, send the target back to the ground
  if (($readini($char($2), status, flying) = yes) && ($readini($char($2), status, heavy) = yes)) { 
    writeini $char($2) status flying no 
    if ($readini($char($2), info, flag) != $null) { remini $char($2) skills flying }
    $set_chr_name($2)
    $display.message($readini(translation.dat, Status, FlyingCrash), battle)
  }



  unset %statusmessage.display

  return 
}

alias item.tp {
  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; calculate amount
  var %tp.amount $readini($dbfile(items.db), $3, amount)

  ; add TP to the target
  var %tp.current $readini($char($2), battle, tp) 
  inc %tp.current %tp.amount 

  if (%tp.current >= $readini($char($2), basestats, tp)) { writeini $char($2) battle tp $readini($char($2), basestats, tp) }
  else { writeini $char($2) battle tp %tp.current }

  $display.message(3 $+ %enemy has regained %tp.amount TP!, battle)
  return 
}

alias item.ig {
  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; calculate amount
  var %ig.amount $readini($dbfile(items.db), $3, amount)

  ; add IG to the target
  var %ig.current $readini($char($2), battle, IgnitionGauge) 
  inc %ig.current %ig.amount 

  if (%ig.current >= $readini($char($2), basestats, IgnitionGauge)) { writeini $char($2) battle IgnitionGauge $readini($char($2), basestats, IgnitionGauge) }
  else { writeini $char($2) battle IgnitionGauge %ig.current }

  $display.message(3 $+ %enemy has regained %ig.amount Ignition Gauge!, battle)
  return 
}

alias item.heal {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  var %item.current.hp $readini($char($2), battle, HP) |   var %item.max.hp $readini($char($2), basestats, HP)
  if ($readini($char($2), info, flag) != monster) {
    if ($person_in_mech($2) = true) { $display.message($readini(translation.dat, errors, ItemNotWorkOnMech), private) | halt }
    if (%item.current.hp >= %item.max.hp) { $set_chr_name($2) | $display.message($readini(translation.dat, errors, DoesNotNeedHealing), private) | halt }
  }

  $calculate_heal_items($1, $3, $2)

  ;If the target is a zombie, do damage instead of healing it.
  if (($readini($char($2), status, zombie) = yes) || ($readini($char($2), monster, type) = undead)) { 
    set %style.attack.damage %attack.damage
    $deal_damage($1, $2, $3)
    $display_damage($1, $2, item, $3)
  } 

  else {   
    $heal_damage($1, $2, $3)
    $display_heal($1, $2, item, $3)
  }

  return
}

alias item.autorevive {
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { $display.message($readini(translation.dat, errors, ItemNotWorkOnMech), private) | halt }

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  writeini $char($2) status revive yes 
  return 
}

alias item.curestatus {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  if ($person_in_mech($2) = true) { $display.message($readini(translation.dat, errors, ItemNotWorkOnMech), private) | halt }

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  $clear_most_status($2)

  $set_chr_name($2) | $display.message($readini(translation.dat, status, MostStatusesCleared), battle)
  return
}


alias item.shopreset {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  var %shop.reset.amount $readini($dbfile(items.db), $3, amount)
  var %player.shop.level $return.shoplevel($2)

  ; This will be turned on in the next version
  if ($return.shoplevel($2) = $return.minshoplevel($2)) { $display.private.message($readini(translation.dat, errors, ShopLevelCannotGoLower)) | halt }

  if (%shop.reset.amount != $null) {
    dec %player.shop.level %shop.reset.amount
    if (%player.shop.level <= 1) { writeini $char($2) stuff shoplevel 1.0 }
    if (%player.shop.level > 1) { writeini $char($2) stuff shoplevel %player.shop.level }
  }

  if (%user = %enemy) { set %enemy $gender2($1) $+ self }

  $set_chr_name($1)

  var %showdiscountmessage $readini(system.dat, system,ShowDiscountMessage)
  if (%showdiscountmessage  = $null) { var %showdiscountmessage false }

  if (%showdiscountmessage = true) {
    if (%battleis != on) { $display.message(3 $+ %real.name $+  $readini($dbfile(items.db), $3, desc), battle) }
    if (%battleis = on) { $display.private.message(3 $+ %real.name $+  $readini($dbfile(items.db), $3, desc)) }
  }

  $display.private.message($readini(translation.dat, system,ShopLevelLowered))

  var %discounts.used $readini($char($2), stuff, DiscountsUsed)
  inc %discounts.used 1 
  writeini $char($2) stuff DiscountsUsed %discounts.used

  $achievement_check($1, Cheapskate)

  unset %player.shop.level |  unset %enemy
  return
}

alias item.food {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  if (($return.systemsetting(EnableFoodOnOthers) = false) && ($2 != $1)) {
    if  ($readini($char($2), info, flag) = $null) { $display.message($readini(translation.dat, errors, Can'tUseFoodOnOthers),private) | halt }
  }

  set %food.type $readini($dbfile(items.db), $3, target)
  set %food.bonus $readini($dbfile(items.db), $3, amount)
  var %food.basestats str.def.int.spd.hp.tp

  if ($istok(%food.basestats,%food.type,46) = $true) { 
    ; Increase the base stat..

    if (%food.bonus <= 0) { 
      if ($2 != $1) {  $display.private.message(4This item cannot be used on other players. Only on monsters or yourself.) | halt }
    }

    if ($readini($char($2), info, flag) != $null)  {  set %target.stat $readini($char($2), battle, %food.type)  }
    else { set %target.stat $readini($char($2), basestats, %food.type) }

    if (%food.type = hp) {
      var %player.current.hp $readini($char($2), basestats, hp)
      var %player.max.hp $readini(system.dat, system, maxHP)
      dec %player.max.hp $armor.stat($1, hp)
      if (%player.current.hp >= %player.max.hp) { $display.message($readini(translation.dat, errors, MaxHPAllowedOthers), private) | halt }
    }

    if (%food.type = tp) {
      var %player.current.tp $readini($char($2), basestats, tp)
      var %player.max.tp $readini(system.dat, system, maxTP)
      dec %player.max.tp $armor.stat($1, tp)
      if (%player.current.tp >= %player.max.tp) { $display.message($readini(translation.dat, errors, MaxTPAllowedOthers), private)  | halt }
    }

    inc %target.stat %food.bonus

    if (%target.stat < 5) { var %target.stat 5 }

    if ($readini($char($2), info, flag) = $null)  { writeini $char($2) basestats %food.type %target.stat }
    if ($readini($char($2), info, flag) != $null)  { writeini $char($2) battle %food.type %target.stat }

    set %target.stat $readini($char($2), battle, %food.type)
    inc %target.stat %food.bonus
    writeini $char($2) battle %food.type %target.stat 

  }

  if (%food.type = style) { 
    $add.playerstyle.xp($2, %food.bonus)
  }

  if (%food.type = redorbs) {
    var %current.redorbs $readini($char($2), stuff, redorbs)
    inc %current.redorbs %food.bonus
    writeini $char($2) stuff redorbs %current.redorbs
    var %food.type Red Orbs
  }

  if (%food.type = killcoins) {
    var %current.coins $return.killcoin.count($2) 
    inc %current.coins %food.bonus
    writeini $char($2) stuff killcoins %current.coins
    var %food.type Kill Coins
  }

  if (%food.type = blackorbs) {
    var %current.orbs $readini($char($2), stuff, BlackOrbs)
    inc %current.orbs %food.bonus
    writeini $char($2) stuff BlackOrbs %current.orbs
    var %food.type Black Orb(s)
  }

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }
  $set_chr_name($1) 
  if (%battleis = on) { 
    if ($readini($char($2), info, flag) = $null)  { $display.private.message(3 $+ %real.name $+  $readini($dbfile(items.db), $3, desc)) }
    if ($readini($char($2), info, flag) != $null) { $display.message(3 $+ %real.name $+  $readini($dbfile(items.db), $3, desc), global) }
  }
  if (%battleis = off) { $display.message(3 $+ %real.name $+  $readini($dbfile(items.db), $3, desc), global) }

  if ($readini($char($2), info, flag) = $null) { 
    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {   $display.private.message2($2, $readini(translation.dat, system,FoodStatIncrease)) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($2, $readini(translation.dat, system,FoodStatIncrease)) }
  }
  unset %food.bonus | unset %target.stat | unset %food.type
  return
}

;=========================================
; Equip an accessory via the !wear command.
;=========================================
ON 50:TEXT:*wears *:*:{ 
  $checkchar($1)
  if ($3 = $null) { halt }
  if ($3 = accessory) {
    if ($3 isnum) { $wear.accessory($1, $5, $4) }
    else {  $wear.accessory($1, $4, 1) }
  }
  if ($3 = armor) { $wear.armor($1, $4) }
}
ON 50:TEXT:*removes *:*:{ 
  $checkchar($1)
  if ($3 = $null) { halt }
  if ($3 = accessory) { 
    if ($3 isnum) {  $remove.accessory($nick, $5, $4) }
    else {  $remove.accessory($nick, $4, 1) }
  }
  if ($3 = armor) { $remove.armor($1, $4) }
}

on 3:TEXT:!wear*:*: {  
  if ($3 = $null) { $display.private.message(4Error: !wear <accessory/armor> <what to wear>, private) | halt }
  if ($2 = accessory) { 
    if ($3 isnum) { $wear.accessory($nick, $4, $3) }
    else {  $wear.accessory($nick, $3, 1) }
  }
  if ($2 = armor) { $wear.armor($nick, $3) }
}
on 3:TEXT:!remove*:*: {  
  if ($3 = $null) { $display.private.message(4Error: !remove <accessory/armor> <what to remove>, private) | halt }
  if ($2 = accessory) { 
    if ($3 isnum) {  $remove.accessory($nick, $4, $3) }
    else {  $remove.accessory($nick, $3, 1) }
  }
  if ($2 = armor) { $remove.armor($nick, $3) }
}

alias wear.accessory {
  ; $1 = person equipping
  ; $2 = the accessory
  ; $3 = the accessory slot (1 by default)

  $set_chr_name($1)
  var %item.type $readini($dbfile(items.db), $2, type)
  if (%item.type != accessory) { $display.message($readini(translation.dat, errors, ItemIsNotAccessory), private) | halt }
  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
  if ((%battleis = on) && ($nick isin $readini($txtfile(battle2.txt), Battle, List))) { $display.message($readini(translation.dat, errors, CanOnlySwitchAccessoriesOutsideBattle), private) | halt }

  if ($3 = 1) { 
    var %current.accessory.type $readini($dbfile(items.db), $2, accessoryType)
    var %accessory2.type  $readini($dbfile(items.db), $readini($char($1), equipment, accessory2), accessoryType)
    if (%current.accessory.type = %accessory2.type) {  $display.message($readini(translation.dat, errors, Can'tWearSecondOfSameAccessoryType), private) | halt }

    writeini $char($1) equipment accessory $2
    $display.message($readini(translation.dat, system, EquippedAccessory), global)
  }

  if ($3 != 1) {
    var %equipment.slot $readini($char($1), enhancements, accessory2)
    if (%equipment.slot != true) { $display.message($readini(translation.dat, errors, NoSecondAccessorySlot), global) }
    if (%equipment.slot = true) {
      var %current.accessory.type $readini($dbfile(items.db), $2, accessoryType)
      var %accessory2.type  $readini($dbfile(items.db), $readini($char($1), equipment, accessory), accessoryType)

      if (%current.accessory.type = %accessory2.type) {  $display.message($readini(translation.dat, errors, Can'tWearSecondOfSameAccessoryType), private) | halt }

      writeini $char($1) equipment accessory2 $2
      $display.message($readini(translation.dat, system, EquippedAccessory2), global)
    }
  }
}
alias remove.accessory {
  ; $1 = person removing
  ; $2 = the accessory
  ; $3 = the accessory slot (1 by default)

  $set_chr_name($1)

  if ($3 = 1) {  var %equipped.accessory $readini($char($1), equipment, accessory) }
  else { var %equipped.accessory $readini($char($1), equipment, accessory2) }

  if ($2 != %equipped.accessory) { $display.message($readini(translation.dat, system, NotWearingThatAccessory), private)  | halt }
  if ((%battleis = on) && ($nick isin $readini($txtfile(battle2.txt), Battle, List))) { $display.message($readini(translation.dat, errors, CanOnlySwitchAccessoriesOutsideBattle), private) | halt }
  else { 
    if ($3 = 1 ) { writeini $char($1) equipment accessory nothing
      $display.message($readini(translation.dat, system, RemovedAccessory), global)
    }
    else { writeini $char($1) equipment accessory2 nothing 
      $display.message($readini(translation.dat, system, RemovedAccessory2), global)
    }
  } 
}

alias wear.armor {
  $set_chr_name($1)
  var %item.location $readini($dbfile(equipment.db), $2, EquipLocation)
  if (%item.location = $null) { $display.message($readini(translation.dat, errors, ItemIsNotArmor), private) | halt }
  if ((%battleis = on) && ($1 isin $readini($txtfile(battle2.txt), Battle, List))) { $display.message($readini(translation.dat, errors, CanOnlySwitchArmorOutsideBattle), private) | halt }

  set %current.armor $readini($char($1), equipment, %item.location) 

  if (((%current.armor != $null) && (%current.armor != nothing) && (%current.armor != none))) { $remove.armor($1, %current.armor, ignore) }

  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }

  var %armor.level.requirement $readini($dbfile(equipment.db), $2, LevelRequirement)
  if (%armor.level.requirement = $null) { var %armor.level.requirement 0 }
  if ($round($get.level($1),0) <= %armor.level.requirement) { $display.message($readini(translation.dat, errors, ArmorLevelHigher), private) | halt }

  ; Increase the stats
  var %hp $round($calc($readini($char($1), Basestats, hp) + $readini($dbfile(equipment.db), $2, hp)),0)
  var %tp $round($calc($readini($char($1), Basestats, tp) + $readini($dbfile(equipment.db), $2, tp)),0)

  writeini $char($1) Basestats Hp %hp
  writeini $char($1) Basestats Tp %tp

  $fulls($1, yes)

  ; Equip the armor and tell the world
  writeini $char($1) equipment %item.location $2

  if ($3 != ignore) {  $display.message($readini(translation.dat, system, EquippedArmor), global) }

  unset %current.armor
}

alias remove.armor {
  ; $1 = the person
  ; $2 = the armor name
  ; $3 = ignore if you don't want the message to be shown

  $set_chr_name($1)
  set %item.location $readini($dbfile(equipment.db), $2, EquipLocation)
  set %worn.item $readini($char($1), equipment, %item.location)
  if (%worn.item != $2) {  unset %item.location | unset %worn.item | $display.message($readini(translation.dat, system, NotWearingThatArmor), private) | halt }
  if ((%battleis = on) && ($nick isin $readini($txtfile(battle2.txt), Battle, List))) { $display.message($readini(translation.dat, errors, CanOnlySwitchArmorOutsideBattle), private) | halt }

  ; Decrease the stats
  var %hp $round($calc($readini($char($1), Basestats, hp) - $readini($dbfile(equipment.db), $2, hp)),0)
  var %tp $round($calc($readini($char($1), Basestats, tp) - $readini($dbfile(equipment.db), $2, tp)),0)

  writeini $char($1) Basestats Hp %hp
  writeini $char($1) Basestats Tp %tp

  $fulls($1, yes)

  ; Clear the armor and tell the world
  writeini $char($1) equipment %item.location nothing

  if ($3 != ignore) { $display.message($readini(translation.dat, system, RemovedArmor), global) }

  unset %item.location | unset %worn.item
}

; ==================================================
; Gearset commands
; !gearset set/equip #
; ==================================================
on 3:TEXT:!gearset*:*: {  
  if (($3 !isnum) || (. isin $3)) { $display.message($readini(translation.dat, errors, GearsetError), private) |  halt }
  if (($3 > 3) || ($3 <= 0)) { $display.message($readini(translation.dat, errors, GearsetError), private) |  halt }
  if ($2 = set) { $gearset.set($nick, $3) }
  if (($2 = equip) || ($2 = wear)) { $gearset.equip($nick, $3) }
  if ($2 = view) { $gearset.view($nick, $3) }
}

alias gearset.view { 
  ; $1 = the person
  ; $2 = the gearset number

  ; Check to see if the gearset number exists
  if ($readini($char($1), Gearset $+ $2, body) = $null) { $display.private.message2($1,$readini(translation.dat, errors, GearsetNumberDoesNotExist)) | halt }

  var %head.armor $readini($char($1), Gearset $+ $2, head)
  var %body.armor $readini($char($1), Gearset $+ $2, body)
  var %legs.armor $readini($char($1), Gearset $+ $2, legs)
  var %feet.armor $readini($char($1), Gearset $+ $2, feet)
  var %hands.armor $readini($char($1), Gearset $+ $2, hands)
  var %accessory1 $readini($char($1), Gearset $+ $2, accessory)
  var %accessory2 $readini($char($1), Gearset $+ $2, accessory2)

  if (%head.armor = $null) { var %head.armor nothing }
  if (%body.armor = $null) { var %body.armor nothing }
  if (%legs.armor = $null) { var %legs.armor nothing }
  if (%feet.armor = $null) { var %feet.armor nothing }
  if (%hands.armor = $null) { var %hands.armor nothing }
  if (%accessory1 = $null) { var %accessory1 nothing }

  ; Display the message
  $display.private.message2($1, $readini(translation.dat, system, GearsetView))
}

alias gearset.set {
  ; $1 = the person we're setting a gearset for
  ; $2 = the gearset number

  ; copy the INI of the current [equipment] section to a gearset (1to 3)
  $copyini($1, equipment, gearset $+ $2)

  ; Display a successful message that it's been copied.
  $display.private.message2($1, $readini(translation.dat, system, GearsetSuccessful))
}

alias gearset.equip {
  ; $1 = the person
  ; $2 = the gearset number

  ; If battle is on, we can't change our armor
  if ((%battleis = on) && ($1 isin $readini($txtfile(battle2.txt), Battle, List))) { $display.message($readini(translation.dat, errors, CanOnlySwitchArmorOutsideBattle), private) | halt }

  ; Check to see if the gearset number exists
  if ($readini($char($1), Gearset $+ $2, body) = $null) { $display.private.message2($1, $readini(translation.dat, errors, GearsetNumberDoesNotExist)) | halt }

  ; Silently unequip all armor that is currently equipped (to reduce TP and HP properly)

  var %head.armor $readini($char($1), equipment, head)
  var %body.armor $readini($char($1), equipment, body)
  var %legs.armor $readini($char($1), equipment, legs)
  var %feet.armor $readini($char($1), equipment, feet)
  var %hands.armor $readini($char($1), equipment, hands)

  if ((%head.armor != nothing) && (%head.armor != $null)) { $remove.armor($1, %head.armor, ignore) }
  if ((%body.armor != nothing) && (%body.armor != $null)) { $remove.armor($1, %body.armor, ignore) }
  if ((%legs.armor != nothing) && (%legs.armor != $null)) { $remove.armor($1, %legs.armor, ignore) }
  if ((%feet.armor != nothing) && (%feet.armor != $null)) { $remove.armor($1, %feet.armor, ignore) }
  if ((%hands.armor != nothing) && (%hands.armor != $null)) { $remove.armor($1, %hands.armor, ignore) }

  ; Check each armor piece to make sure the person still owns it. 
  ; If the armor is not found, set it to "nothing"
  var %armor.not.found false

  ; Set the variables for the armor we're swapping into
  var %head.armor $readini($char($1), gearset $+ $2, head)
  var %body.armor $readini($char($1), gearset $+ $2, body)
  var %legs.armor $readini($char($1), gearset $+ $2, legs)
  var %feet.armor $readini($char($1), gearset $+ $2, feet)
  var %hands.armor $readini($char($1), gearset $+ $2, hands)
  var %accessory1 $readini($char($1), gearset $+ $2, accessory)
  var %accessory2 $readini($char($1), gearset $+ $2, accessory2)

  if ((%head.armor != nothing) && (%head.armor != $null)) { 
    if ($item.amount($1, %head.armor) <= 0) { var %armor.not.found true | writeini $char($1) equipment head nothing }
  }
  if ((%body.armor != nothing) && (%body.armor != $null)) { 
    if ($item.amount($1, %body.armor) <= 0) { var %armor.not.found true | writeini $char($1) equipment body nothing }
  } 
  if ((%legs.armor != nothing) && (%legs.armor != $null)) { 
    if ($item.amount($1, %legs.armor) <= 0) { var %armor.not.found true | writeini $char($1) equipment legs nothing }
  }
  if ((%feet.armor != nothing) && (%feet.armor != $null)) { 
    if ($item.amount($1, %feet.armor) <= 0) { var %armor.not.found true | writeini $char($1) equipment feet nothing }
  }
  if ((%hands.armor != nothing) && (%hands.armor != $null)) { 
    if ($item.amount($1, %hands.armor) <= 0) { var %armor.not.found true | writeini $char($1) equipment hands nothing }
  }
  if ((%accessory1 != nothing) && (%accessory1 != $null)) { 
    if ($item.amount($1, %accessory1) <= 0) { var %armor.not.found true | writeini $char($1) equipment accessory nothing }
  }
  if ((%accessory2 != nothing) && (%accessory2 != $null)) { 
    if ($item.amount($1, %accessory2) <= 0) { var %armor.not.found true | writeini $char($1) equipment accessory2 nothing }
  }

  ; Silently equip armor (to increase TP/HP properly)
  if ((%head.armor != nothing) && (%head.armor != $null)) { $wear.armor($1, %head.armor, ignore) }
  if ((%body.armor != nothing) && (%body.armor != $null)) { $wear.armor($1, %body.armor, ignore) }
  if ((%legs.armor != nothing) && (%legs.armor != $null)) { $wear.armor($1, %legs.armor, ignore) }
  if ((%feet.armor != nothing) && (%feet.armor != $null)) { $wear.armor($1, %feet.armor, ignore) }
  if ((%hands.armor != nothing) && (%hands.armor != $null)) { $wear.armor($1, %hands.armor, ignore) }

  ; Display message.  If armor was changed display a different message
  if (%armor.not.found = true) { $display.private.message2($1, $readini(translation.dat, system, GearsetEquippedWithMissing)) }
  else {  $display.private.message2($1, $readini(translation.dat, system, GearsetEquipped)) }
}

; ==================================================
; The next two aliases are used to convert the old armor style
; to the new armor style. In order to do that, all armor had to be
; removed.
; ==================================================
alias remove.armor.all {
  ; $1 = person

  var %file $nopath($1-) 
  var %name $remove(%file,.char)

  if (%name = new_chr) { return }

  var %armor.head $return.equipped(%name, head)
  var %armor.body $return.equipped(%name, body)
  var %armor.legs $return.equipped(%name, legs)
  var %armor.hands $return.equipped(%name, hands)
  var %armor.feet $return.equipped(%name, feet)

  if ((%armor.head != none) && (%armor.head != nothing)) { $remove.armor.oldstyle(%name, %armor.head) }
  if ((%armor.body != none) && (%armor.body != nothing)) { $remove.armor.oldstyle(%name, %armor.body) }
  if ((%armor.legs != none) && (%armor.legs != nothing)) { $remove.armor.oldstyle(%name, %armor.legs) }
  if ((%armor.hands != none) && (%armor.hands != nothing)) { $remove.armor.oldstyle(%name, %armor.hands) }
  if ((%armor.feet != none) && (%armor.feet != nothing)) { $remove.armor.oldstyle(%name, %armor.feet) }
}

alias remove.armor.oldstyle {
  $set_chr_name($1)
  set %item.location $readini($dbfile(equipment.db), $2, EquipLocation)
  if (%item.location = $null) { return }

  ; Decrease the stats
  var %armor.hp $round($calc($readini($char($1), Basestats, hp) - $readini($dbfile(equipment.db), $2, hp)),0)
  var %armor.tp $round($calc($readini($char($1), Basestats, tp) - $readini($dbfile(equipment.db), $2, tp)),0)
  var %armor.str $round($calc($readini($char($1), Basestats, Str)  - $readini($dbfile(equipment.db), $2, str)),0)
  var %armor.def $round($calc($readini($char($1), Basestats, def)  - $readini($dbfile(equipment.db), $2, def)),0)
  var %armor.int $round($calc($readini($char($1), Basestats, int) - $readini($dbfile(equipment.db), $2, int)),0)
  var %armor.spd $round($calc($readini($char($1), Basestats, spd) - $readini($dbfile(equipment.db), $2, spd)),0)

  writeini $char($1) Basestats Hp %armor.hp
  writeini $char($1) Basestats Tp %armor.tp
  writeini $char($1) Basestats Str %armor.str
  writeini $char($1) Basestats Def %armor.def
  writeini $char($1) Basestats Int %armor.int
  writeini $char($1) Basestats Spd %armor.spd

  $fulls($1, yes)

  ; Clear the armor 
  writeini $char($1) equipment %item.location nothing
  unset %item.location | unset %worn.item
}

;=========================================
; Portal item aliases
;=========================================
alias portal.item.onemonster {

  var %isboss $isfile($boss(%monster.to.spawn))
  var %ismonster $isfile($mon(%monster.to.spawn))

  if ((%isboss != $true) && (%ismonster != $true)) { 
  $display.message($readini(translation.dat, errors, PortalItemNotWorking) , private) | halt  }  

  ; Clear the battlefield.
  set %battle.type boss
  $multiple_wave_clearmonsters

  ; Now summon the special boss

  if ($isfile($boss(%monster.to.spawn)) = $true) {  .copy -o $boss(%monster.to.spawn) $char(%monster.to.spawn)  }
  if ($isfile($mon(%monster.to.spawn)) = $true) {  .copy -o $mon(%monster.to.spawn) $char(%monster.to.spawn)  }

  ; increase the total # of monsters
  set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%monster.to.spawn,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
  write $txtfile(battle.txt) %monster.to.spawn
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters

  ; write the portal level
  var %boss.level $readini($char(%monster.to.spawn), info, bosslevel)
  var %current.portal.level $readini($txtfile(battle2.txt), battleinfo, portallevel)
  if (%current.portal.level = $null) { var %current.portal.level %boss.level | writeini $txtfile(battle2.txt) battleinfo portalevel %boss.level }

  if (%boss.level = $null) { var %boss.level %current.portal.level }
  if (%boss.level > %current.portal.level) { var %current.portal.level %boss.level | writeini $txtfile(battle2.txt) battleinfo PortalLevel %boss.level }

  ; display the description of the spawned monster
  $set_chr_name(%monster.to.spawn) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
  $display.message(12 $+ %real.name  $+ $readini($char(%monster.to.spawn), descriptions, char), battle)
  var %bossquote $readini($char(%monster.to.spawn), descriptions, bossquote)
  if (%bossquote != $null) {   $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.to.spawn), descriptions, BossQuote) $+ ", battle) }

  ; Boost the monster
  $levelsync(%monster.to.spawn, %boss.level)
  writeini $char(%monster.to.spawn) basestats str $readini($char(%monster.to.spawn), battle, str)
  writeini $char(%monster.to.spawn) basestats def $readini($char(%monster.to.spawn), battle, def)
  writeini $char(%monster.to.spawn) basestats int $readini($char(%monster.to.spawn), battle, int)
  writeini $char(%monster.to.spawn) basestats spd $readini($char(%monster.to.spawn), battle, spd)

  $boost_monster_hp(%monster.to.spawn, portal, $get.level(%monster.to.spawn))

  $fulls(%monster.to.spawn, yes)

  set %multiple.wave.bonus yes
  set %first.round.protection yes

  ; Get the boss item.

  ; Check for a drop
  $check_drops(%monster.to.spawn)

  set %darkness.turns 21
  unset %darkness.fivemin.warn
  unset %battle.rage.darkness

  ; Initialize the action points 
  $action.points(%monster.to.spawn)

  unset %monster.to.spawn

  return
}

alias portal.item.multimonsters {
  var %value 1 | set %number.of.monsters $numtok(%monster.to.spawn,46) 
  while (%value <= %number.of.monsters) {
    unset %multiple.monster.found
    set %current.monster.to.spawn $gettok(%monster.to.spawn,%value,46)

    var %isboss $isfile($boss(%current.monster.to.spawn))
    var %ismonster $isfile($mon(%current.monster.to.spawn))

    if ((%isboss != $true) && (%ismonster != $true)) { inc %value }
    else { 
      set %found.monster true 
      if (%cleared.battlefield != true) {  set %battle.type boss | set %cleared.battlefield true | $multiple_wave_clearmonsters }

      var %current.monster.to.spawn.name %current.monster.to.spawn
      var %multiple.monster.counter 2 

      while ($isfile($char(%current.monster.to.spawn.name)) = $true) { 
        var %current.monster.to.spawn.name %current.monster.to.spawn $+ %multiple.monster.counter 
        inc %multiple.monster.counter 1 | var %multiple.monster.found true
      }
    }

    if ($isfile($boss(%current.monster.to.spawn)) = $true) { .copy -o $boss(%current.monster.to.spawn) $char(%current.monster.to.spawn.name)  }
    if ($isfile($mon(%current.monster.to.spawn)) = $true) {  .copy -o $mon(%current.monster.to.spawn) $char(%current.monster.to.spawn.name)  }

    if (%multiple.monster.found = true) {  
      var %real.name.spawn $readini($char(%current.monster.to.spawn), basestats, name) $calc(%multiple.monster.counter - 1)
      writeini $char(%current.monster.to.spawn.name) basestats name %real.name.spawn
    }

    ; increase the total # of monsters
    set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%current.monster.to.spawn.name,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
    write $txtfile(battle.txt) %current.monster.to.spawn.name
    var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters

    ; write the portal level
    var %boss.level $readini($char(%current.monster.to.spawn), info, bosslevel)
    var %current.portal.level $readini($txtfile(battle2.txt), battleinfo, portallevel)
    if (%current.portal.level = $null) { var %current.portal.level %boss.level | writeini $txtfile(battle2.txt) battleinfo portalevel %boss.level }

    if (%boss.level = $null) { var %boss.level %current.portal.level }
    if (%boss.level > %current.portal.level) { var %current.portal.level %boss.level | writeini $txtfile(battle2.txt) battleinfo PortalLevel %boss.level }

    ; display the description of the spawned monster
    $set_chr_name(%current.monster.to.spawn.name) 

    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      var %timer.delay $calc(%value - 1)

      if (%number.of.monsters > 2) { 
        dec %timer.delay 2
        if (%timer.delay <= 0) { var %timer.delay 0 }
      } 

      $display.message.delay($readini(translation.dat, battle, EnteredTheBattle), battle, %timer.delay)

      var %monster.description 12 $+ %real.name  $+ $readini($char(%current.monster.to.spawn.name), descriptions, char)
      $display.message.delay(%monster.description, battle, %timer.delay)

      var %bossquote $readini($char(%current.monster.to.spawn.name), descriptions, bossquote)
      if (%bossquote != $null) { 
        var %bossquote 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.monster.to.spawn), descriptions, BossQuote) $+ "
        $display.message.delay(%bossquote, battle, %timer.delay) 
      }


      if ($readini(system.dat, system, botType) = DCCchat) {
        $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
        $display.message(12 $+ %real.name  $+ $readini($char(%current.monster.to.spawn.name), descriptions, char), battle)
        if (%bossquote != $null) {   $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.monster.to.spawn.name), descriptions, BossQuote) $+ ", battle) }
      }

      ; Boost the monster
      $levelsync(%current.monster.to.spawn.name, %boss.level)
      writeini $char(%current.monster.to.spawn.name) basestats str $readini($char(%current.monster.to.spawn.name), battle, str)
      writeini $char(%current.monster.to.spawn.name) basestats def $readini($char(%current.monster.to.spawn.name), battle, def)
      writeini $char(%current.monster.to.spawn.name) basestats int $readini($char(%current.monster.to.spawn.name), battle, int)
      writeini $char(%current.monster.to.spawn.name) basestats spd $readini($char(%current.monster.to.spawn.name), battle, spd)

      $boost_monster_hp(%current.monster.to.spawn.name, portal, $get.level(%monster.to.spawn.name))

      $fulls(%current.monster.to.spawn.name, yes)

      set %multiple.wave.bonus yes
      set %first.round.protection yes
      set %darkness.turns 21
      unset %darkness.fivemin.warn
      unset %battle.rage.darkness

      ; Get the boss item.
      $check_drops(%current.monster.to.spawn.name)

      ; Initialize the action points 
      $action.points(%current.monster.to.spawn.name)

      inc %value
    }
  }


  if (%found.monster != true) { $display.message($readini(translation.dat, errors, PortalItemNotWorking), private)  | halt  }  

  unset %found.monster | unset %cleared.battlefield | return
}

alias portal.sync.players {
  ; $1 = level to sync to

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)

    if (%flag != monster) { 
      if ($get.level(%who.battle) >= $1) {  
        $levelsync(%who.battle, $1)
        writeini $char(%who.battle) info levelsync yes
        writeini $char(%who.battle) info NeedsFulls yes

        if ($readini($char(%who.battle), NaturalArmor, Max) != $null) {
          var %user.int $readini($char(%who.battle), battle, int)
          var %user.stoneskin.level $readini($char(%who.battle), skills, stoneskin)
          var %stoneskin.max $round($calc(%user.int * ((%user.stoneskin.level + 10) /100)),0)
          if (%stoneskin.max > 3000) { var %stoneskin.max 3000 }

          writeini $char(%who.battle) NaturalArmor Max %stoneskin.max
          writeini $char(%who.battle) NaturalArmor Current %stoneskin.max

        }
      }
    }

    if ((no-trust isin %battleconditions) || (no-trusts isin %battleconditions)) { 
      if ($readini($char(%who.battle), info, trust) = true) { 
        if ($readini($char(%who.battle), info, flag) = npc) { 
          if (($readini($char(%who.battle), info, clone) = yes) || ($readini($char(%who.battle), info, summon) = yes)) { 
            if ($readini($char(%who.battle), info, clone) = yes) { var %owner $readini($char(%who.battle), info, cloneowner) }
            if ($readini($char(%who.battle), info, clone) != yes) { var %owner  $readini($char(%who.battle), info, owner) }
            if ($readini($char(%owner), info, flag) != $null) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
          }
          if ($readini($char(%who.battle), info, clone) != yes) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
        }
      }
    }

    if ((no-summon isin %battleconditions) || (no-summons isin %battleconditions)) { 
      if ($readini($char(%who.battle), info, summon) = yes) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
    }

    if (no-playerclones isin %battleconditions) { 
      if (($readini($char(%who.battle), info, flag) = npc) && ($readini($char(%who.battle), info, clone) = yes)) { writeini $char(%who.battle) battle hp 0 | writeini $char(%who.battle) battle status dead } 
    }

    if ((no-npc isin %battleconditions) || (no-npcs isin %battleconditions)) { 

      if ($readini($char(%who.battle), info, flag) = npc) { 

        if (($readini($char(%who.battle), info, clone) = yes) || ($readini($char(%who.battle), info, summon) = yes)) { 
          if ($readini($char(%who.battle), info, clone) = yes) { var %owner $readini($char(%who.battle), info, cloneowner) }
          if ($readini($char(%who.battle), info, clone) != yes) { var %owner  $readini($char(%who.battle), info, owner) }
          if ($readini($char(%owner), info, flag) != $null) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
        }
        if ($readini($char(%who.battle), info, clone) != yes) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
      }
    }


    inc %battletxt.current.line 1
  }
}


alias portal.uncapped.battleconditionscheck {

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)

    if ((no-trust isin %battleconditions) || (no-trusts isin %battleconditions)) { 
      if ($readini($char(%who.battle), info, flag) = npc) { 
        if (($readini($char(%who.battle), info, clone) = yes) || ($readini($char(%who.battle), info, summon) = yes)) { 
          if ($readini($char(%who.battle), info, clone) = yes) { var %owner $readini($char(%who.battle), info, cloneowner) }
          if ($readini($char(%who.battle), info, clone) != yes) { var %owner  $readini($char(%who.battle), info, owner) }
          if ($readini($char(%owner), info, flag) != $null) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
        }
        if ($readini($char(%who.battle), info, clone) != yes) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
      }
    }

    if ((no-summon isin %battleconditions) || (no-summons isin %battleconditions)) { 
      if ($readini($char(%who.battle), info, summon) = yes) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
    }

    if ((no-npc isin %battleconditions) || (no-npcs isin %battleconditions)) { 

      if ($readini($char(%who.battle), info, flag) = npc) { 

        if (($readini($char(%who.battle), info, clone) = yes) || ($readini($char(%who.battle), info, summon) = yes)) { 
          if ($readini($char(%who.battle), info, clone) = yes) { var %owner $readini($char(%who.battle), info, cloneowner) }
          if ($readini($char(%who.battle), info, clone) != yes) { var %owner  $readini($char(%who.battle), info, owner) }
          if ($readini($char(%owner), info, flag) != $null) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
        }
        if ($readini($char(%who.battle), info, clone) != yes) { writeini $char(%who.battle) battle status dead | writeini $char(%who.battle) battle hp 0 }
      }
    }

    inc %battletxt.current.line 1
  }
}



alias item.torment {
  ; $1 = person using the item
  ; $2 = item used

  ; If a battle is on, we can't use the item
  if (%battleis = on) { $display.message($readini(translation.dat, errors, Can'tStartTormentInBattle), private) | halt }
  if (%battle.type = ai) { $display.message($readini(translation.dat, errors, Can'tStartTormentInBattle), private) | halt }

  ; can't do this during shenron's wish
  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { $display.message($readini(translation.dat, errors, NoTormentDuringShenron), private) | halt }

  ; can't do this while a chest exists
  if ($readini($txtfile(treasurechest.txt), ChestInfo, Color) != $null) { $display.message($readini(translation.dat, errors, Can'tDoActionWhileChest), private) | halt }

  ; Make sure the player has enough of the item to start a torment battle and then remove the item.
  var %torment.item $readini($char($1), Item_Amount, $2) 
  if ((%torment.item <= 0) || (%torment.item = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
  dec %torment.item 1
  writeini $char($1) Item_Amount $2 %torment.item

  ; Get the torment level
  set %torment.level $readini($dbfile(items.db), $2, TormentLevel)
  set %torment.creator $1 
  set %torment.wave 1
  if (%torment.level = $null) { echo -a 4ERROR: TORMENT LEVEL NULL | set %torment.level 1 }

  ; Start the torment 
  $startnormal(torment)
  halt
}


alias item.cosmic {
  ; $1 = person using the item
  ; $2 = the level of the cosmic orb the player wants
  ; $3 = the item name

  ; If a battle is on, we can't use the item
  if (%battleis = on) { $display.message($readini(translation.dat, errors, Can'tStartCosmicInBattle), private) | halt }
  if (%battle.type = ai) { $display.message($readini(translation.dat, errors, Can'tStartCosmicInBattle), private) | halt }

  ; can't do this during shenron's wish
  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { $display.message($readini(translation.dat, errors, NoCosmicDuringShenron), private) | halt }

  ; can't do this while a chest exists
  if ($readini($txtfile(treasurechest.txt), ChestInfo, Color) != $null) { $display.message($readini(translation.dat, errors, Can'tDoActionWhileChest), private) | halt }

  ; Check for a valid number  
  if ($2 !isnum 1-100) { $display.message($readini(translation.dat, errors, NeedValidNumberForCosmicLevel), private) | halt }

  ; Make sure the player has enough of the item to start a cosmic battle and then remove the item.
  var %cosmic.item $readini($char($1), Item_Amount, $3) 
  if ((%cosmic.item <= 0) || (%cosmic.item = $null)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
  dec %cosmic.item 1
  writeini $char($1) Item_Amount $3 %cosmic.item

  ; Set the cosmic level
  set %cosmic.level $2

  ; Start the cosmic battle
  $startnormal(cosmic, $1, $2)
  halt
}


alias item.dungeon {
  ; $1 = person who used the item
  ; $2 = item used
  ; $3 = "true" -- a flag to ignore chests and last start time

  ; If a battle is on, we can't use this item.
  if (%battleis = on) { $display.message($readini(translation.dat, errors, can'tstartdungeoninbattle), private) | halt }

  ; can't do this during shenron's wish
  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { $display.message($readini(translation.dat, errors, NoDungeonsDuringShenron), private) | halt }

  ; can't do this while a chest exists
  if ($3 != true) { 
    if ($readini($txtfile(treasurechest.txt), ChestInfo, Color) != $null) { $display.message($readini(translation.dat, errors, Can'tDoActionWhileChest), private) | halt }
  }

  ; Get the dungeon and make sure the dungeon exists.
  var %dungeon.file $readini($dbfile(items.db), $2, dungeon)
  var %dungeon.name $readini($dungeonfile(%dungeon.file), info, name)

  if (%dungeon.name = $null) { $display.message($readini(translation.dat, errors, NotAValidDungeon), private) | halt }

  ; Check to see if the player can start a dungeon today
  if ($3 != true) { 
    var %player.laststarttime $readini($char($1), info, LastDungeonStartTime)
    var %current.time $ctime
    var %time.difference $calc(%current.time - %player.laststarttime)

    var %dungeon.time.setting 86400 

    if ((%time.difference = $null) || (%time.difference < %dungeon.time.setting)) { 
      $display.message($readini(translation.dat, errors, CanOnlyStartOneDungeonADay), private)
      halt 
    }
  }

  writeini $txtfile(battle2.txt) DungeonInfo DungeonCreator $1
  $dungeon.start($1, $2, %dungeon.file, $3)

}
