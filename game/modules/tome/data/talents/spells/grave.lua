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
	name = "Chill of the Tomb",
	type = {"spell/grave",1},
	require = spells_req1,
	points = 5,
	mana = 30,
	cooldown = 8,
	tactical = { ATTACKAREA = { COLD = 2 } },
	range = 7,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 2, 6, 0.5, 0, 0, true))
	end,
	proj_speed = 4,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t, display={particle="bolt_ice", trail="icetrail"}}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 280) end,
	getFlatResist = function(self, t) return math.floor(self:combatTalentScale(t, 5, 25)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.CHILL_OF_THE_TOMB, {dam=self:spellCrit(t:_getDamage(self)), resist=t:_getFlatResist(self)}, function(self, tg, x, y, grids)
			game.level.map:particleEmitter(x, y, tg.radius, "iceflash", {radius=tg.radius, tx=x, ty=y})
		end)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Conjures up a bolt of cold that moves toward the target and explodes into a chilly circle of death, doing %0.2f cold damage in a radius of %d.
		Necortic minions caught in the blast do not take damage but are instead coated with a thin layer of ice, reducing all damage they take by %d for 4 turns.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.COLD, damage), radius, t:_getFlatResist(self))
	end,
}

newTalent{
	name = "Black Ice",
	type = {"spell/grave",2},
	require = spells_req2,
	points = 5,
	mana = 7,
	cooldown = 4,
	tactical = { ATTACK= { COLD = 2 }, DISABLE = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		if self:getTalentLevel(t) < 5 then
			return {type="hit", range=self:getTalentRange(t)}
		else
			return {type="ball", radius=1, range=self:getTalentRange(t)}
		end
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 250) end,
	getMinionsInc = function(self,t) return math.floor(self:combatTalentScale(t, 10, 30)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end

		local dam = self:spellCrit(t:_getDamage(self))
		self:projectApply(tg, x, y, Map.ACTOR, function(target, x, y)
			if DamageType:get(DamageType.COLD).projector(self, x, y, DamageType.COLD, dam) > 0 then
				target:setEffect(target.EFF_BLACK_ICE, 3, {apply_power=self:combatSpellpower(), power=t:_getMinionsInc(self)})
			end
			game.level.map:particleEmitter(x, y, 1, "spike_decrepitude", {})
		end)

		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Summon a icy spike directly on a foe, impaling it for %0.2f cold damage.
		At level 5 it hits all foes in range 1 around the target.
		Any creature hit will take %d%% more damage from your necrotic minions for 3 turns.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.COLD, damage), t:_getMinionsInc(self))
	end,
}

newTalent{
	name = "Corpselight",
	type = {"spell/grave",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sutain_mana = 20,
	cooldown = 10,
	tactical = { BUFF=1 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 330) / 5 end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if dead or not death_note or not death_note.damtype or target == self then return end
		if death_note.damtype ~= DamageType.DARKNESS then return end
		if target.turn_procs.doing_bane_damage then return end

		local banes = target:effectsFilter{subtype={bane=true}}
		if #banes == 0 then return end

		for _, baneid in ipairs(banes) do
			local bane = target:hasEffect(baneid)
			if bane then bane.dur = bane.dur + 1 end
		end
		
		if target.turn_procs.erupting_shadows then return end
		target.turn_procs.erupting_shadows = true

		DamageType:get(DamageType.DARKNESS).projector(self, target.x, target.y, DamageType.DARKNESS, t:_getDamage(self))
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Shadows engulf your foes, anytime you deal darkness damage to a creature affected by a bane, the bane's duration is increased by 1 turn and the shadows erupt, dealing an additional %0.2f damage.
		The damage the can only happen once per turn per creature, the turn increase however always happens.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Grave Mistake",
	type = {"spell/grave",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	mana = 30, -- Not sustain cost, cast cost
	cooldown = 15,
	tactical = { ATTACKAREA = { DARKNESS = 3 } },
	range = 7,
	direct_hit = true,
	requires_target = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 4)) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=true, talent=t, display={particle="bolt_dark", trail="darktrail"}} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 280) end,
	iconOverlay = function(self, t, p)
		local val = p.dur
		if val <= 0 then return "" end
		return tostring(math.ceil(val)), "buff_font_small"
	end,
	callbackOnChangeLevel = function(self, t, what)
		local p = self:isTalentActive(t.id)
		if not p then return end
		if what ~= "leave" then return end
		self:forceUseTalent(t.id, {ignore_energy=true})
	end,
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end

		if self:getSoul() <= 0 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end

		local tg = self:getTalentTarget(t)
		self:projectile(tg, p.x, p.y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)), {type="dark"})
		self:incSoul(-1)
		p.dur = p.dur - 1

		if self:getSoul() <= 0 or p.dur <= 0 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end
	end,
	on_pre_use = function(self, t) return self:getSoul() > 0 end,
	activate = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		return {x=x, y=y, dur=5}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You summon a river of tortured souls to launch an onslaught of darkness against your foes.
		Every turn for 5 turns you launch a projectile towards the designated area that explodes in radius %d, dealing %0.2f darkness damage.
		Each projectile consumes a soul and the spell ends when it has sent 5 projectiles or when you have no more souls to use.
		The damage will increase with your Spellpower.]]):
		tformat(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, damage))
	end,
}
