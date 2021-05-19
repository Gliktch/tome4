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

newBirthDescriptor{
	type = "class",
	name = "Adventurer",
	locked = function() return profile.mod.allow_build.adventurer and true or "hide"  end,
	desc = {
		_t"Adventurers can learn to do a bit of everything, getting training in whatever they happen to find.",
		_t"#{bold}##GOLD#This is a bonus class for winning the game.  It is by no means balanced.#WHITE##{normal}#",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Adventurer = "allow",
			Wanderer = "allow",
		},
	},
	copy = {
		mana_regen = 0.25,
		max_life = 100,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Adventurer",
	locked = function() return profile.mod.allow_build.adventurer and true or "hide"  end,
	desc = {
		_t"Adventurers can learn to do a bit of everything, getting training in whatever they happen to find.",
		_t"#{bold}##GOLD#This is a bonus class for winning the game.  It is by no means balanced.#WHITE##{normal}#",
		_t"Their most important stats depend on what they wish to do.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +2 Strength, +2 Dexterity, +2 Constitution",
		_t"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +2 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	not_on_random_boss = true,
	stats = { str=2, con=2, dex=2, mag=2, wil=2, cun=2 },
	talents_types = function(birth)
		local tts = {}
		for _, class in ipairs(birth.all_classes) do
			for _, sclass in ipairs(class.nodes) do if sclass.id ~= "Adventurer" and sclass.def and ((not sclass.def.not_on_random_boss) or (sclass.id == "Stone Warden" and birth.descriptors_by_type.race == "Dwarf")) then
				if birth.birth_descriptor_def.subclass[sclass.id].talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, _ in pairs(tt) do
						local tt_def = birth.actor:getTalentTypeFrom(t)
						if tt_def then
							tts[t] = {false, 0}
						end
					end
				end

				if birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, v in pairs(tt) do
						if profile.mod.allow_build[v[3]] then
						local tt_def = birth.actor:getTalentTypeFrom(t)
						if tt_def then
								tts[t] = {false, 0}
							end
						end
					end
				end
			end end
		end
		tts["technique/combat-training"] = {true, 0}
		return tts
	end,
	copy_add = {
		unused_generics = 2,
		unused_talents = 3,
		unused_talents_types = 7,
	},
	copy = {
		resolvers.inventorybirth{ id=true, transmo=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="longsword", name="iron longsword", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="longsword", name="iron longsword", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="rough leather gloves", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="scroll", subtype="rune", name="manasurge rune", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloak", name="linen cloak", autoreq=true, ego_chance=-1000},
		},
		chooseCursedAuraTree = true,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Wanderer",
	locked = function() return profile.mod.allow_build.adventurer and true or "hide"  end,
	desc = {
		_t"Wanderers are adventurers who embrace the chaotic nature of the world. They start the game with the Combat Training talent tree, 3 random class trees and 1 random generic tree.",
		_t"#{bold}##PURPLE#Every 5 levels they gain a new unlocked class tree, at random.#{normal}##LAST#",
		_t"#{bold}##PURPLE#Every 10 levels starting at level 2 they gain a new unlocked generic tree, at random.#{normal}##LAST#",
		_t"#{bold}##GOLD#This is a bonus class for winning the game.  It is by no means balanced, fun or winnable, it is most of all #{italic}#RANDOM#{bold}#.#WHITE##{normal}#",
		_t"Their most important stats depend on what they get to do.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +2 Strength, +2 Dexterity, +2 Constitution",
		_t"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +2 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	not_on_random_boss = true,
	stats = { str=2, con=2, dex=2, mag=2, wil=2, cun=2 },
	talents_types = function(birth)
		local tts_class = {}
		local tts_generic = {}
		local tts_addons = {}

		-- Fnid all available trees
		for _, class in ipairs(birth.all_classes) do if class.id ~= "Adventurer" then
			for _, sclass in ipairs(class.nodes) do if sclass.def and ((not sclass.def.not_on_random_boss) or (sclass.id == "Stone Warden" and birth.descriptors_by_type.race == "Dwarf")) then
				if birth.birth_descriptor_def.subclass[sclass.id].talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, _ in pairs(tt) do
						local tt_def = birth.actor:getTalentTypeFrom(t)
						if tt_def then
							tts_addons[tt_def.source] = true
							if tt_def.generic then
								table.insert(tts_generic, t)
							else
								table.insert(tts_class, t)
							end
						end
					end
				end

				if birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, v in pairs(tt) do
						if profile.mod.allow_build[v[3]] then
							local tt_def = birth.actor:getTalentTypeFrom(t)
							if tt_def then
								tts_addons[tt_def.source] = true
								if tt_def.generic then
									table.insert(tts_generic, t)
								else
									table.insert(tts_class, t)
								end
							end
						end
					end
				end
			end end
		end end
		birth.actor.randventurer_class_trees = tts_class
		birth.actor.randventurer_generic_trees = tts_generic
		
		-- Compute the addons fingerprint
		local md5 = require "md5"
		tts_addons['@vanilla@'] = nil
		birth.actor.randventurer_addons = {game.__mod_info.version_string}
		for a, _ in pairs(tts_addons) do
			local addon = game.__mod_info and game.__mod_info.addons and game.__mod_info.addons[a]
			if addon then
				table.insert(birth.actor.randventurer_addons, a.."-"..(addon.addon_version_txt or addon.version_txt or "???"))
			else -- Shouldnt happen but heh
				table.insert(birth.actor.randventurer_addons, a)
			end
		end
		-- Sort addons so that the fingerprint has meaning ;)
		table.sort(birth.actor.randventurer_addons)
		local addons_md5 = mime.b64(md5.sum(table.concat(birth.actor.randventurer_addons,'|')))

		local seed = rng.range(1, 99999999)
		if __module_extra_info and __module_extra_info.tome_wanderer_seed then
			local error = function() game:onTickEnd(function() require("engine.ui.Dialog"):simplePopup(_t"Wanderer Seed", _t"The wanderer seed you used was generated for a different set of DLC/addons. Your character will still work fine but you will not have the same talent set as the person that shared the seed with you.") end) end
			local _, _, iseed, check = __module_extra_info.tome_wanderer_seed:find("^([0-9]+)%-(.*)$")
			if not check or not tonumber(iseed) then
				error()
			else
				seed = tonumber(iseed)
				if check ~= addons_md5 then error() end
			end
		end
		rng.seed(seed)
		table.sort(tts_class)
		table.sort(tts_generic)
		table.shuffle(tts_class)
		table.shuffle(tts_generic)

		birth.actor.randventurer_seed = seed.."-"..addons_md5

		rng.seed(os.time())

		return {["technique/combat-training"] = {true, 0}}
	end,
	copy_add = {
		mana_regen = 0.5,
		life_rating = 2,
		unused_generics = 2,
		unused_talents = 3,
		unused_talents_types = 3,
	},
	copy = {
		randventurerLearn = function(self, what, silent)
			local tt = table.remove(what == "class" and self.randventurer_class_trees or self.randventurer_generic_trees, 1)
			if not tt then return end
			local tt_def = self:getTalentTypeFrom(tt)
			if tt_def then
				if self:knowTalentType(tt) then return self:randventurerLearn(what, silent) end
				if not silent then
					local cat = tt_def.type:gsub("/.*", "")
					local name = tstring{{"font", "bold"}, _t(cat, "talent category"):capitalize().." / "..tt_def.name:capitalize(), {"font", "normal"}}
					game.bignews:say(90, "#GOLD#As you level up you learn the talent tree: #LIGHT_BLUE#%s", tostring(name))
				end
				self:learnTalentType(tt)
			end
		end,
		randventurer_last_learn_level = 0,
		resolvers.register_callbacks{ callbackOnLevelup = function(self)
			for i = self.randventurer_last_learn_level + 1, self.level do
				if i % 5 == 0 then
					self:randventurerLearn("class")
				end
				if i % 10 == 2 then
					self:randventurerLearn("generic")
				end
			end
			self.randventurer_last_learn_level = self.level
		end },
		resolvers.generic(function(self)
			self:randventurerLearn("class", true)
			self:randventurerLearn("class", true)
			self:randventurerLearn("class", true)
			self:randventurerLearn("generic", true)
		end),
		resolvers.inventorybirth{ id=true, transmo=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="longsword", name="iron longsword", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="longsword", name="iron longsword", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="rough leather gloves", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="scroll", subtype="rune", name="manasurge rune", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloak", name="linen cloak", autoreq=true, ego_chance=-1000},
		},
		chooseCursedAuraTree = true,
	},
	cosmetic_options = {
		wanderer_seed = {
			{name=_t"Wanderer Seed", on_actor=function(actor) actor.alchemist_golem_is_drolem = true end, unlock="cosmetic_class_alchemist_drolem"},
		},
	},
}
