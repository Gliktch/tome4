local args = {...}

local skip_next = false
for line in io.lines(args[1]) do
	local ok = true
	if line == "" and skip_next then ok = false end
	skip_next = false

	if     line == "[img]https://te4.org/images/tmp/changelog_tome.png[/img]" then line = "![Changelog for Tales of MajEyal](https://te4.org/images/tmp/changelog_tome.png)"
	elseif line == "[img]https://te4.org/images/tmp/changelog_ashes.png[/img]" then line = "![Changelog for Ashes of Urh'Rok](http://te4.org/images/tmp/changelog_ashes.png)"
	elseif line == "[img]https://te4.org/images/tmp/changelog_embers.png[/img]" then line = "![Changelog for Embers of Rage](http://te4.org/images/tmp/changelog_embers.png)"
	elseif line == "[img]https://te4.org/images/cults_header.png[/img]" then line = "![Changelog for Forbidden Cults](http://te4.org/images/cults_header.png)"
	end
	line = line:gsub("^%[%*%]", "* ")
	line = line:gsub(" See http://te4.org/", "")
	
	if line == "[list]" or line == "[/list]" then ok = false end
	if line == "Your launcher should automatically update your game so no need to redownload it all." then ok = false skip_next = true end
	if line == "If your launcher didn't self-update correctly, just redownload it from the homepage." then ok = false skip_next = true end
	if line == "Don't forget to help ToME by with donations ( http://te4.org/donate ) or on [url=https://www.patreon.com/darkgodone]Patreon[/url] !" then ok = false skip_next = true end

	if ok then
		print(line)
	end
	was_ok = ok
end
