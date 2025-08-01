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

require "engine.class"
require "engine.World"
require "mod.class.interface.WorldAchievements"
local Savefile = require "engine.Savefile"

module(..., package.seeall, class.inherit(engine.World, mod.class.interface.WorldAchievements))

function _M:init()
	engine.World.init(self)
end

function _M:run()
	self:loadAchievements()
end

--- Requests the world to save
function _M:saveWorld(no_dialog)
	-- savefile_pipe is created as a global by the engine
	savefile_pipe:push("", "world", self)
end

--- Format an achievement source
-- @param src the actor who did it
function _M:achievementWho(src)
	local p = game.party:findMember{main=true}
	return ("%s the %s %s level %s"):tformat(p.name, _t(p.descriptor.subrace), _t(p.descriptor.subclass, "birth descriptor subclass"), p.level)
end

--- Gain an achievement
-- @param id the achievement to gain
-- @param src who did it
function _M:gainAchievement(id, src, ...)
	local no_difficulties = false
	if type(id) == "table" then
		no_difficulties = id.no_difficulties
		id = id.id
	end

	local a = self.achiev_defs[id]
	-- Do not unlock things in easy mode
	if not a then return end
	if game.difficulty == game.DIFFICULTY_EASY and not a.tutorial then return end

	if not no_difficulties then
		if game.permadeath == game.PERMADEATH_INFINITE then id = "EXPLORATION_"..id end
		if game.difficulty == game.DIFFICULTY_NORMAL and game.permadeath == game.PERMADEATH_ONE then id = "NORMAL_ROGUELIKE_"..id end
		if game.difficulty == game.DIFFICULTY_NIGHTMARE and game.permadeath == game.PERMADEATH_MANY then id = "NIGHTMARE_ADVENTURE_".. id end
		if game.difficulty == game.DIFFICULTY_NIGHTMARE and game.permadeath == game.PERMADEATH_ONE then id = "NIGHTMARE_"..id end
		if game.difficulty == game.DIFFICULTY_INSANE and game.permadeath == game.PERMADEATH_MANY then id = "INSANE_ADVENTURE_"..id end
		if game.difficulty == game.DIFFICULTY_INSANE and game.permadeath == game.PERMADEATH_ONE then id = "INSANE_"..id end
		if game.difficulty == game.DIFFICULTY_MADNESS and game.permadeath == game.PERMADEATH_MANY then id = "MADNESS_ADVENTURE_"..id end
		if game.difficulty == game.DIFFICULTY_MADNESS and game.permadeath == game.PERMADEATH_ONE then id = "MADNESS_"..id end
	end

	local knew = self.achieved[id]

	mod.class.interface.WorldAchievements.gainAchievement(self, id, src, ...)
	if not knew and self.achieved[id] then game.party.on_death_show_achieved[#game.party.on_death_show_achieved+1] = ("Gained new achievement: %s"):tformat(a.name) end
end

function _M:seenZone(short_name)
	self.seen_zones = self.seen_zones or {}
	self.seen_zones[short_name] = true
end

function _M:hasSeenZone(short_name)
	self.seen_zones = self.seen_zones or {}
	return self.seen_zones[short_name]
end

function _M:unlockShimmer(o)
	if not o.slot or type(o.type) ~= "string" or type(o.subtype) ~= "string" then return end
	self.unlocked_shimmers = self.unlocked_shimmers or {}

	local shimmer_name
	local unique = nil
	-- if o.randart or o.rare then return end
	if o.cosmetic then
		shimmer_name = o:getName{do_color=true, use_shimmer_suffix=true, no_add_name=true, no_image=true, force_id=true}
		unique = true
	elseif o.unique and not o.randart then
		shimmer_name = o:getName{do_color=true, use_shimmer_suffix=true, no_add_name=true, no_image=true, force_id=true}
		unique = true
	elseif o.__original and not o.__original.randart and not o.__original.rare then
		o = o.__original
		shimmer_name = o:getName{do_color=true, use_shimmer_suffix=true, no_add_name=true, no_image=true, force_id=true}
	else
		return
	end

	local moddables = {}
	for _, p in ipairs{"moddable_tile", "moddable_tile2", "moddable_tile_back", "moddable_tile_hood", "moddable_tile_particle", "moddable_tile_ornament", "moddable_tile_projectile"} do
		if o[p] then moddables[p] = o[p] end
	end

	if next(moddables) then
		self.unlocked_shimmers[o.slot] = self.unlocked_shimmers[o.slot] or {}
		if not self.unlocked_shimmers[o.slot][shimmer_name] then
			game.log("#LIGHT_BLUE#New shimmer option unlocked: #{italic}#%s#{normal}#", shimmer_name)
		end
		self.unlocked_shimmers[o.slot][shimmer_name] = { type = o.type, subtype = o.subtype, unique=unique, moddables = moddables}
	end
end
