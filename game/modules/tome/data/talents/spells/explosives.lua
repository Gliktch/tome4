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
	name = "Throw Bomb",
	type = {"spell/explosives", 1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 4,
	range = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 5, 9))) end,
	radius = function(self, t) return self:callTalent(self.T_EXPLOSION_EXPERT, "getRadius") end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then return end
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), talent=t}
	end,
	tactical = { ATTACKAREA = function(self, t, target)
		if self:isTalentActive(self.T_ACID_INFUSION) then return { ACID = 2 }
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then return { LIGHTNING = 2 }
		elseif self:isTalentActive(self.T_FROST_INFUSION) then return { COLD = 2 }
		elseif self:isTalentActive(self.T_FIRE_INFUSION) then return { FIRE = 2 }
		else return { PHYSICAL = 2 }
		end
	end },
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.PHYSICAL
		local particle = "ball_physical"
		if self:isTalentActive(self.T_ACID_INFUSION) then damtype = DamageType.ACID_BLIND; particle = "ball_acid"
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then damtype = DamageType.LIGHTNING_DAZE; particle = "ball_lightning_beam"
		elseif self:isTalentActive(self.T_FROST_INFUSION) then damtype = DamageType.ICE; particle = "ball_ice"
		elseif self:isTalentActive(self.T_FIRE_INFUSION) then damtype = DamageType.FIREBURN; particle = "fireflash"
		end
		inc_dam = inc_dam + (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 150, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then
			game.logPlayer(self, "You need to ready alchemist gems in your quiver.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		self:attr("no_sound", 1)
		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		self:attr("no_sound", -1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2
		local golem
		if self.alchemy_golem then
			golem = game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem or nil
		end
		local dam_done = 0

		-- Compare theorical AOE zone with actual zone and adjust damage accordingly
		if self:knowTalent(self.T_EXPLOSION_EXPERT) then
			local nb = 0
			local grids = self:project(tg, x, y, function(tx, ty) end)
			if grids then for px, ys in pairs(grids or {}) do for py, _ in pairs(ys) do nb = nb + 1 end end end
			if nb > 0 then
				dam = dam + dam * self:callTalent(self.T_EXPLOSION_EXPERT, "minmax", nb)
			end
		end

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			local target = game.level.map(tx, ty, Map.ACTOR)
			-- Protect yourself
			if tx == self.x and ty == self.y then
				d = dam * (1 - prot)
			-- Protect the golem
			elseif golem and tx == golem.x and ty == golem.y then
				d = dam * (1 - prot)
				if self:isTalentActive(self.T_FROST_INFUSION) and self:knowTalent(self.T_ICE_ARMOUR) then
					self:callTalent(self.T_ICE_ARMOUR, "applyEffect", golem)
				elseif self:isTalentActive(self.T_ACID_INFUSION) and self:knowTalent(self.T_CAUSTIC_GOLEM) then
					self:callTalent(self.T_CAUSTIC_GOLEM, "applyEffect", golem)
				elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) and self:knowTalent(self.T_DYNAMIC_RECHARGE) then
					self:callTalent(self.T_DYNAMIC_RECHARGE, "applyEffect", golem)
				end
			else -- reduced damage to friendly npcs (could make random chance like friendlyfire instead)
				if target and self:reactionToward(target) >= 0 then d = dam * (1 - prot) end
			end
			if d <= 0 then return end

--			local target = game.level.map(tx, ty, Map.ACTOR)
			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then 
			self:heal(math.min(self:getMaxLife() * ammo.alchemist_bomb.leech / 100, dam_done), ammo) 
		end

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1, DamageType.FIRE
		if ammo then dam, damtype = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, damtype, dam)
		return ([[Imbue an alchemist gem with an explosive charge of mana and throw it.
		The gem will explode for %0.1f %s damage.
		Each kind of gem will also provide a specific effect.
		The damage will improve with better gems and with your Spellpower.]]):tformat(dam, DamageType:get(damtype).name)
	end,
}

newTalent{
	name = "Alchemist Protection",
	type = {"spell/explosives", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	getResists = function(self, t) return self:combatTalentScale(t, 4, 17) end,
	passives = function(self, t, p) 
		self:talentTemporaryValue(p, "resists",{[DamageType.FIRE]=t.getResists(self, t)})
		self:talentTemporaryValue(p, "resists",{[DamageType.COLD]=t.getResists(self, t)})
		self:talentTemporaryValue(p, "resists",{[DamageType.LIGHTNING]=t.getResists(self, t)})
		self:talentTemporaryValue(p, "resists",{[DamageType.ACID]=t.getResists(self, t)})
	end,
	info = function(self, t)
		return ([[Grants %d%% protection to you, your golem and other friendly creatures against the elemental damage of your own bombs, and against external elemental damage (fire, cold, lightning and acid) by %d%%.
		At talent level 5 it also protects against all side effects of your bombs.]]):
		tformat(math.min(100, self:getTalentLevelRaw(t) * 20), t.getResists(self, t))
	end,
}

newTalent{
	name = "Explosion Expert",
	type = {"spell/explosives", 3},
	require = spells_req3,
	mode = "passive",
	points = 5,
	getRadius = function(self, t) return math.max(1, math.floor(self:combatTalentScale(t, 2, 6, 0.5, 0, 0, true))) end,
	minmax = function(self, t, grids)
		local theoretical_nb = (2 * t.getRadius(self, t) + 1)^1.94 -- Maximum grids hit vs. talent level
		if grids then
			local lostgrids = math.max(theoretical_nb - grids, 0)
			local mult = math.max(0,math.log10(lostgrids)) / (6 - math.min(self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT), 5))
			print("Adjusting explosion damage to account for ", lostgrids, " lost tiles => ", mult * 100)
			return mult
		else
			local min = 1
			local min = (math.log10(min) / (6 - math.min(self:getTalentLevelRaw(t), 5)))
			local max = theoretical_nb
			local max = (math.log10(max) / (6 - math.min(self:getTalentLevelRaw(t), 5)))
			return min, max
		end
	end,
	info = function(self, t)
		local min, max = t.minmax(self, t)
		return ([[Your alchemist bombs now affect a radius of %d around them.
		Explosion damage may increase by %d%% (if the explosion is not contained) to %d%% if the area of effect is confined.]]):
		tformat(t.getRadius(self, t), min*100, max*100) --I5
	end,
}

newTalent{
	name = "Shockwave Bomb",
	type = {"spell/explosives",4},
	require = spells_req4,
	points = 5,
	mana = 32,
	cooldown = 10,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		-- Using friendlyfire, although this could affect escorts etc.
		local friendlyfire = true
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 20
		if prot > 0 then
			friendlyfire = 100 - prot
		end
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t}
	end,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.SPELLKNOCKBACK
		local particle = "ball_physical"
		inc_dam = (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 120, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 2 then
			game.logPlayer(self, "You need to ready at least two alchemist gems in your quiver.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:removeObject(self:getInven("QUIVER"), 1)
		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2
		local golem
		if self.alchemy_golem then
			golem = game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem or nil
		end
		local dam_done = 0

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			-- Protect yourself
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			-- Protect the golem
			if golem and tx == golem.x and ty == golem.y then d = dam * (1 - prot) end
			if d == 0 then return end

			local target = game.level.map(tx, ty, Map.ACTOR)
			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then 
			self:heal(math.min(self:getMaxLife() * ammo.alchemist_bomb.leech / 100, dam_done)) 
		end

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1
		if ammo then dam = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, DamageType.PHYSICAL, dam)
		return ([[Crush together two alchemist gems, making them extremely unstable.
		You then throw them to a target area, where they explode on impact, dealing %0.2f physical damage and knocking back any creatures in the blast radius %s.
		Each kind of gem will also provide a specific effect.
		The damage will improve with better gems and with your Spellpower.]]):tformat(dam, Desc.vs"sp")
	end,
}
