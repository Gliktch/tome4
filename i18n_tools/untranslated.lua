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

t("%s #GOLD#Online Store#LAST#", "%s #GOLD#Online Store#LAST#")


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
section "game/modules/tome/class/Object.lua"

t("ies", "ies")
t("y", "y")
t(".", ".")


------------------------------------------------
section "game/modules/tome/class/Player.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/class/Trap.lua"

t("#CADET_BLUE#%s %ss %s.", "#CADET_BLUE#%s %ss %s.")


------------------------------------------------
section "game/modules/tome/class/UserChatExtension.lua"

t("#CRIMSON#%s#WHITE#", "#CRIMSON#%s#WHITE#")


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
section "game/modules/tome/class/uiset/Classic.lua"

t("Linked by: ", "Linked by: ")


------------------------------------------------
section "game/modules/tome/class/uiset/ClassicPlayerDisplay.lua"

t("%s#{normal}#", "%s#{normal}#")
t([[#GOLD#%s#LAST#
%s
]], [[#GOLD#%s#LAST#
%s
]])
t([[#GOLD##{bold}#%s#{normal}##WHITE#
]], [[#GOLD##{bold}#%s#{normal}##WHITE#
]])


------------------------------------------------
section "game/modules/tome/class/uiset/Minimalist.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])
t("#VIOLET#", "#VIOLET#")


------------------------------------------------
section "game/modules/tome/data/birth/races/construct.lua"

t("", "")


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


------------------------------------------------
section "game/modules/tome/data/chats/last-hope-lost-merchant.lua"

t(".", ".")


------------------------------------------------
section "game/modules/tome/data/chats/player-inscription.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])


------------------------------------------------
section "game/modules/tome/data/chats/trap-priming.lua"

t([[#GOLD#%s#LAST#
%s]], [[#GOLD#%s#LAST#
%s]])


------------------------------------------------
section "game/modules/tome/data/general/objects/boss-artifacts-maj-eyal.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/general/objects/gem.lua"

t("..", "..")


------------------------------------------------
section "game/modules/tome/data/general/objects/rods.lua"

t("", "")


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


------------------------------------------------
section "game/modules/tome/data/quests/escort-duty.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/quests/high-peak.lua"

t("", "")


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
section "game/modules/tome/data/talents/gifts/malleable-body.lua"

t("azdadazdazdazd", "azdadazdazdazd")
t("ervevev", "ervevev")
t("zeczczeczec", "zeczczeczec")


------------------------------------------------
section "game/modules/tome/data/talents/gifts/summon-distance.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/talents/gifts/summon-melee.lua"

t("", "")


------------------------------------------------
section "game/modules/tome/data/talents/misc/inscriptions.lua"

t(" ", " ")


------------------------------------------------
section "game/modules/tome/data/talents/misc/npcs.lua"

t("", "")


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
section "game/modules/tome/dialogs/ShowLore.lua"

t("", "")


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

t("", "")
t("#LIGHT_BLUE#%s -- %s", "#LIGHT_BLUE#%s -- %s")


------------------------------------------------
section "game/modules/tome/dialogs/debug/CreateItem.lua"

t("#GOLD#%s#LAST#", "#GOLD#%s#LAST#")


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


