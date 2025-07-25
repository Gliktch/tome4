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

newChat{ id="welcome",
	text = _t[[What may I do for you?]],
	answers = {
		{_t"Lady Aeryn, at last I am back home! [tell her your story]", jump="return", cond=function(npc, player) return player:hasQuest("start-sunwall") and player:isQuestStatus("start-sunwall", engine.Quest.COMPLETED, "slazish") and not player:isQuestStatus("start-sunwall", engine.Quest.COMPLETED, "return") end, action=function(npc, player) player:setQuestStatus("start-sunwall", engine.Quest.COMPLETED, "return") end},
		{_t"Tell me more about the Gates of Morning.", jump="explain-gates", cond=function(npc, player) return player.faction ~= "sunwall" end},
		{_t"Before I came here, I happened upon members of the Sunwall in Maj'Eyal. Do you know of this?.", jump="sunwall_west", cond=function(npc, player) return game.state.found_sunwall_west and not npc.been_asked_sunwall_west end, action=function(npc, player) npc.been_asked_sunwall_west = true end},
		{_t"I need help in my hunt for clues about the staff.", jump="clues", cond=function(npc, player) return game.state:isAdvanced() and not player:hasQuest("orc-pride") end},
		{_t"I have destroyed the leaders of all the Orc Prides.", jump="prides-dead", cond=function(npc, player) return player:isQuestStatus("orc-pride", engine.Quest.COMPLETED) end},
		{_t"I am back from the Charred Scar, where the orcs took the staff.", jump="charred-scar", cond=function(npc, player) return player:hasQuest("charred-scar") and player:hasQuest("charred-scar"):isCompleted() end},
		{_t"A dying paladin gave me this map; something about orc breeding pits. [tell her the story]", jump="orc-breeding-pits", cond=function(npc, player) return player:hasQuest("orc-breeding-pits") and player:isQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out") and not player:isQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out-done") end},
		{_t("Sorry, I have to go!", "chat_gates-of-morning-main")},
	}
}

newChat{ id="return",
	text = _t[[@playername@! We thought you had died in the portal explosion. I am glad we were wrong. You saved the Sunwall.
The news about the staff is troubling. Ah well, please at least take time to rest for a while.]],
	answers = {
		{_t"I shall, thank you, my lady.", jump="welcome"},
	},
}

newChat{ id="explain-gates",
	text = _t[[There are two main groups in the population here, Humans and Elves.
Humans came here in the Age of Pyre. Our ancestors were part of a Mardrop expedition to find what had happened to the Naloren lands that sunk under the sea. Their ship was wrecked and the survivors landed on this continent.
They came across a group of elves, seemingly native to those lands, and befriended them - founding the Sunwall and the Gates of Morning.
Then the orc pride came and we have been fighting for our survival ever since.]],
	answers = {
		{_t"Thank you, my lady.", jump="welcome"},
	},
}

newChat{ id="sunwall_west",
	text = _t[[Ahh, so they survived? That is good news...]],
	answers = {
		{_t"Go on.", jump="sunwall_west2"},
		{_t"Well, actually...", jump="sunwall_west2", cond=function(npc, player) return game.state.found_sunwall_west_died end},
	},
}

newChat{ id="sunwall_west2",
	text = _t[[The people you saw are likely the volunteers of Zemekkys' early experiments regarding the farportals.
He is a mage who resides here in the Sunwall, eccentric but skilled, who believes that creation of a new farportal to Maj'Eyal is possible.
Aside from a few early attempts with questionable results, he hasn't had much luck. Still, it's gladdening to hear that the volunteers for his experiments live, regardless of their location. We are all still under the same Sun, after all.

Actually... maybe it would benefit you if you meet Zemekkys. He would surely be intrigued by that Orb of Many Ways you possess. He lives in a small house just to the north.]],
	answers = {
		{_t"Maybe I'll visit him. Thank you.", jump="welcome"},
	},
}

newChat{ id="prides-dead",
	text = _t[[The news has indeed reached me. I could scarce believe it, so long have we been at war with the Pride.
Now they are dead? At the hands of just one @playerdescriptor.race@? Truly I am amazed by your power.
While you were busy bringing an end to the orcs, we managed to discover some parts of the truth from a captive orc.
He talked about the shield protecting the High Peak. It seems to be controlled by "orbs of command" which the masters of the Prides had in their possession.
He also said the only way to enter the peak and de-activate the shield is through the "slime tunnels", located somewhere in one of the Prides, probably Grushnak.
]],
	answers = {
		{_t"Thanks, my lady. I have not been able to find all of the orbs of command in my travels; could you have some of your men search for me?",
		jump="prides-dead-orbs-missing",
		cond=function(npc, player) return not (game.party:findInAllPartyInventoriesBy("define_as", "ORB_DRAGON") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_DESTRUCTION") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_UNDEATH") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_ELEMENTS")) end
		},
		{_t"Thanks, my lady. I will look for the tunnel and venture inside the Peak.", 
		cond=function(npc, player) return (game.party:findInAllPartyInventoriesBy("define_as", "ORB_DRAGON") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_DESTRUCTION") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_UNDEATH") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_ELEMENTS")) end,
		action=function(npc, player)
			player:setQuestStatus("orc-pride", engine.Quest.DONE)
			player:grantQuest("high-peak")
		end},
	},
}

newChat{ id="prides-dead-orbs-missing", 
	text = _t[[I have already sent parties to clear out the remainder of the prides as you progressed, and have instructed to keep a sharp eye out for any orbs of command you may have missed.
	Which do you not have? I can check with the parties if they found any. Our sources indicate that you should have four: one of Undeath, one of Destruction, one of Dragons, and one of Elemental might.]],
	answers = {
				{_t"The orb of Undeath.",
		jump="prides-dead-orbs-missing-undeath",
		cond=function(npc, player) return not (game.party:findInAllPartyInventoriesBy("define_as", "ORB_UNDEATH")) end
		},
				{_t"The orb of Destruction.",
		jump="prides-dead-orbs-missing-destruction",
		cond=function(npc, player) return not (game.party:findInAllPartyInventoriesBy("define_as", "ORB_DESTRUCTION")) end
		},
				{_t"The orb of Dragons.",
		jump="prides-dead-orbs-missing-dragon",
		cond=function(npc, player) return not (game.party:findInAllPartyInventoriesBy("define_as", "ORB_DRAGON")) end
		},
				{_t"The orb of Elements.",
		jump="prides-dead-orbs-missing-elements",
		cond=function(npc, player) return not (game.party:findInAllPartyInventoriesBy("define_as", "ORB_ELEMENTS")) end
		},
				{_t"Thanks, my lady, that is all of them. I will look for the tunnel and venture inside the Peak.", 
		cond=function(npc, player) return (game.party:findInAllPartyInventoriesBy("define_as", "ORB_DRAGON") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_DESTRUCTION") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_UNDEATH") and game.party:findInAllPartyInventoriesBy("define_as", "ORB_ELEMENTS")) end,
		action=function(npc, player)
			player:setQuestStatus("orc-pride", engine.Quest.DONE)
			player:grantQuest("high-peak")
		end},
	},
}

newChat{ id="prides-dead-orbs-missing-undeath",
	text = _t[[Ah yes, my men have found that in Rak'Shor Pride. Here: ]],
	answers = {
		{_t"Thank you, my lady.", 
		jump="prides-dead-orbs-missing",
		action = function(npc, player)
			local orb = game.zone:makeEntityByName(game.level, "object", "ORB_UNDEATH", true)
			orb:identify(true)
			game.zone:addEntity(game.level, orb, "object")
			player:addObject(player:getInven("INVEN"), orb)
		end},
	}
}

newChat{ id="prides-dead-orbs-missing-elements",
	text = _t[[Ah yes, my men have found that in Vor Pride. Here: ]],
	answers = {
		{_t"Thank you, my lady.", 
		jump="prides-dead-orbs-missing",
		action = function(npc, player)
			local orb = game.zone:makeEntityByName(game.level, "object", "ORB_ELEMENTS", true)
			orb:identify(true)
			game.zone:addEntity(game.level, orb, "object")
			player:addObject(player:getInven("INVEN"), orb)
		end},
	}
}

newChat{ id="prides-dead-orbs-missing-destruction",
	text = _t[[Ah yes, my men have found that in Grushnak Pride. Here: ]],
	answers = {
		{_t"Thank you, my lady.", 
		jump="prides-dead-orbs-missing",
		action = function(npc, player)
			local orb = game.zone:makeEntityByName(game.level, "object", "ORB_DESTRUCTION", true)
			orb:identify(true)
			game.zone:addEntity(game.level, orb, "object")
			player:addObject(player:getInven("INVEN"), orb)
		end},
	}
}

newChat{ id="prides-dead-orbs-missing-dragon",
	text = _t[[Ah yes, my men have found that in Gorbat Pride. Here: ]],
	answers = {
		{_t"Thank you, my lady.", 
		jump="prides-dead-orbs-missing",
		action = function(npc, player)
			local orb = game.zone:makeEntityByName(game.level, "object", "ORB_DRAGON", true)
			orb:identify(true)
			game.zone:addEntity(game.level, orb, "object")
			player:addObject(player:getInven("INVEN"), orb)
		end},
	}
}

newChat{ id="clues",
	text = _t[[As much as I would like to help, our forces are already spread too thin; we cannot provide you with direct assistance.
But I might be able to help you by explaining how the Pride is organised.
Recently we have heard the Pride speaking about a new master, or masters. They might be the ones behind that mysterious staff of yours.
We believe that the heart of their power is the High Peak, in the center of the continent. But it is inaccessible and covered by some kind of shield.
You must investigate the bastions of the Pride. Perhaps you will find more information about the High Peak, and any orc you kill is one less that will attack us.
The known bastions of the Pride are:
- Rak'shor Pride, in the west of the southern desert
- Gorbat Pride, in a mountain range in the southern desert
- Vor Pride, in the northeast
- Grushnak Pride, on the eastern slope of the High Peak]],
-- - A group of corrupted humans live in Eastport on the southern coastline; they have contact with the Pride
	answers = {
		{_t"I will investigate them.", jump="relentless", action=function(npc, player)
			player:setQuestStatus("orc-hunt", engine.Quest.DONE)
			player:grantQuest("orc-pride")
			game.logPlayer(game.player, "Aeryn points to the known locations on your map.")
		end},
	},
}

newChat{ id="relentless",
	text = _t[[One more bit of aid I might give you before you go. Your tale has moved me, and the very stars shine with approval of your relentless pursuit. Take their blessing, and let nothing stop you in your quest.
	#LIGHT_GREEN#*She touches your forehead with one cool hand, and you feel a surge of power*
	]],
	answers = {
		{_t"I'll leave not a single orc standing.", jump="welcome", action=function(npc, player)
			player:learnTalent(player.T_RELENTLESS_PURSUIT, true, 1, {no_unlearn=true})
			game.logPlayer(game.player, "#VIOLET#You have learned the talent Relentless Pursuit.")
		end},
	},
}

newChat{ id="charred-scar",
	text = _t[[I have heard about that; good men lost their lives for this. I hope it was worth it.]],
	answers = {
		{_t"Yes, my lady, they delayed the orcs so that I could get to the heart of the volcano. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="charred-scar-success",
			cond=function(npc, player) return player:isQuestStatus("charred-scar", engine.Quest.COMPLETED, "stopped") end,
		},
		{_t"I am afraid I was too late, but I still have some valuable information. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="charred-scar-fail",
			cond=function(npc, player) return player:isQuestStatus("charred-scar", engine.Quest.COMPLETED, "not-stopped") end,
		},
	},
}

newChat{ id="charred-scar-success",
	text = _t[[Sorcerers? I have never heard of them. There were rumours about a new master of the Pride, but it seems they have two.
Thank you for everything. You must continue your hunt now that you know what to look for.]],
	answers = {
		{_t"I will avenge your men.", action=function(npc, player)
			player:setQuestStatus("charred-scar", engine.Quest.DONE)
			game:unlockBackground("aeryn", "High Sun Paladin Aeryn")
		end}
	},
}

newChat{ id="charred-scar-fail",
	text = _t[[Sorcerers? I have never heard of them. There were rumours about a new master of the Pride, but it seems they have two.
I am afraid with the power they gained today they will be even harder to stop, but we do not have a choice.]],
	answers = {
		{_t"I will avenge your men.", action=function(npc, player) player:setQuestStatus("charred-scar", engine.Quest.DONE) end}
	},
}

newChat{ id="orc-breeding-pits",
	text = _t[[Ah! This is wonderful! Finally a ray of hope amidst the darkness. I will assign my best troops to this. Thank you, @playername@ - take this as a token of gratitude.]],
	answers = {
		{_t"Good luck.", action=function(npc, player)
			player:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out-done")
			player:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED)

			for i = 1, 5 do
				local ro = game.zone:makeEntity(game.level, "object", {ignore_material_restriction=true, type="gem", special=function(o) return o.material_level and o.material_level >= 5 end}, nil, true)
				if ro then
					ro:identify(true)
					game.logPlayer(player, "Aeryn gives you: %s", ro:getName{do_color=true})
					game.zone:addEntity(game.level, ro, "object")
					player:addObject(player:getInven("INVEN"), ro)
				end
			end
		end}
	},
}


return "welcome"
