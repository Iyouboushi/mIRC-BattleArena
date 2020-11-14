;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; DISCORD COMMANDS
;;;; Last updated: 11/13/20
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file is to make the bot compatible with an IRC<->Discord bot bridge.
; Note that the format for the incoming text from the bridge has to be the following:
; [Discord] <Player Name> Message Here
;   Example:  [Discord] <Iyouboushi> !shop list items
;
; To make BattleArena work right for Discord it you will need to change the bot type to Discord.
; In system.dat change BotType=   to BotType=Discord
;
; You will also need to tell BattleArena what the name of the discord bridge bot is (security issue otherwise)
; In system.dat update DiscordBridgeName=   to the nick of the bridge bot.
;
; Also note that colors should be turned off on the bot to make it format better on discord.
; In system.dat change AllowColors=true to AllowColors=false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is a serious work in progress and may not be finished any time soon.


on 1:TEXT:[Discord] *:*: { 
  ; $1 = [Discord]
  ; $2 = the name of the person chatting on Discord
  ; $3- = the command/text

  ; Is it the bridge bot's nick doing the discord commands?  If not, we can stop here for security reasons.
  if ($readini(system.dat, system, DiscordBridgeName) != $nick) { halt }

  ; Check to make sure no scripts are being run via text
  $checkscript($3-)

  ; Set the name of the chatter to be used for commands and remove the < >
  set %discord.name $remove($2, $chr(60), $chr(62))

  ; ===================
  ; Character Commands
  ; ===================
  if (($3 = !new) && ($4 = character)) { $create.new.character(%discord.name) }
  if (($3 = !new) && ($4 = char)) { $create.new.character(%discord.name) } 

  if ($3 = !weather) { $display.message($readini(translation.dat, battle, CurrentWeather),private)  }
  if ($3 = !moon) { $display.message($readini(translation.dat, battle, CurrentMoon),private) }
  if ($3 = !time) { $display.message($readini(translation.dat, battle, CurrentTime),private) }

  if ($3 = !desc) {
    if ($4 = $null) { $show.desc(%discord.name) }
    else { $checkchar($4) | $show.desc($4) }
  }
  if ($3 = !cdesc) { writeini $char(%discord.name) Descriptions Char $4- | $okdesc(%discord.name , Character) }

  if ($3 = !hp) {
    if ($4 = $null) { $character.hp.check(%discord.name, public)  }
    else { $checkchar($4) | $character.hp.check($4, public) } 
  }

  if ($3 = !tp) { 
    if ($4 = $null) { $character.tp.check(%discord.name, public)  }
    else { $checkchar($4) | $character.tp.check($4, public) } 
  }


  ; ===================
  ; Shop Commands
  ; ===================
  if ($3 = !shop) { $shop.start($3, $4, $5 $6, $7) }
  if ($3 = !exchange) { $shop.exchange($2, $3, $4) }
  if ($3 = !sell) { $shop.start(!shop, sell, $3, $4, $5 $6) }
  if ($3 = !voucher) { 
    if ($4 = list) { $shop.voucher.list(%discord.name) }
    if ($4 = buy) { $shop.voucher.buy(%discord.name, $4, $5) }
  }

  ; ===================
  ; Battle Commands
  ; ===================
  if ($3 = !enter) {
    if ($readini(system.dat, system, automatedaibattlecasino) = on) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 
    if (%battle.type = ai) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 
    if (%battle.type = dungeon) { $dungeon.enter(%player.name) }
    else { $enter(%discord.name) }
  }

  ; ===================
  ; Skills
  ; ===================

  ; ===================
  ; Misc
  ; ===================
  if ($3 = !version) { $display.message(Battle Arena Bot Version $battle.version,private) }

}
