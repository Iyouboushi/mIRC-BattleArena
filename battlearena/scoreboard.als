;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Scoreboard Generation
;;;; Last updated: 03/13/19
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate.scoreboard {
  set %totalplayers 0
  .echo -q $findfile( $char_path , *.char, 0 , 0, get.score $1-)

  if (%totalplayers <= 2) { $display.message($readini(translation.dat, errors, ScoreBoardNotEnoughPlayers), private)  | .remove scoreboard.txt | unset %totalplayers | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.  
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




  $display.message($readini(translation.dat, system, ScoreBoardTitle), private)
  $display.message($chr(3) $+ 2 $+ %score.list, private)
  if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private)  }
  unset %totalplayers | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
}

get.score {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = new_chr) { return }

  inc %totalplayers 1
  set %score $calculate.score(%name)

  if ($2 != null) {
    writeini $char(%name) scoreboard score %score
    write scoreboard.txt %name 
  }
}  


calculate.score {
  var %score 0
  var %scoreboard.type $readini(system.dat, system, ScoreBoardType)
  if (%scoreboard.type = $null) { var %scoreboard.type 2 }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL SCORE.
  ;;; TYPE 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (%scoreboard.type = 1) { 
    inc %score $readini($char($1), basestats, hp)
    inc %score $readini($char($1), basestats, tp)
    inc %score $readini($char($1), basestats, str)
    inc %score $readini($char($1), basestats, def)
    inc %score $readini($char($1), basestats, int)
    inc %score $readini($char($1), basestats, spd)
    inc %score $readini($char($1), basestats, str)
    inc %score $readini($char($1), stuff, RedOrbs)
    inc %score $readini($char($1), stuff, BlackOrbs)
    inc %score $readini($char($1), stuff, RedOrbsSpent)
    inc %score $readini($char($1), stuff, BlackOrbsSpent)
    inc %score $readini($char($1), stuff, MonsterKills)
    inc %score $readini($char($1), stuff, ChestsOpened)
    inc %score $readini($char($1), stuff, NumberOfResets)
    inc %score $readini($char($1), stuff, WeaponsAugmented)
    inc %score $readini($char($1), stuff, MonstersToGems)
    inc %score $readini($char($1), stuff, LightSpellsCasted)
    inc %score $readini($char($1), stuff, DarkSpellsCasted)
    inc %score $readini($char($1), stuff, EarthSpellsCasted)
    inc %score $readini($char($1), stuff, FireSpellsCasted)
    inc %score $readini($char($1), stuff, WindSpellsCasted)
    inc %score $readini($char($1), stuff, WaterSpellsCasted)
    inc %score $readini($char($1), stuff, IceSpellsCasted)
    inc %score $readini($char($1), stuff, LightningSpellsCasted)
    inc %score $readini($char($1), stuff, PortalBattlesWon)
    inc %score $readini($char($1), stuff, TimesHitByBattlefieldEvent)
    inc %score $readini($char($1), stuff, IgnitionsUsed)
    inc %score $readini($char($1), stuff, TimesDodged)
    inc %score $readini($char($1), stuff, TimesCountered)
    inc %score $readini($char($1), stuff, TimesParried)
    inc %score $readini($char($1), stuff, TimesBlocked)
    inc %score $readini($char($1), stuff, ItemsSold)
    inc %score $readini($char($1), stuff, LostSoulsKilled)
    inc %score $readini($char($1), stuff, totalbets) 
    inc %score $readini($char($1), stuff, totalBetAmount)
    inc %score $readini($char($1), stuff, AuctionBids)
    inc %score $readini($char($1), stuff, AuctionWins)
    inc %score $readini($char($1), stuff, doubledollars)
    inc %score $readini($char($1), stuff, GardenItemsPlanted)
    inc %score $readini($char($1), stuff, WheelsSpun)
    inc %score $readini($char($1), stuff, TrustsUsed)
    inc %score $readini($char($1), stuff, DropsRewarded)
    inc %score $readini($char($1), stuff, GamblesWon)

    inc %score $readini($char($1), Styles, Trickster)
    inc %score $readini($char($1), Styles, Guardian)
    inc %score $readini($char($1), Styles, WeaponMaster)
    if ($readini($char($1), styles, Spellmaster) != $null) { inc %score $readini($char($1), Styles, Spellmaster) }
    if ($readini($char($1), styles, QuickSilver) != $null) { inc %score $readini($char($1), Styles, QuickSilver) }
    if ($readini($char($1), styles, CounterStance) != $null) { inc %score $readini($char($1), Styles, CounterStance) }
    if ($readini($char($1), styles, Doppelganger) != $null) { inc %score $readini($char($1), Styles, Doppelganger) }
    if ($readini($char($1), styles, HitenMitsurugi-ryu) != $null) { inc %score $readini($char($1), Styles, HitenMitsurugi-ryu) }
    if ($readini($char($1), styles, Beastmaster) != $null) { inc %score $readini($char($1), Styles, Beastmaster) }


    dec %score $readini($char($1), stuff, TotalDeaths)
    dec %score $readini($char($1), stuff, TimesFled)
    dec %score $readini($char($1), stuff, DiscountsUsed)
    dec %score $readini($char($1), stuff, GamblesLost)
  }


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL SCORE.
  ;;; TYPE 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (%scoreboard.type = 2) { 



    inc %score $readini($char($1), basestats, hp)
    inc %score $readini($char($1), basestats, tp)
    inc %score $get.level($1)

    inc %score $calc($readini($char($1), stuff, BlackOrbsSpent) / 10)
    inc %score $calc($readini($char($1), stuff, RedOrbsSpent) / 50000)

    inc %score $readini($char($1), stuff, MonsterKills)
    inc %score $readini($char($1), stuff, ChestsOpened)
    inc %score $readini($char($1), stuff, NumberOfResets)
    inc %score $readini($char($1), stuff, WeaponsAugmented)
    inc %score $readini($char($1), stuff, MonstersToGems)
    inc %score $readini($char($1), stuff, LightSpellsCasted)
    inc %score $readini($char($1), stuff, DarkSpellsCasted)
    inc %score $readini($char($1), stuff, EarthSpellsCasted)
    inc %score $readini($char($1), stuff, FireSpellsCasted)
    inc %score $readini($char($1), stuff, WindSpellsCasted)
    inc %score $readini($char($1), stuff, WaterSpellsCasted)
    inc %score $readini($char($1), stuff, IceSpellsCasted)
    inc %score $readini($char($1), stuff, LightningSpellsCasted)
    inc %score $readini($char($1), stuff, PortalBattlesWon)
    inc %score $readini($char($1), stuff, TimesHitByBattlefieldEvent)
    inc %score $readini($char($1), stuff, IgnitionsUsed)
    inc %score $readini($char($1), stuff, TimesDodged)
    inc %score $readini($char($1), stuff, TimesCountered)
    inc %score $readini($char($1), stuff, TimesParried)
    inc %score $readini($char($1), stuff, ItemsSold)
    inc %score $readini($char($1), stuff, totalbets) 
    inc %score $readini($char($1), stuff, GardenItemsPlanted)
    inc %score $readini($char($1), stuff, WheelsSpun)
    inc %score $readini($char($1), stuff, TrustsUsed)
    inc %score $readini($char($1), stuff, DropsRewarded)
    inc %score $readini($char($1), stuff, GamblesWon)
    inc %score $readini($char($1), stuff, TotalBattles)
    inc %score $readini($char($1), stuff, DungeonsCleared)
    inc %score $readini($char($1), stuff, WeaponsReforged)
    inc %score $readini($char($1), stuff, TimesMechActivated)
    inc %score $readini($char($1), stuff, GobbieBoxesOpened)
    inc %score $readini($char($1), stuff, LostSoulsKilled)
    inc %score $readini($char($1), stuff, EnhancementPointsSpent)

    inc %score $readini($char($1), stuff, TechHits)
    inc %score $readini($char($1), stuff, MeleeHits)

    var %totalbetamount $readini($char($1), stuff, totalBetAmount)
    if (%totalbetamount > 100) { inc %score $round($calc(%totalbetamount * .03),0) }

    var %style.score $readini($char($1), Styles, Trickster)
    inc %style.score $readini($char($1), Styles, Guardian)
    inc %style.score $readini($char($1), Styles, WeaponMaster)
    if ($readini($char($1), styles, Spellmaster) != $null) { inc %style.score $readini($char($1), Styles, Spellmaster) }
    if ($readini($char($1), styles, QuickSilver) != $null) { inc %style.score $readini($char($1), Styles, QuickSilver) }
    if ($readini($char($1), styles, CounterStance) != $null) { inc %style.score $readini($char($1), Styles, CounterStance) }
    if ($readini($char($1), styles, Doppelganger) != $null) { inc %style.score $readini($char($1), Styles, Doppelganger) }
    if ($readini($char($1), styles, HitenMitsurugi-ryu) != $null) { inc %style.score $readini($char($1), Styles, HitenMitsurugi-ryu) }
    if ($readini($char($1), styles, Wrestlemania) != $null) { inc %style.score $readini($char($1), Styles, Wrestlemania) }
    if ($readini($char($1), styles, Beastmaster) != $null) { inc %style.score $readini($char($1), Styles, Beastmaster) }

    inc %score $calc(%style.score * 10)

    dec %score $readini($char($1), stuff, TotalDeaths)
    dec %score $readini($char($1), stuff, RevivedTimes)
    dec %score $calc($readini($char($1), stuff, TimesFled) * 5)
    dec %score $round($readini($char($1), stuff, DiscountsUsed) * 5,0)
    dec %score $readini($char($1), stuff, GamblesLost)

    if ((%score <= 0) || (%score = $null)) { var %score 1 }

  }

  return %score
}

generate.monsterdeathboard {

  set %totalmonsters 0 | set %total.deaths 0

  var %value 1
  while (%value <= $ini($lstfile(monsterdeaths.lst), monster,0)) {
    var %score $readini($lstfile(monsterdeaths.lst), monster, $ini($lstfile(monsterdeaths.lst),$ini($lstfile(monsterdeaths.lst),monster),%value))
    if (%score != $null) {  inc %total.deaths %score | write scoreboard.txt $ini($lstfile(monsterdeaths.lst),$ini($lstfile(monsterdeaths.lst),monster),%value) | inc %totalmonsters 1 }
    inc %value 1
  }

  if ((%totalmonsters <= 2) || (%totalmonsters = $null)) { $display.message($readini(translation.dat, errors, DeathBoardNotEnoughMonsters), private) |  unset %totalmonsters | halt }

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


  if ($1 = total) {  $display.message($readini(translation.dat, system, DeathBoardTotalMon), private) }

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

    $display.message($readini(translation.dat, system, DeathBoardTitleMon), private)
    $display.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private) }

  }

  unset %totalmonsters | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
  unset %total.deaths
}

; This is the old method of generating the deathboard.  Will be removed later.
generate.monsterdeathboard.old {
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

  if ((%totalmonsters <= 2) || (%totalmonsters = $null)) { $display.message($readini(translation.dat, errors, DeathBoardNotEnoughMonsters), private) |  unset %totalmonsters | halt }

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


  if ($1 = total) {  $display.message($readini(translation.dat, system, DeathBoardTotalMon), private) }

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

    $display.message($readini(translation.dat, system, DeathBoardTitleMon), private)
    $display.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private) }

  }

  unset %totalmonsters | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
  unset %total.deaths
}


generate.bossdeathboard {
  set %totalboss 0 | set %total.deaths 0

  var %value 1
  while (%value <= $ini($lstfile(monsterdeaths.lst), boss,0)) {
    var %score $readini($lstfile(monsterdeaths.lst), boss, $ini($lstfile(monsterdeaths.lst),$ini($lstfile(monsterdeaths.lst),boss),%value))
    if (%score != $null) { inc %total.deaths %score | write scoreboard.txt $ini($lstfile(monsterdeaths.lst),$ini($lstfile(monsterdeaths.lst),boss),%value) | inc %totalboss 1 }
    inc %value 1
  }

  if ((%totalboss <= 2) || (%totalboss = $null)) { $display.message($readini(translation.dat, errors, DeathBoardNotEnoughmonsters), private) | unset %totalboss | halt }

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

  if ($1 = total) {  $display.message($readini(translation.dat, system, DeathBoardTotalBoss), private) }
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

    $display.message($readini(translation.dat, system, DeathBoardTitleBosses), private)
    $display.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private) }
  }

  unset %totalboss | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score | unset %total.deaths
}




; This is the old method of generating the deathboard for bosses. Will be removed later.
generate.bossdeathboard.old {
  set %totalboss 0 | set %total.deaths 0
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

  if ((%totalboss <= 2) || (%totalboss = $null)) { $display.message($readini(translation.dat, errors, DeathBoardNotEnoughmonsters), private) | unset %totalboss | halt }

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


  if ($1 = total) {  $display.message($readini(translation.dat, system, DeathBoardTotalBoss), private) }
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

    $display.message($readini(translation.dat, system, DeathBoardTitleBosses), private)
    $display.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private) }
  }

  unset %totalboss | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score | unset %total.deaths
}

get.playerdeaths {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = new_chr) { return }

  inc %totalplayers 1
  var %score $readini($char(%name), Stuff, TotalDeaths)
  write scoreboard.txt %name 
}  


generate.playerdeathboard {
  set %totalplayers 0
  .echo -q $findfile( $char_path , *.char, 0 , 0, get.playerdeaths $1-)

  if (%totalplayers <= 2) { $display.message($readini(translation.dat, errors, DamageBoardNotEnoughPlayers), private)  | .remove scoreboard.txt | unset %totalplayers | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($char(%who.ScoreBoard), Stuff, TotalDeaths)

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
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), Stuff, TotalDeaths),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }

  if ((%totalplayers >= 5) && (%totalplayers < 10)) { 
    unset %score.list | set %current.line 1
    while (%current.line <= 5) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), Stuff, TotalDeaths),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  if (%totalplayers >= 10) { 
    unset %score.list | unset %score.list.2 | set %current.line 1
    while (%current.line <= 10) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), Stuff, TotalDeaths),b)
      if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
      if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  $display.message($readini(translation.dat, system, DeathBoardTitlePlayers), private)
  $display.message($chr(3) $+ 2 $+ %score.list, private)
  if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private)  }
  unset %totalplayers | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
}

get.playerkills {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = new_chr) { return }

  inc %totalplayers 1
  var %score $readini($char(%name), Stuff, MonsterKills)
  inc %grand.total %score
  write scoreboard.txt %name 
}  


generate.playerkillboard {
  set %totalplayers 0 | set %grand.total 0
  .echo -q $findfile( $char_path , *.char, 0 , 0, get.playerkills $1-)

  if (%totalplayers <= 2) { $display.message($readini(translation.dat, errors, KillBoardNotEnoughPlayers), private)  | .remove scoreboard.txt | unset %totalplayers | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($char(%who.ScoreBoard), Stuff, MonsterKills)

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
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), Stuff, MonsterKills),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }

  if ((%totalplayers >= 5) && (%totalplayers < 10)) { 
    unset %score.list | set %current.line 1
    while (%current.line <= 5) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), Stuff, MonsterKills),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  if (%totalplayers >= 10) { 
    unset %score.list | unset %score.list.2 | set %current.line 1
    while (%current.line <= 10) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), Stuff, MonsterKills),b)
      if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
      if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  $display.message($readini(translation.dat, system, KillBoardTitle), private)
  $display.message($chr(3) $+ 2 $+ %score.list, private)
  if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private)  }
  $display.message(02Total monsters killed:04 $bytes(%grand.total,b), private)

  unset %totalplayers | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
  unset %grandtotal
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a board
; for average tech damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate.damageboard.techs {
  set %totalplayers 0
  .echo -q $findfile( $char_path , *.char, 0 , 0, get.average.tech $1-)

  if (%totalplayers <= 2) { $display.message($readini(translation.dat, errors, DamageBoardNotEnoughPlayers), private)  | .remove scoreboard.txt | unset %totalplayers | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($char(%who.ScoreBoard), ScoreBoard, AverageDmg.Tech)

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
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, AverageDmg.Tech),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }

  if ((%totalplayers >= 5) && (%totalplayers < 10)) { 
    unset %score.list | set %current.line 1
    while (%current.line <= 5) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, AverageDmg.Tech),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  if (%totalplayers >= 10) { 
    unset %score.list | unset %score.list.2 | set %current.line 1
    while (%current.line <= 10) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, AverageDmg.Tech),b)
      if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
      if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  $display.message($readini(translation.dat, system, DamageBoardTitle.Tech), private)
  $display.message($chr(3) $+ 2 $+ %score.list, private)
  if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private)  }
  unset %totalplayers | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a board
; for average melee damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate.damageboard.melee {
  set %totalplayers 0
  .echo -q $findfile( $char_path , *.char, 0 , 0, get.average.melee $1-)

  if (%totalplayers <= 2) { $display.message($readini(translation.dat, errors, DamageBoardNotEnoughPlayers), private)  | .remove scoreboard.txt | unset %totalplayers | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($char(%who.ScoreBoard), ScoreBoard, AverageDmg.Melee)

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
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, AverageDmg.Melee),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }

  if ((%totalplayers >= 5) && (%totalplayers < 10)) { 
    unset %score.list | set %current.line 1
    while (%current.line <= 5) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, AverageDmg.Melee),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  if (%totalplayers >= 10) { 
    unset %score.list | unset %score.list.2 | set %current.line 1
    while (%current.line <= 10) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, AverageDmg.Melee),b)
      if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
      if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  $display.message($readini(translation.dat, system, DamageBoardTitle.Melee), private)
  $display.message($chr(3) $+ 2 $+ %score.list, private)
  if (%score.list.2 != $null) { $display.message($chr(3) $+ 2 $+ %score.list.2, private)  }
  unset %totalplayers | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
}
get.average.tech {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = new_chr) { return }

  inc %totalplayers 1
  var %score $character.averagedmg(%name, tech)
  write scoreboard.txt %name 
  writeini $char(%name) scoreboard AverageDmg.Tech %score
}  
get.average.melee {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)

  if (%name = new_chr) { return }

  inc %totalplayers 1
  var %score $character.averagedmg(%name, melee)
  write scoreboard.txt %name 
  writeini $char(%name) scoreboard AverageDmg.Melee %score
}  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generates an
; HTML page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
html.generate {

  if ($1 = startpage) { 

    .remove scoreboard.html
    write scoreboard.html <center><B> <font size=13> $readini(system.dat, botinfo, questchan) Stats</font> </B></center> <BR>
    write scoreboard.html <center><B> Last generated: $fulldate </B></center> <BR><BR> 


    write scoreboard.html <table border="1" bordercolor="#FFCC00" style="background-color:#FFFFCC" width="100%" cellpadding="3" cellspacing="3">

    write scoreboard.html  <tr>
    write scoreboard.html  <td><B>NAME</B></td>
    write scoreboard.html  <td><B>SCORE</B></td>
    write scoreboard.html  <td><B>HP</B></td>
    write scoreboard.html  <td><B>TP</B></td>
    write scoreboard.html <td><B>LEVEL</B></td>
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
    var %html.level $bytes($get.level($2),b) 

    write scoreboard.html  <tr>
    write scoreboard.html  <td> $2 </td>
    write scoreboard.html  <td> %html.score </td>
    write scoreboard.html  <td> %html.health </td>
    write scoreboard.html  <td> %html.tp </td>
    write scoreboard.html <td> %html.level </td>
    write scoreboard.html  <td> %html.str </td>
    write scoreboard.html  <td> %html.def </td>
    write scoreboard.html  <td> %html.int </td>
    write scoreboard.html  <td> %html.spd </td>
    write scoreboard.html  </tr>
  }

  if ($1 = endpage) {  write scoreboard.html  </table>  }

}
