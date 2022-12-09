;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; bossaliases.als
;;;; Last updated: 12/09/22
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function will pick a 
; random boss type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_boss_type {

  if (%supplyrun = on) { set %boss.type normal | return } 
  if (%savethepresident = on) { set %boss.type normal | return } 
  if (%battle.type = defendoutpost) { set %boss.type normal | return }
  if (%battle.type = torment) { set %boss.type normal | return }
  if ($return_winningstreak <= 10) { set %boss.type normal | return }

  set %boss.choices normal
  var %enable.doppelganger $readini(system.dat, system, EnableDoppelganger)
  var %enable.warmachine $readini(system.dat, system, EnableWarMachine)
  var %enable.bandits $readini(system.dat, system, EnableBandits)
  var %enable.goblins $readini(system.dat, system, EnableGoblins)
  var %enable.gremlins $readini(system.dat, system, EnableGremlins)
  var %enable.crystalshadow $readini(system.dat, system, EnableCrystalShadow)
  var %enable.dinosaur $readini(system.dat, system, EnableDinosaurs)

  ;; As of version 4.1_051822 the pirate battle is now a dungeon and randomly happens. 
  ;  var %enable.pirates $readini(system.dat, system, EnablePirates)
  var %enable.pirates false


  var %winning.streak.check $readini(battlestats.dat, battle, winningstreak)
  if (%mode.gauntlet.wave != $null) { inc %winning.streak.check %mode.gauntlet.wave }

  echo -a :: Win Streak: %winning.streak.check


  if (%winning.streak.check isnum 1-49) { 
    var %enable.dinosaur false
    var %enable.bandits false
    var %enable.doppelganger false
    var %enable.gremlins false
    var %enable.pirates false 
    var %enable.goblins false
  }


  if ((%winning.streak.check >= 55) && (%winning.streak.check < 500)) { 
    if ($readini(system.dat, system, AllowDemonwall) = yes) { var %enable.demonwall true }
  }

  if (%winning.streak.check >= 500) { 
    if ($readini(system.dat, system, AllowWallOfFlesh) = yes) { var %enable.wallofflesh true }
  }


  if (%mode.gauntlet = on) { var %enable.demonwall false }

  ; This is for the old way of doing the Frost Legion.  It has since been changed to be a dungeon that is accessible in December.
  ; if (($left($adate, 2) = 12) && (%winning.streak.check >= 20)) { %boss.choices = %boss.choices $+ .FrostLegion }

  var %boss.chance $rand(1,100)
  var %boss.chance 1

  if ((%enable.dinosaur = true) && (%boss.chance <= 30)) { %boss.choices = %boss.choices $+ .dinosaurs }
  if ((%enable.doppelganger = true) && (%boss.chance <= 25)) { %boss.choices = %boss.choices $+ .doppelganger }
  if ((%enable.warmachine = true) && (%boss.chance <= 20)) { %boss.choices = %boss.choices $+ .warmachine }
  if ((%enable.bandits = true) && (%boss.chance <= 20)) { %boss.choices = %boss.choices $+ .bandits }
  if ((%enable.gremlins = true) && (%boss.chance <= 20)) { %boss.choices = %boss.choices $+ .gremlins }
  if ((%enable.pirates = true) && (%boss.chance <= 50)) { %boss.choices = %boss.choices $+ .pirates }
  if ((%enable.wallofflesh = true) && (%boss.chance <= 25)) { %boss.choices = %boss.choices $+ .wallofflesh }
  if ((%enable.demonwall = true) && (%boss.chance <= 15)) { %boss.choices = %boss.choices $+ .demonwall }
  if ((%enable.predator = true) && (%boss.chance <= 20)) { %boss.choices = %boss.choices $+ .predator }  
  if ((%enable.crystalshadow = true) && (%boss.chance <= 15)) { 
    if (%winning.streak.check > 15) { %boss.choices = %boss.choices $+ .crystalshadow }
  }

  ; Choose a boss type

  if (%battle.type = ai) { set %boss.choices normal.warmachine.normal.demonwall.wallofflesh.normal.elderdragon.normal.dinosaurs }

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
  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

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

  var %base.hp.tp $calc(9 * %current.battlestreak)
  if ($return_playersinbattle > 3) { inc %base.hp.tp $calc($return_playersinbattle * 500) }

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
  writeini $char(%monster.name) skills Resist-slow 80
  writeini $char(%monster.name) skills Resist-stop 100
  writeini $char(%monster.name) skills Resist-Weaponlock 100
  writeini $char(%monster.name) skills Resist-Paralysis 100
  writeini $char(%monster.name) skills Resist-Petrify 100
  writeini $char(%monster.name) skills Resist-Intimidate 100
  writeini $char(%monster.name) skills Resist-Drunk 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian 2

  var %reflect.chance $rand(1,100)
  if (%reflect.chance <= 40) { writeini $char(%monster.name) status reflect yes | writeini $char(%monster.name) status reflect.timer 1 }

  ; Modifiers
  writeini $char(%monster.name) modifiers Fire 30
  writeini $char(%monster.name) modifiers EnergyBlaster 80
  writeini $char(%monster.name) modifiers HolyHandGrenade 10
  writeini $char(%monster.name) modifiers Crissaegrim 50
  writeini $char(%monster.name) modifiers Valmanway 50
  writeini $char(%monster.name) modifiers Naturaleza 50
  writeini $char(%monster.name) modifiers AsuranFists 35
  writeini $char(%monster.name) modifiers VictorySmite 40
  writeini $char(%monster.name) modifiers ShinjinSpiral 40
  writeini $char(%monster.name) modifiers MillionStab 40
  writeini $char(%monster.name) modifiers VorpalBlade 40
  writeini $char(%monster.name) modifiers DeathBlossom 40
  writeini $char(%monster.name) modifiers SwiftBlade 40
  writeini $char(%monster.name) modifiers ChantDuCygne 40
  writeini $char(%monster.name) modifiers Requiescat 40
  writeini $char(%monster.name) modifiers Resolution 35
  writeini $char(%monster.name) modifiers Guillotine 40
  writeini $char(%monster.name) modifiers Insurgency 40
  writeini $char(%monster.name) modifiers Pentathrust 40
  writeini $char(%monster.name) modifiers Drakesbane 40
  writeini $char(%monster.name) modifiers Stardiver 40
  writeini $char(%monster.name) modifiers PyrrhicKleos 40
  writeini $char(%monster.name) modifiers Evisceration 40
  writeini $char(%monster.name) modifiers DancingEdge 40
  writeini $char(%monster.name) modifiers Ultima 40
  writeini $char(%monster.name) modifiers Kaustra 40
  writeini $char(%monster.name) modifiers Ashes 40
  writeini $char(%monster.name) modifiers Dismay 40
  writeini $char(%monster.name) modifiers ThousandCuts 40
  writeini $char(%monster.name) modifiers Tachi:Shoha 40
  writeini $char(%monster.name) modifiers Tachi:Rana 40
  writeini $char(%monster.name) modifiers Rainstorm 30
  writeini $char(%monster.name) modifiers SpinningAttack 40
  writeini $char(%monster.name) modifiers TornadoKick 40
  writeini $char(%monster.name) modifiers CircularChain 40
  writeini $char(%monster.name) modifiers CircleBlade 40
  writeini $char(%monster.name) modifiers SonicThrust 40
  writeini $char(%monster.name) modifiers ApexArrow 40
  writeini $char(%monster.name) modifiers UrielBlade 40
  writeini $char(%monster.name) modifiers FellCleave 40
  writeini $char(%monster.name) modifiers AeolianEdge 40
  writeini $char(%monster.name) modifiers Twin_Slice 40
  writeini $char(%monster.name) modifiers LightningStrike 40
  writeini $char(%monster.name) modifiers BladeBeamII 40
  writeini $char(%monster.name) modifiers TrillionStabs 40
  writeini $char(%monster.name) modifiers DoubleBackstab 40
  writeini $char(%monster.name) modifiers Chou_Kamehameha 40
  writeini $char(%monster.name) modifiers BloodBath 40
  writeini $char(%monster.name) modifiers UltimaII 40
  writeini $char(%monster.name) modifiers KaustraII 40
  writeini $char(%monster.name) modifiers Chivalry 40
  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

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
  writeini $char(%monster.name) skills Resist-slow 80
  writeini $char(%monster.name) skills Resist-stop 100
  writeini $char(%monster.name) skills Resist-Weaponlock 100
  writeini $char(%monster.name) skills Resist-Paralysis 100
  writeini $char(%monster.name) skills Resist-Petrify 100
  writeini $char(%monster.name) skills Resist-Intimidate 100
  writeini $char(%monster.name) skills Resist-Drunk 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian 4

  ; Modifiers
  writeini $char(%monster.name) modifiers Fire 30
  writeini $char(%monster.name) modifiers Gun 120
  writeini $char(%monster.name) modifiers Rifle 140
  writeini $char(%monster.name) modifiers Bow 105
  writeini $char(%monster.name) modifiers EnergyBlaster 80
  writeini $char(%monster.name) modifiers HolyHandGrenade 10
  writeini $char(%monster.name) modifiers Crissaegrim 50
  writeini $char(%monster.name) modifiers Valmanway 50
  writeini $char(%monster.name) modifiers Naturaleza 50
  writeini $char(%monster.name) modifiers AsuranFists 35
  writeini $char(%monster.name) modifiers VictorySmite 40
  writeini $char(%monster.name) modifiers ShinjinSpiral 40
  writeini $char(%monster.name) modifiers MillionStab 40
  writeini $char(%monster.name) modifiers VorpalBlade 40
  writeini $char(%monster.name) modifiers DeathBlossom 40
  writeini $char(%monster.name) modifiers SwiftBlade 40
  writeini $char(%monster.name) modifiers ChantDuCygne 40
  writeini $char(%monster.name) modifiers Requiescat 40
  writeini $char(%monster.name) modifiers Resolution 35
  writeini $char(%monster.name) modifiers Guillotine 40
  writeini $char(%monster.name) modifiers Insurgency 40
  writeini $char(%monster.name) modifiers Pentathrust 40
  writeini $char(%monster.name) modifiers Drakesbane 40
  writeini $char(%monster.name) modifiers Stardiver 40
  writeini $char(%monster.name) modifiers PyrrhicKleos 40
  writeini $char(%monster.name) modifiers Evisceration 40
  writeini $char(%monster.name) modifiers DancingEdge 40
  writeini $char(%monster.name) modifiers Ultima 40
  writeini $char(%monster.name) modifiers Kaustra 40
  writeini $char(%monster.name) modifiers Ashes 40
  writeini $char(%monster.name) modifiers Dismay 40
  writeini $char(%monster.name) modifiers ThousandCuts 40
  writeini $char(%monster.name) modifiers Tachi:Shoha 40
  writeini $char(%monster.name) modifiers Tachi:Rana 40
  writeini $char(%monster.name) modifiers Rainstorm 30
  writeini $char(%monster.name) modifiers SpinningAttack 40
  writeini $char(%monster.name) modifiers TornadoKick 40
  writeini $char(%monster.name) modifiers CircularChain 40
  writeini $char(%monster.name) modifiers CircleBlade 40
  writeini $char(%monster.name) modifiers SonicThrust 40
  writeini $char(%monster.name) modifiers ApexArrow 40
  writeini $char(%monster.name) modifiers UrielBlade 40
  writeini $char(%monster.name) modifiers FellCleave 40
  writeini $char(%monster.name) modifiers AeolianEdge 40
  writeini $char(%monster.name) modifiers Twin_Slice 40
  writeini $char(%monster.name) modifiers LightningStrike 40
  writeini $char(%monster.name) modifiers BladeBeamII 40
  writeini $char(%monster.name) modifiers TrillionStabs 40
  writeini $char(%monster.name) modifiers DoubleBackstab 40
  writeini $char(%monster.name) modifiers Chou_Kamehameha 40
  writeini $char(%monster.name) modifiers BloodBath 40
  writeini $char(%monster.name) modifiers UltimaII 40
  writeini $char(%monster.name) modifiers KaustraII 40
  writeini $char(%monster.name) modifiers Chivalry 40
  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0


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

  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

  writeini $char(%monster.name) descriptions char is the leader of a wild pack of bandits.
  writeini $char(%monster.name) descriptions snatch uses a chain he has to try and take a hostage
  writeini $char(%monster.name) descriptions BossQuote give me your valuables or your life! 

  $boost_monster_stats(%monster.name)
  $fulls(%monster.name) 
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  $display.message(02 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle)

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
; the allied forces wagon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_wagon {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  set %monster.name supply_wagon | set %monster.realname Supply Wagon

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag npc
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info ai_type defender

  if (%current.battlestreak < 100) { var %base.hp.tp $round($calc(40 * %current.battlestreak),0) }
  else { var %base.hp.tp $round($calc(35 * %current.battlestreak),0) }

  if (%base.hp.tp > 25000) { var %base.hp.tp 25000 }

  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp
  writeini $char(%monster.name) basestats str 2
  writeini $char(%monster.name) basestats def 9
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
  writeini $char(%monster.name) skills Resist-poison 100
  writeini $char(%monster.name) skills Resist-paralysis 100

  writeini $char(%monster.name) descriptions char is a supply wagon sent by the Allied Forces to a nearby outpost for supply delivery.

  $boost_monster_hp(%monster.name)
  $fulls(%monster.name) 
  $levelsync(%monster.name, %current.battlestreak)

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
; a pirate scallywag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_pirate_scallywag {
  ; $1 = the number of the minion

  if (%battle.type != dungeon) {
    set %current.battlestreak $calc($readini(battlestats.dat, Battle, WinningStreak) - 5)
    if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

    if (%current.battlestreak > $return_levelCapSettingMonster(PirateMinion)) { set %current.battlestreak $return_levelCapSettingMonster(PirateMinion) } 
  }
  if (%battle.type = dungeon) { set %current.battlestreak $return_winningstreak }

  set %monster.name Pirate_Scallywag $+ $1 | set %monster.realname Pirate Scallywag $1

  writeini $char(%monster.name) info OrbBonus yes 

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender his
  writeini $char(%monster.name) info gender2 him
  writeini $char(%monster.name) info bosslevel %current.battlestreak
  writeini $char(%monster.name) monster type pirate

  var %base.hp.tp $calc(3 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(25,50)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques FastBlade $round($calc(%current.battlestreak / 3),0)
  writeini $char(%monster.name) techniques BurningBlade $round($calc(%current.battlestreak / 3),0)
  writeini $char(%monster.name) techniques FlatBlade $round($calc(%current.battlestreak / 3),0)

  writeini $char(%monster.name) weapons equipped LargeCutlass
  writeini $char(%monster.name) weapons LargeCutlass $round($calc(%current.battlestreak / 3),0)
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
  writeini $char(%monster.name) monster type pirate

  if ($rand(1,2) = 1) {  writeini $char(%monster.name) info SpawnAfterDeath Silverhook }
  else { writeini $char(%monster.name) info SpawnAfterDeath BlackBeard }

  var %base.hp.tp $calc(9 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) basestats str $rand(50,100)
  writeini $char(%monster.name) basestats def $rand(15,45)
  writeini $char(%monster.name) basestats int $rand(10,35)
  writeini $char(%monster.name) basestats spd $rand(55,155)

  writeini $char(%monster.name) techniques FastBlade %current.battlestreak
  writeini $char(%monster.name) techniques BurningBlade %current.battlestreak
  writeini $char(%monster.name) techniques FlatBlade %current.battlestreak

  writeini $char(%monster.name) weapons equipped LargeCutlass
  writeini $char(%monster.name) weapons LargeCutlass $round($calc(%current.battlestreak / 2),0)
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) augments LargeCutlass EnhanceSnatch

  writeini $char(%monster.name) skills Resist-stun 60
  writeini $char(%monster.name) skills Resist-charm 100
  writeini $char(%monster.name) skills Resist-poison 5
  writeini $char(%monster.name) skills Resist-paralysis 10
  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills Snatch 10
  writeini $char(%monster.name) skills Swordmaster 50

  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

  writeini $char(%monster.name) descriptions char is the first mate of the band of pirates. His smell is only matched by his prowless with a cutlass.
  writeini $char(%monster.name) descriptions snatch tries to take a hostage!
  writeini $char(%monster.name) descriptions BossQuote Arrrr!  We be wanting yer booty! So hand it over and perhapse me and me mates will let ye live!

  $fulls(%monster.name) 
  $boost_monster_stats(%monster.name)
  $levelsync(%monster.name, %current.battlestreak)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name) 
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  $display.message(02 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle)

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

  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

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
  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

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
  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

  $fulls(%monster.name, crystal_shadow) 
  $boost_monster_stats(%monster.name, Crystal_Shadow)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %monster.name
  $set_chr_name(%monster.name)
  if (%battle.type != ai) { 
    $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
    $display.message(02 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle) 
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; an elder dragon boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_dinosaur {

  var %current.battlestreak $return_winningstreak
  if (%battle.type = ai) { set %current.battlestreak %ai.battle.level }

  var %dinoname Tyrannosaurus.Spinosaurus.Giganotosaurus

  set %dinos.total $numtok(%dinoname,46)
  set %random.name $rand(1, %dinos.total) 
  set %dinosaur $gettok(%dinoname,%random.name,46)

  if (%battle.type != ai) {
    $display.message($readini(translation.dat, events, JurassicParkFight),battle) 
  }

  var %monster.name %dinosaur
  .copy -o $char(new_chr) $char(%monster.name)

  var %boss.level $calc(%current.battlestreak + 5)
  if (%battle.type != ai) { 
    if (%boss.level < $return_playerlevelaverage) { var %boss.level $return_playerlevelaverage }
  }

  if (%battle.type = ai) { set %ai.monster.name %dinosaur | writeini $txtfile(1vs1bet.txt) money monsterfile %dinosaur }

  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %dinosaur
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info bosslevel %boss.level
  writeini $char(%monster.name) info OrbBonus yes 
  writeini $char(%monster.name) descriptions char is a large and powerful dinosaur that has escaped from its pin in Jurassic Park.
  writeini $char(%monster.name) monster type dinosaur
  writeini $char(%monster.name) info CanTaunt false

  var %base.hp.tp $round($calc(50 * %boss.level),0)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp

  writeini $char(%monster.name) battle str $rand(19,25)
  writeini $char(%monster.name) battle def $rand(15,20)
  writeini $char(%monster.name) battle int $rand(12,19)
  writeini $char(%monster.name) battle spd $rand(18,30)

  writeini $char(%monster.name) techniques FangRush %current.battlestreak
  writeini $char(%monster.name) techniques AbsoluteTerror %current.battlestreak
  writeini $char(%monster.name) techniques SpikeFlail %current.battlestreak

  writeini $char(%monster.name) weapons equipped DinoFangs
  writeini $char(%monster.name) weapons DinoFangs %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills MonsterConsume 1
  writeini $char(%monster.name) skills resist-charm 100
  writeini $char(%monster.name) skills resist-stun 100
  writeini $char(%monster.name) skills Resist-blind 80
  writeini $char(%monster.name) skills Resist-poison 95
  writeini $char(%monster.name) skills Resist-slow 60
  writeini $char(%monster.name) skills Resist-Weaponlock 100

  set %current.battlefield Jurassic Park
  writeini $dbfile(battlefields.db) weather current Calm

  writeini $char(%monster.name) modifiers light 100
  writeini $char(%monster.name) modifiers dark 100
  writeini $char(%monster.name) modifiers fire 100
  writeini $char(%monster.name) modifiers ice 100
  writeini $char(%monster.name) modifiers water 100
  writeini $char(%monster.name) modifiers lightning 100
  writeini $char(%monster.name) modifiers wind 100
  writeini $char(%monster.name) modifiers earth 100

  writeini $char(%monster.name) NaturalArmor Name Dinosaur Scales
  writeini $char(%monster.name) NaturalArmor Max $calc(%current.battlestreak * 10)
  writeini $char(%monster.name) NaturalArmor Current $calc(%current.battlestreak * 10)

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
  writeini $char(%monster.name) modifiers ultima 10
  writeini $char(%monster.name) modifiers Kaustra 10
  writeini $char(%monster.name) modifiers FinishingTouch 0
  writeini $char(%monster.name) modifiers MurderSpree 0
  writeini $char(%monster.name) modifiers MurderSpreeII 0

  $levelsync(%monster.name, %boss.level)
  writeini $char(%monster.name) basestats str $readini($char(%monster.name), battle, str)
  writeini $char(%monster.name) basestats def $readini($char(%monster.name), battle, def)
  writeini $char(%monster.name) basestats int $readini($char(%monster.name), battle, int)
  writeini $char(%monster.name) basestats spd $readini($char(%monster.name), battle, spd)

  $fulls(%monster.name) 
  $boost_monster_hp(%monster.name, elderdragon, %boss.level)

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
  unset %dinos.total | unset %random.name | unset %dinosaur

  $battlefield.limitations
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function will generate
; the dragon for the dragon
; hunt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dragonhunt.createfile {

  .copy -o $char(new_chr) $char(%dragonhunt.file.name)

  var %dragon.level $dragonhunt.dragonage(%dragonhunt.file.name)
  var %dragon.element $dragonhunt.dragonelement(%dragonhunt.file.name) 

  if (%dragon.element = shadow) { var %dragon.element dark }

  writeini $char(%dragonhunt.file.name) info flag monster 
  writeini $char(%dragonhunt.file.name) Basestats name $readini($dbfile(dragonhunt.db), %dragonhunt.file.name, name)
  writeini $char(%dragonhunt.file.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%dragonhunt.file.name) info gender its
  writeini $char(%dragonhunt.file.name) info gender2 its
  writeini $char(%dragonhunt.file.name) info bosslevel %dragon.level
  writeini $char(%dragonhunt.file.name) info OrbBonus yes 
  writeini $char(%dragonhunt.file.name) descriptions char is a large and powerful $dragonhunt.dragonelement(%dragonhunt.file.name) dragon.  
  writeini $char(%dragonhunt.file.name) monster type dragon
  writeini $char(%dragonhunt.file.name) info CanTaunt false

  if ($dragonhunt.ancientcheck(%dragonhunt.file.name) = true) { writeini $char(%dragonhunt.file.name) info CoinBonus true }

  if ((%dragon.level >= 200) && (%dragon.level <= 500)) { writeini $char(%dragonhunt.file.name) monster elite true }
  if (%dragon.level > 500) { writeini $char(%dragonhunt.file.name) monster SuperElite true }

  var %base.hp.tp $round($calc(100 * %dragon.level),0)
  if ($return_playersinbattle >= 3) { inc %base.hp.tp $round($calc(80 * $return_playersinbattle),0) }

  if ($dragonhunt.ancientcheck(%dragonhunt.file.name) = true) { inc %base.hp.tp 500 }

  writeini $char(%dragonhunt.file.name) basestats hp %base.hp.tp
  writeini $char(%dragonhunt.file.name) basestats tp %base.hp.tp

  writeini $char(%dragonhunt.file.name) battle str $rand(30,35)
  writeini $char(%dragonhunt.file.name) battle def $rand(35,45)
  writeini $char(%dragonhunt.file.name) battle int $rand(20,30)
  writeini $char(%dragonhunt.file.name) battle spd $rand(15,20)

  writeini $char(%dragonhunt.file.name) weapons equipped DragonFangs
  writeini $char(%dragonhunt.file.name) weapons DragonFangs %dragon.level
  remini $char(%dragonhunt.file.name) weapons Fists

  ; These are techniques all dragons know
  writeini $char(%dragonhunt.file.name) techniques FangRush %dragon.level
  writeini $char(%dragonhunt.file.name) techniques SpikeFlail $calc(%dragon.level + 1)
  writeini $char(%dragonhunt.file.name) techniques AbsoluteTerror %dragon.level
  writeini $char(%dragonhunt.file.name) techniques DragonFire $calc(%dragon.level + 5) 

  if ($dragonhunt.ancientcheck(%dragonhunt.file.name) = true) { 
    writeini $char(%dragonhunt.file.name) techniques SpikeFlail $calc(%dragon.level + 50)
    writeini $char(%dragonhunt.file.name) techniques DragonFire $calc(%dragon.level + 50)
  }

  ; Depending on the element of the dragon, it will have different techniques
  if (%dragon.element = fire) { writeini $char(%dragonhunt.file.name) techniques FireII %dragon.level }
  if (%dragon.element = earth) { writeini $char(%dragonhunt.file.name) techniques StoneII %dragon.level }
  if (%dragon.element = ice) { writeini $char(%dragonhunt.file.name) techniques IceII %dragon.level }
  if (%dragon.element = wind) { writeini $char(%dragonhunt.file.name) techniques AeroII %dragon.level }
  if (%dragon.element = water) { writeini $char(%dragonhunt.file.name) techniques WaterII %dragon.level }
  if (%dragon.element = lightning) { writeini $char(%dragonhunt.file.name) techniques ThunderII %dragon.level }
  if (%dragon.element = dark) { writeini $char(%dragonhunt.file.name) techniques DarkII %dragon.level }
  if (%dragon.element = light) { writeini $char(%dragonhunt.file.name) techniques Holy %dragon.level }
  if (%dragon.element = crystal) { 
    writeini $char(%dragonhunt.file.name) techniques FireII %dragon.level 
    writeini $char(%dragonhunt.file.name) techniques Holy %dragon.level
    writeini $char(%dragonhunt.file.name) techniques DarkII %dragon.level 
  }

  ; Add actions per turn based on level of dragons
  var %actions.per.turn 1
  if ((%dragon.level >= 200) && (%dragon.level <= 500)) { inc %actions.per.turn 1 }
  if (%dragon.level > 500) { inc %actions.per.turn 2 }
  writeini $char(%dragonhunt.file.name) Info ActionsPerTurn %actions.per.turn

  ; These are the skills that all dragons know
  writeini $char(%dragonhunt.file.name) skills resist-charm 100
  writeini $char(%dragonhunt.file.name) skills resist-stun 100
  writeini $char(%dragonhunt.file.name) skills Resist-blind 100
  writeini $char(%dragonhunt.file.name) skills Resist-poison 95
  writeini $char(%dragonhunt.file.name) skills Resist-paralysis 95
  writeini $char(%dragonhunt.file.name) skills Resist-slow 70
  writeini $char(%dragonhunt.file.name) skills Resist-Disarm 100
  writeini $char(%dragonhunt.file.name) skills Resist-Weaponlock 100
  writeini $char(%dragonhunt.file.name) skills Resist-Curse 70
  writeini $char(%dragonhunt.file.name) skills TrueStrike.on on
  if (%dragon.level >= 800) { writeini $char(%dragonhunt.file.name) skills desperateblows 1 } 

  if ($rand(1,10) <= 3) { writeini $char(%dragonhunt.file.name) skills DoubleTurn.on on }

  ; Depending on the element of the dragon it will have different skills
  if (%dragon.element = fire) { writeini $char(%dragonhunt.file.name) skills MightyStrike 1  }
  if (%dragon.element = earth) { writeini $char(%dragonhunt.file.name) skills RoyalGuard 1 }
  if (%dragon.element = ice) { writeini $char(%dragonhunt.file.name) skills ManaWall 1 }
  if (%dragon.element = wind) { writeini $char(%dragonhunt.file.name) skills utsusemi.on on | writeini $char(%dragonhunt.file.name) skills utsusemi.shadow $rand(2,5)  }
  if ((%dragon.element = water) && (%actions.per.turn = 1)) { writeini $char(%dragonhunt.file.name) skills Sugitekai 1 }
  if (%dragon.element = lightning) { writeini $char(%dragonhunt.file.name) skills WeaponBash 1 }
  if (%dragon.element = dark) { writeini $char(%dragonhunt.file.name) skills Konzen-Ittai 1  }
  if (%dragon.element = light) { writeini $char(%dragonhunt.file.name) skills DrainSamba 1 }
  if (%dragon.element = crystal) { 
    writeini $char(%dragonhunt.file.name) skills MightyStrike 1
    writeini $char(%dragonhunt.file.name) skills Konzen-Ittai 1
    writeini $char(%dragonhunt.file.name) skills DrainSamba 1
  }

  writeini $char(%dragonhunt.file.name) modifiers light 100
  writeini $char(%dragonhunt.file.name) modifiers dark 100
  writeini $char(%dragonhunt.file.name) modifiers fire 100
  writeini $char(%dragonhunt.file.name) modifiers ice 100
  writeini $char(%dragonhunt.file.name) modifiers water 100
  writeini $char(%dragonhunt.file.name) modifiers lightning 100
  writeini $char(%dragonhunt.file.name) modifiers wind 100
  writeini $char(%dragonhunt.file.name) modifiers earth 100

  ; Dragon will heal its own element
  writeini $char(%dragonhunt.file.name) modifiers %dragon.element 300
  writeini $char(%dragonhunt.file.name) modifiers heal %dragon.element

  if (%dragon.element = crystal) { 
    writeini $char(%dragonhunt.file.name) modifiers light 300
    writeini $char(%dragonhunt.file.name) modifiers dark 300
    writeini $char(%dragonhunt.file.name) modifiers fire 300
    writeini $char(%dragonhunt.file.name) modifiers heal light.dark.fire
  }

  ; Add the dragon scales
  writeini $char(%dragonhunt.file.name) NaturalArmor Name Dragon Scales
  var %dragon.naturalarmor $calc(15 * %dragon.level)
  if (%dragon.naturalarmor >= 20000) { var %dragon.naturalarmor 20000 }
  writeini $char(%dragonhunt.file.name) NaturalArmor Max %dragon.naturalarmor
  writeini $char(%dragonhunt.file.name) NaturalArmor Current %dragon.naturalarmor

  ; Add guardian style
  writeini $char(%dragonhunt.file.name) styles equipped Guardian
  writeini $char(%dragonhunt.file.name) styles Guardian $rand(2,4)
  writeini $char(%dragonhunt.file.name) styles GuardianXP 1

  ; Add modifiers
  writeini $char(%dragonhunt.file.name) modifiers HandToHand 60
  writeini $char(%dragonhunt.file.name) modifiers Whip 60
  writeini $char(%dragonhunt.file.name) modifiers sword 70
  writeini $char(%dragonhunt.file.name) modifiers gun 60
  writeini $char(%dragonhunt.file.name) modifiers rifle 60
  writeini $char(%dragonhunt.file.name) modifiers katana 70
  writeini $char(%dragonhunt.file.name) modifiers wand 40
  writeini $char(%dragonhunt.file.name) modifiers spear 80
  writeini $char(%dragonhunt.file.name) modifiers scythe 80
  writeini $char(%dragonhunt.file.name) modifiers GreatSword 85
  writeini $char(%dragonhunt.file.name) modifiers bow 82
  writeini $char(%dragonhunt.file.name) modifiers glyph 75
  writeini $char(%dragonhunt.file.name) modifiers FinishingTouch 0
  writeini $char(%dragonhunt.file.name) modifiers MurderSpree 0
  writeini $char(%dragonhunt.file.name) modifiers MurderSpreeII 0

  ; Add flying skill for older dragons
  if (%dragon.level >= 150) { writeini $char(%dragonhunt.file.name) skills flying 1 }

  $boost_monster_hp(%dragonhunt.file.name, dragonhunt, %dragon.level)
  $levelsync(%dragonhunt.file.name, %dragon.level)
  writeini $char(%dragonhunt.file.name) basestats str $readini($char(%dragonhunt.file.name), battle, str)
  writeini $char(%dragonhunt.file.name) basestats def $readini($char(%dragonhunt.file.name), battle, def)
  writeini $char(%dragonhunt.file.name) basestats int $readini($char(%dragonhunt.file.name), battle, int)
  writeini $char(%dragonhunt.file.name) basestats spd $readini($char(%dragonhunt.file.name), battle, spd)
  $fulls(%dragonhunt.file.name, elderdragon) 
  $levelsync(%dragonhunt.file.name, %dragon.level)

  ; Add en-spell for dragons that are 500+
  if (%dragon.level >= 500) {  writeini $char(%dragonhunt.file.name) status en-spell %dragon.element }

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,%dragonhunt.file.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) %dragonhunt.file.name
  $set_chr_name(%dragonhunt.file.name)
  $display.message($readini(translation.dat, battle, EnteredTheBattle),battle) 
  var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters

  if ($dragonhunt.ancientcheck(%dragonhunt.file.name) = true) { writeini $txtfile(battle2.txt) battle bonusitem DragonDiamond }
  else { writeini $txtfile(battle2.txt) battle bonusitem DragonScale.DragonFang.DragonEgg }
}


predator_fight {
  $get_mon_list
  var %monsters.total $numtok(%monster.list,46)

  if ((%monsters.total = 0) || (%monster.list = $null)) { $display.message($readini(translation.dat, Errors, NoMonsAvailable), global) | $endbattle(none) | halt }

  var %number.of.monsters.needed 1
  set %value 1 

  while (%value <= %number.of.monsters.needed) {
    if (%monster.list = $null) { inc %value 1 } 

    var %monsters.total $numtok(%monster.list,46)
    var %random.monster $rand(1, %monsters.total) 
    var %monster.name $gettok(%monster.list,%random.monster,46)
    if (%monsters.total = 0) { inc %value 1 }

    if ($readini($mon(%monster.name), battle, hp) != $null) {  .copy -o $mon(%monster.name) $char(%monster.name) | set %curbat $readini($txtfile(battle2.txt), Battle, List) | %curbat = $addtok(%curbat,%monster.name,46) |  writeini $txtfile(battle2.txt) Battle List %curbat }

    writeini $char(%monster.name) battle status normal

    $set_chr_name(%monster.name) 
    if (%battle.type != ai) { 
      if ($readini($mon(%monster.name), battle, hp) != $null) { 
        $display.message($readini(translation.dat, battle, EnteredTheBattle), battle)
        $display.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)
      }
    }

    if (%battle.type = ai) { set %ai.monster.name $set_chr_name(%monster.name) %real.name | writeini $txtfile(1vs1bet.txt) money monsterfile %monster.name }

    var %battlemonsters $readini($txtfile(battle2.txt), BattleInfo, Monsters) 
    inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters 

    set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
    set %monster.list $deltok(%monster.list,%monster.to.remove,46)
    write $txtfile(battle.txt) %monster.name

    writeini $char(%monster.name) info SpawnAfterDeath Predator 
    writeini $char(%monster.name) info BossLevel $calc($1 - 5)
    writeini $char(%monster.name) descriptions DeathMessage falls over dead! Suddenly a Predator leaps out and gives off a loud chuckle as it prepares to face the heroes.

    writeini $char(%monster.name) modifiers FinishingTouch 0
    writeini $char(%monster.name) modifiers MurderSpree 0
    writeini $char(%monster.name) modifiers MurderSpreeII 0

    $boost_monster_stats(%monster.name)
    $levelsync(%monster.name, $calc($1 - 5))
    $fulls(%monster.name) 

    if (%battlemonsters = 10) { set %number.of.monsters.needed 0 }
    inc %value 1
    else {  
      set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
      set %monster.list $deltok(%monster.list,%monster.to.remove,46)
      dec %value 1
    }
  }

  if (%battle.type != ai) {
    $display.message($readini(translation.dat, events, PredatorFight),battle) 
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function will generate
; the dragon killer npc for the
; dragon hunt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dragonhunt.createdragonkiller {

  .copy -o $char(new_chr) $char(DragonKiller)
  var %dragon.level $readini($dbfile(dragonhunt.db), %dragonhunt.file.name, BattleLevel) 
  inc %dragon.level 25

  writeini $char(DragonKiller) info flag npc
  writeini $char(DragonKiller) Basestats name Dragon Killer
  writeini $char(DragonKiller) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(DragonKiller) info gender its
  writeini $char(DragonKiller) info gender2 its
  writeini $char(DragonKiller) info bosslevel %dragon.level
  writeini $char(DragonKiller) descriptions char is a large and powerful machine designed by the Allied Forces to help slay dragons.  
  writeini $char(DragonKiller) monster type machine
  writeini $char(DragonKiller) info CanTaunt false
  writeini $char(DragonKiller) info IgnoreElementalMessage true
  writeini $char(DragonKiller) Info DragonKiller true

  if ((%dragon.level >= 500) && (%dragon.level <= 1000)) { writeini $char(DragonKiller) monster elite true }
  if (%dragon.level > 1000) { writeini $char(DragonKiller) monster SuperElite true }

  var %base.hp.tp $round($calc(5 * %dragon.level),0)

  writeini $char(DragonKiller) basestats hp %base.hp.tp
  writeini $char(DragonKiller) basestats tp %base.hp.tp

  writeini $char(DragonKiller) battle str $rand(300,500)
  writeini $char(DragonKiller) battle def $rand(10,20)
  writeini $char(DragonKiller) battle int $rand(1,3)
  writeini $char(DragonKiller) battle spd 1

  writeini $char(DragonKiller) weapons equipped CompoundBow+1
  writeini $char(DragonKiller) weapons CompoundBow+1 $calc(%dragon.level + 520) 
  remini $char(DragonKiller) weapons Fists

  ; These are the skills that the dragon killer machine has
  writeini $char(DragonKiller) skills resist-charm 100
  writeini $char(DragonKiller) skills resist-stun 100
  writeini $char(DragonKiller) skills Resist-blind 100
  writeini $char(DragonKiller) skills Resist-poison 100
  writeini $char(DragonKiller) skills Resist-paralysis 100
  writeini $char(DragonKiller) skills Resist-slow 100
  writeini $char(DragonKiller) skills Resist-Disarm 100
  writeini $char(DragonKiller) skills Resist-Weaponlock 100
  writeini $char(DragonKiller) skills Resist-Curse 100
  writeini $char(DragonKiller) skills Resist-Intimidate 100
  writeini $char(DragonKiller) skills TrueStrike.on on
  writeini $char(DragonKiller) skills Archery 500
  writeini $char(DragonKiller) skills Overwhelm 25

  writeini $char(DragonKiller) modifiers light 100
  writeini $char(DragonKiller) modifiers dark 100
  writeini $char(DragonKiller) modifiers fire 100
  writeini $char(DragonKiller) modifiers ice 100
  writeini $char(DragonKiller) modifiers water 100
  writeini $char(DragonKiller) modifiers lightning 100
  writeini $char(DragonKiller) modifiers wind 100
  writeini $char(DragonKiller) modifiers earth 100

  ; Add guardian style
  writeini $char(DragonKiller) styles equipped Guardian
  writeini $char(DragonKiller) styles Guardian $rand(1,3)
  writeini $char(DragonKiller) styles GuardianXP 1

  ; Add modifiers
  writeini $char(DragonKiller) modifiers HandToHand 100
  writeini $char(DragonKiller) modifiers Whip 100
  writeini $char(DragonKiller) modifiers sword 100
  writeini $char(DragonKiller) modifiers gun 100
  writeini $char(DragonKiller) modifiers rifle 100
  writeini $char(DragonKiller) modifiers katana 100
  writeini $char(DragonKiller) modifiers wand 100
  writeini $char(DragonKiller) modifiers spear 100
  writeini $char(DragonKiller) modifiers scythe 100
  writeini $char(DragonKiller) modifiers GreatSword 120
  writeini $char(DragonKiller) modifiers bow 100
  writeini $char(DragonKiller) modifiers glyph 100

  ; Add augments
  writeini $char(DragonKiller) augments CompoundBow+1 IgnoreGuardian.MeleeBonus.HurtDragon

  $boost_monster_hp(DragonKiller, dragonhunt, %dragon.level)
  $levelsync(DragonKiller, %dragon.level)
  writeini $char(DragonKiller) basestats str $readini($char(DragonKiller), battle, str)
  writeini $char(DragonKiller) basestats def $readini($char(DragonKiller), battle, def)
  writeini $char(DragonKiller) basestats int $readini($char(DragonKiller), battle, int)
  writeini $char(DragonKiller) basestats spd $readini($char(DragonKiller), battle, spd)
  $fulls(DragonKiller, elderdragon) 
  $levelsync(DragonKiller, %dragon.level)

  set %curbat $readini($txtfile(battle2.txt), Battle, List) |  %curbat = $addtok(%curbat,DragonKiller,46) |  writeini $txtfile(battle2.txt) Battle List %curbat | write $txtfile(battle.txt) DragonKiller
  $set_chr_name(DragonKiller)
  $display.message($readini(translation.dat, events,DragonKiller),battle) 
  var %battlenpcs $readini($txtfile(battle2.txt), BattleInfo, NPCs) | inc %battlenpcs 1 | writeini $txtfile(battle2.txt) BattleInfo NPCs %battlenpcs


  writeini battlestats.dat AlliedForces DragonKiller false
}
