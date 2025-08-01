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
local Entity = require "engine.Entity"
local Map = require "engine.Map"
local Faction = require "engine.Faction"

--- Base Actor class used by NPCs, Players, Enemies, etc
-- @classmod engine.Actor
module(..., package.seeall, class.inherit(Entity))

--- Display actor when seen
_M.display_on_seen = true
--- Remember actor after seeing it
_M.display_on_remember = false
--- Display actor when it hasn't yet been seen
_M.display_on_unknown = false
-- Allow actors to act as object carriers, if the interface is loaded
_M.__allow_carrier = true

--- Instantiates an actor
-- @param[type=table] t default values for actor
-- @param[type=table] no_default override the default values for entities
function _M:init(t, no_default)
	t = t or {}

	if not self.targetable and self.targetable == nil then self.targetable = true end
	self.name = t.name or "unknown actor"
	self.level = t.level or 1
	self.sight = t.sight or 20
	self.energy = t.energy or { value=0, mod=1 }
	self.energy.value = self.energy.value or 0
	self.energy.mod = self.energy.mod or 0
	self.faction = t.faction or "enemies"
	self.changed = true
	Entity.init(self, t, no_default)
end

--- Called when it is time to act
-- @return true if alive
function _M:act()
	if self.dead then return false end
	return true
end

--- Gets the actor target
-- Does nothing, AI redefines it, so should a "Player" class
function _M:getTarget()
end
--- Sets the actor target
-- Does nothing, AI redefines it, so should a "Player" class
function _M:setTarget(target)
end

--- cloneActor default alt_node fields (controls fields copied by cloneCustom)
-- modules should update this as needed
_M.clone_nodes = {player=false, x=false, y=false,
	fov_computed=false,	fov={v={actors={}, actors_dist={}}}, distance_map={v={}},
	_mo=false, _last_mo=false, add_displays=false,
	shader=false, shader_args=false,
}
--- cloneActor default fields (merged by _M.cloneActor with cloneCustom)
-- modules may define this as a table to automatically merge into cloned actors
_M.clone_copy = nil

--- Special version of cloneFull that clones an Actor, automatically managing duplication of some fields
--	uses class.CloneCustom
-- @param[optional, type=?table] post_copy a table merged into the cloned actor
--		updated with self.clone_copy if it is defined
-- @param[default=self.clone_nodes, type=?table] alt_nodes a table containing parameters for cloneCustom
--		to be merged with self.clone_nodes
-- @return the cloned actor
function _M:cloneActor(post_copy, alt_nodes)
	alt_nodes = table.merge(alt_nodes or {}, self.clone_nodes, true)
	if post_copy or self.clone_copy then post_copy = post_copy or {} table.update(post_copy, self.clone_copy or {}, true) end
	-- Clone all except sub-actors which need to simply reference the same ones
	local a = self:cloneCustom(alt_nodes, function(d) return not d:isClassName("mod.class.Actor") end, post_copy)
	-- Handle add_displays as a special case
	if self.add_displays then
		a.add_displays = {}
		for i, d in ipairs(self.add_displays) do
			table.insert(a.add_displays, d:cloneFull())
		end
	end
	a:removeAllMOs()
	return a, post_copy
end

--- Setup minimap color for this entity
-- You may overload this method to customize your minimap
-- @param mo
-- @param[type=Map] map
function _M:setupMinimapInfo(mo, map)
	if map.actor_player and not map.actor_player:canSee(self) then return end
	local r = map.actor_player and map.actor_player:reactionToward(self) or -100
	if r < 0 then mo:minimap(240, 0, 0)
	elseif r > 0 then mo:minimap(0, 240, 0)
	else mo:minimap(0, 0, 240)
	end
end

--- Set the current emote
-- @param[type=Emote] e
function _M:setEmote(e)
	-- Remove previous
	if self.__emote then
		game.level.map:removeEmote(self.__emote)
	end
	self.__emote = e
	if e and self.x and self.y and game.level and game.level.map then
		e.x = self.x
		e.y = self.y
		game.level.map:addEmote(e)
	end
end

--- Attach or remove a display callback
-- Defines particles to display
function _M:defineDisplayCallback()
	if not self._mo then return end

	-- Cunning trick here!
	-- the callback we give to mo:displayCallback is a function that references self
	-- but self contains mo so it would create a cyclic reference and prevent GC'ing
	-- thus we store a reference to a weak table and put self into it
	-- this way when self dies the weak reference dies and does not prevent GC'ing
	local weak = setmetatable({[1]=self}, {__mode="v"})

	local ps = self:getParticlesList()

	local f_self = nil
	local f_danger = nil
	local f_friend = nil
	local f_enemy = nil
	local f_neutral = nil

	local function particles(x, y, w, h)
		local self = weak[1]
		if not self or not self._mo then return end

		local e
		for i = 1, #ps do
			e = ps[i]
			e:checkDisplay()
			if e.ps:isAlive() then
				if game.level and game.level.map then e:shift(game.level.map, self._mo) end
				e.ps:toScreen(x + w / 2 + (e.dx or 0) * w, y + h / 2 + (e.dy or 0) * h, true, w / game.level.map.tile_w)
			elseif weak[1] then weak[1]:removeParticles(e)
			end
		end
	end

	local function tactical(x, y, w, h)
		-- Tactical info
		if game.level and game.level.map.view_faction then
			local self = weak[1]
			if not self then return end
			local map = game.level.map

			if not f_self then
				f_self = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_self)
				f_danger = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_danger)
				f_friend = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_friend)
				f_enemy = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_enemy)
				f_neutral = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_neutral)
			end

			if self.faction then
				local friend
				if not map.actor_player then friend = Faction:factionReaction(map.view_faction, self.faction)
				else friend = map.actor_player:reactionToward(self) end

				if self == map.actor_player then
					f_self:toScreen(x, y, w, h)
				elseif map:faction_danger_check(self) then
					f_danger:toScreen(x, y, w, h)
				elseif friend > 0 then
					f_friend:toScreen(x, y, w, h)
				elseif friend < 0 then
					f_enemy:toScreen(x, y, w, h)
				else
					f_neutral:toScreen(x, y, w, h)
				end
			end
		end
	end

	if self._mo == self._last_mo or not self._last_mo then
		self._mo:displayCallback(function(x, y, w, h)
			tactical(x, y, w, h)
			particles(x, y, w, h)
			return true
		end)
	else
		self._mo:displayCallback(function(x, y, w, h)
			tactical(x, y, w, h)
			return true
		end)
		self._last_mo:displayCallback(function(x, y, w, h)
			particles(x, y, w, h)
			return true
		end)
	end
end

--- Moves an actor on the map
-- *WARNING*: changing x and y properties manually is *WRONG* and will blow up in your face. Use this method. Always.
-- @int x coord of the destination
-- @int y coord of the destination
-- @param[type=boolean] force if true do not check for the presence of an other entity. *Use wisely*
-- @return true if a move was *ATTEMPTED*. This means the actor will probably want to use energy
function _M:move(x, y, force)
	if not x or not y then return end
	if self.dead then return true end
	if not game.level then return end
	local map = game.level.map

	x = math.floor(x)
	y = math.floor(y)

	if x < 0 then x = 0 end
	if x >= map.w then x = map.w - 1 end
	if y < 0 then y = 0 end
	if y >= map.h then y = map.h - 1 end

	if not force and map:checkAllEntities(x, y, "block_move", self, true) then return true end

	if self.x and self.y then
		map:remove(self.x, self.y, Map.ACTOR, self)
	else
--		print("[MOVE] actor moved without a starting position", self.name, x, y)
	end
	self.old_x, self.old_y = self.x or x, self.y or y
	self.x, self.y = x, y
	map(x, y, Map.ACTOR, self)

	-- Move emote
	if self.__emote then
		if self.__emote.dead then self.__emote = nil
		else
			self.__emote.x = x
			self.__emote.y = y
			map.emotes[self.__emote] = true
		end
	end

	map:checkAllEntities(x, y, "on_move", self, force)

	return true
end

--- Moves into the given direction (calls `Actor:move`() internally)
-- @number dir direction to move
-- @number force amount to move
-- @return true if we attempted to move
function _M:moveDir(dir, force)
	local dx, dy = util.dirToCoord(dir, self.x, self.y)
	if dir ~= 5 then self.doPlayerSlide = config.settings.player_slide end

	-- Handles zig-zagging for non-square grids
	local zig_zag = util.dirZigZag(dir, self.x, self.y)
	local next_zig_zag = util.dirNextZigZag(dir, self.x, self.y)
	if next_zig_zag then -- in hex mode, {1,2,3,7,8,9} dirs
		self.zig_zag = next_zig_zag
	elseif zig_zag then -- in hex mode, {4,6} dirs
		self.zig_zag  = self.zig_zag or "zig"
		local dir2 = zig_zag[self.zig_zag]
		dx, dy = util.dirToCoord(dir2, self.x, self.y)
		local nx, ny = util.coordAddDir(self.x, self.y, dir2)
		self.zig_zag = util.dirNextZigZag(self.zig_zag, nx, ny)
		if dir ~= 5 then self.doPlayerSlide = true end
	end

	local x, y = self.x + dx, self.y + dy
	self.move_dir = dir

	return self:move(x, y, force)
end

--- Can the actor go there
-- @int x x coordinate
-- @int y y coordinate
-- @param[type=?boolean] terrain_only if true checks only the terrain, otherwise checks all entities
-- @return true if it can
function _M:canMove(x, y, terrain_only)
	if not game.level.map:isBound(x, y) then return false end
	if terrain_only then
		return not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self)
	else
		return not game.level.map:checkAllEntities(x, y, "block_move", self)
	end
end

--- Remove the actor from the level, marking it as dead but not using the death functions
-- @param src not used by default, but should be the event source
function _M:disappear(src)
	if game.level and game.level:hasEntity(self) then game.level:removeEntity(self) end
	self.dead = true
	self.changed = true
end

--- Get the "path string" for this actor
-- See `Map:addPathString`() for more info
function _M:getPathString()
	return ""
end

--- Teleports randomly to a passable grid
-- @int x the coord of the teleportation
-- @int y the coord of the teleportation
-- @number dist the radius of the random effect, if set to 0 it is a precise teleport
-- @number min_dist the minimum radius of of the effect, will never teleport closer. Defaults to 0 if not set
-- @return true if the teleport worked
function _M:teleportRandom(x, y, dist, min_dist)
	local poss = {}
	dist = math.floor(dist)
	min_dist = math.floor(min_dist or 0)

	for i = x - dist, x + dist do
		for j = y - dist, y + dist do
			if game.level.map:isBound(i, j) and
			   core.fov.distance(x, y, i, j) <= dist and
			   core.fov.distance(x, y, i, j) >= min_dist and
			   self:canMove(i, j) and
			   not game.level.map.attrs(i, j, "no_teleport") then
				poss[#poss+1] = {i,j}
			end
		end
	end

	if #poss == 0 then return false end
	local pos = poss[rng.range(1, #poss)]
	return self:move(pos[1], pos[2], true)
end

--- Knock back the actor
-- @int srcx source x
-- @int srcy source y
-- @number dist distance to push
-- @param[type=?boolean] recursive is it recursive?
-- @param[type=?boolean] on_terrain
function _M:knockback(srcx, srcy, dist, recursive, on_terrain)
	print("[KNOCKBACK] from", srcx, srcx, "over", dist)

	local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
	local l = core.fov.line(srcx, srcy, self.x, self.y, block_actor, true)
	local lx, ly, is_corner_blocked = l:step(true)
	local ox, oy = lx, ly
	dist = dist - 1

	print("[KNOCKBACK] try", lx, ly, dist)

	if recursive then
		local target = game.level.map(lx, ly, Map.ACTOR)
		if target and recursive(target) then
			target:knockback(srcx, srcy, dist, recursive)
		end
	end
	if on_terrain then
		local g = game.level.map(lx, ly, Map.TERRAIN)
		if g and on_terrain(g, lx, ly) then
			dist = 0
		end
	end

	while game.level.map:isBound(lx, ly) and not is_corner_blocked and not game.level.map:checkAllEntities(lx, ly, "block_move", self) and dist > 0 do
		dist = dist - 1
		ox, oy = lx, ly
		lx, ly, is_corner_blocked = l:step(true)
		print("[KNOCKBACK] try", lx, ly, dist, "::", game.level.map:checkAllEntities(lx, ly, "block_move", self))

		if recursive then
			local target = game.level.map(lx, ly, Map.ACTOR)
			if target and recursive(target) then
				target:knockback(srcx, srcy, dist, recursive)
			end
		end
		if on_terrain then
			local g = game.level.map(lx, ly, Map.TERRAIN)
			if g and on_terrain(g, lx, ly) then
				break
			end
		end
	end

	if game.level.map:isBound(lx, ly) and not game.level.map:checkAllEntities(lx, ly, "block_move", self) then
		print("[KNOCKBACK] ok knocked to", lx, ly, "::", game.level.map:checkAllEntities(lx, ly, "block_move", self))
		self:move(lx, ly, true)
	elseif game.level.map:isBound(ox, oy) and not game.level.map:checkAllEntities(ox, oy, "block_move", self) then
		print("[KNOCKBACK] failsafe knocked to", ox, oy, "::", game.level.map:checkAllEntities(ox, oy, "block_move", self))
		self:move(ox, oy, true)
	end
end

--- Pull the actor
-- @int srcx source x
-- @int srcy source y
-- @number dist distance to pull
-- @param[type=boolean] recursive is it recursive?
function _M:pull(srcx, srcy, dist, recursive)
	print("[PULL] from", self.x, self.x, "towards", srcx, srcy, "over", dist)

	local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
	local l = core.fov.line(self.x, self.y, srcx, srcy, block_actor)
	local lx, ly, is_corner_blocked = l:step()
	local ox, oy = lx, ly
	dist = dist - 1

	print("[PULL] try", lx, ly, dist)
	if not lx or not ly then return end

	if recursive then
		local target = game.level.map(lx, ly, Map.ACTOR)
		if target and recursive(target) then
			target:pull(srcx, srcy, dist, recursive)
		end
	end

	while game.level.map:isBound(lx, ly) and not is_corner_blocked and not game.level.map:checkAllEntities(lx, ly, "block_move", self) and dist > 0 do
		dist = dist - 1
		ox, oy = lx, ly
		lx, ly, is_corner_blocked = l:step()
		print("[PULL] try", lx, ly, dist, "::", game.level.map:checkAllEntities(lx, ly, "block_move", self))

		if recursive then
			local target = game.level.map(lx, ly, Map.ACTOR)
			if target and recursive(target) then
				target:pull(srcx, srcy, dist, recursive)
			end
		end
	end

	if game.level.map:isBound(lx, ly) and not game.level.map:checkAllEntities(lx, ly, "block_move", self) then
		print("[PULL] ok pulled to", lx, ly, "::", game.level.map:checkAllEntities(lx, ly, "block_move", self))
		self:move(lx, ly, true)
	elseif game.level.map:isBound(ox, oy) and not game.level.map:checkAllEntities(ox, oy, "block_move", self) then
		print("[PULL] failsafe pulled to", ox, oy, "::", game.level.map:checkAllEntities(ox, oy, "block_move", self))
		self:move(ox, oy, true)
	end
end

--- Remove this actor from specified map
-- @param[type=Map] map
function _M:deleteFromMap(map)
	if self.x and self.y and map then
		map:remove(self.x, self.y, engine.Map.ACTOR, self)
		-- self.x, self.y = nil, nil
		self:closeParticles()
	end
end

--- Do we have enough energy?
-- @number val
-- @return true if we have enough
function _M:enoughEnergy(val)
	val = val or game.energy_to_act
	return self.energy.value >= val
end

--- Use some energy
-- @number val how much energy to use
function _M:useEnergy(val)
	val = val or game.energy_to_act
	self.energy.value = self.energy.value - val
	self.energy.used = true
end

--- What is our reaction toward the target
-- @see Faction.factionReaction
-- @param[type=Actor] target the target to check against
function _M:reactionToward(target)
	return Faction:factionReaction(self.faction, target.faction)
end

--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- By default this returns true, but a module can override it to check for telepathy, invisibility, stealth, ...
-- @param[type=Actor] actor the target actor to check
-- @number def the default
-- @number def_pct the default percent chance
-- @return[1] true
-- @return[1] a number from 0 to 100 representing the "chance" to be seen
-- @return[2] false
-- @return[2] a number from 0 to 100 representing the "chance" to be seen
function _M:canSee(actor, def, def_pct)
	return true, 100
end

--- Create a line to target based on field of vision
-- @int tx terrain x
-- @int ty terrain y
-- @param[type=?boolean|func|string] extra_block function that returns a boolean, or string that checks all entities to see if line of sight is blocked
-- @param[type=?boolean] block boolean of whether or not it's blocked by default
-- @int[opt=self.x] sx actor's x
-- @int[opt=self.y] sy actor's y
-- @return fov line from `core.fov.line`
function _M:lineFOV(tx, ty, extra_block, block, sx, sy)
	sx = sx or self.x
	sy = sy or self.y
	local act = game.level.map(tx, ty, Map.ACTOR)
	local sees_target = (self.sight and core.fov.distance(sx, sy, tx, ty) <= self.sight or not self.sight) and
		(game.level.map.lites(tx, ty) or act and self:canSee(act))

	extra_block = type(extra_block) == "function" and extra_block
		or type(extra_block) == "string" and function(self, x, y) return game.level.map:checkAllEntities(x, y, extra_block, self) end

	block = block
		or sees_target and function(_, x, y)
			return game.level.map:checkAllEntities(x, y, "block_sight", self) or
				game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move", self) and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
				extra_block and extra_block(self, x, y)
			end
		or function(_, x, y)
			if (self.sight and core.fov.distance(sx, sy, x, y) <= self.sight or not self.sight) and game.level.map.lites(x, y) then
				return game.level.map:checkEntity(x, y, Map.TERRAIN, "block_sight", self) or
					game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move", self) and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
					extra_block and extra_block(self, x, y)
			else
				return true
			end
		end

	return core.fov.line(sx, sy, tx, ty, block)
end

--- Does the actor have LOS to the target
-- @int x the spot we test for LOS
-- @int y the spot we test for LOS
-- @param[opt=block_sight] what the property to check for
-- @int[opt=self.sight] range the maximum range to see
-- @int[opt=self.x] source_x the spot to test from
-- @int[opt=self.y] source_y the spot to test from
-- @return[1] true
-- @return[1] last_x
-- @return[1] last_y
-- @return[2] false
-- @return[2] last_x
-- @return[2] last_y
function _M:hasLOS(x, y, what, range, source_x, source_y)
	source_x = source_x or self.x
	source_y = source_y or self.y
	if not x or not y then return false, source_x, source_y end
	what = what or "block_sight"
	range = range or self.sight
	local last_x, last_y = source_x, source_y
	local l = core.fov.line(source_x, source_y, x, y, what)
	local lx, ly, is_corner_blocked = l:step()

	-- Is within range, so no need to check every iteration
	if range and core.fov.distance(source_x, source_y, x, y) <= range then range = nil end

	while lx and ly and not is_corner_blocked do
		-- Check for the range
		if range and core.fov.distance(source_x, source_y, lx, ly) > range then
			break
		end
		last_x, last_y = lx, ly
		if game.level.map:checkAllEntities(lx, ly, what) then break end

		lx, ly, is_corner_blocked = l:step()
	end

	if last_x == x and last_y == y then return true, last_x, last_y end
	return false, last_x, last_y
end

--- Are we within a certain distance of the target
-- @int x the spot we test for nearness
-- @int y the spot we test for nearness
-- @number radius how close we should be (defaults to 1)
-- @return true if near
function _M:isNear(x, y, radius)
	radius = radius or 1
	if core.fov.distance(self.x, self.y, x, y) > radius then return false end
	return true
end


--- Return the kind of the entity
-- @return "actor"
function _M:getEntityKind()
	return "actor"
end

--- he/she formatting
-- @return string.he_she(self)
function _M:he_she() return string.he_she(self) end
--- his/her formatting
-- @return string.his_her(self)
function _M:his_her() return string.his_her(self) end
--- him/her formatting
-- @return string.him_her(self)
function _M:him_her() return string.him_her(self) end
--- he/she/self formatting
-- @return string.his_her_self(self)
function _M:his_her_self() return string.his_her_self(self) end

function _M:getName()
	return _t(self.name, "entity name")
end