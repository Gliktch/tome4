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
level.data.on_enter_list.sludgenest = function()
	if game.level.data.sludgenest_added then return end
	if game:getPlayer(true).level < 30 then return end

	local spot = game.level:pickSpot{type="world-encounter", subtype="sludgenest"}
	if not spot then return end

	game.level.data.sludgenest_added = true
	local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN):cloneFull()
	g.name = _t"Way into a strange lush forest"
	g.display='>' g.color_r=100 g.color_g=255 g.color_b=0 g.notice = true
	g.change_level=1 g.change_zone="sludgenest" g.glow=true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/jungle/jungle_tree_11.png", display_y=-1, display_h=2, z=16}
	g:altered()
	g:initGlow()
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
	print("[WORLDMAP] sludgenest at", spot.x, spot.y)
	require("engine.ui.Dialog"):simpleLongPopup(_t"Lush forest", _t"Suddenly it comes back to you. You remember long ago somebody told you about a strange lush forest... If only you could remember where!", 400)
end

return true
