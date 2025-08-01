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
	name = "Blood Splash",
	type = {"corruption/vile-life", 1},
	require = corrs_req1,
	points = 5,
	mode = "passive",
	heal = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	callbackOnCrit = function(self, t)
		if self.turn_procs.blood_splash_on_crit then return end
		self.turn_procs.blood_splash_on_crit = true

		self:heal(self:spellCrit(t.heal(self, t)), t)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end
	end,
	callbackOnKill = function(self, t)
		if self.turn_procs.blood_splash_on_kill then return end
		self.turn_procs.blood_splash_on_kill = true

		self:heal(self:spellCrit(t.heal(self, t)), t)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end
	end,
	info = function(self, t)
		return ([[Inflicting pain and death invigorates you.
		Each time you deal a critical strike you gain %d life (this effect can only happen once per turn).
		Each time you kill a creature you gain %d life (this effect can only happen once per turn).]]):
		tformat(t.heal(self, t), t.heal(self, t))
	end,
}

newTalent{
	name = "Elemental Discord",
	type = {"corruption/vile-life", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 20,
	sustain_vim = 30,
	mode = "sustained",
	tactical = { BUFF = 2 },
	getFire = function(self, t) return self:combatTalentSpellDamage(t, 10, 400) end,
	getCold = function(self, t) return self:combatTalentSpellDamage(t, 10, 500) end,
	getLightning = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 3, 6)) end,
	getAcid = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 3, 6)) end,
	getNature = function(self, t) return self:combatTalentLimit(t, 75, 25, 55) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		local p = self:isTalentActive(t.id)
		if not p then return end
		if not src.setEffect then return end
		if not p.last_turn[type] or game.turn - p.last_turn[type] < 100 then return end

		if type == DamageType.FIRE then
			src:setEffect(src.EFF_BURNING, 5, {src=self, apply_power=self:combatSpellpower(), power=t.getFire(self, t) / 5})
		elseif type == DamageType.COLD then
			if src:canBe("stun") then
				src:setEffect(src.EFF_FROZEN, 3, {apply_power=self:combatSpellpower(), hp=t.getCold(self, t)})
			end
		elseif type == DamageType.ACID then
			if src:canBe("blind") then
				src:setEffect(src.EFF_BLINDED, t.getAcid(self, t), {apply_power=self:combatSpellpower()})
			end
		elseif type == DamageType.LIGHTNING then
			if src:canBe("stun") then
				src:setEffect(src.EFF_DAZED, t.getLightning(self, t), {apply_power=self:combatSpellpower()})
			end
		elseif type == DamageType.NATURE then
			src:setEffect(src.EFF_SLOW, 4, {apply_power=self:combatSpellpower(), power=t.getNature(self, t) / 100})
		end
		p.last_turn[type] = game.turn
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		return {
			last_turn = {
				[DamageType.FIRE] = game.turn - 100,
				[DamageType.COLD] = game.turn - 100,
				[DamageType.ACID] = game.turn - 100,
				[DamageType.LIGHTNING] = game.turn - 100,
				[DamageType.NATURE] = game.turn - 100,
			},
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local desc = Desc.vs"sp"
		return ([[Use elemental damage dealt to you to trigger terrible effects on the source:
		- Fire: burn for %0.2f fire damage over 5 turns %s
		- Cold: freeze for 3 turns with %d iceblock power %s
		- Acid: blind for %d turns %s
		- Lightning: daze for %d turns %s
		- Nature: %d%% slow for 4 turns %s
		This effect can only happen once every 10 turns per damage type.
		The damage will increase with your Spellpower.]]):
		tformat(
			damDesc(self, DamageType.FIRE, t.getFire(self, t)), desc,
			t.getCold(self, t), desc,
			t.getAcid(self, t), desc,
			t.getLightning(self, t), desc,
			t.getNature(self, t), desc
		)
	end,
}

newTalent{
	name = "Healing Inversion",
	type = {"corruption/vile-life", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 10,
	vim = 16,
	range = 8,
	radius = 4,
	no_npc_use = true,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t} end,
	getPower = function(self,t) return self:combatLimit(self:combatTalentSpellDamage(t, 4, 100), 100, 0, 0, 18.1, 18.1) end, -- Limit to <100%
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_HEALING_INVERSION, 5, {src=self, apply_power=self:combatSpellpower(), power=t.getPower(self, t)})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[You manipulate the vim of enemies in radius %d to temporarily invert all healing done to them (but not natural regeneration) %s.
		For 5 turns all healing will instead damage them for %d%% of the healing done as blight.
		The effect will increase with your Spellpower.]]):tformat(self:getTalentRadius(t), Desc.vs"ss", t.getPower(self,t))
	end,
}

newTalent{
	name = "Vile Transplant",
	type = {"corruption/vile-life", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 15,
	vim = 18,
	direct_hit = true,
	requires_target = true,
	range = 4,
	no_npc_use = true,  -- Bypasses all forms of immunity and such
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, "log")) end,
	getDam = function(self, t) return self:combatTalentLimit(t, 2, 10, 3) end, --Limit < 10% life/effect
	getVim = function(self, t) return 18 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end

			local list = {}
			local nb = t.getNb(self, t)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if (e.type == "physical" or e.type == "magical") and e.status == "detrimental" then
					list[#list+1] = eff_id
				end
			end

			while #list > 0 and nb > 0 do
				local eff_id = rng.tableRemove(list)
				local e = self.tempeffect_def[eff_id]
				self:cloneEffect(eff_id, target, {apply_power = self:combatSpellpower()})
				if target:hasEffect(eff_id) then
					self:removeEffect(eff_id)
					game:delayedLogMessage(self, target, "vile_transplant"..e.desc, ("#CRIMSON##Source# transfers an effect (%s) to #Target#!"):tformat(e.desc))
					self:incVim(-t.getVim(self, t))  -- Vim costs life if there isn't enough so no need to check total
					nb = nb - 1
				end
			end
			
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, g=100, r=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[You transfer up to %d physical or magical detrimental effects currently affecting you to a nearby creature at a cost of %d vim per effect %s.
		Specific effect immunities will not prevent the transfer.]]):
		tformat(t.getNb(self, t), t.getVim(self, t), Desc.vs"ss")
	end,
}
