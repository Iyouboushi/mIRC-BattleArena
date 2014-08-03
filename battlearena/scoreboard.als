generate.scoreboard {
  set %totalplayers 0
  .echo -q $findfile( $char_path , *.char, 0 , 0, get.score $1-)

  if (%totalplayers <= 2) { $display.system.message($readini(translation.dat, errors, ScoreBoardNotEnoughPlayers), private)  | unset %totalplayers | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($char(%who.ScoreBoard), ScoreBoard, score)

    if (%ScoreBoard.score <= 0) { set %ScoreBoard.score 0 }

    hadd ScoreBoardTable %who.ScoreBoard %ScoreBoard.score
    inc %ScoreBoardtxt.current.line
  }

  ; save the ScoreBoardTable hashtable to a file
  hsave ScoreBoardTable ScoreBoardTable.file

  ; load the ScoreBoardTable hashtable (as a temporary table)
  hmake ScoreBoardTable_Temp
  hload ScoreBoardTable_Temp ScoreBoardTable.file

  ; sort the ScoreBoard Table
  hmake ScoreBoardTable_Sorted
  var %ScoreBoardtableitem, %ScoreBoardtabledata, %ScoreBoardtableindex, %ScoreBoardtablecount = $hget(ScoreBoardTable_Temp,0).item
  while (%ScoreBoardtablecount > 0) {
    ; step 1: get the lowest item
    %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).item
    %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).data
    %ScoreBoardtableindex = 1
    while (%ScoreBoardtableindex < %ScoreBoardtablecount) {
      if ($hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data < %ScoreBoardtabledata) {
        %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).item
        %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data
      }
      inc %ScoreBoardtableindex
    }

    ; step 2: remove the item from the temp list
    hdel ScoreBoardTable_Temp %ScoreBoardtableitem

    ; step 3: add the item to the sorted list
    %ScoreBoardtableindex = sorted_ $+ $hget(ScoreBoardTable_Sorted,0).item
    hadd ScoreBoardTable_Sorted %ScoreBoardtableindex %ScoreBoardtableitem

    ; step 4: back to the beginning
    dec %ScoreBoardtablecount
  }

  ; get rid of the temp table
  hfree ScoreBoardTable_Temp

  ; Erase the old ScoreBoard.txt and replace it with the new one.
  .remove ScoreBoard.txt

  var %index = $hget(ScoreBoardTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(ScoreBoardTable_Sorted,sorted_ $+ %index)
    write ScoreBoard.txt %tmp
  }

  ; get rid of the sorted table
  hfree ScoreBoardTable_Sorted

  ; get rid of the ScoreBoard Table and the now un-needed file
  hfree ScoreBoardTable
  .remove ScoreBoardTable.file

  ; unset the ScoreBoard.speed
  unset %ScoreBoard.speed


  if (%totalplayers < 5) { 

    ; Get the top 3 and display it.
    unset %score.list | set %current.line 1
    while (%current.line <= 3) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, score),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }

  if ((%totalplayers >= 5) && (%totalplayers < 10)) { 
    unset %score.list | set %current.line 1
    while (%current.line <= 5) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, score),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  if (%totalplayers >= 10) { 
    unset %score.list | unset %score.list.2 | set %current.line 1
    while (%current.line <= 10) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, score),b)
      if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
      if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  ; Generate an HTML table if we need to.
  if (($readini(system.dat, system, GenerateHTML) = $null) || ($readini(system.dat, system, GenerateHTML) = true)) {
    $html.generate(startpage)

    set %current.line 1
    while (%current.line <= %totalplayers) {
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt
      $html.generate(tableline,%who.score)
      inc %current.line 1
    }
    $html.generate(endpage)
  }




  $display.system.message($readini(translation.dat, system, ScoreBoardTitle), private)
  $display.system.message($chr(3) $+ 2 $+ %score.list, private)
  if (%score.list.2 != $null) { $display.system.message($chr(3) $+ 2 $+ %score.list.2, private)  }
  unset %totalplayers | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
}

get.score {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = new_chr) { return }

  inc %totalplayers 1
  var %score 0
  var %scoreboard.type $readini(system.dat, system, ScoreBoardType)
  if (%scoreboard.type = $null) { var %scoreboard.type 2 }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL SCORE.
  ;;; TYPE 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (%scoreboard.type = 1) { 
    inc %score $readini($char(%name), basestats, hp)
    inc %score $readini($char(%name), basestats, tp)
    inc %score $readini($char(%name), basestats, str)
    inc %score $readini($char(%name), basestats, def)
    inc %score $readini($char(%name), basestats, int)
    inc %score $readini($char(%name), basestats, spd)
    inc %score $readini($char(%name), basestats, str)
    inc %score $readini($char(%name), stuff, RedOrbs)
    inc %score $readini($char(%name), stuff, BlackOrbs)
    inc %score $readini($char(%name), stuff, RedOrbsSpent)
    inc %score $readini($char(%name), stuff, BlackOrbsSpent)
    inc %score $readini($char(%name), stuff, MonsterKills)
    inc %score $readini($char(%name), stuff, ChestsOpened)
    inc %score $readini($char(%name), stuff, NumberOfResets)
    inc %score $readini($char(%name), stuff, WeaponsAugmented)
    inc %score $readini($char(%name), stuff, MonstersToGems)
    inc %score $readini($char(%name), stuff, LightSpellsCasted)
    inc %score $readini($char(%name), stuff, DarkSpellsCasted)
    inc %score $readini($char(%name), stuff, EarthSpellsCasted)
    inc %score $readini($char(%name), stuff, FireSpellsCasted)
    inc %score $readini($char(%name), stuff, WindSpellsCasted)
    inc %score $readini($char(%name), stuff, WaterSpellsCasted)
    inc %score $readini($char(%name), stuff, IceSpellsCasted)
    inc %score $readini($char(%name), stuff, LightningSpellsCasted)
    inc %score $readini($char(%name), stuff, PortalBattlesWon)
    inc %score $readini($char(%name), stuff, TimesHitByBattlefieldEvent)
    inc %score $readini($char(%name), stuff, IgnitionsUsed)
    inc %score $readini($char(%name), stuff, TimesDodged)
    inc %score $readini($char(%name), stuff, TimesCountered)
    inc %score $readini($char(%name), stuff, TimesParried)
    inc %score $readini($char(%name), stuff, TimesBlocked)
    inc %score $readini($char(%name), stuff, ItemsSold)
    inc %score $readini($char(%name), stuff, LostSoulsKilled)
    inc %score $readini($char(%name), stuff, totalbets) 
    inc %score $readini($char(%name), stuff, totalBetAmount)
    inc %score $readini($char(%name), stuff, AuctionBids)
    inc %score $readini($char(%name), stuff, AuctionWins)
    inc %score $readini($char(%name), stuff, doubledollars)

    inc %score $readini($char(%name), Styles, Trickster)
    inc %score $readini($char(%name), Styles, Guardian)
    inc %score $readini($char(%name), Styles, WeaponMaster)
    if ($readini($char(%name), styles, Spellmaster) != $null) { inc %score $readini($char(%name), Styles, Spellmaster) }
    if ($readini($char(%name), styles, QuickSilver) != $null) { inc %score $readini($char(%name), Styles, QuickSilver) }
    if ($readini($char(%name), styles, CounterStance) != $null) { inc %score $readini($char(%name), Styles, CounterStance) }
    if ($readini($char(%name), styles, Doppelganger) != $null) { inc %score $readini($char(%name), Styles, Doppelganger) }
    if ($readini($char(%name), styles, HitenMitsurugi-ryu) != $null) { inc %score $readini($char(%name), Styles, HitenMitsurugi-ryu) }
    if ($readini($char(%name), styles, Beastmaster) != $null) { inc %score $readini($char(%name), Styles, Beastmaster) }


    dec %score $readini($char(%name), stuff, TotalDeaths)
    dec %score $readini($char(%name), stuff, TimesFled)
    dec %score $readini($char(%name), stuff, DiscountsUsed)
  }


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL SCORE.
  ;;; TYPE 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (%scoreboard.type = 2) { 

    inc %score $calc($readini($char(%name), basestats, hp) / 1000)
    inc %score $calc($readini($char(%name), basestats, tp) / 100)
    inc %score $get.level(%name)
    inc %score $calc($readini($char(%name), stuff, BlackOrbsSpent) / 10)
    inc %score $calc($readini($char(%name), stuff, RedOrbsSpent) / 50000)
    inc %score $readini($char(%name), stuff, MonsterKills)
    inc %score $readini($char(%name), stuff, ChestsOpened)
    inc %score $readini($char(%name), stuff, NumberOfResets)
    inc %score $readini($char(%name), stuff, WeaponsAugmented)
    inc %score $readini($char(%name), stuff, MonstersToGems)
    inc %score $readini($char(%name), stuff, LightSpellsCasted)
    inc %score $readini($char(%name), stuff, DarkSpellsCasted)
    inc %score $readini($char(%name), stuff, EarthSpellsCasted)
    inc %score $readini($char(%name), stuff, FireSpellsCasted)
    inc %score $readini($char(%name), stuff, WindSpellsCasted)
    inc %score $readini($char(%name), stuff, WaterSpellsCasted)
    inc %score $readini($char(%name), stuff, IceSpellsCasted)
    inc %score $readini($char(%name), stuff, LightningSpellsCasted)
    inc %score $readini($char(%name), stuff, PortalBattlesWon)
    inc %score $readini($char(%name), stuff, TimesHitByBattlefieldEvent)
    inc %score $readini($char(%name), stuff, IgnitionsUsed)
    inc %score $readini($char(%name), stuff, TimesDodged)
    inc %score $readini($char(%name), stuff, TimesCountered)
    inc %score $readini($char(%name), stuff, TimesParried)
    inc %score $readini($char(%name), stuff, ItemsSold)
    inc %score $readini($char(%name), stuff, totalbets) 

    var %doubledollars $readini($char(%name), stuff, doubledollars)
    if (%doubledollars > 0) { inc %score $round($calc(%doubledollars * .03),0) }

    var %totalbetamount $readini($char(%name), stuff, totalBetAmount)
    if (%totalbetamount > 100) { inc %score $round($calc(%totalbetamount * .03),0) }

    inc %score $readini($char(%name), Styles, Trickster)
    inc %score $readini($char(%name), Styles, Guardian)
    inc %score $readini($char(%name), Styles, WeaponMaster)
    if ($readini($char(%name), styles, Spellmaster) != $null) { inc %score $readini($char(%name), Styles, Spellmaster) }
    if ($readini($char(%name), styles, QuickSilver) != $null) { inc %score $readini($char(%name), Styles, QuickSilver) }
    if ($readini($char(%name), styles, CounterStance) != $null) { inc %score $readini($char(%name), Styles, CounterStance) }
    if ($readini($char(%name), styles, Doppelganger) != $null) { inc %score $readini($char(%name), Styles, Doppelganger) }
    if ($readini($char(%name), styles, HitenMitsurugi-ryu) != $null) { inc %score $readini($char(%name), Styles, HitenMitsurugi-ryu) }

    dec %score $readini($char(%name), stuff, TotalDeaths)
    dec %score $readini($char(%name), stuff, RevivedTimes)
    dec %score $calc($readini($char(%name), stuff, TimesFled) * 5)
    dec %score $round($readini($char(%name), stuff, DiscountsUsed) * 5,0)

    if ((%score <= 0) || (%score = $null)) { var %score 1 }

  }

  if ($2 != null) {
    writeini $char(%name) scoreboard score %score
  write scoreboard.txt %name }
}  



generate.monsterdeathboard {

  set %totalmonsters 0 | set %total.deaths 0

  var %value 1
  while ($findfile( $mon_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($mon_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_mon) || (%name = $null)) { inc %value 1 } 
    set %score $readini($lstfile(monsterdeaths.lst), monster, %name)
    if (%score != $null) {  inc %total.deaths %score }

    if (%score != $null) {   write scoreboard.txt %name | inc %totalmonsters 1 }
    inc %value 1
  }

  if ($readini($lstfile(monsterdeaths.lst), monster, demon_portal) != $null) { write scoreboard.txt demon_portal | inc %totalmonsters 1 }

  if ((%totalmonsters <= 2) || (%totalmonsters = $null)) { $display.system.message($readini(translation.dat, errors, DeathBoardNotEnoughMonsters), private) |  unset %totalmonsters | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($lstfile(monsterdeaths.lst), monster,%who.scoreboard)

    if (%ScoreBoard.score <= 0) { set %ScoreBoard.score 0 }
    hadd ScoreBoardTable %who.ScoreBoard %ScoreBoard.score
    inc %ScoreBoardtxt.current.line
  }

  ; save the ScoreBoardTable hashtable to a file
  hsave ScoreBoardTable ScoreBoardTable.file

  ; load the ScoreBoardTable hashtable (as a temporary table)
  hmake ScoreBoardTable_Temp
  hload ScoreBoardTable_Temp ScoreBoardTable.file

  ; sort the ScoreBoard Table
  hmake ScoreBoardTable_Sorted
  var %ScoreBoardtableitem, %ScoreBoardtabledata, %ScoreBoardtableindex, %ScoreBoardtablecount = $hget(ScoreBoardTable_Temp,0).item
  while (%ScoreBoardtablecount > 0) {
    ; step 1: get the lowest item
    %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).item
    %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).data
    %ScoreBoardtableindex = 1
    while (%ScoreBoardtableindex < %ScoreBoardtablecount) {
      if ($hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data < %ScoreBoardtabledata) {
        %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).item
        %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data
      }
      inc %ScoreBoardtableindex
    }

    ; step 2: remove the item from the temp list
    hdel ScoreBoardTable_Temp %ScoreBoardtableitem

    ; step 3: add the item to the sorted list
    %ScoreBoardtableindex = sorted_ $+ $hget(ScoreBoardTable_Sorted,0).item
    hadd ScoreBoardTable_Sorted %ScoreBoardtableindex %ScoreBoardtableitem

    ; step 4: back to the beginning
    dec %ScoreBoardtablecount
  }

  ; get rid of the temp table
  hfree ScoreBoardTable_Temp

  ; Erase the old ScoreBoard.txt and replace it with the new one.
  .remove ScoreBoard.txt

  var %index = $hget(ScoreBoardTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(ScoreBoardTable_Sorted,sorted_ $+ %index)
    write ScoreBoard.txt %tmp
  }

  ; get rid of the sorted table
  hfree ScoreBoardTable_Sorted

  ; get rid of the ScoreBoard Table and the now un-needed file
  hfree ScoreBoardTable
  .remove ScoreBoardTable.file

  ; unset the ScoreBoard.speed
  unset %ScoreBoard.speed


  if ($1 = total) {  $display.system.message($readini(translation.dat, system, DeathBoardTotalMon), private) }

  if ($1 = $null) { 
    if (%totalmonsters < 5) { 

      ; Get the top 3 and display it.
      unset %score.list | set %current.line 1

      while (%current.line <= 3) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes( $readini($lstfile(monsterdeaths.lst), monster, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    if ((%totalmonsters >= 5) && (%totalmonsters < 10)) { 
      unset %score.list | set %current.line 1

      while (%current.line <= 5) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini($lstfile(monsterdeaths.lst), monster, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }


    if (%totalmonsters >= 10) { 
      unset %score.list | unset %score.list.2 | set %current.line 1
      while (%current.line <= 10) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini($lstfile(monsterdeaths.lst), monster, %who.score),b)
        if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
        if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    $display.system.message($readini(translation.dat, system, DeathBoardTitleMon), private)
    $display.system.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.system.message($chr(3) $+ 2 $+ %score.list.2, private) }

  }

  unset %totalmonsters | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
  unset %total.deaths
}


generate.bossdeathboard {

  set %totalbosss 0 | set %total.deaths 0

  var %value 1
  while ($findfile( $boss_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($boss_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_boss) || (%name = $null)) { inc %value 1 } 
    set %score $readini($lstfile(monsterdeaths.lst), boss, %name)
    if (%score != $null) {  inc %total.deaths %score }

    if (%score != $null) { write scoreboard.txt %name | inc %totalboss 1 }
    inc %value 1
  }

  if ((%totalboss <= 2) || (%totalboss = $null)) { $display.system.message($readini(translation.dat, errors, DeathBoardNotEnoughmonsters), private) | unset %totalboss | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($lstfile(monsterdeaths.lst), boss,%who.scoreboard)

    if (%ScoreBoard.score <= 0) { set %ScoreBoard.score 0 }
    hadd ScoreBoardTable %who.ScoreBoard %ScoreBoard.score
    inc %ScoreBoardtxt.current.line
  }

  ; save the ScoreBoardTable hashtable to a file
  hsave ScoreBoardTable ScoreBoardTable.file

  ; load the ScoreBoardTable hashtable (as a temporary table)
  hmake ScoreBoardTable_Temp
  hload ScoreBoardTable_Temp ScoreBoardTable.file

  ; sort the ScoreBoard Table
  hmake ScoreBoardTable_Sorted
  var %ScoreBoardtableitem, %ScoreBoardtabledata, %ScoreBoardtableindex, %ScoreBoardtablecount = $hget(ScoreBoardTable_Temp,0).item
  while (%ScoreBoardtablecount > 0) {
    ; step 1: get the lowest item
    %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).item
    %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).data
    %ScoreBoardtableindex = 1
    while (%ScoreBoardtableindex < %ScoreBoardtablecount) {
      if ($hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data < %ScoreBoardtabledata) {
        %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).item
        %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data
      }
      inc %ScoreBoardtableindex
    }

    ; step 2: remove the item from the temp list
    hdel ScoreBoardTable_Temp %ScoreBoardtableitem

    ; step 3: add the item to the sorted list
    %ScoreBoardtableindex = sorted_ $+ $hget(ScoreBoardTable_Sorted,0).item
    hadd ScoreBoardTable_Sorted %ScoreBoardtableindex %ScoreBoardtableitem

    ; step 4: back to the beginning
    dec %ScoreBoardtablecount
  }

  ; get rid of the temp table
  hfree ScoreBoardTable_Temp

  ; Erase the old ScoreBoard.txt and replace it with the new one.
  .remove ScoreBoard.txt

  var %index = $hget(ScoreBoardTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(ScoreBoardTable_Sorted,sorted_ $+ %index)
    write ScoreBoard.txt %tmp
  }

  ; get rid of the sorted table
  hfree ScoreBoardTable_Sorted

  ; get rid of the ScoreBoard Table and the now un-needed file
  hfree ScoreBoardTable
  .remove ScoreBoardTable.file

  ; unset the ScoreBoard.speed
  unset %ScoreBoard.speed


  if ($1 = total) {  $display.system.message($readini(translation.dat, system, DeathBoardTotalBoss), private) }
  if ($1 = $null) {

    if (%totalboss < 5) { 

      ; Get the top 3 and display it.
      unset %score.list | set %current.line 1

      while (%current.line <= 3) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes( $readini($lstfile(monsterdeaths.lst), boss, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    if ((%totalboss >= 5) && (%totalboss < 10)) { 
      unset %score.list | set %current.line 1

      while (%current.line <= 5) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini($lstfile(monsterdeaths.lst), boss, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }


    if (%totalboss >= 10) { 
      unset %score.list | unset %score.list.2 | set %current.line 1
      while (%current.line <= 10) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini($lstfile(monsterdeaths.lst), boss, %who.score),b)
        if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
        if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    $display.system.message($readini(translation.dat, system, DeathBoardTitleBosses), private)
    $display.system.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.system.message($chr(3) $+ 2 $+ %score.list.2, private) }
  }

  unset %totalboss | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score | unset %total.deaths
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generates an
; HTML page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
html.generate {

  if ($1 = startpage) { 

    .remove scoreboard.html
    write scoreboard.html <center><B> <font size=13> $readini(system.dat, botinfo, questchan) Stats</font> </B></center> <BR><BR> 

    write scoreboard.html <table border="1" bordercolor="#FFCC00" style="background-color:#FFFFCC" width="100%" cellpadding="3" cellspacing="3">

    write scoreboard.html  <tr>
    write scoreboard.html  <td><B>NAME</B></td>
    write scoreboard.html  <td><B>SCORE</B></td>
    write scoreboard.html  <td><B>Health</B></td>
    write scoreboard.html  <td><B>TP</B></td>
    write scoreboard.html  <td><B>STR</B></td>
    write scoreboard.html  <td><B>DEF</B></td>
    write scoreboard.html  <td><B>INT</B></td>
    write scoreboard.html  <td><B>SPD</B></td>
    write scoreboard.html  <tr>
  }

  if ($1 = tableline) { 
    var %html.score  $bytes($readini($char($2), scoreboard, score),b)
    var %html.health $bytes($readini($char($2),basestats, hp),b)
    var %html.tp $bytes($readini($char($2),basestats, tp),b)
    var %html.str $bytes($readini($char($2),basestats, str),b)
    var %html.def $bytes($readini($char($2),basestats, def),b)
    var %html.int $bytes($readini($char($2),basestats, int),b)
    var %html.spd $bytes($readini($char($2),basestats, spd),b)

    write scoreboard.html  <tr>
    write scoreboard.html  <td> $2 </td>
    write scoreboard.html  <td> %html.score </td>
    write scoreboard.html  <td> %html.health </td>
    write scoreboard.html  <td> %html.tp </td>
    write scoreboard.html  <td> %html.str </td>
    write scoreboard.html  <td> %html.def </td>
    write scoreboard.html  <td> %html.int </td>
    write scoreboard.html  <td> %html.spd </td>
    write scoreboard.html  </tr>

  }

  if ($1 = endpage) { 

    write scoreboard.html  </table>

  }


}
