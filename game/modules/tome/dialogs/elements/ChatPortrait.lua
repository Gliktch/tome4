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
local Tiles = require "engine.Tiles"
local Base = require "engine.ui.Base"
local ActorFrame = require "engine.ui.ActorFrame"

--- A generic UI image
-- @classmod engine.ui.Image
module(..., package.seeall, class.inherit(Base))

function _M:init(t)
	assert(t.actor, "no ChatPortrait actor")
	
	self.name = t.actor.getName and t.actor:getName() or _t(t.actor.name)
	if t.actor.moddable_tile then
		self.actor_frame = ActorFrame.new{actor=t.actor, w=128, h=128, allow_cb=false, allow_shader=false}
	elseif t.actor.image == "invis.png" and t.actor.add_mos and t.actor.add_mos[1] and t.actor.add_mos[1].image then
		self.image = Tiles:loadImage(t.actor.add_mos[1].image)
	else
		self.image = Tiles:loadImage(t.actor.image)
	end
	if self.image then
		local iw, ih = self.image:getSize()
		if iw <= 64 then iw, ih = iw * 2, ih * 2 end
		self.iw, self.ih = iw, ih
		if self.image.getEmptyMargins then
			local x1, x2, y1, y2 = self.image:getEmptyMargins()
			self.iy = y1
		else
			self.iy = 0
		end
	else
		self.iy = 0
		self.iw, self.ih = 128, 128
	end

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.front = self:getUITexture("ui/portrait_frame_front.png")
	self.back = self:getUITexture("ui/portrait_frame_back.png")
	self.w, self.h = self.front.w, self.front.h

	if self.image then self.item = {self.image:glTexture(Tiles.sharp_scaling)} end

	self.name_tex = self:drawFontLine(self.font, self.name, nil, 0xff, 0xee, 0xcb)
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y)
	self.back.t:toScreenFull(x, y, self.back.w, self.back.h, self.back.tw, self.back.th)
	core.display.glScissor(true, screen_x + 15, screen_y + 15, 128, 192)
	local dx, dy = x + 15 + (128 - self.iw) / 2, y + 15 + (192 - self.ih) / 2
	if self.actor_frame then
		self.actor_frame:display(dx, dy - self.iy)
	else
		self.item[1]:toScreen(dx, dy - self.iy, self.iw, self.ih)
	end
	core.display.glScissor(false)
	self.front.t:toScreenFull(x, y, self.front.w, self.front.h, self.front.tw, self.front.th)

	core.display.glScissor(true, screen_x + 4, screen_y + 229, 152, 23)
	-- Center if it fits, left align is not
	if self.name_tex.w <= 229 then
		self:textureToScreen(self.name_tex, x + 80 - self.name_tex.w / 2, y + 240 - self.name_tex.h / 2)
	else
		self:textureToScreen(self.name_tex, x + 4, y + 240 - self.name_tex.h / 2)
	end
	core.display.glScissor(false)
end
