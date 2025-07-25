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

newTalent{
	name = "Skeleton",
	type = {"undead/skeleton", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	statBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 15, 0.75)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "inc_stats", {[self.STAT_STR]=t.statBonus(self, t)})
		self:talentTemporaryValue(p, "inc_stats", {[self.STAT_DEX]=t.statBonus(self, t)})
	end,
	info = function(self, t)
		return ([[Improves your skeletal condition, increasing Strength and Dexterity by %d.]]):
		tformat(t.statBonus(self, t))
	end,
}

newTalent{
	name = "Bone Armour",
	type = {"undead/skeleton", 2},
	require = undeads_req2,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 25, 15, false, 1.1)) end,
	tactical = { DEFEND = 2 },
	getShield = function(self, t)
		return 3.5*self:getDex()+self:combatTalentScale(t, 120, 400) + self:combatTalentLimit(t, 0.1, 0.01, 0.05)*self:getMaxLife()
	end,
	getDuration = function(self, t)
		return 10
	end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, t.getDuration(self, t), {color={0xcb/255, 0xcb/255, 0xcb/255}, power=t.getShield(self, t), image="bonearmour_shield", shield_intensity=0.3})
		return true
	end,
	info = function(self, t)
		return ([[Creates a shield of bones, absorbing %d damage. Lasts for %d turns.
		The total damage the shield can absorb increases with your Dexterity.]]):
		tformat(self:getShieldAmount(t.getShield(self, t)), self:getShieldDuration(t.getDuration(self, t)))
	end,
}

newTalent{
	name = "Resilient Bones",
	type = {"undead/skeleton", 3},
	require = undeads_req3,
	points = 5,
	mode = "passive",
	range = 1,
	-- called by _M:on_set_temporary_effect function in mod.class.Actor.lua
	durresist = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 5/12, false, 1.1) end, -- Limit < 100%
	info = function(self, t)
		return ([[Your undead bones are very resilient, reducing the duration of all detrimental effects on you by up to %d%%.]]):
		tformat(100 * t.durresist(self, t))
	end,
}

newTalent{ short_name = "SKELETON_REASSEMBLE",
	name = "Re-assemble",
	type = {"undead/skeleton",4},
	require = undeads_req4,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 30, 15, false, 1.1)) end, -- Limit cooldown >10
	getHeal = function(self, t)
		return self:combatTalentScale(t, 100, 500) + self:combatTalentLimit(t, 0.1, 0.01, 0.05, false, 1.1)*self:getMaxLife()
	end,
	tactical = { HEAL = 2 },
	is_heal = true,
	no_unlearn_last = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(t.getHeal(self, t), t)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=2.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=1.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Reposition some of your bones, healing yourself for %d.
		At level 5, you will gain the ability to completely re-assemble your body should it be destroyed (can only be used once).]]):
		tformat(t.getHeal(self, t))
	end,
}
