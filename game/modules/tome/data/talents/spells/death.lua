-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2020 Nicolas Casalini
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
	name = "Rigor Mortis",
	type = {"spell/death",1},
	require = spells_req1,
	points = 5,
	soul = 1,
	mana = 10,
	range = 10,
	tactical = { ATTACK = { COLD=1, DARK=1 }, DISABLE = 1 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300) end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	on_pre_use_ai = function(self, t)
		local target = self.ai_target.actor
		if not target then return false end

		return true
	end,
	active = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not target then return end

		local mult = 1 + math.log10(nb) * 1.5

		return true
	end,
	info = function(self, t)
		return ([[Press your advantage when your foes are starting to crumble.
		For every detrimental effect on the target you deals %0.2f frostdusk damage per effect (with disminishing returns) and reduce its global speed by 25%% for one turn per effect (up to a maximum of %d).
		]]):tformat(damDesc(self, DamageType.FROSTDUSK, t:_getDamage(self)), t:_getMax(self))
	end,
}

newTalent{
	name = "Drawn To Death",
	type = {"spell/death", 2},
	require = spells_req2,
	points = 5,
	soul = 1,
	cooldown = 15,
	getHeal = function(self, t) return 20 + self:combatTalentSpellDamage(t, 40, 450) end,
	getMana = function(self, t) return 10 + self:combatTalentSpellDamage(t, 40, 180) end,
	getSpellpower = function(self, t) return self:combatTalentScale(t, 15, 50) end,
	tactical = { MANA=1, HEAL=2, BUFF=function(self) return self.life < 1 and 2 or 0 end},
	action = function(self, t, p)
		if self.life < 1 then
			self:setEffect(self.EFF_CONSUME_SOUL, 10, {power=t.getSpellpower(self, t)})
		end
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		self:incMana(t.getMana(self, t))
		return true
	end,	
	info = function(self, t)
		return ([[Consume a soul whole to rebuild your body, healing you by %d and generating %d mana.
		If used below 1 life the surge increases your spellpower by %d for 10 turns.
		The heal and mana increases with your Spellpower.]]):
		tformat(t.getHeal(self, t), t.getMana(self, t), t.getSpellpower(self, t))
	end,
}

newTalent{
	name = "Grim Shadow",
	type = {"spell/death", 3},
	require = spells_req3,
	points = 5,
	mana = 25,
	cooldown = 18,
	tactical = { ATTACKAREA = { COLD=1, DARK=1 }, SOUL=2 },
	radius = 10,
	range = 0,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300) end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), talent=t} end,
	action = function(self, t)
		local dam = self:spellCrit(t.getDamage(self, t))
		local nb = 0
		self:projectApply(self:getTalentTarget(t), self.x, self.y, Map.ACTOR, function(target)
			if not target:hasEffect(target.EFF_SOUL_LEECH) then return end
			if DamageType:get(DamageType.FROSTDUSK).projector(self, target.x, target.y, DamageType.FROSTDUSK, dam) > 0 then
				nb = nb + 1
			end
		end, "hostile")
		self:incSoul(math.min(nb, t.getNb(self, t)))
		return true
	end,
	info = function(self, t)
		return ([[Unleash dark forces to all foes in sight that are afflicted by Soul Leech, dealing %0.2f frostdusk damage to them and tearing apart their souls.
		This returns up to %d souls toyou (based on number of foes hit).
		The damage increases with your Spellpower.]]):
		tformat(damDesc(self, DamageType.FROSTDUSK, t.getDamage(self, t)), t.getNb(self, t))
	end,
}

newTalent{
	name = "Utterly Destroyed",
	type = {"spell/death",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_mana = 30,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 2, 8)) end,
	getMana = function(self, t) return math.floor(self:combatTalentScale(t, 5, 30)) / 10 end,
	getSpellpower = function(self, t) return math.floor(self:combatTalentScale(t, 10, 40)) end,
	getResists = function(self, t) return math.floor(self:combatTalentLimit(t, 20, 5, 10)) end,
	callbackOnActBase = function(self, t)
		if not self.__old_reaping_souls then self.__old_reaping_souls = self:getSoul() end
		if self.__old_reaping_souls == self:getSoul() then return end
		self:updateTalentPassives(t)
	end,
	passives = function(self, t, p)
		if not self:isTalentActive(t.id) then return end
		local s = self:getSoul()
		if s >= 2 then self:talentTemporaryValue(p, "mana_regen", t.getMana(self, t)) end
		if s >= 5 then self:talentTemporaryValue(p, "combat_spellpower", t.getSpellpower(self, t)) end
		if s >= 8 then self:talentTemporaryValue(p, "resists", {all=t.getResists(self, t)}) end
		self:talentTemporaryValue(p, "max_soul", t.getNb(self, t))
	end,
	activate = function(self, t)
		game:onTickEnd(function() self:updateTalentPassives(t) end)
		return {}
	end,
	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[You draw constant power from the souls you hold within your grasp.
		If you hold at least 2, your mana regeneration is increased by %0.1f per turn.
		If you hold at least 5, your spellpower is increased by %d.
		If you hold at least 8, all your resistances are increased by %d.
		Also increases your maximum souls capacity by %d.]]):
		tformat(t.getMana(self, t), t.getSpellpower(self, t), t.getResists(self, t), t.getNb(self, t))
	end,
}
