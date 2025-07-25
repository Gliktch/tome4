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

local DamageType = require "engine.DamageType"

newTalent{
	name = "Channel Staff",
	type = {"spell/staff-combat", 1},
	require = spells_req1,
	points = 5,
	mana = 5,
	tactical = { ATTACK = 1 },
	range = 8,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display = {particle=particle, trail=trail}, friendlyfire=false,
			friendlyblock=false,
		}
	end,
	on_pre_use = function(self, t, silent) if not self:hasStaffWeapon() then if not silent then game.logPlayer(self, "You need a staff to use this spell.") end return false end return true end,
	getDamageMod = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.1) end,
	action = function(self, t)
		local weapon = self:hasStaffWeapon()
		if not weapon then
			game.logPlayer(self, "You need a staff to use this spell.")
			return
		end
		local combat = weapon.combat

		local trail = "firetrail"
		local particle = "bolt_fire"
		local explosion = "flame"

		local damtype = combat.element or combat.damtype or DamageType.ARCANE

		if     damtype == DamageType.FIRE then      explosion = "flame"               particle = "bolt_fire"      trail = "firetrail"
		elseif damtype == DamageType.COLD then      explosion = "freeze"              particle = "ice_shards"     trail = "icetrail"
		elseif damtype == DamageType.ACID then      explosion = "acid"                particle = "bolt_acid"      trail = "acidtrail"
		elseif damtype == DamageType.LIGHTNING then explosion = "lightning_explosion" particle = "bolt_lightning" trail = "lightningtrail"
		elseif damtype == DamageType.LIGHT then     explosion = "light"               particle = "bolt_light"     trail = "lighttrail"
		elseif damtype == DamageType.DARKNESS then  explosion = "dark"                particle = "bolt_dark"      trail = "darktrail"
		elseif damtype == DamageType.NATURE then    explosion = "slime"               particle = "bolt_slime"     trail = "slimetrail"
		elseif damtype == DamageType.BLIGHT then    explosion = "slime"               particle = "bolt_slime"     trail = "slimetrail"
		elseif damtype == DamageType.PHYSICAL then  explosion = "dark"                particle = "stone_shards"   trail = "earthtrail"
		elseif damtype == DamageType.TEMPORAL then  explosion = "light"				  particle = "temporal_bolt"  trail = "lighttrail"
		else                                        explosion = "manathrust"          particle = "bolt_arcane"    trail = "arcanetrail" --damtype = DamageType.ARCANE
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- Compute damage
		local dam = self:combatDamage(combat, {mag=0.2})
		local damrange = self:combatDamageRange(combat)
		dam = rng.range(dam, dam * damrange)
		dam = self:spellCrit(dam)
		dam = dam * t.getDamageMod(self, t)

		self:projectile(tg, x, y, damtype, dam, {type=explosion})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damagemod = t.getDamageMod(self, t)
		return ([[Channel raw mana through your staff, projecting a bolt of your staff's damage type, doing %d%% staff damage.
		The bolt will only hurt hostile targets, and pass safely through friendly ones.
		This attack always has a 100%% chance to hit, and ignores the target's Armour.
		When projecting a bolt with your staff its damage modifier is increased by 20%%.]]):
		tformat(damagemod * 100)
	end,
}

newTalent{
	name = "Staff Mastery",
	type = {"spell/staff-combat", 2},
	mode = "passive",
	require = spells_req2,
	points = 5,
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases weapon damage by %d%% and physical power by 30 when using staves.]]):
		tformat(100 * inc)
	end,
}

newTalent{
	name = "Defensive Posture",
	type = {"spell/staff-combat", 3},
	require = spells_req3,
	mode = "sustained",
	points = 5,
	sustain_mana = 20,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getDefense = function(self, t) return self:combatTalentSpellDamage(t, 10, 20) end,
	on_pre_use = function(self, t, silent) if not self:hasStaffWeapon() then if not silent then game.logPlayer(self, "You need a staff to use this spell.") end return false end return true end,
	activate = function(self, t)

		local power = t.getDefense(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			arm = self:addTemporaryValue("combat_armor", power),
			def = self:addTemporaryValue("combat_def", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_armor", p.arm)
		self:removeTemporaryValue("combat_def", p.def)
		return true
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		return ([[Adopt a defensive posture, increasing your Defense and Armour by %d.]]):
		tformat(defense)
	end,
}

newTalent{
	name = "Blunt Thrust",
	type = {"spell/staff-combat",4},
	require = spells_req4,
	points = 5,
	mana = 12,
	cooldown = 12,
	tactical = { ATTACK = 1, DISABLE = 2, ESCAPE = 1 },
	range = 1,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasStaffWeapon() then if not silent then game.logPlayer(self, "You need a staff to use this spell.") end return false end return true end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	is_melee = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDazeDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local weapon = self:hasStaffWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Blunt Thrust without a staff weapon!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		if self:getTalentLevel(t) >= 5 then self.turn_procs.auto_melee_hit = true end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, t.getDamage(self, t))
		if self:getTalentLevel(t) >= 5 then self.turn_procs.auto_melee_hit = nil end

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDazeDuration(self, t), {apply_power=self:combatSpellpower()})
			else
				game.logSeen(target, "%s resists the stunning blow!", target:getName():capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local dazedur = t.getDazeDuration(self, t)
		return ([[Hit a target for %d%% melee damage and stun it for %d turns %s.
		At level 5, this attack cannot miss.]]):
		tformat(100 * damage, dazedur, Desc.vs"sp")
	end,
}
