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

local layout = game.state:alternateZoneTier1(short_name, {"OVERGROUND", 1})
if layout == "DEFAULT" then

-- Underground
return {
	name = _t"Rhaloren Camp",
	level_range = {1, 7},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + e:getRankLevelAdjust() + 1 end,
	width = 50, height = 50,
	tier1 = true,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = "Broken.ogg",
	max_material_level = 1,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room", {"money_vault",5}, {"lesser_vault",8}},
			lesser_vaults_list = {"circle","amon-sul-crypt","rat-nest","skeleton-mage-cabal"},
			lite_room_chance = 100,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
		[3] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/rhaloren-camp-last",
				},
				actor = {
					area = {x1=0, x2=49, y1=0, y2=40},
				},
			},
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)
	end,
}

elseif layout == "OVERGROUND" then

-- Overground
return {
	name = _t"Rhaloren Camp",
	level_range = {1, 7},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + e:getRankLevelAdjust() + 1 end,
	width = 50, height = 50,
	tier1 = true,
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	-- Apply a greenish tint to all the map
	color_shown = {0.8, 1, 0.8, 1},
	color_obscure = {0.8*0.6, 1*0.6, 0.8*0.6, 0.6},
	ambient_music = "Broken.ogg",
	max_material_level = 1,
	generator =  {
		map = {
			class = "engine.generator.map.Town",
			building_chance = 80,
			max_building_w = 10, max_building_h = 10,
			edge_entrances = {4,6},
			floor = "FLOOR",
			external_floor = {"GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","TREE"},
			wall = "WALL",
			up = "GRASS_UP4",
			down = "GRASS_DOWN6",
			door = "DOOR",
			['#'] = "WALL",
			['.'] = "FLOOR",
			['+'] = "DOOR",

			nb_rooms = {1,1,2},
			rooms = {"lesser_vault"},
			lesser_vaults_list = {"circle","amon-sul-crypt","skeleton-mage-cabal","collapsed-tower"},
			lite_room_chance = 100,
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "GRASS_UP_WILDERNESS",
			}, },
		},
		[3] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/rhaloren-camp-last",
				},
				actor = {
					area = {x1=0, x2=49, y1=0, y2=40},
				},
			},
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)
	end,
}

end