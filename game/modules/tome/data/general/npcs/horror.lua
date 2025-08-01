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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_HORROR",
	type = "horror", subtype = "eldritch",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	faction = "horrors",

	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	combat_armor = 5, combat_def = 10,
	combat = { dam=5, atk=10, apr=5, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	no_breath = 1,
	fear_immune = 1,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "worm that walks", color=colors.SANDY_BROWN,
	desc = _t[[A bulging rotten robe seems to tear at the seams, with masses of bloated worms spilling out all around the moving form.  Two arm-like appendages, each made up of overlapping mucous-drenched maggots, grasp tightly around the handles of bile-coated waraxes.
Each swing drips pustulant fluid before it, and each droplet writhes and wriggles in the air before splashing against the ground.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(150,170),
	life_rating = 16,
	rank = 3,
	hate_regen = 10,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
	ai_tactic = resolvers.tactic "melee",

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	disease_immune = 1,

	combat_spellpower = resolvers.levelup(10, 1, 1),


	resists = { [DamageType.PHYSICAL] = 50, [DamageType.ACID] = 100, [DamageType.BLIGHT] = 100, [DamageType.FIRE] = -50},
	inc_damage = { [DamageType.BLIGHT] = 20, },
	damage_affinity = { [DamageType.BLIGHT] = 50 },
	no_auto_resists = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="waraxe", ego_chance = 100, autoreq=true},
		{type="weapon", subtype="waraxe", ego_chance = 100, autoreq=true},
		{type="armor", subtype="cloth", ego_chance = 100, autoreq=true}
	},

	talent_cd_reduction = {[Talents.T_BLINDSIDE]=4},

	resolvers.inscriptions(1, {"regeneration infusion"}),

	resolvers.talents{
		[Talents.T_DRAIN]={base=5, every=10, max=7},
		[Talents.T_WORM_ROT]={base=4, every=8},
		[Talents.T_EPIDEMIC]={base=4, every=8},
		[Talents.T_REND]={base=2, every=8},
		[Talents.T_ACID_STRIKE]={base=2, every=8},
		[Talents.T_BLOODLUST]={base=2, every=8},
		[Talents.T_RUIN]={base=2, every=8},
		[Talents.T_CORRUPTED_STRENGTH]={base=2, every=8},

		[Talents.T_BLINDSIDE]={base=3, every=12},

		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=6},
	},

	resolvers.sustains_at_birth(),

	on_takehit = function(self, value, src)
		if value >= (self.max_life * 0.1) then
			local t = self:getTalentFromId(self.T_WORM_ROT)
			t.spawn_carrion_worm(self, self, t)
			game.logSeen(self, "#LIGHT_RED#A carrion worm mass has spawned from %s' wounds!", self:getName())
		end
		return value
	end,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "bloated horror", color=colors.WHITE,
	desc =_t"A bulbous humanoid form floats here. Its bald, child-like head is disproportionately large compared to its body, and its skin is pock-marked with nasty red sores.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 4,
	autolevel = "wildcaster",
	combat_armor = 1, combat_def = 0, combat_def_ranged = resolvers.mbonus(30, 15),
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={mag=0.6}},

	never_move = 1,
	levitation = 1,

	resists = {all = 35, [DamageType.LIGHT] = -30},

	resolvers.talents{
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_MIND_DISRUPTION]={base=2, every=6, max=7},
		[Talents.T_MIND_SEAR]={base=2, every=6, max=7},
		[Talents.T_TELEKINETIC_BLAST]={base=2, every=6, max=7},
	},

	resolvers.inscriptions(1, {"shielding rune"}),

	resolvers.sustains_at_birth(),
	ingredient_on_death = "BLOATED_HORROR_HEART",
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "nightmare horror", color=colors.DARK_GREY,
	desc =_t"A shifting form of darkest night that seems to reflect your deepest fears.",
	level_range = {35, nil}, exp_worth = 1,
	mana_regen = 10,
	negative_regen = 10,
	hate_regen = 10,
	psi_regen = 10,
	rarity = 8,
	rank = 3,
	max_life = resolvers.rngavg(150,170),
	life_rating = 16,
	autolevel = "spider",
	combat_armor = 1, combat_def = 30,
	combat = { dam=resolvers.levelup(20, 1, 1.1), atk=20, apr=50, dammod={mag=1}, damtype=DamageType.DARKSTUN},

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	ai_state = { ai_target="target_player_radius", sense_radius=10, talent_in=1, },
	dont_pass_target = true,

	can_pass = {pass_wall=20},
	resists = {all = 35, [DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},

	negative_status_effect_immune = 1,
	combat_spellpower = resolvers.levelup(30, 1, 2),
	combat_mindpower = resolvers.levelup(30, 1, 2),

	resolvers.talents{
		[Talents.T_STEALTH]={base=5, every=12, max=8},
		[Talents.T_GLOOM]={base=3, every=12, max=8},
		[Talents.T_WEAKNESS]={base=3, every=12, max=8},
		[Talents.T_DISMAY]={base=3, every=12, max=8},
		[Talents.T_DOMINATE]={base=3, every=12, max=8},
		-- DGDGDGDG
		-- [Talents.T_INVOKE_DARKNESS]={base=5, every=8, max=10},
		[Talents.T_NIGHTMARE]={base=5, every=8, max=10},
		[Talents.T_WAKING_NIGHTMARE]={base=3, every=8, max=10},
		[Talents.T_ABYSSAL_SHROUD]={base=3, every=8, max=8},
		[Talents.T_INNER_DEMONS]={base=3, every=8, max=10},
	},

	resolvers.inscriptions(1, {"shielding rune"}),

	resolvers.sustains_at_birth(),
}


------------------------------------------------------------------------
-- Headless horror and its eyes
------------------------------------------------------------------------
newEntity{ base = "BASE_NPC_HORROR",
	name = "headless horror", color=colors.TAN,
	desc =_t"A headless, gangly humanoid with a large distended stomach.",
	level_range = {30, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(200,220),
	life_rating = 16,
	autolevel = "warrior",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	combat = { dam=20, atk=20, apr=10, dammod={str=1} },
	combat = {damtype=DamageType.PHYSICAL},
	no_auto_resists = true,
	move_others=true,
	is_headless_horror = true,

	-- Should get resists based on eyes generated, 30% all per eye and 100% to the eyes element.  Should lose said resists when the eyes die.

	-- Should be blind but see through the eye escorts
	--blind= 1,

	resolvers.talents{
		[Talents.T_MANA_CLASH]={base=4, every=5, max=8},
		[Talents.T_CLINCH]={base=4, every=6, max=8},
		[Talents.T_TAKE_DOWN]={base=4, every=5, max=8},
		[Talents.T_CRUSHING_HOLD]={base=4, every=5, max=8},
	},

	resolvers.inscriptions(1, {"healing infusion"}),
	--resolvers.inscriptions(2, "rune"),

	-- Add eyes
	on_added_to_level = function(self)
		game:onTickEnd(function() --spawn escorts after all other actors are placed
			local eyes = {}
			for i = 1, 3 do
				local x, y = util.findFreeGrid(self.x, self.y, 15, true, {[engine.Map.ACTOR]=true})
				if x and y then
					local m = game.zone:makeEntity(game.level, "actor", {properties={"is_eldritch_eye"}, special_rarity="_eldritch_eye_rarity"}, nil, true)
					if m then
						m.summoner = self
						game.zone:addEntity(game.level, m, "actor", x, y)
						eyes[m] = true

						-- Grant resist
						local damtype = next(m.resists)
						self.resists[damtype] = 100
						self.resists.all = (self.resists.all or 0) + 30
					end
				end
			end
			self.eyes = eyes
		end)
	end,

	-- Needs an on death affect that kills off any remaining eyes.
	on_die = function(self, src)
		local nb = 0
		for eye, _ in pairs(self.eyes or {}) do
			if not eye.dead then eye:die(src) nb = nb + 1 end
		end
		if nb > 0 then
			game.logSeen(self, "#AQUAMARINE#As %s falls all its eyes fall to the ground!", self:getName())
		end
	end,
}

newEntity{ base = "BASE_NPC_HORROR", define_as = "BASE_NPC_ELDRICTH_EYE",
	name = "eldritch eye", color=colors.SLATE, is_eldritch_eye=true,
	desc =_t"A small bloodshot eye floats here.",
	level_range = {30, nil}, exp_worth = 1,
	life_rating = 7,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	combat_armor = 1, combat_def = 0,
	levitation = 1,
	no_auto_resists = true,
	talent_cd_reduction = {all=100},

	on_die = function(self, src)
		if not self.summoner or not self.summoner.is_headless_horror then return end
		self:logCombat(self.summoner, "#AQUAMARINE#As #Source# falls #Target# seems to weaken!")
		local damtype = next(self.resists)
		self.summoner.resists.all = (self.summoner.resists.all or 0) - 30
		self.summoner.resists[damtype] = nil

		-- Blind the main horror if no more eyes
		local nb = 0
		for eye, _ in pairs(self.summoner.eyes or {}) do
			if not eye.dead then nb = nb + 1 end
		end
		if nb == 0 and self.summoner and self.summoner.is_headless_horror then
			local sx, sy = game.level.map:getTileToScreen(self.summoner.x, self.summoner.y, true)
			game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, _t"+Blind", {255,100,80})
			self.summoner.blind = 1
			game.logSeen(self.summoner, "%s is blinded by the loss of all its eyes.", self.summoner:getName():capitalize())
		end
	end,
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--fire
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.FIRE] = 80},
	resolvers.talents{
		[Talents.T_BURNING_HEX]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--cold
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.COLD] = 80},
	resolvers.talents{
		[Talents.T_ICE_SHARDS]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--earth
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.PHYSICAL] = 80},
	resolvers.talents{
		[Talents.T_STRIKE]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--arcane
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.ARCANE] = 80},
	resolvers.talents{
		[Talents.T_MANATHRUST]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--acid
	_eldritch_eye_rarity = 1,
	equilibrium_regen = -100,
	resists = {[DamageType.ACID] = 80},
	nature_summon_max = -1,
	resolvers.talents{
		[Talents.T_HYDRA]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--dark
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.DARKNESS] = 80},
	resolvers.talents{
		[Talents.T_CURSE_OF_DEATH]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--light
	_eldritch_eye_rarity = 1,
	resists = {[DamageType.LIGHT] = 80},
	resolvers.talents{
		[Talents.T_SEARING_LIGHT]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--lightning
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.LIGHTNING] = 80},
	resolvers.talents{
		[Talents.T_LIGHTNING]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--blight
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.BLIGHT] = 80},
	resolvers.talents{
		[Talents.T_VIRULENT_DISEASE]=3,
		[Talents.T_DRAIN]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--nature
	_eldritch_eye_rarity = 1,
	equilibrium_regen = -100,
	resists = {[DamageType.NATURE] = 80},
	resolvers.talents{
		[Talents.T_SPIT_POISON]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--mind
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.MIND] = 80},
	resolvers.talents{
		[Talents.T_MIND_DISRUPTION]=3,
	},
}
-- TODO: Make Luminous and Radiant Horrors cooler
newEntity{ base = "BASE_NPC_HORROR",
	name = "luminous horror", color=colors.YELLOW,
	desc =_t"A lanky humanoid shape composed of yellow light.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	autolevel = "caster",
	combat_armor = 1, combat_def = 10,
	combat = { dam=5, atk=15, apr=20, dammod={mag=0.6}, damtype=DamageType.LIGHT},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1.5, },
	lite = 3,

	resists = {all = 35, [DamageType.DARKNESS] = -50, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100},
	damage_affinity = { [DamageType.LIGHT] = 50,  [DamageType.FIRE] = 50, },

	blind_immune = 1,
	see_invisible = 10,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE]={base=3, every=6, max=8},
		[Talents.T_SEARING_LIGHT]={base=3, every=6, max=8},
		[Talents.T_FIREBEAM]={base=3, every=6, max=8},
		[Talents.T_PROVIDENCE]={base=3, every=6, max=8},
		[Talents.T_HEALING_LIGHT]={base=1, every=6, max=8},
		[Talents.T_BARRIER]={base=1, every=6, max=8},
	},

	resolvers.sustains_at_birth(),

	make_escort = {
		{type="horror", subtype="eldritch", name="luminous horror", number=2, no_subescort=true},
	},
	ingredient_on_death = "LUMINOUS_HORROR_DUST",
	power_source = {arcane=true},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "radiant horror", color=colors.GOLD,
	desc =_t"A lanky four-armed humanoid shape composed of bright golden light.  It's so bright it's hard to look at, and you can feel heat radiating outward from it.",
	level_range = {35, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	autolevel = "caster",
	max_life = resolvers.rngavg(220,250),
	life_rating = 16,
	combat_armor = 1, combat_def = 10,
	combat = { dam=20, atk=30, apr=40, dammod={mag=1}, damtype=DamageType.LIGHT},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	lite = 5,

	resists = {all = 40, [DamageType.DARKNESS] = -50, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100},
	damage_affinity = { [DamageType.LIGHT] = 50,  [DamageType.FIRE] = 50, },

	blind_immune = 1,
	see_invisible = 20,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE]={base=10, every=15},
		[Talents.T_CIRCLE_OF_BLAZING_LIGHT]={base=10, every=15},
		[Talents.T_SEARING_LIGHT]={base=10, every=15},
		[Talents.T_FIREBEAM]={base=10, every=15},
		[Talents.T_SUNBURST]={base=10, every=15},
		[Talents.T_SUN_FLARE]={base=10, every=15},
		[Talents.T_PROVIDENCE]={base=10, every=15},
		[Talents.T_HEALING_LIGHT]={base=10, every=15},
		[Talents.T_BARRIER]={base=10, every=15},
	},

	resolvers.sustains_at_birth(),
	power_source = {arcane=true},

	make_escort = {
		{type="horror", subtype="eldritch", name="luminous horror", number=1, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	subtype = "eldritch",
	name = "devourer", color=colors.CRIMSON,
	desc = _t"A headless, round creature with stubby legs and arms.  Its body seems to be all teeth.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	movement_speed = 0.8,
	size_category = 2,
	autolevel = "zerker",
	max_life = resolvers.rngavg(80, 100),
	life_rating = 14,
	life_regen = 4,
	combat_armor = 16, combat_def = 1,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,40), 1, 0.6), atk=resolvers.rngavg(25,50), apr=25, dammod={str=1.1}, physcrit = 10 },
	ai_state = { talent_in=1.5, },

	resolvers.talents{
		[Talents.T_BLOODBATH]={base=1, every=5, max=7},
		[Talents.T_GNASHING_TEETH]={base=1, every=5, max=7},
		-- talents only usable while frenzied
		[Talents.T_FRENZIED_LEAP]={base=1, every=5, max=7},
		[Talents.T_FRENZIED_BITE]={base=1, every=5, max=7},
	},

	make_escort = {
		{type="horror", subtype="eldritch", name="devourer", number=2, no_subescort=true},
	},
}

--Blade horror, psionic horror surrounded by countless telekinetic blades.
newEntity{ base = "BASE_NPC_HORROR",
	name = "blade horror", color=colors.GREY, define_as="BLADEHORROR",
	desc = _t"Blades whirl in the air around this thin, floating figure. The air around it swirls with force, threatening to tear apart anything that approches, if the blades don't do it first.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_eldritch_blade_horror.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	levitate=1,
	max_psi= 300,
	psi_regen= 4,
	size_category = 3,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(70, 95),
	life_rating = 12,
	life_regen = 0.25,
	combat_armor = 12, combat_def = 24,

	rnd_boss_init = function(self, data)
		self.combat_physspeed = math.max(1, self.combat_physspeed - 2)  -- A bit more sanity when randbossed
	end,

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=2, ally_compassion=0 },

	combat = { dam=resolvers.levelup(resolvers.rngavg(16,22), 1, 1.5), atk=resolvers.levelup(18, 1, 1), apr=4, dammod={wil=0.25, cun=0.1}, damtype=DamageType.PHYSICALBLEED, },
	combat_physspeed = 4, --Crazy fast attack rate

	resists = {[DamageType.PHYSICAL] = 10, [DamageType.MIND] = 40, [DamageType.ARCANE] = -20},

	resolvers.talents{
		[Talents.T_KNIFE_STORM]={base=3, every=6, max=7},
		[Talents.T_IMPLODE]={base=1, every=8, max=4},
		[Talents.T_RAZOR_KNIFE]={base=1, every=6, max=5},
		[Talents.T_PSIONIC_PULL]={base=1, every=6, max=5},
		[Talents.T_KINETIC_AURA]={base=1, every=4, max=7},
		[Talents.T_KINETIC_SHIELD]={base=1, every=3, max=6},
		[Talents.T_KINETIC_LEECH]={base=2, every=5, max=5},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR",
	subtype = "eldritch",
	name = "oozing horror", color=colors.GREEN,
	desc = _t"A massive, amorphous blob of green slime crawls on the ground towards you. Eyes drift through the viscous mass, scanning for potential prey.",
	level_range = {16, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	movement_speed = 0.7,
	size_category = 4,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(100, 120),
	life_rating = 20,
	life_regen = 3,
	combat_armor = 15, combat_def = 24,

	on_move = function(self)
			local DamageType = require "engine.DamageType"
			local MapEffect = require "engine.MapEffect"
			local duration = 10
			local radius = 0
			local dam = 25
			-- Add a lasting map effect
			game.level.map:addEffect(self,
				self.x, self.y, duration,
				engine.DamageType.SLIME, 25,
				radius,
				5, nil,
				MapEffect.new{color_br=25, color_bg=140, color_bb=40, effect_shader="shader_images/retch_effect.png"},
				function(e, update_shape_only)
					if not update_shape_only then e.radius = e.radius end
					return true
				end,
				false
			)
	end,

	on_melee_hit = {[DamageType.SLIME]=resolvers.mbonus(16, 2), [DamageType.ACID]=resolvers.mbonus(14, 2)},
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(40,50), 1, 0.9),
		atk=resolvers.rngavg(25,50), apr=25,
		dammod={wil=1.1}, physcrit = 10,
		damtype=engine.DamageType.SLIME,
	},

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },

	resists = {all=15, [DamageType.PHYSICAL] = -10, [DamageType.NATURE] = 100, [DamageType.ARCANE] = 40, [DamageType.BLIGHT] = 24},

	resolvers.talents{
			[Talents.T_RESOLVE]={base=3, every=6, max=8},
			[Talents.T_MANA_CLASH]={base=1, every=6, max=7},
			[Talents.T_OOZE_SPIT]={base=1, every=8, max=4},
			[Talents.T_OOZE_ROOTS]={base=3, every=6, max=7},
			[Talents.T_SLIME_WAVE]={base=2, every=8, max=7},
			[Talents.T_TENTACLE_GRAB]={base=2, every=7, max=6},
	},
	power_source = {antimagic=true},
}

newEntity{ base = "BASE_NPC_HORROR",
	subtype = "eldritch",
	name = "umbral horror", color=colors.BLACK,
	desc = _t"A dark shifting shape stalks through the shadows, blending in seamlessly.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_eldritch_umbral_horror.png", display_h=2, display_y=-1}}},
	level_range = {16, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	movement_speed = 1.2,
	size_category = 2,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(100, 120),
	life_rating = 20,
	life_regen = 0.25,
	hate_regen=4,
	combat_armor = 0, combat_def = 24,

	combat = {
		dam=resolvers.levelup(resolvers.rngavg(36,45), 1, 1.2),
		atk=resolvers.rngavg(25,35), apr=20,
		dammod={wil=0.8}, physcrit = 12,
		damtype=engine.DamageType.DARKNESS,
	},
	combat_physspeed = 2,

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },

	resists = {[DamageType.PHYSICAL] = -10, [DamageType.DARKNESS] = 100, [DamageType.LIGHT] = -60},

	resolvers.talents{
			[Talents.T_CALL_SHADOWS]={base=3, every=6, max=10},
			[Talents.T_STEALTH]={base=4, every=5, max=10},
			[Talents.T_PHASE_DOOR]=1,
			[Talents.T_BLINDSIDE]={base=2, every=8, max=5},
			[Talents.T_DARK_TORRENT]={base=1, every=5, max=8},
			[Talents.T_CREEPING_DARKNESS]={base=2, every=4, max=10},
			[Talents.T_DARK_VISION]=5,
			[Talents.T_FOCUS_SHADOWS]={base=4, every=5, max=10},
			[Talents.T_SHADOW_WARRIORS]={base=1, every=8, max=5},
	},
		resolvers.sustains_at_birth(),
}

-- Dream Horror
newEntity{ base = "BASE_NPC_HORROR",
	name = "dreaming horror", color=colors.ORCHID,
	desc =_t[[A vaguely tentacled yet constantly changing form rests here apparently oblivious to your existence.
With each slow breath it takes reality distorts around it.  Blue twirls into red, green twists into yellow, and the air sings softly before bursting into a myriad of pastel shapes and colors.]],
	resolvers.nice_tile{tall=1},
	shader = "shadow_simulacrum",
	shader_args = { color = {0.5, 0.5, 1.0}, base = 0.8, time_factor= 2000 },
	level_range = {20, nil}, exp_worth = 1,
	rarity = 30,  -- Very rare; should feel almost like uniques though they aren't
	rank = 3,
	max_life = 100,  -- Solipsism will take care of hit points
	life_rating = 4, 
	psi_rating = 6,
	autolevel = "wildcaster",
	combat_armor = 1, combat_def = 15,
	combat = { dam=resolvers.levelup(20, 1, 1.1), atk=20, apr=20, dammod={wil=1}, damtype=DamageType.MIND},

	ai = "tactical", -- ai_tactic = resolvers.tactic"ranged",
	ai_state = { ai_target="target_player_radius", sense_radius=20, talent_in=1 }, -- Huge radius for projections to target
	dont_pass_target = true,
	summon = {{type="horror", subtype="eldritch", name="dream seed", number=5, hasxp=false}, },

	resists = { all = 35 },

	combat_mindpower = resolvers.levelup(30, 1, 2),
	
	body = { INVEN = 10 },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} }, -- Gives good loot to encourage the player to wake it up

	resolvers.talents{
		[Talents.T_DISTORTION_BOLT]={base=4, every=6, max=8},
		[Talents.T_DISTORTION_WAVE]={base=4, every=6, max=8},
		[Talents.T_MAELSTROM]={base=4, every=6, max=8},
		[Talents.T_RAVAGE]={base=4, every=6, max=8},
		
		[Talents.T_BIOFEEDBACK]={base=4, every=6, max=8},
		[Talents.T_RESONANCE_FIELD]={base=4, every=6, max=8},
		[Talents.T_BACKLASH]={base=4, every=6, max=8},
		[Talents.T_AMPLIFICATION]={base=4, every=6, max=8},
		[Talents.T_CONVERSION]={base=4, every=6, max=8},
		
		[Talents.T_MENTAL_SHIELDING]={base=4, every=6, max=8},

		[Talents.T_SOLIPSISM]={base=7, every=15, max=5}, -- High solipsism is a lot like resist all
		[Talents.T_BALANCE]={base=4, every=6, max=8},
		[Talents.T_CLARITY]={base=4, every=6, max=8},
		[Talents.T_DISMISSAL]={base=4, every=6, max=8},

		[Talents.T_LUCID_DREAMER]={base=4, every=12, max=8},
		[Talents.T_DREAM_WALK]={base=4, every=12, max=8},
		[Talents.T_SLUMBER]={base=4, every=6, max=8},
		[Talents.T_SLEEP]={base=4, every=6, max=8},
		[Talents.T_RESTLESS_NIGHT]={base=4, every=6, max=8},
		[Talents.T_SANDMAN]={base=4, every=6, max=8},
		--[Talents.T_DREAMSCAPE]={base=4, every=5, max=10},
		
		-- Summon Dream Seeds while awake
		[Talents.T_SUMMON]=1,
	},

	resolvers.inscriptions(2, {"regeneration infusion", "phase door rune"}, nil, true),  -- Really has a phase door rune :P
	power_source = {psionic=true},
	resolvers.sustains_at_birth(),

	-- Used to track if he's awake or spawning projections
	dreamer_sleep_state = 1,
	-- And some particles to show that we're asleep
	resolvers.genericlast(function(e)
		if core.shader.active(4) then
			e.sleep_particle = e:addParticles(engine.Particles.new("shader_shield", 1, {img="shield7", size_factor=1.5, y=-0.3}, {type="shield", ellipsoidalFactor=1.5, time_factor=6000, aadjust=7, color={0.6, 1, 0.6}}))
		else
			e.sleep_particle = e:addParticles(engine.Particles.new("generic_shield", 1, {r=0.6, g=1, b=0.6, a=1}))
		end
	end),

	custom_tooltip = function(self)
		if self.dreamer_sleep_state then
			return tstring{{"color", "LIGHT_BLUE"}, _t"It looks asleep and dreamy."}
		else
			return tstring{{"color", "LIGHT_RED"}, _t"It looks awake, beware!"}
		end
	end,

	-- Spawn Dream Seeds
	on_act = function(self)
		if self.dreamer_sleep_state and self.ai_target.actor then 
			self.dreamer_sleep_state = math.min(self.dreamer_sleep_state + 1, 31) -- Caps at 31 so a new one doesn't spawn as soon as an old one dies
			self:useEnergy() -- Always use energy when in the sleep state

			if self.dreamer_sleep_state%10 == 0 and self.dreamer_sleep_state <= 30 then
				-- Find Space
				local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[engine.Map.ACTOR]=true})
				if not x then
					return
				end
				
				local seed = {type="horror", subtype="eldritch", name="dream seed"}
				local list = mod.class.NPC:loadList("/data/general/npcs/horror.lua")
				local m = list.DREAM_SEED:clone()
				if not m then return nil end
				
				m.exp_worth = 0
				m.summoner = self			
				m:resolve() m:resolve(nil, true)
				m:forceLevelup(self.level)
				game.zone:addEntity(game.level, m, "actor", x, y)
				
				game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
				game.logSeen(self, "#LIGHT_BLUE#A dream seed escapes %s's sleeping mind.", self:getName():capitalize())
			end
		-- Script the AI to encourage opening with dream scape
		--[[  Disabled temporarily due to unknown bugs with Dreamscape
		elseif self.ai_target.actor and self.ai_target.actor.game_ender and not game.zone.is_dream_scape then
			if not self:isTalentCoolingDown(self.T_SLEEP) then
				self:forceUseTalent(self.T_SLEEP, {})
			elseif not self:isTalentCoolingDown(self.T_DREAMSCAPE) and self.ai_target.actor:attr("sleep") then
				self:forceUseTalent(self.T_DREAMSCAPE, {})
			end]]
		end
	end,
	on_acquire_target = function(self, who)
		self:useEnergy() -- Use energy as soon as we find a target so we don't move
	end,
	on_takehit = function(self, value, src)
		if value > 0 and self.dreamer_sleep_state then
			self.dreamer_sleep_state = nil
			self.desc = _t[[A vaguely tentacled yet rapidly changing shape floats here.  With each breath you can feel reality twist, shatter, and break. 
Blue burns into red, green bursts into yellow, and the air crackles and hisses before exploding into a thousand fragments of sharp shapes and colors.]]
			self:removeParticles(self.sleep_particle)
			game.logSeen(self, "#LIGHT_BLUE#The sleeper stirs...")
		end
		return value
	end,
}

newEntity{ base = "BASE_NPC_HORROR", define_as = "DREAM_SEED",
	name = "dream seed", color=colors.PINK, image = "npc/dream_seed.png",
	desc =_t"A pinkish bubble floats here, reflecting the world not as it is, but as it would be in that surreal place that exists only in our dreams.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 30,  -- Very rare; but they do spawn on their own to keep the players on thier toes
	rank = 2,
	max_life = 1, life_rating = 4,  -- Solipsism will take care of hit points
	autolevel = "wildcaster",

	ai = "tactical",
	ai_state = { ai_target="target_player_radius", sense_radius=20, talent_in=3, },
	dont_pass_target = true,
	can_pass = {pass_wall=20},
	levitation = 1,

	combat_armor = 1, combat_def = 5,
	combat = { dam=resolvers.levelup(20, 1, 1.1), atk=10, apr=10, dammod={wil=1}, damtype=engine.DamageType.MIND},

	resolvers.talents{
		[Talents.T_BACKLASH]={base=2, every=6, max=8},
		[Talents.T_DISTORTION_BOLT]={base=2, every=6, max=8},
		[Talents.T_SOLIPSISM]={base=7, every=15, max=5},
		[Talents.T_SLEEP]={base=2, every=6, max=8},
		[Talents.T_LUCID_DREAMER]={base=2, every=6, max=8},
		[Talents.T_DREAM_WALK]=5,
	},

	resolvers.sustains_at_birth(),
	power_source = {psionic=true},

	-- Remove ourselves from the dream seed limit
	on_die = function(self)
		if self.summoner and self.summoner.dreamer_sleep_state then
			self.summoner.dreamer_sleep_state = self.summoner.dreamer_sleep_state - 10
		end
	end,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "maelstrom", color=colors.CADET_BLUE,
	resolvers.nice_tile{tall=1},
	desc = _t[[This powerful vortex of ice and lightning somehow gives you the impression of claws, teeth and intense hunger...]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 20,
	rank = 3,
	max_life = resolvers.rngavg(70,80),
	autolevel = "caster",
	mana_rating = 10,
	mana_regen = 10,
	equilibrium_regen = -1,
	combat_armor = 0, combat_def = 20,
	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.LIGHTNING },
	on_melee_hit = { [DamageType.COLD] = resolvers.mbonus(20, 10), [DamageType.LIGHTNING] = resolvers.mbonus(20, 10), },

	ai = "tactical",
	
	resists = { [DamageType.PHYSICAL] = 10, [DamageType.COLD] = 100, [DamageType.LIGHTNING] = 100, [DamageType.LIGHT] = -30, },
	damage_affinity = { [DamageType.COLD] = 50, [DamageType.LIGHTNING] = 50 },

	no_breath = 1,
	poison_immune = 1,
	cut_immune = 1,
	disease_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,
	confusion_immune = 1,
	levitation = 1,
	iceblock_pierce = 1,

	resolvers.talents{
		[Talents.T_DRENCH]={base=3, every=7},
		[Talents.T_SHATTER]={base=3, every=7},
		[Talents.T_ICE_CLAW]={base=3, every=7},
		[Talents.T_HURRICANE]={base=3, every=7},
		[Talents.T_THUNDERSTORM]={base=3, every=7},
		[Talents.T_FROZEN_GROUND]={base=3, every=7},
		[Talents.T_ICE_STORM]={base=3, every=7},
		[Talents.T_LIVING_LIGHTNING]={base=3, every=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.genericlast(function(e)
		e:addShaderAura("body_of_ice", "crystalineaura", {}, "particles_images/spikes.png")
		e.snowparticle = e:addParticles(engine.Particles.new("snowfall", 1))
	end),
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "parasitic horror", color=colors.DARK_GREEN,
	resolvers.nice_tile{tall=1},
	desc =_t"You don't want to think about what sort of creature this lamprey-like horror was feeding on to grow so large.  Its skin pulsates and writhes, like things are moving underneath...",
	level_range = {35, nil}, exp_worth = 1,
	rarity = 20,
	rank = 3,
	autolevel = "warrior",
	max_life = resolvers.rngavg(220,250),
	life_rating = 16,
	combat_armor = 1, combat_def = 10,
	combat = { dam=20, atk=30, apr=40, dammod={str=1}, lifesteal = 100, damtype=DamageType.ACID},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=2, },

	resists = { [DamageType.LIGHTNING] = -50, [DamageType.ACID] = 100, [DamageType.NATURE] = 50, [DamageType.BLIGHT] = 50},
	damage_affinity = { [DamageType.ACID] = 50 },

	blind_immune = 1,
	see_invisible = 20,
	movement_speed = 2,

	resolvers.talents{
		[Talents.T_CRAWL_ACID]={base=5, every=10},
		[Talents.T_SWALLOW]={base=5, every=10},
		[Talents.T_ACIDIC_SKIN]={base=5, every=10},
		[Talents.T_BLOOD_SPLASH]={base=5, every=10},
	},

	on_takehit = function(self, value, src, death_note)
		if value >= self.max_life / 10 then
			for n=1, math.ceil(5*value/self.max_life) do
				-- Find space
				local x, y = util.findFreeGrid(self.x, self.y, 3, true, {[engine.Map.ACTOR]=true})
				if not x then
					--game.logPlayer(self, "Not enough space to invoke!")
					return value
				end
				local m = game.zone:makeEntityByName(game.level, "actor", "HORROR_PARASITIC_LEECHES")
				if m then
					m.exp_worth = 0
					game.zone:addEntity(game.level, m, "actor", x, y)
				end
			end
			game.logSeen(self, "%s's severed flesh starts crawling!", self:getName():capitalize())
		end
		return value
	end,
	
	resolvers.sustains_at_birth(),
}

newEntity{ base="BASE_NPC_HORROR", define_as = "HORROR_PARASITIC_LEECHES",
	name = "mass of parasitic leeches",
	color = colors.LIGHT_GREEN,
	desc = _t"Dozens - hundreds maybe? - of blood-gorged worms, of varying shapes and sizes, making a writhing, ichor-soaked sea of tooth-lined maws and sickly green skin, ready to latch onto you and drink until they burst or your veins run dry.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 10,
	rank = 2,
	autolevel = "warrior",
	size_category = 2,
	max_life = resolvers.rngavg(120,150),
	life_rating = 10,
	combat_armor = 1, combat_def = 10,
	combat = { dam=10, atk=20, apr=30, dammod={str=1}, lifesteal = 100, damtype=DamageType.ACID},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=2, },

	resists = { [DamageType.LIGHTNING] = -50, [DamageType.ACID] = 100, [DamageType.NATURE] = 50, [DamageType.BLIGHT] = 50},
	damage_affinity = { [DamageType.ACID] = 50 },

	blind_immune = 1,
	see_invisible = 20,

	resolvers.talents{
		[Talents.T_CRAWL_ACID]={base=5, every=10},
		[Talents.T_ACIDIC_SKIN]={base=5, every=10},
		[Talents.T_BLOOD_SUCKERS]={base=5, every=10},
	},

	resolvers.sustains_at_birth(),
	
	make_escort = {
		{type="horror", subtype="eldritch", name="parasitic leech", number=2, no_subescort=true},
	},
}


------------------------------------------------------------------------
-- Uniques
------------------------------------------------------------------------

newEntity{ base="BASE_NPC_HORROR",
	name = "Grgglck the Devouring Darkness", unique = true,
	color = colors.DARK_GREY, image = "npc/horror_eldritch_grgglck.png",
	resolvers.nice_tile{tall=1},
	rarity = 50,
	desc = _t[[A horror from the deepest pits of the earth. It looks like a huge pile of tentacles all trying to reach for you.
You can discern a huge round mouth covered in razor-sharp teeth.]],
	level_range = {20, nil}, exp_worth = 2,
	max_life = 300, life_rating = 25, fixed_rating = true,
	equilibrium_regen = -20,
	negative_regen = 20,
	rank = 3.5,
	no_breath = 1,
	size_category = 4,
	movement_speed = 0.8,
	is_grgglck = true,
	immune_possession = 1,

	stun_immune = 1,
	knockback_immune = 1,

	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=0, dammod={str=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resists = { all=500 },

	resolvers.talents{
		[Talents.T_STARFALL]={base=4, every=7},
		[Talents.T_MOONLIGHT_RAY]={base=4, every=7},
		[Talents.T_PACIFICATION_HEX]={base=4, every=7},
		[Talents.T_BURNING_HEX]={base=4, every=7},
	},
	resolvers.sustains_at_birth(),

	-- Invoke tentacles every few turns
	on_act = function(self)
		if not self.ai_target.actor or self.ai_target.actor.dead then return end
		if not self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y) then return end

		self.last_tentacle = self.last_tentacle or (game.turn - 60)
		if game.turn - self.last_tentacle >= 60 then -- Summon a tentacle every 6 turns
			self:forceUseTalent(self.T_INVOKE_TENTACLE, {no_energy=true})
			self.last_tentacle = game.turn
		end
	end,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar" },
}

newEntity{ base="BASE_NPC_HORROR", define_as = "GRGGLCK_TENTACLE",
	name = "Grgglck's Tentacle",
	color = colors.GREY,
	desc = _t[[This is one of Grgglck's tentacles. It looks more vulnerable than the main body.]],
	level_range = {20, nil}, exp_worth = 0,
	max_life = 100, life_rating = 3, fixed_rating = true,
	equilibrium_regen = -20,
	rank = 3,
	no_breath = 1,
	size_category = 2,

	stun_immune = 1,
	knockback_immune = 1,
	teleport_immune = 1,

	resists = { all=50, [DamageType.DARKNESS] = 100 },

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	on_act = function(self)
		if self.summoner.dead then
			self:die()
			game.logSeen(self, "#AQUAMARINE#With Grgglck's death its tentacle also falls lifeless on the ground!")
		end
	end,

	on_die = function(self, who)
		if self.summoner and not self.summoner.dead and who then
			self:logCombat(self.summoner, "#AQUAMARINE#As #Source# falls you notice that #Target# seems to shudder in pain!")
			if self.summoner.is_grgglck then
				self.summoner:takeHit(self.max_life, who)
			else
				self.summoner:takeHit(self.max_life * 0.66, who)
			end
		end
	end,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "Ak'Gishil", color=colors.GREY, unique = true,
	desc = _t"This Blade Horror has been infused with intense temporal magic, causing its power to increase dramatically. Rifts in space open around it constantly, summoning and banishing blades before vanishing as quickly as they appear.",
	resolvers.nice_tile{tall=1},
	level_range = {30, nil}, exp_worth = 2,
	rarity = 45,
	rank = 3.5,
	levitate=1,
	max_psi= 320,
	psi_regen= 5,
	size_category = 4,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(150, 180),
	life_rating = 32,
	life_regen = 0.25,
	global_speed_base = 1.2,
	combat_armor = 30, combat_def = 18,
	is_akgishil = true,
	can_spawn = 1,
	psionic_shield_override = 1,
	
	body = { TOOL=1 },
	resolvers.equip{
		{type="tool", ego_chance = 100, defined="BLADE_RIFT", random_art_replace={chance=25, filter = {type = "charm", subtype = "torque", no_tome_drops=true, unique=true, not_properties={"lore"}, special = function(o) return not table.get(o, "power_source", "antimagic") end}}, autoreq=true},
	},
	
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=2, ally_compassion=0 },
		
	melee_project = {[DamageType.PHYSICALBLEED]=resolvers.mbonus(32, 5)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(20,28), 1, 1.5), physspeed = 0.25,atk=resolvers.levelup(24, 1.2, 1.2), apr=4, dammod={wil=0.3, cun=0.15}, damtype=engine.DamageType.PHYSICALBLEED, },
	--combat_physspeed = 4, --Crazy fast attack rate
	
	resists = {[DamageType.PHYSICAL] = 15, [DamageType.MIND] = 50, [DamageType.TEMPORAL] = 30, [DamageType.ARCANE] = -20},
	
	on_added_to_level = function(self)
		self.blades = 0
	end,

	on_act = function(self)
		if not self:attr("can_spawn") then return end
		if self.blades > 3 or not rng.percent(28/(self.blades+1)) then return end
		self.can_spawn = nil
		self.blades = self.blades + 1
		self:forceUseTalent(self.T_ANIMATE_BLADE, {ignore_cd=true, ignore_energy=true, force_level=1})
		self.can_spawn = 1
	end,
	
	resolvers.talents{
		--Original Blade Horror talents, beefed up
		[Talents.T_KNIFE_STORM]={base=5, every=5, max=8},
		[Talents.T_IMPLODE]={base=2, every=6, max=5},
		[Talents.T_RAZOR_KNIFE]={base=3, every=4, max=7},
		[Talents.T_PSIONIC_PULL]={base=5, every=3, max=7},
		[Talents.T_KINETIC_AURA]={base=4, every=3, max=8},
		[Talents.T_KINETIC_SHIELD]={base=5, every=2, max=9},
		[Talents.T_THERMAL_SHIELD]={base=5, every=2, max=9},
		[Talents.T_CHARGED_SHIELD]={base=5, every=2, max=9},
		[Talents.T_KINETIC_LEECH]={base=3, every=3, max=5},
		--TEMPORAL
		[Talents.T_INDUCE_ANOMALY]={base=1, every=4, max=5},
		[Talents.T_QUANTUM_SPIKE]={base=1, every=4, max=5},
		[Talents.T_WEAPON_FOLDING]={base=1, every=4, max=5},
		[Talents.T_RETHREAD]={base=2, every=4, max=5},
		[Talents.T_DIMENSIONAL_STEP]={base=3, every=4, max=5},
		
		[Talents.T_THROUGH_THE_CROWD]=1,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base="BASE_NPC_HORROR", define_as = "ANIMATED_BLADE",
	resolvers.nice_tile{tall=1},
	type = "construct", subtype = "weapon", image="object/magical_animated_sword.png",
	name = "Animated Sword",
	color = colors.GREY,
	desc = _t[[Time seems to warp and bend around this floating weapon.]],
	level_range = {30, nil}, exp_worth = 0,
	max_life = 75, life_rating = 4, fixed_rating=true,
	rank = 2,
	no_breath = 1,
	size_category = 2,

	negative_status_effect_immune = 1,
	body = { INVEN = 10, MAINHAND=1 },
	no_drops = true,
	resolvers.equip{
		{type="weapon", subtype="longsword", ego_chance = 100, autoreq=true},
	},
	
	resists = {[DamageType.MIND] = 75, [DamageType.TEMPORAL] = 30, all=10},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },
	
	resolvers.talents{
		[Talents.T_SWAP]={base=1, every=4, max=4},
		[Talents.T_WEAPON_COMBAT]={base=1, every=8, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=4, every=4, max=6},
		[Talents.T_DIMENSIONAL_STEP]={base=1, every=4, max=4},
	},
	
	on_added_to_level = function(self)
		self:teleportRandom(self.x, self.y, 3)
		game.logSeen(self, "#AQUAMARINE#A rift opens and a free floating blade emerges!")
		game.level.map:addEffect(self,
			self.x, self.y, 3,
			engine.DamageType.TEMPORAL, 25,
			0,
			5, nil,
			{type="time_prison"},
			nil, false
		)
	end,
	
	on_die = function(self, who)
		if self.summoner and not self.summoner:attr("dead") then
			if self.summoner.is_akgishil then
				self.summoner.blades=self.summoner.blades - 1
			end
		end
	end,

	on_act = function(self)
		if self.summoner and self.summoner:attr("dead") then
			game.logSeen(self, "#AQUAMARINE#The %s no longer seems to be controlled and clatters to the ground before vanishing into a rift.", self:getName():capitalize())
			self:die()
		end
	end,
}

newEntity{ base="BASE_NPC_HORROR", define_as = "DISTORTED_BLADE",
	type = "construct", subtype = "weapon", image="object/artifact/distorted_animated_sword.png",
	name = "Distorted Animated Sword", unique=true,
	color = colors.GREY,
	desc = _t[[This floating weapon shifts and shimmers, time and space warping and bending as it moves. It appears to vibrate, as if it may explode at any moment.]],
	level_range = {30, nil}, exp_worth = 0,
	max_life = 100, life_rating = 10,
	rank = 3.5,
	no_breath = 1,
	size_category = 2,

	negative_status_effect_immune = 1,
	
	body = { INVEN = 10, MAINHAND=1 },
	
	resolvers.equip{
		{type="weapon", subtype="longsword", defined="RIFT_SWORD", random_art_replace={chance=100, filter = {subtype = "longsword", no_tome_drops=true, unique=true, not_properties={"lore"}, special = function(o) return not table.get(o, "power_source", "antimagic") end}}, autoreq=true},
	},
	
	resists = {[DamageType.MIND] = 75, [DamageType.TEMPORAL] = 40, all=15,},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },
	
	resolvers.talents{
		[Talents.T_SWAP]={base=1, every=4, max=4},
		[Talents.T_WEAPON_COMBAT]={base=3, every=8, max=8},
		[Talents.T_WEAPONS_MASTERY]={base=4, every=4, max=7},
		[Talents.T_DIMENSIONAL_STEP]={base=2, every=4, max=5},
		[Talents.T_WEAPON_FOLDING]={base=2, every=4, max=5},
		[Talents.T_TEMPORAL_WAKE]={base=2, every=4, max=5},
	},
	
	on_added_to_level = function(self)
		self:teleportRandom(self.x, self.y, 5)
		game.logSeen(self, "#AQUAMARINE#A rift opens and a free floating blade emerges! It looks unstable...")
		game.level.map:addEffect(self,
			self.x, self.y, 5,
			DamageType.TEMPORAL, 50,
			0,
			5, nil,
			{type="time_prison"},
			nil, false
		)
	end,
	
	on_die = function(self, who)
		if self.summoner and not self.summoner:attr("dead") then
			if self.summoner.is_akgishil then
				self.summoner.blades=self.summoner.blades - 1
			end
		end
	end,

	on_act = function(self)
		self.paradox = self.paradox + 20
		if self.summoner and self.summoner:attr("dead") then
			game.logSeen(self, "#AQUAMARINE#The %s no longer seems to be controlled and clatters to the ground before vanishing into a rift.", self:getName():capitalize())
			self:die()
		end
	end,
}
