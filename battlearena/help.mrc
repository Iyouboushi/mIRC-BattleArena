;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; HELP and VIEW-INFO
;;;; Last updated: 03/08/18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 1:TEXT:!help*:*: { $gamehelp($2, $nick) }
alias gamehelp { 
  $display.private.message2($2, 4It is advised that you visit the online help guide: http://iyouboushi.com/forum/index.php?/topic/890-battle-arena-help-thread/  )
  set %help.topics $readini %help_folder $+ topics.help Help List | set %help.topics2 $readini %help_folder $+ topics.help Help List2 | set %help.topics3 $readini %help_folder $+ topics.help Help List3
  if ($1 = $null) { $display.private.message2($2, 14::[Current Help Topics]::) |  $display.private.message2($2,2 $+ %help.topics) | $display.private.message2($2,2 $+ %help.topics2) | unset %help.topics | unset %help.topics2 | $display.private.message2($2, 14::[Type !help <topic> (without the <>) to view the topic]::) | halt }

  if ($isfile(%help_folder $+ $1 $+ .help) = $true) {  set %topic %help_folder $+ $1 $+ .help |  set %lines $lines(%topic) | set %l 0 | goto help }
  else { $display.private.message2($2, 3The Librarian searchs through the ancient texts but returns with no results for your inquery!  Please try again) | halt }

  :help
  inc %l 1
  if (%l <= %lines) {  
    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      var %timer.delay.help $calc(%l - 1)
      var %line.to.send $read(%topic, %l)
      $display.private.message.delay.custom(%line.to.send, %timer.delay.help)
    }
    if ($readini(system.dat, system, botType) = DCCchat) {  $display.private.message($read(%topic, %l)) }
    goto help
  }
  else { goto endhelp }
  :endhelp
  unset %topic | unset %help.topics | unset %help.topics2 | unset %lines | unset %l | unset %help
}

ON 1:TEXT:!view-info*:*: { $view-info($nick, $2, $3, $4) }
alias view-info {
  if ($2 = $null) { var %error.message 4Error: The command is missing what you want to view.  Use it like:  !view-info <tech $+ $chr(44) item $+ $chr(44) skill $+ $chr(44) weapon, armor, accessory, ignition, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }
  if ($3 = $null) { var %error.message 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <tech, item, skill, weapon, armor, accessory, ignition, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }

  if ($2 = tech) { 
    if ($readini($dbfile(techniques.db), $3, type) = $null) { $display.private.message(4Error: Invalid technique) | halt }
    var %info.type $readini($dbfile(techniques.db), $3, type) |   var %info.tp $readini($dbfile(techniques.db), $3, TP)
    var %info.basePower $readini($dbfile(techniques.db), $3, BasePower) | var %info.basecost $readini($dbfile(techniques.db), $3, Cost)
    var %info.element $readini($dbfile(techniques.db), $3, Element)
    var %info.ignoredef $readini($dbfile(techniques.db), $3, IgnoreDefense)
    var %info.hits $readini($dbfile(techniques.db), n, $3, hits)
    %info.hits = $replacex(%info.hits,$chr(36) $+ rand,random)
    %info.hits = $replacex(%info.hits,$chr(44), $chr(45))
    var %info.stat $readini($dbfile(techniques.db), $3, stat)
    if (%info.stat = $null) { var %info.stat int }

    var %energy.cost $readini($dbfile(techniques.db), $3, energyCost)
    if (%energy.cost != $null) { var %energy  [4Energy Cost12 %energy.cost $+ ] }

    if (%info.hits = $null) { var %info.hits 1 }
    if ($readini($dbfile(techniques.db), $3, magic) = yes) { var %info.magic  [4Magic12 Yes $+ ] }
    if ($readini($dbfile(techniques.db), $3, statusType) != $null) { var %info.statustype [4Stats Type12 $readini($dbfile(techniques.db), $3, StatusType) $+ ] }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ ] }

    if (%info.type != buff) { 
      $display.private.message([4Name12 $3 $+ ] [4Target Type12 %info.type $+ ] [4TP needed to use12 %info.tp $+ ] %energy [4# of Hits12 %info.hits $+ ] %info.statustype %info.magic %info.ignoredefense)
      $display.private.message([4Base Power12 %info.basepower $+ ] [4Base Cost (before Shop Level)12 %info.basecost red orbs] [4Element of Tech12 %info.element $+ ] [4Stat Modifier12 %info.stat $+ ]) 
      if (%info.type = FinalGetsuga) { $display.private.message($readini(translation.dat, system, FinalGetsugaWarning)) }
    }
    if (%info.type = buff) { 
      $display.private.message([4Name12 $3 $+ ] [4Target Type12 %info.type $+ ] [4TP needed to use12 %info.tp $+ ])
    }
  }

  if ($2 = ignition) { 
    if ($readini($dbfile(ignitions.db), $3, name) = $null) { $display.private.message(4Error: Invalid ignition) | halt }
    var %info.name $readini($dbfile(ignitions.db), $3, name)
    var %info.augment $readini($dbfile(ignitions.db), $3, Augment)
    var %info.effect $readini($dbfile(ignitions.db), $3, Effect)
    if (%info.effect = status) { var %info.status.type ( $+ $readini($dbfile(ignitions.db), $3, StatusType) $+ ) }
    var %info.trigger $readini($dbfile(ignitions.db), $3, IgnitionTrigger)
    var %info.consume $readini($dbfile(ignitions.db), $3, IgnitionConsume)

    var %info.level $readini($char($1), ignitions, $3)
    if (%info.level = $null) { var %info.level 1 }

    ; get the ignition increase based on level
    var %ignition.increase 0
    if (%info.level > 1) { var %ignition.increase $calc(.10 * %info.level) }

    ; get the stat values
    var %info.hp $calc(%ignition.increase + $readini($dbfile(ignitions.db), $3, hp))
    var %info.str $calc(%ignition.increase + $readini($dbfile(ignitions.db), $3, str))
    var %info.def $calc(%ignition.increase + $readini($dbfile(ignitions.db), $3, def))
    var %info.int $calc(%ignition.increase + $readini($dbfile(ignitions.db), $3, int))
    var %info.spd $calc(%ignition.increase + $readini($dbfile(ignitions.db), $3, spd))
    var %info.techs $readini($dbfile(ignitions.db), $3, techs)

    if (%info.techs = $null) { var %info.techs none }

    if ($chr(046) isin %info.augment) { set %replacechar $chr(044) $chr(032)
      %info.augment = $replace(%info.augment, $chr(046), %replacechar)
    }

    $display.private.message([4Name12 %info.name $+ ] [4Amount of Ignition Gauge Consumed Upon Use12 %info.trigger $+ ] [4Amount of Ignition Gauge Needed Each Round12 %info.consume $+ ] [4Bonus Augment12 %info.augment $+ ] [4Trigger Effect12 %info.effect %info.status.type $+ ])   
    $display.private.message([4Techs12 %info.techs $+ ])
    $display.private.message([4Stat Multipliers for level12 %info.level $+ ] 4Health x12 %info.hp  $+ $chr(124) 4 $+ Strength x12 %info.str  $+ $chr(124) 4 $+ Defense x12 %info.def  $+ $chr(124) 4Intelligence x12 %info.int  $+ $chr(124) 4Speed x12 %info.spd)
  }

  if ($2 = accessory) { 
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != accessory) { $display.private.message(4Invalid accessory) | halt }

    var %exclusive.test $readini($dbfile(items.db), $3, exclusive)
    if ((%exclusive.test = $null) || (%exclusive.test = no)) { var %exclusive [4Exclusive12 no $+ ]  }
    if (%exclusive.test = yes) {  var %exclusive [4Exclusive12 yes $+ ]  }

    $display.private.message([4Name12 $3 $+ ] [4Type12 Accessory $+ ] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ ])  
  }

  if ($2 = song) { 
    if ($readini($dbfile(songs.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    $display.private.message([4Name12 $3 $+ ] [4Type12 Song $+ ] [4TP Consumed12 $readini($dbfile(songs.db), $3, TP) $+ ] [4Instrument neded12 $readini($dbfile(songs.db), $3, Instrument) $+ ]  [4Song Effect12 $readini($dbfile(songs.db), $3, Type) $+ ] [4Song Target12 $readini($dbfile(songs.db), $3, Target) $+ ])
  }


  if ($2 = gem) { 
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != gem) { $display.private.message(4Invalid gem) | halt }
    $display.private.message([4Name12 $3 $+ ] [4Type12 Gem $+ ] [4Description12 $readini($dbfile(items.db), $3, desc) $+ ])
  }

  if ($2 = key) { 
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != key) { $display.private.message(4Invalid key)  | halt }
    $display.private.message([4Name12 $3 $+ ] [4Type12 Key $+ ] [4Description12 $readini($dbfile(items.db), $3, desc) $+ ])
  }

  if ($2 = rune) { 
    if ($readini($dbfile(items.db), $3, augment) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != rune) { $display.private.message(4Invalid rune) | halt }
    $display.private.message([4Name12 $3 $+ ] [4Type12 Rune $+ ] [4Augment12 $readini($dbfile(items.db), $3, augment) $+ ] [4Description12 $readini($dbfile(items.db), $3, desc) $+ ])
  }

  if ($2 = item) { 
    unset %info.fullbring
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    var %info.type $readini($dbfile(items.db), $3, type) | var %info.amount $readini($dbfile(items.db), $3, amount)
    var %info.cost $bytes($readini($dbfile(items.db), $3, cost),b) | var %info.element $readini($dbfile(items.db), $3, element) $
    var %sell.price $bytes($readini($dbfile(items.db), $3, SellPrice),b)
    if (%sell.price != $null) { var %sell.price [4Sell Price (before Haggling)12 %sell.price $+ ] } 

    if (%info.cost = 0) { var %info.cost Not Available For Purchase }

    var %info.target $readini($dbfile(items.db), $3, target)
    var %info.fullbring $readini($dbfile(items.db), $3, fullbringlevel)
    var %info.status $readini($dbfile(items.db), $3, statustype) | var %info.amount $readini($dbfile(items.db), $3, amount)
    if (%info.fullbring != $null) { set %info.fullbringmsg  [4Fullbring Level12 %info.fullbring $+ ] } 
    if (%info.target = AOE-monster) { var %info.target All monsters }

    var %item.currency $readini($dbfile(items.db), $3, currency)
    if (%item.currency = $null) { var %item.currency red orbs }

    var %exclusive.test $readini($dbfile(items.db), $3, exclusive)
    if ((%exclusive.test = $null) || (%exclusive.test = no)) { var %exclusive [4Exclusive12 no $+ ]  }
    if (%exclusive.test = yes) {  var %exclusive [4Exclusive12 yes $+ ]  }

    if (%info.type = trust) { 
      if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
      $display.private.message([4Name12 $3 $+ ] [4Type12 NPC Trust $+ ] [4NPC Summoned12 $readini($dbfile(items.db), $3, NPC) $+ ])
    }

    if (%info.type = Special) {
      var %info.specialtype $readini($dbfile(items.db), $3, SpecialType)
      if (%info.specialtype = GainWeapon) { 
        $display.private.message([4Name12 $3 $+ ] [4Type12 Gain Weapon $+ ] [4Weapon Gained12 $readini($dbfile(items.db), $3, Weapon) $+ ])
      }
    }

    if (%info.type = random) {
      var %sell.price $bytes($readini($dbfile(items.db), $3, SellPrice),b)
      if (%sell.price != $null) { var %sell.price [4Sell Price (before Haggling)12 %sell.price $+ ] } 
      $display.private.message([4Name12 $3 $+ ] [4Type12 Obtain Random Item $+ ] %exclusive %sell.price [4Description12 $readini($dbfile(items.db), $3, ItemDesc) $+ ])  
    }

    if (%info.type = armor) { $display.private.message(4This item is an armor piece. Use !view-info armor $3 to learn more about it.) }
    if (%info.type = snatch) {  $display.private.message([4Name12 $3 $+ ] [4Type12 Snatch/Grab $+ ] %exclusive [4Description12 This item is used to grab a target and use him/her/it as a protective shield. $+ ])  }
    if (%info.type = heal) { $display.private.message([4Name12 $3 $+ ] [4Type12 Healing $+ ] [4Heal Amount12 %info.amount $+ $chr(37) of target's maximum HP]  [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, %item.currency) $+ ] %sell.price %exclusive %info.fullbringmsg) }
    if (%info.type = IgnitionGauge) { $display.private.message([4Name12 $3 $+ ] [4Type12 Ignition Gauge Restore $+ ] [4Restore Amount12 %info.amount $+ ]  [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, %item.currency) $+ ] %sell.price %exclusive %info.fullbringmsg) }
    if (%info.type = Damage) { $display.private.message([4Name12 $3 $+ ] [4Type12 Damage $+ ] [4Target12 %info.target $+ ]  [4Damage Amount12 %info.amount $+ ] [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, %item.currency) $+ ] %sell.price %exclusive %info.fullbringmsg)  }
    if (%info.type = Status) { $display.private.message([4Name12 $3 $+ ] [4Type12 Status $+ ] [4Target12 %info.target $+ ]  [4Damage Amount12 %info.amount $+ ] [4Status Type12 %info.status $+ ] [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, %item.currency) $+ ] %sell.price %exclusive %info.fullbringmsg) }
    if (%info.type = Food) {  
      var %info.amount $readini($dbfile(items.db), n, $3, amount)
      %info.amount = $replacex(%info.amount,$chr(36) $+ rand,random)
      %info.amount = $replacex(%info.amount,$chr(44), $chr(45))
      $display.private.message([4Name12 $3 $+ ] [4Type12 Stat Increase $+ ] [4Stat to Increase12 %info.target $+ ] [4Increase Amount12 $iif(%info.amount >= 0, $chr(43)) $+ %info.amount $+ ] %sell.price %exclusive)   
    }
    if (%info.type = Consume) { $display.private.message([4Name12 $3 $+ ] [4Type12 Skill Consumable $+ ] [4Skill That Uses This Item12 $readini($dbfile(items.db), $3, skill) $+ ] %exclusive [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ ])    }
    if (%info.type = Summon) {  $display.private.message([4Name12 $3 $+ ] [4Type12 Summon $+ ] [4This item summons12 $iif($readini($dbfile(items.db), $3, RandomSummon) = true, a random summon, $readini($dbfile(items.db), $3, summonname)) 4to fight with you $+ ] %exclusive [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ ])    }
    if (%info.type = ShopReset) {  $display.private.message([4Name12 $3 $+ ] [4Type12 Shop Level Change $+ ] [4When used this item reduces your shop level by %info.amount $+ ] %exclusive [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ ])    }
    if (%info.type = tp) { $display.private.message([4Name12 $3 $+ ] [4Type12 TP Restore $+ ] [4TP Restored Amount12 %info.amount $+ ]  [4Item Cost12 %info.cost red orbs] %exclusive %info.fullbringmsg) }
    if (%info.type = CureStatus) { $display.private.message([4Name12 $3 $+ ] [4Type12 Cure Status $+ ] [4Item Cost12 %info.cost red orbs] [4Note12 This item will not cure Charm or Intimidation $+ ] %exclusive %info.fullbringmsg) }
    if (%info.type = accessory) { $display.private.message([4Name12 $3 $+ ] [4Type12 Accessory $+ ] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ ])  }
    if (%info.type = autorevive) {  $display.private.message([4Name12 $3 $+ ] [4Type12 Automatic Revival $+ ] %exclusive [4Description12 When used this item will activate the "Automatic Revive" status.  If you die in battle, you will be revived with 1/2 HP.  $+ ])  }
    if (%info.type = revive) {  
      var %character.revive.percent $readini($dbfile(items.db), $3, ReviveAmount) 
      if (%character.revive.percent = $null) { var %character.revive.percent .50 }
      var %character.revive.percent $calc(%character.revive.percent * 100) $+ $chr(37)
      $display.private.message([4Name12 $3 $+ ] [4Type12 Revival $+ ] [4HP Restored12 %character.revive.percent $+ ] %exclusive [4Description12 When used this item will revive a dead player with 1/2 HP.  $+ ]) 
    }
    if (%info.type = key) { $display.private.message([4Name12 $3 $+ ] [4Type12 Key $+ ] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ ])  }
    if (%info.type = gem) {  $display.private.message([4Name12 $3 $+ ] [4Type12 Gem $+ ] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ ])  }
    if (%info.type = misc) { 
      if ($readini($dbfile(items.db), $3, MechType) = $null) { $display.private.message([4Name12 $3 $+ ] [4Type12 Crafting Ingredient $+ ] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ ] $iif($readini($dbfile(items.db), $3, GardenXp) != $null, 7* This item can be planted in the Allied Forces HQ Garden.)) }
      else { $display.private.message([4Name12 $3 $+ ] [4Type12 Mech Item; $readini($dbfile(items.db), $3, MechType) $+ ] [4Amount12 $readini($dbfile(items.db), $3, amount) $+ ] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ ]) }
    }
    if (%info.type = trade) {  $display.private.message([4Name12 $3 $+ ] [4Type12 Trading Item $+ ] [4Description12 $readini($dbfile(items.db), $3, desc) $+ ] %exclusive %sell.price)  }
    if (%info.type = rune) { 
      if ($readini($dbfile(items.db), $3, augment) = $null) { $display.private.message(4Invalid item) | halt }
      $display.private.message([4Name12 $3 $+ ] [4Type12 Rune $+ ] [4Augment12 $readini($dbfile(items.db), $3, augment) $+ ] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ ]) 
    }
    unset %info.fullbringmsg
  }

  if (%info.type = IncreaseWeaponLevel) { $display.private.message([4Name12 $3 $+ ] [4Type12 Increase Weapon Level] [4Increase Amount12 $readini($dbfile(items.db), $3, IncreaseAmount) $+ ] %exclusive)  }
  if (%info.type = IncreaseTechLevel) { $display.private.message([4Name12 $3 $+ ] [4Type12 Increase Technique Level] [4Increase Amount12 $readini($dbfile(items.db), $3, IncreaseAmount) $+ ] %exclusive)  }

  if (%info.type = portal) {
    if ($readini($dbfile(items.db), $3, PortalLevel) != $null) { var %levelcap [4Level Cap12 $readini($dbfile(items.db), $3, PortalLevel) $+ ] }
    $display.private.message([4Name12 $3 $+ ] [4Type12 Portal $+ ] [4Lair12 $readini($dbfile(items.db), $3, Battlefield) $+ ] %exclusive %levelcap [4Description12 This item will teleport all players on the battlefield through a portal to the lair of a strong boss! $+ ]) 
  }
  if (%info.type = dungeon) { 
    var %dungeon.file $readini($dbfile(items.db), $3, dungeon)
    var %dungeon.name $readini($dungeonfile(%dungeon.file), info, name)
    var %dungeon.players.needed $readini($dungeonfile(%dungeon.file), info, PlayersNeeded)
    if (%dungeon.players.needed = $null) { var %dungeon.players.needed 2 }
    var %dungeon.level $readini($dungeonfile(%dungeon.file), info, Level)
    if (%dungeon.level = $null) { var %dungeon.level 15 }
    $display.private.message([4Name12 $3 $+ ] [4Type12 Dungeon Key $+ ] [4Dungeon Name12 %dungeon.name $+ ] [4Number of Players Needed12 %dungeon.players.needed $+ ] [4Dungeon Level12 %dungeon.level $+ ] [4Description12 $readini($dbfile(items.db), $3, desc) $+ ]) 
  }

  if (%info.type = TormentReward) { 
    var %amount.given $readini($dbfile(items.db), n, $3, ItemsInside)
    %amount.given = $replacex(%amount.given,$chr(36) $+ rand,random)
    %amount.given = $replacex(%amount.given,$chr(44), $chr(45))
    $display.private.message([4Name12 $3 $+ ] [4Type12 Torment Reward $+ ] [4Items Inside12 %amount.given $+ ] [4This item will give a random amount of12 LifeShard $+ $chr(44) ArcaneDust $+ $chr(44) ForgottenSoul $+ $chr(44) or ResuablePart]) 
    unset %amount.given
  }

  if (%info.type = torment) { $display.private.message([4Name12 $3 $+ ] [4Type12 Torment Portal $+ ] [4Torment Level12 $readini($dbfile(items.db), $3, TormentLevel) $+ ] [4Minimum Level to Enter12 $calc(500 * $readini($dbfile(items.db), $3, TormentLevel)) $+ ] [4Description12 An orb full of anguish and torment. Using this item outside of battle will open a portal to the torment dimension where powerful versions of the monsters await.]) }

  if (%info.type = TradingCard) { 
    var %card.rarity $readini($dbfile(items.db), n, $3, Rarity)
    var %card.numbers $readini($dbfile(items.db), n, $3, Numbers)

    if (%card.rarity = 1) { var %card.rarity * }
    if (%card.rarity = 2) { var %card.rarity ** }
    if (%card.rarity = 3) { var %card.rarity *** }
    if (%card.rarity = 4) { var %card.rarity **** }
    if (%card.rarity = 5) { var %card.rarity ***** }

    var %card.numbers $replace(%card.numbers,$chr(046), $chr(044) $chr(032)) 

    $display.private.message([4Name12 $3 $+ ] [4Type12 Trading Card $+ ] [4Rarity12 %card.rarity $+ ] [4Card Numbers12 %card.numbers $+ ])
    $display.private.message([4Description12 $readini($dbfile(items.db), $3, desc) $+ ]) 
  }


  if (%info.type = mechcore) {  
    var %energy.cost $readini($dbfile(items.db), $3, energyCost)
    var %augments $readini($dbfile(items.db), $3, augment)
    if (%energy.cost = $null) { var %energy.cost 100 }
    if (%augments = $null) { var %augments none }
    $display.private.message([4Name12 $3 $+ ] [4Type12 Mech Core $+ ] [4Base Energy Cost12 %energy.cost $+ ] [4Augments12 %augments $+ ] %exclusive) 
  }

  if ($2 = skill) { 
    if ($readini($dbfile(skills.db), $3, type) = $null) { $display.private.message(4Invalid skill)  | halt }
    var %info.type $readini($dbfile(skills.db), $3, type) | var %info.desc $readini($dbfile(skills.db), $3, info)
    var %info.cost $readini($dbfile(skills.db), $3, cost) | var %info.maxlevel $readini($dbfile(skills.db), $3, max)
    var %info.style $readini($dbfile(skills.db), $3, style)

    if (($return.systemsetting(TurnType) = action) && (%info.type = active)) { var %info.actionpoints $chr(91) $+ 4Action Points Consumed12 $skill.actionpointcheck($3) $+  $+ $chr(93) }

    var %info.current $readini($char($nick), skills, $3)
    if (%info.current = $null) { var %info.current 0 }
    var %skill.current [4Your Skill Level12 %info.current 4/12 %info.maxlevel $+ ]

    var %info.cooldown $readini($dbfile(skills.db), $3, cooldown)
    ; Have to decrease it by 1 to make it show the correct turn count.
    if (%info.cooldown != $null) { dec %info.cooldown 1 | var %skill.cooldown [4Base Turns Between Uses12 %info.cooldown $+ ] }

    var %cost.info.desc $iif(%info.cost != 0, [4Base Cost (before shop level)12 %info.cost $+ ], [4Skill is bought using Enhancement Points])

    var %skill.needs.to.be.equipped [4This skill must be 12equipped4 in order to use in battle]


    $display.private.message([4Name12 $3 $+ ] [4Skill Type12 %info.type $+ ] %cost.info.desc %skill.current %skill.cooldown %info.actionpoints)
    $display.private.message.delay.custom([4Skill Info12 %info.desc $+ ],2)
    if ($skill.needtoequip($3) = true) { 
      $display.private.message.delay.custom(%skill.needs.to.be.equipped, 2) 
      if (%info.style != $null) { $display.private.message.delay.custom(7*2 This skill does not need to be equipped to use if you are using the %info.style style, 2) }
    }
  }


  if ($2 = armor) { 
    if ($readini($dbfile(equipment.db), $3, name) = $null) { $display.private.message(4Error: Invalid Armor) | halt }
    var %info.name $readini($dbfile(equipment.db), $3, name)
    var %info.augment $readini($dbfile(equipment.db), $3, Augment)
    var %info.hp $readini($dbfile(equipment.db), $3, hp)
    var %info.tp $readini($dbfile(equipment.db), $3, tp)
    var %info.str $readini($dbfile(equipment.db), $3, str)
    var %info.def $readini($dbfile(equipment.db), $3, def)
    var %info.int $readini($dbfile(equipment.db), $3, int)
    var %info.spd $readini($dbfile(equipment.db), $3, spd)
    var %info.location $readini($dbfile(equipment.db), $3, EquipLocation)

    var %armor.level.requirement $readini($dbfile(equipment.db), $3, LevelRequirement)
    if (%armor.level.requirement = $null) { var %armor.level.requirement 0 }

    var %sell.price $bytes($readini($dbfile(equipment.db), $3, SellPrice),b)
    if (%sell.price != $null) { var %sell.price [4Sell Price (before Haggling)12 %sell.price $+ ] } 

    if ($chr(046) isin %info.augment) { set %replacechar $chr(044) $chr(032)
      %info.augment = $replace(%info.augment, $chr(046), %replacechar)
    }

    var %exclusive.test $readini($dbfile(equipment.db), $3, exclusive)
    if ((%exclusive.test = $null) || (%exclusive.test = no)) { var %exclusive [4Exclusive12 no $+ ]1  }
    if (%exclusive.test = yes) {  var %exclusive [4Exclusive12 yes $+ ]  }

    $display.private.message([4Name12 %info.name $+ ] [4Armor Location12 %info.location $+ ]  [4Armor Augment12 %info.augment $+ ] [4Player Level Requirement12 %armor.level.requirement $+ ] %exclusive %sell.price)
    $display.private.message([4Stats on Armor $+ ] 4Health12 %info.hp  $+ $chr(124) 4TP12 %info.tp   $+ $chr(124) 4 $+ Strength12 %info.str  $+ $chr(124) 4 $+ Defense12 %info.def  $+ $chr(124) 4Intelligence12 %info.int  $+ $chr(124) 4Speed12 %info.spd)
    if (AutoReraise isin %info.augment) { $display.private.message(4The Auto Reraise Augment only works if you have 5 pieces of armor that all have the same augment.  In other words the augment strength must be at least 5 in order to work) } 
  }

  if ($2 = weapon ) {
    if ($readini($dbfile(weapons.db), $3, type) = $null) { $display.private.message(4Invalid weapon) | halt }
    if ($readini($dbfile(weapons.db), $3, type) = shield) { $display.private.message(4Invalid weapon Use 12!view-info shield $3 4to see info on this) | halt }

    var %info.type $readini($dbfile(weapons.db), $3, type) | var %info.hits $readini($dbfile(weapons.db), n, $3, hits)
    %info.hits = $replacex(%info.hits,$chr(36) $+ rand,random)
    %info.hits = $replacex(%info.hits,$chr(44), $chr(45))
    var %info.basePower $readini($dbfile(weapons.db), $3, BasePower) | var %info.basecost $readini($dbfile(weapons.db), $3, Cost)
    var %info.element $readini($dbfile(weapons.db), $3, Element) | var %info.abilities $readini($dbfile(weapons.db), $3, abilities)
    var %info.ignoredef $readini($dbfile(techniques.db), $3, IgnoreDefense)
    var %info.linkedwpn $readini($dbfile(weapons.db), $3, LinkedWeapon)
    var %info.minlevel [4Minimum Level Needed to Use12 $weapon.minlevel($3) $+ ]

    if ($readini($dbfile(weapons.db), $3, AmmoRequired) != $null) {
      var %info.ammo [4Ammo Required12 $readini($dbfile(weapons.db), $3, AmmoRequired) $+ ] [4Ammo Consumed12 $readini($dbfile(weapons.db), $3, AmmoAmountNeeded) $+ ] 
    }

    if ($chr(046) isin %info.abilities) { set %replacechar $chr(044) $chr(032)
      %info.abilities = $replace(%info.abilities, $chr(046), %replacechar)
    }

    if (%info.abilities = $null) { var %info.abilities none }

    if ($readini($dbfile(weapons.db), $3, energyCost) != $null) { var %energycost [4Energy Cost12 $readini($dbfile(weapons.db), $3, energyCost) $+ ] }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ ] }

    $display.private.message([4Name12 $3 $+ ] [4Weapon Type12 %info.type $+ ] [4Weapon Size12 $return.weaponsize($3) $+ ] [4# of Hits12 %info.hits $+ ] %energycost %info.ammo %info.minlevel) 
    $display.private.message([4Base Power12 %info.basepower $+ ] [4Cost12 %info.basecost black $iif(%info.basecost < 2, orb, orbs) $+ ] [4Element of Weapon12 %info.element $+ ] [4Is the weapon 2 Handed?12 $iif($readini($dbfile(weapons.db), $3, 2Handed) = true, yes, no) $+ 4]) 
    $display.private.message([4Abilities of the Weapon12 %info.abilities $+ ] %info.ignoredefense)
    $display.private.message([4Weapon Description12 $readini($dbfile(weapons.db), $3, Info) $+ ])

    if (%info.linkedwpn != $null) { $display.private.message(12* This weapon is linked with the weapon4 %info.linkedwpn 12and may have more abilities and increased power when dual wielded with the linked weapon) }

  }

  if ($2 = shield ) {
    if ($readini($dbfile(weapons.db), $3, type) != shield) { $display.private.message(4Invalid shield) | halt }
    var %info.basecost $readini($dbfile(weapons.db), $3, Cost)
    var %info.blockchance $readini($dbfile(weapons.db), $3, blockchance)
    var %info.blockamount $readini($dbfile(weapons.db), $3, AbsorbAmount)

    if (%info.blockchance = $null) { var %info.blockchance 0 }
    if (%info.blockamount = $null) { var %info.blockamount 0 }

    $display.private.message([4Name12 $3 $+ ] [4Cost12 %info.basecost black $iif(%info.basecost < 2, orb, orbs) $+ ] [4Block Chance12 %info.blockchance $+ $chr(37) $+ ] [4Block Amount12 %info.blockamount $+ $chr(37) $+ ]) 
  }

  if ($2 = style) {
    if ($readini($dbfile(playerstyles.db), Info, $3) = $null) { $display.private.message(4Invalid style) | halt }
    $display.private.message(2 $+ $readini($dbfile(playerstyles.db), info, $3))
    if ($3 = doppelganger) { $display.private.message(2 $+ $readini($dbfile(playerstyles.db), info, Doppelganger2)) }
  }



  if ($2 = alchemy) {

    if ($3 = list) { 
      unset %crafted.*

      ; Checking items
      var %value 1 | var %crafted.items.lines $lines($lstfile(alchemy_items.lst))

      while (%value <= %crafted.items.lines) {
        set %item.name $read -l $+ %value $lstfile(alchemy_items.lst)

        if ($numtok(%crafted.items,46) <= 12) { %crafted.items = $addtok(%crafted.items, %item.name, 46) }
        else { 
          if ($numtok(%crafted.items2,46) <= 12) { %crafted.items2 = $addtok(%crafted.items2, %item.name, 46) }
          else { 
            if ($numtok(%crafted.items3,46) <= 12) { %crafted.items3 = $addtok(%crafted.items3, %item.name, 46) }
            else { 
              if ($numtok(%crafted.items4,46) <= 12) { %crafted.items4 = $addtok(%crafted.items4, %item.name, 46) }
              else { 
                if ($numtok(%crafted.items5,46) <= 12) { %crafted.items5 = $addtok(%crafted.items5, %item.name, 46) }
                else { 
                  if ($numtok(%crafted.items6,46) <= 12) { %crafted.items6 = $addtok(%crafted.items6, %item.name, 46) }
                  else { 
                    if ($numtok(%crafted.items7,46) <= 12) { %crafted.items7 = $addtok(%crafted.items7, %item.name, 46) }
                    else {
                      if ($numtok(%crafted.items8,46) <= 12) { %crafted.items8 = $addtok(%crafted.items8, %item.name, 46) }
                      else { 
                        if ($numtok(%crafted.items9,46) <= 12) { %crafted.items9 = $addtok(%crafted.items9, %item.name, 46) }
                        else { 
                          if ($numtok(%crafted.items10,46) <= 12) { %crafted.items10 = $addtok(%crafted.items10, %item.name, 46) }
                          else { %crafted.items11 = $addtok(%crafted.items11, %item.name, 46) }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        unset %item.name 
        inc %value 1 
      }

      ; Checking armor
      var %value 1 | var %crafted.armor.lines $lines($lstfile(alchemy_armor.lst))
      while (%value <= %crafted.armor.lines) {

        set %item.name $read -l $+ %value $lstfile(alchemy_armor.lst)

        if ($numtok(%crafted.armor,46) <= 12) { %crafted.armor = $addtok(%crafted.armor, %item.name, 46) }
        else { 
          if ($numtok(%crafted.armor2,46) <= 12) { %crafted.armor2 = $addtok(%crafted.armor2, %item.name, 46) }
          else { 
            if ($numtok(%crafted.armor3,46) <= 12) { %crafted.armor3 = $addtok(%crafted.armor3, %item.name, 46) }
            else { 
              if ($numtok(%crafted.armor4,46) <= 12) { %crafted.armor4 = $addtok(%crafted.armor4, %item.name, 46) }
              else { 
                if ($numtok(%crafted.armor5,46) <= 12) { %crafted.armor5 = $addtok(%crafted.armor5, %item.name, 46) }
                else { 
                  if ($numtok(%crafted.armor6,46) <= 12) { %crafted.armor6 = $addtok(%crafted.armor6, %item.name, 46) }
                  else { 
                    if ($numtok(%crafted.armor7,46) <= 12) { %crafted.armor7 = $addtok(%crafted.armor7, %item.name, 46) }
                    else {
                      if ($numtok(%crafted.armor8,46) <= 12) { %crafted.armor8 = $addtok(%crafted.armor8, %item.name, 46) }
                      else { 
                        if ($numtok(%crafted.armor9,46) <= 12) { %crafted.armor9 = $addtok(%crafted.armor9, %item.name, 46) }
                        else { 
                          if ($numtok(%crafted.armor10,46) <= 12) { %crafted.armor10 = $addtok(%crafted.armor10, %item.name, 46) }
                          else { 

                            if ($numtok(%crafted.armor11,46) <= 12) { %crafted.armor11 = $addtok(%crafted.armor11, %item.name, 46) }
                            else { %crafted.armor12 = $addtok(%crafted.armor12, %item.name, 46) }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        unset %item.name 
        inc %value 1 
      }

      set %replacechar $chr(044) $chr(032)
      %crafted.items = $replace(%crafted.items, $chr(046), %replacechar)
      %crafted.items2 = $replace(%crafted.items2, $chr(046), %replacechar)
      %crafted.items3 = $replace(%crafted.items3, $chr(046), %replacechar)
      %crafted.items4 = $replace(%crafted.items4, $chr(046), %replacechar)
      %crafted.items5 = $replace(%crafted.items5, $chr(046), %replacechar)
      %crafted.items6 = $replace(%crafted.items6, $chr(046), %replacechar)
      %crafted.items7 = $replace(%crafted.items7, $chr(046), %replacechar)
      %crafted.items8 = $replace(%crafted.items8, $chr(046), %replacechar)
      %crafted.items9 = $replace(%crafted.items9, $chr(046), %replacechar)
      %crafted.items10 = $replace(%crafted.items10, $chr(046), %replacechar)

      %crafted.armor = $replace(%crafted.armor, $chr(046), %replacechar)
      %crafted.armor2 = $replace(%crafted.armor2, $chr(046), %replacechar)
      %crafted.armor3 = $replace(%crafted.armor3, $chr(046), %replacechar)
      %crafted.armor4 = $replace(%crafted.armor4, $chr(046), %replacechar)
      %crafted.armor5 = $replace(%crafted.armor5, $chr(046), %replacechar)
      %crafted.armor6 = $replace(%crafted.armor6, $chr(046), %replacechar)
      %crafted.armor7 = $replace(%crafted.armor7, $chr(046), %replacechar)
      %crafted.armor8 = $replace(%crafted.armor8, $chr(046), %replacechar)
      %crafted.armor9 = $replace(%crafted.armor9, $chr(046), %replacechar)
      %crafted.armor10 = $replace(%crafted.armor10, $chr(046), %replacechar)
      %crafted.armor11 = $replace(%crafted.armor11, $chr(046), %replacechar)
      %crafted.armor12 = $replace(%crafted.armor12, $chr(046), %replacechar)
      %crafted.armor13 = $replace(%crafted.armor13, $chr(046), %replacechar)

      if (%crafted.items != $null) { $display.private.message(4Items that can be crafted:12 %crafted.items) }
      if (%crafted.items2 != $null) { $display.private.message(12 $+ %crafted.items2) }
      if (%crafted.items3 != $null) { $display.private.message(12 $+ %crafted.items3) }
      if (%crafted.items4 != $null) { $display.private.message(12 $+ %crafted.items4) }
      if (%crafted.items5 != $null) { $display.private.message(12 $+ %crafted.items5) }
      if (%crafted.items6 != $null) { $display.private.message(12 $+ %crafted.items6) }
      if (%crafted.items7 != $null) { $display.private.message(12 $+ %crafted.items7) }
      if (%crafted.items8 != $null) { $display.private.message(12 $+ %crafted.items8) }
      if (%crafted.items9 != $null) { $display.private.message(12 $+ %crafted.items9) }
      if (%crafted.items10 != $null) { $display.private.message(12 $+ %crafted.items10) }
      if (%crafted.items11 != $null) { $display.private.message(12 $+ %crafted.items11) }

      if (%crafted.armor != $null) { $display.private.message(4Armor that can be crafted:12 %crafted.armor) }
      if (%crafted.armor2 != $null) { $display.private.message(12 $+ %crafted.armor2) }
      if (%crafted.armor3 != $null) { $display.private.message(12 $+ %crafted.armor3) }
      if (%crafted.armor4 != $null) { $display.private.message(12 $+ %crafted.armor4) }
      if (%crafted.armor5 != $null) { $display.private.message(12 $+ %crafted.armor5) }
      if (%crafted.armor6 != $null) { $display.private.message(12 $+ %crafted.armor6) }
      if (%crafted.armor7 != $null) { $display.private.message(12 $+ %crafted.armor7) }
      if (%crafted.armor8 != $null) { $display.private.message(12 $+ %crafted.armor8) }
      if (%crafted.armor9 != $null) { $display.private.message(12 $+ %crafted.armor9) }
      if (%crafted.armor10 != $null) { $display.private.message(12 $+ %crafted.armor10) }
      if (%crafted.armor11 != $null) { $display.private.message(12 $+ %crafted.armor11) }
      if (%crafted.armor12 != $null) { $display.private.message(12 $+ %crafted.armor12) }
      if (%crafted.armor13 != $null) { $display.private.message(12 $+ %crafted.armor13) }

      unset %crafted.*
      unset %replacechar

      halt
    }

    var %gem.required $readini($dbfile(crafting.db), $3, gem)
    if (%gem.required = $null) { $display.private.message($readini(translation.dat, errors, CannotCraftThisItem)) | halt }

    var %ingredients $readini($dbfile(crafting.db), $3, ingredients)
    var %total.ingredients $numtok(%ingredients, 46)

    var %value 1
    while (%value <= %total.ingredients) {
      set %item.name $gettok(%ingredients, %value, 46)
      set %amount.needed $readini($dbfile(crafting.db), $3, %item.name)
      if (%amount.needed = $null) { set %amount.needed 1 }

      set %ingredient.to.add %item.name x $+ %amount.needed
      %ingredient.list = $addtok(%ingredient.list,%ingredient.to.add,46)
      inc %value 1 
    }

    var %base.success $readini($dbfile(crafting.db), $3, successrate) $+ $chr(37)

    set %replacechar $chr(032) $chr(043) $chr(032)
    %ingredient.list = $replace(%ingredient.list, $chr(046), %replacechar)

    $display.private.message([4Name12 $3 $+ ] [4Gem Required12 %gem.required $+ ] [4Ingredients12 %ingredient.list $+ ] [4Base Success Rate12 %base.success $+ ])

    unset %replacechar | unset %amount.needed | unset %item.name | unset %ingredient.list
  }

}

ON 3:TEXT:!recipe search*:*: { $view-recipe($nick, $3) }
alias view-recipe {
  ; Looks through recipes.lst and tries to find the crafting items that use the ingredient.

  var % [ $+ lines $+ [ $1 ] ] $lines($lstfile(recipes.lst))

  if (% [ $+ lines $+ [ $1 ] ] = $null) { $display.private.message(4The bot is missing the recipes.lst file.) | halt }

  var % [ $+ recipes.found $+ [ $1 ] ] 0
  var % [ $+ currentline $+ [ $1 ] ] 1

  while (% [ $+ currentline $+ [ $1 ] ] <= % [ $+ lines $+ [ $1 ] ]) { 
    var % [ $+ recipeline $+ [ $1 ] ]  $read -l $+ % [ $+ currentline $+ [ $1 ] ] $lstfile(recipes.lst)
    if (($istok(% [ $+ recipeline $+ [ $1 ] ] ,$2,46) = $true) && ($gettok(% [ $+ recipeline $+ [ $1 ] ] ,1,46) != $2)) {

      inc % [ $+ recipes.found $+ [ $1 ] ] $1 1 
      if ((% [ $+ recipes.found $+ [ $1 ] ] > 20) && (% [ $+ recipes.found $+ [ $1 ] ]  < 40)) { 
        % [ $+ craftingitems2 $+ [ $1 ] ] = $addtok(% [ $+ craftingitems2 $+ [ $1 ] ], $gettok(% [ $+ recipeline $+ [ $1 ] ] ,1,46), 46) 
      }
      if ((% [ $+ recipes.found $+ [ $1 ] ] >= 40) && (% [ $+ recipes.found $+ [ $1 ] ]  < 55)) { 
        % [ $+ craftingitems3 $+ [ $1 ] ] = $addtok(% [ $+ craftingitems3 $+ [ $1 ] ], $gettok(% [ $+ recipeline $+ [ $1 ] ] ,1,46), 46) 
      }
      if (% [ $+ recipes.found $+ [ $1 ] ] >= 55) {
        % [ $+ craftingitems4 $+ [ $1 ] ] = $addtok(% [ $+ craftingitems4 $+ [ $1 ] ], $gettok(% [ $+ recipeline $+ [ $1 ] ] ,1,46), 46) 
      }


      if (% [ $+ recipes.found $+ [ $1 ] ] <= 20) { 
        % [ $+ craftingitems $+ [ $1 ] ] = $addtok(% [ $+ craftingitems $+ [ $1 ] ], $gettok(% [ $+ recipeline $+ [ $1 ] ] ,1,46), 46) 
      }


    } 
    inc % [ $+ currentline $+ [ $1 ] ] 1
  }

  if (% [ $+ recipes.found $+ [ $1 ] ] > 0) {
    if ($chr(046) isin % [ $+ craftingitems $+ [ $1 ] ]) {  % [ $+ craftingitems $+ [ $1 ] ] = $replace(% [ $+ craftingitems $+ [ $1 ] ], $chr(046), $chr(044) $chr(032))  }
    if ($chr(046) isin % [ $+ craftingitems2 $+ [ $1 ] ]) {  % [ $+ craftingitems2 $+ [ $1 ] ] = $replace(% [ $+ craftingitems2 $+ [ $1 ] ], $chr(046), $chr(044) $chr(032))  }
    if ($chr(046) isin % [ $+ craftingitems3 $+ [ $1 ] ]) {  % [ $+ craftingitems3 $+ [ $1 ] ] = $replace(% [ $+ craftingitems3 $+ [ $1 ] ], $chr(046), $chr(044) $chr(032))  }
    if ($chr(046) isin % [ $+ craftingitems4 $+ [ $1 ] ]) {  % [ $+ craftingitems4 $+ [ $1 ] ] = $replace(% [ $+ craftingitems4 $+ [ $1 ] ], $chr(046), $chr(044) $chr(032))  }
    if ($chr(046) isin % [ $+ craftingitems5 $+ [ $1 ] ]) {  % [ $+ craftingitems5 $+ [ $1 ] ] = $replace(% [ $+ craftingitems5 $+ [ $1 ] ], $chr(046), $chr(044) $chr(032))  }


    $display.private.message(2There $iif(% [ $+ recipes.found $+ [ $1 ] ] = 1, is, are) % [ $+ recipes.found $+ [ $1 ] ] Crafting $iif(% [ $+ recipes.found $+ [ $1 ] ] = 1, Recipe, Recipes) that use the ingredient $2 $+ :) 
    $display.private.message.delay.custom(2 $+ % [ $+ craftingitems $+ [ $1 ] ],2)

    if (% [ $+ craftingitems2 $+ [ $1 ] ] != $null) {     $display.private.message.delay.custom(2 $+ % [ $+ craftingitems2 $+ [ $1 ] ], 2) }
    if (% [ $+ craftingitems3 $+ [ $1 ] ] != $null) {     $display.private.message.delay.custom(2 $+ % [ $+ craftingitems3 $+ [ $1 ] ],2) }
    if (% [ $+ craftingitems4 $+ [ $1 ] ] != $null) {     $display.private.message.delay.custom(2 $+ % [ $+ craftingitems4 $+ [ $1 ] ],2) }
    if (% [ $+ craftingitems5 $+ [ $1 ] ] != $null) {     $display.private.message.delay.custom(2 $+ % [ $+ craftingitems5 $+ [ $1 ] ],2) }

  }
  if (% [ $+ recipes.found $+ [ $1 ] ] = 0) {  $display.private.message(4There are no recipes that use the ingredient $2) }

  unset % [ $+ craftingitems $+ [ $1 ] ]
  unset % [ $+ craftingitems2 $+ [ $1 ] ]
  unset % [ $+ craftingitems3 $+ [ $1 ] ]
  unset % [ $+ craftingitems4 $+ [ $1 ] ]
  unset % [ $+ craftingitems5 $+ [ $1 ] ]
}
