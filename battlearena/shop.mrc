;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  SHOP COMMANDS
;;;; Last updated: 03/31/18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 3:TEXT:!shop*:*: { $shop.start($1, $2, $3, $4, $5) }
on 3:TEXT:!exchange*:*: { $shop.exchange($nick, $2, $3) }
on 3:TEXT:!sell*:*: { $shop.start(!shop, sell, $2, $3, $4, $5) }
on 3:TEXT:!voucher list:*: { $shop.voucher.list($nick) }
on 3:TEXT:!voucher buy *:*: { $shop.voucher.buy($nick, $3, $4) }

alias shop.exchange {
  ; $1 = user
  ; $2 = alliednotes/doubledollars
  ; $3 = amount you want to exchange

  if ($3 <= 0) { $display.private.message($readini(translation.dat, errors, Can'tBuy0ofThat)) | halt }
  if (($2 != alliednotes) && ($2 != doubledollars)) { $display.private.message(4The commands: !exchange alliednotes # to convert allied notes to double dollars or !exchange doubledollars # to convert double dollars to allied notes.) | halt }
  if ($3 = $null) { $display.private.message(4The commands: !exchange alliednotes # to convert allied notes to double dollars or !exchange doubledollars # to convert double dollars to allied notes.) | halt }

  var %currency.symbol $readini(system.dat, n, system, BetCurrency)
  if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }

  var %amount.to.purchase $abs($3)
  if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }

  if ($2 = alliednotes) {
    ; is the user allied notes locked due to auction?
    if ($readini($char($1), status, alliednotes.lock) = true) { $display.private.message(4You are in the middle of an auction and cannot spend or exchange any allied notes until the auction is over.) | halt }

    ; do we have enough notes?
    var %notes.needed $3
    var %notes.have $readini($char($1), stuff, alliednotes)
    if (%notes.have < %notes.needed) { $display.private.message(4Not enough allied notes to make the exchange.) | halt }
    var %dollarstogive $calc(2 * $3)
    dec %notes.have %notes.needed
    writeini $char($1) stuff alliednotes %notes.have

    var %dollars.have $readini($char($1), stuff, doubledollars)
    if (%dollars.have = $null) { var %dollars.have 100 }
    inc %dollars.have %dollarstogive
    writeini $char($1) stuff doubledollars %dollars.have
    $display.private.message($readini(translation.dat, system, ShopExchangeNotes))
  }

  if ($2 = doubledollars) {
    ; do we have enough dollars?
    var %dollars.needed $calc(2 * $3)
    var %dollars.have $readini($char($1), stuff, doubledollars)
    if (%dollars.have < %dollars.needed) { $display.private.message(4Not enough double dollars to make the exchange.) | halt }
    var %notestogive $3
    dec %dollars.have %dollars.needed
    writeini $char($1) stuff doubledollars %dollars.have
    var %notes.have $readini($char($1), stuff, alliednotes)
    if (%notes.have = $null) { var %notes.have 0 }
    inc %notes.have %notestogive
    writeini $char($1) stuff alliednotes %notes.have
    $display.private.message($readini(translation.dat, system, ShopExchangeDoubleDollars))
  }
}

alias shop.categories.list {
  $display.private.message(2Valid shop categories:)
  $display.private.message(2Items $+ $chr(44) Techs $+ $chr(44) Skills $+ $chr(44) Stats $+ $chr(44) Weapons $+ $chr(44) Styles $+ $chr(44) Ignitions $+ $chr(44) Orbs $+ $chr(44) KillCoins $+ $chr(44) Portal $+ $chr(44) Misc) 
  $display.private.message(2Mech $+ $chr(44) Mech Items $+ $chr(44) Shields $+ $chr(44) Enhancement $+ $chr(44) Trusts $+ $chr(44) PotionEffect $+ $chr(44) DungeonKeys $+ $chr(44) TradingCards $+ $chr(44) AlliedForces)
  if ($left($adate, 2) = 10) {  $display.private.message(2Halloween) }
}


alias shop.start {

  ; For now let's check to make sure the shop level isn't over 25.
  var %max.shop.level $readini(system.dat, system, maxshoplevel)
  if (%max.shop.level = $null) { var %max.shop.level 25 }

  var %shop.level $readini($char($nick), stuff, shoplevel) 
  if (%shop.level > %max.shop.level) { writeini $char($nick) stuff shoplevel %max.shop.level }

  $set_chr_name($nick) 
  unset %shop.list |  unset %shop.list2
  if ($2 = $null) { $gamehelp(Shop, $nick)  | halt  }
  if ($2 = level) { $display.private.message($readini(translation.dat, system, CurrentShopLevel)) | halt }

  if ($5 = 0) {  $display.private.message($readini(translation.dat, errors, Can'tBuy0ofThat)) | halt }


  if ($2 = sell) {
    var %sellable.stuff items.accessories.accessory.gems.tech.techs.technique.armor.weapon.weapons.special.trust.trusts
    if ($3 !isin %sellable.stuff) { $display.private.message($readini(translation.dat, errors, Can'tSellThat)) | halt }
    var %amount.to.sell $abs($5)
    if (%amount.to.sell = $null) { var %amount.to.sell 1 }
    if (($3 = item) || ($3 = items)) {
      if ($readini($dbfile(items.db), $4, type) = accessory) { $shop.accessories($nick, sell, $4, %amount.to.sell) | halt }
      else {  $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    }
    if (($3 = key) || ($3 = keys)) { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = accessories) || ($3 = accessory))  { $shop.accessories($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = gems) || ($3 = gem))  { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if ((($3 = tech) || ($3 = techs) || ($3 = technique))) { $shop.techs($nick, sell, $4, %amount.to.sell) | halt }
    if ($3 = armor)  { $shop.armor($nick, sell, $4, %amount.to.sell) | halt }
    if ($3 = weapon) { $shop.weapons($nick, sell, $4) | halt }
    if ($3 = special) { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = trustl) || ($3 = trusts)) { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
  }

  if (($2 = buy) || ($2 = purchase)) { 
    if (%battleis = on) { 
      if ($nick isin $readini($txtfile(battle2.txt), Battle, List)) {  $display.private.message($readini(translation.dat, errors, Can'tUseShopInBattle)) | halt }
    }

    if ($3 = $null) {  $display.private.message(4Error: Use !shop buy category itemname)
      $shop.categories.list 
      halt 
    }
    var %amount.to.purchase $abs($5)
    if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }

    if ($3 = halloween) { $shop.halloween($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = enhancement) || ($3 = enhancements))  { $shop.enhancements($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = items) || ($3 = item))  { $shop.items($nick, buy, $4, %amount.to.purchase) | halt }
    if ((($3 = techs) || ($3 = techniques) || ($3 = tech))) { $shop.techs($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = skills) || ($3 = skill)) { $shop.skills($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = stats) || ($3 = stat))  {  $shop.stats($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = portal) || ($3 = portalitem))  { $shop.portal($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = dungeonkey) || ($3 = dungeonkeys))  { $shop.dungeonkeys($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = alchemy) || ($3 = misc))  { $shop.alchemy($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = alliednotes) || ($3 = gems))  { $shop.alchemy($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, buy, $4, %amount.to.purchase) }
    if (($3 = shields) || ($3 = shield)) { $shop.shields($nick, buy, $4, %amount.to.purchase) }
    if (($3 = potioneffect) || ($3 = potioneffects)) { $shop.potioneffects($nick, buy, $4) | halt }
    if (($3 = tradingcard) || ($3 = tradingcards))  { $shop.tradingcards($nick, buy, $4, %amount.to.purchase) | halt }
    if ($3 = alliedforces) { $shop.alliedforces($nick, buy, $4, $5) | halt }
    if ($3 = killcoins) { 
      var %amount.to.purchase $abs($4)
      if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }
      $shop.killcoins($nick, buy, %amount.to.purchase) 
      halt 
    }

    if ($3 = orbs) { 
      var %amount.to.purchase $abs($4)
      if (%amount.to.purchase = $null) { var %amount.to.purchase 1 }
      $shop.orbs($nick, buy, %amount.to.purchase) 
    }
    if (($3 = style) || ($3 = styles))  { $shop.styles($nick, buy, $4) | halt }
    if (($3 = trusts) || ($3 = trust))  { $shop.trusts($nick, buy, $4) | halt }
    if (($3 = ignition) || ($3 = ignitions))  { $shop.ignitions($nick, buy, $4) | halt }

    if ($3 = mech) {
      if ($4 = $null) { 
        if ($readini($char($nick), mech, HpMax) != $null) { $display.private.message(4Error: You already own a mech and cannot buy another.  If you are looking for weapons and cores use !shop buy/list mech items <what to buy>) | halt }
        $shop.mech($nick, buy)  | halt
      }

      if ($5 != $null) { 
        if ($readini($char($nick), mech, HpMax) = $null) { $display.private.message(4Error: You do not own a mech and cannot buy items for one yet.  If you want to purchase a basic mech use !shop buy mech) | halt }
        $shop.mechitems($nick, buy, $5, %amount.to.purchase)
      }
    }

    else { 
      $display.private.message(4Error: Use 2!shop list category4 or 2!shop buy category itemname)
      $shop.categories.list 
      halt 
    }

  }

  if ($2 = list) { 

    var %valid.categories stats.stat.items.item.techs.techniques.skills.skill.weapons.weapon.orbs.style.styles.ignition.ignitions.portal.portals.alchemy.misc.alliednotes.gems.mech.mech items.shield.shields.enhancement.enhancements.trusts.potioneffect.potioneffects.dungeonkey.dungeonkeys.halloween.tradingcards.alliedforces.killcoins
    if ($istok(%valid.categories, $3, 46) = $false) { 
      $display.private.message(4Error: Use 2!shop list category4 or 2!shop buy category itemname)
      $shop.categories.list 
      halt 
    }

    else {
      if ($3 = halloween) { $shop.halloween($nick, list) }
      if (($3 = enhancement) || ($3 = enhancements))  { $shop.enhancements($nick, list) }
      if (($3 = stats) || ($3 = stat)) { $shop.stats($nick, list) }
      if (($3 = items) || ($3 = item)) { $shop.items($nick, list) }
      if (($3 = tradingcards) || ($3 = tradingcard)) { $shop.tradingcards($nick, list) }
      if (($3 = techs) || ($3 = techniques))  { $shop.techs($nick, list) }
      if (($3 = trusts) || ($3 = trust))  { $shop.trusts($nick, list) }
      if (($3 = potioneffect) || ($3 = potioneffects)) { $shop.potioneffects($nick, list) }
      if (($3 = skills) || ($3 = skill)) { 
        if ($4 = $null) { $shop.skills($nick, list) | halt }

        var %valid.categories passive.active.resists.resistances.killer.killertraits.null
        if ($istok(%valid.categories, $4, 46) = $false) { $display.private.message(4Error: Use !shop list skills <passive/active/resists/killer>)  | halt }

        if ($4 = passive) { $shop.skills.passive($nick) }
        if ($4 = active) { $shop.skills.active($nick) }
        if (($4 = resists) || ($4 = resistances)) { $shop.skills.resists($nick) }
        if (($4 = killer) || ($4 = killertraits)) { $shop.skills.killertraits($nick) }
      }

      if ($3 = alliedforces) { $shop.alliedforces($nick, list) }
      if ($3 = killcoins) { $shop.killcoins($nick, list) }
      if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, list) }
      if (($3 = shields) || ($3 = shield)) { $shop.shields($nick, list) }
      if ($3 = orbs) { $shop.orbs($nick, list) }
      if (($3 = style) || ($3 = styles))  { $shop.styles($nick, list, $4) | halt }
      if (($3 = ignition) || ($3 = ignitions))  { $shop.ignitions($nick, list, $4) | halt }
      if (($3 = portal) || ($3 = portals)) { $shop.portal($nick, list) }
      if (($3 = dungeonkey) || ($3 = dungeonkeys)) { $shop.dungeonkeys($nick, list) }
      if (($3 = alchemy) || ($3 = misc)) { $shop.alchemy($nick, list) }
      if (($3 = alliednotes) || ($3 = gems)) { $shop.alchemy($nick, list) }
      if (($3 = mech) && ($4 = items)) { 
        if ($readini($char($nick), mech, HpMax) = $null) { $display.private.message(4Error: You do not own a mech and cannot buy items for one yet.  If you want to purchase a basic mech use !shop buy mech or !shop list mech to check the price) | halt }
        $shop.mechitems($nick, list) | halt
      }
      if ($3 = mech) {  
        if ($readini($char($nick), mech, HpMax) != $null) { $display.private.message(4Error: You already own a mech and cannot buy another.  If you are looking for weapons and cores use !shop buy/list mech items <what to buy>) | halt }
        $shop.mech($nick, list) | halt
      }

    }

  }

  else {  
    $display.private.message(4Error: Use 2!shop list category4 or 2!shop buy category itemname)
    $shop.categories.list 
    halt 
  }
}

alias shop.accessories {
  if ($2 = sell) {
    ; is it a valid item?
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Error: Invalid accessory.) | halt }

    ; Does the player have it?
    var %player.items $item.amount($1, $3)
    if (%player.items = 0) { $display.private.message($readini(translation.dat, errors, DoNotHaveAccessoryToSell)) | halt }
    if (%player.items < $4) { $display.private.message($readini(translation.dat, errors, DoNotHaveEnoughItemToSell)) | halt }

    var %amount.to.sell $4

    var %equipped.accessory $readini($char($1), equipment, accessory)
    if (%equipped.accessory = $3) {
      dec %player.items 1  | dec %amount.to.sell 1
      if (%player.items <= 0) { $display.private.message($readini(translation.dat, errors, StillWearingAccessory)) | halt }
    }

    ; If so, decrease the amount
    writeini $char($1) item_amount $3 $calc($item.amount($1,$3) - %amount.to.sell)

    var %total.price $readini($dbfile(items.db), $3, sellPrice)

    if (%total.price = $null) { 
      var %total.price $readini($dbfile(items.db), $3, cost)
      %total.price = $round($calc(%total.price / 5),0)
    }

    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $round($calc(($readini($char($1), skills, Haggling) / 100) * %total.price),0)
    }

    if (%total.price > 50000) { %total.price = 50000 }
    if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 100  }

    %total.price = $calc(%amount.to.sell * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message($readini(translation.dat, system, SellMessageAccessory))
  }
}


alias shop.armor {
  if ($2 = sell) {
    ; is it a valid item?
    if ($readini($dbfile(equipment.db), $3, EquipLocation) = $null) { $display.private.message(4Error: Invalid armor piece.) | halt }

    ; Does the player have it?
    var %player.items $item.amount($1, $3)
    if (%player.items = 0) { $display.private.message($readini(translation.dat, errors, DoNotHaveArmorToSell)) | halt }
    if (%player.items < $4) { $display.private.message($readini(translation.dat, errors, DoNotHaveEnoughItemToSell)) | halt }

    set %armor.equip.slot $readini($dbfile(equipment.db), $3, EquipLocation)

    set %equipped.armor $readini($char($1), equipment, %armor.equip.slot)
    if (%equipped.armor = $3) {
      if (%player.items = 1) { $display.private.message($readini(translation.dat, errors, StillWearingArmor)) | halt }
    }

    unset %armor.equip.slot | unset %equipped.armor 

    ; If so, decrease the amount
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) - $4)

    var %total.price $readini($dbfile(equipment.db), $3, sellPrice)

    if (%total.price = $null) { 
      var %total.price $readini($dbfile(equipment.db), $3, cost)
      %total.price = $round($calc(%total.price / 5),0)
    }

    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $round($calc(($readini($char($1), skills, Haggling) / 100) * %total.price),0)
    }

    if (%total.price > 500000) { %total.price = 500000 }
    if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 100  }

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message($readini(translation.dat, system, SellMessage))
  }
}


alias shop.items {

  var %conquest.status $readini(battlestats.dat, conquest, ConquestPreviousWinner)

  if ($2 = list) {
    ; get the list of all the shop items..

    ; CHECKING HEALING ITEMS
    unset %shop.list |  unset %shop.list2 | var %value 1 | var %items.lines $lines($lstfile(items_healing.lst)) | var %current.healing.items.found 0

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_healing.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { 
            inc %current.healing.items.found 1
            if (%current.healing.items.found <= 14) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            else { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }

          }
          if ((%conquest.item = true) && (%conquest.status = players)) { 
            inc %current.healing.items.found 1
            if (%current.healing.items.found <= 14) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            else { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }

          }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(3Healing Items:2 %shop.list)
      if (%shop.list2 != $null) { $display.private.message(2 $+ %shop.list2) }
    }


    ; CHECKING BATTLE ITEMS
    unset %shop.list | unset %shop.list2 | var %value 1 | var %items.lines $lines($lstfile(items_battle.lst)) | var %current.battle.items.found 0


    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_battle.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)    

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { 
            inc %current.battle.items.found 1
            if (%current.battle.items.found <= 14) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            else { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          }
          if ((%conquest.item = true) && (%conquest.status = players)) { 
            inc %current.battle.items.found 1
            if (%current.battle.items.found <= 14) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            else { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }

          }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(4Battle Items:2 %shop.list)
      if (%shop.list2 != $null) { $display.private.message(2 $+ %shop.list2) }
    }


    ; CHECKING CONSUMABLE ITEMS
    unset %shop.list |  unset %shop.list2 | var %value 1 | var %items.lines $lines($lstfile(items_consumable.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_consumable.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(14Items Used For Skills:2 %shop.list)
    }


    ; CHECKING SUMMON ITEMS
    unset %shop.list |  var %value 1 | set %total.summon.items 0 | var %items.lines $lines($lstfile(items_summons.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_summons.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          inc %total.summon.items 1
          if (%total.summon.items < 20) { 
            if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          }
          else { 
            if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          }
        }
      }
      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(10Items Used For Summons:2 %shop.list)
      set %replacechar $chr(044) $chr(032)
      %shop.list2 = $replace(%shop.list2, $chr(046), %replacechar)
      unset %replacechar
      if (%shop.list2 != $null) { 2 $+ %shop.list2 }
    }
    unset %shop.list2

    ; CHECKING SHOP RESET ITEMS
    unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_reset.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_reset.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(12Items Used To Lower Shop Levels:2 %shop.list)
    }

    unset %item.price | unset %item.name | unset %shop.list

    ; CHECKING RANDOM ITEMS
    unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_random.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_random.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(12Items That Give Random Items:2 %shop.list)
    }

    unset %item.price | unset %item.name | unset %shop.list

    ; CHECKING SONGSHEETS AND SPECIAL ITEMS
    unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_special.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_special.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(6Songsheets & Special Items:2 %shop.list)
    }

    unset %item.price | unset %item.name | unset %shop.list

    ; CHECKING INSTRUMENT ITEMS
    unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_instruments.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_instruments.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ($item.amount($1, %item.name) = 0) { 

        if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
          if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
            if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          }
        }

      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(7Instruments:2 %shop.list)
    }

    unset %item.price | unset %item.name | unset %shop.list


    ; CHECKING AMMO ITEMS
    unset %shop.list |  var %value 1 | set %total.ammo.items 0 | var %items.lines $lines($lstfile(items_ammo.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_ammo.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if ((%item.price > 0) && ($readini($dbfile(items.db), %item.name, Currency) = $null)) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          inc %total.ammo.items 1
          if (%total.ammo.items < 20) { 
            if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          }
          else { 
            if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list2 = $addtok(%shop.list2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          }
        }
      }
      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(10Ammo:2 %shop.list)
      if (%shop.list2 != $null) { $display.private.message(2 $+ %shop.list2) }     
    }

    unset %item.price | unset %item.name | unset %shop.list
    unset %shop.list3 | unset %total.summon.items | unset %shop.list2 | unset %total.ammo.items

    if ($shopnpc.present.check(TravelMerchant) = true) {
      ; CHECKING ACCESSORIES
      unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_accessories.lst))

      while (%value <= %items.lines) {
        set %item.name $read -l $+ %value $lstfile(items_accessories.lst)
        set %item.price $readini($dbfile(items.db), %item.name, cost)
        set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
        set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

        if (%item.price > 0) {  
          if ($shopnpc.present.check(%shopnpc.name) = true) {
            if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
            if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          }
        }

        unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
        inc %value 1 
      }

      if (%shop.list != $null) {  $shop.cleanlist 
        $display.private.message(9Accessories:2 %shop.list)
      }

      unset %item.price | unset %item.name | unset %shop.list | unset %shop.list2
      unset %shop.list3 | unset %total.summon.items | unset %check.item
    }

  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Error: Invalid item. Use! !shop list items to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, type) = rune) { $display.private.message(4Error: Invalid item. Use! !shop list items to get a valid list) | halt }

    var %currency.type $readini($dbfile(items.db), $3, currency) 

    if ((%currency.type != none) && (%currency.type != $null)) { $display.private.message(4Error: You cannot buy this item via this command!) | halt }

    ; Check for the shop NPC and see if the npc is available
    var %shopnpc.name $readini($dbfile(items.db), $3, shopNPC)

    if ((%shopnpc.name != $null) && ($shopnpc.present.check(%shopnpc.name) != true)) {  $display.private.message($readini(translation.dat, errors, ShopNPCNotAvailable)) | halt }

    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %total.price $readini($dbfile(items.db), $3, cost)
    %total.price = $calc($4 * %total.price)
    if (%total.price = 0) {  $display.private.message(4You cannot buy this item!) | halt }

    if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough red orbs to purchase this item!) | halt }

    ; is the item only available if players are winning the conquest?
    var %conquest.item $readini($dbfile(items.db), $3, ConquestItem)
    if ((%conquest.item = true) && (%conquest.status != players)) { $display.private.message(4You cannot buy this item because monsters are in control of the conquest region it comes from! Players must be in control of the conquest in order to purchase this.) | halt }

    ; if so, increase the amount and add the item
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + $4)

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for $4 $3 $+ $iif($4 < 2, ,s) $+ ! $readini(translation.dat, system, OrbsLeft))
    $inc.redorbsspent($1, %total.price)
  }

  if ($2 = sell) {
    ; is it a valid item?
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Error: Invalid item. Use! !shop list items to get a valid list) | halt }
    if (($3 = BasicMechCore) || ($3 = BasicMechGun)) { $display.private.message(4Error: You cannot sell this item.) | halt }

    ; Does the player have it?
    var %player.items $item.amount($1, $3)
    if (%player.items = 0) { $display.private.message(4Error: You do not have this item to sell!) | halt }
    if (%player.items < $4) { $display.private.message(4Error: You do not have $4 of this item to sell!) | halt }


    var %total.price $readini($dbfile(items.db), $3, sellPrice)

    if (%total.price = $null) { 
      var %total.price $readini($dbfile(items.db), $3, cost)
      %total.price = $round($calc(%total.price / 5),0)
    }

    if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 1  }

    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $round($calc(($readini($char($1), skills, Haggling) / 100) * %total.price),0)
    }

    ; If so, decrease the amount
    writeini $char($1) item_amount $3 $calc($item.amount($1,$3) - $4)

    if (%total.price > 50000) { %total.price = 50000 }
    if (%total.price <= 0) { %total.price = 1 }

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    var %number.of.items.sold $readini($char($1), stuff, ItemsSold)
    if (%number.of.items.sold = $null) { var %number.of.items.sold 0 }
    inc %number.of.items.sold $4
    writeini $char($1) stuff ItemsSold %number.of.items.sold
    $achievement_check($1, MakeMoney)
    $display.private.message($readini(translation.dat, system, SellMessage))
    unset %total.price
  }
}

alias shop.techs {
  var %shop.currency.type $return.systemsetting(TechCurrency)
  if (%shop.currency.type = null) { var %shop.currency.type orbs }
  if ((%shop.currency.type != coins) && (%shop.currency.type != orbs)) { var %shop.currency.type orbs }

  if ($2 = list) {
    unset %shop.list
    ; get the list of the techs for the weapon you have equipped
    $weapon_equipped($1)
    $shop.get.shop.level($1)

    ; CHECKING TECHS
    unset %shop.list | var %tech.counter 0
    set %tech.list $readini($dbfile(weapons.db), %weapon.equipped.right, Abilities)
    if (%weapon.equipped.left != $null) { set %tech.list $addtok(%tech.list, $readini($dbfile(weapons.db), %weapon.equipped.left, Abilities), 46) }

    var %number.of.items $numtok(%tech.list, 46)
    var %my.tp $readini($char($1), basestats, tp)

    var %value 1
    while (%value <= %number.of.items) {
      set %tech.name $gettok(%tech.list, %value, 46)


      if (%shop.currency.type = orbs) { set %tech.price $round($calc(%shop.level * $readini($dbfile(techniques.db), %tech.name, cost)),0) }
      if (%shop.currency.type = coins) { set %tech.price $round($calc($readini($dbfile(techniques.db), %tech.name, cost) /25),0) }

      if (%tech.price < 1) { set %tech.price 1 }

      set %player.amount $readini($char($1), techniques, %tech.name)

      if ($readini($dbfile(techniques.db), %tech.name, type) = boost) {
        if ((%player.amount <= 500) || (%player.amount = $null)) { 
          inc %tech.counter 1
          if (%tech.counter <= 13) { %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
          if (%tech.counter > 13) { %shop.list2 = $addtok(%shop.list2, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
        }
      }

      if ($readini($dbfile(techniques.db), %tech.name, type) != boost) {  
        set %techs.onlyone buff.ClearStatusPositive.ClearStatusNegative 
        set %tech.type $readini($dbfile(techniques.db), %tech.name, type)
        if ($istok(%techs.onlyone,%tech.type,46) = $true) { 
          set %player.amount $readini($char($1), techniques, %tech.name)
          if ((%player.amount < 1) || (%player.amount = $null)) { 
            inc %tech.counter 1
            if (%tech.counter <= 13) { %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
            if (%tech.counter > 13) { %shop.list2 = $addtok(%shop.list2, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
          }
        }

        if ($istok(%techs.onlyone,%tech.type,46) = $false) {  
          if ((%player.amount <= 500) || (%player.amount = $null)) {
            inc %tech.counter 1
            if (%tech.counter <= 13) { %shop.list = $addtok(%shop.list, $+ $iif(%my.tp < $readini($dbfile(techniques.db), %tech.name, tp), 5) %tech.name $+ 2+1 ( $+ %tech.price $+ ),46)  }
            if (%tech.counter > 13) { %shop.list2 = $addtok(%shop.list2, $+ $iif(%my.tp < $readini($dbfile(techniques.db), %tech.name, tp), 5) %tech.name $+ 2+1 ( $+ %tech.price $+ ),46)  }
          }
        }
      }

      inc %value 1 | unset %player.amount 
    }

    ; display the list with the prices.
    $shop.cleanlist

    if (%shop.currency.type = orbs) { $display.private.message(4Tech Prices2 paid with $readini(system.dat, system, currency) $+ : %shop.list ) }
    if (%shop.currency.type = coins) { $display.private.message(4Tech Prices2 paid with Kill Coins: %shop.list ) }

    if (%shop.list2 != $null) { 
      $display.private.message.delay(2 $+ %shop.list2 ) 
    }

    unset %player.amount | unset %techs.onlyone | unset %tech.type | unset %shop.list | unset %shop.list2
    unset %ignition.tech.list | unset %techs.list | unset %tech.name | unset %shop.level | unset %tech.price
    unset %tech.count | unset %tech.power | unset %tech.counter
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid tech?
    $weapon_equipped($1)
    set %weapon.abilities $readini($dbfile(weapons.db), %weapon.equipped.right, abilities)
    if (%weapon.equipped.left != $null) { set %weapon.abilities $addtok(%weapon.abilities, $readini($dbfile(weapons.db), %weapon.equipped.left, Abilities), 46) }

    if ($istok(%weapon.abilities,$3,46) = $false) { $display.private.message(4Error: Invalid technique. Use! !shop list techs to get a valid list ) | halt }
    unset %weapon.abilities

    ; do you have enough to buy it?

    if (%shop.currency.type = orbs) {
      var %player.redorbs $readini($char($1), stuff, redorbs)
      var %base.cost $readini($dbfile(techniques.db), $3, cost)

      set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

      if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this item!) | halt }
    }

    if (%shop.currency.type = coins) {
      var %player.coins $return.killcoin.count($1)
      var %total.price $round($calc($readini($dbfile(techniques.db), $3, cost) /25),0)
      var %total.price $calc(%total.price * $4)
      if (%tech.price < 1) { var %tech.price 1 }

      if (%player.coins < %total.price) { $display.private.message(4You do not have enough Kill Coins to purchase this item! You currently need $calc(%total.price - %player.coins) more coins) | halt }
    }

    var %current.techlevel $readini($char($1), techniques, $3)

    if ($readini($dbfile(techniques.db), $3, type) = buff) { var %max.techlevel 1 }
    if ($readini($dbfile(techniques.db), $3, type) != buff) {  var %max.techlevel 500 }

    if (%current.techlevel >= %max.techlevel) {  $display.private.message(4You cannot buy any more levels of $3 $+ .) | halt }

    ; if so, increase the amount and add it to the list
    inc %current.techlevel $4

    if (%current.techlevel > %max.techlevel) {  $display.private.message(4Purchasing this amount will put you over the max limit. Please lower the amount and try again.) | halt }

    writeini $char($1) techniques $3 %current.techlevel

    ; decrease amount of currency
    if (%shop.currency.type = orbs) {
      dec %player.redorbs %total.price
      writeini $char($1) stuff redorbs %player.redorbs
      $inc.redorbsspent($1, %total.price)

      $display.private.message(3You spend $bytes(%total.price,b)  $+  $readini(system.dat, system, currency) for + $+ $4 to your $3 technique $+ ! $readini(translation.dat, system, OrbsLeft))

      ; Increase the shop level.
      $inc.shoplevel($1, $4)
    }

    if (%shop.currency.type = coins) {
      dec %player.coins %total.price
      writeini $char($1) stuff killcoins %player.coins
      $display.private.message(3You spend $bytes(%total.price,b)  $+  Kill Coins for + $+ $4 to your $3 technique $+ ! You now have $return.killcoin.count($1) Kill Coins left.)
    }

  }

  if ($2 = sell) {
    ; is it a valid item?
    if ($readini($dbfile(techniques.db), $3, type) = $null) {  $display.private.message(4Error: Invalid tech. Use! !techs to get a valid list of techs you own.) | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), techniques, $3)
    if (%player.items = $null) {  $display.private.message(4Error: You do not have this tech to sell!) | halt }
    if (%player.items < $4) {  $display.private.message(4Error: You do not have $4 levels of this tech to sell!) | halt }

    ; Sell for Orbs
    if (%shop.currency.type = orbs) {
      set %total.price $calc($readini($dbfile(techniques.db), $3, cost) / 5),0)

      if (%total.price = $null) { 
        var %total.price $readini($dbfile(techniques.db), $3, cost)
        %total.price = $round($calc(%total.price / 5),0)
      }

      if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 50  }

      if ($readini($char($1), skills, haggling) > 0) { 
        inc %total.price $round($calc(($readini($char($1), skills, Haggling) / 100) * %total.price),0)
      }

      if (%total.price >= $readini($dbfile(techniques.db), $3, cost)) { set %total.price $readini($dbfile(techniques.db), $3, cost) }
      if (%total.price > 5000) { %total.price = 5000 }
      if ((%total.price <= 0) || (%total.price = $null)) { %total.price = 50 }

      %total.price = $calc($4 * %total.price)

      var %player.redorbs $readini($char($1), stuff, redorbs)
      inc %player.redorbs %total.price
      writeini $char($1) stuff redorbs %player.redorbs

      $display.private.message(3A shop keeper wearing a green and white bucket hat uses a special incantation to take $4 $iif($4 < 2, level, levels) of $3 $+  from you and gives you %total.price $readini(system.dat, system, currency) $+ !)
    }

    ; Sell for Coins
    if (%shop.currency.type = coins) {
      set %total.price $round($calc($readini($dbfile(techniques.db), $3, cost) / 25),0)
      if ((%total.price <= 1) || (%total.price = $null)) {  set %total.price 1  }

      ; Remove a 1% or 1 coin fee for removing the tech
      var %fee $round($calc(%total.price * .01),0)
      if (%fee < 1) { var %fee 1 }
      dec %total.price %fee

      %total.price = $calc($4 * %total.price)

      var %player.coins $readini($char($1), stuff, killcoins) 
      if (%player.coins = $null) { var %player.coins 0 }
      inc %player.coins %total.price
      writeini $char($1) stuff KillCoins %player.coins
    }   

    ; If so, decrease the tech amount
    dec %player.items $4
    writeini $char($1) techniques $3 %player.items

    $display.private.message(3A shop keeper wearing a green and white bucket hat uses a special incantation to take $4 $iif($4 < 2, level, levels) of $3 $+  from you and gives you %total.price Kill Coins!)

    unset %total.price
  }
}

alias shop.skills {
  unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills | unset %total.passive.skills | unset %total.active.skills | unset %shop.list.killertraits
  unset %shop.list.activeskills3

  var %shop.currency.type $return.systemsetting(SkillCurrency)

  if ($2 = list) {
    ; get the list of the skills and display the lists
    $shop.get.shop.level($1)

    $shop.get.skills.active($1)

    if (%shop.list.activeskills != $null) {  $display.private.message(4Active Skill Prices2 in $iif(%shop.currency.type = orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.activeskills) }
    if (%shop.list.activeskills2 != $null) {  $display.private.message(2 $+ %shop.list.activeskills2) }
    if (%shop.list.activeskills3 != $null) {  $display.private.message(2 $+ %shop.list.activeskills3) }

    $shop.get.skills.passive($1)
    if (%shop.list.passiveskills != $null) {  $display.private.message(4Passive Skill Prices2 in $iif(%shop.currency.type = orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.passiveskills) }
    if (%shop.list.passiveskills2 != $null) {  $display.private.message(2 $+ %shop.list.passiveskills2) }

    $shop.get.skills.resistance($1)
    if (%shop.list.resistanceskills != $null) {  $display.private.message(4Resistance Skill Prices2 in $iif(%shop.currency.type = orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.resistanceskills) }

    $shop.get.skills.killertrait($1)
    if (%shop.list.killertraits != $null) {  $display.private.message(4Killer Trait Skill Prices2 in $iif(%shop.currency.type = orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.killertraits) }
    if (%shop.list.killertraits2 != $null) {  $display.private.message(2 $+ %shop.list.killertraits2) }

    unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills | unset %shop.list.activeskills2 | unset %shop.list.passiveskills2 | unset %total.active.skills | unset %total.passives.skills | unset %shop.list.killertraits
    unset %shop.list.killertraits2 | unset %skill.name | unset %skill.have | unset %replacechar
    unset %shop.level | unset %skill.max | unset %skill.price | unset %shop.list.activeskills3
  }


  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid skill?
    if ($readini($dbfile(skills.db), $3, type) = $null) { $display.private.message(4Error: Invalid skill. Use! !shop list skills to get a valid list) | halt }
    if ($readini($dbfile(skills.db), $3, cost) <= 0) { $display.private.message(4Error: Invalid skill. Use! !shop list skills to get a valid list) | halt }

    var %current.skilllevel $readini($char($1), skills, $3)
    inc %current.skilllevel $4
    var %max.skilllevel $readini($dbfile(skills.db), $3, max)
    if (%max.skilllevel = $null) { var %max.skilllevel 100000 }
    if (%current.skilllevel > %max.skilllevel) { $display.private.message(4You cannot buy any more levels into this skill as you have already hit or will go over the max amount with this purchase amount.) | halt }

    ; do you have enough to buy it?

    if (%shop.currency.type = orbs) { 
      var %player.redorbs $readini($char($1), stuff, redorbs)
      var %base.cost $readini($dbfile(skills.db), $3, cost)

      set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

      if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this skill!) | halt }

      ; decrease amount of orbs you have.
      dec %player.redorbs %total.price
      writeini $char($1) stuff redorbs %player.redorbs
      $inc.redorbsspent($1, %total.price)

      $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $4 to your $3 skill $+ ! $readini(translation.dat, system, OrbsLeft))
    }

    if (%shop.currency.type = coins) { 
      var %player.coins $return.killcoin.count($1)
      var %total.price $round($calc($readini($dbfile(skills.db), $3, cost) / 20),0)
      var %total.price $calc(%total.price * $4)

      if (%player.coins < %total.price) { $display.private.message(4You do not have enough Kill Coins to purchase this skill! You still need $calc(%total.price - %player.coins) coins in order to make this purchase.) | halt }

      ; decrease amount of coins you have.
      dec %player.coins %total.price
      writeini $char($1) stuff killcoins %player.coins

      $display.private.message(3You spend $bytes(%total.price,b)  $+ Kill Coins for + $+ $4 to your $3 skill $+ ! You now have %player.coins Kill Coins left)
    }

    ; Increase the skill level
    writeini $char($1) skills $3 %current.skilllevel

    if (%shop.currency.type = orbs) { 
      ; Increase the shop level.
      $inc.shoplevel($1, $4)
    }
  }
}

alias shop.get.skills.passive {
  var %shop.currency.type $return.systemsetting(TechCurrency)

  ; CHECKING PASSIVE SKILLS
  unset %shop.list | unset %skill.list | unset %shop.list.passiveskills2 | unset %total.passive.skills
  var %skills.lines $lines($lstfile(skills_passive.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_passive.lst)
    set %skill.max $readini($dbfile(skills.db), %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)

    if (%skill.have >= %skill.max) { inc %value 1 }
    else { 

      if (%shop.currency.type = orbs) { set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0) }
      if (%shop.currency.type = coins) { set %skill.price $round($calc($readini($dbfile(skills.db), %skill.name, cost) / 20),0) } 

      if (%skill.price > 0) { 

        if ((%total.passive.skills <= 15) || (%total.passive.skills = $null)) {  %shop.list.passiveskills = $addtok(%shop.list.passiveskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if (%total.passive.skills > 15) {  %shop.list.passiveskills2 = $addtok(%shop.list.passiveskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        inc %total.passive.skills 1
      }
      inc %value 1 
    }
  }

  unset %skill.list | unset %total.passive.skills

  set %replacechar $chr(044) $chr(032) |  %shop.list.passiveskills = $replace(%shop.list.passiveskills, $chr(046), %replacechar) | %shop.list.passiveskills2 = $replace(%shop.list.passiveskills2, $chr(046), %replacechar)
}

alias shop.get.skills.active {
  var %shop.currency.type $return.systemsetting(TechCurrency)

  ; CHECKING ACTIVE SKILLS
  unset %skill.list | unset %value | unset %shop.list.activeskills2 | unset %shop.list.activeskills3 | unset %total.active.skills
  var %skills.lines $lines($lstfile(skills_active.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_active.lst)
    set %skill.max $readini($dbfile(skills.db), %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)

    if (%skill.have >= %skill.max) { inc %value 1 }
    else { 
      if (%shop.currency.type = orbs) { set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0) }
      if (%shop.currency.type = coins) { set %skill.price $round($calc($readini($dbfile(skills.db), %skill.name, cost) / 20),0) } 

      if (%skill.price > 0) { 
        if ((%total.active.skills <= 15) || (%total.active.skills = $null)) {  %shop.list.activeskills = $addtok(%shop.list.activeskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if ((%total.active.skills > 15) && (%total.active.skills < 28)) {  %shop.list.activeskills2 = $addtok(%shop.list.activeskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if (%total.active.skills >= 28 ) {  %shop.list.activeskills3 = $addtok(%shop.list.activeskills3, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }

        inc %total.active.skills 1
      }
      inc %value 1
    }
  }

  unset %skill.list 

  set %replacechar $chr(044) $chr(032) |  %shop.list.activeskills = $replace(%shop.list.activeskills, $chr(046), %replacechar) | %shop.list.activeskills2 = $replace(%shop.list.activeskills2, $chr(046), %replacechar)
  %shop.list.activeskills3 = $replace(%shop.list.activeskills3, $chr(046), %replacechar)

}

alias shop.get.skills.resistance {
  var %shop.currency.type $return.systemsetting(TechCurrency)

  ; CHECKING RESISTANCES
  unset %skill.list | unset %value
  var %skills.lines $lines($lstfile(skills_resists.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_resists.lst)
    set %skill.max $readini($dbfile(skills.db), %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)

    if (%skill.have >= %skill.max) { inc %value 1 }
    else { 
      if (%shop.currency.type = orbs) { set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0) }
      if (%shop.currency.type = coins) { set %skill.price $round($calc($readini($dbfile(skills.db), %skill.name, cost) / 20),0) } 

      if (%skill.price > 0) { %shop.list.resistanceskills = $addtok(%shop.list.resistanceskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) } 
      inc %value 1 
    }
  }

  set %replacechar $chr(044) $chr(032) |  %shop.list.resistanceskills = $replace(%shop.list.resistanceskills, $chr(046), %replacechar)
}

alias shop.get.skills.killertrait {
  var %shop.currency.type $return.systemsetting(TechCurrency)

  ; CHECKING KILLER TRAITS
  unset %skill.list | unset %value
  var %skills.lines $lines($lstfile(skills_killertraits.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_killertraits.lst)
    set %skill.max $readini($dbfile(skills.db), %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)

    if (%skill.have >= %skill.max) { inc %value 1 }
    else { 
      if (%shop.currency.type = orbs) { set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0) }
      if (%shop.currency.type = coins) { set %skill.price $round($calc($readini($dbfile(skills.db), %skill.name, cost) / 20),0) } 

      if ((%total.killertraits <= 13) || (%total.killertraits = $null)) {  %shop.list.killertraits = $addtok(%shop.list.killertraits, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      if (%total.killertraits > 13) { %shop.list.killertraits2 = $addtok(%shop.list.killertraits2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }

      inc %value 1 | inc %total.killertraits 1
    }
  }

  set %replacechar $chr(044) $chr(032) |  %shop.list.killertraits = $replace(%shop.list.killertraits, $chr(046), %replacechar) | %shop.list.killertraits2 = $replace(%shop.list.killertraits2, $chr(046), %replacechar)

  unset %total.killertraits
}

alias shop.skills.passive {
  var %shop.currency.type $return.systemsetting(TechCurrency)

  unset %shop.list.passiveskills | unset %shop.list.passiveskills2
  ; get the list of the skills
  $shop.get.shop.level($1)

  $shop.get.skills.passive($1)

  ; display the list with the prices.
  if (%shop.list.passiveskills != $null) {  $display.private.message(4Passive Skill Prices2 in $iif(%shop.currency.type = orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.passiveskills) }
  if (%shop.list.passiveskills2 != $null) { $display.private.message(2 $+ %shop.list.passiveskills2) }

  unset %shop.list.passiveskills |   unset %shop.list.passiveskills2 | unset %total.passive.skills
  unset %skill.name | unset %skill.have | unset %replacechar
}

alias shop.skills.active {
  unset %shop.list.activeskills | unset %shop.list.activeskills2
  ; get the list of the skills
  $shop.get.shop.level($1)
  $shop.get.skills.active($1)

  ; display the list with the prices.
  if (%shop.list.activeskills != $null) {  $display.private.message(4Active Skill Prices2 in $iif(%shop.currency.type = orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.activeskills) }
  if (%shop.list.activeskills2 != $null) {  $display.private.message(2 $+ %shop.list.activeskills2) }

  unset %shop.list.activeskills |   unset %shop.list.activeskills2 | unset %total.active.skills
  unset %skill.name | unset %skill.have | unset %replacechar
}

alias shop.skills.resists {
  var %shop.currency.type $return.systemsetting(TechCurrency)

  unset %shop.list.resistanceskills
  ; get the list of the skills
  $shop.get.shop.level($1)
  $shop.get.skills.resistance($1)

  ; display the list with the prices.
  if (%shop.list.resistanceskills != $null) { $display.private.message(4Resistance Skill Prices2 in $iif(%shop.currency.type =orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.resistanceskills) }

  unset %shop.list.resistanceskills
  unset %skill.name | unset %skill.have | unset %replacechar
}

alias shop.skills.killertraits {
  var %shop.currency.type $return.systemsetting(TechCurrency)

  unset %shop.list.killertraits
  ; get the list of the skills
  $shop.get.shop.level($1)
  $shop.get.skills.killertrait($1)

  if (%shop.list.killertraits != $null) {  $display.private.message(4Killer Trait Skill Prices2 in $iif(%shop.currency.type =orbs, $readini(system.dat, system, currency), Kill Coins) $+ : %shop.list.killertraits) }
  if (%shop.list.killertraits2 != $null) {  $display.private.message(2 $+ %shop.list.killertraits2) }

  unset %shop.list.killertraits2 | unset %skill.name | unset %skill.have
  unset %skill.name | unset %skill.have | unset %replacechar
}

alias shop.get.skills.enhancingpoint {
  ; CHECKING ENHANCING POINT SKILLS
  unset %shop.list.skills | unset %value 
  var %skills.lines $lines($lstfile(skills_enhancingpoint.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_enhancingpoint.lst)
    set %skill.max $readini($dbfile(skills.db), %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)
    if (%skill.have = $null) { var %skill.have 0 }

    if (%skill.have < %skill.max) {
      var %enhancement.purchase.skill $readini($char($1), enhancements, %skill.name)
      if (%enhancement.purchase.skill = $null) { var %enhancement.purchase.skill 0 }
      if (%enhancement.purchase.skill < %skill.max) { %shop.list.skills = $addtok(%shop.list.skills, $+ %skill.name $+ +1 ( $+ $calc(1 + %enhancement.purchase.skill) $+ ),46) }
    }
    inc %value 1
  }

  unset %skill.list 

  set %replacechar $chr(044) $chr(032) |  %shop.list.skills = $replace(%shop.list.skills, $chr(046), %replacechar) 
}


alias shop.stats {
  if ($2 = list) {
    ; get the list of all the shop items..
    $shop.get.shop.level($1)
    var %hp.price $round($calc(%shop.level * $readini(system.dat, statprices, hp)),0)
    var %tp.price $round($calc(%shop.level * $readini(system.dat, statprices, tp)),0)
    var %str.price $round($calc(%shop.level * $readini(system.dat, statprices, str)),0)
    var %def.price $round($calc(%shop.level * $readini(system.dat, statprices, def)),0)
    var %int.price $round($calc(%shop.level * $readini(system.dat, statprices, int)),0)
    var %spd.price $round($calc(%shop.level * $readini(system.dat, statprices, spd)),0)
    var %ig.price $round($calc(%shop.level * $readini(system.dat, statprices, ig)),0)

    var %player.current.hp $readini($char($1), basestats, hp)
    var %player.max.hp $readini(system.dat, system, maxHP)
    dec %player.max.hp $armor.stat($1, hp)

    if (%player.current.hp < %player.max.hp) { 
      %shop.list = $addtok(%shop.list,HP+50 ( $+ %hp.price $+ ),46)
    }

    var %player.current.tp $readini($char($1), basestats, tp)
    var %player.max.tp $readini(system.dat, system, maxTP)
    dec %player.max.tp $armor.stat($1, tp)

    if (%player.current.tp < %player.max.tp) {
      %shop.list = $addtok(%shop.list,TP+5 ( $+ %tp.price $+ ),46)
    }

    var %player.current.ig $readini($char($1), basestats, IgnitionGauge)
    var %player.max.ig $readini(system.dat, system, maxIG)
    if (%player.max.ig = $null) { var %player.max.ig 100 }
    if (%player.current.ig < %player.max.ig) {
      %shop.list = $addtok(%shop.list,IG [Ignition Gauge]+1 ( $+ %ig.price $+ ),46)
    }

    %shop.list = $addtok(%shop.list,Str+1 ( $+ %str.price $+ ),46)
    %shop.list = $addtok(%shop.list,Def+1 ( $+ %def.price $+ ),46)
    %shop.list = $addtok(%shop.list,Int+1 ( $+ %int.price $+ ),46)
    %shop.list = $addtok(%shop.list,Spd+1 ( $+ %spd.price $+ ),46)

    ; display the list with the prices.
    $shop.cleanlist
    $display.private.message(2Stat Prices in $readini(system.dat, system, currency) $+ : %shop.list)
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    if ($readini(system.dat, statprices, $3) = $null) { $display.private.message(4Error: Invalid stat! Use! !shop list stats to get a valid list) | halt }

    ; do you have enough to buy it?
    var %base.cost $readini(system.dat, StatPrices, $3)
    var %player.shop.redorbs $readini($char($1), stuff, redorbs)
    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if ($3 = hp) {
      var %player.current.hp $readini($char($1), basestats, hp)
      dec %player.current.hp $armor.stat($1, hp)
      if (%player.current.hp >= $readini(system.dat, system, maxHP)) { $display.private.message(4Error: You have the maximum amount of HP allowed!) | halt }
    }

    if ($3 = tp) {
      var %player.current.tp $readini($char($1), basestats, tp)
      dec %player.current.tp $armor.stat($1, tp)
      if (%player.current.tp >= $readini(system.dat, system, maxTP)) {  $display.private.message(4Error: You have the maximum amount of TP allowed!) | halt }
    }

    if (($3 = ig) || ($3 = IgnitionGauge)) {
      var %player.current.ig $readini($char($1), basestats, IgitionGauge)
      if (%player.current.ig >= $readini(system.dat, system, maxig)) {  $display.private.message(4Error: You have the maximum amount of Ignition Gauge allowed!) | halt }
    }

    if (%player.shop.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this upgrade!) | halt }

    var %shop.battlestats str.int.def.spd
    if ($istok(%shop.battlestats,$3,46) = $true) { 
      var %current.level $get.level($1)

      var %current.stat $readini($char($1), basestats, $3) 
      var %total.stats $calc($readini($char($1), basestats, str) + $readini($char($1), basestats, def) + $readini($char($1), basestats, int) + $readini($char($1), basestats, spd))
      var %stat.ratio $calc(%current.stat / %total.stats)
      var %player.level $get.level($1)

      if (%player.level <= 50) { var %stat.ratio.limit .55 }
      if ((%player.level > 50) && (%player.level <= 1000)) { var %stat.ratio.limit .43 }
      if ((%player.level > 1000) && (%player.level <= 5000)) { var %stat.ratio.limit .35 }
      if (%player.level > 5000) { var %stat.ratio.limit .335 }

      if (%stat.ratio > %stat.ratio.limit) { $display.private.message($readini(translation.dat, errors, Can'tRaiseStatBeforeOthers)) | halt }
    }

    ; if so, increase the amount and add the stat bonus
    if (($3 != IG) && ($3 != IgnitionGauge)) {  var %basestat.to.increase $readini($char($1), basestats, $3) }
    if (($3 = IG) || ($3 = IgnitionGauge)) { var %basestat.to.increase $readini($char($1), basestats, IgnitionGauge) }

    set %shop.statbonus 0

    if (($3 = str) || ($3 = def)) { set %shop.statbonus 1 }
    if (($3 = int) || ($3 = spd)) { set %shop.statbonus 1 }
    if ($3 = hp) { set %shop.statbonus 50  }
    if ($3 = tp) { set %shop.statbonus 5 }
    if (($3 = ig) || ($3 = IgnitionGauge)) { set %shop.statbonus 1 }

    %shop.statbonus = $calc(%shop.statbonus * $4)
    inc %basestat.to.increase %shop.statbonus

    if ($3 = hp) {
      if (%basestat.to.increase > $readini(system.dat, system, maxHP)) { $display.private.message(4Error: This amount will push you over the limit allowed for HP. Please lower the amount and try again.) | halt }
    }

    if ($3 = tp) {
      if (%basestat.to.increase > $readini(system.dat, system, maxTP)) {  $display.private.message(4Error: This amount will push you over the limit allowed for TP. Please lower the amount and try again.) | halt }
    }

    if (($3 = ig) || ($3 = IgnitionGauge)) {
      if (%basestat.to.increase > $readini(system.dat, system, maxIG)) { $display.private.message(4Error: This amount will push you over the limit allowed for the Ignition Gauge. Please lower the amount and try again.) | halt }
    }

    if (($3 != IG) && ($3 != IgnitionGauge)) {  writeini $char($1) basestats $3 %basestat.to.increase }
    if (($3 = IG) || ($3 = IgnitionGauge)) { writeini $char($1) basestats IgnitionGauge %basestat.to.increase }


    $fulls($1, yes)

    ; decrease amount of orbs you have.
    dec %player.shop.redorbs %total.price
    writeini $char($1) stuff redorbs %player.shop.redorbs
    $inc.redorbsspent($1, %total.price)

    $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $bytes(%shop.statbonus,b) to your $3 $+ ! $readini(translation.dat, system, OrbsLeft))

    ; Increase the shop level.
    $inc.shoplevel($1, $4)

    var %new.level $get.level($1)
    if (%new.level > %current.level) {
      if ($return.systemsetting(ShowPlayerLevelUp) = true) { $display.message($readini(translation.dat, system, PlayerHasLeveledUp), global) }
    }

  }
}

alias shop.enhancements {
  if ($2 = list) {
    unset %shop.list

    $display.private.message(2Everything listed here is purchased using Enhancement Points.)

    ; Check for stats first.

    var %enhancement.purchase.hp $readini($char($1), enhancements, hp)
    if (%enhancement.purchase.hp = $null) { var %enhancement.purchase.hp 0 }

    var %enhancement.purchase.ig $readini($char($1), enhancements, ig)
    if (%enhancement.purchase.ig = $null) { var %enhancement.purchase.ig 0 }

    var %enhancement.purchase.str $readini($char($1), enhancements, str)
    if (%enhancement.purchase.str = $null) { var %enhancement.purchase.str 0 }

    var %enhancement.purchase.def $readini($char($1), enhancements, def)
    if (%enhancement.purchase.def = $null) { var %enhancement.purchase.def 0 }

    var %enhancement.purchase.int $readini($char($1), enhancements, int)
    if (%enhancement.purchase.int = $null) { var %enhancement.purchase.int 0 }

    var %enhancement.purchase.spd $readini($char($1), enhancements, spd)
    if (%enhancement.purchase.spd = $null) { var %enhancement.purchase.spd 0 }

    if (%enhancement.purchase.hp < 50) { %shop.list = $addtok(%shop.list,HP+50 ( $+ $calc(1 + %enhancement.purchase.hp) $+ ),46) }
    if (%enhancement.purchase.ig < 10) { %shop.list = $addtok(%shop.list,IG+5 ( $+ $calc(1 + %enhancement.purchase.ig) $+ ),46) }
    if (%enhancement.purchase.str < 20) { %shop.list = $addtok(%shop.list,STR+10 ( $+ $calc(1 + %enhancement.purchase.str) $+ ),46) }
    if (%enhancement.purchase.def < 20) { %shop.list = $addtok(%shop.list,DEF+10 ( $+ $calc(1 + %enhancement.purchase.def) $+ ),46) }
    if (%enhancement.purchase.int < 20) { %shop.list = $addtok(%shop.list,INT+10 ( $+ $calc(1 + %enhancement.purchase.int) $+ ),46) }
    if (%enhancement.purchase.spd < 20) { %shop.list = $addtok(%shop.list,SPD+10 ( $+ $calc(1 + %enhancement.purchase.spd) $+ ),46) }

    ; display the list with the prices.
    $shop.cleanlist
    if (%shop.list != $null) { $display.private.message.delay(2Stat Enhancements5: %shop.list) }

    ; Check for skills
    $shop.get.skills.enhancingpoint($1)
    if (%shop.list.skills != $null) { $display.private.message.delay.custom(2Enhancement Skills5: %shop.list.skills,2) }

    ; Check for styles (to be added)

    ; Check for the second accessory slot
    if (($readini($char($1), enhancements, accessory2) != true) && ($shopnpc.present.check(Jeweler) = true)) {
      $display.private.message.delay.custom(2Equipment Enhancements5: AccessorySlot2 (10),2) 
    }

    ; Check for "Portal Usage Limit"
    if (($readini($char($1), enhancements, portalusage) < 2) || ($readini($char($1), enhancements, portalusage) = $null)) { 
      $display.private.message.delay.custom(2Battle Enhancements5: DailyPortalUsage+1 (10),2) 
    }

    unset %shop.list | unset %shop.list.skills
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    var %valid.purchase.items hp.ig.str.def.int.spd.Stoneskin.SpoilSeeker.TabulaRasa.Demolitions.DragonHunter.Overwhelm.DieHard.AccessorySlot2.DailyPortalUsage
    var %valid.purchase.skills Stoneskin.SpoilSeeker.TabulaRasa.Demolitions.DragonHunter.Overwhelm.DieHard

    if ($istok(%valid.purchase.items, $lower($3), 46) = $false) { $display.private.message(4You cannot purchase that in this shop) | halt }

    ; do you have enough to buy it?
    var %enhancement.purchase.item $readini($char($1), enhancements, $3)
    if (%enhancement.purchase.item = $null) { var %enhancement.purchase.item 0 }

    if ($3 = AccessorySlot2) { var %enhancement.cost 10 }
    if ($3 = DailyPortalUsage) { var %enhancement.cost 10 }
    if (($3 != AccessorySlot2) && ($3 != DailyPortalUsage)) {  var %enhancement.cost $calc(1 + %enhancement.purchase.item) }

    var %current.player.ep $enhancementpoints($1)
    if (%current.player.ep = $null) { var %current.player.ep 0 }

    if (%current.player.ep < %enhancement.cost) { $display.private.message(4You do not have enough Enhancement Points to purchase this upgrade!) | halt }

    if (($3 != AccessorySlot2) && ($3 != DailyPortalUsage)) { 

      ; Are we hitting the cap amount?
      var %purchase.cap 10

      if ($3 = hp) { var %purchase.cap 50 }
      if (((($3 = str) || ($3 = def) || ($3 = int) || ($3 = spd)))) { inc %purchase.cap 20 }
      if ($istok(%valid.purchase.skills, $lower($3), 46) = $true) { var %purchase.cap $readini($dbfile(skills.db), $3, max) }

      if (%enhancement.cost > %purchase.cap) { $display.private.message(4You cannot purchase any more into this upgrade!) | halt }

      ; Increase the amount and add the enhancement
      inc %enhancement.purchase.item 1
      writeini $char($1) enhancements $3 %enhancement.purchase.item
    }

    if ($3 = AccessorySlot2) { 
      if ($readini($char($1), enhancements, accessory2) = true) { $display.private.message(4You already own this enhancement!) | halt }
      if ($shopnpc.present.check(Jeweler) != true) { $display.private.message(4Error: $readini(shopnpcs.dat, NPCNames,Jeweler) is not at the Allied Forces HQ so this upgrade cannot be purchased.) | halt }
      writeini $char($1) enhancements Accessory2 true
      writeini $char($1) equipment Accessory2 nothing
    }

    if ($3 = DailyPortalUsage) {
      var %portalusage $readini($char($1), enhancements, portalusage)
      if (%portalusage = $null) { var %portalusage 0 } 

      if (%portalusage >= 2) { $display.private.message(4You already own the maximum amount of this enhancement!) | halt }
      inc %portalusage 1
      writeini $char($1) Enhancements PortalUsage %portalusage

    }


    var %number.of.enhancement.spent $readini($char($1), stuff, EnhancementPointsSpent)
    if (%number.of.enhancement.spent = $null) { var %number.of.enhancement.spent 0 }
    inc %number.of.enhancement.spent %enhancement.cost
    writeini $char($1) stuff EnhancementPointsSpent %number.of.enhancement.spent
    $achievement_check($1, HarderBetterFasterStronger)

    ; Decrease the player's enhancement points
    dec %current.player.ep %enhancement.cost
    writeini $char($1) stuff EnhancementPoints %current.player.ep

    ; Is it a stat?
    if ($istok(hp.ig.str.def.int.spd, $lower($3), 46) = $true) {
      set %shop.statbonus 0

      if ($3 = hp) {
        var %current.max.hp $readini($char($1), basestats, hp)
        var %capped.hp $readini(system.dat, system, maxHP)
        if (%current.max.hp < %capped.hp) { $display.private.message(4Your max HP is under the current cap and you cannot purchase any HP enhancements until you are over the cap) | halt }
      }

      if ($3 = ig) {
        var %current.max.ig $readini($char($1), basestats, IgnitionGauge)
        var %capped.ig $readini(system.dat, system, MaxIG)
        if (%current.max.ig < %capped.ig) { $display.private.message(4Your max IG is under the current cap and you cannot purchase any IG enhancements until you are over the cap) | halt }
      }


      var %basestat.to.increase $readini($char($1), basestats, $3)

      if (($3 = str) || ($3 = def)) { set %shop.statbonus 10 }
      if (($3 = int) || ($3 = spd)) { set %shop.statbonus 10 }
      if ($3 = hp) { set %shop.statbonus 50  }
      if (($3 = ig) || ($3 = IgnitionGauge)) { var %basestat.to.increase $readini($char($1), basestats, IgnitionGauge) | set %shop.statbonus 5 }

      inc %basestat.to.increase %shop.statbonus 

      if (($3 != IG) && ($3 != IgnitionGauge)) {  writeini $char($1) basestats $3 %basestat.to.increase }
      if (($3 = IG) || ($3 = IgnitionGauge)) { writeini $char($1) basestats IgnitionGauge %basestat.to.increase }
      if (($3 = health) || ($3 = HP)) { writeini $char($1) basestats HP %basestat.to.increase }

      writeini $char($1) info NeedsFulls yes |  $fulls($1)
      $display.private.message(3You spend $bytes(%enhancement.cost,b) Enhancement Points for + $+ $bytes(%shop.statbonus,b) to your $3 $+ !)

    }

    ; Is it a skill?
    if ($istok(%valid.purchase.skills, $lower($3), 46) = $true) {
      var %skill.level $readini($char($1), skills, $3)
      if (%skill.level = $null) { var %skill.level 0 }
      inc %skill.level 1 
      writeini $char($1) skills $3 %skill.level
      $display.private.message(3You spend $bytes(%enhancement.cost,b) Enhancement Points for +1 to the $3 skill!)
    }

    if ($3 = AccessorySlot2) { 
      $display.private.message(3 $+ $readini(shopnpcs.dat, NPCNames,Jeweler) hands you a special accessory upgrade that allows you to wear two accessories at the same time.2 "Now remember! Accessories do nothing if not equipped!") 
      $display.private.message(3You have spent $bytes(%enhancement.cost,b) Enhancement Points for the second accessory slot. To equip something to this slot use !equip accessory 2 accessoryname)
    }

    if ($3 = DailyPortalUsage) {
      $display.private.message(3You spend $bytes(%enhancement.cost,b) Enhancement Points and feel your Daily Portal Usage Limit increase! You can now do $calc($portal.dailymaxlimit + $readini($char($1), enhancements, portalusage)) portals a day.)
    }

  }
}

alias shop.weapons {
  if ($2 = list) {
    $display.private.message(2New weapon prices are in Black Orbs.  Upgrades are listed in $readini(system.dat, system, currency))
    unset %shop.list | unset %upgrade.list | unset %upgrade.list2 | unset %upgrade.list3 | unset %upgrade.list4
    ; get the list of the weapons.
    $shop.get.shop.level($1)

    unset %shop.list |  unset %weapon.list | unset %weapons | unset %number.of.weapons | unset %base.weapon.list | unset %weapon.list2 | unset %weapon.list3 | unset %weapon.list4
    set %total.weapons.owned 0 | var %upgrade.list.counter 1

    var %weapon.list.place 1 | var %total.weapon.lists $lines($lstfile(weaponlists.lst)) | var %upgrades.available 0 

    while (%weapon.list.place <= %total.weapon.lists) {
      var %weapons.line $read -l $+ %weapon.list.place $lstfile(weaponlists.lst)
      set %weapons $readini($dbfile(weapons.db), Weapons, %weapons.line)
      var %number.of.weapons $numtok(%weapons, 46)
      var %value 1

      while (%value <= %number.of.weapons) {
        set %weapon.name $gettok(%weapons, %value, 46)
        set %weapon_level $readini($char($1), weapons, %weapon.name)
        var %weapon.cost $readini($dbfile(weapons.db), %weapon.name, cost)

        if (%weapon.cost > 0) {
          ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
          if ($readini($char($1), weapons, %weapon.name) != $null) { 
            if (%weapon_level < 500) { 
              set %weapon.price $round($calc(%shop.level * $readini($dbfile(weapons.db), %weapon.name, upgrade)),0)
              inc %upgrades.available 1

              if (%upgrades.available >= 11) { inc %upgrade.list.counter 1 | var %upgrades.available 0 }
              $add.upgradelist(%upgrade.list.counter, %weapon.name, %weapon.price)
            }
          }

          else {  
            if (%weapons.line != defunct) {
              set %weapon.price $readini($dbfile(weapons.db), %weapon.name, cost)
              if (%weapon.price != 0) { %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46) }
            }
          }

        }
        inc %value 1 
      }

      ; Display the weapons available for purchase.
      if (%shop.list != $null) {  $shop.cleanlist 

        var %weaponlist.title $readini($dbfile(weapons.db), WeaponDisplayTitles, %weapons.line)
        if (%weaponlist.title = $null) { var %weaponlist.title %weaponlist.line }

        if ($right(%weaponlist.title,1) = s) { var %weaponlist.title $removecs(%weaponlist.title, s)  }
        if (%weaponlist.title = Handtohand) { var %weaponlist.title Hand to Hand }

        $display.private.message(4New %weaponlist.title Weapons:2 %shop.list)
      }

      unset %weapon.price | unset %shop.list3 | unset %mech.weapon.list | unset %mech.weapon.list2
      unset %total.weapons.owned | unset %shop.list2
      inc %weapon.list.place | unset %value | unset %shop.list | unset %weapon.name | unset %weapon_level | unset %number.of.weapons
    }


    if (%upgrade.list1 != $null) {
      set %replacechar $chr(044) $chr(032) 
      $display.private.message(2Weapons you can upgrade:)

      %upgrade.list1 = $replace(%upgrade.list1, $chr(046), %replacechar)
      $display.private.message.delay(2 $+ %upgrade.list1)

      var %upgrade.counter 2

      while ($return.upgradelist(%upgrade.counter) != $null) {

        set %display.upgradelist $return.upgradelist(%upgrade.counter)
        %display.upgradelist = $replace(%display.upgradelist, $chr(046), %replacechar)

        $display.private.message.delay(2 $+ %display.upgradelist)
        $unset.upgradelist(%upgrade.counter) | unset %display.upgradelist
        inc %upgrade.counter

        if (%upgrade.counter > 100) { echo -a breaking to prevent a flood | break }
      }

      unset %replacechar | unset %upgrade.list1
      unset %weapons | unset %shop.level

    }
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(weapons.db), $3, type) = $null) { $display.private.message(4Error: Invalid weapon! Use! !shop list weapons to get a valid list ) | halt }
    if ($readini($dbfile(weapons.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this weapon!) | halt }
    var %weapon.level $readini($char($1), weapons, $3)
    if (%weapon.level != $null) { 

      if (%weapon.level >= 250) {  $display.private.message(4You cannot buy any more levels into this weapon using the shop. To continue upgrading, please find, craft or purchase weapon upgrade items) | halt }

      ; do you have enough to buy it?
      var %player.redorbs $readini($char($1), stuff, redorbs)
      var %base.cost $readini($dbfile(weapons.db), $3, upgrade)
      set %total.price $shop.calculate.totalcost($1, $4, %base.cost)
      if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this weapon upgrade!) | halt }
      dec %player.redorbs %total.price
      $inc.redorbsspent($1, %total.price)
      inc %weapon.level $4

      if (%weapon.level > 250) {   $display.private.message(4Purchasing this amount will put you over the max limit. Please lower the amount and try again.) | halt }

      writeini $char($1) stuff redorbs %player.redorbs
      writeini $char($1) weapons $3 %weapon.level
      $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) to upgrade your $3 $+ ! $readini(translation.dat, system, OrbsLeft))
      $inc.shoplevel($1, $4)
      halt
    }
    else {
      ; do you have enough to buy it?
      var %player.blackorbs $readini($char($1), stuff, blackorbs) 
      var %total.price $readini($dbfile(weapons.db), $3, cost)
      if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this item!) | halt }
      dec %player.blackorbs %total.price
      writeini $char($1) stuff blackorbs %player.blackorbs
      $inc.blackorbsspent($1, %total.price)
      writeini $char($1) weapons $3 1
      $display.private.message(3You spend %total.price black $iif(%total.price < 2, orb, orbs) to purchase $3 $+ ! $readini(translation.dat, system, BlackOrbsLeft))
      halt
    }
  }

  if ($2 = sell) {
    ; is it your fists?
    if ($3 = fists) { $display.private.message(4You cannot sell your fists) | halt }

    ; does the person have the weapon?
    var %weapon.level $readini($char($1), weapons, $3)
    if ((%weapon.level = $null) || (%weapon.level = 0)) { $display.private.message(4You do not have that weapon to sell!) | halt }

    ; is the weapon equipped?
    if (($readini($char($1), Weapons, Equipped) = $3) || ($readini($char($1), Weapons, EquippedLeft) = $3)) { $display.private.message(4You currently have that weapon equipped. Unequip the weapon before you sell it.) | halt }

    ; get the orb amount, cut it in half if it's greater than 1. If it's a special blueprint weapon set the cost to 5
    var %orb.amount $readini($dbfile(weapons.db), $3, cost)
    if (%orb.amount > 0) { var %orb.amount $round($calc(%orb.amount / 2),0) }
    if (%orb.amount = 0) { var %orb.amount 5 }

    ; give the orbs to the player
    var %orbs.players $readini($char($1), stuff, blackorbs)
    inc %orbs.players %orb.amount
    writeini $char($1) stuff blackorbs %orbs.players

    ; remove the weapon
    remini $char($1) weapons $3

    ; Display the amount
    $display.private.message($readini(translation.dat, system, SellWeaponMessage))
  }

}

alias shop.shields {

  ; Is the shield shop merchant even there?
  if ($readini(shopnpcs.dat, NPCStatus, ShieldMerchant) != true) { $display.private.message(2The shield merchant is currently unavailable for you to purchase a shield.) | halt }

  if ($2 = list) {
    $display.private.message(2New shield prices are in Black Orbs. Remember that you need the DualWield skill to use a shield.)
    ; get the list of the shields.

    unset %shop.list |  unset %shield.list | unset %shields | unset %number.of.shields | unset %base.shield.list | unset %shield.list2 | unset %shield.list3 | unset %shield.list4
    set %total.shields.owned 0 | var %upgrade.list.counter 1

    var %shield.list.place 1 | var %total.shield.lists $lines($lstfile(shieldlists.lst)) | var %upgrades.available 0 

    while (%shield.list.place <= %total.shield.lists) {
      var %shields.line $read -l $+ %shield.list.place $lstfile(shieldlists.lst)
      set %shields $readini($dbfile(weapons.db), shields, %shields.line)
      var %number.of.shields $numtok(%shields, 46)
      var %value 1

      while (%value <= %number.of.shields) {
        set %shield.name $gettok(%shields, %value, 46)
        set %shield_level $readini($char($1), shields, %shield.name)
        var %shield.cost $readini($dbfile(weapons.db), %shield.name, cost)

        if (%shield.cost > 0) {
          ; Does the player own this shield?  If not, add it to the new shield list.
          if ($readini($char($1), weapons, %shield.name) = $null) { 
            if (%shield.cost != 0) { %shop.list = $addtok(%shop.list, $+ %shield.name $+  ( $+ %shield.cost $+ ),46) }
          }
        }

        inc %value 1 
      }

      ; Display the shields available for purchase.
      if (%shop.list != $null) {  $shop.cleanlist 

        var %shieldlist.title %shields.line
        if ($right(%shieldlist.title,1) = s) { var %shieldlist.title $removecs(%shieldlist.title, s)  }

        $display.private.message(4New %shieldlist.title Shields:2 %shop.list)
      }

      unset %shield.price | unset %shop.list3 | unset %mech.shield.list | unset %mech.shield.list2
      unset %total.shields.owned | unset %shop.list2
      inc %shield.list.place | unset %value | unset %shop.list | unset %shield.name | unset %shield_level | unset %number.of.shields
      unset %shields
    }
  }


  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(weapons.db), $3, type) = $null) { $display.private.message(4Error: Invalid shield! Use! !shop list shields to get a valid list ) | halt }
    if ($readini($dbfile(weapons.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this shield!) | halt }
    var %shield.level $readini($char($1), weapons, $3)
    if (%shield.level != $null) { $display.private.message(4You already own this shield.) | halt }
    else {
      ; do you have enough to buy it?
      var %player.blackorbs $readini($char($1), stuff, blackorbs) 
      var %total.price $readini($dbfile(weapons.db), $3, cost)
      if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this item!) | halt }
      dec %player.blackorbs %total.price
      writeini $char($1) stuff blackorbs %player.blackorbs
      $inc.blackorbsspent($1, %total.price)
      writeini $char($1) weapons $3 1
      $display.private.message(3You spend %total.price black $iif(%total.price < 2, orb, orbs) to purchase $3 $+ ! $readini(translation.dat, system, BlackOrbsLeft))
      halt
    }
  }
}


alias add.upgradelist {
  % [ $+ upgrade.list $+ [ $1 ] ] = $addtok(% [ $+ upgrade.list $+ [ $1 ] ] , $+ $2 $+ +1 ( $+ $3 $+ ),46)
}
alias return.upgradelist {
  return % [ $+ upgrade.list $+ [ $1 ] ] 
}
alias unset.upgradelist {
  unset % [ $+ upgrade.list $+ [ $1 ] ] 
}

alias shop.styles {
  if ($2 = list) {
    $display.private.message(2New style prices are in Black Orbs.)
    unset %shop.list | unset %upgrade.list
    ; get the list of the styles
    unset %shop.list | unset %styles.list
    set %styles.list $readini($dbfile(playerstyles.db), Styles, List)
    var %number.of.items $numtok(%styles.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %style.name $gettok(%styles.list, %value, 46)
      ; Does the player own this style? 
      set %player.style.level $readini($char($1), styles, %style.name)
      if ((%player.style.level = $null) || (%player.style.level <= 0)) {
        set %style.price $readini($dbfile(playerstyles.db), Costs, %style.name)
        %shop.list = $addtok(%shop.list, $+ %style.name $+  ( $+ %style.price $+ ),46)
        inc %value 1 
      }
      else {  
        inc %value 1
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Styles: %shop.list)
    }

    if (%shop.list = $null) { $display.private.message(4There are no more styles for you to purchase at this time.) | halt }

    unset %shop.list
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(playerstyles.db), costs, $3) = $null) { $display.private.message(4Error: Invalid style! Use !shop list styles to get a valid list) | halt }
    if ($readini($dbfile(playerstyles.db), costs, $3) = 0) { $display.private.message(4Error: You cannot purchase this style! Use !shop list styles to get a valid list) | halt }
    var %style.level $readini($char($1), styles, $3)
    ; do you have enough to buy it?
    var %player.blackorbs $readini($char($1), stuff, blackorbs) 
    var %total.price $readini($dbfile(playerstyles.db), costs, $3)
    if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this item!) | halt }
    dec %player.blackorbs %total.price
    writeini $char($1) stuff blackorbs %player.blackorbs
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) styles $3 1
    writeini $char($1) styles $3 $+ XP 0
    $display.private.message(3You spend %total.price black $iif(%total.price < 2, orb, orbs) to purchase $3 $+ ! $readini(translation.dat, system, BlackOrbsLeft))
    unset %styles.list | unset %style.name | unset %style.level | unset %style.price | unset %styles
    halt
  }
}

alias shop.mech {
  if ($2 = list) { 
    var %mech.cost $readini(system.dat, mech, MechPurchaseCost)
    if ($chr(41) isin %mech.cost) { 
      %mech.cost = $remove(%mech.cost, $chr(41)) 
      writeini system.dat mech MechPurchaseCost %mech.cost
    } 

    if (%mech.cost = $null) { var %mech.cost 1000 }
    $display.private.message(2A crazy-looking engineer with a wild beard and thick goggles is willing to sell you a basic mech he built for just %mech.cost allied notes.)
    halt
  }

  if ($2 = buy) { 
    var %mech.cost $readini(system.dat, mech, MechPurchaseCost)
    if ($chr(41) isin %mech.cost) { 
      %mech.cost = $remove(%mech.cost, $chr(41)) 
      writeini system.dat mech MechPurchaseCost %mech.cost
    } 

    if (%mech.cost = $null) { var %mech.cost 1000 }

    set %player.currency $readini($char($1), stuff, alliednotes)

    if (%player.currency = $null) { set %player.currency 0 }
    if (%player.currency < %mech.cost) {  $display.private.message(4You do not have enough Allied Notes to purchase a mech!) | unset %currency | unset %player.currency | unset %total.price |  halt }

    dec %player.currency %mech.cost
    writeini $char($1) stuff AlliedNotes %player.currency

    $mech.add($1)

    $display.private.message(2You hand %mech.cost allied notes to a crazy-looking engineer with a wild beard and thick goggles. "Heh. Heh. Right this way!" he tells you as he takes you out back to the scrapyard. "Here ya go! Ain't she a beauty?"  The mech looks rather basic and underwhelming. "Well off ya go now!")
    $display.private.message(2You now own a Basic Mech)

    unset %player.currency 

    halt
  }
}

alias shop.mechitems {
  var %conquest.status $readini(battlestats.dat, conquest, ConquestPreviousWinner)

  if ($2 = list) { 

    unset %mech.weapon.list | unset %mech.weapon.list2 | unset %mech.core.list | unset %mech.core.list2
    unset %count.weapon | unset %count.core | set %count.core 1 | set %count.weapon 1

    ; CHECKING MECH ITEMS
    var %value 1 | var %items.lines $lines($lstfile(items_mech.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_mech.lst)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)

      if ($readini($dbfile(items.db), %item.name, type) = mechCore) { 
        ; does the player already own this item? If so, we don't need to list it.
        set %player.amount $readini($char($1), item_amount, %item.name)

        if ((%player.amount = $null) || (%player.amount = 0)) {
          set %item_amount $readini($dbfile(items.db), %item.name, cost)

          if (%item_amount > 0) {
            var %item_to_add  $+ %item.name $+  $+ $chr(040) $+ %item_amount $+ $chr(041) 

            if ((%conquest.item = $null) || (%conquest.item = false)) {
              if (%count.core <= 14) { %mech.core.list = $addtok(%mech.core.list,%item_to_add,46) }
              if (%count.core > 14) { %mech.core.list2 = $addtok(%mech.core.list2,%item_to_add,46) }  
            }
            if ((%conquest.item = true) && (%conquest.status = players)) { 
              if (%count.core <= 14) { %mech.core.list = $addtok(%mech.core.list,%item_to_add,46) }
              if (%count.core > 14) { %mech.core.list2 = $addtok(%mech.core.list2,%item_to_add,46) }  
            }
          }

          inc %count.core 1
        }
      }

      if ($readini($dbfile(weapons.db), %item.name, cost) > 0) { 
        ; does the player already own this item? If so, we don't need to list it.
        set %player.amount $readini($char($1), item_amount, %item.name)
        if ((%player.amount = $null) || (%player.amount = 0)) {
          set %item_amount $readini($dbfile(weapons.db), %item.name, cost)
          var %item_to_add  $+ %item.name $+   $+ $chr(040) $+ %item_amount $+ $chr(041) 
          if (%count.weapon <= 14) { %mech.weapon.list = $addtok(%mech.weapon.list,%item_to_add,46) }
          if (%count.weapon > 14) { %mech.weapon.list2 = $addtok(%mech.weapon.list2,%item_to_add,46) }    
          inc %count.weapon
        }
      }

      unset %item.name | unset %item_amount | unset %player.amount | unset %conquest.item
      inc %value 1
    }

    unset %item.name | unset %item_amount | unset %count.weapon | unset %count.core
    unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %player.amount

    set %replacechar $chr(044) $chr(032)

    %mech.core.list = $replace(%mech.core.list, $chr(046), %replacechar)
    %mech.core.list2 = $replace(%mech.core.list2, $chr(046), %replacechar)
    %mech.weapon.list = $replace(%mech.weapon.list, $chr(046), %replacechar)
    %mech.weapon.list2 = $replace(%mech.weapon.list2, $chr(046), %replacechar)

    if ((%mech.weapon.list != $null) || (%mech.core.list != $null)) { 
      $display.private.message(2These items are paid for with Allied Notes:)

      if (%mech.weapon.list != $null) { $display.private.message(4Weapons:2 %mech.weapon.list) }
      if (%mech.weapon.list2 != $null) { $display.private.message(2 $+ %mech.weapon.list2) }

      if (%mech.core.list != $null) { $display.private.message(4Cores:2 %mech.core.list)  }
      if (%mech.core.list2 != $null) { $display.private.message(2 $+ %mech.core.list2) }
    }

    if ((%mech.weapon.list = $null) && (%mech.core.list = $null)) {  $display.private.message(4There are no more mech items available for purchase right now)  }

    unset %mech.core.list | unset %mech.weapon.list | unset %mech.core.list2 | unset %mech.weapon.list2
    unset %item.price
  }

  if (($2 = buy) || ($2 = purchase)) {

    if ($readini($dbfile(items.db), $3, type) = $null) { var %item.type weapon }
    else { var %item.type core }

    if (%item.type = core) { var %cost $readini($dbfile(items.db), $3, cost) }
    if (%item.type = weapon) { var %cost $readini($dbfile(weapons.db), $3, cost) }

    if ((%cost = $null) || (%cost <= 0)) { $display.private.message(4Error: Invalid item! Use !shop list mech items to get a valid list) | halt }

    ; do you already have it?
    if ($readini($char($1), item_amount, $3) > 0) { $display.private.message(4The crazy engineer with the wild beard and thick goggles looks at you and goes "You already have one of those! Why on earth would you need another one?" and refuses to sell it to you.) | halt }

    ; is it a conquest item and players are in control?
    var %conquest.item $readini($dbfile(items.db), $3, ConquestItem)
    if ((%conquest.item = true) && (%conquest.status != players)) { $display.private.message(4The crazy engineer turns to you and says2 "I'd love to sell that to ya but monster are in control of the region where I get mah parts. Ya'll will have to work harder to take control of the region via the conquest campaign!".) | halt }

    ; do you have enough to buy it?
    set %player.currency $readini($char($1), stuff, alliednotes)
    set %total.price $calc(%cost * $4)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough Allied Notes to purchase this item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) stuff AlliedNotes %player.currency

    ; Increase the item amount
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + $4) 

    $display.private.message(3The crazy engineer with the wild beard and thick goggles laughs and takes your your %total.price Allied Notes and gives you 1 $3 $+ !)
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }

}

alias shop.ignitions {
  if ($2 = list) {
    unset %shop.list |  var %value 1 | set %total.ignitions 0 | var %ignitions.lines $lines($lstfile(ignitions.lst))

    while (%value <= %ignitions.lines) {
      var %ig.name $read -l $+ %value $lstfile(ignitions.lst)
      var %ig.price $readini($dbfile(ignitions.db), %ig.name, cost)
      var %player.ignition.level $readini($char($1), ignitions, %ig.name)
      if (%player.ignition.level = $null) { var %player.ignition.level 0 }
      var %ig.price $calc((1 + %player.ignition.level) * %ig.price)

      if (%ig.price > 0) {  
        if (%player.ignition.level < 10) {
          inc %total.ignitions 1
          if (%total.ignitions < 20) { %shop.list = $addtok(%shop.list, $+ %ig.name $+ ( $+ %ig.price $+ ),46) }
          else { %shop.list2 = $addtok(%shop.list2, $+ %ig.name $+ ( $+ %ig.price $+ ),46) }
        }
      }
      unset %ig.name | unset %ig_amount
      inc %value 1 
    }


    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2Ignition prices are in Black Orbs.)
      $display.private.message(4Ignitions:2 %shop.list)
      set %replacechar $chr(044) $chr(032)
      %shop.list2 = $replace(%shop.list2, $chr(046), %replacechar)
      unset %replacechar
      if (%shop.list2 != $null) { 2 $+ %shop.list2 }
    }

    if (%shop.list = $null) { $display.private.message(4There are no more ignitions for you to purchase.) | halt }

    unset %shop.list | unset %shop.list2 | unset %player.ignition.level
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(ignitions.db), $3, cost) = $null) { $display.private.message(4Error: Invalid ignition! Use !shop list ignitions to get a valid list) | halt }
    if ($readini($dbfile(ignitions.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this ignition! Use !shop list ignitions to get a valid list) | halt }

    var %ignition.level $readini($char($1), ignitions, $3)
    if (%ignition.level >= 10) { $display.private.message(4Error: You cannot upgrade this ignition any further!) | halt }

    ; calculate the cost
    if (%ignition.level = $null) { var %ignition.level 0 }
    var %total.price $readini($dbfile(ignitions.db), $3, cost)
    var %total.price $calc((1 + %ignition.level) * %total.price)

    ; do you have enough to buy it?
    var %player.blackorbs $readini($char($1), stuff, blackorbs) 

    if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this ignition upgrade!) | halt }
    dec %player.blackorbs %total.price
    writeini $char($1) stuff blackorbs %player.blackorbs
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) ignitions $3 $calc(1 + %ignition.level)
    $display.private.message(3You spend %total.price black $iif(%total.price < 2, orb, orbs) to purchase +1 to $3 $+ ! $3 is now level $calc(%ignition.level + 1) $+ /10. $readini(translation.dat, system, BlackOrbsLeft))
    unset %ignitions.list | unset %ignition.name | unset %ignition.level | unset %ignition.price | unset %ignitions
    halt
  }
}

alias shop.portal {
  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount | unset %portals.bstmen | unset %portals.kindred | unset %portals.highkindredcrest | unset %portals.kindredcrest
    unset %portals.bstmen2 | unset %portals.kindred2 | unset %portals.kindrecrest2 | unset %portals.highkindredcrest2
    unset %portals.shadow | unset %portals.shadow2 | unset %portals.sacredkindredcrest

    var %value 1 | var %items.lines $lines($lstfile(items_portal.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_portal.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      if (%item.price > 0) {  

        if ($readini($dbfile(items.db), %item.name, currency) = BeastmenSeal) { 
          if ($numtok(%portals.bstmen, 46) >= 12) { %portals.bstmen2 = $addtok(%portals.bstmen2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          else { %portals.bstmen = $addtok(%portals.bstmen, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }

        if ($readini($dbfile(items.db), %item.name, currency) = KindredSeal) { 
          if ($numtok(%portals.kindred, 46) >= 12) { %portals.kindred2 = $addtok(%portals.kindred2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          else { %portals.kindred = $addtok(%portals.kindred, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }

        if ($readini($dbfile(items.db), %item.name, currency) = KindredCrest) { %portals.kindredcrest = $addtok(%portals.kindredcrest, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        if (($readini($dbfile(items.db), %item.name, currency) = HighKindredCrest) && ($readini($dbfile(items.db), %item.name, ShadowPortal) != true))  { %portals.highkindredcrest = $addtok(%portals.highkindredcrest, $+ %item.name $+ ( $+ %item.price $+ ),46) }

        if ($readini($dbfile(items.db), %item.name, ShadowPortal) = true) { 
          if ($numtok(%portals.shadow, 46) >= 12) { %portals.shadow2 = $addtok(%portals.shadow2, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          else { %portals.shadow = $addtok(%portals.shadow, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }

        if ($readini($dbfile(items.db), %item.name, currency) =  SacredKindredCrest) { %portals.sacredkindredcrest = $addtok(%portals.sacredkindredcrest, $+ %item.name $+ ( $+ %item.price $+ ),46) }

      }
      unset %item.name | unset %item_amount
      inc %value 1 
    }

    set %replacechar $chr(044) $chr(032)
    %portals.bstmen = $replace(%portals.bstmen, $chr(046), %replacechar)
    %portals.bstmen2 = $replace(%portals.bstmen2, $chr(046), %replacechar)
    %portals.kindred = $replace(%portals.kindred, $chr(046), %replacechar)
    %portals.kindred2 = $replace(%portals.kindred2, $chr(046), %replacechar)
    %portals.kindredcrest = $replace(%portals.kindredcrest, $chr(046), %replacechar)
    %portals.kindredcrest2 = $replace(%portals.kindredcrest2, $chr(046), %replacechar)
    %portals.highkindredcrest = $replace(%portals.highkindredcrest, $chr(046), %replacechar)
    %portals.highkindredcrest2 = $replace(%portals.highkindredcrest2, $chr(046), %replacechar)
    %portals.sacredkindredcrest = $replace(%portals.sacredkindredcrest, $chr(046), %replacechar)
    %portals.shadow = $replace(%portals.shadow, $chr(046), %replacechar)
    %portals.shadow2 = $replace(%portals.shadow2, $chr(046), %replacechar)
    unset %replacechar

    if (%portals.bstmen != $null) {  
      $display.private.message.delay.custom(2These portal items are paid for with 4BeastmenSeals2: %portals.bstmen, 1)  
      if (%portals.bstmen2 != $null) { $display.private.message.delay.custom(2 $+ %portals.bstmen2, 1)  }
    }

    if (%portals.kindred != $null) {  
      $display.private.message.delay.custom(2These portal items are paid for with 4KindredSeals2: %portals.kindred, 2)  
      if (%portals.kindred2 != $null) {  $display.private.message.delay.custom(2 $+ %portals.kindred2, 2)  }
    }

    if (%portals.kindredcrest != $null) {  
      $display.private.message.delay.custom(2These portal items are paid for with 4KindredCrests2: %portals.kindredcrest, 3)  
      if (%portals.kindredcrest2 != $null) {  $display.private.message.delay.custom(2 $+ %portals.kindredcrest2, 3)  }
    }

    if (%portals.highkindredcrest != $null) {  
      $display.private.message.delay.custom(2These portal items are paid for with 4HighKindredCrests2: %portals.highkindredcrest, 3) 
      if (%portals.highkindredcrest2 != $null) {  $display.private.message.delay.custom(2 $+ %portals.highkindredcrest2, 3)  }
    }

    if (%portals.shadow != $null) {  
      $display.private.message.delay.custom(2These shadow portal items are paid for with 4HighKindredCrests2 and are uncapped: %portals.shadow, 3) 
      if (%portals.highkindredcrest2 != $null) {  $display.private.message.delay.custom(2 $+ %portals.shadow2, 3)  }
    }

    if (%portals.sacredkindredcrest != $null) {  
      $display.private.message.delay.custom(2These portal items are paid for with 4SacredKindredCrests2: %portals.sacredkindredcrest, 3) 
      if (%portals.sacredkindredcrest2 != $null) {  $display.private.message.delay.custom(2 $+ %portals.sacredkindredcrest2, 3)  }
    }

    if ((((((%portals.kindred = $null) && (%portals.bstmen = $null) && (%portals.kindredcrest = $null) && (%portals.shadow = $null) && (%portals.sacredkindredcrest = $null) && (%portals.highkindredcrest = $null)))))) { $display.private.message(4There are no portal items available for purchase right now)  }

    unset %portals.bstmen | unset %portals.kindred | unset %portals.kindredcrest | unset %portals.highkindredcrest | unset %item.price
    unset %portals.bstmen2 | unset %portals.kindred2 | unset %portals.kindredcrest2 | unset %portals.highkindredcrest2
    unset %portals.shadow | unset %portals.shadow2 | unset %portals.sacredkindredcrest
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(items.db), $3, cost) = $null) {  $display.private.message(4Error: Invalid portal item! Use !shop list portal to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this portal item! Use !shop list portal to get a valid list) | halt }

    set %currency $readini($dbfile(items.db), $3, currency)  

    ; do you have enough to buy it?
    set %player.currency $readini($char($1), item_amount, %currency)
    set %total.price $calc($readini($dbfile(items.db), $3, cost) * $4)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough %currency $+ s to purchase $4 of this item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) item_amount %currency %player.currency
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + $4) 
    $display.private.message(3A strange merchant by the name of Shami takes %total.price %currency $+ s and trades it for $4 $3 $+ $iif($4 < 2 , ,s) $+ !  "Thank you for your patronage. (heh heh heh, sucker)")
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }
}

alias shop.dungeonkeys {

  ; Is the keymaster even there?
  if ($readini(shopnpcs.dat, NPCStatus, DungeonKeyMerchant) != true) { $display.private.message(2The keymaster is currently unavailable for you to purchase a dungeon key.) | halt }

  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount | unset %dungeonkeyss.bstmen | unset %dungeonkeyss.kindred | unset %dungeonkeyss.highkindredcrest | unset %dungeonkeyss.kindredcrest

    var %value 1 | var %items.lines $lines($lstfile(items_dungeonkeys.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_dungeonkeys.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)

      if ((%item.price > 0) && ($readini($char($1), item_amount, %item.name) !isnum)) {  
        if ($readini($dbfile(items.db), %item.name, currency) = BeastmenSeal) { %dungeonkeyss.bstmen = $addtok(%dungeonkeyss.bstmen, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        if ($readini($dbfile(items.db), %item.name, currency) = KindredSeal) { %dungeonkeyss.kindred = $addtok(%dungeonkeyss.kindred, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        if ($readini($dbfile(items.db), %item.name, currency) = KindredCrest) { %dungeonkeyss.kindredcrest = $addtok(%dungeonkeyss.kindredcrest, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        if ($readini($dbfile(items.db), %item.name, currency) = HighKindredCrest) { %dungeonkeyss.highkindredcrest = $addtok(%dungeonkeyss.highkindredcrest, $+ %item.name $+ ( $+ %item.price $+ ),46) }
      }
      unset %item.name | unset %item_amount
      inc %value 1 
    }

    set %replacechar $chr(044) $chr(032)
    %dungeonkeyss.bstmen = $replace(%dungeonkeyss.bstmen, $chr(046), %replacechar)
    %dungeonkeyss.kindred = $replace(%dungeonkeyss.kindred, $chr(046), %replacechar)
    %dungeonkeyss.kindredcrest = $replace(%dungeonkeyss.kindredcrest, $chr(046), %replacechar)
    %dungeonkeyss.highkindredcrest = $replace(%dungeonkeyss.highkindredcrest, $chr(046), %replacechar)
    unset %replacechar

    if (%dungeonkeyss.bstmen != $null) {  $display.private.message.delay.custom(2These dungeon keys are paid for with 4BeastmenSeals2: %dungeonkeyss.bstmen, 1)  }
    if (%dungeonkeyss.kindred != $null) {  $display.private.message.delay.custom(2These dungeon keys are paid for with 4KindredSeals2: %dungeonkeyss.kindred, 2)  }
    if (%dungeonkeyss.kindredcrest != $null) {  $display.private.message.delay.custom(2These dungeon keys are paid for with 4KindredCrests2: %dungeonkeyss.kindredcrest, 3)  }
    if (%dungeonkeyss.highkindredcrest != $null) {  $display.private.message.delay.custom(2These dungeon keys are paid for with 4HighKindredCrests2: %dungeonkeyss.highkindredcrest, 3)  }

    if ((((%dungeonkeyss.kindred = $null) && (%dungeonkeyss.bstmen = $null) && (%dungeonkeyss.kindredcrest = $null) && (%dungeonkeyss.highkindredcrest = $null)))) { $display.private.message(4There are no dungeon keys available for purchase right now)  }

    unset %dungeonkeyss.bstmen | unset %dungeonkeyss.kindred | unset %dungeonkeyss.kindredcrest | unset %dungeonkeyss.highkindredcrest | unset %item.price
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(items.db), $3, cost) = $null) {  $display.private.message(4Error: Invalid dungeon key! Use !shop list dungeonkeys to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this dungeon key! Use !shop list dungeonkeys to get a valid list) | halt }

    set %currency $readini($dbfile(items.db), $3, currency)  

    ; do you have enough to buy it?
    set %player.currency $readini($char($1), item_amount, %currency)
    set %total.price $calc($readini($dbfile(items.db), $3, cost) * $4)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough %currency $+ s to purchase $4 of this item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) item_amount %currency %player.currency
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + $4) 

    var %shopnpc.name $readini(shopnpcs.dat, NPCNames, DungeonKeyMerchant)
    if (%shopnpc.name = $null) { var %shopnpc.name $1 }

    $display.private.message(3A strange merchant by the name of %shopnpc.name takes %total.price %currency $+ s and trades it for $4 $3 $+ $iif($4 < 2 , ,s) $+ !  "Are you the Gatekeeper? ..Never mind. Here's your key.")
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }
}

alias shop.alchemy {
  var %conquest.status $readini(battlestats.dat, conquest, ConquestPreviousWinner)

  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount | unset %gems | unset %misc | unset %misc2 | unset %misc3
    unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %shop.list3
    set %misc.item.count 1

    ; CHECKING MISC/ALCHEMY ITEMS
    var %value 1 | var %items.lines $lines($lstfile(items_misc.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_misc.lst)

      set %item_amount $readini($dbfile(items.db), %item.name, cost)
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)

        if ($readini($dbfile(items.db), %item.name, currency) = AlliedNotes) { 
          var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 

          if ((%conquest.item = $null) || (%conquest.item = false)) {
            if (%misc.item.count <= 20) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
            if ((%misc.item.count > 20) && (%misc.item.count < 40)) {  %shop.list2 = $addtok(%shop.list2,%item_to_add,46) }
            if (%misc.item.count > 40) { %shop.list3 = $addtok(%shop.list3,%item_to_add,46) }
          }

          if ((%conquest.item = true) && (%conquest.status = players)) { 
            if (%misc.item.count <= 20) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
            if ((%misc.item.count > 20) && (%misc.item.count < 40)) {  %shop.list2 = $addtok(%shop.list2,%item_to_add,46) }
            if (%misc.item.count > 40) { %shop.list3 = $addtok(%shop.list3,%item_to_add,46) }
          }

          inc %misc.item.count 1 
        }
      }
      inc %value 1 | unset %conquest.item
    }

    ; CHECKING SEAL ITEMS
    var %value 1 | var %items.lines $lines($lstfile(items_seals.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_seals.lst)

      set %item_amount $readini($dbfile(items.db), %item.name, cost)
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)

        if ($readini($dbfile(items.db), %item.name, currency) = AlliedNotes) { 
          var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 

          if ((%conquest.item = $null) || (%conquest.item = false)) {
            if (%misc.item.count <= 20) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
            if ((%misc.item.count > 20) && (%misc.item.count < 40)) {  %shop.list2 = $addtok(%shop.list2,%item_to_add,46) }
            if (%misc.item.count > 40) { %shop.list3 = $addtok(%shop.list3,%item_to_add,46) }
          }

          if ((%conquest.item = true) && (%conquest.status = players)) { 
            if (%misc.item.count <= 20) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
            if ((%misc.item.count > 20) && (%misc.item.count < 40)) {  %shop.list2 = $addtok(%shop.list2,%item_to_add,46) }
            if (%misc.item.count > 40) { %shop.list3 = $addtok(%shop.list3,%item_to_add,46) }
          }

          inc %misc.item.count 1 
        }
      }
      inc %value 1 | unset %conquest.item
    }

    if (%shop.list != $null) {  $shop.cleanlist | set %misc %shop.list  | set %misc2 %shop.list2  | set %misc3 %shop.list3 }

    unset %shop.list | unset %item.name | unset %item_amount | unset %misc.item.count
    unset %item.name | unset %item_amount | unset %number.of.items | unset %value


    ; CHECKING GEMS
    var %value 1 | var %items.lines $lines($lstfile(items_gems.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_gems.lst)
      set %item_amount $readini($dbfile(items.db), %item.name, cost)

      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)

        if ($readini($dbfile(items.db), %item.name, currency) = AlliedNotes) { 
          var %item_to_add 7 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 

          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list,%item_to_add,46) } 
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
        }

      }
      inc %value 1 | unset %conquest.item
    }

    unset %item.name | unset %item_amount | unset %number.of.items | unset %value

    if (%shop.list != $null) { $shop.cleanlist | set %gems %shop.list  }

    if ((%misc != $null) || (%gems != $null)) { 
      $display.private.message(2These items are paid for with Allied Notes:)

      if (%misc != $null) { $display.private.message.delay.custom(5 $+ %misc,2) }
      if (%misc2 != $null) { $display.private.message.delay.custom(5 $+ %misc2,3) }
      if (%misc3 != $null) { $display.private.message.delay.custom(5 $+ %misc3,3) }
      if (%gems != $null) { $display.private.message.delay.custom(%gems,4) }
    }

    if ((%misc = $null) && (%gems = $null)) {  $display.private.message.delay.custom(4There are no items available for purchase right now, 2)  }

    unset %shop.list | unset %misc | unset %gems | unset %misc2 | unset %misc3
    unset %shop.list2 | unset %shop.list3 

  }

  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(items.db), $3, cost) = $null) { $display.private.message(4Error: Invalid item! Use !shop list alchemy to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this item! Use !shop list alchemy to get a valid list) | halt }

    if ($readini($dbfile(items.db), $3, type) = mechcore) { $display.private.message(4You cannot buy this item in this shop.) | halt }

    if ($readini($char($1), status, alliednotes.lock) = true) { $display.private.message(4You are in the middle of an auction and cannot spend or exchange any allied notes until the auction is over.) | halt }

    ; do you have enough to buy it?

    if ($readini($dbfile(items.db), $3, currency) != AlliedNotes) {  $display.private.message(4You cannot buy this item in this shop.) | halt }

    var %conquest.item $readini($dbfile(items.db), $3, ConquestItem)
    if ((%conquest.item = true) && (%conquest.status != players)) { $display.private.message(4You cannot buy this item because monsters are in control of the conquest region it comes from! Players must be in control of the conquest in order to purchase this.) | halt }

    var %shopnpc.name $readini($dbfile(items.db), $3, shopNPC)
    if ((%shopnpc.name != $null) && ($shopnpc.present.check(%shopnpc.name) != true)) {  $display.private.message($readini(translation.dat, errors, ShopNPCNotAvailable)) | halt }


    set %player.currency $readini($char($1), stuff, alliednotes)
    set %total.price $calc($readini($dbfile(items.db), $3, cost) * $4)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough Allied Notes to purchase $4 of this item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) stuff AlliedNotes %player.currency
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + $4) 
    $display.private.message(3A merchant of the Allied Forces takes your %total.price Allied Notes and gives you $4 $3 $+ $iif($4 < 2, , s) $+ !)
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }
}

alias shop.tradingcards {
  var %conquest.status $readini(battlestats.dat, conquest, ConquestPreviousWinner)

  ; Is the shield shop merchant even there?
  if ($readini(shopnpcs.dat, NPCStatus, Cardian) != true) { $display.private.message(2The cardian merchant is currently unavailable for you to purchase any trading cards.) | halt }



  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount | unset %gems | unset %card | unset %card2 | unset %card3
    unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %shop.list3
    set %card.item.count 1

    ; CHECKING TRADING CARDS
    var %value 1 | var %items.lines $lines($lstfile(items_misc.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_tradingcards.lst)

      set %item_amount $readini($dbfile(items.db), %item.name, cost)
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)

        if ($readini($dbfile(items.db), %item.name, currency) = AlliedNotes) { 
          var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 

          if ((%conquest.item = $null) || (%conquest.item = false)) {
            if (%card.item.count <= 20) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
            if ((%card.item.count > 20) && (%card.item.count < 40)) {  %shop.list2 = $addtok(%shop.list2,%item_to_add,46) }
            if (%card.item.count > 40) { %shop.list3 = $addtok(%shop.list3,%item_to_add,46) }
          }

          if ((%conquest.item = true) && (%conquest.status = players)) { 
            if (%card.item.count <= 20) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
            if ((%card.item.count > 20) && (%card.item.count < 40)) {  %shop.list2 = $addtok(%shop.list2,%item_to_add,46) }
            if (%card.item.count > 40) { %shop.list3 = $addtok(%shop.list3,%item_to_add,46) }
          }

          inc %card.item.count 1 
        }
      }
      inc %value 1 | unset %conquest.item
    }

    if (%shop.list != $null) {  $shop.cleanlist | set %card %shop.list  | set %card2 %shop.list2  | set %card3 %shop.list3 }

    unset %shop.list | unset %item.name | unset %item_amount | unset %card.item.count
    unset %item.name | unset %item_amount | unset %number.of.items | unset %value


    ; CHECKING BOOSTER SETS
    var %value 1 | var %items.lines $lines($lstfile(items_tradingcardboosters.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_tradingcardboosters.lst)
      set %item_amount $readini($dbfile(items.db), %item.name, cost)

      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)

        if ($readini($dbfile(items.db), %item.name, currency) = AlliedNotes) { 
          var %item_to_add 7 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 

          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list,%item_to_add,46) } 
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list,%item_to_add,46) }
        }

      }
      inc %value 1 | unset %conquest.item
    }

    unset %item.name | unset %item_amount | unset %number.of.items | unset %value

    if (%shop.list != $null) { $shop.cleanlist | set %boosters %shop.list  }




    if ((%card != $null) || (%boosters != $null)) { 
      $display.private.message(2These items are paid for with Allied Notes:)

      if (%card != $null) { $display.private.message.delay.custom(5 $+ %card,2) }
      if (%card2 != $null) { $display.private.message.delay.custom(5 $+ %card2,3) }
      if (%card3 != $null) { $display.private.message.delay.custom(5 $+ %card3,3) }
      if (%boosters != $null) { $display.private.message.delay.custom(%boosters,4) }
    }

    if ((%card = $null) && (%boosters = $null)) {  $display.private.message.delay.custom(4There are no items available for purchase right now, 2)  }

    unset %shop.list | unset %card | unset %boosters | unset %card2 | unset %card3
    unset %shop.list2 | unset %shop.list3 

  }

  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(items.db), $3, cost) = $null) { $display.private.message(4Error: Invalid item! Use !shop list tradingcards to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this item! Use !shop list tradingcards to get a valid list) | halt }

    if ($readini($char($1), status, alliednotes.lock) = true) { $display.private.message(4You are in the middle of an auction and cannot spend or exchange any allied notes until the auction is over.) | halt }

    ; do you have enough to buy it?

    if ($readini($dbfile(items.db), $3, currency) != AlliedNotes) {  $display.private.message(4You cannot buy this item in this shop.) | halt }

    var %conquest.item $readini($dbfile(items.db), $3, ConquestItem)
    if ((%conquest.item = true) && (%conquest.status != players)) { $display.private.message(4You cannot buy this item because monsters are in control of the conquest region it comes from! Players must be in control of the conquest in order to purchase this.) | halt }

    var %shopnpc.name $readini($dbfile(items.db), $3, shopNPC)
    if ((%shopnpc.name != $null) && ($shopnpc.present.check(%shopnpc.name) != true)) {  $display.private.message($readini(translation.dat, errors, ShopNPCNotAvailable)) | halt }


    set %player.currency $readini($char($1), stuff, alliednotes)
    set %total.price $calc($readini($dbfile(items.db), $3, cost) * $4)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough Allied Notes to purchase $4 of this item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) stuff AlliedNotes %player.currency
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + $4) 
    $display.private.message(3The cardian takes your %total.price Allied Notes and gives you $4 $3 $+ $iif($4 < 2, , s) $+ !)
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }
}

alias shop.orbs {
  if ($2 = list) { $display.private.message(2You can exchange 1 black orb for 500 $readini(system.dat, system, currency) $+ .  To do so use the command: !shop buy orbs)  }

  if (($2 = buy) || ($2 = purchase)) {
    ; do you have enough to buy it?
    %total.price = $calc($3 * 1)

    var %player.blackorbs $readini($char($1), stuff, blackorbs)
    if (%player.blackorbs < %total.price) {  $display.private.message(4You do not have enough black orbs to do the exchange!) | halt }

    ; if so, increase the amount
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %orb.increase.amount $calc(500 * $3)
    inc %player.redorbs %orb.increase.amount
    dec %player.blackorbs %total.price
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) stuff redorbs %player.redorbs
    writeini $char($1) stuff blackorbs %player.blackorbs

    $display.private.message(3You spend %total.price black $iif(%total.price < 2, orb, orbs) for  $+ %orb.increase.amount $readini(system.dat, system, currency) $+ ! $readini(translation.dat, system, BlackOrbsLeft))
    halt
  }
}

alias shop.potioneffects {
  if ($readini(shopnpcs.dat, NPCStatus, PotionWitch) != true) {
    var %shopnpc.name $readini(shopnpcs.dat, NPCNames, PotionWitch)
    if (%shopnpc.name = $null) { var %shopnpc.name Syrup the Potion Witch }

    $display.private.message(4 $+ %shopnpc.name is not at the Allied Forces HQ and this shop cannot be accessed.)
    halt 
  }

  if ($2 = list) { 
    $display.private.message(2This shop is used to purchase special Potion Effects that will take effect during or after you next battle. You can only purchase one at a time.)
    $display.private.message(12OrbBonus 2potion effect: $+ $iif($item.amount($1, BeetleShell) >= 2, 3, 4) 2 Beetle Shells2 + $+ $iif($item.amount($1, BeetleJaw) >= 2, 3, 4) 2 Beetle Jaws2 + $+ $iif($item.amount($1, Milk) >= 1, 3, 4) 1 Milk)
    $display.private.message(12DoubleLife 2potion effect: $+ $iif($item.amount($1, Rose) >= 2, 3, 4) 2 Roses2 + $+ $iif($item.amount($1, Tulip) >= 1, 3, 4) 1 Tulip2 + $+ $iif($item.amount($1, Milk) >= 2, 3, 4) 2 Milk)    
    $display.private.message(12BonusSpoils 2potion effect: $+ $iif($item.amount($1, BlueKinstone) >= 2, 3, 4) 2 Blue Kinstones2 + $+ $iif($item.amount($1, GreenKinstone) >= 2, 3, 4) 2 Green Kinstones2 + $+ $iif($item.amount($1, Milk) >= 1, 3, 4) 1 Milk)    
    $display.private.message(12AugmentBonus 2potion effect: $+ $iif($item.amount($1, RedeadAsh) >= 2, 3, 4) 2 Redead Ashes2 + $+ $iif($item.amount($1, GibdoBandage) >= 2, 3, 4) 2 Gibdo Bandages2 + $+ $iif($item.amount($1, Milk) >= 1, 3, 4) 1 Milk)    
    $display.private.message(12UtsusemiBonus 2potion effect: $+ $iif($item.amount($1, GremlinSkin) >= 2, 3, 4) 2 Gremlin Skins2 + $+ $iif($item.amount($1, Milk) >= 1, 3, 4) 1 Milk)    
    $display.private.message(12Dragonskin 2potion effect: $+ $iif($item.amount($1, DragonFang) >= 1, 3, 4) 1 Dragon Fang2 + $+ $iif($item.amount($1, DragonEgg) >= 1, 3, 4) 1 Dragon Egg2 + $iif($item.amount($1, Milk) >= 1, 3, 4) 1 Milk)    

    ; to do: add a Kill Coin Bonus potion effect

    $display.private.message(2To purchase use !shop buy potioneffect [potion effect name]  such as !shop buy potioneffect OrbBonus)
  }

  if (($2 = buy) || ($2 = purchase)) {

    var %shopnpc.name $readini(shopnpcs.dat, NPCNames, PotionWitch)
    if (%shopnpc.name = $null) { var %shopnpc.name Syrup the Potion Witch }

    if ($readini($char($1), status, PotionEffect) != none) { $display.private.message(4Error: You are already under the12 $readini($char($1), status, PotionEffect) 4Potion Effect and cannot purchase another at this time)  | halt }

    if ($3 = OrbBonus) { 

      var %beetle.shells.needed 2
      var %beetle.jaws.needed 2
      var %milk.needed 1

      dec %beetle.shells.needed $item.amount($1, BeetleShell)
      dec %beetle.jaws.needed $item.amount($1, BeetleJaw)
      dec %milk.needed $item.amount($1, Milk)

      if (((%beetle.shells.needed > 0) || (%beetle.jaws.needed > 0) || (%milk.needed > 0))) { 
        $display.private.message(4You do not have enough of the required materials for this potion effect.) 
        if (%beetle.shells.needed < 0) { var %beetle.shells.needed 0 }
        if (%beetle.jaws.needed < 0) { var %beetle.shells.needed 0 }
        if (%milk.needed < 0) { var %milk.needed 0 }
        $display.private.message(4You still need the following:12 %beetle.shells.needed $+ 4x Beetle Shells -12 %beetle.jaws.needed $+ 4x Beetle Jaws -12 %milk.needed $+ x 4Milk)
        halt
      }

      writeini $char($1) item_amount BeetleShell $calc($item.amount($1, BeetleShell) - 2)
      writeini $char($1) item_amount BeetleJaw $calc($item.amount($1, BeetleJaw) - 2)
      writeini $char($1) item_amount Milk $calc($item.amount($1, Milk) - 1)

      writeini $char($1) status PotionEffect Orb Bonus
      $display.private.message(12 $+ %shopnpc.name takes the beetle parts and milk and creates a nasty-smelling red potion. Upon drinking it, you feel as though your next battle will result in more orbs.) 

      halt
    }

    if ($3 = DoubleLife) { 

      var %rose.needed 2
      var %tulip.needed 1
      var %milk.needed 2

      dec %rose.needed $item.amount($1, Rose)
      dec %tulip.needed $item.amount($1, Tulip)
      dec %milk.needed $item.amount($1, Milk)

      if (((%rose.needed > 0) || (%tulip.needed > 0) || (%milk.needed > 0))) { 
        $display.private.message(4You do not have enough of the required materials for this potion effect.) 
        if (%rose.needed < 0) { var %rose.needed 0 }
        if (%tulip.needed < 0) { var %tulip.needed 0 }
        if (%milk.needed < 0) { var %milk.needed 0 }
        $display.private.message(4You still need the following:12 %rose.needed $+ 4x Rose $+ $iif(%rose.needed > 1 || %rose.needed = 0, s) -12 %tulip.needed $+ 4x Tulip -12 %milk.needed $+ x 4Milk)
        halt
      }

      writeini $char($1) item_amount Rose $calc($readini($char($1), item_amount, rose) - 2)
      writeini $char($1) item_amount Tulip $calc($readini($char($1), item_amount, tulip) - 1)
      writeini $char($1) item_amount Milk $calc($item.amount($1, Milk) - 2)

      writeini $char($1) status PotionEffect Double Life
      $display.private.message(12 $+ %shopnpc.name takes the flowers and milk and creates a floral smelling bubbling potion. Upon drinking it, you feel as though your life in the next battle will be double.) 

      halt
    }

    if ($3 = BonusSpoils) { 

      var %bluekinstone.needed 2
      var %greenkinstone.needed 2
      var %milk.needed 1

      dec %bluekinstone.needed $item.amount($1, BlueKinstone) 
      dec %greenkinstone.needed $item.amount($1, GreenKinstone)
      dec %milk.needed $item.amount($1, Milk)  

      if (((%bluekinstone.needed > 0) || (%greenkinstone.needed > 0) || (%milk.needed > 0))) { 
        $display.private.message(4You do not have enough of the required materials for this potion effect.) 
        if (%bluekinstone.needed < 0) { var %bluekinstone.needed 0 }
        if (%greenkinstone.needed < 0) { var %greenkinstone.needed 0 }
        if (%milk.needed < 0) { var %milk.needed 0 }
        $display.private.message(4You still need the following:12 %bluekinstone.needed $+ 4x blue kinstone $+ $iif(%bluekinstone.needed > 1 || %bluekinstone.needed = 0, s) -12 %greenkinstone.needed $+ 4x green kinstone $+ $iif(%bluekinstone.needed > 1 || %greenkinstone.needed = 0, s) -12 %milk.needed $+ x 4Milk)
        halt
      }

      writeini $char($1) item_amount bluekinstone $calc($item.amount($1, BlueKinstone) - 2)
      writeini $char($1) item_amount greenkinstone $calc($item.amount($1, GreenKinstone) - 2)
      writeini $char($1) item_amount Milk $calc($item.amount($1, Milk) - 1)

      writeini $char($1) status PotionEffect Bonus Spoils
      $display.private.message(12 $+ %shopnpc.name takes the kinstones and milk and gives a loud chuckle as she fuses the kinstone pieces together and drops them into the couldron. After a moment she pours the milk in and creates a glowing potion. Upon drinking it, you feel as though your luck with spoils has been enhanced) 

      halt
    }

    if ($3 = AugmentBonus) { 

      var %redeadashes.needed 2
      var %gibdobandages.needed 2
      var %milk.needed 1

      dec %redeadashes.needed $item.amount($1, RedeadAsh)
      dec %gibdobandages.needed $item.amount($1, GibdoBandage)
      dec %milk.needed $item.amount($1, Milk)  

      if (((%redeadashes.needed > 0) || (%gibdobandages.needed > 0) || (%milk.needed > 0))) { 
        $display.private.message(4You do not have enough of the required materials for this potion effect.) 
        if (%redeadashes.needed < 0) { var %redeadashes.needed 0 }
        if (%gibdobandages.needed < 0) { var %gibdobandages.needed 0 }
        if (%milk.needed < 0) { var %milk.needed 0 }
        $display.private.message(4You still need the following:12 %redeadashes.needed $+ 4x redead ash $+ $iif(%redeadashes.needed > 1 || %redeadashes.needed = 0, es) -12 %gibdobandages.needed $+ 4x gibdo bandage $+ $iif(%gibdobandages.needed > 1 || %gibdobandages.needed = 0, s) -12 %milk.needed $+ 4x Milk)
        halt
      }

      writeini $char($1) item_amount redeadbandage $calc($item.amount($1, RedeadAsh) - 2)
      writeini $char($1) item_amount gibdobandage $calc($item.amount($1, GibdoBandage) - 2)
      writeini $char($1) item_amount Milk $calc($item.amount($1, Milk) - 1)

      writeini $char($1) status PotionEffect Augment Bonus
      $display.private.message(12 $+ %shopnpc.name takes the bandages, ashes and milk and gives a loud chuckle as she drops them into the couldron. After a moment she pours the milk in and creates a rotten-smelling potion. Upon drinking it, you feel as though your augments have been enhanced) 

      halt
    }

    if ($3 = UtsusemiBonus) { 

      var %gremlinskins.needed 2
      var %milk.needed 1

      dec %gremlinskins.needed $item.amount($1, gremlinskin)
      dec %milk.needed $item.amount($1, Milk)  

      if ((%gremlinskins.needed > 0) || (%milk.needed > 0)) { 
        $display.private.message(4You do not have enough of the required materials for this potion effect.) 
        if (%gremlinskins.needed < 0) { var %gremlinskins.needed 0 }
        if (%milk.needed < 0) { var %milk.needed 0 }
        $display.private.message(4You still need the following:12 %gremlinskins.needed $+ 4x gremlin skin $+ $iif(%gremlinskins.needed > 1 || %gremlinskins.needed = 0, s) -12 %milk.needed $+ 4x Milk)
        halt
      }

      writeini $char($1) item_amount GremlinSkin $calc($item.amount($1, gremlinskin) - 2)
      writeini $char($1) item_amount Milk $calc($item.amount($1, Milk) - 1)

      writeini $char($1) status PotionEffect Utsusemi Bonus
      $display.private.message(12 $+ %shopnpc.name takes the gremlin skins and milk and gives a loud chuckle as she drops them into the couldron. After a quick stir she hands you a very nasty looking green potion. Upon drinking it, you feel as though your utsusemi shadows will be enhanced) 

      halt
    }

    if ($3 = Dragonskin) { 

      var %dragonegg.needed 1
      var %dragonfang.needed 1
      var %milk.needed 1

      dec %dragonegg.needed $item.amount($1, DragonEgg)
      dec %dragonfang.needed $item.amount($1, Dragonfang)
      dec %milk.needed $item.amount($1, Milk)  

      if (((%dragonegg.needed > 0) || (%dragonfang.needed > 0) || (%milk.needed > 0))) { 
        $display.private.message(4You do not have enough of the required materials for this potion effect.) 
        if (%dragonegg.needed < 0) { var %dragonegg.needed 0 }
        if (%dragonfang.needed < 0) { var %dragonfang.needed 0 }
        if (%milk.needed < 0) { var %milk.needed 0 }
        $display.private.message(4You still need the following:12 %dragonegg.needed $+ 4x dragon egg $+ $iif(%dragonegg.needed > 1 || %dragonegg.needed = 0, es) -12 %dragonfang.needed $+ 4x dragon fang $+ $iif(%dragonfang.needed > 1 || %dragonfang.needed = 0, s) -12 %milk.needed $+ 4x Milk)
        halt
      }

      writeini $char($1) item_amount dragonfang $calc($item.amount($1, DragonFang) - 1)
      writeini $char($1) item_amount dragonegg $calc($item.amount($1, DragonEgg) - 1)
      writeini $char($1) item_amount Milk $calc($item.amount($1, Milk) - 1)

      writeini $char($1) status PotionEffect DragonSkin
      $display.private.message(12 $+ %shopnpc.name takes the dragon parts and milk and gives a loud chuckle as she drops them into the couldron. After a moment she pours the milk in and creates a bubbling green potion. Upon drinking it, you feel as though your skin has become hard as scales) 

      halt
    }

  }

}

alias shop.trusts {
  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount

    var %value 1 | var %items.lines $lines($lstfile(items_trust.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_trust.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)

      if ((%item.price > 0) && ($item.amount($1, %item.name) <= 0)) {
        if (%item.price <= $readini($char($1), stuff, loginpoints)) {  %trusts.list1 = $addtok(%trusts.list1, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        else { %trusts.list1 = $addtok(%trusts.list1,5 $+ %item.name $+ ( $+ %item.price $+ ),46) }
      }
      unset %item.name | unset %item_amount
      inc %value 1 
    }

    set %replacechar $chr(044) $chr(032)
    %trusts.list1 = $replace(%trusts.list1, $chr(046), %replacechar)
    unset %replacechar

    if (%trusts.list1 != $null) {  
      $display.private.message.delay.custom(2NPC Trust items are paid for with 4Login Points,1)
      $display.private.message.delay.custom(2 $+ %trusts.list1, 1)
    }

    if (%trusts.list1 = $null) { $display.private.message(4There are no NPC Trust items available for purchase right now)  }

    unset %trusts.list1 | unset %item.price | unset %item.name
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini($dbfile(items.db), $3, cost) = $null) {  $display.private.message(4Error: Invalid NPC Trust item! Use !shop list trusts to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this NPC Trust item! Use !shop list trusts to get a valid list) | halt }

    ; do you have enough to buy it?
    set %player.currency $readini($char($1), stuff, LoginPoints)
    set %total.price $calc($readini($dbfile(items.db), $3, cost) * 1)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough Login Points to purchase this NPC Trust item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) stuff LoginPoints %player.currency
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + 1) 
    $display.private.message(3A bright white light shines down upon you and when it clears you find you are holding the NPC Trust item: $3 $+ ! Use it to build a strong friendship with $readini($dbfile(items.db), $3, NPC) $+ !)

    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }
}

alias shop.killcoins {
  ; !shop killcoins list
  ; !shop buy killcoins #

  if ($2 = list) {
    $display.private.message(2This shop is used to exchange red orbs into kill coins.  For 100000 red orbs you can buy 1 killcoin.)
    halt
  }

  if ($2 = buy) {

    ; do you have enough to buy it?
    %total.price = $calc($3 * 100000)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    if (%player.redorbs < %total.price) {  $display.private.message(4You do not have enough red orbs to do the exchange!) | halt }

    ; if so, increase the amount
    var %player.coins $round($readini($char($1), stuff, killcoins),0)
    inc %player.coins $3

    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    writeini $char($1) stuff killcoins %player.coins

    $display.private.message(3You spend %total.price red $iif(%total.price < 2, orb, orbs) for  $+ $3 killcoins ! $readini(translation.dat, system, RedOrbsLeft))
    halt
  }

}

alias shop.alliedforces {
  ; !shop alliedforces list
  ; !shop alliedforces buy dragonkiller/bombing

  if ($2 = list) { 
    $display.private.message(2This shop is used to purchase special services from the Allied Forces that will help you defeat the Dragons hiding in their lairs! You can only purchase one at a time.)
    $display.private.message(12DragonKiller 2 - 5000 Allied Notes - This will spawn a Dragon Killer NPC to help fight the dragon)
    $display.private.message(12Bombing 2 - 5000 Allied Notes - This will drop a bomb on the dragon's lair which will weaken the dragon within. You can only purchase one at a time.)
  }

  if ($2 = buy) { 
    var %player.currency $readini($char($1), stuff, alliednotes)

    if ($3 = DragonKiller) { var %shop.cost 5000
      if ($readini(battlestats.dat, AlliedForces, DragonKiller) = true) { $display.private.message(4This service has already been purchased and will be active during the next successful dragon hunt) | halt }

      if (%player.currency = $null) { set %player.currency 0 }
      if (%player.currency < %shop.cost) {  $display.private.message(4You do not have enough Allied Notes to purchase this service) | unset %currency | unset %player.currency | unset %total.price |  halt }

      dec %player.currency %shop.cost
      writeini $char($1) stuff AlliedNotes %player.currency

      writeini battlestats.dat AlliedForces DragonKiller true
      $display.private.message(2The Allied Forces begin work on the new 12Dragon Killer2 to be ready for your next dragon hunt battle!)
    }

    if ($3 = bombing) {  var %shop.cost 5000
      if ($readini(battlestats.dat, AlliedForces, DragonBombing) = true) { $display.private.message(4This service has already been purchased and will be active during the next successful dragon hunt) | halt }

      if (%player.currency = $null) { set %player.currency 0 }
      if (%player.currency < %shop.cost) {  $display.private.message(4You do not have enough Allied Notes to purchase this service) | unset %currency | unset %player.currency | unset %total.price |  halt }

      dec %player.currency %shop.cost
      writeini $char($1) stuff AlliedNotes %player.currency

      writeini battlestats.dat AlliedForces DragonBombing true
      $display.private.message(2The Allied Forces begin work on the new 12Dragon Buster Bomb2 to be ready for your next dragon hunt battle!)
    }
  }
}

alias shop.halloween {
  if ($left($adate, 2) != 10) { $display.private.message(4You can only use this shop in October) | halt }

  if ($2 = list) { 
    unset %shop.list | unset %item.name | unset %item_amount | unset %halloween.items.list | unset %halloween.armor.list

    var %value 1 | var %items.lines $lines($lstfile(items_halloween.lst))

    while (%value <= %items.lines) {
      var %item.name $read -l $+ %value $lstfile(items_halloween.lst)
      var %item.price $readini($dbfile(items.db), %item.name, cost)
      var %item.type $readini($dbfile(items.db), %item.name, type)

      if ((%item.price > 0) && ($item.amount($1, %item.name) <= 0)) {
        if (%item.price <= $readini($char($1), item_amount, CandyCorn)) {  
          if (%item.type = armor) { %halloween.armor.list = $addtok(%halloween.armor.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          else { %halloween.items.list = $addtok(%halloween.items.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }

        }
        else { 
          if (%item.type = armor) { %halloween.armor.list = $addtok(%halloween.armor.list,5 $+ %item.name $+ ( $+ %item.price $+ ),46) }
          else { %halloween.items.list = $addtok(%halloween.items.list,5 $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }
      }

      inc %value 1 
    }

    set %replacechar $chr(044) $chr(032)
    %halloween.armor.list = $replace(%halloween.armor.list, $chr(046), %replacechar)
    %halloween.items.list = $replace(%halloween.items.list, $chr(046), %replacechar)
    unset %replacechar

    $display.private.message.delay.custom(2These items and armor pieces are paid for with 4Candy Corn,1)
    if (%halloween.armor.list != $null) { $display.private.message.delay.custom(4Armor:2 %halloween.armor.list, 1) }
    if (%halloween.items.list != $null) { $display.private.message.delay.custom(4Items:2 %halloween.items.list, 1) }

    if ((%halloween.armor.list = $null) && (%halloween.items.list = $null)) { $display.private.message(4There are no Halloween store items available for purchase right now)  }

    unset %halloween.armor.list | unset %halloween.items.list | unset %item.price | unset %item.name
  }

  if (($2 = buy) || ($2 = purchase)) {

    if ($readini($dbfile(items.db), $3, cost) = $null) {  $display.private.message(4Error: Invalid Halloween Shop item! Use !shop list halloweens to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this item! Use !shop list halloween to get a valid list) | halt }
    if ($readini($dbfile(items.db), $3, currency) != candycorn) {  $display.private.message(4Error: Invalid Halloween Shop item! Use !shop list halloweens to get a valid list) | halt }

    ; do you have enough to buy it?
    set %player.currency $readini($char($1), item_amount, CandyCorn)
    set %total.price $calc($readini($dbfile(items.db), $3, cost) * 1)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough Candy Corn to purchase this Halloween shop item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price

    writeini $char($1) item_amount CandyCorn %player.currency
    writeini $char($1) item_amount $3 $calc($item.amount($1, $3) + 1) 
    $display.private.message(3You deposit %total.price $iif(%total.price > 1, pieces, piece) of candy corn into a glowing orange bucket and find yourself rewarded with $4  $+ $3 $+ !)

    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt

  }

}

alias inc.shoplevel {
  ; At this point, the minimum shop level has already been checked.
  ; Checking it again might cause just-purchased upgrades to increase the shop level too much.
  var %shop.level $return.shoplevel($1, $true)

  if (($2 = $null) || ($2 <= 0)) { var %amount.to.increase .1 }
  if (($2 != $null) && ($2 > 0)) { var %amount.to.increase $calc(.1 * $2) }
  inc %shop.level %amount.to.increase 
  var %max.shop.level $readini(system.dat, system, maxshoplevel)
  if (%max.shop.level = $null) { var %max.shop.level 25 }

  if (%shop.level >= %max.shop.level) { writeini $char($1) stuff shoplevel %max.shop.level |  $display.private.message(2Your Shop Level has been capped at %max.shop.level)  }
  else { 
    writeini $char($1) stuff shoplevel %shop.level  
    $display.private.message(2Your Shop Level has been increased to %shop.level)
  }
  $achievement_check($1, Don'tYouHaveaHome)
  unset %shop.level

}

alias shop.cleanlist {
  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %shop.list = $replace(%shop.list, $chr(046), %replacechar)
  %shop.list2 = $replace(%shop.list2, $chr(046), %replacechar)
  %shop.list3 = $replace(%shop.list3, $chr(046), %replacechar)
  unset %replacechar
}

alias inc.redorbsspent {  
  var %orbs.spent $readini($char($1), stuff, RedOrbsSpent)
  inc %orbs.spent $2
  writeini $char($1) stuff RedOrbsSpent %orbs.spent
  $achievement_check($1, BigSpender)
  $achievement_check($1, BattleArenaAnon)
  $achievement_check($1, Don'tForgetYourFriendsAndFamily)
  return
}
alias inc.blackorbsspent {
  var %orbs.spent $readini($char($1), stuff, BlackOrbsSpent)
  inc %orbs.spent $2
  writeini $char($1) stuff BlackOrbsSpent %orbs.spent

  $achievement_check($1, BossKiller)
  return
}

alias shop.calculate.totalcost {
  var %value 1
  var %total.price.calculate 0
  set %shop.level $return.shoplevel($1)
  var %max.shoplevel $readini(system.dat, system, Maxshoplevel)

  while (%value <= $2) {
    set %true.shop.level %shop.level

    ; Check for the  VIP-MemberCard accessory
    if ($accessory.check($1, ReduceShopLevel) = true) {
      dec %true.shop.level %accessory.amount
      unset %accessory.amount
    }

    if (%true.shop.level < 1) { set %true.shop.level 1.0 }

    inc %total.price.calculate $round($calc(%true.shop.level * $3),0)

    if (%max.shoplevel = $null) { var %max.shoplevel 25 }
    if (%shop.level < %max.shoplevel) {  inc %shop.level .1 }
    inc %value 1
  }
  unset %true.shop.level
  return %total.price.calculate
}

alias shop.get.shop.level {
  set %shop.level $return.shoplevel($1)

  set %current.accessory $readini($char($1), equipment, accessory)
  set %current.accessory.type $readini($dbfile(items.db), %current.accessory, accessorytype)

  ; Check for the  VIP-MemberCard accessory
  if (%current.accessory.type = ReduceShopLevel) {
    set %accessory.amount $readini($dbfile(items.db), %current.accessory, amount)
    dec %shop.level %accessory.amount
    unset %accessory.amount
  }

  if (%shop.level < 1) { set %shop.level 1.0 }

  unset %current.accessory | unset %current.accessory.type
}

alias shop.voucher.list {
  ; cycle through the files and get the item name (token position 1) and the cost (token position 2)
  ; for each types of vouchers (bronze, silver and gold)

  unset %item.name | unset %item_amount | unset %voucher.list.*

  var %player.voucher.bronze $readini($char($1), item_amount, BronzeVoucher)
  var %player.voucher.silver $readini($char($1), item_amount, SilverVoucher)
  var %player.voucher.gold $readini($char($1), item_amount, GoldVoucher)

  if (%player.voucher.bronze = $null) { var %player.voucher.bronze 0 }
  if (%player.voucher.silver = $null) { var %player.voucher.silver 0 }
  if (%player.voucher.gold = $null) { var %player.voucher.gold 0 }

  ; CHECKING BRONZE VOUCHER LIST
  var %value 1 | var %items.lines $lines($lstfile(shop_voucherbronze.lst))

  while (%value <= %items.lines) {
    var %voucher.line  $read -l $+ %value $lstfile(shop_voucherbronze.lst)
    var %item.name $gettok(%voucher.line, 1, 46)
    var %item.price $gettok(%voucher.line, 2, 46)

    if (%item.price > %player.voucher.bronze) { var %item.color 5 }
    else { var %item.color 3 }

    if ($numtok(%voucher.list.bronze, 46) >= 12) { %voucher.list.bronze2 = $addtok(%voucher.list.bronze2, $+ %item.color $+ %item.name $+ ( $+ %item.price $+ ) $+ ,46) }
    else { %voucher.list.bronze = $addtok(%voucher.list.bronze, $+ %item.color $+ %item.name $+ ( $+ %item.price $+ ) $+ ,46) }

    inc %value 1 
  }

  set %replacechar $chr(044) $chr(032)
  %voucher.list.bronze = $replace(%voucher.list.bronze, $chr(046), %replacechar)
  if (%voucher.list.bronze2 != $null) {  %voucher.list.bronze2 = $replace(%voucher.list.bronze2, $chr(046), %replacechar) }

  if (%voucher.list.bronze != $null) { 
    $display.private.message.delay.custom(2These items and armor pieces are paid for with 7Bronze Vouchers,1)
  $display.private.message.delay.custom(%voucher.list.bronze, 1) }
  if (%voucher.list.bronze2 != $null) { $display.private.message.delay.custom(%voucher.list.bronze2, 1) }

  ; CHECKING SILVER VOUCHER LIST
  var %value 1 | var %items.lines $lines($lstfile(shop_vouchersilver.lst))

  while (%value <= %items.lines) {
    var %voucher.line  $read -l $+ %value $lstfile(shop_vouchersilver.lst)
    var %item.name $gettok(%voucher.line, 1, 46)
    var %item.price $gettok(%voucher.line, 2, 46)

    if (%item.price > %player.voucher.silver) { var %item.color 5 }
    else { var %item.color 3 }

    if ($numtok(%voucher.list.silver, 46) <= 12) { %voucher.list.silver = $addtok(%voucher.list.silver, $+ %item.color $+ %item.name $+ ( $+ %item.price $+ ) $+ ,46) }
    else {
      if ($numtok(%voucher.list.silver2, 46) <= 12) { %voucher.list.silver2 = $addtok(%voucher.list.silver2, $+ %item.color $+ %item.name $+ ( $+ %item.price $+ ) $+ ,46) }
      else { %voucher.list.silver3 = $addtok(%voucher.list.silver3, $+ %item.color $+ %item.name $+ ( $+ %item.price $+ ) $+ ,46) }
    }

    inc %value 1 
  }

  set %replacechar $chr(044) $chr(032)
  %voucher.list.silver = $replace(%voucher.list.silver, $chr(046), %replacechar)
  if (%voucher.list.silver2 != $null) {  %voucher.list.silver2 = $replace(%voucher.list.silver2, $chr(046), %replacechar) }
  if (%voucher.list.silver3 != $null) {  %voucher.list.silver3 = $replace(%voucher.list.silver3, $chr(046), %replacechar) }

  if (%voucher.list.silver != $null) {
    $display.private.message.delay.custom(2These items and armor pieces are paid for with 7Silver Vouchers,1)
  $display.private.message.delay.custom(%voucher.list.silver, 1) }
  if (%voucher.list.silver2 != $null) { $display.private.message.delay.custom(%voucher.list.silver2, 1) }
  if (%voucher.list.silver3 != $null) { $display.private.message.delay.custom(%voucher.list.silver3, 1) }

  ; CHECKING GOLD VOUCHER LIST
  var %value 1 | var %items.lines $lines($lstfile(shop_vouchergold.lst))

  while (%value <= %items.lines) {
    var %voucher.line  $read -l $+ %value $lstfile(shop_vouchergold.lst)
    var %item.name $gettok(%voucher.line, 1, 46)
    var %item.price $gettok(%voucher.line, 2, 46)

    if (%item.price > %player.voucher.gold) { var %item.color 5 }
    else { var %item.color 3 }

    if ($numtok(%voucher.list.gold, 46) >= 12) { %voucher.list.gold2 = $addtok(%voucher.list.gold2, $+ %item.color $+ %item.name $+ ( $+ %item.price $+ ) $+ ,46) }
    else { %voucher.list.gold = $addtok(%voucher.list.gold, $+ %item.color $+ %item.name $+ ( $+ %item.price $+ ) $+ ,46) }

    inc %value 1 
  }

  set %replacechar $chr(044) $chr(032)
  %voucher.list.gold = $replace(%voucher.list.gold, $chr(046), %replacechar)
  if (%voucher.list.gold2 != $null) {  %voucher.list.gold2 = $replace(%voucher.list.gold2, $chr(046), %replacechar) }

  if (%voucher.list.gold != $null) { 
    $display.private.message.delay.custom(2These items and armor pieces are paid for with 7Gold Vouchers,1)
  $display.private.message.delay.custom(%voucher.list.gold, 1) }
  if (%voucher.list.gold2 != $null) { $display.private.message.delay.custom(%voucher.list.gold2, 1) }


  if (((%voucher.list.bronze = $null) && (%voucher.list.silver = $null) && (%voucher.list.gold = $null))) {  $display.private.message(4There are no voucher items available for purchase right now)  }

  unset %item.price | unset %item.name | unset %voucher.list.* | unset %replacechar

}

alias shop.voucher.buy {
  ; $1 = the person buying
  ; $2 = the voucher type: bronze, silver or gold
  ; $3 = the item being bought

  ; Check to make sure $2 is a valid voucher type
  var %valid.vouchers bronze.silver.gold
  if ($istok(%valid.vouchers, $2, 46) = $false) { $display.private.message(4Invalid voucher type. Use !voucher buy bronze/silver/gold itemname) | halt }

  ; Check to make sure $3 is a valid item that can be bought with that voucher
  var %search.item $3
  var %search.file shop_voucher $+ $2 $+ .lst
  var %item.line $read($lstfile(%search.file), nw, * $+ %search.item $+ *)

  if (%item.line = $null) { $display.private.message(4This cannot be bought with the $2 voucher) | halt }

  ; Check to make sure the person has enough to buy the item
  var %voucher.item.price $gettok(%item.line, 2, 46)
  var %player.voucher.amount $readini($char($1), item_amount, $2 $+ Voucher)
  if (%player.voucher.amount = $null) { var %player.voucher.amount 0 }

  if (%player.voucher.amount < %voucher.item.price) { $display.private.message(4You do not have enough $2 vouchers to purchase this item) | halt }

  ; Decrease the voucher amount
  dec %player.voucher.amount %voucher.item.price
  writeini $char($1) item_amount $2 $+ Voucher %player.voucher.amount

  ; Increase the player's amount by 1
  var %player.amount.item $readini($char($1), item_amount, $3)
  if (%player.amount.item = $null) { var %player.amount.item 0 }
  inc %player.amount.item 1 
  writeini $char($1) item_amount $3 %player.amount.item

  ; Show a message that we did the exchange
  $display.private.message(3You have exchanged %voucher.item.price $2 $iif(%voucher.item.price > 1, vouchers, voucher) for 1 $3)
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mythic shop commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !mythic forge type <-- purchase a mythic for 10 OdinMarks
; !mythic stats <-- Reveals information about your mythic
; !mythic reset yes <-- Erases the mythic entirely.
; !mythic upgrade type <-- upgrades BasePower.Hits.IgnoreDefense.HurtEthereal.Element
; !mythic tech add name <-- adds the tech to the mythic

on 3:TEXT:!mythic*:*: { $shop.mythic($nick, $2, $3, $4, $5) }

alias shop.mythic {
  if ($2 = $null) { $gamehelp(mythic, $nick) | halt  }
  if (($2 = reset) && ($3 != yes)) { $display.private.message(4In order to erase your mythic you must use !mythic reset yes - Please note that using this command will completely erase your mythic and you will not receive a refund) | halt }
  if (($2 = reset) && ($3 = yes)) { remini $char($1) Mythic | $display.private.message(3The mythical weapon has been destroyed.) | halt }

  var %valid.types HandToHand.Sword.Whip.Gun.Rifle.Bow.Katana.Wand.Stave.Glyph.Spear.Scythe.GreatSword.GreatAxe.Axe.Dagger.Hammer

  if (($2 = forge) && ($3 = $null)) { $display.private.message(4Invalid weapon type! Valid types are:2 %valid.types) | halt }
  if (($2 = forge) && ($3 != $null)) { 
    ; Do we already have a mythic?
    if ($readini($char($1), Mythic, Level) != $null) { $display.private.message(4You already have a mythic weapon. To receive a new one you must first reset your old one. Use !mythic reset yes to do so) | halt }

    ; Is it a valid type?
    if ($istok(%valid.types, $3, 46) = $false) { $display.private.message(4Invalid weapon type! Valid types are:2 %valid.types) | halt }

    ; Do we have enough OdinMarks?
    var %mythic.cost 10
    var %current.odinmarks $readini($char($1), Item_Amount, OdinMark)
    if (%current.odinmarks = $null) { var %current.odinmarks 0 }

    if (%current.odinmarks < %mythic.cost) { $display.private.message(4You do not have enough OdinMarks to forge a mythic) | halt }

    ; Purchase the weapon
    dec %current.odinmarks %mythic.cost 
    writeini $char($1) Item_Amount OdinMark %current.odinmarks

    writeini $char($1) Weapons Mythic 1
    writeini $char($1) Mythic Type $3
    writeini $char($1) Mythic CurrentLevel 1
    writeini $char($1) Mythic BasePower 100
    writeini $char($1) Mythic Element none
    writeini $char($1) Mythic Hits 1
    writeini $char($1) Mythic IgnoreDefense 0
    writeini $char($1) Mythic HurtEthereal no
    writeini $char($1) Mythic AbsorbAmount 0
    writeini $char($1) Mythic UpgradesDone 0

    $display.private.message(3Hephaestus takes your %mythic.cost OdinMarks and forges a powerful $3 mythic weapon for you!)
    $display.private.message(3You can use !mythic stats to see information on your mythic.)
    halt
  }

  if ($2 = stats) { 
    if ($readini($char($1), Mythic, CurrentLevel) = $null) { $display.private.message(4You do not have a mythic weapon. To forge one you must use !mythic forge weapontype) | halt }

    var %mythic.type $readini($char($1), Mythic, Type)
    var %mythic.level $round($calc($readini($char($1), Mythic, UpgradesDone) / 5),0)
    if (%mythic.level < 1) { var %mythic.level 1 }

    var %mythic.basepower $readini($char($1), Mythic, BasePower)
    var %mythic.element $readini($char($1), Mythic, Element)
    var %mythic.hits $readini($char($1), Mythic, Hits)
    var %mythic.IgnoreDefense $readini($char($1), Mythic, IgnoreDefense)
    var %mythic.HurtEthereal $readini($char($1), Mythic, HurtEthereal)
    var %mythic.techs $readini($char($1), Mythic, Techs)
    if (%mythic.techs = $null) { var %mythic.techs none } 
    else { var %mythic.techs $replace(%mythic.techs, $chr(046), $chr(044) $chr(032)) }

    $display.private.message([4Mythic Type12 %mythic.type $+ ] [4Mythic Level12 %mythic.level $+ ] [4Mythic Base Power12 %mythic.basepower $+ ])
    $display.private.message([4Mythic Element12 %mythic.element $+ ] [4Num of Hits12 %mythic.hits $+ ] [4Ignore Defense Amount12 %mythic.IgnoreDefense $+ ] [4Mythic Can Hurt Ethereal Monsters?12 %mythic.hurtethereal $+ ])
    $display.private.message([4Mythic Techs12 %mythic.techs $+ ])
  }

  if ($2 = upgrade) { 
    var %valid.upgrades BasePower.Hits.IgnoreDefense.HurtEthereal.Element
    if ($3 = $null) {  
      $display.private.message(4Invalid upgrade type! Valid types are:2 %valid.upgrades) 
      $display.private.message(4Upgrade costs:12 10 OdinMarks for +5 BasePower $+ $chr(44) 50 OdinMarks for +1 Hit $+ $chr(44) 10 OdinMarks for HurtEthereal $+ $chr(44) 10 OdinMarks for a new Element $+ $chr(44) 20 OdinMarks for +1 IgnoreDefense)
      halt 
    }

    if ($3 = BasePower) { 
      var %upgrade.cost 10 | var %upgrade.amount 5
      $mythic.upgrade.costcheck($1, %upgrade.cost)

      var %current.basepower $readini($char($1), Mythic, BasePower) 
      inc %current.basepower %upgrade.amount
      writeini $char($1) Mythic BasePower %current.basepower
      $mythic.inc.upgrade.count($1)

      $display.private.message(3Hephaestus takes your %upgrade.cost OdinMarks and imbues your mythic with + $+ %upgrade.amount more Base Power)
      halt
    }

    if ($3 = Hits) { 
      var %upgrade.cost 50 | var %hit.upgrade 1
      var %current.hits $readini($char($1), Mythic, Hits) 

      if (%current.hits >= 10) { $display.private.message(4Your mythic has the maximum number of hits allowed!) | halt }

      inc %current.hits %hit.upgrade
      writeini $char($1) Mythic Hits %current.hits
      $mythic.inc.upgrade.count($1)

      $display.private.message(3Hephaestus takes your %upgrade.cost OdinMarks and imbues your mythic with + $+ %hit.upgrade more Hit)
      halt
    }

    if ($3 = HurtEthereal) { 
      if ($readini($char($1), Mythic, HurtEthereal) = true) { $display.private.message(4You have already purchased this upgrade!) | halt }
      var %upgrade.cost 10
      $mythic.upgrade.costcheck($1, %upgrade.cost)
      writeini $char($1) Mythic HurtEthereal true
      $mythic.inc.upgrade.count($1)
      $display.private.message(3Hephaestus takes your %upgrade.cost OdinMarks and imbues your mythic with the power to hurt ethereal creatures)
      halt
    }

    if ($3 = Element) {
      var %valid.elements fire.earth.wind.water.dark.light.lightning
      if ($istok(%valid.elements, $4, 46) = $false) { $display.private.message(4Invalid element! Valid elements are:2 %valid.elements) | halt }

      var %upgrade.cost 10
      $mythic.upgrade.costcheck($1, %upgrade.cost)
      writeini $char($1) Mythic Element $4
      $mythic.inc.upgrade.count($1)
      $display.private.message(3Hephaestus takes your %upgrade.cost OdinMarks and imbues your mythic with the $4 element)
      halt
    }

    if ($3 = IgnoreDefense) { 
      var %upgrade.cost 20 | var %upgrade.amount 1 
      $mythic.upgrade.costcheck($1, %upgrade.cost)

      var %current.ignoredef $readini($char($1), Mythic, IgnoreDefense) 

      if (%current.hits >= 100) { $display.private.message(4Your mythic has the max Ignore Defense possible!) | halt }

      inc %current.ignoredef %upgrade.amount
      writeini $char($1) Mythic IgnoreDefense %current.ignoredef
      $mythic.inc.upgrade.count($1)

      $display.private.message(3Hephaestus takes your %upgrade.cost OdinMarks and imbues your mythic with + $+ %upgrade.amount more IgnoreDefense)
      halt
    }
  }

  if ($2 = tech) {
    if ($3 = add) { 
      if ($numtok($readini($char($1), Mythic, Techs), 46) = 10) { $display.private.message(4Your mythic has used all available technique slots and cannot add any more.) | halt }
      if ($istok($readini($char($1), Mythic, Techs), $4, 46) = $true) { $display.private.message(4Your mythic already has the $4 technique equipped.) | halt }

      var %upgrade.cost 20

      ; Is this a valid technique?
      var %technique.cost $readini($dbfile(techniques.db), $4, cost)
      if ((%technique.cost = $null) || (%technique.cost = 0)) { $display.private.message(4This technique cannot be added to your mythic.) | halt }

      ; Does the player know this technique?
      var %tech.power $readini($char($1), Techniques, $4)
      if ((%tech.power = 0) || (%tech.power = $null)) { $display.private.message(4You do not know this technique and thus it cannot be added to your mythic.) | halt }

      ; Lower the OdinMarks
      $mythic.upgrade.costcheck($1, %upgrade.cost)

      ; Add it to the mythic
      var %current.techniques $readini($char($1), Mythic, Techs)
      var %current.techniques $addtok(%current.techniques, $4, 46)
      writeini $char($1) Mythic Techs %current.techniques
      $mythic.inc.upgrade.count($1)

      $display.private.message(3Hephaestus takes your %upgrade.cost OdinMarks and imbues your mythic with the $4 technique)
      halt
    }

    if ($3 = remove) { 
      if ($istok($readini($char($1), Mythic, Techs), $4, 46) = $false) { $display.private.message(4Your mythic does not have the $4 technique equipped.) | halt }

      ; Remove it from the mythic
      var %current.techniques $readini($char($1), Mythic, Techs)
      var %current.techniques $remtok(%current.techniques, $4, 46)
      writeini $char($1) Mythic Techs %current.techniques
      $display.private.message(3Hephaestus has removed the $4 technique from your mythic)
      halt

    }
  }


}

alias mythic.upgrade.costcheck {
  ; $1 = the person we're checking
  ; $2 = the amount it costs

  var %current.odinmarks $readini($char($1), Item_Amount, OdinMark)
  if (%current.odinmarks = $null) { var %current.odinmarks 0 }
  if (%current.odinmarks <  $2) { $display.private.message(4You do not have enough OdinMarks to purchase this upgrade) | halt }
  dec %current.odinmarks $2
  writeini $char($1) Item_Amount OdinMark %current.odinmarks
}

alias mythic.inc.upgrade.count {
  var %upgrades.done $readini($char($1), Mythic, UpgradesDone)
  inc %upgrades.done 1
  writeini $char($1) Mythic UpgradesDone %upgrades.done
}
