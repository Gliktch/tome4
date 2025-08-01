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

-- Baseline blind because the class has a lot of trouble with CC early game and rushing TL4 isn't reasonable
newTalent{
	name = "Sun Ray", short_name = "SUN_BEAM",
	type = {"celestial/sun", 1},
	require = divi_req1,
	random_ego = "attack",
	points = 5,
	cooldown = 9,
	positive = -16,
	range = 7,
	no_energy = function(self, t) return self:attr("amplify_sun_beam") and true or false end,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	tactical = function(self, t, aitarget)
		local tacs = { attack = {LIGHT = 2}} -- for base damage
		if self:getTalentLevel(t) >= 3 then -- for blinding effect (to self tactics)
			if config.settings.log_detail_ai > 1 then print("###_TACTICAL FUNCTION_### Calculating blinding tactics for", t.id) end
			local blt = {disable = {blind = 2}, _no_tp_cache=true}
			local blind_tacs = self:aiTalentTactics(t, aitarget, nil, blt, t.target2(self, t))
			tacs.self = blind_tacs
		end
		return tacs
	end,
	getDamage = function(self, t)
		local mult = 1
		if self:attr("amplify_sun_beam") then mult = 1 + self:attr("amplify_sun_beam") / 100 end
		return self:combatTalentSpellDamage(t, 20, 220) * mult
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end, -- for LIGHT damage
	target2 = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=2, selffire=false, talent=t} end, -- for blindness
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		
		local _, tx, ty = self:canProject(tg, x, y)

		local particles = {type="light"}
		if core.shader.allow("adv") then
			particles = {type="volumetric", args={kind="conic_cylinder", life=14, base_rotation=rng.range(160, 200), radius=4, y=1.8, density=40, shininess=20, growSpeed=0.006, img="sunray"}}
		end
		local blind_dur = self:getTalentLevel(t) >= 3 and t.getDuration(self, t) or 0

		-- project light damage
		self:project(tg, tx, ty, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t)), particles)
		-- project blindness
		if blind_dur > 0 then
			local tg2 = t.target2(self, t); tg2.x, tg2.y = tx, ty
			self:project(tg2, tx, ty, DamageType.BLIND, blind_dur, {type="light"})
		end

		-- Delay removal of the effect so its still there when no_energy checks
		game:onTickEnd(function()
			self:removeEffect(self.EFF_SUN_VENGEANCE)
		end)

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Calls forth a ray of light from the Sun, doing %0.1f Light damage to the target.
		At level 3 the ray will be so intense it will also blind the target and everyone in a radius 2 around it for %d turns. %s
		The damage dealt will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.LIGHT, damage), t.getDuration(self, t), Desc.vs"sp")
	end,
}

newTalent{
	name = "Path of the Sun",
	type = {"celestial/sun", 2},
	require = divi_req2,
	points = 5,
	cooldown = 15,
	positive = -20,
	tactical = { SELF = {POSITIVE = 0.5}, ATTACKAREA = {LIGHT = 1}, CLOSEIN = 2},
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 9)) end,
	direct_hit = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 310) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, function() end)
		grids[self.x] = grids[self.x] or {}
		grids[self.x][self.y] = true
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:addEffect(self, self.x, self.y, 5, DamageType.SUN_PATH, dam / 5, 0, 5, grids, MapEffect.new{color_br=255, color_bg=249, color_bb=60, alpha=100, effect_shader="shader_images/sun_effect.png"}, nil, true)
		game.level.map:addEffect(self, self.x, self.y, 5, DamageType.COSMETIC, 0      , 0, 5, grids, {type="sun_path", args={tx=x-self.x, ty=y-self.y}, only_one=true}, nil, true)

		self:setEffect(self.EFF_PATH_OF_THE_SUN, 5, {})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[A path of sunlight appears in front of you for 5 turns. All foes standing inside take %0.1f Light damage per turn.
		While standing in the path, your movement takes no time and can not trigger traps.
		The damage done will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.LIGHT, damage / 5), radius)
	end,
}

-- Can someone put a really obvious visual on this?
newTalent{
	name = "Sun's Vengeance", short_name = "SUN_VENGEANCE",
	type = {"celestial/sun",3},
	require = divi_req3,
	mode = "passive",
	points = 5,
	getCrit = function(self, t) return self:combatTalentScale(t, 2, 10, 0.75) end,
	getProcChance = function(self, t) return self:combatTalentLimit(t, 100, 40, 75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellcrit", t.getCrit(self, t))
		self:talentTemporaryValue(p, "combat_physcrit", t.getCrit(self, t))
	end,
	callbackOnCrit = function(self, t, kind, dam, chance)
		if kind ~= "spell" and kind ~= "physical" then return end
		if not rng.percent(t.getProcChance(self, t)) then return end
		if self.turn_procs.sun_vengeance then return end --Note: this will trigger a lot since it get's multiple chances a turn
		self.turn_procs.sun_vengeance = true

		if self:isTalentCoolingDown(self.T_SUN_BEAM) then
			self.talents_cd[self.T_SUN_BEAM] = self.talents_cd[self.T_SUN_BEAM] - 1
			if self.talents_cd[self.T_SUN_BEAM] <= 0 then self.talents_cd[self.T_SUN_BEAM] = nil end
		else
			self:setEffect(self.EFF_SUN_VENGEANCE, 2, {})
		end
		if self:attr("sun_paladin_avatar") then
			self:alterTalentCoolingdown(self.T_JUDGEMENT, -6)
		end
	end,
	info = function(self, t)
		local crit = t.getCrit(self, t)
		local chance = t.getProcChance(self, t)
		return ([[Infuse yourself with the raging fury of the Sun, increasing your physical and spell critical chance by %d%%.
		Each time you crit with a physical attack or a spell you have %d%% chance to gain Sun's Vengeance for 2 turns.
		While affected by Sun's Vengeance, your Sun Ray will take no time to use and will deal 25%% more damage.
		If Sun Ray was on cooldown, the remaining turns are reduced by one instead.
		This effect can only happen once per turn.]]):
		tformat(crit, chance)
	end,
}

-- Core class defense to be compared with Bone Shield, Aegis, Indiscernable Anatomy, etc
-- Moderate offensive scaler
-- The CD reduction effects more abilities on the class than it doesn't
-- Banned from NPCs due to sheer scaling insanity
newTalent{
	name = "Suncloak",
	type = {"celestial/sun", 4},
	require = divi_req4,
	points = 5,
	cooldown = 15, -- 20 was accounting for it buffing itself
	fixed_cooldown = true,
	positive = -15,
	tactical = { BUFF = 2, DEFEND = 1, POSITIVE = 0.5 },
	direct_hit = true,
--	no_npc_use = true,
--	requires_target = true,
	on_pre_use_ai = function(self, t, fake, silent)
		return self.ai_target.actor and self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y)
	end,
	range = 10,
	getCap = function(self, t) return self:combatTalentLimit(t, 30, 85, 55) end,
	getHaste = function(self, t) return math.min(0.5, self:combatTalentSpellDamage(t, 0.1, 0.4)) end,
	getCD = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 5, 450), 0.5, .065, 32, .38, 350) end, -- Limit < 50% cooldown reduction
	action = function(self, t)
		self:setEffect(self.EFF_SUNCLOAK, 6, {cap=t.getCap(self, t), haste=t.getHaste(self, t), cd=t.getCD(self, t)})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[You wrap yourself in a cloak of sunlight that empowers your magic and protects you for 6 turns.
		While the cloak is active, your spell casting speed is increased by %d%%, your spell cooldowns are reduced by %d%%, and you cannot take more than %d%% of your maximum life from a single blow.
		The effects will increase with your Spellpower.]]):
		tformat(t.getHaste(self, t)*100, t.getCD(self, t)*100, t.getCap(self, t))
   end,
}

