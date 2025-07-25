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

-- TODO: Update prices

require "engine.class"
require "engine.Object"
require "engine.interface.ObjectActivable"
require "engine.interface.ObjectIdentify"

local Stats = require("engine.interface.ActorStats")
local Talents = require("engine.interface.ActorTalents")
local DamageType = require("engine.DamageType")
local ActorResource = require "engine.interface.ActorResource"
local Combat = require("mod.class.interface.Combat")

module(..., package.seeall, class.inherit(
	engine.Object,
	engine.interface.ObjectActivable,
	engine.interface.ObjectIdentify,
	engine.interface.ActorTalents
))

_M.projectile_class = "mod.class.Projectile"

_M.logCombat = Combat.logCombat

-- ego fields that are appended as a list when the ego is applied (by Zone:applyEgo)
_M._special_ego_rules = {special_on_hit=true, special_on_crit=true, special_on_kill=true, charm_on_use=true, on_block=true, talent_on_spell=true, talent_on_wild_gift=true, talent_on_mind=true, talent_on_hit=true}

_M.requirement_flags_names = {
	allow_wear_massive = _t"Massive armour training",
	allow_wear_heavy = _t"Heavy armour training",
	allow_wear_shield = _t"Shield usage training",
}

function _M:getRequirementDesc(who)
	local base_getRequirementDesc = engine.Object.getRequirementDesc

	local oldreq
	self.require, oldreq = who:updateObjectRequirements(self)
	local ret = base_getRequirementDesc(self, who)
	self.require = oldreq
	return ret
end

local auto_moddable_tile_slots = {
	MAINHAND = true,
	OFFHAND = true,
	BODY = true,
	CLOAK = true,
	HEAD = true,
	HANDS = true,
	FEET = true,
	QUIVER = true,
}

function _M:init(t, no_default)
	t.encumber = t.encumber or 0

	engine.Object.init(self, t, no_default)
	engine.interface.ObjectActivable.init(self, t)
	engine.interface.ObjectIdentify.init(self, t)
	engine.interface.ActorTalents.init(self, t)

	if self.auto_image then
		self.auto_image = nil
		self.image = "object/"..(self.unique and "artifact/" or "")..self.name:lower():gsub("[^a-z0-9]", "")..".png"
	end
	if not self.auto_moddable_tile_check and self.unique and self.slot and auto_moddable_tile_slots[self.slot] and (not self.moddable_tile or type(self.moddable_tile) == "table" or (type(self.moddable_tile) == "string" and not self.moddable_tile:find("^special/"))) then
		self.auto_moddable_tile_check = true
		local file, filecheck = nil, nil
		if self.type == "weapon" or self.subtype == "shield" then
			file = "special/%s_"..self.name:lower():gsub("[^a-z0-9]", "_")
			filecheck = file:format("left")
		elseif self.subtype == "cloak" then
			file = "special/"..self.name:lower():gsub("[^a-z0-9]", "_").."_%s"
			filecheck = file:format("behind")
		else
			file = "special/"..self.name:lower():gsub("[^a-z0-9]", "_")
			filecheck = file
		end
		if file and fs.exists("/data/gfx/shockbolt/player/human_female/"..filecheck..".png") then
			self.moddable_tile = file
			self.moddable_tile2 = false
			-- print("[UNIQUE MODDABLE] auto moddable set (case 1) for ", self.name, file)
		else
			-- Try using the artifact image name
			if type(self.image) == "string" and self.image:find("^object/artifact/") then
				local base = self.image:gsub("object/artifact/", ""):gsub("%.png$", "")
				if self.type == "weapon" or self.subtype == "shield" then
					file = "special/%s_"..base
					filecheck = file:format("left")
				elseif self.subtype == "cloak" then
					file = "special/"..base.."_%s"
					filecheck = file:format("behind")
				else
					file = "special/"..base
					filecheck = file
				end
				if file and fs.exists("/data/gfx/shockbolt/player/human_female/"..filecheck..".png") then
					self.moddable_tile = file
					self.moddable_tile2 = false
					-- print("[UNIQUE MODDABLE] auto moddable set (case 2) for ", self.name, file)
				else
					print("[UNIQUE MODDABLE] auto moddable failed for ", self.name)
				end
			end
		end
	end

	-- if self.unique and self.slot and type(self.moddable_tile) == "string" then
	-- 	local filecheck = nil, nil
	-- 	if self.type == "weapon" or self.subtype == "shield" then
	-- 		filecheck = self.moddable_tile:format("left")
	-- 	elseif self.subtype == "cloak" then
	-- 		filecheck = self.moddable_tile:format("behind")
	-- 	else
	-- 		filecheck = self.moddable_tile
	-- 	end
	-- 	if filecheck and fs.exists("/data/gfx/shockbolt/player/human_female/"..filecheck..".png") then
	-- 		-- print("[UNIQUE MODDABLE] auto moddable set for ", self.name, file)
	-- 	else
	-- 		print("[UNIQUE MODDABLE] auto moddable failed for ", self.name, self.moddable_tile, filecheck)
	-- 	end
	-- end
end

function _M:altered(t)
	if t then for k, v in pairs(t) do self[k] = v end end
	self.__SAVEINSTEAD = nil
	self.__nice_tile_base = nil
	self.nice_tiler = nil
end

--- Can this object act at all
-- Most object will want to answer false, only recharging and stuff needs them
function _M:canAct()
	if (self.power_regen or self.use_talent or self.sentient) and not self.talent_cooldown then return true end
	return false
end

--- Do something when its your turn
-- For objects this mostly is to recharge them
-- By default, does nothing at all
function _M:act()
	self:regenPower()
	self:cooldownTalents()
	self:useEnergy()
end

--- can the object be used?
--	@param who = the object user (optional)
--	returns boolean, msg
function _M:canUseObject(who)
	if self.__transmo then return false, _t"Can not use an item in the transmogrification chest." end
	if not engine.interface.ObjectActivable.canUseObject(self, who) then
		return false, _t"This object has no usable power."
	end

	if who then
		if who.no_inventory_access then
			return false, _t"You cannot use items now!"
		end
		if self.use_no_blind and who:attr("blind") then
			return false, _t"You cannot see!"
		end
		if self.use_no_silence and who:attr("silence") then
			return false, _t"You are silenced!"
		end
		if not who.bypass_active_item_worn_check and (self:wornInven() and not self.wielded and not self.use_no_wear) then
			return false, _t"You must wear this object to use it!"
		end
		if who:hasEffect(self.EFF_UNSTOPPABLE) then
			return false, _t"You can not use items during a battle frenzy!"
		end
		if who:attr("sleep") and not who:attr("lucid_dreamer") then
			return false, _t"You can not use objects while sleeping!"
		end

		-- Count magic devices
		if (self.power_source and self.power_source.arcane) and who:attr("forbid_arcane") then
			return false, ("Your antimagic disrupts %s."):tformat(self:getName{no_count=true, do_color=true})
		end
	end
	return true, _t"Object can be used."
end

---	Does the actor have inadequate AI to use this object intelligently?
--	@param who = the potential object user
function _M:restrictAIUseObject(who)
	return not (who.ai == "tactical" or who.ai_real == "tactical" or who.ai_state._advanced_ai or (who.ai_state and who.ai_state.ai_party) == "tactical")
end

function _M:useObject(who, ...)
	-- Make sure the object is registered with the game, if need be
	if not game:hasEntity(self) then game:addEntity(self) end

	local reduce = 100 - util.bound(who:attr("use_object_cooldown_reduce") or 0, 0, 100)
	if self:attr("unaffected_device_mastery") then reduce = 100 end
	local usepower = function(power) return math.ceil(power * reduce / 100) end

	if self.use_power then
		if (self.talent_cooldown and not who:isTalentCoolingDown(self.talent_cooldown)) or (not self.talent_cooldown and self.power >= usepower(self.use_power.power)) then

			local ret = self.use_power.use(self, who, ...) or {}
			local no_power = not ret.used or ret.no_power
			if not no_power then
				if self.talent_cooldown then
					who.talents_cd[self.talent_cooldown] = usepower(self.use_power.power)
					local t = who:getTalentFromId(self.talent_cooldown)
					if t.cooldownStart then t.cooldownStart(who, t, self) end
				else
					self.power = self.power - usepower(self.use_power.power)
				end
			end
			return ret
		else
			if self.talent_cooldown or (self.power_regen and self.power_regen ~= 0) then
				game.logPlayer(who, "%s is still recharging.", self:getName{no_count=true})
			else
				game.logPlayer(who, "%s can not be used anymore.", self:getName{no_count=true})
			end
			return {}
		end
	elseif self.use_simple then
		return self.use_simple.use(self, who, ...) or {}
	elseif self.use_talent then
		if (self.talent_cooldown and not who:isTalentCoolingDown(self.talent_cooldown)) or (not self.talent_cooldown and (not self.use_talent.power or self.power >= usepower(self.use_talent.power))) then

			local id = self.use_talent.id
			local ab = self:getTalentFromId(id)
			local old_level = who.talents[id]; who.talents[id] = self.use_talent.level

			who:attr("force_talent_ignore_ressources", 1)
			local ret = false
			if not who:preUseTalent(ab) then
				ret = false
			else
				local ok, special
				ok, ret, special = xpcall(function() return ab.action(who, ab) end, debug.traceback)
				if not ok then
					who:attr("force_talent_ignore_ressources", -1)
					who.talents[id] = old_level
					who:onTalentLuaError(ab, ret)
					error(ret)
				end
			end
			who:attr("force_talent_ignore_ressources", -1)
			who.talents[id] = old_level

			if ret then
				if self.talent_cooldown then
					who.talents_cd[self.talent_cooldown] = usepower(self.use_talent.power)
					local t = who:getTalentFromId(self.talent_cooldown)
					if t.cooldownStart then t.cooldownStart(who, t, self) end
				else
					self.power = self.power - usepower(self.use_talent.power)
				end
			end

			return {used=ret, no_energy = util.getval(ab.no_energy, who, ab)}
		else
			if self.talent_cooldown or (self.power_regen and self.power_regen ~= 0) then
				game.logPlayer(who, "%s is still recharging.", self:getName{no_count=true})
			else
				game.logPlayer(who, "%s can not be used anymore.", self:getName{no_count=true})
			end
			return {}
		end
	end
end

function _M:getObjectCooldown(who)
	if not self.power then return end
	if self.talent_cooldown then
		return (who and who:isTalentCoolingDown(self.talent_cooldown)) or 0
	end
	local reduce = 100 - util.bound(who:attr("use_object_cooldown_reduce") or 0, 0, 100)
	local usepower = function(power) return math.ceil(power * reduce / 100) end
	local need = (self.use_power and usepower(self.use_power.power)) or (self.use_talent and usepower(self.use_talent.power)) or 0
	if self.power < need then
		if self.power_regen and self.power_regen > 0 then
			return math.ceil((need - self.power)/self.power_regen)
		else
			return nil
		end
	else
		return 0
	end
end

--- Use the object (quaff, read, ...)
function _M:use(who, typ, inven, item)
	inven = who:getInven(inven)
	local types = {}
	local useable, msg = self:canUseObject(who)

	if useable then
		types[#types+1] = "use"
	else
		game.logPlayer(who, msg)
		return
	end
	if not typ and #types == 1 then typ = types[1] end

	if typ == "use" then
		who.__object_use_running = self
		local ret = self:useObject(who, inven, item)
		who.__object_use_running = nil
		if ret.used then
			if self.charm_on_use then
				for i, d in ipairs(self.charm_on_use) do
					if rng.percent(d[1]) then d[3](self, who) end
				end
			end
			if self.use_sound then game:playSoundNear(who, self.use_sound) end
			if not ret.nobreakStepUp then who:breakStepUp() end
			if not ret.nobreakLightningSpeed then who:breakLightningSpeed() end
			if not ret.nobreakReloading then who:breakReloading() end
			if not ret.nobreakSpacetimeTuning then who:breakSpacetimeTuning() end
			if not (self.use_no_energy or ret.no_energy) then
				who:useEnergy(game.energy_to_act * (inven.use_speed or 1))
				if not ret.nobreakStealth then who:breakStealth() end
			end
		end
		return ret
	end
end

--- Find the best locations (inventory and slot) to try to wear an object in
--		applies inventory filters, optionally sorted, does not check if the object can actually be worn
-- @param use_actor: the actor to wear the object
-- @param weight_fn[1]: a function(o, inven) returning a weight value for an object
--		default is (1 + o:getPowerRank())*o.material_level, (0 for no object)
-- @param weight_fn[2]: true weight is 1 (object) or 0 (no object) return empty locations (sorted)
-- @param weight_fn[3]: false weight is 1 (object) or 0 (no object) return all locations (unsorted)
-- @param filter_field: field to check in each inventory for an object filter (defaults: "auto_equip_filter")
-- 		(sets filter._equipping_entity == use_actor before testing the filter)
-- @param no_type_check: set to allow locations with objects of different type/subtype (automatic if a filter is defined)
-- @return[1] nil if no locations could be found
-- @return[2] an ordered list (table) of locations where the object can be worn, each with format:
--		{inv=inventory (table), wt=sort weight, slot=slot within inventory}
--		The sort weight for each location is computed = weight_fn(self, inven)-weight_fn(worn object, inven)
--		(weight for objects that fail inventory filter checks is 0)
--  	The list is sorted by descending weight, removing locations with sort weight <= 0
function _M:wornLocations(use_actor, weight_fn, filter_field, no_type_check)
	if not use_actor then return end
	filter_field = filter_field == nil and "auto_equip_filter" or filter_field
	if weight_fn == nil then
		weight_fn = function(o, inven) return (1 + o:getPowerRank())*(o.material_level or 1) end
	elseif weight_fn == true then
		weight_fn = function(o, inven) return o and 1 or 0 end
	end
	-- considers main and offslot (could check others here)
	-- Note: psionic focus needs code similar to that in the Telekinetic Grasp talent
	local inv_ids = {self:wornInven()}
	inv_ids[#inv_ids+1] = use_actor:getObjectOffslot(self)
	local invens = {}
	local new_wt = weight_fn and weight_fn(self) or 1
	--print("[Object:wornLocations] found inventories", self.uid, self.name) table.print(inv_ids)
	for i, id in ipairs(inv_ids) do
		local inv = use_actor:getInven(id)
		if inv then
			local flt = inv[filter_field]
			local match_types = not (no_type_check or flt)
			if flt then
				flt._equipping_entity = use_actor
				if not game.zone:checkFilter(self, flt, "object") then inv = nil end
			end
			if inv then
				local inv_name = use_actor:getInvenDef(id).short_name
				for k = 1, math.min(inv.max, #inv + 1) do
					local wo, wt = inv[k], new_wt
					if wo then
						if match_types and (self.type ~= wo.type or self.subtype ~= wo.subtype) and (inv_name == wo.slot or inv_name == use_actor:getObjectOffslot(wo)) then
							wt = 0
						elseif not flt or game.zone:checkFilter(wo, flt, "object") then
							wt = wt - (weight_fn and weight_fn(wo) or 1)
						end
					end
					if weight_fn == false or wt > 0 then invens[#invens+1] = {inv=inv, wt=wt, slot=k} end
					if not wo then break end -- 1st open inventory slot
				end
			end
			if flt then flt._equipping_entity = nil end
		end
	end
	if #invens > 0 then
		if weight_fn then table.sort(invens, function(a, b) return a.wt > b.wt end)	end
		return invens
	end
end

--- Returns a tooltip for the object
function _M:tooltip(x, y, use_actor)
	local str = self:getDesc({do_color=true}, game.player:getInven(self:wornInven()))
--	local str = self:getDesc({do_color=true}, game.player:getInven(self:wornInven()), nil, use_actor)
	if config.settings.cheat then str:add(true, "UID: "..self.uid, true, self.image) end
	local nb = game.level.map:getObjectTotal(x, y)
	if nb == 2 then str:add(true, "---", true, _t"You see one more object.")
	elseif nb > 2 then str:add(true, "---", true, ("You see %d more objects."):tformat(nb-1))
	end
	return str
end

--- Describes an attribute, to expand object name
function _M:descAttribute(attr)
	local power = function(c)
		if config.settings.tome.advanced_weapon_stats then
			return ("%d%% power"):tformat(math.floor(game.player:combatDamagePower(self.special_combat or self.combat)*100))
		else
			return ("%d-%d power"):tformat(c.dam, (c.dam*(c.damrange or 1.1)))
		end
	end
	if attr == "MASTERY" then
		local tms = {}
		for ttn, i in pairs(self.wielder.talents_types_mastery) do
			local tt = Talents.talents_types_def[ttn]
			local cat = tt.type:gsub("/.*", "")
			local name = _t(cat, "talent category"):capitalize().._t(" / ")..tt.name:capitalize()
			tms[#tms+1] = ("%0.2f %s"):tformat(i, name)
		end
		return table.concat(tms, ",")
	elseif attr == "STATBONUS" then
		local stat, i = next(self.wielder.inc_stats)
		return i > 0 and "+"..i or tostring(i)
	elseif attr == "DAMBONUS" then
		local stat, i = next(self.wielder.inc_damage)
		return (i > 0 and "+"..i or tostring(i)).."%"
	elseif attr == "RESIST" then
		local stat, i = next(self.wielder.resists)
		return (i and i > 0 and "+"..i or tostring(i)).."%"
	elseif attr == "REGEN" then
		local i = self.wielder.mana_regen or self.wielder.stamina_regen or self.wielder.life_regen or self.wielder.hate_regen or self.wielder.positive_regen or self.wielder.negative_regen
		return ("%s%0.2f/turn"):tformat(i > 0 and "+" or "-", math.abs(i))
	elseif attr == "COMBAT" then
		local c = self.combat
		return ("%s, %s apr"):tformat(power(c), (c.apr or 0))
	elseif attr == "COMBAT_AMMO" then
		local c = self.combat
		return ("%d/%d, %s, %s apr"):tformat(c.shots_left, math.floor(c.capacity), power(c), (c.apr or 0), " apr")
	elseif attr == "COMBAT_DAMTYPE" then
		local c = self.combat
		return ("%s, %d apr, %s damage"):tformat(power(c), (c.apr or 0), DamageType:get(c.damtype).name)
	elseif attr == "COMBAT_ELEMENT" then
		local c = self.combat
		return ("%s, %d apr, %s element"):tformat(power(c), (c.apr or 0), DamageType:get(c.element or DamageType.PHYSICAL).name)
	elseif attr == "SHIELD" then
		local c = self.special_combat
		if c and (game.player:knowTalentType("technique/shield-offense") or game.player:knowTalentType("technique/shield-defense") or game.player:attr("show_shield_combat") or config.settings.tome.display_shield_stats) then
			return ("%s, %s block"):tformat(power(c), c.block)
		else
			return ("%s block"):tformat(c.block)
		end
	elseif attr == "ARMOR" then
		return ("%s def, %s armour"):tformat(self.wielder and self.wielder.combat_def and math.round(self.wielder.combat_def) or 0, self.wielder and self.wielder.combat_armor and math.round(self.wielder.combat_armor) or 0)
	elseif attr == "ATTACK" then
		return ("%s accuracy, %s apr, %s power"):tformat(self.wielder and self.wielder.combat_atk or 0, self.wielder and self.wielder.combat_apr or 0, self.wielder and self.wielder.combat_dam or 0)
	elseif attr == "MONEY" then
		return ("worth %0.2f"):tformat(self.money_value / 10)
	elseif attr == "USE_TALENT" then
		return self:getTalentFromId(self.use_talent.id).name:lower()
	elseif attr == "DIGSPEED" then
		return ("dig speed %d turns"):tformat(self.digspeed)
	elseif attr == "CHARM" then
		return (" [power %d]"):tformat(self:getCharmPower(game.player))
	elseif attr == "CHARGES" then
		local reduce = 100 - util.bound(game.player:attr("use_object_cooldown_reduce") or 0, 0, 100)
		if self.talent_cooldown and (self.use_power or self.use_talent) then
			local cd = game.player.talents_cd[self.talent_cooldown]
			if cd and cd > 0 then
				return (" (%d/%d cooldown)"):tformat(cd, math.ceil((self.use_power or self.use_talent).power * reduce / 100))
			else
				return (" (%d cooldown)"):tformat(math.ceil((self.use_power or self.use_talent).power * reduce / 100))
			end
		elseif self.use_power or self.use_talent then
			return (" (%d/%d)"):format(math.floor(self.power / (math.ceil((self.use_power or self.use_talent).power * reduce / 100))), math.floor(self.max_power / (math.ceil((self.use_power or self.use_talent).power * reduce / 100))))
		else
			return ""
		end
	elseif attr == "INSCRIPTION" then
		game.player.__inscription_data_fake = self.inscription_data
		local t = self:getTalentFromId("T_"..self.inscription_talent.."_1")
		local desc = "--"
		if t then
			local ok
			ok, desc = pcall(t.short_info, game.player, t)
			if not ok then desc = "--" end
		end
		game.player.__inscription_data_fake = nil
		return ("%s"):format(desc)
	end
end

--- Gets the "power rank" of an object
-- Possible values are 0 (normal, lore), 1 (ego), 2 (greater ego), 3 (artifact)
function _M:getPowerRank()
	if self.godslayer then return 10 end
	if self.legendary then return 5 end
	if self.unique then return 3 end
	if self.egoed then
		return math.min(2.5, 1 + (self.greater_ego and self.greater_ego or 0) + (self.rare and 1 or 0))
	end
	return 0
end

--- Gets the color in which to display the object in lists
function _M:getDisplayColor(fake)
	if not fake and not self:isIdentified() then return {180, 180, 180}, "#B4B4B4#" end
	if self.cosmetic then return {0xC5, 0x75, 0xC6}, "#C578C6#"
	elseif self.lore then return {0, 128, 255}, "#0080FF#"
	elseif self.unique then
		if self.randart then
			return {255, 0x77, 0}, "#FF7700#"
		elseif self.legendary then
			return {0xFF, 0x40, 0x00}, "#FF4000#"
		elseif self.godslayer then
			return {0xAA, 0xD5, 0x00}, "#AAD500#"
		else
			return {255, 215, 0}, "#FFD700#"
		end
	elseif self.rare then
		return {250, 128, 114}, "#SALMON#"
	elseif self.egoed then
		if self.greater_ego then
			if self.greater_ego > 1 then
				return {0x8d, 0x55, 0xff}, "#8d55ff#"
			else
				return {0, 0x80, 255}, "#0080FF#"
			end
		else
			return {0, 255, 128}, "#00FF80#"
		end
	else return {255, 255, 255}, "#FFFFFF#"
	end
end

function _M:resolveSource()
	if self.summoner_gain_exp and self.summoner then
		return self.summoner:resolveSource()
	elseif self.summoner_gain_exp and self.src then
		return self.src:resolveSource()
	else
		return self
	end
end

--- Gets the full name of the object
function _M:getName(t)
	t = t or {}
	local qty = self:getNumber()
	local name = _t(self.name, "entity name") or _t"object"
	if t.trans_only then
		return name
	end
	if t.raw_name then
		return self.name or "object"
	end

	if not t.no_add_name and (self.been_reshaped or self.been_imbued) then
		name = (type(self.been_reshaped) == "string" and self.been_reshaped or "") .. name .. (type(self.been_imbued) == "string" and self.been_imbued or "")
	end

	if t.use_shimmer_suffix and self.shimmer_suffix then
		name = name .. " " .. self.shimmer_suffix
	end

	if not self:isIdentified() and not t.force_id and self:getUnidentifiedName() then name = self:getUnidentifiedName() end

	-- To extend later
	name = name:gsub("~", ""):gsub("&", "a"):gsub("#([^#]+)#", function(attr)
		return self:descAttribute(attr)
	end)

	if not t.no_add_name and self.add_name and self:isIdentified() then
		name = name .. self.add_name:gsub("#([^#]+)#", function(attr)
			return self:descAttribute(attr)
		end)
	end

	if not t.no_add_name and self.tinker then
		name = name .. ' #{italic}#<' .. self.tinker:getName(t) .. '>#{normal}#'
	end

	if not t.no_add_name and self.__tagged then
		name = name .. " #ORANGE#="..self.__tagged.."=#LAST#"
	end

	if not t.do_color then
		if qty == 1 or t.no_count then return name
		else return qty.." "..name
		end
	else
		local _, c = self:getDisplayColor()
		local ds = t.no_image and "" or self:getDisplayString()
		if qty == 1 or t.no_count then return c..ds..name.."#LAST#"
		else return c..qty.." "..ds..name.."#LAST#"
		end
	end
end

--- Gets the short name of the object
-- currently, this is only used by EquipDollFrame
function _M:getShortName(t)
	if not self.short_name then return self:getName(t) end

	t = t or {}
	t.no_add_name = true

	local qty = self:getNumber()
	local identified = t.force_id or self:isIdentified()
	local name = _t(self.short_name, "entity short_name") or _t"object"

	if not identified then
		local _, c = self:getDisplayColor(true)
		if self.unique then
			name = ("%s, %sspecial#LAST#"):tformat(self:getUnidentifiedName(), c)
		elseif self.egoed then
			name = ("%s, %sego#LAST#"):tformat(name, c)
		end
	elseif self.keywords and next(self.keywords) then
		-- I18N translate keywords.
		local ks = table.keys(self.keywords)
		local k = {}
		for i, key in ipairs(ks) do
			k[i] = _t(key, "entity keyword")
		end
		table.sort(k)
		name = name..", "..table.concat(k, ', ')
	end

	if not t.do_color then
		if qty == 1 or t.no_count then return name
		else return qty.." "..name
		end
	else
		local _, c = self:getDisplayColor()
		local ds = t.no_image and "" or self:getDisplayString()
		if qty == 1 or t.no_count then return c..ds..name.."#LAST#"
		else return c..qty.." "..ds..name.."#LAST#"
		end
	end
end

function _M:descAccuracyBonus(desc, weapon, use_actor)
	use_actor = use_actor or game.player
	local _, kind = use_actor:isAccuracyEffect(weapon)
	if not kind then return end

	local showpct = function(v, mult)
		return ("+%0.1f%%"):format(v * mult)
	end

	local m = weapon.accuracy_effect_scale or 1
	if kind == "sword" then
		desc:add(_t"Accuracy bonus: ", {"color","LIGHT_GREEN"}, showpct(0.4, m), {"color","LAST"}, _t" crit mult (max 40%)", true)
	elseif kind == "axe" then
		desc:add(_t"Accuracy bonus: ", {"color","LIGHT_GREEN"}, showpct(0.25, m), {"color","LAST"}, _t" crit chance (max 25%)", true)
	elseif kind == "mace" then
		desc:add(_t"Accuracy bonus: ", {"color","LIGHT_GREEN"}, showpct(0.2, m), {"color","LAST"}, _t" base dam (max 20%)", true)
	elseif kind == "staff" then
		desc:add(_t"Accuracy bonus: ", {"color","LIGHT_GREEN"}, showpct(2.0, m), {"color","LAST"}, _t" proc dam (max 200%)", true)
	elseif kind == "knife" then
		desc:add(_t"Accuracy bonus: ", {"color","LIGHT_GREEN"}, showpct(0.5, m), {"color","LAST"}, _t" APR (max 50%)", true)
	end
end

--- Static
function _M:compareFields(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
	add_table = add_table or {}
	mod = mod or 1
	isinversed = isinversed or false
	isdiffinversed = isdiffinversed or false
	local ret = tstring{}
	local added = 0
	local add = false
	ret:add(text)
	local outformatres
	local resvalue = ((item1[field] or 0) + (add_table[field] or 0)) * mod
	local item1value = resvalue
	if type(outformat) == "function" then
		outformatres = outformat(resvalue, nil)
	else outformatres = outformat:format(resvalue) end
	if isinversed then
		ret:add(((item1[field] or 0) + (add_table[field] or 0)) > 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformatres, {"color", "LAST"})
	else
		ret:add(((item1[field] or 0) + (add_table[field] or 0)) < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformatres, {"color", "LAST"})
	end
	if item1[field] then
		add = true
	end
	for i=1, #items do
		if items[i][infield] and items[i][infield][field] then
			local resvalue = (items[i][infield][field] + (add_table[field] or 0)) * mod
		
			if item1value ~= 0 or resvalue ~= 0 then
				if added == 0 then
					ret:add(" (")
				elseif added > 1 then
					ret:add(_t(" / "))
				end
				
				if items[i][infield][field] ~= (item1[field] or 0) then
					local outformatres
					
					if type(outformat) == "function" then
						outformatres = outformat(item1value, resvalue)
					else outformatres = outformat:format(item1value - resvalue) end
					if isdiffinversed then
						ret:add(items[i][infield][field] < (item1[field] or 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, outformatres, {"color", "LAST"})
					else
						ret:add(items[i][infield][field] > (item1[field] or 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, outformatres, {"color", "LAST"})
					end
				else
					ret:add("-")
				end
				
				added = added + 1
				add = true
			end
		end
	end
	if added > 0 then
		ret:add(")")
	end
	if add and (resvalue ~= 0 or added > 0)then
		ret:add(true)
		return ret
	end
end

function _M:compareTableFields(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
	mod = mod or 1
	isinversed = isinversed or false
	local ret = tstring{}
	local added = 0
	local add = false
	ret:add(text)
	local tab = {}
	if item1[field] then
		for k, v in pairs(item1[field]) do
			tab[k] = {}
			tab[k][1] = v
		end
	end
	for i=1, #items do
		if items[i][infield] and items[i][infield][field] then
			for k, v in pairs(items[i][infield][field]) do
				tab[k] = tab[k] or {}
				tab[k][i + 1] = v
			end
		end
	end
	local kdel = {}
	for k, t in pairs(tab) do
		local del = true
		for i, v in pairs(t) do
			if v ~= 0 then 
				del = nil 
				break 
			end
		end
		kdel[k] = del
	end
	for k, _ in pairs(kdel) do
		tab[k] = nil
	end
	local count1 = 0
	for k, v in pairs(tab) do
		if not filter or filter(k, v) then
			local count = 0
			if isinversed then
				ret:add(("%s"):format((count1 > 0) and _t(" / ") or ""), (v[1] or 0) > 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			else
				ret:add(("%s"):format((count1 > 0) and _t(" / ") or ""), (v[1] or 0) < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			end
			count1 = count1 + 1
			if v[1] then
				add = true
			end
			for kk, vv in pairs(v) do
				if kk > 1 then
					if count == 0 then
						ret:add("(")
					elseif count > 0 then
						ret:add(_t(" / "))
					end
					if vv ~= (v[1] or 0) then
						if isinversed then
							ret:add((v[1] or 0) > vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
						else
							ret:add((v[1] or 0) < vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
						end
					else
						ret:add("-")
					end
					add = true
					count = count + 1
				end
			end
			if count > 0 then
				ret:add(")")
			end
			ret:add(kfunct(k))
		end
	end

	if add then
		ret:add(true)
		return ret
	end
end

--- Static
function _M:descCombat(use_actor, combat, compare_with, field, add_table, is_fake_add)
	local desc = tstring{}
	add_table = add_table or {}
	add_table.dammod = add_table.dammod or {}
	combat = table.clone(combat[field] or {})
	compare_with = compare_with or {}

	local compare_fields = function(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		local add = self:compareFields(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		if add then desc:merge(add) end
	end
	local compare_table_fields = function(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		local add = self:compareTableFields(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		if add then desc:merge(add) end
	end

	local dm = {}
	combat.dammod = table.mergeAdd(table.clone(combat.dammod or {}), add_table.dammod)
	local dammod = use_actor:getDammod(combat)
	for stat, i in pairs(dammod) do
		-- I18N Stats using display_short_name
		local name = Stats.stats_def[stat].display_short_name:capitalize()
		dm[#dm+1] = ("%d%% %s"):tformat(i * 100, name)
	end
	if #dm > 0 or combat.dam then
		local diff_count = 0
		local any_diff = false
		if config.settings.tome.advanced_weapon_stats then
			local base_power = use_actor:combatDamagePower(combat, add_table.dam)
			local base_range = use_actor:combatDamageRange(combat, add_table.damrange)
			local power_diff, range_diff = {}, {}
			for _, v in ipairs(compare_with) do
				if v[field] then
					local base_power_diff = base_power - use_actor:combatDamagePower(v[field], add_table.dam)
					local base_range_diff = base_range - use_actor:combatDamageRange(v[field], add_table.damrange)
					power_diff[#power_diff + 1] = ("%s%+d%%#LAST#"):format(base_power_diff > 0 and "#00ff00#" or "#ff0000#", base_power_diff * 100)
					range_diff[#range_diff + 1] = ("%s%+.1fx#LAST#"):format(base_range_diff > 0 and "#00ff00#" or "#ff0000#", base_range_diff)
					diff_count = diff_count + 1
					if base_power_diff ~= 0 or base_range_diff ~= 0 then
						any_diff = true
					end
				end
			end
			if any_diff then
				local s = ("Power: %3d%% (%s)  Range: %.1fx (%s)"):tformat(base_power * 100, table.concat(power_diff, _t(" / ")), base_range, table.concat(range_diff, _t(" / ")))
				desc:merge(s:toTString())
			else
				desc:add(("Power: %3d%%  Range: %.1fx"):tformat(base_power * 100, base_range))
			end
		else
			local power_diff = {}
			for i, v in ipairs(compare_with) do
				if v[field] then
					local base_power_diff = ((combat.dam or 0) + (add_table.dam or 0)) - ((v[field].dam or 0) + (add_table.dam or 0))
					local dfl_range = (1.1 - (add_table.damrange or 0))
					local multi_diff = (((combat.damrange or dfl_range) + (add_table.damrange or 0)) * ((combat.dam or 0) + (add_table.dam or 0))) - (((v[field].damrange or dfl_range) + (add_table.damrange or 0)) * ((v[field].dam or 0) + (add_table.dam or 0)))
					power_diff [#power_diff + 1] = ("%s%+.1f#LAST# - %s%+.1f#LAST#"):format(base_power_diff > 0 and "#00ff00#" or "#ff0000#", base_power_diff, multi_diff > 0 and "#00ff00#" or "#ff0000#", multi_diff)
					diff_count = diff_count + 1
					if base_power_diff ~= 0 or multi_diff ~= 0 then
						any_diff = true
					end
				end
			end
			if any_diff == false then
				power_diff = ""
			else
				power_diff = ("(%s)"):format(table.concat(power_diff, _t(" / ")))
			end
			desc:add(("Base power: %.1f - %.1f"):tformat((combat.dam or 0) + (add_table.dam or 0), ((combat.damrange or (1.1 - (add_table.damrange or 0))) + (add_table.damrange or 0)) * ((combat.dam or 0) + (add_table.dam or 0))))
			desc:merge(power_diff:toTString())
		end
		desc:add(true)
		desc:add(("Uses %s: %s"):tformat(#dm > 1 and _t"stats" or _t"stat",table.concat(dm, ', ')), true)
		local col = (combat.damtype and DamageType:get(combat.damtype) and DamageType:get(combat.damtype).text_color or "#WHITE#"):toTString()
		desc:add(_t"Damage type: ", col[2],DamageType:get(combat.damtype or DamageType.PHYSICAL).name:capitalize(),{"color","LAST"}, true)
	end

	if combat.talented then
		local t = use_actor:combatGetTraining(combat)
		if t and t.name then desc:add(_t"Mastery: ", {"color","GOLD"}, t.name, {"color","LAST"}, true) end
	end

	self:descAccuracyBonus(desc, combat, use_actor)

	if combat.wil_attack then
		desc:add(_t"Accuracy is based on willpower for this weapon.", true)
	end

	compare_fields(combat, compare_with, field, "atk", "%+d", _t"Accuracy: ", 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "apr", "%+d", _t"Armour Penetration: ", 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "physcrit", "%+.1f%%", _t"Crit. chance: ", 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "crit_power", "%+.1f%%", _t"Crit. power: ", 1, false, false, add_table)
	local physspeed_compare = function(orig, compare_with)
		orig = 100 / orig
		if compare_with then return ("%+.0f%%"):format(orig - 100 / compare_with)
		else return ("%2.0f%%"):format(orig) end
	end
	compare_fields(combat, compare_with, field, "physspeed", physspeed_compare, _t"Attack speed: ", 1, false, true, add_table)

	compare_fields(combat, compare_with, field, "block", "%+d", _t"Block value: ", 1, false, false, add_table)

	compare_fields(combat, compare_with, field, "dam_mult", "%d%%", _t"Dam. multiplier: ", 100, false, false, add_table)
	compare_fields(combat, compare_with, field, "range", "%+d", _t"Firing range: ", 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "capacity", "%d", _t"Capacity: ", 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "shots_reloaded_per_turn", "%+d", _t"Reload speed: ", 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "ammo_every", "%d", _t"Turns elapse between self-loadings: ", 1, false, false, add_table)

	local talents = {}
	if combat.talent_on_hit then
		for tid, data in pairs(combat.talent_on_hit) do
			talents[tid] = {data.chance, data.level}
		end
	end
	for i, v in ipairs(compare_with or {}) do
		for tid, data in pairs(v[field] and (v[field].talent_on_hit or {})or {}) do
			if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
				desc:add({"color","RED"}, ("When this weapon hits: %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
			else
				talents[tid][3] = true
			end
		end
	end
	for tid, data in pairs(talents) do
		desc:add(talents[tid][3] and {"color","WHITE"} or {"color","GREEN"}, ("When this weapon hits: %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
	end

	local talents = {}
	if combat.talent_on_crit then
		for tid, data in pairs(combat.talent_on_crit) do
			talents[tid] = {data.chance, data.level}
		end
	end
	for i, v in ipairs(compare_with or {}) do
		for tid, data in pairs(v[field] and (v[field].talent_on_crit or {})or {}) do
			if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
				desc:add({"color","RED"}, ("When this weapon crits: %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
			else
				talents[tid][3] = true
			end
		end
	end
	for tid, data in pairs(talents) do
		desc:add(talents[tid][3] and {"color","WHITE"} or {"color","GREEN"}, ("When this weapon crits: %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
	end

	local special = ""
	if combat.special_on_hit then
		special = combat.special_on_hit.desc
	end

	-- get_items takes the combat table and returns a table of items to print.
	-- Each of these items one of the following:
	-- id -> {priority, string}
	-- id -> {priority, message_function(this, compared), value}
	-- header is the section header.
	local compare_list = function(header, get_items)
		local priority_ordering = function(left, right)
			return left[2][1] < right[2][1]
		end

		if next(compare_with) then
			-- Grab the left and right items.
			local left = get_items(combat)
			local right = {}
			for i, v in ipairs(compare_with) do
				for k, item in pairs(get_items(v[field])) do
					if not right[k] then
						right[k] = item
					elseif type(right[k]) == 'number' then
						right[k] = right[k] + item
					else
						right[k] = item
					end
				end
			end

			-- Exit early if no items.
			if not next(left) and not next(right) then return end

			desc:add(header, true)

			local combined = table.clone(left)
			table.merge(combined, right)

			for k, _ in table.orderedPairs2(combined, priority_ordering) do
				l = left[k]
				r = right[k]
				message = (l and l[2]) or (r and r[2])
				if type(message) == 'function' then
					desc:add(message(l and l[3], r and r[3] or 0), true)
				elseif type(message) == 'string' then
					local prefix = '* '
					local color = 'WHITE'
					if l and not r then
						color = 'GREEN'
						prefix = '+ '
					end
					if not l and r then
						color = 'RED'
						prefix = '- '
					end
					desc:add({'color',color}, prefix, message, {'color','LAST'}, true)
				end
			end
		else
			local items = get_items(combat)
			if next(items) then
				desc:add(header, true)
				for k, v in table.orderedPairs2(items, priority_ordering) do
					message = v[2]
					if type(message) == 'function' then
						desc:add(message(v[3]), true)
					elseif type(message) == 'string' then
						desc:add({'color','WHITE'}, '* ', message, {'color','LAST'}, true)
					end
				end
			end
		end
	end

	local get_special_list = function(combat, key)
		local special = combat[key]

		-- No special
		if not special then return {} end
		-- Single special
		if special.desc then
			return {[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}}
		end

		-- Multiple specials
		local list = {}
		for _, special in pairs(special) do
			list[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}
		end
		return list
	end

	compare_list(
		_t"#YELLOW#On weapon hit:#LAST#",
		function(combat)
			if not combat then return {} end
			local list = {}
			-- Get complex damage types
			for dt, amount in pairs(combat.melee_project or combat.ranged_project or {}) do
				local dt_def = DamageType:get(dt)
				if dt_def and dt_def.tdesc then
					local desc = function(dam)
						return dt_def.tdesc(dam, nil, use_actor)
					end
					list[dt] = {0, desc, amount}
					--list[dt] = {0, dt_def.tdesc, amount}
				end
			end
			-- Get specials
			table.merge(list, get_special_list(combat, 'special_on_hit'))
			return list
		end
	)

	compare_list(
		_t"#YELLOW#On weapon crit:#LAST#",
		function(combat)
			if not combat then return {} end
			return get_special_list(combat, 'special_on_crit')
		end
	)

	compare_list(
		_t"#YELLOW#On weapon kill:#LAST#",
		function(combat)
			if not combat then return {} end
			return get_special_list(combat, 'special_on_kill')
		end
	)

	local found = false
	for i, v in ipairs(compare_with or {}) do
		if v[field] and v[field].no_stealth_break then
			found = true
		end
	end

	if combat.no_stealth_break then
		desc:add(found and {"color","WHITE"} or {"color","GREEN"},_t"When used from stealth a simple attack with it will not break stealth.", {"color","LAST"}, true)
	elseif found then
		desc:add({"color","RED"}, _t"When used from stealth a simple attack with it will not break stealth.", {"color","LAST"}, true)
	end

	if combat.crushing_blow then
		desc:add({"color", "YELLOW"}, _t"Crushing Blows: ", {"color", "LAST"}, _t"Damage dealt by this weapon is increased by half your critical multiplier, if doing so would kill the target.", true)
	end

	compare_fields(combat, compare_with, field, "travel_speed", "%+d%%", _t"Travel speed: ", 100, false, false, add_table)

	compare_fields(combat, compare_with, field, "phasing", "%+d%%", _t"Damage Shield penetration (this weapon only): ", 1, false, false, add_table)

	compare_fields(combat, compare_with, field, "lifesteal", "%+d%%", _t"Lifesteal (this weapon only): ", 1, false, false, add_table)

	local attack_recurse_procs_reduce_compare = function(orig, compare_with)
		orig = 100 - 100 / orig
		if compare_with then return ("%+d%%"):format(-(orig - (100 - 100 / compare_with)))
		else return ("%d%%"):format(-orig) end
	end
	compare_fields(combat, compare_with, field, "attack_recurse", "%+d", _t"Multiple attacks: ", 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "attack_recurse_procs_reduce", attack_recurse_procs_reduce_compare, _t"Multiple attacks procs power reduction: ", 1, true, false, add_table)

	if combat.tg_type and combat.tg_type == "beam" then
		desc:add({"color","YELLOW"}, (_t"Shots beam through all targets."), {"color","LAST"}, true)
	end

	compare_table_fields(
		combat, compare_with, field, "melee_project", "%+d", _t"Damage (Melee): ",
		function(item)
			local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
			return col[2], (" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
		end,
		nil, nil,
		function(k, v) return not DamageType.dam_def[k].tdesc end)

	compare_table_fields(
		combat, compare_with, field, "ranged_project", "%+d", _t"Damage (Ranged): ",
		function(item)
			local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
			return col[2], (" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
		end,
		nil, nil,
		function(k, v) return not DamageType.dam_def[k].tdesc end)

	compare_table_fields(combat, compare_with, field, "burst_on_hit", "%+d", _t"Damage (radius 1) on hit: ", function(item)
			local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
			return col[2], (" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
		end)

	compare_table_fields(combat, compare_with, field, "burst_on_crit", "%+d", _t"Damage (radius 2) on crit: ", function(item)
			local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
			return col[2], (" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
		end)

	compare_table_fields(combat, compare_with, field, "convert_damage", "%d%%", _t"Damage conversion: ", function(item)
			local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
			return col[2], (" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
		end)

	compare_table_fields(combat, compare_with, field, "inc_damage_type", "%+d%% ", _t"Damage against: ", function(item)
			local _, _, t, st = item:find("^([^/]+)/?(.*)$")
			if st and st ~= "" then
				return _t(st):capitalize()
			else
				return _t(t):capitalize()
			end
		end)

	-- resources used to attack
	compare_table_fields(
		combat, compare_with, field, "use_resources", "%0.1f", _t"#ORANGE#Attacks use: #LAST#",
		function(item)
			local res_def = ActorResource.resources_def[item]
			local col = (res_def and res_def.color or "#SALMON#"):toTString()
			return col[2], (" %s"):tformat(res_def and res_def.name or item:capitalize()),{"color","LAST"}
		end,
		nil,
		true)

	self:triggerHook{"Object:descCombat", compare_with=compare_with, compare_fields=compare_fields, compare_scaled=compare_scaled, compare_scaled=compare_scaled, compare_table_fields=compare_table_fields, desc=desc, combat=combat}
	return desc
end

--- Gets the full textual desc of the object without the name and requirements
function _M:getTextualDesc(compare_with, use_actor)
	use_actor = use_actor or game.player
	compare_with = compare_with or {}
	local desc = tstring{}

	if self.quest then desc:add({"color", "VIOLET"},_t"[Plot Item]", {"color", "LAST"}, true)
	elseif self.cosmetic then desc:add({"color", "C578C6"},_t"[Cosmetic Item]", {"color", "LAST"}, true)
	elseif self.unique then
		if self.legendary then desc:add({"color", "FF4000"},_t"[Legendary]", {"color", "LAST"}, true)
		elseif self.godslayer then desc:add({"color", "AAD500"},_t"[Godslayer]", {"color", "LAST"}, true)
		elseif self.randart then desc:add({"color", "FF7700"},_t"[Random Unique]", {"color", "LAST"}, true)
		else desc:add({"color", "FFD700"},_t"[Unique]", {"color", "LAST"}, true)
		end
	end

	desc:add(("Type: %s / %s"):tformat(_t(tostring(rawget(self, 'type')) or _t"unknown", "entity type"), _t(tostring(rawget(self, 'subtype') or _t"unknown"), "entity subtype")))
	if self.material_level then desc:add(_t" ; tier ", tostring(self.material_level)) end
	desc:add(true)
	if self.slot_forbid == "OFFHAND" then desc:add(_t"It must be held with both hands.", true) end
	if self.double_weapon then desc:add(_t"It can be used as a weapon and offhand.", true) end
	desc:add(true)

	if not self:isIdentified() then -- give limited information if the item is unidentified
		local combat = self.combat
		if not combat and self.wielded then
			-- shield combat
			if self.subtype == "shield" and self.special_combat and ((use_actor:knowTalentType("technique/shield-offense") or use_actor:knowTalentType("technique/shield-defense") or use_actor:attr("show_shield_combat") or config.settings.tome.display_shield_stats)) then
				combat = self.special_combat
			end
			-- gloves combat
			if self.subtype == "hands" and self.wielder and self.wielder.combat and (use_actor:knowTalent(use_actor.T_EMPTY_HAND) or use_actor:attr("show_gloves_combat") or config.settings.tome.display_glove_stats) then
				combat = self.wielder.combat
			end
		end
		if combat then -- always list combat damage types (but not amounts)
			local special = 0
			if combat.talented then
				local t = use_actor:combatGetTraining(combat)
				if t and t.name then desc:add(_t"Mastery: ", {"color","GOLD"}, t.name, {"color","LAST"}, true) end
			end
			self:descAccuracyBonus(desc, combat or {}, use_actor)
			if combat.wil_attack then
				desc:add(_t"Accuracy is based on willpower for this weapon.", true)
			end
			local dt = DamageType:get(combat.damtype or DamageType.PHYSICAL)
			desc:add(_t"Weapon Damage: ", dt.text_color or "#WHITE#", dt.name:upper(),{"color","LAST"})
			for dtyp, val in pairs(combat.melee_project or combat.ranged_project or {}) do
				dt = DamageType:get(dtyp)
				if dt then
					if dt.tdesc then
						special = special + 1
					else
						desc:add(_t", ", dt.text_color or "#WHITE#", dt.name, {"color", "LAST"})
					end
				end
			end
			desc:add(true)
			--special_on_hit count # for both melee and ranged
			if special>0 or combat.special_on_hit or combat.special_on_crit or combat.special_on_kill or combat.burst_on_crit or combat.burst_on_hit or combat.talent_on_hit or combat.talent_on_crit then
				desc:add(_t"#YELLOW#It can cause special effects when it strikes in combat.#LAST#", true)
			end
			if self.on_block then
				desc:add(_t"#ORCHID#It can cause special effects when a melee attack is blocked.#LAST#", true)
			end
		end
		if self.wielder then
			if self.wielder.lite then
				desc:add(("It %s ambient light (%+d radius)."):tformat(self.wielder.lite >= 0 and _t"provides" or _t"dims", self.wielder.lite), true)
			end
		end
		if self.wielded then
			if self.use_power or self.use_simple or self.use_talent then
				desc:add(_t"#ORANGE#It has an activatable power.#LAST#", true)
			end
		end
--desc:add(_t"----END UNIDED DESC----", true)
		return desc
	end

	if self.set_list then
		desc:add({"color","GREEN"}, _t"It is part of a set of items.", {"color","LAST"}, true)
		if self.set_desc then
			for set_id, text in pairs(self.set_desc) do
				desc:add({"color","GREEN"}, text, {"color","LAST"}, true)
			end
		end
		if self.set_complete then desc:add({"color","LIGHT_GREEN"}, _t"The set is complete.", {"color","LAST"}, true) end
	end

	local compare_fields = function(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		local add = self:compareFields(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		if add then desc:merge(add) end
	end

	-- included - if we should include the value in the present total.
	-- total_call - function to call on the actor to get the current total
	local compare_scaled = function(item1, items, infield, change_field, results, outformat, text, included, mod, isinversed, isdiffinversed, add_table)
		local out = function(base_change, base_change2)
			local unworn_base = (item1.wielded and table.get(item1, infield, change_field)) or table.get(items, 1, infield, change_field)  -- ugly
			unworn_base = unworn_base or 0
			local scale_change = use_actor:getAttrChange(change_field, -unworn_base, base_change - unworn_base, unpack(results))
			if base_change2 then
				scale_change = scale_change - use_actor:getAttrChange(change_field, -unworn_base, base_change2 - unworn_base, unpack(results))
				base_change = base_change - base_change2
			end
			return outformat:format(base_change, scale_change)
		end
		return compare_fields(item1, items, infield, change_field, out, text, mod, isinversed, isdiffinversed, add_table)
	end

	local compare_table_fields = function(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		local add = self:compareTableFields(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		if add then desc:merge(add) end
	end

	local desc_combat = function(...)
		local cdesc = self:descCombat(use_actor, ...)
		desc:merge(cdesc)
	end

	local desc_wielder = function(w, compare_with, field)
		w = w or {}
		w = w[field] or {}
		compare_scaled(w, compare_with, field, "combat_atk", {"combatAttack"}, _t"%+d #LAST#(%+d eff.)", _t"Accuracy: ")
		compare_fields(w, compare_with, field, "combat_apr", "%+d", _t"Armour penetration: ")
		compare_fields(w, compare_with, field, "combat_physcrit", "%+.1f%%", _t"Physical crit. chance: ")
		compare_scaled(w, compare_with, field, "combat_dam", {"combatPhysicalpower"}, _t"%+d #LAST#(%+d eff.)", _t"Physical power: ")

		compare_fields(w, compare_with, field, "combat_armor", "%+d", _t"Armour: ")
		compare_fields(w, compare_with, field, "combat_armor_hardiness", "%+d%%", _t"Armour Hardiness: ")
		compare_scaled(w, compare_with, field, "combat_def", {"combatDefense", true}, _t"%+d #LAST#(%+d eff.)", _t"Defense: ")
		compare_scaled(w, compare_with, field, "combat_def_ranged", {"combatDefenseRanged", true}, _t"%+d #LAST#(%+d eff.)", _t"Ranged Defense: ")

		compare_fields(w, compare_with, field, "fatigue", "%+d%%", _t"Fatigue: ", 1, true, true)

		compare_fields(w, compare_with, field, "ammo_reload_speed", "%+d", _t"Ammo reloads per turn: ")


		local dt_string = tstring{}
		local found = false
		local combat2 = { melee_project = {} }
		for i, v in pairs(w.melee_project or {}) do
			local def = DamageType.dam_def[i]
			if def and def.tdesc then
				local d = def.tdesc(v, nil, use_actor)
				found = true
				dt_string:add(d, {"color","LAST"}, true)
			else
				combat2.melee_project[i] = v
			end
		end

		if found then
			desc:add({"color","ORANGE"}, _t"Effects on melee hit: ", {"color","LAST"}, true)
			desc:merge(dt_string)
		end

		local ranged = tstring{}
		local ranged_found = false
		local ranged_combat = { ranged_project = {} }
		for i, v in pairs(w.ranged_project or {}) do
			local def = DamageType.dam_def[i]
			if def and def.tdesc then
				local d = def.tdesc(v, nil, use_actor)
				ranged_found = true
				ranged:add(d, {"color","LAST"}, true)
			else
				ranged_combat.ranged_project[i] = v
			end
		end

		local onhit = tstring{}
		local found = false
		local onhit_combat = { on_melee_hit = {} }
		for i, v in pairs(w.on_melee_hit or {}) do
			local def = DamageType.dam_def[i]
			if def and def.tdesc then
				local d = def.tdesc(v, nil, use_actor)
				found = true
				onhit:add(d, {"color","LAST"}, true)
			else
				onhit_combat.on_melee_hit[i] = v
			end
		end

		compare_table_fields(combat2, compare_with, field, "melee_project", "%d", _t"Damage (Melee): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2],(" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		if ranged_found then
			desc:add({"color","ORANGE"}, _t"Effects on ranged hit: ", {"color","LAST"}, true)
			desc:merge(ranged)
		end

		compare_table_fields(ranged_combat, compare_with, field, "ranged_project", "%d", _t"Damage (Ranged): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2],(" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		if found then
			desc:add({"color","ORANGE"}, _t"Effects when hit in melee: ", {"color","LAST"}, true)
			desc:merge(onhit)
		end

		compare_table_fields(onhit_combat, compare_with, field, "on_melee_hit", "%d", _t"Damage when hit (Melee): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2],(" %s"):tformat(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		-- get_items takes the object table and returns a table of items to print.
		-- Each of these items one of the following:
		-- id -> {priority, string}
		-- id -> {priority, message_function(this, compared), value}
		-- header is the section header.
		local compare_list = function(header, get_items)
			local priority_ordering = function(left, right)
				return left[2][1] < right[2][1]
			end

			if next(compare_with) then
				-- Grab the left and right items.
				local left = get_items(self)
				local right = {}
				for i, v in ipairs(compare_with) do
					for k, item in pairs(get_items(v[field])) do
						if not right[k] then
							right[k] = item
						elseif type(right[k]) == 'number' then
							right[k] = right[k] + item
						else
							right[k] = item
						end
					end
				end
				if not left then game.log("No left") end
				if not right then game.log("No right") end
				-- Exit early if no items.
				if not next(left) and not next(right) then return end

				desc:add(header, true)

				local combined = table.clone(left)
				table.merge(combined, right)

				for k, _ in table.orderedPairs2(combined, priority_ordering) do
					l = left[k]
					r = right[k]

					message = (l and l[2]) or (r and r[2])
					if type(message) == 'function' then
						desc:add(message(l and l[3], r and r[3] or 0), true)
					elseif type(message) == 'string' then
						local prefix = '* '
						local color = 'WHITE'
						if l and not r then
							color = 'GREEN'
							prefix = '+ '
						end
						if not l and r then
							color = 'RED'
							prefix = '- '
						end
						desc:add({'color',color}, prefix, message, {'color','LAST'}, true)
					end
				end
			else
				local items = get_items(self)
				if next(items) then
					desc:add(header, true)
					for k, v in table.orderedPairs2(items, priority_ordering) do
						message = v[2]
						if type(message) == 'function' then
							desc:add(message(v[3]), true)
						elseif type(message) == 'string' then
							desc:add({'color','WHITE'}, '* ', message, {'color','LAST'}, true)
						end
					end
				end
			end
		end

		local get_special_list = function(o, key)
			local special = o[key]

			-- No special
			if not special then return {} end
			-- Single special
			if special.desc then
				return {[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}}
			end

			-- Multiple specials
			local list = {}
			for _, special in pairs(special) do
				list[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}
			end
			return list
		end

		compare_list(
			_t"#YELLOW#On shield block:#LAST#",
			function(o)
				if not o then return {} end
				return get_special_list(o, 'on_block')
			end
		)

		compare_table_fields(w, compare_with, field, "inc_stats", "%+d", _t"Changes stats: ", function(item)
			-- I18N Stats using display_short_name
			return (" %s"):tformat(Stats.stats_def[item].display_short_name:capitalize())
		end)
		compare_table_fields(w, compare_with, field, "resists", "%+d%%", _t"Changes resistances: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):tformat(item == "all" and _t"all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "resists_cap", "%+d%%", _t"Changes resistances cap: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):tformat(item == "all" and _t"all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "flat_damage_armor", "%+d", _t"Reduce damage by fixed amount: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):tformat(item == "all" and _t"all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "wards", "%+d", _t"Maximum wards: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):tformat(item == "all" and _t"all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "resists_pen", "%+d%%", _t"Changes resistances penetration: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):tformat(item == "all" and _t"all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "inc_damage", "%+d%%", _t"Changes damage: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):tformat(item == "all" and _t"all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "inc_damage_actor_type", "%+d%% ", _t"Damage against: ", function(item)
				local _, _, t, st = item:find("^([^/]+)/?(.*)$")
				if st and st ~= "" then
					return _t(st):capitalize()
				else
					return _t(t):capitalize()
				end
			end)

		compare_table_fields(w, compare_with, field, "resists_actor_type", "%+d%% ", _t"Reduced damage from: ", function(item)
		local _, _, t, st = item:find("^([^/]+)/?(.*)$")
			if st and st ~= "" then
				return _t(st):capitalize()
			else
				return _t(t):capitalize()
			end
		end)

		compare_table_fields(w, compare_with, field, "talents_mastery_bonus", "+%0.2f ", _t"Talent category bonus: ", function(item)
		local _, _, t, st = item:find("^([^/]+)/?(.*)$")
			if st and st ~= "" then
				return _t(st):capitalize()
			else
				return _t(t):capitalize()
			end
		end)

		compare_table_fields(w, compare_with, field, "damage_affinity", "%+d%%", _t"Damage affinity(heal): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):tformat(item == "all" and _t"all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
			end)

		compare_fields(w, compare_with, field, "esp_range", "%+d", _t"Change telepathy range by : ")

		local any_esp = false
		local esps_compare = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].esp_all and v[field].esp_all > 0 then
				esps_compare["All"] = esps_compare["All"] or {}
				esps_compare["All"][1] = true
				any_esp = true
			end
			for type, i in pairs(v[field] and (v[field].esp or {}) or {}) do if i and i > 0 then
				local _, _, t, st = type:find("^([^/]+)/?(.*)$")
				local esp = ""
				if st and st ~= "" then
					esp = t:capitalize().."/"..st:capitalize()
				else
					esp = t:capitalize()
				end
				esps_compare[esp] = esps_compare[esp] or {}
				esps_compare[esp][1] = true
				any_esp = true
			end end
		end

		local esps = {}
		if w.esp_all and w.esp_all > 0 then
			esps[#esps+1] = _t"All"
			esps_compare[esps[#esps]] = esps_compare[esps[#esps]] or {}
			esps_compare[esps[#esps]][2] = true
			any_esp = true
		end
		for type, i in pairs(w.esp or {}) do if i and i > 0 then
			local _, _, t, st = type:find("^([^/]+)/?(.*)$")
			if st and st ~= "" then
				esps[#esps+1] = _t(t):capitalize().."/".._t(st):capitalize()
			else
				esps[#esps+1] = _t(t):capitalize()
			end
			esps_compare[esps[#esps]] = esps_compare[esps[#esps]] or {}
			esps_compare[esps[#esps]][2] = true
			any_esp = true
		end end
		if any_esp then
			desc:add(_t"Grants telepathy: ")
			for esp, isin in pairs(esps_compare) do
				if isin[2] then
					desc:add(isin[1] and {"color","WHITE"} or {"color","GREEN"}, ("%s "):format(esp), {"color","LAST"})
				else
					desc:add({"color","RED"}, ("%s "):format(esp), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		local any_mastery = 0
		local masteries = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].talents_types_mastery then
				for ttn, mastery in pairs(v[field].talents_types_mastery) do
					masteries[ttn] = masteries[ttn] or {}
					masteries[ttn][1] = mastery
					any_mastery = any_mastery + 1
				end
			end
		end
		for ttn, i in pairs(w.talents_types_mastery or {}) do
			masteries[ttn] = masteries[ttn] or {}
			masteries[ttn][2] = i
			any_mastery = any_mastery + 1
		end
		if any_mastery > 0 then
			desc:add(("Talent %s: "):tformat(any_mastery > 1 and _t"masteries" or _t"mastery"))
			for ttn, ttid in pairs(masteries) do
				local tt = Talents.talents_types_def[ttn]
				if tt then
					local cat = tt.type:gsub("/.*", "")
					local name = _t(cat, "talent category"):capitalize().._t(" / ")..tt.name:capitalize()
					local diff = (ttid[2] or 0) - (ttid[1] or 0)
					if diff ~= 0 then
						if ttid[1] then
							desc:add(("%+.2f"):format(ttid[2] or 0), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(%+.2f) "):format(diff), {"color","LAST"}, ("%s "):format(name))
						else
							desc:add({"color","LIGHT_GREEN"}, ("%+.2f"):format(ttid[2] or 0),  {"color","LAST"}, (" %s "):format(name))
						end
					else
						desc:add({"color","WHITE"}, ("%+.2f(-) %s "):format(ttid[2] or ttid[1], name), {"color","LAST"})
					end
				end
			end
			desc:add(true)
		end

		local any_cd_reduction = 0
		local cd_reductions = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].talent_cd_reduction then
				for tid, cd in pairs(v[field].talent_cd_reduction) do
					cd_reductions[tid] = cd_reductions[tid] or {}
					cd_reductions[tid][1] = cd
					any_cd_reduction = any_cd_reduction + 1
				end
			end
		end
		for tid, cd in pairs(w.talent_cd_reduction or {}) do
			cd_reductions[tid] = cd_reductions[tid] or {}
			cd_reductions[tid][2] = cd
			any_cd_reduction = any_cd_reduction + 1
		end
		if any_cd_reduction > 0 then
			desc:add(("%s cooldown:"):tformat(any_cd_reduction > 1 and _t"Talents" or _t"Talent"))
			for tid, cds in pairs(cd_reductions) do
				local diff = (cds[2] or 0) - (cds[1] or 0)
				if diff ~= 0 then
					if cds[1] then
						desc:add((" %s ("):format(Talents.talents_def[tid].name), ("(%+d"):format(-(cds[2] or 0)), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(%+d) "):format(-diff), {"color","LAST"}, ("%s)"):tformat(((cds[2] or 0) > 1) and _t"turns" or _t"turn"))
					else
						desc:add((" %s ("):format(Talents.talents_def[tid].name), {"color","LIGHT_GREEN"}, ("%+d"):format(-(cds[2] or 0)), {"color","LAST"}, (" %s)"):tformat((cds[2] > 1) and _t"turns" or _t"turn"))
					end
				else
					desc:add({"color","WHITE"}, (" %s (%+d(-) %s)"):tformat(Talents.talents_def[tid].name, -(cds[2] or cds[1]), ((cds[2] or 0) > 1) and _t"turns" or _t"turn"), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		-- Display learned talents
		local any_learn_talent = 0
		local learn_talents = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].learn_talent then
				for tid, tl in pairs(v[field].learn_talent) do if tl > 0 then
					learn_talents[tid] = learn_talents[tid] or {}
					learn_talents[tid][1] = tl
					any_learn_talent = any_learn_talent + 1
				end end
			end
		end
		for tid, tl in pairs(w.learn_talent or {}) do if tl > 0 then
			learn_talents[tid] = learn_talents[tid] or {}
			learn_talents[tid][2] = tl
			any_learn_talent = any_learn_talent + 1
		end end
		if any_learn_talent > 0 then
			desc:add(("%s granted: "):tformat(any_learn_talent > 1 and _t"Talents" or _t"Talent"))
			for tid, tl in pairs(learn_talents) do
				local diff = (tl[2] or 0) - (tl[1] or 0)
				local name = Talents.talents_def[tid].name
				if diff ~= 0 then
					if tl[1] then
						desc:add(("+%d"):format(tl[2] or 0), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(+%d) "):format(diff), {"color","LAST"}, ("%s "):format(name))
					else
						desc:add({"color","LIGHT_GREEN"}, ("+%d"):format(tl[2] or 0),  {"color","LAST"}, (" %s "):format(name))
					end
				else
					desc:add({"color","WHITE"}, ("%+.2f(-) %s "):format(tl[2] or tl[1], name), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		local any_breath = 0
		local breaths = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].can_breath then
				for what, _ in pairs(v[field].can_breath) do
					breaths[what] = breaths[what] or {}
					breaths[what][1] = true
					any_breath = any_breath + 1
				end
			end
		end
		for what, _ in pairs(w.can_breath or {}) do
			breaths[what] = breaths[what] or {}
			breaths[what][2] = true
			any_breath = any_breath + 1
		end
		if any_breath > 0 then
			desc:add(_t"Allows you to breathe in: ")
			for what, isin in pairs(breaths) do
				if isin[2] then
					desc:add(isin[1] and {"color","WHITE"} or {"color","GREEN"}, ("%s "):format(_t(what)), {"color","LAST"})
				else
					desc:add({"color","RED"}, ("%s "):format(_t(what)), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		compare_fields(w, compare_with, field, "combat_critical_power", "%+.2f%%", _t"Critical mult.: ")
		compare_fields(w, compare_with, field, "ignore_direct_crits", "%-.2f%%", _t"Reduces incoming crit damage: ")
		compare_fields(w, compare_with, field, "combat_crit_reduction", "%-d%%", _t"Reduces opponents crit chance: ")

		compare_fields(w, compare_with, field, "disarm_bonus", "%+d", _t"Trap disarming bonus: ")
		compare_fields(w, compare_with, field, "inc_stealth", "%+d", _t"Stealth bonus: ")
		compare_fields(w, compare_with, field, "max_encumber", "%+d", _t"Maximum encumbrance: ")

		compare_scaled(w, compare_with, field, "combat_physresist", {"combatPhysicalResist", true}, _t"%+d #LAST#(%+d eff.)", _t"Physical save: ")
		compare_scaled(w, compare_with, field, "combat_spellresist", {"combatSpellResist", true}, _t"%+d #LAST#(%+d eff.)", _t"Spell save: ")
		compare_scaled(w, compare_with, field, "combat_mentalresist", {"combatMentalResist", true}, _t"%+d #LAST#(%+d eff.)", _t"Mental save: ")

		compare_fields(w, compare_with, field, "blind_immune", "%+d%%", _t"Blindness immunity: ", 100)
		compare_fields(w, compare_with, field, "poison_immune", "%+d%%", _t"Poison immunity: ", 100)
		compare_fields(w, compare_with, field, "disease_immune", "%+d%%", _t"Disease immunity: ", 100)
		compare_fields(w, compare_with, field, "cut_immune", "%+d%%", _t"Cut immunity: ", 100)

		compare_fields(w, compare_with, field, "silence_immune", "%+d%%", _t"Silence immunity: ", 100)
		compare_fields(w, compare_with, field, "disarm_immune", "%+d%%", _t"Disarm immunity: ", 100)
		compare_fields(w, compare_with, field, "confusion_immune", "%+d%%", _t"Confusion immunity: ", 100)
		compare_fields(w, compare_with, field, "sleep_immune", "%+d%%", _t"Sleep immunity: ", 100)
		compare_fields(w, compare_with, field, "pin_immune", "%+d%%", _t"Pinning immunity: ", 100)

		compare_fields(w, compare_with, field, "stun_immune", "%+d%%", _t"Stun/Freeze immunity: ", 100)
		compare_fields(w, compare_with, field, "fear_immune", "%+d%%", _t"Fear immunity: ", 100)
		compare_fields(w, compare_with, field, "knockback_immune", "%+d%%", _t"Knockback immunity: ", 100)
		compare_fields(w, compare_with, field, "instakill_immune", "%+d%%", _t"Instant-death immunity: ", 100)
		compare_fields(w, compare_with, field, "teleport_immune", "%+d%%", _t"Teleport immunity: ", 100)

		compare_fields(w, compare_with, field, "life_regen", "%+.2f", _t"Life regen: ")
		compare_fields(w, compare_with, field, "stamina_regen", "%+.2f", _t"Stamina each turn: ")
		compare_fields(w, compare_with, field, "mana_regen", "%+.2f", _t"Mana each turn: ")
		compare_fields(w, compare_with, field, "hate_regen", "%+.2f", _t"Hate each turn: ")
		compare_fields(w, compare_with, field, "psi_regen", "%+.2f", _t"Psi each turn: ")
		compare_fields(w, compare_with, field, "equilibrium_regen", "%+.2f", _t"Equilibrium each turn: ", nil, true, true)
		compare_fields(w, compare_with, field, "vim_regen", "%+.2f", _t"Vim each turn: ")
		compare_fields(w, compare_with, field, "positive_regen", "%+.2f", _t"P.Energy each turn: ")
		compare_fields(w, compare_with, field, "negative_regen", "%+.2f", _t"N.Energy each turn: ")

		compare_fields(w, compare_with, field, "stamina_regen_when_hit", "%+.2f", _t"Stamina when hit: ")
		compare_fields(w, compare_with, field, "mana_regen_when_hit", "%+.2f", _t"Mana when hit: ")
		compare_fields(w, compare_with, field, "equilibrium_regen_when_hit", "%+.2f", _t"Equilibrium when hit: ")
		compare_fields(w, compare_with, field, "psi_regen_when_hit", "%+.2f", _t"Psi when hit: ")
		compare_fields(w, compare_with, field, "hate_regen_when_hit", "%+.2f", _t"Hate when hit: ")
		compare_fields(w, compare_with, field, "vim_regen_when_hit", "%+.2f", _t"Vim when hit: ")

		compare_fields(w, compare_with, field, "vim_on_melee", "%+.2f", _t"Vim when hitting in melee: ")

		compare_fields(w, compare_with, field, "mana_on_crit", "%+.2f", _t"Mana when firing critical spell: ")
		compare_fields(w, compare_with, field, "vim_on_crit", "%+.2f", _t"Vim when firing critical spell: ")
		compare_fields(w, compare_with, field, "spellsurge_on_crit", "%+d", _t"Spellpower on spell critical (stacks up to 3 times): ")

		compare_fields(w, compare_with, field, "hate_on_crit", "%+.2f", _t"Hate when firing a critical mind attack: ")
		compare_fields(w, compare_with, field, "psi_on_crit", "%+.2f", _t"Psi when firing a critical mind attack: ")
		compare_fields(w, compare_with, field, "equilibrium_on_crit", "%+.2f", _t"Equilibrium when firing a critical mind attack: ")

		compare_fields(w, compare_with, field, "hate_per_kill", "+%0.2f", _t"Hate per kill: ")
		compare_fields(w, compare_with, field, "psi_per_kill", "+%0.2f", _t"Psi per kill: ")
		compare_fields(w, compare_with, field, "vim_on_death", "%+.2f", _t"Vim per kill: ")

		compare_fields(w, compare_with, field, "die_at", _t"%+.2f life", _t"Only die when reaching: ", 1, true, true)
		compare_fields(w, compare_with, field, "max_life", "%+.2f", _t"Maximum life: ")
		compare_fields(w, compare_with, field, "max_mana", "%+.2f", _t"Maximum mana: ")
		compare_fields(w, compare_with, field, "max_soul", "%+.2f", _t"Maximum souls: ")
		compare_fields(w, compare_with, field, "max_stamina", "%+.2f", _t"Maximum stamina: ")
		compare_fields(w, compare_with, field, "max_hate", "%+.2f", _t"Maximum hate: ")
		compare_fields(w, compare_with, field, "max_psi", "%+.2f", _t"Maximum psi: ")
		compare_fields(w, compare_with, field, "max_vim", "%+.2f", _t"Maximum vim: ")
		compare_fields(w, compare_with, field, "max_positive", "%+.2f", _t"Maximum pos.energy: ")
		compare_fields(w, compare_with, field, "max_negative", "%+.2f", _t"Maximum neg.energy: ")
		compare_fields(w, compare_with, field, "max_air", "%+.2f", _t"Maximum air capacity: ")

		compare_scaled(w, compare_with, field, "combat_spellpower", {"combatSpellpower"}, _t"%+d #LAST#(%+d eff.)", _t"Spellpower: ")
		compare_fields(w, compare_with, field, "combat_spellcrit", "%+d%%", _t"Spell crit. chance: ")
		compare_fields(w, compare_with, field, "spell_cooldown_reduction", "%d%%", _t"Lowers spell cool-downs by: ", 100)

		compare_scaled(w, compare_with, field, "combat_mindpower", {"combatMindpower"}, _t"%+d #LAST#(%+d eff.)", _t"Mindpower: ")
		compare_fields(w, compare_with, field, "combat_mindcrit", "%+d%%", _t"Mental crit. chance: ")

		compare_fields(w, compare_with, field, "lite", "%+d", _t"Light radius: ")
		compare_fields(w, compare_with, field, "infravision", "%+d", _t"Infravision radius: ")
		compare_fields(w, compare_with, field, "heightened_senses", "%+d", _t"Heightened senses radius: ")
		compare_fields(w, compare_with, field, "sight", "%+d", _t"Sight radius: ")

		compare_fields(w, compare_with, field, "see_stealth", "%+d", _t"See stealth: ")

		compare_fields(w, compare_with, field, "see_invisible", "%+d", _t"See invisible: ")
		compare_fields(w, compare_with, field, "invisible", "%+d", _t"Invisibility: ")

		compare_fields(w, compare_with, field, "global_speed_add", "%+d%%", _t"Global speed: ", 100)
		compare_fields(w, compare_with, field, "movement_speed", "%+d%%", _t"Movement speed: ", 100)
		compare_fields(w, compare_with, field, "combat_physspeed", "%+d%%", _t"Combat speed: ", 100)
		compare_fields(w, compare_with, field, "combat_spellspeed", "%+d%%", _t"Casting speed: ", 100)
		compare_fields(w, compare_with, field, "combat_mindspeed", "%+d%%", _t"Mental speed: ", 100)

		compare_fields(w, compare_with, field, "healing_factor", "%+d%%", _t"Healing mod.: ", 100)
		compare_fields(w, compare_with, field, "heal_on_nature_summon", "%+d", _t"Heals friendly targets nearby when you use a nature summon: ")

		compare_fields(w, compare_with, field, "life_leech_chance", "%+d%%", _t"Life leech chance: ")
		compare_fields(w, compare_with, field, "life_leech_value", "%+d%%", _t"Life leech: ")

		compare_fields(w, compare_with, field, "resource_leech_chance", "%+d%%", _t"Resource leech chance: ")
		compare_fields(w, compare_with, field, "resource_leech_value", "%+d", _t"Resource leech: ")

		compare_fields(w, compare_with, field, "damage_shield_penetrate", "%+d%%", _t"Damage Shield penetration: ")

		compare_fields(w, compare_with, field, "projectile_evasion", "%+d%%", _t"Deflect projectiles away: ")
		compare_fields(w, compare_with, field, "evasion", "%+d%%", _t"Chance to avoid attacks: ")
		compare_fields(w, compare_with, field, "cancel_damage_chance", "%+d%%", _t"Chance to avoid any damage: ")

		compare_fields(w, compare_with, field, "defense_on_teleport", "%+d", _t"Defense after a teleport: ")
		compare_fields(w, compare_with, field, "resist_all_on_teleport", "%+d%%", _t"Resist all after a teleport: ")
		compare_fields(w, compare_with, field, "effect_reduction_on_teleport", "%+d%%", _t"New effects duration reduction after a teleport: ")

		compare_fields(w, compare_with, field, "damage_resonance", "%+d%%", _t"Damage Resonance (when hit): ")

		compare_fields(w, compare_with, field, "size_category", "%+d", _t"Size category: ")

		compare_fields(w, compare_with, field, "nature_summon_max", "%+d", _t"Max wilder summons: ")
		compare_fields(w, compare_with, field, "nature_summon_regen", "%+.2f", _t"Life regen bonus (wilder-summons): ")

		compare_fields(w, compare_with, field, "shield_dur", "%+d", _t"Damage Shield Duration: ")
		compare_fields(w, compare_with, field, "shield_factor", "%+d%%", _t"Damage Shield Power: ")

		compare_fields(w, compare_with, field, "iceblock_pierce", "%+d%%", _t"Ice block penetration: ")

		compare_fields(w, compare_with, field, "slow_projectiles", "%+d%%", _t"Slows Projectiles: ")

		compare_fields(w, compare_with, field, "shield_windwall", "%+d", _t"Bonus block near projectiles: ")

		compare_fields(w, compare_with, field, "paradox_reduce_anomalies", "%+d", _t"Reduces paradox anomalies(equivalent to willpower): ")

		compare_fields(w, compare_with, field, "resist_unseen", "%-d%%", _t"Reduce all damage from unseen attackers: ")

		if w.undead and w.undead > 0 then
			desc:add(_t"The wearer is treated as an undead.", true)
		end

		if w.demon and w.demon > 0 then
			desc:add(_t"The wearer is treated as a demon.", true)
		end

		if w.blind and w.blind > 0 then
			desc:add(_t"The wearer is blinded.", true)
		end

		if w.sleep and w.sleep > 0 then
			desc:add(_t"The wearer is asleep.", true)
		end

		if w.blind_fight and w.blind_fight > 0 then
			desc:add({"color", "YELLOW"}, _t"Blind-Fight: ", {"color", "LAST"}, _t"This item allows the wearer to attack unseen targets without any penalties.", true)
		end

		if w.lucid_dreamer and w.lucid_dreamer > 0 then
			desc:add({"color", "YELLOW"}, _t"Lucid Dreamer: ", {"color", "LAST"}, _t"This item allows the wearer to act while sleeping.", true)
		end

		if w.no_breath and w.no_breath > 0 then
			desc:add(_t"The wearer no longer has to breathe.", true)
		end

		if w.quick_weapon_swap and w.quick_weapon_swap > 0 then
			desc:add({"color", "YELLOW"}, _t"Quick Weapon Swap:", {"color", "LAST"}, _t"This item allows the wearer to swap to their secondary weapon without spending a turn.", true)
		end

		if w.avoid_pressure_traps and w.avoid_pressure_traps > 0 then
			desc:add({"color", "YELLOW"}, _t"Avoid Pressure Traps: ", {"color", "LAST"}, _t"The wearer never triggers traps that require pressure.", true)
		end

		if w.speaks_shertul and w.speaks_shertul > 0 then
			desc:add(_t"Allows you to speak and read the old Sher'Tul language.", true)
		end

		self:triggerHook{"Object:descWielder", compare_with=compare_with, compare_fields=compare_fields, compare_scaled=compare_scaled, compare_table_fields=compare_table_fields, desc=desc, w=w, field=field}

		-- Do not show "general effect" if nothing to show
--		if desc[#desc-2] == "General effects: " then table.remove(desc) table.remove(desc) table.remove(desc) table.remove(desc) end

		local can_combat_unarmed = false
		local compare_unarmed = {}
		for i, v in ipairs(compare_with) do
			if v.wielder and v.wielder.combat then
				can_combat_unarmed = true
			end
			compare_unarmed[i] = compare_with[i].wielder or {}
		end

		if (w and w.combat or can_combat_unarmed) and (use_actor:knowTalent(use_actor.T_EMPTY_HAND) or use_actor:attr("show_gloves_combat") or config.settings.tome.display_glove_stats) then
			desc:add({"color","YELLOW"}, _t"When used to modify unarmed attacks:", {"color", "LAST"}, true)
			compare_tab = { dam=1, atk=1, apr=0, physcrit=0, physspeed =(use_actor:knowTalent(use_actor.T_EMPTY_HAND) and 0.8 or 1), dammod={str=1}, damrange=1.1 }
			desc_combat(w, compare_unarmed, "combat", compare_tab, true)
		elseif (w and w.combat or can_combat_unarmed) then
			desc:add({"color","LIGHT_BLUE"}, _t"Learn an unarmed attack talent or enable 'Always show glove combat' to see combat stats.", {"color", "LAST"}, true)
		end
	end
	local can_combat = false
	local can_special_combat = false
	local can_wielder = false
	local can_carrier = false
	local can_imbue_powers = false

	for i, v in ipairs(compare_with) do
		if v.combat then
			can_combat = true
		end
		if v.special_combat then
			can_special_combat = true
		end
		if v.wielder then
			can_wielder = true
		end
		if v.carrier then
			can_carrier = true
		end
		if v.imbue_powers then
			can_imbue_powers = true
		end
	end

	if self.combat or can_combat then
		desc_combat(self, compare_with, "combat")
	end

	if (self.special_combat or can_special_combat) and (use_actor:knowTalentType("technique/shield-offense") or use_actor:knowTalentType("technique/shield-defense") or use_actor:attr("show_shield_combat") or config.settings.tome.display_shield_stats) then
		desc:add({"color","YELLOW"}, _t"When used to attack (with talents):", {"color", "LAST"}, true)
		desc_combat(self, compare_with, "special_combat")
	elseif (self.special_combat or can_special_combat) then
		desc:add({"color","LIGHT_BLUE"}, _t"Learn shield attack talent or enable 'Always show shield combat' to see combat stats.", {"color", "LAST"}, true)
	end

	local found = false
	for i, v in ipairs(compare_with or {}) do
		if v[field] and v[field].no_teleport then
			found = true
		end
	end

	if self.no_teleport then
		desc:add(found and {"color","WHITE"} or {"color","GREEN"}, _t"It is immune to teleportation, if you teleport it will fall on the ground.", {"color", "LAST"}, true)
	elseif found then
		desc:add({"color","RED"}, _t"It is immune to teleportation, if you teleport it will fall on the ground.", {"color", "LAST"}, true)
	end

	if self.wielder or can_wielder then
		desc:add({"color","YELLOW"}, _t"When wielded/worn:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "wielder")
		if self:attr("skullcracker_mult") and use_actor:knowTalent(use_actor.T_SKULLCRACKER) then
			compare_fields(self, compare_with, "wielder", "skullcracker_mult", "%+d", _t"Skullcracker multiplicator: ")
		end
	end

	if self.carrier or can_carrier then
		desc:add({"color","YELLOW"}, _t"When carried:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "carrier")
	end

	if self.is_tinker then
		if self.on_type then
			if self.on_subtype then
				desc.add(("Attach on item of type '#ORANGE#%s / %s#LAST#'"):tformat(self.on_type, self.on_subtype):toTString(), true)
			else
				desc.add(("Attach on item of type '#ORANGE#%s#LAST#'"):tformat(self.on_type):toTString(), true)
			end
		end
		if self.on_slot then desc.add(("Attach on item worn on slot '#ORANGE#%s#LAST#'"):tformat(_t(self.on_slot, "entity on slot"):lower():gsub('_', ' ')):toTString(), true) end

		if self.object_tinker and (self.object_tinker.combat or self.object_tinker.wielder) then
			desc:add({"color","YELLOW"}, _t"When attach to an other item:", {"color", "LAST"}, true)
			if self.object_tinker.combat then desc_combat(self.object_tinker, compare_with, "combat") end
			if self.object_tinker.wielder then desc_wielder(self.object_tinker, compare_with, "wielder") end
		end
	end

	if self.special_desc then
		local d = self:special_desc(use_actor)
		if d then
			desc:add({"color", "ROYAL_BLUE"})
			desc:merge(d:toTString())
			desc:add({"color", "LAST"}, true)
		end
	end

	if self.on_block and self.on_block.desc then
		local d = self.on_block.desc
		desc:add({"color", "ORCHID"})
		desc:add(_t"Special effect on block: " .. d)
		desc:add({"color", "LAST"}, true)
	end

	if self.imbue_powers or can_imbue_powers then
		desc:add({"color","YELLOW"}, _t"When used to imbue an object:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "imbue_powers")
	end

	if self.alchemist_bomb or self.type == "gem" and use_actor:knowTalent(Talents.T_CREATE_ALCHEMIST_GEMS) then
		local a = self.alchemist_bomb
		if not a then
			a = game.zone.object_list["ALCHEMIST_GEM_"..self.name:gsub(" ", "_"):upper()]
			if a then a = a.alchemist_bomb end
		end
		if a then
			desc:add({"color","YELLOW"}, _t"When used as an alchemist bomb:", {"color", "LAST"}, true)
			if a.power then desc:add(("Bomb damage +%d%%"):tformat(a.power), true) end
			if a.range then desc:add(("Bomb thrown range +%d"):tformat(a.range), true) end
			if a.mana then desc:add(("Mana regain %d"):tformat(a.mana), true) end
			if a.daze then desc:add(("%d%% chance to daze for %d turns"):tformat(a.daze.chance, a.daze.dur), true) end
			if a.stun then desc:add(("%d%% chance to stun for %d turns"):tformat(a.stun.chance, a.stun.dur), true) end
			if a.splash then
				if a.splash.desc then
					desc:add(a.splash.desc, true)
				else
					desc:add(("Additional %d %s damage"):tformat(a.splash.dam, DamageType:get(DamageType[a.splash.type]).name), true)
				end
			end
			if a.leech then desc:add(("Life regen %d%% of max life"):tformat(a.leech), true) end
		end
	end

	local latent = table.get(self.color_attributes, 'damage_type')
	if latent then
		latent = DamageType:get(latent) or {}
		desc:add({"color","YELLOW",}, _t"Latent Damage Type: ", {"color","LAST",},
			latent.text_color or "#WHITE#", latent.name:capitalize(), {"color", "LAST",}, true)
	end

	if self.inscription_data and self.inscription_talent then
		use_actor.__inscription_data_fake = self.inscription_data
		local t = self:getTalentFromId("T_"..self.inscription_talent.."_1")
		if t then
			local ok, tdesc = pcall(use_actor.getTalentFullDescription, use_actor, t)
			if ok and tdesc then
				desc:add({"color","YELLOW"}, _t"When inscribed on your body:", {"color", "LAST"}, true)
				desc:merge(tdesc)
				desc:add(true)
			end
		end
		use_actor.__inscription_data_fake = nil
	end

	if self.wielder and self.wielder.talents_add_levels then
		for tid, lvl in pairs(self.wielder.talents_add_levels) do
			local t = use_actor:getTalentFromId(tid)
			desc:add(lvl < 0 and {"color","FIREBRICK"} or {"color","OLIVE_DRAB"}, ("Talent level: %+d %s."):tformat(lvl, t and t.name or "???"), {"color","LAST"}, true)
		end
	end
	if self.talents_add_levels_filters then
		for _, data in ipairs(self.talents_add_levels_filters) do
			desc:add(data.detrimental and {"color","FIREBRICK"} or {"color","OLIVE_DRAB"}, ("Talent level: %s."):tformat(data.desc), {"color","LAST"}, true)
		end
	end

	local talents = {}
	if self.talent_on_spell then
		for _, data in ipairs(self.talent_on_spell) do if data.talent then
			talents[data.talent] = {data.chance, data.level}
		end end
	end
	for i, v in ipairs(compare_with or {}) do
		for _, data in ipairs(v[field] and (v[field].talent_on_spell or {})or {}) do if data.talent then
			local tid = data.talent
			if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
				desc:add({"color","RED"}, ("Talent on hit(spell): %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
			else
				talents[tid][3] = true
			end
		end end
	end
	for tid, data in pairs(talents) do
		desc:add(talents[tid][3] and {"color","GREEN"} or {"color","WHITE"}, ("Talent on hit(spell): %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
	end

	local talents = {}
	if self.talent_on_wild_gift then
		for _, data in ipairs(self.talent_on_wild_gift) do if data.talent then
			talents[data.talent] = {data.chance, data.level}
		end end
	end
	for i, v in ipairs(compare_with or {}) do
		for _, data in ipairs(v[field] and (v[field].talent_on_wild_gift or {})or {}) do if data.talent then
			local tid = data.talent
			if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
				desc:add({"color","RED"}, ("Talent on hit(nature): %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
			else
				talents[tid][3] = true
			end
		end end
	end
	for tid, data in pairs(talents) do
		desc:add(talents[tid][3] and {"color","GREEN"} or {"color","WHITE"}, ("Talent on hit(nature): %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
	end

	local talents = {}
	if self.talent_on_mind then
		for _, data in ipairs(self.talent_on_mind) do if data.talent then
			talents[data.talent] = {data.chance, data.level}
		end end
	end
	for i, v in ipairs(compare_with or {}) do
		for _, data in ipairs(v[field] and (v[field].talent_on_mind or {})or {}) do if data.talent then
			local tid = data.talent
			if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
				desc:add({"color","RED"}, ("Talent on hit(mindpower): %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
			else
				talents[tid][3] = true
			end
		end end
	end
	for tid, data in pairs(talents) do
		desc:add(talents[tid][3] and {"color","GREEN"} or {"color","WHITE"}, ("Talent on hit(mindpower): %s (%d%% chance level %d)."):tformat(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
	end

	if self.use_no_energy and self.use_no_energy ~= "fake" then
		desc:add(_t"Activating this item is instant.", true)
	elseif self.use_talent then
		local t = use_actor:getTalentFromId(self.use_talent.id)
		if util.getval(t.no_energy, use_actor, t) == true then
			desc:add(_t"Activating this item is instant.", true)
		end
	end

	if self.curse then
		local t = use_actor:getTalentFromId(use_actor.T_DEFILING_TOUCH)
		if t and t.canCurseItem(use_actor, t, self) then
			desc:add({"color",0xf5,0x3c,0xbe}, use_actor.tempeffect_def[self.curse].desc, {"color","LAST"}, true)
		end
	end

	self:triggerHook{"Object:descMisc", compare_with=compare_with, compare_fields=compare_fields, compare_scaled=compare_scaled, compare_table_fields=compare_table_fields, desc=desc, object=self}

	local use_desc = self:getUseDesc(use_actor)
	if use_desc then desc:merge(use_desc:toTString()) end
	return desc
end

-- get the textual description of the object's usable power
function _M:getUseDesc(use_actor)
	use_actor = use_actor or game.player
	local ret = tstring{}
	local reduce = 100 - util.bound(use_actor:attr("use_object_cooldown_reduce") or 0, 0, 100)
	local usepower = function(power) return math.ceil(power * reduce / 100) end
	if self.use_power and not self.use_power.hidden then
		local desc = util.getval(self.use_power.name, self, use_actor)
		if self.show_charges then
			ret = tstring{{"color","YELLOW"}, ("It can be used to %s, with %d charges out of %d."):tformat(desc, math.floor(self.power / usepower(self.use_power.power)), math.floor(self.max_power / usepower(self.use_power.power))), {"color","LAST"}}
		elseif self.talent_cooldown then
			local t_name = self.talent_cooldown == "T_GLOBAL_CD" and _t"all charms" or ("Talent %s"):tformat(use_actor:getTalentDisplayName(use_actor:getTalentFromId(self.talent_cooldown)))
			ret = tstring{{"color","YELLOW"}, ("It can be used to %s\n\nActivation puts %s on cooldown for %d turns."):tformat(desc:tformat(self:getCharmPower(use_actor)), t_name, usepower(self.use_power.power)), {"color","LAST"}}
		else
			ret = tstring{{"color","YELLOW"}, ("It can be used to %s\n\nActivation costs %d power out of %d/%d."):tformat(desc, usepower(self.use_power.power), self.power, self.max_power), {"color","LAST"}}
		end
	elseif self.use_simple then
		ret = tstring{{"color","YELLOW"}, ("It can be used to %s."):tformat(util.getval(self.use_simple.name, self, use_actor)), {"color","LAST"}}
	elseif self.use_talent then
		local t = use_actor:getTalentFromId(self.use_talent.id)
		if t then
			local desc = use_actor:getTalentFullDescription(t, nil, {force_level=self.use_talent.level, ignore_cd=true, ignore_ressources=true, ignore_use_time=true, ignore_mode=true, custom=self.use_talent.power and tstring{{"color",0x6f,0xff,0x83}, _t"Power cost: ", {"color",0x7f,0xff,0xd4},("%d out of %d/%d."):tformat(usepower(self.use_talent.power), self.power, self.max_power)}})
			if self.talent_cooldown then
				ret = tstring{{"color","YELLOW"}, ("It can be used to activate talent %s, placing all other charms into a %s cooldown :"):tformat(t.name, tostring(math.floor(usepower(self.use_talent.power)))), {"color","LAST"}, true}
			else
				ret = tstring{{"color","YELLOW"}, ("It can be used to activate talent %s (costing %s power out of %s/%s) :"):tformat(t.name, tostring(math.floor(usepower(self.use_talent.power))), tostring(math.floor(self.power)), tostring(math.floor(self.max_power))), {"color","LAST"}, true}
			end
			ret:merge(desc)
		end
	end

	if self.charm_on_use then
		ret:add(true, _t"When used:", true)
		for i, d in ipairs(self.charm_on_use) do
			-- Clean up the description if our chance to proc is 100%
			local percent = d[1]
			if percent < 100 then
				ret:add({"color","ORCHID"}, "* ", ("%s%% chance to %s"):tformat(tostring(d[1]), d[2](self, use_actor)), ".", true, {"color","LAST"})
			else
				ret:add({"color","ORCHID"}, "* ", d[2](self, use_actor):capitalize(), ".", true, {"color","LAST"})
			end
		end
	end

	return ret
end

--- Gets the full desc of the object
function _M:getDesc(name_param, compare_with, never_compare, use_actor)
	use_actor = use_actor or game.player
	local desc = tstring{}

	if self.__new_pickup then
		desc:add({"font","bold"},{"color","LIGHT_BLUE"},_t"Newly picked up",{"font","normal"},{"color","LAST"},true)
	end
	if self.__transmo then
		desc:add({"font","bold"},{"color","YELLOW"},_t"This item will automatically be transmogrified when you leave the level.",{"font","normal"},{"color","LAST"},true)
	end

	name_param = name_param or {}
	name_param.do_color = true
	compare_with = compare_with or {}

	desc:merge(self:getName(name_param):toTString())
	desc:add({"color", "WHITE"}, true)
	local reqs = self:getRequirementDesc(use_actor)
	if reqs then
		desc:merge(reqs)
	end

	if self.power_source then
		if self.power_source.arcane then desc:merge((_t"Powered by #VIOLET#arcane forces#LAST#\n"):toTString()) end
		if self.power_source.nature then desc:merge((_t"Infused by #OLIVE_DRAB#nature#LAST#\n"):toTString()) end
		if self.power_source.antimagic then desc:merge((_t"Infused by #ORCHID#arcane disrupting forces#LAST#\n"):toTString()) end
		if self.power_source.technique then desc:merge((_t"Crafted by #LIGHT_UMBER#a master#LAST#\n"):toTString()) end
		if self.power_source.psionic then desc:merge((_t"Infused by #YELLOW#psionic forces#LAST#\n"):toTString()) end
		if self.power_source.unknown then desc:merge((_t"Powered by #CRIMSON#unknown forces#LAST#\n"):toTString()) end
		self:triggerHook{"Object:descPowerSource", desc=desc, object=self}
	end

	if self.encumber then
		desc:add({"color",0x67,0xAD,0x00}, ("%0.2f Encumbrance."):tformat(self.encumber), {"color", "LAST"})
	end
	-- if self.ego_bonus_mult then
	-- 	desc:add(true, {"color",0x67,0xAD,0x00}, ("%0.2f Ego Multiplier."):format(1 + self.ego_bonus_mult), {"color", "LAST"})
	-- end

	local could_compare = false
	if not name_param.force_compare and not core.key.modState("ctrl") then
		if compare_with[1] then could_compare = true end
		compare_with = {}
	end

	desc:add(true, true)
	desc:merge(self:getTextualDesc(compare_with, use_actor))

	if self:isIdentified() then
		desc:add(true, true, {"color", "ANTIQUE_WHITE"})
		desc:merge(self.desc:toTString())
		desc:add({"color", "WHITE"})
	end

	if self.shimmer_moddable then
		local oname = (self.shimmer_moddable.name or "???"):toTString()
		desc:add(true, {"color", "OLIVE_DRAB"})
		desc:merge(("This object's appearance was changed to %s"):tformat(oname:toString()):toTString())
		-- desc:merge(oname)
		desc:add(_t".", {"color","LAST"}, true)
	end

	if could_compare and not never_compare then desc:add(true, {"font","italic"}, {"color","GOLD"}, _t"Press <control> to compare", {"color","LAST"}, {"font","normal"}) end

	return desc
end

local type_sort = {
	potion = 1,
	scroll = 1,
	jewelry = 3,
	weapon = 100,
	armor = 101,
}
_M.type_sort = type_sort

--- Sorting by type function
-- By default, sort by type name
function _M:getTypeOrder()
	if self.type and type_sort[self.type] then
		return type_sort[self.type]
	else
		return 99999
	end
end

--- Sorting by type function
-- By default, sort by subtype name
function _M:getSubtypeOrder()
	return self.subtype or ""
end

--- Gets the item's flag value
function _M:getPriceFlags()
	local price = 0

	local function count(w)
		--status immunities
		if w.stun_immune then price = price + w.stun_immune * 80 end
		if w.knockback_immune then price = price + w.knockback_immune * 80 end
		if w.disarm_immune then price = price + w.disarm_immune * 80 end
		if w.teleport_immune then price = price + w.teleport_immune * 80 end
		if w.blind_immune then price = price + w.blind_immune * 80 end
		if w.confusion_immune then price = price + w.confusion_immune * 80 end
		if w.poison_immune then price = price + w.poison_immune * 80 end
		if w.disease_immune then price = price + w.disease_immune * 80 end
		if w.cut_immune then price = price + w.cut_immune * 80 end
		if w.pin_immune then price = price + w.pin_immune * 80 end
		if w.silence_immune then price = price + w.silence_immune * 80 end

		--saves
		if w.combat_physresist then price = price + w.combat_physresist * 0.15 end
		if w.combat_mentalresist then price = price + w.combat_mentalresist * 0.15 end
		if w.combat_spellresist then price = price + w.combat_spellresist * 0.15 end

		--resource-affecting attributes
		if w.max_life then price = price + w.max_life * 0.1 end
		if w.max_stamina then price = price + w.max_stamina * 0.1 end
		if w.max_mana then price = price + w.max_mana * 0.2 end
		if w.max_vim then price = price + w.max_vim * 0.4 end
		if w.max_hate then price = price + w.max_hate * 0.4 end
		if w.life_regen then price = price + w.life_regen * 10 end
		if w.stamina_regen then price = price + w.stamina_regen * 100 end
		if w.mana_regen then price = price + w.mana_regen * 80 end
		if w.psi_regen then price = price + w.psi_regen * 100 end
		if w.stamina_regen_when_hit then price = price + w.stamina_regen_when_hit * 3 end
		if w.equilibrium_regen_when_hit then price = price + w.equilibrium_regen_when_hit * 3 end
		if w.mana_regen_when_hit then price = price + w.mana_regen_when_hit * 3 end
		if w.psi_regen_when_hit then price = price + w.psi_regen_when_hit * 3 end
		if w.hate_regen_when_hit then price = price + w.hate_regen_when_hit * 3 end
		if w.vim_regen_when_hit then price = price + w.vim_regen_when_hit * 3 end
		if w.mana_on_crit then price = price + w.mana_on_crit * 3 end
		if w.vim_on_crit then price = price + w.vim_on_crit * 3 end
		if w.psi_on_crit then price = price + w.psi_on_crit * 3 end
		if w.hate_on_crit then price = price + w.hate_on_crit * 3 end
		if w.psi_per_kill then price = price + w.psi_per_kill * 3 end
		if w.hate_per_kill then price = price + w.hate_per_kill * 3 end
		if w.resource_leech_chance then price = price + w.resource_leech_chance * 10 end
		if w.resource_leech_value then price = price + w.resource_leech_value * 10 end

		--combat attributes
		if w.combat_def then price = price + w.combat_def * 1 end
		if w.combat_def_ranged then price = price + w.combat_def_ranged * 1 end
		if w.combat_armor then price = price + w.combat_armor * 1 end
		if w.combat_physcrit then price = price + w.combat_physcrit * 1.4 end
		if w.combat_critical_power then price = price + w.combat_critical_power * 2 end
		if w.combat_atk then price = price + w.combat_atk * 1 end
		if w.combat_apr then price = price + w.combat_apr * 0.3 end
		if w.combat_dam then price = price + w.combat_dam * 3 end
		if w.combat_physspeed then price = price + w.combat_physspeed * -200 end
		if w.combat_spellpower then price = price + w.combat_spellpower * 0.8 end
		if w.combat_spellcrit then price = price + w.combat_spellcrit * 0.4 end

		--shooter attributes
		if w.ammo_regen then price = price + w.ammo_regen * 10 end
		if w.ammo_reload_speed then price = price + w.ammo_reload_speed *10 end
		if w.travel_speed then price = price +w.travel_speed * 10 end

		--miscellaneous attributes
		if w.inc_stealth then price = price + w.inc_stealth * 1 end
		if w.see_invisible then price = price + w.see_invisible * 0.2 end
		if w.infravision then price = price + w.infravision * 1.4 end
		if w.trap_detect_power then price = price + w.trap_detect_power * 1.2 end
		if w.disarm_bonus then price = price + w.disarm_bonus * 1.2 end
		if w.healing_factor then price = price + w.healing_factor * 0.8 end
		if w.heal_on_nature_summon then price = price + w.heal_on_nature_summon * 1 end
		if w.nature_summon_regen then price = price + w.nature_summon_regen * 5 end
		if w.max_encumber then price = price + w.max_encumber * 0.4 end
		if w.movement_speed then price = price + w.movement_speed * 100 end
		if w.fatigue then price = price + w.fatigue * -1 end
		if w.lite then price = price + w.lite * 10 end
		if w.size_category then price = price + w.size_category * 25 end
		if w.esp_all then price = price + w.esp_all * 25 end
		if w.esp then price = price + table.count(w.esp) * 7 end
		if w.esp_range then price = price + w.esp_range * 15 end
		if w.can_breath then for t, v in pairs(w.can_breath) do price = price + v * 30 end end
		if w.damage_shield_penetrate then price = price + w.damage_shield_penetrate * 1 end
		if w.spellsurge_on_crit then price = price + w.spellsurge_on_crit * 5 end
		if w.quick_weapon_swap then price = price + w.quick_weapon_swap * 50 end

		--on teleport abilities
		if w.resist_all_on_teleport then price = price + w.resist_all_on_teleport * 4 end
		if w.defense_on_teleport then price = price + w.defense_on_teleport * 3 end
		if w.effect_reduction_on_teleport then price = price + w.effect_reduction_on_teleport * 2 end

		--resists
		if w.resists then for t, v in pairs(w.resists) do price = price + v * 0.15 end end

		--resist penetration
		if w.resists_pen then for t, v in pairs(w.resists_pen) do price = price + v * 1 end end

		--resist cap
		if w.resists_cap then for t, v in pairs(w.resists_cap) do price = price + v * 5 end end

		--stats
		if w.inc_stats then for t, v in pairs(w.inc_stats) do price = price + v * 3 end end

		--percentage damage increases
		if w.inc_damage then for t, v in pairs(w.inc_damage) do price = price + v * 0.8 end end
		if w.inc_damage_type then for t, v in pairs(w.inc_damage_type) do price = price + v * 0.8 end end

		--damage auras
		if w.on_melee_hit then for t, v in pairs(w.on_melee_hit) do price = price + v * 0.6 end end

		--projected damage
		if w.melee_project then for t, v in pairs(w.melee_project) do price = price + v * 0.7 end end
		if w.ranged_project then for t, v in pairs(w.ranged_project) do price = price + v * 0.7 end end
		if w.burst_on_hit then for t, v in pairs(w.burst_on_hit) do price = price + v * 0.8 end end
		if w.burst_on_crit then for t, v in pairs(w.burst_on_crit) do price = price + v * 0.8 end end

		--damage conversion
		if w.convert_damage then for t, v in pairs(w.convert_damage) do price = price + v * 1 end end

		--talent mastery
		if w.talent_types_mastery then for t, v in pairs(w.talent_types_mastery) do price = price + v * 100 end end

		--talent cooldown reduction
		if w.talent_cd_reduction then for t, v in pairs(w.talent_cd_reduction) do if v > 0 then price = price + v * 5 end end end
	end

	if self.carrier then count(self.carrier) end
	if self.wielder then count(self.wielder) end
	if self.combat then count(self.combat) end
	return price
end

--- Get item cost
function _M:getPrice()
	local base = self.cost or 0
	if self.egoed then
		base = base + self:getPriceFlags()
	end
	if self.__price_level_mod then base = base * self.__price_level_mod end
	return base
end

--- Called when trying to pickup
function _M:on_prepickup(who, idx)
	if self.quest and who ~= game.party:findMember{main=true} then
		return "skip"
	end
	if who.player and self.lore then
		game.level.map:removeObject(who.x, who.y, idx)
		game.party:learnLore(self.lore)
		return true
	end
	if who.player and self.force_lore_artifact then
		game.party:additionalLore(self.unique, self:getName(), "artifacts", self.desc)
		game.party:learnLore(self.unique, false, false, false, nil, self)
	end
end

--- Can it stacks with others of its kind ?
function _M:canStack(o)
	-- Can only stack known things
	if not self:isIdentified() or not o:isIdentified() then return false end
	return engine.Object.canStack(self, o)
end

--- On identification, add to lore
function _M:on_identify()
	game:onTickEnd(function()
		if self.on_id_lore then
			game.party:learnLore(self.on_id_lore, false, false, true)
		end
		if self.unique and self.desc and not self.no_unique_lore then
			game.party:additionalLore(self.unique, self:getName{no_add_name=true, do_color=false, no_count=true}, "artifacts", self.desc)
			game.party:learnLore(self.unique, false, false, true, nil, self)
		end
	end)
end

--- Add some special properties right before wearing it
function _M:specialWearAdd(prop, value)
	self._special_wear = self._special_wear or {}
	self._special_wear[prop] = self:addTemporaryValue(prop, value)
end

--- Add some special properties right when completing a set
-- Items with overlapping sets (such as Kinetic/Thermal/Charged focus) must
-- include the set_id parameter identifying which of the overlapping sets the
-- bonus belongs to. Otherwise, breaking one of the overlapping sets will
-- remove ALL set bonuses from the other item(s).
function _M:specialSetAdd(prop, value, set_id)
	self._special_set = self._special_set or {}
	if set_id then
		self._special_set[set_id] = self._special_set[set_id] or {}
		self._special_set[set_id][prop] = self:addTemporaryValue(prop, value)
	else
		self._special_set[prop] = self:addTemporaryValue(prop, value)
	end
end

function _M:getCharmPower(who, raw)
	if raw then return self.charm_power or 1 end
	local def = self.charm_power_def or {add=0, max=100}
	if type(def) == "function" then
		return def(self, who)
	else
		local v = def.add + ((self.charm_power or 1) * def.max / 100)
		if def.floor then v = math.floor(v) end
		return v
	end
end

function _M:addedToLevel(level, x, y)
	if self.material_level_min_only and level.data then
		local min_mlvl = util.getval(level.data.min_material_level) or 1
		local max_mlvl = util.getval(level.data.max_material_level) or 5
		self.material_level_gen_range = {min=min_mlvl, max=max_mlvl}
	end

	if level and level.data and level.data.objects_cost_modifier then
		self.__price_level_mod = util.getval(level.data.objects_cost_modifier, self)
	end
end

function _M:getTinker()
	return self.tinker
end

function _M:canAttachTinker(tinker, override)
	if not tinker.is_tinker then return end
	if tinker.on_type and tinker.on_type ~= rawget(self, "type") then return end
	if tinker.on_subtype and tinker.on_subtype ~= rawget(self, "subtype") then return end
	if tinker.on_slot and tinker.on_slot ~= self.slot then return end
	if self.tinker and not override then return end
	if self.forbid_tinkers then return end
	return true
end

-- Staff stuff
local standard_flavors = {
	magestaff = {engine.DamageType.FIRE, engine.DamageType.COLD, engine.DamageType.LIGHTNING, engine.DamageType.ARCANE},
	starstaff = {engine.DamageType.LIGHT, engine.DamageType.DARKNESS, engine.DamageType.TEMPORAL, engine.DamageType.PHYSICAL},
	vilestaff = {engine.DamageType.DARKNESS, engine.DamageType.BLIGHT, engine.DamageType.ACID, engine.DamageType.FIRE}, -- yes it overlaps, it's okay
}
_M.staves_standard_flavors = standard_flavors

-- from command-staff.lua
local function update_staff_table(o, d_table_old, d_table_new, old_element, new_element, tab, v, is_greater)
	o.wielder[tab] = o.wielder[tab] or {}
	if is_greater then
		if d_table_old then for i = 1, #d_table_old do
			o.wielder[tab][d_table_old[i]] = math.max(0, (o.wielder[tab][d_table_old[i]] or 0) - v)
			if o.wielder[tab][d_table_old[i]] == 0 then o.wielder[tab][d_table_old[i]] = nil end
		end end
		for i = 1, #d_table_new do
			o.wielder[tab][d_table_new[i]] = (o.wielder[tab][d_table_new[i]] or 0) + v
		end
	else
		if old_element then
			o.wielder[tab][old_element] = math.max(0, (o.wielder[tab][old_element] or 0) - v)
			if o.wielder[tab][old_element] == 0 then o.wielder[tab][old_element] = nil end
		end
		o.wielder[tab][new_element] = (o.wielder[tab][new_element] or 0) + v
	end
end

function _M:getStaffFlavorList()
	if self.modes and not self.flavors then -- build flavor list for older staves
		self.flavors = {exoticstaff={}}
		for i = 1, #self.modes do
			self.flavors.exoticstaff[i] = self.modes[i]:upper()
		end
	end
	return self.flavors or standard_flavors
end

function _M:getStaffFlavor(flavor)
	local flavors = self:getStaffFlavorList()
	if not flavors[flavor] then return nil end
	if flavors[flavor] == true then return standard_flavors[flavor]
	else return flavors[flavor] end
end

local function staff_command(o) -- compat
	if o.command_staff then return o.command_staff end
	if o.no_command then return {} end
	o.command_staff = {
		inc_damage = 1,
		resists = o.combat.of_protection and 0.5 or nil,
		resists_pen = o.combat.of_breaching and 0.5 or nil,
		of_warding = o.combat.of_warding and {add=2, mult=0, "wards"} or nil,
		of_greater_warding = o.combat.of_greater_warding and {add=3, mult=0, "wards"} or nil,
	}
	return o.command_staff
end

-- Command a staff to another element
function _M:commandStaff(element, flavor)
	if self.subtype ~= "staff" then return end
	local old_element = self.combat.element or self.combat.damtype  -- safeguard!
	element  = element or old_element
	flavor = flavor or self.flavor_name
	-- Art staves may define new flavors or redefine meaning of existing ones; "true" means standard, otherwise it should be a list of damage types.
	local old_flavor = self:getStaffFlavor(self.flavor_name)
	local new_flavor = self:getStaffFlavor(flavor)
	if not new_flavor then return end
	local staff_power = self.combat.staff_power or self.combat.dam
	local is_greater = self.combat.is_greater
	for k, v in pairs(staff_command(self)) do
		if v then
			if type(v) == "table" then
				local power = staff_power * (v.mult or 1) + v.add
				update_staff_table(self, old_flavor, new_flavor, old_element, element, v[1] or k, power, is_greater)
			elseif type(v) == "number" then  -- shortcut for previous case
				update_staff_table(self, old_flavor, new_flavor, old_element, element, k, staff_power * v, is_greater)
			else
				v(self, element, flavor, update_staff_table)
			end
		end
	end
	self.combat.element = element
	if self.combat.melee_element then self.combat.damtype = element end
	if not self.unique then self.name = _t(self.name):gsub(_t(self.flavor_name or "staff"), _t(flavor)) end
	self.flavor_name = flavor
end

-- find the preferred element for a staff user based on talents
-- @param who the staff user
-- @param force force recalculation
-- @return string or nil, best element type
-- @return string, best aspect
-- @return damage weights (based on tactical info), sets self.ai_state._pref_staff_element
function _M:getStaffPreferredElement(who, force)
	if not who then return end
	-- get a list of elements the staff can use
	local damweights, aspects = {}, {}
	local aspect = self.flavor_name or "none"
	local flavors = self:getStaffFlavorList()
	for flav, dams in pairs(flavors) do
		for j, typ in ipairs(self:getStaffFlavor(flav)) do
			damweights[typ] = 0
			aspects[typ] = flav
		end
	end
	if not force and who.ai_state._pref_staff_element and damweights[who.ai_state._pref_staff_element] then
		return who.ai_state._pref_staff_element, aspects[who.ai_state._pref_staff_element], damweights
	end
	for tid, lev in pairs(who.talents) do
		if tid ~= "T_ATTACK" then
			local t = who.talents_def[tid]
			local tacs = t.tactical
			local damType
			if type(tacs) == "table" then
				for tac, val in pairs(tacs) do
					if (tac == "attack" or tac == "attackarea") and type(val) == "table" then
						for typ, weight in pairs(val) do
							if damweights[typ] then --matches a staff element
								local wt = type(weight) == "number" and weight or type(weight) == "function" and weight(who, t, who) or 0
								damweights[typ] = damweights[typ] + wt*lev
							end
						end
					end
				end
			end
		end
	end
	local best, wt = self.combat.element or self.combat.damtype, 0
	for typ, weight in pairs(damweights) do
		if weight > wt then best, wt = typ, weight end
	end
	if wt > 0 then aspect = aspects[best] end
	return wt > 0 and best, aspect, damweights
end
