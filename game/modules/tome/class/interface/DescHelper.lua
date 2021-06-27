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

_M.powers = {
    _t"Accuracy", _t"Physical Power", _t"Accuracy/Physical Power", _t"Spellpower",
    _t"Accuracy/Spellpower", _t"Physical Power/Spellpower", _t"Accuracy/Physical Power/Spellpower", _t"Mindpower",
    _t"Accuracy/Mindpower", _t"Physical Power/Mindpower",_t"Accuracy/Physical Power/Mindpower", _t"Spellpower/Mindpower",
    _t"Accuracy/Spellpower/Mindpower", _t"Physical Power/Spellpower/Mindpower", _t"Accuracy/Physical Power/Spellpower/Mindpower"
}

_M.saves = {
    _t"Defense", _t"Physical Save", _t"Defense/Physical Save", "Spell Save",
    _t"Defense/Spell Save", _t"Physical Save/Spell Save", _t"Defense/Physical Save/Spell Save", _t"Mental Save",
    _t"Defense/Mental Save", _t"Physical Save/Mental Save", _t"Defense/Physical Save/Mental Save", _t"Spell Save/Mental Save",
    _t"Defense/Spell Save/Mental Save", _t"Physical Save/Spell Save/Mental Save", _t"Defense/Physical Save/Spell Save/Mental Save"
}

_M.powers_short = {
    _t"Acc", _t"PP", _t"Acc/PP", _t"SP",
    _t"Acc/SP", _t"PP/SP", _t"Acc/PP/SP", _t"MP",
    _t"Acc/MP", _t"PP/MP",_t"Acc/PP/MP", _t"SP/MP",
    _t"Acc/SP/MP", _t"PP/SP/MP", _t"Acc/PP/SP/MP"
}

_M.saves_short = {
    _t"Def", _t"PS", _t"Def/PS", "SS",
    _t"Def/SS", _t"PS/SS", _t"Def/PS/SS", _t"MS",
    _t"Def/MS", _t"PS/MS", _t"Def/PS/MS", _t"SS/MS",
    _t"Def/SS/MS", _t"PS/SS/MS", _t"Def/PS/SS/MS"
}
_M.acc = 1
_M.pp = 2
_M.sp = 4
_M.mp = 8
_M.def = _M.acc
_M.ps = _M.pp
_M.ss = _M.sp
_M.ms = _M.mp
_M.atk = _M.acc
_M.attack = _M.acc
_M.accuracy = _M.acc
_M.defense = _M.def
_M.physicalpower = _M.pp
_M.spellpower = _M.sp
_M.mindpower = _M.mp
_M.physicalsave = _M.ps
_M.spellsave = _M.ss
_M.mentalsave = _M.ms

_M.max = function(...)
    local arg = { ... }
    local res = 0
    for _, v in ipairs(arg) do
        res = bit.bor(res, v)
    end
    return res
end

_M.max_power = function(...)
    return _M.powers[_M.max(...)]
end

_M.max_save = function(...)
    return _M.saves[_M.max(...)]
end

_M.vs = function(power, save)
    power = type(power) == "number" and _M.powers[power] or power
    save = type(save) == "number" and _M.saves[save] or save
    if power and save then
        return string.tformat("(%s vs %s)", power, save)
    else
        return _t"(Bypass Saves)"
    end
end

_M.max_power_short = function(...)
    return _M.powers_short[_M.max(...)]
end

_M.max_save_short = function(...)
    return _M.saves_short[_M.max(...)]
end

_M.vs_short = function(power, save)
    power = type(power) == "number" and _M.powers_short[power] or power
    save = type(save) == "number" and _M.saves_short[save] or save
    if power and save then
        return string.tformat("(%s vs %s)", power, save)
    else
        return _t"(Bypass Saves)"
    end
end