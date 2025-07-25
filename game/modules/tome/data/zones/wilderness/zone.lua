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

return {
	name = _t"World of Eyal",
	display_name = function(x, y) return game.level and _t(game.level.map.attrs(x or game.player.x, y or game.player.y, "zonename")) or _t"Eyal" end,
	variable_zone_name = true,
	level_range = {1, 1},
	max_level = 1,
	width = 170, height = 100,
--	all_remembered = true,
	all_lited = true,
--	day_night = true,
	persistent = "zone",
	ambient_music = "Remembrance.ogg",
	wilderness = true,
	wilderness_see_radius = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "wilderness/eyal",
		},
	},
	post_nicer_tiles = function(level)
		for _, z in ipairs(level.custom_zones) do
			if z.type == "zonename" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "zonename", z.subtype)
					if z.subtype == "Tar'Eyal" then
						game.level.map.attrs(x, y, "block_fortress", true)
					end
				end end
			elseif z.type == "world-encounter" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					if not game.level.map.attrs(x, y, "world-encounter") then game.level.map.attrs(x, y, "world-encounter", {}) end
					game.level.map.attrs(x, y, "world-encounter")[z.subtype] = true
				end end
			elseif z.type == "block_fortress" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "block_fortress", true)
				end end
			end
		end

		-- The shield protecting the sorcerer hideout
		local spot = level:pickSpot{type="zone-pop", subtype="high-peak"}
		local p = level.map:particleEmitter(spot.x, spot.y, 3, "istari_shield_map")

		-- Place immediate "encounters"
		local function place_list(list)
			for i = 1, #list do
				local e = list[i]
				if e.immediate then
					e = e:clone()
					e:resolve() e:resolve(nil, true)
					local where
					if e.immediate.force_spot then
						where = e.immediate.force_spot
					else
						where = game.level:pickSpotRemove{type=e.immediate[1], subtype=e.immediate[2]}
						while where and (game.level.map:checkAllEntities(where.x, where.y, "block_move") or not game.level.map:checkAllEntities(where.x, where.y, "can_encounter")) do where = game.level:pickSpotRemove{type=e.immediate[1], subtype=e.immediate[2]} end
					end
					if e:check("on_encounter", where) then
						e:added()
						print("[Encounter] Immediate set", e.name, where.x, where.y)
					end
				end
			end
		end
		for i, name in ipairs(level.data.auto_placelists or {}) do
			place_list(game.level:getEntitiesList(name))
		end

		-- Create the glow
		level.entrance_glow = require("engine.Particles").new("starglow", 1, {})

		-- Only run once
		level.data.post_nicer_tiles = nil
	end,
	on_enter_list = {},
	on_enter = function(_, _, newzone)
		if game.player.level >= 14 and game.player.level <= 22 and not game.player:hasQuest("lightning-overload") and game:isCampaign("Maj'Eyal") then
			game.player:grantQuest("lightning-overload")
		elseif game.player:hasQuest("lightning-overload") then
			game.player:hasQuest("lightning-overload"):on_wilderness()
		end
		for name, f in pairs(game.level.data.on_enter_list) do
			f()
		end
	end
}
