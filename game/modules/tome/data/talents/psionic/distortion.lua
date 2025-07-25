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

local Object = require "mod.class.Object"

function DistortionCount(self)
	local distortion_count = 0
	
	for tid, lev in pairs(self.talents) do
		local t = game.player:getTalentFromId(tid)
		if t.type[1]:find("^psionic/") and t.type[1]:find("^psionic/distortion") then
			distortion_count = distortion_count + lev
		end
	end
	distortion_count = mod.class.interface.Combat:combatScale(distortion_count, 0, 0, 20, 20, 0.75)
	print("Distortion Count", distortion_count)
	return distortion_count
end

newTalent{
	name = "Distortion Bolt",
	type = {"psionic/distortion", 1},
	points = 5, 
	require = psi_wil_req1,
	cooldown = 3,
	psi = 5,
	tactical = { ATTACKAREA = { PHYSICAL = 2} },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 2.7)) end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	target = function(self, t)
		local friendlyfire = true
		if self:getTalentLevel(self.T_DISTORTION_BOLT) >= 5 then
			friendlyfire = false
		end
		return {type="ball", radius=self:getTalentRadius(t), friendlyfire=friendlyfire, range=self:getTalentRange(t), talent=t, display={trail="distortion_trail"}}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local damage = self:mindCrit(t.getDamage(self, t))
		tg.type = "bolt" -- switch our targeting to a bolt for the initial projectile
		self:projectile(tg, x, y, DamageType.DISTORTION, {dam=damage,  penetrate=true, explosion=damage*1.5, friendlyfire=tg.friendlyfire, distort=DistortionCount(self), radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/distortion")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local distort = DistortionCount(self)
		return ([[Fire a bolt of distortion that ignores resistance and inflicts %0.2f physical damage.  This damage will distort affected targets %s, decreasing physical resistance by %d%% and rendering them vulnerable to distortion effects for two turns.
		If the bolt comes in contact with a target that's already distorted, a detonation will occur, inflicting 150%% of the base damage in a radius of %d.
		Investing in this talent will increase the physical resistance reduction from all of your distortion effects.
		At talent level 5, you learn to shape your distortion effects, preventing them from hitting you or your allies.
		The damage will scale with your Mindpower.]]):tformat(damDesc(self, DamageType.PHYSICAL, damage), Desc.vs(), distort, radius)
	end,
}

newTalent{
	name = "Distortion Wave",
	type = {"psionic/distortion", 2},
	points = 5, 
	require = psi_wil_req2,
	cooldown = 6,
	psi = 10,
	tactical = { ATTACKAREA = { PHYSICAL = 2}, ESCAPE = 2,
		DISABLE = function(self, t, target) if target and target:hasEffect(target.EFF_DISTORTION) then return 2 else return 0 end end,
	},
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	getPower = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end, -- stun duration
	target = function(self, t)
		local friendlyfire = true
		if self:getTalentLevel(self.T_DISTORTION_BOLT) >=5 then
			friendlyfire = false
		end
		return { type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t }
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DISTORTION, {dam=self:mindCrit(t.getDamage(self, t)), knockback=t.getPower(self, t), stun=t.getPower(self, t), distort=DistortionCount(self)})
		game:playSoundNear(self, "talents/warp")
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y, allow=core.shader.allow("distort")})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local power = t.getPower(self, t)
		local distort = DistortionCount(self)
		return ([[Creates a distortion wave in a radius %d cone that deals %0.2f physical damage and knocks back targets in the blast radius %s.
		This damage will distort affected targets %s, decreasing physical resistance by %d%% and rendering them vulnerable to distortion effects for two turns.
		Investing in this talent will increase the physical resistance reduction from all of your distortion effects.
		If the target is already distorted, they'll be stunned for %d turns as well %s.
		The damage will scale with your Mindpower.]]):tformat(radius, damDesc(self, DamageType.PHYSICAL, damage), Desc.vs"mp", Desc.vs(), distort, power, Desc.vs"mp")
	end,
}

newTalent{
	name = "Ravage",
	type = {"psionic/distortion", 3},
	points = 5, 
	require = psi_wil_req3,
	cooldown = 12,
	psi = 20,
	tactical = { ATTACK = { PHYSICAL = 2},
		DISABLE = function(self, t, target) if target and target:hasEffect(target.EFF_DISTORTION) then return 4 else return 0 end end,
	},
	range = 10,
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
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
		
		local ravage = false
		if target:hasEffect(target.EFF_DISTORTION) then
			ravage = true
		end
		target:setEffect(target.EFF_RAVAGE, t.getDuration(self, t), {src=self, dam=self:mindCrit(t.getDamage(self, t)), ravage=ravage, distort=DistortionCount(self), apply_power=self:combatMindpower()})
		game:playSoundNear(self, "talents/echo")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local distort = DistortionCount(self)
		return ([[Ravages the target with distortion %s, inflicting %0.2f physical damage each turn for %d turns.
		This damage will distort affected targets %s, decreasing physical resistance by %d%% and rendering them vulnerable to distortion effects for two turns.
		If the target is already distorted when Ravage is applied, the damage will be increased by 50%% and the target will lose one beneficial physical effect or sustain each turn.
		Investing in this talent will increase the physical resistance reduction from all of your distortion effects.
		The damage will scale with your Mindpower.]]):tformat(Desc.vs"mp", damDesc(self, DamageType.PHYSICAL, damage), duration, Desc.vs(), distort)
	end,
}

newTalent{
	name = "Maelstrom",
	type = {"psionic/distortion", 4},
	points = 5, 
	require = psi_wil_req4,
	cooldown = 24,
	psi = 30,
	tactical = { ATTACK = { PHYSICAL = 2}, DISABLE = 2, ESCAPE=2 },
	range = 10,
	radius = function(self, t) return math.min(4, 1 + math.ceil(self:getTalentLevel(t)/3)) end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), nolock=true, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local oe = game.level.map(x, y, Map.TERRAIN+1)
		if (oe and oe.is_maelstrom) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end
		
		local e = Object.new{
			old_feat = oe,
			type = "psionic", subtype = "maelstrom",
			name = ("%s's maelstrom"):tformat(self:getName():capitalize()),
			display = ' ',
			tooltip = mod.class.Grid.tooltip,
			always_remember = true,
			temporary = t.getDuration(self, t),
			is_maelstrom = true,
			x = x, y = y,
			canAct = false,
			dam = self:mindCrit(t.getDamage(self, t)),
			radius = self:getTalentRadius(t),
			distortionPower = DistortionCount(self),
			act = function(self)
				local tgts = {}
				local Map = require "engine.Map"
				local DamageType = require "engine.DamageType"
				local grids = core.fov.circle_grids(self.x, self.y, self.radius, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local Map = require "engine.Map"
					local target = game.level.map(x, y, Map.ACTOR)
					local friendlyfire = true
					if self.summoner:getTalentLevel(self.summoner.T_DISTORTION_BOLT) >= 5 then
						friendlyfire = false
					end
					if target and not (friendlyfire == false and self.summoner:reactionToward(target) >= 0) then 
						tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, x, y)}
					end
				end end
				table.sort(tgts, "sqdist")
				for i, target in ipairs(tgts) do
					self.summoner.__project_source = self
					if target.actor:canBe("knockback") then
						target.actor:pull(self.x, self.y, 1)
						target.actor.logCombat(self, target.actor, "#Source# pulls #Target# in!")
					end
					DamageType:get(DamageType.PHYSICAL).projector(self.summoner, target.actor.x, target.actor.y, DamageType.PHYSICAL, self.dam)
					self.summoner.__project_source = nil
					target.actor:setEffect(target.actor.EFF_DISTORTION, 2, {power=self.distortionPower})
				end

				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:removeParticleEmitter(self.particles)	
					if self.old_feat then game.level.map(self.x, self.y, engine.Map.TERRAIN+1, self.old_feat)
					else game.level.map:remove(self.x, self.y, engine.Map.TERRAIN+1) end
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
					game.nicer_tiles:updateAround(game.level, self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}

		local particle = engine.Particles.new("generic_vortex", e.radius, {radius=e.radius, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
		if core.shader.allow("distort") then particle:setSub("vortex_distort", e.radius, {radius=e.radius}) end
		e.particles = game.level.map:addParticleEmitter(particle, x, y)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+1, e)
		game.level.map:updateMap(x, y)
		game:playSoundNear(self, "talents/lightning_loud")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local distort = DistortionCount(self)
		return ([[Create a powerful maelstorm for %d turns.  Each turn, the maelstrom will pull in targets within a radius of %d, and inflict %0.2f physical damage.
		This damage will distort affected targets %s, decreasing physical resistance by %d%% and rendering them vulnerable to distortion effects for two turns.
		Investing in this talent will increase the physical resistance reduction from all of your distortion effects.
		The damage will scale with your Mindpower.]]):tformat(duration, radius, damDesc(self, DamageType.PHYSICAL, damage), Desc.vs(), distort)
	end,
}