;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function will pick a 
; random boss type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_boss_type {

  if (%savethepresident = on) { set %boss.type normal | return } 
  if (%battle.type = defendoutpost) { set %boss.type normal | return }
  if ($return_winningstreak <= 10) { set %boss.type normal | return }

  set %boss.choices normal
  var %enable.doppelganger $readini(system.dat, system, EnableDoppelganger)
  var %enable.warmachine $readini(system.dat, system, EnableWarMachine)
  var %enable.bandits $readini(system.dat, system, EnableBandits)
  var %enable.pirates $readini(system.dat, system, EnablePirates)
  var %enable.goblins $readini(system.dat, system, EnableGoblins)
  var %enable.gremlins $readini(system.dat, system, EnableGremlins)
  var %enable.crystalshadow $readini(system.dat, system, EnableCrystalShadow)

  var %winning.streak.check $readini(battlestats.dat, battle, winningstreak)
  if (%mode.gauntlet.wave != $null) { inc %winning.streak.check %mode.gauntlet.wave }

  if ((%winning.streak.check < 50) || (%winning.streak.check > 200)) { var %enable.bandits false }
  if ((%winning.streak.check < 50) || (%winning.streak.check > 100)) { var %enable.doppelganger false }
  if ((%winning.streak.check < 50) || (%winning.streak.check > 200)) { var %enable.gremlins false }
  if ((%winning.streak.check < 75) || (%winning.streak.check > 200)) { var %enable.goblins false }
  if (%winning.streak.check >= 250) { var %enable.warmachine false } 
  if ((%winning.streak.check < 75) || (%winning.streak.check > 200)) { var %enable.pirates false }
  if (%winning.streak.check >= 500) { var %enable.pirates false } 
  if ((%winning.streak.check > 75) && (%winning.streak.check < 200)) { 
    if ($readini(system.dat, system, AllowDemonwall) = yes) { var %enable.demonwall true }
  }
  if ((%winning.streak.check >= 200) && (%winning.streak.check <= 5000)) { var %enable.elderdragon true }

  if ((%winning.streak.check >= 200) && (%winning.streak.check <= 5000)) { 
    if ($readini(system.dat, system, AllowWallOfFlesh) = yes) { var %enable.wallofflesh true }
  }

  if (%mode.gauntlet = on) { var %enable.demonwall false }

  if (($left($adate, 2) = 12) && (%winning.streak.check >= 20)) { %boss.choices = %boss.choices $+ .FrostLegion }

  var %boss.chance $rand(1,100)

  if ((%enable.doppelganger = true) && (%boss.chance <= 10)) { %boss.choices = %boss.choices $+ .doppelganger }
  if ((%enable.warmachine = true) && (%boss.chance <= 20)) { %boss.choices = %boss.choices $+ .warmachine }
  if ((%enable.bandits = true) && (%boss.chance <= 5)) { %boss.choices = %boss.choices $+ .bandits }
  if ((%enable.gremlins = true) && (%boss.chance <= 5)) { %boss.choices = %boss.choices $+ .gremlins }
  if ((%enable.crystalshadow = true) && (%boss.chance <= 15)) { 
    if (%winning.streak.check > 15) { %boss.choices = %boss.choices $+ .crystalshadow }
  }

  if (%enable.pirates = true) {
    if ((%winning.streak.check >= 15) && (%winning.streak.check <= 500)) { %boss.choices = %boss.choices $+ .pirates }
  }

  if ((%enable.wallofflesh = true) && (%boss.chance <= 10)) { %boss.choices = %boss.choices $+ .demonwall }
  if ((%enable.demonwall = true) && (%boss.chance <= 15)) { %boss.choices = %boss.choices $+ .demonwall }
  if ((%enable.elderdragon = true) && (%boss.chance < 20)) { %boss.choices = %boss.choices $+ .elderdragon }

  ; Choose a boss type

  if (%battle.type = ai) { set %boss.choices normal.warmachine.normal.demonwall.wallofflesh.normal.elderdragon.normal }

  set %total.types $numtok(%boss.choices, 46)
  set %random.type $rand(1,%total.types)
  set %boss.type $gettok(%boss.choices,%random.type,46)

  unset %total.types | unset %boss.choices | unset %random.type
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the evil doppelgangers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_evil_clones {
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      .copy $char(%who.battle) $char(Evil_ $+ %who.battle)

      ; Copy the battle stats over to basestats to account for level sync
      writeini $char(evil_ $+ %who.battle) basestats str $readini($char(%who.battle), battle, str)
      writeini $char(evil_ $+ %who.battle) basestats def $readini($char(%who.battle), battle, def)
      writeini $char(evil_ $+ %who.battle) basestats int $readini($char(%who.battle), battle, int)
      writeini $char(evil_ $+ %who.battle) basestats spd $readini($char(%who.battle), battle, spd)

      writeini $char(evil_ $+ %who.battle) info flag monster 
      writeini $char(evil_ $+ %who.battle) info clone yes
      writeini $char(evil_ $+ %who.battle) info Doppelganger yes
      writeini $char(evil_ $+ %who.battle) Basestats name Evil Doppelganger of %who.battle
      writeini $char(evil_ $+ %who.battle) info password .8V%N)W1T;W5C:'1H:7,`1__.154
      $boost_monster_stats(evil_ $+ %who.battle, doppelganger)
      $fulls(evil_ $+ %who.battle) 
      $clear_status(evil_ $+ %who.battle)
      $clear_skills(evil_ $+ %who.battle) 
      writeini $char(evil_ $+ %who.battle) status FinalGetsuga yes
      writeini $char(evil_ $+ %who.battle) info OrbBonus yes
      set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,evil_ $+ %who.battle,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) evil_ $+ %who.battle
      $set_chr_name(evil_ $+ %who.battle) 

      var %style.chance $rand(1,3)
      if (%style.chance = 1) { writeini $char(evil_ $+ %who.battle) styles equipped trickster }
      if (%style.chance = 2) { writeini $char(evil_ $+ %who.battle) styles equipped guardian }
      if (%style.chance = 3) { writeini $char(evil_ $+ %who.battle) styles equipped weaponmaster }

      writeini $char(evil_ $+ %who.battle) status resist-fire no | writeini $char(evil_ $+ %who.battle) status resist-lightning no | writeini $char(evil_ $+ %who.battle) status resist-ice no
      writeini $char(evil_ $+ %who.battle) status resist-earth no | writeini $char(evil_ $+ %who.battle) status resist-wind no | writeini $char(evil_ $+ %who.battle) status resist-water no
      writeini $char(evil_ $+ %who.battle) status resist-light no | writeini $char(evil_ $+ %who.battle) status resist-dark no
      writeini $char(evil_ $+ %who.battle) status revive no

      writeini $txtfile(battle2.txt) BattleInfo CanKidnapNPCs yes

      $display.message($readini(translation.dat, battle, EnteredTheBattle),battle)

      var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
      inc %battletxt.current.line 1 
    }
  }

  var %random.chest $rand(1,2)
  if (%random.chest = 1) { set %chest chest_green.lst }
  if (%random.chest = 2) { set %chest chest_silver.lst }

  var %items.lines $lines($lstfile(%chest))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(%chest)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  unset %chest 

  if (%boss.item = $null) { var %boss.item ethrune }

  writeini $txtfile(battle2.txt) battle bonusitem %boss.item | unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the warmachine boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_monster_warmachine {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  if ((%current.battlestreak >= 1) && (%current.battlestreak < 50)) { 
    set %monster.name Small_Warmachine | set %monster.realname Small Warmachine 
    if (%current.battlestreak > $return_levelCapSettingMonster(SmallWarmachine)) { set %current.battlestreak $return_levelCapSettingMonster(SmallWarmachine) } 
  }
  if ((%current.battlestreak >= 50) && (%current.battlestreak < 75)) { 
    set %monster.name Medium_Warmachine | set %monster.realname Medium Warmachine | writeini $char(%monster.name) info OrbBonus yes
    if (%current.battlestreak > $return_levelCapSettingMonster(MediumWarmachine)) { set %current.battlestreak $return_levelCapSettingMonster(MediumWarmachine) } 
  }
  if (%current.battlestreak >= 75) {  
    set %monster.name Large_Warmachine | set %monster.realname Large Warmachine | writeini $char(%monster.name) info OrbBonus yes
    if (%current.battlestreak > $return_levelCapSettingMonster(LargeWarmachine)) { set %current.battlestreak $return_levelCapSettingMonster(LargeWarmachine) } 
  }

  if (%battle.type = ai) { set %current.battlestreak %ai.battle.level }

  .copy -o $char(new_chr) $char(%monster.name)

  if (%battle.type = ai) { set %ai.monster.name %monster.realname | writeini $txtfile(1vs1bet.txt) money monsterfile %monster.name }

  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info bosslevel %current.battlestreak
  writeini $char(%monster.name) info CanTaunt false

  var %base.hp.tp $calc(7 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  if (%battle.type != ai) {  writeini $char(%monster.name) basestats hp $iif($return_playersinbattle > 1, $rand(5000,6000), $rand(2000,3000)) }

  writeini $char(%monster.name) basestats str $rand(25,50)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(60,75)
  writeini $char(%monster.name) basestats spd $rand(5,15)

  var %base.stats $calc($rand(1,3) * %current.battlestreak)
  writeini $char(%monster.name) basestats str %base.stats
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats def %base.stats
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats int %base.stats
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats spd %base.stats

  writeini $char(%monster.name) techniques FirajaII %current.battlestreak
  writeini $char(%monster.name) techniques Quake %current.battlestreak
  writeini $char(%monster.name) techniques Flare %current.battlestreak
  writeini $char(%monster.name) techniques Tornado %current.battlestreak
  writeini $char(%monster.name) techniques Poison %current.battlestreak
  writeini $char(%monster.name) techniques Blind %current.battlestreak
  writeini $char(%monster.name) techniques AsuranFists %current.battlestreak

  writeini $char(%monster.name) weapons equipped WarMachine
  writeini $char(%monster.name) weapons WarMachine %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills Utsusemi 1

  $boost_monster_stats(%monster.name, warmachine)
  $fulls(%monster.name, warmachine)
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 

  if (%battle.type != ai) { $display.message($readini(translation.dat, battle, EnteredTheBattle),battle)   }
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  var %random.chest $rand(1,2)
  if (%random.chest = 1) { set %chest chest_green.lst }
  if (%random.chest = 2) { set %chest chest_orange.lst }

  var %items.lines $lines($lstfile(%chest))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(%chest)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  unset %chest 

  writeini $txtfile(battle2.txt) BattleInfo CanKidnapNPCs yes

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; an elder dragon boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_elderdragon {
  var %current.battlestreak $calc($readini(battlestats.dat, Battle, WinningStreak) - 5)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  if (%current.battlestreak > $return_levelCapSettingMonster(ElderDragon)) { set %current.battlestreak $return_levelCapSettingMonster(ElderDragon) } 

  if (%battle.type = ai) { set %current.battlestreak %ai.battle.level }

  var %surname The Fierce.The Destroyer.The Evil.The Berserk.The Chaos.Bloodspawn.Bloodtear.Bloodfang.The Fierce

  set %names.lines $lines($lstfile(dragonnames.lst))
  if ((%names.lines = $null) || (%names.lines = 0)) { write $lstfile(dragonnames.lst) Nasith | var %names.lines 1 }

  set %random.firstname $rand(1,%names.lines)
  set %first.name $read($lstfile(dragonnames.lst), %random.firstname)
  set %lastnames.total $numtok(%surname,46)
  set %random.lastname $rand(1, %lastnames.total) 
  set %last.name $gettok(%surname,%random.lastname,46)

  var %elderdragon.name %first.name %last.name
  if (%battle.type != ai) {
    $display.message($readini(translation.dat, events, ElderDragonFight),battle) 
  }

  var %monster.name %first.name
  .copy -o $char(new_chr) $char(%first.name)

  var %boss.level %current.battlestreak

  if (%battle.type = ai) { set %ai.monster.name %elderdragon.name | writeini $txtfile(1vs1bet.txt) money monsterfile %first.name }

  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %elderdragon.name
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info bosslevel %boss.level
  writeini $char(%monster.name) info OrbBonus yes 
  writeini $char(%monster.name) descriptions char is a large and powerful Elder Dragon, recently awoken from its long slumber in the earth.
  writeini $char(%monster.name) monster type dragon
  writeini $char(%monster.name) info CanTaunt false

  var %base.hp.tp $round($calc(5 * %current.battlestreak),0)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) battle str $rand(19,25)
  writeini $char(%monster.name) battle def $rand(15,20)
  writeini $char(%monster.name) battle int $rand(12,19)
  writeini $char(%monster.name) battle spd $rand(18,30)

  writeini $char(%monster.name) techniques FangRush %current.battlestreak
  writeini $char(%monster.name) techniques SpikeFlail $calc(%current.battlestreak + 1)
  writeini $char(%monster.name) techniques AbsoluteTerror %current.battlestreak
  writeini $char(%monster.name) techniques DragonFire $calc(%current.battlestreak + 5) 

  writeini $char(%monster.name) weapons equipped DragonFangs
  writeini $char(%monster.name) weapons DragonFangs %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills Utsusemi 1
  writeini $char(%monster.name) skills MonsterConsume 1
  writeini $char(%monster.name) skills resist-charm 100
  writeini $char(%monster.name) skills resist-stun 80
  writeini $char(%monster.name) skills Resist-blind 80
  writeini $char(%monster.name) skills Resist-poison 75
  writeini $char(%monster.name) skills Resist-slow 60
  writeini $char(%monster.name) skills Resist-Weaponlock 100

  set %current.battlefield Ancient Dragon Burial Site
  writeini $dbfile(battlefields.db) weather current Calm

  set %magic.types light.dark.fire.ice.water.lightning.wind.earth
  set %number.of.magic.types $numtok(%magic.types,46)

  writeini $char(%monster.name) modifiers light 100
  writeini $char(%monster.name) modifiers dark 100
  writeini $char(%monster.name) modifiers fire 100
  writeini $char(%monster.name) modifiers ice 100
  writeini $char(%monster.name) modifiers water 100
  writeini $char(%monster.name) modifiers lightning 100
  writeini $char(%monster.name) modifiers wind 100
  writeini $char(%monster.name) modifiers earth 100

  writeini $char(%monster.name) NaturalArmor Name Dragon Scales
  writeini $char(%monster.name) NaturalArmor Max %current.battlestreak
  writeini $char(%monster.name) NaturalArmor Current %current.battlestreak

  var %numberof.weaknesses 1

  var %value 1
  while (%value <= %numberof.weaknesses) {
    set %weakness.number $rand(1,%number.of.magic.types)
    %weakness = $gettok(%magic.types,%weakness.number,46)
    if (%weakness != $null) {  writeini $char(%monster.name) modifiers %weakness 120 }
    inc %value
  }

  var %numberof.strengths $rand(1,4)

  var %value 1
  while (%value <= %numberof.strengths) {
    set %strength.number $rand(1,%number.of.magic.types)
    %strengths = $gettok(%magic.types,%strength.number,46)
    if (%strengths != $null) {  writeini $char(%monster.name) modifiers %strengths 40 }
    inc %value
  }

  var %numberof.heal $rand(1,3)

  var %value 1
  while (%value <= %numberof.heal) {
    set %heal.number $rand(1,%number.of.magic.types)
    %heals = $addtok(%heals, $gettok(%magic.types,%heal.number,46),46)
    inc %value
  }

  if (%heals != $null) { writeini $char(%monster.name) modifiers Heal %heals }

  unset %heal.number | unset %heals
  unset %strengths | unset %strength.number
  unset %weakness | unset %weakness.number
  unset %number.of.magic.types | unset %magic.types

  writeini $char(%monster.name) modifiers HandToHand 40
  writeini $char(%monster.name) modifiers Whip 40
  writeini $char(%monster.name) modifiers sword 60
  writeini $char(%monster.name) modifiers gun 40
  writeini $char(%monster.name) modifiers rifle 40
  writeini $char(%monster.name) modifiers katana 60
  writeini $char(%monster.name) modifiers wand 20
  writeini $char(%monster.name) modifiers spear 70
  writeini $char(%monster.name) modifiers scythe 70
  writeini $char(%monster.name) modifiers GreatSword 70
  writeini $char(%monster.name) modifiers bow 20
  writeini $char(%monster.name) modifiers glyph 60

  $levelsync(%monster.name, %boss.level)
  writeini $char(%monster.name) basestats str $readini($char(%monster.name), battle, str)
  writeini $char(%monster.name) basestats def $readini($char(%monster.name), battle, def)
  writeini $char(%monster.name) basestats int $readini($char(%monster.name), battle, int)
  writeini $char(%monster.name) basestats spd $readini($char(%monster.name), battle, spd)

  $fulls(%monster.name, elderdragon) 
  $boost_monster_hp(%monster.name, elderdragon, %boss.level)
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name)
  if (%battle.type != ai) { $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) }
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname
  unset %random.firstname | unset %first.name | unset %lastnames.total | unset %random.lastname | unset %last.name | unset %names.lines

  var %random.chest $rand(1,2)
  if (%random.chest = 1) { set %chest chest_gold.lst }
  if (%random.chest = 2) { set %chest chest_silver.lst }

  var %items.lines $lines($lstfile(%chest))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(%chest)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  unset %chest 

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the demon wall boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_demonwall {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  if (%current.battlestreak > $return_levelCapSettingMonster(DemonWall)) { set %current.battlestreak $return_levelCapSettingMonster(DemonWall) } 

  if (%battle.type = ai) { set %current.battlestreak %ai.battle.level }

  set %monster.name Demon_Wall | set %monster.realname Demon Wall

  .copy -o $char(new_chr) $char(%monster.name)
  if (%battle.type = ai) { set %ai.monster.name Demon Wall | writeini $txtfile(1vs1bet.txt) money monsterfile %monster.name }

  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info BattleStats ignoreHP
  writeini $char(%monster.name) info OrbBonus yes
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  var %base.hp.tp $calc(7 * %current.battlestreak)
  if (%battle.type != ai) {  writeini $char(%monster.name) basestats hp $iif($return_playersinbattle > 1, $rand(10000,15000), $rand(12000,16000)) }
  if (%battle.type = ai) {  writeini $char(%monster.name) basestats hp $rand(20000,25000) }

  writeini $char(%monster.name) basestats tp %base.hp.tp
  writeini $char(%monster.name) basestats str $round($calc(%current.battlestreak / 1.2),0)
  writeini $char(%monster.name) basestats def $round($calc(%current.battlestreak / 7),0)
  writeini $char(%monster.name) basestats int $round($calc(%current.battlestreak / 6),0)
  var %base.stats $calc($rand(1,3) * %current.battlestreak)
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats spd %base.stats
  writeini $char(%monster.name) info CanTaunt false

  writeini $char(%monster.name) techniques FirajaII %current.battlestreak
  writeini $char(%monster.name) techniques Poison %current.battlestreak
  writeini $char(%monster.name) techniques Slow %current.battlestreak
  writeini $char(%monster.name) techniques Blind %current.battlestreak
  writeini $char(%monster.name) techniques Petrify %current.battlestreak

  writeini $char(%monster.name) weapons equipped DemonWall
  writeini $char(%monster.name) weapons DemonWall %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills manawall.on on
  writeini $char(%monster.name) skills royalguard.on on
  writeini $char(%monster.name) skills MagicMirror 10
  writeini $char(%monster.name) skills Resist-blind 100
  writeini $char(%monster.name) skills Resist-slow 100
  writeini $char(%monster.name) skills Resist-stun 100
  writeini $char(%monster.name) skills Resist-Weaponlock 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian 1

  var %reflect.chance $rand(1,100)
  if (%reflect.chance <= 40) { writeini $char(%monster.name) status reflect yes | writeini $char(%monster.name) status reflect.timer 1 }

  $fulls(%monster.name)
  $boost_monster_stats(%monster.name, demonwall)
  $levelsync(%monster.name, %current.battlestreak)

  set %number.of.monsters.needed 0

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  if (%battle.type != ai) { $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) }

  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  set %current.battlefield Dead-End Hallway
  writeini $dbfile(battlefields.db) weather current Gloomy

  var %items.lines $lines($lstfile(chest_gold.lst))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(chest_gold.lst)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the wall of flesh boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_wallofflesh {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  if (%current.battlestreak > $return_levelCapSettingMonster(WallOfFlesh)) { set %current.battlestreak $return_levelCapSettingMonster(WallOfFlesh) } 

  if (%battle.type = ai) { set %current.battlestreak %ai.battle.level }

  set %monster.name Wall_of_Flesh | set %monster.realname Wall of Flesh

  .copy -o $char(new_chr) $char(%monster.name)
  if (%battle.type = ai) { set %ai.monster.name Wall of Flesh | writeini $txtfile(1vs1bet.txt) money monsterfile %monster.name }

  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info BattleStats ignoreHP
  writeini $char(%monster.name) info OrbBonus yes
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  writeini $char(%monster.name) descriptions Snatch reaches out with a long tonge and attempts to latch onto %enemy to use as a human shield.

  var %base.hp.tp $calc(7 * %current.battlestreak)
  if (%battle.type != ai) {  writeini $char(%monster.name) basestats hp $iif($return_playersinbattle > 1, $rand(15000,17000), $rand(13000,16000)) }
  if (%battle.type = ai) {  writeini $char(%monster.name) basestats hp $rand(20000,25000) }

  writeini $char(%monster.name) basestats tp %base.hp.tp
  writeini $char(%monster.name) basestats str $round($calc(%current.battlestreak / 5),0)
  writeini $char(%monster.name) basestats def $round($calc(%current.battlestreak / 6),0)
  writeini $char(%monster.name) basestats int $round($calc(%current.battlestreak / 3),0)
  var %base.stats $calc($rand(1,2) * %current.battlestreak)
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats spd %base.stats
  writeini $char(%monster.name) info CanTaunt false

  writeini $char(%monster.name) techniques WoFEyeLaser %current.battlestreak
  writeini $char(%monster.name) techniques WoFMouthBite %current.battlestreak

  writeini $char(%monster.name) weapons equipped WallofFleshMouth
  writeini $char(%monster.name) weapons WallofFleshMouth %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills snatch 15
  writeini $char(%monster.name) skills speed 2
  writeini $char(%monster.name) skills manawall.on on
  writeini $char(%monster.name) skills royalguard.on on
  writeini $char(%monster.name) skills MagicMirror 10
  writeini $char(%monster.name) skills Resist-blind 100
  writeini $char(%monster.name) skills Resist-slow 100
  writeini $char(%monster.name) skills Resist-Weaponlock 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian 2

  writeini $char(%monster.name) modifiers Fire 60
  writeini $char(%monster.name) modifiers Gun 170
  writeini $char(%monster.name) modifiers Rifle 200
  writeini $char(%monster.name) modifiers Bow 120

  var %reflect.chance $rand(1,100)
  if (%reflect.chance <= 70) { writeini $char(%monster.name) status reflect yes | writeini $char(%monster.name) status reflect.timer 1 }

  $fulls(%monster.name) 
  $boost_monster_stats(%monster.name, demonwall)
  $levelsync(%monster.name, %current.battlestreak)

  set %number.of.monsters.needed 0

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  if (%battle.type != ai) {  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) }

  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  set %current.battlefield Dead-End Hallway
  writeini $dbfile(battlefields.db) weather current Gloomy

  var %items.lines $lines($lstfile(chest_gold.lst))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(chest_gold.lst)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a bandit leader
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_bandit_leader {
  set %current.battlestreak $calc($readini(battlestats.dat, Battle, WinningStreak) - 3)

  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  if (%current.battlestreak > $return_levelCapSettingMonster(BanditLeader)) { set %current.battlestreak $return_levelCapSettingMonster(BanditLeader) } 

  set %monster.name Bandit_Leader | set %monster.realname Bandit Leader

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info bosslevel %current.battlestreak
  writeini $char(%monster.name) info OrbBonus yes

  var %base.hp.tp $calc(10 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(50,110)
  writeini $char(%monster.name) basestats def $rand(25,75)
  writeini $char(%monster.name) basestats int $rand(9,30)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques RainStorm %current.battlestreak
  writeini $char(%monster.name) techniques Detonator %current.battlestreak

  writeini $char(%monster.name) weapons equipped SubMachineGun
  writeini $char(%monster.name) weapons SubMachineGun $calc(%current.battlestreak / 2)
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) augments SubMachineGun EnhanceSnatch.EnhanceParry.EnhanceDodge

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills Snatch 10
  writeini $char(%monster.name) skills Resist-stun 50
  writeini $char(%monster.name) skills Resist-charm 80
  writeini $char(%monster.name) skills Resist-poison 5
  writeini $char(%monster.name) skills Resist-paralysis 10

  writeini $char(%monster.name) descriptions char is the leader of a wild pack of bandits.
  writeini $char(%monster.name) descriptions snatch uses a chain he has to try and take a hostage
  writeini $char(%monster.name) descriptions BossQuote give me your valuables or your life! 

  $boost_monster_stats(%monster.name)
  $fulls(%monster.name) 
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle)

  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  var %random.chest $rand(1,4)
  if (%random.chest = 1) { set %chest chest_gold.lst }
  if (%random.chest = 2) { set %chest chest_silver.lst }
  if (%random.chest = 3) { set %chest chest_green.lst }
  if (%random.chest = 4) { set %chest chest_orange.lst }

  var %items.lines $lines($lstfile(%chest))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(%chest)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  unset %chest 

  writeini $txtfile(battle2.txt) BattleInfo CanKidnapNPCs yes

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a bandit minion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_bandit_minion {
  ; $1 = the number of the minion
  set %current.battlestreak $calc($readini(battlestats.dat, Battle, WinningStreak) - 5)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  if (%current.battlestreak > $return_levelCapSettingMonster(BanditMinion)) { set %current.battlestreak $return_levelCapSettingMonster(BanditMinion) } 

  set %monster.name Bandit_Minion $+ $1 | set %monster.realname Bandit Minion $1

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  writeini $char(%monster.name) basestats str $rand(25,50)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques RainStorm $round($calc(%current.battlestreak / 3),0)
  writeini $char(%monster.name) techniques Detonator $round($calc(%current.battlestreak / 3),0)

  writeini $char(%monster.name) weapons equipped SubMachineGun
  writeini $char(%monster.name) weapons SubMachineGun $round($calc(%current.battlestreak / 3),0)
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills Resist-stun 30
  writeini $char(%monster.name) skills Resist-charm 30

  writeini $char(%monster.name) descriptions char is a random bandit minion

  $fulls(%monster.name) 
  $boost_monster_stats(%monster.name)
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the allied forces president
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_president {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  set %monster.name alliedforces_president | set %monster.realname $readini(shopnpcs.dat, NPCNames, AlliedForcesPresident)

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag npc
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info ai_type defender

  if (%current.battlestreak < 100) { var %base.hp.tp $round($calc(45 * %current.battlestreak),0) }
  else { var %base.hp.tp $round($calc(20 * %current.battlestreak),0) }

  if (%base.hp.tp > 20000) { var %base.hp.tp 20000 }

  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp
  writeini $char(%monster.name) basestats str 2
  writeini $char(%monster.name) basestats def 8
  writeini $char(%monster.name) basestats int 5
  writeini $char(%monster.name) basestats spd 5

  $levelsync(%monster.name, $calc(%current.battlestreak + 2))
  writeini $char(%monster.name) battlestats str $readini($char(%monster.name), battle, str)
  writeini $char(%monster.name) battlestats def $readini($char(%monster.name), battle, def)
  writeini $char(%monster.name) battlestats int $readini($char(%monster.name), battle, int)
  writeini $char(%monster.name) battlestats spd $readini($char(%monster.name), battle, spd)

  writeini $char(%monster.name) weapons equipped Fists

  writeini $char(%monster.name) skills Resist-stun 100
  writeini $char(%monster.name) skills Resist-charm 100
  writeini $char(%monster.name) skills Resist-poison 55
  writeini $char(%monster.name) skills Resist-paralysis 100

  writeini $char(%monster.name) descriptions char is the president of the Allied Forces and is currently tied up and totally defenseless.

  $boost_monster_hp(%monster.name)
  $fulls(%monster.name) 

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 

  set %chest chest_gold.lst

  var %items.lines $lines($lstfile(%chest))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(%chest)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  unset %chest 

  if (%current.battlestreak < 100) {  writeini $txtfile(battle2.txt) battle alliednotes 100 }
  if ((%current.battlestreak >= 100) && (%current.battlestreak < 500)) { writeini $txtfile(battle2.txt) battle alliednotes 200 }
  if ((%current.battlestreak >= 500) && (%current.battlestreak < 1000)) { writeini $txtfile(battle2.txt) battle alliednotes 400 }
  if ((%current.battlestreak >= 1000) && (%current.battlestreak < 2000)) { writeini $txtfile(battle2.txt) battle alliednotes 500 }
  if ((%current.battlestreak >= 2000) && (%current.battlestreak < 3000)) { writeini $txtfile(battle2.txt) battle alliednotes 800 }
  if (%current.battlestreak >= 3000) {  writeini $txtfile(battle2.txt) battle alliednotes 1000 }

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item | unset %current.battlestreak | unset %monster.name | unset %monster.realname
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; an allied troop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_allied_troop {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  var %battle.level.cap $return.levelcapsetting(DefendOutpost)
  if (%battle.level.cap = null) { var %battle.level.cap 100 } 
  if (%current.battlestreak > %battle.level.cap) { set %current.battlestreak %battle.level.cap }

  set %monster.name allied_troop | set %monster.realname Allied Forces Troop

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag npc
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info cantaunt false

  if (%current.battlestreak < 100) { var %base.hp.tp $round($calc(50 * %current.battlestreak),0) }
  else { var %base.hp.tp $round($calc(35 * %current.battlestreak),0) }


  if (%base.hp.tp > 20000) { var %base.hp.tp 20000 }

  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp
  writeini $char(%monster.name) basestats str 4
  writeini $char(%monster.name) basestats def 6
  writeini $char(%monster.name) basestats int 7
  writeini $char(%monster.name) basestats spd 3

  $fulls(%monster.name) 

  if ((%battle.type = defendoutpost) && (%current.battlestreak >= 100)) { $levelsync(%monster.name, 101) }
  if ((%battle.type = defendoutpost) && (%current.battlestreak < 100)) {  $levelsync(%monster.name, $calc(%current.battlestreak + 1)) }

  writeini $char(%monster.name) battlestats str $readini($char(%monster.name), battle, str)
  writeini $char(%monster.name) battlestats def $readini($char(%monster.name), battle, def)
  writeini $char(%monster.name) battlestats int $readini($char(%monster.name), battle, int)
  writeini $char(%monster.name) battlestats spd $readini($char(%monster.name), battle, spd)

  writeini $char(%monster.name) weapons equipped Mythril_Sword
  writeini $char(%monster.name) weapons Mythril_Sword %current.battlestreak

  writeini $char(%monster.name) techniques FastBlade $round($calc(%current.battlestreak / 2),0)
  writeini $char(%monster.name) techniques BurningBlade $round($calc(%current.battlestreak / 2),0)

  writeini $char(%monster.name) skills Resist-stun 20
  writeini $char(%monster.name) skills Resist-charm 50
  writeini $char(%monster.name) skills Resist-poison 55
  writeini $char(%monster.name) skills Resist-paralysis 100

  writeini $char(%monster.name) descriptions char is the sole surviver of the outpost from the monster attack. He wields a rusty mythril blade

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  $display.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)

  inc %battletxt.current.line 1 
  writeini $txtfile(battle2.txt) battleinfo npcs 1

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item | unset %current.battlestreak | unset %monster.name | unset %monster.realname
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a pirate scallywag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_pirate_scallywag {
  ; $1 = the number of the minion
  set %current.battlestreak $calc($readini(battlestats.dat, Battle, WinningStreak) - 5)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  if (%current.battlestreak > $return_levelCapSettingMonster(PirateMinion)) { set %current.battlestreak $return_levelCapSettingMonster(PirateMinion) } 

  set %monster.name Pirate_Scallywag $+ $1 | set %monster.realname Pirate Scallywag $1

  writeini $char(%monster.name) info OrbBonus yes 

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  var %base.hp.tp $calc(4 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(25,50)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques FastBlade $round($calc(%current.battlestreak / 3),0)
  writeini $char(%monster.name) techniques BurningBlade $round($calc(%current.battlestreak / 3),0)
  writeini $char(%monster.name) techniques FlatBlade $round($calc(%current.battlestreak / 3),0)

  writeini $char(%monster.name) weapons equipped Cutlass
  writeini $char(%monster.name) weapons Cutlass $round($calc(%current.battlestreak / 3),0)
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills Resist-stun 30
  writeini $char(%monster.name) skills Resist-charm 70

  writeini $char(%monster.name) descriptions char is a random pirate scallywag who is in need of an orange and some toothpaste

  $fulls(%monster.name) 
  $boost_monster_stats(%monster.name)
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a pirate first matey
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_pirate_firstmatey {
  set %current.battlestreak $calc($readini(battlestats.dat, Battle, WinningStreak) - 3)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  if (%current.battlestreak > $return_levelCapSettingMonster(PirateFirstMatey)) { set %current.battlestreak $return_levelCapSettingMonster(PirateFirstMatey) } 

  set %monster.name Pirate_FirstMatey | set %monster.realname Pirate's First Matey

  writeini $char(%monster.name) info OrbBonus yes 

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  if ($rand(1,2) = 1) {  writeini $char(%monster.name) info SpawnAfterDeath Silverhook }
  else { writeini $char(%monster.name) info SpawnAfterDeath BlackBeard }

  var %base.hp.tp $calc(10 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(50,100)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques FastBlade %current.battlestreak
  writeini $char(%monster.name) techniques BurningBlade %current.battlestreak
  writeini $char(%monster.name) techniques FlatBlade %current.battlestreak

  writeini $char(%monster.name) weapons equipped Cutlass
  writeini $char(%monster.name) weapons Cutlass $round($calc(%current.battlestreak / 2),0)
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) augments Cutlass EnhanceSnatch

  writeini $char(%monster.name) skills Resist-stun 60
  writeini $char(%monster.name) skills Resist-charm 100
  writeini $char(%monster.name) skills Resist-poison 5
  writeini $char(%monster.name) skills Resist-paralysis 10
  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills Snatch 10
  writeini $char(%monster.name) skills Swordmaster 50

  writeini $char(%monster.name) descriptions char is the first mate of the band of pirates. His smell is only matched by his prowless with a cutlass.
  writeini $char(%monster.name) descriptions snatch tries to take a hostage!
  writeini $char(%monster.name) descriptions BossQuote Arrrr!  We be wanting yer booty! So hand it over and perhapse me and me mates will let ye live!

  $fulls(%monster.name) 
  $boost_monster_stats(%monster.name)
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle)

  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  set %boss.item TreasureMap

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a random gremlin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_gremlin {
  ; $1 = the number of the minion
  set %current.battlestreak $calc($readini(battlestats.dat, Battle, WinningStreak) - 5)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  if (%current.battlestreak > $return_levelCapSettingMonster(Gremlins)) { set %current.battlestreak $return_levelCapSettingMonster(Gremlins) } 

  set %monster.name Gremlin $+ $1 | set %monster.realname Gremlin $1

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  writeini $char(%monster.name) descriptions MonsterSummon $eval(The Gremlin's $chr(2) $+ back begins to bubble and hiss as a boil appears and suddenly shoots off. When the bubble lands it steams and turns into another large green gremlin ready to attack.,0)

  var %base.hp.tp $calc(3 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(25,50)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques Gremlinbite $round($calc(%current.battlestreak / 3),0)

  writeini $char(%monster.name) weapons equipped GremlinAttack
  writeini $char(%monster.name) weapons GremlinAttack $round($calc(%current.battlestreak / 3),0)
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) techniques GremlinBite $round($calc(%current.battlestreak / 3),0)

  writeini $char(%monster.name) skills Resist-stun 30
  writeini $char(%monster.name) skills Resist-charm 100
  writeini $char(%monster.name) skills Resist-paralysis 100
  writeini $char(%monster.name) skills Resist-poison 100

  writeini $char(%monster.name) descriptions char is an ugly green monster with large bat-like ears and sharp teeth. It gives a mischievous laugh

  writeini $char(%monster.name) modifiers water 0
  writeini $char(%monster.name) modifiers light 300
  writeini $char(%monster.name) modifier_special water $eval($iif($return_monstersinbattle < $return_maxmonstersinbattle, $skill.monstersummon($3, Gremlin)),0)

  $fulls(%monster.name) 
  $boost_monster_stats(%monster.name)
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a mimic monster
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_monster_mimic {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  set %monster.name Mimic | set %monster.realname Mimic 
  writeini $char(%monster.name) info OrbBonus yes 

  var %mimic.level %current.battlestreak
  inc %mimic.level $rand(0,3)

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info bosslevel %mimic.level
  writeini $char(%monster.name) info CanTaunt false

  var %base.hp.tp $calc(7 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(75,100)
  writeini $char(%monster.name) basestats def $rand(50,65)
  writeini $char(%monster.name) basestats int $rand(15,35)
  writeini $char(%monster.name) basestats spd $rand(60,155)

  writeini $char(%monster.name) techniques AsuranFists %current.battlestreak

  writeini $char(%monster.name) weapons equipped Mimic
  writeini $char(%monster.name) weapons Mimic %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills manawall.on on
  writeini $char(%monster.name) skills royalguard.on on
  writeini $char(%monster.name) skills resist-charm 100
  writeini $char(%monster.name) skills resist-poison 100
  writeini $char(%monster.name) skills resist-confuse 100
  writeini $char(%monster.name) skills resist-stun 100
  writeini $char(%monster.name) skills resist-bored 100
  writeini $char(%monster.name) skills resist-blind 100
  writeini $char(%monster.name) skills Resist-Paralysis 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian $rand(6,10)

  $boost_monster_stats(%monster.name, mimic)
  $fulls(%monster.name, mimic) 

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) | writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname


  var %items.lines $lines($lstfile(chest_mimic.lst))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(chest_mimic.lst)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  unset %chest 

  writeini $txtfile(battle2.txt) BattleInfo CanKidnapNPCs no

  writeini $txtfile(battle2.txt) battle bonusitem %boss.item
  unset %boss.item
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a frost monster
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_frost_monster {
  ; $1 = the number of the minion

  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak > $return_levelCapSettingMonster(FrostLegion)) { set %current.battlestreak $return_levelCapSettingMonster(FrostLegion) } 

  set %monster.name Frost_Monster $+ $1 | set %monster.realname Frost Monster $1

  writeini $char(%monster.name) info OrbBonus yes

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  var %base.hp.tp $calc(3 * %current.battlestreak)
  if (%base.hp.tp <= 300) { var %base.hp.tp 300 }

  writeini $char(%monster.name) basestats hp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(20,30)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques FrostBite $round($calc(%current.battlestreak / 1.5),0)
  writeini $char(%monster.name) techniques FreezeII $round($calc(%current.battlestreak / 1.5),0)
  writeini $char(%monster.name) techniques BlizzajaII $round($calc(%current.battlestreak / 1.5),0)

  writeini $char(%monster.name) weapons equipped FrostWhip
  writeini $char(%monster.name) weapons FrostWhip $round($calc(%current.battlestreak / 2),0)
  writeini $char(%monster.name) weapons Fists %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills Resist-stun 70
  writeini $char(%monster.name) skills Resist-charm 100
  writeini $char(%monster.name) skills resist-poison 100
  writeini $char(%monster.name) skills resist-confuse 100
  writeini $char(%monster.name) skills resist-stun 100
  writeini $char(%monster.name) skills resist-bored 100
  writeini $char(%monster.name) skills resist-blind 100
  writeini $char(%monster.name) skills Resist-Paralysis 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian $rand(6,10)

  writeini $char(%monster.name) modifiers heal ice
  writeini $char(%monster.name) modifiers ice 2000
  writeini $char(%monster.name) modifiers fire 110
  writeini $char(%monster.name) modifiers wind 50

  writeini $char(%monster.name) descriptions char is a monster made out of ice
  $levelsync(%monster.name, %current.battlestreak)
  $fulls(%monster.name) 
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a crystal shadow boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_crystalshadow {

  set %monster.name Crystal_Shadow  | set %monster.realname Crystal Shadow Warrior
  if (%battle.type != ai) {  $display.message($readini(translation.dat, events, CrystalShadowFight),battle) }

  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  if (%battle.type = ai) { set %current.battlestreak %ai.battle.level }

  .copy -o $char(new_chr) $char(%monster.name)

  if (%battle.type = ai) { set %ai.monster.name %monster.realname | writeini $txtfile(1vs1bet.txt) money monsterfile %monster.name }

  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info bosslevel %current.battlestreak
  writeini $char(%monster.name) info OrbBonus no 
  writeini $char(%monster.name) descriptions char is a powerful shadow of an ancient Crystal Warrior of an age long past. It stands with its arms crossed, waiting for the heroes to attack.
  writeini $char(%monster.name) descriptions BossQuote Your anger will be your undoing.
  writeini $char(%monster.name) monster type Crystal Warrior
  writeini $char(%monster.name) info CanTaunt true
  writeini $char(%monster.name) info HurtByTaunt true
  writeini $char(%monster.name) info ai_type counteronly
  writeini $char(%monster.name) info IgnoreQuickSilver true
  writeini $char(%monster.name) info JustReleaseDefense 100
  writeini $char(%monster.name) info TauntFile taunts_crystalwarrior.txt

  var %base.hp.tp $calc(20 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(200,300)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques Scourge %current.battlestreak
  writeini $char(%monster.name) techniques HerculeanSlash %current.battlestreak
  writeini $char(%monster.name) techniques HerculeanSlash %current.battlestreak
  writeini $char(%monster.name) techniques Resolution %current.battlestreak
  writeini $char(%monster.name) techniques Torcleaver %current.battlestreak

  writeini $char(%monster.name) weapons equipped Ragnarok
  writeini $char(%monster.name) weapons Ragnarok $round($calc(%current.battlestreak * 2),0)
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills resist-charm 100
  writeini $char(%monster.name) skills resist-stun 100
  writeini $char(%monster.name) skills Resist-blind 100
  writeini $char(%monster.name) skills Resist-poison 100
  writeini $char(%monster.name) skills Resist-slow 100
  writeini $char(%monster.name) skills Resist-Weaponlock 100
  writeini $char(%monster.name) skills Resist-confuse 100
  writeini $char(%monster.name) skills Resist-paralysis 100
  writeini $char(%monster.name) skills Resist-zombie 100

  set %current.battlefield Inner Crystal Chamber
  writeini $dbfile(battlefields.db) weather current Calm

  writeini $char(%monster.name) modifiers light 0
  writeini $char(%monster.name) modifiers dark 0
  writeini $char(%monster.name) modifiers fire 0
  writeini $char(%monster.name) modifiers ice 0
  writeini $char(%monster.name) modifiers water 0
  writeini $char(%monster.name) modifiers lightning 0
  writeini $char(%monster.name) modifiers wind 0
  writeini $char(%monster.name) modifiers earth 0

  writeini $char(%monster.name) modifiers HandToHand 1
  writeini $char(%monster.name) modifiers Whip 1
  writeini $char(%monster.name) modifiers sword 1
  writeini $char(%monster.name) modifiers gun 1
  writeini $char(%monster.name) modifiers rifle 1
  writeini $char(%monster.name) modifiers katana 1
  writeini $char(%monster.name) modifiers wand 1
  writeini $char(%monster.name) modifiers spear 1
  writeini $char(%monster.name) modifiers scythe 1
  writeini $char(%monster.name) modifiers GreatSword 1
  writeini $char(%monster.name) modifiers bow 1
  writeini $char(%monster.name) modifiers glyph 1

  $fulls(%monster.name, crystal_shadow) 
  $boost_monster_stats(%monster.name, Crystal_Shadow)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name)
  if (%battle.type != ai) { 
    $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
    $display.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle) 
  }
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname
  unset %random.firstname | unset %first.name | unset %lastnames.total | unset %random.lastname | unset %last.name | unset %names.lines

  var %random.chest $rand(1,2)
  if (%random.chest = 1) { set %chest chest_gold.lst }
  if (%random.chest = 2) { set %chest chest_silver.lst }

  var %items.lines $lines($lstfile(%chest))
  if (%items.lines = 0) { set %boss.item Ethrune }
  else { 
    set %random $rand(1, %items.lines)
    if (%random = $null) { var %random 1 }
    set %random.item.contents $read -l $+ %random $lstfile(%chest)
    set %boss.item %random.item.contents
    unset %random.item.contents | unset %random
  }

  unset %chest 

  if (%boss.item != $null) {  writeini $txtfile(battle2.txt) battle bonusitem %boss.item }
  unset %boss.item
}
