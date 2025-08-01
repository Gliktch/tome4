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
require "engine.Mouse"
require "engine.DebugConsole"
local tween = require "tween"
local Shader = require "engine.Shader"

--- Represents a game  
-- A module should subclass it and initialize anything it needs to play inside
-- @classmod engine.Game
module(..., package.seeall, class.make)

_M.TICK_RESCHEDULE = {}

--- Sets up the default keyhandler
-- Also requests the display size and stores it in "w" and "h" properties
-- @param[type=Key] keyhandler the default keyhandler for this game
function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
	self.w, self.h, self.fullscreen = core.display.size()
	self.dialogs = {}
	self.save_name = ""
	self.player_name = ""

	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.uniques = {}

	self.__savefile_version_tokens = {}

	self:defaultMouseCursor()
end

--- Log a message
-- Redefine as needed
function _M.log(style, ...) end

--- Log something associated with an entity that is seen by the player
-- Redefine as needed
function _M.logSeen(e, style, ...) end

--- Log something associated with an entity if it is the player
-- Redefine as needed
function _M.logPlayer(e, style, ...) end

--- Default mouse cursor
function _M:defaultMouseCursor()
	local UIBase = require "engine.ui.Base"
	local ui = UIBase.ui or "dark"

	if fs.exists("/data/gfx/"..ui.."-ui/mouse.png") and fs.exists("/data/gfx/"..ui.."-ui/mouse-down.png") then
		self:setMouseCursor("/data/gfx/"..ui.."-ui/mouse.png", "/data/gfx/"..ui.."-ui/mouse-down.png", -4, -4)
	else
		self:setMouseCursor("/data/gfx/ui/mouse.png", "/data/gfx/ui/mouse-down.png", -4, -4)
	end
end

--- Sets the mouse cursor
-- @string mouse image for mouse
-- @string[opt] mouse_down image for mouse click
-- @number offsetx
-- @number offsety
function _M:setMouseCursor(mouse, mouse_down, offsetx, offsety)
	if type(mouse) == "string" then mouse = core.display.loadImage(mouse) end
	if type(mouse_down) == "string" then mouse_down = core.display.loadImage(mouse_down) end
	if mouse then
		self.__cursor = { up=mouse, down=(mouse_down or mouse), ox=offsetx, oy=offsety }
		if config.settings.mouse_cursor then
			core.display.setMouseCursor(self.__cursor.ox, self.__cursor.oy, self.__cursor.up, self.__cursor.down)
		else
			core.display.setMouseCursor(0, 0, nil, nil)
		end
	end
end

--- Called whenever the cursor needs updating
function _M:updateMouseCursor()
	if self.__cursor then
		if config.settings.mouse_cursor then
			core.display.setMouseCursor(self.__cursor.ox, self.__cursor.oy, self.__cursor.up, self.__cursor.down)
		else
			core.display.setMouseCursor(0, 0, nil, nil)
		end
	end
end

--- Called when the game is loaded
function _M:loaded()
	self.w, self.h, self.fullscreen = core.display.size()
	self.dialogs = {}
	self.key = engine.Key.current
	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.__coroutines = self.__coroutines or {}

	self:setGamma(config.settings.gamma_correction / 100)
end

--- Defines the default fields to be saved by the savefile code
-- @param[type=table] t additional definitions to save
-- @return table of definitions
function _M:defaultSavedFields(t)
	local def = {
		w=true, h=true, zone=true, player=true, level=true, entities=true,
		energy_to_act=true, energy_per_tick=true, turn=true, paused=true, save_name=true,
		always_target=true, gfxmode=true, uniques=true, object_known_types=true,
		memory_levels=true, achievement_data=true, factions=true, playing_musics=true,
		state=true,
		__savefile_version_tokens = true, bad_md5_loaded = true,
		__persistent_hooks=true,
	}
	table.merge(def, t)
	return def
end

--- Sets the player name
-- @string name
function _M:setPlayerName(name)
	self.save_name = name
	self.player_name = name
end

--- Do not touch!!
function _M:prerun()
	if self.__persistent_hooks then for _, h in ipairs(self.__persistent_hooks) do
		self:bindHook(h.hook, h.fct)
	end end
end

--- Starts the game
-- Modules should reimplement it to do whatever their game needs
function _M:run()
end

--- Checks if the current character is "tainted" by cheating  
-- @return false by default
function _M:isTainted()
	return false
end

--- Sets the current level
-- @param level a `Level` (or subclass) object
function _M:setLevel(level)
	self.level = level
end

--- Tells the game engine to play this game
function _M:setCurrent()
	core.game.set_current_game(self)
	_M.current = self
end

--- Displays the screen
-- Called by the engine core to redraw the screen every frame
-- @param nb_keyframes The number of elapsed keyframes since last draw (this can be 0). This is set by the engine
function _M:display(nb_keyframes)
	nb_keyframes = nb_keyframes or 1
	if self.flyers then
		self.flyers:display(nb_keyframes)
	end

	-- Suppress the display of dialogs when drawing for a savefile screenshot.
	if not core.display.redrawingForSavefileScreenshot() and #self.dialogs then
		local last = self.dialogs[#self.dialogs]
		for i = last and last.__show_only and #self.dialogs or 1, #self.dialogs do
			local d = self.dialogs[i]
			d:display()
			d:toScreen(d.display_x, d.display_y, nb_keyframes)
		end
	end

	-- Check profile thread events
	self:handleEvents()

	-- Check timers
	if self._timers_cb and nb_keyframes > 0 then
		local new = {}
		local exec = {}
		for cb, frames in pairs(self._timers_cb) do
			frames = frames - nb_keyframes
			if frames <= 0 then exec[#exec+1] = cb
			else new[cb] = frames end
		end
		if next(new) then self._timers_cb = new
		else self._timers_cb = nil end
		for _, cb in ipairs(exec) do cb() end
	end

	-- Update tweening engine
	if nb_keyframes > 0 then tween.update(nb_keyframes) end
end

--- Register a timer
-- @int seconds will be called in the given number of seconds
-- @func cb the callback function
function _M:registerTimer(seconds, cb)
	self._timers_cb = self._timers_cb or {}
	self._timers_cb[cb] = seconds * 30
end

--- Called when the game is focused/unfocused
-- @param[type=boolean] focus are we focused?
function _M:idling(focus)
	self.has_os_focus = focus
--	print("Game got focus/unfocus", focus)
end


--- Handle pending events
function _M:handleEvents()
	local evt = profile:popEvent()
	while evt do
		self:handleProfileEvent(evt)
		evt = profile:popEvent()
	end
end

--- Receives a profile event
-- Usually this just transfers it to the PlayerProfile class but you can overload it to handle special stuff
-- @param evt the event
function _M:handleProfileEvent(evt)
	return profile:handleEvent(evt)
end

--- Returns the player
-- Reimplement it in your module, this can just return nil if you dont want/need
-- the engine adjusting stuff to the player or if you have many players or whatever
-- @param main if true the game should try to return the "main" player, if any
-- @return nil by default
function _M:getPlayer(main)
	return nil
end

--- Returns current "campaign" name
-- @return "default" by default
function _M:getCampaign()
	return "default"
end

--- Says if this savefile is usable or not
-- Reimplement it in your module, returning false when the player is dead
-- @return true by default
function _M:isLoadable()
	return true
end

--- Gets/increment the savefile version
-- @param[opt] token if "new" this will create a new allowed save token and return it. Otherwise this checks the token against the allowed ones and returns true if it is allowed
-- @return uuid
-- @return true
function _M:saveVersion(token)
	if token == "new" then
		token = util.uuid()
		self.__savefile_version_tokens[token] = true
		return token
	end
	return self.__savefile_version_tokens[token]
end

--- This is the "main game loop", do something here
function _M:tick()
	-- If any errors have occurred, save them and open the error dialog
	local errs = core.game.checkError()
	if errs then
		if not self.errors or self.errors.turn ~= self.turn then self.errors = {turn=self.turn, first_error = errs} end
		self.errors.last_error = errs table.insert(self.errors, (#self.errors%10) + 1, errs)
		if config.settings.cheat then for id = #self.dialogs, 1, -1 do self:unregisterDialog(self.dialogs[id]) end end
		self:registerDialog(require("engine.dialogs.ShowErrorStack").new(errs))
	end

	local stop = {}
	local id, co = next(self.__coroutines)
	while id do
		local ok, err = coroutine.resume(co)
		if not ok then
			print(debug.traceback(co))
			print("[COROUTINE] error", err)
		end
		if coroutine.status(co) == "dead" then
			stop[#stop+1] = id
		end
		id, co = next(self.__coroutines, id)
	end
	if #stop > 0 then
		for i = 1, #stop do
			self.__coroutines[stop[i]] = nil
			print("[COROUTINE] dead", stop[i])
		end
	end

	Shader:cleanup()

	if self.cleanSounds then self:cleanSounds() end

	self:onTickEndExecute()
end

--- Run all registered tick end functions
-- Usually just let the engine call it
function _M:onTickEndExecute()
	local set = self.on_tick_end_custom or self.on_tick_end
	if not set then return end

	if #set.fcts > 0 then
		local fs = set.fcts
		set.fcts = {}
		set.names = {}
		for i = 1, #fs do
			local r = fs[i]()
			if r == self.TICK_RESCHEDULE then
				set.fcts[#set.fcts+1] = fs[i]
				core.game.requestNextTick()
			end
		end
	end
end

--- Register things to do on tick end
-- @func f function to do on tick end
-- @string name callback to reference the function
function _M:onTickEnd(f, name)
	local set = self.on_tick_end_custom or self.on_tick_end
	if not set then self.on_tick_end = { fcts={}, names={} } set = self.on_tick_end end

	if name then
		if set.names[name] then return end
		set.names[name] = f
	end

	set.fcts[#set.fcts+1] = f
	core.game.requestNextTick()
end

--- Returns a registered function to do on tick end by name
-- @string name callback to reference the function
function _M:onTickEndGet(name)
	local set = self.on_tick_end_custom or self.on_tick_end
	if not set then return end
	return set.names[name]
end

--- Returns true if at laest one on tick end is planned
function _M:onTickEndExists()
	local set = self.on_tick_end_custom or self.on_tick_end
	if not set then return end
	return #set.fcts > 0
end

--- Cancels all on tick end factions
function _M:onTickEndCancelAll()
	local set = self.on_tick_end_custom or self.on_tick_end
	if not set then return end
	set.fcts = {}
	set.names = {}
end

--- Capture all calls to onTickEnd into a custom table
-- @param set The table to contain all the calls. If set is nil the capture mode ends
function _M:onTickEndCapture(set)
	if set then set.fcts = {} set.names = {} end
	self.on_tick_end_custom = set
end

--- Merge a custom set of on tick end to the current list
-- @param srcset The table that contain all the calls
function _M:onTickEndMerge(srcset)
	local set = self.on_tick_end_custom or self.on_tick_end
	if not set then self.on_tick_end = { fcts={}, names={} } set = self.on_tick_end end

	for _, fct in ipairs(srcset.fcts) do set.fcts[#set.fcts+1] = fct end
	for name, fct in pairs(srcset.names) do set.names[name] = fct end
end

--- Called when a zone leaves a level
-- @param level the level we're leaving
-- @param lev the new level
-- @param old_lev the old level (probably same value as level)
function _M:leaveLevel(level, lev, old_lev)
end

--- Called by the engine when the user tries to close the module
function _M:onQuit()
end

--- Called by the engine when the user tries to close the window
function _M:onExit()
	if core.steam then core.steam.exit() end
	core.game.exit_engine()
end

--- Sets up a `FlyingText` for general use
-- @param[type=FlyingText] fl 
function _M:setFlyingText(fl)
	self.flyers = fl
end

--- Registers a dialog to display
-- @param[type=Dialog] d
function _M:registerDialog(d)
	if d.__refuse_dialog then return end
	table.insert(self.dialogs, d)
	self.dialogs[d] = #self.dialogs
	d.__stack_id = #self.dialogs
	if d.key then d.key:setCurrent() end
	if d.mouse then d.mouse:setCurrent() end
	if d.on_register then d:on_register() end
	if self.onRegisterDialog then self:onRegisterDialog(d) end
end

--- Registers a dialog to display somewhere in the stack
-- @param[type=Dialog] d
-- @int pos the stack position (1=top, 2=second, ...)
function _M:registerDialogAt(d, pos)
	if pos == 1 then return self:registerDialog(d) end
	table.insert(self.dialogs, #self.dialogs - (pos - 2), d)
	for i = 1, #self.dialogs do
		local dd = self.dialogs[i]
		self.dialogs[dd] = i
		dd.__stack_id = i
	end
	if d.on_register then d:on_register() end
	if self.onRegisterDialog then self:onRegisterDialog(d) end
end

--- Replaces a dialog to display with another
-- @param[type=Dialog] src old dialog
-- @param[type=Dialog] dest new dialog
function _M:replaceDialog(src, dest)
	local id = src.__stack_id

	-- Remove old one
	self.dialogs[src] = nil

	-- Update
	self.dialogs[id] = dest
	self.dialogs[dest] = id
	dest.__stack_id = id

	-- Give focus
	if id == #self.dialogs then
		if dest.key then dest.key:setCurrent() end
		if dest.mouse then dest.mouse:setCurrent() end
	end
	if dest.on_register then dest:on_register(src) end
end

--- Undisplay a dialog, removing its own keyhandler if needed
-- @param[type=Dialog] d
function _M:unregisterDialog(d)
	if not self.dialogs[d] then return end
	table.remove(self.dialogs, self.dialogs[d])
	self.dialogs[d] = nil
	d:cleanup()
	d:unload()
	-- Update positions
	for i, id in ipairs(self.dialogs) do id.__stack_id = i self.dialogs[id] = i end

	local last = (#self.dialogs > 0) and self.dialogs[#self.dialogs] or self
	if last.key then last.key:setCurrent() end
	if last.mouse then last.mouse:setCurrent() end
	if self.onUnregisterDialog then self:onUnregisterDialog(d) end
	if last.on_recover_focus then last:on_recover_focus() end
end

--- Do we have a specific dialog
-- @param[type=Dialog] d
function _M:hasDialog(d)
	return self.dialogs[d] and true or false
end

--- Do we have a dialog(s) running
-- @int[opt=0] nb how many dialogs minimum
function _M:hasDialogUp(nb)
	nb = nb or 0
	return #self.dialogs > nb
end

--- The C core gives us command line arguments
-- @param[type=table] args filled in by the C core
function _M:commandLineArgs(args)
	for i, a in ipairs(args) do
		print("Command line: ", a)
	end
end

--- Called by savefile code to describe the current game
-- @return table
function _M:getSaveDescription()
	return {
		name = "player",
		description = [[Busy adventuring!]],
	}
end

--- Save a settings file
-- @string file
-- @param data
function _M:saveSettings(file, data)
	core.game.resetLocale()
	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	local f, msg = fs.open("/settings/"..file..".cfg", "w")
	if f then
		f:write(data)
		f:close()
	else
		print("WARNING: could not save settings in ", file, "::", data, "::", msg)
	end
	if restore then fs.setWritePath(restore) end
end

--- Remove a settings file
-- @string file
function _M:removeSettings(file)
	core.game.resetLocale()
	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	fs.delete("/settings/"..file..".cfg")
	if restore then fs.setWritePath(restore) end
end

available_resolutions =
{
	["800x600 Windowed"] 	= {800, 600, false},
	["1024x768 Windowed"] 	= {1024, 768, false},
	["1200x1024 Windowed"] 	= {1200, 1024, false},
	["1280x720 Windowed"] 	= {1280, 720, false},
	["1600x900 Windowed"] 	= {1600, 900, false},
	["1600x1200 Windowed"] = {1600, 1200, false},
--	["800x600 Fullscreen"] = {800, 600, true},
--	["1024x768 Fullscreen"] = {1024, 768, true},
--	["1200x1024 Fullscreen"] = {1200, 1024, true},
--	["1600x1200 Fullscreen"] = {1600, 1200, true},
}
--- Get the available display modes for the monitor from the core
-- @function list
-- @local
local list = core.display.getModesList()
for _, m in ipairs(list) do
	local ms = m.w.."x"..m.h.." Fullscreen"
	if m.w >= 800 and m.h >= 600 and not available_resolutions[ms] then
		available_resolutions[ms] = {m.w, m.h, true}
	end
end

--- Change screen resolution
-- @string res should be in format like "800x600 Windowed"
-- @param[type=boolean] force try to force the resolution if it can't find it
function _M:setResolution(res, force)
	local r = available_resolutions[res]
	if force and not r then
		local b = false
		local _, _, w, h, f = res:find("([0-9][0-9][0-9]+)x([0-9][0-9][0-9]+)(.*)")
		w = tonumber(w)
		h = tonumber(h)
		if f == " Fullscreen" then
			f = true
		elseif f == " Borderless" then
			f = false
			b = true
		elseif f ~= " Windowed" then
			-- If no windowed/fullscreen option sent, use the old value.
			-- If no old value, opt for windowed mode.
			f = self.fullscreen
		else
			f = false
		end 
		if w and h then r = {w, h, f, b} end
	end
	if not r then return false, "unknown resolution" end

	-- Change the window size
	print("setResolution: switching resolution to", res, r[1], r[2], r[3], r[4], force and "(forced)")
	local old_w, old_h, old_f, old_b, old_rw, old_rh = self.w, self.h, self.fullscreen, self.borderless
	core.display.setWindowSize(r[1], r[2], r[3], r[4], config.settings.screen_zoom)
	
	-- Don't write self.w/h/fullscreen yet
	local new_w, new_h, new_f, new_b, new_rw, new_rh = core.display.size()

	-- Check if a resolution change actually happened
	if new_w ~= old_w or new_h ~= old_h or new_rw ~= old_rw or new_rh ~= old_rh or new_f ~= old_f or new_b ~= old_b then
		print("setResolution: performing onResolutionChange...\n")
		self:onResolutionChange()
		-- onResolutionChange saves settings...
		-- self:saveSettings("resolution", ("window.size = %q\n"):format(res))
	else
		print("setResolution: resolution change requested from same resolution!\n")
	end
end

--- Called when screen resolution changes
function _M:onResolutionChange()
	local ow, oh, of, ob = self.w, self.h, self.fullscreen, self.borderless

	-- Save old values for a potential revert
	if game and not self.change_res_dialog_oldw then
		print("onResolutionChange: saving current resolution for potential revert.")
		self.change_res_dialog_oldw, self.change_res_dialog_oldh, self.change_res_dialog_oldf = ow, oh, of
	end
	
	-- Get new resolution and save
	local realw, realh
	self.w, self.h, self.fullscreen, self.borderless, realw, realh = core.display.size()
	realw, realh = realw or self.w, realh or self.h
	config.settings.window.size = ("%dx%d%s"):format(realw, realh, self.fullscreen and " Fullscreen" or (self.borderless and " Borderless" or " Windowed"))	
	
	self:saveSettings("resolution", ("window.size = '%s'\n"):format(config.settings.window.size))
	print("onResolutionChange: resolution changed to ", realw, realh, "from", ow, oh)

	-- We do not even have a game yet
	if not game then
		print("onResolutionChange: no game yet!") 
		return 
	end
	
	-- Redraw existing dialogs
	self:updateVideoDialogs()

	-- No actual resize
	if ow == self.w and oh == self.h 
		and of == self.fullscreen and ob == self.borderless then 
		print("onResolutionChange: no actual resize, no confirm dialog.")
		return 
	end

	-- Extra game logic to be updated on a resize
	if not self:checkResolutionChange(self.w, self.h, ow, oh) then
		print("onResolutionChange: checkResolutionChange returned false, no confirm dialog.")
		return
	end

	-- Do not repop if we just revert back
	if self.change_res_dialog and type(self.change_res_dialog) == "string" and self.change_res_dialog == "revert" then
		print("onResolutionChange: Reverting, no popup.")
		return 
	end
	
	-- Unregister old dialog if there was one
	if self.change_res_dialog and type(self.change_res_dialog) == "table" then 
		print("onResolutionChange: Unregistering dialog")
		self:unregisterDialog(self.change_res_dialog) 
	end
	
	-- Are you sure you want to save these settings?  Somewhat obnoxious...
--	self.change_res_dialog = require("engine.ui.Dialog"):yesnoPopup(_t"Resolution changed", _t"Accept the new resolution?", function(ret)
--		if ret then
--			if not self.creating_player then self:saveGame() end
--			util.showMainMenu(false, nil, nil, self.__mod_info.short_name, self.save_name, false)
--		else
--			self.change_res_dialog = "revert"
--			self:setResolution(("%dx%d%s"):format(self.change_res_dialog_oldw, self.change_res_dialog_oldh, self.change_res_dialog_oldf and " Fullscreen" or " Windowed"), true)
--			self.change_res_dialog = nil
--			self.change_res_dialog_oldw, self.change_res_dialog_oldh, self.change_res_dialog_oldf = nil, nil, nil
--		end
--	end, _t"Accept", _t"Revert")
	print("onResolutionChange: (Would have) created popup.")
	
end

--- Checks if we must reload to change resolution
-- @int w width
-- @int h height
-- @int ow original width
-- @int oh original height
function _M:checkResolutionChange(w, h, ow, oh)
	return false
end

--- Called when the game window is moved around
-- @int x x coordinate
-- @int y y coordinate
function _M:onWindowMoved(x, y)
	config.settings.window.pos = config.settings.window.pos or {}
	config.settings.window.pos.x = x
	config.settings.window.pos.y = y
	self:saveSettings("window_pos", ("window.pos = {x=%d, y=%d}\n"):format(x, y))
	
	-- Redraw existing dialogs
	self:updateVideoDialogs()
end

--- Update any registered video options dialogs with the latest changes.
--
-- Note: If the title of the video options dialog changes, this
-- functionality will break.
function _M:updateVideoDialogs()
	-- Update the video settings dialogs if any are registered.
	-- We don't know which dialog (if any) is VideoOptions, so iterate through.
	for i, v in ipairs(self.dialogs) do
		if v.title == "Video Options" then
			v.c_list:drawTree()
		end
	end
end

--- Sets the gamma of the window
-- By default it uses SDL gamma settings, but it can also use a fullscreen shader if available
-- @param gamma
function _M:setGamma(gamma)
	if self.support_shader_gamma and core.shader.active() then
		if self.full_fbo_shader then
			-- Tell the shader which gamma to use
			self.full_fbo_shader:setUniform("gamma", gamma)
			-- Remove SDL gamma correction
			-- core.display.setGamma(1)
			print("[GAMMA] Setting gamma correction using fullscreen shader", gamma)
		else
			print("[GAMMA] Not setting gamma correction yet, no fullscreen shader found", gamma)
		end
	else
		-- core.display.setGamma(gamma)
		print("[GAMMA] Setting gamma correction using SDL", gamma)
	end
end

--- Sets the gamma of the window only if using a fullscreen shader
-- @param gamma
function _M:setFullscreenShaderGamma(gamma)
	if self.support_shader_gamma and core.shader.active() then
		if self.full_fbo_shader then
			-- Tell the shader which gamma to use
			self.full_fbo_shader:setUniform("gamma", gamma)
			print("[GAMMA] Setting gamma correction using fullscreen shader", gamma)
		else
			print("[GAMMA] Not setting gamma correction yet, no fullscreen shader found", gamma)
		end
	end
end

--- Requests the game to save
function _M:saveGame()
end

--- Saves the highscore of the current char
function _M:registerHighscore()
end

--- Add a coroutine to the pool
-- Coroutines registered will be run each game tick
-- @param id the id
-- @thread co the coroutine
function _M:registerCoroutine(id, co)
	print("[COROUTINE] registering", id, co)
	self.__coroutines[id] = co
end

--- Get the coroutine corresponding to the id
-- @param id the id
function _M:getCoroutine(id)
	return self.__coroutines[id]
end

--- Ask a registered coroutine to cancel
-- The coroutine must accept a "cancel" action
-- @param id the id
function _M:cancelCoroutine(id)
	local co = self.__coroutines[id]
	if not co then return end
	local ok, err = coroutine.resume(co, "cancel")
	if not ok then
		print(debug.traceback(co))
		print("[COROUTINE] error", err)
	end
	if coroutine.status(co) == "dead" then
		self.__coroutines[id] = nil
	else
		error("Told coroutine "..id.." to cancel, but it is not dead!")
	end
end

--- Take a screenshot of the game
-- @param[type=boolean] for_savefile The screenshot will be used for savefile display
-- @return screenshot
function _M:takeScreenshot(for_savefile)
	core.display.forceRedrawForScreenshot(for_savefile)
	if for_savefile then
		return core.display.getScreenshot(self.w / 4, self.h / 4, self.w / 2, self.h / 2)
	else
		return core.display.getScreenshot(0, 0, self.w, self.h)
	end
end

--- Take a screenshot of the game and saves it to the screenshots folder
function _M:saveScreenshot()
	local s = self:takeScreenshot()
	if not s then return end
	fs.mkdir("/screenshots")

	local file = ("/screenshots/%s-%d.png"):format(self.__mod_info.version_string, os.time())
	local f = fs.open(file, "w")
	f:write(s)
	f:close()

	local Dialog = require "engine.ui.Dialog"

	if core.steam then
		local desc = self:getSaveDescription()
		core.steam.screenshot(file, self.w, self.h, desc.description)
		Dialog:simpleLongPopup(_t"Screenshot taken!", ("Screenshot should appear in your Steam client's #LIGHT_GREEN#Screenshots Library#LAST#.\nAlso available on disk: %s"):tformat(fs.getRealPath(file)), 600)
	else
		Dialog:simplePopup(_t"Screenshot taken!", ("File: %s"):tformat(fs.getRealPath(file)))
	end
end

--- Register a hook that will be saved in the savefile
-- Obviously only run it once per hook per save
-- @string hook the hook to run on
-- @func fct the function to run
function _M:registerPersistentHook(hook, fct)
	self.__persistent_hooks = self.__persistent_hooks or {}
	table.insert(self.__persistent_hooks, {hook=hook, fct=fct})
	self:bindHook(hook, fct)
end

-- get a text-compatible texture for a game entity (overload in module)
-- @param[type=Entity] en
-- @return ""
function _M:getGenericTextTiles(en)
	return "" 
end

--- Checks the presence of a specific addon
function _M:isAddonActive(name)
	if not self.__mod_info then return end
	if not self.__mod_info.addons then return end
	return game.__mod_info.addons[name]
end
