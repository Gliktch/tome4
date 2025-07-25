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
	name = "Mind Sear",
	type = {"psionic/psychic-assault", 1},
	require = psi_wil_req1,
	points = 5,
	cooldown = 2,
	psi = 5,
	range = function(self, t)
		if self:isTalentActive(self.T_MIND_STORM) then return 10 end
		return 7 
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	tactical = { ATTACKAREA = { MIND = 3 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		
		local baseradius = math.ceil(core.fov.distance(self.x, self.y, x, y) * 2.5)
		self:project(tg, x, y, function(px, py)
			DamageType:get(DamageType.MIND).projector(self, px, py, DamageType.MIND, dam)
			game.level.map:particleEmitter(px, py, 1, "mindsear", {baseradius=baseradius * 0.66})
			baseradius = baseradius - 10
		end)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Sends a telepathic attack, trying to destroy the brains of any target in the beam, doing %0.2f mind damage.
		The damage will increase with your Mindpower.]]):tformat(damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Psychic Lobotomy",
	type = {"psionic/psychic-assault", 2},
	require = psi_wil_req2,
	points = 5,
	cooldown = 8,
	range = function(self, t)
		if self:isTalentActive(self.T_MIND_STORM) then return 10 end
		return 7 
	end,
	psi = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { MIND = 2 }, DISABLE = { confusion = 2 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 200) end,
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end, --2x cunning damage
	-- confusion effect implemented in "LOBOTOMIZED" effect in data\timed_effects\mental.lua
	getConfuse = function(self, t) return self:combatLimit(t.getPower(self,t), 50, 0, 0, 34.7, 34.7) end, -- Limit < 50%
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		
		local dam = self:mindCrit(t.getDamage(self, t))
		if target:canBe("confusion") then
			target:setEffect(target.EFF_LOBOTOMIZED, t.getDuration(self, t), {src=self, dam=dam, power=t.getPower(self, t), confuse=t.getConfuse(self,t), apply_power=self:combatMindpower()})
		else
			game.logSeen(target, "%s resists the lobotomy!", target:getName():capitalize())
		end

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local cunning_damage = t.getPower(self, t)/2
		local power = t.getConfuse(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f mind damage and cripples the target's higher mental functions, reducing cunning by %d and confusing (%d%% power) the target for %d turns. %s
		The damage, cunning penalty, and confusion power will scale with your Mindpower.]]):
		tformat(damDesc(self, DamageType.MIND, (damage)), cunning_damage, power, duration, Desc.vs"mm")
	end,
}

newTalent{
	name = "Synaptic Static",
	type = {"psionic/psychic-assault", 3},
	require = psi_wil_req3,
	points = 5,
	cooldown = 10,
	psi = 10,
	range = 0,
	direct_hit = true,
	requires_target = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t, friendlyfire=false, selffire=false} end,
	tactical = { ATTACKAREA = { MIND = 3 }, DISABLE=1 },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.MIND, {dam=self:mindCrit(self:combatTalentMindDamage(t, 20, 200)), crossTierChance=100} )
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "generic_ball", {radius=self:getTalentRadius(t), rm=100, rM=125, gm=100, gM=125, bm=100, bM=125, am=200, aM=255})
		game:playSoundNear(self, "talents/echo")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Sends out a blast of telepathic static in a %d radius, inflicting %0.2f mind damage.  This attack can brainlock affected targets %s.
		The damage will increase with your Mindpower.]]):tformat(radius, damDesc(self, DamageType.MIND, damage), Desc.vs"mm")
	end,
}

newTalent{
	name = "Sunder Mind",
	type = {"psionic/psychic-assault", 4},
	require = psi_wil_req4,
	points = 5,
	cooldown = 4,
	psi = 5,
	tactical = { ATTACK = { MIND = 2}, DISABLE = 1},
	range = function(self, t)
		if self:isTalentActive(self.T_MIND_STORM) then return 10 end
		return 7 
	end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		local dam =self:mindCrit(t.getDamage(self, t))
		if target:hasEffect(target.EFF_BRAINLOCKED) then dam = dam * 2 end
		self:project(tg, x, y, DamageType.MIND, {dam=dam, alwaysHit=true}, {type="mind"})
		target:setEffect(target.EFF_SUNDER_MIND, 4, {power=dam/10})
		
		game:playSoundNear(self, "talents/warp")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local power = t.getDamage(self, t) / 10
		return ([[Cripples the target's mind, inflicting %0.2f mind damage and reducing its Mental Save by %d for 4 turns %s.  The mental save reduction stacks.
		Against brainlocked targets, the damage and Mental Save reduction will be doubled.
		The damage and save reduction will scale with your Mindpower.]]):
		tformat(damDesc(self, DamageType.MIND, (damage)), power, Desc.vs())
	end,
}