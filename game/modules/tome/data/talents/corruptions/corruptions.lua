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

-- Corruptions
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/sanguisuge", name = _t("sanguisuge", "talent type"), description = _t"Manipulate life force to feed your own dark powers." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/torment", name = _t("torment", "talent type"), generic = true, description = _t"All the tools to torment your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/vim", name = _t("vim", "talent type"), description = _t"Touch the very essence of your victims." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/bone", name = _t("bone", "talent type"), description = _t"Harness the power of bones." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/hexes", name = _t("hexes", "talent type"), generic = true, description = _t"Hex your foes, hindering and crippling them." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/curses", name = _t("curses", "talent type"), generic = true, description = _t"Curse your foes, hindering and crippling them." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/vile-life", name = _t("vile life", "talent type"), generic = true, description = _t"Manipulate life for your vile needs." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/plague", name = _t("plague", "talent type"), description = _t"Spread diseases to your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/scourge", name = _t("scourge", "talent type"), description = _t"Bring pain and destruction to the world." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/reaving-combat", name = _t("reaving combat", "talent type"), description = _t"Enhanced melee combat through the dark arts." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/blood", name = _t("blood", "talent type"), description = _t"Harness the power of blood, both your own and your foes'." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/blight", name = _t("blight", "talent type"), description = _t"Bring corruption and decay to all who oppose you." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/shadowflame", name = _t("Shadowflame", "talent type"), description = _t"Harness the power of the demonic shadowflame." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, min_lev = 10, type="corruption/rot", name = _t("rot", "talent type"), description = _t"Become one with rot and decay." }

-- Generic requires for corruptions based on talent level
corrs_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
corrs_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
corrs_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
corrs_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
corrs_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
str_corrs_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_corrs_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_corrs_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_corrs_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_corrs_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

corrs_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
corrs_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
corrs_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
corrs_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
corrs_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

load("/data/talents/corruptions/sanguisuge.lua")
load("/data/talents/corruptions/scourge.lua")
load("/data/talents/corruptions/plague.lua")
load("/data/talents/corruptions/reaving-combat.lua")
load("/data/talents/corruptions/bone.lua")
load("/data/talents/corruptions/curses.lua")
load("/data/talents/corruptions/hexes.lua")
load("/data/talents/corruptions/blood.lua")
load("/data/talents/corruptions/blight.lua")
load("/data/talents/corruptions/shadowflame.lua")
load("/data/talents/corruptions/vim.lua")
load("/data/talents/corruptions/torment.lua")
load("/data/talents/corruptions/vile-life.lua")
load("/data/talents/corruptions/rot.lua")