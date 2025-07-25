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

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g = require("mod.class.Object").new(g)
g.identified = true
g.name = _t"glimmerstone"
g.desc = _t"It shimmers and changes the light all around. This is dazling!"
g.display='&' g.color_r=255 g.color_g=255 g.color_b=255 g.notice = true
g.always_remember = true
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/moonstone_05.png", display_w=0.5, display_x=0.25, z=5}
end
g:altered()
g.canAct = false
g.x, g.y = x, y
g.act = function(self)
	local grids = core.fov.circle_grids(self.x, self.y, rng.range(1, 2), "block_move")
	for x, yy in pairs(grids) do for y, _ in pairs(yy) do
		if rng.chance(6) then
			if game.level.map.lites(x, y) then
				game.level.map.lites(x, y, false)
			else
				game.level.map.lites(x, y, true)
			end
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if target then
				target:setEffect(target.EFF_DAZING_DAMAGE, 1, {})
				game.logSeen(target, "%s is affected by the glimmerstone!", target:getName():capitalize())
			end
		end
	end end

	self:useEnergy()
end
game.zone:addEntity(game.level, g, "terrain", x, y)
game.level:addEntity(g)

return true
