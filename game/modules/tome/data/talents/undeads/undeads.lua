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

-- Undead talents
newTalentType{ type="undead/base", name = _t("base", "talent type"), generic = true, description = _t"Undead's innate abilities." }
newTalentType{ type="undead/ghoul", name = _t("ghoul", "talent type"), generic = true, description = _t"Ghoul's innate abilities." }
newTalentType{ type="undead/skeleton", name = _t("skeleton", "talent type"), generic = true, description = _t"Skeleton's innate abilities." }
newTalentType{ type="undead/vampire", name = _t("vampire", "talent type"), generic = true, description = _t"Vampire's innate abilities." }
newTalentType{ type="undead/lich", name = _t("lich", "talent type"), generic = true, description = _t"Liches innate abilities." }

-- Generic requires for undeads based on talent level
undeads_req1 = { level = function(level) return 0 + (level-1)  end, }
undeads_req2 = { level = function(level) return 4 + (level-1)  end, }
undeads_req3 = { level = function(level) return 8 + (level-1)  end, }
undeads_req4 = { level = function(level) return 12 + (level-1)  end, }
undeads_req5 = { level = function(level) return 16 + (level-1)  end, }

high_undeads_req1 = { level = function(level) return 25 + (level-1)  end }
high_undeads_req2 = { level = function(level) return 28 + (level-1)  end }
high_undeads_req3 = { level = function(level) return 30 + (level-1)  end }
high_undeads_req4 = { level = function(level) return 32 + (level-1)  end }


load("/data/talents/undeads/ghoul.lua")
load("/data/talents/undeads/skeleton.lua")
load("/data/talents/undeads/lich.lua")


-- Undeads's power: ID
newTalent{
	short_name = "UNDEAD_ID",
	name = "Knowledge of the Past",
	type = {"undead/base", 1},
	no_npc_use = true,
	mode = "passive",
	no_unlearn_last = true,
	on_learn = function(self, t) self.auto_id = 100 end,
	info = function(self)
		return ([[You concentrate for a moment to recall some of your memories as a living being and look for knowledge to identify rare objects.]]):tformat()
	end,
}
