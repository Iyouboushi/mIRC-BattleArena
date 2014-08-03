;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  SHOP COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 3:TEXT:!shop*:*: { $shop.start($1, $2, $3, $4, $5) }
on 3:TEXT:!exchange*:*: { $shop.exchange($nick, $2, $3) }
on 3:TEXT:!sell*:*: { $shop.start(!shop, sell, $2, $3, $4, $5) }

alias shop.exchange {
  ; $1 = user
  ; $2 = alliednotes/doubledollars
  ; $3 = amount you want to exchange

  if ($3 = 0) {  $display.private.message($readini(translation.dat, errors, Can'tBuy0ofThat)) | halt }
  if (($2 != alliednotes) && ($2 != doubledollars)) { $display.private.message(4!exchange alliednotes/doubledollars #amount) | halt }

  var %currency.symbol $readini(system.dat, system, BetCurrency)
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
    var %message 2You exchange %notes.needed allied notes for %currency.symbol $+ %dollarstogive double dollars
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
    var %message 2You exchange %currency.symbol $+ %dollars.needed double dollars  for %notestogive allied notes
  }

  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {  $display.private.message2($1, %message) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($1, %message) }

  return


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
    var %sellable.stuff items.accessories.accessory.gems.tech.techs.technique.armor
    if ($3 !isin %sellable.stuff) { $display.private.message($readini(translation.dat, errors, Can'tSellThat)) | halt }
    var %amount.to.sell $abs($5)
    if (%amount.to.sell = $null) { var %amount.to.sell 1 }
    if (($3 = item) || ($3 = items)) { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = key) || ($3 = keys)) { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = accessories) || ($3 = accessory))  { $shop.accessories($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = gems) || ($3 = gem))  { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if ((($3 = tech) || ($3 = techs) || ($3 = technique))) { $shop.techs($nick, sell, $4, %amount.to.sell) | halt }
    if ($3 = armor)  { $shop.armor($nick, sell, $4, %amount.to.sell) | halt }
  }

  if (($2 = buy) || ($2 = purchase)) { 
    if (%battleis = on) { 
      if ($nick isin $readini($txtfile(battle2.txt), Battle, List)) {  $display.private.message($readini(translation.dat, errors, Can'tUseShopInBattle)) | halt }
    }

    if ($3 = $null) {  $display.private.message(4Error: Use !shop buy <items/techs/skills/stats/weapons/styles/ignitions/orbs/portal/misc/mech/mech items/shields> <what to buy>)  }
    var %amount.to.purchase $abs($5)
    if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }

    if (($3 = items) || ($3 = item))  { $shop.items($nick, buy, $4, %amount.to.purchase) | halt }
    if ((($3 = techs) || ($3 = techniques) || ($3 = tech))) { $shop.techs($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = skills) || ($3 = skill)) { $shop.skills($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = stats) || ($3 = stat))  {  $shop.stats($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = portal) || ($3 = portalitem))  { $shop.portal($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = alchemy) || ($3 = misc))  { $shop.alchemy($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = alliednotes) || ($3 = gems))  { $shop.alchemy($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, buy, $4, %amount.to.purchase) }
    if (($3 = shields) || ($3 = shield)) { $shop.shields($nick, buy, $4, %amount.to.purchase) }
    if ($3 = orbs) { 
      var %amount.to.purchase $abs($4)
      if (%amount.to.purchase = $null) { var %amount.to.purchase 1 }
      $shop.orbs($nick, buy, %amount.to.purchase) 
    }
    if (($3 = style) || ($3 = styles))  { $shop.styles($nick, buy, $4) | halt }
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

    else {  $display.private.message(4Error: Use !shop list <items/techs/skills/stats/weapons/orbs/ignitions/styles/portal/misc/mech/mech items/shields>  or !shop buy <items/techs/skills/stats/weapons/orbs/style/ignitions/portal/misc/mech/mech items/shields> <what to buy>)  | halt }
  }

  if ($2 = list) { 

    var %valid.categories stats.stat.items.item.techs.techniques.skills.skill.weapons.weapon.orbs.style.styles.ignition.ignitions.portal.portals.alchemy.misc.alliednotes.gems.mech.mech items.shield.shields
    if ($istok(%valid.categories, $3, 46) = $false) { $display.private.message(4Error: Use !shop list <<items/techs/skills/stats/weapons/styles/ignitions/orbs/portal/misc/mech/mech items>  or !shop buy <items/techs/skills/stats/weapons/styles/ignitions/orbs/portal/misc/mech/mech items/shields> <what to buy>)  | halt }

    else {

      if (($3 = stats) || ($3 = stat)) { $shop.stats($nick, list) }
      if (($3 = items) || ($3 = item)) { $shop.items($nick, list) }
      if (($3 = techs) || ($3 = techniques))  { $shop.techs($nick, list) }
      if (($3 = skills) || ($3 = skill)) { 
        if ($4 = $null) { $shop.skills($nick, list) | halt }

        var %valid.categories passive.active.resists.resistances.killer.killertraits.null
        if ($istok(%valid.categories, $4, 46) = $false) { $display.private.message(4Error: Use !shop list skills <passive/active/resists/killer>)  | halt }

        if ($4 = passive) { $shop.skills.passive($nick) }
        if ($4 = active) { $shop.skills.active($nick) }
        if (($4 = resists) || ($4 = resistances)) { $shop.skills.resists($nick) }
        if (($4 = killer) || ($4 = killertraits)) { $shop.skills.killertraits($nick) }
      }

      if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, list) }
      if (($3 = shields) || ($3 = shield)) { $shop.shields($nick, list) }
      if ($3 = orbs) { $shop.orbs($nick, list) }
      if (($3 = style) || ($3 = styles))  { $shop.styles($nick, list, $4) | halt }
      if (($3 = ignition) || ($3 = ignitions))  { $shop.ignitions($nick, list, $4) | halt }
      if (($3 = portal) || ($3 = portals)) { $shop.portal($nick, list) }
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

  else {  $display.private.message(4Error: Use !shop list <<items/techs/skills/stats/weapons/styles/ignitions/orbs/portal/misc/mech/mech items/shields>  or !shop buy <<items/techs/skills/stats/weapons/styles/ignitions/orbs/portal/misc/mech/mech items/shields> <what to buy>)  | halt }

}

alias shop.accessories {
  if ($2 = sell) {
    ; is it a valid item?
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Error: Invalid accessory.) | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), Item_Amount, $3)
    if (%player.items = $null) { $display.private.message($readini(translation.dat, errors, DoNotHaveAccessoryToSell)) | halt }
    if (%player.items < $4) { $display.private.message($readini(translation.dat, errors, DoNotHaveEnoughItemToSell)) | halt }

    var %equipped.accessory $readini($char($1), equipment, accessory)
    if (%equipped.accessory = $3) {
      if (%player.items = 1) { $display.private.message($readini(translation.dat, errors, StillWearingAccessory)) | halt }
    }
    ; If so, decrease the amount
    dec %player.items $4
    writeini $char($1) item_amount $3 %player.items

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

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message($readini(translation.dat, system, SellMessage))
  }
}


alias shop.armor {
  if ($2 = sell) {
    ; is it a valid item?
    if ($readini($dbfile(equipment.db), $3, EquipLocation) = $null) { $display.private.message(4Error: Invalid armor piece.) | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), Item_Amount, $3)
    if (%player.items = $null) { $display.private.message($readini(translation.dat, errors, DoNotHaveArmorToSell)) | halt }
    if (%player.items < $4) { $display.private.message($readini(translation.dat, errors, DoNotHaveEnoughItemToSell)) | halt }

    set %armor.equip.slot $readini($dbfile(equipment.db), $3, EquipLocation)

    set %equipped.armor $readini($char($1), equipment, %armor.equip.slot)
    if (%equipped.armor = $3) {
      if (%player.items = 1) { $display.private.message($readini(translation.dat, errors, StillWearingArmor)) | halt }
    }

    unset %armor.equip.slot | unset %equipped.armor 

    ; If so, decrease the amount
    dec %player.items $4
    writeini $char($1) item_amount $3 %player.items

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
    unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_healing.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_healing.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if (%item.price > 0) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(3Healing Items:2 %shop.list)
    }


    ; CHECKING BATTLE ITEMS
    unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_battle.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_battle.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if (%item.price > 0) {  
        if ((%shopnpc.name = $null) || ($shopnpc.present.check(%shopnpc.name) = true)) {
          if ((%conquest.item = $null) || (%conquest.item = false)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
          if ((%conquest.item = true) && (%conquest.status = players)) { %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        }
      }

      unset %item.name | unset %item_amount | unset %conquest.item | unset %shopnpc.name
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(4Battle Items:2 %shop.list)
    }


    ; CHECKING CONSUMABLE ITEMS
    unset %shop.list |  var %value 1 | var %items.lines $lines($lstfile(items_consumable.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_consumable.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      set %conquest.item $readini($dbfile(items.db), %item.name, ConquestItem)
      set %shopnpc.name $readini($dbfile(items.db), %item.name, shopNPC)

      if (%item.price > 0) {  
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

      if (%item.price > 0) {  
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

      if (%item.price > 0) {  
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

      if (%item.price > 0) {  
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

      if (%item.price > 0) {  
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

      if (($readini($char($1), item_amount, %item.name) = $null) || ($readini($char($1), item_amount, %item.name) <= 0)) {

        if (%item.price > 0) {  
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

      unset %item.price | unset %item.name | unset %shop.list
    }

  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Error: Invalid item. Use! !shop list items to get a valid list) | halt }

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
    var %player.items $readini($char($1), Item_Amount, $3)
    inc %player.items $4
    writeini $char($1) Item_Amount $3 %player.items

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
    var %player.items $readini($char($1), Item_Amount, $3)
    if (%player.items = $null) { $display.private.message(4Error: You do not have this item to sell!) | halt }
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
    dec %player.items $4
    writeini $char($1) item_amount $3 %player.items

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
  if ($2 = list) {
    unset %shop.list
    ; get the list of the techs for the weapon you have equipped
    $weapon_equipped($1)
    $shop.get.shop.level($1)

    ; CHECKING TECHS
    unset %shop.list
    set %tech.list $readini($dbfile(weapons.db), %weapon.equipped, Abilities)
    var %number.of.items $numtok(%tech.list, 46)
    var %my.tp $readini($char($1), basestats, tp)

    var %value 1
    while (%value <= %number.of.items) {
      set %tech.name $gettok(%tech.list, %value, 46)
      set %tech.price $round($calc(%shop.level * $readini($dbfile(techniques.db), %tech.name, cost)),0)
      set %player.amount $readini($char($1), techniques, %tech.name)

      if ($readini($dbfile(techniques.db), %tech.name, type) = boost) {
        if ((%player.amount <= 500) || (%player.amount = $null)) { %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
      }
      if ($readini($dbfile(techniques.db), %tech.name, type) != boost) {  

        set %techs.onlyone buff.ClearStatusPositive.ClearStatusNegative 
        set %tech.type $readini($dbfile(techniques.db), %tech.name, type)
        if ($istok(%techs.onlyone,%tech.type,46) = $true) { 
          set %player.amount $readini($char($1), techniques, %tech.name)
          if ((%player.amount < 1) || (%player.amount = $null)) { %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
        }
        if ($istok(%techs.onlyone,%tech.type,46) = $false) {  
          if ((%player.amount <= 500) || (%player.amount = $null)) {

            %shop.list = $addtok(%shop.list, $+ $iif(%my.tp < $readini($dbfile(techniques.db), %tech.name, tp), 5) %tech.name $+ 2+1 ( $+ %tech.price $+ ),46) 

          }
        }
      }

      inc %value 1 | unset %player.amount 
    }

    ; display the list with the prices.
    $shop.cleanlist
    $display.private.message(4Tech Prices2 in $readini(system.dat, system, currency) $+ : %shop.list ) 
    unset %player.amount | unset %techs.onlyone | unset %tech.type | unset %shop.list | unset %shop.list2
    unset %ignition.tech.list | unset %techs.list | unset %tech.name | unset %shop.level | unset %tech.price
    unset %tech.count | unset %tech.power
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid tech?
    $weapon_equipped($1)
    set %weapon.abilities $readini($dbfile(weapons.db), %weapon.equipped, abilities)
    if ($istok(%weapon.abilities,$3,46) = $false) { $display.private.message(4Error: Invalid item. Use! !shop list techs to get a valid list ) | halt }
    unset %weapon.abilities

    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %base.cost $readini($dbfile(techniques.db), $3, cost)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this item!) | halt }

    var %current.techlevel $readini($char($1), techniques, $3)

    if ($readini($dbfile(techniques.db), $3, type) = buff) { var %max.techlevel 1 }
    if ($readini($dbfile(techniques.db), $3, type) != buff) {  var %max.techlevel 500 }

    if (%current.techlevel >= %max.techlevel) {  $display.private.message(4You cannot buy any more levels of $3 $+ .) | halt }

    ; if so, increase the amount and add it to the list
    inc %current.techlevel $4

    if (%current.techlevel > %max.techlevel) {  $display.private.message(4Purchasing this amount will put you over the max limit. Please lower the amount and try again.) | halt }

    writeini $char($1) techniques $3 %current.techlevel

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    $inc.redorbsspent($1, %total.price)

    $display.private.message(3You spend $bytes(%total.price,b)  $+  $readini(system.dat, system, currency) for + $+ $4 to your $3 technique $+ ! $readini(translation.dat, system, OrbsLeft))

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
  }

  if ($2 = sell) {
    ; is it a valid item?
    if ($readini($dbfile(techniques.db), $3, type) = $null) {  $display.private.message(4Error: Invalid tech. Use! !techs to get a valid list of techs you own.) | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), techniques, $3)
    if (%player.items = $null) {  $display.private.message(4Error: You do not have this tech to sell!) | halt }
    if (%player.items < $4) {  $display.private.message(4Error: You do not have $4 levels of this tech to sell!) | halt }

    set %total.price $readini($dbfile(techniques.db), $3, cost)



    var %total.price $readini($dbfile(techniques.db), $3, sellPrice)

    if (%total.price = $null) { 
      var %total.price $readini($dbfile(techniques.db), $3, cost)
      %total.price = $round($calc(%total.price / 5),0)
    }

    if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 50  }

    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $round($calc(($readini($char($1), skills, Haggling) / 100) * %total.price),0)
    }

    ; If so, decrease the amount
    dec %player.items $4
    writeini $char($1) techniques $3 %player.items

    if (%total.price >= $readini($dbfile(techniques.db), $3, cost)) { set %total.price $readini($dbfile(techniques.db), $3, cost) }
    if (%total.price > 5000) { %total.price = 5000 }
    if ((%total.price <= 0) || (%total.price = $null)) { %total.price = 50 }

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message(3A shop keeper wearing a green and white bucket hat uses a special incantation to take $4 $iif($4 < 2, level, levels) of $3 $+  from you and gives you %total.price $readini(system.dat, system, currency) $+ !)
    unset %total.price
  }
}

alias shop.skills {
  unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills | unset %total.passive.skills | unset %total.active.skills | unset %shop.list.killertraits
  if ($2 = list) {
    ; get the list of the skills and display the lists
    $shop.get.shop.level($1)

    $shop.get.skills.active($1)
    if (%shop.list.activeskills != $null) {  $display.private.message(4Active Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.activeskills) }
    if (%shop.list.activeskills2 != $null) {  $display.private.message(2 $+ %shop.list.activeskills2) }

    $shop.get.skills.passive($1)
    if (%shop.list.passiveskills != $null) {  $display.private.message(4Passive Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.passiveskills) }
    if (%shop.list.passiveskills2 != $null) {  $display.private.message(2 $+ %shop.list.passiveskills2) }

    $shop.get.skills.resistance($1)
    if (%shop.list.resistanceskills != $null) {  $display.private.message(4Resistance Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.resistanceskills) }

    $shop.get.skills.killertrait($1)
    if (%shop.list.killertraits != $null) {  $display.private.message(4Killer Trait Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.killertraits) }
    if (%shop.list.killertraits2 != $null) {  $display.private.message(2 $+ %shop.list.killertraits2) }




    unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills | unset %shop.list.activeskills2 | unset %shop.list.passiveskills2 | unset %total.active.skills | unset %total.passives.skills | unset %shop.list.killertraits
    unset %shop.list.killertraits2 | unset %skill.name | unset %skill.have | unset %replacechar
    unset %shop.level | unset %skill.max | unset %skill.price 
  }


  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid skill?
    if ($readini($dbfile(skills.db), $3, type) = $null) { $display.private.message(4Error: Invalid . Use! !shop list skills to get a valid list) | halt }

    var %current.skilllevel $readini($char($1), skills, $3)
    inc %current.skilllevel $4
    var %max.skilllevel $readini($dbfile(skills.db), $3, max)
    if (%max.skilllevel = $null) { var %max.skilllevel 100000 }
    if (%current.skilllevel > %max.skilllevel) { $display.private.message(4You cannot buy any more levels into this skill as you have already hit or will go over the max amount with this purchase amount.) | halt }

    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %base.cost $readini($dbfile(skills.db), $3, cost)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this item!) | halt }

    writeini $char($1) skills $3 %current.skilllevel

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    $inc.redorbsspent($1, %total.price)

    $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $4 to your $3 skill $+ ! $readini(translation.dat, system, OrbsLeft))

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
  }
}

alias shop.get.skills.passive {

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
      set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0)
      if ((%total.passive.skills <= 15) || (%total.passive.skills = $null)) {  %shop.list.passiveskills = $addtok(%shop.list.passiveskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      if (%total.passive.skills > 15) {  %shop.list.passiveskills2 = $addtok(%shop.list.passiveskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      inc %value 1 | inc %total.passive.skills 1
    }
  }

  unset %skill.list | unset %total.passive.skills

  set %replacechar $chr(044) $chr(032) |  %shop.list.passiveskills = $replace(%shop.list.passiveskills, $chr(046), %replacechar) | %shop.list.passiveskills2 = $replace(%shop.list.passiveskills2, $chr(046), %replacechar)
}

alias shop.get.skills.active {
  ; CHECKING ACTIVE SKILLS
  unset %skill.list | unset %value | unset %shop.list.activeskills2 | unset %total.active.skills
  var %skills.lines $lines($lstfile(skills_active.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_active.lst)
    set %skill.max $readini($dbfile(skills.db), %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)

    if (%skill.have >= %skill.max) { inc %value 1 }
    else { 
      set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0)
      if (%skill.price > 0) { 
        if ((%total.active.skills <= 15) || (%total.active.skills = $null)) {  %shop.list.activeskills = $addtok(%shop.list.activeskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if (%total.active.skills > 15) {  %shop.list.activeskills2 = $addtok(%shop.list.activeskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        inc %total.active.skills 1
      }
      inc %value 1
    }
  }

  unset %skill.list 

  set %replacechar $chr(044) $chr(032) |  %shop.list.activeskills = $replace(%shop.list.activeskills, $chr(046), %replacechar) | %shop.list.activeskills2 = $replace(%shop.list.activeskills2, $chr(046), %replacechar)

}

alias shop.get.skills.resistance {
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
      set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0)
      %shop.list.resistanceskills = $addtok(%shop.list.resistanceskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46)
      inc %value 1 
    }
  }

  set %replacechar $chr(044) $chr(032) |  %shop.list.resistanceskills = $replace(%shop.list.resistanceskills, $chr(046), %replacechar)
}

alias shop.get.skills.killertrait {
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
      set %skill.price $round($calc(%shop.level * $readini($dbfile(skills.db), %skill.name, cost)),0)

      if ((%total.killertraits <= 13) || (%total.killertraits = $null)) {  %shop.list.killertraits = $addtok(%shop.list.killertraits, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      if (%total.killertraits > 13) { %shop.list.killertraits2 = $addtok(%shop.list.killertraits2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }

      inc %value 1 | inc %total.killertraits 1
    }
  }

  set %replacechar $chr(044) $chr(032) |  %shop.list.killertraits = $replace(%shop.list.killertraits, $chr(046), %replacechar) | %shop.list.killertraits2 = $replace(%shop.list.killertraits2, $chr(046), %replacechar)

  unset %total.killertraits
}


alias shop.skills.passive {
  unset %shop.list.passiveskills | unset %shop.list.passiveskills2
  ; get the list of the skills
  $shop.get.shop.level($1)

  $shop.get.skills.passive($1)

  ; display the list with the prices.
  if (%shop.list.passiveskills != $null) {  $display.private.message(4Passive Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.passiveskills) }
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
  if (%shop.list.activeskills != $null) {  $display.private.message(4Active Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.activeskills) }
  if (%shop.list.activeskills2 != $null) {  $display.private.message(2 $+ %shop.list.activeskills2) }

  unset %shop.list.activeskills |   unset %shop.list.activeskills2 | unset %total.active.skills
  unset %skill.name | unset %skill.have | unset %replacechar
}

alias shop.skills.resists {
  unset %shop.list.resistanceskills
  ; get the list of the skills
  $shop.get.shop.level($1)
  $shop.get.skills.resistance($1)

  ; display the list with the prices.
  if (%shop.list.resistanceskills != $null) { $display.private.message(4Resistance Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.resistanceskills) }

  unset %shop.list.resistanceskills
  unset %skill.name | unset %skill.have | unset %replacechar
}

alias shop.skills.killertraits {
  unset %shop.list.killertraits
  ; get the list of the skills
  $shop.get.shop.level($1)
  $shop.get.skills.killertrait($1)

  if (%shop.list.killertraits != $null) {  $display.private.message(4Killer Trait Skill Prices2 in $readini(system.dat, system, currency) $+ : %shop.list.killertraits) }
  if (%shop.list.killertraits2 != $null) {  $display.private.message(2 $+ %shop.list.killertraits2) }

  unset %shop.list.killertraits2 | unset %skill.name | unset %skill.have
  unset %skill.name | unset %skill.have | unset %replacechar
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
    if (%player.current.hp < %player.max.hp) { 
      %shop.list = $addtok(%shop.list,HP+50 ( $+ %hp.price $+ ),46)
    }

    var %player.current.tp $readini($char($1), basestats, tp)
    var %player.max.tp $readini(system.dat, system, maxTP)
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
      if (%player.current.hp >= $readini(system.dat, system, maxHP)) { $display.private.message(4Error: You have the maximum amount of HP allowed!) | halt }
    }

    if ($3 = tp) {
      var %player.current.tp $readini($char($1), basestats, tp)
      if (%player.current.tp >= $readini(system.dat, system, maxTP)) {  $display.private.message(4Error: You have the maximum amount of TP allowed!) | halt }
    }

    if (($3 = ig) || ($3 = IgnitionGauge)) {
      var %player.current.ig $readini($char($1), basestats, IgitionGauge)
      if (%player.current.ig >= $readini(system.dat, system, maxig)) {  $display.private.message(4Error: You have the maximum amount of Ignition Gauge allowed!) | halt }
    }

    if (%player.shop.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this upgrade!) | halt }


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

    $fulls($1)

    ; decrease amount of orbs you have.
    dec %player.shop.redorbs %total.price
    writeini $char($1) stuff redorbs %player.shop.redorbs
    $inc.redorbsspent($1, %total.price)

    $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $bytes(%shop.statbonus,b) to your $3 $+ ! $readini(translation.dat, system, OrbsLeft))

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
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

        var %weaponlist.title %weapons.line
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

      if (%weapon.level >= 500) {  $display.private.message(4You cannot buy any more levels into this weapon.) | halt }

      ; do you have enough to buy it?
      var %player.redorbs $readini($char($1), stuff, redorbs)
      var %base.cost $readini($dbfile(weapons.db), $3, upgrade)
      set %total.price $shop.calculate.totalcost($1, $4, %base.cost)
      if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this weapon upgrade!) | halt }
      dec %player.redorbs %total.price
      $inc.redorbsspent($1, %total.price)
      inc %weapon.level $4

      if (%weapon.level > 500) {   $display.private.message(4Purchasing this amount will put you over the max limit. Please lower the amount and try again.) | halt }

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
          var %item_to_add  $+ %item.name $+  $+ $chr(040) $+ %item_amount $+ $chr(041) 

          if ((%conquest.item = $null) || (%conquest.item = false)) {
            if (%count.core <= 20) { %mech.core.list = $addtok(%mech.core.list,%item_to_add,46) }
            if (%count.core > 20) { %mech.core.list2 = $addtok(%mech.core.list2,%item_to_add,46) }  
          }
          if ((%conquest.item = true) && (%conquest.status = players)) { 
            if (%count.core <= 20) { %mech.core.list = $addtok(%mech.core.list,%item_to_add,46) }
            if (%count.core > 20) { %mech.core.list2 = $addtok(%mech.core.list2,%item_to_add,46) }  
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
          if (%count.weapon <= 20) { %mech.weapon.list = $addtok(%mech.weapon.list,%item_to_add,46) }
          if (%count.weapon > 20) { %mech.weapon.list = $addtok(%mech.weapon.list2,%item_to_add,46) }    
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

    if (%cost = $null) { $display.private.message(4Error: Invalid item! Use !shop list mech items to get a valid list) | halt }

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

    var %item.amount $readini($char($1), item_amount, $3)
    if (%item.amount = $null) { var %item.amount 0 }
    inc %item.amount $4
    writeini $char($1) item_amount $3 %item.amount
    $display.private.message(3The crazy engineer with the wild beard and thick goggles laughs and takes your your %total.price Allied Notes and gives you 1 $3 $+ !)
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }

}

alias shop.ignitions {
  if ($2 = list) {
    unset %shop.list |  var %value 1 | set %total.ignitions 0 | var %ignitions.lines $lines($lstfile(ignitions.lst))

    while (%value <= %ignitions.lines) {
      set %ig.name $read -l $+ %value $lstfile(ignitions.lst)
      set %ig.price $readini($dbfile(ignitions.db), %ig.name, cost)
      if (%ig.price > 0) {  

        set %player.ignition.level $readini($char($1), ignitions, %ig.name)

        if ((%player.ignition.level = $null) || (%player.ignition.level <= 0)) {
          inc %total.ignitions 1
          if (%total.ignitions < 20) { %shop.list = $addtok(%shop.list, $+ %ig.name $+ ( $+ %ig.price $+ ),46) }
          else { %shop.list2 = $addtok(%shop.list2, $+ %ig.name $+ ( $+ %ig.price $+ ),46) }
        }
      }
      unset %ig.name | unset %ig_amount
      inc %value 1 
    }


    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New ignition prices are in Black Orbs.)
      $display.private.message(4New ignitions:2 %shop.list)
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
    ; do you have enough to buy it?
    var %player.blackorbs $readini($char($1), stuff, blackorbs) 
    var %total.price $readini($dbfile(ignitions.db), $3, cost)
    if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this item!) | halt }
    dec %player.blackorbs %total.price
    writeini $char($1) stuff blackorbs %player.blackorbs
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) ignitions $3 1
    $display.private.message(3You spend %total.price black $iif(%total.price < 2, orb, orbs) to purchase $3 $+ ! $readini(translation.dat, system, BlackOrbsLeft))
    unset %ignitions.list | unset %ignition.name | unset %ignition.level | unset %ignition.price | unset %ignitions
    halt
  }
}

alias shop.portal {
  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount | unset portals.bstmen | unset %portals.kindred | unset %portals.highkindredcrest | unset %portals.kindredcrest

    var %value 1 | var %items.lines $lines($lstfile(items_portal.lst))

    while (%value <= %items.lines) {
      set %item.name $read -l $+ %value $lstfile(items_portal.lst)
      set %item.price $readini($dbfile(items.db), %item.name, cost)
      if (%item.price > 0) {  
        if ($readini($dbfile(items.db), %item.name, currency) = BeastmenSeal) { %portals.bstmen = $addtok(%portals.bstmen, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        if ($readini($dbfile(items.db), %item.name, currency) = KindredSeal) { %portals.kindred = $addtok(%portals.kindred, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        if ($readini($dbfile(items.db), %item.name, currency) = KindredCrest) { %portals.kindredcrest = $addtok(%portals.kindredcrest, $+ %item.name $+ ( $+ %item.price $+ ),46) }
        if ($readini($dbfile(items.db), %item.name, currency) = HighKindredCrest) { %portals.highkindredcrest = $addtok(%portals.highkindredcrest, $+ %item.name $+ ( $+ %item.price $+ ),46) }
      }
      unset %item.name | unset %item_amount
      inc %value 1 
    }

    set %replacechar $chr(044) $chr(032)
    %portals.bstmen = $replace(%portals.bstmen, $chr(046), %replacechar)
    %portals.kindred = $replace(%portals.kindred, $chr(046), %replacechar)
    %portals.kindredcrest = $replace(%portals.kindredcrest, $chr(046), %replacechar)
    %portals.highkindredcrest = $replace(%portals.highkindredcrest, $chr(046), %replacechar)
    unset %replacechar

    if (%portals.bstmen != $null) {  $display.private.message.delay.custom(2These portal items are paid for with 4BeastmenSeals2: %portals.bstmen, 1)  }
    if (%portals.kindred != $null) {  $display.private.message.delay.custom(2These portal items are paid for with 4KindredSeals2: %portals.kindred, 2)  }
    if (%portals.kindredcrest != $null) {  $display.private.message.delay.custom(2These portal items are paid for with 4KindredCrests2: %portals.kindredcrest, 3)  }
    if (%portals.highkindredcrest != $null) {  $display.private.message.delay.custom(2These portal items are paid for with 4HighKindredCrests2: %portals.highkindredcrest, 3)  }

    if ((((%portals.kindred = $null) && (%portals.bstmen = $null) && (%portals.kindredcrest = $null) && (%portals.highkindredcrest = $null)))) { $display.private.message(4There are no portal items available for purchase right now)  }

    unset %portals.bstmen | unset %portals.kindred | unset %portals.kindredcrest | unset %portals.highkindredcrest | unset %item.price
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
    var %item.amount $readini($char($1), item_amount, $3)
    if (%item.amount = $null) { var %item.amount 0 }
    inc %item.amount $4
    writeini $char($1) item_amount $3 %item.amount
    $display.private.message(3A strange merchant by the name of Shami takes %total.price %currency $+ s and trades it for $4 $3 $+ $iif($4 < 2 , ,s) $+ !  "Thank you for your patronage. (heh heh heh, sucker)")
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

    var %item.amount $readini($char($1), item_amount, $3)
    if (%item.amount = $null) { var %item.amount 0 }
    inc %item.amount $4
    writeini $char($1) item_amount $3 %item.amount
    $display.private.message(3A merchant of the Allied Forces takes your %total.price Allied Notes and gives you $4 $3 $+ $iif($4 < 2, , s) $+ !)
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
alias inc.shoplevel {   
  var %shop.level $readini($char($1), stuff, shoplevel) 
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
  set %shop.level $readini($char($1), stuff, shoplevel)
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
  set %shop.level $readini($char($1), stuff, shoplevel)

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
