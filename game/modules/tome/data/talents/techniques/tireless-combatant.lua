-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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



newTalent {
	short_name = "SKIRMISHER_BREATHING_ROOM",
	name = "Breathing Room",
	type = {"technique/tireless-combatant", 1},
	require = techs_strdex_req1,
	mode = "passive",
	points = 5,
	getRestoreRate = function(self, t)
		return t.applyMult(self, t, self:combatTalentScale(t, 1.5, 6, 0.75))
	end,
	applyMult = function(self, t, gain)
		if self:knowTalent(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR) then
			local t2 = self:getTalentFromId(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR)
			return gain * t2.getMult(self, t2)
		else
			return gain
		end
	end,
	callbackOnAct = function(self, t)

		-- Remove the existing regen rate
		if self.temp_skirmisherBreathingStamina then
			self:removeTemporaryValue("stamina_regen", self.temp_skirmisherBreathingStamina)
		end
		if self.temp_skirmisherBreathingLife then
			self:removeTemporaryValue("life_regen", self.temp_skirmisherBreathingLife)
		end
		self.temp_skirmisherBreathingStamina = nil
		self.temp_skirmisherBreathingLife = nil

		-- Calculate surrounding enemies
		local nb_foes = 0
		local add_if_visible_enemy = function(x, y)
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if target and self:reactionToward(target) < 0 and self:canSee(target) then
				nb_foes = nb_foes + 1
			end
		end
		local adjacent_tg = {type = "ball", range = 0, radius = 1, selffire = false}
		self:project(adjacent_tg, self.x, self.y, add_if_visible_enemy)

		-- Add new regens if needed
		if nb_foes == 0 then
			self.temp_skirmisherBreathingStamina = self:addTemporaryValue("stamina_regen", t.getRestoreRate(self, t))
			if self:getTalentLevel(t) >= 3 then
				self.temp_skirmisherBreathingLife = self:addTemporaryValue("life_regen", t.getRestoreRate(self, t))
			end
		end

	end,
	info = function(self, t)
		local stamina = t.getRestoreRate(self, t)
		return ([[Any time you do not have an opponent in a square adjacent to you, you gain %0.1f Stamina regeneration. At talent level 3 or more, you also gain an equal amount of life regen when Breathing Room is active.]])
			:tformat(stamina)
	end,
}

newTalent {
	short_name = "SKIRMISHER_PACE_YOURSELF",
	name = "Pace Yourself",
	type = {"technique/tireless-combatant", 2},
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_stamina = 15,
	no_energy = true,
	require = techs_strdex_req2,
	tactical = { DEFENSE = 2 },
	random_ego = "utility",
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "global_speed_add", -t.getSlow(self, t))
		self:talentTemporaryValue(ret, "flat_damage_armor", {all = t.getReduction(self, t)})
		if core.shader.active(4) then
			self:talentParticles(ret, {type="shader_shield", args={toback=true,  size_factor=1, img="pace_yourself_shieldwall"}, shader={type="rotatingshield", noup=2.0, time_factor=2500, appearTime=0.2}})
			self:talentParticles(ret, {type="shader_shield", args={toback=false, size_factor=1, img="pace_yourself_shieldwall"}, shader={type="rotatingshield", noup=1.0, time_factor=2500, appearTime=0.2}})
		end
		return ret
	end,
	deactivate = function(self, t, p) return true end,
	getSlow = function(self, t)
		return  self:combatTalentLimit(t, 0, 0.15, .05)
	end,
	getReduction = function(self, t)
		return self:combatScale(self:combatDefense() * self:getTalentLevel(t), 5, 10, 30, 550)
	end,
	getBlockChance = function(self, t)
		return self:combatTalentLimit(t, 100, 20, 40)
	end,
	callbackOnTakeDamageBeforeResists = function(self, t, src, x, y, type, dam, tmp)
		local shield = self:hasShield()
		local chance = t.getBlockChance(self, t)
		if not shield or not self:knowTalent(self.T_BLOCK) then return end
		local eff = self:hasEffect(self.EFF_BLOCKING)
		local t2 = self:getTalentFromId(self.T_BLOCK)
		local bt, bt_string = t2.getBlockedTypes(self, t2)
		local bv = t2.getBlockValue(self, t2)
		if not bt[type] then return end -- ignore types we can't block
		if rng.percent(chance) and dam > bv/3 and not self:isTalentCoolingDown(t2) and not eff then 
			self:forceUseTalent(self.T_BLOCK, {ignore_energy=true})
			return {dam=dam}
		end
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t) * 100
		local reduction = t.getReduction(self, t)
		chance = t.getBlockChance(self, t)
		return ([[Control your movements to increase your defenses. This allows you to shrug off minor damage and, if you have a shield equipped, preemptively Block in reaction to incoming damage.  
		While this talent is activated, you are globally slowed by %0.1f%% and all damage you take is reduced by a flat %0.1f.
		If you have a shield equipped and Block is not on cooldown, any blockable damage that is greater than 33%% of your block value (before resistances) will have a %d%% chance to instantly activate Block.
		The flat damage reduction will increase with your defense.]])
		:tformat(slow, reduction, chance)
	end,
}

newTalent {
	short_name = "SKIRMISHER_DAUNTLESS_CHALLENGER",
	name = "Dauntless Challenger",
	type = {"technique/tireless-combatant", 3},
	require = techs_strdex_req3,
	mode = "passive",
	points = 5,
	getStaminaRate = function(self, t)
		return t.applyMult(self, t, self:combatTalentScale(t, 0.3, 1.5, 0.75))
	end,
	getLifeRate = function(self, t)
		return t.applyMult(self, t, self:combatTalentScale(t, 1, 5, 0.75))
	end,
	applyMult = function(self, t, gain)
		if self:knowTalent(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR) then
			local t2 = self:getTalentFromId(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR)
			return gain * t2.getMult(self, t2)
		else
			return gain
		end
	end,
	callbackOnAct = function(self, t)
		-- Remove the existing regen rate
		if self.temp_skirmisherDauntlessStamina then
			self:removeTemporaryValue("stamina_regen", self.temp_skirmisherDauntlessStamina)
		end
		if self.temp_skirmisherDauntlessLife then
			self:removeTemporaryValue("life_regen", self.temp_skirmisherDauntlessLife)
		end
		self.temp_skirmisherDauntlessStamina = nil
		self.temp_skirmisherDauntlessLife = nil

		-- Calculate visible enemies
		local nb_foes = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and self:canSee(act) then nb_foes = nb_foes + 1 end
		end

		-- Add new regens if needed
		if nb_foes >= 1 then
			if nb_foes > 4 then nb_foes = 4 end
			self.temp_skirmisherDauntlessStamina = self:addTemporaryValue("stamina_regen", t.getStaminaRate(self, t) * nb_foes)
			if self:getTalentLevel(t) >= 3 then
				self.temp_skirmisherDauntlessLife = self:addTemporaryValue("life_regen", t.getLifeRate(self, t) * nb_foes)
			end
		end

	end,
	info = function(self, t)
		local stamina = t.getStaminaRate(self, t)
		local health = t.getLifeRate(self, t)
		return ([[When the going gets tough, you get tougher. You gain %0.1f Stamina regen per enemy in sight, and beginning at talent level 3 and above, you also gain %0.1f life regen per enemy. The bonuses cap at 4 enemies.]])
			:tformat(stamina, health)
	end,
}

newTalent {
	short_name = "SKIRMISHER_THE_ETERNAL_WARRIOR",
	name = "The Eternal Warrior",
	type = {"technique/tireless-combatant", 4},
	require = techs_strdex_req4,
	mode = "passive",
	points = 5,
	getResist = function(self, t)
		return self:combatTalentScale(t, 0.7, 2.5)
	end,
	getResistCap = function(self, t)
		return self:combatTalentLimit(t, 30, 1, 3.5)/t.getMax(self, t) -- Limit < 30%
	end,
	getDuration = function(self, t)
		return 3
	end,
	getMax = function(self, t)
		return 5
	end,
	getMult = function(self, t, fake)
		if self:getTalentLevel(t) >= 5 or fake then
			return 1.2
		else
			return 1
		end
	end,
	-- call from incStamina whenever stamina is incremented or decremented
	onIncStamina = function(self, t, delta)
		if delta < 0 and not self.temp_skirmisherSpentThisTurn then
			self:setEffect(self.EFF_SKIRMISHER_ETERNAL_WARRIOR, t.getDuration(self, t), {
				res = t.getResist(self, t),
				cap = t.getResistCap(self, t),
				max = t.getMax(self, t),
			})
			self.temp_skirmisherSpentThisTurn = true
		end
	end,
	callbackOnAct = function(self, t)
		self.temp_skirmisherSpentThisTurn = false
	end,
	info = function(self, t)
		local max = t.getMax(self, t)
		local duration = t.getDuration(self, t)
		local resist = t.getResist(self, t)
		local cap = t.getResistCap(self, t)
		local mult = (t.getMult(self, t, true) - 1) * 100
		return ([[For each turn you spend stamina, you gain %0.1f%% resist all and %0.1f%% all resistances cap for %d turns. The buff stacks up to %d times, and each new application refreshes the duration.
		Additionally, at talent level 5 and above, Breathing Room and Dauntless Challenger are %d%% more effective.]])
			:tformat(resist, cap, duration, max, mult)
	end,
}
