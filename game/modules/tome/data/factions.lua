-- ToME - Tales of Maj'Eyal
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

-- CSV export
local src = [[
,Enemies,Undead,Allied Kingdoms,Shalore,Thalore,Iron Throne,The Way,Angolwen,Keepers of Reality,Dreadfell,,Temple of Creation|H,Water lair|H,Assassin lair|H,Rhalore,Zigur,,Vargh Republic,Sunwall,Orc Pride,,Sandworm Burrowers,Victim,Slavers,,Sorcerers,Fearscape,,Sher'Tul,Cosmic Fauna,Horrors
Enemies,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Undead,-1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Allied Kingdoms,-1,-1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Shalore,-1,-1,0.5,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Thalore,-1,-1,0.7,0.2,,,,,,,,,,,,,,,,,,,,,,,,,,,
Iron Throne,-1,-1,0.2,0.2,0.2,,,,,,,,,,,,,,,,,,,,,,,,,,
The Way,-1,-1,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,
Angolwen,-1,-1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Keepers of Reality,-1,-1,,,,,,0.2,,,,,,,,,,,,,,,,,,,,,,,
Dreadfell,,-1,-1,-1,-1,-1,-1,-1,-1,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Temple of Creation|H,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Water lair|H,-1,,,,,,,,,,,-1,,,,,,,,,,,,,,,,,,,
Assassin lair|H,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Rhalore,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,,-1,-1,-1,,,,,,,,,,,,,,,,,
Zigur,-1,-1,1,1,1,1,0.2,-1,0,-1,,,,,-1,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Vargh Republic,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,,-1,,-1,-1,-1,,,,,,,,,,,,,,,
Sunwall,-1,-1,,,,,,,,-1,,,,-1,-1,,,-1,,,,,,,,,,,,,
Orc Pride,,-1,-1,-1,-1,-1,-1,-1,-1,-1,,,,,-1,-1,,-1,-1,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Sandworm Burrowers,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Victim,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Slavers,-1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Sorcerers,,-1,-1,-1,-1,-1,-1,-1,-1,-1,,,,,-1,-1,,-1,-1,1,,,,,,,,,,,
Fearscape,,-1,-1,-1,-1,-1,-1,-1,-1,,,-1,-1,-1,-1,-1,,-1,-1,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Sher'Tul,,,,,,,,,,,,,,,,,,,,,,,,,,,-1,,,,
Cosmic Fauna,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,,-1,-1,-1,-1,-1,,-1,-1,-1,,-1,-1,-1,,-1,-1,,-1,,
Horrors,,-1,-1,-1,-1,-1,-1,-1,-1,,,-1,-1,-1,-1,-1,,-1,-1,-1,,,-1,-1,,-1,-1,,,-1,
]]

local fact_names = {_nt("Enemies", "faction name"), _nt("Undead", "faction name"), _nt("Allied Kingdoms", "faction name"), _nt("Shalore", "faction name"), _nt("Thalore", "faction name"),
_nt("Iron Throne", "faction name"), _nt("The Way", "faction name"), _nt("Angolwen", "faction name"), _nt("Keepers of Reality", "faction name"), _nt("Dreadfell", "faction name"),
_nt("Temple of Creation", "faction name"), _nt("Water lair", "faction name"), _nt("Assassin lair", "faction name"),
_nt("Rhalore", "faction name"), _nt("Zigur", "faction name"), _nt("Vargh Republic", "faction name"), _nt("Sunwall", "faction name"),
_nt("Orc Pride", "faction name"), _nt("Sandworm Burrowers", "faction name"), _nt("Victim", "faction name"), _nt("Slavers", "faction name"),
_nt("Sorcerers", "faction name"), _nt("Fearscape", "faction name"), _nt("Sher'Tul", "faction name"), _nt("Cosmic Fauna", "faction name"), _nt("Horrors", "faction name")}

local facts = {}
local factsid = {}
local lines = src:split("\n")
for i, line in ipairs(lines) do
	local data = line:split(",")
	for j, d in ipairs(data) do

		if i == 1 then
			if d ~= "" then
				local def = d:split("|")
				local on_attack = false
				for z = 2, #def do if def[z] == "H" then on_attack = true end end

				local sn = engine.Faction:add{ name=def[1], reaction={}, hostile_on_attack=on_attack }
				print("[FACTION] added", sn, def[1])
				facts[sn] = {id=j, reactions={}}
				factsid[j] = sn
			end
		else
			local n = tonumber(d)
			if n then
				facts[factsid[j]].reactions[factsid[i]] = n * 100
			end
		end
	end
end

for f1, data in pairs(facts) do
	for f2, v in pairs(data.reactions) do
--		print("[FACTION] initial reaction", f1, f2, " => ", v)
		engine.Faction:setInitialReaction(f1, f2, v, true)
	end
end

engine.Faction:add{ name=_nt("Neutral", "faction name"), reaction={}, }
engine.Faction:setInitialReaction("neutral", "enemies", -100, true)

engine.Faction:add{ name=_nt("Unaligned", "faction name"), reaction={}, }
engine.Faction:add{ shortname="merchant-caravan", name=_nt("Merchant Caravan", "faction name"), reaction={}, }

engine.Faction:add{ name=_nt("Point Zero Onslaught", "faction name"), reaction={}, }
engine.Faction:add{ name=_nt("Point Zero Guardians", "faction name"), reaction={}, }
engine.Faction:setInitialReaction("point-zero-onslaught", "point-zero-guardians", -100, true)
engine.Faction:setInitialReaction("enemies", "point-zero-guardians", -100, true)
engine.Faction:setInitialReaction("keepers-of-reality", "point-zero-guardians", 100, true)
