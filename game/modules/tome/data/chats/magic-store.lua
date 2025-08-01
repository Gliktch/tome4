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

local function recharge(npc, player)
	player:showEquipInven(_t"Select the item to recharge", function(o) return o.recharge_cost and o.power and o.max_power and o.power < o.max_power end, function(o, inven, item)
		local cost = math.ceil(o.recharge_cost * (o.max_power / (o.use_talent and o.use_talent.power or o.use_power.power)))
		if cost > player.money then require("engine.ui.Dialog"):simplePopup(_t"Not enough money", ("This costs %d gold."):tformat(cost)) return true end
		require("engine.ui.Dialog"):yesnoPopup(_t"Recharge?", ("This will cost you %d gold."):tformat(cost), function(ok) if ok then
			o.power = o.max_power
			player:incMoney(-cost)
			player.changed = true
		end end)
		return true
	end)

end

newChat{ id="welcome",
	text = _t[[Welcome, @playername@, to my shop.]],
	answers = {
		{_t"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{_t"I want to recharge some of my equipment.", action=recharge},
		{_t("Sorry, I have to go!", "chat_magic-store")},
	}
}

return "welcome"
