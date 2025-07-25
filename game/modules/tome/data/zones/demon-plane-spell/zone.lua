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
	name = _t"Fearscape",
	level_range = {1, 100},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return level.source_zone.base_level + e:getRankLevelAdjust() + level.source_level.level-1 + rng.range(-1,2) end,
	width = 12, height = 12,
--	all_remembered = true,
	all_lited = true,
	no_worldport = true,
	is_demon_plane = true,
	no_planechange = true,
	in_orbit = true,
	ambient_music = "Straight Into Ambush.ogg",
	effects = {"EFF_ZONE_AURA_FEARSCAPE"},
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			zoom = 3,
			sqrt_percent = 45,
			noise = "fbm_perlin",
			floor = "LAVA_FLOOR",
			wall = "LAVA_WALL",
			up = "LAVA_FLOOR",
			down = "LAVA_FLOOR",
		},
	},
	on_enter = function()
		game.player:attr("planetary_orbit", 1)
	end,
}
