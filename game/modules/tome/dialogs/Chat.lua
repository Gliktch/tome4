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
local ChatPortrait = require "mod.dialogs.elements.ChatPortrait"
local Map = require "engine.Map"
local Entity = require "engine.Entity"

module(..., package.seeall, class.inherit(Chat))

function _M:init(chat, id, width)
	self.ui = "chat"
	self.force_title = ""
	self.force_min_h = 256

	Chat.init(self, chat, id, math.max(width, game.w * 0.4))
end

function _M:makeUI()
	self.c_desc = Textzone.new{has_box=true, ui="chat", font=self.chat.dialog_text_font, width=self.iw, height=1, auto_height=true, text=self.text, can_focus=false}
	self.c_list = VariableList.new{font=self.chat.dialog_answer_font, width=self.iw, max_height=game.h * 0.70 - self.c_desc.h, list=self.list, fct=function(item) self:use(item) end, select=function(item) self:select(item) end}
	local npc_frame = ChatPortrait.new{ui="chat", actor=self:getActorPortrait(self.npc.chat_display_entity or self.npc)}
	local player_frame = ChatPortrait.new{ui="chat", actor=self:getActorPortrait(self.player.chat_display_entity or self.player)}

	local uis = {
		{hcenter=0, top=-12, ui=self.c_desc},
		{right=0, bottom=0, ui=self.c_list},
		{left=-player_frame.w+self.frame.ox1-5, vcenter=-self.ix-4, ui=player_frame, ignore_size=true},
		{right=-npc_frame.w-self.frame.ox2-5, vcenter=-self.ix-4, ui=npc_frame, ignore_size=true},
	}

	self:loadUI(uis)
	self:setFocus(self.c_list)
	self:setupUI(false, true, function(w, h)
		self.force_x = game.w / 2 - w / 2
		self.force_y = game.h - h - 20
	end)
end

function _M:getActorPortrait(actor)
	local actor = actor.replace_display or actor
	
	-- Moddable tiles are already portrait sized
	if actor.moddable_tile and Map.tiles.no_moddable_tiles then return actor end

	-- No image at all ?
	if not actor.image then
		-- By any chance are we running a talent ?
		if self.player.getCurrentTalent and self.player:getCurrentTalent() then
			local t = self.player:getTalentFromId(self.player:getCurrentTalent())
			if t then
				return Entity.new{name=t.name, image=t.image or "talents/default.png"}
			else
				return Entity.new{name=actor.name, image="talents/default.png"}
			end
		else
			return Entity.new{name=actor.name, image="talents/default.png"}
		end
	end

	-- No need for anything special
	if actor.image:find("^portrait/") then return actor end

	-- Find the npc portrait
	if actor.image == "invis.png" and actor.add_mos and actor.add_mos[1] and actor.add_mos[1].image and actor.add_mos[1].image:find("^npc/") and fs.exists("/data/gfx/shockbolt/"..actor.add_mos[1].image:gsub("^npc/", "portrait/")) then
		return Entity.new{name=actor.name, image=actor.add_mos[1].image:gsub("^npc/", "portrait/")}
	elseif actor.image:find("^npc/") and fs.exists("/data/gfx/shockbolt/"..actor.image:gsub("^npc/", "portrait/")) then
		return Entity.new{name=actor.name, image=actor.image:gsub("^npc/", "portrait/")}
	end

	-- Last resort, use it as it is
	return actor
end
