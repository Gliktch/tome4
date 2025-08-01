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
	name = "Lightning",
	type = {"spell/air", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 3,
	tactical = { ATTACK = {LIGHTNING = 2} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		if thaumaturgyCheck(self) then return {type="widebeam", radius=1, range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=self:spellFriendlyFire()} end
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	allow_for_arcane_combat = true,
	is_beam_spell = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 350) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = thaumaturgyBeamDamage(self, self:spellCrit(t.getDamage(self, t)))
		self:project(tg, x, y, DamageType.LIGHTNING_DAZE, {dam=rng.avg(dam / 3, dam, 3), daze=self:attr("lightning_daze_tempest") or 0, power_check=self:combatSpellpower()})
		local _ _, x, y = self:canProject(tg, x, y)

		if thaumaturgyCheck(self) then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning_beam_wide", {tx=x-self.x, ty=y-self.y}, core.shader.active() and {type="lightning"} or nil)
		else
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning_beam", {tx=x-self.x, ty=y-self.y}, core.shader.active() and {type="lightning"} or nil)
		end

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Conjures up mana into a powerful beam of lightning, doing %0.2f to %0.2f damage (%0.2f average)
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.LIGHTNING, damage / 3),
		damDesc(self, DamageType.LIGHTNING, damage),
		damDesc(self, DamageType.LIGHTNING, (damage + damage / 3) / 2))

	end,
}

newTalent{
	name = "Chain Lightning",
	type = {"spell/air", 2},
	require = spells_req2,
	points = 5,
	mana = 20,
	cooldown = 8,
	tactical = { ATTACKAREA = {LIGHTNING = 2} }, --note: only considers the primary target
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 330) end,
	getTargetCount = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8, "log")) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local fx, fy = self:getTarget(tg)
		if not fx or not fy then return nil end

		local nb = t.getTargetCount(self, t)
		local affected = {}
		local first = nil

		self:project(tg, fx, fy, function(dx, dy)
			print("[Chain lightning] targetting", fx, fy, "from", self.x, self.y)
			local actor = game.level.map(dx, dy, Map.ACTOR)
			if actor and not affected[actor] then
				affected[actor] = true
				first = actor

				print("[Chain lightning] looking for more targets", nb, " at ", dx, dy, "radius ", 10, "from", actor.name)
				self:project({type="ball", selffire=false, x=dx, y=dy, radius=10, range=0}, dx, dy, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
						affected[actor] = true
					end
				end)
				return true
			end
		end)

		if not first then return end
		local targets = { first }
		affected[first] = nil
		local possible_targets = table.listify(affected)
		print("[Chain lightning] Found targets:", #possible_targets)
		for i = 2, nb do
			if #possible_targets == 0 then break end
			local act = rng.tableRemove(possible_targets)
			targets[#targets+1] = act[1]
		end

		local sx, sy = self.x, self.y
		for i, actor in ipairs(targets) do
			local tgr = {type="beam", range=self:getTalentRange(t), selffire=false, talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			local dam = self:spellCrit(t.getDamage(self, t))
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING_DAZE, {dam=rng.avg(rng.avg(dam / 3, dam, 3), dam, 5), daze=self:attr("lightning_daze_tempest") or 0, power_check=self:combatSpellpower()})
			if core.shader.active() then game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy}, {type="lightning"})
			else game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy})
			end

			sx, sy = actor.x, actor.y
		end

		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local targets = t.getTargetCount(self, t)
		return ([[Invokes an arc of lightning doing %0.2f to %0.2f damage (%0.2f average) and chaining to another target.
		The arc can jump to %d targets at most, up to 10 grids apart, and will never jump to the same target twice, or to the caster. The arc will also strike all creatures between each target.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.LIGHTNING, damage / 3),
			damDesc(self, DamageType.LIGHTNING, damage),
			damDesc(self, DamageType.LIGHTNING, (damage + damage / 3) / 2),
			targets)
	end,
}

newTalent{
	name = "Feather Wind",
	type = {"spell/air",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 10,
	tactical = { BUFF = 2 },
	getEncumberance = function(self, t) return math.floor(self:combatTalentSpellDamage(t, 10, 110)) end,
	getRangedDefence = function(self, t) return self:combatTalentSpellDamage(t, 4, 30) end,
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.05, 0.25, 0.75) end,
	getPinImmune = function(self, t) return math.min(1, self:combatTalentScale(t, 0.1, 0.90, 0.5)) end,
	getStunImmune = function(self, t) return math.min(1, self:combatTalentScale(t, 0.05, 0.45, 0.5)) end,
	getFatigue = function(self, t) return math.floor(2.5 * self:getTalentLevel(t)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {}

		self:talentTemporaryValue(ret, "max_encumber", t.getEncumberance(self, t))
		self:talentTemporaryValue(ret, "combat_def_ranged", t.getRangedDefence(self, t))
		self:talentTemporaryValue(ret, "pin_immune", t.getPinImmune(self, t))
		self:talentTemporaryValue(ret, "stun_immune", t.getStunImmune(self, t))
		
		if self:getTalentLevel(t) >= 4 then
			self:talentTemporaryValue(ret, "levitation", 1)
			self:talentTemporaryValue(ret, "avoid_pressure_traps", 1)
		end
		if self:getTalentLevel(t) >= 5 then
			self:talentTemporaryValue(ret, "movement_speed", t.getSpeed(self, t))
			self:talentTemporaryValue(ret, "fatigue", -t.getFatigue(self, t))
		end

		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:checkEncumbrance()
		return true
	end,
	info = function(self, t)
		local encumberance = t.getEncumberance(self, t)
		local rangedef = t.getRangedDefence(self, t)
		local stun = t.getStunImmune(self, t)
		local pin = t.getPinImmune(self, t)
		return ([[A gentle wind circles around the caster, increasing carrying capacity by %d, defense against projectiles by %d, pin immunity by %d%% and stun immunity by %d%%.
		At level 4 it also makes you levitate slightly above the ground, allowing you to ignore some traps.
		At level 5 it also grants %d%% movement speed and removes %d fatigue.]]):
		tformat(encumberance, rangedef, pin*100, stun*100, t.getSpeed(self, t) * 100, t.getFatigue(self, t))
	end,
}

newTalent{
	name = "Thunderstorm",
	type = {"spell/air", 4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 15,
	tactical = { ATTACKAREA = {LIGHTNING = 2} },
	range = 6,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	getTargetCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	callbackOnActBase = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", radius=1, range=self:getTalentRange(t), talent=t, friendlyfire=false}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.LIGHTNING_DAZE, {dam=rng.avg(1, self:spellCrit(t.getDamage(self, t)), 3), daze=(self:attr("lightning_daze_tempest") or 0) / 2, power_check=self:combatSpellpower()})
			if core.shader.active() then game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning_beam", {radius=tg.radius, tx=x, ty=y}, {type="lightning"})
			else game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning_beam", {radius=tg.radius, tx=x, ty=y}) end
		end
		game:playSoundNear(self, "talents/lightning")
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
		game.logSeen(self, "#0080FF#A furious lightning storm forms around %s!", self:getName())
		self:callTalent(self.T_ENERGY_ALTERATION, "forceActivate", DamageType.LIGHTNING)
		return {
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#0080FF#The furious lightning storm around %s calms down and disappears.", self:getName())
		return true
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local damage = t.getDamage(self, t)
		return ([[Conjures a furious, raging lightning storm with a radius of %d that follows you as long as this spell is active.
		Each turn, a random lightning bolt will hit up to %d of your foes for 1.00 to %0.2f damage (%0.2f average) in a radius of 1.
		The damage will increase with your Spellpower.]]):
		tformat(self:getTalentRange(t), targetcount, damDesc(self, DamageType.LIGHTNING, damage), damDesc(self, DamageType.LIGHTNING, damage / 2))
	end,
}
