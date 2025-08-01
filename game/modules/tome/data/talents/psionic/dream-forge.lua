-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

newTalent{
	name = "Forge Shield",
	type = {"psionic/dream-forge", 1},
	points = 5, 
	require = psi_wil_high1,
	cooldown = 12,
	sustain_psi = 50,
	mode = "sustained",
	tactical = { DEFEND = 2, },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 5, 30) end,
	getDuration = function(self,t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	doForgeShield = function(type, dam, t, self, src)
		-- Grab our damage threshold
		local dam_threshold = self:getMaxLife() * 0.15
		if self:knowTalent(self.T_SOLIPSISM) then
			local t = self:getTalentFromId(self.T_SOLIPSISM)
			local ratio = t.getConversionRatio(self, t)
			local psi_percent =  self:getMaxPsi() * t.getConversionRatio(self, t)
			dam_threshold = (self:getMaxLife() * (1 - ratio) + psi_percent) * 0.15
		end

		local dur = t.getDuration(self,t)
		local blocked
		local amt = dam
		local eff = self:hasEffect(self.EFF_FORGE_SHIELD)
		if not eff and dam > dam_threshold then
			self:setEffect(self.EFF_FORGE_SHIELD, dur, {power=t.getPower(self, t), number=1, d_types={[type]=true}})
			amt = util.bound(dam - t.getPower(self, t), 0, dam)
			blocked = t.getPower(self, t)
			game.logSeen(self, "#ORANGE#%s forges a dream shield to block the attack!", self:getName():capitalize())
		elseif eff and eff.d_types[type] then
			amt = util.bound(dam - eff.power, 0, dam)
			blocked = eff.power
		elseif eff and dam > dam_threshold * (1 + eff.number) then
			eff.number = eff.number + 1
			eff.d_types[type] = true
			amt = util.bound(dam - eff.power, 0, dam)
			blocked = eff.power
			game.logSeen(self, "#ORANGE#%s's dream shield has been strengthened by the attack!", self:getName():capitalize())
		end

		if blocked then
			print("[Forge Shield] blocked", math.min(blocked, dam), DamageType.dam_def[type].name, "damage")
		end
		
		if amt == 0 and src.life then src:setEffect(src.EFF_COUNTERSTRIKE, 1, {power=t.getPower(self, t), no_ct_effect=true, src=self, nb=1}) end
		return amt
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local ret ={
		}
		if self:knowTalent(self.T_FORGE_ARMOR) then
			local t = self:getTalentFromId(self.T_FORGE_ARMOR)
			ret.def = self:addTemporaryValue("combat_def", t.getDefense(self, t))
			ret.armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t))
			ret.psi = self:addTemporaryValue("psi_regen_when_hit", t.getPsiRegen(self, t))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.def then self:removeTemporaryValue("combat_def", p.def) end
		if p.armor then self:removeTemporaryValue("combat_armor", p.armor) end
		if p.psi then self:removeTemporaryValue("psi_regen_when_hit", p.psi) end
	
		return true	
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local dur = t.getDuration(self, t)
		return ([[When an attack would deal 15%% or more of your effective total health, you forge the Dream Shield to protect yourself, reducing the damage of all attacks of that type by %0.2f for the next %d turn(s).
		You may block multiple damage types at one time, but the base damage threshold increases by 15%% per damage type the shield is already blocking.
		If you block all of an attack's damage, the attacker will be vulnerable to a deadly counterstrike (a normal melee or ranged attack will instead deal 200%% damage) for one turn.
		At talent level 5, the block effect will last two turns.
		This damage reduction scales with your Mindpower.]]):tformat(power, dur)
	end,
}

newTalent{
	name = "Forge Bellows",
	type = {"psionic/dream-forge", 2},
	points = 5, 
	require = psi_wil_high2,
	cooldown = 24,
	psi = 30,
	tactical = { ATTACKAREA = { FIRE = 2, MIND = 2}, ESCAPE = 2, },
	range = 0,
	radius = function(self, t) return math.min(7, 2 + math.ceil(self:getTalentLevel(t)/2)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), friendlyfire=false, radius = self:getTalentRadius(t), talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	getBlastDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	getForgeDamage = function(self, t) return self:combatTalentMindDamage(t, 0, 10) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local blast_damage = self:mindCrit(t.getBlastDamage(self, t))
		local forge_damage = self:mindCrit(t.getForgeDamage(self, t))
		
		-- Do our blast first
		self:project(tg, x, y, DamageType.DREAMFORGE, {dam=blast_damage, dist=math.ceil(tg.radius/2)})
		
		-- Now build our Barrier
		self:project(tg, x, y, function(px, py, tg, self)
			local oe = game.level.map(px, py, Map.TERRAIN)
			if rng.percent(50) or not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
			
			local e = Object.new{
				old_feat = oe,
				type = oe.type, subtype = oe.subtype,
				name = ("%s's forge barrier"):tformat(self:getName():capitalize()),
				image = "terrain/lava/lava_mountain5.png",
				display = '#', color=colors.RED, back_color=colors.DARK_GREY,
				shader = "shadow_simulacrum",
				shader_args = { color = {0.6, 0.0, 0.0}, base = 0.9, time_factor = 1500 },
				always_remember = true,
				desc = _t"a summoned wall of mental energy",
				type = "wall",
				can_pass = {pass_wall=1},
				does_block_move = true,
				show_tooltip = true,
				block_move = true,
				block_sight = true,
				temporary = t.getDuration(self, t),
				x = px, y = py,
				canAct = false,
				dam = forge_damage,
				radius = self:getTalentRadius(t),
				act = function(self)
					local t = self.summoner:getTalentFromId(self.T_FORGE_BELLOWS)
					local tg = {type="ball", range=0, friendlyfire=false, radius = 1, talent=t, x=self.x, y=self.y,}
					self.summoner.__project_source = self
					self.summoner:project(tg, self.x, self.y, engine.DamageType.DREAMFORGE, self.dam)
					self.summoner.__project_source = nil
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.level.map:updateMap(self.x, self.y)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end,
				dig = function(src, x, y, old)
					game.level:removeEntity(old, true)
					return nil, old.old_feat
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			e.tooltip = mod.class.Grid.tooltip
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN, e)
			game.nicer_tiles:updateAround(game.level, px, py)
			game.level.map:updateMap(px, py)
		end)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local blast_damage = t.getBlastDamage(self, t)/2
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		local forge_damage = t.getForgeDamage(self, t)/2
		return ([[Release the bellows of the forge upon your surroundings, inflicting %0.2f mind damage, %0.2f burning damage, and knocking back your enemies in a radius %d cone.
		Empty terrain may be changed (50%% chance) for %d turns into forge walls, which block movement and inflict %0.2f mind and %0.2f fire damage on nearby enemies.
		The damage and knockback chance will scale with your Mindpower.]]):
		tformat(damDesc(self, DamageType.MIND, blast_damage), damDesc(self, DamageType.FIRE, blast_damage), radius, duration, damDesc(self, DamageType.MIND, forge_damage), damDesc(self, DamageType.FIRE, forge_damage))
	end,
}

newTalent{
	name = "Forge Armor",
	type = {"psionic/dream-forge", 3},
	points = 5,
	require = psi_wil_high3,
	mode = "passive",
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 1, 15) end,
	getDefense = function(self, t) return self:combatTalentMindDamage(t, 1, 15) end,
	getPsiRegen = function(self, t) return self:combatTalentMindDamage(t, 1, 10) end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		local defense = t.getDefense(self, t)
		local psi = t.getPsiRegen(self, t)
		return([[Your Forge Shield talent now increases your Armour by %d, your Defense by %d, and gives you %0.2f psi when you're hit by a melee or ranged attack.
		The bonuses will scale with your Mindpower.]]):tformat(armor, defense, psi)
	end,
}

newTalent{
	name = "Dreamforge",
	type = {"psionic/dream-forge", 4},
	points = 5, 
	require = psi_wil_high4,
	cooldown = 12,
	sustain_psi = 50,
	mode = "sustained",
	no_sustain_autoreset = true,
	tactical = { ATTACKAREA = { FIRE = 2, MIND = 2}, DISABLE = 2, },
	range = 0,
	radius = function(self, t) return math.min(5, 1 + math.ceil(self:getTalentLevel(t)/3)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius = self:getTalentRadius(t), talent=t}
	end,
	getDamage = function(self, t) return math.ceil(self:combatTalentMindDamage(t, 5, 30)) end,
	getPower = function(self, t) return math.floor(self:combatTalentMindDamage(t, 5, 25)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 8, 30) end, --Limit < 100%
	getFailChance = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 5, 25), 67, 0, 0, 16.34, 16.34) end, -- Limit to <67%
	
	callbackOnActBase = function(self, t, p)
		local p = self:isTalentActive(t.id)
		-- If we moved reset the forge
		if self.x ~= p.x or self.y ~= p.y or p.new then
			p.x = self.x; p.y=self.y; p.radius=0; p.damage=0; p.power=0; p.new = nil;
		-- Otherwise we strike the forge
		elseif not self.resting then
			local max_radius = self:getTalentRadius(t)
			local max_damage = t.getDamage(self, t)
			local power = t.getPower(self, t)
			p.radius = math.min(p.radius + 1, max_radius)

			if p.damage < max_damage then
				p.radius = math.min(p.radius + 1, max_radius)
				p.damage = math.min(max_damage/4 + p.damage, max_damage)
				game.logSeen(self, "#GOLD#%s strikes the dreamforge!", self:getName():capitalize())
			elseif p.power == 0 then
				p.power = power
				game.logSeen(self, "#GOLD#%s begins breaking dreams!", self:getName():capitalize())
				game:playSoundNear(self, "talents/lightning_loud")
			end
			local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=p.radius, talent=t}
			-- Spell failure handled under "DREAMFORGE" damage type in data\damage_types.lua and transferred to "BROKEN_DREAM" effect in data\timed_effects\mental.lua
			self:project(tg, self.x, self.y, engine.DamageType.DREAMFORGE, {dam=self:mindCrit(p.damage), power=p.power, fail=t.getFailChance(self,t), dur=p.dur, chance=p.chance, do_particles=true })
		end
	end,
	activate = function(self, t)
		local ret ={
			x = self.x, y=self.y, radius=0, damage=0, power=0, new = true, dur=t.getDuration(self, t), chance=t.getChance(self, t)
		}
		game:playSoundNear(self, "talents/devouringflame")
		return ret
	end,
	deactivate = function(self, t, p)
		return true	
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)/2
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local fail = t.getFailChance(self,t)
		return ([[The pounding forge of thought in your mind is released upon your surroundings.  Each turn that you remain stationary, you'll strike the dreamforge, inflicting mind and burning damage on enemies around you.
		The effect will build over five turns, until it reaches a maximum radius of %d, maximum mind damage of %0.2f, and maximum burning damage of %0.2f.
		At this point you'll begin breaking the dreams of enemies who hear the forge, reducing their Mental Save by %d and giving them a %d%% chance of spell failure due to the tremendous echo in their minds for %d turns %s.
		Broken Dreams has a %d%% chance to brainlock your enemies %s.
		The damage and dream breaking effect will scale with your Mindpower.]]):
		tformat(radius, damDesc(self, DamageType.MIND, damage), damDesc(self, DamageType.FIRE, damage), power, fail, duration, Desc.vs"mm", chance, Desc.vs"mm")
	end,
}
