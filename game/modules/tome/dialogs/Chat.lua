-- TE4 - T-Engine 4
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
local Chat = require "engine.dialogs.Chat"
local VariableList = require "engine.ui.VariableList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local ActorFrame = require "engine.ui.ActorFrame"

module(..., package.seeall, class.inherit(Chat))

function _M:init(chat, id, width)
	self.ui = "chat"

	Chat.init(self, chat, id, math.max(width, game.w * 0.4))
end

function _M:makeUI()
	local xoff = 0

	self.c_desc = Textzone.new{font=self.chat.dialog_text_font, width=self.iw - 10 - xoff, height=1, auto_height=true, text=self.text.."\n", can_focus=false}
	self.c_list = VariableList.new{font=self.chat.dialog_answer_font, width=self.iw - 10 - xoff, max_height=game.h * 0.70 - self.c_desc.h, list=self.list, fct=function(item) self:use(item) end, select=function(item) self:select(item) end}
	local npc_frame = ActorFrame.new{actor=self.npc.chat_display_entity or self.npc, w=128, h=128, allow_shader=false, allow_cb=false}
	local player_frame = ActorFrame.new{actor=self.player.chat_display_entity or self.player, w=128, h=128, allow_shader=false, allow_cb=false}

	local uis = {
		{left=0, top=0, ui=self.c_desc},
		{right=0, bottom=math.max(self.c_desc.h, npc_frame.h) + 5, ui=self.c_list},
		{left=5, top=self.c_desc.h - 10, ui=Separator.new{ui="simple", dir="vertical", size=self.iw - 10}},
		{right=-128, vcenter=0, ui=npc_frame, ignore_size=true},
		{left=-128, vcenter=0, ui=player_frame, ignore_size=true},
	}

	self:loadUI(uis)
	self:setFocus(self.c_list)
	self:setupUI(false, true, function(w, h)
		self.force_x = game.w / 2 - w / 2
		self.force_y = game.h - h - 20
	end)
end
