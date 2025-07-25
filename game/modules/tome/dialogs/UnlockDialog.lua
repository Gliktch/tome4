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

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(what)
	self.what = what

	local f, err = loadfile("/data/texts/unlock-"..self.what..".lua")
	if not f and err then error(err) end
	setfenv(f, {_t=_t})
	self.name, self.str = f()

	game.logPlayer(game.player, "#VIOLET#Option unlocked: %s", self.name)

	Dialog.init(self, ("Option unlocked: %s"):tformat(self.name), math.min(math.max(game.w * 0.8, 800), 1200, game.w), 400)

	self.c_desc = Textzone.new{width=math.floor(self.iw - 10), no_color_bleed=true, auto_height=true, text=self.str}

	self:loadUI{
		{left=0, top=0, ui=self.c_desc},
	}
	self:setupUI(true, true)

	self.key:addBinds{
		ACCEPT = accept_key and "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
			if on_exit then on_exit() end
		end,
	}
end
