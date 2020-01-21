local lfs = require 'lfs'
local locales_trans = {}
local locales_args = {}
local locales_sections ={}
local sections = {}
local current_section = ""
local function runfile(file, env)
	-- Base loader
	local prev, err = loadfile(file)
	if err then error(err) end
    setfenv(prev, env)
    print("running "..file)
    prev()
    return
end
local function count_string(str, pattern)
    count = 0
    for i in string.gfind(str, pattern) do
        count = count + 1
    end
    return count
end

local function suitable_string(string)
    if string:find("\n") and string:sub(1, 1) ~= "\n" then
        return "[[" .. string .. "]]"
    else
        return ("%q"):format(string)
    end
end

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
  
local function introduce_file(file_in)
    local env = setmetatable({
		locale = function(s) end,
        section = function(s)
            current_section = s
            sections[#sections+1] = current_section
            locales_sections[current_section] = locales_sections[current_section] or {}
        end,
        tDef = function(line, src) 
            locales_sections[current_section][src] = {
                line = line,
                src = src,
            }
        end,
    }, {__index=getfenv(2)})
    runfile(file_in, env)
end

local function merge_file_t(src, dst, args_order) 
    if not dst or dst == "" or src == dst then 
        return
    end
    if false and count_string(src, "%%") ~= count_string(dst, "%%") then
        print("% MISMATCH:")
        print(src)
        print(dst)
    end
    if locales_trans[src] and locales_trans[src] ~= dst then
        print("CONFLICT: ", src)
        print("OLD: ", locales_trans[src])
        print("NEW: ", dst)
    end
    if not locales_sections[current_section][src] then
        -- print(src)
        locales_sections[current_section][src] = {
            line = 999,
            src = src,
            bogus = true
        }
    end
    locales_trans[src] = dst
    if args_order then
        locales_args[src] = args_order
    end
end
local function merge_file(file_merge)
    local env = setmetatable({
		locale = function(s) end,
        section = function(s)
            current_section = s
            if not locales_sections[current_section] then
                sections[#sections+1] = current_section
                locales_sections[current_section] = locales_sections[current_section] or {} 
            end
        end,
        t = merge_file_t,
        t_old = merge_file_t,
    }, {__index=getfenv(2)})
    runfile(file_merge, env)
end
local merged_src = {}
local translated = 0
local all_entry = 0
local not_merged = 0
local function write_section(f, f2, f3, section)
    t = locales_sections[section]
    f:write("------------------------------------------------\n")
    f:write(('section "%s"\n\n'):format(section))
    f3:write("------------------------------------------------\n")
    f3:write(('section "%s"\n\n'):format(section))
    local f2_text = ""
    local list = {}
    for _, e in pairs(t) do
        list[#list+1] = e
    end
    if section ~= "not_merged" then
        table.sort(list, function(a, b) 
            if a.line ~= b.line then
                return a.line < b.line
            else
                return a.src < b.src
            end
        end)
    else
        table.sort(list, function(a, b) return a.src < b.src end)
    end
    for _, e in ipairs(list) do
        local src = e.src

        if section ~= "not_merged" then
            merged_src[src] = true
        end

        local print_str = ""
        if locales_trans[src] then
            if section ~= "always_merge" and e.bogus then
                print_str = "t_old"
            else
                print_str = "t"
            end
            print_str = print_str .. "(" .. suitable_string(src) .. ", " .. suitable_string(locales_trans[src])
            if locales_args[src] then
                print_str = print_str .. ", " .. table.tostring(locales_args[src]) .. ")"
            else
                print_str = print_str .. ")"
            end
            if not (section ~= "always_merge" and e.bogus) then
                f3:write(print_str .. "\n")
            end
        else
            print_str = "t(" .. suitable_string(src) .. ", " .. suitable_string(src) .. ")"
            -- f2:write(print_str .. "\n")
            f2_text = f2_text .. print_str .. "\n"
        end
        if section ~= "not_merged" or not merged_src[src] then
            f:write(print_str .. '\n')
        end
        if section ~= "not_merged" then
            all_entry = all_entry + 1
            if locales_trans[src] then
                translated = translated + 1
            end
        end
    end
    f:write("\n\n")
    f3:write("\n\n")
    if f2_text ~= "" then
        f2:write("------------------------------------------------\n")
        f2:write(('section "%s"\n\n'):format(section))
        f2:write(f2_text)
        f2:write("\n\n")
    end
end
local function print_file(file_out, file_out_2, file_out_3)
    local f = io.open(file_out, "w")
    local f2 = io.open(file_out_2, "w")
    local f3 = io.open(file_out_3, "w")
    f3:write("locale \"zh_CN\"\n")
    table.sort(sections)
    for _, section in ipairs(sections) do
        write_section(f, f2, f3, section)
    end
    print(("%d / %d entries translated"):format(translated, all_entry))
end
local function extract(file_in, file_merge, file_out, file_out_2, file_out_3)
    local file_in = file_in or "i18n_list.lua"
    local file_merge = file_merge or "merge_translation.lua"
    local file_out = file_out or "output_translation.lua"
    local file_out_2 = file_out_2 or "untranslated.lua"
    local file_out_3 = file_out_3 or "../game/engines/default/data/locales/zh_CN.lua"
    introduce_file(file_in)
    merge_file(file_merge)
    print_file(file_out, file_out_2, file_out_3)
end
extract(...)