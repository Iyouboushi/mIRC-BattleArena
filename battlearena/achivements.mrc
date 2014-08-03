;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ACHIEVEMENTS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 50:TEXT:!clear achievement*:*:{
  $checkchar($3)
  if ($4 = $null) { $display.system.message(4!clear achievement <person> <achievement name>, private) | halt }

  .remini $char($3) achievements $4 
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {   $display.system.message(4Achievement ( $+ $4  $+ ) has been cleared for $3 $+ .,global) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.global.message(4Achievement ( $+ $4  $+ ) has been cleared for $3 $+ .) }
}

alias achievement.list {
  ; CHECKING ACHIEVEMENTS
  unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3
  set %totalachievements $lines($lstfile(achievements.lst)) | set %totalachievements.unlocked 0

  var %value 1 | var %achievements.lines $lines($lstfile(achievements.lst))
  if ((%achievements.lines = $null) || (%achievements.lines = 0)) { return }

  while (%value <= %achievements.lines) {

    var %achievement.name $read -l $+ %value $lstfile(achievements.lst)
    $achievement_already_unlocked($1, %achievement.name) 

    if (%achievement.unlocked = true) {   
      inc %totalachievements.unlocked 1
      if (%achievement.name = 1.21Gigawatts) { %achievement.name = 1point21Gigawatts }

      if ($numtok(%achievement.list,46) <= 12) { %achievement.list = $addtok(%achievement.list, %achievement.name, 46) }
      else { 
        if ($numtok(%achievement.list.2,46) >= 12) { %achievement.list.3 = $addtok(%achievement.list.3, %achievement.name, 46) }
        else { %achievement.list.2 = $addtok(%achievement.list.2, %achievement.name, 46) }
      }
    }
    unset %achievement.unlocked
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %achievement.list = $replace(%achievement.list, $chr(046), %replacechar)
  %achievement.list.2 = $replace(%achievement.list.2, $chr(046), %replacechar)
  %achievement.list.3 = $replace(%achievement.list.3, $chr(046), %replacechar)

  writeini $char($1) stuff TotalAchievements %totalachievements.unlocked
}


alias achievement_check {
  if ($readini($char($1), info, flag) != $null) { return } 
  if (%achievement.system = off) { return }

  $achievement_already_unlocked($1, $2) 

  if (%achievement.unlocked = true) {  unset %achievement.unlocked | return  }

  $set_chr_name($1)

  if ($2 = BossKiller) {
    var %black.orbs.spent $readini($char($1), stuff, BlackOrbsSpent)
    if (%black.orbs.spent >= 200) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = BigSpender) {
    var %red.orbs.spent $readini($char($1), stuff, RedOrbsSpent)
    if (%red.orbs.spent >= 1000000) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = BattleArenaAnon) {
    var %red.orbs.spent $readini($char($1), stuff, RedOrbsSpent)
    if (%red.orbs.spent >= 100000000 ) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 10000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 10000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = Don'tForgetYourFriendsAndFamily) {
    var %red.orbs.spent $readini($char($1), stuff, RedOrbsSpent)
    if (%red.orbs.spent >= 200000000 ) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 50000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 50000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = SirDiesALot) {
    var %total.deaths $readini($char($1), stuff, TotalDeaths)
    if (%total.deaths >= 100) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = Don'tYouHaveaHome) {
    var %max.shop.level $readini(system.dat, system, maxshoplevel)
    if (%max.shop.level = $null) { var %max.shop.level 25 }

    var %shop.level $readini($char($1), stuff, shoplevel) 

    if (%shop.level >= %max.shop.level) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 1000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = MakeMoney) {
    var %number.of.items.sold $readini($char($1), stuff, ItemsSold)
    if (%number.of.items.sold >= 500) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 3000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 3000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = ScardyCat) {
    var %number.of.flees $readini($char($1), stuff, TimesFled)
    if (%number.of.flees >= 100) {
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = Cheapskate) {
    var %number.of.discounts $readini($char($1), stuff, DiscountsUsed)
    if (%number.of.discounts >= 5) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = Can'tKeepAGoodManDown) {
    var %number.of.revives $readini($char($1), stuff, RevivedTimes)
    if (%number.of.revives >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = MonsterSlayer) {
    var %number.of.kills $readini($char($1), stuff, MonsterKills)
    if (%number.of.kills >= 500) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.apples $readini($char($1), item_amount, SilverApple) | inc %current.apples 1 | writeini $char($1) Item_Amount SilverApple %current.apples

    }
  }

  if ($2 = PrettyGemCollector) {
    var %total.mtog $readini($char($1), stuff, MonstersToGems)
    if (%total.mtog >= 200) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = MasterOfUnlocking) {
    var %total.chests $readini($char($1), stuff, ChestsOpened)
    if (%total.chests >= 100) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %current.goldkeys $readini($char($1), item_amount, GoldKey) | inc %current.goldkeys 5 | writeini $char($1) Item_Amount GoldKey %current.goldkeys
    }
  }

  if ($2 = Santa'sLittleHelper) {
    var %number.of.gifts $readini($char($1), stuff, ItemsGiven)
    if (%number.of.gifts >= 20) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 1000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = AreYouTheKeyMaster) { 
    var %number.of.keys $readini($char($1), stuff, TotalNumberOfKeys)
    if (%number.of.keys >= 100) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %gold.keys $readini($char($1), item_amount, GoldKey) | inc %gold.keys 5 | writeini $char($1) item_amount GoldKey %gold.keys
    }
  }

  if ($2 = NowYou'rePlayingWithPower) { 
    var %number.of.augments $readini($char($1), stuff, WeaponsAugmented)
    if (%number.of.augments >= 5) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 1000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = HiHoHiHo) { 
    var %number.of.augments $readini($char($1), stuff, WeaponsReforged)
    if (%number.of.augments >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %current.hammers $readini($char($1), item_amount, RepairHammer) | inc %current.hammers 5 | writeini $char($1) Item_Amount RepairHammer %current.hammers
    }
  }

  if ($2 = PartyIsGettingCrazy) { 
    var %number.of.ignitions.used $readini($char($1), stuff, IgnitionsUsed)
    if (%number.of.ignitions.used >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2)
      set %player.ig.max $readini($char($1), BaseStats, IgnitionGauge)
      writeini $char($1) Battle IgnitionGauge %player.ig.max
      unset %player.ig.max
    }
  }

  if ($2 = Can'tTouchThis) { 
    var %number.of.dodges $readini($char($1), stuff, TimesDodged)
    if (%number.of.dodges >= 25) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = NeverAskedForThis) { 
    var %number.of.events $readini($char($1), stuff, TimesHitByBattlefieldEvent)
    if (%number.of.events >= 30) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = AlliedScrub) { 
    var %total.portalbattles.won $readini($char($1), stuff, PortalBattlesWon) 
    if (%total.portalbattles.won <= 1) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.trainingpapers $readini($char($1), item_amount, AlliedTrainingPaper) | inc %current.trainingpapers 1 | writeini $char($1) Item_Amount AlliedTrainingPaper %current.trainingpapers
    }
  }

  if ($2 = AlliedSoldier) { 
    var %total.portalbattles.won $readini($char($1), stuff, PortalBattlesWon) 
    if ((%total.portalbattles.won > 10) && (%total.portalbattles.won <= 50)) {  writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = AlliedGeneral) { 
    var %total.portalbattles.won $readini($char($1), stuff, PortalBattlesWon) 
    if (%total.portalbattles.won > 100) {  writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 8000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 8000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = GlassCannon) { 
    var %total.aggression.won $readini($char($1), stuff, BattlesWonWithAggressor) 
    if (%total.aggression.won >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = StoneWall) { 
    var %total.defender.won $readini($char($1), stuff, BattlesWonWithDefender) 
    if (%total.defender.won >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = BloodGoneDry) {
    var %total.bloodboost $readini($char($1), stuff, BloodBoostTimes) 
    if (%total.bloodboost >= 20) {   writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = BloodGoneToHead) {
    var %total.bloodboost $readini($char($1), stuff, BloodSpiritTimes) 
    if (%total.bloodboost >= 20) {   writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = IceIceBaby) { 
    var %total.spell $readini($char($1), stuff, IceSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = DiscoInferno) { 
    var %total.spell $readini($char($1), stuff, FireSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = BlindedBytheLight) { 
    var %total.spell $readini($char($1), stuff, LightSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = RockYouLikeAHurricane) { 
    var %total.spell $readini($char($1), stuff, WindSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = 1.21gigawatts) { 
    var %total.spell $readini($char($1), stuff, LightningSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = It'sAllDoomAndGloom) { 
    var %total.spell $readini($char($1), stuff, DarkSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = InTuneWithMotherEarth) { 
    var %total.spell $readini($char($1), stuff, EarthSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = TimeToBuildAnArk) { 
    var %total.spell $readini($char($1), stuff, WaterSpellsCasted) 
    if (%total.spell >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %ethers $readini($char($1), item_amount, Ether) 
      if (%ethers = $null) { var %ethers 0 }
      inc %ethers 1
      writeini $char($1) item_amount Ether %ethers
    }
  }

  if ($2 = YouBringMonstersI'llBringWeapons) { 
    if ($readini($char($1), info, flag) != $null) { return }
    if (%total.weapons.owned >= 32) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 10000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 10000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = Warbound) {
    var %total.battles $readini($char($1), stuff, TotalBattles)
    if (%total.battles >= 500) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = FillYourDarkSoulWithLight) {
    var %total.souls $readini($char($1), stuff, LostSoulsKilled)
    if (%total.souls >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.igstar $readini($char($1), item_amount, IgnitionStar) | inc %current.igstar 1 | writeini $char($1) Item_Amount IgnitionStar %current.igstar
    }
  }

  if ($2 = IAmIronMan) {
    var %total.battles $readini($char($1), stuff, TimesMechActivated)
    if (%total.battles >= 30) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %current.etanks $readini($char($1), item_amount, E-tank) | inc %current.etanks 5 | writeini $char($1) Item_Amount E-tank %current.etanks
    }
  }

  if ($2 = Jackpot) {
    writeini $char($1) achievements $2 true 
    $announce_achievement($1, $2, 1)
    var %current.clover $readini($char($1), item_amount, 4leaf-clover) 
    if (%current.clover = $null) { var %current.clover 0 }
    inc %current.clover 1 | writeini $char($1) Item_Amount 4leaf-clover %current.clover
  }

  if ($2 = HumanoidTyphoon) {
    writeini $char($1) achievements $2 true 
    $announce_achievement($1, $2, 1)
    var %current.jacket $readini($char($1), item_amount, Vash'sJacket) 
    if (%current.jacket = $null) { var %current.jacket 0 }
    inc %current.jacket 1 | writeini $char($1) Item_Amount Vash'sJacket %current.jacket
  }

  if ($2 = ICanQuitBettingAnyTimeIWant) { 
    var %total.bets $readini($char($1), stuff, TotalBets)
    if (%total.bets > 100) { 
      $announce_achievement($1, $2, 100)
      var %current.doubledollars $readini($char($1), stuff, doubledollars) | inc %current.doubledollars 100 | writeini $char($1) stuff doubledollars %current.doubledollars
    }
  }

  if ($2 = DoIHear500) { 
    if ($readini($char($1), info, flag) != $null) { return }
    var %number.of.auctionbids $readini($char($1), stuff, AuctionBids)

    if (%number.of.auctionbids >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 500)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 500 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = SoldToTheOneInFront) { 
    if ($readini($char($1), info, flag) != $null) { return }
    var %number.of.auctionwins $readini($char($1), stuff, AuctionWins)

    if (%number.of.auctionwins >= 50) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 10000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 10000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = MasteredTechnique) { 
    if ($readini($char($1), info, flag) != $null) { return }
    writeini $char($1) achievements $2 true 
    $announce_achievement($1, $2, 10000)
    var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 10000 | writeini $char($1) stuff redorbs %current.redorbs
  }

  if ($2 = SSStylish) { 
    if ($readini($char($1), info, flag) != $null) { return }
    writeini $char($1) achievements $2 true 
    $announce_achievement($1, $2, 10000)
    var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 10000 | writeini $char($1) stuff redorbs %current.redorbs
  }

}

alias achievement_already_unlocked {
  if ($readini($char($1), achievements, $2) = true) { set %achievement.unlocked true }
}

alias announce_achievement { $set_chr_name($1) 
  $display.system.message($readini(translation.dat, achievements, $2),global) 
}
