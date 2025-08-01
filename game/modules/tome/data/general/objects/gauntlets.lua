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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_GAUNTLETS",
	slot = "HANDS",
	type = "armor", subtype="hands",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE,
	image = resolvers.image_material("hgloves", "metal"),
	moddable_tile = resolvers.moddable_tile("gauntlets"),
	require = { flag = { "allow_wear_heavy" }, },
	encumber = 1.5,
	rarity = 9,
	metallic = true,
	wielder={combat = {accuracy_effect = "mace",  is_gloves_combat = 1},},
	desc = _t[[Metal gloves protecting the hands up to the middle of the lower arm.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/gloves.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_GAUNTLETS",
	name = "iron gauntlets", short_name = "iron",
	level_range = {1, 10},
	cost = 5,
	material_level = 1,
	wielder = {
		combat_armor = 1,
		fatigue = 1,
		combat = {
			dam = resolvers.rngavg(7, 12),
			apr = 3,
			physcrit = 2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			physspeed = 0.2,
			damrange = 0.3,
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	name = "dwarven-steel gauntlets", short_name = "d.steel",
	level_range = {10, 30},
	cost = 7,
	material_level = 2, effective_ego_material_level = 3,
	wielder = {
		combat_armor = 2,
		fatigue = 3,
		combat = {
			dam = resolvers.rngavg(16, 22),
			apr = 9,
			physcrit = 8,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			physspeed = 0.2,
			damrange = 0.3,
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	name = "voratun gauntlets", short_name = "voratun",
	level_range = {30, 50},
	cost = 10,
	material_level = 4, effective_ego_material_level = 5,
	wielder = {
		combat_armor = 3,
		fatigue = 5,
		combat = {
			dam = resolvers.rngavg(25, 32),
			apr = 15,
			physcrit = 10,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			physspeed = 0.2,
			damrange = 0.3,
		},
	},
}
