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
	name = "Gravitic Effulgence",
	type = {"celestial/other", 1},
	mode = "sustained",
	points = 1,
	cooldown = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getShieldFlat = function(self, t)
		return t.getDamage(self, t)
	end,
	activate = function(self, t)
		game:onTickEnd(function()
			if self:isTalentActive(self.T_WEAPON_OF_LIGHT) then
				self.turn_procs.resetting_talents = true
				self:forceUseTalent(self.T_WEAPON_OF_LIGHT, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
				self:forceUseTalent(self.T_WEAPON_OF_LIGHT, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true})
				self.turn_procs.resetting_talents = nil			
			end
		end)

		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		game:onTickEnd(function()
			if self:isTalentActive(self.T_WEAPON_OF_LIGHT) then
				self.turn_procs.resetting_talents = true
				self:forceUseTalent(self.T_WEAPON_OF_LIGHT, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
				self:forceUseTalent(self.T_WEAPON_OF_LIGHT, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true})
				self.turn_procs.resetting_talents = nil			
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[Your Weapon of Light nows pulls in all foes in radius 5.]]):tformat()
	end,
}

newTalent{
	name = "Weapon of Light",
	type = {"celestial/combat", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getDamage = function(self, t) return (7 + self:combatSpellpower(0.092) * self:combatTalentScale(t, 1, 7))  end,
	getShieldFlat = function(self, t)
		return t.getDamage(self, t)
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {}
		if not self:isTalentActive(self.T_GRAVITIC_EFFULGENCE) then ret.dam = self:addTemporaryValue("melee_project", {[DamageType.LIGHT]=t.getDamage(self, t)}) end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.dam then self:removeTemporaryValue("melee_project", p.dam) end
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if self.turn_procs.weapon_of_light then return end
		if hitted and self:hasEffect(self.EFF_DAMAGE_SHIELD) and (self:reactionToward(target) < 0) then
			self.turn_procs.weapon_of_light = true
			-- Shields can't usually merge, so change the parameters manually
			local shield = self:hasEffect(self.EFF_DAMAGE_SHIELD)
			local shield_power = t.getShieldFlat(self, t)

			shield.power = shield.power + shield_power
			shield.power_max = shield.power_max + shield_power
			shield.dur = math.max(2, shield.dur)
		end
		if hitted and self:isTalentActive(self.T_GRAVITIC_EFFULGENCE) then
			local list = table.values(self:projectCollect({type="ball", radius=5, x=target.x, y=target.y, friendlyfire=false}, target.x, target.y, Map.ACTOR))
			table.sort(list, "dist")
			for _, l in ipairs(list) do
				if l.target:canBe("knockback") then l.target:pull(target.x, target.y, 5) end
			end
			self:project({type="ball", radius=2, x=target.x, y=target.y, friendlyfire=false}, target.x, target.y, DamageType.LIGHT, t.getDamage(self, t))
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local shieldflat = t.getShieldFlat(self, t)
		return ([[Infuse your weapon with the power of the Sun, adding %0.1f light damage on each melee hit.
		Additionally, if you have a temporary damage shield active, melee hits will increase its power by %d and set its duration to 2 (if not already higher), once per turn.
		The damage dealt and shield bonus will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.LIGHT, damage), shieldflat)
	end,
}

-- A potentially very powerful ranged attack that gets more effective with range
-- 2nd attack does reduced damage to balance high damage on 1st attack (so that the talent is always useful at low levels and close ranges)
newTalent{
	name = "Wave of Power",
	type = {"celestial/combat",2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	positive = 15,
	tactical = { ATTACK = 2 },
	requires_target = true,
	is_melee = true,
	range = function(self, t) return 2 + math.max(0, math.floor(self:combatStatScale("str", 0.8, 8))) end,
	SecondStrikeChance = function(self, t, range)
		return self:combatLimit(self:getTalentLevel(t)*range, 100, 15, 4, 70, 50)
	end, -- 15% for TL 1.0 at range 4, 70% for TL 5.0 at range 10
	getDamage = function(self, t, second)
		if second then
			return self:combatTalentWeaponDamage(t, 0.9, 2)*self:combatTalentLimit(t, 1.0, 0.4, 0.65)
		else
			return self:combatTalentWeaponDamage(t, 0.9, 2)
		end
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
			local range = core.fov.distance(self.x, self.y, target.x, target.y)
			if range > 1 and rng.percent(t.SecondStrikeChance(self, t, range)) then
				game.logSeen(self, "#CRIMSON#%sstrikes twice with Wave of Power!#NORMAL#", self:getName())
				self:attackTarget(target, nil, t.getDamage(self, t, true), true)
			end
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[In a pure display of power, you project a ranged melee attack, doing %d%% weapon damage.
		If the target is outside of melee range, you have a chance to project a second attack against it for %d%% weapon damage.
		The second strike chance (which increases with distance) is %0.1f%% at range 2 and %0.1f%% at the maximum range of %d.
		The range will increase with your Strength.]]):
		tformat(t.getDamage(self, t)*100, t.getDamage(self, t, true)*100, t.SecondStrikeChance(self, t, 2), t.SecondStrikeChance(self, t, range), range)
	end,
}

-- Interesting interactions with shield timing, lots of synergy and antisynergy in general
newTalent{
	name = "Weapon of Wrath",
	type = {"celestial/combat", 3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	rnd_boss_restrict = function(self, t, data) return true end, -- martyrdom is fine on fixedbosses specifically given the talents but let's avoid it on randbosses
	tactical = { BUFF = 2 },
	range = 10,
	getMartyrDamage = function(self, t) return self:combatTalentLimit(t, 50, 10, 25) end, --Limit < 50%
	getLifeDamage = function(self, t) return self:combatTalentScale(t, 0.55, 0.95) end, -- Limit < 100%
	getMaxDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 400) end,
	getDamage = function(self, t)
		local damage = (self:attr("weapon_of_wrath_life") or t.getLifeDamage(self, t)) * (self:getMaxLife() - math.max(0, self:getLife())) -- avoid problems with die_at
		return math.min(t.getMaxDamage(self, t), damage) -- The Martyr effect provides the upside for high HP NPC's
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		-- Is this any better than having the callback call getLifeDamage?  I figure its better to calculate it once
		local ret = {
			martyr = self:addTemporaryValue("weapon_of_wrath_martyr", t.getMartyrDamage(self, t)),
			damage = self:addTemporaryValue("weapon_of_wrath_life", t.getLifeDamage(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("weapon_of_wrath_martyr", p.martyr)
		self:removeTemporaryValue("weapon_of_wrath_life", p.damage)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted and self:attr("weapon_of_wrath_martyr") and not self.turn_procs.weapon_of_wrath and not target.dead then
			target:setEffect(target.EFF_MARTYRDOM, 4, {power = self:attr("weapon_of_wrath_martyr")})
			local damage = t.getDamage(self, t)
			if damage == 0 then return end
			local tg = {type="hit", range=10, selffire=true, talent=t}
			self:project(tg, target.x, target.y, DamageType.FIRE, damage)
			self.turn_procs.weapon_of_wrath = true
		end
	end,
	info = function(self, t)
		local martyr = t.getMartyrDamage(self, t)
		local damagepct = t.getLifeDamage(self, t)
		local damage = t.getDamage(self, t)
		return ([[Your weapon attacks burn with righteous fury, dealing %d%% of your lost HP as additional Fire damage (up to %d, Current:  %d).
		Targets struck are also afflicted with a Martyrdom effect %s that causes them to take %d%% of all damage they deal for 4 turns.
		The bonus damage can only occur once per turn.]]):
		tformat(damagepct*100, t.getMaxDamage(self, t, 10, 400), damage, Desc.vs(), martyr)
	end,
}

-- Core class defense to be compared with Bone Shield, Aegis, Indiscernable Anatomy, etc
-- !H/Shield could conceivably reactivate this in the same fight with Crusade spam if it triggers with Suncloak up, 2H never will without running
newTalent{
	name = "Second Life",
	type = {"celestial/combat", 4},
	require = divi_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 20,
	cooldown = 30,
	tactical = { DEFEND = 2 },
	getLife = function(self, t) return self:getMaxLife() * self:combatTalentLimit(t, 1.5, 0.2, 0.5) end, -- Limit < 150% max life (to survive a large string of hits between turns)
	callbackPriorities = {callbackOnHit = 350},
	callbackOnHit = function(self, t, cb, src, death_note)		
		if cb.value  >= self.life then
			local sl = t.getLife(self, t)
			cb.value = 0
			self.life = 1
			self:forceUseTalent(self.T_SECOND_LIFE, {ignore_energy=true})
			local value = self:heal(sl, self)
			game.logSeen(self, "#YELLOW#%s has been healed by a blast of positive energy!#LAST#", self:getName():capitalize())
			if value > 0 then
				if self.player then
					self:setEmote(require("engine.Emote").new("The Sun Protects!", 45))
					world:gainAchievement("AVOID_DEATH", self)
				end
			end
		end
		
		return cb
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.6, rotation=0, radius=2, img="flamesgeneric"}, {type="sunaura", time_factor=6000}))
		else
			ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Any attack that would drop you below 1 hit point instead triggers Second Life, deactivating the talent, setting your hit points to 1, then healing you for %d.]]):
		tformat(t.getLife(self, t))
	end,
}
