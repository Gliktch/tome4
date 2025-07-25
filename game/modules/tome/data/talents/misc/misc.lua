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

-- race & classes
newTalentType{ type="base/class", name = _t("class", "talent type"), hide = true, description = _t"The basic talents defining a class." }
newTalentType{ type="base/race", name = _t("race", "talent type"), hide = true, description = _t"The various racial bonuses a character can have." }
newTalentType{ is_nature = true, type="inscriptions/infusions", name = _t("infusions", "talent type"), hide = true, description = _t"Infusions are not class abilities, you must find them or learn them from other people." }
newTalentType{ is_spell=true, no_silence=true, type="inscriptions/runes", name = _t("runes", "talent type"), hide = true, description = _t"Runes are not class abilities, you must find them or learn them from other people." }
newTalentType{ is_spell=true, no_silence=true, type="inscriptions/taints", name = _t("taints", "talent type"), hide = true, description = _t"Taints are not class abilities, you must find them or learn them from other people." }

-- Load other misc things
load("/data/talents/misc/objects.lua")
load("/data/talents/misc/inscriptions.lua")
load("/data/talents/misc/npcs.lua")
load("/data/talents/misc/horrors.lua")
load("/data/talents/misc/races.lua")
load("/data/talents/misc/tutorial.lua")

-- Default melee attack
newTalent{
	name = "Attack",
	type = {"base/class", 1},
	no_energy = "fake",
	hide = "always",
	innate = true,
	points = 1,
	range = 1,
	message = false,
	no_break_stealth = true, -- stealth is broken in attackTarget
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	tactical = { ATTACK = { weapon = 1}},
	no_unlearn_last = true,
	ignored_by_hotkeyautotalents = true,
	alternate_attacks = {'T_DOUBLE_STRIKE'},
	speed = 'weapon',
	is_melee = true,
	action = function(self, t)
		if self:attr("never_attack") then return end
		local swap = not self:attr("disarmed") and (self:attr("warden_swap") and doWardenWeaponSwap(self, t, "blade"))
	
		local tg = self:getTalentTarget(t)
		local ok, x, y = self:canProject(tg, self:getTarget(tg))
		local target = game.level.map(x, y, game.level.map.ACTOR)
	
		if not ok or not target then
			if swap then doWardenWeaponSwap(self, t, "bow") end
			if ok then -- talent is treated as used even if there is no target (prevents stealth scumming)
				print("[T_ATTACK]", self.uid, self.name, "attacks empty space:", x, y)
				self:logCombat(target, "#Source# attacks empty space.")
				self:useEnergy(game.energy_to_act * self:getTalentSpeed(t))
			end
			return ok
		end

		local did_alternate = false
		for _, alt_t in ipairs(t.alternate_attacks) do
			if self:knowTalent(alt_t) and self:callTalent(alt_t, 'can_alternate_attack') then
				self:forceUseTalent(alt_t, {force_target = target})
				did_alternate = true
				break
			end
		end

		if not did_alternate then self:attackTarget(target) end -- this uses energy

		if config.settings.tome.smooth_move > 0 and config.settings.tome.twitch_move then
			self:setMoveAnim(self.x, self.y, config.settings.tome.smooth_move, blur, util.getDir(x, y, self.x, self.y), 0.2)
		end

		return true
	end,
	info = function(self, t)
		return ([[Hack and slash, baby!]]):tformat()
	end,
}

--mindslayer resource
newTalent{
	name = "Psi Pool",
	type = {"base/class", 1},
	info = "Allows you to have an energy pool. Energy is used to perform psionic manipulations.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}

newTalent{
	name = "Feedback Pool",
	type = {"base/class", 1},
	info = "Allows you to have a Feedback pool. Feedback is used to power feedback and discharge talents.",
	mode = "passive",
	hide = "always",
	-- Adjust feedback ratio with character level to reflect the degree of "pain" received
	-- Called in function _M:onTakeHit in mod.class.Actor.lua
	getFeedbackRatio = function(self, t, raw)
		local ratio = self:combatLimit(self.level, 0, 0.5, 1, 0.2, 50)  -- Limit >0% damage taken, 50% @ level 1, 20% @ level 50
		local mult = 1 + (not raw and self:callTalent(self.T_AMPLIFICATION, "getFeedbackGain") or 0)
		return ratio*mult
	end,
	callbackPriorities = {callbackOnHit = -100},
	callbackOnHit = function(self, t, cb, src, death_note)
		if src == self or src == self.summoner then return end
		local value = cb.value + (self.turn_procs.resonance_field_absorb or 0)
		self.turn_procs.resonance_field_absorb = nil
		if value <= 0 then return end
		local ratio = t.getFeedbackRatio(self, t)
		local feedback_gain = value * ratio
		self:incFeedback(feedback_gain)
		-- Give feedback to summoner
		if self.summoner and self.summoner:getTalentLevel(self.summoner.T_OVER_MIND) >=1 and self.summoner:getMaxFeedback() > 0 then
			self.summoner:incFeedback(feedback_gain)
		end
		-- Trigger backlash retribution damage
		if src and src.turn_procs and self:knowTalent(self.T_BACKLASH) and not src.no_backlash_loops and not src.turn_procs.backlash then
			if src.y and src.x and not src.dead then
				local t = self:getTalentFromId(self.T_BACKLASH)
				t.doBacklash(self, src, feedback_gain, t)
				src.turn_procs.backlash = true
			end
		end
	end,
	no_unlearn_last = true,
	on_learn = function(self, t)
		if self:getMaxFeedback() <= 0 then
			self:incMaxFeedback(100 - self:getMaxFeedback())
		end
		return true
	end,
}

newTalent{
	name = "Mana Pool",
	type = {"base/class", 1},
	info = "Allows you to have a mana pool. Mana is used to cast all spells.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Soul Pool",
	type = {"base/class", 1},
	info = "Allows you to have a soul pool. Souls are used to cast necrotic spells.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Vim Pool",
	type = {"base/class", 1},
	info = "Allows you to have a vim pool. Vim is used by corruptions.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Stamina Pool",
	type = {"base/class", 1},
	info = "Allows you to have a stamina pool. Stamina is used to activate special combat attacks.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Equilibrium Pool",
	type = {"base/class", 1},
	info = "Allows you to have an equilibrium pool. Equilibrium is used to measure your balance with nature and the use of wild gifts.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Positive Pool",
	type = {"base/class", 1},
	info = "Allows you to have a positive energy pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Negative Pool",
	type = {"base/class", 1},
	info = "Allows you to have a negative energy pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Hate Pool",
	type = {"base/class", 1},
	info = "Allows you to have a hate pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
	updateRegen = function(self, t)
		-- hate loss speeds up as hate increases
		local hate = self:getHate()
		local hateChange
		if hate < self.baseline_hate then
			hateChange = 0
		else
			hateChange = -0.7 * math.pow(hate / 100, 1.5)
		end
		if hateChange < 0 then
			hateChange = math.min(0, math.max(hateChange, self.baseline_hate - hate))
		end

		self.hate_regen = self.hate_regen - (self.hate_decay or 0) + hateChange
		self.hate_decay = hateChange
	end,
	updateBaseline = function(self, t)
		self.baseline_hate = math.max(10, self:getHate() * 0.5)
	end,
	on_kill = function(self, t, target)
		local hateGain = self.hate_per_kill
		local hateMessage

		if target.level - 2 > self.level then
			-- level bonus
			hateGain = hateGain + math.ceil(self:combatTalentScale(target.level - 2 - self.level, 2, 10, "log", 0, 1))
			hatemessage = _t"#F53CBE#You have taken the life of an experienced foe!"
		end

		if target.rank >= 4 then
			-- boss bonus
			hateGain = hateGain * 4
			hatemessage = _t"#F53CBE#Your hate has conquered a great adversary!"
		elseif target.rank >= 3 then
			-- elite bonus
			hateGain = hateGain * 2
			hatemessage = _t"#F53CBE#An elite foe has fallen to your hate!"
		end
		hateGain = math.min(hateGain, 100)

		self.hate = math.min(self.max_hate, self.hate + hateGain)
		if hateMessage then
			game.logPlayer(self, hateMessage.." (+%d hate)", hateGain - self.hate_per_kill)
		end
	end,
	callbackPriorities = {callbackOnHit = -100},
	callbackOnHit = function(self, t, cb, src, death_note)
		local value = cb.value
		if value <= 0 then return end
		local hateGain = 0
		local hateMessage

		if value / self:getMaxLife() >= 0.15 then
			-- you take a big hit..adds 2 + 2 for each 5% over 15%
			hateGain = hateGain + 2 + (((value / self:getMaxLife()) - 0.15) * 100 * 0.5)
			hatemessage = _t"#F53CBE#You fight through the pain!"
		end

		if value / self:getMaxLife() >= 0.05 and (self.life - value) / self:getMaxLife() < 0.25 then
			-- you take a hit with low health
			hateGain = hateGain + 4
			hatemessage = _t"#F53CBE#Your hatred grows even as your life fades!"
		end

		if hateGain >= 1 then
			self:incHate(hateGain)
			if hateMessage then
				game.logPlayer(self, ("%s (+%d hate)"):tformat(hateMessage), hateGain)
			end
		end
	
	end,
}

newTalent{
	name = "Paradox Pool",
	type = {"base/class", 1},
	info = "Allows you to have a paradox pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}

-- Madness difficulty
newTalent{
	name = "Hunted!", short_name = "HUNTED_PLAYER",
	type = {"base/class", 1},
	mode = "passive",
	no_unlearn_last = true,
	callbackOnActBase = function(self, t)
		if not rng.percent(1 + self.level / 7) then return end

		local rad = math.ceil(10 + self.level / 5)
		for i = self.x - rad, self.x + rad do for j = self.y - rad, self.y + rad do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and self:reactionToward(actor) < 0 and not actor:attr("hunted_difficulty_immune") then
				actor:setEffect(actor.EFF_HUNTER_PLAYER, 30, {src=self})
			end
		end end end
	end,
	info = function(self, t) return ([[You are hunted!.
		There is a %d%% chance each turn that all foes in a %d radius get a glimpse of your position for 30 turns.]]):
		tformat(math.min(100, 1 + self.level / 7), 10 + self.level / 5)
	end,
}

-- Mages class talent, teleport to angolwen
newTalent{
	short_name = "TELEPORT_ANGOLWEN",
	name = "Teleport: Angolwen",
	type = {"base/class", 1},
	cooldown = 400,
	no_npc_use = true,
	no_unlearn_last = true,
	no_silence=true, is_spell=true,
	action = function(self, t)
		if not self:canBe("worldport") or self:attr("never_move") then
			game.logPlayer(self, "The spell fizzles...")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you; you cannot take the risk.")
			return
		end

		self:setEffect(self.EFF_TELEPORT_ANGOLWEN, 40, {})
		return true
	end,
	info = _t[[Allows a mage to teleport to the secret town of Angolwen.
	You have studied the magic arts there and have been granted a special portal spell to teleport there.
	Nobody must learn about this spell and so it should never be used while seen by any creatures.
	The spell will take time to activate. You must be out of sight of any creature when you cast it and when the teleportation takes effect.]]
}

-- Chronomancer class talent, teleport to Point Zero
newTalent{
	short_name = "TELEPORT_POINT_ZERO",
	name = "Timeport: Point Zero",
	type = {"base/class", 1},
	cooldown = 400,
	no_npc_use = true,
	no_unlearn_last = true,
	no_silence=true, is_spell=true,
	action = function(self, t)
		if not self:canBe("worldport") or self:attr("never_move") then
			game.logPlayer(self, "The spell fizzles...")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then
				if actor.summoner and actor.summoner == self then
					seen = false
				else
					seen = true
				end
			end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you; you cannot take the risk.")
			return
		end

		self:setEffect(self.EFF_TELEPORT_POINT_ZERO, 40, {})
		self:attr("temporal_touched", 1)
		self:attr("time_travel_times", 1)
		return true
	end,
	info = _t[[Allows a chronomancer to timeport to Point Zero.
	You have studied the chronomancy there and have been granted a special portal spell to teleport back.
	This spell must be kept secret; it should never be used within view of uninitiated witnesses.
	The spell takes time (40 turns) to activate, and you must be out of sight of any other creature when you cast it and when the timeportation takes effect.]]
}

newTalent{
	name = "Relentless Pursuit",
	type = {"base/class", 1},
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return self:combatTalentLimit(t, 20, 50, 30) end, -- Shouldn't really need more than one level
	tactical = { CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then nb = nb + 1 end
		end
		return nb
	end},
	getReduction = function(self, t, e)
		local save_fn = self[type(e) == "table" and self.save_for_effects[e.type] or self.save_for_effects[e]]
		local save = save_fn and save_fn(self, true) or 0
		return math.floor(math.max(2, save/5))
	end,
	action = function(self, t)
		local target = self
		local todel = {}

		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.status == "detrimental" and self.save_for_effects[e.type] then
				local decrease = t.getReduction(self, t, e)
				print(("%s: Reducing duration of %s, using %s, by %d"):tformat(t.name, e.desc, self.save_for_effects[e.type], decrease))
				p.dur = p.dur - decrease
				if p.dur <= 0 then todel[#todel+1] = eff_id end
			end
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local eff_desc = ""
		for e_type, fn in pairs(self.save_for_effects) do
			eff_desc = eff_desc .. ("\n%s effect durations -%d turns"):tformat(_t(e_type):capitalize(), t.getReduction(self, t, e_type))
		end
		return ([[Not the Master himself, nor all the orcs in fallen Reknor, nor even the terrifying unknown beyond Reknor's portal could slow your pursuit of the Staff of Absorption.
		Children will hear of your relentlessness in song for years to come.
		When activated, this ability reduces the duration of all active detrimental effects by 20%% of your associated save value or 2, whichever is greater:
		%s]]):
		tformat(eff_desc)
	end,
}

newTalent{
	short_name = "SHERTUL_FORTRESS_GETOUT",
	name = "Teleport to the ground",
	type = {"base/race", 1},
	no_npc_use = true,
	no_unlearn_last = true,
	on_pre_use = function(self, t) return not game.zone.stellar_map end,
	action = function(self, t)
		if game.level.map:checkAllEntities(self.x, self.y, "block_move") then game.log("You cannot teleport there.") return true end
		game:onTickEnd(function()
			game.party:removeMember(self, true)
			game.party:findSuitablePlayer()
			game.player.dont_act = nil
			game.player:move(self.x, self.y, true)
		end)
		return true
	end,
	info = _t[[Use the onboard short-range teleport of the Fortress to beam down to the surface.
	Requires being in flight above the ground of a planet.]]
}

newTalent{
	short_name = "SHERTUL_FORTRESS_BEAM",
	name = "Fire a blast of energy",
	type = {"base/race", 1},
	fortress_energy = 10,
	no_npc_use = true,
	no_unlearn_last = true,
	on_pre_use = function(self, t) return not game.zone.stellar_map end,
	action = function(self, t)
		for i = 1, 5 do
			local rad = rng.float(0.5, 1)
			local bx = rng.range(-12, 12)
			local by = rng.range(-12, 12)

			if core.shader.active(4) then game.level.map:particleEmitter(self.x, self.y, 1, "shader_ring", {radius=rad * 2, life=12, x=bx, y=by}, {type="sparks", zoom=1, time_factor=400, hide_center=0, color1={0.6, 0.3, 0.8, 1}, color2={0.8, 0, 0.8, 1}})
			else game.level.map:particleEmitter(self.x, self.y, 1, "generic_ball", {rm=150, rM=180, gm=20, gM=60, bm=180, bM=200, am=80, aM=150, radius=rad, x=bx, y=by})
			end
		end

		local target = game.level.map(self.x, self.y, Map.ACTOR)
		if target and target.takePowerHit then
			target:takePowerHit(20, self)
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = _t[[Use 10 Fortress energy to send a powerful blast to the ground, directly below the Fortress, heavily damaging any creatures caught inside.
	Requires being in flight above the ground of a planet.]]
}

newTalent{
	short_name = "SHERTUL_FORTRESS_ORBIT",
	name = "High Planetary Orbit",
	type = {"base/race", 1},
	fortress_energy = 100,
	no_npc_use = true,
	no_unlearn_last = true,
	no_energy = true,
	on_pre_use = function(self, t) return not game.zone.stellar_map end,
	action = function(self, t)
		game:changeLevelReal(1, "stellar-system-shandral", {})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = _t[[Activate the powerful flight engines of the Fortress, propelling it fast into high planetary orbit.
	Requires being in flight above the ground of a planet.]]
}
