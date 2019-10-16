local lfs = require 'lfs'
local Parser = require 'luafish.parser'
local p = Parser()

local locales = {}

function table.keys(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = k end
	return tt
end

function table.print(src, offset, ret)
	if type(src) ~= "table" then print("table.print has no table:", src) return end
	offset = offset or ""
	for k, e in pairs(src) do
		-- Deep copy subtables, but not objects!
		if type(e) == "table" and not e.__ATOMIC and not e.__CLASSNAME then
			print(("%s[%s] = {"):format(offset, tostring(k)))
			table.print(e, offset.."  ")
			print(("%s}"):format(offset))
		else
			print(("%s[%s] = %s"):format(offset, tostring(k), tostring(e)))
		end
	end
end

local function explore(file, ast)
	for i, e in ipairs(ast) do
		if type(e) == "table" then
			table.print(e)
			if e.tag == "Id" and e[1] == "_t" then
				local en = ast[i+1]
				if en and type(en) == "table" and en.tag == "ExpList" and type(en[1]) == "table" and en[1].tag == "String" then
					print("!!", en[1][1])
					locales[file] = locales[file] or {}
					locales[file][en[1][1]] = true
				end
			elseif e.tag == "String" and e[1] == "tformat" and i == 2 then
				local en = ast[i-1]
				if en and type(en) == "table" and en.tag == "Paren" and type(en[1]) == "table" then
					local sn = en[1]
					if sn.tag == "String" and sn[1] then
						print("%%", sn[1])
						locales[file] = locales[file] or {}
						locales[file][sn[1]] = true
					end
				end
			end
			explore(file, e)
		end
	end
end

local function dofolder(dir)
	for sfile in lfs.dir(dir) do
		local file = dir.."/"..sfile
		if lfs.attributes(file, "mode") == "directory" and sfile ~= ".." and sfile ~= "." then
			dofolder(file)
		elseif sfile:find("%.lua$") then
			print("-------------------------------------")
			print("--", file)
			print("-------------------------------------")
			explore(file:gsub("%.%./", ""), p:parse{file})
		end
	end
end

for _, dir in ipairs{...} do
	dofolder(dir)
end

local f = io.open("i18n_list.lua", "w")
local slist = table.keys(locales)
table.sort(slist)
for _, section in ipairs(slist) do
	f:write('------------------------------------------------\n')
	f:write(('section %q\n\n'):format(section))

	local list = table.keys(locales[section])
	table.sort(list)
	for _, s in ipairs(list) do
		f:write(('t(%q, "")\n'):format(s))
	end
	f:write('\n\n')
end
f:close()
