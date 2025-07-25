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
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Tiles = require "engine.Tiles"
local UI = require "engine.ui.Base"

--- Display of hotkeys with icons
-- @classmod engine.HotkeysIconsDisplay
module(..., package.seeall, class.make)

--- Init
-- @param[type=Actor] actor
-- @number x x coordinate
-- @number y y coordinate
-- @number w width
-- @number h height
-- @param[type=table] bgcolor background color
-- @string[opt="DroidSansMono"] fontname
-- @number[opt=10] fontsize
-- @number icon_w icon width
-- @number icon_h icon height
function _M:init(actor, x, y, w, h, bgcolor, fontname, fontsize, icon_w, icon_h)
	self.actor = actor
	if type(bgcolor) ~= "string" then
		self.bgcolor = bgcolor or {0,0,0}
	else
		self.bgcolor = {0,0,0}
		self.bg_image = bgcolor
	end
	self.font = core.display.newFont(fontname or "/data/font/DroidSansMono.ttf", fontsize or 10)
	self.fontbig = core.display.newFont(fontname or "/data/font/DroidSansMono.ttf", (fontsize or 10) * 2)
	self.font_h = self.font:lineSkip()
	self.dragclics = {}
	self.clics = {}
	self.items = {}
	self.fontname = fontname
	self.fontsize = fontsize

	--local fw, fh = core.display.loadImage("/data/gfx/ui/talent_frame_ok.png"):getSize()
	--self.frames = {w=math.floor(fw * icon_w / 64), h=math.floor(fh * icon_h / 64), rw=icon_w / 64, rh=icon_h / 64}
	self.frames = {}
--	self.frames.ok = { core.display.loadImage("/data/gfx/ui/talent_frame_ok.png"):glTexture() }
--	self.frames.disabled = { core.display.loadImage("/data/gfx/ui/talent_frame_disabled.png"):glTexture() }
--	self.frames.cooldown = { core.display.loadImage("/data/gfx/ui/talent_frame_cooldown.png"):glTexture() }
--	self.frames.sustain = { core.display.loadImage("/data/gfx/ui/talent_frame_sustain.png"):glTexture() }
	self.frames.base = UI:makeFrame("ui/icon-frame/frame", icon_w + 8, icon_h + 8)  --doesn't really matter since we pass a different size


	self.default_entity = Entity.new{display='?', color=colors.WHITE}

	self:resize(x, y, w, h, icon_w, icon_h)
end

--- Sets the display into nb columns
function _M:setColumns(nb)
end

--- Enable our shadows
function _M:enableShadow(v)
	self.shadow = v
end

--- Resize the display area
-- @number x x coordinate
-- @number y y coordinate
-- @number w width
-- @number h height
-- @number iw icon width
-- @number ih icon height
function _M:resize(x, y, w, h, iw, ih)
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.surface = core.display.newSurface(w, h)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
	if self.actor then self.actor.changed = true end

	if iw and ih and (self.icon_w ~= iw or self.icon_h ~= ih) then
		self.icon_w = iw
		self.icon_h = ih
		self.frames.w = iw + 8
		self.frames.fx = 4
		self.frames.h = ih + 8
		self.frames.fy = 4
		self.tiles = Tiles.new(iw, ih, self.fontname or "/data/font/DroidSansMono.ttf", self.fontsize or 10, true, true)
		self.tiles.use_images = true
		self.tiles.force_back_color = {r=0, g=0, b=0}
	end

	self.max_cols = math.floor(self.w / self.frames.w)
	self.max_rows = math.floor(self.h / self.frames.h)

	if self.bg_image then
		local fill = core.display.loadImage(self.bg_image)
		local fw, fh = fill:getSize()
		self.bg_surface = core.display.newSurface(w, h)
		self.bg_surface:erase(0, 0, 0)
		for i = 0, w, fw do for j = 0, h, fh do
			self.bg_surface:merge(fill, i, j)
		end end
		self.bg_texture, self.bg_texture_w, self.bg_texture_h = self.bg_surface:glTexture()
	end
end

local page_to_hotkey = {"", "SECOND_", "THIRD_", "FOURTH_", "FIFTH_", "SIX_", "SEVEN_"}

local frames_colors = {
	ok = {0.3, 0.6, 0.3},
	sustain = {0.6, 0.6, 0},
	cooldown = {0.6, 0, 0},
	disabled = {0.65, 0.65, 0.65},
}

-- Store it so addons can play with it.
_M.frames_colors = frames_colors

-- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	local bpage = a.hotkey_page
	local spage = bpage
--	if bpage == 1 and core.key.modState("ctrl") then spage = 2 if self.max_cols < 24 then bpage = 2 end
--	elseif bpage == 1 and core.key.modState("shift") then spage = 3 if self.max_cols < 36 then bpage = 3 end
--	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	if self.bg_surface then self.surface:merge(self.bg_surface, 0, 0) end

	local orient = self.orient or "down"
	local x = 0
	local y = 0
	local col, row = 0, 0
	self.dragclics = {}
	self.clics = {}
	self.items = {}
	local w, h = self.frames.w, self.frames.h

	for page = bpage, #page_to_hotkey do 
		for i = 1, 12 do
			local ts = nil
			local bi = i
			local j = i + (12 * (page - 1))
			if a.hotkey[j] and a.hotkey[j][1] == "talent" then
				ts = {a.hotkey[j][2], j, "talent", i, page, i + (12 * (page - bpage))}
			elseif a.hotkey[j] and a.hotkey[j][1] == "inventory" then
				ts = {a.hotkey[j][2], j, "inventory", i, page, i + (12 * (page - bpage))}
			end

			x = self.frames.w * col
			y = self.frames.h * row
			self.dragclics[j] = {x,y,w,h}
			
			local ind, hktable, cfake = self:displayHotkey(page, i, x, y, ts)
			
			self.items[#self.items+1] = hktable
			self.clics[ind] = {x, y, w, h, fake=cfake}
		
			if orient == "down" or orient == "up" then
				col = col + 1
				if col >= self.max_cols then
					col = 0
					row = row + 1
					if row >= self.max_rows then return end
				end
			elseif orient == "left" or orient == "right" then
				row = row + 1
				if row >= self.max_rows then
					row = 0
					col = col + 1
					if col >= self.max_cols then return end
				end
			end
		end 
	end
end

function _M:displayHotkey(page, i, x, y, ts)
	local bi = i
	local w, h = self.frames.w, self.frames.h
	local a = self.actor
	
	if ts then
		local s
		local i = ts[2]
		local lpage = ts[5]
		local color, angle, txt = nil, 0, nil
		local display_entity = nil
		local frame = "ok"
		if ts[3] == "talent" then
			local tid = ts[1]
			local t = a:getTalentFromId(tid)
			if t then
				display_entity = t.display_entity
				if a:isTalentCoolingDown(t) then
					if not a:preUseTalent(t, true, true) then
						color = {190,190,190}
						frame = "disabled"
					else
						frame = "cooldown"
						color = {255,0,0}
						angle = 360 * (1 - (a.talents_cd[t.id] / a:getTalentCooldown(t)))
					end
					txt = tostring(math.ceil(a:isTalentCoolingDown(t)))
				elseif a:isTalentActive(t.id) then
					color = {255,255,0}
					frame = "sustain"
				elseif not a:preUseTalent(t, true, true) then
					color = {190,190,190}
					frame = "disabled"
				end
			end
		elseif ts[3] == "inventory" then
			local o = a:findInAllInventories(ts[1], {no_add_name=true, force_id=true, no_count=true})
			local cnt = 0
			if o then cnt = o:getNumber() end
			if cnt == 0 then
				color = {190,190,190}
				frame = "disabled"
			end
			display_entity = o
			if o and o.use_talent and o.use_talent.id then
				local t = a:getTalentFromId(o.use_talent.id)
				display_entity = t and t.display_entity
			end
			if o and o.talent_cooldown then
				local t = a:getTalentFromId(o.talent_cooldown)
				angle = 360
				if t and a:isTalentCoolingDown(t) then
					color = {255,0,0}
					angle = 360 * (1 - (a.talents_cd[t.id] / a:getTalentCooldown(t)))
					frame = "cooldown"
					txt = tostring(math.ceil(a:isTalentCoolingDown(t)))
				end
			elseif o and (o.use_talent or o.use_power) then
				angle = 360 * ((o.power / o.max_power))
				color = {255,0,0}
				local cd = o:getObjectCooldown(a)
				if cd and cd > 0 then
					frame = "cooldown"
					txt = tostring(cd)
				elseif not cd then
					frame = "disabled"
				end
			end
			if o and o.wielded then
				frame = "sustain"
			end
			if o and o.wielded and o.use_talent and o.use_talent.id then
				local t = a:getTalentFromId(o.use_talent.id)
				if not a:preUseTalent(t, true, true, true) then
					angle = 0
					color = {190,190,190}
					frame = "disabled"
				end
			end
		end

		self.font:setStyle("bold")
		local ks = game.key:formatKeyString(game.key:findBoundKeys("HOTKEY_"..page_to_hotkey[page]..bi))
		local key = self.font:draw(ks, self.font:size(ks), colors.ANTIQUE_WHITE.r, colors.ANTIQUE_WHITE.g, colors.ANTIQUE_WHITE.b, true)[1]
		self.font:setStyle("normal")

		local gtxt = nil
		if txt then
			gtxt = self.fontbig:draw(txt, w, colors.WHITE.r, colors.WHITE.g, colors.WHITE.b, true)[1]
			gtxt.fw, gtxt.fh = self.fontbig:size(txt)
		end

		--self.items[#self.items+1] = {i=i, x=x, y=y, e=display_entity or self.default_entity, color=color, angle=angle, key=key, gtxt=gtxt, frame=frame, pagesel=lpage==a.hotkey_page}
		--self.clics[i] = {x,y,w,h}
		
		return i, {i=i, x=x, y=y, e=display_entity or self.default_entity, color=color, angle=angle, key=key, gtxt=gtxt, frame=frame, pagesel=lpage==a.hotkey_page}, nil
	else
		local i = i + (12 * (page - 1))
		local angle = 0
		local color = {190,190,190}
		local frame = "disabled"

		self.font:setStyle("bold")
		local ks = game.key:formatKeyString(game.key:findBoundKeys("HOTKEY_"..page_to_hotkey[page]..bi))
		local key = self.font:draw(ks, self.font:size(ks), colors.ANTIQUE_WHITE.r, colors.ANTIQUE_WHITE.g, colors.ANTIQUE_WHITE.b, true)[1]
		self.font:setStyle("normal")

		--self.items[#self.items+1] = {show_on_drag=true, i=i, x=x, y=y, e=nil, color=color, angle=angle, key=key, gtxt=nil, frame=frame}
		--self.clics[i] = {x,y,w,h, fake=true}
		return i, {show_on_drag=true, i=i, x=x, y=y, e=nil, color=color, angle=angle, key=key, gtxt=nil, frame=frame}, true
	end
end

--- Our toScreen override
function _M:toScreen()
	self:display()
	local shader = Shader.default.textoutline and Shader.default.textoutline.shad
	if self.bg_texture then self.bg_texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.bg_texture_w, self.bg_texture_h) end
	for i = 1, #self.items do
		local item = self.items[i]
		if not item.show_on_drag or (game.mouse and game.mouse.drag) and self.cur_sel then
			local key = item.key
			local gtxt = item.gtxt
			local frame = self.frames_colors[item.frame]
			local pagesel = item.pagesel and 1 or 0.5

			if item.e then item.e:toScreen(self.tiles, self.display_x + item.x + self.frames.fx, self.display_y + item.y + self.frames.fy, self.icon_w, self.icon_h) end

			if item.color then core.display.drawQuadPart(self.display_x + item.x + self.frames.fx, self.display_y + item.y + self.frames.fy, self.icon_w, self.icon_h, item.angle, item.color[1], item.color[2], item.color[3], 100) end

			if self.cur_sel == item.i then core.display.drawQuad(self.display_x + item.x + self.frames.fx, self.display_y + item.y + self.frames.fy, self.icon_w, self.icon_h, 128, 128, 255, 80) end

	--		frame[1]:toScreenFull(self.display_x + item.x, self.display_y + item.y, self.frames.w, self.frames.h, frame[2] * self.frames.rw, frame[3] * self.frames.rh, pagesel, pagesel, pagesel, 255)
	--		frame[1]:toScreenFull(self.display_x + item.x, self.display_y + item.y, self.frames.w, self.frames.h, frame[2] * self.frames.rw, frame[3] * self.frames.rh, pagesel, pagesel, pagesel, 255)
			UI:drawFrame(self.frames.base, self.display_x + item.x, self.display_y + item.y, frame[1], frame[2], frame[3], 1, self.frames.w, self.frames.h)

			if self.shadow then
				if shader then
					shader:use(true)
					shader:uniOutlineSize(0.7, 0.7)
					shader:uniTextSize(key._tex_w, key._tex_h)
				else
					key._tex:toScreenFull(self.display_x + item.x + 1 + self.frames.fx + self.icon_w - key.w, self.display_y + item.y + 1 + self.icon_h - key.h, key.w, key.h, key._tex_w, key._tex_h, 0, 0, 0, self.shadow)
					if gtxt then gtxt._tex:toScreenFull(self.display_x + item.x + self.frames.fy + 2 + (self.icon_w - gtxt.fw) / 2, self.display_y + item.y + self.frames.fy + 2 + (self.icon_h - gtxt.fh) / 2, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h, 0, 0, 0, self.shadow) end
				end
			end

			key._tex:toScreenFull(self.display_x + item.x + self.frames.fx + self.icon_w - key.w, self.display_y + item.y + self.icon_h - key.h, key.w, key.h, key._tex_w, key._tex_h)
			if gtxt then
				gtxt._tex:toScreenFull(self.display_x + item.x + self.frames.fx + (self.icon_w - gtxt.fw) / 2, self.display_y + item.y + self.frames.fy + (self.icon_h - gtxt.fh) / 2, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h)
			end

			if self.shadow and shader then shader:use(false) end
		end
	end
end

--- Call when a mouse event arrives in this zone  
-- This is optional, only if you need mouse support
-- @string button
-- @number mx mouse x
-- @number my mouse y
-- @param[type=boolean] click did they click
-- @param[type=function] on_over callback for hover
-- @param[type=function] on_click callback for click
function _M:onMouse(button, mx, my, click, on_over, on_click)
	local orient = self.orient or "down"
	mx, my = mx - self.display_x, my - self.display_y
	local a = self.actor

	if button == "wheelup" and click then
		a:prevHotkeyPage()
		return
	elseif button == "wheeldown" and click then
		a:nextHotkeyPage()
		return
	elseif button == "drag-end" then
		local drag = game.mouse.dragged.payload
--		print(table.serialize(drag,nil,true))
		if drag.kind == "talent" or drag.kind == "inventory" then
			for i, zone in pairs(self.dragclics) do
				if mx >= zone[1] and mx < zone[1] + zone[3] and my >= zone[2] and my < zone[2] + zone[4] then
					local old = self.actor.hotkey[i]

					if i <= #page_to_hotkey * 12 then -- Only add this hotkey if we support a valid page for it.
						self.actor.hotkey[i] = {drag.kind, drag.id}

						if drag.source_hotkey_slot then
							self.actor.hotkey[drag.source_hotkey_slot] = old
						end

						-- Update the quickhotkeys table immediately rather than waiting for a save.
						if self.actor.save_hotkeys then
							engine.interface.PlayerHotkeys:updateQuickHotkey(self.actor, i)
							engine.interface.PlayerHotkeys:updateQuickHotkey(self.actor, drag.source_hotkey_slot)
						end
					end
					game.mouse:usedDrag()
					self.actor.changed = true
					break
				end
			end
		end
	end

	for i, zone in pairs(self.clics) do
		if mx >= zone[1] and mx < zone[1] + zone[3] and my >= zone[2] and my < zone[2] + zone[4] then
			if on_click and click and not zone.fake then
				if on_click(i, a.hotkey[i]) then click = false end
			end
			local oldsel = self.cur_sel
			self.cur_sel = i
			if button == "left" and not zone.fake then
				if click then
					a:activateHotkey(i)
				else
					if a.hotkey[i][1] == "talent" then
						local t = self.actor:getTalentFromId(a.hotkey[i][2])
						local s = nil
						if t then s = t.display_entity:getEntityFinalSurface(nil, 64, 64) end
						game.mouse:startDrag(mx, my, s, {kind=a.hotkey[i][1], id=a.hotkey[i][2], source_hotkey_slot=i}, function(drag, used) if not used then self.actor.hotkey[i] = nil self.actor.changed = true end end)
					elseif a.hotkey[i][1] == "inventory" then
						local o = a:findInAllInventories(a.hotkey[i][2], {no_add_name=true, force_id=true, no_count=true})
						local s = nil
						if o then s = o:getEntityFinalSurface(nil, 64, 64) end
						game.mouse:startDrag(mx, my, s, {kind=a.hotkey[i][1], id=a.hotkey[i][2], source_hotkey_slot=i}, function(drag, used) if not used then self.actor.hotkey[i] = nil self.actor.changed = true end end)
					end
				end
			elseif button == "right" and click and not zone.fake then
				a.hotkey[i] = nil
				a.changed = true
			else
				a.changed = true
				if on_over and self.cur_sel ~= oldsel and not zone.fake then
					local text = ""
					if a.hotkey[i] and a.hotkey[i][1] == "talent" then
						local t = self.actor:getTalentFromId(a.hotkey[i][2])
						if t then
							text = tstring{{"color","GOLD"}, {"font", "bold"}, t.name .. (config.settings.cheat and " ("..t.id..")" or ""), {"font", "normal"}, {"color", "LAST"}, true}
							text:merge(self.actor:getTalentFullDescription(t))
						else text = _t"Unknown!" end
					elseif a.hotkey[i] and a.hotkey[i][1] == "inventory" then
						local o = a:findInAllInventories(a.hotkey[i][2], {no_add_name=true, force_id=true, no_count=true})
						if o then
							text = o:getDesc()
						else text = _t"Missing!" end
					end
					on_over(text)
				end
			end
			return
		end
	end
	self.cur_sel = nil
end
