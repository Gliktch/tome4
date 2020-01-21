------------------------------------------------
section "game/engines/default/engine/Birther.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/Trap.lua"

t("%s", "%s")


------------------------------------------------
section "game/engines/default/engine/ai/talented.lua"

t("#ORCHID#__[%d]%s improved talented AI picked talent[att:%d, turn %s]: %s", "#ORCHID#__[%d]%s improved talented AI picked talent[att:%d, turn %s]: %s")
t("__[%d]%s#ORANGE# ACTION FAILED:  %s, %s", "__[%d]%s#ORANGE# ACTION FAILED:  %s, %s")
t("#SLATE#__%s[%d] improved talented AI No talents available [att:%d, turn %s]", "#SLATE#__%s[%d] improved talented AI No talents available [att:%d, turn %s]")


------------------------------------------------
section "game/engines/default/engine/dialogs/GameMenu.lua"

t("Steam", "Steam")


------------------------------------------------
section "game/engines/default/engine/dialogs/GetText.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/ShowAchievements.lua"

t("", "")
t("???", "???")


------------------------------------------------
section "game/engines/default/engine/dialogs/ShowEquipInven.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/ShowEquipment.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/ShowErrorStack.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/ShowInventory.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/ShowPickupFloor.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/ShowStore.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/SteamOptions.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/Talkbox.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/UseTalents.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/VideoOptions.lua"

t("", "")


------------------------------------------------
section "game/engines/default/engine/dialogs/microtxn/ShowPurchasable.lua"

t("%0.2f %s", "%0.2f %s")


------------------------------------------------
section "game/engines/default/engine/interface/ActorTalents.lua"

t("%s", "%s")


------------------------------------------------
section "game/engines/default/engine/ui/Inventory.lua"

t("", "")


------------------------------------------------
section "game/engines/default/modules/boot/dialogs/MainMenu.lua"

t("#LIGHT_BLUE##{underline}#%s#LAST##{normal}#", "#LIGHT_BLUE##{underline}#%s#LAST##{normal}#")
t("Steam", "Steam")


------------------------------------------------
section "game/engines/default/modules/boot/dialogs/ProfileSteamRegister.lua"

t("Steam", "Steam")


------------------------------------------------
section "game/modules/tome/ai/improved_tactical.lua"

t("#ORCHID#%s wants escape(move) %0.2f (air: %s = %0.2f) on %s (%d, %d, air:%s = %s turns)", "#ORCHID#%s wants escape(move) %0.2f (air: %s = %0.2f) on %s (%d, %d, air:%s = %s turns)")
t("#ORCHID#%s wants escape(move) %0.2f (heal) in %s at(%d, %d) dam %d vs %d avail life)", "#ORCHID#%s wants escape(move) %0.2f (heal) in %s at(%d, %d) dam %d vs %d avail life)")
t("#GREY#__%s[%d] tactical AI: NO USEFUL ACTIONS", "#GREY#__%s[%d] tactical AI: NO USEFUL ACTIONS")
t("#GREY#%3d: %-40s score=%-+4.2f[Lx%-5.2f Sx%5.2f Mx%0.2f] (%s)", "#GREY#%3d: %-40s score=%-+4.2f[Lx%-5.2f Sx%5.2f Mx%0.2f] (%s)")
t("%s__%s[%d] tactical AI picked action[att:%d, turn %s]: (%s)%s {%-+4.2f [%s]}", "%s__%s[%d] tactical AI picked action[att:%d, turn %s]: (%s)%s {%-+4.2f [%s]}")
t("#GREY#__[%d]%s ACTION SUCCEEDED:  %s, tacs: %s, FT:%s", "#GREY#__[%d]%s ACTION SUCCEEDED:  %s, tacs: %s, FT:%s")
t("__[%d]%s #ORANGE# ACTION FAILED:  %s, FT:%s", "__[%d]%s #ORANGE# ACTION FAILED:  %s, FT:%s")
t("__[%d]%s #SLATE# tactical AI: NO ACTION, best: %s, %s", "__[%d]%s #SLATE# tactical AI: NO ACTION, best: %s, %s")
t("%s__turn %d: Invoking improved tactical AI for [%s]%s(%d,%d) target:[%s]%s %s", "%s__turn %d: Invoking improved tactical AI for [%s]%s(%d,%d) target:[%s]%s %s")
t("#ROYAL_BLUE#---talents disabled---", "#ROYAL_BLUE#---talents disabled---")


------------------------------------------------
section "game/modules/tome/ai/improved_talented.lua"

t("%s__turn %d: Invoking improved_talented_simple AI for [%s]%s(%d,%d) target:[%s]%s %s", "%s__turn %d: Invoking improved_talented_simple AI for [%s]%s(%d,%d) target:[%s]%s %s")


------------------------------------------------
section "game/modules/tome/ai/maintenance.lua"

t("#ORCHID#__%s[%d]maintenance AI picked action: %s (%s)", "#ORCHID#__%s[%d]maintenance AI picked action: %s (%s)")
t("__%s[%d] #ORANGE# maintenance ACTION FAILED:  %s", "__%s[%d] #ORANGE# maintenance ACTION FAILED:  %s")


------------------------------------------------
section "game/modules/tome/ai/special_movements.lua"

t("__%s #GREY# (%d, %d) trying to move to a safe grid", "__%s #GREY# (%d, %d) trying to move to a safe grid")
t("#GREY#___Trying existing path to (%s, %s)", "#GREY#___Trying existing path to (%s, %s)")
t("#GREY#___Using new path to (%s, %s)", "#GREY#___Using new path to (%s, %s)")
t("__%s #GREY# (%d, %d) trying to flee_dmap_keep_los to (%d, %d)", "__%s #GREY# (%d, %d) trying to flee_dmap_keep_los to (%d, %d)")


------------------------------------------------
section "game/modules/tome/ai/tactical.lua"

t("%s__turn %d: Invoking old tactical AI for [%s]%s(%d,%d) target:[%s]%s %s", "%s__turn %d: Invoking old tactical AI for [%s]%s(%d,%d) target:[%s]%s %s")


------------------------------------------------
section "game/modules/tome/ai/target.lua"

t("#RED# [%s]%s #ORANGE#CLEARING OLD TARGET#LAST#: [%s]%s", "#RED# [%s]%s #ORANGE#CLEARING OLD TARGET#LAST#: [%s]%s")


------------------------------------------------
section "game/modules/tome/class/Actor.lua"

t(" (%d%%)", " (%d%%)")
t("%s%d %s#LAST#", "%s%d %s#LAST#")


------------------------------------------------
section "game/modules/tome/class/Game.lua"

t("#TEAL#%s", "#TEAL#%s")
t("%s", "%s")


------------------------------------------------
section "game/modules/tome/class/GameState.lua"

t("#LIGHT_GREEN#%s", "#LIGHT_GREEN#%s")


------------------------------------------------
section "game/modules/tome/class/Grid.lua"

t("%s", "%s")


------------------------------------------------
section "game/modules/tome/class/NPC.lua"

t("UID: ", "UID: ")


------------------------------------------------
section "game/modules/tome/class/Object.lua"

t(", ", ", ")
t(".", ".")


------------------------------------------------
section "game/modules/tome/class/Player.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/class/Projectile.lua"

t("UID: ", "UID: ")


------------------------------------------------
section "game/modules/tome/class/Trap.lua"

t("#LIGHT_BLUE#%s: %s#LAST#", "#LIGHT_BLUE#%s: %s#LAST#")
t("#CADET_BLUE#%s %ss %s.", "#CADET_BLUE#%s %ss %s.")


------------------------------------------------
section "game/modules/tome/class/UserChatExtension.lua"

t("#ANTIQUE_WHITE#has linked an item: #WHITE# %s", "#ANTIQUE_WHITE#has linked an item: #WHITE# %s")
t("#ANTIQUE_WHITE#has linked a creature: #WHITE# %s", "#ANTIQUE_WHITE#has linked a creature: #WHITE# %s")
t("#ANTIQUE_WHITE#has linked a talent: #WHITE# %s", "#ANTIQUE_WHITE#has linked a talent: #WHITE# %s")
t("#CRIMSON#%s#WHITE#%s", "#CRIMSON#%s#WHITE#%s")


------------------------------------------------
section "game/modules/tome/class/generator/actor/Arena.lua"

t("#LIGHT_RED#%s%s", "#LIGHT_RED#%s%s")


------------------------------------------------
section "game/modules/tome/class/interface/ActorAI.lua"

t("%s #PINK#searching for safer grids [radius %s from (%s, %s), val = %s], dam_wt=%s, air_wt=%s, dist_weight=%s, want_closer=%s", "%s #PINK#searching for safer grids [radius %s from (%s, %s), val = %s], dam_wt=%s, air_wt=%s, dist_weight=%s, want_closer=%s")
t("#PINK# --best reachable grid: (%d, %d) (dist: %s, val: %s(%s))", "#PINK# --best reachable grid: (%d, %d) (dist: %s, val: %s(%s))")
t("_[%d]%s %s%s tactical weight CACHE MISMATCH (%s) vs %s[%d]{%s}: %s vs %s(cache)", "_[%d]%s %s%s tactical weight CACHE MISMATCH (%s) vs %s[%d]{%s}: %s vs %s(cache)")
t("_[%d]%s #YELLOW# TACTICAL turn_procs CACHE MISMATCH for %s", "_[%d]%s #YELLOW# TACTICAL turn_procs CACHE MISMATCH for %s")
t("#YELLOW_GREEN#____Cached tactics: %s", "#YELLOW_GREEN#____Cached tactics: %s")
t("#YELLOW_GREEN#__Computed tactics: %s", "#YELLOW_GREEN#__Computed tactics: %s")


------------------------------------------------
section "game/modules/tome/class/interface/ActorObjectUse.lua"

t("%s", "%s")


------------------------------------------------
section "game/modules/tome/class/interface/PartyDeath.lua"

t("#{bold}#", "#{bold}#")


------------------------------------------------
section "game/modules/tome/class/uiset/ClassicPlayerDisplay.lua"

t([[#{bold}##GOLD#%s
(%s: %s)#WHITE##{normal}#
]], [[#{bold}##GOLD#%s
(%s: %s)#WHITE##{normal}#
]])
t("%s#{normal}#", "%s#{normal}#")
t([[#GOLD#%s#LAST#
%s
]], [[#GOLD#%s#LAST#
%s
]])
t("%-8.8s:", "%-8.8s:")
t("Saving:", "Saving:")
t([[#GOLD##{bold}#%s#{normal}##WHITE#
]], [[#GOLD##{bold}#%s#{normal}##WHITE#
]])


------------------------------------------------
section "game/modules/tome/class/uiset/Minimalist.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])
t([[#{bold}##GOLD#%s
(%s: %s)#WHITE##{normal}#
]], [[#{bold}##GOLD#%s
(%s: %s)#WHITE##{normal}#
]])
t("#VIOLET#", "#VIOLET#")


------------------------------------------------
section "game/modules/tome/data/birth/classes/wilder.lua"

t([[The Spellblaze's scars may be starting to heal,
but little can change how the partisans feel.
Nature and arcane could bridge their divide -
and when it comes down to it, gold won't take sides...]], [[The Spellblaze's scars may be starting to heal,
but little can change how the partisans feel.
Nature and arcane could bridge their divide -
and when it comes down to it, gold won't take sides...]])


------------------------------------------------
section "game/modules/tome/data/birth/races/construct.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/calendar_allied.lua"

t("Allure", "Allure")
t("Regrowth", "Regrowth")
t("Time of Balance", "Time of Balance")
t("Pyre", "Pyre")
t("Mirth", "Mirth")
t("Dusk", "Dusk")
t("Time of Equilibrium", "Time of Equilibrium")
t("Haze", "Haze")
t("Decay", "Decay")


------------------------------------------------
section "game/modules/tome/data/calendar_dwarf.lua"

t("Iron", "Iron")
t("Steel", "Steel")
t("Gold", "Gold")
t("Stralite", "Stralite")
t("Voratun", "Voratun")
t("Acquisition", "Acquisition")
t("Profit", "Profit")
t("Wealth", "Wealth")
t("Dearth", "Dearth")
t("Loss", "Loss")
t("Shortage", "Shortage")


------------------------------------------------
section "game/modules/tome/data/chats/artifice-mastery.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])


------------------------------------------------
section "game/modules/tome/data/chats/artifice.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])


------------------------------------------------
section "game/modules/tome/data/chats/escort-quest.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])
t([[#GOLD#%s / %s#LAST#
%s]], [[#GOLD#%s / %s#LAST#
%s]])


------------------------------------------------
section "game/modules/tome/data/chats/last-hope-lost-merchant.lua"

t(".", ".")


------------------------------------------------
section "game/modules/tome/data/chats/player-inscription.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])


------------------------------------------------
section "game/modules/tome/data/chats/shertul-fortress-gladium-orb.lua"

t("*#LIGHT_GREEN#This orb is used to control the gladium arena.#WHITE#*", "*#LIGHT_GREEN#This orb is used to control the gladium arena.#WHITE#*")
t("[Go back to the Fortress]", "[Go back to the Fortress]")


------------------------------------------------
section "game/modules/tome/data/chats/trap-priming.lua"

t("%s[%s: %s]#LAST#", "%s[%s: %s]#LAST#")
t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])


------------------------------------------------
section "game/modules/tome/data/chats/worldly-knowledge.lua"

t([[#GOLD#%s / %s#LAST#
]], [[#GOLD#%s / %s#LAST#
]])


------------------------------------------------
section "game/modules/tome/data/general/objects/boss-artifacts-maj-eyal.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/general/objects/gem.lua"

t("..", "..")


------------------------------------------------
section "game/modules/tome/data/general/objects/lore/fun.lua"

t("..", "..")


------------------------------------------------
section "game/modules/tome/data/general/objects/rods.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/general/objects/world-artifacts.lua"

t("%s: %s", "%s: %s")


------------------------------------------------
section "game/modules/tome/data/lore/age-allure.lua"

t([[FROM: Investigator Churrack
TO: Whoever holds the position of High Overseer of Loyalty when we're let out

Though I'm trapped in here with these healers, I haven't stopped prying to determine if their loyalties lie with us or with themselves. This case has more layers than a damn onion; while Astelrid did disobey a direct order (and several more by revealing the existence of that order), her alternative seems to fit our goals nonetheless. Response from staff has been mixed.  While most are reluctantly going along with her plan for lack of other options, some seem to follow her lead enthusiastically, and have been singing this song as they wait in line for their treatment:

#{italic}#Some Nargol once told me their Empire's gonna roll me
We ain't as strong as all their undead
They looked kind of silly with giant feet so furry
And an ogre's club smashing their foreheads

Well, the Empire's coming and they won't stop coming
So you'd better be ready to hit the ground running
Didn't make sense to kill everyone
Praise the Overseers, but that plan was dumb

So much to do, so much to see
So what's wrong with waiting in stasis?
We'll never know if we don't try
We'll never shine if we just die

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

It's a safe place, even as it gets older
'cause this war's not over until we say it's ogre
But the golems outside beg to differ
Judging by the sights in the scrying-orb's picture

The ground we're under was getting pretty thin
Their scouts are onto us, and they've got us all pinned
We blew the tunnels - no way out,
until the Conclave finds us, give trespassers a rout!

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

Somebody once asked if we'd finished, but alas
While I'm proud of what we've done in this place
We weren't done yet with this project,
but we're close enough where this isn't neglect
Eyal will appreciate our new race!

Well, the years'll start coming and they won't stop coming
So you'd better be ready to hit the ground running
Didn't make sense to kill everyone
Praise the Overseers, but that plan was dumb

So much to do, so much to see
So what's wrong with waiting in stasis?
We'll never know if we don't try
We'll never shine if we just die

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

They won't work on normal humans
But we won't age sleeping in these ruins#{normal}#

...Everyone reacts to grief differently, I guess. #{bold}#-Churrack#{normal}#]], [[FROM: Investigator Churrack
TO: Whoever holds the position of High Overseer of Loyalty when we're let out

Though I'm trapped in here with these healers, I haven't stopped prying to determine if their loyalties lie with us or with themselves. This case has more layers than a damn onion; while Astelrid did disobey a direct order (and several more by revealing the existence of that order), her alternative seems to fit our goals nonetheless. Response from staff has been mixed.  While most are reluctantly going along with her plan for lack of other options, some seem to follow her lead enthusiastically, and have been singing this song as they wait in line for their treatment:

#{italic}#Some Nargol once told me their Empire's gonna roll me
We ain't as strong as all their undead
They looked kind of silly with giant feet so furry
And an ogre's club smashing their foreheads

Well, the Empire's coming and they won't stop coming
So you'd better be ready to hit the ground running
Didn't make sense to kill everyone
Praise the Overseers, but that plan was dumb

So much to do, so much to see
So what's wrong with waiting in stasis?
We'll never know if we don't try
We'll never shine if we just die

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

It's a safe place, even as it gets older
'cause this war's not over until we say it's ogre
But the golems outside beg to differ
Judging by the sights in the scrying-orb's picture

The ground we're under was getting pretty thin
Their scouts are onto us, and they've got us all pinned
We blew the tunnels - no way out,
until the Conclave finds us, give trespassers a rout!

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

Somebody once asked if we'd finished, but alas
While I'm proud of what we've done in this place
We weren't done yet with this project,
but we're close enough where this isn't neglect
Eyal will appreciate our new race!

Well, the years'll start coming and they won't stop coming
So you'd better be ready to hit the ground running
Didn't make sense to kill everyone
Praise the Overseers, but that plan was dumb

So much to do, so much to see
So what's wrong with waiting in stasis?
We'll never know if we don't try
We'll never shine if we just die

Hey, now, you're a healer, get ogrified, go wait
Hey, now, you're a guard now, stand vigil in the tanks
They won't work on normal humans
But we won't age sleeping in these ruins

They won't work on normal humans
But we won't age sleeping in these ruins#{normal}#

...Everyone reacts to grief differently, I guess. #{bold}#-Churrack#{normal}#]])


------------------------------------------------
section "game/modules/tome/data/lore/misc.lua"

t("Mantra of a Shiiak", "Mantra of a Shiiak")


------------------------------------------------
section "game/modules/tome/data/lore/shertul.lua"

t("#{italic}#'Meas Abar.'#{normal}#", "#{italic}#'Meas Abar.'#{normal}#")


------------------------------------------------
section "game/modules/tome/data/maps/vaults/test.lua"

t("#PINK# Test vault onplace function called: zone:%s, level:%s, map:%s", "#PINK# Test vault onplace function called: zone:%s, level:%s, map:%s")
t("#PINK# Test vault roomCheck function called: zone:%s, level:%s, map:%s", "#PINK# Test vault roomCheck function called: zone:%s, level:%s, map:%s")


------------------------------------------------
section "game/modules/tome/data/quests/arena.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/quests/charred-scar.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/quests/east-portal.lua"

t("", "")
t("Meranas, Herald of Angolwen", "Meranas, Herald of Angolwen")


------------------------------------------------
section "game/modules/tome/data/quests/escort-duty.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/quests/high-peak.lua"

t("Endgame", "Endgame")
t("", "")


------------------------------------------------
section "game/modules/tome/data/quests/keepsake.lua"

t("Last of the Caravan", "Last of the Caravan")
t("Death of Kyless", "Death of Kyless")


------------------------------------------------
section "game/modules/tome/data/quests/lightning-overload.lua"

t("Scared Halfling", "Scared Halfling")


------------------------------------------------
section "game/modules/tome/data/quests/orc-breeding-pits.lua"

t("Desperate Measures", "Desperate Measures")
t("You have encountered a dying sun paladin that told you about the orcs breeding pit, a true abomination.", "You have encountered a dying sun paladin that told you about the orcs breeding pit, a true abomination.")
t("You have decided to report the information to Aeryn so she can deal with it.", "You have decided to report the information to Aeryn so she can deal with it.")
t("Aeryn said she would send troops to deal with it.", "Aeryn said she would send troops to deal with it.")
t("You have taken upon yourself to cleanse it and deal a crippling blow to the orcs.", "You have taken upon yourself to cleanse it and deal a crippling blow to the orcs.")
t("The abominable task is done.", "The abominable task is done.")
t("Entrance to the orc breeding pit", "Entrance to the orc breeding pit")


------------------------------------------------
section "game/modules/tome/data/quests/orc-pride.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/quests/ring-of-blood.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/quests/west-portal.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/resources.lua"

t("%d/%d (%d%%%%)", "%d/%d (%d%%%%)")


------------------------------------------------
section "game/modules/tome/data/rooms/greater_vault.lua"

t("#GOLD#PLACED GREATER VAULT: %s", "#GOLD#PLACED GREATER VAULT: %s")


------------------------------------------------
section "game/modules/tome/data/rooms/lesser_vault.lua"

t("#GOLD#PLACED LESSER VAULT: %s", "#GOLD#PLACED LESSER VAULT: %s")


------------------------------------------------
section "game/modules/tome/data/talents/chronomancy/induced-phenomena.lua"

t("Cosmic Cycle", "Cosmic Cycle")
t("#LIGHT_BLUE#Your cosmic cycle expands.", "#LIGHT_BLUE#Your cosmic cycle expands.")
t("#LIGHT_RED#Your cosmic cycle contracts.", "#LIGHT_RED#Your cosmic cycle contracts.")
t([[Tune yourself into the ebb and flow of spacetime.  When your Paradox crosses a 100 point threshold, your Cosmic Cycle gains or loses one radius.
		While Cosmic Cycle is expanding, your temporal resistance penetration will be increased by %d%%.  While it's contracting, your Willpower for Paradox calculations will be increased by %d%%.]], [[Tune yourself into the ebb and flow of spacetime.  When your Paradox crosses a 100 point threshold, your Cosmic Cycle gains or loses one radius.
		While Cosmic Cycle is expanding, your temporal resistance penetration will be increased by %d%%.  While it's contracting, your Willpower for Paradox calculations will be increased by %d%%.]])
t("Polarity Shift", "Polarity Shift")
t("You must have Cosmic Cycle active to use this talent.", "You must have Cosmic Cycle active to use this talent.")
t("particles_images/alt_temporal_bolt_0%d", "particles_images/alt_temporal_bolt_0%d")
t([[Reverses the polarity of your Cosmic Cycle.  If it's currently contracting, it will begin to expand, firing a homing missile at each target within the radius that deals %0.2f temporal damage.
		If it's currently expanding, it will begin to contract, braiding the lifelines of all targets within the radius for %d turns.  Braided targets take %d%% of all damage dealt to other braided targets.
		The damage will scale with your Spellpower.]], [[Reverses the polarity of your Cosmic Cycle.  If it's currently contracting, it will begin to expand, firing a homing missile at each target within the radius that deals %0.2f temporal damage.
		If it's currently expanding, it will begin to contract, braiding the lifelines of all targets within the radius for %d turns.  Braided targets take %d%% of all damage dealt to other braided targets.
		The damage will scale with your Spellpower.]])
t("Reverse Causality", "Reverse Causality")
t([[When a creature enters your expanding Cosmic Cycle, you heal %d life at the start of your next turn.
		When a creature leaves your contracting Cosmic Cycle, you reduce the duration of one detrimental effect on you by %d at the start of your next turn.
		The healing will scale with your Spellpower.]], [[When a creature enters your expanding Cosmic Cycle, you heal %d life at the start of your next turn.
		When a creature leaves your contracting Cosmic Cycle, you reduce the duration of one detrimental effect on you by %d at the start of your next turn.
		The healing will scale with your Spellpower.]])
t([[While your cosmic cycle is expanding, creatures in its radius have a %d%% chance to suffer the effects of aging; pinning, blinding, or confusing them for 3 turns.
		While your cosmic cycle is contracting, creatures in its radius suffer from age regression; reducing their three highest stats by %d.
		The chance and stat reduction will scale with your Spellpower.]], [[While your cosmic cycle is expanding, creatures in its radius have a %d%% chance to suffer the effects of aging; pinning, blinding, or confusing them for 3 turns.
		While your cosmic cycle is contracting, creatures in its radius suffer from age regression; reducing their three highest stats by %d.
		The chance and stat reduction will scale with your Spellpower.]])


------------------------------------------------
section "game/modules/tome/data/talents/chronomancy/temporal-archery.lua"

t("Phase Shot", "Phase Shot")
t("You fire a shot that phases out of time and space allowing it to virtually ignore armor.  The shot will deal %d%% weapon damage as temporal damage to its target.", "You fire a shot that phases out of time and space allowing it to virtually ignore armor.  The shot will deal %d%% weapon damage as temporal damage to its target.")
t("Unerring Shot", "Unerring Shot")
t("You focus your aim and fire a shot with great accuracy, inflicting %d%% weapon damage.  Afterwords your attack will remain improved for one turn as the chronomantic effects linger.", "You focus your aim and fire a shot with great accuracy, inflicting %d%% weapon damage.  Afterwords your attack will remain improved for one turn as the chronomantic effects linger.")
t("Perfect Aim", "Perfect Aim")
t([[You focus your aim, increasing your critical damage multiplier by %d%% and your physical and spell critical strike chance by %d%%
		The effect will scale with your Spellpower.]], [[You focus your aim, increasing your critical damage multiplier by %d%% and your physical and spell critical strike chance by %d%%
		The effect will scale with your Spellpower.]])
t("Quick Shot", "Quick Shot")
t([[You pause time around you long enough to fire a single shot, doing %d%% damage.
		The damage will scale with your Paradox and the cooldown will go down with more talent points invested.]], [[You pause time around you long enough to fire a single shot, doing %d%% damage.
		The damage will scale with your Paradox and the cooldown will go down with more talent points invested.]])


------------------------------------------------
section "game/modules/tome/data/talents/cunning/artifice.lua"

t([[#YELLOW#%s (%s)#LAST#
]], [[#YELLOW#%s (%s)#LAST#
]])
t([[%s (%s)
]], [[%s (%s)
]])


------------------------------------------------
section "game/modules/tome/data/talents/cunning/traps.lua"

t(" (%s)", " (%s)")


------------------------------------------------
section "game/modules/tome/data/talents/cursed/primal-magic.lua"

t("Arcane Bolts", "Arcane Bolts")
t([[Each turn for 4 turns you fire a bolt of arcane energy at your nearest enemy inflicting %d damage.
		The damage will increase with the Magic stat.]], [[Each turn for 4 turns you fire a bolt of arcane energy at your nearest enemy inflicting %d damage.
		The damage will increase with the Magic stat.]])
t("Displace", "Displace")
t("Instantaneously displace yourself within line of sight up to 3 squares away.", "Instantaneously displace yourself within line of sight up to 3 squares away.")
t("Primal Skin", "Primal Skin")
t([[Years of magic have permeated your skin leaving it resistant to the physical world. Your armor is increased by %d.
		The bonus will increase with the Magic stat.]], [[Years of magic have permeated your skin leaving it resistant to the physical world. Your armor is increased by %d.
		The bonus will increase with the Magic stat.]])
t("Vaporize", "Vaporize")
t([[Bathes the target in raw magic inflicting %d damage. Such wild magic is difficult to control and if you fail to keep your wits you will be confused for 4 turns.
		The damage will increase with the Magic stat.]], [[Bathes the target in raw magic inflicting %d damage. Such wild magic is difficult to control and if you fail to keep your wits you will be confused for 4 turns.
		The damage will increase with the Magic stat.]])


------------------------------------------------
section "game/modules/tome/data/talents/cursed/traveler.lua"

t("Hardened", "Hardened")
t("Your travels have hardened you. You gain +%d armor.", "Your travels have hardened you. You gain +%d armor.")
t("Wary", "Wary")
t("You have become wary of danger in your journeys. You have a %d%% chance of not triggering traps.", "You have become wary of danger in your journeys. You have a %d%% chance of not triggering traps.")
t("Weathered", "Weathered")
t("You have become weathered by the elements. Your Cold and Fire resistance is increased by %d%%", "You have become weathered by the elements. Your Cold and Fire resistance is increased by %d%%")
t("Savvy", "Savvy")
t("You have become a keen observer in your travels. Each kill gives you %d%% more experience.", "You have become a keen observer in your travels. Each kill gives you %d%% more experience.")


------------------------------------------------
section "game/modules/tome/data/talents/gifts/gifts.lua"

t("Your body's anatomy is starting to blur.", "Your body's anatomy is starting to blur.")
t("malleable body", "malleable body")


------------------------------------------------
section "game/modules/tome/data/talents/gifts/malleable-body.lua"

t("azdadazdazdazd", "azdadazdazdazd")
t([[Your body is more like that of an ooze, you can split into two for %d turns.
		Your original self has the original ooze aspect while your mitosis gains the acid aspect.
		If you know the Oozing Blades tree all the talents inside are exchanged for those of the Corrosive Blades tree.
		Your two selves share the same healthpool.
		While you are split both of you gain %d%% all resistances.
		Resistances will increase with Mindpower.]], [[Your body is more like that of an ooze, you can split into two for %d turns.
		Your original self has the original ooze aspect while your mitosis gains the acid aspect.
		If you know the Oozing Blades tree all the talents inside are exchanged for those of the Corrosive Blades tree.
		Your two selves share the same healthpool.
		While you are split both of you gain %d%% all resistances.
		Resistances will increase with Mindpower.]])
t("ervevev", "ervevev")
t([[Improve your fungus to allow it to take a part of any healing you receive and improve it.
		Each time you are healed you get a regeneration effect for 6 turns that heals you of %d%% of the direct heal you received.
		The effect will increase with your Mindpower.]], [[Improve your fungus to allow it to take a part of any healing you receive and improve it.
		Each time you are healed you get a regeneration effect for 6 turns that heals you of %d%% of the direct heal you received.
		The effect will increase with your Mindpower.]])
t("zeczczeczec", "zeczczeczec")
t([[Both of you swap place in an instant, creatures attacking one will target the other.
		While swaping you briefly merge together, boosting all your nature and acid damage by %d%% for 6 turns and healing you for %d.
		Damage and healing increase with Mindpower.]], [[Both of you swap place in an instant, creatures attacking one will target the other.
		While swaping you briefly merge together, boosting all your nature and acid damage by %d%% for 6 turns and healing you for %d.
		Damage and healing increase with Mindpower.]])
t("Indiscernible Anatomyblabla", "Indiscernible Anatomyblabla")
t([[Your body's internal organs are melted together, making it much harder to suffer critical hits.
		All direct critical hits (physical, mental, spells) against you have a %d%% chance to instead do their normal damage.]], [[Your body's internal organs are melted together, making it much harder to suffer critical hits.
		All direct critical hits (physical, mental, spells) against you have a %d%% chance to instead do their normal damage.]])


------------------------------------------------
section "game/modules/tome/data/talents/gifts/summon-distance.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/talents/gifts/summon-melee.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/talents/misc/inscriptions.lua"

t("- will only auto use when no saturation effect exists", "- will only auto use when no saturation effect exists")
t(" ", " ")


------------------------------------------------
section "game/modules/tome/data/talents/misc/npcs.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/talents/psionic/grip.lua"

t("Bind", "Bind")
t([[Bind the target in crushing bands of telekinetic force, immobilizing it for %d turns. 
		The duration will improve with your Mindpower.]], [[Bind the target in crushing bands of telekinetic force, immobilizing it for %d turns. 
		The duration will improve with your Mindpower.]])
t("Greater Telekinetic Grasp", "Greater Telekinetic Grasp")
t([[Use finely controlled forces to augment both your flesh-and-blood grip, and your telekinetic grip. This does the following:
		Increases disarm immunity by %d%%.
		Allows %d%% of Willpower and Cunning (instead of the usual 60%%) to be substituted for Strength and Dexterity for the purposes of determining damage done by telekinetically-wielded weapons.
		At talent level 5, telekinetically wielded gems and mindstars will be treated as one material level higher than they actually are.
		]], [[Use finely controlled forces to augment both your flesh-and-blood grip, and your telekinetic grip. This does the following:
		Increases disarm immunity by %d%%.
		Allows %d%% of Willpower and Cunning (instead of the usual 60%%) to be substituted for Strength and Dexterity for the purposes of determining damage done by telekinetically-wielded weapons.
		At talent level 5, telekinetically wielded gems and mindstars will be treated as one material level higher than they actually are.
		]])


------------------------------------------------
section "game/modules/tome/data/talents/psionic/mental-discipline.lua"

t("Aura Discipline", "Aura Discipline")
t([[Your expertise in the art of energy projection grows.
		Aura cooldowns are all reduced by %d turns. Aura damage drains energy more slowly (+%0.2f damage required to lose a point of energy).]], [[Your expertise in the art of energy projection grows.
		Aura cooldowns are all reduced by %d turns. Aura damage drains energy more slowly (+%0.2f damage required to lose a point of energy).]])
t("Shield Discipline", "Shield Discipline")
t("Your expertise in the art of energy absorption grows. Shield cooldowns are all reduced by %d turns, the amount of damage absorption required to gain a point of energy is reduced by %0.1f, and the maximum energy you can gain from each shield is increased by %0.1f per turn.", "Your expertise in the art of energy absorption grows. Shield cooldowns are all reduced by %d turns, the amount of damage absorption required to gain a point of energy is reduced by %0.1f, and the maximum energy you can gain from each shield is increased by %0.1f per turn.")
t("Highly Trained Mind", "Highly Trained Mind")
t([[A life of the mind has had predictably good effects on your Willpower and Cunning.
		Increases Willpower and Cunning by %d.]], [[A life of the mind has had predictably good effects on your Willpower and Cunning.
		Increases Willpower and Cunning by %d.]])


------------------------------------------------
section "game/modules/tome/data/talents/psionic/psi-archery.lua"

t("Guided Shot", "Guided Shot")
t("Fire and guide an arrow to its target with precise telekinetic nudges. Does normal damage, but accuracy and crit chance are increased by %d.", "Fire and guide an arrow to its target with precise telekinetic nudges. Does normal damage, but accuracy and crit chance are increased by %d.")
t("Augmented Shot", "Augmented Shot")
t("Use telekinetic forces to greatly augment the durability and tension of your bow in order to fire an arrow with velocity unmatched by even the mightiest mundane archers. Increases armor penetration by %d, and deals %d%% damage.", "Use telekinetic forces to greatly augment the durability and tension of your bow in order to fire an arrow with velocity unmatched by even the mightiest mundane archers. Increases armor penetration by %d, and deals %d%% damage.")
t("Thought-quick Shot", "Thought-quick Shot")
t("Ready and release an arrow with a flitting thought. This attack does not use a turn, and increases in talent level reduce its cooldown.", "Ready and release an arrow with a flitting thought. This attack does not use a turn, and increases in talent level reduce its cooldown.")
t("Masterful Telekinetic Archery", "Masterful Telekinetic Archery")
t("You cannot do that without a telekinetically-wielded bow.", "You cannot do that without a telekinetically-wielded bow.")
t([[You temporarily set aside a part of you mind to direct your telekinetically-wielded bow. It will automatically attack the nearest target each turn for %d turns.
			The telekinetically-wielded bow uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
			You are not telekinetically wielding anything right now.]], [[You temporarily set aside a part of you mind to direct your telekinetically-wielded bow. It will automatically attack the nearest target each turn for %d turns.
			The telekinetically-wielded bow uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
			You are not telekinetically wielding anything right now.]])
t([[You temporarily set aside a part of you mind to direct your telekinetically-wielded bow. It will automatically attack a target each turn for %d turns.
			The telekinetically-wielded bow uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
		Combat stats:
		Accuracy: %d
		Damage: %d
		APR: %d
		Crit: %0.2f
		Speed: %0.2f]], [[You temporarily set aside a part of you mind to direct your telekinetically-wielded bow. It will automatically attack a target each turn for %d turns.
			The telekinetically-wielded bow uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
		Combat stats:
		Accuracy: %d
		Damage: %d
		APR: %d
		Crit: %0.2f
		Speed: %0.2f]])


------------------------------------------------
section "game/modules/tome/data/talents/psionic/telekinetic-combat.lua"

t("Telekinetic Assault", "Telekinetic Assault")
t([[Assault your target with all weapons, dealing two strikes with your telekinetically-wielded weapon for %d%% damage followed by an attack with your physical weapon for %d%% damage.
		This physical weapon attack uses your Willpower and Cunning instead of Strength and Dexterity to determine Accuracy and damage.
		Any active Aura damage bonusses will extend to your main weapons for this attack.]], [[Assault your target with all weapons, dealing two strikes with your telekinetically-wielded weapon for %d%% damage followed by an attack with your physical weapon for %d%% damage.
		This physical weapon attack uses your Willpower and Cunning instead of Strength and Dexterity to determine Accuracy and damage.
		Any active Aura damage bonusses will extend to your main weapons for this attack.]])


------------------------------------------------
section "game/modules/tome/data/talents/psionic/trance.lua"

t("Trance of Purity", "Trance of Purity")
t([[Activate to purge negative status effects (100%% chance for the first effect, -%d%% less chance for each subsequent effect).  While this talent is sustained all your saving throws are increased by %d.
		The chance to purge and saving throw bonus will scale with your mindpower.
		Only one trance may be active at a time.]], [[Activate to purge negative status effects (100%% chance for the first effect, -%d%% less chance for each subsequent effect).  While this talent is sustained all your saving throws are increased by %d.
		The chance to purge and saving throw bonus will scale with your mindpower.
		Only one trance may be active at a time.]])
t("Trance of Well-Being", "Trance of Well-Being")
t([[Activate to heal yourself for %0.2f life.  While this talent is sustained your healing modifier will be increased by %d%% and your life regen by %0.2f.
		The effects will scale with your mindpower.
		Only one trance may be active at a time.]], [[Activate to heal yourself for %0.2f life.  While this talent is sustained your healing modifier will be increased by %d%% and your life regen by %0.2f.
		The effects will scale with your mindpower.
		Only one trance may be active at a time.]])
t("Trance of Focus", "Trance of Focus")
t([[Activate to increase your critical strike damage by %d%% for 10 turns.  While this talent is sustained your critical strike chance is improved by +%d%%.
		The effects will scale with your mindpower.
		Only one trance may be active at a time.]], [[Activate to increase your critical strike damage by %d%% for 10 turns.  While this talent is sustained your critical strike chance is improved by +%d%%.
		The effects will scale with your mindpower.
		Only one trance may be active at a time.]])
t("Deep Trance", "Deep Trance")
t([[When you wield or wear an item infused by psionic, nature, or arcane-disrupting forces you improve all values under its 'when wielded/worn' field %d%%.
		Note this doesn't change the item itself, but rather the effects it has on your person (the item description will not reflect the improved values).]], [[When you wield or wear an item infused by psionic, nature, or arcane-disrupting forces you improve all values under its 'when wielded/worn' field %d%%.
		Note this doesn't change the item itself, but rather the effects it has on your person (the item description will not reflect the improved values).]])


------------------------------------------------
section "game/modules/tome/data/talents/spells/necrotic-minions.lua"

t(": %d%%", ": %d%%")


------------------------------------------------
section "game/modules/tome/data/talents/techniques/throwing-knives.lua"

t("%d%% %s", "%d%% %s")


------------------------------------------------
section "game/modules/tome/data/talents/uber/mag.lua"

t([[%s
#YELLOW#%s#LAST#
%s
]], [[%s
#YELLOW#%s#LAST#
%s
]])


------------------------------------------------
section "game/modules/tome/data/texts/intro-orc.lua"

t([[Welcome #LIGHT_GREEN#@name@#WHITE#.
You are a member of the feared race of the Orcs.
BLAH BLAH BLAH

You have been sent to a remote island on the southwest coast of the Far East to crush an outpost of the Sunwall, the last remaining bastion of men, elves and dwarves on this continent.

A little to the south lies the outpost. Your task: destroy it and bathe in the blood of its people!
]], [[Welcome #LIGHT_GREEN#@name@#WHITE#.
You are a member of the feared race of the Orcs.
BLAH BLAH BLAH

You have been sent to a remote island on the southwest coast of the Far East to crush an outpost of the Sunwall, the last remaining bastion of men, elves and dwarves on this continent.

A little to the south lies the outpost. Your task: destroy it and bathe in the blood of its people!
]])


------------------------------------------------
section "game/modules/tome/data/texts/unlock-wilder_stone_warden.lua"

t([[While most races of Eyal firmly believe that arcane and nature forces are opposites, Dwarves have found a way to bind them together and meld them into a power to be reckoned with.

You have mastered some arcane and wild talents at a crude level can now create new dwarf characters with the #LIGHT_GREEN#Stone Warden class#WHITE#.

Stone Wardens are Wilders, who are at home in the wilds and draw their power from their connection with nature and arcane
Class features:#YELLOW#
- Dual wield shields and bash your foes with arcane enhanced shield strikes
- Combine arcane and nature forces to split yourself into two powerful halves
- Use vines of stone to grab and assail your foes
- Turn into a huge earth elemental and summon volcanos
- Dwarf race exclusive class (Select it at birth for the option to even appear)#WHITE#

All Wilder classes use Equilibrium for their powers. It represents their connection to nature. 
The higher it gets the more off-balance they are with it. A high Equilibrium makes for a chance to fail to use a power and lose a turn.
Stone Wardens also use Mana.
]], [[While most races of Eyal firmly believe that arcane and nature forces are opposites, Dwarves have found a way to bind them together and meld them into a power to be reckoned with.

You have mastered some arcane and wild talents at a crude level can now create new dwarf characters with the #LIGHT_GREEN#Stone Warden class#WHITE#.

Stone Wardens are Wilders, who are at home in the wilds and draw their power from their connection with nature and arcane
Class features:#YELLOW#
- Dual wield shields and bash your foes with arcane enhanced shield strikes
- Combine arcane and nature forces to split yourself into two powerful halves
- Use vines of stone to grab and assail your foes
- Turn into a huge earth elemental and summon volcanos
- Dwarf race exclusive class (Select it at birth for the option to even appear)#WHITE#

All Wilder classes use Equilibrium for their powers. It represents their connection to nature. 
The higher it gets the more off-balance they are with it. A high Equilibrium makes for a chance to fail to use a power and lose a turn.
Stone Wardens also use Mana.
]])


------------------------------------------------
section "game/modules/tome/data/timed_effects/magical.lua"

t("%d%%", "%d%%")


------------------------------------------------
section "game/modules/tome/data/timed_effects/mental.lua"

t("#ORANGE#", "#ORANGE#")
t("#LIGHT_GREEN#", "#LIGHT_GREEN#")


------------------------------------------------
section "game/modules/tome/data/timed_effects/other.lua"

t("\
- %s%s#LAST#", "\
- %s%s#LAST#")
t("\
- #ffa0ff#%s#LAST#", "\
- #ffa0ff#%s#LAST#")
t("%s%d %s#LAST#", "%s%d %s#LAST#")
t("???", "???")


------------------------------------------------
section "game/modules/tome/data/timed_effects/physical.lua"

t("%0.1f%%", "%0.1f%%")


------------------------------------------------
section "game/modules/tome/data/zones/ardhungol/npcs.lua"

t("xhaiak", "xhaiak")
t("shiaak", "shiaak")


------------------------------------------------
section "game/modules/tome/data/zones/deep-bellow/objects.lua"

t("..", "..")


------------------------------------------------
section "game/modules/tome/data/zones/gladium/grids.lua"

t("Gladium Control Orb", "Gladium Control Orb")


------------------------------------------------
section "game/modules/tome/data/zones/gladium/zone.lua"

t("Fortress Gladium", "Fortress Gladium")


------------------------------------------------
section "game/modules/tome/data/zones/town-last-hope/objects.lua"

t("..", "..")


------------------------------------------------
section "game/modules/tome/dialogs/CharacterSheet.lua"

t("vs ", "vs ")
t("#ORANGE#vs %-11s#LAST#: #00ff00#%3s %s", "#ORANGE#vs %-11s#LAST#: #00ff00#%3s %s")


------------------------------------------------
section "game/modules/tome/dialogs/Donation.lua"

t("#GOLD#Exploration mode (infinite lives)#WHITE#", "#GOLD#Exploration mode (infinite lives)#WHITE#")
t("#GOLD#Item's appearance change (Shimmering)#WHITE#", "#GOLD#Item's appearance change (Shimmering)#WHITE#")


------------------------------------------------
section "game/modules/tome/dialogs/GraphicMode.lua"

t("Altefcat/Gervais", "Altefcat/Gervais")
t("Old RPG", "Old RPG")
t("64x64", "64x64")
t("48x48", "48x48")
t("32x32", "32x32")
t("16x16", "16x16")


------------------------------------------------
section "game/modules/tome/dialogs/MapMenu.lua"

t(" ", " ")


------------------------------------------------
section "game/modules/tome/dialogs/ShowChatLog.lua"

t("#VIOLET#", "#VIOLET#")


------------------------------------------------
section "game/modules/tome/dialogs/ShowEquipInven.lua"

t("up", "up")


------------------------------------------------
section "game/modules/tome/dialogs/ShowStore.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/TrapsSelect.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])
t(" (%s)", " (%s)")


------------------------------------------------
section "game/modules/tome/dialogs/UseTalents.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/debug/AdvanceActor.lua"

t([[Levelup an actor.
Optionally set Stat levels, learn all talents possible, and gain points to spend on Levelup. 
The actor is backed up before changes are made.  (Use the "Restore" button to recover.)
]], [[Levelup an actor.
Optionally set Stat levels, learn all talents possible, and gain points to spend on Levelup. 
The actor is backed up before changes are made.  (Use the "Restore" button to recover.)
]])
t(" Advance to Level: ", " Advance to Level: ")
t("Restore: %s (v%d)", "Restore: %s (v%d)")
t("Restore: none", "Restore: none")
t("#LIGHT_BLUE#Restoring [%s]%s from backup version %d", "#LIGHT_BLUE#Restoring [%s]%s from backup version %d")
t("Gain points for stats, talents, and prodigies (unlimited respec)", "Gain points for stats, talents, and prodigies (unlimited respec)")
t(" Force all BASE stats to: ", " Force all BASE stats to: ")
t("", "")
t(" Force all BONUS stats to: ", " Force all BONUS stats to: ")
t("Learn Talents ", "Learn Talents ")
t("Unlock & Learn all available talents to level: ", "Unlock & Learn all available talents to level: ")
t("Ignore requirements", "Ignore requirements")
t("Force all talent mastery levels to (0.1-5.0): ", "Force all talent mastery levels to (0.1-5.0): ")
t("Unlock all talent types (slow)", "Unlock all talent types (slow)")
t("#LIGHT_BLUE#AdvanceActor inputs: %s", "#LIGHT_BLUE#AdvanceActor inputs: %s")
t("%s #GOLD#Forcing all Base Stats to %s", "%s #GOLD#Forcing all Base Stats to %s")
t("%s #GOLD#Resetting all talents_types_mastery to %s", "%s #GOLD#Resetting all talents_types_mastery to %s")
t("%s #GOLD#Unlocking All Talent Types", "%s #GOLD#Unlocking All Talent Types")
t("#LIGHT_BLUE#%s -- %s", "#LIGHT_BLUE#%s -- %s")
t("#GOLD#Checking %s Talents (%s)", "#GOLD#Checking %s Talents (%s)")
t("#LIGHT_BLUE#Talent %s learned to level %d", "#LIGHT_BLUE#Talent %s learned to level %d")
t("%s #GOLD#Forcing all Bonus Stats to %s", "%s #GOLD#Forcing all Bonus Stats to %s")
t("#ORCHID#%d prodigy point(s)#LAST#", "#ORCHID#%d prodigy point(s)#LAST#")
t("#LIGHT_BLUE#%s has %s to spend", "#LIGHT_BLUE#%s has %s to spend")
t(", and ", ", and ")


------------------------------------------------
section "game/modules/tome/dialogs/debug/AdvanceZones.lua"

t("Advance Through Zones", "Advance Through Zones")
t("Enter a comma delimited list of zones or zone tiers to clear", "Enter a comma delimited list of zones or zone tiers to clear")
t("%s:  Level %0.2f to %0.2f (#LIGHT_STEEL_BLUE#+%0.2f#LAST#)", "%s:  Level %0.2f to %0.2f (#LIGHT_STEEL_BLUE#+%0.2f#LAST#)")
t("#RED#Low value items have been dropped on the ground.#LAST#", "#RED#Low value items have been dropped on the ground.#LAST#")
t("Unable to level change to floor 1 of %s", "Unable to level change to floor 1 of %s")
t("%s is not valid for autoclear", "%s is not valid for autoclear")
t("Unable to level change to floor %d of %s", "Unable to level change to floor %d of %s")


------------------------------------------------
section "game/modules/tome/dialogs/debug/CreateItem.lua"

t([[#ORANGE# Create Object: Unable to load all objects from file %s:#GREY#
 %s]], [[#ORANGE# Create Object: Unable to load all objects from file %s:#GREY#
 %s]])
t("Generate examples (right-click refreshes) ", "Generate examples (right-click refreshes) ")
t("#CRIMSON#==Resolved Example==#LAST#", "#CRIMSON#==Resolved Example==#LAST#")
t([[#LIGHT_BLUE#Object %s could not be generated or identified. Error:
%s]], [[#LIGHT_BLUE#Object %s could not be generated or identified. Error:
%s]])
t("#GOLD#%s#LAST#", "#GOLD#%s#LAST#")
t([[Error:
%s]], [[Error:
%s]])
t("Object could not be resolved/identified.", "Object could not be resolved/identified.")
t("#LIGHT_BLUE#Could not add object to %s at (%d, %d)", "#LIGHT_BLUE#Could not add object to %s at (%d, %d)")
t("#LIGHT_BLUE#No creature to add object to at (%d, %d)", "#LIGHT_BLUE#No creature to add object to at (%d, %d)")
t("#LIGHT_BLUE#No object to create", "#LIGHT_BLUE#No object to create")
t("Place Object", "Place Object")
t("Place the object where?", "Place the object where?")
t("Inventory of %s%s", "Inventory of %s%s")
t(" #LIGHT_GREEN#(player)#LAST#", " #LIGHT_GREEN#(player)#LAST#")
t("Drop @ (%s, %s)%s", "Drop @ (%s, %s)%s")
t("#LIGHT_BLUE#Dropped %s at (%d, %d)", "#LIGHT_BLUE#Dropped %s at (%d, %d)")
t("NPC Inventory", "NPC Inventory")
t("#LIGHT_BLUE#OBJECT:#LAST# %s%s: #LIGHT_BLUE#[%s] %s {%s, slot %s} at (%s, %s)#LAST#", "#LIGHT_BLUE#OBJECT:#LAST# %s%s: #LIGHT_BLUE#[%s] %s {%s, slot %s} at (%s, %s)#LAST#")
t(", or 0 for the example item", ", or 0 for the example item")
t("#LIGHT_BLUE# Creating %d items:", "#LIGHT_BLUE# Creating %d items:")
t("Add an ego enhancement if possible?", "Add an ego enhancement if possible?")
t("Add a greater ego enhancement if possible?", "Add a greater ego enhancement if possible?")
t("#LIGHT_BLUE#Created %s", "#LIGHT_BLUE#Created %s")
t("#LIGHT_BLUE#Creating All Artifacts.", "#LIGHT_BLUE#Creating All Artifacts.")
t("#LIGHT_BLUE#%d artifacts created.", "#LIGHT_BLUE#%d artifacts created.")


------------------------------------------------
section "game/modules/tome/dialogs/debug/CreateTrap.lua"

t("#LIGHT_BLUE#Trap [%s]%s already occupies (%d, %d)", "#LIGHT_BLUE#Trap [%s]%s already occupies (%d, %d)")
t("#LIGHT_BLUE#Added %s[%s]%s at (%d, %d)", "#LIGHT_BLUE#Added %s[%s]%s at (%d, %d)")


------------------------------------------------
section "game/modules/tome/dialogs/debug/DebugMain.lua"

t("#LIGHT_BLUE#God mode OFF", "#LIGHT_BLUE#God mode OFF")
t("#LIGHT_BLUE#God mode ON", "#LIGHT_BLUE#God mode ON")
t("#LIGHT_BLUE#Demi-God mode OFF", "#LIGHT_BLUE#Demi-God mode OFF")
t("#LIGHT_BLUE#Demi-God mode ON", "#LIGHT_BLUE#Demi-God mode ON")
t("#LIGHT_BLUE#Revealing Map.", "#LIGHT_BLUE#Revealing Map.")
t("#GREY#Removing [%s] %s at (%s, %s)", "#GREY#Removing [%s] %s at (%s, %s)")
t("#GREY#Killing [%s] %s at (%s, %s)", "#GREY#Killing [%s] %s at (%s, %s)")
t("#LIGHT_BLUE#%s %d creatures.", "#LIGHT_BLUE#%s %d creatures.")


------------------------------------------------
section "game/modules/tome/dialogs/debug/Endgamify.lua"

t([[#ORANGE# Create Object: Unable to load all objects from file %s:#GREY#
 %s]], [[#ORANGE# Create Object: Unable to load all objects from file %s:#GREY#
 %s]])
t("Failed to generate %s", "Failed to generate %s")


------------------------------------------------
section "game/modules/tome/dialogs/debug/PlotTalent.lua"

t("Values plot for: %s (mastery %0.1f)", "Values plot for: %s (mastery %0.1f)")
t("TL: ", "TL: ")


------------------------------------------------
section "game/modules/tome/dialogs/debug/RandomActor.lua"

t("#LIGHT_GREEN#(From %s, line %s):#LAST#", "#LIGHT_GREEN#(From %s, line %s):#LAST#")
t([[Randomly generate actors subject to a filter and/or create random bosses according to a data table.
Filters are interpreted by game.zone:checkFilter.
#ORANGE#Boss Data:#LAST# is interpreted by game.state:createRandomBoss, game.state:applyRandomClass, and Actor.levelupClass.
Generation is performed within the _G environment (used by the Lua Console) using the current zone's #LIGHT_GREEN#npc_list#LAST#.
Press #GOLD#'F1'#LAST# for help.
Mouse over controls for an actor preview (which may be further adjusted when placed on to the level).
(Press #GOLD#'L'#LAST# to lua inspect or #GOLD#'C'#LAST# to open the character sheet.)

The #LIGHT_BLUE#Base Filter#LAST# is used to filter the actor randomly generated.]], [[Randomly generate actors subject to a filter and/or create random bosses according to a data table.
Filters are interpreted by game.zone:checkFilter.
#ORANGE#Boss Data:#LAST# is interpreted by game.state:createRandomBoss, game.state:applyRandomClass, and Actor.levelupClass.
Generation is performed within the _G environment (used by the Lua Console) using the current zone's #LIGHT_GREEN#npc_list#LAST#.
Press #GOLD#'F1'#LAST# for help.
Mouse over controls for an actor preview (which may be further adjusted when placed on to the level).
(Press #GOLD#'L'#LAST# to lua inspect or #GOLD#'C'#LAST# to open the character sheet.)

The #LIGHT_BLUE#Base Filter#LAST# is used to filter the actor randomly generated.]])
t("Current Base Actor: %s", "Current Base Actor: %s")
t("#LIGHT_BLUE# Current base actor: %s", "#LIGHT_BLUE# Current base actor: %s")
t("Default Filter", "Default Filter")
t("#LIGHT_BLUE# Reset base filter", "#LIGHT_BLUE# Reset base filter")
t("Clear", "Clear")
t("#LIGHT_BLUE# Clear base actor: %s", "#LIGHT_BLUE# Clear base actor: %s")
t("#LIGHT_BLUE#Base Filter:#LAST# ", "#LIGHT_BLUE#Base Filter:#LAST# ")
t("The #ORANGE#Boss Data#LAST# is used to transform the base actor into a random boss (which will use a random actor if needed).", "The #ORANGE#Boss Data#LAST# is used to transform the base actor into a random boss (which will use a random actor if needed).")
t("#GREY#None#LAST#", "#GREY#None#LAST#")
t("Current Boss Actor: %s", "Current Boss Actor: %s")
t("Generate", "Generate")
t("Default Data", "Default Data")
t("#LIGHT_BLUE# Reset Randboss Data", "#LIGHT_BLUE# Reset Randboss Data")
t("Place", "Place")
t("#ORANGE#Boss Data:#LAST# ", "#ORANGE#Boss Data:#LAST# ")
t("Filter and Data Help", "Filter and Data Help")
t("#GREY#No Actor to Display#LAST#", "#GREY#No Actor to Display#LAST#")
t("#LIGHT_BLUE#Inspect [%s]%s", "#LIGHT_BLUE#Inspect [%s]%s")
t("#LIGHT_BLUE#No actor to inspect", "#LIGHT_BLUE#No actor to inspect")
t("#LIGHT_BLUE#Lua Inspect [%s]%s", "#LIGHT_BLUE#Lua Inspect [%s]%s")
t("#LIGHT_BLUE#No actor to Lua inspect", "#LIGHT_BLUE#No actor to Lua inspect")
t("#LIGHT_BLUE#Bad filter for base actor: %s", "#LIGHT_BLUE#Bad filter for base actor: %s")
t("#LIGHT_BLUE#Could not generate a base actor with filter: %s", "#LIGHT_BLUE#Could not generate a base actor with filter: %s")
t([[#LIGHT_BLUE#Base actor could not be generated with filter [%s].
 Error:%s]], [[#LIGHT_BLUE#Base actor could not be generated with filter [%s].
 Error:%s]])
t("#LIGHT_BLUE#Bad data for random boss actor: %s", "#LIGHT_BLUE#Bad data for random boss actor: %s")
t("#LIGHT_BLUE#Could not generate a base actor with data: %s", "#LIGHT_BLUE#Could not generate a base actor with data: %s")
t([[#LIGHT_BLUE#ERROR: Random Boss could not be generated with data [%s].
 Error:%s]], [[#LIGHT_BLUE#ERROR: Random Boss could not be generated with data [%s].
 Error:%s]])


------------------------------------------------
section "game/modules/tome/dialogs/debug/RandomObject.lua"

t("#LIGHT_GREEN#(From %-10.60s, line: %s):#LAST#", "#LIGHT_GREEN#(From %-10.60s, line: %s):#LAST#")
t("Drops", "Drops")
t("Attach Tinker", "Attach Tinker")
t("Drop Randart (auto data)", "Drop Randart (auto data)")
t("Drop Randart", "Drop Randart")
t("The #LIGHT_GREEN#Random Filter#LAST# controls random generation of a normal object.", "The #LIGHT_GREEN#Random Filter#LAST# controls random generation of a normal object.")
t("#GREY#None#LAST#", "#GREY#None#LAST#")
t("%s: %s", "%s: %s")
t("#LIGHT_GREEN#Random Object#LAST#", "#LIGHT_GREEN#Random Object#LAST#")
t("#LIGHT_GREEN#Random Filter:#LAST# ", "#LIGHT_GREEN#Random Filter:#LAST# ")
t("The #LIGHT_BLUE#Base Filter#LAST# is to generate a base object for building a Randart.", "The #LIGHT_BLUE#Base Filter#LAST# is to generate a base object for building a Randart.")
t("#LIGHT_BLUE#Base Object#LAST#", "#LIGHT_BLUE#Base Object#LAST#")
t("Default Filter", "Default Filter")
t("Clear Object", "Clear Object")
t("#LIGHT_BLUE#Base Filter:#LAST# ", "#LIGHT_BLUE#Base Filter:#LAST# ")
t("#SALMON#Resolver selected:#LAST# ", "#SALMON#Resolver selected:#LAST# ")
t("An object resolver interprets additional filter fields to generate an object and determine where it will go.", "An object resolver interprets additional filter fields to generate an object and determine where it will go.")
t("Dropdown text", "Dropdown text")
t("No Tooltip", "No Tooltip")
t("Use this selector to choose which resolver to use", "Use this selector to choose which resolver to use")
t([[#ORANGE#Randart Data#LAST# contains parameters used to generate a Randart (interpreted by game.state:generateRandart).
The #LIGHT_BLUE#Base Object#LAST# will be used if possible.]], [[#ORANGE#Randart Data#LAST# contains parameters used to generate a Randart (interpreted by game.state:generateRandart).
The #LIGHT_BLUE#Base Object#LAST# will be used if possible.]])
t("Generate", "Generate")
t("Add Object", "Add Object")
t("Default Data", "Default Data")
t("#ORANGE#Randart Data:#LAST# ", "#ORANGE#Randart Data:#LAST# ")
t("#ORANGE#Randart#LAST#", "#ORANGE#Randart#LAST#")
t("Show #GOLD#I#LAST#nventory", "Show #GOLD#I#LAST#nventory")
t("Show #GOLD#C#LAST#haracter Sheet", "Show #GOLD#C#LAST#haracter Sheet")
t("Set working actor: [%s] %s", "Set working actor: [%s] %s")
t(" #LIGHT_GREEN#(player)#LAST#", " #LIGHT_GREEN#(player)#LAST#")
t("Set working actor: [%s] %s%s", "Set working actor: [%s] %s%s")
t("#GREY#No Tooltip to Display#LAST#", "#GREY#No Tooltip to Display#LAST#")
t("Filter/Data/Resolver Reference", "Filter/Data/Resolver Reference")
t("#LIGHT_BLUE#Lua Inspect [%s] %s", "#LIGHT_BLUE#Lua Inspect [%s] %s")
t("#LIGHT_BLUE#Nothing to Lua inspect", "#LIGHT_BLUE#Nothing to Lua inspect")
t("#LIGHT_BLUE#Bad %s: %s", "#LIGHT_BLUE#Bad %s: %s")
t("table definition", "table definition")
t("#LIGHT_BLUE# Generate Random object using resolver: %s", "#LIGHT_BLUE# Generate Random object using resolver: %s")
t(" (resolver: %s)", " (resolver: %s)")
t("#LIGHT_BLUE# New random%s object: %s", "#LIGHT_BLUE# New random%s object: %s")
t("#LIGHT_BLUE#Could not generate a random object with filter: %s", "#LIGHT_BLUE#Could not generate a random object with filter: %s")
t([[#LIGHT_BLUE#ERROR generating random object with filter [%s].
 Error: %s]], [[#LIGHT_BLUE#ERROR generating random object with filter [%s].
 Error: %s]])
t("#LIGHT_BLUE#Could not generate a base object with filter: %s", "#LIGHT_BLUE#Could not generate a base object with filter: %s")
t([[#LIGHT_BLUE#ERROR generating base object with filter [%s].
 Error:%s]], [[#LIGHT_BLUE#ERROR generating base object with filter [%s].
 Error:%s]])
t("#LIGHT_BLUE#Could not generate a Randart with data: %s", "#LIGHT_BLUE#Could not generate a Randart with data: %s")
t([[#LIGHT_BLUE#ERROR generating Randart with data [%s].
 Error:%s]], [[#LIGHT_BLUE#ERROR generating Randart with data [%s].
 Error:%s]])
t("#LIGHT_BLUE#No object to add", "#LIGHT_BLUE#No object to add")
t([[#LIGHT_BLUE#ERROR accepting object with resolver %s.
 Error:%s]], [[#LIGHT_BLUE#ERROR accepting object with resolver %s.
 Error:%s]])
t("#LIGHT_BLUE#Working Actor set to [%s]%s at (%d, %d)", "#LIGHT_BLUE#Working Actor set to [%s]%s at (%d, %d)")


------------------------------------------------
section "game/modules/tome/dialogs/debug/SummonCreature.lua"

t("#LIGHT_BLUE# no actor to place.", "#LIGHT_BLUE# no actor to place.")
t("#LIGHT_BLUE#Actor [%s]%s already occupies (%d, %d)", "#LIGHT_BLUE#Actor [%s]%s already occupies (%d, %d)")
t("#LIGHT_BLUE#Added %s[%s]%s at (%d, %d)", "#LIGHT_BLUE#Added %s[%s]%s at (%d, %d)")
t("#YELLOW#Random Actor#LAST#", "#YELLOW#Random Actor#LAST#")
t("#PINK#Test Dummy#LAST#", "#PINK#Test Dummy#LAST#")


------------------------------------------------
section "game/modules/tome/dialogs/orders/Talents.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/talents/ChronomancyContingency.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/talents/ChronomancyEmpower.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/talents/ChronomancyExtension.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/talents/ChronomancyMatrix.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/talents/ChronomancyQuicken.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/dialogs/talents/MagicalCombatArcaneCombat.lua"

t("", "")


