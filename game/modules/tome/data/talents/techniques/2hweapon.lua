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
	name = "Death Dance",
	type = {"technique/2hweapon-offense", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { ATTACKAREA = { weapon = 3 } },
	range = 0,
	radius = 1,
	requires_target = true,
	is_melee = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Death Dance without a two-handed weapon!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.4, 2.1))
			end
		end)

		self:addParticles(Particles.new("meleestorm", 1, {}))

		return true
	end,
	info = function(self, t)
		return ([[Spin around, extending your weapon and damaging all targets around you for %d%% weapon damage.]]):tformat(100 * self:combatTalentWeaponDamage(t, 1.4, 2.1))
	end,
}

newTalent{
	name = "Berserker",
	type = {"technique/2hweapon-offense", 2},
	require = techs_req2,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getDam = function(self, t) return self:combatScale(self:getStr(7, true) * self:getTalentLevel(t), 5, 0, 40, 35)end,
	getAtk = function(self, t) return self:combatScale(self:getDex(7, true) * self:getTalentLevel(t), 5, 0, 40, 35) end ,
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.22, 0.5) end,
	activate = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Berserker without a two-handed weapon!")
			return nil
		end

		return {
			armor = self:addTemporaryValue("combat_armor", -10),
			stun = self:addTemporaryValue("stun_immune", t.getImmune(self, t)),
			pin = self:addTemporaryValue("pin_immune", t.getImmune(self, t)),
			dam = self:addTemporaryValue("combat_dam", t.getDam(self, t)),
			atk = self:addTemporaryValue("combat_atk", t.getAtk(self, t)),
			def = self:addTemporaryValue("combat_def", -10),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("pin_immune", p.pin)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[You enter an aggressive battle stance, increasing Accuracy by %d and Physical Power by %d, at the cost of -10 Defense and -10 Armour.
		While berserking, you are nearly unstoppable, granting you %d%% stun and pinning resistance.
		The Accuracy bonus increases with your Dexterity, and the Physical Power bonus with your Strength.]]):
		tformat( t.getAtk(self, t), t.getDam(self, t), t.getImmune(self, t)*100)
	end,
}

newTalent{
	name = "Warshout",
	type = {"technique/2hweapon-offense",3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	message = function(self) if self.subtype == "rodent" then return _t"@Source@ uses Warsqueak." else return _t"@Source@ uses Warshout." end end ,
	stamina = 30,
	cooldown = 18,
	tactical = { ATTACKAREA = { confusion = 1 }, DISABLE = { confusion = 3 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getConfusion = function(self, t) return self:combatTalentLimit(t, 50, 15, 45) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Warshout without a two-handed weapon!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CONFUSION, {
			dur=t.getDuration(self, t),
			dam=t.getConfusion(self, t),
			power_check=function() return self:combatPhysicalpower() end,
			resist_check=self.combatPhysicalResist,
		})
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=8, size=3, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.4, gM=0.6, bm=0.1, bM=0.2, am=1, aM=1})
		return true
	end,
	info = function(self, t)
		return ([[Shout your warcry in a frontal cone of radius %d. Any targets caught inside will be confused (power %d%%) for %d turns %s.]]):
		tformat(self:getTalentRadius(t),t.getConfusion(self, t), t.getDuration(self, t), Desc.vs"pm")
	end,
}

newTalent{
	name = "Death Blow",
	type = {"technique/2hweapon-offense", 4},
	require = techs_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 } },
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Death Blow without a two-handed weapon!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local inc = self.stamina / 2
		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam + inc
		end
		self.turn_procs.auto_phys_crit = true
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3))

		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam - inc
			self:incStamina(-self.stamina / 2)
		end
		self.turn_procs.auto_phys_crit = nil

		-- Try to insta-kill
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("instakill") and target:getLife() > target:getMinLife() and target:getLife() < target:getMaxLife() * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s feels the pain of the death blow!", target:getName():capitalize())
				target:die(self)
			elseif target:getLife() > target:getMinLife() and target:getLife() < target:getMaxLife() * 0.2 then
				game.logSeen(target, "%s resists the death blow!", target:getName():capitalize())
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Tries to perform a killing blow, doing %d%% weapon damage and dealing an automatic critical hit. If the target ends up with low enough life (<20%%), it might be instantly killed %s.
		At level 4, it drains half your remaining stamina, and uses it to increase the blow damage by 100%% of it.]]):tformat(100 * self:combatTalentWeaponDamage(t, 0.8, 1.3), Desc.vs"pp")
	end,
}

-----------------------------------------------------------------------------
-- Cripple
-----------------------------------------------------------------------------
newTalent{
	name = "Stunning Blow",
	type = {"technique/2hweapon-cripple", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 8,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Stunning Blow without a two-handed weapon!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s resists the stunning blow!", target:getName():capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon, doing %d%% damage. If the attack hits, the target is stunned for %d turns. %s]])
		:tformat(100 * self:combatTalentWeaponDamage(t, 1, 1.5), t.getDuration(self, t), Desc.vs"pp")
	end,
}

newTalent{
	name = "Sunder Armour",
	type = {"technique/2hweapon-cripple", 2},
	require = techs_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 12,
	requires_target = true,
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getShatter = function(self, t) return self:combatTalentLimit(t, 100, 10, 85) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	getArmorReduc = function(self, t) return self:combatTalentScale(t, 5, 25, 0.75) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Sunder Armour without a two-handed weapon!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to Sunder !
		if hit then
			target:setEffect(target.EFF_SUNDER_ARMOUR, t.getDuration(self, t), {power=t.getArmorReduc(self,t), apply_power=self:combatPhysicalpower()})

			if rng.percent(t.getShatter(self, t)) then
				local effs = {}

				-- Go through all shield effects
				for eff_id, p in pairs(target.tmp) do
					local e = target.tempeffect_def[eff_id]
					if e.status == "beneficial" and e.subtype and e.subtype.shield then
						effs[#effs+1] = {"effect", eff_id}
					end
				end

				for i = 1, 1 do
					if #effs == 0 then break end
					local eff = rng.tableRemove(effs)

					if eff[1] == "effect" then
						game.logSeen(self, "#CRIMSON#%s shatters %s shield!", self:getName():capitalize(), target:getName())
						target:removeEffect(eff[2])
					end
				end
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon, doing %d%% damage. If the attack hits, the target's armour and saves are reduced by %d for %d turns %s.
		Also if the target is protected by any temporary magical or psionic damage absorbing shields there is %d%% chance to shatter one random shield.]])
		:tformat(100 * self:combatTalentWeaponDamage(t, 1, 1.5),t.getArmorReduc(self, t), t.getDuration(self, t), Desc.vs"pp", t.getShatter(self, t))
	end,
}

newTalent{
	name = "Sunder Arms",
	type = {"technique/2hweapon-cripple", 3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 12,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	range = 1,
	is_melee = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Sunder Arms without a two-handed weapon!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to Sunder !
		if hit then
			target:setEffect(target.EFF_SUNDER_ARMS, t.getDuration(self, t), {power=3*self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon, doing %d%% damage. If the attack hits, the target's Accuracy is reduced by %d for %d turns %s.]])
		:tformat(
			100 * self:combatTalentWeaponDamage(t, 1, 1.5), 3 * self:getTalentLevel(t), t.getDuration(self, t), Desc.vs"pp")
	end,
}

newTalent{
	name = "Blood Frenzy",
	type = {"technique/2hweapon-cripple", 4},
	require = techs_req4,
	points = 5,
	mode = "sustained",
	cooldown = 15,
	sustain_stamina = 70,
	no_energy = true,
	tactical = { BUFF = 1 },
	callbackOnActBase = function(self, t)
		if self.blood_frenzy > 0 then
			self.blood_frenzy = math.max(self.blood_frenzy - 2, 0)
		end
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	bonuspower = function(self,t) return self:combatTalentScale(t, 2, 10, 0.5, 0, 2) end, -- called by _M:die function in mod.class.Actor.lua
	activate = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Blood Frenzy without a two-handed weapon!")
			return nil
		end
		self.blood_frenzy = 0
		return {
			regen = self:addTemporaryValue("stamina_regen", -2),
		}
	end,
	deactivate = function(self, t, p)
		self.blood_frenzy = nil
		self:removeTemporaryValue("stamina_regen", p.regen)
		return true
	end,
	info = function(self, t)
		return ([[Enter a blood frenzy, draining stamina quickly (-2 stamina/turn). Each time you kill a foe while in the blood frenzy, you gain a cumulative bonus to Physical Power of %d.
		Each turn, this bonus decreases by 2.]]):
		tformat(t.bonuspower(self,t))
	end,
}
