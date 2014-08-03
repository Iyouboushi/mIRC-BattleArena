; ===================================
; Allied Forces HQ Garden commands
; ===================================
on 3:TEXT:!garden*:*:{ $garden.control($nick, $2, $3) } 

alias garden.control {
  ; $1 = user
  ; $2 = command
  ; $3 = item to plant

  if ($shopnpc.present.check(Gardener) != true) { $display.private.message(4Error: $readini(shopnpcs.dat, NPCNames,Gardener) is not at the Allied Forces HQ so the garden cannot be visted.) | halt }

  if ($2 = help) { 
    ; Display the help for the garden
    $display.private.message.delay.custom($readini(translation.dat, garden, helpmessage) , 1)
  }


  if ($2 = plant) {
    if ($3 = $null) { $display.private.message.delay.custom(4Error: !garden plant itemname, 1) | halt }
    ; Is this a valid item we can plant?
    var %plant.xp $readini($dbfile(items.db), $3, GardenXp)
    if (%plant.xp = $null) {   $display.private.message.delay.custom($readini(translation.dat, garden, Can'tPlantThat) , 1) | halt }

    ; Does the player have that item?   
    set %check.item $readini($char($1), Item_Amount, $3) 
    if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.private.message.delay.custom($readini(translation.dat, errors, DoesNotHaveThatItem),1) | halt }

    ; Remove the item from the player.
    $decrease_item($1, $3)

    ; Get the item garden type
    var %plant.type $readini($dbfile(items.db), $3, GardenType)
    if (%plant.type = $null) { var %plant.type seed }

    $garden.givexp($3, %plant.xp, %plant.type)

    ; check for achievement
    var %items.planted $readini($char($1), stuff, GardenItemsPlanted)
    if (%items.planted = $null) { var %items.planted 0 }
    inc %items.planted 1 
    writeini $char($1) stuff GardenItemsPlanted %items.planted
    ; $achievement_check($1, GreenThumb)
  }

  if ((($2 = $null) || ($2 = view) || ($2 = status))) { 
    ; View the garden
    $garden.description
  }

}


alias garden.givexp {
  ; $1 = the item planted
  ; $2 = the xp
  ; $3 = the garden item type

  ; Get the xp value of the garden.
  var %garden.xp $readini(garden.dat, GardenStats, xp)
  if (%garden.xp = $null) { var %garden.xp 0 }

  ; Add the xp to the garden
  inc %garden.xp $2
  writeini garden.dat GardenStats xp %garden.xp

  ; Increase the base counter for the item type.
  if (($3 = seed) || ($3 = seeds)) {
    var %garden.seeds $readini(garden.dat, Seeds,planted)
    if (%garden.seeds = $null) { var %garden.seeds 0 }
    inc %garden.seeds 1
    writeini garden.dat seeds planted %garden.seeds
    $display.private.message.delay.custom($readini(translation.dat, garden, PlantSeed $+ $rand(1,2)) , 1)
  } 

  if (($3 = flower) || ($3 = plant)) {
    var %garden.plants $readini(garden.dat, Plants,planted)
    if (%garden.plants = $null) { var %garden.plants 0 }
    inc %garden.plants 1
    writeini garden.dat plants planted %garden.plants
    $display.private.message.delay.custom($readini(translation.dat, garden, PlantFlower $+ $rand(1,2)) , 1)
  } 

  ; Check for a levelup
  var %garden.level $readini(garden.dat, GardenStats, level)
  if (%garden.level = $null) { var %garden.level 1 }
  var %garden.xp.needed $calc(500 * %garden.level)

  if (%garden.xp >= %garden.xp.needed) { 
    inc %garden.level 1 
    writeini garden.dat GardenStats level %garden.level
    writeini garden.dat GardenStats xp 0

    writeini garden.dat GardenStats bonus $round($calc(50 * %garden.level),0)

  }
}

alias garden.description { 
  var %garden.seeds $readini(garden.dat, Seeds,planted)
  var %garden.saplings $readini(garden.dat, Seeds, Saplings)
  var %garden.trees $readini(garden.dat, seeds, trees)
  var %garden.plants $readini(garden.dat, Plants,planted)
  var %garden.bloomed $readini(garden.dat, plants, bloomed)

  ; Get the last checked
  var %garden.lastchecked $readini(garden.dat, GardenStats,LastChecked)

  ; If the last checked was greater than 24 hours, upgrade a plant and seed.
  ; Can we spin again so soon?
  var %current.time $ctime
  var %time.difference $calc(%current.time - %garden.lastchecked)

  if ((%time.difference = $null) || (%time.difference >= 86400)) { 
    if (%garden.saplings >= 1) {  dec %garden.saplings 1 | inc %garden.trees 1 | writeini garden.dat Seeds Saplings %garden.saplings | writeini garden.dat seeds Trees %garden.trees }
    if (%garden.seeds >= 1) {  dec %garden.seeds 1 | inc %garden.saplings 1 | writeini garden.dat Seeds Saplings %garden.saplings | writeini garden.dat seeds planted %garden.seeds }
    if (%garden.plants >= 1) {  dec %garden.plants 1 | inc %garden.bloomed 1 | writeini garden.dat Plants planted %garden.plants | writeini garden.dat Plants Bloomed %garden.bloomed }
  }

  writeini garden.dat GardenStats LastChecked $ctime

  ; Display the information on the garden and the description
  $display.private.message.delay.custom($readini(translation.dat, garden,GardenStatus) , 1)

  var %garden.level $readini(garden.dat, GardenStats, Level)
  if (%garden.level > 10) { var %garden.level 10 }
  $display.private.message.delay.custom($readini(translation.dat, garden,Level $+ %garden.level $+ Garden) , 1)
}
