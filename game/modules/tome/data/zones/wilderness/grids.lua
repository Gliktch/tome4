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

local grass_editer = {method="borders_def", def="grass_wm"}
local jungle_grass_editer = { method="borders_def", def="jungle_grass"}
local sand_editer = {method="borders_def", def="sand"}
local ice_editer = {method="borders_def", def="ice"}
local mountain_editer = {method="borders_def", def="mountain"}
local gold_mountain_editer = {method="borders_def", def="gold_mountain"}
local lava_editer = {method="borders_def", def="lava"}

--------------------------------------------------------------------------------
-- Grassland
--------------------------------------------------------------------------------

newEntity{
	define_as = "PLAINS",
	type = "floor", subtype = "grass",
	name = "plains", image = "terrain/grass_worldmap/grass_main_01.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	nice_tiler = { method="replace", base={"PLAINS_PATCH", 70, 1, 14}},
	can_encounter=true, equilibrium_level=-10,
	nice_editer = grass_editer,
}
for i = 1, 14 do newEntity{ base = "PLAINS", define_as = "PLAINS_PATCH"..i, image = ("terrain/grass/grass_main_%02d.png"):format(i) } end

newEntity{ base="PLAINS", define_as="CULTIVATION",
	name="cultivated fields",
	display=';', color=colors.GREEN, back_color=colors.DARK_GREEN,
	image="terrain/cultivation.png",
	nice_tiler = { method="replace", base={"CULTIVATION", 100, 1, 4}},
}
for i = 1, 4 do newEntity{ base = "CULTIVATION", define_as = "CULTIVATION"..i, image="terrain/grass.png", add_mos={{image="terrain/cultivation0"..i..".png"}} } end

newEntity{ base="PLAINS", define_as="LOW_HILLS",
	name="low hills",
	display=';', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	nice_tiler = { method="replace", base={"LOW_HILLS", 100, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "LOW_HILLS", define_as = "LOW_HILLS"..i, image="terrain/grass.png", add_mos={{image="terrain/grass_hill_"..i.."_01.png"}} } end

local forest_editer = { method="borders", type="forest", use_type="name",
	default8={z=16,  add_mos={{image="terrain/worldmap/WM_norm_trees_8_%02d.png", display_y=-1}}, min=1, max=6},
	default2={z=6, add_mos={{image="terrain/worldmap/WM_norm_trees_2_%02d.png", display_h=2}}, min=1, max=6},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_norm_trees_4.png", display_x=-1}}, min=1, max=1},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_norm_trees_6.png", display_x=1}}, min=1, max=1},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_norm_trees_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_norm_trees_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_norm_trees_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_norm_trees_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
	default7i={z=6, add_mos={{image="terrain/worldmap/WM_norm_trees_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9i={z=6, add_mos={{image="terrain/worldmap/WM_norm_trees_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "FOREST",
	type = "wall", subtype = "grass",
	name = "forest",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_editer = grass_editer,
	nice_editer2 = forest_editer,
	nice_tiler = { method="replace", base={"FOREST", 100, 1, 12}},
	special_minimap = colors.GREEN,
}
for i = 1, 12 do newEntity{ base="FOREST", define_as = "FOREST"..i, image = "terrain/grass.png", add_displays={class.new{z=17, image=("terrain/worldmap/WM_norm_trees_5_%02d.png"):format(i), display_h=2, display_y=-1}}} end

local pine_forest_editer = { method="borders", type="pine forest", use_type="name",
	default8={z=16,  add_mos={{image="terrain/worldmap/WM_pines_8_%02d.png", display_y=-1}}, min=1, max=3},
	default2={z=6, add_mos={{image="terrain/worldmap/WM_pines_2_%02d.png", display_h=2}}, min=1, max=3},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_pines_4.png", display_x=-1, display_h=2, display_y=-1}}, min=1, max=1},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_pines_6.png", display_x=1, display_h=2, display_y=-1}}, min=1, max=1},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_pines_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_pines_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_pines_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_pines_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
	default7i={z=6, add_mos={{image="terrain/worldmap/WM_pines_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9i={z=6, add_mos={{image="terrain/worldmap/WM_pines_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "PINE_FOREST",
	type = "wall", subtype = "grass",
	name = "pine forest",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_editer = grass_editer,
	nice_editer2 = pine_forest_editer,
	nice_tiler = { method="replace", base={"PINE_FOREST", 100, 1, 6}},
	special_minimap = colors.GREEN,
}
for i = 1, 6 do newEntity{ base="PINE_FOREST", define_as = "PINE_FOREST"..i, image = "terrain/grass.png", add_displays={class.new{z=17, image="terrain/worldmap/WM_pines_5_0"..i..".png", display_h=2, display_y=-1}}} end


local old_forest_editer = { method="borders", type="Old forest", use_type="name",
	default8={z=16,  add_mos={{image="terrain/worldmap/WM_oldforest_8_%02d.png", display_y=-1}}, min=1, max=3},
	default2={z=6, add_mos={{image="terrain/worldmap/WM_oldforest_2_%02d.png", display_h=2}}, min=1, max=3},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_oldforest_4_%02d.png", display_x=-1, display_h=2, display_y=-1}}, min=1, max=2},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_oldforest_6_%02d.png", display_x=1, display_h=2, display_y=-1}}, min=1, max=2},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_oldforest_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_oldforest_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_oldforest_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_oldforest_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
	default7i={z=6, add_mos={{image="terrain/worldmap/WM_oldforest_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9i={z=6, add_mos={{image="terrain/worldmap/WM_oldforest_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "OLD_FOREST",
	type = "wall", subtype = "grass",
	name = "Old forest",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_editer = grass_editer,
	nice_editer2 = old_forest_editer,
	nice_tiler = { method="replace", base={"OLD_FOREST", 100, 1, 5}},
	special_minimap = colors.GREEN,
}
for i = 1, 5 do newEntity{ base="OLD_FOREST", define_as = "OLD_FOREST"..i, image = "terrain/grass.png", add_displays={class.new{z=17, image="terrain/worldmap/WM_oldforest_5_0"..i..".png", display_h=2, display_y=-1}}} end

--------------------------------------------------------------------------------
-- Desolation
--------------------------------------------------------------------------------

newEntity{
	define_as = "CHARRED_SCAR",
	type = "floor", subtype = "lava",
	name = "Charred Scar", image = "terrain/lava_floor.png",
	display='.', color=colors.WHITE, back_color=colors.LIGHT_DARK,
	nice_tiler = { method="replace", base={"CHARRED_SCAR_PATCH", 100, 1, 16}},
	can_encounter=true, equilibrium_level=-10,
	nice_editer = lava_editer,
}
for i = 1, 16 do newEntity{ base = "CHARRED_SCAR", define_as = "CHARRED_SCAR_PATCH"..i, image = "terrain/lava/lava_floor"..i..".png" } end

local burnt_forest_editer = { method="borders", type="burnt forest", use_type="name",
--	default8={z=16,  add_mos={{image="terrain/worldmap/WM_burnttrees_8_%02d.png", display_y=-1}}, min=1, max=3},
	default2={z=6, add_mos={{image="terrain/worldmap/WM_burnttrees_2.png", display_h=2}}, min=1, max=1},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_burnttrees_4.png", display_x=-1}}, min=1, max=1},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_burnttrees_6.png", display_x=1}}, min=1, max=1},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_burnttrees_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_burnttrees_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_burnttrees_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_burnttrees_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
--	default7i={z=6, add_mos={{image="terrain/worldmap/WM_burnttrees_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
--	default9i={z=6, add_mos={{image="terrain/worldmap/WM_burnttrees_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "BURNT_FOREST",
	type = "wall", subtype = "lava",
	name = "burnt forest",
	image = "terrain/burnt_tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"BURNT_FOREST", 100, 1, 5}},
	nice_editer = lava_editer,
	nice_editer2 = burnt_forest_editer,
	special_minimap = colors.GREY,
}
for i = 1, 5 do newEntity{ base="BURNT_FOREST", define_as = "BURNT_FOREST"..i, name = "burnt forest", image = "terrain/lava_floor.png", add_mos={{image="terrain/worldmap/WM_burnttrees_5_0"..i..".png", display_y=-1, display_h=2}}} end

--------------------------------------------------------------------------------
-- Iceland
--------------------------------------------------------------------------------

newEntity{
	define_as = "POLAR_CAP",
	type = "floor", subtype = "ice",
	name = "polar cap", image = "terrain/frozen_ground.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.WHITE,
	can_encounter=true, equilibrium_level=-10,
	nice_editer = ice_editer,
}
newEntity{
	define_as = "FROZEN_SEA",
	type = "floor", subtype = "ice",
	name = "frozen sea", image = "terrain/water_grass_5_1.png",
	display = ';', color=colors.LIGHT_BLUE, back_color=colors.WHITE,
	can_encounter=true, equilibrium_level=-10,
	nice_editer = ice_editer,
	nice_tiler = { method="replace", base={"FROZEN_SEA", 100, 1, 4}},
	special_minimap = colors.BLUE,
}
for i = 1, 4 do newEntity{ base="FROZEN_SEA", define_as = "FROZEN_SEA"..i, add_mos = {{image = "terrain/ice/frozen_ground_5_0"..i..".png"}}} end

local pine_forest_editer = { method="borders", type="cold forest", use_type="name",
	default8={z=16,  add_mos={{image="terrain/worldmap/WM_snow_pine_8_%02d.png", display_y=-1}}, min=1, max=3},
	default2={z=6, add_mos={{image="terrain/worldmap/WM_snow_pine_2_%02d.png", display_h=2}}, min=1, max=3},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_snow_pine_4_%02d.png", display_x=-1, display_h=2, display_y=-1}}, min=1, max=2},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_snow_pine_6_%02d.png", display_x=1, display_h=2, display_y=-1}}, min=1, max=2},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_snow_pine_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_snow_pine_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_snow_pine_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_snow_pine_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
	default7i={z=6, add_mos={{image="terrain/worldmap/WM_snow_pine_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9i={z=6, add_mos={{image="terrain/worldmap/WM_snow_pine_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "COLD_FOREST",
	type = "wall", subtype = "ice",
	name = "cold forest",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_editer = ice_editer,
	nice_editer2 = pine_forest_editer,
	nice_tiler = { method="replace", base={"COLD_FOREST", 100, 1, 6}},
	special_minimap = colors.GREEN,
}
for i = 1, 6 do newEntity{ base="COLD_FOREST", define_as = "COLD_FOREST"..i, image = "terrain/frozen_ground.png", add_displays={class.new{z=17, image="terrain/worldmap/WM_snow_pine_5_0"..i..".png", display_h=2, display_y=-1}}} end

local elvenwoon_snow_forest_editer = { method="borders", type="cold thaloren forest", use_type="name",
--	default8={z=16,  add_mos={{image="terrain/worldmap/WM_snow_elvenwood_8_%02d.png", display_y=-1}}, min=1, max=3},
--	default2={z=6, add_mos={{image="terrain/worldmap/WM_snow_elvenwood_2_%02d.png", display_h=2}}, min=1, max=3},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_snow_elvenwood_4_%02d.png", display_x=-1, display_h=2, display_y=-1}}, min=1, max=2},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_snow_elvenwood_6_%02d.png", display_x=1, display_h=2, display_y=-1}}, min=1, max=2},

	-- default1={z=6, add_mos={{image="terrain/worldmap/WM_snow_elvenwood_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	-- default3={z=6, add_mos={{image="terrain/worldmap/WM_snow_elvenwood_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	-- default7={z=16,  add_mos={{image="terrain/worldmap/WM_snow_elvenwood_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	-- default9={z=16,  add_mos={{image="terrain/worldmap/WM_snow_elvenwood_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
	default7i={z=6, add_mos={{image="terrain/worldmap/WM_snow_elvenwood_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9i={z=6, add_mos={{image="terrain/worldmap/WM_snow_elvenwood_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "ELVENWOOD_SNOW",
	type = "wall", subtype = "ice",
	name = "cold thaloren forest",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_editer = ice_editer,
	nice_editer2 = elvenwoon_snow_forest_editer,
	nice_tiler = { method="replace", base={"ELVENWOOD_SNOW", 100, 1, 7}},
	special_minimap = colors.GREEN,
}
for i = 1, 7 do newEntity{ base="ELVENWOOD_SNOW", define_as = "ELVENWOOD_SNOW"..i, image = "terrain/frozen_ground.png", add_displays={class.new{z=17, image="terrain/worldmap/WM_snow_elvenwood_5_0"..i..".png", display_h=2, display_y=-1}}} end

local elvenwoon_green_forest_editer = { method="borders", type="thaloren forest", use_type="name",
	default8={z=16, add_mos={{image="terrain/worldmap/WM_green_elvenwood_8_%02d.png", display_y=-1, display_h=2}}, min=1, max=3},
	default2={z=6,  add_mos={{image="terrain/worldmap/WM_green_elvenwood_2_%02d.png", display_y=-1, display_h=2}}, min=1, max=3},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_green_elvenwood_4_%02d.png", display_x=-1, display_h=2, display_y=-1}}, min=1, max=2},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_green_elvenwood_6_%02d.png", display_x=1, display_h=2, display_y=-1}}, min=1, max=2},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_green_elvenwood_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_green_elvenwood_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_green_elvenwood_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_green_elvenwood_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
	default7i={z=6, add_mos={{image="terrain/worldmap/WM_green_elvenwood_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9i={z=6, add_mos={{image="terrain/worldmap/WM_green_elvenwood_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "ELVENWOOD_GREEN",
	type = "wall", subtype = "grass",
	name = "thaloren forest",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_editer = grass_editer,
	nice_editer2 = elvenwoon_green_forest_editer,
	nice_tiler = { method="replace", base={"ELVENWOOD_GREEN", 100, 1, 1}},
	special_minimap = colors.GREEN,
}
for i = 1, 1 do newEntity{ base="ELVENWOOD_GREEN", define_as = "ELVENWOOD_GREEN"..i, image = "terrain/grass.png", add_displays={class.new{z=17, image="terrain/worldmap/WM_green_elvenwood_5_0"..i..".png", display_h=2, display_y=-1}}} end

--------------------------------------------------------------------------------
-- Water
--------------------------------------------------------------------------------

newEntity{
	define_as = "WATER_BASE",
	type = "floor", subtype = "water",
	name = "deep water", image = "terrain/water_grass_5_1.png",
	display = '~', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	always_remember = true,
	can_encounter="water", equilibrium_level=-10,
	special_minimap = colors.BLUE,
	shader = "water",
}
newEntity{ base = "WATER_BASE", define_as = "WATER_BASE_DEEP", can_pass = {pass_water=1}, does_block_move = true }

newEntity{ base="WATER_BASE_DEEP", define_as = "SEA_EYAL", name = "sea of Eyal" }
newEntity{ base="WATER_BASE", define_as = "RIVER", name = "river" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_NUR", name = "lake of Nur" }
newEntity{ base="WATER_BASE_DEEP", define_as = "SEA_SASH", name = "sea of Sash" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE", name = "lake" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_WESTREACH", name = "Westreach lake" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_IRONDEEP", name = "Irondeep lake" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_SPELLMURK", name = "Spellmurk lake" }


--------------------------------------------------------------------------------
-- Mountains
--------------------------------------------------------------------------------

for id, name in pairs{['']=_nt'mountain chain', DAIKARA_=_nt'daikara', IRONTHRONE_=_nt'Iron Throne', VOLCANIC_=_nt'volcanic mountains'} do
newEntity{
	define_as = id.."MOUNTAIN",
	type = "rockwall", subtype = "grass",
	name = name, image = "terrain/rocky_mountain.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	nice_editer = mountain_editer,
	nice_tiler = { method="replace", base={id.."MOUNTAIN_WALL", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_WALL"..i, image = "terrain/mountain5_"..i..".png"} end
end

newEntity{
	define_as = "GOLDEN_MOUNTAIN",
	type = "rockwall", subtype = "grass",
	name = "Sunwall mountain", image = "terrain/golden_mountain5_1.png",
	display = '#', color=colors.GOLD, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
	nice_editer = gold_mountain_editer,
	nice_tiler = { method="replace", base={"GOLDEN_MOUNTAIN_WALL", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="GOLDEN_MOUNTAIN", define_as = "GOLDEN_MOUNTAIN_WALL"..i, image = "terrain/golden_mountain5_"..i..".png"} end


--------------------------------------------------------------------------------
-- Jungle
--------------------------------------------------------------------------------

newEntity{
	define_as = "JUNGLE_PLAINS",
	type = "floor", subtype = "grass",
	name = "plains", image = "terrain/jungle/jungle_grass_floor_01.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	nice_tiler = { method="replace", base={"JUNGLE_PLAINS_PATCH", 60, 1, 5+8+3+4+4}},
	nice_editer = jungle_grass_editer,
}
for i = 1, 5 do
	newEntity{ base = "JUNGLE_PLAINS", define_as = "JUNGLE_PLAINS_PATCH"..i, add_displays={class.new{z=3,image = "terrain/jungle/jungle_brush_"..({2,3,4,6,8})[i].."_64_01.png"}} }
end
for i = 1, 8 do
	newEntity{ base = "JUNGLE_PLAINS", define_as = "JUNGLE_PLAINS_PATCH"..(i+5), add_displays={class.new{z=3,image = "terrain/jungle/jungle_brush_"..({4,5,6,7,8,9,10,11})[i].."_128_01.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}} }
end
for i = 1, 3 do
	newEntity{ base = "JUNGLE_PLAINS", define_as = "JUNGLE_PLAINS_PATCH"..(i+5+8), add_displays={class.new{z=3,image = "terrain/jungle/jungle_brush_"..({3,4,5})[i].."_192_01.png", display_x=-1, display_y=-1, display_w=3, display_h=3}} }
end
for i = 1, 4 do
	newEntity{ base = "JUNGLE_PLAINS", define_as = "JUNGLE_PLAINS_PATCH"..(i+5+8+3), add_displays={class.new{z=3,image = "terrain/jungle/jungle_dirt_var_"..i.."_64_01.png"}} }
end
for i = 1, 4 do
	newEntity{ base = "JUNGLE_PLAINS", define_as = "JUNGLE_PLAINS_PATCH"..(i+5+8+3+4), add_displays={class.new{z=3,image = "terrain/jungle/jungle_plant_0"..i..".png"}} }
end

local jungle_forest_editer = { method="borders", type="jungle", use_type="name",
	default8={z=16,  add_mos={{image="terrain/worldmap/WM_jungle_8_%02d.png", display_y=-1}}, min=1, max=3},
	default2={z=6, add_mos={{image="terrain/worldmap/WM_jungle_2_%02d.png", display_h=2}}, min=1, max=3},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_jungle_4_%02d.png", display_x=-1, display_h=2, display_y=-1}}, min=1, max=2},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_jungle_6_%02d.png", display_x=1, display_h=2, display_y=-1}}, min=1, max=2},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_jungle_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_jungle_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_jungle_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_jungle_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
	default7i={z=6, add_mos={{image="terrain/worldmap/WM_jungle_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9i={z=6, add_mos={{image="terrain/worldmap/WM_jungle_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "JUNGLE_FOREST",
	type = "wall", subtype = "grass",
	name = "jungle",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"JUNGLE_FOREST", 100, 1, 3}},
	nice_editer = jungle_grass_editer,
	nice_editer2 = jungle_forest_editer,
	special_minimap = colors.GREEN,
}
for i = 1, 3 do
	newEntity{ base="JUNGLE_FOREST", define_as = "JUNGLE_FOREST"..i, image = "terrain/jungle/jungle_grass_floor_01.png", add_displays={class.new{z=17, image="terrain/worldmap/WM_jungle_5_0"..i..".png", display_h=2, display_y=-1}}}
end

--------------------------------------------------------------------------------
-- Sand & beaches
--------------------------------------------------------------------------------

newEntity{
	define_as = "DESERT",
	type = "floor", subtype = "sand",
	name = "desert", image = "terrain/sandfloor.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	can_encounter="desert", equilibrium_level=-10,
	nice_editer = sand_editer,
}

local oasis_forest_editer = { method="borders", type="oasis", use_type="name",
	default8={z=16,  add_mos={{image="terrain/worldmap/WM_palms_8_%02d.png", display_y=-1}}, min=1, max=3},
--	default2={z=6, add_mos={{image="terrain/worldmap/WM_palms_2_%02d.png", display_h=2}}, min=1, max=3},
	default4={z=16, add_mos={{image="terrain/worldmap/WM_palms_4_%02d.png", display_x=-1}}, min=1, max=2},
	default6={z=16, add_mos={{image="terrain/worldmap/WM_palms_6_%02d.png", display_x=1}}, min=1, max=2},

	default1={z=6, add_mos={{image="terrain/worldmap/WM_palms_37d_%02d.png", display_y=1, display_x=-1}}, min=1, max=1},
	default3={z=6, add_mos={{image="terrain/worldmap/WM_palms_19d_%02d.png", display_y=1, display_x=1}}, min=1, max=1},
	default7={z=16,  add_mos={{image="terrain/worldmap/WM_palms_91d_%02d.png", display_y=-1, display_x=-1}}, min=1, max=1},
	default9={z=16,  add_mos={{image="terrain/worldmap/WM_palms_73d_%02d.png", display_y=-1, display_x=1}}, min=1, max=1},

	default1i={},
	default3i={},
--	default7i={z=6, add_mos={{image="terrain/worldmap/WM_palms_7.png", display_y=-1, display_x=-1}}, min=1, max=1},
--	default9i={z=6, add_mos={{image="terrain/worldmap/WM_palms_9.png", display_y=-1, display_x=1}}, min=1, max=1},
}
newEntity{
	define_as = "OASIS",
	type = "wall", subtype = "sand",
	name = "oasis", image = "terrain/palmtree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=93,g=79,b=22},
--	add_displays = class:makeTrees("terrain/palmtree_alpha", 8, 5),
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"OASIS", 100, 1, 5} },
	nice_editer = sand_editer,
	nice_editer2 = oasis_forest_editer,
}
for i = 1, 5 do
	newEntity{ base="OASIS", define_as = "OASIS"..i, image = "terrain/sandfloor.png", add_displays={class.new{z=17, image="terrain/worldmap/WM_palms_5_0"..i..".png", display_h=2, display_y=-1}}}
end

--------------------------------------------------------------------------------
-- Towns
--------------------------------------------------------------------------------
newEntity{ base="PLAINS", define_as = "TOWN", notice = true, change_level=1, glow=true, display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, nice_tiler=false }
newEntity{ base="JUNGLE_PLAINS", define_as = "JUNGLE_TOWN", notice = true, change_level=1, glow=true, display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, nice_tiler=false }

newEntity{ base="TOWN", define_as = "TOWN_DERTH",
	name = "Derth (Town)", add_mos = {{image="terrain/village_01.png"}},
	desc = _t"A quiet town at the crossroads of the north",
	change_zone="town-derth",
}
newEntity{ base="TOWN", define_as = "TOWN_LAST_HOPE",
	name = "Last Hope (Town)", add_displays = {class.new{image="terrain/last_hope.png", display_w=2, display_x=-0.5, z=5}, class.new{image="terrain/last_hope_up.png", display_w=2, display_x=-0.5, display_h=2, display_y=-2, z=16}},
	desc = _t"Capital city of the Allied Kingdoms ruled by King Tolak",
	change_zone="town-last-hope",
}
newEntity{ base="TOWN", define_as = "TOWN_ANGOLWEN",
	name = "Angolwen, the hidden city of magic", add_displays = {mod.class.Grid.new{z=5, image="terrain/town1.png"}},
	desc = _t"Secret place of magic, set apart from the world to protect it.\nLead by the Supreme Archmage Linaniil.",
	change_zone="town-angolwen",
}
newEntity{ base="TOWN", define_as = "TOWN_ANGOLWEN_PORTAL",
	name = "Hidden teleportation portal to Angolwen, the hidden city of magic",
	display='&', color=colors.LIGHT_BLUE, back_color=colors.DARK_GREEN,
	image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/maze_teleport.png"}},
	change_level_check = function() local p = game.party:findMember{main=true} if p:attr("forbid_arcane") then game.log("The portal fizzles.") return true end return false end,
	change_zone="town-angolwen",
}
newEntity{ base="TOWN", define_as = "TOWN_SHATUR",
	name = "Shatur (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = _t"Capital city of Thaloren lands, ruled by Nessilla Tantaelen",
	change_zone="town-shatur",
}
newEntity{ base="TOWN", define_as = "TOWN_ELVALA",
	name = "Elvala (Town)", add_mos = {{image="terrain/village_01.png"}},
	desc = _t"Capital city of Shaloren lands, ruled by Aranion Gayaeil",
	change_zone="town-elvala",
}
newEntity{ base="TOWN", define_as = "TOWN_GATES_OF_MORNING",
	name = "Gates of Morning (Town)",
	desc = _t"A massive hole in the Sunwall.",
	add_displays = {class.new{image="terrain/golden_cave_entrance02.png", z=8}},
	change_zone="town-gates-of-morning",
}
newEntity{ base="JUNGLE_TOWN", define_as = "TOWN_IRKKK",
	name = "Irkkk (Town)", add_mos = {{image="terrain/village_01.png"}},
	desc = _t"Yeek Wayist main village",
	change_zone="town-irkkk",
}
newEntity{ base="TOWN", define_as = "TOWN_ZIGUR",
	name = "Zigur (Town)", add_mos = {{image="terrain/village_01.png"}},
	desc = _t"Ziguranth main training ground",
	change_zone="town-zigur",
	change_level_check = function()
		local p = game.party:findMember{main=true}
		if p:attr("forbid_arcane") then
			return false
		end
		if p:attr("has_arcane_knowledge") or p:attr("undead") then
			require("engine.ui.Dialog"):simplePopup(_t"Zigur", _t"Somehow as magic user you feel this place is not safe for you.")
			return true
		end
		return false
	end,
}
newEntity{ base="TOWN", define_as = "TOWN_IRON_COUNCIL",
	name = "Iron Council (Town)",
	add_displays = {class.new{image="terrain/cave_entrance_closed02.png", z=5}},
	desc = _t"Heart of the dwarven Empire",
	change_zone="town-iron-council", change_zone_auto_stairs = true,
}

--------------------------------------------------------------------------------
-- Maj'Eyal Zones
--------------------------------------------------------------------------------
newEntity{ base="PLAINS", define_as = "ZONE_PLAINS", change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true, nice_tiler=false }
newEntity{ base="DESERT", define_as = "ZONE_DESERT", change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true, nice_tiler=false }
newEntity{ base="JUNGLE_PLAINS", define_as = "ZONE_JUNGLE_PLAINS", change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true, nice_tiler=false }

newEntity{ base="ZONE_PLAINS", define_as = "MAZE",
	name="A gate into the Maze",
	color={r=0, g=255, b=255},
	add_displays={class.new{image="terrain/dungeon_entrance02.png", z=4}},
	change_zone="maze",
}

newEntity{ base="ZONE_PLAINS", define_as = "TROLLMIRE",
	name="Passageway into the Trollmire",
	color={r=0, g=255, b=0},
	add_displays={class.new{image="terrain/road_going_right_01.png", display_w=2}},
	change_zone="trollmire",
}

newEntity{ base="ZONE_PLAINS", define_as = "OLD_FOREST_ZONE",
	name="A path into the Old Forest",
	color={r=0, g=180, b=0},
	add_displays={class.new{image="terrain/road_going_right_01.png", display_w=2}},
	change_zone="old-forest",
}

newEntity{ base="ZONE_PLAINS", define_as = "NORGOS_LAIR",
	name="Passageway into Norgos' Lair",
	color={r=0, g=180, b=0},
	add_displays={class.new{image="terrain/road_going_left_01.png", display_w=2, display_x=-1, z=4}},
	change_zone="norgos-lair",
}

newEntity{ base="ZONE_PLAINS", define_as = "DAIKARA_ZONE",
	name="Passageway into the Daikara",
	color=colors.UMBER,
	add_displays={mod.class.Grid.new{image="terrain/road_upwards_01.png", display_h=2, display_y=-1}},
	change_zone="daikara",
}

newEntity{ base="ZONE_PLAINS", define_as = "DREADFELL",
	name="The entry to the old tower of Dreadfell",
	color={r=0, g=255, b=255},
	add_mos={{image="terrain/tower_entrance02.png"}}, add_displays={class.new{image="terrain/tower_entrance_up02.png", z=18, display_y=-1}},
	change_zone="dreadfell",
}

newEntity{ base="ZONE_PLAINS", define_as = "KOR_PUL",
	name="Ruins of Kor'Pul",
	color={r=0, g=255, b=255},
	add_displays={class.new{image="terrain/ruin_tower01.png", display_h=2, display_y=-1}},
	change_zone="ruins-kor-pul",
}

newEntity{ base="ZONE_PLAINS", define_as = "HALFLING_RUINS",
	name="Very old halfling ruins",
	color={r=0, g=255, b=255},
	add_displays={class.new{image="terrain/road_going_left_01.png", display_w=2, display_x=-1, z=4}},
	change_zone="halfling-ruins",
}

newEntity{ base="ZONE_PLAINS", define_as = "SCINTILLATING_CAVES",
	name="Entrance to the Scintillating Caves",
	color={r=0, g=255, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="scintillating-caves",
}

newEntity{ base="ZONE_PLAINS", define_as = "RHALOREN_CAMP",
	name="Stairway into the Rhaloren Camp",
	color={r=0, g=255, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="rhaloren-camp",
}

newEntity{ base="ZONE_PLAINS", define_as = "HEART_GLOOM",
	name="Way into the heart of the gloom",
	color={r=0, g=255, b=255},
	add_mos={{image="terrain/cave_entrance_closed01.png"}},
	change_zone="heart-gloom",
}

newEntity{ base="ZONE_DESERT", define_as = "SANDWORM_LAIR",
	name="A mysterious hole in the beach",
	color={r=200, g=255, b=55},
	add_mos={{image="terrain/ladder_down.png"}},
	change_zone="sandworm-lair",
}

newEntity{ base="ZONE_DESERT", define_as = "RITCH_TUNNELS",
	name="Tunnel into the ritchs grounds",
	color={r=200, g=255, b=55},
	add_mos={{image="terrain/ladder_down.png"}},
	change_zone="ritch-tunnels",
}

newEntity{ base="CHARRED_SCAR", define_as = "CHARRED_SCAR_VOLCANO",
	name="Charred Scar Volcano", nice_tiler=false,
	color={r=200, g=255, b=55},
	display='>', color=colors.RED, back_color=colors.LIGHT_DARK,
	add_mos={{image="terrain/lava/volcano_02.png"}}, add_displays={class.new{image="terrain/lava/volcano_02_up.png", display_y=-1, z=18}},
	notice = true, 
	--change_level=1, change_zone="charred-scar",
}

newEntity{ base="ZONE_JUNGLE_PLAINS", define_as = "REL_TUNNEL",
	name="Tunnel to Maj'Eyal",
	colors.LIGHT_BLUE,
	add_mos={{image="terrain/ruin_entrance01.png"}},
	force_down=true, change_level=4, change_zone="halfling-ruins",
	change_level_check = function() local p = game.party:findMember{main=true} if p:hasQuest("start-yeek") and not p:isQuestStatus("start-yeek", engine.Quest.DONE) then require("engine.ui.Dialog"):simplePopup(_t"Long tunnel", _t"You cannot abandon the yeeks of Rel to the dangers that lie within the island.") return true end p:setQuestStatus("rel-tunnel", engine.Quest.DONE) return false end,
}

newEntity{ base="ZONE_PLAINS", define_as = "UNREMARKABLE_CAVE",
	name="Unremarkable cave",
	color={r=0, g=255, b=255},
	add_displays={class.new{image="terrain/cave_entrance01.png", z=4}},
	change_zone="unremarkable-cave",
}

newEntity{ base="ZONE_PLAINS", define_as = "REKNOR",
	name="A gate into the old kingdom of Reknor",
	color=colors.UMBER,
	add_displays={class.new{image="terrain/cave_entrance_closed02.png", z=4}},
	change_zone="reknor",
}

newEntity{ base="ZONE_PLAINS", define_as = "TELMUR",
	name="Entrance into Telmur, tower of Telos",
	color=colors.RED,
	add_mos={{image="terrain/tower_entrance02.png"}}, add_displays={class.new{image="terrain/tower_entrance_up02.png", z=18, display_y=-1}},
	change_zone="telmur",
}

newEntity{ base="WATER_BASE", define_as = "MURGOL_LAIR",
	name="Way into the lair of Murgol",
	color={r=0, g=0, b=255},
	add_displays={class.new{image="terrain/underwater/subsea_cave_entrance_01.png", z=4, display_h=2, display_y=-1}},
	change_level=1, change_zone="murgol-lair", glow=true,
}

newEntity{ base="ZONE_PLAINS", define_as = "TEMPEST_PEAK",
	name="Long road to the Tempest Peak",
	color=colors.WHITE,
	add_displays={mod.class.Grid.new{image="terrain/road_upwards_01.png", display_h=2, display_y=-1}},
	change_level=1, change_zone="tempest-peak",
	change_level_check = function()
		game.turn = game.turn + 5 * game.calendar.HOUR
		if not game.player:hasQuest("lightning-overload").walked then
			require("engine.ui.Dialog"):simpleLongPopup(_t"Danger...", _t[[After walking many hours, you finally reach the end of the way. You are nearly on top of one of the highest peaks you can see.
The storm is raging above your head.]], 400)
			game.player:hasQuest("lightning-overload").walked = true
		end
	end,
}

newEntity{ base="ZONE_PLAINS", define_as = "LAST_HOPE_GRAVEYARD",
	name="A gate into Last Hope's graveyard",
	color={r=0, g=255, b=255},
	add_displays={class.new{image="terrain/dungeon_entrance01.png", z=4}},
	change_zone="last-hope-graveyard",
}

--------------------------------------------------------------------------------
-- Far East Zones
--------------------------------------------------------------------------------

newEntity{ base="ZONE_DESERT", define_as = "RAK_SHOR_PRIDE",
	name="Entrance to Rak'shor Pride bastion",
	color=colors.UMBER,
	add_displays = {mod.class.Grid.new{image="terrain/dungeon_entrance_closed02.png", z=5}},
	change_zone="rak-shor-pride",
}

newEntity{ base="ZONE_DESERT", define_as = "GORBAT_PRIDE",
	name="Entrance to Gorbat Pride bastion",
	color=colors.UMBER,
	add_displays = {mod.class.Grid.new{image="terrain/dungeon_entrance_closed02.png", z=5}},
	change_zone="gorbat-pride",
}

newEntity{ base="ZONE_PLAINS", define_as = "GRUSHNAK_PRIDE",
	name="Entrance to Grushnak Pride bastion",
	color=colors.UMBER,
	add_displays = {mod.class.Grid.new{image="terrain/ladder_down.png", z=5}},
	change_zone="grushnak-pride",
}

newEntity{ base="ZONE_PLAINS", define_as = "VOR_PRIDE",
	name="Entrance to Vor Pride bastion",
	color=colors.UMBER,
	add_displays = {mod.class.Grid.new{image="terrain/dungeon_entrance_closed02.png", z=5}},
	change_zone="vor-pride",
}

newEntity{ base="ZONE_PLAINS", define_as = "VOR_ARMOURY",
	name="Backdoor to the Vor Armoury",
	color=colors.UMBER,
	add_displays = {mod.class.Grid.new{image="terrain/dungeon_entrance_closed02.png", z=5}},
	change_zone="vor-armoury",
}

newEntity{ base="ZONE_DESERT", define_as = "BRIAGH_LAIR",
	name="Entrance into the sandpit of Briagh",
	color=colors.YELLOW,
	add_displays = {mod.class.Grid.new{image="terrain/ladder_down.png", z=5}},
	change_zone="briagh-lair",
}

newEntity{ base="ZONE_DESERT", define_as = "CAVERN_MOON",
	name="Cavern leading to the valley of the moon",
	color=colors.GREY,
	add_displays = {mod.class.Grid.new{image="terrain/cave_entrance_closed02.png", z=5}},
	change_zone="valley-moon-caverns",
}

newEntity{ base="ZONE_PLAINS", define_as = "ARDHUNGOL",
	name="A way into the caverns of Ardhungol",
	color=colors.GREEN,
	add_displays = {mod.class.Grid.new{image="terrain/cave_entrance02.png", z=5}},
	change_zone="ardhungol",
}

newEntity{ base="ZONE_DESERT", define_as = "ERUAN",
	name="The arid wastes of Erúan",
	color=colors.UMBER,
	add_displays={mod.class.Grid.new{image="terrain/road_upwards_01.png", display_h=2, display_y=-1}},
	change_zone="eruan",
}
