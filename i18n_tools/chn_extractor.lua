local lfs = require 'lfs'
local colors = require 'ansicolors'
local Parser = require 'luafish.parser'
local p = Parser()

local locales = {}
local text = ""
local checks = {
    desc = true,
    unided_name = true,
    name = true,
    lore = true,
    info = true,
    long_desc = true,
}
local t_checks = {
    info = true,
    long_desc = true,
}
function table.val_to_str ( v )
    if "string" == type( v ) then
      v = string.gsub( v, "\n", "\\n" )
      if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
        return "'" .. v .. "'"
      end
      return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
    else
      return "table" == type( v ) and table.tostring( v ) or
        tostring( v )
    end
  end
  
  function table.key_to_str ( k )
    if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
      return k
    else
      return "[" .. table.val_to_str( k ) .. "]"
    end
  end
    
function table.tostring( tbl )
    local result, done = {}, {}
    for k, v in ipairs( tbl ) do
      table.insert( result, table.val_to_str( v ) )
      done[ k ] = true
    end
    for k, v in pairs( tbl ) do
      if not done[ k ] then
        table.insert( result,
          table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
      end
    end
    return "{" .. table.concat( result, "," ) .. "}"
  end

local function explore(file, ast, _now_name, _status, _flags)
    local now_name = _now_name
    --local flags = table.clone(_flags)
	for i, e in ipairs(ast) do
        local status = _status
        if type(e) == "table" then
            if e.tag == "Id" and e[1] == "_t" then
				local en = ast[i+1]
                if en and type(en) == "table" and en.tag == "ExpList" and type(en[1]) == "table" and en[1].tag == "String" then
                    if now_name~="" and status~="" then
                        locales[now_name][status] = en[1][1]
                    end
				end
			elseif e.tag == "String" and e[1] == "tformat" and i == 2 then
                local en = ast[i-1]
				if en and type(en) == "table" and en.tag == "Paren" and type(en[1]) == "table" then
					local sn = en[1]
					if sn.tag == "String" and sn[1] then
                        if now_name~="" and status~="" then
                            if type(locales[now_name][status]) ~= "table" then
                                locales[now_name][status] = {}
                            end
                            locales[now_name][status][#locales[now_name][status] + 1] = sn[1]
                        end
					end
				end
			elseif e.tag == "String" and e[1] == "format" and i == 2 then
				local en = ast[i-1]
				if en and type(en) == "table" and en.tag == "Paren" and type(en[1]) == "table" then
					local sn = en[1]
                    if sn.tag == "String" and sn[1] then
                        if now_name~="" and t_checks[status] and locales[now_name] and locales[now_name][status] then
                            local count = locales[now_name][status .. "_count"] or 1
                            text = text .. ("t(%q, %q)\n"):format(locales[now_name][status][count], sn[1])
                            locales[now_name][status .. "_count"] = count + 1
                        end
					end
				end
            elseif e.tag == "Id" and e[1] == "registerArtifactTranslation" then
				local en = ast[i+1]
				if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "originName" then
                        now_name = p[2][1]
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "unided_name" then
                        if locales[now_name] and locales[now_name]["unided_name"]then
                            text = text .. ("t(%q, %q)\n"):format(locales[now_name]["unided_name"], p[2][1])
                        end
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "desc" then
                        if locales[now_name] and locales[now_name]["desc"] then
                            text = text .. ("t(%q, %q)\n"):format(locales[now_name]["desc"], p[2][1])
                        end
					end
                end end
            elseif e.tag == "Id" and e[1] == "registerLoreTranslation" then
                local en = ast[i+1]
                flags.proc_format = true
				if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "id" then
                        now_name = p[2][1]
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
                        if locales[now_name] and locales[now_name]["name"]then
                            text = text .. ("t(%q, %q)\n"):format(locales[now_name]["name"], p[2][1])
                        end
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "lore" then
                        if locales[now_name] and locales[now_name]["lore"] then
                            if type(p[2][1]) == "string" then
                                text = text .. ("t(%q, %q)\n"):format(locales[now_name]["lore"], p[2][1])
                            end
                        end
					end
				end end
            elseif e.tag == "Id" and e[1] == "registerTalentTranslation" then
				local en = ast[i+1]
				if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "id" then
                        now_name = p[2][1]
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
                        if locales[now_name] and locales[now_name]["name"]then
                            text = text .. ("t(%q, %q)\n"):format(locales[now_name]["name"], p[2][1])
                        end
					end
                end end
            elseif e.tag == "Id" and e[1] == "registerAchievementTranslation" then
				local en = ast[i+1]
				if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
                        now_name = p[2][1]
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "chnName" then
                        if locales[now_name] and locales[now_name]["name"]then
                            text = text .. ("t(%q, %q)\n"):format(locales[now_name]["name"], p[2][1])
                        end
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "desc" then
                        if locales[now_name] and locales[now_name]["desc"]then
                            text = text .. ("t(%q, %q)\n"):format(locales[now_name]["desc"], p[2][1])
                        end
					end
                end end
            elseif e.tag == "Id" and e[1] == "newEntity" then
				local en = ast[i+1]
                if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
                        now_name = p[2][1]
                        locales[now_name] = {}
                    end
                end end
            elseif e.tag == "Id" and e[1] == "newLore" then
				local en = ast[i+1]
                if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "id" then
                        now_name = p[2][1]
                        locales[now_name] = {}
                    end
                end end
            elseif e.tag == "Id" and e[1] == "newTalent" then
                local en = ast[i+1]
                local name_data = ""
                local short_named = false
                if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
                        if not short_named then
                            now_name = "T_" .. p[2][1]:upper():gsub("[ ']", "_")
                        end
                        name_data = p[2][1]
                        locales[now_name] = {}
                        locales[now_name]["name"] = name_data
                    elseif p[1] and p[2] and p.tag == "Field" and p[1][1] == "short_name" then
                        now_name = "T_" .. p[2][1]:upper():gsub("[ ']", "_")
                        short_named = true
                        locales[now_name] = {}
                        locales[now_name]["name"] = name_data
                    end
                end end
            elseif e.tag == "Id" and e[1] == "newEffect" then
                local en = ast[i+1]
                if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
                        now_name = p[2][1]
                        locales[now_name] = locales[now_name] or {}
                    end
                end end
            elseif e.tag == "Id" and e[1] == "newAchievement" then
				local en = ast[i+1]
                if en then for j, p in ipairs(en[1]) do
                    if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
                        now_name = p[2][1]
                        locales[now_name] = {}
                        locales[now_name]["name"] = now_name
                    end
                end end
            elseif e.tag == "Set" and e[1][1].tag == "Index" and e[1][1][1][1] == "npcDescCHN" and #e[1][1] == 2 then
                local now_name = e[1][1][2][1]
                if locales[now_name] and locales[now_name]["desc"] then
                    if e[2][1][1] and e[2][1][1] ~= "" then
                        text = text .. ("t(%q, %q)\n"):format(locales[now_name]["desc"], e[2][1][1])
                    end
                end                
            elseif e.tag == "Field" and checks[e[1][1]] then
                status = e[1][1]
            end
            explore(file, e, now_name, status, flags)
		end
	end
end

local function handle_file(file)
    print(colors("%{bright}-------------------------------------"))
    print(colors("%{bright}-- "..file))
    print(colors("%{bright}-------------------------------------"))
    explore(file:gsub("%.%./", ""), p:parse{file}, "", "", {})
end

local function dofolder(dir)
	if lfs.attributes(dir, "mode") == "file" then
		handle_file(dir)
		return
	end

	for sfile in lfs.dir(dir) do
		local file = dir.."/"..sfile
		if lfs.attributes(file, "mode") == "directory" and sfile ~= ".." and sfile ~= "." then
			dofolder(file)
		elseif sfile:find("%.lua$") then
			handle_file(file)
		end
	end
end
local f = io.open("result.lua", "w")
--handle_file("test.lua")
--handle_file("../game/modules/tome/data/general/objects/boss-artifacts.lua")
--dofolder("../game/modules/tome/data/general/objects")
--handle_file("/mnt/c/Program Files (x86)/Steam/steamapps/common/TalesMajEyal/game/addons/tome-chn/data/objects/artifact.lua")
--dofolder("../game/modules/tome/data/lore")
--dofolder("/mnt/c/Program Files (x86)/Steam/steamapps/common/TalesMajEyal/game/addons/tome-chn/data/lore")
-- handle_file("../game/modules/tome/data/talents/spells/aegis.lua")
-- handle_file("/mnt/c/Program Files (x86)/Steam/steamapps/common/TalesMajEyal/game/addons/tome-chn/superload/data/talents/spells/aegis.lua")
-- dofolder("../game/modules/tome/data/talents")
-- dofolder("/mnt/c/Program Files (x86)/Steam/steamapps/common/TalesMajEyal/game/addons/tome-chn/superload/data/talents")
-- dofolder("../game/modules/tome/data/general/npcs")
-- dofolder("../game/modules/tome/data/zones")
-- handle_file("/mnt/c/Program Files (x86)/Steam/steamapps/common/TalesMajEyal/game/addons/tome-chn/data/npc_name.lua")
-- dofolder("../game/modules/tome/data/achievements")
-- dofolder("/mnt/c/Program Files (x86)/Steam/steamapps/common/TalesMajEyal/game/addons/tome-chn/data/achievements")
dofolder("../game/modules/tome/data/timed_effects")
dofolder("/mnt/c/Program Files (x86)/Steam/steamapps/common/TalesMajEyal/game/addons/tome-chn/overload/data/timed_effects")
f:write(text)
f:close()
