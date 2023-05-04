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
	name = "Solipsism",
	type = {"psionic/solipsism", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	no_unlearn_last = true,
	psi = 0,
	-- Speed effect calculations performed in _M:actBase function in mod\class\Actor.lua to handle suppressing the solipsim threshold
	-- Damage conversion handled in mod.class.Actor.lua _M:onTakeHit
	getConversionRatio = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.5) end, -- Limit < 100% Keep some life dependency
	getPsiDamageResist = function(self, t)
		local lifemod = 1 + (1 + self.level)/2/40 -- Follows normal life progression with level see mod.class.Actor:getRankLifeAdjust (level_adjust = 1 + self.level / 40)
		-- Note: This effectively magifies healing effects
		local talentmod = self:combatTalentLimit(t, 50, 3, 11) -- Limit < 50%
		return 100 - (100 - talentmod)/lifemod, 1-1/lifemod, talentmod
	end,
	callbackPriorities = {callbackOnHit = -30},
	callbackOnHit = function(self, t, cb, src, death_note)
		local value = cb.value
		local damage_to_psi = 0
		if value > 0 and self:getPsi() > 0 then
			damage_to_psi = value * t.getConversionRatio(self, t)
		end
		
		if damage_to_psi > 0 then
			local psi_damage_resist = 1 - t.getPsiDamageResist(self, t)/100
		--	print("Psi Damage Resist", psi_damage_resist, "Damage", damage_to_psi, "Final", damage_to_psi*psi_damage_resist)
			if self:getPsi() > damage_to_psi*psi_damage_resist then
				self:incPsi(-damage_to_psi*psi_damage_resist)
			else
				damage_to_psi = self:getPsi()
				self:incPsi(-damage_to_psi)
				if self.die_from_damage_to_psi then
					self:die(src or self, {special_death_msg=death_message or "lost all psionic focus and dissipated into nothingness"})
				end
			end
			local mindcolor = DamageType:get(DamageType.MIND).text_color or "#aaaaaa#"
			game:delayedLogMessage(self, nil, "Solipsism hit", ("%s#Source# converts some damage to Psi!"):tformat(mindcolor))
			game:delayedLogDamage(src, self, damage_to_psi*psi_damage_resist, ("%s%d %s#LAST#"):tformat(mindcolor, damage_to_psi*psi_damage_resist, _t"to psi"), false)

			value = value - damage_to_psi
		end
		
		cb.value = value
		return cb
	end,
	on_levelup_close = function(self, t, lvl, old_lvl, lvl_raw, old_lvl_raw)
		if old_lvl_raw == 0 and lvl_raw >= 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.life_rating = math.ceil(self.life_rating/2)
			self.psi_rating =  self.psi_rating + 5
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.2
			
			-- Adjust the values onTickEnd for NPCs to make sure these table values are resolved
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()
				--automatically updates to account for changes in inc_resource_multi

				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	info = function(self, t)
		local conversion_ratio = t.getConversionRatio(self, t)
		local psi_damage_resist, psi_damage_resist_base, psi_damage_resist_talent = t.getPsiDamageResist(self, t)
		local threshold = math.min((self.solipsism_threshold or 0),self:callTalent(self.T_CLARITY, "getClarityThreshold") or 1)
		return ([[You believe that your mind is the center of everything.  Permanently increases the amount of psi you gain per level by 5 and reduces your life rating (affects life at level up) by 50%% (one time only adjustment).
		You also have learned to overcome damage with your mind alone, and convert %d%% of all damage you receive into Psi damage and %d%% of your healing and life regen now recovers Psi instead of life.
		Converted Psi damage you take will be further reduced by %0.1f%% (%0.1f%% from character level with the remainder further reduced by %0.1f%% from talent level).
		The first talent point invested will also increase the amount of Psi you gain from Willpower by 0.5, but reduce the amount of life you gain from Constitution by 0.25.
		The first talent point also increases your solipsism threshold by 20%% (currently %d%%), reducing your global speed by 1%% for each percentage your current Psi falls below this threshold.]]):tformat(conversion_ratio * 100, conversion_ratio * 100, psi_damage_resist, psi_damage_resist_base * 100, psi_damage_resist_talent, (self.solipsism_threshold or 0) * 100)
	end,
}

newTalent{
	name = "Balance",
	type = {"psionic/solipsism", 2},
	points = 5, 
	require = psi_wil_req2,
	mode = "passive",
	getBalanceRatio = function(self, t) return math.min(0.1 + self:getTalentLevel(t) * 0.1, 1) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
			-- Adjust the values onTickEnd for NPCs to make sure these table values are filled out
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()

				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then

			self.inc_resource_multi.psi = self.inc_resource_multi.psi - 0.5
			self.inc_resource_multi.life = self.inc_resource_multi.life + 0.25
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
	end,
	info = function(self, t)
		local ratio = t.getBalanceRatio(self, t) * 100
		return ([[You now substitute %d%% of your Mental Save for %d%% of your Physical and Spell Saves throws (so at 100%%, you would effectively use mental save for all saving throw rolls).
		The first talent point invested will also increase the amount of Psi you gain from Willpower by 0.5, but reduce the amount of life you gain from Constitution by 0.25.
		Learning this talent also increases your solipsism threshold by 10%% (currently %d%%).]]):tformat(ratio, ratio, math.min((self.solipsism_threshold or 0),self.clarity_threshold or 1) * 100)
	end,
}

newTalent{
	name = "Clarity",
	type = {"psionic/solipsism", 3},
	points = 5, 
	require = psi_wil_req3,
	mode = "passive",
	-- Speed effect calculations performed in _M:actBase function in mod\class\Actor.lua to handle suppressing the solipsim threshold
	getClarityThreshold = function(self, t) return self:combatTalentLimit(t, 0, 0.85, 0.6)	end, -- Limit > 0%
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
			-- Adjust the values onTickEnd for NPCs to make sure these table values are resolved
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()

				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then

			self.inc_resource_multi.psi = self.inc_resource_multi.psi - 0.5
			self.inc_resource_multi.life = self.inc_resource_multi.life + 0.25
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
	end,
	info = function(self, t)
		local threshold = t.getClarityThreshold(self, t)
		local bonus = ""
		if not self.max_level or self.max_level > 50 then
			bonus = _t" Exceptional focus on this talent can suppress your solipsism threshold."
		end
		return ([[For every percent that your Psi pool exceeds %d%%, you gain 1%% global speed (up to a maximum of %+d%%).
		The first talent point invested will also increase the amount of Psi you gain from Willpower by 0.5, but reduce the amount of life you gain from Constitution by 0.25 and will increase your solipsism threshold by 10%% (currently %d%%).]]):
		tformat(threshold * 100, (1-threshold)*100, math.min(self.solipsism_threshold or 0,threshold) * 100)..bonus
	end,
}

newTalent{
	name = "Dismissal",
	type = {"psionic/solipsism", 4},
	points = 5, 
	require = psi_wil_req4,
	mode = "passive",
	getSavePercentage = function(self, t) return self:combatTalentScale(t, 0.25, 0.6) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
			-- Adjust the values onTickEnd for NPCs to make sure these table values are resolved
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()

				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then

			self.inc_resource_multi.psi = self.inc_resource_multi.psi - 0.5
			self.inc_resource_multi.life = self.inc_resource_multi.life + 0.25
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
	end,
	callbackPriorities = {callbackOnHit = -60}, -- This should not have high priority, otherwise this will have very poor effect
	callbackOnHit = function(self, t, cb, src, death_note)
		if cb.value > 0 then
			local saving_throw = self:combatMentalResist() * t.getSavePercentage(self, t)
			print("[Dismissal] ", self:getName():capitalize(), " attempting to ignore ", cb.value, "damage from ", src.name:capitalize(), "using", saving_throw,  "mental save.")
			if self:checkHit(saving_throw, cb.value) then
				-- Only calculate crit once per turn to avoid log spam
				local rate = 2
				if not self.turn_procs.dismissal_ratio then
					local critted_ratio = self:mindCrit(2)
					self.turn_procs.dismissal_ratio = math.max(2, critted_ratio)
				end
				rate = self.turn_procs.dismissal_ratio
				local dismissed = cb.value * (1 - (1 / rate)) -- Diminishing returns on high crits
				game:delayedLogMessage(self, nil, "Dismissal", "#TAN##Source# mentally dismisses some damage!")
				game:delayedLogDamage(src, self, 0, ("#TAN#(%d dismissed)#LAST#"):tformat(dismissed))
				cb.value = cb.value - dismissed
			end
		end
	end,
	info = function(self, t)
		local save_percentage = t.getSavePercentage(self, t)
		return ([[Each time you take damage, you roll %d%% of your mental save against it.  A successful saving throw can crit and will reduce the damage by at least 50%%.
		The first talent point invested will also increase the amount of Psi you gain from Willpower by 0.5, but reduce the amount of life you gain from Constitution by 0.25.
		The first talent point also increases your solipsism threshold by 10%% (currently %d%%).]]):tformat(save_percentage * 100, math.min(self.solipsism_threshold or 0,self.clarity_threshold or 1) * 100)		
	end,
}
