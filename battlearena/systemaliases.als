;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; systemaliases.als
;;;; Last updated: 02/24/16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version of the bot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
battle.version {  
  if ($readini(version.ver, versions, Bot) = $null) { echo -a 4ERROR: version.ver is either missing or corrupted! | return 3.1 }
  else { return $readini(version.ver, versions, Bot) } 
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version of the system.dat file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system.dat.version { 
  if ($readini(version.ver, versions, systemdat) = $null) { echo -a 4ERROR: version.ver is either missing or corrupted! | return 0 }
  else { return $readini(version.ver, versions, systemdat) } 
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The bot's quit message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
quitmsg { return Battle Arena version $battle.version written by James  "Iyouboushi" }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for all system defaults
; and adds any that are missing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    if ($readini(system.dat, system, AllowBold) = $null) { writeini system.dat system AllowBold true }
    if ($readini(system.dat, system, automatedbattlesystem) = $null) { writeini system.dat system automatedbattlesystem on } 
    if ($readini(system.dat, system, TimeBetweenBattles) = $null) { writeini system.dat system TimeBetweenBattles 120 } 
    if ($readini(system.dat, system, TimeBetweenSave) = $null) { writeini system.dat system TimeBetweenSave 3600 } 
    if ($readini(system.dat, system, TimeBetweenSaveReload) = $null) { writeini system.dat system TimeBetweenSaveReload 1200 } 
    if ($readini(system.dat, system, automatedaibattlecasino) = $null) { writeini system.dat system automatedaibattlecasino off } 
    if ($readini(system.dat, system, aisystem) = $null) { writeini system.dat system aisystem on } 
    if ($readini(system.dat, system, showCustomBattleMessages) = $null) { writeini system.dat system showCustomBattleMessages true  } 
    if ($readini(system.dat, system, currency) = $null) { writeini system.dat system currency Red Orbs }
    if ($readini(system.dat, system, basexp) = $null) { writeini system.dat system basexp 100 } 
    if ($readini(system.dat, system, basebossxp) = $null) { writeini system.dat system basebossxp 500 } 
    if ($readini(system.dat, system, baseportalxp) = $null) { writeini system.dat system baseportalxp 600 } 
    if ($readini(system.dat, system, startingorbs) = $null) { writeini system.dat system startingorbs 1000 } 
    if ($readini(system.dat, system, maxHP) = $null) { writeini system.dat system maxHP 2500 } 
    if ($readini(system.dat, system, maxTP) = $null) { writeini system.dat system maxTP 500 } 
    if ($readini(system.dat, system, maxIG) = $null) { writeini system.dat system maxIG 100 } 
    if ($readini(system.dat, system, maxOrbReward) = $null) { writeini system.dat system maxOrbReward 20000 } 
    if ($readini(system.dat, system, MaxGauntletOrbReward) = $null) { writeini system.dat system MaxGauntletOrbReward 50000 } 
    if ($readini(system.dat, system, maxshoplevel) = $null) { writeini system.dat system maxshoplevel 25 } 
    if ($readini(system.dat, system, EnableChests) = $null) { writeini system.dat system EnableChests true }
    if ($readini(system.dat, system, MaxCharacters) = $null) { writeini system.dat system MaxCharacters 2 }
    if ($readini(system.dat, system, EnableDNSCheck) = $null) { writeini system.dat system EnableDNSCheck true }
    if ($readini(system.dat, system, TimeForIdle) = $null) { writeini system.dat system TimeForIdle 180 }
    if ($readini(system.dat, system, TimeToEnter) = $null) { writeini system.dat system TimeToEnter 120 }
    if ($readini(system.dat, system, TimeToEnterDungeon) = $null) { writeini system.dat system TimeToEnterDungeon 120 }
    if ($readini(system.dat, system, ShowOrbsCmdInChannel) = $null) { writeini system.dat system ShowOrbsCmdInChannel true }
    if ($readini(system.dat, system, ShowDiscountMessage) = $null) { writeini system.dat system ShowDiscountMessage false }
    if ($readini(system.dat, system, EnableBattlefieldEvents) = $null) { writeini system.dat system EnableBattlefieldEvents true }
    if ($readini(system.dat, system, GuaranteedBossBattles) = $null) { writeini system.dat system GuaranteedBossBattles 10.15.20.30.60.100.150.180.220.280.320.350.401.440.460.501.560.601.670.705.780.810.890.920.999.1100.1199.1260. 1305.1464.1500.1650.1720.1880.1999.2050.2250.9999  }
    if ($readini(system.dat, system, BonusEvent) = $null) { writeini system.dat system BonusEvent false }
    if ($readini(system.dat, system, IgnoreDmgCap) = $null) { writeini system.dat system IgnoreDmgCap false }
    if ($readini(system.dat, system, MaxNumberOfMonsInBattle) = $null) { writeini system.dat system MaxNumberOfMonsInBattle 6 }
    if ($readini(system.dat, system, ScoreBoardType) = $null) { writeini system.dat system ScoreBoardType 2 }
    if ($readini(system.dat, system, EmptyRoundsBeforeStreakReset) = $null) { writeini system.dat system EmptyRoundsBeforeStreakReset 10 }
    if ($readini(system.dat, system, ChestTime) = $null) { writeini system.dat system ChestTime 45 }
    if ($readini(system.dat, system, RedChestBase) = $null) { writeini system.dat system RedChestBase $eval($rand(150,700),0) }
    if ($readini(system.dat, system, MimicChance) = $null) { writeini system.dat system MimicChance 10 }
    if ($readini(system.dat, system, AllowMechs) = $null) { writeini system.dat system AllowMechs true }
    if ($readini(system.dat, system, PhantomBetters) = $null) { writeini system.dat system PhantomBetters 13 }
    if ($readini(system.dat, system, EnableAuctionHouse) = $null) { writeini system.dat system EnableAuctionHouse true }
    if ($readini(system.dat, system, BattleThrottle) = $null) { writeini system.dat system BattleThrottle false }
    if ($readini(system.dat, system, LimitPortalBattles) = $null) { writeini system.dat system LimitPortalBattles true }
    if ($readini(system.dat, system, ForcePortalSync) = $null) { writeini system.dat system ForcePortalSync true }
    if ($readini(system.dat, system, GenerateHTML) = $null) { writeini system.dat system GenerateHTML true }
    if ($readini(system.dat, system, PlayersMustDieMode) = $null) { writeini system.dat system PlayersMustDieMode false }
    if ($readini(system.dat, system, WheelGameCost) = $null) { writeini system.dat system WheelGameCost 500 }
    if ($readini(system.dat, system, WheelGameTime) = $null) { writeini system.dat system WheelGameTime 43200 }
    if ($readini(system.dat, system, TwitchDelayTime) = $null) { writeini system.dat system TwitchDelayTime 2 }
    if ($readini(system.dat, system, ShowDeleteEcho) = $null) { writeini system.dat system ShowDeleteEcho false }
    if ($readini(system.dat, system, AllowSpiritOfHero) = $null) { writeini system.dat system AllowSpiritOfHero true }
    if ($readini(system.dat, system, EnableFoodOnOthers) = $null) { writeini system.dat system EnableFoodOnOthers true }
    if ($readini(system.dat, system, AllowPersonalDifficulty) = $null) { writeini system.dat system AllowPersonalDifficulty true }
    if ($readini(system.dat, system, AllowPlayerAccessCmds) = $null) { writeini system.dat system AllowPlayerAccessCmds true }
    if ($readini(system.dat, system, BattleDamageFormula) = $null) { writeini system.dat system BattleDamageFormula 1 }
    if ($readini(system.dat, system, AllowAuctionHouseTopicChange) = $null) { writeini system.dat system AllowAuctionHouseTopicChange true }
    if ($readini(system.dat, system, MaxIdleTurns) = $null) { writeini system.dat system MaxIdleTurns 2 }

    if ($readini(system.dat, system, EnableDoppelganger) = $null) { writeini system.dat system EnableDoppelganger true }
    if ($readini(system.dat, system, EnableWarmachine) = $null) { writeini system.dat system EnableWarmachine true }
    if ($readini(system.dat, system, EnableBandits) = $null) { writeini system.dat system EnableBandits true }
    if ($readini(system.dat, system, EnableGremlins) = $null) { writeini system.dat system EnableGremlins true }
    if ($readini(system.dat, system, EnableGoblins) = $null) { writeini system.dat system EnableGoblins true }
    if ($readini(system.dat, system, EnablePirates) = $null) { writeini system.dat system EnablePirates true }
    if ($readini(system.dat, system, EnableDinosaurs) = $null) { writeini system.dat system EnableDinosaurs true }
    if ($readini(system.dat, system, EnableCrystalShadow) = $null) { writeini system.dat system EnableCrystalShadow true }
    if ($readini(system.dat, system, EnablePresidentKidnapping) = $null) { writeini system.dat system EnablePresidentKidnapping true }
    if ($readini(system.dat, system, EnableNPCKidnapping) = $null) { writeini system.dat system EnableNPCKidnapping true }
    if ($readini(system.dat, system, AllowDemonwall) = $null) { writeini system.dat system AllowDemonwall yes }
    if ($readini(system.dat, system, AllowWallOfFlesh) = $null) { writeini system.dat system AllowWallOfFlesh yes }
    if ($readini(system.dat, system, MaxDemonWallTurns) = $null) { writeini system.dat system MaxDemonWallTurns 10 }
    if ($readini(system.dat, system, MaxWallOfFleshTurns) = $null) { writeini system.dat system MaxWallOfFleshTurns 16 }
    if ($readini(system.dat, system, EnablePredator) = $null) { writeini system.dat system EnablePredator true }

    ; Player Level Caps for special battles
    if ($readini(system.dat, PlayerLevelCaps, Doppelganger) = $null) { writeini system.dat PlayerLevelCaps Doppelganger 50 }
    if ($readini(system.dat, PlayerLevelCaps, SmallWarmachine) = $null) { writeini system.dat PlayerLevelCaps SmallWarmachine 20 }
    if ($readini(system.dat, PlayerLevelCaps, MediumWarmachine) = $null) { writeini system.dat PlayerLevelCaps MediumWarmachine 50  }
    if ($readini(system.dat, PlayerLevelCaps, LargeWarmachine) = $null) { writeini system.dat PlayerLevelCaps LargeWarmachine 75  }
    if ($readini(system.dat, PlayerLevelCaps, Bandits) = $null) { writeini system.dat PlayerLevelCaps Bandits 50 }
    if ($readini(system.dat, PlayerLevelCaps, Gremlins) = $null) { writeini system.dat PlayerLevelCaps Gremlins 50 }
    if ($readini(system.dat, PlayerLevelCaps, Pirates) = $null) { writeini system.dat PlayerLevelCaps Pirates 75 }
    if ($readini(system.dat, PlayerLevelCaps, FrostLegion) = $null) { writeini system.dat PlayerLevelCaps FrostLegion 20 }
    if ($readini(system.dat, PlayerLevelCaps, ElderDragon) = $null) { writeini system.dat PlayerLevelCaps ElderDragon 200 }
    if ($readini(system.dat, PlayerLevelCaps, DemonWall) = $null) { writeini system.dat PlayerLevelCaps DemonWall 75 }
    if ($readini(system.dat, PlayerLevelCaps, WallOfFlesh) = $null) { writeini system.dat PlayerLevelCaps WallOfFlesh 200 }
    if ($readini(system.dat, PlayerLevelCaps, DefendOutpost) = $null) { writeini system.dat PlayerLevelCaps DefendOutpost 100 }
    if ($readini(system.dat, PlayerLevelCaps, Assault) = $null) { writeini system.dat PlayerLevelCaps Assault 100 }
    if ($readini(system.dat, PlayerLevelCaps, Predator) = $null) { writeini system.dat PlayerLevelCaps Predator 200 }

    ; Monster Level Caps for special bosses
    if ($readini(system.dat, MonsterLevelCaps, SmallWarmachine) = $null) { writeini system.dat MonsterLevelCaps SmallWarmachine 18 }
    if ($readini(system.dat, MonsterLevelCaps, MediumWarmachine) = $null) { writeini system.dat MonsterLevelCaps MediumWarmachine 48  }
    if ($readini(system.dat, MonsterLevelCaps, LargeWarmachine) = $null) { writeini system.dat MonsterLevelCaps LargeWarmachine 74  }
    if ($readini(system.dat, MonsterLevelCaps, BanditLeader) = $null) { writeini system.dat MonsterLevelCaps BanditLeader 48 }
    if ($readini(system.dat, MonsterLevelCaps, BanditMinion) = $null) { writeini system.dat MonsterLevelCaps BanditMinion 45 }
    if ($readini(system.dat, MonsterLevelCaps, Gremlins) = $null) { writeini system.dat MonsterLevelCaps Gremlins 45 }
    if ($readini(system.dat, MonsterLevelCaps, PirateMinion) = $null) { writeini system.dat MonsterLevelCaps PirateMinion 70 }
    if ($readini(system.dat, MonsterLevelCaps, PirateFirstMatey) = $null) { writeini system.dat MonsterLevelCaps PirateFirstMatey 73 }
    if ($readini(system.dat, MonsterLevelCaps, FrostLegion) = $null) { writeini system.dat MonsterLevelCaps FrostLegion 15 }
    if ($readini(system.dat, MonsterLevelCaps, ElderDragon) = $null) { writeini system.dat MonsterLevelCaps ElderDragon 195 }
    if ($readini(system.dat, MonsterLevelCaps, DemonWall) = $null) { writeini system.dat MonsterLevelCaps DemonWall 75 }
    if ($readini(system.dat, MonsterLevelCaps, WallOfFlesh) = $null) { writeini system.dat MonsterLevelCaps WallOfFlesh 200 }
    if ($readini(system.dat, MonsterLevelCaps, Predator) = $null) { writeini system.dat MonsterLevelCaps Predator 200 }

    ; Stat prices
    if ($readini(system.dat, statprices, hp) = $null) { writeini system.dat statprices hp 150 }
    if ($readini(system.dat, statprices, tp) = $null) { writeini system.dat statprices tp 150 }
    if ($readini(system.dat, statprices, str) = $null) { writeini system.dat statprices str 250 }
    if ($readini(system.dat, statprices, def) = $null) { writeini system.dat statprices def 250 }
    if ($readini(system.dat, statprices, int) = $null) { writeini system.dat statprices int 250 }
    if ($readini(system.dat, statprices, spd) = $null) { writeini system.dat statprices spd 250 }
    if ($readini(system.dat, statprices, ig) = $null) { writeini system.dat statprices ig 800 }

    ; Mech settings
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

    ; Auction Info
    if ($readini(system.dat, auctionInfo, TimeBetweenAuctions) = $null) { writeini system.dat AuctionInfo TimeBetweenAuction 3600 }

    ; Certain battle settings
    if ($readini(battlestats.dat, battle, LevelAdjust) = $null) { writeini battlestats.dat battle LevelAdjust 0 }
    if ($readini(battlestats.dat, battle, emptyRounds) = $null) { writeini battlestats.dat battle emptyRounds 0 }

    ; Conquest Settings
    if ($readini(battlestats.dat, conquest, LastTally) = $null) { writeini battlestats.dat conquest LastTally $ctime }
    if ($readini(battlestats.dat, conquest, ConquestPointsPlayers) = $null) { 
      var %conquest.points.old $readini(battlestats.dat, conquest, ConquestPoints)
      if (%conquest.points.old > 0) { writeini battlestats.dat conquest ConquestPointsPlayers %conquest.points.old }
      else { writeini battlestats.dat conquest ConquestPointsPlayers 0 }
    }

    if ($readini(battlestats.dat, conquest, ConquestPointsMonsters) = $null) { 
      var %conquest.points.old $readini(battlestats.dat, conquest, ConquestPoints)
      if (%conquest.points.old < 0) { writeini battlestats.dat conquest ConquestPointsMonsters $abs(%conquest.points.old) }
      else { writeini battlestats.dat conquest ConquestPointsMonsters 1000 }
    }

    if ($readini(battlestats.dat, conquest, ConquestBonus) = $null) { writeini battlestats.dat conquest ConquestBonus 0 }
    if ($readini(battlestats.dat, conquest, AlliedInfluence) = $null) { writeini battlestats.dat conquest AlliedInfluence 0 }
    if ($readini(battlestats.dat, conquest, MonsterInfluence) = $null) { writeini battlestats.dat conquest MonsterInfluence 50 }

    ; Dragonballs
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
    if ($readini(shopnpcs.dat, NPCStatus, PotionWitch) = $null) { writeini shopnpcs.dat NPCStatus PotionWitch false }
    if ($readini(shopnpcs.dat, NPCStatus, Gambler) = $null) { writeini shopnpcs.dat NPCStatus Gambler kidnapped }
    if ($readini(shopnpcs.dat, NPCStatus, DungeonKeyMerchant) = $null) { writeini shopnpcs.dat NPCStatus DungeonKeyMerchant kidnapped }
    if ($readini(shopnpcs.dat, NPCStatus, GobbieBoxGoblin) = $null) { writeini shopnpcs.dat NPCStatus GobbieBoxGoblin false }
    if ($readini(shopnpcs.dat, NPCStatus, Jeweler) = $null) { writeini shopnpcs.dat NPCStatus Jeweler false }

    if ($readini(shopnpcs.dat, Events, FrostLegionDefeated) = $null) { writeini shopnpcs.dat Events FrostLegionDefeated false }
    if ($readini(shopnpcs.dat, Events, SavedElves) = $null) { writeini shopnpcs.dat Events SavedElves 0 }
    if ($readini(shopnpcs.dat, NPCNames, Santa) = $null) { writeini shopnpcs.dat NPCNames Santa Santa }
    if ($readini(shopnpcs.dat, NPCNames, EasterBunny) = $null) { writeini shopnpcs.dat NPCNames EasterBunny Easter Bunny }
    if ($readini(shopnpcs.dat, NPCNames, DiscountCardMerchant) = $null) { writeini shopnpcs.dat NPCNames DiscountCardMerchant Myles the Discount Merchant }
    if ($readini(shopnpcs.dat, NPCNames, HealingMerchant) = $null) { writeini shopnpcs.dat NPCNames HealingMerchant Katelyn the Healing Merchant }
    if ($readini(shopnpcs.dat, NPCNames, BattleMerchant) = $null) { writeini shopnpcs.dat NPCNames BattleMerchant Gerhardt the Battle Merchant }

    if (($readini(shopnpcs.dat, NPCNames, AlliedForcesPresident) = $null) || ($readini(shopnpcs.dat, NPCNames, AlliedForcesPresident) = Allied Forces President)) { 
      var %shopnpc.name the Allied Forces President
      if ($isfile($lstfile(presidentnames.lst)) = $true) {
        var %shopnpc.name $read($lstfile(presidentnames.lst))
        var %shopnpc.name %shopnpc.name the Allied Forces President
      }
      writeini shopnpcs.dat NPCNames AlliedForcesPresident %shopnpc.name
    }

    if ($readini(shopnpcs.dat, NPCNames, SongMerchant) = $null) { writeini shopnpcs.dat NPCNames SongMerchant Spoony the Bard }
    if ($readini(shopnpcs.dat, NPCNames, ShieldMerchant) = $null) { writeini shopnpcs.dat NPCNames ShieldMerchant Gondo the Shield Merchant }
    if ($readini(shopnpcs.dat, NPCNames, WheelMaster) = $null) { writeini shopnpcs.dat NPCNames WheelMaster Dodoh the Wheel Master }
    if ($readini(shopnpcs.dat, NPCNames, TravelMerchant) = $null) { writeini shopnpcs.dat NPCNames TravelMerchant Beedle the Traveling Merchant }
    if ($readini(shopnpcs.dat, NPCNames, Gardener) = $null) { writeini shopnpcs.dat NPCNames Gardener Green Thumb the Garden Moogle }
    if ($readini(shopnpcs.dat, NPCNames, PotionWitch) = $null) { writeini shopnpcs.dat NPCNames PotionWitch Syrup the Potion Witch }
    if ($readini(shopnpcs.dat, NPCNames, Gambler) = $null) { writeini shopnpcs.dat NPCNames Gambler Setzer the Gambler }
    if ($readini(shopnpcs.dat, NPCNames, DungeonKeyMerchant) = $null) { writeini shopnpcs.dat NPCNames DungeonKeyMerchant Vinz Clortho the Keymaster }
    if ($readini(shopnpcs.dat, NPCNames, GobbieBoxGoblin) = $null) { writeini shopnpcs.dat NPCNames GobbieBoxGoblin Bountibox the Goblin }
    if ($readini(shopnpcs.dat, NPCNames, Jeweler) = $null) { writeini shopnpcs.dat NPCNames Jeweler Vasu the Jeweler }

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
  /.load -a characters.als
  /.load -a battlealiases.als
  /.load -a  battleformulas.als
  /.load -a dungeons.als
  /.load -a bossaliases.als
  /.load -a scoreboard.als

  ; Remove files that are no longer needed.
  .remove $npc(Soifon)
  .remove $npc(Yoruichi_Shihoiun)
  .remove $npc(Nauthima)

  .remove $mon(Demonic_Succubus)
  .remove $mon(Final_Guard)
  .remove $mon(Prime_Vise)
  .remove $mon(Excenmille)
  .remove $mon(NajaSalaheem)
  .remove $mon(Wind-UpShantotto)

  .remove $boss(Adlanna)
  .remove $boss(Eldora)
  .remove $boss(EldoraAdlanna)
  .remove $boss(NauthimaTiranadel)
  .remove $boss(RuneFencer_Nauthima)
  .remove $boss(Magus)

  .remove $summon(Eldora_Adlanna)

  .remove $lstfile(items_songs.lst)

  .remove $txtfile(attack_Aettir.txt)
  .remove $txtfile(attack_ChatoyantStaff.txt)

  ; Remove settings no longer needed
  if ($readini(system.dat, system, BattleDamageFormula) != $null) { remini system.dat system BattleDamageFormula }
  if ($readini(battlestats.dat, conquest, ConquestPoints) != $null) { remini battlestats.dat conquest ConquestPoints }


}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a system setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.systemsetting {
  var %system.setting.temp $readini(system.dat, system, $1) 
  if (%system.setting.temp = $null) { return null }
  else { return %system.setting.temp }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a levelcap setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.levelCapSetting {
  var %level.cap.setting $readini(system.dat, PlayerLevelCaps, $1)
  if (%level.cap.setting = $null) { return null }
  else { return %level.cap.setting }
}

return_levelCapSettingMonster {
  var %level.cap.setting $readini(system.dat, MonsterLevelCaps, $1)
  if (%level.cap.setting = $null) { return null }
  else { return %level.cap.setting }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Identifies to nickserv
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
identifytonickserv {
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if (%bot.pass != $null) { /.msg nickserv identify %bot.pass }
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
  if (%battle.type = torment) { return $calc(500 * %torment.level) }
  if (%battle.type = ai) { return %ai.battle.level }
  if (%battle.type = DragonHunt) { return $dragonhunt.dragonage(%dragonhunt.file.name) }

  if (%portal.bonus = true) {
    var %portal.streak $readini($txtfile(battle2.txt), battleinfo, Portallevel)
    if (%portal.streak = $null) { echo -a portal level is null | return 10 }
    return %portal.streak 
  }
  if (%portal.bonus != true) { 

    if (%battle.type = dungeon) { return $readini($txtfile(battle2.txt), dungeoninfo, dungeonlevel) }

    var %current.winningstreak $readini(battlestats.dat, battle, winningstreak)
    if (%current.winningstreak = $null) { var %current.winningstreak 0 }

    if ((%battle.type = assault) || (%battle.type = defendoutpost)) {
      if (%current.winningstreak > 100) { return 100 }
      else { return %current.winningstreak }
    }
    else {  return %current.winningstreak }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cleans the main bot folder.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clean_mainfolder { 
  if ($2 = $null) {  .remove $1 }
  if ($2 != $null) { 
    set %clean.file $nopath($1-) 
    .remove %clean.file
    unset %clean.file
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Writes Hostname to file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writehost {
  if ($isfile($char($nick)) = $true) { 
    if ($2 != $null) { writeini $char($1) info lastIP $2 }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a color for equipment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
equipment.color {
  var %equipment.color 3
  if (+1 isin $1) { var %equipment.color 12 }
  if (+2 isin $1) { var %equipment.color 6 }
  if ((($readini($dbfile(weapons.db), $1, legendary) = true) || ($readini($dbfile(items.db), $1, legendary) = true) || ($readini($dbfile(equipment.db), $1, legendary) = true))) { var %equipment.color 7 }
  return %equipment.color
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starts a new battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system.start.newbattle {
  if ($readini(system.dat, system, automatedbattlesystem) = off) { return }

  var %time.between.battles $readini(system.dat, System, TimeBetweenBattles)
  if (%time.between.battles = $null) { var %time.between.battles 120 }
  var %newbattle.time %time.between.battles

  var %president.enabled $readini(system.dat, system, EnablePresidentKidnapping)
  if (%president.enabled = $null) { var %president.enabled true }
  if (%president.enabled = true) {
    var %president.chance $rand(1,100)

    var %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
    if ((%current.battlestreak <= 0) || (%current.battlestreak = $null)) { var %current.battlestreak 1 }
    if (%current.battlestreak < 20) { var %president.chance 9999999999999 }
    if ($shopnpc.present.check(AlliedForcesPresident) != kidnapped) { var %president.chance 9999999999999 }

    if (%president.chance <= 25) { var %president.flag boss savethepresident }
  }

  if (%newbattle.time = $null) { set %newbattle.time 120 }

  if (%president.flag = boss savethepresident) { $display.message($readini(translation.dat, Battle, StartBattlePresident), global) }
  else {  $display.message($readini(translation.dat, Battle, StartBattle), global)  }


  if ($readini(system.dat, system, automatedaibattlecasino) = on) {  /.timerBattleStart 0 %newbattle.time /startnormal ai }
  else {  /.timerBattleStart 0 %newbattle.time /startnormal %president.flag }

  unset %newbattle.time
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if someone
; has entered the max # of
; controlled chars into battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
access.enter.limit.check {
  ; $1 = the person we're checking
  var %controlled.chars.entered $readini($txtfile(battle2.txt), BattleInfo, Entered. $+ $1)

  if (%controlled.chars.entered = $null) { var %controlled.chars.entered 0 }
  inc %controlled.chars.entered 1

  if (%controlled.chars.entered > 2) { $display.message($readini(translation.dat, errors, MaxAccessEnteredBattle), private) | halt }

  writeini $txtfile(battle2.txt) BattleInfo Entered. $+ $1 %controlled.chars.entered
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A timer runs this every 5
; minutes. This will restart 
; the bot if it stalls.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system.autobattle.timercheck {
  if (%battleisopen = on) { return }
  if (%battleis = on) { return }
  if ($readini(system.dat, system, automatedbattlesystem) = off) { return }

  var %battlestart.timer.secs $timer(battlestart).secs
  if (%battlestart.timer.secs = $null) { $clear_battle }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for illegal 
; characters/commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if a char
; exists
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkchar {
  var %check $readini($char($1), Stuff, ShopLevel)
  if (%check = $null) { $display.message($readini(translation.dat, errors, NotInDataBank), private) | halt }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if the char
; has control over the second char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
controlcommand.check {
  var %player.access.list $readini($char($2), access, list)
  if (%player.access.list = $null) { writeini $char($2) access list $2 | var %player.access.list $2 }
  if ($istok(%player.access.list,$1,46) = $false) { $display.message($readini(translation.dat, errors, DoNotHaveAccessToThatChar), private) | halt }

  if ($readini($char($2), info, clone) = yes) {
    var %clone.owner $readini($char($2), info, cloneowner)
    var %style.equipped $readini($char(%clone.owner), styles, equipped)
    if (%style.equipped != doppelganger) { $set_chr_name(%clone.owner) | $display.message($readini(translation.dat, errors, MustUseDoppelgangerStyleToControl), private) | halt }
  }

  if ($readini($char($2), info, summon) = yes) {
    var %owner $readini($char($2), info, owner)
    var %style.equipped $readini($char(%owner), styles, equipped)
    if (%style.equipped != beastmaster) {  $set_chr_name(%owner) | $display.message($readini(translation.dat, errors, MustUseBeastmasterStyleToControl), private) | halt }
  }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Paths
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
char { return " $+ $mircdir $+ %player_folder $+ $1 $+ .char" }
boss { return " $+ $mircdir $+ %boss_folder $+ $1 $+ .char" } 
mon { return " $+ $mircdir $+ %monster_folder $+ $1 $+ .char" }
npc { return " $+ $mircdir $+ %npc_folder $+ $1 $+ .char" }
summon { return " $+ $mircdir $+ %summon_folder $+ $1 $+ .char" } 
zapped { return " $+ $mircdir $+ %player_folder $+ zapped $+ \ $+ $1 $+ .char" }
lstfile { return " $+ $mircdir $+ lsts\ $+ $1" }
txtfile {  return " $+ $mircdir $+ txts\ $+ $1" }
dbfile { return " $+ $mircdir $+ dbs\ $+ $1" }
dungeonfile { return " $+ $mircdir $+ dungeons\ $+ $1 $+ .dungeon $+ " }
char_path { return " $+ $mircdir $+ %player_folder $+ " }
mon_path { return " $+ $mircdir $+ %monster_folder $+ " }
boss_path { return " $+ $mircdir $+ %boss_folder $+ " }
npc_path { return " $+ $mircdir $+ %npc_folder $+ " }
zap_path { return " $+ $mircdir $+ %player_folder $+ %zapped_folder $+ " }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Password aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
password { set %password $readini($char($1), n, Info, Password) }
passhurt { set %passhurt $readini($char($1), Info, Passhurt) | return }
clr_passhurt { writeini $char($1) Info Passhurt 0 | unset %passhurt | return }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the char's user level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
userlevel { set %userlevel $readini($char($1), Info, user) | return }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns enemy's name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enemy { return %enemy }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the name of the
; currency (red orbs)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
currency {
  var %currency $readini(system.dat, system, currency)
  if (%currency = $null) { return Red Orbs }
  else { return %currency }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds info for shop NPC
; checks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

      var %temp.totallostsouls $readini($char(%name), stuff, LostSoulsKilled)
      if (%temp.totallostsouls = $null) { var %temp.totallostsouls 0 }
      inc %player.totallostsouls %temp.totallostsouls

      var %temp.itemssold $readini($char(%name), Stuff, ItemsSold)
      if (%temp.itemssold = $null) { var %temp.itemssold 0 }
      inc %player.itemssold %temp.itemssold

      var %temp.enhancementpoints.spent $readini($char(%name), stuff, EnhancementPointsSpent) 
      if (%temp.enhancementpoints.spent = $null) { var %temp.enhancementpoints.spent 0 }
      inc %player.enhancementpointsspent %temp.enhancementpoints.spent 

    }    
  }

  unset %file | unset %name
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the combined total
; of all player's death counts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the combined total
; of all player's shop levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the total number
; of battles that players
; have participated in.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the total average
; player levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
total.player.averagelevel {
  var %player.totallevels 0

  var %value 1 | var %total.players 0
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { inc %value 1 }
    else { 
      var %temp.playerlevel $get.level(%name)
      inc %player.totallevels %temp.playerlevel 
      inc %total.players 1
      inc %value 1
    }
  }
  unset %file | unset %name
  return $round($calc(%player.totallevels / %total.players),0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true/false if 
; the bot is allowing colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
allowcolors {
  if ($readini(system.dat, system, AllowColors) = false) { return false }
  return true
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true/false if 
; the bot is allowing bold
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
allowbold {
  if ($readini(system.dat, system, AllowBold) = false) { return false }
  return true
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aliases that display
; messages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display.message {
  ; $1 = the message
  ; $2 = is a flag for the DCCchat option to determine where it sends the message

  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan %message.to.display  }
  if ($readini(system.dat, system, botType) = TWITCH) {
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { 
    if ((%battle.type = ai) && ($2 = battle)) { $dcc.global.message(%message.to.display) | return } 

    if ($2 = private) { $dcc.private.message($nick, %message.to.display) }
    if ($2 = battle) { $dcc.battle.message(%message.to.display) }
    if ($2 = $null) { $dcc.global.message(%message.to.display) }
    if ($2 = global) { $dcc.global.message(%message.to.display) }
  }
}
display.message.delay {
  ; $1 = the message
  ; $2 = is a flag for the DCCchat option to determine where it sends the message
  ; $3 = delay

  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  var %delay.time $3
  if (%delay.time = $null) { var %delay.time 1 }

  if ($readini(system.dat, system, botType) = IRC) { 
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %delay.time /query %battlechan %message.to.display
  }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %delay.time %twitch.delay
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %delay.time /query %battlechan %message.to.display
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
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 1 /.msg $nick %message.to.display
  }
  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, %message.to.display) }
}
display.private.message2 {
  var %message.to.display $2-

  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 1 /.msg $1 %message.to.display 
  }
  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($1, %message.to.display) }
}
display.private.message.delay {
  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 2 /.msg $nick %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, %message.to.display) }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %twitch.delay 1 
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
}
display.private.message.delay.custom {
  var %message.to.display $1

  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 $2 /.msg $nick %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, %message.to.display) }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %twitch.delay $2
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the status line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status_message_check { 
  if (%all_status = $null) { %all_status = 4 $+ $1- | return }
  else { %all_status = 4 $+ %all_status $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the skills line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
skills_message_check { 
  if (%all_skills = $null) { %all_skills = 4 $+ $1- | return }
  else { %all_skills = 4 $+ %all_skills $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !id aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
idcheck { 
  if ($readini($char($1), info, flag) != $null) { $display.private.message($readini(translation.dat, errors, Can'tLogIntoThisChar)) | halt }
  if ($readini($char($1), info, banned) = yes) {  $display.private.message(4This character has been banned and cannot be used to log in.) | halt }
  $passhurt($1) | $password($1)
  if (%password = $null) { unset %passhurt | unset %password |  $display.private.message($readini(translation.dat, errors, NeedToMakeACharacter)) | halt }
  if ($2 = $null) { halt }
  else { 
    var %encode.type $readini($char($1), info, PasswordType)
    if (%encode.type = $null) { var %encode.type encode }
    if (%encode.type = encode) { 
      if ($encode($2) == %password) { 
        if ($version < 6.3) { writeini $char($1) info PasswordType encode }
        else { writeini $char($1) info PasswordType hash |  writeini $char($1) info password $sha1($2) }
        $id_login($1) | unset %password | return 
      } 
      if ($encode($2) != %password)  { 
        if ((%passhurt = $null) || (%passhurt < 3)) {  $display.private.message2($1, $readini(translation.dat, errors, WrongPassword2)) | inc %passhurt 1 | writeini $char($1) info passhurt %passhurt | unset %password | unset %passhurt | halt }
        else { kick %battlechan $1 $readini(translation.dat, errors, TooManyWrongPass)  | unset %passhurt | unset %password | writeini $char($1) Info passhurt 0 | halt } 
      }
    }
    if (%encode.type = hash) {
      if ($sha1($2) == %password) { $id_login($1) | unset %password | return } 
      if ($sha1($2) != %password) { 
        if ((%passhurt = $null) || (%passhurt < 3)) {  $display.private.message2($1, $readini(translation.dat, errors, WrongPassword2)) | inc %passhurt 1 | writeini $char($1) info passhurt %passhurt | unset %password | unset %passhurt | halt }
        else { kick %battlechan $1 $readini(translation.dat, errors, TooManyWrongPass)  | unset %passhurt | unset %password | writeini $char($1) Info passhurt 0 | halt } 
      }
    }
  }
}
id_login {
  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$1, 46) = $true) { 
    var %bot.owner $gettok(%bot.owners, 1, 46)
    if ($nick = %bot.owner) { .auser 100 $nick }
    else { .auser 50 $nick }

    if ($readini(system.dat, system, botType) = DCCchat) { 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }
  else { 
    if ($readini(system.dat, system, botType) = IRC) { .auser 3 $1 }
    if ($readini(system.dat, system, botType) = TWITCH) { .auser 3 $1 }
    if ($readini(system.dat, system, botType) = DCCchat) { .auser 2 $1 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }

  $loginpoints($1,add)
  writeini $char($1) Info LastSeen $fulldate
  writeini $char($1) info passhurt 0 
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Capacity Points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
capacitypoints {
  var %capacitypoints $readini($char($1), stuff, CapacityPoints)
  if (%capacitypoints = $null) { return 0 }
  else { return %capacitypoints }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enhancement Points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enhancementpoints {
  var %enhancementpoints $readini($char($1), stuff, enhancementPoints)
  if (%enhancementpoints = $null) { return 0 }
  else { return %enhancementpoints }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Login Points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loginpoints {
  if ($2 = add) {
    var %char.lastseen $readini($char($1), info, lastloginpoint)
    if (%char.lastseen = $null) { var %char.lastseen 0 } 

    if ($calc($ctime - %char.lastseen) >= 86400) {
      var %current.loginpoints $readini($char($1), stuff, LoginPoints)
      if (%current.loginpoints = $null) { var %current.loginpoints 0 }
      inc %current.loginpoints 10
      writeini $char($1) stuff LoginPoints %current.loginpoints
      writeini $char($1) info lastloginpoint $ctime 
    }
  }


  if ($2 = check) {
    var %player.loginpoints $readini($char($1), stuff, LoginPoints)
    if (%player.loginpoints = $null) { return 0 }
    else { return %player.loginpoints }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays the Description Set
; message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
okdesc { 
  $display.private.message2($1,$readini(translation.dat, system,OKDesc)) 
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sets the stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
battle_stats { set %str $readini($char($1), Battle, Str) | set %def $readini($char($1), Battle, Def) | set %int $readini($char($1), Battle, int) | set %spd $readini($char($1), Battle, spd) | return }  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Battle HP list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
build_battlehp_list {
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
    else { 
      $set_chr_name(%who.battle) | $hp_status_hpcommand(%who.battle) 
      var %hp.to.add  3 $+ $chr(91) $+  $+ %who.battle $+ :  %hstats $+ 3 $+ $chr(93) 
      %battle.hp.list = $addtok(%battle.hp.list,%hp.to.add,46) 
      inc %battletxt.current.line
    }
  }

  if ($chr(046) isin %battle.hp.list) { 
    %battle.hp.list = $replace(%battle.hp.list, $chr(046), $chr(032))
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Battle Style list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
build_battlestyle_list {
  unset %battle.style.list

  ; Generate the style ordering
  $generate_style_order(BattleStyle)

  ; Put together the list
  var %number.of.people $numtok(%battle.style.order, 46)
  var %current.person 1
  while (%current.person <= %number.of.people) {
    var %person.name $gettok(%battle.style.order,%current.person,46)
    if ($readini($char(%person.name), info, flag) != monster) {
      $calculate.stylepoints(%person.name)
      var %style.to.add  3 $+ %person.name $+ :  %style.rating
      %battle.style.list = $addtok(%battle.style.list, %style.to.add, 46) 
      unset %style.rating
    }

    inc %current.person
  }

  if ($chr(046) isin %battle.style.list) { set %replacechar $chr(044) $chr(032)
    %battle.style.list = $replace(%battle.style.list, $chr(046), %replacechar)
    unset %replacechar
  }
  unset %battle.style.order

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the equipped weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
weapon_equipped { 
  if ($person_in_mech($1) = false) {  
    set %weapon.equipped.right $readini($char($1), Weapons, Equipped) 
    set %weapon.equipped.left $readini($char($1), Weapons, EquippedLeft)
    set %weapon.equipped $readini($char($1), weapons, equipped)
  }
  if ($person_in_mech($1) = true) { set %weapon.equipped $readini($char($1), mech, EquippedWeapon) } 
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for a linked weapon
; returns true or false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
weapon.linkcheck {
  ; $1 = person 
  ; $2 = weapon to check for

  if (($readini($char($1), Weapons,Equipped) = $2) || ($readini($char($1), Weapons, EquippedLeft) = $2)) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the  weapon list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        var %weapon.color 3
        if (+1 isin %weapon.name) { var %weapon.color 12 }
        if ($readini($dbfile(weapons.db), %weapon.name, Legendary) = true) { var %weapon.color 7 }

        var %weapon_to_add  $+ %weapon.color $+ %weapon.name $+ 3 $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Shield list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        var %shield.name $equipment.color(%shield.name) $+ %shield.name $+ 3
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Styles list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the NPC Trusts list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trusts.list {
  unset %trust.items.list
  set %trust.items.list $trusts.get.list($1)

  if ($1 = return) { return %trust.items.list }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %trust.items.list = $replace(%trust.items.list, $chr(046), %replacechar)

  unset %value | unset %replacechar

  return
}
trusts.get.list {
  ; CHECKING TRUST ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_trust.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_trust.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {  %trust.items.list = $addtok(%trust.items.list, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46)  }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  unset %item.name | unset %item_amount

  return %trust.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Ingredients list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ingredients.list {
  unset %ingredients.items.list
  set %ingredients.items.list $ingredients.get.list($1)

  if ($1 = return) { return %ingredients.items.list }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %ingredients.items.list = $replace(%ingredients.items.list, $chr(046), %replacechar)

  unset %value | unset %replacechar

  return
}
ingredients.get.list {
  ; CHECKING POTION INGREDIENT ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_potioningredient.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_potioningredient.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {  %ingredients.items.list = $addtok(%ingredients.items.list, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46)  }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  unset %item.name | unset %item_amount

  return %ingredients.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Songs list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Ignitions list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Tech list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tech.list {
  unset %techs.list | unset %tech.list
  set %techs.list $techs.get.list($1, $2)

  if ($person_in_mech($1) = true) { 
    set %replacechar $chr(044) $chr(032)
    %techs.list = $replace(%techs.list, $chr(046), %replacechar)
    unset %replacechar
    return 
  }

  if (%weapon.equipped.left != $null) { 
    var %techs.list.left $techs.get.list($1, %weapon.equipped.left)

    if (%techs.list.left = $null) { goto cleantechs }
    var %tech.position 1 
    while (%tech.position <= $numtok(%techs.list.left,46)) {
      var %tech.name $gettok(%techs.list.left,%tech.position,46)
      %techs.list = $addtok(%techs.list, %tech.name, 46) 
      inc %tech.position
    }
  }

  :cleantechs
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
      if (%battle.type = ai) {  var %tech_to_add %tech.name | inc %tech.count 1 | inc %tech.power $readini($dbfile(techniques.db), %tech.name, basepower) }
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

techs.count {
  $weapon_equipped($1) 
  set %techs.list $techs.get.list($1, %weapon.equipped)
  var %techs.list.left $techs.get.list($1, %weapon.equipped.left)
  return $numtok(%techs.list, 46)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Skills list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Portal Item list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portals.list {
  unset %portals.items.*
  var %value 1 | var %items.lines $lines($lstfile(items_portal.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_portal.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%portals.items.list,46) <= 15) { %portals.items.list = $addtok(%portals.items.list, 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { 
        if ($numtok(%portals.items.list2,46) <= 15) { %portals.items.list2 = $addtok(%portals.items.list2, 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
        else { %portals.items.list3 = $addtok(%portals.items.list3, 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      }
    }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  var %replacechar $chr(044) $chr(032)
  %portals.items.list = $replace(%portals.items.list, $chr(046), %replacechar)
  %portals.items.list2 = $replace(%portals.items.list2, $chr(046), %replacechar)
  %portals.items.list3 = $replace(%portals.items.list3, $chr(046), %replacechar)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Trading Card Item list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tradingcards.list {
  unset %tradingcards.items.*
  var %value 1 | var %items.lines $lines($lstfile(items_tradingcards.lst)) | var %card.collection 0

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_tradingcards.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      inc %card.collection 1
      if ($numtok(%tradingcards.items.list,46) <= 15) { %tradingcards.items.list = $addtok(%tradingcards.items.list, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { 
        if ($numtok(%tradingcards.items.list2,46) <= 15) { %tradingcards.items.list2 = $addtok(%tradingcards.items.list2, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
        else { %tradingcards.items.list3 = $addtok(%tradingcards.items.list3, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      }
    }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  var %replacechar $chr(044) $chr(032)
  %tradingcards.items.list = $replace(%tradingcards.items.list, $chr(046), %replacechar)
  %tradingcards.items.list2 = $replace(%tradingcards.items.list2, $chr(046), %replacechar)
  %tradingcards.items.list3 = $replace(%tradingcards.items.list3, $chr(046), %replacechar)


  if (%card.collection >= 30) { 
    ;  $achievement_check($1, GottaCollectThemAll)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Keys list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
keys.list {
  unset %keys.items.list | unset %dungeon.keys.items.list

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

  ; CHECKING DUNGEON KEYS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %value 1 | var %items.lines $lines($lstfile(items_dungeonkeys.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_dungeonkeys.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      %dungeon.keys.items.list = $addtok(%dungeon.keys.items.list, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) 
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  if ($chr(046) isin %keys.items.list) { set %replacechar $chr(044) $chr(032) | %keys.items.list = $replace(%keys.items.list, $chr(046), %replacechar)  }
  if ($chr(046) isin %dungeon.keys.items.list) { set %replacechar $chr(044) $chr(032) | %dungeon.keys.items.list = $replace(%dungeon.keys.items.list, $chr(046), %replacechar)  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Gems list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gems.list {
  unset %gems.items.list  

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Seal list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
seals.list {
  unset %seals.items.list

  ; CHECKING SEALS
  var %value 1 | var %items.lines $lines($lstfile(items_seals.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_seals.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %seals.items.list = $addtok(%seals.items.list, %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  if ($chr(046) isin %seals.items.list) { set %replacechar $chr(044) $chr(032)
    %seals.items.list = $replace(%seals.items.list, $chr(046), %replacechar)
  }

  unset %replacechar
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Items list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
items.list {
  unset %*.items.lis* | unset %items.lis*

  ; CHECKING HEALING ITEMS
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

    var %item.color 4
    if ($readini($dbfile(items.db), %item.name, TormentReward) = true) { var %item.color 7 }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%items.list,46) <= 20) { %items.list = $addtok(%items.list, %item.color $+ %item.name $+ 4 $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %items.list2 = $addtok(%items.list2, %item.color $+ %item.name $+ 4 $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
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

  ; Check for summon items
  $summonitems.list($1)

  ; Check for mech cores
  $items.mechcore($1)

  ; Check for special items
  $specialitems.list($1)

  ; Check for portal items
  $portals.list($1) 

  ; Check for trust items
  $trusts.list($1)

  ; Check for potion ingredient items
  $potioningredient.list($1)

  ; Check for misc items
  $miscitems.list($1)

  ; Check for keys
  $keys.list($1) 

  ; Check for gems
  $gems.list($1)

  ; CLEAN UP THE LISTS
  var %replacechar $chr(044) $chr(032)
  %items.list = $replace(%items.list, $chr(046), %replacechar)
  %items.list2 = $replace(%items.list2, $chr(046), %replacechar)
  %reset.items.list = $replace(%reset.items.list, $chr(046), %replacechar)
  %statplus.items.list = $replace(%statplus.items.list, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %food.items | unset %consume.items
  unset %replacechar
  return
}

summonitems.list {
  ; CHECKING SUMMON ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_summons.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_summons.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 

      if ($numtok(%summons.items.list,46) <= 15) { %summons.items.list = $addtok(%summons.items.list, 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { 
        if ($numtok(%summons.items.list2,46) <= 15) { %summons.items.list2 = $addtok(%summons.items.list2, 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
        else { 
          if ($numtok(%summons.items.list3,46) <= 15) { %summons.items.list3 = $addtok(%summons.items.list3, 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
          else { 
            if ($numtok(%summons.items.list4,46) <= 15) { %summons.items.list4 = $addtok(%summons.items.list4, 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
            else { %summons.items.list5 = $addtok(%summons.items.list5, 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
          } 
        }
      }

    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  var %replacechar $chr(044) $chr(032)
  %summons.items.list = $replace(%summons.items.list, $chr(046), %replacechar)
  %summons.items.list2 = $replace(%summons.items.list2, $chr(046), %replacechar)
  %summons.items.list3 = $replace(%summons.items.list3, $chr(046), %replacechar)
  %summons.items.list4 = $replace(%summons.items.list4, $chr(046), %replacechar)
}
specialitems.list {
  ; CHECKING SPECIAL ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_special.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_special.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 

      if ($numtok(%special.items.list,46) <= 12) { %special.items.list = $addtok(%special.items.list, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { %special.items.list2 = $addtok(%special.items.list2, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
    }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  var %replacechar $chr(044) $chr(032)
  %special.items.list = $replace(%special.items.list, $chr(046), %replacechar)
  %special.items.list2 = $replace(%special.items.list2, $chr(046), %replacechar)
}

potioningredient.list {
  ; CHECKING POTION INGREDIENT ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_potioningredient.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_potioningredient.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {  %potioningredient.items.list = $addtok(%potioningredient.items.list, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46)  }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  unset %item.name | unset %item_amount

  var %replacechar $chr(044) $chr(032)
  %potioningredient.items.list = $replace(%potioningredient.items.list, $chr(046), %replacechar)

  return
}

miscitems.list {

  ; CHECKING MISC ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_misc.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_misc.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    var %item.color 5
    if ($readini($dbfile(items.db), %item.name, TormentReward) = true) { var %item.color 7 }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%misc.items.list,46) <= 15) { %misc.items.list = $addtok(%misc.items.list, %item.color $+ %item.name $+ 5 $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
      else { 
        if ($numtok(%misc.items.list2,46) <= 15) { %misc.items.list2 = $addtok(%misc.items.list2, %item.color $+ %item.name $+ 5 $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
        else { 
          if ($numtok(%misc.items.list3,46) <= 15) { %misc.items.list3 = $addtok(%misc.items.list3, %item.color $+ %item.name $+ 5 $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
          else { 
            if ($numtok(%misc.items.list4,46) <= 15) { %misc.items.list4 = $addtok(%misc.items.list4, %item.color $+ %item.name $+ 5 $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
            else { %misc.items.list5 = $addtok(%misc.items.list5, %item.color $+ %item.name $+ 5 $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }
          } 
        }
      }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  var %replacechar $chr(044) $chr(032)

  %misc.items.list = $replace(%misc.items.list, $chr(046), %replacechar)
  %misc.items.list2 = $replace(%misc.items.list2, $chr(046), %replacechar)
  %misc.items.list3 = $replace(%misc.items.list3, $chr(046), %replacechar)
  %misc.items.list4 = $replace(%misc.items.list4, $chr(046), %replacechar)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Instrument list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Mech Core list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Armor list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
armor.list {
  unset %armor.*
  var %number.of.ini.items $ini($char($1), item_amount, 0)

  var %current.ini.item.num 1 | var %replacechar $chr(044) $chr(032)
  while (%current.ini.item.num <= %number.of.ini.items) { 

    ; get item name
    var %current.ini.item $ini($char($1), item_amount, %current.ini.item.num)
    var %current.ini.value $readini($char($1), np, item_amount, %current.ini.item)
    if (%current.ini.value = 0) { remini $char($1) item_amount %current.ini.item | dec %current.ini.item.num 1 }
    else {
      var %item.type $readini($dbfile(equipment.db), %current.ini.item, EquipLocation)
      if (%item.type != $null) { 

        inc % [ $+ token.count. $+ [ %item.type ] ] 1

        var %armor.name %current.ini.item
        var %armor.level $readini($dbfile(equipment.db), %armor.name, LevelRequirement)
        if (%armor.level = $null) { var %armor.level 0 }

        if (+1 isin %armor.name) { var %armor.name 12 $+ %armor.name $+ 3 }
        if (+2 isin %armor.name) { var %armor.name 6 $+ %armor.name $+ 3 }
        if ($readini($dbfile(equipment.db), %armor.name, Legendary) = true) { var %armor.name 7 $+ %armor.name $+ 3 }


        if (%armor.level > $get.level($1)) { var %armor.name 4 $+ %current.ini.item $+ 3 }

        if (% [ $+ token.count. $+ [ %item.type ] ] <= 20) { 
          % [ $+ armor. $+ [ %item.type ] ] = $addtok(% [ $+ armor. $+ [ %item.type ] ] , %armor.name $+ $chr(040) $+ %current.ini.value $+ $chr(041),46) 
          % [ $+ armor. $+ [ %item.type ] ] = $replace(% [ $+ armor. $+ [ %item.type ] ] , $chr(046), %replacechar)
        }

        if ((% [ $+ token.count. $+ [ %item.type ] ] > 20) && (% [ $+ token.count. $+ [ %item.type ] ] <= 40)) { 
          % [ $+ armor. $+ [ %item.type ]  $+ 2 ] = $addtok(% [ $+ armor. $+ [ %item.type ]  $+ 2 ], %armor.name $+ $chr(040) $+ %current.ini.value $+ $chr(041),46) 
          % [ $+ armor. $+ [ %item.type ]  $+ 2 ] = $replace(% [ $+ armor. $+ [ %item.type ]  $+ 2 ] , $chr(046), %replacechar)
        }

        if ((% [ $+ token.count. $+ [ %item.type ] ] > 40) && (% [ $+ token.count. $+ [ %item.type ] ] <= 60)) {
          % [ $+ armor. $+ [ %item.type ]  $+ 3 ] = $addtok(% [ $+ armor. $+ [ %item.type ]  $+ 3 ], %armor.name $+ $chr(040) $+ %current.ini.value $+ $chr(041),46) 
          % [ $+ armor. $+ [ %item.type ]  $+ 3 ] = $replace(% [ $+ armor. $+ [ %item.type ]  $+ 3 ] , $chr(046), %replacechar)
        }

        if ((% [ $+ token.count. $+ [ %item.type ] ] > 60) && (% [ $+ token.count. $+ [ %item.type ] ] <= 80)) { 
          % [ $+ armor. $+ [ %item.type ]  $+ 4 ] = $addtok(% [ $+ armor. $+ [ %item.type ]  $+ 4 ], %armor.name $+ $chr(040) $+ %current.ini.value $+ $chr(041),46) 
          % [ $+ armor. $+ [ %item.type ]  $+ 4 ] = $replace(% [ $+ armor. $+ [ %item.type ]  $+ 4 ] , $chr(046), %replacechar)
        }

        if ((% [ $+ token.count. $+ [ %item.type ] ] > 80) && (% [ $+ token.count. $+ [ %item.type ] ] <= 100)) { 
          % [ $+ armor. $+ [ %item.type ]  $+ 5 ] = $addtok(% [ $+ armor. $+ [ %item.type ]  $+ 5 ], %armor.name $+ $chr(040) $+ %current.ini.value $+ $chr(041),46) 
          % [ $+ armor. $+ [ %item.type ]  $+ 5 ] = $replace(% [ $+ armor. $+ [ %item.type ]  $+ 5 ] , $chr(046), %replacechar)
        }

        if ((% [ $+ token.count. $+ [ %item.type ] ] > 100) && (% [ $+ token.count. $+ [ %item.type ] ] <= 120)) { 
          % [ $+ armor. $+ [ %item.type ]  $+ 6 ] = $addtok(% [ $+ armor. $+ [ %item.type ]  $+ 6 ], %armor.name $+ $chr(040) $+ %current.ini.value $+ $chr(041),46) 
          % [ $+ armor. $+ [ %item.type ]  $+ 6 ] = $replace(% [ $+ armor. $+ [ %item.type ]  $+ 6 ] , $chr(046), %replacechar)
        }

      }
    }
    inc %current.ini.item.num 1
  }

  unset %token.count*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Accessory list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
accessories.list {
  ; CHECKING ACCESSORIE
  unset %accessories.list | unset %accessories.list2 | unset %accessories.list3 | unset %accessories.have

  var %value 1 | var %items.lines $lines($lstfile(items_accessories.lst)) | var %accessories.have 0

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_accessories.lst)

    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      inc %accessories.have 1

      var %item.name $equipment.color(%item.name) $+  $+ %item.name $+ 3

      if (%accessories.have <= 16) {  %accessories.list = $addtok(%accessories.list, %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) $+ , 46) }
      if ((%accessories.have > 16) && (%accessories.have <= 32)) { %accessories.list2 = $addtok(%accessories.list2, %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) $+ , 46) }
      if (%accessories.have > 32) {  %accessories.list3 = $addtok(%accessories.list3, %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) $+ , 46) }

    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %accessories.list = $replace(%accessories.list, $chr(046), %replacechar)
  %accessories.list2 = $replace(%accessories.list2, $chr(046), %replacechar)
  %accessories.list3 = $replace(%accessories.list3, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Runes list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
runes.list {
  ; CHECKING RUNES
  var %value 1 | var %items.lines $lines($lstfile(items_runes.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_runes.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %runes.list = $addtok(%runes.list, 7 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
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
  if ($2 = clearSotH) { remini $char($1) status SpiritOfHero }
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

  if (($return.potioneffect($1) = Double Life) && (%players.must.die.mode != true)) {
    var %current.hp $readini($char($1), basestats, hp)
    var %current.hp $round($calc(%current.hp * 2),0)
    writeini $char($1) battle hp %current.hp
    writeini $char($1) status PotionEffect none
  }

  if (($return.potioneffect($1) = Double Life) && (%players.must.die.mode = true)) {
    var %current.hp $readini($char($1), battle, hp)
    var %current.hp $round($calc(%current.hp * 2),0)
    writeini $char($1) battle hp %current.hp
    writeini $char($1) status PotionEffect none
  }

  writeini $char($1) Battle Str $readini($char($1), BaseStats, Str)
  writeini $char($1) Battle Def $readini($char($1), BaseStats, Def)
  writeini $char($1) Battle Int $readini($char($1), BaseStats, Int)
  writeini $char($1) Battle Spd $readini($char($1), BaseStats, Spd)

  ; Check for things that shouldn't be null
  if ($readini($char($1), battle, status) != inactive) {  writeini $char($1) Battle Status alive }
  if ($readini($char($1), status, PotionEffect) = $null) { writeini $char($1) Status PotionEffect none }

  if ($readini($char($1), stuff, alliednotes) = $null) { writeini $char($1) stuff alliednotes 0 }

  if ($readini($char($1), BaseStats, IgnitionGauge) = $null) { writeini $char($1) BaseStats IgnitionGauge 0 | writeini $char($1) Battle IgnitionGauge 0 }
  if ($readini($char($1), Battle, IgnitionGauge) = $null) { writeini $char($1) Battle IgnitionGauge 0 }

  if ($readini($char($1), stuff, TotalDeaths) = $null) { writeini $char($1) stuff TotalDeaths 0 }
  if ($readini($char($1), stuff, TimesFled) = $null) { writeini $char($1) stuff TimesFled 0 }

  ; Clear status
  $clear_status($1)

  ; If it's not a monster or NPC, we need to clear some more stuff and check for $$.
  if ($readini($char($1), info, flag) = $null) { 
    $clear_skills($1) | var %stylelist $styles.get.list($1) 
    .remini $char($1) modifiers
    var %doubledollars $readini($char($1), stuff, doubledollars) 
    if (%doubledollars = $null) { writeini $char($1) stuff doubledollars 100 | var %doubledollars 100 }

    if ($readini($char($1), stuff, loginpoints) = $null) { writeini $char($1) stuff LoginPoints 0 }

    ; If someone is in a mech, take them out
    if ($person_in_mech($1) = true) { writeini $char($1) mech inuse false }
  }

  ; Clear skill timers
  $clear_skill_timers($1)

  ; Remove the Renkei value
  remini $char($1) Renkei

  ; Check on, and fill Natural Armor
  $fullNaturalArmor($1)

  ; Check for the Shenron's Wish buff
  $db.shenronwish.check($1)

  ; We're all done here
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
  if (%lastseen.date = $null) { writeini $char($1) info LastSeen $fulldate | return }
  if (%lastseen.date = N/A) { var %lastseen.date $readini($char($1), info, Created) | writeini $char($1) info LastSeen %lastseen.date }

  var %lastseen.ctime $ctime(%lastseen.date)
  var %ctime.calc.sixmonths 15901200
  var %current.ctime $calc( $ctime($fulldate) - %lastseen.ctime)

  if (%current.ctime > %ctime.calc.sixmonths) { 
    ; It's been greater than six months.  Zap the char.
    echo -a 4 $+ $1 is older than 6 months and is being removed..
    $zap_char($1)
  }

  else { $fulls($1, clearSotH) }

  return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true if a char has
; logged in in the last week
; false if not
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
char.seeninaweek {
  if ($readini($char($1), info, summon) = yes) { return }
  var %lastseen.date $readini($char($1), info, LastSeen)
  if (%lastseen.date = $null) { writeini $char($1) info LastSeen $fulldate | return true }
  if (%lastseen.date = N/A) { var %lastseen.date $readini($char($1), info, Created) | writeini $char($1) info LastSeen %lastseen.date }

  var %lastseen.ctime $ctime(%lastseen.date)
  var %ctime.calc.week 604800
  var %current.ctime $calc( $ctime($fulldate) - %lastseen.ctime)

  if (%current.ctime > %ctime.calc.week) { return false }
  else { return true }
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
  remini $char($1) NaturalArmor
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
  remini $char($1) skills weaponlock.time | remini $char($1) skills PerfectDefense.time | remini $char($1) skills stoneskin.time
  remini $char($1) skills tabularasa.time | remini $char($1) skills sugitekai.time
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
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) Status drunk no 
  writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status zombie no | writeini $char($1) Status slow no 
  writeini $char($1) Status sleep no | writeini $char($1) Status stun no | writeini $char($1) status zombieregenerating no | writeini $char($1) status silence no
  writeini $char($1) status petrified no  | writeini $char($1) status bored no | writeini $char($1) status defensedown no | writeini $char($1) status strengthdown no 
  writeini $char($1) status intdown no | writeini $char($1) status protect no | writeini $char($1) status shell no | writeini $char($1) status speedup no | writeini $char($1) status speedup.timer 0 

  writeini $char($1) status poison.timer 0 | writeini $char($1) status amnesia.timer 0 | writeini $char($1) status paralysis.timer 0 | writeini $char($1) status drunk.timer 0
  writeini $char($1) status curse.timer 0 | writeini $char($1) status slow.timer 0 | writeini $char($1) status zombie.timer 0 | writeini $char($1) status confuse.timer 0 
  writeini $char($1) status defensedown.timer 0 |  writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown.timer 0
  writeini $char($1) status protect.timer 0 | writeini $char($1) status shell.timer 0 | writeini $char($1) status virus.timer 0
}

clear_negative_status {
  ; Note, this doesn't clear charm.
  writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no
  writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no | writeini $char($1) Status intimidated no
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status zombie no
  writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no |  writeini $char($1) status zombieregenerating no | writeini $char($1) status intimidate no 
  writeini $char($1) status defensedown no | writeini $char($1) status strengthdown no | writeini $char($1) status intdown no  |  writeini $char($1) status stop no | writeini $char($1) status petrified no 
  writeini $char($1) status bored no | remini $char($1) status weapon.locked | writeini $char($1) status confuse no 
  remini $char($1) status annoyed

  ; Clear negative timer statuses
  writeini $char($1) status poison.timer 0 |  writeini $char($1) status amnesia.timer 0 | writeini $char($1) status paralysis.timer 0 | writeini $char($1) status drunk.timer 0
  writeini $char($1) status curse.timer 0 | writeini $char($1) status slow.timer 0 | writeini $char($1) status zombie.timer 0
  writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown.timer 0 | writeini $char($1) status defensedown.timer 0
  writeini $char($1) status bored.timer 0 |  writeini $char($1) status confuse.timer 0 | writeini $char($1) status virus.timer 0

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
  writeini $char($1) status defenseup no | writeini $char($1) status defenseup.timer 0
  writeini $char($1) status speedup no | writeini $char($1) status speedup.timer 0

  if ($2 != tech) { writeini $char($1) status ignition.on off | remini $char($1) status ignition.name | remini $char($1) status ignition.augment }

  if ($accessory.check($1, AutoRegen) = true) { writeini $char($1) status auto-regen yes }
  if (($readini($char($1), info, flag) = $null) && ($accessory.check($1, AutoRegen) != true)) { remini $char($1) status auto-regen }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears statuses on chars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_status {
  if ($readini($char($1), status, finalgetsuga) = yes) {
    $reset_char($1) | $set_chr_name($1)
    $display.message(4 $+ %real.name feels all of $gender($1) power leaving $gender($1) body -- resetting $gender2($1) back to level 1.,global) 

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
  writeini $char($1) Status drowning no | writeini $char($1) Status tornado no |  writeini $char($1) Status earthquake no 

  ; The resists are used to resist the magic effect stuff (Freezing, Burning, etc).  Only players need this removed each time.
  if ($readini($char($1), info, flag) = $null) { 
    writeini $char($1) status resist-fire no | writeini $char($1) status resist-lightning no | writeini $char($1) status resist-ice no
    writeini $char($1) status resist-earth no | writeini $char($1) status resist-wind no | writeini $char($1) status resist-water no
    writeini $char($1) status resist-light no | writeini $char($1) status resist-dark no
  }

  if ($readini($char($1), info, flag) = $null) {  writeini $char($1) status ethereal no | writeini $char($1) status reflect no | writeini $char($1) status reflect.timer 0 | writeini $char($1) status invincible no | writeini $char($1) status invincible.timer 0 }
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

  if ($1 = npc) {
    set %monster.info.streak.max $readini($npc($2), info, Streak)
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

  if ($1 = npc) {
    set %monster.info.streak.max $readini($npc($2), info, StreakMax)
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
  if (((($1 = portal) || (%battle.type = defendoutpost) || (%mode.gauntlet != $null) || (%battle.type = assault)))) { set %nosouls true }

  set %current.winning.streak.value $readini(battlestats.dat, battle, WinningStreak) 
  set %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty) | inc %current.winning.streak.value %difficulty
  set %current.month $left($adate, 2)

  if (%battle.type = ai) { set %current.winning.streak.value %ai.battle.level } 

  if (%mode.gauntlet.wave != $null) { inc %current.winning.streak.value %mode.gauntlet.wave }
  if (%portal.bonus = true) { var %current.winning.streak.value 100 }
  if (%battle.type = defendoutpost) { inc %current.winning.streak.value $rand(75,125) }

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
  if (%battle.type = torment) { write $txtfile(temporary_mlist.txt) %name | return }
  if (%battle.type = ai) { 
    if ($readini($mon(%name), info, ai_type) = defender) { return }
    write $txtfile(temporary_mlist.txt) %name | return
  }

  if ((%savethepresident = on) && ($readini($mon(%name), info, IgnorePresident) = true)) { return }

  if ((%battle.type = defendoutpost) || (%battle.type = assault)) { 
    if ($readini($mon(%name), info, MetalDefense) = true) { return }
    if ($readini($mon(%name), info, IgnoreOutpost) = true) { return }
  }

  ; Check the winning streak #..  some monsters won't show up until a certain streak or higher.
  $get_minimum_streak(mon, %name)
  $get_maximum_streak(mon, %name)

  var %monster.month $readini($mon(%name), info, month) 

  if (%monster.month = %current.month) { write $txtfile(temporary_mlist.txt) %name  | inc %value 1 | return }
  if ((%monster.month != $null) && (%monster.month != %current.month)) { return }
  if (%monster.month = $null) { 
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
  if (%battle.type = defendoutpost) { inc %current.winning.streak.value 100 }

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
  if (%battle.type = torment) { write $txtfile(temporary_mlist.txt) %name | return }

  if ((%savethepresident = on) && ($readini($mon(%name), info, IgnorePresident) = true)) { return }

  if ((%battle.type = defendoutpost) || (%battle.type = assault)) { 
    if ($readini($boss(%name), info, MetalDefense) = true) { return }
    if ($readini($boss(%name), info, IgnoreOutpost) = true) { return }
  }

  ; Check the winning streak #..  some monsters won't show up until a certain streak or higher.
  $get_minimum_streak(boss, %name)
  $get_maximum_streak(boss, %name)

  if ($readini($boss(%name), info, month) = %current.month) { write $txtfile(temporary_mlist.txt) %name  | inc %value 1 }
  if ($readini($boss(%name), info, month) != %current.month) { 
    if (%monster.info.streak <= -500) { return }
    if ((%monster.info.streak > -500) || (%monster.info.streak = $null)) {

      if (($readini($boss(%name), info, month) != $null) && ($readini($boss(%name), info, month) != %current.month)) { return }

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
    if ($readini($npc(%name), info, ai_type) = healer) { return }
    if ($readini($npc(%name), info, ai_type) = defender) { return }
  }

  ; Check the winning streak #..  some npcs won't show up until a certain streak or higher.
  $get_minimum_streak(npc, %name)
  $get_maximum_streak(npc, %name)
  if (%monster.info.streak <= -500) { return }
  if ((%monster.info.streak > -500) || (%monster.info.streak = $null)) {

    var %biome $readini($npc(%name), info, biome)
    var %monster.moonphase $readini($npc(%name), info, moonphase)
    var %monster.timeofday $readini($npc(%name), info, TimeOfDay)
    var %current.time.of.day $readini($dbfile(battlefields.db), TimeOfDay, CurrentTimeOfDay)

    if ($return_winningstreak < %monster.info.streak) { return }
    if ($return_winningstreak > %monster.info.streak.max) { return }
    if ((%monster.moonphase != $null) && (%monster.moonphaes != %moon.phase)) { return }
    if ((%biome != $null) && ($istok(%biome,%current.battlefield,46) = $false)) { return }
    if ((%monster.timeofday != $null) && ($istok(%monster.timeofday,%current.time.of.day,46) = $false)) { return }
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
  $clear_variables2 | unset *.level | unset %dragonhunt.* | unset %true.turn
  unset %darkness.turns | unset %holy.aura.turn | unset %mech.power | unset %attacker | unset %item.drop.rewards | unset %tp
  unset %boss.type | unset %portal.bonus | unset %holy.aura | unset %darkness.fivemin.warn  | unset %battle.rage.darkness |  unset %battleconditions |  unset %red.orb.winners |  unset %bloodmoon 
  unset %line | unset %file | unset %name | unset %curbat | unset %real.name | unset %attack.target
  unset %battle.type | unset %number.of.monsters.needed | unset %who |  unset %next.person | unset %status | unset %hstats | unset %baseredorbs | unset %hp.percent
  unset %monster.list | unset %monsters.total | unset %random.monster | unset %monster.name |  unset %ai.* | unset %resist.skill | unset %value | unset %mastery.bonus
  unset %user | unset %enemy | unset %handtohand.wpn.list | unset %sword.wpn.list | unset %monster.wpn.list | unset %base.redorbs | unset %tech.type | unset %whoturn | unset %replacechar | unset %status.battle 
  unset %number.of.hits | unset %timer.time | unset %help.topics3 | unset %skill.name |  unset %skill_level | unset %action | unset %idwho | unset %currentshoplevel | unset %totalplayers
  unset %life.max | unset %passive.skills.list | unset %active.skills.list | unset %reists.skills.list |  unset %items.list | unset %techs.list | unset %tech.name | unset %tech_level | unset %multiplier
  unset %number.of.techs | unset %tech.list |  unset %who.battle | unset %weapon.equipped |  unset %all_skills | unset %all_status | unset %status.message | unset %stylepoints.toremove
  unset %resist.have | unset %bonus.orbs | unset %attack.damage | unset %style.multiplier |  unset %style.rating | unset %file | unset %name | unset %weapon.howmany.hits | unset %element.desc
  unset %monster.to.remove | unset %burning | unset %hp | unset %drowning | unset %weapon.price |  unset %tornado | unset %tech.to.remove | unset %upgrade.list | unset %tech.price | unset %total.price
  unset %skill.price | unset %shop.list.passiveskills | unset %shop.list.activeskills |  unset %skill.list | unset %shop.list.resistanceskills | unset %resists.skills.list | unset %shop.statbonus
  unset %password | unset %passhurt | unset %userlevel | unset %comma_replace | unset %comma_new |  unset %freezing | unset %file | unset %name | unset %inc.shoplevel
  unset %poison.timer | unset %skill.description | unset %item.total | unset %black.orb.winners |  unset %file | unset %name | unset %bosschance | unset %fullbring.check | unset %check.item
  unset %fourhit.attack | unset %weapon.name | unset %shock | unset %skill.max | unset %skill.have |  unset %weapon.list | unset %tp.current | unset %drainsamba.turn | unset %absorb | unset %drainsamba.turns
  unset %drainsamba.turn.max | unset %life.target | unset %drainsamba.on | unset %weapons | unset %techs | unset %number.of.players | unset %keys.items.list
  unset %amount | unset %current.shoplevel | unset %shop.list | unset %battletxt.lines | unset %battletxt.current.lint
  unset %opponent.flag | unset %spell.element | unset %timer.time |   unset %battletxt.currentline | unset %first.round.protection | unset %first.round.protection.turn
  unset %npc.list | unset %random.npc | unset %npc.to.remove | unset %npc.name | unset %double.attack | unset %lastaction.nerf
  unset %shaken | unset %info.fullbringmsg | unset %basepower | unset %fullbring.needed | unset %poison | unset %totalwins
  unset %fullbring.type | unset %fullbring.target | unset %fullbring.status | unset %item.base | unset %timer.time | unset %savethepresident
  unset %real.name | unset %weapon.name | unset %weapon.price | unset %steal.item | unset %skip.ai | unset %file.to.read.lines 
  unset %attacker.spd | unset %playerstyle.* | unset %stylepoints.to.add | unset %current.playerstyle.* | unset %styles | unset %wait.your.turn | unset %weapon.list2
}
clear_variables2 {
  unset %torment.*
  unset %max.demonwall.turns | unset %demonwall.name | unset %styles.list | unset %style.name | unset %style.level | unset %player.style.level | unset %style.price | unset %styles
  unset %weapon.name.used | unset %weapon.used.type | unset %quicksilver.used | unset %upgrade.list2
  unset %upgrade.list3 | unset %statusmessage.display | unset %current.turn | unset %surpriseattack
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
  unset %mech.hp | unset %number.of.monsters | unset %current.monster.to.spawn | unset %total.weapons.owned 
  unset %action.bar | unset %betting.period | unset %winners | unset %multihit.message.on 
  unset %food.type | unset %shop.list2 | unset %shop.list3 | unset %mech.weaponname | unset %mech.techs | unset %ignition.tech.list | unset %stylepoints.current
  unset %mech.weapon.list | unset %fstrike.turns | unset %fstrike.turn.max | unset %ignitions.list  | unset %techincrease.check
  unset %total.summon.items | unset %accessories.list2 | unset %weapon_augment | unset %totalbosss 0 | unset %ignition.description's
  unset %ingredient.to.add | unset %weapons7 | unset %user.gets.second.turn | unset %spd.increase | unset %spd.current 
  unset %temp.damage | unset %cost | unset %current.line | unset %mech.weapon.list2
  unset %weapon.equipped.right | unset unset %weapon.equipped.left | unset %shield.block.line
  unset %original.ignition.name | unset %holy.aura.user | unset %max.hp.restore | unset %max.tp.restore 
  unset %passive.skills.list2 | unset %prize.list | unset %inflict.meleewpn | unset %weapon.list1 | unset %duplicate.ips
  unset %attacker.level | unset %defender.level | unset %damage.display.color | unset %current.playerstyle
  unset %number.of monsters.needed | unset %battle.level.cap | unset %percent.increase
  unset %monster.info.streak.max | unset %monster.info.streak
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zap (erase) a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zap_char {
  set %new.name $1 $+ _ $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z)
  .rename $char($1) $zapped(%new.name)

  if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING $1 :: Reason: Zapped }

  .remove $char($1)
  unset %new.name
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UnZap (restore) a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
unzap_char {
  set %new.name $gettok($1,1,95)
  .rename $zapped($1) $char(%new.name)
  .remove $zapped($1)
  writeini $char(%new.name) info lastseen $fulldate
  $set_chr_name(%new.name) 
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
  var %total.orbs.unspent $readini($char($1), stuff, RedOrbs)
  var %total.orbs.spent $readini($char($1), stuff, RedOrbsSpent)

  var %new.orbs $round($calc((%total.orbs.spent + %total.orbs.unspent)* .10),0)
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

  ; Reset the equipment
  writeini $char($1) equipment accessory none
  writeini $char($1) equipment head none
  writeini $char($1) equipment body none
  writeini $char($1) equipment legs none
  writeini $char($1) equipment feet none
  writeini $char($1) equipment hands none
  remini $char($1) equipment accessory2

  ; Reset the ignitions
  remini $char($1) ignitions

  ; Reset the styles
  remini $char($1) styles
  writeini $char($1) styles Equipped Trickster
  writeini $char($1) styles Trickster 1
  writeini $char($1) styles TricksterXP 0
  writeini $char($1) styles WeaponMaster 1
  writeini $char($1) styles WeaponMasterXP 0
  writeini $char($1) styles Guardian 1
  writeini $char($1) styles GuardianXP 0

  ; Remove the augments
  remini $char($1) augments

  ; Remove all enhancements
  remini $char($1) enhancements

  ; Increase the total number of times this char has reset
  var %number.of.resets $readini($char($1), stuff, NumberOfResets)
  if (%number.of.resets = $null) { var %number.of.resets 0 }
  inc %number.of.resets 1 
  writeini $char($1) stuff NumberOfResets %number.of.resets
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a treasure chest 
; with a random item inside.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
create_treasurechest {

  set %chest.type.random $rand(1,150)
  dec %chest.type.random $treasurehunter.check

  if (%portal.bonus = true) { %chest.type.random = $rand(1,35) }
  if (%battle.type = dungeon) { %chest.type.random = 1 }

  if (%chest.type.random <= 10)  { set %color.chest gold  }
  if ((%chest.type.random > 10) && (%chest.type.random <= 20)) { set %color.chest silver }
  if ((%chest.type.random > 20) && (%chest.type.random <= 35)) { set %color.chest purple }
  if ((%chest.type.random > 35) && (%chest.type.random <= 55)) { set %color.chest orange }
  if ((%chest.type.random > 55) && (%chest.type.random <= 70)) { set %color.chest green }
  if ((%chest.type.random > 70) && (%chest.type.random <= 90)) { set %color.chest blue  }
  if ((%chest.type.random > 90) && (%chest.type.random <= 120)) { set %color.chest brown  }
  if ((%chest.type.random > 120) && (%chest.type.random <= 130)) { set %color.chest black  }
  if (%chest.type.random > 130) { set %color.chest red | set %chest.contents RedOrbs 

    set %chest.amount $return.systemsetting(RedChestBase)
    if (%chest.amount = null) { set %chest.amount $rand(150,700) }

  }

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

  $display.message($readini(translation.dat, system, ChestDrops),global) 

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
    $display.message($readini(translation.dat, system, ChestDestroyed),global) 
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
  if ((%winning.streak >= 1500) && (%winning.streak < 5000)) { var %orb.tier 9 }
  if (%winning.streak >= 5000) { var %orb.tier 10 }

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
  if (%orb.tier = 11) { set %chest.amount $round($calc(%chest.amount * 4.2),0) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gives a random reward
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
give_random_reward {
  if ($readini($txtfile(battle2.txt), battle, bonusitem) != $null) {

    if (((%battle.type = boss) || (%battle.type = dragonhunt) || (%battle.type = dungeon))) { var %reward.chance 100 }
    else { 
      var %reward.chance $rand(1,100)
      inc %reward.chance $treasurehunter.check

      if (%battle.type = mimic) { var %reward.chance 100 }
    }

    if ($left($adate, 2) = 10) { inc %reward.chance 10 }

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

        $display.message($readini(translation.dat, battle, BonusItemWin),battle) 
        remini $txtfile(battle2.txt) battle bonusitem
        writeini $txtfile(battle2.txt) battle MostStylish %item.winner
      }
    }
    unset %boss.item | unset %item.winner
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gives a random key reward
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
  $display.message($readini(translation.dat, Battle, KeyWin),battle) 

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
    var %weapon.name.left.temp $readini($char($1), weapons, equippedLeft)
    set %ignition.augment $readini($char($1), status, ignition.augment) 
    set %weapon.augment $readini($char($1), augments, %weapon.name.temp)
    var %weapon.augment.left $readini($char($1), augments, %weapon.name.left.temp)

    if (%weapon.augment = $null) {  set %weapon.augment $readini($char($1), augments, %weapon.name.temp) }

    set %equipment.head.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, head), augment)
    set %equipment.body.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, body), augment)
    set %equipment.legs.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, legs), augment)
    set %equipment.feet.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, feet), augment)
    set %equipment.hands.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, hands), augment)

    unset %weapon.name.temp
    set %augment.strength 0

    if ($istok(%ignition.augment,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%weapon.augment,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%weapon.augment.left,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.head.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.body.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.legs.augment,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.feet.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.hands.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

    ; check the name of the armor in the character file too. This is mostly used for NPCs and not players, as players can't augment armor
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, head)),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, body)),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, legs)),$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, feet)),$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, hands)),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

    ; If the character is in FinalGetsuga mode, increase the augment strength by 5
    if (($readini($char($1), status, FinalGetsuga) = yes) && ($readini($char($1), info, flag) = $null)) { inc %augment.strength 5 | set %augment.found true }
  }

  var %style.equipped $readini($char($1), styles, equipped)
  if ($istok($readini($dbfile(playerstyles.db), augments, %style.equipped),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

  if ($person_in_mech($1) = true) {
    set %augment.strength 0
    set %augments $readini($char($1), mech, augments)
    if ($istok(%augments,$2,46) = $true) { inc %augment.strength 2 | set %augment.found true }
    unset %augments

    ; check the file itself for the mech weapon/core name in the character's [augments]  Mostly used for NPCs
    var %mech.weapon.equipped $readini($char($1), mech, EquippedWeapon) 
    var %mech.core.equipped $readini($char($1), mech, EquippedCore)

    var %mech.weapon.augments $readini($char($1), augments, %mech.weapon.equipped)
    var %mech.core.augments $readini($char($1), augments, %mech.core.equipped)
    if ($istok(%mech.weapon.augments,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%mech.core.augments,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  }


  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { 
    if ($readinI($char($1), info, flag) = $null) { inc %augment.strength 2 | set %augment.found true }
  }

  if ($return.potioneffect($1) = Augment Bonus) { 
    inc %augment.strength 1 | set %augment.found true
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

  set %accessory.found false | set %accessory.amount 0 

  var %current.accessory $readini($char($1), equipment, accessory) 
  var %accessory.type $readini($dbfile(items.db), %current.accessory, accessoryType)

  if ($istok(%accessory.type,$2,46) = $true) {
    set %accessory.amount $readini($dbfile(items.db), %current.accessory, %accessory.type $+ .amount)

    if (%accessory.amount = $null) { set %accessory.amount 0 }
    var %accessory.found true
  }

  ; Does the player have a secondary accessory slot?  If so, let's check it.
  if ($readini($char($1), enhancements, accessory2) = true) {
    var %current.accessory2 $readini($char($1), equipment, accessory2) 
    var %accessory2.type  $readini($dbfile(items.db), %current.accessory2, accessoryType)

    if ($istok(%accessory2.type,$2,46) = $true) {
      var %accessory.amount2 $readini($dbfile(items.db), %current.accessory2, %accessory.type $+ .amount)
      if (%accessory.amount2 = $null) { var %accessory.amount2 0 }

      inc %accessory.amount %accessory.amount2
      var %accessory.found true
    }
  }

  unset %current.accessory | unset %accessory.type 

  return %accessory.found
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adjusts orbs based on
; the winning streak.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
orb.adjust {
  var %winning.streak $return_winningstreak
  if (%base.redorbs < 1000) { return }

  if (%mode.gauntlet.wave != $null) { inc %winning.streak %mode.gauntlet.wave }      

  var %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
  if (%difficulty != 0) {  inc %winning.streak %difficulty }

  var %orb.tier 1


  if (%portal.bonus = true) {  
    var %winning.streak $readini($txtfile(battle2.txt), BattleInfo, PortalLevel)
    if (%winning.streak = $null) { var %winning.streak 100 }
  }

  if (%battle.type = dungeon) { var %winning.streak $calc(%winning.streak * 10) }
  if ((%battle.type = defendoutpost) || (%battle.type = assault)) { var %winning.streak 100 }
  if (%battle.type = torment) { var %winning.streak $calc(500 * %torment.level) }

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
  if ($return.potioneffect($1) = Orb Bonus) { 
    if (%winning.streak <= 100) { inc %orb.tier 2 }
    else { inc %orb.tier 1 }
    writeini $char($1) status PotionEffect none 
  }

  if (%portal.bonus = true) { inc %orb.tier 2 }
  if (%battle.type = defendoutpost) { inc %orb.tier 1 }
  if (%battle.type = dungeon) { inc %orb.tier 2 }
  if (%battle.type = dragonhunt) { inc %orb.tier 3 }
  if (%battle.type = torment) { inc %orb.tier 2 }

  if ($readini($txtfile(battle2.txt), battleinfo, bountyclaimed) = true) { inc %orb.tier 1 }

  if ($readini($char($1), status, SpiritOfHero) = true) { 
    remini $char($1) status SpiritOfHero
    dec %orb.tier 1
  }

  if ((%moon.phase = Blood Moon) && (%winning.streak > 50)) { inc %orb.tier 1 }

  if (%orb.tier <= -2) { set %base.redorbs $round($calc(500 + (%base.redorbs * .20)),0) }
  if (%orb.tier = -1) { set %base.redorbs $round($calc(1000 + (%base.redorbs * .45)),0) }
  if (%orb.tier = 0) { set %base.redorbs $round($calc(1000 + (%base.redorbs * .50)),0) }
  if (%orb.tier = 1) { return }
  if (%orb.tier = 2) { set %base.redorbs $round($calc(%base.redorbs * 1.65),0) }
  if (%orb.tier = 3) { set %base.redorbs $round($calc(%base.redorbs * 1.755),0) }
  if (%orb.tier = 4) { set %base.redorbs $round($calc(%base.redorbs * 1.812),0) }
  if (%orb.tier = 5) { set %base.redorbs $round($calc(%base.redorbs * 1.898),0) }
  if (%orb.tier = 6) { set %base.redorbs $round($calc(%base.redorbs * 2.390),0) }
  if (%orb.tier = 7) { set %base.redorbs $round($calc(%base.redorbs * 2.55),0) }
  if (%orb.tier = 8) { set %base.redorbs $round($calc(%base.redorbs * 2.98),0) }
  if (%orb.tier = 9) { set %base.redorbs $round($calc(%base.redorbs * 3.25),0) }
  if (%orb.tier = 10) { set %base.redorbs $round($calc(%base.redorbs * 4),0) }
  if (%orb.tier = 11) { set %base.redorbs $round($calc(%base.redorbs * 4.1),0) }
  if (%orb.tier = 12) { set %base.redorbs $round($calc(%base.redorbs * 4.2),0) }

  if (%battle.type = dragonhunt) { set %base.redorbs $round($calc(%base.redorbs * 1.85),0) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds allied notes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
give_alliednotes {
  set %allied.notes $readini($char($1), stuff, alliednotes)
  if (%allied.notes = $null) { set %allied.notes 0 }
  inc %allied.notes $readini($txtfile(battle2.txt), battle, alliednotes)
  writeini $char($1) stuff alliednotes %allied.notes
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Increases the monsterdeaths.lst
; death tally
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Increases monster kills
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inc_monster_kills {
  var %monster.kills $readini($char($1), stuff, MonsterKills)
  if (%monster.kills = $null) { var %monster.kills 0 }
  inc %monster.kills 1 
  writeini $char($1) stuff MonsterKills %monster.kills
  $achievement_check($1, MonsterSlayer)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Increases the character 
; total deaths
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
increase_death_tally {
  if ($readini($char($1), info, flag) = npc) { return }
  var %deaths $readini($char($1), stuff, TotalDeaths)
  if (%deaths = $null) { var %deaths 0 } 
  inc %deaths 1
  writeini $char($1) stuff TotalDeaths %deaths
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for clone/summon
; deaths
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check.clone.death {
  if ($isfile($char($1 $+ _clone)) = $true) { 
    if ($readini($char($1 $+ _clone), battle, status) != dead) { writeini $char($1 $+ _clone) battle status dead | writeini $char($1 $+ _clone) battle hp 0 | $set_chr_name($1 $+ _clone) 
      $display.message(4 $+ %real.name disappears back into $set_chr_name($1) %real.name $+ 's shadow., battle) 
    }
  }
  if ($isfile($char($1 $+ _summon)) = $true) { 
    if ($readini($char($1 $+ _summon), battle, status) != dead) { writeini $char($1 $+ _summon) battle status dead | writeini $char($1 $+ _summon) battle hp 0 | $set_chr_name($1 $+ _summon) 
      $display.message(4 $+ %real.name fades away.,battle) 
    }
  }
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
    if ((%monster.flag = monster) && ($readini($char(%name), battle, hp) <= 0)) { 
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Dead Monster }
      .remove $char(%name) 
    }
    else { return }    
  }
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
  if ($1 = players) { 
    var %conquest.points $readini(battlestats.dat, conquest, ConquestPointsPlayers)
    inc %conquest.points $2
    if (%conquest.points >= 6000) { var %conquest.points 6000 }
    writeini battlestats.dat conquest ConquestPointsPlayers %conquest.points
  }
  if ($1 = monsters) {
    var %conquest.points $readini(battlestats.dat, conquest, ConquestPointsMonsters)
    inc %conquest.points $2
    if (%conquest.points >= 6000) { var %conquest.points 6000 }
    writeini battlestats.dat conquest ConquestPointsMonsters %conquest.points
  }
}

conquest.tally {
  var %current.time $ctime
  var %last.conquest $readini(battlestats.dat, conquest,  LastTally)
  var %time.difference $calc(%current.time - %last.conquest)

  if (%time.difference >= 432000) {
    writeini battlestats.dat conquest LastTally $ctime

    ; Perform the tally
    $display.message($readini(translation.dat, conquest, ConquestTallyTimeToTally), global) 

    ; Get the current conquest points
    var %conquest.points.players $readini(battlestats.dat, conquest, ConquestPointsPlayers)
    var %conquest.points.monsters $readini(battlestats.dat, conquest, ConquestPointsMonsters)

    if (%conquest.points.players = $null) { var %conquest.points.players 0 }
    if (%conquest.points.monsters = $null) { var %conquest.points.monsters 1000 }

    if (%conquest.points.players >= %conquest.points.monsters) { 
      ; Players win 
      writeini battlestats.dat conquest ConquestBonus %conquest.points.players
      writeini battlestats.dat conquest ConquestPreviousWinner Players
      writeini battlestats.dat conquest ConquestPointsPlayers 1 
      writeini battlestats.dat conquest ConquestPointsMonsters 0
      $display.message($readini(translation.dat, conquest, ConquestTallyPlayersWin), global) 
      var %conquest.wins $readini(battlestats.dat, conquest, TotalPlayerWins)
      if (%conquest.wins = $null) { var %conquest.wins 0 }
      inc %conquest.wins 1
      writeini battlestats.dat conquest TotalPlayerWins %conquest.wins
    }

    if (%conquest.points.players < %conquest.points.monsters) { 
      ; Monsters win
      writeini battlestats.dat conquest ConquestBonus 0 
      writeini battlestats.dat conquest ConquestPreviousWinner Monsters

      writeini battlestats.dat conquest ConquestPointsPlayers %conquest.points.players 
      writeini battlestats.dat conquest ConquestPointsMonsters %conquest.points.monsters

      $display.message($readini(translation.dat, conquest, ConquestTallyMonstersWin), global) 
      var %conquest.wins $readini(battlestats.dat, conquest, TotalMonsterWins)
      if (%conquest.wins = $null) { var %conquest.wins 0 }
      inc %conquest.wins 1
      writeini battlestats.dat conquest TotalMonsterWins %conquest.wins
    }
  }
}

conquest.display {
  if (($2 = $null) || ($2 = info)) { 
    var %conquest.points.players $readini(battlestats.dat, conquest, ConquestPointsPlayers)
    var %conquest.points.monsters $readini(battlestats.dat, conquest, ConquestPointsMonsters)

    if (%conquest.points.players >= %conquest.points.monsters) {  $display.message($readini(translation.dat, conquest, ConquestTallyCurrentPlayers), private) }
    else { $display.message($readini(translation.dat, conquest, ConquestTallyCurrentMon), private) }

    var %previous.conquest.winner $readini(battlestats.dat, conquest, ConquestPreviousWinner)
    if (%previous.conquest.winner = players) { $display.message($readini(translation.dat, conquest, ConquestPreviousPlayers), private) }
    if (%previous.conquest.winner = monsters) { $display.message($readini(translation.dat, conquest, ConquestPreviousMon), private) }

    var %last.conquest $readini(battlestats.dat, conquest,  LastTally)
    var %next.conquest $calc(%last.conquest + 432000)

    var %conquest.hours.left $round($calc(((%next.conquest - $ctime) / 60) /60 ),2)

    $display.message($readini(translation.dat, conquest, ConquestPeriodOverIn), private) 
  }

  if ($2 = points) {
    var %conquest.points.players $readini(battlestats.dat, conquest, ConquestPointsPlayers)
    var %conquest.points.monsters $readini(battlestats.dat, conquest, ConquestPointsMonsters)
    $display.message($readini(translation.dat, conquest, ConquestPoints), private) 
  }

  if ($2 = record) {
    var %wins.monsters $readini(battlestats.dat, conquest, TotalMonsterWins)
    var %wins.players $readini(battlestats.dat, conquest, TotalPlayerWins)
    if (%wins.monsters = $null) { var %wins.monsters 0 }
    if (%wins.players = $null) { var %wins.players 0 }
    var %total.wins $calc(%wins.monsters + %wins.players)

    $display.message($readini(translation.dat, conquest, ConquestRecord), private) 
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
  if (%battle.type = ai) { return }
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
  if (%battle.type = ai) { return }
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
      $display.message($readini(translation.dat, Dragonball, ShenronWishOver), battle)
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

  $display.message($readini(translation.dat, Dragonball, DragonballFound), battle)

  if (%dbs.total < 7) { writeini battlestats.dat dragonballs DragonBallsFound %dbs.total }
  if (%dbs.total >= 7) { 
    writeini battlestats.dat dragonballs DragonBallsFound 0
    writeini battlestats.dat dragonballs DragonballsActive no
    writeini battlestats.dat dragonballs ShenronWish on
    writeini battlestats.dat dragonballs ShenronWish.rounds 1
    $display.message($readini(translation.dat, Dragonball, ShenronSummoned), battle)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display the # of DBs found
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db.display {
  var %dbs.total $readini(battlestats.dat, dragonballs, DragonBallsFound)
  if ($readini(battlestats.dat, dragonballs, ShenronWish) != on) { $display.message($readini(translation.dat, Dragonball, DragonballCheck), private) }
  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { $display.message($readini(translation.dat, Dragonball, ShenronWishOnMessage), private) }
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

  ; Prevent armos statues from ending the battle prematurely
  writeini $char(%monsterfile) battle status normal

  ; Get the levels and calculate the most likely to win the battle
  var %monster.level $get.level(%monsterfile)
  var %npc.level $get.level(%npcfile)

  ; Get their techs & ignitions
  unset %techs.list | unset %weapon.equipped

  var %total.npc.techs $techs.count(%npcfile)
  var %ignitions $ignitions.get.list(%npcfile) 

  if (%techs.list = $null) { var %techs.list none }
  if (%ignition.counter = $null) { var %ignition.counter 0 }

  var %ai.npc.techs %techs.list
  inc %npc.level %tech.power
  inc %npc.level %ignition.counter 
  inc %npc.level %total.npc.techs

  if (%ignitions != $null) { var %npc.use.ignitions yes }

  unset %techs.list | unset %ignition.counter | unset %tech.count | unset %tech.power | unset %ignitions

  var %ignitions $ignitions.get.list(%monsterfile) 
  var %total.monster.techs $techs.count(%monsterfile)

  if (%techs.list = $null) { var %techs.list none }
  if (%ignition.counter = $null) { var %ignition.counter 0 }

  var %ai.monster.techs %techs.list
  inc %monster.level %tech.count
  inc %monster.level %ignition.counter | unset %ignition.counter

  if (%ignitions != $null) { var %monster.use.ignitions yes }

  ; calculate their battle level.
  inc %npc.level $log($readini($char(%npcfile), battle, hp))
  inc %monster.level $log($readini($char(%monsterfile), battle, hp))

  if ($readini($char(%npcfile), mech, HpMax) != $null) { inc %npc.level 100 }
  if ($readini($char(%monsterfile), mech, HpMax) != $null) { inc %monster.level 100 }

  if ($readini($char(%npcfile), info, CanTaunt) != false) { dec %npc.level 10 } 
  if ($readini($char(%monsterfile), info, CanTaunt) != false) { dec %monster.level 10 } 

  if ($readini($char(%monsterfile), info, MetalDefense) = true) { inc %monster.level 10 }
  if ($readini($char(%npcfile), info, MetalDefense) = true) { inc %npc.level 10 }

  if ($readini($char(%monsterfile), skills, MonsterSummon) >= 1) { inc %monster.level 20 }

  if ($readini($char(%monsterfile), naturalarmor, max) != $null) { inc %monster.level $readini($char(%monsterfile), naturalarmor, max) }

  ; Set a favorite to win the fight.
  if (%monster.level > %npc.level) { var %favorite.to.win monster }
  if (%monster.level <= %npc.level) { var %favorite.to.win npc }

  ; create some random gamblers who will participate and place random bets.
  ; I will expand this later to be "smarter" but for now..random. 
  var %total.gamblers $readini(system.dat, system, PhantomBetters)
  if (%total.gamblers = $null) { var %total.gamblers 13 }
  if (%total.gamblers < 3) { var %total.gamblers 3 }

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
  $display.message($readini(translation.dat, battle, BattleAIInfo), global)
  $display.message($readini(translation.dat, battle, BattleAITechInfoNPC), global)
  $display.message($readini(translation.dat, battle, BattleAITechInfoMon), global)

  ; Open betting
  set %betting.period open
  $display.message($readini(translation.dat, system, BettingPeriodOpened), global)

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

  if (%payout.ratio <= .50) { var %payout.ratio .50 }

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
    $display.message(12Payout ratio for the winner [ $+ %money.winner $+ ]: %payout.ratio for every $chr(36) $+ $chr(36) $+ 1, battle) 
    $display.message($readini(translation.dat, system, DoubleDollarWinners), global) 
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

ai.battle.updateodds {
  ; Update the odds based on players (to be done later)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds a list of players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buildplayerlist {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    if ($readini($char(%name), info, flag) != $null) { return }
    write $nick $+ _players.txt %name 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds a list of zapped players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buildzappedlist {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 

    write $nick $+ _zapped.txt %name - $asctime($file($1-).mtime,mm/dd/yyyy - hh:mm:ss tt) 
    write zapped.html  <td> %name </td>
    write zapped.html  <td> $asctime($file($1-).mtime,mm/dd/yyyy - hh:mm:ss tt) </td>
    write zapped.html  </tr>
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a list of bot admins
; or allows the owner to add
; or remove admins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bot.admin {
  if ($1 = list) { var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if (%bot.admins = $null) { $display.message(4There are no bot admins set., private) | halt }
    else {
      set %replacechar $chr(044) $chr(032)
      %bot.admins = $replace(%bot.admins, $chr(046), %replacechar)
      unset %replacechar
      $display.message(3Bot Admins:12 %bot.admins, private) | halt 
    }
  }

  if ($1 = add) { $checkchar($2) | var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if ($istok(%bot.admins,$2,46) = $true) { $display.message(4Error: $2 is already a bot admin, private) | halt }
    %bot.admins = $addtok(%bot.admins,$2,46) | $display.message(3 $+ $2 has been added as a bot admin., private) 
    writeini system.dat botinfo bot.owner %bot.admins | halt 
  }

  if ($1 = remove) { var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if ($istok(%bot.admins,$2,46) = $false) { $display.message(4Error: $2 is not a bot admin, private) | halt }

    ; The bot admin in the first position is considered to be the "bot owner" and cannot be removed via this command.
    var %bot.owner $gettok(%bot.admins,1,46)
    if ($2 = %bot.owner) { $display.message(4Error: $2 cannot be removed from the bot admin list using this command, private) | halt }

    %bot.admins = $remtok(%bot.admins,$2,46) | $display.message(3 $+ $2 has been removed as a bot admin., private) 
    writeini system.dat botinfo bot.owner %bot.admins | halt 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dragon Hunt aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dragonhunt.check {
  var %dragonhunt.lastdragonmade $readini(battlestats.dat, battle, DragonHunt.LastMade)
  if (%dragonhunt.lastdragonmade = $null) { $dragonhunt.createdragon | halt }

  var %dragon.time.difference $calc($ctime - %dragonhunt.lastdragonmade)

  if (%dragon.time.difference >= 43200) {
    var %dragon.createchance $rand(1,100)
    if (%dragon.createchance <= 60) { $dragonhunt.createdragon }
  }
}

dragonhunt.dragonage {
  var %dragon.createdtime $readini($dbfile(dragonhunt.db), $1, created)

  var %dragon.age $round($calc(((($ctime - %dragon.createdtime)/60)/60)/12),0)
  inc %dragon.age $readini($dbfile(dragonhunt.db), $1, Age)
  return %dragon.age
}

dragonhunt.dragonage.combined {
  var %total.dragon.age 0

  ; Cycle through the dragons 
  var %dragonhunt.totaldragons $ini($dbfile(dragonhunt.db),0)
  var %dragonhunt.counter 1

  while (%dragonhunt.counter <= %dragonhunt.totaldragons) {
    var %current.dragon $ini($dbfile(dragonhunt.db), %dragonhunt.counter)
    var %dragon.name $readini($dbfile(dragonhunt.db), %current.dragon, name)

    ; Calculate the dragon's age..
    inc %total.dragon.age $dragonhunt.dragonage(%current.dragon)

    inc %dragonhunt.counter
  }

  return %total.dragon.age

}
dragonhunt.dragonelement { return %dragon.element $readini($dbfile(dragonhunt.db), $1, Element) }

dragonhunt.createdragon {
  ; Write the time to battlestats.dat
  writeini battlestats.dat battle DragonHunt.LastMade $ctime

  ; Are players too low level for a dragon to spawn?
  if ($total.player.averagelevel < 45) { return }

  var %dragonhunt.numberofdragons $ini($dbfile(dragonhunt.db),0)
  if (%dragonhunt.numberofdragons >= 5) { 
    ; Dragons are full, so let's have a chance that one of them will attack the allied forces HQ
    $shopnpc.kidnap(dragon) 
    return 
  }

  ; Pick a random first name
  var %names.lines $lines($lstfile(dragonnames.lst))
  if ((%names.lines = $null) || (%names.lines = 0)) { write $lstfile(dragonnames.lst) Nasith | var %names.lines 1 }
  var %random.firstname $rand(1,%names.lines)
  var %first.name $read($lstfile(dragonnames.lst), %random.firstname)
  unset %names.lines

  ; Pick a random surname
  var %names.lines $lines($lstfile(dragonlastnames.lst))
  if ((%names.lines = $null) || (%names.lines = 0)) { write $lstfile(dragonlastnames.lst) BloodFang | var %names.lines 1 }
  var %random.surname $rand(1,%names.lines)
  var %last.name $read($lstfile(dragonlastnames.lst), %random.surname)
  unset %names.lines

  var %dragon.name.file %first.name $+ _ $+ %last.name
  var %dragonhunt.name %first.name %last.name

  writeini $dbfile(dragonhunt.db) %dragon.name.file Name %dragonhunt.name

  ; Write the dragon's created time
  writeini $dbfile(dragonhunt.db) %dragon.name.file Created $ctime

  ; Pick a random age for the dragon
  writeini $dbfile(dragonhunt.db) %dragon.name.file Age $rand(100,200)

  ; Pick a random element
  var %elements fire.ice.wind.shadow.earth.light.lightning
  var %dragon.element $gettok(%elements,$rand(1, $numtok(%elements,46)),46)
  writeini $dbfile(dragonhunt.db) %dragon.name.file Element %dragon.element

  ; Show the message
  $display.message($readini(translation.dat, system, DragonHunt.CreatedDragon), global)
}

dragonhunt.listdragons {
  var %dragonhunt.numberofdragons $ini($dbfile(dragonhunt.db),0)
  if ((%dragonhunt.numberofdragons = 0) || (%dragonhunt.numberofdragons = $null)) { $display.message($readini(translation.dat, errors, DragonHunt.NoDragons), private) | halt }

  $display.message($readini(translation.dat, system, DragonHunt.ListDragons), private) 

  ; Cycle through the dragons and build a list
  var %dragonhunt.totaldragons $ini($dbfile(dragonhunt.db),0)
  var %dragonhunt.counter 1

  while (%dragonhunt.counter <= %dragonhunt.totaldragons) {
    var %current.dragon $ini($dbfile(dragonhunt.db), %dragonhunt.counter)
    var %dragon.name $readini($dbfile(dragonhunt.db), %current.dragon, name)

    ; Calculate the dragon's age..
    var %dragonhunt.dragonage $dragonhunt.dragonage(%current.dragon)

    ; Show dragon
    $display.message.Delay(4 $+ %dragon.name  - Age: %dragonhunt.dragonage - Element: $dragonhunt.dragonelement(%current.dragon) , private, 1)

    inc %dragonhunt.counter
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays some messages
; for people who are logging 
; in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system.intromessage {
  var %player.candycorn $readini($char($1), item_amount, candycorn)
  if (%player.candycorn = $null) { var %player.candycorn 0 }

  var %player.loginpoints $readini($char($1), stuff, loginpoints)
  if (%player.loginpoints = $null) { var %player.loginpoints 0 }

  var %player.redorbs $bytes($readini($char($1), stuff, redorbs),b)
  if (%player.redorbs = $null) { var %player.redorbs 0 }

  var %player.blackorbs $bytes($readini($char($1), stuff, blackorbs),b)
  if (%player.blackorbs = $null) { var %player.blackorbs 0 }

  var %player.alliednotes $bytes($readini($char($1), stuff, alliednotes),b)
  if (%player.alliednotes = $null) { var %player.alliednotes 0 }

  var %player.doubledollars $bytes($readini($char($1), stuff, doubledollars),b)
  if (%player.doubledollars = $null) { var %player.doubledollars 0 }

  var %player.enhancementpoints $bytes($readini($char($1), stuff, EnhancementPoints),b)
  if (%player.enhancementpoints = $null) { var %player.enhancementpoints 0 }

  $display.private.message(2Welcome back4 $readini($char($1), basestats, name) $+ . 2The current local bot time is4 $asctime(hh:nn tt) 2on4  $asctime(mmm dd yyyy) 2and this is bot version5 $battle.version )
  $display.private.message(2You currently have: 3 $+ %player.loginpoints 2login points $+ $chr(44) 3 $+ %player.redorbs 2 $+ $readini(system.dat, system, currency) $+ $chr(44) 3 $+ %player.blackorbs 2Black Orbs $+ $chr(44) 3 $+ %player.alliednotes 2Allied Notes $+ $chr(44) 3 $+ %player.doubledollars 2double dollars $+ $chr(44) 3 $+ %player.enhancementpoints 2enhancement points  $iif($left($adate, 2) = 10, and7 %player.candycorn 2candycorn ) )
  if ($isfile($txtfile(motd.txt)) = $true) { $display.private.message(4Current Admin Message2: $read($txtfile(motd.txt))) }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Select a bounty boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bounty.select {
  var %bounty.placed $readini(battlestats.dat, Bounty, BountyPlaced)
  if (%bounty.placed = $null) { var %bounty.placed 0 }
  var %bounty.time.difference $calc($ctime - %bounty.placed)

  if (($readini(battlestats.dat, Bounty, BossName) = $null) || (%bounty.time.difference > 86400)) { 

    ; Determine # of bosses in the bot
    var %bounty.numberofchoices $findfile($boss_path, *.char, 0, 0)

    ; Select one at random
    var %bounty.randomchoice $rand(1, %bounty.numberofchoices)
    var %bounty.bossname $findfile($boss_path, *.char, %bounty.randomchoice)

    var %bounty.bossname $nopath(%bounty.bossname) 
    var %bounty.bossname $remove(%bounty.bossname,.char)

    var %bounty.bossname $remove(%bounty.bossname, $boss_path)

    ; Write it to the file
    writeini battlestats.dat Bounty BossName %bounty.bossname
    writeini battlestats.dat Bounty BountyPlaced $ctime

    ; Display the message
    $display.message($readini(translation.dat, system, BountyPlaced),global)
  }
}

bounty.display {
  if ($readini(battlestats.dat, Bounty, BossName) = $null) { $display.message(4There is no current bounty, private) | halt }
  else {
    var %bounty.name $readini($boss($readini(battlestats.dat, Bounty, BossName)), basestats, name)
    $display.message($readini(translation.dat, system, CurrentBounty), private) 
  } 
}
