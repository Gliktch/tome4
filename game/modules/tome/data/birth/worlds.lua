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

local default_eyal_descriptors = function(add)
	local base = {

	race =
	{
		__ALL__ = "disallow",
		Human = "allow",
		Elf = "allow",
		Dwarf = "allow",
		Halfling = "allow",
		Yeek = "allow",
		Giant = "allow",
		Undead = "allow",
		Construct = "allow",
	},

	class =
	{
		__ALL__ = "disallow",
		Psionic = "allow",
		Warrior = "allow",
		Rogue = "allow",
		Mage = "allow",
		Celestial = "allow",
		Wilder = "allow",
		Defiler = "allow",
		Afflicted = "allow",
		Chronomancer = "allow",
		Psionic = "allow",
		Adventurer = "allow",
	},
	subclass =
	{
		-- Nobody should be a sun paladin & anorithil but humans & elves
		['Sun Paladin'] = "nolore",
		Anorithil = "nolore",
		-- Nobody should be an archmage but human, elves, halflings and undeads
		Archmage = "nolore",
	},
}
	if add then table.merge(base, add) end
	return base
end
Birther.default_eyal_descriptors = default_eyal_descriptors

-- Player worlds/campaigns
newBirthDescriptor{
	type = "world",
	name = "Maj'Eyal",
	display_name = _t"Maj'Eyal: The Age of Ascendancy",
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.campaign == "Maj'Eyal",
	desc =
	{
		_t"The people of Maj'Eyal: Humans, Halflings, Elves and Dwarves.",
		_t"The known world has been at relative peace for over one hundred years, and people are prospering again.",
		_t"You are an adventurer, setting out to find lost treasure and glory.",
		_t"But what lurks in the shadows of the world?",
	},
	descriptor_choices = default_eyal_descriptors{},
	game_state = {
		campaign_name = "maj-eyal",
		supports_lich_transform = "lichform",
		supports_fallen_transform = function(actor)
			-- Didn't save the merchant
			if actor:hasQuest("lost-merchant") then
				if actor:hasQuest("lost-merchant"):isCompleted("evil") then return true end
				if actor:hasQuest("lost-merchant"):isFailed() then return true end
				if not actor:hasQuest("lost-merchant"):isCompleted("saved") then return true end
			end
			-- Let Melinda die
			if (actor:hasQuest("kryl-feijan-escape") and actor:hasQuest("kryl-feijan-escape"):isStatus(engine.Quest.FAILED)) then return true end
			-- Sided with the Grand Corruptor
			if (actor:hasQuest("anti-antimagic") and actor:hasQuest("anti-antimagic"):isStatus(engine.Quest.DONE)) then return true end
			-- Killed an escort yourself
			local id = world:getCurrentAchievementDifficultyId(game, "ESCORT_KILL")
			if actor.achievement_data and actor.achievement_data[id] and (actor.achievement_data[id].nb or 0) > 0 then return true end
			-- Lumberjack massacre
			if (actor:hasQuest("lumberjack-cursed") and (actor:hasQuest("lumberjack-cursed").lumberjacks_died or 0) >= 20) then return true end
			-- Slave arena
			if (actor:hasQuest("ring-of-blood") and actor:hasQuest("ring-of-blood"):isStatus(engine.Quest.DONE)) and actor:hasQuest("ring-of-blood"):isCompleted("won-fight") then return true end
			return false
		end,
		stores_restock_by_level = 1,
		__allow_rod_recall = true,
		__allow_transmo_chest = true,
		grab_online_event_zone = function() return "wilderness-1" end,
		grab_online_event_spot = function(zone, level)
			local find = {type="world-encounter", subtype="maj-eyal"}
			local where = game.level:pickSpotRemove(find)
			while where and (game.level.map:checkAllEntities(where.x, where.y, "block_move") or not game.level.map:checkAllEntities(where.x, where.y, "can_encounter")) do where = game.level:pickSpotRemove(find) end
			local x, y = mod.class.Encounter:findSpot(where)
			return x, y
		end,
		zone_tiers = {
			{name="tier1", "trollmire", "norgos-lair", "scintillating-caves", "rhaloren-camp", "heart-gloom", "ruins-kor-pul"},
			{name="tier2", "sandworm-lair", "old-forest", "maze", "daikara", "halfling-ruins"},
			{name="tier3", "dreadfell", "reknor", "unremarkable-cave", "vor-armoury", "briagh-lair"}
		}		
	},
}

newBirthDescriptor{
	type = "world",
	name = "Infinite",
	display_name = _t"Infinite Dungeon: The Neverending Descent",
	locked = function() return profile.mod.allow_build.campaign_infinite_dungeon end,
	locked_desc = _t"Ever deeper, never ending, no reprieve, keep descending. In ruins old, through barred gate, once riddle solved, find thy fate.",
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.campaign == "Infinite",
	desc =
	{
		_t"Play as your favorite race and class and venture into the infinite dungeon.",
		_t"The only limit to how far you can go is your own skill!",
		_t"Inside the infinite dungeon you will yourself be limitless. You can level up beyond level 50 and continue to gain stat and talent points (at a reduced rate).",
		_t"Every level after level 50 the maximum of stats will increase by one.",
		_t"Every 10 levels after level 50 the maximum points of each talent will increase by one.",
	},
	descriptor_choices = default_eyal_descriptors{ difficulty = { Tutorial = "never"} },
	random_escort_possibilities = { {"infinite-dungeon", 5, 40} },
	copy = {
		-- Can levelup forever
		resolvers.generic(function(e) e.max_level = nil end),
		no_points_on_levelup = function(self)
			if self.level <= 50 then
				self.unused_stats = self.unused_stats + (self.stats_per_level or 3) + self:getRankStatAdjust()
				self.unused_talents = self.unused_talents + 1
				self.unused_generics = self.unused_generics + 1
				if self.level % 5 == 0 then self.unused_talents = self.unused_talents + 1 end
				if self.level % 5 == 0 then self.unused_generics = self.unused_generics - 1 end

				if self.extra_talent_point_every and self.level % self.extra_talent_point_every == 0 then self.unused_talents = self.unused_talents + 1 end
				if self.extra_generic_point_every and self.level % self.extra_generic_point_every == 0 then self.unused_generics = self.unused_generics + 1 end

				if self.level == 10 or self.level == 20 or self.level == 34 or self.level == 46 then
					self.unused_talents_types = self.unused_talents_types + 1
				end
				if self.level == 25 or self.level == 42 then
					self.unused_prodigies = self.unused_prodigies + 1
				end
				if self.level == 50 then
					self.unused_stats = self.unused_stats + 10
					self.unused_talents = self.unused_talents + 3
					self.unused_generics = self.unused_generics + 3
				end
			else
				self.unused_stats = self.unused_stats + 1
				if self.level % 2 == 0 then
					self.unused_talents = self.unused_talents + 1
				elseif self.level % 3 == 0 then
					self.unused_generics = self.unused_generics + 1
				end
			end
		end,

		resolvers.equip{ id=true, {name="iron pickaxe", ego_chance=-1000}},
		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "infinite-dungeon"
			self.starting_quest = "infinite-dungeon"
			self.starting_intro = "infinite-dungeon"
		end,
	},
	game_state = {
		campaign_name = "infinite-dungeon",
		__allow_transmo_chest = true,
		is_infinite_dungeon = true,
		ignore_prodigies_special_reqs = true,
		grab_online_event_zone = function() return "infinite-dungeon-"..(game.level.level+rng.range(1,4)) end,
		grab_online_event_spot = function(zone, level)
			if not level then return end
			local x, y = game.state:findEventGrid(level)
			return x, y
		end,
	},
}

newBirthDescriptor{
	type = "world",
	name = "Arena",
	display_name = _t"The Arena: Challenge of the Master",
	locked = function() return profile.mod.allow_build.campaign_arena end,
	locked_desc = _t"Blood spilled on sand, only the strong survive. Prove yourself worthy to enter.",
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.campaign == "Arena",
	desc =
	{
		_t"Play as a lone warrior facing the Arena's challenge!",
		_t"You can use any class and race for it.",
		_t"See how far you can go! Can you become the new Master of the Arena?",
		_t"If so, you will battle your own champion next time!",
	},
	descriptor_choices = default_eyal_descriptors{ difficulty = { Tutorial = "never" }, permadeath = { Exploration = "never", Adventure = "never" } },
	copy = {
		death_dialog = "ArenaFinish",
		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "arena"
			self.starting_quest = "arena"
			self.starting_intro = "arena"
		end,
	},
	game_state = {
		campaign_name = "arena",
		is_arena = true,
		ignore_prodigies_special_reqs = true,
	},
}

