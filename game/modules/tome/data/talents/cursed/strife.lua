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

local Stats = require "engine.interface.ActorStats"

newTalent{
	name = "Dominate",
	type = {"cursed/strife", 1},
	require = cursed_str_req1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		return 8
	end,
	hate = 4,
	tactical = { ATTACK = function(self, t, aitarget)
			return self.fov.actors[aitarget] and self.fov.actors[aitarget].sqdist <= 1 and 2 or nil
		end,
		DISABLE = {pin = 2}},
	requires_target = true,
	range = 2.5,
	getDuration = function(self, t)
		return math.min(6, math.floor(2 + self:getTalentLevel(t)))
	end,
	getArmorChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 4, 30)
	end,
	getDefenseChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 6, 45)
	end,
	getResistPenetration = function(self, t) return math.min(70, self:combatTalentStatDamage(t, "wil", 25, 60)) end, -- Limit < 70%
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		-- attempt domination
		local duration = t.getDuration(self, t)
		local armorChange = t.getArmorChange(self, t)
		local defenseChange = t.getDefenseChange(self, t)
		local resistPenetration = t.getResistPenetration(self, t)
		target:setEffect(target.EFF_DOMINATED, duration, {src = self, armorChange = armorChange, defenseChange = defenseChange, resistPenetration = resistPenetration, apply_power=self:combatMindpower() })

		-- attack if adjacent
		if core.fov.distance(self.x, self.y, x, y) <= 1 then
			-- We need to alter behavior slightly to accomodate shields since they aren't used in attackTarget
			local shield, shield_combat = self:hasShield()
			local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat --can do unarmed attack
			local hit = false
			if not shield then
				hit = self:attackTarget(target, nil, 1, true)
			else
				hit = self:attackTargetWith(target, weapon, nil, 1)
				if self:attackTargetWith(target, shield_combat, nil, 1) or hit then hit = true end
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local armorChange = t.getArmorChange(self, t)
		local defenseChange = t.getDefenseChange(self, t)
		local resistPenetration = t.getResistPenetration(self, t)
		return ([[Turn your attention to a nearby foe, and dominate them with your overwhelming presence %s. They will be unable to move for %d turns and vulnerable to attacks. They will lose %d Armour, %d Defense and your attacks will gain %d%% resistance penetration. If the target is adjacent to you, your domination will include a melee attack.
		Effects will improve with your Willpower.

		This talent will also attack with your shield, if you have one equipped.]]):tformat(Desc.vs"mm", duration, -armorChange, -defenseChange, resistPenetration)
	end,
}

newTalent{
	name = "Preternatural Senses",
	type = {"cursed/strife", 2},
	mode = "passive",
	require = cursed_str_req2,
	points = 5,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 6.6)) end,
	-- _M:combatSeeStealth and _M:combatSeeInvisible functions updated in mod.class.interface.Combat.lua
	sensePower = function(self, t) return math.max(0, self:combatScale(self:getWil(15, true)*self:getTalentLevel(t), 10, 1, 80, 75, 0.25)) end, --TL 5, wil 100 = 80
	info = function(self, t)
		local range = self:getTalentRange(t)
		local sense = t.sensePower(self, t)
		return ([[Your preternatural senses aid you in your hunt for the next victim. You sense foes in a radius of %0.1f. You will always sense a stalked victim in a radius of 10.
		Also increases stealth detection by %d and invisibility detection by %d.
		Stealth and invisibility detection improves with your Willpower]]):
		tformat(range, sense, sense)
	end,
}

--newTalent{
--	name = "Suffering",
--	type = {"cursed/strife", 2},
--	require = cursed_str_req2,
--	points = 5,
--	cooldown = 30,
--	hate = 5,
--	tactical = { DEFEND = 3 },
--	getConversionDuration = function(self, t)
--		return 3
--	end,
--	getDuration = function(self, t)
--		return 10
--	end,
--	getConversionPercent = function(self, t)
--		return self:combatTalentStatDamage(t, "wil", 40, 80)
--	end,
--	getMaxConversion = function(self, t, hate)
--		return self:combatTalentStatDamage(t, "wil", 60, 400) * getHateMultiplier(self, 0.7, 1, false, hate)
--	end,
--	action = function(self, t)
--		local duration = t.getDuration(self, t)
--		local conversionDuration = t.getConversionDuration(self, t)
--		local conversionPercent = t.getConversionPercent(self, t)
--		local maxConversion = t.getMaxConversion(self, t)
--		self:setEffect(target.EFF_SUFFERING, duration, { conversionDuration = conversionDuration, conversionPercent = conversionPercent, maxConversion = maxConversion })
--
--		return true
--	end,
--	info = function(self, t)
--		local duration = t.getDuration(self, t)
--		local conversionDuration = t.getConversionDuration(self, t)
--		local conversionPercent = t.getConversionPercent(self, t)
--		local maxConversion = t.getMaxConversion(self, t)
--		return ([[Your suffering becomes theirs. %d%% of all damage (up to a maximum of %d per turn) that you inflict over %d turns feeds your own endurance allowing you to negate that much damage over % turns.]]):tformat(conversionPercent, maxConversion, conversionDuration, duration)
--	end,
--}

--newTalent{
--	name = "Bait",
--	type = {"cursed/strife", 2},
--	require = cursed_str_req2,
--	points = 5,
--	random_ego = "attack",
--	cooldown = 6,
--	hate = 4,
--	tactical = { ATTACK = 2 },
--	requires_target = true,
--	getDamagePercent = function(self, t)
--		return 100 - (40 / self:getTalentLevel(t))
--	end,
--	getDistance = function(self, t)
--		return math.max(1, math.floor(self:getTalentLevel(t)))
--	end,
--	action = function(self, t)
--		local tg = {type="hit", range=self:getTalentRange(t)}
--		local x, y, target = self:getTarget(tg)
--		if not x or not y or not target then return nil end
--		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
--
--		local damagePercent = t.getDamagePercent(self, t)
--		local distance = t.getDistance(self, t)
--
--		local hit = self:attackTarget(target, nil, damagePercent / 100, true)
--		self:knockback(target.x, target.y, distance)
--
--		return true
--	end,
--	info = function(self, t)
--		local damagePercent = t.getDamagePercent(self, t)
--		local distance = t.getDistance(self, t)
--		return ([[Swing your weapon for %d%% damage as you leap backwards %d spaces from your target.]]):tformat(damagePercent, distance)
--	end,
--}

--newTalent{
--	name = "Ruined Cut",
--	type = {"cursed/strife", 2},
--	require = cursed_wil_req2,
--	points = 5,
--	random_ego = "attack",
--	cooldown = 6,
--	hate = 4,
--	tactical = { ATTACK = 2 },
--	requires_target = true,
--	getDamagePercent = function(self, t)
--		return 100 - (40 / self:getTalentLevel(t))
--	end,
--	getPoisonDamage = function(self, t, hate)
--		return self:combatTalentStatDamage(t, "wil", 20, 300) * getHateMultiplier(self, 0.5, 1.0, false, hate)
--	end,
--	getHealFactor = function(self, t, hate)
--		return self:combatTalentStatDamage(t, "wil", 30, 70) * getHateMultiplier(self, 0.5, 1.0, false, hate)
--	end,
--	getDuration = function(self, t)
--		return math.max(3, math.floor(6.5 - self:getTalentLevel(t) * 0.5))
--	end,
--	action = function(self, t)
--		local tg = {type="hit", range=self:getTalentRange(t)}
--		local x, y, target = self:getTarget(tg)
--		if not x or not y or not target then return nil end
--		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
--
--		local damagePercent = t.getDamagePercent(self, t)
--		local poisonDamage = t.getPoisonDamage(self, t)
--		local healFactor = t.getHealFactor(self, t)
--		local duration = t.getDuration(self, t)
--
--		local hit = self:attackTarget(target, nil, damagePercent / 100, true)
--		if hit and target:canBe("poison") then
--			target:setEffect(target.EFF_INSIDIOUS_POISON, duration, {src=self, power=poisonDamage / duration, heal_factor=healFactor})
--		end
--
--		return true
--	end,
--	info = function(self, t)
--		local damagePercent = t.getDamagePercent(self, t)
--		local poisonDamageMin = t.getPoisonDamage(self, t, 0)
--		local poisonDamageMax = t.getPoisonDamage(self, t, 100)
--		local healFactorMin = t.getHealFactor(self, t, 0)
--		local healFactorMax = t.getHealFactor(self, t, 100)
--		local duration = t.getDuration(self, t)
--		return ([[Poison your foe with the essence of your curse inflicting %d%% damage and %d (at 0 Hate) to %d (at 100+ Hate) poison damage over %d turns. Healing is also reduced by %d%% (at 0 Hate) to %d%% (at 100+ Hate).
--		Poison damage increases with the Willpower stat. Hate-based effects will improve when wielding cursed weapons.]]):tformat(damagePercent, poisonDamageMin, poisonDamageMax, duration, healFactorMin, healFactorMax)
--	end,
--}

newTalent{
	name = "Blindside",
	type = {"cursed/strife", 3},
	require = cursed_str_req3,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.max(6, 13 - math.floor(self:getTalentLevel(t))) end,
	hate = 4,
	range = 6,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 0.5 } },
	requires_target = true,
	is_melee = true,
	is_teleport = true,
	target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
	getDefenseChange = function(self, t)
		return self:combatTalentStatDamage(t, "str", 20, 50)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		
		if not self:teleportRandom(x, y, 0) then game.logSeen(self, "The blindside fizzles!") return true end

		game:playSoundNear(self, "talents/teleport")
		
		-- Attack ?
		if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
			local multiplier = self:combatTalentWeaponDamage(t, 0.7, 1.9) * getHateMultiplier(self, 0.3, 1.0, false)
			
			self:attackTarget(target, nil, multiplier, true)
			local defenseChange = t.getDefenseChange(self, t)
			self:setEffect(target.EFF_BLINDSIDE_BONUS, 1, { defenseChange=defenseChange })
		end
		
		return true
	end,
	info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 0.7, 1.9)
		local defenseChange = t.getDefenseChange(self, t)
		return ([[With blinding speed, you suddenly appear next to a target up to %d spaces away and attack for %d%% (at 0 Hate) to %d%% (at 100+ Hate) damage. Your sudden appearance catches everyone off-guard, giving you %d extra Defense for 1 turn.
		The Defense boost improves with your Strength.]]):tformat(self:getTalentRange(t), multiplier * 30, multiplier * 100, defenseChange)
	end,
}

-- newTalent{
	-- name = "Assail",
	-- type = {"cursed/strife", 4},
	-- require = cursed_str_req4,
	-- points = 5,
	-- random_ego = "attack",
	-- cooldown = 20,
	-- hate = 15,
	-- tactical = { ATTACKAREA = 2 },
	-- requires_target = false,
	-- getDamagePercent = function(self, t)
		-- return 100 - (40 / self:getTalentLevel(t))
	-- end,
	-- getAttackCount = function(self, t)
		-- return 2 + math.floor(self:getTalentLevel(t) / 2)
	-- end,
	-- getConfuseDuration = function(self, t)
		-- return 2 + math.floor(self:getTalentLevel(t) / 1.5)
	-- end,
	-- getConfuseEfficiency = function(self, t)
		-- return 50 + self:getTalentLevelRaw(t) * 10
	-- end,
	-- action = function(self, t)
		-- local damagePercent = t.getDamagePercent(self, t)
		-- local attackCount = t.getAttackCount(self, t)
		-- local confuseDuration = t.getConfuseDuration(self, t)
		-- local confuseEfficiency = t.getConfuseEfficiency(self, t)

		-- local minDistance = 1
		-- local maxDistance = 4
		-- local startX, startY = self.x, self.y
		-- local positions = {}
		-- local targets = {}

		-- -- find all positions and targets in range
		-- for x = startX - maxDistance, startX + maxDistance do
			-- for y = startY - maxDistance, startY + maxDistance do
				-- if game.level.map:isBound(x, y)
						-- and core.fov.distance(startX, startY, x, y) <= maxDistance
						-- and core.fov.distance(startX, startY, x, y) >= minDistance
						-- and self:hasLOS(x, y) then
					-- if self:canMove(x, y) then positions[#positions + 1] = {x, y} end

					-- local target = game.level.map(x, y, Map.ACTOR)
					-- if target and target ~= self and self:reactionToward(target) < 0 then targets[#targets + 1] = target end
				-- end
			-- end
		-- end

		-- -- perform confusion
		-- for i = 1, #targets do
			-- self:project({type="hit",x=targets[i].x,y=targets[i].y}, targets[i].x, targets[i].y, DamageType.CONFUSION, { dur = confuseDuration, dam = confuseEfficiency })
		-- end

		-- -- perform attacks
		-- for i = 1, attackCount do
			-- if #targets == 0 then break end

			-- local target = rng.tableRemove(targets)
			-- local hit = self:attackTarget(target, nil, damagePercent / 100, true)
		-- end

		-- -- perform movements
		-- if #positions > 0 then
			-- for i = 1, 8 do
				-- local position = positions[rng.range(1, #positions)]
				-- if rng.chance(50) then
					-- game.level.map:particleEmitter(position[1], position[2], 1, "teleport_out")
				-- else
					-- game.level.map:particleEmitter(position[1], position[2], 1, "teleport_in")
				-- end
			-- end
		-- end

		-- game.level.map:particleEmitter(currentX, currentY, 1, "teleport_in")
		-- local position = positions[rng.range(1, #positions)]
		-- self:move(position[1], position[2], true)

		-- return true
	-- end,
	-- info = function(self, t)
		-- local damagePercent = t.getDamagePercent(self, t)
		-- local attackCount = t.getAttackCount(self, t)
		-- local confuseDuration = t.getConfuseDuration(self, t)
		-- local confuseEfficiency = t.getConfuseEfficiency(self, t)

		-- return ([[With unnatural speed you assail all foes in sight within a range of 4 with wild swings from your axe. You will attack up to %d different targets for %d%% damage. When the assualt finally ends all foes in range will be confused for %d turns and you will find yourself in a nearby location.]]):tformat(attackCount, damagePercent, confuseDuration)
	-- end,
-- }

-- Using shields on a class without strikes to go with the is a notable disadvantage on attacks, so were generous with the bonus here
newTalent{
	name = "Repel",
	type = {"cursed/strife", 4},
	mode = "sustained",
	require = cursed_str_req4,
	points = 5,
	cooldown = 6,
	no_energy = true,
	getChance = function(self, t)
		local chance = self:combatLimit(self:combatTalentStatDamage(t, "str", 12, 36), 50, 0, 0, 26.45, 26.45) -- Limit <50% (70% with shield)
		if self:hasShield() then
			chance = chance + 20
		end
		return chance
	end,
	preUseTalent = function(self, t)
		-- prevent AI's from activating more than 1 talent
		if self ~= game.player and (self:isTalentActive(self.T_CLEAVE) or self:isTalentActive(self.T_SURGE)) then return false end
		return true
	end,
	sustain_slots = 'cursed_combat_style',
	activate = function(self, t)
		-- Place other talents on cooldown.
		if self:knowTalent(self.T_SURGE) and not self:isTalentActive(self.T_SURGE) then
			local tSurge = self:getTalentFromId(self.T_SURGE)
			self.talents_cd[self.T_SURGE] = tSurge.cooldown
		end

		if self:knowTalent(self.T_CLEAVE) and not self:isTalentActive(self.T_CLEAVE) then
			local tCleave = self:getTalentFromId(self.T_CLEAVE)
			self.talents_cd[self.T_CLEAVE] = tCleave.cooldown
		end

		return {
			luckId = self:addTemporaryValue("inc_stats", { [Stats.STAT_LCK] = -3 })
		}
	end,
	deactivate = function(self, t, p)
		if p.luckId then self:removeTemporaryValue("inc_stats", p.luckId) end

		return true
	end,
	isRepelled = function(self, t)
		local chance = t.getChance(self, t)
		return rng.percent(chance)
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[Rather than hide from the onslaught, you face down every threat. While active you have a %d%% chance of repelling a melee attack. The recklessness of your defense brings you bad luck (Luck -3).
		Cleave, Repel and Surge cannot be active simultaneously, and activating one will place the others in cooldown.
		Repel chance increases with your Strength and by 20%% when equipped with a shield.]]):tformat(chance)
	end,
}
