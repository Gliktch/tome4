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
local Map = require "engine.Map"
local Target = require "engine.Target"
local DamageType = require "engine.DamageType"

--- Handles actors projecting damage to zones/targets
-- @classmod engine.generator.interface.ActorProject
module(..., package.seeall, class.make)

_M.projectile_class = "engine.Projectile"

function _M:init(t)
end

--- Project damage to a distance
-- @param t a type table describing the attack, passed to engine.Target:getType() for interpretation
-- @param x target coords
-- @param y target coords
-- @param damtype a damage type ID from the DamageType class or a function to be called as damtype(px, py, t, self) on each grid
-- @param dam damage to be done
-- @param particles particles effect configuration, or nil
function _M:project(t, x, y, damtype, dam, particles)
	if type(particles) ~= "table" then particles = nil end

	self:check("on_project_init", t, x, y, damtype, dam, particles)

	local mods = {}
	if game.level.map:checkAllEntities(x, y, "on_project_acquire", self, t, x, y, damtype, dam, particles, false, mods) then
		if mods.x then x = mods.x end
		if mods.y then y = mods.y end
	end

--	if type(dam) == "number" and dam < 0 then return end
	local typ = Target:getType(t)
	typ.source_actor = self
	typ.start_x = typ.start_x or typ.x or (typ.source_actor and typ.source_actor.x or self.x)
	typ.start_y = typ.start_y or typ.y or (typ.source_actor and typ.source_actor.y or self.y)

	local grids = {}
	local function addGrid(x, y)
		if typ.filter and not typ.filter(x, y) then return end
		if not grids[x] then grids[x] = {} end
		grids[x][y] = true
	end

	-- Stop at range or on block
	local stop_x, stop_y = typ.start_x, typ.start_y
	local stop_radius_x, stop_radius_y = typ.start_x, typ.start_y
	local l, is_corner_blocked
	if typ.source_actor.lineFOV and typ.source_actor.x and typ.source_actor.y then
		l = typ.source_actor:lineFOV(x, y, nil, nil, typ.start_x, typ.start_y)
	else
		l = core.fov.line(typ.start_x, typ.start_y, x, y)
	end
	local block_corner = typ.block_path and function(_, bx, by) local b, h, hr = typ:block_path(bx, by, true) ; return b and h and not hr end
		or function(_, bx, by) return false end

	l:set_corner_block(block_corner)
	local lx, ly, blocked_corner_x, blocked_corner_y = l:step(typ.force_max_range)

	-- Being completely blocked by the corner of an adjacent tile is annoying, so let's make it a special case and hit it instead
	if blocked_corner_x and game.level.map:isBound(blocked_corner_x, blocked_corner_y) then
		stop_x = blocked_corner_x
		stop_y = blocked_corner_y
		if typ.line then addGrid(blocked_corner_x, blocked_corner_y) end
		if not t.bypass and game.level.map:checkAllEntities(blocked_corner_x, blocked_corner_y, "on_project", self, t, blocked_corner_x, blocked_corner_y, damtype, dam, particles) then
			return
		end
	else
		while lx and ly do
			local block, hit, hit_radius = false, true, true
			if is_corner_blocked then
				block, hit, hit_radius = true, true, false
				lx = stop_radius_x
				ly = stop_radius_y
			elseif typ.block_path then
				block, hit, hit_radius = typ:block_path(lx, ly)
			end
			if hit then
				stop_x, stop_y = lx, ly
				-- Deal damage: beam
				if typ.line then addGrid(lx, ly) end
				-- WHAT DOES THIS DO AGAIN?
				-- Call the on project of the target grid if possible
				if not t.bypass and game.level.map:checkAllEntities(lx, ly, "on_project", self, t, lx, ly, damtype, dam, particles) then
					return
				end
			end
			if hit_radius then
				stop_radius_x, stop_radius_y = lx, ly
			end

			if block then break end
			lx, ly, is_corner_blocked = l:step(typ.force_max_range)
			if typ.force_max_range and core.fov.distance(typ.start_x, typ.start_y, lx, ly) > typ.range then break end
		end
	end

	local single_target = true
	if typ.ball and typ.ball > 0 then
		single_target = false
		core.fov.calc_circle(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			typ.ball,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				-- Deal damage: ball
				addGrid(px, py)
			end,
		nil)
		addGrid(stop_x, stop_y)
	end

	if typ.triangle then
		single_target = false
		core.fov.calc_triangle(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			typ.triangle,
			typ.triangle_mode or "center",
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				-- Deal damage: ball
				addGrid(px, py)
			end
		)
	end

	if typ.widebeam and typ.widebeam > 0 then
		single_target = false
		core.fov.calc_wide_beam(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			typ.start_x,
			typ.start_y,
			typ.widebeam,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				addGrid(px, py)
			end,
		nil)
		addGrid(stop_x, stop_y)
	end

	if typ.cone and typ.cone > 0 then
		single_target = false
		--local dir_angle = math.deg(math.atan2(y - self.y, x - self.x))
		core.fov.calc_beam_any_angle(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			typ.cone,
			typ.cone_angle,
			typ.start_x,
			typ.start_y,
			x - typ.start_x,
			y - typ.start_y,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				addGrid(px, py)
			end,
		nil)
		addGrid(stop_x, stop_y)
	end

	if typ.wall and typ.wall > 0 then
		single_target = false
		core.fov.calc_wall(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			typ.wall,
			typ.halfmax_spots,
			typ.start_x,
			typ.start_y,
			x - typ.start_x,
			y - typ.start_y,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				addGrid(px, py)
			end,
		nil)
	end

	-- Deal damage: single
	if single_target then addGrid(stop_x, stop_y) end

	-- Check for minimum range
	if typ.min_range and core.fov.distance(typ.start_x, typ.start_y, stop_x, stop_y) < typ.min_range then
		return
	end

	--Remove any excluded grids
	if typ.grid_exclude then
		for px, ys in pairs(typ.grid_exclude) do
			if grids[px] then
				for py, _ in pairs(ys) do
					grids[px][py]=nil
				end
			end
		end
	end

	self:check("on_project_grids", grids)

	-- Now project on each grid, one type
	local state = {}
	local stop = false
	DamageType:projectingFor(self, {project_type=typ})
	for px, ys in pairs(grids) do
		for py, _ in pairs(ys) do
			-- Call the projected method of the target grid if possible
			if not game.level.map:checkAllEntities(px, py, "projected", self, t, px, py, damtype, dam, particles) then
				-- Check self- and friendly-fire, excluded Actors, and if the projection "misses"
				local act = game.level.map(px, py, engine.Map.ACTOR)
				if act and (typ.act_exclude and typ.act_exclude[act.uid]) or act == self and not ((type(typ.selffire) == "number" and rng.percent(typ.selffire)) or (type(typ.selffire) ~= "number" and typ.selffire)) then
				elseif act and self.reactionToward and (self:reactionToward(act) >= 0) and not ((type(typ.friendlyfire) == "number" and rng.percent(typ.friendlyfire)) or (type(typ.friendlyfire) ~= "number" and typ.friendlyfire)) then
				-- Otherwise hit
				else
					if type(damtype) == "function" then if damtype(px, py, t, self) then stop=true break end
					else DamageType:get(damtype).projector(self, px, py, damtype, dam, state, nil) end
					if particles then
						game.level.map:particleEmitter(px, py, 1, particles.type, particles.args)
					end
				end
			end
		end
		if stop then break end
	end
	DamageType:projectingFor(self, nil)
	return grids, stop_x, stop_y
end

--- Can we project to this grid?  
-- This function can be used for either just the boolean, or to tell you where the projection stops.  
-- Two sets of coordinates will be returned, one for where the projection stops (stop_x, stop_y) and
-- one for where any radius effect should start from (radius_x, radius_y).  The distinction is made
-- because a projection should hit the wall, but explosions should start one tile back to avoid
-- "leaking" through a one tile thick wall.
-- @param[type=table] t a type table describing the attack, passed to engine.Target:getType() for interpretation
-- @number x target coords
-- @number y target coords
-- @return can_project
-- @return stop_x
-- @return stop_y
-- @return radius_x
-- @return radius_y
function _M:canProject(t, x, y)
	if not x or not y then return end
	local typ = Target:getType(t)
	typ.source_actor = self
	typ.start_x = typ.start_x or typ.x or typ.source_actor and typ.source_actor.x or self.x
	typ.start_y = typ.start_y or typ.y or typ.source_actor and typ.source_actor.y or self.y

	-- Stop at range or on block
	local stop_x, stop_y = typ.start_x, typ.start_y
	local stop_radius_x, stop_radius_y = typ.start_x, typ.start_y

	local l, is_corner_blocked
	if typ.source_actor.lineFOV then
		l = typ.source_actor:lineFOV(x, y, nil, nil, typ.start_x, typ.start_y)
	else
		l = core.fov.line(typ.start_x, typ.start_y, x, y)
	end
	local block_corner = typ.block_path and function(_, bx, by) local b, h, hr = typ:block_path(bx, by, true) ; return b and h and not hr end
		or function(_, bx, by) return false end

	l:set_corner_block(block_corner)
	local lx, ly, blocked_corner_x, blocked_corner_y = l:step(typ.force_max_range)

	-- Being completely blocked by the corner of an adjacent tile is annoying, so let's make it a special case and hit it instead
	if blocked_corner_x then
		stop_x = blocked_corner_x
		stop_y = blocked_corner_y
	else
		while lx and ly do
			local block, hit, hit_radius = false, true, true
			if is_corner_blocked then
				stop_x = stop_radius_x
				stop_y = stop_radius_y
				break
			elseif typ.block_path then
				block, hit, hit_radius = typ:block_path(lx, ly)
			end
			if hit then
				stop_x, stop_y = lx, ly
			end
			if hit_radius then
				stop_radius_x, stop_radius_y = lx, ly
			end

			if block then break end
			lx, ly, is_corner_blocked = l:step(typ.force_max_range)
			if typ.force_max_range and core.fov.distance(typ.start_x, typ.start_y, lx, ly) > typ.range then break end
		end
	end

	-- Check for minimum range
	if typ.min_range and core.fov.distance(typ.start_x, typ.start_y, stop_x, stop_y) < typ.min_range then
		return
	end

	local is_hit = stop_x == x and stop_y == y
	return is_hit, stop_x, stop_y, stop_radius_x, stop_radius_y
end

function _M:projectCollect(t, x, y, kind, cond, tgts, particles)
	tgts = tgts or {}
	self:project(t, x, y, function(px, py)
		local tgt = game.level.map(px, py, kind)
		if not tgt then return end
		local ok = false
		if kind == Map.ACTOR and type(cond) ~= "function" then
			if cond == "hostile" and self:reactionToward(tgt) < 0 then ok = true
			elseif cond == "friend" and self:reactionToward(tgt) > 0 then ok = true
			elseif cond == nil then ok = true
			end
		else
			if cond(tgt, px, py) then ok = true end
		end
		if ok then tgts[tgt] = {x=px, y=py, target=tgt, dist=core.fov.distance(self.x, self.y, px, py)} end
	end, nil, particles)
	return tgts
end

function _M:projectApply(t, x, y, kind, fct, cond, particles)
	tgts = tgts or {}
	self:project(t, x, y, function(px, py)
		local tgt = game.level.map(px, py, kind)
		if not tgt then return end
		local ok = false
		if kind == Map.ACTOR and type(cond) ~= "function" then
			if cond == "hostile" and self:reactionToward(tgt) < 0 then ok = true
			elseif cond == "friend" and self:reactionToward(tgt) > 0 then ok = true
			elseif cond == nil then ok = true
			end
		else
			if not cond or cond(tgt, px, py) then ok = true end
		end
		if ok then fct(tgt, px, py) end
	end, nil, particles)
	return tgts
end

--- Calls :getTarget and :canProject to limit the results and returns the same as getTarget
function _M:getTargetLimited(t)
	local x, y = self:getTarget(t)
	local _ _, x, y = self:canProject(t, x, y)
	local target = game.level.map(x, y, Map.ACTOR)
	return x, y, target
end

--- Calls :getTarget and :canProject to limit the results and returns the same as getTarget
function _M:getTargetLimitedWallStop(t)
	local x, y = self:getTarget(t)
	local _ _, _, _, x, y = self:canProject(t, x, y)
	local target = game.level.map(x, y, Map.ACTOR)
	return x, y, target
end

--- Project damage to a distance using a moving projectile
-- @param t a type table describing the attack, passed to engine.Target:getType() for interpretation
-- @param x target coords
-- @param y target coords
-- @param damtype a damage type ID from the DamageType class
-- @param dam damage to be done
-- @param particles particles effect configuration, or nil
function _M:projectile(t, x, y, damtype, dam, particles)
	if type(particles) ~= "function" and type(particles) ~= "table" then particles = nil end

	self:check("on_project_init", t, x, y, damtype, dam, particles)

	local mods = {}
	if game.level.map:checkAllEntities(x, y, "on_project_acquire", self, t, x, y, damtype, dam, particles, true, mods) then
		if mods.x then x = mods.x end
		if mods.y then y = mods.y end
	end

--	if type(dam) == "number" and dam < 0 then return end
	local typ = Target:getType(t)
	typ.source_actor = self
	typ.start_x = typ.start_x or typ.x or (typ.source_actor and typ.source_actor.x or self.x)
	typ.start_y = typ.start_y or typ.y or (typ.source_actor and typ.source_actor.y or self.y)
	if self.lineFOV then
		typ.line_function = self:lineFOV(x, y, nil, nil, typ.start_x, typ.start_y)
	else
		typ.line_function = core.fov.line(typ.start_x, typ.start_y, x, y)
	end
	local block_corner = typ.block_path and function(_, bx, by) local b, h, hr = typ:block_path(bx, by, true) ; return b and h and not hr end
		or function(_, bx, by) return false end

	typ.line_function:set_corner_block(block_corner)

	local proj = require(self.projectile_class):makeProject(self, t.display, {x=x, y=y, start_x=typ.start_x, start_y=typ.start_y, damtype=damtype, tg=t, typ=typ, dam=dam, particles=particles, _allow_upvalues = true,})
	game.zone:addEntity(game.level, proj, "projectile", typ.start_x, typ.start_y)

	self:check("on_projectile_fired", proj, typ, x, y, damtype, dam, particles)
	return proj
end

--- Do move
-- @param typ a target type table
-- @param tgtx the target's x-coordinate
-- @param tgty the target's y-coordinate
-- @param x the projectile's x-coordinate
-- @param y the projectile's y-coordinate
-- @param srcx the sourcs's x-coordinate
-- @param srcy the source's y-coordinate
-- @return lx x-coordinate the projectile travels to next
-- @return ly y-coordinate the projectile travels to next
-- @return act should we call `projectDoAct`() (usually only for beam)
-- @return stop is this the last (blocking) tile?
function _M:projectDoMove(typ, tgtx, tgty, x, y, srcx, srcy)
	local lx, ly, blocked_corner_x, blocked_corner_y = typ.line_function:step()
	if blocked_corner_x and x == srcx and y == srcy then
		return blocked_corner_x, blocked_corner_y, false, true
	end

	if lx and ly then
		local block, hit, hit_radius = false, true, true
		if blocked_corner_x then
			block, hit, hit_radius = true, false, false
		elseif typ.block_path then
			block, hit, hit_radius = typ:block_path(lx, ly)
		end
		if block then
			if hit then
				return lx, ly, false, true
			-- If we don't hit the tile, pass back nils to stop on the current spot
			else
				return nil, nil, false, true
			end
		end

		-- End of the map
		if lx < 0 or lx >= game.level.map.w or ly < 0 or ly >= game.level.map.h then
			return nil, nil, false, true
		end

		-- Deal damage: beam
		if typ.line and (lx ~= tgtx or ly ~= tgty) then return lx, ly, true, false end
	end
	-- Ok if we are at the end
	if (not lx and not ly) then return lx, ly, false, true end
	return lx, ly, false, false
end

--- projectDoAct
function _M:projectDoAct(typ, tg, damtype, dam, particles, px, py, tmp)
	-- Now project on each grid, one type
	-- Call the projected method of the target grid if possible
	if not game.level.map:checkAllEntities(px, py, "projected", self, typ, px, py, damtype, dam, particles) then
		-- Check self- and friendly-fire, and if the projection "misses"
		local act = game.level.map(px, py, engine.Map.ACTOR)
		if act and act == self and not ((type(typ.selffire) == "number" and rng.percent(typ.selffire)) or (type(typ.selffire) ~= "number" and typ.selffire)) then
		elseif act and self.reactionToward and (self:reactionToward(act) >= 0) and not ((type(typ.friendlyfire) == "number" and rng.percent(typ.friendlyfire)) or (type(typ.friendlyfire) ~= "number" and typ.friendlyfire)) then
		-- Otherwise hit
		else
			DamageType:projectingFor(self, {project_type=tg})
			if type(damtype) == "function" then if damtype(px, py, tg, self, tmp) then return true end
			else DamageType:get(damtype).projector(self, px, py, damtype, dam, tmp, nil, tg) end
			if particles and type(particles) == "table" then
				game.level.map:particleEmitter(px, py, 1, particles.type, particles.args)
			end
			DamageType:projectingFor(self, nil)
		end
	end
end

--- projectDoStop
function _M:projectDoStop(typ, tg, damtype, dam, particles, lx, ly, tmp, rx, ry, projectile)
	local grids = {}
	local function addGrid(x, y)
		if not x or not y then return end
		if not grids[x] then grids[x] = {} end
		grids[x][y] = true
	end

	if typ.ball and typ.ball > 0 then
		core.fov.calc_circle(
			rx,
			ry,
			game.level.map.w,
			game.level.map.h,
			typ.ball,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				-- Deal damage: ball
				addGrid(px, py)
			end,
		nil)
		addGrid(rx, ry)
	elseif typ.cone and typ.cone > 0 then
		--local initial_dir = lx and util.getDir(lx, ly, x, y) or 5
		--local dir_angle = math.deg(math.atan2(ly - typ.source_actor.y, lx - typ.source_actor.x))
		core.fov.calc_beam_any_angle(
			rx,
			ry,
			game.level.map.w,
			game.level.map.h,
			typ.cone,
			typ.cone_angle,
			typ.start_x,
			typ.start_y,
			lx - typ.start_x,
			ly - typ.start_y,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				-- Deal damage: cone
				addGrid(px, py)
			end,
		nil)
		addGrid(rx, ry)
	elseif typ.widebeam and typ.widebeam > 0 then
		core.fov.calc_wide_beam(
			rx,
			ry,
			game.level.map.w,
			game.level.map.h,
			typ.start_x,
			typ.start_y,
			typ.widebeam,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				-- Deal damage: cone
				addGrid(px, py)
			end,
		nil)
		addGrid(rx, ry)
	elseif typ.wall and typ.wall > 0 then
		core.fov.calc_wall(
			rx,
			rx,
			game.level.map.w,
			game.level.map.h,
			typ.wall,
			typ.halfmax_spots,
			typ.start_x,
			typ.start_y,
			lx - typ.start_x,
			ly - typ.start_y,
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				-- Deal damage: wall
				addGrid(px, py)
			end,
		nil)
	elseif typ.triangle then
		core.fov.calc_triangle(
			rx,
			rx,
			game.level.map.w,
			game.level.map.h,
			typ.triangle,
			typ.triangle_mode or "center",
			function(_, px, py)
				if typ.block_radius and typ:block_radius(px, py) then return true end
			end,
			function(_, px, py)
				-- Deal damage: ball
				addGrid(px, py)
			end
		)
	else
		-- Deal damage: single
		addGrid(lx, ly)
	end

	self:check("on_project_grids", grids)

	if typ.sound_stop then game:playSoundNear({x=lx,y=ly}, typ.sound_stop) end

	for px, ys in pairs(grids) do
		for py, _ in pairs(ys) do
			if self:projectDoAct(typ, tg, damtype, dam, particles, px, py, tmp) then break end
		end
	end
	if particles and type(particles) == "function" then
		if (typ.ball and typ.ball > 0) or (typ.cone and typ.cone > 0) then
			particles(self, tg, rx, ry, grids)
		else
			particles(self, tg, lx, ly, grids)
		end
	end

	if typ.on_stop_check then
		if typ.on_stop_check(self, typ, tg, damtype, dam, particles, lx, ly, tmp, rx, ry, projectile) then
			game.level:removeEntity(projectile, true)
			projectile.dead = true
		end
	else
		game.level:removeEntity(projectile, true)
		projectile.dead = true
	end
end
