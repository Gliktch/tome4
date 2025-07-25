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
local Dialog = require "engine.ui.Dialog"
local VariableList = require "engine.ui.VariableList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local ActorFrame = require "engine.ui.ActorFrame"

--- Controls chat between players and npcs
-- @classmod engine.dialogs.Chat
module(..., package.seeall, class.inherit(Dialog))

show_portraits = false

function _M:init(chat, id, width)
	self.force_width = width
	self.cur_id = id
	self.chat = chat
	self.npc = chat.npc
	self.player = chat.player
	self.no_offscreen = "bottom"
	Dialog.init(self, self.force_title or (self.npc.getName and self.npc:getName() or self.npc.name), width or 500, 400)

	self:generateList()

	self:makeUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if self.list and self.list.chars[c] then
				self:use(self.list[self.list.chars[c]])
			end
		end,
	}
end

function _M:makeUI()
	local xoff = 0
	if self.show_portraits then
		xoff = 64
	end

	self.c_desc = Textzone.new{font=self.chat.dialog_text_font, width=self.iw - 10 - xoff, height=1, auto_height=true, text=self.text.."\n", can_focus=false}
	self.c_list = VariableList.new{font=self.chat.dialog_answer_font, width=self.iw - 10 - xoff, max_height=game.h * 0.70 - self.c_desc.h, list=self.list, fct=function(item) self:use(item) end, select=function(item) self:select(item) end}

	local uis = {
		{left=0, top=0, ui=self.c_desc},
		{left=0, bottom=0, ui=self.c_list},
		{left=5, top=self.c_desc.h - 10, ui=Separator.new{dir="vertical", size=self.iw - 10}},
	}
	if self.show_portraits then
		uis[#uis+1] = {right=0, top=0, ui=ActorFrame.new{actor=self.npc.chat_display_entity or self.npc, w=64, h=64}}
		uis[#uis+1] = {left=0, bottom=0, ui=ActorFrame.new{actor=self.player.chat_display_entity or self.player, w=64, h=64}}
		uis[2].left = nil uis[2].right = 0
		uis[3].top = math.max(self.c_desc.h, uis[4].ui.h) + 5
	end

	self:loadUI(uis)
	self:setFocus(self.c_list)
	self:setupUI(false, true)
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:select(item)
	local a = self.chat:get(self.cur_id).answers[item.answer]
	if not a then return end

	if a.on_select then
		a.on_select(self.npc, self.player, self)
	end
end

function _M:use(item, a)
	if item then
		if item.answer == -1 then game:unregisterDialog(self) return end
		a = a or self.chat:get(self.cur_id).answers[item.answer]
	end
	if not a then return end

	print("[CHAT] selected", a[1], a.action, a.jump)
	if a.switch_npc then self.chat:switchNPC(a.switch_npc, a.switch_npc_move_camera) end
	if a.action then
		local id = a.action(self.npc, self.player, self)
		if id then
			self.cur_id = id
			self:regen()
			return
		end
	end
	local new_id
	if type(a.jump) == "function" then
	    new_id = a.jump(self.npc, self.player)
	else
	    new_id = a.jump
	end

	if new_id and not self.killed then
		self.cur_id = new_id
		self:regen()
	else
		game:unregisterDialog(self)
		return
	end
end

function _M:regen()
	local d = require(self.chat.chat_dialog).new(self.chat, self.cur_id, self.force_width)
	d.__showup = false
	game:replaceDialog(self, d)
	self.next_dialog = d
end
function _M:resolveAuto()
	if not self.chat:get(self.cur_id).auto then return end
	local auto = self.chat:get(self.cur_id).auto
	local answers = self.chat:get(self.cur_id).answers
	if type(auto) == "function" then
		local mode, res = auto(self.npc, self.player)
		if mode == "exit" then
			game:onTickEnd(function() game:unregisterDialog(self) end)
			return
		elseif mode == "jump" then
			game:onTickEnd(function() self.cur_id = res self:regen() end)
			return
		elseif mode == "answer" then
			game:onTickEnd(function() self:use(nil, answers[res]) end)
			return
		end
	end
	for i, a in ipairs(answers) do
		-- use the first answer that works
		if not a.cond or a.cond(self.npc, self.player) then
			game:onTickEnd(function() self:use(nil, a) end)
			return
		end
	end
end

function _M:generateList()
	self:resolveAuto()

	-- Makes up the list
	local list = { chars={} }
	local nb = 1
	for i, a in ipairs(self.chat:get(self.cur_id).answers or {}) do
		if not a.fallback and (not a.cond or a.cond(self.npc, self.player)) then
			list[#list+1] = { name=string.char(string.byte('a')+nb-1)..") "..self.chat:replace(a[1]), answer=i, color=a.color}
			list.chars[string.char(string.byte('a')+nb-1)] = #list
			nb = nb + 1
		end
	end
	if #list == 0 then
		for i, a in ipairs(self.chat:get(self.cur_id).answers or {}) do
			if a.fallback and (not a.cond or a.cond(self.npc, self.player)) then
				list[#list+1] = { name=string.char(string.byte('a')+nb-1)..") "..self.chat:replace(a[1]), answer=i, color=a.color}
				list.chars[string.char(string.byte('a')+nb-1)] = #list
				nb = nb + 1
			end
		end
	end

	-- Anti bug
	if #list == 0 then
		list[#list+1] = { name=string.char(string.byte('a')+nb-1)..") [error - exit - please report the bug]", answer=-1}
		list.chars[string.char(string.byte('a')+nb-1)] = #list
		nb = nb + 1
	end

	self.list = list

	self.text = self.chat:replace(self.chat:get(self.cur_id).text)

	if self.chat:get(self.cur_id).action then
		self.chat:get(self.cur_id).action(self.npc, self.player)
	end

	return true
end
