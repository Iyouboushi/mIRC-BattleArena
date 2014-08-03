;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AUCTION HOUSE COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; See info on the auction
on 3:TEXT:!auction info*:*: {  $auction.status($nick) }
on 3:TEXT:!auction winner*:*: { $auctionhouse.winners($nick, $3) }
on 3:TEXT:!auction bid*:*: { $auctionhouse.bid($nick, $3) }


alias auction.status {
  if ($readini(system.dat, auctionInfo, current.item) = $null) { $display.private.message2($1, $readini(translation.dat, errors, NoAuction)) | halt }
  if ($readini(system.dat, system, enableauctionhouse) = false) { $display.private.message2($1, $readini(translation.dat, errors, NoAuction)) | halt }

  var %auction.time $readini(system.dat, auctionInfo, startingTime)
  var %current.time $ctime 
  var %time.difference %current.time - %auction.time
  var %time.between.auctions $readini(system.dat, auctioninfo, TimeBetweenAuctions)
  if (%time.between.auctions = $null) { var %time.between.auctions 3600 } 

  var %auction.time.diff $calc(%time.between.auctions - %time.difference)
  var %auction.time.remain $round($calc(%auction.time.diff / 60),2)

  if (%auction.time.remain <= 0) { var %auction.time.remain none. Auction will refresh at the end of the next battle. }
  else {
    if (%auction.time.remain >= 1) { var %auction.time.remain %auction.time.remain $iif(%auction.time.remain > 1, minutes, minute) }
    if ((%auction.time.remain < 1) && (%auction.time.remain > -1)) {  var %auction.time.remain $remove(%auction.time.remain, 0.) | var %auction.time.remain %auction.time.remain $iif(%auction.time.remain > 1, seconds, second)  }
  }


  $display.private.message2($1, $readini(translation.dat, system, AuctionInfo))
}

alias auctionhouse.winners { 
  ; $1 = user of the command
  ; $2 = not used for now, but later will be used to allow you to search through the records

  if ($readini(system.dat, system, enableauctionhouse) = false) { $display.private.message($readini(translation.dat, errors, NoAuction)) | halt }

  var %total.winner.lines $lines($txtfile(auction_winners.txt))
  if (%total.winner.lines = 0) { $display.private.message2($1, $readini(translation.dat, errors, NoAuction)) | halt }


  if ($2 = $null) { 

    if (%total.winner.lines <= 3) { var %last.line 3 | var %starting.line 1 }
    if (%total.winner.lines >= 4) {
      var %starting.line $calc(%total.winner.lines - 3)
      var %last.line %total.winner.lines
    }

    var %winner.displayline 3Auction No. - Date - Time - Winner - Item - Notes Paid
    $display.private.message2($1, %winner.displayline)

    while (%starting.line <= %last.line) {
      $display.private.message2($1, $read -l $+ %starting.line $txtfile(auction_winners.txt))
      inc %starting.line
    }

  }

  if ($2 != $null) {
    if ($2 !isnum) { $display.private.message2($1, 4Error: Must input a number) | halt }
    var %winner.auctionline $read -l $+ $2 $txtfile(auction_winners.txt)
    if (%winner.auctionline = $null) {  $display.private.message2($1, 4Error: Invalid auction number) | halt }
    var %winner.displayline 3Auction No. - Date - Time - Winner - Item - Notes Paid
    $display.private.message2($1, %winner.displayline)
    $display.private.message2($1, %winner.auctionline)
  }

}


; Bid on an item
alias auctionhouse.bid {
  ; Is the AH system enabled?  Is there an auction to bid on?
  if ($readini(system.dat, auctionInfo, current.item) = $null) { $display.private.message2($1, $readini(translation.dat, errors, NoAuction)) | halt }
  if ($readini(system.dat, system, enableauctionhouse) = false) { $display.private.message2($1, $readini(translation.dat, errors, NoAuction)) | halt }

  ; Has the person already bid on this auction?  If so, we can't bid again.
  if ($readini($char($1), status, alliednotes.lock) = true) { $display.private.message2($1, $readini(translation.dat, errors, AlreadyPlacedBid)) |  halt }

  if ((. isin $2) || ($2 < 1)) { $display.private.message2($1, 4Error: You must bid a whole number greater than 1.) | halt }

  ; Does the person have that many notes?
  var %current.alliednotes $readini($char($1), stuff, alliednotes)
  if (%current.alliednotes < $2) { $display.private.message2($1, $readini(translation.dat, errors, NotEnoughNotesToBid)) | halt }

  ; Is the person betting the minimum?
  var %minimum.bid $readini(system.dat, auctioninfo, minimumBid)
  if ($2 < %minimum.bid) { $display.private.message2($1, $readini(translation.dat, errors, AHnotMinBid)) | halt }

  ; Check to see if the person is the highest bidder.
  var %highest.bid $readini(system.dat, auctionInfo, current.bid)
  if (%highest.bid = $null) || ($2 > %highest.bid) { writeini system.dat auctionInfo current.bid $2 | writeini system.dat auctionInfo current.winner $1 } 

  ; Write the flag.
  writeini $char($1) status alliednotes.lock true
  write $txtfile(temp_auction_bidders.txt) $1

  $display.private.message2($1, $readini(translation.dat, system, AuctionHouseBid))

  var %number.of.auctionbids $readini($char($1), stuff, AuctionBids)
  if (%number.of.auctionbids = $null) { var %number.of.auctionbids 0 }
  inc %number.of.auctionbids 1
  writeini $char($1) stuff AuctionBids %number.of.auctionbids
  $achievement_check($1, DoIHear500)
}

alias auctionhouse.check {
  ; Checks to see if an auction is in progress and if it needs to wrap up.  
  ; If no auction is currently happening, it will start one.

  if ($readini(system.dat, system, enableauctionhouse) = false) { halt }

  var %auction.time $readini(system.dat, auctionInfo, startingTime)
  var %current.time $ctime 
  if (%auction.time = $null) { $auctionhouse.create | halt }

  var %time.difference %current.time - %auction.time
  var %time.between.auctions $readini(system.dat, auctioninfo, TimeBetweenAuctions)
  if (%time.between.auctions = $null) { var %time.between.auctions 3600 } 

  if ((%time.difference = $null) || (%time.difference > %time.between.auctions)) { 
    $auctionhouse.end
    $auctionhouse.clear
    $auctionhouse.create 
  }

}

alias auctionhouse.create {
  ; Creates an auction.

  var %auction.lines $lines($lstfile(items_auctionhouse.lst))
  if ((%auction.lines = $null) || (%auction.lines = 0)) { echo -a 4,1ERROR! NO ITEMS IN ITEMS_AUCTIONHOUSE.LST | halt }

  set %random.aitem $rand(1,%auction.lines)
  set %auction.line $read -l $+ %random.aitem $lstfile(items_auctionhouse.lst)

  var %auction.item $gettok(%auction.line,1,46) 
  var %auction.minbid $gettok(%auction.line, 2, 46)

  unset %auction.line | unset %random.aitem 

  if (%auction.minbid = $null) {  echo -a 4,1ERROR! NO MIN BID FOR THE AUCTION ITEM %auction.item | halt }

  writeini system.dat auctionInfo current.item %auction.item
  writeini system.dat auctionInfo minimumBid %auction.minbid
  writeini system.dat auctionInfo startingTime $ctime

  ; Increase the total # of auctions.
  var %total.auctions $readini(system.dat, auctionInfo, NumberOfAuctions)
  if (%total.auctions = $null) { var %total.auctions 0 }
  inc %total.auctions 1
  writeini system.dat auctionInfo NumberOfAuctions %total.auctions
}

alias auctionhouse.end {
  ; Determine the auction #
  var %auction.number $readini(system.dat, auctioninfo, NumberOfAuctions)
  if (%auction.number < 10) { var %auction.number 0000 $+ %auction.number }
  if ((%auction.number >= 10) && (%auction.number <= 99)) { var %auction.number 000 $+ %auction.number }
  if ((%auction.number >= 100) && (%auction.number <= 999)) { var %auction.number 00 $+ %auction.number }
  if ((%auction.number >= 1000) && (%auction.number <= 9999)) { var %auction.number 0 $+ %auction.number }

  ; Give the item to the person who won.
  set %auction.winner $readini(system.dat, auctionInfo, current.winner)
  if (%auction.winner != $null) { 
    if ($readini($char(%auction.winner), battle, HP) != $null) { 
      set %auction.item $readini(system.dat, auctionInfo, current.item)
      set %player.amount $readini($char(%auction.winner), item_amount, %auction.item)
      if (%player.amount = $null) { var %player.amount 0 }
      inc %player.amount 1
      writeini $char(%auction.winner) item_amount %auction.item %player.amount

      ; Decrease the notes
      var %auction.cost $readini(system.dat, auctionInfo, current.bid)
      var %player.notes $readini($char(%auction.winner), stuff, alliednotes)
      dec %player.notes %auction.cost
      writeini $char(%auction.winner) stuff alliednotes %player.notes

      ; Send a message to the winner.
      if ($level(%auction.winner) >= 2) { $display.private.message2(%auction.winner, $readini(translation.dat, system, AuctionWinner)) }

      ; Check for an achievement.
      var %number.of.auctionwins $readini($char(%auction.winner), stuff, AuctionWins)
      if (%number.of.auctionwins = $null) { var %number.of.auctionwins 0 }
      inc %number.of.auctionwins 1
      writeini $char(%auction.winner) stuff AuctionWins %number.of.auctionwins
      $achievement_check(%auction.winner, SoldToTheOneInFront)

      ; Write the date/time, winner, item name and winning notes to a file in the text folder.
      write $txtfile(auction_winners.txt) %auction.number - $date - $time - %auction.winner - %auction.item - %auction.cost
    }
  }

  if (%auction.winner = $null) {
    ; Write info into the text file
    write $txtfile(auction_winners.txt) %auction.number  - $date - $time - No Winner - $readini(system.dat, auctionInfo, current.item)
  }

  unset %auction.winner | unset %auction.item | unset %player.amount

}

alias auctionhouse.clear {
  ; Clears the auction house info and makes it so players can use their ANs again.
  remini system.dat auctionInfo current.item
  remini system.dat auctioninfo current.bid
  remini system.dat auctioninfo current.winner
  remini system.dat auctioninfo minimumBid

  var %lines.peoplebid $lines($txtfile(temp_auction_bidders.txt))

  if (%lines.peoplebid != 0) {
    var %current.ahline 1

    while (%current.ahline <= %lines.peoplebid) {
      var %person.bidding $read -l $+ %current.ahline $txtfile(temp_auction_bidders.txt)
      writeini $char(%person.bidding) status alliednotes.lock false
      inc %current.ahline
    }

    .remove $txtfile(temp_auction_bidders.txt)

  }
}
