-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

use_ui = "quest-main"

name = _t"Falling Toward Apotheosis"
desc = function(self, who)
	local desc = {}

	if not self:isCompleted() then
		desc[#desc+1] = _t"You have vanquished the masters of the Orc Pride. Now you must venture inside the most dangerous place of this world: the High Peak."
		desc[#desc+1] = _t"Seek the Sorcerers and stop them before they bend the world to their will."
		desc[#desc+1] = _t"To enter, you will need the four orbs of command to remove the shield over the peak."
		desc[#desc+1] = _t"The entrance to the peak passes through a place called 'the slime tunnels', probably located inside or near Grushnak Pride."
	else
		desc[#desc+1] = _t"You have reached the summit of the High Peak, entered the sanctum of the Sorcerers and destroyed them, freeing the world from the threat of evil."
		desc[#desc+1] = _t"You have won the game!"
	end

	if self:isCompleted("killed-aeryn") then desc[#desc+1] = _t"#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall. You were forced to kill her.#LAST#" end
	if self:isCompleted("spared-aeryn") then desc[#desc+1] = _t"#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall, but you spared her.#LAST#" end

	if game.winner and game.winner == "full" then desc[#desc+1] = _t"#LIGHT_GREEN#* You defeated the Sorcerers before the Void portal could open.#LAST#" end
	if game.winner and game.winner == "aeryn-sacrifice" then desc[#desc+1] = _t"#LIGHT_GREEN#* You defeated the Sorcerers and Aeryn sacrificed herself to close the Void portal.#LAST#" end
	if game.winner and game.winner == "self-sacrifice" then desc[#desc+1] = _t"#LIGHT_GREEN#* You defeated the Sorcerers and sacrificed yourself to close the Void portal.#LAST#" end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("elandar-dead") and self:isCompleted("argoniel-dead") and not who:isQuestStatus("high-peak", engine.Quest.DONE) then
			self.use_ui = "quest-win"
			who:setQuestStatus(self.id, engine.Quest.DONE)

			-- Remove all remaining hostiles
			for i = #game.level.e_array, 1, -1 do
				local e = game.level.e_array[i]
				if game.player:reactionToward(e) < 0 then game.level:removeEntity(e) end
			end

			local Chat = require"engine.Chat"
			local chat = Chat.new("sorcerer-end", {name=_t"Endgame", image="portrait/win.png"}, game:getPlayer(true))
			chat:invoke()

			self:end_end_combat()
		end
	end
end

function start_end_combat(self)
	local p = game.party:findMember{main=true}
	game.level.allow_portals = true
end

function end_end_combat(self)
	local floor = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
	for i = 8, 13 do
		game.level.map(i, 11, engine.Map.TERRAIN, floor)
	end
	for i = 36, 41 do
		game.level.map(i, 11, engine.Map.TERRAIN, floor)
	end
	game.level.allow_portals = false

	local nb_portal = 0
	if self:isCompleted("closed-portal-demon") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-dragon") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-elemental") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-undead") then nb_portal = nb_portal + 1 end
	if nb_portal == 0 then world:gainAchievement("SORCERER_NO_PORTAL", game.player)
	elseif nb_portal == 1 then world:gainAchievement("SORCERER_ONE_PORTAL", game.player)
	elseif nb_portal == 2 then world:gainAchievement("SORCERER_TWO_PORTAL", game.player)
	elseif nb_portal == 3 then world:gainAchievement("SORCERER_THREE_PORTAL", game.player)
	elseif nb_portal == 4 then world:gainAchievement("SORCERER_FOUR_PORTAL", game.player)
	end
end

function failed_charred_scar(self, level)
	if not game.state:isUniqueDead("High Sun Paladin Aeryn") then
		local aeryn = game.zone:makeEntityByName(level, "actor", "FALLEN_SUN_PALADIN_AERYN")
		if aeryn then  
			game.zone:addEntity(level, aeryn, "actor", level.default_down.x, level.default_down.y)
			game.logPlayer(game.player, "#LIGHT_RED#As you enter the level you hear a familiar voice.")
			game.logPlayer(game.player, "#LIGHT_RED#Fallen Sun Paladin Aeryn: '%s YOU BROUGHT ONLY DESTRUCTION TO THE SUNWALL! YOU WILL PAY!'", game.player.name:upper())
		end
	end

	game:onLevelLoad("wilderness-1", function(zone, level)
		local spot = level:pickSpot{type="zone-pop", subtype="ruined-gates-of-morning"}
		local wild = level.map(spot.x, spot.y, engine.Map.TERRAIN)
		wild.name = _t"Ruins of the Gates of Morning"
		wild.desc = _t"The Sunwall was destroyed while you were trapped in the High Peak."
		wild.change_level = nil
		wild.change_zone = nil
	end)
	game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "gates-of-morning-destroyed")
end

function win(self, how)
	game:playAndStopMusic("Lords of the Sky.ogg")
	game.party:learnLore("closing-farportal")

	if how == "full" then world:gainAchievement("WIN_FULL", game.player)
	elseif how == "aeryn-sacrifice" then world:gainAchievement("WIN_AERYN", game.player)
	elseif how == "self-sacrifice" then world:gainAchievement("WIN_SACRIFICE", game.player)
	elseif how == "yeek-sacrifice" then world:gainAchievement("YEEK_SACRIFICE", game.player)
	elseif how == "yeek-selfless" then world:gainAchievement("YEEK_SELFLESS", game.player)
	elseif how == "distant-sun" then world:gainAchievement("AOADS_BURN", game.player)
	elseif how == "distant-sun-selfless" then world:gainAchievement("AOADS_SELFLESS", game.player)
	elseif how == "distant-sun-shertul" then world:gainAchievement("AOADS_SHERTUL", game.player)
	end
	
	local p = game:getPlayer(true)
	p:inventoryApplyAll(function(inven, item, o) o:check("on_win") end)
	self:triggerHook{"Winner", how=how, kind="sorcerers"}

	local aeryn = game.level:findEntity{define_as="HIGH_SUN_PALADIN_AERYN"}
	if aeryn and not aeryn.dead then world:gainAchievement("WIN_AERYN_SURVIVE", game.player) end

	if not game.state.gone_west then world:gainAchievement("WIN_NEVER_WEST", game.player) end

	game:setAllowedBuild("adventurer", true)
	if game.difficulty == game.DIFFICULTY_NIGHTMARE then game:setAllowedBuild("difficulty_insane", true) end
	if game.difficulty == game.DIFFICULTY_INSANE then game:setAllowedBuild("difficulty_madness", true) end

	local p = game:getPlayer(true)
	p.winner = how
	game:registerDialog(require("engine.dialogs.ShowText").new(_t"Winner", "win", {playername=p.name, how=how}, game.w * 0.6))

	-- Save the winner, if alive
	if not p.dead then
		local pwinner = p:cloneFull()
		pwinner.version = game.__mod_info.version
		pwinner.addons = table.keys(game.__mod_info.addons)				
		pwinner.no_drops = true
		pwinner.energy.value = 0
		pwinner.player = nil
		pwinner.rank = 5
		pwinner:removeAllMOs()
		pwinner.ai = "tactical"
		pwinner.ai_state = {talent_in=1, ai_move="move_astar"}
		pwinner.faction="enemies"
		pwinner.life = pwinner.max_life
		pwinner:removeEffectsFilter(pwinner, function() return true end, 9999, true, true)
		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(pwinner.talents) do
			local t = pwinner:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		world.majeyal_campaign_last_winner = pwinner
	end

	if not config.settings.cheat then game:saveGame() end
end

function onWin(self, who)
	local desc = {}

	desc[#desc+1] = _t"#GOLD#Well done! You have won the Tales of Maj'Eyal: The Age of Ascendancy#WHITE#"
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"The Sorcerers are dead, and the Orc Pride lies in ruins, thanks to your efforts."
	desc[#desc+1] = _t""

	-- Avatars are special
	if who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "distant-sun") then
		desc[#desc+1] = _t"Your patron's plan worked. As your body was crushed by the raw forces of the void portal it opened wide. In an instant the connection was made and waves of heat came through."
		desc[#desc+1] = _t"The mad sun brought forth all its power through the portal, turning the High Peak into a giant searing needle!"
		desc[#desc+1] = _t"A few minutes later the whole world was set ablaze, nothing survived except Faeros elementals."
		return 0, desc
	elseif who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "distant-sun-stab") then
		desc[#desc+1] = _t"In the aftermath of the battle the Distant Sun tried to force you to open the portal to bring it forth onto Eyal."
		desc[#desc+1] = _t"Through an incredible display of willpower you resisted long enough to ask Aeryn to kill you."
		desc[#desc+1] = _t"She sadly agreed and ran her sword through you, enabling you to do the last sacrifice you could for the world."
		return 0, desc
	elseif who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "distant-sun-shertul") then
		desc[#desc+1] = _t"In the aftermath of the battle the Distant Sun tried to force you to open the portal to bring it forth onto Eyal."
		desc[#desc+1] = _t"Through an incredible display of willpower you resisted for a few decisive seconds. During this time a Sher'tul appeared, took the Staff and killed you."
		desc[#desc+1] = _t"Though you succumbed to the fight, your mind was already gone, burnt to ashes by your mad patron sun. But the world was saved."
		return 0, desc
	end

	-- Yeeks are special
	if who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek") then
		desc[#desc+1] = _t"Your sacrifice worked. Your mental energies were imbued with farportal energies. The Way radiated from the High Peak toward the rest of Eyal like a mental tidal wave."
		desc[#desc+1] = _t"Every sentient being in Eyal is now part of the Way. Peace and happiness are enforced for all."
		desc[#desc+1] = _t"Only the mages of Angolwen were able to withstand the mental shock and thus are the only unsafe people left. But what can they do against the might of the Way?"
		return 0, desc
	elseif who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek-stab") then
		desc[#desc+1] = _t"In the aftermath of the battle the Way tried to force you to act as a vessel to bring the Way to every sentient being."
		desc[#desc+1] = _t"Through an incredible display of willpower you resisted long enough to ask Aeryn to kill you."
		desc[#desc+1] = _t"She sadly agreed and ran her sword through you, enabling you to do the last sacrifice you could for the world."
		return 0, desc
	end

	if who.winner == "full" then
		desc[#desc+1] = _t"You have prevented the portal to the Void from opening and thus stopped the Creator from bringing about the end of the world."
	elseif who.winner == "aeryn-sacrifice" then
		desc[#desc+1] = _t"In a selfless act, High Sun Paladin Aeryn sacrificed herself to close the portal to the Void and thus stopped the Creator from bringing about the end of the world."
	elseif who.winner == "self-sacrifice" then
		desc[#desc+1] = _t"In a selfless act, you sacrificed yourself to close the portal to the Void and thus stopped the Creator from bringing about the end of the world."
	end

	if who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "gates-of-morning-destroyed") then
		desc[#desc+1] = _t""
		desc[#desc+1] = _t"The Gates of Morning have been destroyed and the Sunwall has fallen. The last remnants of the free people in the Far East will surely diminish, and soon only orcs will inhabit this land."
	else
		desc[#desc+1] = _t""
		desc[#desc+1] = _t"The orc presence in the Far East has greatly been diminished by the loss of their leaders and the destruction of the Sorcerers. The free people of the Sunwall will be able to prosper and thrive on this land."
	end

	desc[#desc+1] = _t""
	desc[#desc+1] = _t"Maj'Eyal will once more know peace. Most of its inhabitants will never know they even were on the verge of destruction, but then this is what being a true hero means: to do the right thing even though nobody will know about it."

	if who.winner ~= "self-sacrifice" then
		desc[#desc+1] = _t""
		desc[#desc+1] = _t"You may continue playing and enjoy the rest of the world."
	end
	return 0, desc
end
