ON 1:TEXT:!help*:*: { $gamehelp($2, $nick) }
alias gamehelp { 
  set %help.topics $readini %help_folder $+ topics.help Help List | set %help.topics2 $readini %help_folder $+ topics.help Help List2 | set %help.topics3 $readini %help_folder $+ topics.help Help List3
  if ($1 = $null) { $display.private.message2($2, 14::[Current Help Topics]::) |  $display.private.message2($2,2 $+ %help.topics) | $display.private.message2($2,2 $+ %help.topics2) | unset %help.topics | unset %help.topics2 | $display.private.message2($2, 14::[Type !help <topic> (without the <>) to view the topic]::) | halt }
  if ($1 isin %help.topics) || ($1 isin %help.topics2) || ($1 isin %help.topics3) {  set %topic %help_folder $+ $1 $+ .help |  set %lines $lines(%topic) | set %l 0 | goto help }
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

ON 1:TEXT:!view-info*:*: { $view-info($1, $2, $3, $4) }
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
    var %info.stat $readini($dbfile(techniques.db), $3, stat)
    if (%info.stat = $null) { var %info.stat int }

    var %energy.cost $readini($dbfile(techniques.db), $3, energyCost)
    if (%energy.cost != $null) { var %energy  [4Energy Cost12 %energy.cost $+ 1] }

    if (%info.hits = $null) { var %info.hits 1 }
    if ($readini($dbfile(techniques.db), $3, magic) = yes) { var %info.magic  [4Magic12 Yes $+ 1] }
    if ($readini($dbfile(techniques.db), $3, statusType) != $null) { var %info.statustype [4Stats Type12 $readini($dbfile(techniques.db), $3, StatusType) $+ 1] }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ 1] }

    if (%info.type != buff) { 
      $display.private.message([4Name12 $3 $+ 1] [4Target Type12 %info.type $+ 1] [4TP needed to use12 %info.tp $+ 1] %energy [4# of Hits12 %info.hits $+ 1] %info.statustype %info.magic %info.ignoredefense)
      $display.private.message([4Base Power12 %info.basepower $+ 1] [4Base Cost (before Shop Level)12 %info.basecost red orbs1] [4Element of Tech12 %info.element $+ 1] [4Stat Modifier12 %info.stat $+ 1]) 
      if (%info.type = FinalGetsuga) { $display.private.message($readini(translation.dat, system, FinalGetsugaWarning)) }
    }
    if (%info.type = buff) { 
      $display.private.message([4Name12 $3 $+ 1] [4Target Type12 %info.type $+ 1] [4TP needed to use12 %info.tp $+ 1])
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
    var %info.hp $readini($dbfile(ignitions.db), $3, hp)
    var %info.str $readini($dbfile(ignitions.db), $3, str)
    var %info.def $readini($dbfile(ignitions.db), $3, def)
    var %info.int $readini($dbfile(ignitions.db), $3, int)
    var %info.spd $readini($dbfile(ignitions.db), $3, spd)
    var %info.techs $readini($dbfile(ignitions.db), $3, techs)
    if (%info.techs = $null) { var %info.techs none }


    if ($chr(046) isin %info.augment) { set %replacechar $chr(044) $chr(032)
      %info.augment = $replace(%info.augment, $chr(046), %replacechar)
    }

    $display.private.message([4Name12 %info.name $+ 1] [4Amount of Ignition Gauge Consumed Upon Use12 %info.trigger $+ 1] [4Amount of Ignition Gauge Needed Each Round12 %info.consume $+ 1] [4Bonus Augment12 %info.augment $+ 1] [4Trigger Effect12 %info.effect %info.status.type $+ 1])   
    $display.private.message([4Techs12 %info.techs $+ 1])
    $display.private.message([4Stat Multipliers $+ 1] 4Health x12 %info.hp  $+ $chr(124) 4 $+ Strength x12 %info.str  $+ $chr(124) 4 $+ Defense x12 %info.def  $+ $chr(124) 4Intelligence x12 %info.int  $+ $chr(124) 4Speed x12 %info.spd)
  }

  if ($2 = accessory) { 
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != accessory) { $display.private.message(4Invalid accessory) | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Accessory $+ 1] [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1])
  }


  if ($2 = song) { 
    if ($readini($dbfile(songs.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Song $+ 1] [4TP Consumed12 $readini($dbfile(songs.db), $3, TP) $+ 1] [4Instrument neded12 $readini($dbfile(songs.db), $3, Instrument) $+ 1]  [4Song Effect12 $readini($dbfile(songs.db), $3, Type) $+ 1] [4Song Target12 $readini($dbfile(songs.db), $3, Target) $+ 1])
  }

  if ($2 = gem) { 
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != gem) { $display.private.message(4Invalid gem) | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Gem $+ 1] [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1])
  }

  if ($2 = key) { 
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != key) { $display.private.message(4Invalid key)  | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Key $+ 1] [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1])
  }

  if ($2 = rune) { 
    if ($readini($dbfile(items.db), $3, augment) = $null) { $display.private.message(4Invalid item) | halt }
    if ($readini($dbfile(items.db), $3, type) != rune) { $display.private.message(4Invalid rune) | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Rune $+ 1] [4Augment12 $readini($dbfile(items.db), $3, augment) $+ 1] [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1])
  }

  if ($2 = item) { 
    unset %info.fullbring
    if ($readini($dbfile(items.db), $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    var %info.type $readini($dbfile(items.db), $3, type) | var %info.amount $readini($dbfile(items.db), $3, amount)
    var %info.cost $bytes($readini($dbfile(items.db), $3, cost),b) | var %info.element $readini($dbfile(items.db), $3, element) $
    var %sell.price $bytes($readini($dbfile(items.db), $3, SellPrice),b)
    if (%sell.price != $null) { var %sell.price [4Sell Price (before Haggling)12 %sell.price $+ 1] } 

    if (%info.cost = 0) { var %info.cost Not Available For Purchase }

    var %info.target $readini($dbfile(items.db), $3, target)
    var %info.fullbring $readini($dbfile(items.db), $3, fullbringlevel)
    var %info.status $readini($dbfile(items.db), $3, statustype) | var %info.amount $readini($dbfile(items.db), $3, amount)
    if (%info.fullbring != $null) { set %info.fullbringmsg  [4Fullbring Level12 %info.fullbring $+ 1] } 
    if (%info.target = AOE-monster) { var %info.target All monsters }


    var %exclusive.test $readini($dbfile(items.db), $3, exclusive)
    if ((%exclusive.test = $null) || (%exclusive.test = no)) { var %exclusive [4Exclusive12 no $+ 1]  }
    if (%exclusive.test = yes) {  var %exclusive [4Exclusive12 yes $+ 1]  }

    if (%info.type = snatch) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Snatch/Grab $+ 1] %exclusive [4Description12 This item is used to grab a target and use him/her/it as a protective shield. $+ 1])  }
    if (%info.type = heal) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Healing $+ 1] [4Heal Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ 1] %sell.price %exclusive %info.fullbringmsg) }
    if (%info.type = IgnitionGauge) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Ignition Gauge Restore $+ 1] [4Restore Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ 1] %sell.price %exclusive %info.fullbringmsg) }
    if (%info.type = Damage) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Damage $+ 1] [4Target12 %info.target $+ 1]  [4Damage Amount12 %info.amount $+ 1] [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ 1] %sell.price %exclusive %info.fullbringmsg)  }
    if (%info.type = Status) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Status $+ 1] [4Target12 %info.target $+ 1]  [4Damage Amount12 %info.amount $+ 1] [4Status Type12 %info.status $+ 1] [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ 1] %sell.price %exclusive %info.fullbringmsg) }
    if (%info.type = Food) {  
      var %info.amount $readini($dbfile(items.db), n, $3, amount)
      %info.amount = $replacex(%info.amount,$chr(36) $+ rand,random)
      %info.amount = $replacex(%info.amount,$chr(44), $chr(45))
      $display.private.message([4Name12 $3 $+ 1] [4Type12 Stat Increase $+ 1] [4Stat to Increase12 %info.target $+ 1] [4Increase Amount12 $iif(%info.amount >= 0, $chr(43)) $+ %info.amount $+ 1] %sell.price %exclusive)   
    }
    if (%info.type = Consume) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Skill Consumable $+ 1] [4Skill That Uses This Item12 $readini($dbfile(items.db), $3, skill) $+ 1] %exclusive [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ 1])    }
    if (%info.type = Summon) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Summon $+ 1] [4This item summons12 $readini($dbfile(items.db), $3, summonname) 4to fight with you $+ 1] %exclusive [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ 1])    }
    if (%info.type = ShopReset) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Shop Level Change $+ 1] [4When used this item reduces your shop level by %info.amount $+ 1] %exclusive [4Item Cost12 %info.cost $iif(%info.cost != Not Available For Purchase, red orbs) $+ 1])    }
    if (%info.type = tp) { $display.private.message([4Name12 $3 $+ 1] [4Type12 TP Restore $+ 1] [4TP Restored Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %exclusive %info.fullbringmsg) }
    if (%info.type = CureStatus) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Cure Status $+ 1] [4Item Cost12 %info.cost red orbs1] [4Note12 This item will not cure Charm or Intimidation $+ 1] %exclusive %info.fullbringmsg) }
    if (%info.type = accessory) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Accessory $+ 1] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1])  }
    if (%info.type = revive) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Automatic Revival $+ 1] %exclusive [4Description12 When used this item will activate the "Automatic Revive" status.  If you die in battle, you will be revived with 1/2 HP.  $+ 1])  }
    if (%info.type = key) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Key $+ 1] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1])  }
    if (%info.type = gem) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Gem $+ 1] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1])  }
    if (%info.type = misc) { 
      if ($readini($dbfile(items.db), $3, MechType) = $null) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Crafting Ingredient $+ 1] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1] $iif($readini($dbfile(items.db), $3, GardenXp) != $null, 7* This item can be planted in the Allied Forces HQ Garden.)) }
      else { $display.private.message([4Name12 $3 $+ 1] [4Type12 Mech Item; $readini($dbfile(items.db), $3, MechType) $+ 1] [4Amount12 $readini($dbfile(items.db), $3, amount) $+ 1] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1]) }
    }
    if (%info.type = trade) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Trading Item $+ 1] [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1] %exclusive %sell.price)  }
    if (%info.type = random) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Random item inside! $+ 1] %exclusive %sell.price) }
    if (%info.type = rune) { 
      if ($readini($dbfile(items.db), $3, augment) = $null) { $display.private.message(4Invalid item) | halt }
      $display.private.message([4Name12 $3 $+ 1] [4Type12 Rune $+ 1] [4Augment12 $readini($dbfile(items.db), $3, augment) $+ 1] %exclusive [4Description12 $readini($dbfile(items.db), $3, desc) $+ 1]) 
    }
    unset %info.fullbringmsg
  }
  if (%info.type = portal) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Portal $+ 1] [4Lair12 $readini($dbfile(items.db), $3, Battlefield) $+ 1] %exclusive [4Description12 This item will teleport all players on the battlefield through a portal to the lair of a strong boss! $+ 1])  }
  if (%info.type = mechcore) {  
    var %energy.cost $readini($dbfile(items.db), $3, energyCost)
    var %augments $readini($dbfile(items.db), $3, augment)
    if (%energy.cost = $null) { var %energy.cost 100 }
    if (%augments = $null) { var %augments none }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Mech Core $+ 1] [4Base Energy Cost12 %energy.cost $+ 1] [4Augments12 %augments $+ 1] %exclusive) 
  }


  if ($2 = skill) { 
    if ($readini($dbfile(skills.db), $3, type) = $null) { $display.private.message(4Invalid skill)  | halt }
    var %info.type $readini($dbfile(skills.db), $3, type) | var %info.desc $readini($dbfile(skills.db), $3, info)
    var %info.cost $readini($dbfile(skills.db), $3, cost) | var %info.maxlevel $readini($dbfile(skills.db), $3, max)

    var %info.current $readini($char($nick), skills, $3)
    if (%info.current = $null) { var %info.current 0 }
    var %skill.current [4Your Skill Level12 %info.current 4/12 %info.maxlevel $+ 1]

    var %info.cooldown $readini($dbfile(skills.db), $3, cooldown)
    ; Have to decrease it by 1 to make it show the correct turn count.
    if (%info.cooldown != $null) { dec %info.cooldown 1 | var %skill.cooldown [4Base Turns Between Uses12 %info.cooldown $+ 1] }

    $display.private.message([4Name12 $3 $+ 1] [4Skill Type12 %info.type $+ 1] [4Base Cost (before shop level)12 %info.cost $+ 1] %skill.current %skill.cooldown)
    $display.private.message([4Skill Info12 %info.desc $+ 1])
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
    if (%sell.price != $null) { var %sell.price [4Sell Price (before Haggling)12 %sell.price $+ 1] } 

    if ($chr(046) isin %info.augment) { set %replacechar $chr(044) $chr(032)
      %info.augment = $replace(%info.augment, $chr(046), %replacechar)
    }

    var %exclusive.test $readini($dbfile(equipment.db), $3, exclusive)
    if ((%exclusive.test = $null) || (%exclusive.test = no)) { var %exclusive [4Exclusive12 no $+ 1  }
    if (%exclusive.test = yes) {  var %exclusive [4Exclusive12 yes $+ 1]  }

    $display.private.message([4Name12 %info.name $+ 1] [4Armor Location12 %info.location $+ 1]  [4Armor Augment12 %info.augment $+ 1] [4Armor Level Requirement12 %armor.level.requirement $+ 1] %exclusive %sell.price)
    $display.private.message([4Stats on Armor $+ 1] 4Health12 %info.hp  $+ $chr(124) 4TP12 %info.tp   $+ $chr(124) 4 $+ Strength12 %info.str  $+ $chr(124) 4 $+ Defense12 %info.def  $+ $chr(124) 4Intelligence12 %info.int  $+ $chr(124) 4Speed12 %info.spd)
    if (AutoReraise isin %info.augment) { $display.private.message(4The Auto Reraise Augment only works if you have 5 pieces of armor that all have the same augment.  In other words the augment strength must be at least 5 in order to work) } 
  }

  if ($2 = weapon ) {
    if ($readini($dbfile(weapons.db), $3, type) = $null) { $display.private.message(4Invalid weapon) | halt }
    var %info.type $readini($dbfile(weapons.db), $3, type) | var %info.hits $readini($dbfile(weapons.db), n, $3, hits)
    %info.hits = $replacex(%info.hits,$chr(36) $+ rand,random)
    %info.hits = $replacex(%info.hits,$chr(44), $chr(45))
    var %info.basePower $readini($dbfile(weapons.db), $3, BasePower) | var %info.basecost $readini($dbfile(weapons.db), $3, Cost)
    var %info.element $readini($dbfile(weapons.db), $3, Element) | var %info.abilities $readini($dbfile(weapons.db), $3, abilities)
    var %info.ignoredef $readini($dbfile(techniques.db), $3, IgnoreDefense)

    if ($chr(046) isin %info.abilities) { set %replacechar $chr(044) $chr(032)
      %info.abilities = $replace(%info.abilities, $chr(046), %replacechar)
    }

    if (%info.abilities = $null) { var %info.abilities none }

    if ($readini($dbfile(weapons.db), $3, energyCost) != $null) { var %energycost [4Energy Cost12 $readini($dbfile(weapons.db), $3, energyCost) $+ 1] }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ 1] }

    $display.private.message([4Name12 $3 $+ 1] [4Weapon Type12 %info.type $+ 1] [4Weapon Size12 $return.weaponsize($3) $+ 1] [4# of Hits12 %info.hits $+ 1] %energycost) 
    $display.private.message([4Base Power12 %info.basepower $+ 1] [4Cost12 %info.basecost black $iif(%info.basecost < 2, orb, orbs) $+ 1] [4Element of Weapon12 %info.element $+ 1] [4Is the weapon 2 Handed?12 $iif($readini($dbfile(weapons.db), $3, 2Handed) = true, yes, no) $+ 4]) 
    $display.private.message([4Abilities of the Weapon12 %info.abilities $+ 1] %info.ignoredefense)
    $display.private.message([4Weapon Description12 $readini($dbfile(weapons.db), $3, Info) $+ 1])
  }

  if ($2 = shield ) {
    if ($readini($dbfile(weapons.db), $3, type) != shield) { $display.private.message(4Invalid shield) | halt }
    var %info.basecost $readini($dbfile(weapons.db), $3, Cost)
    var %info.blockchance $readini($dbfile(weapons.db), $3, blockchance)
    var %info.blockamount $readini($dbfile(weapons.db), $3, AbsorbAmount)

    if (%info.blockchance = $null) { var %info.blockchance 0 }
    if (%info.blockamount = $null) { var %info.blockamount 0 }

    $display.private.message([4Name12 $3 $+ 1] [4Cost12 %info.basecost black $iif(%info.basecost < 2, orb, orbs) $+ 1] [4Block Chance12 %info.blockchance $+ $chr(37) $+ 1] [4Block Amount12 %info.blockamount $+ $chr(37) $+ 1]) 
  }



  if ($2 = alchemy) {

    if ($3 = list) { 
      unset %crafted.items | unset %crafted.items2 | unset %crafted.items3 | unset %crafted.armor | unset %crafted.armor2 | unset %crafted.armor3 | unset %crafted.armor4 | unset %crafted.armor5 | unset %crafted.armor6 | unset %crafted.armor7
      unset %crafted.armor8 | unset %crafted.armor9

      ; Checking items
      var %value 1 | var %crafted.items.lines $lines($lstfile(alchemy_items.lst))

      while (%value <= %crafted.items.lines) {
        set %item.name $read -l $+ %value $lstfile(alchemy_items.lst)
        if ($numtok(%crafted.items,46) <= 20) { %crafted.items = $addtok(%crafted.items, %item.name, 46) }
        else { 
          if ($numtok(%crafted.items2,46) >= 20) { %crafted.items3 = $addtok(%crafted.items3, %item.name, 46) }
          else { %crafted.items2 = $addtok(%crafted.items2, %item.name, 46) }
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
                      if ($numtok(%crafted.armor8,46) <= 12) { %crafted.armor7 = $addtok(%crafted.armor8, %item.name, 46) }
                      else { %crafted.armor9 = $addtok(%crafted.armor9, %item.name, 46) }
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
      %crafted.armor = $replace(%crafted.armor, $chr(046), %replacechar)
      %crafted.armor2 = $replace(%crafted.armor2, $chr(046), %replacechar)
      %crafted.armor3 = $replace(%crafted.armor3, $chr(046), %replacechar)
      %crafted.armor4 = $replace(%crafted.armor4, $chr(046), %replacechar)
      %crafted.armor5 = $replace(%crafted.armor5, $chr(046), %replacechar)
      %crafted.armor6 = $replace(%crafted.armor6, $chr(046), %replacechar)
      %crafted.armor7 = $replace(%crafted.armor7, $chr(046), %replacechar)
      %crafted.armor8 = $replace(%crafted.armor8, $chr(046), %replacechar)
      %crafted.armor9 = $replace(%crafted.armor9, $chr(046), %replacechar)

      if (%crafted.items != $null) { $display.private.message(4Items that can be crafted:12 %crafted.items) }
      if (%crafted.items2 != $null) { $display.private.message(12 $+ %crafted.items2) }
      if (%crafted.items3 != $null) { $display.private.message(12 $+ %crafted.items3) }

      if (%crafted.armor != $null) { $display.private.message(4Armor that can be crafted:12 %crafted.armor) }
      if (%crafted.armor2 != $null) { $display.private.message(12 $+ %crafted.armor2) }
      if (%crafted.armor3 != $null) { $display.private.message(12 $+ %crafted.armor3) }
      if (%crafted.armor4 != $null) { $display.private.message(12 $+ %crafted.armor4) }
      if (%crafted.armor5 != $null) { $display.private.message(12 $+ %crafted.armor5) }
      if (%crafted.armor6 != $null) { $display.private.message(12 $+ %crafted.armor6) }
      if (%crafted.armor7 != $null) { $display.private.message(12 $+ %crafted.armor7) }
      if (%crafted.armor8 != $null) { $display.private.message(12 $+ %crafted.armor8) }
      if (%crafted.armor9 != $null) { $display.private.message(12 $+ %crafted.armor9) }

      unset %crafted.items | unset %crafted.items2 | unset %crafted.items3 | unset %crafted.armor | unset %crafted.armor2 | unset %crafted.armor3 | unset %crafted.armor4 | unset %crafted.armor5 | unset %crafted.armor6 | unset %crafted.armor7 | unset %crafted.armor8 | unset %crafted.armor9
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

    $display.private.message([4Name12 $3 $+ 1] [4Gem Required12 %gem.required $+ 1] [4Ingredients12 %ingredient.list $+ 1] [4Base Success Rate12 %base.success $+ 1])

    unset %replacechar | unset %amount.needed | unset %item.name | unset %ingredient.list
  }

  if ($2 = style) {
    if ($readini($dbfile(playerstyles.db), Info, $3) = $null) { $display.private.message(4Invalid style) | halt }
    $display.private.message(2 $+ $readini($dbfile(playerstyles.db), info, $3), private)
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
