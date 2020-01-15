local lfs = require 'lfs'
local colors = require 'ansicolors'
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
			table.print(e, offset.."\t")
			print(("%s}"):format(offset))
		else
			print(("%s[%s] = %s"):format(offset, tostring(k), tostring(e)))
		end
	end
end

local log_alias = {
	log = 1,
	logSeen = 2,
	logCombat = 2,
	logPlayer = 2,
	logMessage = 5,
	delayedLogMessage = 4,
}
local function explore(file, ast)
	--table.print(ast)
	for i, e in ipairs(ast) do
		if type(e) == "table" then
			if e.tag == "Id" and e[1] == "_t" then
				local en = ast[i+1]
				if en and type(en) == "table" and en.tag == "ExpList" and type(en[1]) == "table" and en[1].tag == "String" then
					print(colors("%{bright cyan}_t"), en[1][1])
					locales[file] = locales[file] or {}
					locales[file][en[1][1]] = {line=en[1].nline, type="_t"}
				end
			elseif e.tag == "String" and e[1] == "tformat" and i == 2 then
				local en = ast[i-1]
				if en and type(en) == "table" and en.tag == "Paren" and type(en[1]) == "table" then
					local sn = en[1]
					if sn.tag == "String" and sn[1] then
						print(colors("%{bright yellow}tformat"), sn[1])
						locales[file] = locales[file] or {}
						locales[file][sn[1]] = {line=sn.nline, type="tformat"}
					end
				end
			elseif e.tag == "Id" and e[1] == "newTalent" then
				local en = ast[i+1]
				if en then for j, p in ipairs(en[1]) do
					if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
						print(colors("%{bright green}newTalent"), p[2][1])
						locales[file] = locales[file] or {}
						locales[file][p[2][1]] = {line=p[2].nline, type="talent name"}
					end
				end end
			elseif e.tag == "Id" and e[1] == "newEntity" then
				local en = ast[i+1]
				if en then for j, p in ipairs(en[1]) do
					if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
						print(colors("%{green}newEntity"), p[2][1])
						locales[file] = locales[file] or {}
						locales[file][p[2][1]] = {line=p[2].nline, type="entity name"}
					end
				end end
			elseif e.tag == "Id" and e[1] == "newAchievement" then
				local en = ast[i+1]
				if en then for j, p in ipairs(en[1]) do
					if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
						print(colors("%{bright red}newAchievement"), p[2][1])
						locales[file] = locales[file] or {}
						locales[file][p[2][1]] = {line=p[2].nline, type="achievement name"}
					end
				end end
			elseif e.tag == "Id" and e[1] == "newBirthDescriptor" then
				local en = ast[i+1]
				local dname, name = nil, nil
				if en then for j, p in ipairs(en[1]) do
					if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
						name = p[2]
					end
					if p[1] and p[2] and p.tag == "Field" and p[1][1] == "display_name" then
						dname = p[2]
					end
				end end
				if dname then
					print(colors("%{bright cyan}newBirthDescriptor"), dname[1])
					locales[file] = locales[file] or {}
					locales[file][dname[1]] = {line=dname.nline, type="birth descriptor name"}
				elseif name then
					print(colors("%{bright cyan}newBirthDescriptor"), name[1])
					locales[file] = locales[file] or {}
					locales[file][name[1]] = {line=name.nline, type="birth descriptor name"}
				end
			elseif e.tag == "Invoke" and log_alias[e[2][1] ] then
				local en = e[3]
				local log_type = e[2][1]
				local order = log_alias[log_type]
				if en and type(en) == "table" and en.tag == "ExpList" and type(en[order]) == "table" and en[order].tag == "String" then
					print(colors("%{bright blue}"..log_type), en[order][1])
					locales[file] = locales[file] or {}
					locales[file][en[order][1]] = {line=en[order].nline, type=log_type}
				end
			elseif e.tag == "Call" and e[1][2] and log_alias[e[1][2][1] ] then
				local en = e[2]
				local log_type = e[1][2][1]
				local order = log_alias[log_type]
				if en and type(en) == "table" and en.tag == "ExpList" and type(en[order]) == "table" and en[order].tag == "String" then
					print(colors("%{bright blue}"..log_type), en[order][1])
					locales[file] = locales[file] or {}
					locales[file][en[order][1]] = {line=en[order].nline, type=log_type}
				end
			elseif e.tag == "Invoke" and
			    e[1] and e[1].tag == "Index" and e[1][1] and e[1][1][1] == "engine" and e[1][1].tag == "Id" and e[1][2][1] == "Faction" and e[1][2].tag == "String" and
			    e[2] and e[2].tag == "String" and e[2][1] == "add" then
				local en = e[3]
				if en then for j, p in ipairs(en[1]) do
					if p[1] and p[2] and p.tag == "Field" and p[1][1] == "name" then
						print(colors("%{blue}newFaction"), p[2][1])
						locales[file] = locales[file] or {}
						locales[file][p[2][1]] = {line=p[2].nline, type="faction name"}
					end
				end end
			end
			explore(file, e)
		end
	end
end

local function dofolder(dir)
	local function handle_file(file)
		print(colors("%{bright}-------------------------------------"))
		print(colors("%{bright}-- "..file))
		print(colors("%{bright}-------------------------------------"))
		explore(file:gsub("%.%./", ""), p:parse{file})
	end

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

for _, dir in ipairs{...} do
	dofolder(dir)
end

local f = io.open("i18n_list.lua", "w")
local slist = table.keys(locales)
table.sort(slist)
for _, section in ipairs(slist) do
	f:write('------------------------------------------------\n')
	f:write(('section %q\n\n'):format(section))
	
	local list = {}
	for k, v in pairs(locales[section]) do
		list[#list+1] = {text=k, line=v.line, type=v.type}
	end
	table.sort(list, function(a,b) return a.line < b.line end)

	-- local list = table.keys(locales[section])
	-- table.sort(list)

	for _, s in ipairs(list) do
		if type(s.text) == "string" then
			f:write(('tDef(%s, %q) -- %s\n'):format(s.line, s.text, s.type))
		end
	end
	f:write('\n\n')
end
f:close()
