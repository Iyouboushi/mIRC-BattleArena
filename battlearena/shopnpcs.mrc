;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SHOP/EVENT NPCS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 3:TEXT:!npc status:*: {  $shopnpc.list(global) }
on 3:TEXT:!npc status:?: {  $shopnpc.list(private) }

alias shopnpc.list {

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

  var %npcstatus.president $readini(shopnpcs.dat, NPCstatus, AlliedForcesPresident)
  if (%npcstatus.president = true) { var %npcstatus.president at the Allied Forces HQ }
  if (%npcstatus.president = false) { var %npcstatus.president not found yet }

  var %npcs.status [4Allied Forces President:12 %npcstatus.president $+ 1] [4Healing Items Merchant:12 %npcstatus.healing $+ 1] [4Battle Items Merchant:12 %npcstatus.battle $+ 1] [4Discount Card Merchant:12 %npcstatus.discountcard $+ 1]  [4Bard:12 %npcstatus.song $+ 1]
  var %easter.status [4Easter Bunny?12 $iif($readini(shopnpcs.dat, NPCstatus, EasterBunny) = true, at the Allied Forces HQ, not around yet) $+ 1]
  var %santa.status [4Santa Saved?12 $readini(shopnpcs.dat, NPCStatus, Santa) $+ 1] [4Number of Elves Saved:12 $readini(shopnpcs.dat,Events, SavedElves) $+ 1]
  set %seasonal.status $iif( $left($adate, 2) = 04, %easter.status) $iif( $left($adate, 2) = 12, %santa.status)

  if ($1 = global) { 
    $display.system.message(%npcs.status) 
    if (%seasonal.status != $null) { $display.system.message(%seasonal.status) }
  }
  if ($1 = private) { 
    .msg $nick %npcs.status
    if (%seasonal.status != $null) {  .msg $nick %seasonal.status }
  }
  if ($1 = dcc) { 
    $dcc.private.message($2, %npcs.status)
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

  ; Allied Forces President
  if ($shopnpc.present.check(AlliedForcesPresident) = false) { $shopnpc.add(AlliedForcesPresident) }

  set %player.deaths 0 
  set %player.shoplevels 0
  set %player.totalbattles 0
  set %player.totalachievements

  .echo -q $findfile( $char_path , *.char, 0 , 0, shopnpc.totalinfo $1-)

  ; Check for Healing items NPC
  if (($shopnpc.present.check(HealingMerchant) = false) && (%player.deaths >= 20)) { $shopnpc.add(HealingMerchant) }

  ; Check for discount card items NPC
  if (($shopnpc.present.check(DiscountCardMerchant) = false) && (%player.shoplevels >= 20)) { $shopnpc.add(DiscountCardMerchant) }

  ; Check for battle items NPC
  if (($shopnpc.present.check(BattleMerchant) = false) && (%player.totalbattles >= 100)) { $shopnpc.add(BattleMerchant) }

  ; Check for the song merchant NPC
  if (($shopnpc.present.check(SongMerchant) = false) && (%player.totalachievements >= 20)) { $shopnpc.add(SongMerchant) }

  unset %player.deaths | unset %player.shoplevels | unset %player.totalbattles | unset %player.totalachievements

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

  if ($1 != alliedforcespresident) {  $display.system.message($readini(translation.dat, shopnpcs, AddedNPC)) }
}

; Removes a shop NPC
alias shopnpc.remove { 
  writeini shopnpcs.dat NPCStatus $1 false

  var %shopnpc.name $readini(shopnpcs.dat, NPCNames, $1)
  if (%shopnpc.name = $null) { var %shopnpc.name $1 }
  $display.system.message($readini(translation.dat, shopnpcs, removedNPC))

  ; If it's an npc that relies on flags, like Santa, turn the flags off.
  if ($1 = Santa) { writeini shopnpcs.dat Events FrostLegionDefeated false | writeini shopnpcs.dat Events SavedElves 0 }
}

; A Shop NPC gets kidnapped.
alias shopnpc.kidnap {
  ; If allow kidnapping = false return

  if (($readini(system.dat, system, EnableNPCKidnapping) = $null) ||  ($readini(system.dat, system, EnableNPCKidnapping) = false)) { return }
  if ($readini($txtfile(battle2.txt), BattleInfo, CanKidnapNPCS) != yes) { return }
  if ($rand(1,100) <= 50) { return }

  ; Get a list of NPCs that can be kidnapped.
  if ($shopnpc.present.check(HealingMerchant) = true) { %active.npcs = $addtok(%active.npcs, HealingMerchant, 46) }
  if ($shopnpc.present.check(BattleMerchant) = true) { %active.npcs = $addtok(%active.npcs, BattleMerchant, 46) }
  if ($shopnpc.present.check(DiscountCardMerchant) = true) { %active.npcs = $addtok(%active.npcs, DiscountCardMerchant, 46) }
  if ($shopnpc.present.check(AlliedForcesPresident) = true) { %active.npcs = $addtok(%active.npcs, AlliedForcesPresident, 46) }

  if (%active.npcs = $null) { return }

  set %total.npcs $numtok(%active.npcs, 46)
  set %random.npc $rand(1,%total.npcs)
  set %kidnapped.npc $gettok(%active.npcs,%random.npc,46)

  set %shopnpc.name $readini(shopnpcs.dat, NPCNames, %kidnapped.npc)
  if (%shopnpc.name = $null) { var %shopnpc.name %kidnapped.npc }

  writeini shopnpcs.dat NPCStatus %kidnapped.npc kidnapped

  $display.system.message($readini(translation.dat, shopnpcs, ShopNPCKidnapped)) 

  unset %active.npcs | unset %kidnapped.npc |  unset %total.npcs | unset %random.npc | unset %shopnpc.name

}

; A Shop NPC gets rescued
alias shopnpc.rescue {
  if (($readini(system.dat, system, EnableNPCKidnapping) = $null) ||  ($readini(system.dat, system, EnableNPCKidnapping) = false)) { return }
  if ($readini($txtfile(battle2.txt), BattleInfo, CanKidnapNPCS) != yes) { return }
  if ($rand(1,100) <= 0) { return }

  ; Get a list of NPCs that have been kidnapped.
  if ($shopnpc.present.check(HealingMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, HealingMerchant, 46) }
  if ($shopnpc.present.check(BattleMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, BattleMerchant, 46) }
  if ($shopnpc.present.check(DiscountCardMerchant) = kidnapped) { %active.npcs = $addtok(%active.npcs, DiscountCardMerchant, 46) }

  if (%active.npcs = $null) { return }

  set %total.npcs $numtok(%active.npcs, 46)
  set %random.npc $rand(1,%total.npcs)
  set %kidnapped.npc $gettok(%active.npcs,%random.npc,46)

  set %shopnpc.name $readini(shopnpcs.dat, NPCNames, %kidnapped.npc)
  if (%shopnpc.name = $null) { var %shopnpc.name %kidnapped.npc }

  writeini shopnpcs.dat NPCStatus %kidnapped.npc true

  $display.system.message($readini(translation.dat, shopnpcs, ShopNPCRescued)) 

  unset %active.npcs | unset %kidnapped.npc |  unset %total.npcs | unset %random.npc | unset %shopnpc.name


}

alias shopnpc.event.saveelf {
  if ($shopnpc.present.check(Santa) = true) { 
    var %total.elves.saved $readini(shopnpcs.dat, events, SavedElves)
    if (%total.elves.saved = $null) { var %total.elves.saved 0 }
    inc %total.elves.saved 1 
    writeini shopnpcs.dat events SavedElves %total.elves.saved
    $display.system.message($readini(translation.dat, shopnpcs, SavedElf))
  }
}
