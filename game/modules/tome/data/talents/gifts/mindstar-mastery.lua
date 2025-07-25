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

function get_mindstar_power_mult(self, div)
	local main, off = self:hasPsiblades(true, true)
	if not main or not off then return 1 end

	local mult = 1 + (main.combat.dam + off.combat.dam) * 0.8 / (div or 40)
	return mult
end

newTalent{
	name = "Psiblades",
	type = {"wild-gift/mindstar-mastery", 1},
	require = gifts_req1,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 18,
	cooldown = 10,
	tactical = { BUFF = 4 },
	getPowermult = function(self,t,level) return 1.076 + 0.324*(level or self:getTalentLevel(t))^.5 end,
	getStatmult = function(self,t,level) return 1.076 + 0.324*(level or self:getTalentLevel(t))^.5 end,
	getAPRmult = function(self,t,level) return 0.65 + 0.51*(level or self:getTalentLevel(t))^.5 end,
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	activate = function(self, t)
		local r = {
			tmpid = self:addTemporaryValue("psiblades_active", self:getTalentLevel(t)),
		}

		self:attr("on_wear_simple_reload", 1)
		for i, o in ipairs(self:getInven("MAINHAND") or {}) do self:onTakeoff(o, self.INVEN_MAINHAND, true) self:onWear(o, self.INVEN_MAINHAND, true) end
		for i, o in ipairs(self:getInven("OFFHAND") or {}) do self:onTakeoff(o, self.INVEN_OFFHAND, true) self:onWear(o, self.INVEN_OFFHAND, true) end
		for i, o in ipairs(self:getInven("PSIONIC_FOCUS") or {}) do self:onTakeoff(o, self.INVEN_PSIONIC_FOCUS, true) self:onWear(o, self.INVEN_PSIONIC_FOCUS, true) end
		self:attr("on_wear_simple_reload", -1)
		self:updateModdableTile()

		return r
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("psiblades_active", p.tmpid)

		self:attr("on_wear_simple_reload", 1)
		for i, o in ipairs(self:getInven("MAINHAND") or {}) do self:onTakeoff(o, self.INVEN_MAINHAND, true) self:checkMindstar(o) self:onWear(o, self.INVEN_MAINHAND, true) end
		for i, o in ipairs(self:getInven("OFFHAND") or {}) do self:onTakeoff(o, self.INVEN_OFFHAND, true) self:checkMindstar(o) self:onWear(o, self.INVEN_OFFHAND, true) end
		for i, o in ipairs(self:getInven("PSIONIC_FOCUS") or {}) do self:onTakeoff(o, self.INVEN_PSIONIC_FOCUS, true) self:checkMindstar(o) self:onWear(o, self.INVEN_PSIONIC_FOCUS, true) end
		self:attr("on_wear_simple_reload", -1)
		self:updateModdableTile()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Channel your mental power through your wielded mindstars, generating psionic blades.
		Mindstar psiblades have their damage modifiers (how much damage they gain from stats) multiplied by %0.2f, their armour penetration by %0.2f and mindpower, willpower and cunning by %0.2f.
		Also passively increases weapon damage by %d%% and physical power by 30 when using mindstars.]]):
		tformat(t.getStatmult(self, t), t.getAPRmult(self, t), t.getPowermult(self, t), 100 * inc) --I5
	end,
}

newTalent{
	name = "Thorn Grab",
	type = {"wild-gift/mindstar-mastery", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 7,
	cooldown = 15,
	no_energy = true,
	range = 1,
	is_melee = true,
	tactical = { ATTACK = 2, DISABLE = 2 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	on_pre_use = function(self, t, silent) if not self:hasPsiblades(true, false) then if not silent then game.logPlayer(self, "You require a psiblade in your mainhand to use this talent.") end return false end return true end,
	speedPenalty = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.45) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		target:setEffect(target.EFF_THORN_GRAB, 10, {src=self, speed = t.speedPenalty(self, t), dam=self:mindCrit(self:combatTalentMindDamage(t, 15, 250) / 10 * get_mindstar_power_mult(self))})
		game.level.map:particleEmitter(x, y, 1, "thorn_grab", {})
		return true
	end,
	info = function(self, t)
		return ([[You touch the target with your psiblade, bringing the forces of nature to bear on your foe.
		Thorny vines will grab the target, slowing it by %d%% and dealing %0.2f nature damage each turn for 10 turns.
		Damage will increase with your Mindpower and Mindstar power (requires two mindstars, multiplier %2.f).]]):
		tformat(100*t.speedPenalty(self,t), damDesc(self, DamageType.NATURE, self:combatTalentMindDamage(t, 15, 250) / 10 * get_mindstar_power_mult(self)), get_mindstar_power_mult(self))
	end,
}

newTalent{
	name = "Leaves Tide",
	type = {"wild-gift/mindstar-mastery", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 20,
	cooldown = 25,
	tactical = {
		ATTACK = {PHYSICAL = function(self, t, target) return self:reactionToward(target) < 0 and {cut=2} or 0 end
		}, -- add for each foe affected
		DEFEND = {special = function(self, t, target) return self:reactionToward(target) >= 0 and 3 or 0 end} -- add for each ally affected
	},
	target = {type="ball", radius=3, friendlyblock=false}, -- used by the AI to determine actors affected
	getDamage = function(self, t) return 5 + self:combatTalentMindDamage(t, 5, 35) * get_mindstar_power_mult(self) end,
	getChance = function(self, t) return util.bound(10 + self:combatTalentMindDamage(t, 3, 25), 10, 40) * get_mindstar_power_mult(self, 90) end,
	on_pre_use = function(self, t, silent) if not self:hasPsiblades(true, true) and not self:attr("leaves_tide_no_mindstar") then if not silent then game.logPlayer(self, "You require two psiblades in your hands to use this talent.") end return false end return true end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, 7,
			DamageType.LEAVES, {dam=self:mindCrit(t.getDamage(self, t)), chance=t.getChance(self, t)},
			3,
			5, nil,
			{type="leavestide", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			true
		)
		game:playSoundNear(self, "talents/icestorm")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local c = t.getChance(self, t)
		return ([[Smash your psiblades into the ground, creating a tide of crystallized leaves circling you in a radius of 3 for 7 turns.
		All foes hit by the leaves will start bleeding for %0.2f per turn (cumulative).
		All allies hit will be covered in leaves, granting them %d%% chance to completely avoid any damaging attack.
		Damage and avoidance will increase with your Mindpower and Mindstar power (requires two mindstars, multiplier %0.2f).]]):
		tformat(dam, c, get_mindstar_power_mult(self))
	end,
}

newTalent{
	name = "Nature's Equilibrium",
	type = {"wild-gift/mindstar-mastery", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 15,
	range = 1,
	tactical = { ATTACK = 1, HEAL = 1, EQUILIBRIUM = 1 },
	direct_hit = true,
	requires_target = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	second_target = function(self, t) return {default_target=self, type="hit", nowarning=true, range=1, first_target="friend"} end,
	on_pre_use = function(self, t, silent) if not self:hasPsiblades(true, true) then if not silent then game.logPlayer(self, "You require two psiblades in your hands to use this talent.") end return false end return true end,
	getMaxDamage = function(self, t) return 50 + self:combatTalentMindDamage(t, 5, 250) * get_mindstar_power_mult(self) end,
	action = function(self, t)
		local main, off = self:hasPsiblades(true, true)

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local ol = target.life
		local speed, hit = self:attackTargetWith(target, main.combat, nil, self:combatTalentWeaponDamage(t, 2.5, 4))
		local dam = util.bound(ol - target.life, 0, t.getMaxDamage(self, t))

		while hit do -- breakable if
			local tg = util.getval(t.second_target, self, t)
			local x, y, target = self:getTarget(tg)
			if not target then target = self end

			target:attr("allow_on_heal", 1)
			target:heal(dam, t)
			target:attr("allow_on_heal", -1)
			target:incEquilibrium(-dam / 10)
			if core.shader.active(4) then
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
			end
			break
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[You hit a foe with your mainhand psiblade doing %d%% weapon damage, channeling all the damage done through your offhand psiblade with which you touch a friendly creature to heal it.
		The maximum heal possible is %d. Equilibrium of the healed target will also decrease by 10%% of the heal power.
		Max heal will increase with your Mindpower and Mindstar power (requires two mindstars, multiplier %2.f).]]):
		tformat(self:combatTalentWeaponDamage(t, 2.5, 4) * 100, t.getMaxDamage(self, t), get_mindstar_power_mult(self))
	end,
}
