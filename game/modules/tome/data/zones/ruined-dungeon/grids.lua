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

load("/data/general/grids/basic.lua")

local loreprefix = ""
if currentZone.clues_layout == "ALT1" then loreprefix = "alt1-" end

for i = 1, 3 do
newEntity{
	define_as = "LORE"..i,
	name = "inscription", image = "terrain/maze_floor.png",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	notice = true,
	lore = loreprefix.."infinite-dungeon-"..i,
	on_move = function(self, x, y, who)
		if not who.player then return end
		game.party:learnLore(self.lore)
	end,
}
end

newEntity{
	define_as = "LORE4",
	name = "inscription", image = "terrain/maze_floor.png",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	notice = true,
	lore = "infinite-dungeon-4",
	on_move = function(self, x, y, who)
		if not who.player then return end
		game:setAllowedBuild("campaign_infinite_dungeon", true)
		game.party:learnLore(self.lore)
	end,
}

newEntity{
	define_as = "INFINITE",
	name = "way into the infinite dungeon", image = "terrain/maze_floor.png", add_mos={{image = "terrain/stair_down.png"}},
	display = '>', color=colors.VIOLET, back_color=colors.DARK_GREY,
	always_remember = true,
	on_move = function(self, x, y, who)
		if not who.player then return end
		local p = game:getPlayer(true)
		if p.winner then
			require("engine.ui.Dialog"):yesnoLongPopup(_t"Infinite Dungeon", _t"You have accomplished great deeds, but if you enter the infinite dungeon there will be no way back. You will go on and on until you meet your glorious death.", 400, function(ret)
				if ret then
					game:changeLevel(math.ceil(game.player.level * 1.5), "infinite-dungeon")
				end
			end)
		else
			require("engine.ui.Dialog"):simplePopup(_t"Infinite Dungeon", _t"You should not go there. There is no way back. Ever. Maybe later when you have done all you must do.")
		end
	end,
}

newEntity{
	define_as = "LOCK",
	name = "sealed door", image = "terrain/sealed_door.png",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{
	define_as = "PORTAL",
	name = "orb", image = "terrain/maze_floor.png", add_displays={class.new{z=18, image = "terrain/pedestal_orb_04.png", display_h=2, display_y=-1}},
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREY,
	force_clone=true,
	always_remember = true,
	notice = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return true end
		if not game.level.data.touch_orb then return true end

		if not self.orb_allowed then
			require("engine.ui.Dialog"):simplePopup(_t"Strange Orb", _t"The orb looks inactive.")
			return true
		end

		local text = "???"
		if self.portal_type == "water" then text = _t"The orb seems to drip water."
		elseif self.portal_type == "earth" then text = _t"The orb is covered in dust."
		elseif self.portal_type == "wind" then text = _t"The orb is floating in the air."
		elseif self.portal_type == "nature" then text = _t"Small seeds seem to be growing inside the orb."
		elseif self.portal_type == "arcane" then text = _t"The orb swirls with magical energies."
		elseif self.portal_type == "fire" then text = _t"Flames burst out of the orb."

		elseif self.portal_type == "darkness" then text = _t"The orb seems to absorb all light."
		elseif self.portal_type == "blood" then text = _t"The orb is drips with thick blood."
		elseif self.portal_type == "ice" then text = _t"The orb is icy to the touch."
		elseif self.portal_type == "time" then text = _t"Time seems to slow down around the orb."
		elseif self.portal_type == "mind" then text = _t"Your mind is filled with strange thoughts as you approach the orb."
		elseif self.portal_type == "blight" then text = _t"The orb seems to corrupt all it touches."
		end
		require("engine.ui.Dialog"):yesnoLongPopup(_t"Strange Orb", text.._t"\nDo you touch it?", 400, function(ret)
			if ret then
				game.level.data.touch_orb(self.portal_type, x, y)
			end
		end)
		return true
	end,
}
