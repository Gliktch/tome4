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
require "bit"

--- Provide some helper functions for description
-- @classmod engine.generator.interface.ActorTalentsDescHelper
module(..., package.seeall, class.make)
local acc, def, pp, sp, mp, ps, ss, ms = _t"accuracy", _t"defense", _t"physical power", _t"spellpower", _t"mindpower", _t"physical save", _t"spell save", _t"mental save"

_M.power_save_simple_pairs = {
	ap = { acc, ps },
	as = { acc, ss },
	am = { acc, ms },
	pp = { pp, ps },
	ps = { pp, ss },
	pm = { pp, ms },
	sp = { sp, ps },
	ss = { sp, ss },
	sm = { sp, ms },
	mp = { mp, ps },
	ms = { mp, ss },
	mm = { mp, ms },
}
_M.powers_saves = {
	a = acc,
	acc = acc,
	atk = acc,
	attack = acc,
	accuracy = acc,
	pp = pp,
	physicalpower = pp,
	sp = sp,
	spellpower = sp,
	mp = mp,
	mindpower = mp,
	d = def,
	def = def,
	defense = def,
	ps = ps,
	physicalsave = ps,
	ss = ss,
	spellsave = ss,
	ms = ms,
	mindsave = ms,
}
_M.powers = {
	p = pp,
	s = sp,
	m = mp,
}
_M.saves = {
	p = ps,
	s = ss,
	m = ms,
}

_M.concat = function(...)
	local arg = { ... }
	local transformed = {}
	for _, v in ipairs(arg) do
		transformed[#transformed + 1] = _M.powers_saves[v] or _t(tostring(v))
	end
	return transformed
end
_M.max = _M.concat

-- possible input:
-- 1. power: "pp", "ps", etc; save: nil   stored in power_save_simple_pairs
-- 2. power: string/table; save: string/table
--      string: search in _M.powers/saves/powers_saves and replace with proper desc
--      tables: simply concat them with "/"
_M.vs = function(power, save)
	if not save and _M.power_save_simple_pairs[power] then
		local pair = _M.power_save_simple_pairs[power]
		return string.tformat("(%s vs %s)", pair[1], pair[2])
	end
	if type(power) == "table" then
		power = table.concat(power, "/")
	else
		power = _M.powers[power] or _M.powers_saves[power] or power
	end
	if type(save) == "table" then
		save = table.concat(save, "/")
	else
		save = _M.saves[save] or _M.powers_saves[save] or save
	end
	if power and save then
		return string.tformat("(%s vs %s)", power, save)
	else
		return _t"(bypass saves)"
	end
end