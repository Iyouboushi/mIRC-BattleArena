;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SHOP/EVENT NPCS
;;;; Last updated: 11/02/15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 3:TEXT:!npc status:#: {  $shopnpc.list(global) }
on 3:TEXT:!npc status:?: {  $shopnpc.list(private) }
on 3:TEXT:!npc news:#: { $shopnpc.news(global) }
on 3:TEXT:!npc news:?: { $shopnpc.news(private) }

alias shopnpc.news {
  var %npcnews.kidnapped $readini(shopnpcs.dat, NPCNews, Kidnapped) 
  var %npcnews.arrived $readini(shopnpcs.dat, NPCNews, Arrived)

  if ((%npcnews.kidnapped = $null) && (%npcnews.arrived = $null)) { 

    if ($1 = global) { $display.message($readini(translation.dat, errors, NoNPCNews),private)  }
    if ($1 = private) {  $display.private.message($readini(translation.dat, errors, NoNPCNews)) } 
    if ($1 = dcc) { $dcc.private.message($2, $readini(translation.dat, errors, NoNPCNews)) } 
    halt
  }

  if ($1 = global) {
    $display.message($readini(translation.dat, ShopNPCs, LatestNPCNews),global) 
    if (%npcnews.kidnapped != $null) { $display.message(4 $+ %npcnews.kidnapped,global) }
    if (%npcnews.arrived != $null) { $display.message(2 $+ %npcnews.arrived,global) }
  }

  if ($1 = private) {
    $display.private.message($readini(translation.dat, ShopNPCs, LatestNPCNews)) 
    if (%npcnews.kidnapped != $null) { $display.private.message(4 $+ %npcnews.kidnapped) }
    if (%npcnews.arrived != $null) { $display.private.message(2 $+ %npcnews.arrived) }
  }

  if ($1 = dcc) {
    $dcc.private.message($2, $readini(translation.dat, ShopNPCs, LatestNPCNews)) 
    if (%npcnews.kidnapped != $null) { $dcc.private.message($2, 4 $+ %npcnews.kidnapped) }
    if (%npcnews.arrived != $null) { $dcc.private.message($2, 2 $+ %npcnews.arrived) }
  }

}

alias shopnpc.list {
  var %npcstatus.healing $readini(shopnpcs.dat, NPCstatus, HealingMerchant)
  if (%npcstatus.healing = true) { var %npcstatus.healing.color 3 }
  if (%npcstatus.healing = false) { var %npcstatus.healing.color 5 }
  if (%npcstatus.healing = kidnapped) { var %npcstatus.healing.color 4 }
  var %npcstatus.healing.name $readini(shopnpcs.dat, NPCNames, HealingMerchant)
  if (%npcstatus.healing.name = $null) { var %npcstatus.healing.name Healing Merchant }

  var %npcstatus.Battle $readini(shopnpcs.dat, NPCstatus, BattleMerchant)
  if (%npcstatus.Battle = true) { var %npcstatus.Battle.color 3 }
  if (%npcstatus.Battle = false) { var %npcstatus.Battle.color 5 }
  if (%npcstatus.Battle = kidnapped) { var %npcstatus.Battle.color 4 }
  var %npcstatus.Battle.name $readini(shopnpcs.dat, NPCNames, BattleMerchant)
  if (%npcstatus.Battle.name = $null) { var %npcstatus.Battle.name Battle Merchant }

  var %npcstatus.Discount $readini(shopnpcs.dat, NPCstatus, DiscountCardMerchant)
  if (%npcstatus.Discount = true) { var %npcstatus.Discount.color 3 }
  if (%npcstatus.Discount = false) { var %npcstatus.Discount.color 5 }
  if (%npcstatus.Discount = kidnapped) { var %npcstatus.Discount.color 4 }
  var %npcstatus.Discount.name $readini(shopnpcs.dat, NPCNames, DiscountCardMerchant)
  if (%npcstatus.Discount.name = $null) { var %npcstatus.Discount.name Discount Card Merchant }

  var %npcstatus.Song $readini(shopnpcs.dat, NPCstatus, SongMerchant)
  if (%npcstatus.Song = true) { var %npcstatus.Song.color 3 }
  if (%npcstatus.Song = false) { var %npcstatus.Song.color 5 }
  if (%npcstatus.Song = kidnapped) { var %npcstatus.Song.color 4 }
  var %npcstatus.Song.name $readini(shopnpcs.dat, NPCNames, SongMerchant)
  if (%npcstatus.Song.name = $null) { var %npcstatus.Song.name Song Merchant }

  var %npcstatus.Shield $readini(shopnpcs.dat, NPCstatus, ShieldMerchant)
  if (%npcstatus.Shield = true) { var %npcstatus.Shield.color 3 }
  if (%npcstatus.Shield = false) { var %npcstatus.Shield.color 5 }
  if (%npcstatus.Shield = kidnapped) { var %npcstatus.Shield.color 4 }
  var %npcstatus.Shield.name $readini(shopnpcs.dat, NPCNames, ShieldMerchant)
  if (%npcstatus.Shield.name = $null) { var %npcstatus.Shield.name Shield Merchant }

  var %npcstatus.Wheel $readini(shopnpcs.dat, NPCstatus, WheelMaster)
  if (%npcstatus.Wheel = true) { var %npcstatus.Wheel.color 3 }
  if (%npcstatus.Wheel = false) { var %npcstatus.Wheel.color 5 }
  if (%npcstatus.Wheel = kidnapped) { var %npcstatus.Wheel.color 4 }
  var %npcstatus.Wheel.name $readini(shopnpcs.dat, NPCNames, WheelMaster)
  if (%npcstatus.Wheel.name = $null) { var %npcstatus.Wheel.name Wheel Master }

  var %npcstatus.President $readini(shopnpcs.dat, NPCstatus, AlliedForcesPresident)
  if (%npcstatus.President = true) { var %npcstatus.President.color 3 }
  if (%npcstatus.President = false) { var %npcstatus.President.color 5 }
  if (%npcstatus.President = kidnapped) { var %npcstatus.President.color 4 }
  var %npcstatus.President.name $readini(shopnpcs.dat, NPCNames, AlliedForcesPresident)
  if (%npcstatus.President.name = $null) { var %npcstatus.President.name Allied Forces President }

  var %npcstatus.Gambler $readini(shopnpcs.dat, NPCstatus, Gambler)
  if (%npcstatus.Gambler = true) { var %npcstatus.Gambler.color 3 }
  if (%npcstatus.Gambler = false) { var %npcstatus.Gambler.color 5 }
  if (%npcstatus.Gambler = kidnapped) { var %npcstatus.Gambler.color 4 }
  var %npcstatus.Gambler.name $readini(shopnpcs.dat, NPCNames, Gambler)
  if (%npcstatus.Gambler.name = $null) { var %npcstatus.Gambler.name Gambler }

  var %npcstatus.Gardener $readini(shopnpcs.dat, NPCstatus, Gardener)
  if (%npcstatus.Gardener = true) { var %npcstatus.Gardener.color 3 }
  if (%npcstatus.Gardener = false) { var %npcstatus.Gardener.color 5 }
  if (%npcstatus.Gardener = kidnapped) { var %npcstatus.Gardener.color 4 }
  var %npcstatus.Gardener.name $readini(shopnpcs.dat, NPCNames, Gardener)
  if (%npcstatus.Gardener.name = $null) { var %npcstatus.Gardener.name Gardener }

  var %npcstatus.PotionWitch $readini(shopnpcs.dat, NPCstatus, PotionWitch)
  if (%npcstatus.PotionWitch = true) { var %npcstatus.PotionWitch.color 3 }
  if (%npcstatus.PotionWitch = false) { var %npcstatus.PotionWitch.color 5 }
  if (%npcstatus.PotionWitch = kidnapped) { var %npcstatus.PotionWitch.color 4 }
  var %npcstatus.PotionWitch.name $readini(shopnpcs.dat, NPCNames, PotionWitch)
  if (%npcstatus.PotionWitch.name = $null) { var %npcstatus.PotionWitch.name PotionWitch }

  var %npcstatus.DungeonKey $readini(shopnpcs.dat, NPCstatus, DungeonKeyMerchant)
  if (%npcstatus.DungeonKey = true) { var %npcstatus.DungeonKey.color 3 }
  if (%npcstatus.DungeonKey = false) { var %npcstatus.DungeonKey.color 5 }
  if (%npcstatus.DungeonKey = kidnapped) { var %npcstatus.DungeonKey.color 4 }
  var %npcstatus.DungeonKey.name $readini(shopnpcs.dat, NPCNames, DungeonKeyMerchant)
  if (%npcstatus.DungeonKey.name = $null) { var %npcstatus.DungeonKey.name Dungeon Key Merchant }

  var %npcstatus.Travel $readini(shopnpcs.dat, NPCstatus, TravelMerchant)
  if (%npcstatus.Travel = true) { var %npcstatus.Travel.color 3 }
  if (%npcstatus.Travel = false) { var %npcstatus.Travel.color 5 }
  if (%npcstatus.Travel = kidnapped) { var %npcstatus.Travel.color 4 }
  var %npcstatus.Travel.name $readini(shopnpcs.dat, NPCNames, TravelMerchant)
  if (%npcstatus.Travel.name = $null) { var %npcstatus.Travel.name Travel Merchant }

  var %npcs.status [ $+ %npcstatus.president.color $+ %npcstatus.president.name $+ ]  [ $+ %npcstatus.healing.color $+ %npcstatus.healing.name $+ ] [ $+ %npcstatus.battle.color $+ %npcstatus.battle.name $+ ] [ $+ %npcstatus.discount.color $+ %npcstatus.discount.name $+ ] [ $+ %npcstatus.song.color $+ %npcstatus.song.name $+ ] [ $+ %npcstatus.shield.color $+ %npcstatus.shield.name $+ ]
  var %npcs.status2 [ $+ %npcstatus.dungeonkey.color $+ %npcstatus.dungeonkey.name $+ ]  [ $+ %npcstatus.potionwitch.color $+ %npcstatus.potionwitch.name $+ ] [ $+ %npcstatus.wheel.color $+ %npcstatus.wheel.name $+ ] [ $+ %npcstatus.gambler.color $+ %npcstatus.gambler.name $+ ] [ $+ %npcstatus.gardener.color $+ %npcstatus.gardener.name $+ ] [ $+ %npcstatus.travel.color $+ %npcstatus.travel.name $+ ]

  ; Check for seasonal NPCs
  if ($readini(shopnpcs.dat, NPCstatus, EasterBunny) = true) { var %seasonal.status %seasonal.status [3Easter Bunny] }
  if ($readini(shopnpcs.dat, NPCstatus, Santa) = true) { 
    var %seasonal.status %seasonal.status [3Santa] [3Number of Elves Saved:12 $readini(shopnpcs.dat,Events, SavedElves) $+ ]
  }
  if ($left($adate, 2) = 10) { var %seasonal.status %seasonal.status [7Halloween Shop is Open] }


  ; Display the NPCs

  if ($1 = global) { 
    $display.message(%npcs.status) 
    $display.message(%npcs.status2) 
    if (%seasonal.status != $null) { $display.message(%seasonal.status) }
  }
  if ($1 = private) { 
    $display.private.message(%npcs.status)
    $display.private.message(%npcs.status2)
    if (%seasonal.status != $null) {  $display.private.message(%seasonal.status) }
  }
  if ($1 = dcc) { 
    $dcc.private.message($2, %npcs.status) 
    $dcc.private.message($2, %npcs.status2)
    if (%seasonal.status != $null) { $dcc.private.message($2,%seasonal.status) }
  }

  unset %seasonal.status
}

alias shopnpc.list.oldstyle {
  var %npcstatus.healing $readini(shopnpcs.dat, NPCstatus, HealingMerchant)
  if (%npcstatus.healing = true) { var %npcstatus.healing at the Allied Forces HQ }
  if (%npcstatus.healing = false) { var %npcstatus.healing not found yet }

  var %npcstatus.battle $readini(shopnpcs.dat, NPCstatus, BattleMerchant)
  if (%npcstatus.battle = true) { var %npcstatus.battle at the Allied Forces HQ }
  if (%npcstatus.battle = false) { var %npcstatus.battle not found yet }

  var %npcstatus.discountcard $readini(shopnpcs.dat, NPCstatus, DiscountCardMerchant)
  if (%npcstatus.discountcard = true) { var %npcstatus.discountcard at the Allied Forces HQ }
  if (%npcstatus.discountcard = false) { var %npcstatus.discountcard not found yet }

  var %npcstatus.song $readini(shopnpcs.dat, NPCstatus, songMerchant)
  if (%npcstatus.song = true) { var %npcstatus.song at the Allied Forces HQ }
  if (%npcstatus.song = false) { var %npcstatus.song not found yet }

  var %npcstatus.shield $readini(shopnpcs.dat, NPCstatus, shieldMerchant)
  if (%npcstatus.shield = true) { var %npcstatus.shield at the Allied Forces HQ }
  if (%npcstatus.shield = false) { var %npcstatus.shield not found yet }

  var %npcstatus.wheel $readini(shopnpcs.dat, NPCstatus, WheelMaster)
  if (%npcstatus.wheel = true) { var %npcstatus.wheel at the Allied Forces HQ }
  if (%npcstatus.wheel = false) { var %npcstatus.wheel not found yet }

  var %npcstatus.gambler $readini(shopnpcs.dat, NPCstatus, Gambler)
  if (%npcstatus.gambler = true) { var %npcstatus.gambler at the Allied Forces HQ }
  if (%npcstatus.gambler = false) { var %npcstatus.gambler not found yet }

  var %npcstatus.gardener $readini(shopnpcs.dat, NPCstatus, gardener)
  if (%npcstatus.gardener = true) { var %npcstatus.gardener at the Allied Forces HQ }
  if (%npcstatus.gardener = false) { var %npcstatus.gardener not found yet }

  var %npcstatus.potionWitch $readini(shopnpcs.dat, NPCstatus, potionWitch)
  if (%npcstatus.potionWitch = true) { var %npcstatus.potionWitch at the Allied Forces HQ }
  if (%npcstatus.potionWitch = false) { var %npcstatus.potionWitch not found yet }

  var %npcstatus.president $readini(shopnpcs.dat, NPCstatus, AlliedForcesPresident)
  if (%npcstatus.president = true) { var %npcstatus.president at the Allied Forces HQ }
  if (%npcstatus.president = false) { var %npcstatus.president not found yet }

  var %npcstatus.travelmerchant $readini(shopnpcs.dat, NPCstatus, TravelMerchant)
  if (%npcstatus.travelmerchant = true) { var %npcstatus.travelmerchant at the Allied Forces HQ }
  if (%npcstatus.travelmerchant = false) { var %npcstatus.travelmerchant not here yet }

  var %npcstatus.dungeonkeymaster $readini(shopnpcs.dat, NPCstatus, DungeonKeyMerchant)
  if (%npcstatus.dungeonkeymaster = true) { var %npcstatus.dungeonkeymaster at the Allied Forces HQ }
  if (%npcstatus.dungeonkeymaster = false) { var %npcstatus.dungeonkeymaster not found yet }

  var %npcs.status [4Allied Forces President:12 %npcstatus.president $+ 1] [4Healing Items Merchant:12 %npcstatus.healing $+ 1] [4Battle Items Merchant:12 %npcstatus.battle $+ 1] [4Discount Card Merchant:12 %npcstatus.discountcard $+ 1]  [4Shield Merchant:12 %npcstatus.shield $+ 1] [4Dungeon Keymaster:12 %npcstatus.dungeonkeymaster $+ 1]
  var %npcs.status2 [4Bard:12 %npcstatus.song $+ 1]  [4Gardener:12 %npcstatus.gardener $+ 1] [4Wheel Minigame Master:12 %npcstatus.wheel $+ 1] [4Gambler:12 %npcstatus.gambler $+ 1] [4Traveling Merchant:12 %npcstatus.travelmerchant $+ ]  [4Potion Witch:12 %npcstatus.potionwitch $+ ] 

  var %easter.status [4Easter Bunny?12 $iif($readini(shopnpcs.dat, NPCstatus, EasterBunny) = true, at the Allied Forces HQ, not around yet) $+ 1]
  var %santa.status [4Santa Saved?12 $readini(shopnpcs.dat, NPCStatus, Santa) $+ 1] [4Number of Elves Saved:12 $readini(shopnpcs.dat,Events, SavedElves) $+ 1]
  set %seasonal.status $iif( $left($adate, 2) = 04, %easter.status) $iif( $left($adate, 2) = 12, %santa.status)

  if ($1 = global) { 
    $display.message(%npcs.status) 
    $display.message(%npcs.status2) 
    if (%seasonal.status != $null) { $display.message(%seasonal.status) }
  }
  if ($1 = private) { 
    $display.private.message(%npcs.status)
    $display.private.message(%npcs.status2)
    if (%seasonal.status != $null) {  $display.private.message(%seasonal.status) }
  }
  if ($1 = dcc) { 
    $dcc.private.message($2, %npcs.status) 
    $dcc.private.message($2, %npcs.status2)
    if (%seasonal.status != $null) { $dcc.private.message($2,%seasonal.status) }
  }

  unset %seasonal.status
}
; Check the various NPCs to see their status.
alias shopnpc.status.check {

  ; Check for Santa
  if (($shopnpc.present.check(Santa) = false) && ($readini(shopnpcs.dat, Events, FrostLegionDefeated) = true)) { $shopnpc.add(Santa) }
  if (($shopnpc.present.check(Santa) = true) && ($left($adate, 2) != 12)) { $shopnpc.remove(Santa) }

  ; Easter Bunny
  if (($shopnpc.present.check(EasterBunny) = false) && ($left($adate, 2) = 04)) { $shopnpc.add(EasterBunny) }
  if (($shopnpc.present.check(EasterBunny) = true) && ($left($adate, 2) != 04)) { $shopnpc.remove(EasterBunny) }

  ; Traveling Merchant
  var %current.day $gettok($adate,2,47)

  if ($shopnpc.present.check(TravelMerchant) = false) {
    if ((%current.day >= 15) && (%current.day <= 20)) {  $shopnpc.add(TravelMerchant)  }
  }
  if ($shopnpc.present.check(TravelMerchant) = true) { 
    if ((%current.day < 15) || (%current.day > 20)) { $shopnpc.remove(TravelMerchant) } 
  }

  ; Allied Forces President
  if ($shopnpc.present.check(AlliedForcesPresident) = false) { $shopnpc.add(AlliedForcesPresident) }

  var %need.to.check.newnpcs false
  if ($readini(shopnpcs.dat, NPCStatus, DiscountCardMerchant) = false) { var %need.to.check.newnpcs true }
  if ($readini(shopnpcs.dat, NPCStatus, HealingMerchant) = false) { var %need.to.check.newnpcs true }
  if ($readini(shopnpcs.dat, NPCStatus, BattleMerchant) = false) { var %need.to.check.newnpcs true }
  if ($readini(shopnpcs.dat, NPCStatus, SongMerchant) = false) { var %need.to.check.newnpcs true }
  if ($readini(shopnpcs.dat, NPCStatus, ShieldMerchant) = false) { var %need.to.check.newnpcs true }
  if ($readini(shopnpcs.dat, NPCStatus, PotionWitch) = false) { var %need.to.check.newnpcs true }

  if (%need.to.check.newnpcs = false) { return }

  set %player.deaths 0 
  set %player.shoplevels 0
  set %player.totalbattles 0
  set %player.totalachievements 0
  set %player.totalparries 0
  set %player.totallostsouls 0

  .echo -q $findfile( $char_path , *.char, 0 , 0, shopnpc.totalinfo $1-)

  ; Check for Healing items NPC
  if (($shopnpc.present.check(HealingMerchant) = false) && (%player.deaths >= 20)) { $shopnpc.add(HealingMerchant) }

  ; Check for discount card items NPC
  if (($shopnpc.present.check(DiscountCardMerchant) = false) && (%player.shoplevels >= 20)) { $shopnpc.add(DiscountCardMerchant) }

  ; Check for battle items NPC
  if (($shopnpc.present.check(BattleMerchant) = false) && (%player.totalbattles >= 100)) { $shopnpc.add(BattleMerchant) }

  ; Check for the song merchant NPC
  if (($shopnpc.present.check(SongMerchant) = false) && (%player.totalachievements >= 20)) { $shopnpc.add(SongMerchant) }

  ; Check for shield merchant NPC
  if (($shopnpc.present.check(ShieldMerchant) = false) && (%player.totalparries >= 100)) { $shopnpc.add(ShieldMerchant) }

  ; Check the potion witch NPC
  if (($shopnpc.present.check(PotionWitch) = false) && (%player.totallostsouls >= 200)) { $shopnpc.add(PotionWitch) }

  unset %player.deaths | unset %player.shoplevels | unset %player.totalbattles | unset %player.totalachievements
  unset %player.totallostsouls | unset %player.totalparries
}

; Is an NPC at the allied forces HQ?
alias shopnpc.present.check {
  ; $1 = npc name or npc type ("Santa" or "DIscountMerchant" for example)
  ; returns true, false or kidnapped

  var %status $readini(shopnpcs.dat, npcstatus, $1)

  if ($readini(shopnpcs.dat, NPCStatus, $1) = $null) { return false }
  if ($readini(shopnpcs.dat, NPCStatus, $1) = false) { return false }
  if ($readini(shopnpcs.dat, NPCStatus, $1) = true) { return true }
  if ($readini(shopnpcs.dat, NPCStatus, $1) = kidnapped) { return kidnapped }
}

; Add a shop NPC
alias shopnpc.add {
  writeini shopnpcs.dat NPCStatus $1 true

  var %shopnpc.name $readini(shopnpcs.dat, NPCNames, $1)
  if (%shopnpc.name = $null) { var %shopnpc.name $1 }

  if ($1 != alliedforcespresident) {  
    $display.message($readini(translation.dat, shopnpcs, AddedNPC)) 
    writeini shopnpcs.dat NPCNews Arrived  $chr(91) $+ $adate - $asctime(hh:nn tt) $+ $chr(93) $readini(translation.dat, shopnpcs, AddedNPC)
  }

  if ($1 = alliedforcespresident) {

    ; Get a random name
    var %shopnpc.name the Allied Forces President

    if ($isfile($lstfile(presidentnames.lst)) = $true) {
      var %shopnpc.name $read($lstfile(presidentnames.lst))
      $display.message($readini(translation.dat, shopnpcs, AddedNewPresident)) 
      var %shopnpc.name %shopnpc.name the Allied Forces President
    }


    if ($isfile($lstfile(presidentnames.lst)) = $false) { $display.message($readini(translation.dat, shopnpcs, AddedNewPresident))  }
    writeini shopnpcs.dat NPCNames AlliedForcesPresident %shopnpc.name

    writeini shopnpcs.dat NPCNews Arrived  $chr(91) $+ $adate - $asctime(hh:nn tt) $+ $chr(93) $readini(translation.dat, shopnpcs, AddedNewPresident)
  }

}

; Removes a shop NPC
alias shopnpc.remove { 
  writeini shopnpcs.dat NPCStatus $1 false

  var %shopnpc.name $readini(shopnpcs.dat, NPCNames, $1)
  if (%shopnpc.name = $null) { var %shopnpc.name $1 }
  $display.message($readini(translation.dat, shopnpcs, removedNPC))

  ; If it's an npc that relies on flags, like Santa, turn the flags off.
  if ($1 = Santa) { writeini shopnpcs.dat Events FrostLegionDefeated false | writeini shopnpcs.dat Events SavedElves 0 }
}

; A Shop NPC gets kidnapped.
alias shopnpc.kidnap {
  if (($readini(system.dat, system, EnableNPCKidnapping) = $null) ||  ($readini(system.dat, system, EnableNPCKidnapping) = false)) { return }
  if (($readini($txtfile(battle2.txt), BattleInfo, CanKidnapNPCS) != yes) && ($1 != dragon)) { return }

  if ($rand(1,100) <= 45) { return }
  ; Get a list of NPCs that can be kidnapped.
  if ($shopnpc.present.check(HealingMerchant) = true) { %active.npcs = $addtok(%active.npcs, HealingMerchant, 46) }
  if ($shopnpc.present.check(BattleMerchant) = true) { %active.npcs = $addtok(%active.npcs, BattleMerchant, 46) }
  if ($shopnpc.present.check(DiscountCardMerchant) = true) { %active.npcs = $addtok(%active.npcs, DiscountCardMerchant, 46) }
  if ($shopnpc.present.check(AlliedForcesPresident) = true) { %active.npcs = $addtok(%active.npcs, AlliedForcesPresident, 46) }
  if ($shopnpc.present.check(SongMerchant) = true) { %active.npcs = $addtok(%active.npcs, SongMerchant, 46) }
  if ($shopnpc.present.check(ShieldMerchant) = true) { %active.npcs = $addtok(%active.npcs, ShieldMerchant, 46) }
  if ($shopnpc.present.check(WheelMerchant) = true) { %active.npcs = $addtok(%active.npcs, WheelMerchant, 46) }
  if ($shopnpc.present.check(PotionWitch) = true) { %active.npcs = $addtok(%active.npcs, PotionWitch, 46) }
  if ($shopnpc.present.check(Gambler) = true) { %active.npcs = $addtok(%active.npcs, Gambler, 46) }

  if (%active.npcs = $null) { return }

  set %total.npcs $numtok(%active.npcs, 46)
  set %random.npc $rand(1,%total.npcs)
  set %kidnapped.npc $gettok(%active.npcs,%random.npc,46)

  set %shopnpc.name $readini(shopnpcs.dat, NPCNames, %kidnapped.npc)
  if (%shopnpc.name = $null) { var %shopnpc.name %kidnapped.npc }

  writeini shopnpcs.dat NPCStatus %kidnapped.npc kidnapped

  if ($1 != dragon) { $display.message($readini(translation.dat, shopnpcs, ShopNPCKidnapped)) | writeini shopnpcs.dat NPCNews Kidnapped $chr(91) $+ $adate - $asctime(hh:nn tt) $+ $chr(93) $readini(translation.dat, shopnpcs, ShopNPCKidnapped) }
  if ($1 = dragon) { 

    var %current.dragon $ini($dbfile(dragonhunt.db),  $rand(1, $ini($dbfile(dragonhunt.db),0)))
    var %dragon.name $readini($dbfile(dragonhunt.db), %current.dragon, name)
    $display.message($readini(translation.dat, shopnpcs, ShopNPCKidnappedDragon)) 
    writeini shopnpcs.dat NPCNews Kidnapped $chr(91) $+ $adate - $asctime(hh:nn tt) $+ $chr(93) $readini(translation.dat, shopnpcs, ShopNPCKidnappedDragon)
    unset %random.dragon | unset %dragon.name
  }
  unset %active.npcs | unset %kidnapped.npc |  unset %total.npcs | unset %random.npc | unset %shopnpc.name
}

; A Shop NPC gets rescued
alias shopnpc.rescue {
  if (($readini(system.dat, system, EnableNPCKidnapping) = $null) ||  ($readini(system.dat, system, EnableNPCKidnapping) = false)) { return }
  if ($readini($txtfile(battle2.txt), BattleInfo, CanKidnapNPCS) != yes) { return }
  if ($rand(0, 100) <= 15) { return }

  ; Get a list of NPCs that have been kidnapped.
  if ($shopnpc.present.check(HealingMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, HealingMerchant, 46) }
  if ($shopnpc.present.check(BattleMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, BattleMerchant, 46) }
  if ($shopnpc.present.check(DiscountCardMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, DiscountCardMerchant, 46) }
  if ($shopnpc.present.check(ShieldMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, ShieldMerchant, 46) }
  if ($shopnpc.present.check(SongMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, SongMerchant, 46) }
  if ($shopnpc.present.check(WheelMaster) = kidnapped) { %active.npcs = $addtok(%active.npcs, WheelMaster, 46) }
  if ($shopnpc.present.check(Gardener) = kidnapped) { %active.npcs = $addtok(%active.npcs, Gardener, 46) }
  if ($shopnpc.present.check(PotionWitch) = kidnapped) { %active.npcs = $addtok(%active.npcs, PotionWitch, 46) }
  if ($shopnpc.present.check(Gambler) = kidnapped) { %active.npcs = $addtok(%active.npcs, Gambler, 46) }
  if ($shopnpc.present.check(DungeonKeyMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, DungeonKeyMerchant, 46) } 

  if (%active.npcs = $null) { return }

  set %total.npcs $numtok(%active.npcs, 46)
  set %random.npc $rand(1,%total.npcs)
  set %kidnapped.npc $gettok(%active.npcs,%random.npc,46)

  set %shopnpc.name $readini(shopnpcs.dat, NPCNames, %kidnapped.npc)
  if (%shopnpc.name = $null) { var %shopnpc.name %kidnapped.npc }

  writeini shopnpcs.dat NPCStatus %kidnapped.npc true

  $display.message($readini(translation.dat, shopnpcs, ShopNPCRescued)) 
  writeini shopnpcs.dat NPCNews Arrived $chr(91) $+ $adate - $asctime(hh:nn tt) $+ $chr(93) $readini(translation.dat, shopnpcs, ShopNPCRescued)

  unset %active.npcs | unset %kidnapped.npc |  unset %total.npcs | unset %random.npc | unset %shopnpc.name


}
alias shopnpc.event.saveelf {
  if ($shopnpc.present.check(Santa) = true) { 
    var %total.elves.saved $readini(shopnpcs.dat, events, SavedElves)
    if (%total.elves.saved = $null) { var %total.elves.saved 0 }
    inc %total.elves.saved 1 
    writeini shopnpcs.dat events SavedElves %total.elves.saved
    $display.message($readini(translation.dat, shopnpcs, SavedElf))
  }
}
