;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; STYLE CONTROL 
;;;; Last updated: 07/12/21
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias calculate.stylepoints {
  unset %style.rating
  if ($readini($char($1), info, flag) = monster) { return }
  var %style.points $readini($txtfile(battle2.txt), style, $1)
  if (%style.points = $null) { set %style.points 0 }

  var %boss.modifier 0
  if (%battle.type = boss) { inc %boss.modifier 100 }
  if (%portal.bonus = true) { inc %boss.modifier 100 }

  if (%style.points <= $calc(20 + %boss.modifier + $return_winningstreak))  { set %style.rating $readini(translation.dat, styles, FlatOutBoring) }
  if ((%style.points > $calc(20 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(50 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Dope) }
  if ((%style.points > $calc(50 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(75 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Don'tWorry) }
  if ((%style.points > $calc(75 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(100 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, ComeOn) }
  if ((%style.points > $calc(100 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(110 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Cool) }
  if ((%style.points > $calc(110 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(120 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Blast) }
  if ((%style.points > $calc(120 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(140 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Alright) }
  if ((%style.points > $calc(140 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(180 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Atomic) }
  if ((%style.points > $calc(180 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(250 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Sweet) }
  if ((%style.points > $calc(250 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(350 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Savage) }
  if ((%style.points > $calc(350 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(450 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, SShowtime) }
  if ((%style.points > $calc(450 + %boss.modifier + $return_winningstreak)) && (%style.points <=  $calc(550 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, SSadistic) }
  if ((%style.points > $calc(550 + %boss.modifier + $return_winningstreak)) && (%style.points <= $calc(750 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, SSStylish) }
  if ((%style.points > $calc(750 + %boss.modifier + $return_winningstreak)) && (%style.points <= $calc(1000 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, SSSensational) }
  if ((%style.points > $calc(1000 + %boss.modifier + $return_winningstreak)) && (%style.points <= $calc(3500 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, SSSSmokingHotStyle) }
  if ((%style.points > $calc(3500 + %boss.modifier + $return_winningstreak)) && (%style.points < $calc(6000 + %boss.modifier + $return_winningstreak))) { set %style.rating $readini(translation.dat, styles, Jackpot) }
  if (%style.points >= $calc(6000 + %boss.modifier + $return_winningstreak)) { set %style.rating $readini(translation.dat, styles, MaximumStyle) }
}

alias add.stylepoints {
  ; $1 = person who earns style points
  ; $2 = person who loses style points
  ; $3 = attack damage
  ; $4 = last action taken

  $decrease.stylepoints($2, $3)
  if ($readini($char($1), info, flag) = monster) { return }

  unset %style.multiplier

  set %style.multiplier $calc.stylemultiplier($1, $2, $3, $4)
  set %stylepoints.current $readini($txtfile(battle2.txt), style, $1)  

  if (($3 != mon_death) && ($3 != boss_death)) {
    if (%style.multiplier > 0) {  set %stylepoints.toadd $round($calc($3 * %style.multiplier),0) }
    else { set %stylepoints.toadd $round($calc(%stylepoints.current * %style.multiplier),0) }
  }

  if ($3 = mon_death) {  set %stylepoints.toadd $readini(system.dat, style, MonDeath) | $add.playerstyle.xp($1, $rand(1,2)) }
  if ($3 = boss_death) {  set %stylepoints.toadd $readini(system.dat, style, BossDeath) | $add.playerstyle.xp($1, $rand(3,4)) }

  if ($augment.check($1, EnhanceStylePoints) = true) { inc %stylepoints.toadd $round($calc(10 *  %augment.strength),0) }

  if (%stylepoints.current = $null) { set %stylepoints.current 0 }
  if (%stylepoints.current >= 5000) { set %stylepoints.to.add 0 }
  if (%aoe.turn > 2) { set %stylepoints.to.add 0 }
  inc %stylepoints.current %stylepoints.toadd

  if (%stylepoints.current < 0) { set %stylepoints.current 0 }
  writeini $txtfile(battle2.txt) style $1 %stylepoints.current
  unset %stylepoints.toadd | unset %stylepoints.current | unset %style.multiplier | unset %lastaction
}

alias decrease.stylepoints {
  set %stylepoints.current $readini($txtfile(battle2.txt), style, $1)  
  if ($3 <= 1) { set %stylepoints.toremove 2 } 
  if ($3 = 1) { set %stylepoints.toremove $rand(1,5) }
  else { set %stylepoints.toremove $round($calc(%stylepoints.current / 2),0) }

  if (%stylepoints.current = $null) { return }
  dec %stylepoints.current %stylepoints.toremove
  if (%stylepoints.current < 0) { set %stylepoints.current 0 }
  writeini $txtfile(battle2.txt) style $1 %stylepoints.current

  unset %stylepoints.toremove | unset %stylepoints.current
}

alias calc.stylemultiplier {
  set %lastaction $readini($txtfile(battle2.txt), style, $1 $+ .lastaction) 

  if (%lastaction = $4) { 
    if ($4 = taunt) { return -.65 }
    else { 
      if ((%aoe.turn = $null) || (%aoe.turn = 1)) {
        if ($3 <= 10) { return -.05 }
        if (($3 > 10) && ($3 < 1000)) { return -.45 }
        if (($3 >= 1000) && ($3 < 5000)) { return -.55 }
        if ($3 >= 5000) { return -.65 }
      }
    }
  }

  if (%lastaction != $4) { 
    writeini $txtfile(battle2.txt) style $1 $+ .lastaction $4
    if ((%aoe.turn = $null) || (%aoe.turn < 2)) { 
      if ($3 <= 100) { return 1.1 }
      if (($3 > 100) && ($3 < 1000)) { return 1.0 }
      if ($3 >= 1000) { return .9 }
    }
    if ((%aoe.turn > 2) && (%aoe.turn < 4)) { return .7 }
    if (%aoe.turn > 4) { return .2 }
  }
}

alias add.style.orbbonus {
  set %style.points $readini($txtfile(battle2.txt), style, $1)
  if (%style.points = $null) { %style.points = 1 }

  set %multiplier 0
  if ($2 = monster) { %multiplier = 1.25 }
  if ($2 = boss) { %multiplier = 1.4 }

  if (%battle.type = dungeon) { %multiplier = 1.35 }
  if (%battle.type = torment) { %multiplier = 0.75 }

  var %orb.bonus.flag $readini($char($3), info, OrbBonus)
  if (%orb.bonus.flag = yes) { inc %multiplier $rand(130,180) }

  set %current.orb.bonus $readini($txtfile(battle2.txt), BattleInfo, OrbBonus)
  if (%current.orb.bonus = $null) { set %current.orb.bonus 0 }

  %style.points = $round($calc(%style.points / 2),0)

  set %total.orbs.to.add $calc(%style.points * %multiplier)
  if (%total.orbs.to.add <= 0) { set %total.orbs.to.add 1 } 

  inc %current.orb.bonus %total.orbs.to.add
  writeini $txtfile(battle2.txt) BattleInfo OrbBonus %current.orb.bonus
  unset %style.points | unset %current.orb.bonus | unset %total.orbs.to.add
}

alias stylepoints.decay {
  ; $1 = player
  var %current.player.style.points $readini $txtfile(battle2.txt) style $1
  if (%current.player.style.points = $null) { return }

  var %decay.rate .10
  if (%current.player.style.points >= 8000) { inc %decay.rate .15 }

  dec %current.player.style.points $round($calc(%current.player.style.points * %decay.rate),2)
  writeini $txtfile(battle2.txt) style $1 %current.player.style.points
}

alias add.style.effectdeath {  
  set %current.orb.bonus $readini($txtfile(battle2.txt), BattleInfo, OrbBonus)
  if (%current.orb.bonus = $null) { set %current.orb.bonus 0 }

  set %total.orbs.to.add $rand(20,120)

  inc %current.orb.bonus %total.orbs.to.add

  writeini $txtfile(battle2.txt) BattleInfo OrbBonus %current.orb.bonus
  unset %style.points | unset %current.orb.bonus | unset %total.orbs.to.add
}  

alias add.playerstyle.xp {
  ; $1 = person adding xp
  ; $2 = # of xp you get

  if ($readini($char($1), info, flag) != $null) { return }

  set %current.playerstyle $readini($char($1), styles, equipped)
  if (%current.playerstyle = $null) { return } 

  set %current.playerstyle.xp $readini($char($1), styles, %current.playerstyle $+ XP)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  set %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)

  var %max.style.level 10
  if ($readini($char($1), stuff, NumberOfResets) >= 1) { inc %max.style.level 1 }

  if (%current.playerstyle.level >= %max.style.level) { return }

  if ($2 = $null) { var %style.xp.to.add 1 } 
  if ($2 != $null) { var %style.xp.to.add $2 }

  if ($accessory.check($1, Stylish) = true) { var %style.xp.to.add $calc(%style.xp.to.add * 2) }

  inc %current.playerstyle.xp %style.xp.to.add
  writeini $char($1) styles %current.playerstyle $+ XP %current.playerstyle.xp

  if (%current.playerstyle.xp >= %current.playerstyle.xptolevel) {
    inc %current.playerstyle.level 1 | writeini $char($1) styles %current.playerstyle %current.playerstyle.level
    writeini $char($1) styles %current.playerstyle $+ XP 0
    $set_chr_name($1) | $display.message($readini(translation.dat, system, PlayerStyleLevelUp), global)
  }
  unset %current.playerstyle |  unset %current.playerstyle.*
  return
}

; returns the player's current level of the style he/she has equipped
alias style.level {
  ; $1 = player
  var %current.playerstyle $readini($char($1), styles, equipped)
  return $readini($char($1), styles, %current.playerstyle)
}

alias generate_style_order {
  ; $1 = null for end of battle or BattleStyle for generating the list in battle

  unset %battle.style.order

  ; make the Battle List table
  hmake BattleTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    set %battle.style $readini($txtfile(battle2.txt), style, %who.battle)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { set %battle.style 0 }
    if ((%battle.style = $null) || (%battle.style = 0)) { set %battle.style 1 }
    hadd BattleTable %who.battle %battle.style
    inc %battletxt.current.line
  }

  ; save the BattleTable hashtable to a file
  hsave BattleTable BattleTable.file

  ; load the BattleTable hashtable (as a temporary table)
  hmake BattleTable_Temp
  hload BattleTable_Temp BattleTable.file

  ; sort the Battle Table
  hmake BattleTable_Sorted
  var %item, %data, %index, %count = $hget(BattleTable_Temp,0).item
  while (%count > 0) {
    ; step 1: get the lowest item
    %item = $hget(BattleTable_Temp,%count).item
    %data = $hget(BattleTable_Temp,%count).data
    %index = 1
    while (%index < %count) {
      if ($hget(BattleTable_Temp,%index).data < %data) {
        %item = $hget(BattleTable_Temp,%index).item
        %data = $hget(BattleTable_Temp,%index).data
      }
      inc %index
    }

    ; step 2: remove the item from the temp list
    hdel BattleTable_Temp %item

    ; step 3: add the item to the sorted list
    %index = sorted_ $+ $hget(BattleTable_Sorted,0).item
    hadd BattleTable_Sorted %index %item

    ; step 4: back to the beginning
    dec %count
  }

  ; get rid of the temp table
  hfree BattleTable_Temp

  ; Erase the old battle.txt and replace it with the new one.
  if ($1 = $null) { .remove $txtfile(battle.txt) }

  var %index = $hget(BattleTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(BattleTable_Sorted,sorted_ $+ %index)
    if ($1 = $null) { write $txtfile(battle.txt) %tmp }
    if ($1 = BattleStyle) { %battle.style.order = $addtok(%battle.style.order, %tmp, 46)
    } 
  }

  ; get rid of the sorted table
  hfree BattleTable_Sorted

  ; get rid of the Battle Table and the now un-needed file
  hfree BattleTable
  if ($isfile(BattleTable.file) = $true) { .remove BattleTable.file }

  ; unset the style rating
  unset %battle.style
}
