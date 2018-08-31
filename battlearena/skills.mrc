;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SKILLS 
;;;; Last updated: 08/30/18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 50:TEXT:*does *:*:{ $use.skill($1, $2, $3, $4) }

ON 3:TEXT:*does *:*:{ 
  if ($2 != does) { halt }
  if ($3 = $null) { halt }
  if ($readini($char($1), info, flag) = monster) { halt }
  if ($readini($char($1), stuff, redorbs) = $null) { halt }
  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($readini(translation.dat, errors, PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($readini(translation.dat, errors, PlayerAccessOffDueToLogin), private) | halt }

  $use.skill($1, $2, $3, $4) 
}
alias use.skill { 
  ; $1 = user
  ; $2 = does
  ; $3 = skill name
  ; $4 = target, if necessary

  if ($4 != $null) { $partial.name.match($1, $4) }

  if ($3 = speed) { $skill.speedup($1) }
  if ($3 = elementalseal) { $skill.elementalseal($1) }
  if ($3 = mightystrike) { $skill.mightystrike($1) }
  if ($3 = perfectdefense) { $skill.perfectdefense($1) }
  if ($3 = truestrike) { $skill.truestrike($1) }
  if ($3 = manawall) { $skill.manawall($1) } 
  if ($3 = royalguard) { $skill.royalguard($1) }
  if ($3 = utsusemi) { $skill.utsusemi($1) }
  if ($3 = fullbring) { $skill.fullbring($1, %attack.target) }
  if ($3 = doubleturn) { $skill.doubleturn($1) } 
  if ($3 = sugitekai) { $skill.doubleturn($1) } 
  if ($3 = meditate) { $skill.meditate($1) }
  if ($3 = conserveTP) { $skill.conserveTP($1) } 
  if ($3 = thinair) { $skill.thinair($1) } 
  if ($3 = bloodboost) { $skill.bloodboost($1) } 
  if ($3 = bloodspirit) { $skill.bloodspirit($1) } 
  if ($3 = drainsamba) { $skill.drainsamba($1) } 
  if ($3 = formlessstrike) { $skill.formlessstrike($1) } 
  if (($3 = regen) && ($4 = $null)) { $skill.regen($1) } 
  if (($3 = regen) && ($4 = stop)) { $skill.regen.stop($1) } 
  if (($3 = regeneration) && ($4 = $null)) { $skill.regen($1) } 
  if (($3 = regeneration) && ($4 = stop)) { $skill.regen.stop($1) } 
  if ($3 = kikouheni) { $skill.kikouheni($1, %attack.target) }
  if ($3 = shadowcopy) { $skill.clone($1) }  
  if ($3 = steal) { $skill.steal($1, %attack.target, !steal) } 
  if ($3 = analysis) { $skill.analysis($1, %attack.target) } 
  if ($3 = quicksilver) { $skill.quicksilver($1) } 
  if ($3 = cover) { $skill.cover($1, %attack.target) } 
  if ($3 = aggressor) { $skill.aggressor($1) } 
  if ($3 = defender) { $skill.defender($1) }
  if ($3 = shieldfocus) { $skill.shieldfocus($1) }
  if ($3 = alchemy) { $skill.alchemy($1, %attack.target) } 
  if ($3 = craft) { $skill.craft($1, %attack.target) }  
  if ($3 = holyaura) { $skill.holyaura($1) } 
  if ($3 = provoke) { $skill.provoke($1, %attack.target) }
  if ($3 = weaponlock) { $skill.weaponlock($1, %attack.target) }  
  if ($3 = disarm) { $skill.disarm($1, %attack.target) } 
  if ($3 = konzen-ittai) { $skill.konzen-ittai($1) } 
  if ($3 = sealbreak) { $skill.sealbreak($1) }
  if ($3 = magicmirror) { $skill.magicmirror($1) }
  if ($3 = gamble) { $skill.gamble($1) }
  if ($3 = thirdeye) { $skill.thirdeye($1) }
  if ($3 = barrage) { $skill.barrage($1) }
  if ($3 = doublecast) { $skill.doublecast($1) }
  if ($3 = criticalfocus) { $skill.criticalfocus($1) }
  if ($3 = scavenge) { $skill.scavenge($1) }
  if ($3 = perfectcounter) { $skill.perfectcounter($1) }
  if ($3 = justrelease) { $skill.justrelease($1, %attack.target, !justrelease) } 
  if ($3 = retaliation) { $skill.retaliation($1) } 
  if (($3 = lockpicking) || ($3 = lockpick)) { $skill.lockpicking($1) } 
  if ($3 = stoneskin) { $skill.stoneskin($1) }
  if ($3 = tabularasa) { $skill.tabularasa($1, %attack.target) }
  if ($3 = snatch) { $skill.snatch($1, %attack.target) }
  if ($3 = warp) { $skill.warp($1, %attack.target-) } 
  if ($3 = wrestle) { $skill.wrestle($1, %attack.target) }
  if ($3 = invigorate) { $skill.invigorate($1) }
  if ($3 = ThrillOfBattle) { $skill.thrillofbattle($1) } 
  if ($3 = duality) { $skill.duality($1) }
  if ($3 = quickpockets) { $skill.quickpockets($1) }
  if ($3 = LucidDreaming) { $skill.luciddreaming($1) }

  ; Below are monster-only skills

  if ($3 = magicshift) { $skill.magic.shift($1) }
  if ($3 = demonportal) { $skill.demonportal($1) }
  if ($3 = cocoon) { $skill.cocoon.evolve($1) }
  if ($3 = cocoonevolve) { $skill.cocoon.evolve($1) }
  if ($3 = monsterconsume) { $skill.monster.consume($1, %attack.target) }
  if ($3 = repairNaturalArmor) { $skill.monster.repairnaturalarmor($1, %attack.target) }
  if ($3 = flying) { $skill.flying($1) }
  if ($3 = weaknessshift) { $skill.weaknessshift($1) }
}

;=================
; This alias checks
; to see how many
; action points a skill
; consumes
;=================
alias skill.actionpointcheck {
  var %action.points.consumed $readini($dbfile(skills.db), $1, ActionPoints)
  if (%action.points.consumed = $null) { return 1 }
  else { return %action.points.consumed }
}

;=================
; This alias will return
; true if instant=true
; is set in the skill.
;=================
alias skill.instantcheck {
  ; $1 = the skill name
  if ($readini($dbfile(skills.db), $1, Instant) = true) { return true }
  else { return false }
}

;=================
; This alias will move 
; onto the next turn if
; the skill is not instant.
;=================
alias skill.nextturn.check {
  ; $1 the skill name
  ; $2 the user

  if ($skill.instantcheck($1) = true) { $display.message(12 $+ $get_chr_name($2) gets another action this turn.,battle) | halt }
  else { 
    if (%battleis = on)  { $check_for_double_turn($2) | halt }
  }
}

;=================
; This alias checks
; to see if a skill can
; be used again
;=================
alias skill.turncheck {
  ; $1 = the person using the skill
  ; $2 = skill name (in db file)
  ; $3 = the skill command
  ; $4 = true/false -> if skill level affects the turn amount

  if (($readini($char($1), info, flag) != $null) && ($readini($char($1), info, clone) != yes)) { return }

  if ($readini($char($1), info, clone) = yes) {
    var %clone.owner $readini($char($1), info, cloneowner) 
    var %clone.owner.style $readini($char(%clone.owner), styles, equipped)
    if (%clone.owner.style != doppelganger) { return }
  }

  var %skill.turns $readini($dbfile(skills.db), $2, cooldown)

  if ($4 = true) { dec %skill.turns $readini($char($1), skills, $2) }

  var %last.turn.used $readini($char($1), skills, $2 $+ .time)

  if (%last.turn.used = $null) { var %next.turn.can.use 0 }
  else { var %next.turn.can.use $calc(%last.turn.used + %skill.turns) }

  if (%true.turn >= %next.turn.can.use) { return }
  else { $set_chr_name($1) | $display.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc(%next.turn.can.use - %true.turn) turns before you can use $3 again) | halt }
}

;=================
; Is a skill equipped?
;=================
alias skill.equipped.check {
  ; $1 = the player
  ; $2 = the skill being checked

  if ($readini($char($1), info, flag) = $null) { 
    var %player.equipped.skills $readini($char($1), skills, equipped)

    ; The skill is equipped and can be used. Return true
    if ($istok(%player.equipped.skills,$2,46) = $true) { return true }

    ; If the skill can be used while in a certain style that the player has equipped, return true
    else if ($return.playerstyle($1) = $readini($dbfile(skills.db), $2, style)) { return true }

    ; Not equipped, not a style skill, return false
    else { return false }
  }
  else { return true }
}

;=================
; Does the skill need
; to be equipped to
; use? returns true/false
;=================
alias skill.needtoequip {
  var %skill.need.equipped $readini($dbfile(skills.db), $1, NeedToEquip)
  if (%skill.need.equipped = $null) { return false }
  else { return %skill.need.equipped }
}

;=================
; SPEED SKILL
;=================
on 3:TEXT:!speed*:*: { $skill.speedup($nick) }

alias skill.speedup { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if (%battle.type = dungeon) { $display.message($readini(translation.dat, errors, Can'tUseThisSkillInDungeon), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, speed) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private) | halt }
  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1)

  var %skill.name Speed
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  if ($readini($char($1), skills, speed.on) = on) { $set_chr_name($1) | $display.message(4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle., private)  | halt }

  if ($readini($char($1), info, flag) = $null) { 
    ; Does the char have enough HP to perform it?
    var %hp.cost.percent $calc(.25 * $readini($char($1), skills, speed))
    if (%hp.cost.percent < 10) { var %hp.cost.percent 10 }
    var %hp.cost $round($return_percentofvalue($readini($char($1), basestats, hp), %hp.cost.percent),0)
    if (%hp.cost >= $readini($char($1), battle, hp)) { $display.message($readini(translation.dat, errors, NotEnoughHPForSkill) ,private) | halt }
    else {  writeini $char($1) battle hp $calc($readini($char($1), battle, hp) - %hp.cost)  }
  }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(speed))

  ; Display the desc. 
  if ($readini($char($1), descriptions, speed) = $null) { set %skill.description forces $gender($1) body to speed up! }
  else { set %skill.description $readini($char($1), descriptions, speed) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills speed.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction speed

  unset %spd.increase | unset %spd.current | unset %spd.original

  $skill.nextturn.check(speed, $1)
}

alias skill.speed.calculate {
  ; Returns the amount of STR that bloodboost gives
  ; $1 = person we're checking

  var %spd.current $readini($char($1), battle, spd)

  ; Find out the increase amount. 
  var %spd.increase $readini($char($1), skills, speed)
  if (%spd.increase = $null) { var %spd.increase 1 }

  if ($augment.check($1, EnhanceSpeed) = true) {
    inc %spd.increase $calc(2 + %augment.strength)
  }

  var %percent.increase $return_percentofvalue(%spd.current, %spd.increase) 

  return %percent.increase
}

alias skill.speed.status {
  ; returns on if on, or off if not
  if ($readini($char($1), skills, speed.on) = on) { return on }
  else { return off }
}

;=================
; ELEMENTAL SEAL
;=================
on 3:TEXT:!elemental seal*:*: { $skill.elementalseal($nick) }
on 3:TEXT:!elementalseal*:*: { $skill.elementalseal($nick) }

alias skill.elementalseal { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ElementalSeal) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1)

  var %skill.name ElementalSeal
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, ElementalSeal, !elemental seal, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(elementalseal))

  ; Display the desc. 
  if ($readini($char($1), descriptions, ElementalSeal) = $null) { set %skill.description uses an ancient technique to enhance $gender($1) next magical spell! }
  else { set %skill.description $readini($char($1), descriptions, ElementalSeal) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the elementalseal-on flag & write the last used time.
  writeini $char($1) skills elementalseal.on on
  writeini $char($1) skills elementalseal.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction elementalseal

  $skill.nextturn.check(ElementalSeal, $1)
}

;=================
; MIGHTY STRIKE
;=================
on 3:TEXT:!mighty strike*:*: { $skill.mightystrike($nick) }
on 3:TEXT:!mightystrike*:*: { $skill.mightystrike($nick) }

alias skill.mightystrike { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, MightyStrike) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }

  $check_for_battle($1)

  var %skill.name MightyStrike
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, MightyStrike, !mighty strike, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(mightystrike))

  ; Display the desc. 
  if ($readini($char($1), descriptions, MightyStrike) = $null) { set %skill.description forces energy into $gender($1) weapon, causing the next blow done with it to be double power }
  else { set %skill.description $readini($char($1), descriptions, MightyStrike) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the flag & write the last used time.
  writeini $char($1) skills mightystrike.on on
  writeini $char($1) skills mightystrike.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction mightystrike

  $skill.nextturn.check(MightyStrike, $1)
}


;=================
; TRUE STRIKE
;=================
on 3:TEXT:!true strike*:*: { $skill.truestrike($nick) }
on 3:TEXT:!truestrike*:*: { $skill.truestrike($nick) }

alias skill.truestrike { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, truestrike) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }

  $check_for_battle($1)

  var %skill.name TrueStrike
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, truestrike, !true strike, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(truestrike))

  ; Display the desc. 
  if ($readini($char($1), descriptions, truestrike) = $null) { set %skill.description focuses intently on $gender($1) target.. }
  else { set %skill.description $readini($char($1), descriptions, truestrike) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the flag & write the last used time.
  writeini $char($1) skills truestrike.on on
  writeini $char($1) skills truestrike.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction truestrike

  $skill.nextturn.check(TrueStrike, $1)
}

;=================
; MANA WALL
;=================
on 3:TEXT:!mana wall*:*: { $skill.manawall($nick) }
on 3:TEXT:!manawall*:*: { $skill.manawall($nick) }

alias skill.manawall { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ManaWall) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name ManaWall
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, ManaWall, !mana wall, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(manawall))

  ; Display the desc. 
  if ($readini($char($1), descriptions, ManaWall) = $null) { set %skill.description uses an ancient technique to produce a powerful magic-blocking barrier around $gender($1) body! }
  else { set %skill.description $readini($char($1), descriptions, ManaWall) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the ManaWall-on flag & write the last used time.
  writeini $char($1) skills ManaWall.on on
  writeini $char($1) skills ManaWall.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction manawall

  $skill.nextturn.check(ManaWall, $1)
}

;=================
; ROYAL GUARD
;=================
on 3:TEXT:!royal guard*:*: { $skill.royalguard($nick) }
on 3:TEXT:!royalguard*:*: { $skill.royalguard($nick) }

alias skill.royalguard { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, royalguard) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name RoyalGuard
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, RoyalGuard, !royal guard, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(royalguard))

  ; Display the desc. 
  if ($readini($char($1), descriptions, royalguard) = $null) { set %skill.description uses an ancient style to negate the next melee attack towards $gender2($1) }
  else { set %skill.description $readini($char($1), descriptions, royalguard) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the royalguard-on flag & write the last used time.
  writeini $char($1) skills royalguard.on on
  writeini $char($1) skills royalguard.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction royalguard

  $skill.nextturn.check(RoyalGuard, $1)
}


;=================
; LOCKPICKING
;=================
on 3:TEXT:!lockpick*:*: { $skill.lockpicking($nick) }
on 3:TEXT:!lockpicking*:*: { $skill.lockpicking($nick) }

alias skill.lockpicking { $set_chr_name($1)
  if ($skillhave.check($1, lockpicking) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = on) { $display.message($readini(translation.dat, errors, Can'tUseSkillInBattle), private) | halt }

  ; Is there a treasure chest to even open?
  var %chest.color $readini($txtfile(treasurechest.txt), ChestInfo, Color)
  if (%chest.color = $null) { $display.message($readini(translation.dat, errors, NoChestExists), private) | halt }

  ; Has the person already tried to lockpick the chest?
  if ($readini($char($1), skills, lockpicking.on) != $null) { $display.message($readini(translation.dat,skill, LockpickingInUse), private) | halt }

  ; Check to see if the chest is already being unlocked.
  if (%keyinuse = true) { $display.message($readini(translation.dat, errors, ChestAlreadyBeingOpened), private) | halt }

  ; Prevent lockpicks
  if ($readini($txtfile(treasurechest.txt), chestInfo, Contents) = RedOrbs) { $display.message($readini(translation.dat, errors, LockPickCan'tBeUsedOnRedChests), private) | halt }

  ; Check to see if the user has enough lockpicks.
  set %check.item $readini($char($1), item_amount, lockpick)
  if ((%check.item = $null) || (%check.item <= 0)) { $set_chr_name($1) | $display.message(4Error: %real.name does not have enough lockpicks to perform this skill, private) | halt }
  $decrease_item($1, lockpick) 

  set %keyinuse true

  ; Display the desc. 
  if ($readini($char($1), descriptions, lockpicking) = $null) { set %skill.description kneels down in front of the chest and pulls out a lockpick.  Carefully, %real.name attempts to unlock the chest. }
  else { set %skill.description $readini($char($1), descriptions, lockpicking) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, public)  | unset %skill.description

  ; Toggle the royalguard-on flag & write the last used time.
  writeini $char($1) skills lockpicking.on on

  var %skill.level $readini($char($1), skills, lockpicking)
  var %lockpicking.chance $calc(3 * %skill.level)
  var %chest.open.chance $rand(1,100)

  if (%chest.open.chance <= %lockpicking.chance) {
    ; Open the chest.
    $item.open.chest($1)
  }
  if (%chest.open.chance > %lockpicking.chance) { 
    ;  Lockpicking failed.
    $display.message($readini(translation.dat, skill, LockpickingFailed), public)
    unset %keyinuse 
    halt
  }
}

;=================
; PERFECT DEFENSE
;=================
on 3:TEXT:!perfect defense:*: { $skill.perfectdefense($nick) }
on 3:TEXT:!perfectdefense:*: { $skill.perfectdefense($nick) }

alias skill.perfectdefense { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, perfectdefense) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }

  $check_for_battle($1)

  var %skill.name PerfectDefense
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, perfectdefense, !perfect defense, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(perfectdefense))

  ; Display the desc. 
  if ($readini($char($1), descriptions, perfectdefense) = $null) { set %skill.description is covered by a powerful barrier that will reduce the next attack done to 0 }
  else { set %skill.description $readini($char($1), descriptions, perfectdefense) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the flag & write the last used time.
  writeini $char($1) skills perfectdefense.on on
  writeini $char($1) skills perfectdefense.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction perfectdefense

  $skill.nextturn.check(PerfectDefense, $1)
}

;=================
; UTSUSEMI
;=================
on 3:TEXT:!utsusemi*:*: { $skill.utsusemi($nick) }

alias skill.utsusemi { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, utsusemi) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Utsusemi
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Utsusemi, !utsusemi, true)

  ; Check for the item "Shihei" and consume it, or display an error if they don't have any.
  set %check.item $readini($char($1), item_amount, shihei)
  if ((%check.item = $null) || (%check.item <= 0)) { $set_chr_name($1) | $display.message(4Error: %real.name does not have enough shihei to perform this skill, private) | halt }
  $decrease_item($1, Shihei) 

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(utsusemi))

  ; Display the desc. 
  if ($readini($char($1), descriptions, utsusemi) = $null) { set %skill.description uses an ancient ninjutsu technique to create shadow copies to absorb attacks. }
  else { set %skill.description $readini($char($1), descriptions, utsusemi) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the utsusemi-on flag & write the last used time.
  writeini $char($1) skills utsusemi.on on
  writeini $char($1) skills utsusemi.time %true.turn

  var %number.of.shadows 2

  if ($augment.check($1, UtsusemiBonus) = true) {  inc %number.of.shadows 2  }
  if ($return.potioneffect($1) = Utsusemi Bonus) { var %number.of.shadows 6 }

  writeini $char($1) skills utsusemi.shadows %number.of.shadows

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction utsusemi

  $skill.nextturn.check(Utsusemi, $1)
}

;=================
; FULL BRING SKILL
;=================
on 3:TEXT:!fullbring*:*: { $skill.fullbring($nick, $2) }

alias skill.fullbring { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  $set_chr_name($1) | $amnesia.check($1, skill) 

  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { unset %check.item | $set_chr_name($1) | $display.message(4Error: %real.name does not have that item., private) | halt }

  set %fullbring.check $readini($char($1), skills, fullbring) | set %fullbring.needed $readini($dbfile(items.db), $2, FullbringLevel)
  if (%fullbring.needed > %fullbring.check) { $display.message(4Error: %real.name does not have a high enough Fullbring skill level to perform Fullbring on this item!, private) | halt }

  $check_for_battle($nick)
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }

  var %skill.name FullBring
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  set %fullbring.type $readini($dbfile(items.db), $2, type) | set %fullbring.target $readini($dbfile(items.db), $2, FullbringTarget)

  if (%fullbring.target = $null) { unset %check.item | $display.message(4Error: This item does not have a fullbring ability attached to it!, private) | halt }
  $decrease_item($nick, $2)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(fullbring))

  if (%fullbring.type = heal) {
    if (%fullbring.target = AOE) { $fullbring.aoeheal($1, $2) }
    else { $fullbring.singleheal($1, $2, $1) }
  }

  if (%fullbring.type = status) {
    $fullbring.aoestatus($1, $2) 
  }

  if (%fullbring.type = damage) { 
    $fullbring.aoedamage($1, $2)
  }

  if (%fullbring.type = tp) { 
    $fullbring.aoetp($1, $2)
  }

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction fullbring

  $skill.nextturn.check(Fullbring, $1)
}

alias fullbring.singleheal { 
  ; $1 = user
  ; $2 = item
  ; $3 = target

  ; Display the fullbring desc
  $display.message(3 $+ %user  $+ $readini($dbfile(items.db), $2, Fullbringdesc), battle)

  set %attack.damage 0

  ; First things first, let's find out the base power.
  var %item.base $readini($dbfile(items.db), $2, FullbringAmount)
  inc %attack.damage %item.base

  ; Increase the amount if the player's fullbring level is over the item's fullbring level
  var %fullbring.level.diff $calc($readini($char($1), skills, Fullbring) - $readini($dbfile(items.db), $2, FullbringLevel))
  var %fullbring.item.increase $calc(%fullbring.level.diff * %attack.damage)
  inc %attack.damage %fullbring.item.increase

  ; If the person has the FieldMedic skill, increase the amount.
  var %field.medic.skill $readini($char($1), skills, FieldMedic) 
  if (%field.medic.skill != $null) {
    var %skill.increase.amount $calc(5 * %field.medic.skill)
    inc %attack.damage %skill.increase.amount
  }

  ; Increase by a percent of the log of the arena level
  var %percent.increase $log($return_winningstreak)
  inc %attack.damage $round($return_percentofvalue(%attack.damage, %percent.increase),0)

  ; Let's increase by a random amount.
  inc %attack.damage $rand(1,10)

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ;If the target is a zombie, do damage instead of healing it.
  if ($readini($char($3), status, zombie) = yes) { 
    $deal_damage($1, $3, $2)
    $display_damage($1, $3, fullbring, $2)
  } 

  else {   

    ; If the target has max hp we don't need to heal them 
    if ($readini($char($3), battle, hp) >= $readini($char($3), basestats, hp)) { set %attack.damage 0 } 

    ; If the amount being healed is more than the target's max HP, set the max to the HP max
    if (%attack.damage > $readini($char($3), basestats, hp)) { set %attack.damage $readini($char($3), basestats, hp) }

    $heal_damage($1, $3, $2)
    $display_heal($1, $3, fullbring, $2)
  }
}

alias fullbring.calcheal {
  ; First things first, let's find out the base power.
  var %item.base $readini($dbfile(items.db), $2, FullbringAmount)
  inc %attack.damage %item.base

  ; Increase the amount if the player's fullbring level is over the item's fullbring level
  var %fullbring.level.diff $calc($readini($char($1), skills, Fullbring) - $readini($dbfile(items.db), $2, FullbringLevel))
  var %fullbring.item.increase $calc(%fullbring.level.diff * %attack.damage)
  inc %attack.damage %fullbring.item.increase

  ; If the person has the FieldMedic skill, increase the amount.
  var %field.medic.skill $readini($char($1), skills, FieldMedic) 
  if (%field.medic.skill != $null) {
    var %skill.increase.amount $calc(5 * %field.medic.skill)
    inc %attack.damage %skill.increase.amount
  }

  ; Increase by a percent of the log of the arena level
  var %percent.increase $log($return_winningstreak)
  inc %attack.damage $round($return_percentofvalue(%attack.damage, %percent.increase),0)

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }
}

alias fullbring.aoeheal {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0

  set %wait.your.turn on
  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  $display.message(3 $+ %user  $+ $readini($dbfile(items.db), $2, Fullbringdesc), battle)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
    else { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
      else { 
        inc %number.of.hits 1

        set %attack.damage 0
        $fullbring.calcheal($1, $2, $3)

        ;If the target is a zombie, do damage instead of healing it.
        if ($readini($char(%who.battle), status, zombie) = yes) { 
          $deal_damage($1, %who.battle, $2)
          $display_damage($1, %who.battle, fullbring, $2)
        } 

        else {   
          ; If the target has max hp we don't need to heal them 
          if ($readini($char(%who.battle), battle, hp) >= $readini($char(%who.battle), basestats, hp)) { set %attack.damage 0 } 

          ; If the amount being healed is more than the target's max HP, set the max to the HP max
          if (%attack.damage > $readini($char(%who.battle), basestats, hp)) { set %attack.damage $readini($char(%who.battle), basestats, hp) }

          $heal_damage($1, %who.battle, $2)
          $display_heal($1, %who.battle, fullbring, $2)
        }

        inc %battletxt.current.line 1 
      } 
    }
  }


  return
}

alias fullbring.aoestatus {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0
  set %wait.your.turn on

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  $display.message(3 $+ %user  $+ $readini($dbfile(items.db), $2, Fullbringdesc), battle)

  ; Get the fullbring status type
  set %fullbring.status $readini($dbfile(items.db), $2, StatusType)

  if (%fullbring.status = stop) { set %status.type stop | var %tech.status.grammar frozen in time }
  if (%fullbring.status = poison) { set %status.type poison | var %tech.status.grammar poisoned }
  if (%fullbring.status = silence) { set %status.type silence | var %tech.status.grammar silenced }
  if (%fullbring.status = blind) { set %status.type blind | var %tech.status.grammar blind }
  if (%fullbring.status = virus) { set %status.type virus | var %tech.status.grammar inflicted with a virus }
  if (%fullbring.status = amnesia) { set %status.type amnesia | var %tech.status.grammar inflicted with amnesia }
  if (%fullbring.status = paralysis) { set %status.type paralysis | var %tech.status.grammar paralyzed }
  if (%fullbring.status = zombie) { set %status.type zombie | var %tech.status.grammar a zombie }
  if (%fullbring.status = slow) { set %status.type slow | var %tech.status.grammar slowed }
  if (%fullbring.status = stun) { set %status.type stun | var %tech.status.grammar stunned }
  if (%fullbring.status = curse) { set %status.type curse | var %tech.status.grammar cursed }
  if (%fullbring.status = charm) { set %status.type charm | var %tech.status.grammar charmed }
  if (%fullbring.status = intimidate) { set %status.type intimidate | var %tech.status.grammar intimidated }
  if (%fullbring.status = defensedown) { set %status.type defensedown | var %tech.status.grammar inflicted with defense down }
  if (%fullbring.status = strengthdown) { set %status.type strengthdown | var %tech.status.grammar inflicted with strength down }
  if (%fullbring.status = intdown) { set %status.type intdown | var %tech.status.grammar inflicted with int down }
  if (%fullbring.status = petrify) { set %status.type petrify  | var %tech.status.grammar petrified }
  if (%fullbring.status = bored) { set %status.type bored | var %tech.status.grammar bored of the battle  }
  if (%fullbring.status = confuse) { set %status.type confuse  | var %tech.status.grammar confused }
  if (%fullbring.status = removeboost) { set %status.type removeboost | var %tech.status.grammar no longer boosted }

  if (%tech.status.grammar = $null) { echo -a 4Invalid status type: $3 | return }

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
    else { 
      inc %number.of.hits 1
      set %current.status $readini($char(%who.battle), battle, status)

      if (%current.status != dead) { 
        if ($readini($char(%who.battle), skills, utsusemi.on) = on) { set %chance 0  } 
        $calculate_damage_items($1, $2, %who.battle, fullbring)
        $deal_damage($1, %who.battle, $2)

        ; Check for resistance to that status type.
        var %chance $rand(1,100) | $set_chr_name($1) 
        set %resist.have resist- $+ %fullbring.status
        set %resist.skill $readini($char(%who.battle), skills, %resist.have)

        $ribbon.accessory.check(%who.battle)

        if (%status.type = charm) {
          if ($readini($char(%who.battle), status, zombie) != no) { set %resist.skill 100 }
          if ($readini($char(%who.battle), monster, type) = undead) { set %resist.skill 100 }
        }

        if ((%resist.skill != $null) && (%resist.skill > 0)) { 
          if (%resist.skill >= 100) { set %statusmessage.display 4 $+ %real.name is immune to the %fullbring.status status! }
          else { dec %chance %resist.skill }
        }


        if (%chance >= 50) {
          if ((%chance = 50) && (%fullbring.status = poison)) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char(%who.battle) Status poison-heavy yes }
          if ((%chance = 50) && (%fullbring.status != poison)) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char(%who.battle) Status %fullbring.status yes }
          else { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char(%who.battle) Status %fullbring.status yes 
            if (%fullbring.status = charm) { writeini $char(%who.battle) status charmed yes | writeini $char($2) status charmer $1 | writeini $char(%who.battle) status charm.timer $rand(2,3) }
            if (%fullbring.status = curse) { writeini $char(%who.battle) battle tp 0 }
            if (%fullbring.status = removeboost) { 
              if ($readini($char(%who.battle), status, ignition.on) != on) { var %chance 0 }
              if ($readini($char(%who.battle), status, ignition.on) = on) { var %chance 100 | var %ignition.name $readini($char(%who.battle), status, ignition.name) | $revert(%who.battle,%ignition.name) }
            }


          }
        }
        else {
          if (%resist.skill >= 100) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is immune to the %fullbring.status status! }
          if ((%resist.skill  >= 1) && (%resist.skill < 100)) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%fullbring.status) status effect! }
          if ((%resist.skill <= 0) || (%resist.skill = $null)) { $set_chr_name($1) | set %statusmessage.display 4 $+ %real.name $+ 's $lower(%fullbring.status) status effect has failed against $set_chr_name(%who.battle) %real.name $+ ! }
        }


        ; If a monster, increase the resistance.
        if ($readini($char(%who.battle), info, flag) = monster) {
          if (%resist.skill = $null) { set %resist.skill 2 }
          else { inc %resist.skill 2 }
          writeini $char(%who.battle) skills %resist.have %resist.skill
        }
        unset %resist.have | unset %chance

        $display_Statusdamage_item($1, %who.battle, fullbring)
        inc %battletxt.current.line 1 
      }

      if ((%current.status = dead) || (%current.status = runaway)) {  inc %battletxt.current.line 1  }
    } 
  }

  set %timer.time $calc(%number.of.hits * 1) 
  unset %current.status

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

alias fullbring.aoedamage {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0
  set %wait.your.turn on

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  $display.message(3 $+ %user  $+ $readini($dbfile(items.db), $2, Fullbringdesc), battle)

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
    else { 
      inc %number.of.hits 1
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
      else { 
        $calculate_damage_items($1, $2, %who.battle, fullbring)
        $deal_damage($1, %who.battle, $2)
        $display_aoedamage($1, %who.battle, $2)
        inc %battletxt.current.line 1 
      } 
    }
  }

  set %timer.time $calc(%number.of.hits * 1) 

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

alias fullbring.aoetp {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0
  $set_chr_name($1) | set %user %real.name

  set %wait.your.turn on

  ; Display the item description
  set %user $get_chr_name($1)
  set %enemy $get_chr_name($2)
  $display.message(3 $+ %user  $+ $readini($dbfile(items.db), $2, Fullbringdesc), battle)

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle.fullbring $read -l $+ %battletxt.current.line $txtfile(battle.txt)

    if ($readini($char(%who.battle.fullbring), info, flag) != monster) { 
      inc %number.of.hits 1
      var %current.status $readini($char(%who.battle.fullbring), battle, status)
      if ((%current.status != dead) && (%current.status != runaway)) {  

        set %enemy $get_chr_name(%who.battle.fullbring)

        ; calculate amount
        var %tp.amount $readini($dbfile(items.db), $2, fullbringamount)

        ; add TP to the target
        var %tp.current $readini($char(%who.battle.fullbring), battle, tp) 
        inc %tp.current %tp.amount 

        if (%tp.current >= $readini($char(%who.battle.fullbring), basestats, tp)) { writeini $char(%who.battle.fullbring) battle tp $readini($char(%who.battle.fullbring), basestats, tp) }
        else { writeini $char(%who.battle.fullbring) battle tp %tp.current }

        $display.message(3 $+ %enemy has regained %tp.amount TP!, battle)
      }
    }
    inc %battletxt.current.line 1 
  }

  set %timer.time $calc(%number.of.hits * .5) 

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

;=================
; DOUBLE TURN
;=================
on 3:TEXT:!double turn*:*: { $skill.doubleturn($nick) }
on 3:TEXT:!doubleturn*:*: { $skill.doubleturn($nick) }
on 3:TEXT:!sugitekai*:*: { $skill.doubleturn($nick) }

alias skill.doubleturn { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, sugitekai) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Sugitekai
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, sugitekai, !sugitekai, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(sugitekai))

  ; Display the desc. 
  if ($readini($char($1), descriptions, sugitekai) = $null) { set %skill.description becomes very focused and is able to do two actions next round! }
  else { set %skill.description $readini($char($1), descriptions, sugitekai) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the doubleturn-on flag & write the last used time.
  writeini $char($1) skills doubleturn.on on
  writeini $char($1) skills sugitekai.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction sugitekai

  if (%battleis = on) { $next }
}

;=================
; MEDITATE
;=================
on 3:TEXT:!meditate*:*: { $skill.meditate($nick) }

alias skill.meditate { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, meditate) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Meditate
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Meditate, !meditate, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(meditate))

  ; Display the desc. 
  if ($readini($char($1), descriptions, meditate) = $null) { set %skill.description meditates and feel $gender($1) TP being restored.  }
  else { set %skill.description $readini($char($1), descriptions, meditate) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills meditate.time %true.turn

  ; get TP
  var %tp.current $readini($char($1), battle, tp)
  var %tp.max $readini($char($1), basestats, tp)

  ; Find out the increase amount
  var %tp.increase $calc(5 * $readini($char($1), skills, meditate))

  if ($augment.check($1, EnhanceMeditate) = true) { 
    inc %tp.increase $calc(10 * %augment.strength)
  }

  ; increase the tp and make sure it's not over the max
  inc %tp.current %tp.increase

  if (%tp.current >= %tp.max) { $display.message(3 $+ %real.name has restored all of $gender($1) TP!, battle) | writeini $char($1) battle tp %tp.max }
  if (%tp.current < %tp.max) { $display.message(3 $+ %real.name has restored %tp.increase TP!, battle) | writeini $char($1) battle tp %tp.current }

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction meditate

  $skill.nextturn.check(Meditate, $1)
}

;=================
; CONSERVE TP
;=================
on 3:TEXT:!conserve TP*:*: { $skill.conserveTP($nick) }
on 3:TEXT:!conserveTP*:*: { $skill.conserveTP($nick) }

alias skill.conserveTP { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, conserveTP) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name ConserveTP
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, ConserveTP, !conserve tp, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(conserveTP))

  ; Display the desc. 
  if ($readini($char($1), descriptions, conserveTP) = $null) { set %skill.description uses an ancient skill to reduce the cost of $gender($1) next technique to 0. }
  else { set %skill.description $readini($char($1), descriptions, conserveTP) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the conserveTP-on flag & write the last used time.
  writeini $char($1) status conserveTP yes
  writeini $char($1) skills conserveTP.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction conserveTP

  $skill.nextturn.check(ConserveTP, $1)
}

;=================
; THIN AIR
;=================
on 3:TEXT:!thinair*:*: { $skill.thinair($nick) }
on 3:TEXT:!thin air*:*: { $skill.thinair($nick) }

alias skill.thinair { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, thinair) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name thinair
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, thinair, !thin air, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(thinair))

  ; Display the desc. 
  if ($readini($char($1), descriptions, thinair) = $null) { set %skill.description uses an ancient skill to reduce the cost of $gender($1) next spell to 0. }
  else { set %skill.description $readini($char($1), descriptions, thinair) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the thinair-on flag & write the last used time.
  writeini $char($1) skills thinair.on on
  writeini $char($1) skills thinair.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction thinair

  $skill.nextturn.check(ThinAir, $1)
}


;=================
; QUICK POCKETS
;=================
on 3:TEXT:!quickpockets*:*: { $skill.quickpockets($nick) }
on 3:TEXT:!quick pockets*:*: { $skill.quickpockets($nick) }

alias skill.quickpockets { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, quickpockets) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name quickpockets
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, quickpockets, !quick pockets, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(quickpockets))

  ; Display the desc. 
  if ($readini($char($1), descriptions, quickpockets) = $null) { set %skill.description uses an ancient skill to prepare to quickly use an item without consuming a turn. }
  else { set %skill.description $readini($char($1), descriptions, quickpockets) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the quickpockets-on flag & write the last used time.
  writeini $char($1) skills quickpockets.on on
  writeini $char($1) skills quickpockets.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction quickpockets

  $skill.nextturn.check(QuickPockets, $1)
}


;=================
; BLOOD BOOST
;=================
on 3:TEXT:!bloodboost*:*: { $skill.bloodboost($nick) }
on 3:TEXT:!blood boost*:*: { $skill.bloodboost($nick) }

alias skill.bloodboost { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if (%battle.type = dungeon) { $display.message($readini(translation.dat, errors, Can'tUseThisSkillInDungeon), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, bloodboost) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name BloodBoost
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Has bloodboost been used?
  if ($readini($char($1), skills, bloodboost.on) = on) { $display.message($readini(translation.dat, skill, SkillAlreadyUsed), private) | halt }

  if ($readini($char($1), info, flag) = $null) { 
    ; Does the char have enough HP to perform it?
    var %hp.cost.percent $calc(3 * $readini($char($1), skills, bloodboost))
    var %hp.cost $return_percentofvalue($readini($char($1), basestats, hp), %hp.cost.percent)
    if (%hp.cost >= $readini($char($1), battle, hp)) { $display.message($readini(translation.dat, errors, NotEnoughHPForSkill) ,private) | halt }
    else {  writeini $char($1) battle hp $calc($readini($char($1), battle, hp) - %hp.cost)  }
  }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(bloodboost))

  ; Display the desc. 
  if ($readini($char($1), descriptions, bloodboost) = $null) { set %skill.description sacrifices some of $gender($1) blood for raw strength.  }
  else { set %skill.description $readini($char($1), descriptions, bloodboost) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills bloodboost.time %true.turn
  writeini $char($1) skills bloodboost.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction bloodboost

  var %total.bloodboost $readini($char($1), stuff, BloodBoostTimes) 
  if (%total.bloodboost = $null) { var %total.bloodboost 0 }
  inc %total.bloodboost 1 
  writeini $char($1) stuff BloodBoostTimes %total.bloodboost
  $achievement_check($1, BloodGoneDry)

  unset %str.current | unset %str.increase | unset %percent.increase

  $skill.nextturn.check(BloodBoost, $1)
}

alias skill.bloodboost.calculate {
  ; Returns the amount of STR that bloodboost gives
  ; $1 = person we're checking

  var %str.current $readini($char($1), battle, str)

  ; Find out the increase amount. Bloodmoon increases the amount by a random amount.
  var %str.increase $calc(2 * $readini($char($1), skills, bloodboost))

  if (%bloodmoon = on) { inc %str.increase $rand(2,5) }

  if ($augment.check($1, EnhanceBloodboost) = true) {
    inc %str.increase $calc(2 + %augment.strength)
  }

  var %percent.increase $return_percentofvalue(%str.current, %str.increase)

  return %percent.increase
}

alias skill.bloodboost.status {
  ; returns on if on, or off if not
  if ($readini($char($1), skills, bloodboost.on) = on) { return on }
  else { return off }
}

;=================
; BLOOD SPIRIT
;=================
on 3:TEXT:!bloodspirit*:*: { $skill.bloodspirit($nick) }
on 3:TEXT:!blood spirit*:*: { $skill.bloodspirit($nick) }

alias skill.bloodspirit { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if (%battle.type = dungeon) { $display.message($readini(translation.dat, errors, Can'tUseThisSkillInDungeon), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  var %skill.name BloodSpirit
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  $checkchar($1)
  if ($skillhave.check($1, bloodspirit) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  ; Has bloodspirit been used?
  if ($readini($char($1), skills, bloodspirit.time) != $null) { $display.message($readini(translation.dat, skill, SkillAlreadyUsed), private) | halt }

  if ($readini($char($1), info, flag) = $null) { 
    ; Does the char have enough HP to perform it?
    var %hp.cost.percent $calc(3 * $readini($char($1), skills, bloodboost))
    var %hp.cost $return_percentofvalue($readini($char($1), basestats, hp), %hp.cost.percent)
    if (%hp.cost >= $readini($char($1), battle, hp)) { $display.message($readini(translation.dat, errors, NotEnoughHPForSkill) ,private) | halt }
    else {  writeini $char($1) battle hp $calc($readini($char($1), battle, hp) - %hp.cost)  }
  }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(bloodspirit))

  ; Display the desc. 
  if ($readini($char($1), descriptions, bloodspirit) = $null) { set %skill.description sacrifices some of $gender($1) blood for raw intelligence.  }
  else { set %skill.description $readini($char($1), descriptions, bloodspirit) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills bloodspirit.time %true.turn
  writeini $char($1) skills bloodspirit.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction bloodspirit

  ; Check for achievement.
  var %total.BloodSpirit $readini($char($1), stuff, BloodSpiritTimes) 
  if (%total.BloodSpirit = $null) { var %total.BloodSpirit 0 }
  inc %total.BloodSpirit 1 
  writeini $char($1) stuff BloodSpiritTimes %total.BloodSpirit
  $achievement_check($1, BloodGoneToHead)

  unset %int.increase | unset %int.current | unset %percent.increase

  $skill.nextturn.check(BloodSpirit, $1)
}

alias skill.bloodspirit.calculate {
  ; Returns the amount of STR that bloodboost gives
  ; $1 = person we're checking

  var %int.current $readini($char($1), battle, int)

  ; Find out the increase amount. Bloodmoon increases the amount by a random amount.
  var %int.increase $calc(2 * $readini($char($1), skills, bloodspirit))
  if (%bloodmoon = on) { inc %int.increase $rand(2,5) }

  if ($augment.check($1, EnhanceBloodSpirit) = true) {
    inc %int.increase $calc(2 + %augment.strength)
  }

  var %percent.increase $return_percentofvalue(%int.current, %int.increase)
  return %percent.increase
}
alias skill.bloodspirit.status {
  ; returns on if on, or off if not
  if ($readini($char($1), skills, bloodspirit.on) = on) { return on }
  else { return off }
}

;=================
; DRAIN SAMBA
;=================
on 3:TEXT:!drainsamba*:*: { $skill.drainsamba($nick) }
on 3:TEXT:!drain samba*:*: { $skill.drainsamba($nick) }

alias skill.drainsamba { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, drainsamba) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name DrainSamba
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  if ($readini($char($1), info, flag) = $null) { 
    var %tp.needed 15 | var %tp.current $readini($char($1), battle, tp)
    if (%tp.needed > %tp.current) { $display.message(4Error: %real.name does not have enough TP to use this skill!, private) | halt }
  }

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, DrainSamba, !drain samba, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(DrainSamba))

  ; Display the desc. 
  if ($readini($char($1), descriptions, drainsamba) = $null) { set %skill.description performs a powerful samba that activates a draining technique on $gender($1) weapon!   }
  else { set %skill.description $readini($char($1), descriptions, drainsamba) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills drainsamba.time %true.turn

  if ($readini($char($1), info, flag) = $null) { 
    ; Dec the TP
    dec %tp.current %tp.needed
    writeini $char($1) battle tp %tp.current
  }

  writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on on

  $display.message(3 $+ %real.name has gained the drain status for $readini($char($1), skills, drainsamba) melee attacks!, battle)

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction drainsamba

  $skill.nextturn.check(DrainSamba, $1)
}


;=================
; CRITICAL FOCUS
;=================
on 3:TEXT:!criticalfocus*:*: { $skill.criticalfocus($nick) }
on 3:TEXT:!critical focus*:*: { $skill.criticalfocus($nick) }

alias skill.criticalfocus { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, criticalfocus) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name CriticalFocus
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, CriticalFocus, !critical focus, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(CriticalFocus))

  ; Display the desc. 
  if ($readini($char($1), descriptions, criticalfocus) = $null) { set %skill.description becomes hyper focused in this battle.   }
  else { set %skill.description $readini($char($1), descriptions, criticalfocus) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills criticalfocus.time %true.turn
  writeini $char($1) skills criticalfocus.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction criticalfocus

  $skill.nextturn.check(CriticalFocus, $1)
}


;=================
; SHIELD FOCUS
;=================
on 3:TEXT:!shieldfocus*:*: { $skill.shieldfocus($nick) }
on 3:TEXT:!shield focus*:*: { $skill.shieldfocus($nick) }

alias skill.shieldfocus { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, shieldfocus) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name ShieldFocus
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, ShieldFocus, !shield focus, false)

  ; Is the player using a shield?
  var %left.hand.weapon $readini($char($1), weapons, equippedLeft)
  if (%left.hand.weapon = $null) { var %shield.check false }
  var %left.hand.weapon.type $readini($dbfile(weapons.db), %left.hand.weapon, type)
  if (%left.hand.weapon.type != shield) { var %shield.check false }

  if (%shield.check = false) { $display.message(4 $+ $get_chr_name($1) is not using a shield and cannot use this skill at this moment., battle) | halt } 


  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(ShieldFocus))

  ; Display the desc. 
  if ($readini($char($1), descriptions, shieldfocus) = $null) { set %skill.description readies $gender($1) shield in anticipation of the next attack.  }
  else { set %skill.description $readini($char($1), descriptions, shieldfocus) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills shieldfocus.time %true.turn
  writeini $char($1) skills shieldfocus.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction shieldfocus

  $skill.nextturn.check(ShieldFocus, $1)
}


;=================
; BARRAGE
;=================
on 3:TEXT:!barrage*:*: { $skill.Barrage($nick) }

alias skill.barrage { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, Barrage) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Barrage
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Barrage, !barrage, false)

  ; Is the player using a ranged weapon?
  var %equipped.weapon $readini($char($1), weapons, equipped)
  var %weapon.type $readini($dbfile(weapons.db), %equipped.weapon, type)
  if (((%weapon.type != bow) && (%weapon.type != gun) && (%weapon.type != rifle))) { $display.message(4 $+ $get_chr_name($1) is not using a ranged weapon and cannot use this skill at this moment., battle) | halt } 

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(Barrage))

  ; Display the desc. 
  if ($readini($char($1), descriptions, Barrage) = $null) { set %skill.description prepares to send the next volley of ranged attacks at a faster pace.  }
  else { set %skill.description $readini($char($1), descriptions, Barrage) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills Barrage.time %true.turn
  writeini $char($1) skills Barrage.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction Barrage

  $skill.nextturn.check(Barrage, $1)
}

;=================
; Doublecast
;=================
on 3:TEXT:!doublecast*:*: { $skill.doublecast($nick) }

alias skill.doublecast { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, doublecast) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name doublecast
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, doublecast, !doublecast, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(doublecast))

  ; Display the desc. 
  if ($readini($char($1), descriptions, doublecast) = $null) { set %skill.description uses ancient wisdom to prepare to send two of the next spell at $gender($1) target.  }
  else { set %skill.description $readini($char($1), descriptions, doublecast) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills doublecast.time %true.turn
  writeini $char($1) skills doublecast.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction doublecast

  $skill.nextturn.check(DoubleCast, $1)
}


;=================
; duality
;=================
on 3:TEXT:!duality*:*: { $skill.duality($nick) }

alias skill.duality { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, duality) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name duality
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, duality, !duality, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(duality))

  ; Display the desc. 
  if ($readini($char($1), descriptions, duality) = $null) { set %skill.description uses ancient wisdom to increase the leathality of $gender($1) next single-target technique }
  else { set %skill.description $readini($char($1), descriptions, duality) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills duality.time %true.turn
  writeini $char($1) skills duality.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction duality

  $skill.nextturn.check(Duality, $1)
}

;=================
; Invigorate
;=================
on 3:TEXT:!invigorate*:*: { $skill.invigorate($nick) }

alias skill.invigorate { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, invigorate) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name invigorate
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, invigorate, !invigorate, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(invigorate))

  ; Display the desc. 
  if ($readini($char($1), descriptions, invigorate) = $null) { set %skill.description uses an ancient battle tactic to restore some of $gender($1) missing TP.  }
  else { set %skill.description $readini($char($1), descriptions, invigorate) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills invigorate.time %true.turn

  ; write last action
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction invigorate

  ; Restore 200 TP
  $restore_tp($1, 200)

  ; Display a message
  $display.message(3 $+ $get_chr_name($1) restores2 200 3TP, battle)

  $skill.nextturn.check(Invigorate, $1)
}

;=================
; Thrill Of Battle
;=================
on 3:TEXT:!thrillofbattle*:*: { $skill.thrillofbattle($nick) }
on 3:TEXT:!thrill of battle*:*: { $skill.thrillofbattle($nick) }

alias skill.thrillofbattle { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, thrillofbattle) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name thrillofbattle
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, thrillofbattle, !thrillofbattle, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(thrillofbattle))

  ; Display the desc. 
  if ($readini($char($1), descriptions, thrillofbattle) = $null) { set %skill.description uses an ancient battle tactic to gain HP and keep this battle going! }
  else { set %skill.description $readini($char($1), descriptions, thrillofbattle) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills thrillofbattle.time %true.turn

  ; write last action
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction thrillofbattle

  ; Restore some missing HP
  $restore_hp($1, 500)

  ; Give +100 HP on top of that.
  var %current.hp $readini($char($1), battle, HP)
  if (%current.hp = $readini($char($1), basestats, hp)) { var %max.hp true }
  inc %current.hp 100
  writeini $char($1) battle HP %current.hp

  ; Display a message
  if (%max.hp = true) { $display.message(3 $+ $get_chr_name($1) has restored2 5003 base HP and gained2 100 3temporary Max HP, battle) }
  else { $display.message(3 $+ $get_chr_name($1) restores2 600 3HP, battle) }

  $skill.nextturn.check(ThrillOfBattle, $1)
}

;=================
; FORMLESS STRIKE
;=================
on 3:TEXT:!formless strike*:*: { $skill.formlessstrike($nick) }
on 3:TEXT:!formlessstrike*:*: { $skill.formlessstrike($nick) }

alias skill.formlessstrike { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, formlessstrike) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name FormlessStrike
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  if ($readini($char($1), info, flag) = $null) { 
    set %tp.current $readini($char($1), battle, tp) | set %tp.needed $round($calc(%tp.current * .50),0)
    if (%tp.needed > %tp.current) { unset %tp.current | unset %tp.needed | $display.message(4Error: %real.name does not have enough TP to use this skill!, private) | halt }
  }

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, FormlessStrike, !formless strike, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(FormlessStrike))

  ; Display the desc. 
  if ($readini($char($1), descriptions, formlessstrike) = $null) { set %skill.description channels some of $gender($1) TP into $gender($1) weapon, activing a power that can hurt ethereal beings.  }
  else { set %skill.description $readini($char($1), descriptions, formlessstrike) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills formlessstrike.time %true.turn

  if ($readini($char($1), info, flag) = $null) { 
    ; Dec the TP
    dec %tp.current %tp.needed
    writeini $char($1) battle tp %tp.current
    unset %tp.current | unset %tp.needed
  }

  writeini $char($1) skills formlessstrike.turn 1 | writeini $char($1) skills formlessstrike.on on

  $display.message(3 $+ %real.name has gained the hurt ethereal status for $readini($char($1), skills, formlessstrike) melee attacks!, battle)

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction formlessstrike

  $skill.nextturn.check(FormlessStrike, $1)
}

;=================
; REGEN
;=================
on 3:TEXT:!regen*:*: { $skill.regen($nick) }
on 3:TEXT:!regeneration*:*: { $skill.regen($nick) }
on 3:TEXT:!stop regen*:*: { $skill.regen.stop($nick) } 

alias skill.regen { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  $amnesia.check($1, skill) 

  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)
  if ($skillhave.check($1, regen) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }

  var %skill.name Regen
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  set %current.hp $readini($char($1), Battle, HP)  |  set %max.hp $readini($char($1), BaseStats, HP)

  if ($readini($char($1), Status, PotionEffect) = Double Life) { set %max.hp $calc(%max.hp * 2) } 

  if (%current.hp >= %max.hp) { $set_chr_name($1) | $display.message(3 $+ %real.name is already at full HP!, private) | unset %current.hp | unset %max.hp | halt }

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Regen, !regen, false)

  ; write the last used time.
  writeini $char($1) skills regen.time %true.turn

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(regen))

  if ($readini($char($1), descriptions, regen) = $null) { set %skill.description has gained the regeneration effect.  }
  else { set %skill.description $readini($char($1), descriptions, regen) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  var %regen.amount $skill.regen.calculate($1)
  inc %current.hp %regen.amount
  writeini $char($1) Battle HP %current.hp

  if ($readini($char($1), status, ignition.on) = on) {
    var %max.hp $round($calc($readini($char($1), basestats, hp) * $readini($dbfile(ignitions.db), $readini($char($1), status, ignition.name), hp)),0)
  }

  if (%current.hp >= %max.hp) { writeini $char($1) Battle HP %max.hp | $display.message(12 $+ %real.name has regenerated all of $gender($1) HP!, battle)
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }
  else { 
    $set_chr_name($1) | $display.message(12 $+ %real.name has regenerated %regen.amount HP!, battle)
    writeini $char($1) Status Regenerating yes | goto regenhalt 
  }
  :regenhalt
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction regen
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
  else { halt }
}

alias skill.regen.calculate {
  var %max.hp $readini($char($1), basestats, hp)

  if ($readini($char($1), Status, PotionEffect) = Double Life) { var %max.hp $calc(%max.hp * 2) } 

  var %skill.level $readini($char($1), skills, regen)
  if (%skill.level = $null) { var %skill.level 1 }
  set %amount $return_percentofvalue(%max.hp, %skill.level)
  set %amount $round($calc(%amount / 2),0)
  return %amount
}

alias skill.TPregen.calculate {
  return 5
}

alias skill.zombieregen.calculate {
  var %temp.winning.streak $return_winningstreak

  var %difficulty $readini($txtfile(battle2.txt), BattleInfo, Difficulty)
  inc %temp.winning.streak %difficulty

  if (%battle.type = ai) { var %temp.winning.streak %ai.battle.level }

  if (%temp.winning.streak < 10) { set %amount $rand(1,10) }
  if ((%temp.winning.streak >= 10) && (%temp.winning.streak < 50)) { set %amount $rand(20,50) }
  if ((%temp.winning.streak >= 50) && (%temp.winning.streak < 100)) { set %amount $rand(50,100) }
  if ((%temp.winning.streak >= 100) && (%temp.winning.streak < 300)) { set %amount $rand(75, 150) }
  if ((%temp.winning.streak >= 300) && (%temp.winning.streak <= 500)) { set %amount $rand(150, 250) }
  if (%temp.winning.streak > 500) { set %amount $rand(350,600) }

  return %amount
}

alias skill.tpregen {
  set %current.tp $readini($char($1), Battle, TP)  |  set %max.tp $readini($char($1), BaseStats, TP)
  if (%current.tp >= %max.tp) { $set_chr_name($1) | $display.message(3 $+ %real.name is already at full TP!, private) | halt }

  if ($readini($char($1), descriptions, TPregen) = $null) { set %skill.description has gained the tp regeneration effect.  }
  else { set %skill.description $readini($char($1), descriptions, TPregen) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  var %regen.amount $skill.TPregen.calculate($1)
  inc %current.tp %regen.amount
  writeini $char($1) Battle TP %current.tp
  if (%current.tp > %max.tp) { writeini $char($1) Battle TP %max.tp | $display.message(12 $+ %real.name has regenerated all of $gender($1) TP!, battle)
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }
  else { 
    $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.desc) | $display.message(12 $+ %real.name has regenerated %regen.amount TP!, battle)
    writeini $char($1) Status TPRegenerating yes | goto regenhalt 
  }
  :regenhalt
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
  else { halt }
}

alias skill.regen.stop {
  set %check $readini($char($1), Status, regenerating)
  if (%check = yes) { writeini $char($1) Status Regenerating no | $set_chr_name($1) | $display.message(3 $+ %real.name stops regenerating, battle) | halt }
  else { $set_chr_name($1) | $display.message(4Error: %real.name is not regenerating!, private) | halt }
}

;=================
; KIKOUHENI
;=================
on 3:TEXT:!kikouheni*:*: { $skill.kikouheni($nick, $2) }

alias skill.kikouheni { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, kikouheni) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Kikouheni
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  var %weather.list $readini($dbfile(battlefields.db), weather, list)
  if ($2 !isin %weather.list) {
    if ($chr(046) isin %weather.list) { set %replacechar $chr(044) $chr(032)
      var %weather.list $replace(%weather.list, $chr(046), %replacechar)
    }

    $display.private.message2($1, 4Error: Not a valid weather.  Valid weather types are: %weather.list ) | halt
  }

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Kikouheni, !kikouheni, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(kikouheni))

  ; Display the desc. 
  if ($readini($char($1), descriptions, kikouheni) = $null) { set %skill.description summons a mystical power that changes the weather! }
  else { set %skill.description $readini($char($1), descriptions, kikouheni) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills kikouheni.time %true.turn

  writeini $dbfile(battlefields.db) weather current $2 
  $display.message(3The weather has changed! It is currently $2, battle)
  %battleconditions = $addtok(%battleconditions, weather-lock, 46)

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction kikouheni

  $skill.nextturn.check(Kikouheni, $1)
}

;=================
; SHADOW COPY (cloning)
;=================
on 3:TEXT:!clone*:*: { $skill.clone($nick) }
on 3:TEXT:!shadowcopy*:*: { $skill.clone($nick) }
on 3:TEXT:!shadow copy*:*: { $skill.clone($nick) }

alias skill.clone { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if (%battle.type = dungeon) { $display.message($readini(translation.dat, errors, Can'tUseThisSkillInDungeon), private) | halt }
  if (%battle.type = dragonhunt) { $display.message($readini(translation.dat, errors, Can'tUseThisSkillInDragonHunt), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  if ((no-playerclones isin %battleconditions) && ($readini($char($1), info, flag) = $null)) {  $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  $amnesia.check($1, skill) 

  var %skill.name ShadowCopy
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  if (%mode.pvp = on) { $display.message($readini(translation.dat, errors, ActionDisabledForPVP), private) | halt }

  $checkchar($1)
  if ($skillhave.check($1, shadowcopy) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  if (($readini($char($1), info, flag) = $null) && ($readini($char($1 $+ _summon), battle, hp) != $null)) { $display.message($readini(translation.dat, errors, CanOnlyUseSummonOrDoppel), private) | halt }
  if (($isfile($char($1 $+ _clone)) = $true) && ($readini($char($1), info, ClonesCanClone) != true)) { $set_chr_name($1) | $display.message(4Error: %real.name has already used this skill for this battle and cannot use it again!, private) | halt }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(shadowcopy))

  ; Display the desc. 
  if ($readini($char($1), descriptions, shadowcopy) = $null) { set %skill.description releases $gender($1) shadow, which comes to life as a clone, ready to fight. }
  else { set %skill.description $readini($char($1), descriptions, shadowcopy) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Check for command access
  var %player.access.list $readini($char($1), access, list)
  if (%player.access.list = $null) { writeini $char($1) access list $1 }

  .copy $char($1) $char($1 $+ _clone)
  if ($readini($char($1), info, flag) = $null) { writeini $char($1 $+ _clone) info flag npc }
  writeini $char($1 $+ _clone) info clone yes 
  writeini $char($1 $+ _clone) info cloneowner $1

  var %clones.made $readini($char($1), info, CloneNumber)
  if (%clones.made = $null) { var %clones.made 0 } 
  inc %clones.made 1 
  writeini $char($1 $+ _clone) info CloneNumber %clones.made

  if ($2 = $null) {  writeini $char($1 $+ _clone) basestats name Clone of %real.name }
  if ($2 != $null) { writeini $char($1 $+ _clone) basestats name $2- }

  set %curbat $readini($txtfile(battle2.txt), Battle, List)
  %curbat = $addtok(%curbat,$1 $+ _clone,46)
  writeini $txtfile(battle2.txt) Battle List %curbat
  write $txtfile(battle.txt) $1 $+ _clone

  set %current.hp $readini($char($1 $+ _clone), battle, hp)
  if ($readini($char($1), info, flag) = $null) {
    set %current.playerstyle $readini($char($1), styles, equipped)
    set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
    if (%current.playerstyle != Doppelganger) { set %hp $round($calc(%current.hp / 2.5),0) }
    if (%current.playerstyle = Doppelganger) { 
      var %value $calc(2 - (%current.playerstyle.level * .1)) 
      if (%value < 1) { var %value 1 } 
      set %hp $round($calc(%current.hp / %value),0) 
    }
  }

  if ($readini($char($1), info, flag) = npc) {
    set %hp $round($calc(%current.hp / 1.8),0)
    writeini $char($1) skills shadowcopy 0

    if (%battle.type = ai) {
      var %total.players $readini($txtfile(battle2.txt), BattleInfo, Players)
      inc %total.players 1
      writeini $txtfile(battle2.txt) BattleInfo Players %total.players
    }

  }

  if ($readini($char($1), info, flag) = monster) { 
    set %hp $round($calc(%current.hp / 1.5),0)
    writeini $char($1) skills shadowcopy 0
    var %number.of.monsters $readini($txtfile(battle2.txt), BattleInfo, Monsters)
    inc %number.of.monsters 1
    writeini $txtfile(battle2.txt) battleinfo monsters %number.of.monsters
  }

  if (%hp <= 1) { set %hp 1 }

  if ($readini($char($1 $+ _clone), status, ignition.on) = on) { $revert($1 $+ _clone, $readini($char($1 $+ _clone), status, ignition.name)) }
  if ($readini($char($1 $+ _clone), styles, equipped) = doppelganger) { 
    var %style.chance $rand(1,3)
    if (%style.chance = 1) { writeini $char($1 $+ _clone) styles equipped trickster }
    if (%style.chance = 2) { writeini $char($1 $+ _clone) styles equipped guardian }
    if (%style.chance = 3) { writeini $char($1 $+ _clone) styles equipped weaponmaster }
  }

  unset %current.playerstyle | unset %current.playerstyle.level

  writeini $char($1 $+ _clone) battle hp %hp
  writeini $char($1 $+ _clone) basestats hp %hp
  writeini $char($1 $+ _clone) info password .8V%N)W1T;W5C:'1H:7,`1__.114
  writeini $char($1 $+ _clone) info CanTaunt false
  writeini $char($1 $+ _clone) skills shadowcopy 0

  if (($readini($char($1 $+ _clone), info, ClonesCanClone) = true) && (%clones.made  <= 5)) { writeini $char($1 $+ _clone) skills shadowcopy 1 }

  remini $char($1 $+ _clone) skills CoverTarget 

  unset %hp

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction shadowcopy

  if (%portal.bonus != true) { writeini $char($1 $+ _clone) info FirstTurn true }

  ; Initialize the action points 
  $action.points($1 $+ _clone, initialize)

  $skill.nextturn.check(ShadowCopy, $1)
}
;=================
; SHADOW CONTROL
;=================
on 3:TEXT:!shadow *:*: { $skill.clonecontrol($nick, $2, $3, $4) }

alias skill.clonecontrol {
  ; $1 = the user of the command
  ; $2 = the command issued
  ; $3 = either the target or the tech/skill to use.
  ; $4 = the target if $3 = tech or skill

  if ($isfile($char($1 $+ _clone)) != $true) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, NoCloneToControl), private) | halt }

  $check_for_battle($1 $+ _clone)

  var %cloneowner $readini($char($1 $+ _clone), info, cloneowner)
  var %style.equipped $readini($char(%cloneowner), styles, equipped)

  if (%style.equipped != doppelganger) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, MustUseDoppelgangerStyleToControl), private) | halt }

  var %shadow.command $2 | $set_chr_name($1 $+ _clone)

  if (($3 = scavenge) || ($3 = steal)) { $display.message($readini(translation.dat, errors, CloneCannotUseSkill), private) | halt }

  if (%shadow.command = skill) { $use.skill($1 $+ _clone, $2, $3, $4) } 
  if (%shadow.command = taunt) {   $partial.name.match($1, $3) | $taunt($1 $+ _clone, %attack.target) }
  if (%shadow.command = attack) {  $partial.name.match($1, $3) | $covercheck(%attack.target) | $attack_cmd($1 $+ _clone , %attack.target) }
  if (%shadow.command = tech) {   $partial.name.match($1, $4) | $tech_cmd($1 $+ _clone, $3, %attack.target) }

}

;=================
; STEAL
;=================
on 3:TEXT:!steal*:*: { $partial.name.match($nick, $2)  | $skill.steal($nick, %attack.target, !steal) }

alias skill.steal { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, steal) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)
  $person_in_battle($2)

  var %skill.name Steal
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  var %target.flag $readini($char($2), info, flag)
  if (%target.flag != monster) { $set_chr_name($1) | $display.message(4 $+ %real.name can only steal from monsters!, private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot steal while unconcious!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot steal from someone who is dead!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $display.message(4 $+ %real.name cannot steal from $set_chr_name($2) %real.name $+ , because %real.name has run away from the fight!, private) | unset %real.name | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Steal, !steal, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(steal))

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($1), descriptions, steal) = $null) { set %skill.description sneaks around to %enemy in an attempt to steal something! }
  else { set %skill.description $readini($char($1), descriptions, steal) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills steal.time %true.turn

  ; If we're using the Mugger's Belt accessory, let's do some damage.
  if ($accessory.check($1, Mug) = true) {
    unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4
    unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb
    unset %enemy | unset %user | unset %real.name

    ; Get the weapon equipped
    $weapon_equipped($1)

    ; Calculate, deal, and display the damage..
    $calculate_damage_weapon($1, %weapon.equipped, $2, mugger's-belt)
    $drain_samba_check($1)
    $deal_damage($1, $2, %weapon.equipped)
    $display_damage($1, $2, weapon, %weapon.equipped)

    unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance | unset %accessory.amount
  }

  ; Now to check to see if we steal something.
  var %steal.chance $rand(1,100)
  var %skill.steal $readini($char($1), skills, steal)
  inc %steal.chance %skill.steal

  if (%bloodmoon = on) { inc %steal.chance 25 }

  if ($accessory.check($1, IncreaseSteal) = true) {
    inc %steal.chance %accessory.amount 
    unset %accessory.amount
  }

  ; Check augment
  if ($augment.check($1, EnhanceSteal) = true) {  inc %steal.chance $calc(2 * %augment.strength) }

  var %current.playerstyle $readini($char($1), styles, equipped)
  if (%current.playerstyle = Trickster) { inc %steal.chance $rand(5,10) }

  if (%steal.chance >= 85) {
    var %stolen.from.counter $readini($char($2), status, stolencounter)
    if (%stolen.from.counter >= 3) { $set_chr_name($2) | $display.message(4 $+ %real.name  has nothing left to steal!, battle) | halt }

    inc %stolen.from.counter 1 | writeini $char($2) status stolencounter %stolen.from.counter 

    set %steal.pool $readini($dbfile(steal.db), stealpool, $2)
    var %steal.orb.amount $rand(100,300) 

    if (%steal.pool = $null) { 
      if ($readini($char($2), Info, flag) = monster) { set %steal.pool $readini($dbfile(steal.db), stealpool, monster) }
      if ($readini($char($2), Info, flag) = boss) { set %steal.pool $readini($dbfile(steal.db), stealpool, boss) }
    }

    if (%bloodmoon = on) { var %steal.pool orbs.orbs.orbs.orbs | var %steal.orb.amount $rand(300,500) }

    set %total.items $numtok(%steal.pool, 46)
    set %random.item $rand(1,%total.items)
    set %steal.item $gettok(%steal.pool,%random.item,46)

    if (%steal.item = $null) { set %steal.item orbs }  
    if (%steal.item = orbs) { 
      if (%steal.orb.amount = $null) { var %steal.orb.amount $rand(100,300)  }
      var %current.orb.amount $readini($char($1), stuff, redorbs) | inc %current.orb.amount %steal.orb.amount | writeini $char($1) stuff redorbs %current.orb.amount 
      $set_chr_name($1) | $display.message(2 $+ %real.name has stolen %steal.orb.amount $readini(system.dat, system, currency) from $set_chr_name($2) %real.name $+ ! , battle)
    }
    else {
      set %current.item.total $readini($char($1), Item_Amount, %steal.item) 
      if (%current.item.total = $null) { var %current.item.total 0 }
      inc %current.item.total 1 | writeini $char($1) Item_Amount %steal.item %current.item.total 
      $set_chr_name($1) | $display.message($readini(translation.dat, skill, StealItem), battle)
    }
  }
  else { $set_chr_name($1) | $display.message($readini(translation.dat, skill, UnableTosteal), battle) }

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction steal 

  unset %enemy | unset %steal.pool

  $skill.nextturn.check(Steal, $1)
}

;=================
; ANALYSIS
;=================
on 3:TEXT:!analyze*:*: { $partial.name.match($nick, $2)  | $skill.analysis($nick, %attack.target)  }
on 3:TEXT:!analysis*:*: { $partial.name.match($nick, $2)  | $skill.analysis($nick, %attack.target) }

alias skill.analysis.color {
  ; $1 current analysis level
  ; $2 analysis level needed
  ; $3 resistant, weak, normal

  if ($1 < $2) { return 1,1 }
  if (($3 = resistant) || ($3 = resist)) { return 6 }
  if ($3 = weak) { return 7 }
  if ($3 = normal) { return 3 }
  if ($3 = stat) { return 3 }
  if ($3 = immune) { return 4 }
  if ($3 = heal) { return 4 }
}

alias skill.analysis { $set_chr_name($1)
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, analysis) = false) { $set_chr_name($nick) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private) | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  var %skill.name Analysis
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  var %analysis.flag $readini($char($2), info, flag) 
  if (%analysis.flag != monster) { $display.message($readini(translation.dat, errors, OnlyAnalyzeMonsters), private) | halt }

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, analysis, !analyze, false)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(analysis))

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($nick), descriptions, analysis) = $null) { set %skill.description focuses intently on %enemy in an attempt to analyze $gender2($2) $+ ! }
  else { set %skill.description $readini($char($nick), descriptions, analysis) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Get the level of the skill.  The level will determine the information we get from the skill.
  var %analysis.level $readini($char($1), skills, analysis)

  unset %analysis.weapon.weak | unset %analysis.weapon.strength | unset %analysis.element.weak | unset %analysis.element.strength | unset %analysis.element.absorb
  unset %analysis.element.heal

  ; Get the target info
  var %analysis.hp $skill.analysis.color(%analysis.level, 1, stat) $+ $readini($char($2), battle, hp) $+ 3 

  if (%analysis.level >= 2) { var %analysis.tp $skill.analysis.color(%analysis.level, 2, stat) $+ $readini($char($2), battle, tp) $+ 3 }
  if (%analysis.level >= 3) { 
    var %analysis.str $skill.analysis.color(%analysis.level, 3, stat) $+ $readini($char($2), battle, str) $+ 3  | var %analysis.def $skill.analysis.color(%analysis.level, 3, stat) $+ $readini($char($2), battle, def) $+ 3
    var %analysis.int $skill.analysis.color(%analysis.level, 3, stat) $+ $readini($char($2), battle, int) $+ 3 | var %analysis.spd $skill.analysis.color(%analysis.level, 3, stat) $+ $readini($char($2), battle, spd) $+ 3
  }

  if (%analysis.level >= 4) { 
    ; Check for elemental weaknesses
    if (($readini($char($2), modifiers, earth) > 100) && ($istok($readini($char($2), modifiers, heal), earth, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ earth3, 46) }
    if (($readini($char($2), modifiers, fire) > 100) && ($istok($readini($char($2), modifiers, heal), fire, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ fire3, 46) }
    if (($readini($char($2), modifiers, wind) > 100) && ($istok($readini($char($2), modifiers, heal), wind, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ wind3, 46) }
    if (($readini($char($2), modifiers, ice) > 100) && ($istok($readini($char($2), modifiers, heal), ice, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ ice3, 46) }
    if (($readini($char($2), modifiers, water) > 100) && ($istok($readini($char($2), modifiers, heal), water, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ water3, 46) }
    if (($readini($char($2), modifiers, lightning) > 100) && ($istok($readini($char($2), modifiers, heal), lightning, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ lightning3, 46) }
    if (($readini($char($2), modifiers, light) > 100) && ($istok($readini($char($2), modifiers, heal), light, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ light3, 46) }
    if (($readini($char($2), modifiers, dark) > 100) && ($istok($readini($char($2), modifiers, heal), dark, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, $skill.analysis.color(%analysis.level, 4, weak) $+ dark3, 46) }

    if (%analysis.element.weak = $null) { %analysis.element.weak = 3none }
  }

  if (%analysis.level >= 5) { 
    ; Check for elemental healing
    if ($istok($readini($char($2), modifiers, heal), earth, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ earth3, 46) }
    if ($istok($readini($char($2), modifiers, heal), fire, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ fire3, 46) }
    if ($istok($readini($char($2), modifiers, heal), wind, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ wind3, 46) }
    if ($istok($readini($char($2), modifiers, heal), ice, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ ice3, 46) }
    if ($istok($readini($char($2), modifiers, heal), water, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ water3, 46) }
    if ($istok($readini($char($2), modifiers, heal), lightning, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ lightning3, 46) }
    if ($istok($readini($char($2), modifiers, heal), light, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ light3, 46) }
    if ($istok($readini($char($2), modifiers, heal), dark, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, $skill.analysis.color(%analysis.level, 5, heal) $+ dark3, 46) }

    if (%analysis.element.heal = $null) { %analysis.element.heal = 3none }

    ;  Check for elemental resistances
    if ($readini($char($2), modifiers, earth) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ earth3, 46) }
    if ($readini($char($2), modifiers, fire) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ fire3, 46) }
    if ($readini($char($2), modifiers, wind) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ wind3, 46) }
    if ($readini($char($2), modifiers, ice) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ ice3, 46) }
    if ($readini($char($2), modifiers, water) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ water3, 46) }
    if ($readini($char($2), modifiers, lightning) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ lightning3, 46) }
    if ($readini($char($2), modifiers, light) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ light3, 46) }
    if ($readini($char($2), modifiers, dark) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, $skill.analysis.color(%analysis.level, 5, resistant) $+ dark3, 46) }

    if (%analysis.element.strength = $null) { %analysis.element.strength = 3none }

    ;  Check for elemental absorb
    if ($readini($char($2), modifiers, earth) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ earth3, 46) }
    if ($readini($char($2), modifiers, fire) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ fire3, 46) }
    if ($readini($char($2), modifiers, wind) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ wind3, 46) }
    if ($readini($char($2), modifiers, ice) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ ice3, 46) }
    if ($readini($char($2), modifiers, water) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ water3, 46) }
    if ($readini($char($2), modifiers, lightning) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ lightning3, 46) }
    if ($readini($char($2), modifiers, light) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ light3, 46) }
    if ($readini($char($2), modifiers, dark) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, $skill.analysis.color(%analysis.level, 5, immune) $+ dark3, 46) }

    if (%analysis.element.absorb = $null) { %analysis.element.absorb = 3none }

  }

  if (%analysis.level >= 6) { 
    ; Check for weapon weaknesses
    if ($readini($char($2), modifiers, HandToHand) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ handtohand3, 46) }
    if ($readini($char($2), modifiers, Whip) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ whip3, 46) }
    if ($readini($char($2), modifiers, Sword) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ sword3, 46) }
    if ($readini($char($2), modifiers, gun) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ gun3, 46) }
    if ($readini($char($2), modifiers, rifle) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ rifle3, 46) }
    if ($readini($char($2), modifiers, katana) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ katana3, 46) }
    if ($readini($char($2), modifiers, wand) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ wand3, 46) }
    if ($readini($char($2), modifiers, spear) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ spear3, 46) }
    if ($readini($char($2), modifiers, scythe) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ scythe3, 46) }
    if ($readini($char($2), modifiers, glyph) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ glyph3, 46) }
    if ($readini($char($2), modifiers, greatsword) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ greatsword3, 46) }
    if ($readini($char($2), modifiers, bow) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ bow3, 46) }
    if ($readini($char($2), modifiers, dagger) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ dagger3, 46) }
    if ($readini($char($2), modifiers, hammer) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ hammer3, 46) }
    if ($readini($char($2), modifiers, ParticleAccelerator) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ ParticleAccelerator3, 46) }
    if ($readini($char($2), modifiers, lightsaber) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, $skill.analysis.color(%analysis.level, 6, weak) $+ lightsaber3, 46) }

    if (%analysis.weapon.weak = $null) { %analysis.weapon.weak = 3none }

    ; Check for weapon normal
    if ($readini($char($2), modifiers, HandToHand) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ handtohand3, 46) }
    if ($readini($char($2), modifiers, Whip) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ whip3, 46) }
    if ($readini($char($2), modifiers, Sword) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ sword3, 46) }
    if ($readini($char($2), modifiers, gun) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ gun3, 46) }
    if ($readini($char($2), modifiers, rifle) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ rifle3, 46) }
    if ($readini($char($2), modifiers, katana) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ katana3, 46) }
    if ($readini($char($2), modifiers, wand) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ wand3, 46) }
    if ($readini($char($2), modifiers, spear) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ spear3, 46) }
    if ($readini($char($2), modifiers, scythe) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ scythe3, 46) }
    if ($readini($char($2), modifiers, glyph) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ glyph3, 46) }
    if ($readini($char($2), modifiers, greatsword) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ greatsword3, 46) }
    if ($readini($char($2), modifiers, bow) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ bow3, 46) }
    if ($readini($char($2), modifiers, dagger) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ dagger3, 46) }
    if ($readini($char($2), modifiers, hammer) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ hammer3, 46) }
    if ($readini($char($2), modifiers, ParticleAccelerator) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ ParticleAccelerator3, 46) }
    if ($readini($char($2), modifiers, lightsaber) = 100) { %analysis.weapon.normal = $addtok(%analysis.weapon.normal, $skill.analysis.color(%analysis.level, 6, normal) $+ lightsaber3, 46) }

    if (%analysis.weapon.normal = $null) { %analysis.weapon.normal = 3none }

    ; Check for weapon resistances
    if ($readini($char($2), modifiers, HandToHand) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ handtohand3, 46) }
    if ($readini($char($2), modifiers, Whip) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ whip3, 46) }
    if ($readini($char($2), modifiers, Sword) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ sword3, 46) }
    if ($readini($char($2), modifiers, gun) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ gun3, 46) }
    if ($readini($char($2), modifiers, rifle) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ rifle3, 46) }
    if ($readini($char($2), modifiers, katana) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ katana3, 46) }
    if ($readini($char($2), modifiers, wand) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ wand3, 46) }
    if ($readini($char($2), modifiers, spear) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ spear3, 46) }
    if ($readini($char($2), modifiers, scythe) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ scythe3, 46) }
    if ($readini($char($2), modifiers, glyph) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ glyph3, 46) }
    if ($readini($char($2), modifiers, greatsword) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ greatsword3, 46) }
    if ($readini($char($2), modifiers, bow) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ bow3, 46) }
    if ($readini($char($2), modifiers, dagger) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ dagger3, 46) }
    if ($readini($char($2), modifiers, hammer) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ hammer3, 46) }
    if ($readini($char($2), modifiers, ParticleAccelerator) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ ParticleAccelerato3r, 46) }
    if ($readini($char($2), modifiers, lightsaber) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, $skill.analysis.color(%analysis.level, 6, resist) $+ lightsaber3, 46) }

    if (%analysis.weapon.strength = $null) { %analysis.weapon.strength = 3none }

  }

  var %analysis.defeat.conditions $readini($char($2), info, DeathConditions)
  if (%analysis.defeat.conditions = $null) { var %analysis.defeat.conditions none }

  var %replacechar $chr(044) $chr(032)
  %analysis.weapon.normal = $replace(%analysis.weapon.normal, $chr(046), %replacechar)
  %analysis.weapon.weak = $replace(%analysis.weapon.weak, $chr(046), %replacechar)
  %analysis.weapon.strength = $replace(%analysis.weapon.strength, $chr(046), %replacechar)
  %analysis.element.weak = $replace(%analysis.element.weak, $chr(046), %replacechar)
  %analysis.element.strength = $replace(%analysis.element.strength, $chr(046), %replacechar)
  %analysis.element.absorb = $replace(%analysis.element.absorb, $chr(046), %replacechar)
  %analysis.element.heal = $replace(%analysis.element.heal, $chr(046), %replacechar)
  %analysis.defeat.conditions = $replace(%analysis.defeat.conditions, $chr(046), %replacechar)

  ; Display the analysis..
  $set_chr_name($2) | $display.private.message(3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and $iif(%analysis.tp = $null, $skill.analysis.color(%analysis.level, 1000000, stat) $+ [][][][][] $+ 3, %analysis.tp) TP left.)
  $display.private.message(3 $+ %real.name has the following stats: [str: $iif(%analysis.str = $null, $skill.analysis.color(%analysis.level, 1000000, stat) $+ [][][][][] $+ 3, %analysis.str) $+ ] [def: $iif(%analysis.def = $null, $skill.analysis.color(%analysis.level, 1000000, stat) $+ [][][][][] $+ 3, %analysis.def) $+ ] [int: $iif(%analysis.int = $null, $skill.analysis.color(%analysis.level, 1000000, stat) $+ [][][][][] $+ 3, %analysis.int) $+ ] [spd: $iif(%analysis.spd = $null, $skill.analysis.color(%analysis.level, 1000000, stat) $+ [][][][][] $+ 3, %analysis.spd) $+ ])
  $display.private.message(3 $+ %real.name can be hurt normally with the following weapon types: $iif(%analysis.weapon.normal = $null, $skill.analysis.color(%analysis.level, 1000000, normal) $+ [][][][][] $+ 3, %analysis.weapon.normal) and is resistant against the following weapon types: $iif(%analysis.weapon.strength = $null, $skill.analysis.color(%analysis.level, 1000000, weak) $+ [][][][][] $+ 3, %analysis.weapon.strength) and weak against the following weapon types: $iif(%analysis.weapon.weak = $null, $skill.analysis.color(%analysis.level, 1000000, weak) $+ [][][][][] $+ 3, %analysis.weapon.weak))
  $display.private.message(3 $+ %real.name is resistant against the following elements: $iif(%analysis.element.strength = $null, $skill.analysis.color(%analysis.level, 1000000, resistant) $+ [][][][][] $+ 3, %analysis.element.strength) and weak against the following elements: $iif(%analysis.element.weak = $null, $skill.analysis.color(%analysis.level, 1000000, weak) $+ [][][][][] $+ 3, %analysis.element.weak) ) 
  $display.private.message(3 $+ %real.name is completely immune to the following elements: $iif(%analysis.element.absorb = $null, $skill.analysis.color(%analysis.level, 1000000, immune) $+ [][][][][] $+ 3, %analysis.element.absorb)  )
  $display.private.message(3 $+ %real.name will be healed by the following elements: $iif(%analysis.element.heal = $null, $skill.analysis.color(%analysis.level, 1000000, immune) $+ [][][][][] $+ 3, %analysis.element.heal) )
  if ((%analysis.defeat.conditions != none) && (%analysis.level >= 7)) {  $display.private.message(3 $+ %real.name has special death conditions and will continue to revive if not killed with these conditions) }

  unset %enemy
  unset %analysis.* 
  unset %analysis.weapon.weak | unset %analysis.weapon.strength | unset %analysis.element.weak | unset %analysis.element.strength | unset %analysis.element.absorb
  unset %analysis.element.heal | unset %analysis.weapon.normal

  ; write the last used time.
  writeini $char($1) skills analysis.time %true.turn


  $skill.nextturn.check(%skill.name, $1)
}

;=================
; QUICKSILVER
;=================
on 3:TEXT:!quicksilver*:*: { $skill.quicksilver($nick) }

alias skill.quicksilver { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if ((no-skill isin %battleconditions) || (no-quicksilver isin %battleconditions)) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  set %current.playerstyle $readini($char($1), styles, equipped)
  if (($return.playerstyle($1) != Quicksilver) && ($readini($char($1), info, flag) = $null)) { $display.message(4Error: This command can only be used while the Quicksilver style is equipped!, private) | unset %current.playerstyle | halt }

  if (%mode.pvp = on) { $display.message($readini(translation.dat, errors, ActionDisabledForPVP), private) | halt }

  $check_for_battle($1)

  if ($readini($char($1), info, flag) = $null) { 
    set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
    set %quicksilver.used $readini($char($1), skills, quicksilver.used)
    set %quicksilver.turn $readini($char($1), skills, quicksilver.turn)
    if (%quicksilver.used = $null) { set %quicksilver.used 0 }
    if (%quicksilver.turn = $null) { set %quicksilver.turn -1 }

    if (%quicksilver.used >= %current.playerstyle.level) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot use $gender($1) Quicksilver power again this battle!,private) | unset %current.playerstyle | halt }
    if (($calc(%quicksilver.turn + 1) = %true.turn) || (%quicksilver.turn = %true.turn)) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot use $gender($1) Quicksilver power again so quickly!, private) | unset %current.playerstyle | halt }
  }

  inc %quicksilver.used 1 | writeini $char($1) skills quicksilver.used %quicksilver.used
  writeini $char($1) skills quicksilver.turn %true.turn

  ; Decrease the action points
  $action.points($1, remove, 5)

  if ($readini($char($1), descriptions, quicksilver) = $null) { $set_chr_name($1) | set %skill.description unleashes the power of Quicksilver! Time seems to stop for everyone except %real.name $+ ! }
  else { set %skill.description $readini($char($1), descriptions, quicksilver) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    if (%who.battle != $1) {
      if (($accessory.check(%who.battle, IgnoreQuickSilver) = true) || ($readini($char(%who.battle), info, ignorequicksilver) = true)) {
        if ($readini($char(%who.battle), battle, hp) > 0) { $set_chr_name(%who.battle) | $display.message($readini(translation.dat, skill, QuickSilverImmune), battle) }
      }
      else { writeini $char(%who.battle) status stop yes }
    }

    inc %battletxt.current.line 1 
  }

  writeini $char($1) skills doubleturn.on on

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
  unset %current.playerstyle | unset %current.playerstyle.level | unset %quicksilver.used
}

;=================
; COVER
;=================
on 3:TEXT:!cover*:*: { $skill.cover($nick, $2) }

alias skill.cover { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if ($2 = $1) { $display.message($readini(translation.dat, errors, CannotCoverYourself),private) | halt }

  if ($readini($char($1), info, flag) = $null) {
    if ($skillhave.check($1, cover) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  }

  var %skill.name Cover
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Cover, !cover, false)

  var %cover.status $readini($char($2), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { $display.message($readini(translation.dat, skill, CoverTargetDead), private) | halt }

  var %cover.target $readini($char($2), skills, CoverTarget)
  if  ($readini($char($1), info, flag) = $null) {
    if ((%cover.target != none) && (%cover.target != $null)) { $display.message($readini(translation.dat, skill, AlreadyBeingCovered),private) | halt  }
  }

  var %user.flag $readini($char($1), info, flag) 
  if (%user.flag = $null) { var %user.flag player }
  var %target.flag $readini($char($2), info, flag)

  if (%user.flag = player) && (%target.flag = monster) { $display.message($readini(translation.dat, errors, CannotCoverMonsters),private) | halt }

  writeini $char($2) skills CoverTarget $1

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(cover))

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($1), descriptions, cover) = $null) { set %skill.description prepares to leap in front of %enemy in order to defend $gender2($2) }
  else { set %skill.description $readini($char($1), descriptions, cover) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills cover.time %true.turn
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction cover

  unset %enemy

  $skill.nextturn.check(Cover, $1)
}

;=================
; SNATCH
;=================
on 3:TEXT:!snatch*:*: { $partial.name.match($nick, $2)  | $skill.snatch($nick, %attack.target) }

alias skill.snatch { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)

  ; Do we have an augment or something that lets us snatch a monster?

  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Snatch, the snatch item, false)

  var %cover.status $readini($char($2), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { $display.message($readini(translation.dat, skill, SnatchTargetDead), private) | halt }

  var %cover.target $readini($char($2), skills, CoverTarget)
  if ((%cover.target != none) && (%cover.target != $null)) { $display.message($readini(translation.dat, skill, AlreadyBeingHeld), private) | halt  }

  var %user.flag $readini($char($1), info, flag) 
  if (%user.flag = $null) { var %user.flag player }
  var %target.flag $readini($char($2), info, flag)

  if (%user.flag = player) && (%target.flag != monster) { 
    if (%mode.pvp != on) { $display.message($readini(translation.dat, errors, CannotSnatchPlayers), private) | halt }
  }

  if ($isfile($boss($2)) = $true) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CannotSnatchBosses), private) | halt }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(snatch))

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($1), descriptions, snatch) = $null) { set %skill.description grabs onto %enemy and tries to use $gender2($2) as a shield! }
  else { set %skill.description $readini($char($1), descriptions, snatch) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  $do.snatch($1, $2)

  unset %enemy

  $skill.nextturn.check(Snatch, $1)
}

alias do.snatch {
  var %snatch.chance $rand(1,100)

  var %user.speed $readini($char($1), battle, spd)
  var %target.speed $readini($char($2), battle, spd)
  var %user.level $get.level($1) | var %target.level $get.level($2)

  if (%user.speed > %target.speed) { inc %snatch.chance 10 }
  if (%user.speed < %target.speed) { dec %snatch.chance 10 }
  if (%user.level > %target.level) { inc %snatch.chance 5 }
  if (%user.level < %target.level) { inc %snatch.chance 5 }

  if ($augment.check($1, EnhanceSnatch) = true) { inc %snatch.chance $round($calc(3.5 * %augment.strength),0) }

  if (%snatch.chance >= 70) { 
    writeini $char($1) skills CoverTarget $2 
    $display.message($readini(translation.dat, battle, TargetSnatched), battle)
  }
  if (%snatch.chance < 70) {
    $display.message($readini(translation.dat, battle, TargetNotSnatched), battle)
  }

  ; write the last used time.
  writeini $char($1) skills snatch.time %true.turn
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction snatch

  return

}

;=================
; AGGRESSOR 
;=================
on 3:TEXT:!aggressor*:*: { $skill.aggressor($nick) }

alias skill.aggressor { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, aggressor) = false) { $set_chr_name($nick) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private) | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Aggressor
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  if ($readini($char($1), skills, aggressor.on) = on) { $set_chr_name($1) | $display.message(4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle., private) | halt }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(aggressor))

  ; Display the desc. 
  if ($readini($char($1), descriptions, aggressor) = $null) { set %skill.description gives a loud battle warcry as $gender($1) strength is enhanced at the cost of $gender($1) defense! }
  else { set %skill.description $readini($char($1), descriptions, aggressor) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Increase the strength
  var %strength $readini($char($1), battle, str)
  var %defense $readini($char($1), battle, def)
  var %skill.level $readini($char($1), skills, aggressor)
  var %skill.increase.percent $calc(%skill.level * .10)

  if ($augment.check($1, EnhanceAggressor) = true) {  inc %skill.increase.percent $calc(%augment.strength * .10) }

  var %increase.amount $round($calc(%skill.increase.percent * %defense),0)
  inc %strength %increase.amount
  writeini $char($1) battle str %strength
  writeini $char($1) battle def 5

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills aggressor.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction aggressor

  $skill.nextturn.check(Aggressor, $1)
}

;=================
; DEFENDER
;=================
on 3:TEXT:!defender*:*: { $skill.defender($nick) }

alias skill.defender { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, defender) = false) { $set_chr_name($nick) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Defender
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  if ($readini($char($1), skills, defender.on) = on) { $set_chr_name($1) | $display.message(4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle.,private) | halt }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(defender))

  ; Display the desc. 
  if ($readini($char($1), descriptions, defender) = $null) { set %skill.description decides that the best offense is a good defense and sacrifices $gender($1) strength for defense! }
  else { set %skill.description $readini($char($1), descriptions, defender) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Increase the defense
  var %strength $readini($char($1), battle, str)
  var %defense $readini($char($1), battle, def)
  var %skill.level $readini($char($1), skills, defender)
  var %skill.increase.percent $calc(%skill.level * .10)

  if ($augment.check($1, EnhanceDefender) = true) { 
    inc %skill.increase.percent $calc(%augment.strength * .10)
  }

  var %increase.amount $round($calc(%skill.increase.percent * %strength),0)
  inc %defense %increase.amount
  writeini $char($1) battle str 5
  writeini $char($1) battle def %defense

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills defender.on on

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction defender

  $skill.nextturn.check(Defender, $1)
}


;=================
; CRAFTING/ALCHEMY
;=================
on 3:TEXT:!alchemy*:*: { $skill.alchemy($nick, $2, $3) }
on 3:TEXT:!craft*:*: { $skill.alchemy($nick, $2, $3) }

alias skill.alchemy { 
  ; $1 = person crafting
  ; $2 = the item you're trying to craft.
  ; $3 = how many you want to craft of that item.

  $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ($skillhave.check($1, alchemy) = false) { $set_chr_name($nick) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }


  if ($readini($dbfile(weapons.db), $2, basepower) != $null) {  
    var %player.amount.weapon $readini($char($1), weapons, $2)
    if ((%player.amount.weapon != $null) || (%player.amount > 0)) { $display.message(4 $+ $get_chr_name($1) already owns this weapon and cannot craft another!, private) | halt }
  }

  var %gem.required $readini($dbfile(crafting.db), $2, gem)
  if (%gem.required = $null) { unset %gem.required | $display.message($readini(translation.dat, errors, CannotCraftThisItem),private) | halt }

  var %amount.to.craft $abs($3)
  if ($3 !isnum) {
    if (%amount.to.craft = $null) { var %amount.to.craft 1 }
    else { $display.message($readini(translation.dat, errors, NotAValidAmount),private) | halt }
  }

  ; Does the user have the gem necessary to craft the item?
  var %player.gem.amount $readini($char($1), item_amount, %gem.required)  

  if (%player.gem.amount <= 0) { remini $char($1) item_amount %gem.required } 
  if (%player.gem.amount = $null) { set %player.gem.amount 0 } 
  if (%player.gem.amount < %amount.to.craft) { unset %player.gem.amount | unset %gem.required | $display.message($readini(translation.dat, errors, MissingCorrectGem),private) | halt } 

  ; Check each ingredient and add total ingredients vs needed ingredients.
  var %player.ingredients 0 |  var %ingredients $readini($dbfile(crafting.db), $2, ingredients)
  var %total.ingredients $numtok(%ingredients, 46)

  var %value 1
  while (%value <= %total.ingredients) {
    var %item.name $gettok(%ingredients, %value, 46)
    var %item_amount $readini($char($1), item_amount, %item.name)
    var %item_type $readini($dbfile(items.db), %item.name, type)

    if (%item_amount <= 0) { remini $char($1) item_amount %item.name } 
    if (%item_amount = $null) { set %item_amount 0 }

    ; How many of the ingredient do we need to craft this?
    if ($readini($dbfile(weapons.db), $2, power) != $null) { 
      var %amount.needed $readini($dbfile(crafting.db), $2, %item.name) 
      if (%amount.needed = $null) { var %amount.needed 1 } 
    }
    else { 
      set %amount.needed $calc($readini($dbfile(crafting.db), $2, %item.name) * %amount.to.craft )
      if ((%amount.needed = $null) || (%amount.needed = 0)) { set %amount.needed %amount.to.craft }
    }

    ; Check to see if we have enough.

    if (%item_type = accessory) { 
      var %equipped.accessory $readini($char($1), equipment, accessory) 
      if (%equipped.accessory = %item.name) { dec %item_amount 1 }
    }
    if (%item_type = $null) { 
      set %item_type $readini(equipment.db, %item.name, EquipLocation)
      if (%item_type = head) {
        var %equipped.armor $readini($char($1), equipment, head) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = body) {
        var %equipped.armor $readini($char($1), equipment, body) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = legs) {
        var %equipped.armor $readini($char($1), equipment, legs) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = feet) {
        var %equipped.armor $readini($char($1), equipment, feet) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = hands) {
        var %equipped.armor $readini($char($1), equipment, hands) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
    }

    if ((%item_amount != $null) && (%item_amount >= %amount.needed)) { 
      inc %player.ingredients 1
    }

    inc %value 1 
  }


  if (%player.ingredients < %total.ingredients) { $display.message($readini(translation.dat, errors, MissingIngredients),private)  | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, alchemy) = $null) { set %skill.description uses the power of the gem to combine ingredients in an attempt to create something better! }
  else { set %skill.description $readini($char($1), descriptions, alchemy) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, global) 

  ; Check for success or not.
  if ((%amount.to.craft = $null) || (%amount.to.craft = 1)) {

    set %base.success $readini($dbfile(crafting.db), $2, successrate)
    inc %base.success $readini($char($1), skills, alchemy)

    if ($augment.check($1, EnhanceCrafting) = true) {
      inc %base.success $calc(2 + %augment.strength)
    }

    var %random.chance $rand(1,100)

    if (%random.chance <= %base.success) { 

      ; Figure out if this is a weapon or normal item/armor
      if ($readini($dbfile(weapons.db), $2, basepower) != $null) { 
        writeini $char($1) weapons $2 1
        var %crafting.item.amount 1
        $display.message($readini(translation.dat, skill, CraftingSuccess), global)
      }
      else { 
        var %player.amount.item $readini($char($1), item_amount, $2) 
        if (%player.amount.item = $null) { var %player.amount.item 0 }
        var %crafting.item.amount $readini($dbfile(crafting.db), $2, amount)

        if ($rand(1,100) = 100) { inc %crafting.item.amount %crafting.item.amount | set %crit.crafting true }

        inc %player.amount.item %crafting.item.amount

        if (%crit.crafting = true) {  $display.message($readini(translation.dat, skill, CriticalCraftingSuccess), global)  }
        $display.message($readini(translation.dat, skill, CraftingSuccess), global)

        writeini $char($1) item_amount $2 %player.amount.item
      }


    }
    if (%random.chance > %base.success) { $display.message($readini(translation.dat, skill, CraftingFailure), global) }
  }

  if (%amount.to.craft  > 1) { 
    var %crafting.success.total 0
    var %crafting.failure.total 0
    var %crafting.value 1
    var %total.crafted 0 

    while (%crafting.value <= %amount.to.craft) {
      set %base.success $readini($dbfile(crafting.db), $2, successrate)
      inc %base.success $readini($char($1), skills, alchemy)

      if ($augment.check($1, EnhanceCrafting) = true) {
        inc %base.success $calc(2 + %augment.strength)
      }

      var %random.chance $rand(1,100)

      if (%random.chance <= %base.success) { 
        var %player.amount.item $readini($char($1), item_amount, $2) 
        var %crafting.item.amount $readini($dbfile(crafting.db), $2, amount)

        if ($rand(1,100) = 100) { inc %crafting.item.amount %crafting.item.amount | set %crit.crafting true }

        inc %player.amount.item %crafting.item.amount

        inc %total.crafted %crafting.item.amount

        writeini $char($1) item_amount $2 %player.amount.item
        inc %crafting.success.total 1
      }
      if (%random.chance > %base.success) { inc %crafting.failure.total 1 }
      inc %crafting.value 1
    }

    if (%crit.crafting = true) {  $display.message($readini(translation.dat, skill, CriticalCraftingSuccess), global)  }
    $display.message($readini(translation.dat, skill, CraftingMultiple), global) 
  }

  var %value 1
  while (%value <= %total.ingredients) {
    set %item.name $gettok(%ingredients, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)
    set %amount.needed $readini($dbfile(crafting.db), $2, %item.name)
    if (%amount.needed = $null) { set %amount.needed 1 }
    set %amount.needed $calc(%amount.needed * %amount.to.craft)
    dec %item_amount %amount.needed | writeini $char($1) item_amount %item.name %item_amount
    inc %value 1 
  }

  dec %player.gem.amount %amount.to.craft | writeini $char($1) item_amount %gem.required %player.gem.amount
  unset %crit.crafting 
  unset %gem.required | unset %player.gem.amount | unset %item.name | unset %item_amount | unset %base.success | unset %item_type | unset %amount.needed
}

;=================
; DESYNTH
;=================
on 3:TEXT:!desynth*:*: { $skill.desynth($nick, $2, $3) }

alias skill.desynth { 
  ; $1 = person desynthing
  ; $2 = the item you're trying to desynth
  ; $3 = how many you want to desynth

  $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  if ($skillhave.check($1, desynth) = false) { $set_chr_name($nick) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }


  if ($readini($dbfile(crafting.db), $2, Ingredients) = $null) { $display.message(4 $+ $get_chr_name($1) cannot desynth this item!, private) | halt }

  var %gem.required $readini($dbfile(crafting.db), $2, gem)
  if (%gem.required = $null) { unset %gem.required | $display.message(4 $+ $get_chr_name($1) cannot desynth this item!, private) | halt }

  var %amount.to.desynth $abs($3)
  if ($3 !isnum) {
    if (%amount.to.desynth = $null) { var %amount.to.desynth 1 }
    else { $display.message($readini(translation.dat, errors, NotAValidAmount),private) | halt }
  }

  ; Does the user have the gem necessary to desynth the item?
  var %player.gem.amount $readini($char($1), item_amount, %gem.required)  
  if (%player.gem.amount <= 0) { remini $char($1) item_amount %gem.required } 
  if (%player.gem.amount = $null) { set %player.gem.amount 0 } 
  if (%player.gem.amount < %amount.to.desynth) { unset %player.gem.amount | unset %gem.required | $display.message($readini(translation.dat, errors, MissingCorrectGemDesynth),private) | halt } 

  ; Does the player have the item to desynth?
  var %player.desynth.item.amount $readini($char($1), item_amount, $2)

  var %equipped.accessory $readini($char($1), equipment, accessory) 
  if (%equipped.accessory = $2) { dec %player.desynth.item.amount 1 }
  var %equipped.accessory2 $readini($char($1), equipment, accessory2) 
  if (%equipped.accessory2 = $2) { dec %player.desynth.item.amount 1 }
  var %equipped.armor $readini($char($1), equipment, head) 
  if (%equipped.armor = $2) { dec %player.desynth.item.amount 1 }
  var %equipped.armor $readini($char($1), equipment, body) 
  if (%equipped.armor = $2) { dec %player.desynth.item.amount 1 }
  var %equipped.armor $readini($char($1), equipment, legs) 
  if (%equipped.armor = $2) { dec %player.desynth.item.amount 1 }
  var %equipped.armor $readini($char($1), equipment, feet) 
  if (%equipped.armor = $2) { dec %player.desynth.item.amount 1 }
  var %equipped.armor $readini($char($1), equipment, hands) 
  if (%equipped.armor = $2) { dec %player.desynth.item.amount 1 }

  if (%player.desynth.item.amount < %amount.to.desynth) { unset %player.gem.amount | unset %gem.required | $display.message($readini(translation.dat, errors, MissingIngredientsDesynth),private) | halt }

  ; Decrease the item from the player
  dec %player.desynth.item.amount %amount.to.desynth 
  writeini $char($1) item_amount $2 %player.desynth.item.amount
  dec %player.gem.amount %amount.to.desynth | writeini $char($1) item_amount %gem.required %player.gem.amount


  ; Desynth the item!
  ; Go through the ingredient list of the original item and add each.

  var %ingredients $readini($dbfile(crafting.db), $2, ingredients)
  var %total.ingredients $numtok(%ingredients, 46)
  var %value 1
  while (%value <= %total.ingredients) {
    var %item.name $gettok(%ingredients, %value, 46)
    var %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount <= 0) || (%item_amount = $null)) { set %item_amount 0 }
    inc %item_amount %amount.to.desynth
    writeini $char($1) item_amount %item.name %item_amount
    unset %item_amount
    inc %value 1 
  }

  ; Display the desc. 
  if ($readini($char($1), descriptions, desynth) = $null) { set %skill.description uses the power of the gem to break the $2 into base ingredients. }
  else { set %skill.description $readini($char($1), descriptions, desynth) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, global) 

  var %ingredients $replace(%ingredients, $chr(046), $chr(044) $chr(032)) 
  $display.message($readini(translation.dat, skill, DesynthSuccess), global)

  unset %gem.required | unset %player.gem.amount | unset %item.name | unset %item_amount | unset %base.success | unset %item_type | unset %amount.needed
}

;=================
; HOLY AURA
;=================
on 3:TEXT:!holy aura*:*: { $skill.holyaura($nick) }
on 3:TEXT:!holyaura*:*: { $skill.holyaura($nick) }

alias skill.holyaura { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, holyaura) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name HolyAura
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  if ((%darkness.turns = $null) && (%demonwall.fight != on)) { $set_chr_name($1) | $display.message($readini(translation.dat, Skill, HolyAuraAlreadyOn), private)  | halt }

  if (%battle.rage.darkness != $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DarknessAlreadyInEffect), private)  | halt }
  if (%holy.aura != $null) { $set_chr_name($1) | $display.message($readini(translation.dat, Skill, HolyAuraAlreadyOn), private)  | halt }

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, HolyAura, !holy aura, false)

  var %skill.level $readini($char($1), skills, holyaura)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(holyaura))

  ; Display the desc. 
  if ($readini($char($1), descriptions, holyaura) = $null) { 
    if (%max.demonwall.turns = $null) { set %skill.description releases a holy aura that covers the battlefield and keeps the darkness at bay for an additional %skill.level $iif(%skill.level > 1,turns, turn) $+ . }
    if (%max.demonwall.turns != $null) { set %skill.description releases a holy aura that covers the battlefield and pushes the %demonwall.name back for an additional %skill.level $iif(%skill.level > 1,turns, turn) $+ . }
  }
  else { set %skill.description $readini($char($1), descriptions, holyaura) }
  set %skill.description $replace(%skill.description,#time,$readini($char($1), skills, HolyAura))
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the last time used
  writeini $char($1) skills holyaura.time %true.turn

  if (%max.demonwall.turns = $null) { inc %darkness.turns %skill.level }
  if (%max.demonwall.turns != $null) { inc %max.demonwall.turns %skill.level }
  set %holy.aura.turn $calc(%true.turn + %skill.level)
  set %holy.aura on
  set %holy.aura.user $1

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction holyaura

  $skill.nextturn.check(HolyAura, $1)
}

alias holy_aura_end {
  unset %holy.aura
  $set_chr_name(%holy.aura.user) | $display.message($readini(translation.dat, skill,  HolyAuraEnd), private)
  unset %holy.aura.user
  unset %total.darkness.timer 
}

;=================
; MONSTER COCOON/EVOLVE
;=================
alias skill.cocoon.evolve {
  $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.message($readini(translation.dat, status, CurrentlyCharmed),private) | halt }
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  ; Display the desc. 
  if ($readini($char($1), descriptions, cocoonevolve) = $null) { set %skill.description is enveloped by a large cocoon-like protective barrier as $gender3($1) prepares for an evolved state. }
  else { set %skill.description $readini($char($1), descriptions, cocoonevolve) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  writeini $char($1) status cocoon yes
  writeini $char($1) status cocoon.timer 1
  writeini $char($1) skills cocoonevolve 0

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; MONSTER MAGIC SHIFT
;=================
alias skill.magic.shift {
  $set_chr_name($1)
  if ($is_charmed($1) = true) { return }
  if (no-skill isin %battleconditions) { return }
  if ($readini($char($1), status, amnesia) = yes) { return }

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  ; Display the desc. 
  if ($readini($char($1), descriptions, magicshift) = $null) { set %skill.description is covered with a rainbow-colored light that quickly fades. }
  else { set %skill.description $readini($char($1), descriptions, magicshift) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  set %magic.types light.dark.fire.ice.water.lightning.wind.earth
  set %number.of.magic.types $numtok(%magic.types,46)

  writeini $char($1) modifiers light 100
  writeini $char($1) modifiers dark 100
  writeini $char($1) modifiers fire 100
  writeini $char($1) modifiers ice 100
  writeini $char($1) modifiers water 100
  writeini $char($1) modifiers lightning 100
  writeini $char($1) modifiers wind 100
  writeini $char($1) modifiers earth 100

  var %numberof.weaknesses $rand(1,3)

  var %value 1
  while (%value <= %numberof.weaknesses) {
    set %weakness.number $rand(1,%number.of.magic.types)
    %weakness = $gettok(%magic.types,%weakness.number,46)
    if (%weakness != $null) {  writeini $char($1) modifiers %weakness 120 }
    inc %value
  }

  var %numberof.strengths $rand(1,3)

  var %value 1
  while (%value <= %numberof.strengths) {
    set %strength.number $rand(1,%number.of.magic.types)
    %strengths = $gettok(%magic.types,%strength.number,46)
    if (%strengths != $null) {  writeini $char($1) modifiers %strengths 50 }
    inc %value
  }

  var %numberof.heal $rand(1,2)

  var %value 1
  while (%value <= %numberof.heal) {
    set %heal.number $rand(1,%number.of.magic.types)
    %heals = $addtok(%heals, $gettok(%magic.types,%heal.number,46),46)
    inc %value
  }

  if (%heals != $null) { writeini $char($1) modifiers Heal %heals }

  unset %heal.number | unset %heals
  unset %strengths | unset %strength.number
  unset %weakness | unset %weakness.number
  unset %number.of.magic.types | unset %magic.types

  return
}

;=================
; MONSTER CONSUME
;=================
alias skill.monster.consume {
  set %debug.location skill.monster.consume
  $set_chr_name($1)
  if ($is_charmed($1) = true) { return }

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  ; Decrease the action points
  $action.points($1, remove, 1)

  ; Display the desc. 
  if ($readini($char($1), descriptions, monsterconsume) = $null) { set %skill.description grabs $set_chr_name($2) $+ %real.name and eats $gender2($2) $+ , gaining some of %real.name $+ 's power in the process! }
  else { set %skill.description $readini($char($1), descriptions, monsterconsume) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Increase the user's stats

  var %tp $readini($char($1), battle, tp)
  var %str $readini($char($1), Battle, Str)
  var %def $readini($char($1), Battle, Def)
  var %int $readini($char($1), Battle, Int)
  var %spd $readini($char($1), Battle, Spd)

  inc %tp $round($calc($readini($char($2), battle, tp) * .45),0)
  inc %str $round($calc($readini($char($2), battle, str) * .45),0)
  inc %def $round($calc($readini($char($2), battle, def) * .45),0)
  inc %int $round($calc($readini($char($2), battle, int) * .45),0)
  inc %spd $round($calc($readini($char($2), battle, spd) * .45),0)

  writeini $char($1) Battle Tp %tp
  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  ; Set the other monster as dead
  writeini $char($2) battle status dead
  writeini $char($2) battle hp 0

  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; MONSTER DEMON PORTAL
;=================
alias skill.demonportal {
  $set_chr_name($1)
  if ($is_charmed($1) = true) { return }
  if (no-skill isin %battleconditions) { return }
  if ($readini($char($1), status, amnesia) = yes) { return }

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  if ($readini($char(demon_portal), battle, hp) <= 0) { 
    ; Portal is dead. Let's just return.
    return
  }

  if ($readini($char(demon_portal), battle, hp) > 0) { 
    ; Portal already exists, let's repair it.
    if ($readini($char(demon_portal), battle, hp) < $readini($char(demon_portal), basestats, hp)) { 

      ; Decrease the action points
      $action.points($1, remove, 1)

      $set_chr_name($1) | $display.message(12 $+ %real.name  $+ begins work on repairing the damaged portal., battle)
      set %attack.damage $round($calc($readini($char($1), battle, hp) / 2),0)
      $heal_damage($1, demon_portal, skill)
      $display_heal($1, demon_portal ,aoeheal, skill)
      $next
    }
    else { return }
  }

  if ($readini($char(demon_portal), battle, hp) = $null) {
    if ($readini($char($1), descriptions, demonportal) = $null) { set %skill.description runs to the edge of the battlefield and performs a powerful summoning spell that opens a demonic portal so that more reinforcements can arrive.  }
    else { set %skill.description $readini($char($1), descriptions, demonportal) }
    $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description,battle)
    $generate_demonportal
    set %multiple.wave yes
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  return
}

;=================
; MONSTER REPAIR NATURAL ARMOR
;=================
alias skill.monster.repairnaturalarmor {
  $set_chr_name($1)
  if ($is_charmed($1) = true) { return }
  if (no-skill isin %battleconditions) { return }
  if ($readini($char($1), status, amnesia) = yes) { return }

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  ; Decrease the action points
  $action.points($1, remove, 1)

  ; Display the desc. 
  if ($readini($char($1), descriptions, repairnaturalarmor) = $null) { $set_chr_name($1) | set %skill.description %real.name repairs $gender($1) armor! }
  else { set %skill.description %real.name  $+ $readini($char($1), descriptions, repairnaturalarmor) }
  $display.message(4 $+ %skill.description, battle)

  var %max.armor $readini($char($1), NaturalArmor, Max)
  writeini $char($1) NaturalArmor Current %max.armor

  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; MONSTER SUMMON
;=================
alias skill.monstersummon {
  ; $1 = user
  ; $2 = name of summon
  ; $3 = item used to summon

  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  set %monster.name $2
  set %number.of.spawns.needed $readini($char($1), skills, monstersummon.numberspawn)

  if (%number.of.spawns.needed = $null) { var %number.of.spawns.needed 1 }

  ; Is it a valid monster? If not, return.
  if ($isfile($mon(%monster.name)) = $false) { return }

  ; Display the desc. 
  if ($readini($char($1), descriptions, monstersummon) = $null) { $set_chr_name($1) | set %skill.description %real.name opens a vortex and summons %number.of.spawns.needed $2 $+ $iif(%number.of.spawns.needed < 2, , s) into the battle. }
  else { set %skill.description $readini($char($1), descriptions, monstersummon) }
  $display.message(4 $+ %skill.description, battle)

  var %spawn.current 1
  while (%spawn.current <= %number.of.spawns.needed) {
    ; Check to see if the monster already exists..  if so, just increase the # at the end of its name.
    if ($isfile($char(%monster.name)) = $true) {
      var %value 2

      while ($isfile($char(%monster.name)) = $true) {
        set %monster.name $2 $+ %value
        inc %value
      }
    }

    .copy -o $mon($2) $char(%monster.name)
    writeini $char(%monster.name) Basestats Name %monster.name

    if ($eliteflag.check($1) = true) { writeini $char(%monster.name) Monster Elite true }
    if ($supereliteflag.check($1) = true) { writeini $char(%monster.name) Monster SuperElite true }

    ; Add to battle
    set %curbat $readini($txtfile(battle2.txt), Battle, List)
    %curbat = $addtok(%curbat,%monster.name,46)
    writeini $txtfile(battle2.txt) Battle List %curbat
    write $txtfile(battle.txt) %monster.name

    var %number.of.monsters $readini($txtfile(battle2.txt), battleinfo, Monsters)
    inc %number.of.monsters 1
    writeini $txtfile(battle2.txt) battleinfo Monsters %number.of.monsters

    $set_chr_name($1) 
    $boost_monster_stats(%monster.name, monstersummon, $1)
    $fulls(%monster.name, yes) 
    $levelsync(%monster.name, $round($calc($return_winningstreak / 2.2),0))

    ; Display the desc of the monsters
    $set_chr_name(%monster.name) | $display.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)

    if ($readini($char($1), skills, monstersummon.monsterscoverme) != false) {  
      writeini $char(%monster.name) skills Cover 100 
    }

    writeini $char(%monster.name) info master $1

    ; Get the action points
    var %battle.speed $readini($char(%monster.name), battle, speed)
    var %action.points $action.points(%monster.name, check)
    inc %action.points 1
    if (%battle.speed >= 1) { inc %action.points $round($log(%battle.speed),0) }
    if ($readini($char(%monster.name), info, flag) = monster) { inc %action.points 1 }
    if ($readini($char(%monster.name), info, ai_type) = defender) { var %action.points 0 } 
    var %max.action.points $round($log(%battle.speed),0)
    inc %max.action.points 1
    if (%action.points > %max.action.points) { var %action.points %max.action.points }
    writeini $txtfile(battle2.txt) ActionPoints %monster.name %action.points


    inc %spawn.current 1
  }

  unset %number.of.spawns.needed

  return
}


;=================
; MONSTER FLY
;=================
alias skill.flying {
  $set_chr_name($1)
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  if ($readini($char($1), status, flying) = yes) { 
    if ($readini($char($1), descriptions, landing) = $null) { set %skill.description flies back to the ground and lands. }
    else { set %skill.description $readini($char($1), descriptions, landing) }
    writeini $char($1) status flying no
    remini $char($1) status flying.timer
  }
  else { 
    if ($readini($char($1), descriptions, flying) = $null) { set %skill.description leaps high into the air and begins to fly around the battlefield }
    else { set %skill.description $readini($char($1), descriptions, flying) }
    writeini $char($1) status flying yes
    writeini $char($1) status flying.timer 0
  }

  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}


;=================
; MONSTER WEAKNESS
; SHIFT
;=================
alias skill.weaknessshift {
  if ($readini($char($1), info, flag) = $null) { return }
  if ($readini($char($1), modifiers, HitWithWeakness) != true) { return } 
  if (($readini($char($1), skills, WeaknessShift) = $null) || ($readini($char($1), skills, WeaknessShift) <= 0)) { return }

  if ($readini($char($1), descriptions, weaknessshift) = $null) { set %skill.description flashes with a bright light as $get_chr_name($1) changes weaknesses }
  else { set %skill.description $readini($char($1), descriptions, weaknessshift) }

  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  set %magic.types light.dark.fire.ice.water.lightning.wind.earth
  set %number.of.magic.types $numtok(%magic.types,46)

  set %weapon.types axe.bat.bow.dagger.energyblaster.glyph.greatsword.gun.hammer.handtohand.katana.lightsaber.mace.rifle.scythe.spear.stave.sword.wand.whip
  set %number.of.weapon.types $numtok(%weapon.types,46)

  var %current.magic.weakness $gettok(%magic.types,$rand(1,%number.of.magic.types),46)
  var %current.weapon.weakness  $gettok(%weapon.types,$rand(1,%number.of.weapon.types),46)

  ; Cycle through the magic modifiers and set them
  var %current.magic.mod 1
  while (%current.magic.mod <= %number.of.magic.types) {
    var %magic.modifier $gettok(%magic.types, %current.magic.mod, 46)

    if (%magic.modifier = %current.magic.weakness) { writeini $char($1) modifiers %magic.modifier 120 }
    else { writeini $char($1) modifiers %magic.modifier 10 }

    inc %current.magic.mod 1
  }

  ; Cycle through the weapon modifiers and set them
  var %current.weapon.mod 1
  while (%current.weapon.mod <= %number.of.weapon.types) {
    var %weapon.modifier $gettok(%weapon.types, %current.weapon.mod, 46)

    if (%weapon.modifier = %current.weapon.weakness) { writeini $char($1) modifiers %weapon.modifier 120 }
    else { writeini $char($1) modifiers %weapon.modifier 10 }

    inc %current.weapon.mod 1
  }

  unset %heal.number | unset %heals
  unset %strengths | unset %strength.number
  unset %weakness | unset %weakness.number
  unset %number.of.magic.types | unset %magic.types

  remini $char($1) modifiers HitWithWeakness

}

alias skill.completeweaknessshift {
  ; This skill will randomize weaknesses and resistances to $1

  if ($readini($char($1), descriptions, completeweaknessshift) = $null) { set %skill.description flashes with a bright light as $get_chr_name($1) changes weaknesses }
  else { set %skill.description $readini($char($1), descriptions, completeweaknessshift) }

  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  set %magic.types light.dark.fire.ice.water.lightning.wind.earth
  set %number.of.magic.types $numtok(%magic.types,46)

  set %weapon.types axe.bat.bow.dagger.energyblaster.glyph.greatsword.gun.hammer.handtohand.katana.lightsaber.mace.rifle.scythe.spear.stave.sword.wand.whip
  set %number.of.weapon.types $numtok(%weapon.types,46)

  var %current.magic.weakness $gettok(%magic.types,$rand(1,%number.of.magic.types),46)
  var %current.weapon.weakness  $gettok(%weapon.types,$rand(1,%number.of.weapon.types),46)

  ; Cycle through the magic modifiers and set them
  var %current.magic.mod 1
  while (%current.magic.mod <= %number.of.magic.types) {
    var %magic.modifier $gettok(%magic.types, %current.magic.mod, 46)

    if (%magic.modifier = %current.magic.weakness) { writeini $char($1) modifiers %magic.modifier 120 }
    else { writeini $char($1) modifiers %magic.modifier 10 }

    inc %current.magic.mod 1
  }

  ; Cycle through the weapon modifiers and set them
  var %current.weapon.mod 1
  while (%current.weapon.mod <= %number.of.weapon.types) {
    var %weapon.modifier $gettok(%weapon.types, %current.weapon.mod, 46)

    if (%weapon.modifier = %current.weapon.weakness) { writeini $char($1) modifiers %weapon.modifier 120 }
    else { writeini $char($1) modifiers %weapon.modifier 10 }

    inc %current.weapon.mod 1
  }


  var %current.resistance 1 | var %total.resistances $lines($lstfile(skills_resists.lst))
  while (%current.resistance <= %total.resistances) { 
    writeini $char($1) skills $read($lstfile(skills_resists.lst), %current.resistance) $rand(0,100)
    inc %current.resistance
  }

  ; If the skill is set to 2 or higher it will randomly pick a death condition out of the list
  if ($readini($char($1), skills, CompleteWeaknessShift) >= 2) {
    var %death.conditions melee.magic.tech.item.renkei.status.magiceffect
    var %random.deathcondition.number $rand(1,$numtok(%death.conditions,46))
    var %random.deathcondition $gettok(%death.conditions, %random.deathcondition.number, 46)
    writeini $char($1) info DeathConditions %random.deathcondition
  }

  unset %heal.number | unset %heals
  unset %strengths | unset %strength.number
  unset %weakness | unset %weakness.number
  unset %number.of.magic.types | unset %magic.types
}

;=================
; PROVOKE
;=================
on 3:TEXT:!provoke*:*: { $partial.name.match($nick, $2)  | $skill.provoke($nick, %attack.target) }

alias skill.provoke { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if ($skillhave.check($1, provoke) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  var %skill.name Provoke
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Provoke, !provoke, false)

  var %provoke.status $readini($char($2), battle, status)
  if ((%provoke.status = dead) || (%provoke.status = runaway)) { $display.message($readini(translation.dat, skill, provokeTargetDead),private) | halt }

  var %provoke.target $readini($char($2), skills, provoke.target)
  if (%provoke.target != $null) { $display.message($readini(translation.dat, skill, AlreadyBeingProvoked),private) | halt  }

  var %user.flag $readini($char($1), info, flag) 
  if (%user.flag = $null) { var %user.flag player }
  var %target.flag $readini($char($2), info, flag)

  if (%user.flag = player) && (%target.flag = player) { $readini(translation.dat, errors, CannotprovokePlayers) | halt }
  if (%user.flag = player) && (%target.flag = npc) { $readini(translation.dat, errors, CannotprovokePlayers) | halt }

  writeini $char($2) skills provoke.target $1

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(provoke))

  ; Display the desc. 
  set %enemy $get_chr_name($2) 
  if ($readini($char($1), descriptions, provoke) = $null) { $set_chr_name($2) | set %skill.description makes a series of gestures towards %real.name in order to provoke $gender2($2) }
  else { set %skill.description $readini($char($1), descriptions, provoke) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills provoke.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction provoke

  $skill.nextturn.check(Provoke, $1)
}

;=================
; WEAPON LOCK
;=================
on 3:TEXT:!weaponlock*:*: { $partial.name.match($nick, $2)  | $skill.weaponlock($nick, %attack.target) }
on 3:TEXT:!weapon lock*:*: { $partial.name.match($nick, $3)  | $skill.weaponlock($nick, %attack.target) }

alias skill.weaponlock { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  if ($readini($char($1), info, clone) = yes) { $display.message($readini(translation.dat, errors, ShadowClonesCan'tUseSkill,private)) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if ($skillhave.check($1, weaponlock) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 
  if (($2 = $1) && ($is_charmed($1) = false))  { $display.message($readini(translation.dat, errors, Can'tAttackYourself),private) | unset %real.name | halt  }

  var %skill.name WeaponLock
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, WeaponLock, !weapon lock, false)

  var %wpnlck.status $readini($char($2), battle, status)
  if ((%wpnlck.status = dead) || (%wpnlck.status = runaway)) { $display.message($readini(translation.dat, skill, WeaponLockTargetDead),private) | halt }

  var %user.flag $readini($char($1), info, flag) 
  if (%user.flag = $null) { var %user.flag player }
  var %target.flag $readini($char($2), info, flag)

  if (%mode.pvp = on) { var %user.flag monster }

  if (%user.flag = player) && (%target.flag = player) { $readini(translation.dat, errors, CannotWeaponLockPlayers) | halt }
  if (%user.flag = player) && (%target.flag = npc) { $readini(translation.dat, errors, CannotWeaponLockPlayers) | halt }

  var %weapon.lock.target $readini($char($2), status, weapon.locked)
  if (%weapon.lock.target != $null) { $display.message($readini(translation.dat, skill, AlreadyWeaponLocked),private) | halt  }

  ; Check for the item "Sokubaku" and consume it, or display an error if they don't have any.
  set %check.item $readini($char($1), item_amount, Sokubaku)
  if ((%check.item = $null) || (%check.item <= 0)) { $display.message(4Error: %real.name does not have enough Sokubaku to perform this skill,private) | halt }
  $decrease_item($1, Sokubaku) 

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(weaponlock))

  ; Display the desc. 
  if ($readini($char($1), descriptions, weaponlock) = $null) { $set_chr_name($2) | set %skill.description uses an ancient technique to place a powerful seal around %real.name $+ 's weapon, preventing $gender2($2) from removing or changing it. }
  else { set %skill.description $readini($char($1), descriptions, weaponlock) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills weaponlock.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction weaponlock


  if ($readini($char($2), info, flag) = monster) {
    ; Check for resistance to weaponlock
    set %resist.skill $readini($char($2), skills, resist-weaponlock)
    if (%resist.skill >= 100) { $set_chr_name($2) | $display.message(%real.name is immune to the weapon lock status!,battle) }

    else {    
      writeini $char($2) status weapon.locked yes 
      writeini $char($2) status weaponlock.timer 1 
    }

  }
  if (($readini($char($2), info, flag) = npc) || ($readini($char($2), info, flag) = $null)) {
    writeini $char($2) status weapon.locked yes 
    writeini $char($2) status weaponlock.timer 1 
  }

  $skill.nextturn.check(WeaponLock, $1)
}

;=================
; DISARM
;=================
on 3:TEXT:!disarm*:*: { $partial.name.match($nick, $2)  | $skill.disarm($nick, %attack.target) }

alias skill.disarm { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if ($skillhave.check($1, disarm) = false) { $set_chr_name($nick) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 
  if (($2 = $1) && ($is_charmed($1) = false))  { $display.message($readini(translation.dat, errors, Can'tAttackYourself),private) | unset %real.name | halt  }

  var %skill.name Disarm
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Disarm, !disarm, false)

  var %disarm.status $readini($char($2), battle, status)
  if ((%disarm.status = dead) || (%disarm.status = runaway)) { $display.message($readini(translation.dat, skill, DisarmTargetDead),private) | halt }

  var %user.flag $readini($char($1), info, flag) 
  if (%user.flag = $null) { var %user.flag player }
  var %target.flag $readini($char($2), info, flag)

  if (%mode.pvp = on) { var %user.flag monster }

  if (%user.flag = player) && (%target.flag = player) { $readini(translation.dat, errors, CannotDisarmPlayers) | halt }
  if (%user.flag = player) && (%target.flag = npc) { $readini(translation.dat, errors, CannotDisarmPlayers) | halt }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(disarm))

  ; Display the desc. 
  if ($readini($char($1), descriptions, disarm) = $null) { $set_chr_name($2) | set %skill.description grapples with %real.name in an attempt to disarm $gender2($2) }
  else { set %skill.description $readini($char($1), descriptions, disarm) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills disarm.time %true.turn

  var %disarm.chance $rand(1,100)
  var %skill.disarm $readini($char($1), skills, disarm)
  inc %disarm.chance %skill.disarm

  var %disarm.protection $readini($char($2), skills, resist-disarm)
  if (%disarm.protection != $null) { dec %disarm.chance %disarm.protection }

  if (%disarm.chance >= 60) {
    writeini $char($2) weapons equipped fists
    if ($readini($char($2), weapons, fists) = $null) { writeini $char($2) weapons fists $readini(battlestats.dat, battle, winningstreak) }
    $set_chr_name($1) | $display.message($readini(translation.dat, skill, DisarmedTarget), battle)
  }
  if (%disarm.chance < 60) { 
    $set_chr_name($1) | $display.message($readini(translation.dat, skill, UnableToDisarm), battle) 
  }

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction disarm

  $skill.nextturn.check(Disarm, $1)
}

;=================
; KONZEN-ITTAI
;=================
on 3:TEXT:!konzen-ittai*:*:{ $skill.konzen-ittai($nick) }

alias skill.konzen-ittai { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, Konzen-ittai) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Konzen-ittai
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Konzen-ittai, !konzen-ittai, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(konzen-ittai))

  ; Display the desc. 
  if ($readini($char($1), descriptions, Konzen-ittai) = $null) { set %skill.description channels an ancient power of the samurai that helps increase the amount of renkei $gender($1) weapon is worth. }
  else { set %skill.description $readini($char($1), descriptions, Konzen-ittai) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the flag & write the last used time.
  writeini $char($1) skills konzen-ittai.on on
  writeini $char($1) skills konzen-ittai.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction konzen-ittai

  $skill.nextturn.check(Konzen-ittai, $1)
}

;=================
; Seal Break
;=================
on 3:TEXT:!sealbreak*:*: { $skill.sealbreak($nick) }
on 3:TEXT:!seal break*:*: { $skill.sealbreak($nick) }

alias skill.sealbreak { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if ($readini($char($1), info, clone) = yes) { $display.message($readini(translation.dat, errors, ShadowClonesCan'tUseSkill,private)) | halt }

  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  $check_for_battle($1)

  if ($skillhave.check($1, sealbreak) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }

  var %skill.name SealBreak
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  if ((no-item isin %battleconditions) && (no-items isin %battleconditions))  { $display.message($readini(translation.dat, errors, SkillWon'tWorkWithSeal), private) | halt }

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, SealBreak, !seal break, false)

  ; Check for the item "Hankai" and consume it, or display an error if they don't have any.
  set %check.item $readini($char($1), item_amount, Hankai)
  if ((%check.item = $null) || (%check.item <= 0)) { $set_chr_name($1) | $display.message(4Error: %real.name does not have enough Hankai to perform this skill, private) | halt }
  $decrease_item($1, Hankai) 

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(sealbreak))

  ; Display the desc. 
  if ($readini($char($1), descriptions, sealbreak) = $null) { $set_chr_name($2) | set %skill.description lays some Hankai powder upon the seal and chants a powerful mantra in an attempt to break the seal. }
  else { set %skill.description $readini($char($1), descriptions, sealbreak) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills sealbreak.time %true.turn
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction sealbreak

  var %random.chance $rand(1,100)
  var %chance.of.working $calc($readini($char($1), skills, sealbreak) * 10)
  if (%random.chance <= %chance.of.working) { $display.message($readini(translation.dat, skill, SealBreaks), battle) | unset %battleconditions }
  if (%random.chance > %chance.of.working) { $display.message($readini(translation.dat, skill, SealStays), battle) }

  $skill.nextturn.check(SealBreak, $1)
}

;=================
; MAGIC MIRROR
;=================
on 3:TEXT:!magicmirror*:*: { $skill.magicmirror($nick) }

alias skill.magicmirror { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, magicmirror) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, MagicMirror, !magicmirror, true)

  var %skill.name MagicMirror
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check for the item "MirrorShard" and consume it, or display an error if they don't have any.
  set %check.item $readini($char($1), item_amount, MirrorShard)
  if ((%check.item = $null) || (%check.item <= 0)) { $display.message(4Error: %real.name does not have enough MirrorShards to perform this skill, private) | halt }
  $decrease_item($1, MirrorShard) 

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(magicmirror))

  ; Display the desc. 
  if ($readini($char($1), descriptions, magicmirror) = $null) { $set_chr_name($1) | set %skill.description pulls out a magic mirror shard which expands into a large reflective barrier around %real.name $+ 's body. }
  else { set %skill.description $readini($char($1), descriptions, magicmirror) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the magicmirror-on flag & write the last used time.
  writeini $char($1) status reflect yes
  writeini $char($1) status reflect.timer 1
  writeini $char($1) skills magicmirror.time %true.turn

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction magicmirror

  $skill.nextturn.check(MagicMirror, $1)
}

;=================
; GAMBLE
;=================
on 3:TEXT:!gamble*:*: { $skill.gamble($nick) }

alias skill.gamble { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, gamble) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill),private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Gamble
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Gamble, !gamble, true)

  ; Check for 1k orbs
  set %check.item $readini($char($1), stuff, RedOrbs)
  var %gamble.cost 1000

  if ($return.playerstyle($1) = HighRoller) { var %gamble.cost 200 }

  if ((%check.item = $null) || (%check.item <= %gamble.cost)) { $display.message(4Error: %real.name does not have enough $readini(system.dat, system, currency) to perform this skill [need $calc(%gamble.cost - %check.item) more!], private) | halt }
  dec %check.item %gamble.cost
  writeini $char($1) stuff RedOrbs %check.item

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(gamble))

  ; Display the desc. 
  if ($readini($char($1), descriptions, gamble) = $null) { $set_chr_name($1) | set %skill.description sacrficies %gamble.cost $readini(system.dat, system, currency) to summon a magic slot machine. %real.name pulls the handle....  }
  else { set %skill.description $readini($char($1), descriptions, gamble) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the last used flag
  writeini $char($1) skills gamble.time %true.turn
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction gamble

  ; Time to gamble, baby!
  var %gamble.chance $rand(1,100) 

  if (%gamble.chance = 1) { $display.message(12JACKPOT! %real.name $+ 's health, tp, and Ignition Gauge are all filled!, battle)
    if ($readini($char($1), battle, hp) < $readini($char($1), basestats, hp)) {  writeini $char($1) battle hp $readini($char($1), basestats, hp) }
    writeini $char($1) battle tp $readini($char($1), basestats, tp)
    writeini $char($1) battle IgnitionGauge $readini($char($1), basestats, IgnitionGauge)
  }
  if ((%gamble.chance >= 2) && (%gamble.chance <= 10)) { $display.message(12The slot machine spins and %real.name wins! %real.name $+ 's HP has been restored!, battle)
    if ($readini($char($1), battle, hp) < $readini($char($1), basestats, hp)) {  writeini $char($1) battle hp $readini($char($1), basestats, hp) }
  }
  if ((%gamble.chance > 10) && (%gamble.chance <= 15)) { $display.message(12The slot machine spins and %real.name wins! %real.name $+ 's TP has been restored!, battle)
    writeini $char($1) battle tp $readini($char($1), basestats, tp)
  }
  if ((%gamble.chance > 15) && (%gamble.chance <= 45)) { $inflict_status(Slot Machine, $1, random, IgnoreResistance) | $set_chr_name($1) | $display.message(12The slot machine spins and %real.name loses!4  %statusmessage.display, battle)  | unset %statusmessage.display  }
  if ((%gamble.chance > 45) && (%gamble.chance <= 55)) { $clear_most_status($1) | $display.message(12The slot machine spins and %real.name wins! Most of %real.name $+ 's statuses have been removed!, battle) }
  if ((%gamble.chance > 55) && (%gamble.chance <= 65)) { 
    writeini $char($1) battle hp $round($calc($readini($char($1), battle, hp) /2),0)
    $display.message(12The slot machine spins and %real.name loses!4 %real.name loses half of $gender($1) current HP! , battle)
  }

  if ((%gamble.chance > 65) && (%gamble.chance <= 75)) {
    var %random.item.list $rand(1,2)

    if (%random.item.list = 1) { set %item.list items_healing.lst }
    if (%random.item.list = 2) { set %item.list items_misc.lst }

    var %items.lines $lines($lstfile(%item.list))
    if (%items.lines = 0) { set %gamble.item MegaPotion }
    else { 
      set %random.line $rand(1, %items.lines)
      if (%random.line = $null) { var %random 1 }
      set %random.item.contents $read -l $+ %random.line $lstfile(%item.list)
      set %gamble.item %random.item.contents
      unset %random.item.contents | unset %random.line | unset %random.line
    }

    set %current.plyr.item.total $readini($char($1), Item_Amount, %gamble.item) 
    if (%current.plyr.item.total = $null) { var %current.plyr.item.total 0 }
    inc %current.plyr.item.total 1 | writeini $char($1) Item_Amount %gamble.item %current.plyr.item.total 

    $display.message(12The slot machine spins and %real.name wins a(n) %gamble.item $+ !, battle)
  }
  if ((%gamble.chance > 75) && (%gamble.chance <= 80)) { 
    writeini $char($1) status orbbonus yes
    $display.message(12The slot machine spins and %real.name wins! %real.name will receive an orb bonus at the end of battle!, battle)
  }
  if ((%gamble.chance > 80) && (%gamble.chance <= 85)) {  $display.message(12The slot machine spins and %real.name breaks even!, battle)
    var %red.orbs $readini($char($1), stuff, RedOrbs)
    inc %red.orbs 1000
    writeini $char($1) stuff RedOrbs %red.orbs
  }
  if ((%gamble.chance > 85) && (%gamble.chance <= 95)) { $set_chr_name($1) | $display.message(12The slot machine spins and %real.name loses!  But nothing seems to happen!, battle) }
  if ((%gamble.chance > 95) && (%gamble.chance < 100)) {
    $inflict_status(Slot Machine, $1, random, IgnoreResistance) | $display.message(12BUST! %real.name $+ 's health and tp are cut in half! 4  %statusmessage.display, battle) | unset %statusmessage.display 
    writeini $char($1) battle hp $round($calc($readini($char($1), battle, hp) /2),0)
    writeini $char($1) battle tp $round($calc($readini($char($1), battle, tp) /2),0)
  }

  if (%gamble.chance = 100) { $display.message(12The slot machine spins and %real.name wins! %real.name $+ 's Ignition Gauge has been restored!, battle)
    writeini $char($1) battle IgnitionGauge $readini($char($1), basestats, IgnitionGauge)
  }

  $skill.nextturn.check(Gamble, $1)
}

;=================
; BLOODPACT
;=================
alias skill.bloodpact {
  ; $1 = user
  ; $2 = name of summon
  ; $3 = item used to summon

  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }

  .copy -o $summon($2) $char($1 $+ _summon)

  ; Add to battle
  set %curbat $readini($txtfile(battle2.txt), Battle, List)
  %curbat = $addtok(%curbat,$1 $+ _summon,46)
  writeini $txtfile(battle2.txt) Battle List %curbat
  write $txtfile(battle.txt) $1 $+ _summon

  ; Display the desc. 
  $set_chr_name($1) 
  if ($readini($char($1), descriptions, bloodpact) = $null) { $set_chr_name($1  $+ _summon) | set %skill.description The $3 explodes and summons %real.name $+ !   }
  else { set %skill.description  $+ %real.name  $+ $readini($char($1), descriptions, bloodpact) }
  $display.message(4 $+ %skill.description, battle)

  $set_chr_name($1 $+ _summon) | $display.message(12 $+ %real.name  $+ $readini($char($1 $+ _summon), descriptions, char), battle)

  writeini $char($1 $+ _summon) info summon yes
  writeini $char($1 $+ _summon) info owner $1
  writeini $char($1 $+ _summon) access list $1

  if ($augment.check($1, EnhanceBloodpact) != true) {
    ; Set the user's TP to 0.
    writeini $char($1) Battle TP 0
  }

  if ($augment.check($1, EnhanceBloodpact) = true) {
    writeini $char($1) battle TP $round($calc($readini($char($1), battle, tp) / 2),0)
  }

  set %bloodpact.level $readini($char($1), skills, BloodPact)
  if (%bloodpact.level >= 1) { $boost_summon_stats($1, %bloodpact.level, $2)  }
  unset %bloodpact.level

  var %temp.flag $readini($char($1), info, flag)
  if (%temp.flag = monster) { 

    writeini $char($1 $+ _summon) info flag monster | remini $char($1) skills bloodpact 

  }
  if (%temp.flag = npc) { remini $char($1) skills bloodpact }

  ; Initialize the action points 
  $action.points($1 $+ _summon, initialize)

  if (%portal.bonus != true) { writeini $char($1 $+ _summon) info FirstTurn true }

  return
}

;=================
; THIRD EYE
;=================
on 3:TEXT:!third eye*:*: { $skill.thirdeye($nick) }
on 3:TEXT:!thirdeye*:*: { $skill.thirdeye($nick) }

alias skill.thirdeye { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ThirdEye) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name ThirdEye
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Check to see if enough time has elapsed
  $skill.turncheck($1, ThirdEye, !third eye, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(thirdeye))

  ; Display the desc. 
  if ($readini($char($1), descriptions, ThirdEye) = $null) { set %skill.description uses an ancient Samurai skill to increase the odds of dodging attacks. }
  else { set %skill.description $readini($char($1), descriptions, ThirdEye) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the ThirdEye-on flag & write the last used time.
  writeini $char($1) skills ThirdEye.on on
  writeini $char($1) skills ThirdEye.time %true.turn 

  var %thirdeye.dodges $rand(1,2)

  if ($augment.check($1, EnhanceThirdEye) = true) {
    inc %thirdeye.dodges %augment.strength
  }

  writeini $char($1) status Thirdeye.turn %thirdeye.dodges

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction ThirdEye

  $skill.nextturn.check(ThirdEye, $1)
}

;=================
; SCAVENGE
;=================
on 3:TEXT:!scavenge*:*: { $skill.scavenge($nick, $2, !scavenge) }

alias skill.scavenge { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, scavenge) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)

  var %skill.name Scavenge
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 


  ; Can we use scavenge again?
  if ($readini($char($1), skills, scavenge.on) = on) { $display.message($readini(translation.dat, skill, ScavengeAlreadyUsed), private) | halt }

  ; Check to see if the battlefield even has an item pool
  set %scavenge.pool $readini($dbfile(battlefields.db), %current.battlefield, scavenge)
  if ((%scavenge.pool = $null) || (%scavenge.pool = none)) { unset %scavenge.pool | $set_chr_name($1) | $display.message($readini(translation.dat, skill, ScavengeNothingToGet), private) | halt }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(scavenge))

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($1), descriptions, scavenge) = $null) { set %skill.description drops to the ground and begins digging, hoping to find something of use buried in the battlefield. }
  else { set %skill.description $readini($char($1), descriptions, scavenge) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Turn the used flag on
  writeini $char($1) skills scavenge.on on

  ; Now to check to see if we scavenge something.
  var %scavenge.chance $rand(1,100)
  var %skill.scavenge $readini($char($1), skills, scavenge)
  inc %scavenge.chance %skill.scavenge

  ; Check augment
  if ($augment.check($1, EnhanceScavenge) = true) {  inc %scavenge.chance $calc(2 * %augment.strength) }

  ; Did the player find anything?
  if (%scavenge.chance >= 55) {

    set %total.items $numtok(%scavenge.pool, 46)
    set %random.item $rand(1,%total.items)
    set %scavenge.item $gettok(%scavenge.pool,%random.item,46)

    set %current.item.total $readini($char($1), Item_Amount, %scavenge.item) 
    if (%current.item.total = $null) { var %current.item.total 0 }
    inc %current.item.total 1 | writeini $char($1) Item_Amount %scavenge.item %current.item.total 
    $set_chr_name($1) | $display.message($readini(translation.dat, skill, ScavengeSuccessful), battle)
  }

  else { $set_chr_name($1) | $display.message($readini(translation.dat, skill, ScavengeFailed), battle) }

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction scavenge 

  unset %enemy | unset %total.items | unset %random.item | unset %scavenge.item | unset %current.item.total | unset %scavenge.pool 

  $skill.nextturn.check(Scavenge, $1)
}

;=================
; PERFECT COUNTER
;=================
on 3:TEXT:!perfectcounter*:*: { $skill.perfectcounter($nick) }
on 3:TEXT:!perfect counter*:*: { $skill.perfectcounter($nick) }

alias skill.perfectcounter { $set_chr_name($1) | $check_for_battle($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  set %current.playerstyle $readini($char($1), styles, equipped)
  if (%current.playerstyle != CounterStance) { $display.message(4Error: This command can only be used while the CounterStance style is equipped!, private) | unset %current.playerstyle | halt }

  if ($readini($char($1), skills, perfectcounter.on) != $null) { $display.message(4 $+ %real.name cannot use $gender($1) Perfect Counter again this battle!, private) | halt }

  writeini $char($1) skills perfectcounter.on on 

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(perfectcounter))

  if ($readini($char($nick), descriptions, PerfectCounter) = $null) { $set_chr_name($1) | set %skill.description performs an ancient technique perfected by monks to ensure a perfect melee counter! }
  else { set %skill.description $readini($char($nick), descriptions, perfectcounter) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  unset %current.playerstyle | unset %current.playerstyle.level | unset %quicksilver.used

  $skill.nextturn.check(PerfectCounter, $1)
}

;=================
; RETALIATION
;=================
on 3:TEXT:!retaliation*:*: { $skill.retaliation($nick) }

alias skill.retaliation { $set_chr_name($1) |  $check_for_battle($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  var %skill.name Retaliation
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, Retaliation, !retaliation, true)

  ; Is the skill still on?
  if ($readini($char($1), skills, retaliation.on) = on) { $display.message(4 $+ %real.name cannot use $gender($1) Retaliation again so soon!, private) | halt }

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(retaliation))

  ; Display the desc. 
  if ($readini($char($1), descriptions, Retaliation) = $null) { set %skill.description stands perfectly still and waits to be attacked. }
  else { set %skill.description $readini($char($1), descriptions, Retaliation) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Toggle the Retaliation-on flag & write the last used time.
  writeini $char($1) skills Retaliation.on on
  writeini $char($1) skills Retaliation.time %true.turn 

  unset %current.playerstyle | unset %current.playerstyle.level | unset %quicksilver.used

  $skill.nextturn.check(Retaliation, $1)
}

;=================
; JUST RELEASE
;=================
on 3:TEXT:!justrelease*:*: { $partial.name.match($1, $2) | $skill.justrelease($nick, %attack.target, !justrelease) }
on 3:TEXT:!just release*:*: { $partial.name.match($1, $3) | $skill.justrelease($nick, %attack.target, !justrelease) }

alias skill.justrelease { $set_chr_name($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  if ($readini($char($1), info, clone) = yes) { $display.message($readini(translation.dat, errors, ShadowClonesCan'tUseSkill,private)) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, JustRelease) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.message($readini(translation.dat, errors, NoBattleCurrently),private) | halt }
  $check_for_battle($1)
  $person_in_battle($2)

  var %skill.name JustRelease
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  var %target.flag $readini($char($2), info, flag)
  if (($readini($char($1), info, flag) = $null) && (%target.flag != monster)) { $set_chr_name($1) | $display.message(4 $+ %real.name can only Just Release on monsters!, private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot steal while unconcious!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot steal from someone who is dead!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $display.message(4 $+ %real.name cannot  Just Release on $set_chr_name($2) %real.name $+ , because %real.name has run away from the fight!, private) | unset %real.name | halt } 

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(justrelease))

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($1), descriptions, JustRelease) = $null) { set %skill.description unleashes all of $gender($1) blocked damage upon %enemy $+ ! }
  else { set %skill.description $readini($char($1), descriptions, JustRelease) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Get the attack damage.

  var %block.damage $readini($char($1), skills, royalguard.dmgblocked)
  if (%block.damage = $null) { var %block.damage 0 }

  ; Clear the blocked damage meter.
  writeini $char($1) skills royalguard.dmgblocked 0

  ; Calculate the total damage we'll do.
  set %attack.damage $round($calc(($readini($char($1), skills, JustRelease) /100) * %block.damage),0)  

  ; Check for the JustReleaseDefense on monsters.
  if ($readini($char($2), info, JustReleaseDefense) > 0) {
    var %justreleasedef $readini($char($2), info, JustReleaseDefense)
    var %justreleasedef $calc(%justreleasedef / 100)
    dec %attack.damage $round($calc(%attack.damage * %justreleasedef),0)
  }

  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb
  unset %enemy | unset %user | unset %real.name

  ; Calculate, deal, and display the damage..
  $deal_damage($1, $2, JustRelease)
  $display_damage($1, $2, skill, JustRelease)

  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction JustRelease

  unset %enemy

  $skill.nextturn.check(JustRelease, $1)
}

;=================
; STONESKIN
;=================
on 3:TEXT:!stoneskin*:*: { $skill.stoneskin($nick) }
on 3:TEXT:!stone skin:*: { $skill.stoneskin($nick) }

alias skill.stoneskin { $set_chr_name($1)
  if ($skillhave.check($1, Stoneskin) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $check_for_battle($1)

  if ($readini($char($1), skills, stoneskin.time) != $null) { $display.message(4Error: This skill can only be used once per battle!, private) | halt }

  writeini $char($1) skills stoneskin.time $ctime

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(stoneskin))

  ; Show the desc
  if ($readini($char($1), descriptions, stoneskin) = $null) { $set_chr_name($1) | set %skill.description unleashes the power of stoneskin! %real.name $+ 's body becomes hard as stone and gains a natural shielding. }
  else { set %skill.description $readini($char($1), descriptions, stoneskin) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Add the stoneskin
  var %user.int $readini($char($1), battle, int)
  var %user.stoneskin.level $readini($char($1), skills, stoneskin)
  var %stoneskin.max $round($calc(%user.int * ((%user.stoneskin.level + 10) /100)),0)
  var %stoneskin.max.perpoint $calc(%user.stoneskin.level * 300)

  if (%stoneskin.max > %stoneskin.max.perpoint) { var %stoneskin.max %stoneskin.max.perpoint }

  writeini $char($1) NaturalArmor Max %stoneskin.max
  writeini $char($1) NaturalArmor Current %stoneskin.max
  writeini $char($1) NaturalArmor Name Stoneskin

  $display.message(12 $+ %real.name has gained %stoneskin.max natural armor, battle) 

  unset %current.playerstyle | unset %current.playerstyle.level | unset %stoneskin.used

  $skill.nextturn.check(StoneSkin, $1)
}

;=================
; TABULA RASA
;=================
on 3:TEXT:!tabularasa*:*: { $partial.name.match($nick, $2)  | $skill.tabularasa($nick, %attack.target) }
on 3:TEXT:!tabula rasa *:*: { $partial.name.match($nick, $3)  | $skill.tabularasa($nick, %attack.target) }

alias skill.tabularasa { $set_chr_name($1)
  if ($skillhave.check($1, TabulaRasa) = false) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $check_for_battle($1)
  $checkchar($1)
  $person_in_battle($2)

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, TabulaRasa, !tabula rasa, true)

  writeini $char($1) skills tabularasa.time %true.turn

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(TabulaRasa))

  ; Show the desc
  if ($readini($char($1), descriptions, tabularasa) = $null) { $set_chr_name($2) | set %skill.description unleashes a powerful and ancient technique upon %real.name in an attempt to inflict amnesia. }
  else { set %skill.description $readini($char($1), descriptions, tabularasa) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; check for immunity/resistance and inflict amensia
  var %resist.skill $readini($char($2), skills, resist-amnesia)
  if (%resist.skill = $null) { var %resist.skill 0 }

  $set_chr_name($2)
  if (%resist.skill = 100) { $display.message(4 $+ %real.name is immune to the amnesia status!, battle)
  }
  if (%resist.skill < 100) { 
    var %inflict.chance $calc(40 + $readini($char($1), skills, tabularasa))
    dec %inflict.chance %resist.skill
    if (%inflict.chance <= 0) { $display.message(4 $+ %real.name has resisted the amnesia status!, battle) }
    if ($rand(1,100) <= %inflict.chance) { 
      writeini $char($2) status amnesia yes
      $display.message(4 $+ %real.name is now inflicted with amnesia!, battle)
    } 
  }

  unset %current.playerstyle | unset %current.playerstyle.level | unset %stoneskin.used

  $skill.nextturn.check(TabulaRasa, $1)
}

;=================
; WARP
;=================
on 3:TEXT:!warp *:*: { $skill.warp($nick, $2-) }
alias skill.warp { $set_chr_name($1)
  if ($skillhave.check($1, warp) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private) | halt }
  if ((%battleis = on) && (%battleisopen != on)) { $display.system.message($readini(translation.dat, errors, Can'tUseSkillInBattle), private) | halt }
  if (%warp.battlefield != $null) { $display.message(4The Warp skill has already been used this battle!, private) | halt }

  ; Check the battlefield.
  var %battlefield = $read($lstfile(battlefields.lst), w, $2-)
  if (%battlefield = $null) { $display.private.message2($1, 4There is no such battlefield or you cannot warp to it using this skill.) | halt  }

  ; Check for 2k orbs
  set %check.item $readini($char($1), stuff, RedOrbs)
  if ((%check.item = $null) || (%check.item <= 2000)) { $display.system.message(4Error: %real.name does not have enough $readini(system.dat, system, currency) to perform this skill [need $calc(2000 - %check.item) more!], private) | halt }
  dec %check.item 2000
  writeini $char($1) stuff RedOrbs %check.item

  set %warp.battlefield %battlefield

  ; Display the desc.
  if ($readini($char($1), descriptions, warp) = $null) { $set_chr_name($1) | set %skill.description uses 2,000 $readini(system.dat, system, currency) to warp the next battle to the $2 battlefield! }
  else { set %skill.description $readini($char($1), descriptions, warp) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, global)

  unset %check.item | unset %skill.description
}

;=================
; OVERWHELM
;=================
; This enhancement point skill increases damage
; by 1% per skill level

alias skill.overwhelm {
  ; $1 = the person we're checking

  if (%attack.damage = 0) { return }
  if (%guard.message != $null) { return }

  var %skill.level $readini($char($1), skills, Overwhelm)
  if ((%skill.level = 0) || (%skill.level = $null)) { return }

  var %damage.increase $return_percentofvalue(%attack.damage, $calc(2 * %skill.level))
  inc %attack.damage %damage.increase
  return
}


;=================
; WRESTLE
;=================
on 3:TEXT:!wrestle *:*: { $partial.name.match($nick, $2) | $skill.wrestle($nick, %attack.target) }

alias skill.wrestle { $set_chr_name($1)
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFled),private) | unset %real.name | halt } 
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if (($return.playerstyle($1) != Wrestlemania) && ($readini($char($1), info, flag) = $null)) { $display.message(4Error: This command can only be used while the Wrestlemania style is equipped!, private) | halt }
  if (%mode.pvp = on) { $display.message($readini(translation.dat, errors, ActionDisabledForPVP), private) | halt }

  $check_for_battle($1)

  if ($readini($char($1), info, flag) = $null) { 
    var %current.playerstyle.level $readini($char($1), styles, $return.playerstyle($1))
    var %wrestle.used $readini($char($1), skills, wrestle.used)
    var %wrestle.turn $readini($char($1), skills, wrestle.turn)
    if (%wrestle.used = $null) { set %wrestle.used 0 }
    if (%wrestle.turn = $null) { set %wrestle.turn -1 }

    if (%wrestle.used >= %current.playerstyle.level) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot use $gender($1) wrestling moves again this battle!,private) | unset %current.playerstyle | halt }
    if (($calc(%wrestle.turn + 1) = %true.turn) || (%wrestle.turn = %true.turn)) { $set_chr_name($1) | $display.message(4 $+ %real.name cannot use $gender($1) wrestling moves again so quickly!, private) | unset %current.playerstyle | halt }
  }

  inc %wrestle.used 1 | writeini $char($1) skills wrestle.used %wrestle.used
  writeini $char($1) skills wrestle.turn %true.turn

  ; Decrease the action points
  $action.points($1, remove, 3)

  var %skill.description $read($txtfile(attack_wrestle.txt))
  if (%skill.description = $nulll) {  $set_chr_name($2) | var %skill.description performs a powerful wrestling move on %real.name $+ ! }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  writeini $txtfile(battle2.txt) style $1 $+ .lastaction wrestle

  ; If the target is ethereal, we miss
  if ($readini($char($2), status, ethereal) = yes) { $display.message(4 $+ %real.name $+ 's wrestling move goes right through $get_chr_name($2) $+ !, battle) }
  else { 
    ; Reduce the target's HP by style.level %
    var %target.hp $readini($char($2), battle, hp)

    ; Check for an accessory to increase the Wrestling Damage
    if ($accessory.check($1, IncreaseWrestlingDamage) = true) {
      inc %current.playerstyle.level %accessory.amount
      unset %accessory.amount
    }

    set %attack.damage $return_percentofvalue(%target.hp, %current.playerstyle.level)

    if ($readini($char($2), Info, MetalDefense) = true) { set %attack.damage 1 }

    $deal_damage($1, $2, skill, none)
    $display_damage($1, $2)

    ; If the target is not a 'large' target, attempt to stun
    var %monster.size $readini($char($2), monster, size) 
    if (($person_in_mech($1) = false) && (%monster.size != large)) {

      var %resist.skill $readini($char($2), skills, resist-stun)
      if (%resist.skill = $null) { var %resist.skill 0 }

      var %stun.chance $rand(1,100)
      dec %stun.chance %resist.skill

      inc %resist.skill 10
      writeini $char($2) skills resist-stun %resist.skill

      if ($readini($char($2), battle, hp) > 0) { 
        if ((%stun.chance >= 1) && (%stun.chance <= 50)) { 
          writeini $char($2) status stun yes
          $display.message(4 $+ $get_chr_name($2) is now stunned!, battle)
        }
      }
    }
  }

  unset %attack.damage | unset %skill.description

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}


;=================
; CARD SHARK
;=================
on 3:TEXT:!cardshark *:*: { 
  if ($3 = $null) { $display.message(4Error: !cardshark item target,private) | halt }
  if ($readini($dbfile(items.db), $2, type) != TradingCard) { $display.message(4Error: !cardshark trading-card target,private) | halt }
  if (($readini($char($nick), item_amount, $2) = $null) || ($readini($char($nick), item_amount, $2) <= 0)) { $set_chr_name($1) | $display.message(4Error: $nick does not have any $2 to perform this skill, private) | halt }

  $partial.name.match($nick, $3) |  $skill.cardshark($nick, %attack.target, $2) 
}

alias skill.cardshark { $set_chr_name($1)
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFled),private) | unset %real.name | halt } 
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if (%battleis = off) { $display.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if (($return.playerstyle($1) != HighRoller) && ($readini($char($1), info, flag) = $null)) { $display.message(4Error: This command can only be used while the HighRoller style is equipped!, private) | halt }
  if (%mode.pvp = on) { $display.message($readini(translation.dat, errors, ActionDisabledForPVP), private) | halt }

  ; Check the rarity of the card vs the level of the style
  var %style.level $readini($char($1), styles, HighRoller)
  var %card.rarity $readini($dbfile(items.db), $3, Rarity)
  if (%style.level < %card.rarity) {  $display.message(4Error: %real.name cannot use this card as the rarity is too high for the current style level.) | halt  }

  $check_for_battle($1)

  ; Decrease the action points
  $action.points($1, remove, 3)

  ; Show the description
  if ($readini($char($1), descriptions, CardShark) = $null) { var %skill.description unleashes the power of the monster pictured on the $3 $+ ! }
  else { set %skill.description $readini($char($1), descriptions, CardShark) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 
  unset %skill.description

  ; Write the last action
  writeini $txtfile(battle2.txt) style $1 $+ .lastaction CardShark

  ; Decrease the amount of the card
  var %card.amount $readini($char($1), item_amount, $3)
  dec %card.amount 1
  writeini $char($1) item_amount $3 %card.amount

  ; Activate one of the random techniques
  var %card.powers $readini($dbfile(items.db), $3, Powers)
  var %total.techs $numtok(%card.powers, 46)
  var %random.tech $rand(1, %total.techs)
  var %card.technique $gettok(%card.powers,%random.tech,46)

  ; Clear some attack variables
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged 
  unset %techincrease.check | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on  | unset %lastaction.nerf

  ; Perform the technique upon the target
  ; Get the tech type
  var %tech.type $readini($dbfile(techniques.db), %card.technique, type)

  if (%tech.type = heal) { $tech.heal($1, %card.technique, %attack.target) }
  if (%tech.type = heal-aoe) { $tech.aoeheal($1, %card.technique, %attack.target) }
  if (%tech.type = single) {  $covercheck(%attack.target, $2) | $tech.single($1, %card.technique, %attack.target )  }
  if (%tech.type = suicide) { $covercheck(%attack.target, $2) | $tech.suicide($1, %card.technique, %attack.target )  }
  if (%tech.type = death) { $covercheck(%attack.target, $2) | $tech.death($1, %card.technique, %attack.target) } 
  if (%tech.type = death-aoe) { $covercheck(%attack.target, AOE) | $tech.deathaoe($1, %card.technique, %attack.target, monster) | halt }
  if (%tech.type = suicide-AOE) { $covercheck(%attack.target, AOE) | $tech.aoe($1, %card.technique, %attack.target, monster, suicide) | halt }
  if (%tech.type = status) { $covercheck(%attack.target, $2) | $tech.single($1, %card.technique, %attack.target ) } 
  if (%tech.type = stealPower) { $covercheck(%attack.target, $2) | $tech.stealPower($1, %card.technique, %attack.target ) }
  if (%tech.type = AOE) { $covercheck(%attack.target, AOE) | $tech.aoe($1, %card.technique, %attack.target, monster) | halt }

  $skill.nextturn.check(CardShark, $1)
}

;=================
; LUCID DREAMING
;=================
on 3:TEXT:!luciddreaming*:*: { $skill.luciddreaming($nick) }
on 3:TEXT:!lucid dreaming*:*: { $skill.luciddreaming($nick) }

alias skill.luciddreaming { $set_chr_name($1) |  $check_for_battle($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  var %skill.name luciddreaming
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, luciddreaming, !luciddreaming, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(luciddreaming))

  ; Display the desc. 
  if ($readini($char($1), descriptions, luciddreaming) = $null) { set %skill.description performs an ancient technique to reduce $gender($1) enmity. }
  else { set %skill.description $readini($char($1), descriptions, luciddreaming) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; write the last used time.
  writeini $char($1) skills luciddreaming.time %true.turn 

  ; Cut the enmity in half
  var %current.enmity $enmity($1, return)
  $enmity($1, remove, $calc(%current.enmity / 2))

  $skill.nextturn.check(LucidDreaming, $1)
}

;=================
; SOFT BLOWS
;=================
on 3:TEXT:!softblows*:*: { $skill.softblows($nick) }
on 3:TEXT:!soft blows:*: { $skill.softblows($nick) }

alias skill.softblows { $set_chr_name($1) |  $check_for_battle($1)
  if ($person_in_mech($1) = true) { $display.message($readini(translation.dat, errors, Can'tDoThatInMech), private) | halt }
  $no.turn.check($1)
  if (no-skill isin %battleconditions) { $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  var %skill.name softblows
  if (($skill.needtoequip(%skill.name) = true) && ($skill.equipped.check($1, %skill.name) = false)) { $display.message($readini(translation.dat, errors, SkillNeedsToBeEquippedToUse), private) | halt } 

  ; Check to see if enough time has elapsed
  $skill.turncheck($1, softblows, !softblows, true)

  ; Decrease the action points
  $action.points($1, remove, $skill.actionpointcheck(softblows))

  ; Display the desc. 
  if ($readini($char($1), descriptions, softblows) = $null) { set %skill.description performs an ancient technique to deal damage without increasing enmity }
  else { set %skill.description $readini($char($1), descriptions, softblows) }
  $set_chr_name($1) | $display.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Turn the skill on and write the last used time.
  writeini $char($1) skills softblows.on on
  writeini $char($1) skills softblows.time %true.turn 

  $skill.nextturn.check(SoftBlows, $1)
}
