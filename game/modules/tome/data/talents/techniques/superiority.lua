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
	name = "Juggernaut",
	type = {"technique/superiority", 1},
	require = techs_req_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 40,
	stamina = 50,
	no_energy = true,
	tactical = { DEFEND = 2 },
	critResist = function(self, t) return self:combatTalentScale(t, 8, 20, 0.75) end,
	getResist = function(self, t) return self:combatTalentScale(t, 15, 35) end,
	action = function(self, t)
		self:setEffect(self.EFF_JUGGERNAUT, 20, {power=t.getResist(self, t), crits=t.critResist(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Concentrate on the battle, ignoring some of the damage you take.
		Improves physical damage resistance by %d%% and reduces the bonus damage multiplier of incoming critical hits by %d%% for 20 turns.]]):
		tformat(t.getResist(self,t), t.critResist(self, t))
	end,
}

newTalent{
	name = "Onslaught",
	type = {"technique/superiority", 2},
	require = techs_req_high2,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	no_energy = true,
	sustain_stamina = 10,
	tactical = { BUFF = 2 },
	range = function(self,t) return math.floor(self:combatTalentLimit(t, 10, 1, 5)) end, -- Limit KB range to <10
	activate = function(self, t)
		return {
			stamina = self:addTemporaryValue("stamina_regen", -1),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		-- Onslaught
		if hitted then
			local dir = util.getDir(target.x, target.y, self.x, self.y) or 6
			local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
			local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
			local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)
			local range = self:getTalentRange(t)

			if target:checkHit(self:combatAttack(weapon), target:combatPhysicalResist(), 0, 95, 10) and target:canBe("knockback") then
				target:knockback(self.x, self.y, range)
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatAttack())
			end
			if lt and lt:checkHit(self:combatAttack(weapon), lt:combatPhysicalResist(), 0, 95, 10) and lt:canBe("knockback") then
				lt:knockback(self.x, self.y, range)
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatAttack())
			end
			if rt and rt:checkHit(self:combatAttack(weapon), rt:combatPhysicalResist(), 0, 95, 10) and rt:canBe("knockback") then
				rt:knockback(self.x, self.y, range)
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatAttack())
			end
		end
	end,
	info = function(self, t)
		return ([[Take an offensive stance. As you attack your foes, you knock %s your target and foes adjacent to them in a frontal arc back (up to %d grids).
		This consumes stamina rapidly (-1 stamina/turn).]]):
		tformat(Desc.vs"ap", t.range(self, t))
	end,
}

newTalent{
	name = "Battle Call",
	type = {"technique/superiority", 3},
	require = techs_req_high3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { CLOSEIN = 2 },
	range = 0,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 7))
	end,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if tx and ty and target:canBe("teleport") then
				target:move(tx, ty, true)
				game.logSeen(target, "%s is called to battle!", target:getName():capitalize())
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Call all foes in a radius of %d around you into battle, getting them into melee range in an instant %s.]]):tformat(t.radius(self,t), Desc.vs())
	end,
}

newTalent{
	name = "Shattering Impact",
	type = {"technique/superiority", 4},
	require = techs_req_high4,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	tactical = { BUFF = 2 },
	weaponDam = function(self, t) return (self:combatTalentLimit(t, 1, 0.38, 0.6)) end, -- Limit < 100% weapon damage
	callbackOnMeleeProject = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		-- Shattering Impact
		if hitted and (not self.shattering_impact_last_turn or self.shattering_impact_last_turn < game.turn) then
			local dam = dam * t.weaponDam(self, t)
			game.logSeen(target, "The shattering blow creates a shockwave!")
			self:project({type="ball", radius=1, selffire=false, act_exclude={[target.uid]=true}}, target.x, target.y, DamageType.PHYSICAL, dam)  -- don't hit target with the AOE
			self:incStamina(-8)
			self.shattering_impact_last_turn = game.turn
		end
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Put all of your strength into your weapon blows, creating shockwaves that deal %d%% Physical weapon damage to all nearby targets.  Only one shockwave will be created per action, and the primary target does not take extra damage.
		Each shattering impact will drain 8 stamina.]]):
		tformat(100*t.weaponDam(self, t))
	end,
}
