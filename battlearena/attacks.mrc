;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ATTACKS COMMAND
;;;; Last updated: 09/06/19
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 3:ACTION:attacks *:#:{ 
  $no.turn.check($nick)
  $set_chr_name($nick) 
  $partial.name.match($nick, $2)
  $covercheck(%attack.target)
  $attack_cmd($nick , %attack.target) 
} 
on 3:TEXT:!attack *:#:{ 
  $no.turn.check($nick)
  $set_chr_name($nick)
  $partial.name.match($nick, $2)
  $covercheck(%attack.target)
  $attack_cmd($nick , %attack.target) 
} 

ON 50:TEXT:*attacks *:*:{ 
  if ($2 != attacks) { halt } 
  else { 
    $no.turn.check($1,admin)
    if ($readini($char($1), Battle, HP) = $null) { halt }
    $set_chr_name($1) 
    $partial.name.match($1, $3)
    $covercheck(%attack.target)
    $attack_cmd($1 , %attack.target) 
  }
}

ON 3:TEXT:*attacks *:*:{ 
  if ($2 != attacks) { halt } 
  if ($readini($char($1), info, flag) = monster) { halt }
  if ($readini($char($1), stuff, redorbs) = $null) { halt }
  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($readini(translation.dat, errors, PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($readini(translation.dat, errors, PlayerAccessOffDueToLogin), private) | halt }
  $no.turn.check($1)
  unset %real.name 
  if ($readini($char($1), Battle, HP) = $null) { halt }
  $set_chr_name($1) 
  $partial.name.match($1, $3)
  $covercheck(%attack.target)
  $attack_cmd($1 , %attack.target) 
}

alias attack_cmd { 
  set %debug.location alias attack_cmd
  $check_for_battle($1) | $person_in_battle($2) | $checkchar($2) | var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  var %ai.type $readini($char($1), info, ai_type)

  if ((%ai.type != berserker) && (%covering.someone != on)) {
    if (%mode.pvp != on) {
      if ($2 = $1) {
        if (($is_confused($1) = false) && ($is_charmed($1) = false))  { $display.message($readini(translation.dat, errors, Can'tAttackYourself), private) | unset %real.name | halt  }
      }
    }
  }

  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster } 
  if (%tech.type = heal) { var %user.flag monster }
  if (%tech.type = heal-aoe) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }
  if (%ai.type = berserker) { var %user.flag monster }
  if (%covering.someone = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanOnlyAttackMonsters),private)  | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious),private)  | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFled),private) | unset %real.name | halt } 

  ; Make sure the old attack damages have been cleared, and clear a few variables.
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %target.flag | unset %trickster.dodged | unset %covering.someone
  unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on | unset %critical.hit.chance | unset %drainsamba.on | unset %absorb | unset %counterattack
  unset %shield.block.line | unset %inflict.meleewpn

  ; Get the weapon equipped
  if ($person_in_mech($1) = false) {  $weapon_equipped($1) }
  if ($person_in_mech($1) = true) { set %weapon.equipped $readini($char($1), mech, equippedweapon) }


  ; Check to see if the weapons require ammo to swing
  if ($readini($char($1), info, flag) = $null) { 
    var %ammo.amount.met false
    var %ammo.needed false

    ; Check right hand
    var %weapon.ammo $readini($dbfile(weapons.db), %weapon.equipped, AmmoRequired)

    if (%weapon.ammo != $null) { 
      var %ammo.needed true
      var %weapon.ammo.amount $readini($dbfile(weapons.db), %weapon.equipped, AmmoAmountNeeded)
      var %player.ammo.amount $readini($char($1), item_amount, %weapon.ammo)
      if (%player.ammo.amount = $null) { var %player.ammo.amount 0 }

      if (%player.ammo.amount >= %weapon.ammo.amount) { 
        dec %player.ammo.amount %weapon.ammo.amount
        writeini $char($1) item_amount %weapon.ammo %player.ammo.amount
        var %ammo.amount.met true 
      }
    }

    ; check the left hand
    if (%weapon.equipped.left != $null) { 
      var %weapon.ammo $readini($dbfile(weapons.db), %weapon.equipped.left, AmmoRequired)

      if ((%weapon.ammo != $null) && (%ammo.amount.met = false)) {
        var %ammo.needed true
        var %weapon.ammo.amount $readini($dbfile(weapons.db), %weapon.equipped.left, AmmoAmountNeeded)
        var %player.ammo.amount $readini($char($1), item_amount, %weapon.ammo)
        if (%player.ammo.amount = $null) { var %player.ammo.amount 0 }

        if (%player.ammo.amount >= %weapon.ammo.amount) { 
          dec %player.ammo.amount %weapon.ammo.amount
          writeini $char($1) item_amount %weapon.ammo %player.ammo.amount
          var %ammo.amount.met true 
        }
      }
    }

    if ((%ammo.needed = true) && (%ammo.amount.met = false))  {   $display.message($readini(translation.dat, errors, NeedAmmoToDoThis), private) | unset %weapon.equipped | halt }

  }


  var %action.points.to.decrease $round($log($readini($dbfile(weapons.db), %weapon.equipped, basepower)),0)
  if (%action.points.to.decrease <= 0) { inc %action.points.to.decrease 1 }

  ; Decrease the action point cost
  $action.points($1, remove, %action.points.to.decrease)

  ; Clear the BattleNext timer until this action is finished
  /.timerBattleNext off

  ; If it's an AOE attack, perform that here.  Else, do a single hit.

  if ($readini($dbfile(weapons.db), %weapon.equipped, target) != aoe) {

    ; Calculate, deal, and display the damage..
    $calculate_damage_weapon($1, %weapon.equipped, $2)

    if ($person_in_mech($1) = true) { $mech.energydrain($1, melee) }

    set %wpn.element $readini($dbfile(weapons.db), %weapon.equipped, element)
    if ((%wpn.element != none) && (%wpn.element != $null)) { 
      var %target.element.heal $readini($char($2), modifiers, heal)
      if ($istok(%target.element.heal,%wpn.element,46) = $true) { 
        unset %wpn.element
        unset %counterattack
        $heal_damage($1, $2, %weapon.equipped)
        $display_heal($1, $2, weapon, %weapon.equipped)
        if (%battleis = on)  { $check_for_double_turn($1) | halt } 
      }
    }
    unset %wpn.element

    if ((%counterattack != on) && (%counterattack != shield)) { 
      $drain_samba_check($1) 
      var %weapon.equipped.original %weapon.equipped
      if ((%weapon.equipped.left != $null) && ($readini($dbfile(weapons.db), %weapon.equipped.left, type) != shield)) { set %weapon.equipped %weapon.equipped $+ . $+ %weapon.equipped.left }
      $deal_damage($1, $2, %weapon.equipped, melee)
      $display_damage($1, $2, weapon, %weapon.equipped.original)

    }

    if (%counterattack = on) { 
      $deal_damage($2, $1, %weapon.equipped, melee)
      $display_damage($1, $2, weapon, %weapon.equipped)
    }

    if (%counterattack = shield) { 
      $deal_damage($2, $1, $readini($char($2), weapons, equippedLeft), shield)
      $display_damage($1, $2, weapon, $readini($char($2), weapons, equippedLeft))
    }

    unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
    unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
    unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
    unset %multihit.message.on | unset %critical.hit.chance

    $formless_strike_check($1)

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if ($readini($dbfile(weapons.db), %weapon.equipped, target) = aoe) {

    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $melee.aoe($1, %weapon.equipped, $2, player) | halt }
      if (%current.flag = monster) { $melee.aoe($1, %weapon.equipped, $2, monster) | halt }
    }
    else {
      ; check for confuse.
      if ($is_confused($1) = true) { 
        var %random.target.chance $rand(1,2)
        if (%random.target.chance = 1) { var %user.flag monster }
        if (%random.target.chance = 2) { unset %user.flag }
      }

      ; Determine if it's players or monsters
      if (%user.flag = monster) { $melee.aoe($1, %weapon.equipped, $2, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $melee.aoe($1, %weapon.equipped, $2,monster) | halt }
    }

  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates Melee Damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias calculate_damage_weapon {
  set %debug.location alias calculate_damage_weapon
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 
  ; $4 = a special flag for mugger's belt.

  if ($readini($char($1), info, flag) = monster) { $formula.meleedmg.monster($1, $2, $3, $4) }
  else { 

    if (%battle.type = dungeon) { $formula.meleedmg.player.formula($1, $2, $3, $4) }
    if (%battle.type = torment) { $formula.meleedmg.player.formula_2.5($1, $2, $3, $4)  }
    if (%battle.type = cosmic) { $formula.meleedmg.player.formula_2.5($1, $2, $3, $4)  }

    if (((%battle.type != dungeon) && (%battle.type != cosmic) && (%battle.type != torment))) { $formula.meleedmg.player.formula($1, $2, $3, $4)  }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a melee AOE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias melee.aoe {
  ; $1 = user
  ; $2 = weapon name
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Display the weapon type description
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  var %enemy all targets

  var %weapon.type $readini($dbfile(weapons.db), $2, type) |  var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt) 

  $display.message(03 $+ %user $+  $read %attack.file  $+ 03., battle)
  set %showed.melee.desc true

  if ($readini($dbfile(weapons.db), $2, absorb) = yes) { set %absorb absorb }

  var %melee.element $readini($dbfile(weapons.db), $2, element)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { 

        if (($readini($char($1), status, confuse) != yes) && ($1 = %who.battle)) { inc %battletxt.current.line 1 }

        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 

          if ($readini($char($1), battle, hp) > 0) {
            inc %number.of.hits 1
            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%melee.element != none) && (%melee.element != $null)) {
              if ($istok(%target.element.heal,%melee.element,46) = $true) { 
                $heal_damage($1, %who.battle, %weapon.equipped)
                inc %battletxt.current.line 1 
              }
            }

            if (($istok(%target.element.heal,%melee.element,46) = $false) || (%melee.element = none)) { 

              $covercheck(%who.battle, $2, AOE)

              $calculate_damage_weapon($1, %weapon.equipped, %who.battle)
              $deal_damage($1, %who.battle, %weapon.equipped, melee)

              $display_aoedamage($1, %who.battle, $2, %absorb, melee)
              unset %attack.damage

            }
          }

          unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
          unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
          unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
          unset %multihit.message.on | unset %critical.hit.chance

          inc %battletxt.current.line 1 | inc %aoe.turn 1
        } 
      }
    }
  }


  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 | set %aoe.turn 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { 
        inc %number.of.hits 1
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          if ($readini($char($1), battle, hp) > 0) {

            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%melee.element != none) && (%melee.element != $null)) {
              if ($istok(%target.element.heal,%melee.element,46) = $true) { 
                $heal_damage($1, %who.battle, %weapon.equipped)
              }
            }

            if (($istok(%target.element.heal,%melee.element,46) = $false) || (%melee.element = none)) { 
              $covercheck(%who.battle, $2, AOE)


              $calculate_damage_weapon($1, %weapon.equipped, %who.battle)
              $deal_damage($1, %who.battle, %weapon.equipped, melee)
              $display_aoedamage($1, %who.battle, $2, %absorb, melee)

            }
          }

          unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
          unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
          unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
          unset %multihit.message.on | unset %critical.hit.chance

          inc %battletxt.current.line 1 | inc %aoe.turn 1 | unset %attack.damage
        } 
      }
    }
  }

  unset %element.desc | unset %showed.melee.desc | unset %aoe.turn
  set %timer.time $calc(%number.of.hits * 1.1) 

  if ($readini($dbfile(weapons.db), $2, magic) = yes) {
    ; Clear elemental seal
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      writeini $char($1) skills elementalseal.on off 
    }
  }

  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    set %inflict.user $1 | set %inflict.meleewpn $2 
    $self.inflict_status(%inflict.user, %inflict.meleewpn, melee)
    if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }


  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  if (%timer.time > 20) { %timer.time = 20 }

  unset %melee.element | $formless_strike_check($1)

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Skill and Mastery checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias mastery_check {
  var %type.of.weapon $readini($dbfile(weapons.db), $2, type)
  set %mastery.type nonexistant 
  if (%type.of.weapon = handtohand) { set %mastery.type MartialArts }
  if (%type.of.weapon = nunchuku) { set %mastery.type MartialArts }
  if (%type.of.weapon = katana) { set %mastery.type Swordmaster }
  if (%type.of.weapon = sword) { set %mastery.type Swordmaster }
  if (%type.of.weapon = greatsword) { set %mastery.type Swordmaster }
  if (%type.of.weapon = gun) { set %mastery.type Gunslinger }
  if (%type.of.weapon = rifle) { set %mastery.type Gunslinger }
  if (%type.of.weapon = wand) { set %mastery.type Wizardry }
  if (%type.of.weapon = stave) { set %mastery.type Wizardry }
  if (%type.of.weapon = glyph) { set %mastery.type Wizardry }
  if (%type.of.weapon = spear) { set %mastery.type Polemaster }
  if (%type.of.weapon = bow) { set %mastery.type Archery }
  if (%type.of.weapon = axe) { set %mastery.type Hatchetman }
  if (%type.of.weapon = greataxe) { set %mastery.type Hatchetman }
  if (%type.of.weapon = scythe) { set %mastery.type Harvester }
  if (%type.of.weapon = dagger) { set %mastery.type SleightOfHand }
  if (%type.of.weapon = whip) { set %mastery.type Whipster }
  if (%type.of.weapon = lightsaber) { set %mastery.type JediArts }
  if (%type.of.weapon = hammer) { set %mastery.type Hammermaster }

  set %mastery.bonus $readini($char($1), skills, %mastery.type) 
  if (%mastery.bonus = $null) { set %mastery.bonus 0 }

  var %current.playerstyle $return.playerstyle($1)
  var %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (%current.playerstyle = WeaponMaster) { 
    if ($3 = melee) {
      var %amount.to.increase $calc(.05 * %current.playerstyle.level)
      if (%amount.to.increase >= .70) { var %amount.to.increase .70 }
      var %wpnmst.increase $round($calc(%amount.to.increase * %attack.damage),0)
      inc %attack.damage %wpnmst.increase
      var %playerstyle.bonus $round($calc(%current.playerstyle.level * 1.5),0)
      inc %mastery.bonus %playerstyle.bonus
    }
  }


  unset %mastery.type
}

alias mighty_strike_check {
  var %mightystrike $readini($char($1), skills, mightystrike.on)
  if (%mightystrike = on) { return true }
  else { return false }
}

alias desperate_blows_check {
  if ($readini($char($1), skills, desperateblows) != $null) { return true }
  else { return false }
}

alias weapon_bash_check {
  if (%counterattack = on) { return }
  if (%attack.damage = 0) { return }

  if ($readini($char($1), skills, WeaponBash) > 0) {

    set %resist.skill $readini($char($2), skills, resist-stun)
    $ribbon.accessory.check($2)
    if (%resist.skill >= 100) { return }
    unset %resist.skill

    if (%guard.message != $null) { return }
    if ($readini($char($2), skills, royalguard.on) = on) { return }
    if ($readini($char($2), skills, perfectdefense.on) = on) { return }
    if ($readini($char($2), skills, utsusemi.on) = on) { return }
    if (%trickster.dodged = on) { return }
    if ($readini($char($2), NaturalArmor, Current) > 0) { return }

    var %stun.chance $rand(1,100)
    var %weapon.bash.chance $calc($readini($char($1), skills, weaponbash) * 10)

    if ($augment.check($1, EnhanceWeaponBash) = true) { inc %weapon.bash.chance %augment.strength  } 

    if (%stun.chance <= %weapon.bash.chance) {
      writeini $char($2) status stun yes | $set_chr_name($2) | set %statusmessage.display 04 $+ %real.name has been stunned by the blow!
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Drain Samba check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias drain_samba_check {
  unset %drainsamba.on
  if ($readini($char($1), skills, drainsamba.on) = on) {
    ; Check to see how many turns its been..  
    set %drainsamba.turns $readini($char($1), skills, drainsamba.turn)
    if (%drainsamba.turns = $null) { set %drainsamba.turns 0 }
    set %drainsamba.turn.max $readini($char($1), skills, drainsamba)
    inc %drainsamba.turns 1 
    if (%drainsamba.turns > %drainsamba.turn.max) { $set_chr_name($1) | $display.message($readini(translation.dat, skill, DrainSambaWornOff), battle) | writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on off | return }
    writeini $char($1) skills drainsamba.turn %drainsamba.turns   
    set %drainsamba.on on
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Formless Strike check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias formless_strike_check {
  if ($readini($char($1), skills, formlessstrike.on) = on) {
    ; Check to see how many turns its been..  
    set %fstrike.turns $readini($char($1), skills, formlessstrike.turn)
    if (%fstrike.turns = $null) { set %fstrike.turns 0 }
    set %fstrike.turn.max $readini($char($1), skills, formlessstrike)
    inc %fstrike.turns 1 

    if (%fstrike.turns > %fstrike.turn.max) { $set_chr_name($1) | $display.message($readini(translation.dat, skill, FormlessStrikeWornOff), battle) | writeini $char($1) skills formlessstrike.turn 0 | writeini $char($1) skills formlessstrike.on off | return }
    writeini $char($1) skills formlessstrike.turn %fstrike.turns   
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for augments and accessories
; that enhance weapon types.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias melee.weapontype.enhancements {

  ; Hand To Hand
  if (%weapon.type = HandToHand) {

    ;  Check for a +h2h damage accessory
    if ($accessory.check($1, IncreaseH2HDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceHandtoHand) = true) {  inc %attack.damage $round($calc(%attack.damage + (%augment.strength * 50)),0)  } 
  }


  ; Spears
  if (%weapon.type = spear) {

    ;  Check for a +spear damage accessory
    if ($accessory.check($1, IncreaseSpearDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceSpear) = true) {  inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  ; Swords

  if (%weapon.type = sword) {

    ; Check for a +sword damage accessory
    if ($accessory.check($1, IncreaseSwordDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceSword) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = greatsword) {

    ; Check for a +greatsword damage accessory
    if ($accessory.check($1, IncreaseGreatSwordDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceSword) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = gunblade) {
    if ($accessory.check($1, IncreaseGunbladeDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
    if ($augment.check($1, EnhanceSword) = true) { inc %attack.damage $calc(%augment.strength * 100)  }     
  }

  if (%weapon.type = whip) {

    if ($accessory.check($1, IncreaseWhipDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceWhip) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = gun) {
    if ($accessory.check($1, IncreaseGunDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = chakram) {
    if ($accessory.check($1, IncreaseChakramDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = bow) {
    if ($accessory.check($1, IncreaseBowDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = glyph) {
    if ($accessory.check($1, IncreaseGlyphDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceGlyph) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Katana) {
    if ($accessory.check($1, IncreaseKatanaDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceKatana) = true) {  inc %attack.damage $calc(%augment.strength * 100)   } 
  }

  if (%weapon.type = Wand) {
    if ($accessory.check($1, IncreaseWandDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceWand) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }
  if (%weapon.type = Staff) {
    if ($accessory.check($1, IncreaseStaffDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceStaff) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Stave) {
    if ($accessory.check($1, IncreaseStaffDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceStaff) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Scythe) {
    if ($accessory.check($1, IncreaseScytheDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceScythe) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Axe) {
    if ($accessory.check($1, IncreaseAxeDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }
    ; Check for an augment
    if ($augment.check($1, EnhanceAxe) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Dagger) {
    if ($accessory.check($1, IncreaseDaggerDamage) = true) {
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }
    ; Check for an augment
    if ($augment.check($1, EnhanceDagger) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

}
