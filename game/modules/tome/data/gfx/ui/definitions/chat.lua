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

chat = {
	frame_alpha = 1,
	frame_darkness = 0.6,
	frame_ox1 = -14,
	frame_ox2 = 14,
	frame_oy1 = -5,
	frame_oy2 = 10,
	-- force_min_w = 64 * 4,
	-- force_min_h = 64 * 4,
	specifics = {
		["ui/textbox"] = {
			offset_w = -(64 - 30) * 2,
			offset_x = 64 - 30,
		},
	},
}
