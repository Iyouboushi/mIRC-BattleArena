;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; DISCORD COMMANDS
;;;; Last updated: 11/11/20
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file is to make the bot compatible with an IRC<->Discord bot bridge.
; Note that the format for the incoming text from the bridge has to be the following:
; [Discord] <Player Name> Message Here
;   Example:  [Discord] <Iyouboushi> !enter
; Also note that colors should be turned off on the bot to make it format better on discord.
; In system.dat change AllowColors=true to AllowColors=false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is a serious work in progress and may not be finished any time soon.


on 1:TEXT:[Discord] *:*: { 
  var %player.name $remove($2, $chr(60), $chr(62))

  if ($3 = !enter) {
    if ($readini(system.dat, system, automatedaibattlecasino) = on) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 
    if (%battle.type = ai) { $display.message($readini(translation.dat, errors, CannotJoinAIBattles), private) | halt } 
    if (%battle.type = dungeon) { $dungeon.enter(%player.name) }
    else { $enter(%player.name) }
  }





}
