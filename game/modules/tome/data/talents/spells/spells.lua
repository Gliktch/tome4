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

-- Archmage spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/arcane", name = _t"arcane", description = _t"Arcane studies manipulate the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/aether", name = _t"aether", description = _t"Tap on the core arcane forces of the aether, unleashing devastating effects on your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire", name = _t"fire", description = _t"Harness the power of fire to burn your foes to ashes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/wildfire", name = _t"wildfire", min_lev = 10, description = _t"Harness the power of wildfire to burn your foes to ashes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/earth", name = _t"earth", description = _t"Harness the power of the earth to protect and destroy." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/stone", name = _t"stone", min_lev = 10, description = _t"Harness the power of the stone to protect and destroy." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/water", name = _t"water", description = _t"Harness the power of water to drown your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/ice", name = _t"ice", min_lev = 10, description = _t"Harness the power of ice to freeze and shatter your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/air", name = _t"air", description = _t"Harness the power of the air to fry your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/storm", name = _t"storm", min_lev = 10, description = _t"Harness the power of the storm to incinerate your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/meta", name = _t"meta", description = _t"Meta spells alter the working of magic itself." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/temporal", name = _t"temporal", description = _t"The school of time manipulation." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/phantasm", name = _t"phantasm", description = _t"Control the power of tricks and illusions." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/enhancement", name = _t"enhancement", description = _t"Magical enhancement of your body." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/conveyance", name = _t"conveyance", generic = true, description = _t"Conveyance is the school of travel. It allows you to travel faster and to track others." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/divination", name = _t"divination", generic = true, description = _t"Divination allows the caster to sense its surroundings, and find hidden things." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/aegis", name = _t"aegis", generic = true, description = _t"Command the arcane forces into healing and protection." }

-- Alchemist spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/explosives", name = _t"explosive admixtures", description = _t"Manipulate gems to turn them into explosive magical bombs." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/infusion", name = _t"infusion", description = _t"Infusion your gem bombs with the powers of the elements." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy-base", name = _t"golemancy", hide = true, description = _t"Learn to craft and upgrade your golem." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy", name = _t"golemancy", description = _t"Learn to craft and upgrade your golem." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/advanced-golemancy", name = _t"advanced-golemancy", min_lev = 10, description = _t"Advanced golem operations." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/war-alchemy", name = _t"fire alchemy", description = _t"Alchemical spells designed to wage war." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire-alchemy", name = _t"fire alchemy", description = _t"Alchemical control over fire." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/acid-alchemy", name = _t"acid alchemy", description = _t"Alchemical control over acid." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/frost-alchemy", name = _t"frost alchemy", description = _t"Alchemical control over frost." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/energy-alchemy", name = _t"energy alchemy", min_lev = 10, description = _t"Alchemical control over lightning energies." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy-base", name = _t"stone alchemy", hide = true, description = _t"Manipulate gems, and imbue their powers into other objects." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy", name = _t"stone alchemy", generic = true, description = _t"Alchemical control over stone and gems." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/staff-combat", name = _t"staff combat", generic = true, description = _t"Harness the power of magical staves." }
newTalentType{ type="golem/fighting", name = _t"fighting", description = _t"Golem melee capacity." }
newTalentType{ type="golem/arcane", no_silence=true, is_spell=true, name = _t"arcane", description = _t"Golem arcane capacity." }
newTalentType{ type="golem/golem", name = _t"golem", description = _t"Golem basic capacity." }
newTalentType{ type="golem/drolem", name = _t"drolem", description = _t"Drolem basic capacity." }

-- Necromancer spells
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/master-of-bones", name = _t"master of bones", description = _t"Become of the master of bones, creating skeletal minions to do your bidding." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/master-of-flesh", name = _t"master of flesh", description = _t"Become of the master of flesh, creating ghoul minions to do your bidding" }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/master-necromancer", name = _t"master necromancer", min_lev = 10, description = _t"Full and total control over your undead army." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/nightfall", name = _t"nightfall", description = _t"Manipulate darkness itself to slaughter your foes." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/dreadmaster", name = _t"dreadmaster", description = _t"Summon an undead minion of pure darkness to harass your foes." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/age-of-dusk", name = _t"age of dusk", min_lev = 10, description = _t"Recall the glorious days of the Age of Dusk when necromancers reigned supreme." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/grave", name = _t"grave", description = _t"Use the rotting cold doom of the tomb to fell your foes." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/glacial-waste", name = _t"glacial waste", description = _t"Wither the land into a cold, dead ground to protect yourself." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/rime-wraith", name = _t"rime wraith", min_lev = 10, description = _t"Summon an undead minion of pure cold to harass your foes." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/death", name = _t"death", description = _t"Learn to fasten your foes way into the grave." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/animus", name = _t"animus", description = _t"Crush the souls of your foes to improve yourself." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/eradication", name = _t"eradication", min_lev = 10, description = _t"Doom to all your foes. Crush them." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/necrosis", name = _t"necrosis", generic = true, description = _t"Gain control over death, by unnaturally expanding your life." }
newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, mana_regen=true, type="spell/spectre", name = _t"spectre", generic = true, description = _t"Turn into a spectre to move around the battlefield." }

-- Stone Warden spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/eldritch-shield", name = _t"eldritch shield", description = _t"Infuse arcane forces into your shield." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/eldritch-stone", name = _t"eldritch stone", description = _t"Summon stony spikes imbued with various powers." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/deeprock", name = _t"deeprock", description = _t"Harness the power of the world to turn into a Deeprock Form." }

-- Generic requires for spells based on talent level
spells_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
spells_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
spells_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
spells_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
spells_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
spells_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

-------------------------------------------
-- Necromancer minions
function necroGetNbSummon(self)
	local nb = 0
	if not game.party or not game.party:hasMember(self) then return 0 end
	-- Count party members
	for act, def in pairs(game.party.members) do
		if act.summoner and act.summoner == self and act.necrotic_minion then nb = nb + 1 end
	end
	return nb
end

function applyDarkEmpathy(self, m)
	if self:knowTalent(self.T_DARK_EMPATHY) then
		local t = self:getTalentFromId(self.T_DARK_EMPATHY)
		local perc = t.getPerc(self, t)
		for k, e in pairs(self.resists) do
			m.resists[k] = (m.resists[k] or 0) + e * perc / 100
		end
		for k, e in pairs(self.resists_cap) do
			m.resists_cap[k] = e
		end
		m.combat_physresist = m.combat_physresist + self:combatPhysicalResist() * perc / 100
		m.combat_spellresist = m.combat_spellresist + self:combatSpellResist() * perc / 100
		m.combat_mentalresist = m.combat_mentalresist + self:combatMentalResist() * perc / 100

		m.poison_immune = (m.poison_immune or 0) + (self:attr("poison_immune") or 0) * perc / 100
		m.disease_immune = (m.disease_immune or 0) + (self:attr("disease_immune") or 0) * perc / 100
		m.cut_immune = (m.cut_immune or 0) + (self:attr("cut_immune") or 0) * perc / 100
		m.confusion_immune = (m.confusion_immune or 0) + (self:attr("confusion_immune") or 0) * perc / 100
		m.blind_immune = (m.blind_immune or 0) + (self:attr("blind_immune") or 0) * perc / 100
		m.silence_immune = (m.silence_immune or 0) + (self:attr("silence_immune") or 0) * perc / 100
		m.disarm_immune = (m.disarm_immune or 0) + (self:attr("disarm_immune") or 0) * perc / 100
		m.pin_immune = (m.pin_immune or 0) + (self:attr("pin_immune") or 0) * perc / 100
		m.stun_immune = (m.stun_immune or 0) + (self:attr("stun_immune") or 0) * perc / 100
		m.fear_immune = (m.fear_immune or 0) + (self:attr("fear_immune") or 0) * perc / 100
		m.knockback_immune = (m.knockback_immune or 0) + (self:attr("knockback_immune") or 0) * perc / 100
		m.stone_immune = (m.stone_immune or 0) + (self:attr("stone_immune") or 0) * perc / 100
		m.teleport_immune = (m.teleport_immune or 0) + (self:attr("teleport_immune") or 0) * perc / 100

		m.necrotic_minion_be_nice = self:getTalentLevelRaw(self.T_DARK_EMPATHY) * 0.2
	end
end

function necroSetupSummon(self, m, x, y, level, no_control, no_decay)
	m.faction = self.faction
	m.summoner = self
	m.summoner_gain_exp = true
	m.necrotic_minion = true
	m.exp_worth = 0
	m.life_regen = 0
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.silent_levelup = true
	m.no_points_on_levelup = true
	m.ai_state = m.ai_state or {}
	m.ai_state.tactic_leash = 100
	-- Try to use stored AI talents to preserve tweaking over multiple summons
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	m.inc_damage = table.clone(self.inc_damage, true)
	m.no_breath = 1
	m.no_drops = true

	applyDarkEmpathy(self, m)

	if game.party:hasMember(self) then
		local can_control = not no_control

		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control=can_control and "full" or "no",
			type="minion",
			title=_t"Necrotic Minion",
			orders = {target=true},
		})
	end
	m:resolve() m:resolve(nil, true)
	m.max_level = self.level + (level or 0)
	m:forceLevelup(math.max(1, self.level + (level or 0)))
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "summon")

	-- Summons decay
	if not no_decay then
		m.necrotic_aura_decaying = self.necrotic_aura_decay
		m.on_act = function(self)
			local src = self.summoner
			if src and self.necrotic_aura_decaying and self.x and self.y and not src.dead and src.x and src.y and core.fov.distance(self.x, self.y, src.x, src.y) <= (src.necrotic_aura_radius or 0) then return end

			self.life = self.life - self.max_life * (self.necrotic_aura_decaying or 10) / 100
			self.changed = true
			if self.life <= 0 then
				game.logSeen(self, "#{bold}#%s decays into a pile of ash!#{normal}#", self:getName():capitalize())
				if src then
					local t = src:getTalentFromId(src.T_NECROTIC_AURA)
					t.die_speach(self, t)
				end
				self:die(self)
			end
		end
	end

	m.on_die = function(self, killer)
		if self.on_die_necrotic_minion then self:on_die_necrotic_minion(killer) end
		local src = self.summoner
		local w = src:isTalentActive(src.T_WILL_O__THE_WISP)
		local p = src:isTalentActive(src.T_NECROTIC_AURA)
		if not p or not self.x or not self.y or not src.x or not src.y or core.fov.distance(self.x, self.y, src.x, src.y) > self.summoner.necrotic_aura_radius then return end
		if w and rng.percent(w.chance) then
			local t = src:getTalentFromId(src.T_WILL_O__THE_WISP)
			ret = t.summon(src, t, w.dam, self, killer, false)
			if ret then return end
		end
		if src:getTalentLevel(src.T_AURA_MASTERY) >= 3 and rng.percent(25) then
			src:incSoul(1)
			src.changed = true
			game.logPlayer(src, "A soul returns to %s.", src:getName())
		end
	end

	-- Summons never flee
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0
end

function necroEssenceDead(self, checkonly)
	local eff = self:hasEffect(self.EFF_ESSENCE_OF_THE_DEAD)
	if not eff then return false end
	if checkonly then return true end
	return function()
		eff.nb = eff.nb - 1
		if eff.nb <= 0 then self:removeEffect(self.EFF_ESSENCE_OF_THE_DEAD, true) end
	end
end

function checkLifeThreshold(val, fct)
	return function(self, t)
		local checkid = "__check_threshold_"..t.id
		if not self[checkid] then self[checkid] = self.life end
		if (self[checkid] >= val and self.life < val) or (self[checkid] < val and self.life >= val) then
			fct(self, t)
		end
		self[checkid] = self.life
	end
end
-------------------------------------------

load("/data/talents/spells/arcane.lua")
load("/data/talents/spells/aether.lua")
load("/data/talents/spells/fire.lua")
load("/data/talents/spells/wildfire.lua")
load("/data/talents/spells/earth.lua")
load("/data/talents/spells/stone.lua")
load("/data/talents/spells/water.lua")
load("/data/talents/spells/ice.lua")
load("/data/talents/spells/air.lua")
load("/data/talents/spells/storm.lua")
load("/data/talents/spells/conveyance.lua")
load("/data/talents/spells/aegis.lua")
load("/data/talents/spells/meta.lua")
load("/data/talents/spells/divination.lua")
load("/data/talents/spells/temporal.lua")
load("/data/talents/spells/phantasm.lua")
load("/data/talents/spells/enhancement.lua")

load("/data/talents/spells/explosives.lua")
load("/data/talents/spells/golemancy.lua")
load("/data/talents/spells/advanced-golemancy.lua")
load("/data/talents/spells/staff-combat.lua")
load("/data/talents/spells/war-alchemy.lua")
load("/data/talents/spells/fire-alchemy.lua")
load("/data/talents/spells/frost-alchemy.lua")
load("/data/talents/spells/acid-alchemy.lua")
load("/data/talents/spells/energy-alchemy.lua")
load("/data/talents/spells/stone-alchemy.lua")
load("/data/talents/spells/golem.lua")

load("/data/talents/spells/animus.lua")
load("/data/talents/spells/necrosis.lua")
load("/data/talents/spells/spectre.lua")

load("/data/talents/spells/eldritch-shield.lua")
load("/data/talents/spells/eldritch-stone.lua")
load("/data/talents/spells/deeprock.lua")
