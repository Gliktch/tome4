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
	name = "Congeal Time",
	type = {"spell/temporal",1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 15,
	use_only_arcane = 4,
	tactical = { DISABLE = 2 },
	reflectable = true,
	proj_speed = 5,
	range = 6,
	direct_hit = true,
	requires_target = true,
	getSlow = function(self, t) return math.min(self:getTalentLevel(t) * 0.08, 0.6) end,
	getProj = function(self, t) return math.min(90, 5 + self:combatTalentSpellDamage(t, 5, 700) / 10) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t, display={particle="bolt_arcane"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.CONGEAL_TIME, {
			slow = t.getSlow(self, t),
			proj = t.getProj(self, t),
		}, {type="manathrust"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local proj = t.getProj(self, t)
		return ([[Project a bolt of time distortion, decreasing the target's global speed by %d%% and all projectiles it fires by %d%% for 7 turns %s.]]):
		tformat(100 * slow, proj, Desc.vs"ss")
	end,
}

newTalent{
	name = "Temporal Shield",
	short_name = "TIME_SHIELD",
	type = {"spell/temporal", 2},
	require = spells_req2,
	points = 5,
	mana = 25,
	cooldown = 18,
	use_only_arcane = 4,
	tactical = { DEFEND = 2, HEAL = 1 },
	range = 10,
	no_energy = true,
	getMaxAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 50, 450) end,
	getDuration = function(self, t) return util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15) end,
	getTimeReduction = function(self, t) return 25 + util.bound(15 + math.floor(self:getTalentLevel(t) * 2), 15, 35) end,
	action = function(self, t)
		self:setEffect(self.EFF_TIME_SHIELD, t.getDuration(self, t), {power=t.getMaxAbsorb(self, t), dot_dur=5, time_reducer=0})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxabsorb = self:getShieldAmount(t.getMaxAbsorb(self, t))
		local duration = self:getShieldDuration(t.getDuration(self, t))
		local time_reduc = t.getTimeReduction(self,t)
		return ([[This intricate spell instantly erects a time shield around the caster, preventing any incoming damage and sending it forward in time.
		Once either the maximum damage (%d) is absorbed, or the time runs out (%d turns), the stored damage will return as a temporal restoration field over time (5 turns).
		Each turn the restoration field is active, you get healed for 10%% of the absorbed damage (Aegis Shielding talent affects the percentage).
		The shield's max absorption will increase with your Spellpower.]]):
		tformat(maxabsorb, duration)
	end,
}

newTalent{
	name = "Time Prison",
	type = {"spell/temporal", 3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 100,
	cooldown = 40,
	use_only_arcane = 4,
	tactical = { DISABLE = 1, ESCAPE = 3, PROTECT = 3 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 4, 0, 12, 8)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.TIME_PRISON, t.getDuration(self, t), {type="manathrust"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Removes the target from the flow of time for %d turns %s. In this state, the target can neither act nor be harmed.
		Time does not pass at all for the target, no talents will cooldown, no resources will regen, and so forth.
		The duration will increase with your Spellpower.]]):
		tformat(duration, Desc.vs"ss")
	end,
}

newTalent{
	name = "Essence of Speed",
	type = {"spell/temporal",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 120,
	cooldown = 20,
	use_only_arcane = 4,
	tactical = { BUFF = 2 },
	getHaste = function(self, t) return self:combatTalentScale(t, 0.075, 0.26, 1/3) end, -- +10~30% for players, cube root scaling to prevent excessive strength on NPCs
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = t.getHaste(self, t)
		return {
			speed = self:addTemporaryValue("global_speed_add", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("global_speed_add", p.speed)
		return true
	end,
	info = function(self, t)
		local haste = t.getHaste(self, t)
		return ([[Increases the caster's global speed by %d%%.]]):
		tformat(100 * haste)
	end,
}
