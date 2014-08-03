battle.version { return 2.5 } 
system.dat.version { return 080314 }
quitmsg { return Battle Arena version $battle.version written by James  "Iyouboushi" }
system_defaults_check {
  if (%player_folder = $null) { set %player_folder characters\ }
  if (%boss_folder = $null) { set %boss_folder bosses\ }
  if (%monster_folder = $null) { set %monster_folder monsters\ }
  if (%zapped_folder = $null) { set %zapped_folder zapped\ }
  if (%npc_folder = $null) { set %npc_folder npcs\ }
  if (%summon_folder = $null) { set %summon_folder summons\ }
  if (%help_folder = $null) { set %help_folder help-files\ }
  if (%battleis = $null) { set %battleis off }
  if (%battleisopen = $null) { set %battleisopen off }

  var %last.system.dat.version $readini(system.dat, version, SystemDatVersion)
  if (%last.system.dat.version != $system.dat.version) { 
    if ($readini(system.dat, system, botType) = $null) { writeini system.dat system botType IRC }
    if ($readini(system.dat, system, AllowColors) = $null) { writeini system.dat system AllowColors true }
    if ($readini(system.dat, system, automatedbattlesystem) = $null) { writeini system.dat system automatedbattlesystem on } 
    if ($readini(system.dat, system, automatedaibattlecasino) = $null) { writeini system.dat system automatedaibattlecasino off } 
    if ($readini(system.dat, system, aisystem) = $null) { writeini system.dat system aisystem on } 
    if ($readini(system.dat, system, basexp) = $null) { writeini system.dat system basexp 100 } 
    if ($readini(system.dat, system, basebossxp) = $null) { writeini system.dat system basebossxp 500 } 
    if ($readini(system.dat, system, startingorbs) = $null) { writeini system.dat system startingorbs 1000 } 
    if ($readini(system.dat, system, maxHP) = $null) { writeini system.dat system maxHP 2500 } 
    if ($readini(system.dat, system, maxTP) = $null) { writeini system.dat system maxTP 500 } 
    if ($readini(system.dat, system, maxIG) = $null) { writeini system.dat system maxIG 100 } 
    if ($readini(system.dat, system, maxOrbReward) = $null) { writeini system.dat system maxOrbReward 20000 } 
    if ($readini(system.dat, system, MaxGauntletOrbReward) = $null) { writeini system.dat system MaxGauntletOrbReward 50000 } 
    if ($readini(system.dat, system, maxshoplevel) = $null) { writeini system.dat system maxshoplevel 25 } 
    if ($readini(system.dat, system, EnableDoppelganger) = $null) { writeini system.dat system EnableDoppelganger true }
    if ($readini(system.dat, system, EnableWarmachine) = $null) { writeini system.dat system EnableWarmachine true }
    if ($readini(system.dat, system, EnableBandits) = $null) { writeini system.dat system EnableBandits true }
    if ($readini(system.dat, system, EnablePirates) = $null) { writeini system.dat system EnablePirates true }
    if ($readini(system.dat, system, EnableCrystalShadow) = $null) { writeini system.dat system EnableCrystalShadow true }
    if ($readini(system.dat, system, EnablePresidentKidnapping) = $null) { writeini system.dat system EnablePresidentKidnapping true }
    if ($readini(system.dat, system, EnableNPCKidnapping) = $null) { writeini system.dat system EnableNPCKidnapping true }
    if ($readini(system.dat, system, AllowDemonwall) = $null) { writeini system.dat system AllowDemonwall yes }
    if ($readini(system.dat, system, AllowDemonwall) = $null) { writeini system.dat system AllowWallOfFlesh yes }
    if ($readini(system.dat, system, MaxDemonWallTurns) = $null) { writeini system.dat system MaxDemonWallTurns 10 }
    if ($readini(system.dat, system, MaxDemonWallTurns) = $null) { writeini system.dat system MaxWallOfFleshTurns 16 }
    if ($readini(system.dat, system, EnableChests) = $null) { writeini system.dat system EnableChests true }
    if ($readini(system.dat, system, MaxCharacters) = $null) { writeini system.dat system MaxCharacters 2 }
    if ($readini(system.dat, system, TimeForIdle) = $null) { writeini system.dat system TimeForIdle 180 }
    if ($readini(system.dat, system, TimeToEnter) = $null) { writeini system.dat system TimeToEnter 120 }
    if ($readini(system.dat, system, ShowOrbsCmdInChannel) = $null) { writeini system.dat system ShowOrbsCmdInChannel true }
    if ($readini(system.dat, system, ShowDiscountMessage) = $null) { writeini system.dat system ShowDiscountMessage false }
    if ($readini(system.dat, system, BattleDamageFormula) = $null) { writeini system.dat system BattleDamageFormula 3 }
    if ($readini(system.dat, system, EnableBattlefieldEvents) = $null) { writeini system.dat system EnableBattlefieldEvents true }
    if ($readini(system.dat, system, GuaranteedBossBattles) = $null) { writeini system.dat system GuaranteedBossBattles 10.15.20.30.60.100.150.180.220.280.320.350.401.440.460.501.560.601.670.705.780.810.890.920.999.1100.1199.1260. 1305.1464.1500.1650.1720.1880.1999.2050.2250.9999  }
    if ($readini(system.dat, system, BonusEvent) = $null) { writeini system.dat system BonusEvent false }
    if ($readini(system.dat, system, IgnoreDmgCap) = $null) { writeini system.dat system IgnoreDmgCap false }
    if ($readini(system.dat, system, MaxNumberOfMonsInBattle) = $null) { writeini system.dat system MaxNumberOfMonsInBattle 6 }
    if ($readini(system.dat, system, ScoreBoardType) = $null) { writeini system.dat system ScoreBoardType 2 }
    if ($readini(system.dat, system, EmptyRoundsBeforeStreakReset) = $null) { writeini system.dat system EmptyRoundsBeforeStreakReset 10 }
    if ($readini(system.dat, system, ChestTime) = $null) { writeini system.dat system ChestTime 45 }
    if ($readini(system.dat, system, MimicChance) = $null) { writeini system.dat system MimicChance 10 }
    if ($readini(system.dat, system, AllowMechs) = $null) { writeini system.dat system AllowMechs true }
    if ($readini(system.dat, system, PhantomBetters) = $null) { writeini system.dat system PhantomBetters 13 }
    if ($readini(system.dat, system, EnableAuctionHouse) = $null) { writeini system.dat system EnableAuctionHouse true }
    if ($readini(system.dat, system, BattleThrottle) = $null) { writeini system.dat system BattleThrottle false }
    if ($readini(system.dat, system, LimitPortalBattles) = $null) { writeini system.dat system LimitPortalBattles true }
    if ($readini(system.dat, system, GenerateHTML) = $null) { writeini system.dat system GenerateHTML true }
    if ($readini(system.dat, system, PlayersMustDieMode) = $null) { writeini system.dat system PlayersMustDieMode false }
    if ($readini(system.dat, system, WheelGameCost) = $null) { writeini system.dat system WheelGameCost 500 }
    if ($readini(system.dat, system, TwitchDelayTime) = $null) { writeini system.dat system TwitchDelayTime 2 }

    if ($readini(system.dat, statprices, hp) = $null) { writeini system.dat statprices hp 150 }
    if ($readini(system.dat, statprices, tp) = $null) { writeini system.dat statprices tp 150 }
    if ($readini(system.dat, statprices, str) = $null) { writeini system.dat statprices str 250 }
    if ($readini(system.dat, statprices, def) = $null) { writeini system.dat statprices def 250 }
    if ($readini(system.dat, statprices, int) = $null) { writeini system.dat statprices int 250 }
    if ($readini(system.dat, statprices, spd) = $null) { writeini system.dat statprices spd 250 }
    if ($readini(system.dat, statprices, ig) = $null) { writeini system.dat statprices ig 800 }

    if ($readini(system.dat, mech, EnergyCostConstant) = $null) { writeini system.dat mech EnergyCostConstant 100 }
    if ($readini(system.dat, mech, StatMultiplier) = $null) { writeini system.dat mech StatMultiplier 2 }
    if ($readini(system.dat, mech, EngineUpgradeCost) = $null) { writeini system.dat mech EngineUpgradeCost 1500 }
    if ($readini(system.dat, mech, EnergyUpgradeCost) = $null) { writeini system.dat mech EnergyUpgradeCost 500 }
    if ($readini(system.dat, mech, HealthUpgradeCost) = $null) { writeini system.dat mech HealthUpgradeCost 200 }
    if ($readini(system.dat, mech, RepairHPItem) = $null) { writeini system.dat mech RepairHPItem MetalScrap }
    if ($readini(system.dat, mech, RepairEnergyItem) = $null) { writeini system.dat mech RepairEnergyItem E-tank }
    if ($readini(system.dat, mech, MaxHP) = $null) { writeini system.dat mech maxHP 10000 }
    if ($readini(system.dat, mech, MaxEnergy) = $null) { writeini system.dat mech MaxEnergy 5000 }
    if ($readini(system.dat, mech, MaxEngine) = $null) { writeini system.dat mech MaxEngine 5 }
    if ($readini(system.dat, mech, MechPurchaseCost) = $null) { writeini system.dat mech MechPurchaseCost 1000 }

    if ($readini(system.dat, auctionInfo, TimeBetweenAuctions) = $null) { writeini system.dat AuctionInfo TimeBetweenAuction 3600 }

    if ($readini(battlestats.dat, battle, LevelAdjust) = $null) { writeini battlestats.dat battle LevelAdjust 0 }
    if ($readini(battlestats.dat, battle, emptyRounds) = $null) { writeini battlestats.dat battle emptyRounds 0 }
    if ($readini(battlestats.dat, conquest, LastTally) = $null) { writeini battlestats.dat conquest LastTally $ctime }
    if ($readini(battlestats.dat, conquest, ConquestPoints) = $null) { writeini battlestats.dat conquest ConquestPoints -1000 }
    if ($readini(battlestats.dat, conquest, ConquestBonus) = $null) { writeini battlestats.dat conquest ConquestBonus 0 }
    if ($readini(battlestats.dat, dragonballs, ShenronWish) = $null) { writeini battlestats.dat dragonballs ShenronWish off }
    if ($readini(battlestats.dat, dragonballs, ShenronWish.rounds) = $null) { writeini battlestats.dat dragonballs ShenronWish.rounds 1 }
    if ($readini(battlestats.dat, dragonballs, DragonBallsFound) = $null) { writeini battlestats.dat dragonballs DragonBallsFound 0 }
    if ($readini(battlestats.dat, dragonballs, DragonballsActive) = $null) { writeini battlestats.dat dragonballs DragonballsActive yes }
    if ($readini(battlestats.dat, dragonballs, DragonballChance) = $null) { writeini battlestats.dat dragonballs DragonballChance 10 }

    var %number.of.gamedays $readini(battlestats.dat, battle, GameDays)
    if (%number.of.gamedays = $null) { 
      var %number.of.battles $readini(battlestats.dat, battle, TotalBattles)
      if (%number.of.battles = 0) { var %number.of.battles 1 }
      var %number.of.gamedays $round($calc(%number.of.battles / 8),0)
      writeini battlestats.dat battle GameDays %number.of.gamedays
    }

    ; Shop NPC stuff
    if ($readini(shopnpcs.dat, NPCStatus, Santa) = $null) { writeini shopnpcs.dat NPCStatus Santa false }
    if ($readini(shopnpcs.dat, NPCStatus, EasterBunny) = $null) { writeini shopnpcs.dat NPCStatus EasterBunny false }
    if ($readini(shopnpcs.dat, NPCStatus, HealingMerchant) = $null) { writeini shopnpcs.dat NPCStatus HealingMerchant false }
    if ($readini(shopnpcs.dat, NPCStatus, BattleMerchant) = $null) { writeini shopnpcs.dat NPCStatus BattleMerchant false }
    if ($readini(shopnpcs.dat, NPCStatus, DiscountCardMerchant) = $null) { writeini shopnpcs.dat NPCStatus DiscountCardMerchant false }
    if ($readini(shopnpcs.dat, NPCStatus, AlliedForcesPresident) = $null) { writeini shopnpcs.dat NPCStatus AlliedForcesPresident true }
    if ($readini(shopnpcs.dat, NPCStatus, SongMerchant) = $null) { writeini shopnpcs.dat NPCStatus SongMerchant false }
    if ($readini(shopnpcs.dat, NPCStatus, ShieldMerchant) = $null) { writeini shopnpcs.dat NPCStatus ShieldMerchant false }
    if ($readini(shopnpcs.dat, NPCStatus, WheelMaster) = $null) { writeini shopnpcs.dat NPCStatus WheelMaster kidnapped }
    if ($readini(shopnpcs.dat, NPCStatus, TravelMerchant) = $null) { writeini shopnpcs.dat NPCStatus TravelMerchant false }
    if ($readini(shopnpcs.dat, NPCStatus, Gardener) = $null) { writeini shopnpcs.dat NPCStatus Gardener kidnapped }

    if ($readini(shopnpcs.dat, Events, FrostLegionDefeated) = $null) { writeini shopnpcs.dat Events FrostLegionDefeated false }
    if ($readini(shopnpcs.dat, Events, SavedElves) = $null) { writeini shopnpcs.dat Events SavedElves 0 }
    if ($readini(shopnpcs.dat, NPCNames, Santa) = $null) { writeini shopnpcs.dat NPCNames Santa Santa }
    if ($readini(shopnpcs.dat, NPCNames, EasterBunny) = $null) { writeini shopnpcs.dat NPCNames EasterBunny Easter Bunny }
    if ($readini(shopnpcs.dat, NPCNames, DiscountCardMerchant) = $null) { writeini shopnpcs.dat NPCNames DiscountCardMerchant Myles the Discount Merchant }
    if ($readini(shopnpcs.dat, NPCNames, HealingMerchant) = $null) { writeini shopnpcs.dat NPCNames HealingMerchant Katelyn the Healing Merchant }
    if ($readini(shopnpcs.dat, NPCNames, BattleMerchant) = $null) { writeini shopnpcs.dat NPCNames BattleMerchant Gerhardt the Battle Merchant }
    if ($readini(shopnpcs.dat, NPCNames, AlliedForcesPresident) = $null) { writeini shopnpcs.dat NPCNames AlliedForcesPresident Allied Forces President }
    if ($readini(shopnpcs.dat, NPCNames, SongMerchant) = $null) { writeini shopnpcs.dat NPCNames SongMerchant Spoony the Bard }
    if ($readini(shopnpcs.dat, NPCNames, ShieldMerchant) = $null) { writeini shopnpcs.dat NPCNames ShieldMerchant Gondo the Shield Merchant }
    if ($readini(shopnpcs.dat, NPCNames, WheelMaster) = $null) { writeini shopnpcs.dat NPCNames WheelMaster Dodoh the Wheel Master }
    if ($readini(shopnpcs.dat, NPCNames, TravelMerchant) = $null) { writeini shopnpcs.dat NPCNames TravelMerchant Beedle the Traveling Merchant }
    if ($readini(shopnpcs.dat, NPCNames, Gardener) = $null) { writeini shopnpcs.dat NPCNames Gardener Green Thumb the Garden Moogle }

    ; Allied Forces Garden stuff
    if ($readini(garden.dat, GardenStats, XP) = $null) { writeini garden.dat GardenStats XP 0 }
    if ($readini(garden.dat, GardenStats, Level) = $null) { writeini garden.dat GardenStats Level 1 }
    if ($readini(garden.dat, GardenStats, LastChecked) = $null) { writeini garden.dat GardenStats LastChecked $ctime }
    if ($readini(garden.dat, GardenStats, Bonus) = $null) { writeini garden.dat GardenStats Bonus 0 }

    if ($readini(garden.dat, Seeds, Planted) = $null) { writeini garden.dat Seeds Planted 0 }
    if ($readini(garden.dat, Seeds, Saplings) = $null) { writeini garden.dat Seeds Saplings 0 }
    if ($readini(garden.dat, Seeds, Trees) = $null) { writeini garden.dat Seeds Trees 0 }
    if ($readini(garden.dat, Plants, Planted) = $null) { writeini garden.dat Plants Planted 0 }
    if ($readini(garden.dat, Plants, Bloomed) = $null) { writeini garden.dat Plants Bloomed 0 }

    writeini system.dat version SystemDatVersion $system.dat.version
  }

  ; Check to see if all the remotes are loaded (except control.mrc as that causes an infinite loop)
  /.load -rs characters.mrc 
  /.load -rs ai.mrc
  /.load -rs battlecontrol.mrc
  /.load -rs attacks.mrc
  /.load -rs techs.mrc
  /.load -rs mechs.mrc
  /.load -rs items.mrc
  /.load -rs shop.mrc
  /.load -rs style.mrc
  /.load -rs skills.mrc 
  /.load -rs auctionhouse.mrc
  /.load -rs achivements.mrc
  /.load -rs shopnpcs.mrc
  /.load -rs garden.mrc
  /.load -rs help.mrc
  /.load -rs dccchat.mrc

  ; Check to see if the aliases are loaded (except this one as it'd cause a loop)
  /.load -a battlealiases.als
  /.load -a bossaliases.als
  /.load -a scoreboard.als

  ; Remove files that are no longer needed.
  .remove $npc(Soifon)
  .remove $npc(Yoruichi_Shihoiun)
  .remove $mon(Demonic_Succubus)
  .remove $lstfile(items_songs.lst)
}

checkscript {
  var %command $1-
  %command = $remove(%command,$set_chr_name)
  %command = $remove(%command,$chr(36) $+ 1, $chr(36) $+ 2, $chr(36) $+ 3, $chr(36) $+ 4, $chr(36) $+ 5)
  %command = $remove(%command,$chr(36) $+ set_chr_name())
  %command = $remove(%command,$chr(36) $+ $chr(43))
  %command = $replacex(%command,$chr(36) $+ gender(),OK)
  %command = $replacex(%command,$chr(36) $+ gender2(),OK)
  %command = $replacex(%command,$chr(36) $+ gender3(),OK)
  if ($chr(47) $+ set isin %command) { $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  if (| isin %command) { $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  if (/ isin %command) { $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  if (($chr(36) $+ readini isin %command) || ($chr(36) $+ decode isin $1-)) { $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  if (writeini isin %command) {  $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  if (encode isin %command) { $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  if (decode isin %command) { $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  if ($chr(36) isin %command) { $display.private.message($readini(translation.dat, errors, NoScriptsWithCommands)) | halt }
  return
}
checkchar {
  var %check $readini($char($1), Stuff, ShopLevel)
  if (%check = $null) { $display.system.message($readini(translation.dat, errors, NotInDataBank), private) | halt }
  else { return }
}
controlcommand.check {
  var %player.access.list $readini($char($2), access, list)
  if (%player.access.list = $null) { writeini $char($2) access list $2 | var %player.access.list $2 }
  if ($istok(%player.access.list,$1,46) = $false) { $display.system.message($readini(translation.dat, errors, DoNotHaveAccessToThatChar), private) | halt }

  if ($readini($char($2), info, clone) = yes) {
    var %clone.owner $readini($char($2), info, cloneowner)
    var %style.equipped $readini($char(%clone.owner), styles, equipped)
    if (%style.equipped != doppelganger) { $set_chr_name(%clone.owner) | $display.system.message($readini(translation.dat, errors, MustUseDoppelgangerStyleToControl), private) | halt }
  }

  if ($readini($char($2), info, summon) = yes) {
    var %owner $readini($char($2), info, owner)
    var %style.equipped $readini($char(%owner), styles, equipped)
    if (%style.equipped != beastmaster) {  $set_chr_name(%owner) | $display.system.message($readini(translation.dat, errors, MustUseBeastmasterStyleToControl), private) | halt }
  }

  return
}
check.allied.notes {
  var %allied.notes $readini($char($1), stuff, alliednotes) 
  if (%allied.notes = $null) { var %allied.notes no }
  $set_chr_name($1) 
  if ($readini(system.dat, system, botType) = IRC) {
    if ($2 = channel) {  $display.system.message($readini(translation.dat, system, ViewAlliedNotes),private) } 
    else { $display.private.message($readini(translation.dat, system, ViewAlliedNotes)) }
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, $readini(translation.dat, system, ViewAlliedNotes)) }

  unset %real.name | unset %hstats 
}
check.doubledollars {
  var %doubledollars $readini($char($1), stuff, doubledollars) 
  if (%doubledollars = $null) { writeini $char($1) stuff doubledollars 100 | var %doubledollars 100 }
  var %currency.symbol $readini(system.dat, system, BetCurrency)
  if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }
  $set_chr_name($1) 
  if ($readini(system.dat, system, botType) = IRC) {
    if ($2 = channel) {  $display.system.message($readini(translation.dat, system, ViewDoubleDollars),private) } 
    else { $display.private.message($readini(translation.dat, system, ViewDoubleDollars)) }
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, $readini(translation.dat, system, ViewDoubleDollars)) }

  unset %real.name | unset %hstats 
}

lookat {
  $weapon_equipped($1) | $set_chr_name($1)
  var %equipped.accessory $readini($char($1), equipment, accessory) 
  if (%equipped.accessory = $null) { var %equipped.accessory nothing }
  var %equipped.armor.head $readini($char($1), equipment, head) 
  if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
  var %equipped.armor.body $readini($char($1), equipment, body) 
  if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
  var %equipped.armor.legs $readini($char($1), equipment, legs) 
  if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
  var %equipped.armor.feet $readini($char($1), equipment, feet) 
  if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
  var %equipped.armor.hands $readini($char($1), equipment, hands) 
  if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }

  if ($readini($char($1), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($1), info, CustomTitle) $+ " }

  if ($readini(system.dat, system, botType) = IRC) { 
    if ($2 = channel) {  $display.system.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped $iif(%weapon.equipped.left != $null, and %weapon.equipped.left weapons, weapon),private) }
    if ($2 != channel) { $display.private.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped weapon.) }
  }
  if ($readini(system.dat, system, botType) = DCCchat) {
    var %look.message 3 $+ %real.name is wearing %equipped.armor.head on $gender($1) head, %equipped.armor.body on $gender($1) body, %equipped.armor.legs on $gender($1) legs, %equipped.armor.feet on $gender($1) feet, %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped weapon.
  $dcc.private.message($nick, %look.message) }
} 
char { return " $+ $mircdir $+ %player_folder $+ $1 $+ .char" }
boss { return " $+ $mircdir $+ %boss_folder $+ $1 $+ .char" } 
mon { return " $+ $mircdir $+ %monster_folder $+ $1 $+ .char" }
npc { return " $+ $mircdir $+ %npc_folder $+ $1 $+ .char" }
summon { return " $+ $mircdir $+ %summon_folder $+ $1 $+ .char" } 
zapped { return " $+ $mircdir $+ %player_folder $+ zapped $+ \ $+ $1 $+ .char" }
lstfile { return " $+ $mircdir $+ lsts\ $+ $1" }
txtfile {  return " $+ $mircdir $+ txts\ $+ $1" }
dbfile { return " $+ $mircdir $+ dbs\ $+ $1" }
char_path { return " $+ $mircdir $+ %player_folder $+ " }
mon_path { return " $+ $mircdir $+ %monster_folder $+ " }
boss_path { return " $+ $mircdir $+ %boss_folder $+ " }
npc_path { return " $+ $mircdir $+ %npc_folder $+ " }
password { set %password $readini($char($1), n, Info, Password) }
passhurt { set %passhurt $readini($char($1), Info, Passhurt) | return }
userlevel { set %userlevel $readini($char($1), Info, user) | return }
clr_passhurt { writeini $char($1) Info Passhurt 0 | unset %passhurt | return }
gender { return $readini($char($1), Info, Gender) }
gender2 {
  if ($gender($1) = her) { return her }
  if ($gender($1) = its) { return it }
  else { return him }
}
gender3 {
  if ($gender($1) = her) { return she }
  if ($gender($1) = its) { return it }
  else { return he }
}
enemy { return %enemy }
get.level.old {
  var %str $readini($char($1),battle, str)
  var %def $readini($char($1), battle, def)
  var %int $readini($char($1), battle, int)
  var %spd $readini($char($1), battle, spd)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %spd

  var %level $round($calc(%level / 20), 1)

  return %level
}

get.level {
  var %str $readini($char($1),battle, str)
  var %def $readini($char($1), battle, def)
  var %int $readini($char($1), battle, int)
  var %spd $round($calc($readini($char($1), battle, spd) * .5),0)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %spd

  var %level $round($calc(%level / 18), 1)

  return %level
}

get.level.basestats {
  var %str $readini($char($1), BaseStats, str)
  var %def $readini($char($1), basestats, def)
  var %int $readini($char($1), basestats, int)
  var %spd $round($calc($readini($char($1), basestats, spd) * .5),0)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %spd

  var %level $round($calc(%level / 18), 1)
  return %level
}


shopnpc.totalinfo  {

  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { return }
    else { 
      var %temp.playerdeaths $readini($char(%name), Stuff, TotalDeaths)
      if (%temp.playerdeaths = $null) { var %temp.playerdeaths 0 }
      inc %player.deaths %temp.playerdeaths

      var %temp.playershop $readini($char(%name), Stuff, ShopLevel)
      if (%temp.playershop = $null) { var %temp.playershop 1 }
      inc %player.shoplevels %temp.playershop

      var %temp.playerbattles $readini($char(%name), Stuff, TotalBattles)
      if (%temp.playerbattles = $null) { var %temp.playerbattles 0 }
      inc %player.totalbattles %temp.playerbattles

      var %temp.playerachievements $readini($char(%name), Stuff, TotalAchievements)
      if (%temp.playerachievements = $null) { var %temp.playerachievements 0 }
      inc %player.totalachievements %temp.playerachievements

      var %temp.totalparries $readini($char(%name), Stuff, TimesParried)
      if (%temp.totalparries = $null) { var %temp.totalparries 0 }
      inc %player.totalparries %temp.totalparries

    }    
  }

  unset %file | unset %name
}

total.player.deaths {
  var %player.deaths 0 

  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { inc %value 1 }
    else { 
      var %temp.playerdeaths $readini($char(%name), Stuff, TotalDeaths)
      if (%temp.playerdeaths = $null) { var %temp.playerdeaths 0 }

      inc %player.deaths %temp.playerdeaths
      inc %value 1
    }
  }

  unset %file | unset %name
  return %player.deaths
}

total.player.shoplevels {
  var %player.shoplevels 0 

  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { inc %value 1 }
    else { 
      var %temp.playershop $readini($char(%name), Stuff, ShopLevel)
      if (%temp.playershop = $null) { var %temp.playershop 1 }

      inc %player.shoplevels %temp.playershop
      inc %value 1
    }
  }

  unset %file | unset %name
  return %player.shoplevels
}

total.player.battles {
  var %player.totalbattles 0 

  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { inc %value 1 }
    else { 
      var %temp.playershop $readini($char(%name), Stuff, TotalBattles)
      inc %player.totalbattles %temp.playershop
      inc %value 1
    }
  }

  unset %file | unset %name
  return %player.totalbattles
}

allowcolors {
  if ($readini(system.dat, system, AllowColors) = false) { return false }
  return true
}

display.system.message {
  ; $1 = the message
  ; $2 = is a flag for the DCCchat option to determine where it sends the message

  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }

  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan %message.to.display  }
  if ($readini(system.dat, system, botType) = TWITCH) {
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) 1 %twitch.delay /query %battlechan %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { 
    if ((%battle.type = ai) && ($2 = battle)) { $dcc.global.message(%message.to.display) | return } 

    if ($2 = private) { $dcc.private.message($nick, %message.to.display) }
    if ($2 = battle) { $dcc.battle.message(%message.to.display) }
    if ($2 = $null) { $dcc.global.message(%message.to.display) }
    if ($2 = global) { $dcc.global.message(%message.to.display) }
  }
}
display.system.message.delay {
  ; $1 = the message
  ; $2 = is a flag for the DCCchat option to determine where it sends the message
  ; $3 = delay

  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }

  var %delay.time $3
  if (%delay.time = $null) { var %delay.time 1 }

  if ($readini(system.dat, system, botType) = IRC) { 
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) 1 %delay.time /query %battlechan %message.to.display
  }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %delay.time %twitch.delay
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) 1 %delay.time /query %battlechan %message.to.display
  }

  if ($readini(system.dat, system, botType) = DCCchat) { 
    if ((%battle.type = ai) && ($2 = battle)) { $dcc.global.message(%message.to.display) | return } 

    if ($2 = private) { $dcc.private.message($nick, %message.to.display) }
    if ($2 = battle) { $dcc.battle.message(%message.to.display) }
    if ($2 = $null) { $dcc.global.message(%message.to.display) }
    if ($2 = global) { $dcc.global.message(%message.to.display) }
  }
}

display.private.message {
  var %message.to.display $1-

  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 1 /.msg $nick %message.to.display 
  }
  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 %twitch.delay /query %battlechan %message.to.display
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, %message.to.display) }
}
display.private.message2 {
  var %message.to.display $2

  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 1 /.msg $1 %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($1, %message.to.display) }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 %twitch.delay /query %battlechan %message.to.display
  }

}
display.private.message.delay {
  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 2 /.msg $nick %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, %message.to.display) }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %twitch.delay 1 
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 %twitch.delay /query %battlechan %message.to.display
  }
}
display.private.message.delay.custom {

  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 $2 /.msg $nick %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, %message.to.display) }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %twitch.delay $2
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 %twitch.delay /query %battlechan %message.to.display
  }

}

; This particular display alias is actually defunct, but leaving it in just in case I missed something.
display.battle.message {
  ; $1 = the message
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {  query %battlechan $1  }
  if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message($1)   }
}

get.unspentpoints {
  ; $1 = monster
  ; $2 = level it should be
  ; $3 = type of battle

  var %str $readini($char($1), basestats, str)
  var %def $readini($char($1), basestats, def)
  var %int $readini($char($1), basestats, int)
  var %spd $round($calc($readini($char($1), basestats, spd) * .5),0)

  var %total.points.spent %str
  inc %total.points.spent %def
  inc %total.points.spent %int
  inc %total.points.spent %spd

  if (%battle.type = ai) {  var %points.per.level 20 | var %points.should.have.spent $round($calc(%points.per.level * $2),0) }

  if (%battle.type != ai) {
    if ($isfile($boss($1)) = $true) {  var %points.per.level $rand(21,22) | var %points.should.have.spent $round($calc(%points.per.level * $2),0) }
    if ($isfile($mon($1)) = $true) {   
      if ($2 < 10) { var %points.should.have.spent $round($calc(5 * $2),0) } 
      if ($2 >= 10) { var %points.should.have.spent $round($calc(20 * $2),0) }
    }
    if ($isfile($npc($1)) = $true) {  var %points.should.have.spent $round($calc(18 * $2),0) }
    if ($isfile($summon($4)) = $true) {   var %points.should.have.spent $round($calc(19 * $2),0) }

    if (((($isfile($boss($1)) = $false) && ($isfile($mon($1)) = $false) && ($isfile($npc($1)) = $false) && ($isfile($summon($1)) = $false)))) { var %points.per.level 20 | var %points.should.have.spent $round($calc(%points.per.level * $2),0) }

    if ($3 = doppelganger) { var %points.should.have.spent $round($calc(20 * $2),0) }
    if ($3 = demonwall) { var %points.should.have.spent $round($calc(20 * $2),0) }
    if ($3 = warmachine) { var %points.should.have.spent $round($calc(20 * $2),0) }
    if ($3 = rage) { var %points.should.have.spent $round($calc(1000 * $2),0) }

    if (%bloodmoon = on) { inc %points.should.have.spent $calc(20 * $rand(5,10)) }

  }

  var %unspent.points $calc(%points.should.have.spent - %total.points.spent)

  return %unspent.points
}

player.status { unset %all_status | unset %all_skills | $set_chr_name($1) 
  if ($readini($char($1), Battle, Status) = dead) { set %all_status dead | return } 
  else { 
    if ($readini($char($1), Battle, Status) = rage) { $status_message_check(rage) } 
    if ($readini($char($1), Status, poison) = yes) {  $status_message_check(poisoned) }
    if ($readini($char($1), Status, HeavyPoison) = yes) { $status_message_check(poisoned heavily) }
    if ($readini($char($1), Status, Poison-heavy) = yes) { $status_message_check(poisoned heavily) }
    if ($readini($char($1), Status, Blind) = yes) { $status_message_check(blind) } 
    if ($readini($char($1), Status, Regenerating) = yes) { $status_message_check(regenerating) }
    if ($readini($char($1), Status, TPRegenerating) = yes) { $status_message_check(regenerating TP) }
    if ($readini($char($1), Status, Frozen) = yes) { $status_message_check(frozen) } 
    if ($readini($char($1), Status, shock) = yes) { $status_message_check(shocked) } 
    if ($readini($char($1), Status, burning) = yes) { $status_message_check(burning) } 
    if ($readini($char($1), Status, drowning) = yes) { $status_message_check(drowning) } 
    if ($readini($char($1), Status, earth-quake) = yes) { $status_message_check(shaking violently) } 
    if ($readini($char($1), Status, silence) = yes) { $status_message_check(silenced) } 
    if ($readini($char($1), Status, intimidated) = yes) { $status_message_check(intimidated) }
    if ($readini($char($1), Status, weight) = yes) { $status_message_check(weighed down) } 
    if ($readini($char($1), Status, charmed) = yes) { $status_message_check(charmed by $readini($char($1), Status, Charmer)) }
    if ($readini($char($1), Status, amnesia) = yes) { $status_message_check(under amnesia) }
    if ($readini($char($1), status, paralysis) = yes) { $status_message_check(paralyzed) }
    if ($readini($char($1), Status, drunk) = yes) { $status_message_check(drunk) } 
    if ($readini($char($1), status, tornado) = yes) { $status_message_check(caught in a tornado) }
    if ($readini($char($1), status, zombie) = yes) { $status_message_check(a zombie) }
    if ($readini($char($1), status, slow) = yes) { $status_message_check(slowed) }
    if ($readini($char($1), status, sleep) = yes) { $status_message_check(asleep) }
    if ($readini($char($1), status, stun) = yes) { $status_message_check(stunned) }
    if ($readini($char($1), status, stop) = yes) { $status_message_check(frozen in time) }
    if ($readini($char($1), status, virus) = yes) { $status_message_check(inflicted with a virus) }
    if ($readini($char($1), status, curse) = yes) { $status_message_check(cursed) }
    if ($readini($char($1), status, revive) = yes) { $status_message_check(will auto revive) }
    if ($readini($char($1), status, petrified) = yes) { $status_message_check(petrified) }
    if ($readini($char($1), status, bored) = yes) { $status_message_check(bored) }
    if ($readini($char($1), status, confuse) = yes) { $status_message_check(confused) }
    if ($readini($char($1), status, reflect) = yes) { $status_message_check(has a reflective barrier) }
    if ($readini($char($1), status, invincible) = yes) { $status_message_check(invincible) }
    if ($readini($char($1), skills, drainsamba.on) = on) { $status_message_check(using Drain Samba) }
    if ($readini($char($1), status, defensedown) = on) { $status_message_check(defense down) }
    if ($readini($char($1), status, strengthdown) = on) { $status_message_check(strength down) }
    if ($readini($char($1), status, intdown) = on) { $status_message_check(int down) }
    if (($readini($char($1), status, defenseup) = on) || ($readini($char($1), status, defenseup) = yes)) { $status_message_check(defense up) }
    if ($readini($char($1), status, ethereal) = yes) { $status_message_check(ethereal) }
    if ($readini($char($1), status, ignition.on) = on) { $status_message_check(ignition boosted) }
    if ($readini($char($1), status, shell) = yes) { $status_message_check(shell) }
    if ($readini($char($1), status, protect) = yes) { $status_message_check(protect) }

    $bar_check($1)
    unset %resists

    if ($readini($char($1), status, en-spell) != none) { var %enspell $readini($char($1), status, en-spell) | $status_message_check(en- $+ %enspell) }

    $player.skills.list($1)

    if (%all_status = $null) { %all_status = 3Normal }
    if (%all_skills = $null) { %all_skills = 3None }
    return
  }
  unset %real.name | unset %status 
}

player.skills.list {
  unset %all_skills
  if ($readini($char($1), status, conservetp.on) = on) { $skills_message_check(2conserving TP) }
  if ($readini($char($1), status, conservetp) = yes) { $skills_message_check(2conserving TP) }
  if ($readini($char($1), skills, utsusemi.on) = on) { $skills_message_check(2Utsusemi[ $+ $readini($char($1), skills, utsusemi.shadows) $+ ]) }
  if ($readini($char($1), skills, royalguard.on) = on) { $skills_message_check(2Royal Guard) }
  if ($readini($char($1), skills, manawall.on) = on) { $skills_message_check(2Mana Wall) }
  if ($readini($char($1), skills, mightystrike.on) = on) { $skills_message_check(2Mighty Strike) }
  if ($readini($char($1), skills, truestrike.on) = on) { $skills_message_check(2True Strike) }
  if ($readini($char($1), skills, elementalseal.on) = on) { $skills_message_check(2Elemental Seal) }
  if ($readini($char($1), skills, thirdeye.on) = on) { $skills_message_check(2Third Eye) }
  if ($readini($char($1), skills, retaliation.on) = on) { $skills_message_check(2Retaliation) }
  if ($readini($char($1), skills, konzen-ittai.on) = on) { $skills_message_check(2Konzen-Ittai) }
  if ($readini($char($1), skills, defender.on) = on) { $skills_message_check(2Defender) }
  if ($readini($char($1), skills, aggressor.on) = on) { $skills_message_check(2Aggressor) }
  if ($readini($char($1), skills, perfectcounter.on) = on) { $skills_message_check(2Will Perform a Perfect Counter) }
  if ($readini($char($1), skills, FormlessStrike.on) = on) { $skills_message_check(Formless Strikes) }
  if ($readini($char($1), skills, PerfectDefense.on) = on) { $skills_message_check(Perfect Defense) }

  set %cover.target $readini($char($1), skills, CoverTarget)
  if ((%cover.target != $null) && (%cover.target != none)) { $skills_message_check(2Covered by %cover.target) }

  unset %cover.target
}

status_message_check { 
  if (%all_status = $null) { %all_status = 4 $+ $1- | return }
  else { %all_status = 4 $+ %all_status $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}
skills_message_check { 
  if (%all_skills = $null) { %all_skills = 4 $+ $1- | return }
  else { %all_skills = 4 $+ %all_skills $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}

is_charmed {
  if ($readini($char($1), status, charmed) = yes) { return true }
  else { return false }
}

is_confused {
  if ($readini($char($1), status, confuse) = yes) { return true }
  else { return false }
}

amnesia.check {
  var %amnesia.check $readini($char($1), status, amnesia)
  if (%amnesia.check = no) { return }
  else { 
    $set_chr_name($1) 
    $display.system.message($readini(translation.dat, status, CurrentlyAmnesia),battle) 

    halt 
  }
}

id_login { set %idwho $1 | unset %newbie | unset %password | unset %userlevel | unset %character.description | .dns %idwho | $clr_passhurt($1) | writeini $char($1) Info LastSeen $fulldate | .close -m* |  unset %guess  | unset %gender | halt }
okdesc { 
  $display.private.message2($1,$readini(translation.dat, system,OKDesc)) 
  return 
}
set_chr_name {
  set %real.name $readini($char($1), BaseStats, Name)
  if (%real.name = $null) { set %real.name $1 | return }
  else { return }
}

battle_stats { set %str $readini($char($1), Battle, Str) | set %def $readini($char($1), Battle, Def) | set %int $readini($char($1), Battle, int) | set %spd $readini($char($1), Battle, spd) | return }  
build_battlehp_list {
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
    else { 
      $set_chr_name(%who.battle) | $hp_status_hpcommand(%who.battle) 
      var %hp.to.add  3 $+ $chr(91) $+  $+ %who.battle $+ :  %hstats $+ 3 $+ $chr(93) 
      %battle.hp.list = $addtok(%battle.hp.list,%hp.to.add,46) 
      inc %battletxt.current.line
    }
  }

  if ($chr(046) isin %battle.hp.list) { 
    %battle.hp.list = $replace(%battle.hp.list, $chr(046), $chr(032))
  }
}
weapon_equipped { 
  if ($person_in_mech($1) = false) {  
    set %weapon.equipped.right $readini($char($1), Weapons, Equipped) 
    set %weapon.equipped.left $readini($char($1), Weapons, EquippedLeft)
    set %weapon.equipped $readini($char($1), weapons, equipped)
  }
  if ($person_in_mech($1) = true) { set %weapon.equipped $readini($char($1), mech, EquippedWeapon) } 
  return 
}
weapon.list { 
  $weapons.get.list($1)
  $weapons.mech($1)

  $achievement_check($1, YouBringMonstersI'llBringWeapons)
  unset %total.weapons.owned
  return
}

weapons.mech {
  unset %mech.weapon.list | unset %mech.weapon.list2

  if ($readini($char($1), mech, HpMax) = $null) { return }

  ; CHECKING MECH WEAPONS
  var %value 1 | var %items.lines $lines($lstfile(items_mech.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_mech.lst)

    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ($readini($dbfile(weapons.db), %item.name, type) != $null) {
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        if ($numtok(%mech.weapon.list,46) <= 20) { %mech.weapon.list = $addtok(%mech.weapon.list, 3 $+ %item.name, 46) }
        else { %mech.weapon.list2 = $addtok(%mech.weapon.list2, 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  set %replacechar $chr(044) $chr(032)
  %mech.weapon.list = $replace(%mech.weapon.list, $chr(046), %replacechar)
  %mech.weapon.list2 = $replace(%mech.weapon.list2, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %replacechar

  return
}

weapons.get.list { 
  unset %weapon.list1 | unset %weapons | unset %number.of.weapons | unset %base.weapon.list | unset %weapon.list2 | unset %weapon.list3 | unset %weapon.list4
  set %total.weapons.owned 0 | unset %weapon.list

  var %weapon.list.place 1 | var %total.weapon.lists $lines($lstfile(weaponlists.lst)) | set %weaponlist.counter 1
  var %weaponlist.totalweapons.counter 0

  while (%weapon.list.place <= %total.weapon.lists) {
    var %weapons.line $read -l $+ %weapon.list.place $lstfile(weaponlists.lst)
    set %weapons $readini($dbfile(weapons.db), Weapons, %weapons.line)
    var %number.of.weapons $numtok(%weapons, 46)
    var %value 1

    while (%value <= %number.of.weapons) {
      set %weapon.name $gettok(%weapons, %value, 46)
      set %weapon_level $readini($char($1), weapons, %weapon.name)

      if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
        ; add the weapon level to the weapon list
        var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 

        inc %weaponlist.totalweapons.counter 1

        if ($calc($weaponlist.length(%weaponlist.counter) + $len(%weapon_to_add)) > 900) { echo -a line too long, increasing | inc %weaponlist.counter 1 | var %weaponlist.totalweapons.counter 0 } 

        if (%weaponlist.totalweapons.counter >= 20) { inc %weaponlist.counter 1 | var %weaponlist.totalweapons.counter 0 }
        $weapons.addlist(%weaponlist.counter, %weapon_to_add) 

        if ($readini($char($1), info, flag) != $null) { 
          if ($calc($len(%base.weapon.list) + $len(%weapon_to_add)) < 920) { %base.weapon.list = $addtok(%base.weapon.list, %weapon.name, 46)  }
        }
        inc %total.weapons.owned 1
      }
      inc %value 1 
    }

    inc %weapon.list.place |  unset %value | unset %weapon.name | unset %weapon_level | unset %number.of.weapons
  }

  return
}

weaponlist.length {
  return $len($weapons.returnlist($1))
}
weapons.addlist {
  % [ $+ weapon.list $+ [ $1 ] ] = $addtok(% [ $+ weapon.list $+ [ $1 ] ] ,$2,46)
}
weapons.returnlist {
  return % [ $+ weapon.list $+ [ $1 ] ] 
}
weapons.unsetlist {
  unset % [ $+ weapon.list $+ [ $1 ] ] 
}

shield.list { 
  $shields.get.list($1)
  unset %total.shields.owned
  return
}

shields.get.list { 
  unset %shield.list1 | unset %shields | unset %number.of.shields | unset %base.shield.list | unset %shield.list2 | unset %shield.list3 | unset %shield.list4
  set %total.shields.owned 0 | unset %shield.list

  var %shield.list.place 1 | var %total.shield.lists $lines($lstfile(shieldlists.lst)) | set %shieldlist.counter 1
  var %shieldlist.totalshields.counter 0

  while (%shield.list.place <= %total.shield.lists) {
    var %shields.line $read -l $+ %shield.list.place $lstfile(shieldlists.lst)
    set %shields $readini($dbfile(weapons.db), shields, %shields.line)
    var %number.of.shields $numtok(%shields, 46)
    var %value 1

    while (%value <= %number.of.shields) {
      set %shield.name $gettok(%shields, %value, 46)
      set %shield_level $readini($char($1), weapons, %shield.name)

      if ((%shield_level != $null) && (%shield_level >= 1)) { 
        ; add the shield level to the shield list
        var %shield_to_add  $+ %shield.name $+ 

        inc %shieldlist.totalshields.counter 1

        if ($calc($shieldlist.length(%shieldlist.counter) + $len(%shield_to_add)) > 900) { echo -a line too long, increasing | inc %shieldlist.counter 1 | var %shieldlist.totalshields.counter 0 } 

        if (%shieldlist.totalshields.counter >= 20) { inc %shieldlist.counter 1 | var %shieldlist.totalshields.counter 0 }
        $shields.addlist(%shieldlist.counter, %shield_to_add) 

        if ($readini($char($1), info, flag) != $null) { 
          if ($calc($len(%base.shield.list) + $len(%shield_to_add)) < 920) { %base.shield.list = $addtok(%base.shield.list, %shield.name, 46)  }
        }
        inc %total.shields.owned 1
      }
      inc %value 1 
    }

    inc %shield.list.place |  unset %value | unset %shield.name | unset %shield_level | unset %number.of.shields
  }

  return
}

shieldlist.length {
  return $len($shields.returnlist($1))
}
shields.addlist {
  % [ $+ shield.list $+ [ $1 ] ] = $addtok(% [ $+ shield.list $+ [ $1 ] ] ,$2,46)
}
shields.returnlist {
  return % [ $+ shield.list $+ [ $1 ] ] 
}
shields.unsetlist {
  unset % [ $+ shield.list $+ [ $1 ] ] 
}

styles.list { 
  set %styles.list $styles.get.list($1)

  ; CLEAN UP THE LIST
  if ($chr(046) isin %styles.list) { set %replacechar $chr(044) $chr(032)
    %styles.list = $replace(%styles.list, $chr(046), %replacechar)
  }
  return
}
styles.get.list { 
  unset %styles.list | unset %styles | unset %number.of.styles
  set %styles $readini($dbfile(playerstyles.db), styles, list)
  var %number.of.styles $numtok(%styles, 46)
  var %total.style.levels 0

  var %value 1
  while (%value <= %number.of.styles) {
    set %style.name $gettok(%styles, %value, 46)
    set %style_level $readini($char($1), styles, %style.name)

    if (%style_level = $null) {
      if (%style.name = Trickster) { writeini $char($1) styles Trickster 1 | writeini $char($1) styles TricksterXP 0 }
      if (%style.name = WeaponMaster) { writeini $char($1) styles WeaponMaster 1 | writeini $char($1) styles WeaponMasterXP 0 }
      if (%style.name = Guardian) { writeini $char($1) styles Guardian 1 | writeini $char($1) styles GuardianXP 0 }
    }

    if ((%style_level != $null) && (%style_level >= 1)) { 
      ; add the style level to the weapon list
      var %style_to_add  $+ %style.name $+ $chr(040) $+ %style_level $+ $chr(041) $+ 
      %styles.list = $addtok(%styles.list,%style_to_add,46)
      inc %total.style.levels %style_level
    }

    inc %value 1 
  }

  if ($readini($char($1), styles, equipped) = $null) { writeini $char($1) styles equipped Trickster }
  unset %value | unset %weapon.name | unset %weapon_level

  if (%total.style.levels >= 80) { $achievement_check($1, SSStylish) }

  return %styles.list
}
songs.list {
  unset %songs.list
  set %songs.list $songs.get.list($1)

  if ($1 = return) { return %songs.list }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %songs.list = $replace(%songs.list, $chr(046), %replacechar)

  unset %value | unset %replacechar

  return
}
songs.get.list { 
  unset %songs.list | unset %songs.list2 | unset %songs | unset %number.of.songs

  var %value 1 | var %items.lines $lines($lstfile(songs.lst))
  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(songs.lst)
    set %item_amount $readini($char($1), songs, %item.name)

    if ((%item_amount = 0) && ($readini($char($1), info, flag) = $null)) { remini $char($1) songs %item.name }
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      %songs.list = $addtok(%songs.list, %item.name, 46) 
    }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  return %songs.list
}
ignition.list {
  unset %ignitionss.list
  set %ignitions.list $ignitions.get.list($1)

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %ignitions.list = $replace(%ignitions.list, $chr(046), %replacechar)

  unset %value | unset %replacechar

  return
}
ignitions.get.list { 
  unset %ignitions.list | unset %ignitions | unset %number.of.ignitions

  var %value 1 | var %items.lines $lines($lstfile(ignitions.lst))
  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(ignitions.lst)
    set %item_amount $readini($char($1), ignitions, %item.name)
    if ((%item_amount = 0) && ($readini($char($1), info, flag) = $null)) { remini $char($1) ignitions %item.name }
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      %ignitions.list = $addtok(%ignitions.list, %item.name, 46) 
    }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  return %ignitions.list
}

tech.list {
  unset %techs.list | unset %tech.list
  set %techs.list $techs.get.list($1, $2)

  if ($person_in_mech($1) = true) { return }

  if (%weapon.equipped.left != $null) { 
    var %techs.list.left $techs.get.list($1, %weapon.equipped.left)

    if (%techs.list.left = $null) { return }

    var %tech.position 1 
    while (%tech.position <= $numtok(%techs.list.left,46)) {
      var %tech.name $gettok(%techs.list.left,%tech.position,46)
      %techs.list = $addtok(%techs.list, %tech.name, 46) 
      inc %tech.position
    }

  }

  set %replacechar $chr(044) $chr(032)
  %techs.list = $replace(%techs.list, $chr(046), %replacechar)
  unset %replacechar

  return
}
techs.get.list { 
  unset %tech.list | unset %techs | unset %number.of.techs | unset %ignition.tech.list | set %tech.count 0 | set %tech.power
  var %techs $readini($dbfile(techniques.db), techs, $2)
  var %number.of.techs $numtok(%techs, 46)
  var %value 1
  var %my.tp $readini($char($1), battle, tp)

  while (%value <= %number.of.techs) {
    set %tech.name $gettok(%techs, %value, 46)
    set %tech_level $readini($char($1), techniques, %tech.name)

    if ((%tech_level != $null) && (%tech_level >= 1)) { 
      ; add the tech level to the tech list
      if (%battle.type != ai) {  set %tech_to_add $iif(%my.tp < $readini($dbfile(techniques.db), %tech.name, tp), 5 $+ %tech.name $+ 3, %tech.name) $+ $chr(040) $+ %tech_level $+ $chr(041) }
      if (%battle.type = ai) {  var %tech_to_add %tech.name | inc %tech.count 1 |  inc %tech.power $readini($dbfile(techniques.db), %tech.name, basepower) }
      %tech.list = $addtok(%tech.list,%tech_to_add,46)
    }

    inc %value 1 
  }

  unset %tech_to_add

  ; Check for ignition techs
  if ($readini($char($1), status, ignition.on) = on) {
    set %ignition.name $readini($char($1), status, ignition.name)
    set %techs $readini($dbfile(ignitions.db), %ignition.name, techs)
    var %number.of.techs $numtok(%techs, 46)
    var %value 1
    if (%techs != $null) {
      while (%value <= %number.of.techs) {
        set %tech.name $gettok(%techs, %value, 46)
        var %tech_to_add 7 $+ %tech.name 
        %ignition.tech.list = $addtok(%ignition.tech.list,%tech_to_add,46)
        inc %value 1
      }
    }
  }

  if ($person_in_mech($1) = true) {
    set %tech.list $readini($dbfile(weapons.db), $2, abilities)
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %ignition.tech.list = $replace(%ignition.tech.list, $chr(046), %replacechar)

  unset %value | unset %tech.name | unset %tech_level | unset %ignition.name | unset %techs
  return %tech.list
}

skills.list {
  $passive.skills.list($1)
  $active.skills.list($1)
  set %resists.skills.list $resists.skills.list($1)
  set %killer.skills.list $killer.skills.list($1)
  unset %total.skills | unset %skill.name | unset %skill_level | unset %replacechar
  return
}

passive.skills.list { 
  ; CHECKING PASSIVE SKILLS
  unset %passive.skills.list | unset %passive.skills.list2 | unset %total.skills
  var %skills.lines $lines($lstfile(skills_passive.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_passive.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      inc %total.skills 1
      if (%total.skills > 13) {  %passive.skills.list2 = $addtok(%passive.skills.list2,%skill_to_add,46) }
      else {  %passive.skills.list = $addtok(%passive.skills.list,%skill_to_add,46) }
    }
    inc %value 1
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %passive.skills.list) { set %replacechar $chr(044) $chr(032)
    %passive.skills.list = $replace(%passive.skills.list, $chr(046), %replacechar)
  }
  if ($chr(046) isin %passive.skills.list2) { set %replacechar $chr(044) $chr(032)
    %passive.skills.list2 = $replace(%passive.skills.list2, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value 
}

active.skills.list {
  ; CHECKING ACTIVE SKILLS
  unset %active.skills.list | unset %active.skills.list2 | unset %total.skills
  var %skills.lines $lines($lstfile(skills_active.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_active.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      inc %total.skills 1
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      if (%total.skills > 13) { %active.skills.list2 = $addtok(%active.skills.list2,%skill_to_add,46) }
      else { %active.skills.list = $addtok(%active.skills.list,%skill_to_add,46) }
    }
    inc %value 1 
  }

  var %active.skills $readini($dbfile(skills.db), Skills, activeSkills2)
  var %number.of.skills $numtok(%active.skills, 46)
  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%active.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      inc %total.skills 1
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      if (%total.skills > 13) { %active.skills.list2 = $addtok(%active.skills.list2,%skill_to_add,46) }
      else { %active.skills.list = $addtok(%active.skills.list,%skill_to_add,46) }
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %active.skills.list) { set %replacechar $chr(044) $chr(032)
    %active.skills.list = $replace(%active.skills.list, $chr(046), %replacechar)
  }
  if ($chr(046) isin %active.skills.list2) { set %replacechar $chr(044) $chr(032)
    %active.skills.list2 = $replace(%active.skills.list2, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
}

resists.skills.list { 
  ; CHECKING RESISTANCE SKILLS
  unset %resists.skills.list
  var %skills.lines $lines($lstfile(skills_resists.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_resists.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      %resists.skills.list = $addtok(%resists.skills.list,%skill_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %resists.skills.list = $replace(%resists.skills.list, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return %resists.skills.list
}

killer.skills.list { 
  ; CHECKING KILLER SKILLS
  unset %killer.skills.list

  var %skills.lines $lines($lstfile(skills_killertraits.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_killertraits.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      %killer.skills.list = $addtok(%killer.skills.list,%skill_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %killer.skills.list = $replace(%killer.skills.list, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return %killer.skills.list
}

keys.list {
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list | unset %reset.items.list 

  ; CHECKING KEYS 
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %keys.items $readini($dbfile(items.db), items, Keys)
  var %number.of.items $numtok(%keys.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%keys.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %keys.items.list = $addtok(%keys.items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  if ($chr(046) isin %keys.items.list) { set %replacechar $chr(044) $chr(032)
    %keys.items.list = $replace(%keys.items.list, $chr(046), %replacechar)
  }
}

gems.list {
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list | unset %reset.items.list 

  ; CHECKING GEMS
  var %value 1 | var %items.lines $lines($lstfile(items_gems.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_gems.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %gems.items.list = $addtok(%gems.items.list, 7 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  if ($chr(046) isin %gems.items.list) { set %replacechar $chr(044) $chr(032)
    %gems.items.list = $replace(%gems.items.list, $chr(046), %replacechar)
  }
}

seals.list {
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list | unset %reset.items.list  | unset %seals.items.list

  ; CHECKING SEALS
  var %value 1 | var %items.lines $lines($lstfile(items_seals.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_seals.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %seals.items.list = $addtok(%seals.items.list, 1 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  if ($chr(046) isin %seals.items.list) { set %replacechar $chr(044) $chr(032)
    %seals.items.list = $replace(%seals.items.list, $chr(046), %replacechar)
  }

  unset %replacechar
}

items.list {
  ; CHECKING HEALING ITEMS
  unset %items.list | unset %items.list2 | unset %summons.items.list | unset %summons.items.list2 | unset %gems.items.list | unset %keys.items.list
  unset %misc.items.list | unset %misc.items.list2 | unset %reset.items.list | unset %statplus.items.list | unset %portals.items.list | unset %portals.items.list2
  unset %misc.items.list3 | unset %special.items.list | unset %misc.items.list3

  var %value 1 | var %items.lines $lines($lstfile(items_healing.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_healing.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%items.list,46) <= 20) { %items.list = $addtok(%items.list, 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %items.list2 = $addtok(%items.list2, 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING BATTLE ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_battle.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_battle.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%items.list,46) <= 20) { %items.list = $addtok(%items.list, 4 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %items.list2 = $addtok(%items.list2, 4 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING RANDOMITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_random.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_random.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%items.list,46) <= 20) { %items.list = $addtok(%items.list, 4 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %items.list2 = $addtok(%items.list2, 4 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING CONSUMABLE ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_consumable.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_consumable.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%items.list,46) <= 20) { %items.list = $addtok(%items.list, 15 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %items.list2 = $addtok(%items.list2, 15 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING SHOP RESET ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_reset.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_reset.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %reset.items.list = $addtok(%reset.items.list, 2 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING MISC ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_misc.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_misc.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%misc.items.list,46) <= 20) { %misc.items.list = $addtok(%misc.items.list, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { 
        if ($numtok(%misc.items.list2,46) <= 20) { %misc.items.list2 = $addtok(%misc.items.list2, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
        else { 
          if ($numtok(%misc.items.list3,46) <= 20) { %misc.items.list3 = $addtok(%misc.items.list3, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
          else { %misc.items.list4 = $addtok(%misc.items.list4, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) } 
        }
      }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING +STAT
  var %value 1 | var %items.lines $lines($lstfile(items_food.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_food.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %statplus.items.list = $addtok(%statplus.items.list, 12 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING SUMMON ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_summons.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_summons.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%summons.items.list,46) <= 20) { %summons.items.list = $addtok(%summons.items.list, 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %summons.items.list2 = $addtok(%summons.items.list2, 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }


  ; CHECKING GEMS
  var %value 1 | var %items.lines $lines($lstfile(items_gems.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_gems.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %gems.items.list = $addtok(%gems.items.list, 7 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }


  ; CHECKING PORTAL ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_portal.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_portal.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%portals.items.list,46) <= 20) { %portals.items.list = $addtok(%portals.items.list, 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %portals.items.list2 = $addtok(%portals.items.list2, 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  $items.mechcore($1)

  ; CHECKING SPECIAL ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_special.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_special.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %special.items.list = $addtok(%special.items.list, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  unset %item.name | unset %item_amount

  ; CLEAN UP THE LISTS
  set %replacechar $chr(044) $chr(032)
  %items.list = $replace(%items.list, $chr(046), %replacechar)
  %items.list2 = $replace(%items.list2, $chr(046), %replacechar)
  %summons.items.list = $replace(%summons.items.list, $chr(046), %replacechar)
  %summons.items.list2 = $replace(%summons.items.list2, $chr(046), %replacechar)
  %gems.items.list = $replace(%gems.items.list, $chr(046), %replacechar)
  %keys.items.list = $replace(%keys.items.list, $chr(046), %replacechar)
  %misc.items.list = $replace(%misc.items.list, $chr(046), %replacechar)
  %misc.items.list2 = $replace(%misc.items.list2, $chr(046), %replacechar)
  %misc.items.list3 = $replace(%misc.items.list3, $chr(046), %replacechar)
  %misc.items.list4 = $replace(%misc.items.list4, $chr(046), %replacechar)
  %reset.items.list = $replace(%reset.items.list, $chr(046), %replacechar)
  %statplus.items.list = $replace(%statplus.items.list, $chr(046), %replacechar)
  %portals.items.list = $replace(%portals.items.list, $chr(046), %replacechar)
  %portals.items.list2 = $replace(%portals.items.list2, $chr(046), %replacechar)
  %special.items.list = $replace(%special.items.list, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %food.items | unset %consume.items
  unset %replacechar
  return
}

instruments.list {
  ; CHECKING INSTRUMENT ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_instruments.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_instruments.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %instruments.items.list = $addtok(%instruments.items.list, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  if (%instruments.items.list != $null) {
    set %replacechar $chr(044) $chr(032)
    %instruments.items.list = $replace(%instruments.items.list, $chr(046), %replacechar)
  }

}

items.mechcore {
  unset %mech.items.list | unset %mech.items.list2

  if ($readini($char($1), mech, HpMax) = $null) { return }

  ; CHECKING MECH CORE ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_mech.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_mech.lst)

    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ($readini($dbfile(items.db), %item.name, type) = mechCore) {
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        if ($numtok(%mech.items.list,46) <= 20) { %mech.items.list = $addtok(%mech.items.list, 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
        else { %mech.items.list2 = $addtok(%mech.items.list2, 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  set %replacechar $chr(044) $chr(032)
  %mech.items.list = $replace(%mech.items.list, $chr(046), %replacechar)
  %mech.items.list2 = $replace(%mech.items.list2, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %replacechar

  return
}

armor.list {
  unset %armor.head | unset %armor.body | unset %armor.legs | unset %armor.feet | unset %armor.hands | unset %armor.head2 | unset %armor.body2 | unset %armor.legs2 | unset %armor.feet2 | unset %armor.hands2
  unset %armor.head3 | unset %armor.body3 | unset %armor.legs3 | unset %armor.feet3 | unset %armor.hands3

  ; CHECKING HEAD ARMOR
  var %value 1 | var %armor.head.lines $lines($lstfile(armor_head.lst))

  while (%value <= %armor.head.lines) {

    set %armor.name $read -l $+ %value $lstfile(armor_head.lst)
    set %item_amount $readini($char($1), item_amount, %armor.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %armor.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {   
      if ($numtok(%armor.head,46) <= 12) { %armor.head = $addtok(%armor.head, %armor.name, 46) }
      else { 
        if ($numtok(%armor.head2,46) >= 12) { %armor.head3 = $addtok(%armor.head3, %armor.name, 46) }
        else { %armor.head2 = $addtok(%armor.head2, %armor.name, 46) }
      }
    }
    unset %armor.name | unset %item.amount
    inc %value 1 
  }

  ; CHECKING BODY ARMOR
  var %value 1 | var %armor.body.lines $lines($lstfile(armor_body.lst))

  while (%value <= %armor.body.lines) {

    set %armor.name $read -l $+ %value $lstfile(armor_body.lst)
    set %item_amount $readini($char($1), item_amount, %armor.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %armor.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {   
      if ($numtok(%armor.body,46) <= 12) { %armor.body = $addtok(%armor.body, %armor.name, 46) }
      else { 
        if ($numtok(%armor.body2,46) >= 12) { %armor.body3 = $addtok(%armor.body3, %armor.name, 46) }
        else { %armor.body2 = $addtok(%armor.body2, %armor.name, 46) }
      }
    }
    unset %armor.name | unset %item.amount
    inc %value 1 
  }

  ; CHECKING LEG ARMOR
  var %value 1 | var %armor.legs.lines $lines($lstfile(armor_legs.lst))

  while (%value <= %armor.legs.lines) {

    set %armor.name $read -l $+ %value $lstfile(armor_legs.lst)
    set %item_amount $readini($char($1), item_amount, %armor.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %armor.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {   
      if ($numtok(%armor.legs,46) <= 12) { %armor.legs = $addtok(%armor.legs, %armor.name, 46) }
      else { 
        if ($numtok(%armor.legs2,46) >= 12) { %armor.legs3 = $addtok(%armor.legs3, %armor.name, 46) }
        else { %armor.legs2 = $addtok(%armor.legs2, %armor.name, 46) }
      }
    }
    unset %armor.name | unset %item.amount
    inc %value 1 
  }

  ; CHECKING FEET ARMOR
  var %value 1 | var %armor.feet.lines $lines($lstfile(armor_feet.lst))

  while (%value <= %armor.feet.lines) {

    set %armor.name $read -l $+ %value $lstfile(armor_feet.lst)
    set %item_amount $readini($char($1), item_amount, %armor.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %armor.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {   
      if ($numtok(%armor.feet,46) <= 12) { %armor.feet = $addtok(%armor.feet, %armor.name, 46) }
      else { 
        if ($numtok(%armor.feet2,46) >= 12) { %armor.feet3 = $addtok(%armor.feet3, %armor.name, 46) }
        else { %armor.feet2 = $addtok(%armor.feet2, %armor.name, 46) }
      }
    }
    unset %armor.name | unset %item.amount
    inc %value 1 
  }

  ; CHECKING HAND ARMOR
  var %value 1 | var %armor.hands.lines $lines($lstfile(armor_hands.lst))

  while (%value <= %armor.hands.lines) {

    set %armor.name $read -l $+ %value $lstfile(armor_hands.lst)
    set %item_amount $readini($char($1), item_amount, %armor.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %armor.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {   
      if ($numtok(%armor.hands,46) <= 12) { %armor.hands = $addtok(%armor.hands, %armor.name, 46) }
      else { 
        if ($numtok(%armor.hands2,46) >= 12) { %armor.hands3 = $addtok(%armor.hands3, %armor.name, 46) }
        else { %armor.hands2 = $addtok(%armor.hands2, %armor.name, 46) }
      }
    }
    unset %armor.name | unset %item.amount
    inc %value 1 
  }

  ; CLEAN UP THE LISTS
  set %replacechar $chr(044) $chr(032)
  %armor.head = $replace(%armor.head, $chr(046), %replacechar)
  %armor.head2 = $replace(%armor.head2, $chr(046), %replacechar)
  %armor.head3 = $replace(%armor.head3, $chr(046), %replacechar)
  %armor.body = $replace(%armor.body, $chr(046), %replacechar)
  %armor.body2 = $replace(%armor.body2, $chr(046), %replacechar)
  %armor.body3 = $replace(%armor.body3, $chr(046), %replacechar)
  %armor.legs = $replace(%armor.legs, $chr(046), %replacechar)
  %armor.legs2 = $replace(%armor.legs2, $chr(046), %replacechar)
  %armor.legs3 = $replace(%armor.legs3, $chr(046), %replacechar)
  %armor.feet = $replace(%armor.feet, $chr(046), %replacechar)
  %armor.feet2 = $replace(%armor.feet2, $chr(046), %replacechar)
  %armor.feet3 = $replace(%armor.feet3, $chr(046), %replacechar)
  %armor.hands = $replace(%armor.hands, $chr(046), %replacechar)
  %armor.hands2 = $replace(%armor.hands2, $chr(046), %replacechar)
  %armor.hands3 = $replace(%armor.hands3, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %food.items | unset %consume.items
  return
}

accessories.list {
  ; CHECKING ACCESSORIE
  unset %accessories.list | unset %accessories.list2

  var %value 1 | var %items.lines $lines($lstfile(items_accessories.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_accessories.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%accessories.list,46) <= 20) { %accessories.list = $addtok(%accessories.list, %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %accessories.list2 = $addtok(%accessories.list2, %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %accessories.list = $replace(%accessories.list, $chr(046), %replacechar)
  %accessories.list2 = $replace(%accessories.list2, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return
}

runes.list {
  ; CHECKING RUNES
  unset %runes.list
  var %runes.items $readini($dbfile(items.db), items, Runes)
  var %number.of.items $numtok(%runes.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%runes.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %runes.list = $addtok(%runes.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %runes.list) { set %replacechar $chr(044) $chr(032)
    %runes.list = $replace(%runes.list, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The fulls command brings
; everyone back to max hp
; and regular stats.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fulls {  
  if (($readini($char($1), info, NeedsFulls) = no) && ($2 != yes)) { return } 

  var %players.must.die.mode $readini(system.dat, system, PlayersMustDieMode) 

  if ($readini($char($1), info, flag) = $null) {

    remini $char($1) info ai_type

    if ((%players.must.die.mode = false) || (%players.must.die.mode = $null))  { 
      writeini $char($1) Battle Hp $readini($char($1), BaseStats, HP)
      writeini $char($1) Battle Tp $readini($char($1), BaseStats, TP)
    }
    if (%players.must.die.mode = true)  { 
      var %max.hp.restore $round($calc($readini($char($1), BaseStats, HP) / 2),0) 
      var %max.tp.restore $round($calc($readini($char($1), BaseStats, TP) / 2),0)

      if (%max.hp.restore > $readini($char($1), battle, hp)) { writeini $char($1) Battle Hp %max.hp.restore }
      if (%max.tp.restore > $readini($char($1), battle, tp)) { writeini $char($1) Battle Tp %max.tp.restore }
    }
  }

  if ($readini($char($1), info, flag) = monster) {
    if ((%players.must.die.mode = false) || (%players.must.die.mode = $null))  { 
      writeini $char($1) Battle Hp $readini($char($1), BaseStats, HP)
      writeini $char($1) Battle Tp $readini($char($1), BaseStats, TP)
    }

    if (%players.must.die.mode = true)  { 
      var %max.hp.restore $round($calc($readini($char($1), BaseStats, HP) * 1.1),0) 
      var %max.tp.restore $round($calc($readini($char($1), BaseStats, TP) * 1.1),0)

      if (%max.hp.restore > $readini($char($1), battle, hp)) { writeini $char($1) Battle Hp %max.hp.restore }
      if (%max.tp.restore > $readini($char($1), battle, tp)) { writeini $char($1) Battle Tp %max.tp.restore }
    }
  }

  if ($readini($char($1), info, flag) = npc) {
    writeini $char($1) Battle Hp $readini($char($1), BaseStats, HP)
    writeini $char($1) Battle Tp $readini($char($1), BaseStats, TP)
  }


  writeini $char($1) Battle Str $readini($char($1), BaseStats, Str)
  writeini $char($1) Battle Def $readini($char($1), BaseStats, Def)
  writeini $char($1) Battle Int $readini($char($1), BaseStats, Int)
  writeini $char($1) Battle Spd $readini($char($1), BaseStats, Spd)

  if ($readini($char($1), battle, status) != inactive) {  writeini $char($1) Battle Status alive }

  if ($readini($char($1), BaseStats, IgnitionGauge) = $null) { writeini $char($1) BaseStats IgnitionGauge 0 | writeini $char($1) Battle IgnitionGauge 0 }
  if ($readini($char($1), Battle, IgnitionGauge) = $null) { writeini $char($1) Battle IgnitionGauge 0 }

  if ($readini($char($1), stuff, TotalDeaths) = $null) { writeini $char($1) stuff TotalDeaths 0 }
  if ($readini($char($1), stuff, TotalFled) = $null) { writeini $char($1) stuff TotalFled 0 }

  $clear_status($1)

  ; If it's not a monster or NPC, we need to clear some more stuff and check for $$.
  if ($readini($char($1), info, flag) = $null) { 
    $clear_skills($1) | var %stylelist $styles.get.list($1) 
    .remini $char($1) modifiers
    var %doubledollars $readini($char($1), stuff, doubledollars) 
    if (%doubledollars = $null) { writeini $char($1) stuff doubledollars 100 | var %doubledollars 100 }
  }

  $clear_skill_timers($1)

  if ($person_in_mech($1) = true) { writeini $char($1) mech inuse false }

  remini $char($1) Renkei

  $fullNaturalArmor($1)

  $db.shenronwish.check($1)

  writeini $char($1) info NeedsFulls no
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if a char is
; older than 6 mo and erase it
; if so. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
oldchar.check {
  if ($istok(%bot.owners,$1,46) = $true) { return }

  var %lastseen.date $readini($char($1), info, LastSeen)
  if (%lastseen.date = $null) { writeini $char($1) info LastSeen $fulldate) | return }
  if (%lastseen.date = N/A) { var %lastseen.date $readini($char($1), info, Created) | writeini $char($1) info LastSeen %lastseen.date }

  var %lastseen.ctime $ctime(%lastseen.date)
  var %ctime.calc.sixmonths 15901200
  var %current.ctime $calc( $ctime($fulldate) - %lastseen.ctime)

  if (%current.ctime > %ctime.calc.sixmonths) { 
    ; It's been greater than six months.  Zap the char.
    echo -a 4 $+ $1 is older than 6 months and is being removed..
    $zap_char($1)
  }

  else { $fulls($1) }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Refills a char's natural armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fullNaturalArmor {
  if ($readini($char($1), info, flag) = $null) { return }
  var %naturalArmorMax $readini($char($1), NaturalArmor, Max)
  if (%naturalArmorMax != $null) { writeini $char($1) NaturalArmor Current %naturalArmorMax }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turns skills off on chars.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_skills {
  writeini $char($1) skills speed.on no | writeini $char($1) skills doubleturn.on off | writeini $char($1) status charmed no | writeini $char($1) status charmer noonethatIknowlol | writeini $char($1) status charm.timer 0 
  writeini $char($1) skills soulvoice.on off | writeini $char($1) skills manawall.on off | writeini $char($1) skills elementalseal.on off
  writeini $char($1) skills mightystrike.on off | writeini $char($1) skills royalguard.on off | writeini $char($1) skills drainsamba.turn 0 
  writeini $char($1) skills drainsamba.on off | writeini $char($1) skills utsusemi.on off |  writeini $char($1) skills utsusemi.shadows 0 
  writeini $char($1) skills Quicksilver.turn -1 | writeini $char($1) skills Quicksilver.used 0 | writeini $char($1) skills CoverTarget none
  remini $char($1) skills PerfectCounter.on | writeini $char($1) skills aggressor.on off | writeini $char($1) skills defender.on off
  writeini $char($1) skills konzen-ittai.on off |  writeini $char($1) skills thirdeye.on off | writeini $char($1) status thirdeye.turn 0 
  writeini $char($1) skills scavenge.on off | writeini $char($1) skills FormlessStrike.on off | writeini $char($1) skills retaliation.on off
  writeini $char($1) skills truestrike.on off | writeini $char($1) skills PerfectDefense.on off
}

clear_skill_timers {
  remini $char($1) skills elementalseal.time | remini $char($1) skills doubleturn.time | remini $char($1) skills mightystrike.time
  remini $char($1) skills royalguard.time | remini $char($1) skills manawall.time | remini $char($1) skills conserveTP.time
  remini $char($1) skills utsusemi.time | remini $char($1) skills cover.time | remini $char($1) skills drainsamba.time
  remini $char($1) skills kikouheni.time | remini $char($1) skills meditate.time | remini $char($1) skills holyaura.time
  remini $char($1) skills provoke.time | remini $char($1) skills disarm.time | remini $char($1) skills steal.time 
  remini $char($1) skills sealbreak.time | remini $char($1) skills thirdeye.time | remini $char($1) skills bloodboost.time 
  remini $char($1) skills bloodspirit.time | remini $char($1) skills formlessstrike.time  | remini $char($1) skills regen.time
  remini $char($1) skills konzen-ittai.time | remini $char($1) skills gamble.time | remini $char($1) skills truestrike.time
  remini $char($1) skills magicmirror.time | remini $char($1) skills snatch.time | remini $char($1) skills retaliation.time
  remini $char($1) skills weaponlock.time | remini $char($1) skills PerfectDefense.time
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear Certain Skills
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_certain_skills {
  writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills Quicksilver.turn -1 | writeini $char($1) skills Quicksilver.used 0
  writeini $char($1) skills scavenge.on off
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears most statuses on
; chars. This is for the 
; clearstatus type items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_most_status {
  writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no | writeini $char($1) status confuse no
  writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no 
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 0
  writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
  writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no
  writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1
  writeini $char($1) status zombieregenerating no | writeini $char($1) status silence no | writeini $char($1) status petrified no | writeini $char($1) status bored no 
  writeini $char($1) status confuse.timer 1 | writeini $char($1) status defensedown no | writeini $char($1) status defensedown.timer 0 | writeini $char($1) status strengthdown no 
  writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown no | writeini $char($1) status intdown.timer 1
  writeini $char($1) status protect no | writeini $char($1) status shell no | writeini $char($1) status protect.timer 0 | writeini $char($1) status shell.timer 0
}

clear_negative_status {
  ; Note, this doesn't clear charm.
  writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no
  writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no | writeini $char($1) Status intimidated no
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 1 
  writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
  writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no | writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1
  writeini $char($1) status zombieregenerating no | writeini $char($1) status intimidate no |  writeini $char($1) status defensedown no | writeini $char($1) status strengthdown no | writeini $char($1) status intdown no
  writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown.timer 0 | writeini $char($1) status defensedown.timer 0 |  writeini $char($1) status stop no | writeini $char($1) status petrified no 
  writeini $char($1) status bored no | writeini $char($1) status bored.timer 0 | remini $char($1) status weapon.locked | writeini $char($1) status confuse no | writeini $char($1) status confuse.timer 1

  ; Monsters that are zombies need to be reset as zombies.
  if ($readini($char($1), monster, type) = zombie) {  writeini $char($1) status zombie yes | writeini $char($1) status zombieregenerating yes } 

  ; If the target has Fool's Tablet on, it needs to add poison
  if ($accessory.check($1, IncreaseMeleeAddPoison) = true) {
    writeini $char($1) status poison yes
    writeini $char($1) status poison.timer 0
    unset %accessory.amount
  }
}

clear_positive_status {
  writeini $char($1) Status Regenerating no | writeini $char($1) Status MPRegenerating no | writeini $char($1) Status KiRegenerating no
  writeini $char($1) status TPRegenerating no | writeini $char($1) status conservetp no 
  writeini $char($1) status protect no | writeini $char($1) status shell no | writeini $char($1) status protect.timer 0 | writeini $char($1) status shell.timer 0
  writeini $char($1) status en-spell none | writeini $char($1) status en-spell.timer 0
  writeini $char($1) status defenseup no | writeini $char($1) status defenseup.timer 1

  if ($2 != tech) { writeini $char($1) status ignition.on off | remini $char($1) status ignition.name | remini $char($1) status ignition.augment }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears statuses on chars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_status {
  if ($readini($char($1), status, finalgetsuga) = yes) {
    $reset_char($1) | $set_chr_name($1)
    $display.system.message(4 $+ %real.name feels all of $gender($1) power leaving $gender($1) body -- resetting $gender2($1) back to level 1.,global) 

    unset %real.name
  }

  ; Negative status effects
  $clear_negative_status($1)

  ; Clear Charm, since the clear_negative_status doesn't.
  writeini $char($1) status charmer noOneThatIKnow | writeini $char($1) status charm.timer 0 | writeini $char($1) status charmed no | writeini $char($1) status boosted no 

  ; Positive status effects
  $clear_positive_status($1)

  writeini $char($1) status orbbonus no | writeini $char($1) status revive no | writeini $char($1) status FinalGetsuga no

  ; Magic effects  
  writeini $char($1) Status frozen no | writeini $char($1) status freezing no | writeini $char($1) Status shock no | writeini $char($1) Status burning no 
  writeini $char($1) Status drowning no | writeini $char($1) Status tornado no |  writeini $char($1) Status earth-quake no 

  ; The resists are used to resist the magic effect stuff (Freezing, Burning, etc).  Only players need this removed each time.
  if ($readini($char($1), info, flag) = $null) { 
    writeini $char($1) status resist-fire no | writeini $char($1) status resist-lightning no | writeini $char($1) status resist-ice no
    writeini $char($1) status resist-earth no | writeini $char($1) status resist-wind no | writeini $char($1) status resist-water no
    writeini $char($1) status resist-light no | writeini $char($1) status resist-dark no
  }

  if ($readini($char($1), info, flag) = $null) {  writeini $char($1) status ethereal no | writeini $char($1) status reflect no | writeini $char($1) status reflect.timer 1 | writeini $char($1) status invincible no | writeini $char($1) status invincible.timer 0 }
  if ($augment.check($1, AutoReraise) = true) { 
    if (%augment.strength >= 5) { writeini $char($1) status revive yes }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the min streak for
; mons/bosses to show up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_minimum_streak {
  if ($1 = mon) {
    set %monster.info.streak $readini($mon($2), info, Streak)
  }

  if ($1 = boss) {
    set %monster.info.streak $readini($boss($2), info, Streak)
  }
  if (%monster.info.streak = $null) { set %monster.info.streak 0 }
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the max streak
; for mons/bosses to show
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_maximum_streak {
  if ($1 = mon) {
    set %monster.info.streak.max $readini($mon($2), info, StreakMax)
  }

  if ($1 = boss) {
    set %monster.info.streak.max $readini($boss($2), info, StreakMax)
  }
  if (%monster.info.streak.max = $null) { set %monster.info.streak.max 999999999999 }
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of monsters
; eligable for the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_mon_list {
  unset %monster.list
  if ($1 = portal) { set %nosouls true }

  set %current.winning.streak.value $readini(battlestats.dat, battle, WinningStreak) 
  set %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty) | inc %current.winning.streak.value %difficulty
  set %current.month $left($adate, 2)

  if (%battle.type = ai) { set %current.winning.streak.value %ai.battle.level } 

  if (%mode.gauntlet.wave != $null) { inc %current.winning.streak.value %mode.gauntlet.wave }

  if (%portal.bonus = true) { var %current.winning.streak 100 }

  .echo -q $findfile( $mon_path , *.char, 0 , 0, mon_list_add $1-)

  $sort_mlist

  set %token.value 1
  while (%token.value <= 15) {
    var %monster.name $read -l $+ %token.value $txtfile(temporary_mlist.txt)
    if (%monster.name != $null) { %monster.list = $addtok(%monster.list,%monster.name,46) | inc %token.value 1 }
    else { inc %token.value 15 }
  }
  .remove $txtfile(temporary_mlist.txt)
  unset %token.value | unset %current.winning.streak.value | unset %difficulty | unset %current.month
  unset %monster.info.streak | unset %monster.info.streak.max | unset %nosouls
  return
}

mon_list_add {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (((%name = new_mon) || (%name = $null) || (%name = orb_fountain))) { return } 
  if ((%nosouls = true) && (%name = lost_soul)) { return }

  if ((%mode.gauntlet != $null) && ($readini($mon(%name), info, streak) > -500)) { write $txtfile(temporary_mlist.txt) %name | return }
  if (%battle.type = ai) { write $txtfile(temporary_mlist.txt) %name | return }

  if ((%savethepresident = on) && ($readini($mon(%name), info, IgnorePresident) = true)) { return }

  ; Check the winning streak #..  some monsters won't show up until a certain streak or higher.
  $get_minimum_streak(mon, %name)
  $get_maximum_streak(mon, %name)

  if ($readini($mon(%name), info, month) = %current.month) { write $txtfile(temporary_mlist.txt) %name  | inc %value 1 }
  if ($readini($mon(%name), info, month) != %current.month) { 
    if (%monster.info.streak <= -500) { return }
    if ((%monster.info.streak > -500) || (%monster.info.streak = $null)) {

      var %biome $readini($mon(%name), info, biome)
      var %monster.moonphase $readini($mon(%name), info, moonphase)
      var %monster.timeofday $readini($mon(%name), info, TimeOfDay)
      var %current.time.of.day $readini($dbfile(battlefields.db), TimeOfDay, CurrentTimeOfDay)

      if (%current.winning.streak.value < %monster.info.streak) { return }
      if (%current.winning.streak.value > %monster.info.streak.max) { return }

      if (((%monster.moonphase = $null) && (%biome = $null) && (%monster.timeofday = $null))) { write $txtfile(temporary_mlist.txt) %name | return  }
      if ((%monster.moonphase != $null) && (%monster.moonphaes != %moon.phase)) { return }
      if ((%biome != $null) && ($istok(%biome,%current.battlefield,46) = $false)) { return }
      if ((%monster.timeofday != $null) && ($istok(%monster.timeofday,%current.time.of.day,46) = $false)) { return }

      write $txtfile(temporary_mlist.txt) %name

    }
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of bosses eligable
; for the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_boss_list {
  unset %monster.list
  set %current.winning.streak.value $readini(battlestats.dat, battle, WinningStreak) 
  set %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty) | inc %current.winning.streak.value %difficulty
  set %current.month $left($adate, 2)

  if (%mode.gauntlet.wave != $null) { inc %current.winning.streak.value %mode.gauntlet.wave }

  if (%portal.bonus = true) { var %current.winning.streak 100 }

  if (%battle.type = ai) { set %current.winning.streak.value %ai.battle.level } 

  .echo -q $findfile( $boss_path , *.char, 0 , 0, boss_list_add $1-)

  $sort_mlist

  set %token.value 1
  while (%token.value <= 15) {
    var %monster.name $read -l $+ %token.value $txtfile(temporary_mlist.txt)
    if (%monster.name != $null) { %monster.list = $addtok(%monster.list,%monster.name,46) | inc %token.value 1 }
    else { inc %token.value 15 }
  }
  .remove $txtfile(temporary_mlist.txt)
  unset %token.value | unset %current.winning.streak.value | unset %difficulty | unset %current.month
  unset %monster.info.streak | unset %monster.info.streak.max
  return
}

boss_list_add {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (((%name = new_boss) || (%name = $null) || (%name = orb_fountain))) { return } 
  if ((%mode.gauntlet != $null) && ($readini($boss(%name), info, streak) > -500)) { write $txtfile(temporary_mlist.txt) %name | return }
  if (%battle.type = ai) { write $txtfile(temporary_mlist.txt) %name | return }

  if ((%savethepresident = on) && ($readini($mon(%name), info, IgnorePresident) = true)) { return }

  ; Check the winning streak #..  some monsters won't show up until a certain streak or higher.
  $get_minimum_streak(boss, %name)
  $get_maximum_streak(boss, %name)

  if ($readini($boss(%name), info, month) = %current.month) { write $txtfile(temporary_mlist.txt) %name  | inc %value 1 }
  if ($readini($boss(%name), info, month) != %current.month) { 
    if (%monster.info.streak <= -500) { return }
    if ((%monster.info.streak > -500) || (%monster.info.streak = $null)) {

      var %biome $readini($boss(%name), info, biome)
      var %monster.moonphase $readini($boss(%name), info, moonphase)
      var %monster.timeofday $readini($boss(%name), info, TimeOfDay)
      var %current.time.of.day $readini($dbfile(battlefields.db), TimeOfDay, CurrentTimeOfDay)

      if (%current.winning.streak.value < %monster.info.streak) { return }
      if (%current.winning.streak.value > %monster.info.streak.max) { return }

      if (((%monster.moonphase = $null) && (%biome = $null) && (%monster.timeofday = $null))) { write $txtfile(temporary_mlist.txt) %name | return  }
      if ((%monster.moonphase != $null) && (%monster.moonphaes != %moon.phase)) { return }
      if ((%biome != $null) && ($istok(%biome,%current.battlefield,46) = $false)) { return }
      if ((%monster.timeofday != $null) && ($istok(%monster.timeofday,%current.time.of.day,46) = $false)) { return }

      write $txtfile(temporary_mlist.txt) %name

    }
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of NPCs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_npc_list {
  unset %npc.list
  .echo -q $findfile( $npc_path , *.char, 0 , 0, npc_list_add $1-)
  $sort_mlist

  set %token.value 1
  while (%token.value <= 15) {
    var %monster.name $read -l $+ %token.value $txtfile(temporary_mlist.txt)
    if (%monster.name != $null) { %npc.list = $addtok(%npc.list,%monster.name,46) | inc %token.value 1 }
    else { inc %token.value 15 }
  }
  .remove $txtfile(temporary_mlist.txt)
  unset %token.value
  return
}
npc_list_add {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_npc) || (%name = $null)) { return } 
  if (%battle.type = ai) { 
    if ($readini($char(%name), info, ai_type) = healer) { return }
  }

  write $txtfile(temporary_mlist.txt) %name 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function sorts the
; monster list.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sort_mlist {
  ; get rid of the Monster Table and the now un-needed file
  if ($isfile(MonsterTable.file) = $true) { 
    .hfree MonsterTable
    .remove MonsterTable.file
  }

  ; make the monster List table
  hmake MonsterTable

  ; load them from the file.  
  var %monstertxt.lines $lines($txtfile(temporary_mlist.txt)) | var %monstertxt.current.line 1 
  while (%monstertxt.current.line <= %monstertxt.lines) { 
    var %who.monster $read -l $+ %monstertxt.current.line $txtfile(temporary_mlist.txt)
    set %monster.index.num $rand(1,10000)
    var %tmp.mon.moonphase $readini($mon(%who.monster), info, moonphase)
    if (%tmp.mon.moonphase = %moon.phase) { inc %monster.index.num $rand(500,2000) }

    hadd MonsterTable %who.monster %monster.index.num
    inc %monstertxt.current.line
  }

  ; save the MonsterTable hashtable to a file
  hsave MonsterTable MonsterTable.file

  ; load the MonsterTable hashtable (as a temporary table)
  hmake MonsterTable_Temp
  hload MonsterTable_Temp MonsterTable.file

  ; sort the Monster Table
  hmake MonsterTable_Sorted
  var %MonsterTableitem, %MonsterTabledata, %MonsterTableindex, %MonsterTablecount = $hget(MonsterTable_Temp,0).item
  while (%MonsterTablecount > 0) {
    ; step 1: get the lowest item
    %MonsterTableitem = $hget(MonsterTable_Temp,%MonsterTablecount).item
    %MonsterTabledata = $hget(MonsterTable_Temp,%MonsterTablecount).data
    %MonsterTableindex = 1
    while (%MonsterTableindex < %MonsterTablecount) {
      if ($hget(MonsterTable_Temp,%MonsterTableindex).data < %MonsterTabledata) {
        %MonsterTableitem = $hget(MonsterTable_Temp,%MonsterTableindex).item
        %MonsterTabledata = $hget(MonsterTable_Temp,%MonsterTableindex).data
      }
      inc %MonsterTableindex
    }

    ; step 2: remove the item from the temp list
    hdel MonsterTable_Temp %MonsterTableitem

    ; step 3: add the item to the sorted list
    %MonsterTableindex = sorted_ $+ $hget(MonsterTable_Sorted,0).item
    hadd MonsterTable_Sorted %MonsterTableindex %MonsterTableitem

    ; step 4: back to the beginning
    dec %MonsterTablecount
  }

  ; get rid of the temp table
  hfree MonsterTable_Temp

  ; Erase the old monster.txt and replace it with the new one.
  .remove $txtfile(temporary_mlist.txt)

  var %index = $hget(MonsterTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(MonsterTable_Sorted,sorted_ $+ %index)
    if (%tmp != $null) { write $txtfile(temporary_mlist.txt) %tmp }
  }

  ; get rid of the sorted table
  hfree MonsterTable_Sorted

  ; get rid of the Monster Table and the now un-needed file
  hfree MonsterTable
  .remove MonsterTable.file

  ; unset the monster.index
  unset %monster.index.num
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two statuses return
; the HP status (perfect,
; injured, good, etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hp_status { 
  set %current.hp $readini($char($1), Battle, HP) | set %max.hp $readini($char($1), BaseStats, HP) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent > 100) { set %hstats $readini(translation.dat, health, beyondperfect)  | return }
  if (%hp.percent = 100) { set %hstats $readini(translation.dat, health, perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $readini(translation.dat, health, great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $readini(translation.dat, health, good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $readini(translation.dat, health, decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $readini(translation.dat, health, scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $readini(translation.dat, health, bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $readini(translation.dat, health, hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $readini(translation.dat, health, injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { set %hstats $readini(translation.dat, health, injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { set %hstats $readini(translation.dat, health, critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { set %hstats $readini(translation.dat, health, AliveHairBredth) | return }
  if (%hp.percent <= 0) { set %whoturn $1 |  next | halt }
}
hp_status_hpcommand { 
  set %current.hp $readini($char($1), Battle, HP) | set %max.hp $readini($char($1), BaseStats, HP) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent > 100) { set %hstats $readini(translation.dat, health, beyondperfect)  | return }
  if (%hp.percent = 100) { set %hstats $readini(translation.dat, health, perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $readini(translation.dat, health, great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $readini(translation.dat, health, good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $readini(translation.dat, health, decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $readini(translation.dat, health, scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $readini(translation.dat, health, bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $readini(translation.dat, health, hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $readini(translation.dat, health, injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { set %hstats $readini(translation.dat, health, injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { set %hstats $readini(translation.dat, health, critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { set %hstats $readini(translation.dat, health, AliveHairBredth) | return }
  if (%hp.percent <= 0) { set %hstats $readini(translation.dat, health, Dead)  | return }
}
hp_mech_hpcommand { 
  set %current.hp $readini($char($1), Mech, HpCurrent) | set %max.hp $readini($char($1), Mech, HpMax) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent >= 100) { set %hstats $readini(translation.dat, health, perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $readini(translation.dat, health, great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $readini(translation.dat, health, good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $readini(translation.dat, health, decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $readini(translation.dat, health, scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $readini(translation.dat, health, smoking) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $readini(translation.dat, health, sparking) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $readini(translation.dat, health, shortingout) | return }
  if ((%hp.percent < 30) && (%hp.percent > 10)) { set %hstats $readini(translation.dat, health, critical) | return }
  if ((%hp.percent <= 10) && (%hp.percent > 0)) { set %hstats $readini(translation.dat, health, malfunctioning) | return }
  if (%hp.percent <= 0) { set %hstats $readini(translation.dat, health, Disabled)  | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions to restore HP
; TP and IG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $1 = person being restored
; $2 = amount
restore_hp {
  var %max.hp $readini($char($1), basestats, hp)
  var %current.hp $readini($char($1), battle, hp)
  inc %current.hp $2
  if ($readini($char($1), status, ignition.on) = off) {
    if (%current.hp >= %max.hp) { writeini $char($1) battle hp %max.hp }
    else {  writeini $char($1) battle hp %current.hp }
  } 
  else {  writeini $char($1) battle hp %current.hp }
}

restore_tp {
  var %max.tp $readini($char($1), basestats, tp)
  var %current.tp $readini($char($1), battle, tp)
  inc %current.tp $2
  if ($readini($char($1), status, ignition.on) = off) {
    if (%current.tp >= %max.tp) { writeini $char($1) battle tp %max.tp }
    else {  writeini $char($1) battle tp %current.tp }
  } 
  else { writeini $char($1) battle tp %current.tp }
}

restore_ig {
  var %max.ig $readini($char($1), basestats, IgnitionGauge)
  var %current.ig $readini($char($1), battle, IgnitionGauge)

  if (%max.ig > 0) { 
    inc %current.ig $2
    if (%current.ig >= %max.ig) { writeini $char($1) battle IgnitionGauge %max.ig }
    else {  writeini $char($1) battle IgnitionGauge %current.ig }
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two functions clear
; variables.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_variables { 
  $clear_variables2
  unset %darkness.turns | unset %holy.aura.turn | unset %mech.power
  unset %boss.type | unset %portal.bonus | unset %holy.aura | unset %darkness.fivemin.warn  | unset %battle.rage.darkness |  unset %battleconditions |  unset %red.orb.winners |  unset %bloodmoon 
  unset %line | unset %file | unset %name | unset %curbat | unset %real.name | unset %attack.target
  unset %battle.type | unset %number.of.monsters.needed | unset %who |  unset %next.person | unset %status | unset %hstats | unset %baseredorbs | unset %hp.percent
  unset %monster.list | unset %monsters.total | unset %random.monster | unset %monster.name |  unset %ai.target | unset %resist.skill | unset %value | unset %mastery.bonus
  unset %user | unset %enemy | unset %handtohand.wpn.list | unset %sword.wpn.list | unset %monster.wpn.list | unset %base.redorbs | unset %tech.type | unset %whoturn | unset %replacechar | unset %status.battle 
  unset %number.of.hits | unset %timer.time | unset %help.topics3 | unset %skill.name |  unset %skill_level | unset %action | unset %idwho | unset %currentshoplevel | unset %totalplayers
  unset %life.max | unset %passive.skills.list | unset %active.skills.list | unset %reists.skills.list |  unset %items.list | unset %techs.list | unset %tech.name | unset %tech_level | unset %multiplier
  unset %number.of.techs | unset %tech.list | unset %ai.tech | unset %who.battle | unset %weapon.equipped |  unset %ai.targetlist | unset %all_skills | unset %all_status | unset %status.message | unset %stylepoints.toremove
  unset %resist.have | unset %bonus.orbs | unset %attack.damage | unset %style.multiplier |  unset %style.rating | unset %file | unset %name | unset %weapon.howmany.hits | unset %element.desc
  unset %monster.to.remove | unset %burning | unset %hp | unset %drowning | unset %weapon.price |  unset %tornado | unset %tech.to.remove | unset %upgrade.list | unset %tech.price | unset %total.price
  unset %skill.price | unset %shop.list.passiveskills | unset %shop.list.activeskills |  unset %skill.list | unset %shop.list.resistanceskills | unset %resists.skills.list | unset %shop.statbonus
  unset %password | unset %passhurt | unset %userlevel | unset %comma_replace | unset %comma_new |  unset %freezing | unset %file | unset %name | unset %inc.shoplevel
  unset %poison.timer | unset %skill.description | unset %item.total | unset %black.orb.winners |  unset %file | unset %name | unset %bosschance | unset %fullbring.check | unset %check.item
  unset %fourhit.attack | unset %weapon.name | unset %shock | unset %skill.max | unset %skill.have |  unset %weapon.list | unset %tp.current | unset %drainsamba.turn | unset %absorb | unset %drainsamba.turns
  unset %drainsamba.turn.max | unset %life.target | unset %drainsamba.on | unset %weapons | unset %techs | unset %number.of.players | unset %keys.items.list
  unset %amount | unset %current.shoplevel | unset %shop.list | unset %battletxt.lines | unset %battletxt.current.lint
  unset %opponent.flag | unset %spell.element | unset %timer.time |   unset %battletxt.currentline | unset %first.round.protection | unset %first.round.protection.turn
  unset %npc.list | unset %random.npc | unset %npc.to.remove | unset %npc.name | unset %double.attack
  unset %shaken | unset %info.fullbringmsg | unset %basepower | unset %fullbring.needed | unset %poison | unset %ai.ignition | unset %ai.action
  unset %fullbring.type | unset %fullbring.target | unset %fullbring.status | unset %item.base | unset %timer.time | unset %savethepresident
  unset %real.name | unset %weapon.name | unset %weapon.price | unset %steal.item | unset %skip.ai | unset %file.to.read.lines 
  unset %attacker.spd | unset %playerstyle.* | unset %stylepoints.to.add | unset %current.playerstyle.* | unset %styles | unset %wait.your.turn | unset %weapon.list2
}
clear_variables2 {
  unset %max.demonwall.turns | unset %demonwall.name | unset %styles.list | unset %style.name | unset %style.level | unset %player.style.level | unset %style.price | unset %styles
  unset %ai.skill | unset %weapon.name.used | unset %weapon.used.type | unset %quicksilver.used | unset %upgrade.list2
  unset %upgrade.list3 | unset %ai.skilllist | unset %ai.type | unset %statusmessage.display | unset %current.turn | unset %surpriseattack
  unset %mode.pvp | unset %summons.items.list | unset %style_level | unset %attack.damage4 | unset %renkei.name | unset %renkei.description
  unset %status.type | unset %number.of.items.sold | unset %who.battle.flag | unset %shop.level | unset %overkill
  unset %style.name | unset %style_level | unset %styles | unset %trickster.dodged | unset %ip.address.* | unset %multiple.wave.bonus
  unset %monster.to.spawn | unset %mode.gauntlet | unset %mode.gauntlet.wave | unset %changeweapon.chance | unset %active.skills.list2 | unset %total.skills
  unset %who.battle.ai | unset %demonwall.fight | unset %weapon.base | unset %target.hp | unset %ignition.description | unset %temp.battle.list
  unset %style.name | unset %style_level | unset %quicksilver.used | unset %quicksilver.turn | unset %playersgofirst
  unset %battlefield.event.number | unset %number.of.events | unset %augment.strength | unset %augment.found | unset %curse.night | unset %random.item
  unset %absorb.message |   unset %battle.player.death | unset %battle.monster.death | unset %ignition.list | unset %renkei.tech.percent | unset %current.item.total
  unset %portals.bstmen | unset %allied.notes | unset %portals.kindred | unset %item.name | unset %item_amount | unset %treasure.hunter.percent
  unset %player.ig.current | unset player.ig.max | unset %player.ig.reward | unset %battletxt.current.line | %multiple.wave.noaction | unset %covering.someone
  unset %previous.tp | unset %multiple.wave | unset %portal.multiple.wave | unset %augment.strength | unset %current.monster.level.temp
  unset %current.monster.weapon.level.temp | unset %weapon.type | unset %original.attackdmg | unset %target | unset %monster.level 
  unset %target.tech.null | unset %naturalArmorName | unset %target.stat | unset %base.stat | unset %shop.level | unset %total.price
  unset %random.tech | unset %multiple.wave.noactio | unset %debug.location | unset %multiple.wave.noaction
  unset %monsters.in.battle | unset %target.element.null | unset %battleconditions | unset %ingredients.to.add
  unset %mech.hp | unset %number.of.monsters | unset %current.monster.to.spawn | unset %total.weapons.owned | unset %ai.battle.level | unset %ai.npc.name
  unset %ai.monster.name | unset %ai.winner | unset %action.bar | unset %betting.period | unset %winners | unset %multihit.message.on 
  unset %food.type | unset %shop.list2 | unset %shop.list3 | unset %mech.weaponname | unset %mech.techs | unset %ignition.tech.list | unset %stylepoints.current
  unset %mech.weapon.list | unset %fstrike.turns | unset %fstrike.turn.max | unset %ignitions.list  | unset %techincrease.check
  unset %total.summon.items | unset %accessories.list2 | unset %weapon_augment | unset %totalbosss 0 | unset %ignition.description's
  unset %ingredient.to.add | unset %weapons7 | unset %user.gets.second.turn | unset %spd.increase | unset %spd.current 
  unset %temp.damage | unset %cost | unset %current.line | unset %mech.weapon.list2
  unset unset %weapon.equipped.right | unset unset %weapon.equipped.left | unset %shield.block.line
  unset %original.ignition.name | unset %holy.aura.user | unset %max.hp.restore | unset %max.tp.restore 
  unset %passive.skills.list2 | unset %prize.list | unset %inflict.meleewpn
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See if the user $1 has
; the skill $2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
skillhave.check {
  if ($readini($char($1), skills, $2) > 0) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zap (erase) a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zap_char {
  set %new.name $1 $+ _ $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z)
  .rename $char($1) $zapped(%new.name)
  .remove $char($1)
  unset %new.name
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Resets a char to base
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reset_char {
  ; Reset all stats to base
  writeini $char($1) basestats hp 100 |  writeini $char($1) battle hp 100
  writeini $char($1) basestats tp 20 |  writeini $char($1) battle tp 20
  writeini $char($1) basestats str 5 |  writeini $char($1) battle str 5
  writeini $char($1) basestats def 5 |  writeini $char($1) battle def 5
  writeini $char($1) basestats int 5 |  writeini $char($1) battle int 5
  writeini $char($1) basestats spd 5 |  writeini $char($1) battle spd 5

  ; Reset the shop level
  writeini $char($1) stuff ShopLevel 1.0

  ; Reset the orbs.  Orbs gained will be 10% of whatever you had spent.
  var %total.orbs.spent $readini($char($1), stuff, RedOrbsSpent)
  var %new.orbs $round($calc(%total.orbs.spent * .05),0)
  writeini $char($1) stuff RedOrbs %new.orbs
  writeini $char($1) stuff BlackOrbs 1
  writeini $char($1) stuff RedOrbsSpent 0
  writeini $char($1) stuff BlackOrbsSpent 0

  ; Remove all skills
  remini $char($1) skills

  ; Reset the weapons to just the fists
  var %fists.level $readini($char($1), weapons, fists)
  remini $char($1) weapons
  writeini $char($1) weapons equipped fists
  writeini $char($1) weapons Fists %fists.level

  ; Reset the techniques
  var %doublepunch.level $readini($char($1), techniques, doublepunch)
  remini $char($1) techniques
  writeini $char($1) techniques DoublePunch %doublepunch.level 

  var %number.of.resets $readini($char($1), stuff, NumberOfResets)
  if (%number.of.resets = $null) { var %number.of.resets 0 }
  inc %number.of.resets 1 
  writeini $char($1) stuff NumberOfResets %number.of.resets

  ; Remove the augments
  remini $char($1) augments
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a treasure chest 
; with a random item inside.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
create_treasurechest {

  set %chest.type.random $rand(1,150)
  dec %chest.type.random $treasurehunter.check

  if (%portal.bonus = true) { %chest.type.random = $rand(1,35) }

  if (%chest.type.random <= 10)  { set %color.chest gold  }
  if ((%chest.type.random > 10) && (%chest.type.random <= 20)) { set %color.chest silver }
  if ((%chest.type.random > 20) && (%chest.type.random <= 35)) { set %color.chest purple }
  if ((%chest.type.random > 35) && (%chest.type.random <= 55)) { set %color.chest orange }
  if ((%chest.type.random > 55) && (%chest.type.random <= 70)) { set %color.chest green }
  if ((%chest.type.random > 70) && (%chest.type.random <= 90)) { set %color.chest blue  }
  if ((%chest.type.random > 90) && (%chest.type.random <= 120)) { set %color.chest brown  }
  if ((%chest.type.random > 120) && (%chest.type.random <= 130)) { set %color.chest black  }
  if (%chest.type.random > 130) { set %color.chest red | set %chest.contents RedOrbs | set %chest.amount $rand(150,700) }

  if (%color.chest != red) {
    var %chest.name $lstfile(chest_ $+ %color.chest $+ .lst)
    set %total.items $lines(%chest.name)
    set %random $rand(1, %total.items)
    if (%random = $null) { var %random 1 }
    set %chest.contents $read -l $+ %random %chest.name

    unset %total.items
  }

  if (%chest.amount = $null) { set %chest.amount 1 }
  if (%chest.contents = $null) { unset %chest.amount | unset %color.chest | unset %chest.contents | return } 

  $display.system.message($readini(translation.dat, system, ChestDrops),global) 

  writeini $txtfile(treasurechest.txt) ChestInfo Color %color.chest
  writeini $txtfile(treasurechest.txt) ChestInfo Contents %chest.contents
  writeini $txtfile(treasurechest.txt) ChestInfo Amount %chest.amount

  unset %color.chest | unset %chest.contents | unset %chest.amount | unset %random | unset %chest.type.random
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove a treasure chest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
destroy_treasurechest {
  if ($readini($txtfile(treasurechest.txt), ChestInfo, Color) != $null) {
    $display.system.message($readini(translation.dat, system, ChestDestroyed),global) 
    .remove $txtfile(treasurechest.txt)
  }
  unset %previous.battle.type
  unset %keyinuse
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adjusts red orbs in a chest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chest.adjustredorbs {
  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
  if (%winning.streak < 100) { var %orb.tier 1 }
  if ((%winning.streak >= 100) && (%winning.streak < 200)) { var %orb.tier 2 }
  if ((%winning.streak >= 200) && (%winning.streak < 300)) { var %orb.tier 3 }
  if ((%winning.streak >= 300) && (%winning.streak < 500)) { var %orb.tier 4 }
  if ((%winning.streak >= 500) && (%winning.streak < 800)) { var %orb.tier 5 }
  if ((%winning.streak >= 800) && (%winning.streak < 1000)) { var %orb.tier 6 }
  if ((%winning.streak >= 1000) && (%winning.streak < 1200)) { var %orb.tier 7 }
  if ((%winning.streak >= 1200) && (%winning.streak < 1500)) { var %orb.tier 8 }
  if (%winning.streak >= 1500) { var %orb.tier 9 }

  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { inc %orb.tier 1 }

  if (%orb.tier = 1) { return }
  if (%orb.tier = 2) { set %chest.amount $round($calc(%chest.amount * 1.45),0) }
  if (%orb.tier = 3) { set %chest.amount $round($calc(%chest.amount * 1.555),0) }
  if (%orb.tier = 4) { set %chest.amount $round($calc(%chest.amount * 1.692),0) }
  if (%orb.tier = 5) { set %chest.amount $round($calc(%chest.amount * 1.798),0) }
  if (%orb.tier = 6) { set %chest.amount $round($calc(%chest.amount * 2.190),0) }
  if (%orb.tier = 7) { set %chest.amount $round($calc(%chest.amount * 2.5),0) }
  if (%orb.tier = 8) { set %chest.amount $round($calc(%chest.amount * 2.95),0) }
  if (%orb.tier = 9) { set %chest.amount $round($calc(%chest.amount * 3.15),0) }
  if (%orb.tier = 10) { set %chest.amount $round($calc(%chest.amount * 4),0) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for the treasurehunter
; skill.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
treasurehunter.check {
  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1 | set %treasure.hunter.percent 0
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt) | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = dead) { inc %l 1 }
    else { 
      var %treasurehunter.skill $readini($char(%who.battle), skills, treasurehunter) 
      if (%treasurehunter.skill > 0) { inc %treasure.hunter.percent %treasurehunter.skill }
      if ($augment.check($1, EnhanceTreasureHunter) = true) { inc %treasure.hunter.percent %augment.strength }

      if ($accessory.check(%who.battle, IncreaseTreasureOdds) = true) {
        inc %treasure.hunter.percent %accessory.amount
        unset %accessory.amount
      }

      inc %l 1 
    } 
  }
  unset %lines | unset %l | unset %current.accessory | unset %current.accessory.type

  return %treasure.hunter.percent
}

backguard.check {
  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt)
    if ($readini($char($1), info, flag) != $null) { inc %l 1 }
    else { 
      var %backguard.skill $readini($char(%who.battle), skills,backguard) 
      if (%backguard.skill > 0) { dec %surpriseattack.chance %backguard.skill }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 
}

divineblessing.check {
  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt)
    if ($readini($char($1), info, flag) != $null) { inc %l 1 }
    else { 
      var %divineblessing.skill $readini($char(%who.battle), skills,divineblessing) 
      if (%divineblessing.skill > 0) { inc %curse.chance %divineblessing.skill }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 
}


give_random_reward {
  if ($readini($txtfile(battle2.txt), battle, bonusitem) != $null) {

    if (%battle.type = boss) { var %reward.chance 100 }

    if (%battle.type != boss) { 
      var %reward.chance $rand(1,100)
      inc %reward.chance $treasurehunter.check

      if (%battle.type = mimic) { var %reward.chance 100 }
    }

    if (%reward.chance < 65) { return }

    set %item.winner $read -l $+ 1 $txtfile(battle.txt)
    var %winner.flag $readini($char(%item.winner), info, flag)
    if ((%winner.flag != monster) && (%winner.flag != npc)) {
      set %boss.item.list $readini($txtfile(battle2.txt), battle, bonusitem)

      if (%boss.item.list != $null) {

        set %boss.item.total $numtok(%boss.item.list,46)
        set %random.boss.item $rand(1, %boss.item.total) 
        set %boss.item $gettok(%boss.item.list,%random.boss.item,46)
        unset %boss.item.total | unset %boss.item.list | unset %random.boss.item
        set %item.total $readini($char(%item.winner), item_amount, %boss.item)
        if (%item.total = $null) { writeini $char(%item.winner) item_amount %boss.item 1 }
        else { inc %item.total 1 | writeini $char(%item.winner) item_amount %boss.item %item.total }
        $set_chr_name(%item.winner) 

        $display.system.message($readini(translation.dat, battle, BonusItemWin),battle) 
        remini $txtfile(battle2.txt) battle bonusitem
      }
    }
    unset %boss.item | unset %item.winner
  }
}

give_random_key_reward {
  var %random.key.chance $rand(1,100)

  if (%portal.bonus = true) { %random.key.chance = 100 }

  if (%random.key.chance <= 75) { return }

  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt) | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = dead) { inc %l 1 }
    else { 
      if ($readini($char(%who.battle), info, flag) = $null) { %players.list = $addtok(%players.list, %who.battle, 46) }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 

  if (%players.list = $null) { return }

  set %random $rand(1, $numtok(%players.list,46))
  if (%random = $null) { var %random 1 }
  set %key.winner $gettok(%players.list,%random,46)

  set %key.list $readini($dbfile(items.db), items, keys)
  set %random $rand(1, $numtok(%key.list,46))
  if (%random = $null) { var %random 1 }
  set %key.item $gettok(%key.list,%random,46)

  set %key.color $readini($dbfile(items.db), %key.item, unlocks)

  $set_chr_name(%key.winner)
  $display.system.message($readini(translation.dat, Battle, KeyWin),battle) 

  set %current.amount $readini($char(%key.winner), item_amount, %key.item) 
  if (%current.amount = $null) { set %current.amount 0 }
  inc %current.amount 1 | writeini $char(%key.winner) item_amount %key.item %current.amount

  var %total.number.of.keys $readini($char(%key.winner), stuff, TotalNumberOfKeys) 
  if (%total.number.of.keys = $null) { var %total.number.of.keys 0 }
  inc %total.number.of.keys 1
  writeini $char(%key.winner) stuff TotalNumberOfKeys %total.number.of.keys
  $achievement_check(%key.winner, AreYouTheKeyMaster)


  unset %key.list | unset %key.item | unset %players.list | unset %random | unset %key.item | unset %current.amount | unset %key.winner | unset %key.color
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for an augment
; and returns true/false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
augment.check {
  ; 1 = user
  ; 2 = augment name

  if ($1 = battlefield) { return }

  if ($person_in_mech($1) = false) {

    set %weapon.name.temp $readini($char($1), weapons, equipped)
    set %ignition.augment $readini($char($1), status, ignition.augment) 
    set %weapon.augment $readini($char($1), augments, %weapon.name.temp)
    if (%weapon.augment = $null) {  set %weapon.augment $readini($char($1), augment, %weapon.name.temp) }

    set %equipment.head.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, head), augment)
    set %equipment.body.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, body), augment)
    set %equipment.legs.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, legs), augment)
    set %equipment.feet.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, feet), augment)
    set %equipment.hands.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, hands), augment)

    unset %weapon.name.temp
    set %augment.strength 0

    if ($istok(%ignition.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%weapon.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.head.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.body.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.legs.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.feet.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.hands.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

    if (($readini($char($1), status, FinalGetsuga) = yes) && ($readini($char($1), info, flag) = $null)) { inc %augment.strength 5 | set %augment.found true }

  }

  if ($person_in_mech($1) = true) {
    set %augment.strength 0
    set %augments $readini($char($1), mech, augments)
    if ($istok(%augments,$2,46) = $true) { inc %augment.strength 2 | set %augment.found true }
    unset %augments
  }


  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { 
    if ($readinI($char($1), info, flag) = $null) { inc %augment.strength 2 | set %augment.found true }
  }

  unset %weapon.augment  | unset %ignition.augment | unset %equipment.head.augment | unset %equipment.body.augment
  unset %equipment.legs.augment | unset %equipment.feet.augment | unset %equipment.hands.augment

  if (%augment.found != true) { return false }
  if (%augment.found = true) { unset %augment.found | return true }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for an accessory
; and returns true/false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
accessory.check {
  ; 1 = user or target
  ; 2 = accessory type

  if ($person_in_mech($1) = true) { return } 

  unset %amount

  var %accessory.found false
  set %current.accessory $readini($char($1), equipment, accessory) 
  set %accessory.type $readini($dbfile(items.db), %current.accessory, accessoryType)

  if ($istok(%accessory.type,$2,46) = $true) {
    set %accessory.amount $readini($dbfile(items.db), %current.accessory, %accessory.type $+ .amount)

    if (%accessory.amount = $null) { set %accessory.amount 0 }
    var %accessory.found true
  }
  if ($istok(%accessory.type,$2,46) = $false) { var %accessory.found false }

  unset %current.accessory | unset %accessory.type 

  return %accessory.found
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adjusts orbs based on
; the winning streak.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
orb.adjust {
  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
  if (%base.redorbs <= 1000) { return }

  if (%mode.gauntlet.wave != $null) { inc %winning.streak %mode.gauntlet.wave }      

  var %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
  if (%difficulty != 0) {  inc %winning.streak %difficulty }

  if (%portal.bonus = true) {  var %winning.streak 500 }
  var %orb.tier 1

  if (%winning.streak < 50) { var %orb.tier -1 }
  if ((%winning.streak >= 50) && (%winning.streak < 100)) { var %orb.tier 0 }
  if ((%winning.streak >= 100) && (%winning.streak < 200)) { var %orb.tier 1 }
  if ((%winning.streak >= 200) && (%winning.streak < 300)) { var %orb.tier 2 }
  if ((%winning.streak >= 300) && (%winning.streak < 500)) { var %orb.tier 3 }
  if ((%winning.streak >= 500) && (%winning.streak < 800)) { var %orb.tier 4 }
  if ((%winning.streak >= 800) && (%winning.streak < 1000)) { var %orb.tier 5 }
  if ((%winning.streak >= 1000) && (%winning.streak < 1200)) { var %orb.tier 6 }
  if ((%winning.streak >= 1200) && (%winning.streak < 1500)) { var %orb.tier 7 }
  if ((%winning.streak >= 1500) && (%winning.streak < 2000)) { var %orb.tier 8 }
  if (%winning.streak >= 2000) { var %orb.tier 9 }

  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { inc %orb.tier 1 }

  if (%orb.tier = -1) { set %base.redorbs $round($calc(1000 + (%base.redorbs * .35)),0) }
  if (%orb.tier = 0) { set %base.redorbs $round($calc(1000 + (%base.redorbs * .40)),0) }
  if (%orb.tier = 1) { return }
  if (%orb.tier = 2) { set %base.redorbs $round($calc(%base.redorbs * 1.45),0) }
  if (%orb.tier = 3) { set %base.redorbs $round($calc(%base.redorbs * 1.555),0) }
  if (%orb.tier = 4) { set %base.redorbs $round($calc(%base.redorbs * 1.692),0) }
  if (%orb.tier = 5) { set %base.redorbs $round($calc(%base.redorbs * 1.798),0) }
  if (%orb.tier = 6) { set %base.redorbs $round($calc(%base.redorbs * 2.190),0) }
  if (%orb.tier = 7) { set %base.redorbs $round($calc(%base.redorbs * 2.5),0) }
  if (%orb.tier = 8) { set %base.redorbs $round($calc(%base.redorbs * 2.95),0) }
  if (%orb.tier = 9) { set %base.redorbs $round($calc(%base.redorbs * 3.15),0) }
  if (%orb.tier = 10) { set %base.redorbs $round($calc(%base.redorbs * 4),0) }

}

give_alliednotes {
  set %allied.notes $readini($char($1), stuff, alliednotes)
  if (%allied.notes = $null) { set %allied.notes 0 }
  inc %allied.notes $readini($txtfile(battle2.txt), battle, alliednotes)
  writeini $char($1) stuff alliednotes %allied.notes
}

increase.death.tally {
  if ($readini($char($1), info, flag) = monster) {

    if ($isfile($boss($1)) = $true) { 
      var %boss.deaths $readini($lstfile(monsterdeaths.lst), boss, $1) 
      if (%boss.deaths = $null) { var %boss.deaths 0 }
      inc %boss.deaths 1
      writeini $lstfile(monsterdeaths.lst) boss $1 %boss.deaths
    }
    if ($isfile($mon($1)) = $true) { 
      var %monster.deaths $readini($lstfile(monsterdeaths.lst), monster, $1) 
      if (%monster.deaths = $null) { var %monster.deaths 0 }
      inc %monster.deaths 1
      writeini $lstfile(monsterdeaths.lst) monster $1 %monster.deaths
    }
  }
}

inc_monster_kills {
  var %monster.kills $readini($char($1), stuff, MonsterKills)
  if (%monster.kills = $null) { var %monster.kills 0 }
  inc %monster.kills 1 
  writeini $char($1) stuff MonsterKills %monster.kills
  $achievement_check($1, MonsterSlayer)
}

increase_death_tally {
  if ($readini($char($1), info, flag) = npc) { return }
  var %deaths $readini($char($1), stuff, TotalDeaths)
  if (%deaths = $null) { var %deaths 0 } 
  inc %deaths 1
  writeini $char($1) stuff TotalDeaths %deaths
}

check.clone.death {
  if ($isfile($char($1 $+ _clone)) = $true) { 
    if ($readini($char($1 $+ _clone), battle, status) != dead) { writeini $char($1 $+ _clone) battle status dead | writeini $char($1 $+ _clone) battle hp 0 | $set_chr_name($1 $+ _clone) 
      $display.system.message(4 $+ %real.name disappears back into $set_chr_name($1) %real.name $+ 's shadow., battle) 
    }
  }
  if ($isfile($char($1 $+ _summon)) = $true) { 
    if ($readini($char($1 $+ _summon), battle, status) != dead) { writeini $char($1 $+ _summon) battle status dead | writeini $char($1 $+ _summon) battle hp 0 | $set_chr_name($1 $+ _summon) 
      $display.system.message(4 $+ %real.name fades away.,battle) 
    }
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This alias just counts how
; many monsters are in
; the battle. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count.monsters {
  set %monsters.in.battle 0 

  var %count.battletxt.lines $lines($txtfile(battle.txt)) | var %count.battletxt.current.line 1 
  while (%count.battletxt.current.line <= %count.battletxt.lines) { 
    var %count.who.battle $read -l $+ %count.battletxt.current.line $txtfile(battle.txt)
    if (%count.who.battle = $null) { write -d $+ %count.battletxt.current.line $txtfile(battle.txt) | inc %count.battletxt.current.line }

    else { 
      var %count.flag $readini($char(%count.who.battle), info, flag)

      if (%count.flag = monster) { 
        var %summon.flag $readini($char(%count.who.battle), info, summon)
        var %clone.flag $readini($char(%count.who.battle), info, clone)
        var %doppel.flag $readini($char(%count.who.battle), info, Doppelganger)

        if ((%summon.flag != yes) && (%clone.flag != yes)) {  inc %monsters.in.battle 1 }
        if (%doppel.flag = yes) { inc %monsters.in.battle 1 }
      }

      inc %count.battletxt.current.line 1
    }
  }
  writeini $txtfile(battle2.txt) battleinfo monsters %monsters.in.battle
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears dead monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_dead_monsters {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    var %monster.flag $readini($char(%name), Info, Flag)
    if ((%monster.flag = monster) && ($readini($char(%name), battle, hp) <= 0)) { .remove $char(%name) }
    else { return }    
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a percent of the #
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_percentofvalue {
  ; $1 = the original value
  ; $2 = the %

  var %percent $round($calc($2 / 100),2)
  return $round($calc($1 * %percent),0)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the difference of 2 #s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_differenceof {
  return $calc($1 - $2)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the current winning streak
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_winningstreak {
  var %current.winningstreak $readini(battlestats.dat, battle, winningstreak)
  if (%current.winningstreak = $null) { var %current.winningstreak 0 }
  return %current.winningstreak
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns total player levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playerlevelstotal {
  var %total.playerlevels $readini($txtfile(battle2.txt), BattleInfo, PlayerLevels)
  if (%total.playerlevels = $null) { var %total.playerlevels 0 }
  return %total.playerlevels
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Recalculates Total Battles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recalc_totalbattles {
  var %total.battles 0
  inc %total.battles $readini(battlestats.dat, battle, TotalWins)
  inc %total.battles $readini(battlestats.dat, battle, TotalLoss)
  inc %total.battles $readini(battlestats.dat, battle, TotalDraws)
  writeini battlestats.dat battle TotalBattles %total.battles

  var %total.npcwins $readini(battlestats.dat, AIbattles, npc) 
  var %total.monwins $readini(battlestats.dat, AIBattles, monster)
  if (%total.npcwins = $null) { var %total.npcwins 0 }
  if (%total.monwins = $null) { var %total.monwins 0 }
  var %total.aibattles $calc(%total.npcwins + %total.monwins)
  writeini battlestats.dat AIBattles totalBattles %total.aibattles 

  if (%total.battles = 0) { var %total.battles 1 }
  var %number.of.gamedays $round($calc(%total.battles / 8),0)
  writeini battlestats.dat battle GameDays %number.of.gamedays
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Conquest Tally aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
conquest.points {
  if ($1 = add) { 
    var %conquest.points $readini(battlestats.dat, conquest, ConquestPoints)
    inc %conquest.points $2

    if (%conquest.points >= 6000) { var %conquest.points 6000 }
    if (%conquest.points < -6000) { var %conquest.points -6000 }

    writeini battlestats.dat conquest ConquestPoints %conquest.points
  }
  if ($1 = subtract) { 
    var %conquest.points $readini(battlestats.dat, conquest, ConquestPoints)
    dec %conquest.points $2

    if (%conquest.points >= 6000) { var %conquest.points 6000 }
    if (%conquest.points < -6000) { var %conquest.points -6000 }

    writeini battlestats.dat conquest ConquestPoints %conquest.points
  }
}

conquest.tally {
  var %current.time $ctime
  var %last.conquest $readini(battlestats.dat, conquest,  LastTally)
  var %time.difference $calc(%current.time - %last.conquest)

  if (%time.difference >= 432000) {
    writeini battlestats.dat conquest LastTally $ctime

    ; Perform the tally
    $display.system.message($readini(translation.dat, conquest, ConquestTallyTimeToTally), global) 

    ; Get the current conquest points
    var %conquest.points $readini(battlestats.dat, conquest, ConquestPoints)

    if (%conquest.points >= 0) { 
      ; Players win 
      writeini battlestats.dat conquest ConquestBonus %conquest.points
      writeini battlestats.dat conquest ConquestPreviousWinner Players
      writeini battlestats.dat conquest ConquestPoints 1
      $display.system.message($readini(translation.dat, conquest, ConquestTallyPlayersWin), global) 
      var %conquest.wins $readini(battlestats.dat, conquest, TotalPlayerWins)
      if (%conquest.wins = $null) { var %conquest.wins 0 }
      inc %conquest.wins 1
      writeini battlestats.dat conquest TotalPlayerWins %conquest.wins
    }

    if (%conquest.points < 0) { 
      ; Monsters win
      writeini battlestats.dat conquest ConquestBonus 0 
      writeini battlestats.dat conquest ConquestPreviousWinner Monsters
      $display.system.message($readini(translation.dat, conquest, ConquestTallyMonstersWin), global) 
      var %conquest.wins $readini(battlestats.dat, conquest, TotalMonsterWins)
      if (%conquest.wins = $null) { var %conquest.wins 0 }
      inc %conquest.wins 1
      writeini battlestats.dat conquest TotalMonsterWins %conquest.wins
    }
  }
}

conquest.display {
  if (($2 = $null) || ($2 = info)) { 
    var %conquest.points $readini(battlestats.dat, conquest, ConquestPoints)

    if (%conquest.points >= 0) {  $display.system.message($readini(translation.dat, conquest, ConquestTallyCurrentPlayers), private) }
    if (%conquest.points < 0) {  $display.system.message($readini(translation.dat, conquest, ConquestTallyCurrentMon), private) }

    var %previous.conquest.winner $readini(battlestats.dat, conquest, ConquestPreviousWinner)
    if (%previous.conquest.winner = players) { $display.system.message($readini(translation.dat, conquest, ConquestPreviousPlayers), private) }
    if (%previous.conquest.winner = monsters) { $display.system.message($readini(translation.dat, conquest, ConquestPreviousMon), private) }

    var %last.conquest $readini(battlestats.dat, conquest,  LastTally)
    var %next.conquest $calc(%last.conquest + 432000)

    var %conquest.hours.left $round($calc(((%next.conquest - $ctime) / 60) /60 ),2)

    $display.system.message($readini(translation.dat, conquest, ConquestPeriodOverIn), private) 
  }

  if ($2 = points) {
    var %conquest.points $readini(battlestats.dat, conquest, ConquestPoints)
    if (%conquest.points <= 0) { $display.system.message($readini(translation.dat, conquest, ConquestPointsMonsters), private) }
    if (%conquest.points > 0) { $display.system.message($readini(translation.dat, conquest, ConquestPointsPlayers), private) }
  }

  if ($2 = record) {
    var %wins.monsters $readini(battlestats.dat, conquest, TotalMonsterWins)
    var %wins.players $readini(battlestats.dat, conquest, TotalPlayerWins)
    if (%wins.monsters = $null) { var %wins.monsters 0 }
    if (%wins.players = $null) { var %wins.players 0 }
    var %total.wins $calc(%wins.monsters + %wins.players)

    $display.system.message($readini(translation.dat, conquest, ConquestRecord), private) 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DRAGONBALL RELATED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shenron's Wish Check.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db.shenronwish.check {
  if ($readini(battlestats.dat, dragonballs, ShenronWish) != on) { return }
  if ($readini($char($1), info, flag) != $null) { return }
  if (%mode.gauntlet = on) { return }

  ;  Shenron's Wish turns on a bunch of skills and status bonuses
  writeini $char($1) status revive yes  | writeini $char($1) status conservetp yes | writeini $char($1) status orbbonus yes | writeini $char($1) status protect yes 
  writeini $char($1) status shell yes | writeini $char($1) status protect.timer 0 | writeini $char($1) status shell.timer 0
  writeini $char($1) skills thirdeye.on on | writeini $char($1) status thirdeye.turn 0 
  writeini $char($1) skills royalguard.on on | writeini $char($1) skills manawall.on on | writeini $char($1) skills elementalseal.on on
  writeini $char($1) status resist-fire yes | writeini $char($1) status resist-lightning yes | writeini $char($1) status resist-ice yes
  writeini $char($1) status resist-earth yes | writeini $char($1) status resist-wind yes | writeini $char($1) status resist-water yes
  writeini $char($1) status resist-light yes | writeini $char($1) status resist-dark yes
}

db.shenronwish.turncheck {
  if (($readini(battlestats.dat, dragonballs, ShenronWish) = on) && (%mode.gauntlet != on)) { 
    var %shenronwish.turn $readini(battlestats.dat, dragonballs, ShenronWish.rounds)  
    if (%shenronwish.turn = $null) { var %shenronwish.turn 1 }
    inc %shenronwish.turn 1
    writeini battlestats.dat dragonballs ShenronWish.rounds %shenronwish.turn
    if (%shenronwish.turn > 10) { 
      writeini battlestats.dat dragonballs ShenronWish.rounds 1 
      writeini battlestats.dat dragonballs ShenronWish off
      writeini battlestats.dat dragonballs DragonBallsFound 0
      writeini battlestats.dat dragonballs DragonballsActive yes
      $display.system.message($readini(translation.dat, Dragonball, ShenronWishOver), battle)
    }

  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Found a DB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db.dragonball.find {
  if ($readini(battlestats.dat, dragonballs, DragonballsActive) != yes) { return }

  var %dbs.total $readini(battlestats.dat, dragonballs, DragonBallsFound)
  if (%dbs.total = $null) { var %dbs.total 0 }
  if (%dbs.total >= 7) { return }

  var %dbs.random.chance $rand(1,100)
  var %dbs.chance $readini(battlestats.dat, dragonballs, DragonballChance)
  if (%dbs.random.chance > %dbs.chance) { return }

  ; We found a dragonball! Let's announce it to the world then check for Shenron
  inc %dbs.total 1

  $display.system.message($readini(translation.dat, Dragonball, DragonballFound), battle)

  if (%dbs.total < 7) { writeini battlestats.dat dragonballs DragonBallsFound %dbs.total }
  if (%dbs.total >= 7) { 
    writeini battlestats.dat dragonballs DragonBallsFound 0
    writeini battlestats.dat dragonballs DragonballsActive no
    writeini battlestats.dat dragonballs ShenronWish on
    writeini battlestats.dat dragonballs ShenronWish.rounds 1
    $display.system.message($readini(translation.dat, Dragonball, ShenronSummoned), battle)
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display the # of DBs found
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db.display {
  var %dbs.total $readini(battlestats.dat, dragonballs, DragonBallsFound)
  if ($readini(battlestats.dat, dragonballs, ShenronWish) != on) { $display.system.message($readini(translation.dat, Dragonball, DragonballCheck), private) }
  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { $display.system.message($readini(translation.dat, Dragonball, ShenronWishOnMessage), private) }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AI Battle aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ai.battle.generate {
  set %battle.type ai 

  ; set a random battle level
  if (%ai.battle.level = $null) {  set %ai.battle.level $rand(1,9000) }

  ; Create the files.
  writeini $txtfile(1vs1bet.txt) money monster 0
  writeini $txtfile(1vs1bet.txt) money npc 0
  writeini $txtfile(1vs1bet.txt) money total 0
  writeini $txtfile(1vs1bet.txt) money odds.npc 1
  writeini $txtfile(1vs1bet.txt) money odds.monster 1

  ; Generate the random NPC to fight
  $random.battlefield.ally

  ; Generate the monster
  $ai.battle.getmonster($1)

  set %npcfile $readini($txtfile(1vs1bet.txt), money, npcfile) | set %monsterfile $readini($txtfile(1vs1bet.txt), money, monsterfile)

  ; Get the levels
  var %monster.level $get.level(%monsterfile)
  var %npc.level $get.level(%npcfile)

  ; Get their techs & ignitions
  unset %tech.list | unset %weapon.equipped

  $weapon_equipped(%npcfile) | $tech.list(%npcfile, %weapon.equipped) | var %ignitions $ignitions.get.list(%npcfile) 

  if (%tech.list = $null) { var %tech.list none | var %total.npc.techs 0 }
  if (%ignition.counter = $null) { var %ignition.counter 0 }

  var %ai.npc.techs %tech.list
  inc %npc.level %tech.power
  inc %npc.level %ignition.counter

  if (%ignitions != $null) { var %npc.use.ignitions yes }
  if (%tech.list != none) { var %total.npc.techs %tech.count }

  unset %tech.list | unset %ignition.counter | unset %tech.count | unset %tech.power | unset %ignitions

  $weapon_equipped(%monsterfile) | $tech.list(%monsterfile, %weapon.equipped) | var %ignitions $ignitions.get.list(%monsterfile) 

  if (%tech.list = $null) { var %tech.list none | var %total.monster.techs 0 }
  if (%ignition.counter = $null) { var %ignition.counter 0 }

  var %ai.monster.techs %tech.list
  inc %monster.level %tech.power
  inc %monster.level %ignition.counter | unset %ignition.counter

  if (%ignitions != $null) { var %monster.use.ignitions yes }
  if (%tech.list != none) { var %total.monster.techs %tech.count }

  ; calculate their battle level.
  inc %npc.level $readini($char(%npcfile), battle, hp)
  inc %monster.level $readini($char(%monsterfile), battle, hp)
  if ($readini($char(%npcfile), mech, HpMax) != $null) { inc %npc.level 100 }
  if ($readini($char(%monsterfile), mech, HpMax) != $null) { inc %monster.level 100 }
  if ($readini($char(%npcfile), info, CanTaunt) != false) { dec %npc.level 10 } 
  if ($readini($char(%monsterfile), info, CanTaunt) != false) { dec %monster.level 10 } 
  if ($readini($char(%monsterfile), naturalarmor, max) != $null) { inc %monster.level $readini($char(%monsterfile), naturalarmor, max) }

  ; Set a favorite to win the fight.
  if (%monster.level > %npc.level) { var %favorite.to.win monster }
  if (%monster.level <= %npc.level) { var %favorite.to.win npc }

  ; create some random gamblers who will participate and place random bets.
  ; I will expand this later to be "smarter" but for now..random. 
  var %total.gamblers $readini(system.dat, system, PhantomBetters)
  if (%total.gamblers = $null) { var %total.gamblers 13 }
  if (%total.gambleres < 3) { var %total.gamblers 3 }

  var %counter 1

  while (%counter <= %total.gamblers) { 
    unset %money.multiplier | unset %money.bet | unset %money.target

    var %money.multiplier $rand(1,5)
    var %money.bet $calc(10 * %money.multiplier)

    if (%counter = %total.gamblers) { 
      if (%favorite.to.win = monster) { var %money.target 1 }
      if (%favorite.to.win = npc) { var %money.target 2 }
    }
    if (%counter < %total.gamblers) {
      var %chance.to.bet.on.favorite $rand(1,100)
      if (%chance.to.bet.on.favorite < 90) { 
        if (%favorite.to.win = monster) { var %money.target 2 }
        if (%favorite.to.win = npc) { var %money.target 1 }
      }
      if (%chance.to.bet.on.favorite >= 90) { 
        if (%favorite.to.win = monster) { var %money.target 1 }
        if (%favorite.to.win = npc) { var %money.target 2 }
      }
    }

    if (%money.target = 1) { 
      var %money.npc $readini($txtfile(1vs1bet.txt), money, npc)
      inc %money.npc %money.bet
      writeini $txtfile(1vs1bet.txt) money npc %money.npc
    } 
    if (%money.target = 2) {
      var %money.mon $readini($txtfile(1vs1bet.txt), money, monster)
      inc %money.mon %money.bet
      writeini $txtfile(1vs1bet.txt) money monster %money.mon
    }
    var %money.total $readini($txtfile(1vs1bet.txt), money, total)
    inc %money.total %money.bet
    writeini $txtfile(1vs1bet.txt) money total %money.total
    inc %counter 1
  }

  ; Generate the opening odds
  $ai.battle.createodds

  var %odds.npc $readini($txtfile(1vs1bet.txt), money, odds.npc)
  var %odds.monster $readini($txtfile(1vs1bet.txt), money, odds.monster)

  ; Display the AI battle information
  $display.system.message($readini(translation.dat, battle, BattleAIInfo), global)
  $display.system.message($readini(translation.dat, battle, BattleAITechInfoNPC), global)
  $display.system.message($readini(translation.dat, battle, BattleAITechInfoMon), global)

  ; Open betting
  set %betting.period open
  $display.system.message($readini(translation.dat, system, BettingPeriodOpened), global)

  unset %npcfile | unset %monsterfile | unset %tech.list | unset %tech.count | unset %tech.power

  var %totalaibattles $readini(battlestats.dat, AIBattles, totalBattles)
  if (%totalaibattles = $null) { var %totalaibattles 0 }
  inc %totalaibattles 1
  writeini battlestats.dat AIBattles totalBattles %totalaibattles


  return
}
ai.battle.payout {
  set %money.winner $readini($txtfile(1vs1bet.txt), money, winner)

  set %totalwins $readini(battlestats.dat, AIBattles, %money.winner)
  if (%totalwins = $null) { var %totalwins 0 }
  inc %totalwins 1
  if (%money.winner != $null) { writeini battlestats.dat AIBattles %money.winner %totalwins }

  unset %totalwins

  if ($lines($txtfile(1vs1gamblers.txt)) = 0) { unset %money.winner | return }

  var %currency.symbol $readini(system.dat, system, BetCurrency)
  if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }

  var %odds.npc $readini($txtfile(1vs1bet.txt), money, odds.npc)
  var %odds.monster $readini($txtfile(1vs1bet.txt), money, odds.monster)
  var %payout.ratio 0

  if (%money.winner = npc) { var %payout.ratio $round($calc(%odds.monster / %odds.npc),2) }
  if (%money.winner = monster) { var %payout.ratio $round($calc(%odds.npc / %odds.monster),2) }

  var %gambler.lines $lines($txtfile(1vs1gamblers.txt)) | var %gamblers.current.line 1 
  while (%gamblers.current.line <= %gambler.lines) { 
    set %who.gambler $read -l $+ %gamblers.current.line $txtfile(1vs1gamblers.txt)

    set %who.gambler.beton $readini($txtfile(1vs1bet.txt), money, %who.gambler $+ .bettarget)
    if (%who.gambler.beton = %money.winner) {
      set %original.bet $readini($txtfile(1vs1bet.txt), money, %who.gambler $+ .betamount)
      var %payout.amount $round($calc(%original.bet * %payout.ratio),0)
      if (%payout.amount < 1) { var %payout.amount 1 }

      if (%payout.amount >= 2000) {   $achievement_check(%who.gambler, Jackpot) }

      inc %payout.amount %original.bet
      %winners = $addtok(%winners,  $+ %who.gambler $+ ( $+ %currency.symbol $+ %payout.amount $+ ), 46)

      var %double.dollars $readini($char(%who.gambler), stuff, doubledollars)
      inc %double.dollars %payout.amount
      writeini $char(%who.gambler) stuff doubledollars %double.dollars
    }

    unset %who.gambler.beton | unset %who.gambler | unset %original.bet | inc %gamblers.current.line 

  }

  if (%winners != $null) { 
    ; CLEAN UP THE LIST
    set %replacechar $chr(044) $chr(032)
    %winners = $replace(%winners, $chr(046), %replacechar)
    $display.system.message(12Payout ratio for the winner [ $+ %money.winner $+ ]: %payout.ratio for every $chr(36) $+ $chr(36) $+ 1, battle) 
    $display.system.message($readini(translation.dat, system, DoubleDollarWinners), global) 
    unset %replacechar
  }

  unset %winners | unset %money.winner
}
ai.battle.getmonster {
  if (%battle.type = ai) { 
    inc %number.of.monsters.needed 1 

    var %random.montype $rand(1,2)

    if ($1 = boss) { var %random.montype 2 }
    if ($1 = monster) { var %random.montype 1 }

    if (%random.montype = 1) {  $generate_monster(monster) }
    if (%random.montype = 2) { $generate_monster(boss) }
  }
}

ai.battle.createodds {
  var %money.total $readini($txtfile(1vs1bet.txt), money, total)
  var %money.npc $readini($txtfile(1vs1bet.txt), money, npc)
  var %money.monster $readini($txtfile(1vs1bet.txt),money,monster)

  var %odds.npc $round($calc(%money.total / %money.npc),1)
  var %odds.monster $round($calc(%money.total / %money.monster),1)

  if (%odds.npc <= 1) { var %odds.npc 1 }
  if (%odds.monster <= 1) { var %odds.monster 1 }

  writeini $txtfile(1vs1bet.txt) money odds.npc %odds.monster
  writeini $txtfile(1vs1bet.txt) money odds.monster %odds.npc
}

ai.battle.place.bet {
  if (%betting.period != open) { $display.private.message2($1, $readini(translation.dat, errors, BettingPeriodClosed)) | halt } 
  if (%battle.type != ai) { $display.private.message2($1, $readini(translation.dat, errors, CannotBetOnThisBattle)) | halt } 
  if ($2 = $null) { $display.private.message2($1, $readini(translation.dat, errors, NotValidBet)) | halt }
  if (($2 != npc) && ($2 != monster)) { $display.private.message2($1, $readini(translation.dat, errors, NotValidBet)) | halt }
  if ($3 = $null) { $display.private.message2($1, $readini(translation.dat, errors, NotValidBetAmount)) | halt }
  if ($3 !isnum 1-9999) { $display.private.message2($1, $readini(translation.dat, errors, NotValidBetAmount)) | halt }
  if ($readini($txtfile(1vs1bet.txt), money, $1 $+ .betamount) != $null) { $display.private.message2($1, $readini(translation.dat, errors, AlreadyPlacedBet)) | halt }

  var %double.dollars $readini($char($1), stuff, doubledollars)
  if (%double.dollars = $null) { writeini $char($1) stuff doubledollars 100 | var %double.dollars 100 }

  if (%double.dollars < $3) { $display.private.message2($1, $readini(translation.dat, errors, NotEnoughDoubleDollars)) | halt }

  var %currency.symbol $readini(system.dat, system, BetCurrency)
  if (%currency.symbol = $null) { var %currency.symbol $chr(36) $+ $chr(36) }

  dec %double.dollars $3
  writeini $char($1) stuff doubledollars %double.dollars

  var %money.total $readini($txtfile(1vs1bet.txt), money, total)
  inc %money.total $3
  writeini $txtfile(1vs1bet.txt) money total %money.total

  writeini $txtfile(1vs1bet.txt) money $1 $+ .betamount $3
  writeini $txtfile(1vs1bet.txt) money $1 $+ .bettarget $2
  write $txtfile(1vs1gamblers.txt) $1

  if ($2 = npc) { 
    var %money.npc $readini($txtfile(1vs1bet.txt), money, npc)
    inc %money.npc $3
    writeini $txtfile(1vs1bet.txt) money npc %money.npc
  }
  if ($2 = monster) { 
    var %money.mon $readini($txtfile(1vs1bet.txt), money, monster)
    inc %money.mon $3
    writeini $txtfile(1vs1bet.txt) money monster %money.mon
  }

  ; check for achievement
  var %total.bets $readini($char($1), stuff, TotalBets)
  var %total.bet.amount $readini($char($1), stuff, TotalBetAmount)

  if (%total.bets = $null) { var %total.bets 0 }
  if (%total.bet.amount = $null) { var %total.bet.amount 0 }

  inc %total.bets 1 
  inc %total.bet.amount $3 

  writeini $char($1) stuff TotalBets %total.bets
  writeini $char($1) stuff TotalBetAmount %total.bet.amount

  $achievement_check($1, ICanQuitAnyBettingTimeIWant)

  $display.private.message2($1, $readini(translation.dat, system, BetPlaced))
}

portal.clearusagecheck {
  ; $1 = person to check

  set %current.day $gettok($adate, 2, 47)
  set %current.month $gettok($adate, 1, 47)

  set %last.portal.used.month $gettok($readini($char($1), info, LastPortalDate), 1, 47)
  set %last.portal.used.day $gettok($readini($char($1), info, LastPortalDate), 2, 47)

  var %reset.usage false

  if ((%current.month = $null) || (%last.portal.used.day = $null)) { var %reset.usage true }

  if (%last.portal.used.month = %current.month) { 
    if (%last.portal.used.day != %current.day) { var %reset.usage true }
  }
  if (%current.month != %last.portal.used.month) { var %reset.usage true }

  if (%reset.usage = true) { writeini $char($1) info PortalsUsedTotal 0 }

  unset %current.day | unset %current.month | unset %last.portal.used.day | unset %last.portal.used.month

}
