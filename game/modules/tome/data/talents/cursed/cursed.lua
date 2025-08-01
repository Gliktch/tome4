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

-- Cursed
newTalentType{ allow_random=true, type="cursed/slaughter", name = _t("slaughter", "talent type"), description = _t"Your weapon yearns for its next victim." }
newTalentType{ allow_random=true, type="cursed/endless-hunt", name = _t("endless hunt", "talent type"), description = _t"Each day, you lift your weary body and begin the unending hunt." }
newTalentType{ allow_random=true, type="cursed/strife", name = _t("strife", "talent type"), description = _t"The battlefield is your home; death and confusion, your comfort." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/gloom", name = _t("gloom", "talent type"), description = _t"All those in your sight must share your despair." }
newTalentType{ allow_random=true, type="cursed/rampage", name = _t("rampage", "talent type"), description = _t"Let loose the hate that has grown within." }
newTalentType{ allow_random=false, type="cursed/predator", name = _t("predator", "talent type"), description = _t"Track and kill your prey with single-minded focus." }

-- Doomed
newTalentType{ allow_random=true, is_mind=true, type="cursed/dark-sustenance", name = _t("dark sustenance", "talent type"), generic = true, description = _t"The powers of your foes feed your dark will." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/force-of-will", name = _t("force of will", "talent type"), description = _t"Invoke the powerful force of your will." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/darkness", name = _t("darkness", "talent type"), description = _t"Harness the power of darkness to envelop your foes." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/shadows", name = _t("shadows", "talent type"), description = _t"Summon shadows from the darkness to aid you." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/punishments", name = _t("punishments", "talent type"), description = _t"Your hate becomes punishment in the minds of your foes." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/one-with-shadows", name = _t("one with shadows", "talent type"), min_lev = 10, description = _t"Harness your shadows to their full potential." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/advanced-shadowmancy", name = _t("advanced shadowmancy", "talent type"), min_lev = 10, description = _t"Gain more direct control over your shadows with physical damage talents." }

-- Generic
newTalentType{ allow_random=true, is_mind=true, type="cursed/gestures", name = _t("gestures", "talent type"), generic = true, description = _t"Enhance the power of your mind with gestures." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/cursed-form", name = _t("cursed form", "talent type"), generic = true, description = _t"You are wracked with the dark energies of the curse." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/cursed-aura", name = _t("cursed aura", "talent type"), generic = true, description = _t"The things you surround yourself with soon wither away." }
newTalentType{ allow_random=false, is_mind=true, type="cursed/curses", name = _t("curses", "talent type"), hide = true, description = _t"The effects of cursed objects." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/fears", name = _t("fears", "talent type"), description = _t"Use the fear that lies at the heart of your curse to attack the minds of your enemies." }

-- Fallen Class Evolution
newTalentType{ allow_random=true, is_mind=true, type="cursed/bloodstained", name = _t("Bloodstained", "talent type"), description = _t"You, like your weapons, are tainted forever." }
newTalentType{ allow_random=true, is_mind=true, type="cursed/crimson-templar", name = _t("Crimson Templar", "talent type"), description = _t"Blood is power. Let the rivers run red." }
newTalentType{ allow_random=true, is_mind=true, generic=true, type="cursed/hatred", name = _t("Hatred", "talent type"), description = _t"All the things in this dark world are contemptible.  Let yourself hate them and find the power therein." }
newTalentType{ allow_random=false, type="cursed/other", name = _t("Cursed", "talent type"), description = _t"Hate-powered abilities that don't belong anywhere else." }

cursed_wil_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_wil_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_wil_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_wil_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_wil_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

cursed_str_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_str_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_str_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_str_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_str_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

cursed_str_req_high1 = {
	stat = { str=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
cursed_str_req_high2 = {
	stat = { str=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
cursed_str_req_high3 = {
	stat = { str=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
cursed_str_req_high4 = {
	stat = { str=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
cursed_str_req_high5 = {
	stat = { str=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

cursed_cun_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_cun_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_cun_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_cun_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_cun_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

cursed_cun_req_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
cursed_cun_req_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
cursed_cun_req_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
cursed_cun_req_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
cursed_cun_req_high5 = {
	stat = { cun=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

cursed_mag_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
cursed_mag_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
cursed_mag_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
cursed_mag_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
cursed_mag_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

cursed_lev_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
cursed_lev_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
cursed_lev_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
cursed_lev_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
cursed_lev_req5 = {
	level = function(level) return 16 + (level-1)  end,
}

-- utility functions
function getHateMultiplier(self, min, max, cursedWeaponBonus, hate)
	local fraction = (hate or self.hate) / 100
	if cursedWeaponBonus then
		if self:hasDualWeapon() then
			if self:hasCursedWeapon() then fraction = fraction + 0.13 end
			if self:hasCursedOffhandWeapon() then fraction = fraction + 0.07 end
		else
			if self:hasCursedWeapon() then fraction = fraction + 0.2 end
		end
	end
	fraction = math.min(fraction, 1)
	return (min + ((max - min) * fraction))
end

load("/data/talents/cursed/slaughter.lua")
load("/data/talents/cursed/endless-hunt.lua")
load("/data/talents/cursed/strife.lua")
load("/data/talents/cursed/gloom.lua")
load("/data/talents/cursed/rampage.lua")
load("/data/talents/cursed/predator.lua")

load("/data/talents/cursed/force-of-will.lua")
load("/data/talents/cursed/dark-sustenance.lua")
load("/data/talents/cursed/shadows.lua")
load("/data/talents/cursed/darkness.lua")
load("/data/talents/cursed/punishments.lua")
load("/data/talents/cursed/gestures.lua")
load("/data/talents/cursed/one-with-shadows.lua")
load("/data/talents/cursed/advanced-shadowmancy.lua")

load("/data/talents/cursed/cursed-form.lua")
load("/data/talents/cursed/cursed-aura.lua")
load("/data/talents/cursed/fears.lua")

load("/data/talents/cursed/bloodstained.lua")
load("/data/talents/cursed/self-hatred.lua")
load("/data/talents/cursed/crimson-templar.lua")
