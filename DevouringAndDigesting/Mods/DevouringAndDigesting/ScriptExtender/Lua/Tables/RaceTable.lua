---@type SP_RaceConfigVars
RaceConfigVars = {}

local RACECONFIG_PATH = "RaceConfig.json"

---races that are considered creatures for config
---@type table<string,boolean>
SINGLE_GENDER_CREATURE = {
    ["Humanoid"] = false,
    ["Human"] = false,
    ["Elf"] = false,
    ["Elf_HighElf"] = false,
    ["Elf_WoodElf"] = false,
    ["Drow"] = false,
    ["Drow_LolthSworn"] = false,
    ["Drow_Seldarine"] = false,
    ["Dwarf"] = false,
    ["Dwarf_GoldHill"] = false,
    ["Dwarf_ShieldMountain"] = false,
    ["Duergar"] = false,
    ["HalfElf"] = false,
    ["HalfElf_High"] = false,
    ["HalfElf_Wood"] = false,
    ["HalfElf_Drow"] = false,
    ["Gnome"] = false,
    ["Gnome_Rock"] = false,
    ["Gnome_Deep"] = false,
    ["Gnome_Forest"] = false,
    ["Halfling"] = false,
    ["Halfling_Lightfoot"] = false,
    ["Halfling_Strongheart"] = false,
    ["Tiefling"] = false,
    ["Tiefling_Asmodeus"] = false,
    ["Tiefling_Mephistopeles"] = false,
    ["Tiefling_Zariel"] = false,
    ["Githyanki"] = false,
    ["Goblin"] = false,
    ["Hobgoblin"] = false,
    ["Bugbear"] = false,
    ["Gnoll"] = true,
    ["Gnoll Flind"] = true,
    ["Werewolf"] = false,
    ["Kuotoa"] = true,
    ["Undead"] = false,
    ["Skeleton"] = true,
    ["Monstrosity"] = true,
    ["Ettercap"] = true,
    ["Harpy"] = false,
    ["PhaseSpider"] = true,
    ["Giant"] = false,
    ["Ogre"] = false,
    ["Ooze"] = true,
    ["Aberration"] = true,
    ["Beholder"] = true,
    ["Mindflayer"] = true,
    ["Celestial"] = false,
    ["Elemental"] = true,
    ["Elemental_Mud"] = true,
    ["Elemental_Lava"] = true,
    ["Mephit"] = true,
    ["Azer"] = false,
    ["Fey"] = false,
    ["Redcap"] = false,
    ["Fiend"] = false,
    ["Devil"] = false,
    ["Demon"] = false,
    ["Construct"] = true,
    ["ScryingEye"] = true,
    ["Automaton"] = true,
    ["AdamantineGolem"] = true,
    ["AnimatedArmor"] = true,
    ["Plant"] = true,
    ["Myconid"] = true,
    ["Bulette"] = true,
    ["Hook Horror"] = true,
    ["Beast"] = true,
    ["Spider"] = true,
    ["Dragon"] = true,
    ["Critter"] = true,
    ["Rat"] = true,
    ["Bird"] = true,
    ["Frog"] = true,
    ["Crab"] = true,
    ["EMPTY"] = false,
    ["UndeadHighElfHidden"] = false,
    ["UndeadHighElfRevealed"] = false,
    ["MagicalSpecter"] = false,
    ["Zombie"] = true,
    ["Hellsboar"] = true,
    ["Imp"] = true,
    ["Cambion"] = false,
    ["Hag"] = false,
    ["Badger"] = true,
    ["Merregon"] = false,
    ["Wolf"] = true,
    ["Raven"] = true,
    ["Bear"] = true,
    ["Boar"] = true,
    ["Hyena"] = true,
    ["Dragonborn"] = false,
    ["Dragonborn_Black"] = false,
    ["Dragonborn_Blue"] = false,
    ["Dragonborn_Brass"] = false,
    ["Dragonborn_Bronze"] = false,
    ["Dragonborn_Copper"] = false,
    ["Dragonborn_Gold"] = false,
    ["Dragonborn_Green"] = false,
    ["Dragonborn_Red"] = false,
    ["Dragonborn_Silver"] = false,
    ["Dragonborn_White"] = false,
    ["HalfOrc"] = false,
    ["Kobold"] = true,
    ["DarkJusticiar"] = false,
    ["Blight"] = true,
    ["Meazel"] = true,
    ["Brewer"] = true,
    ["ShadarKai"] = false,
    ["Ghost"] = false,
    ["CrawlingClaw"] = true,
    ["TollCollector"] = true,
    ["Gremishka"] = true,
    ["ApostleOfMyrkul"] = true,
    ["ShadowMastiff"] = true,
    ["Phasm"] = true,
    ["FleshGolem"] = true,
    ["Meenlock"] = true,
    ["Shadow"] = true,
    ["Wraith"] = true,
    ["Cloaker"] = true,
    ["FlyingGhoul"] = true,
    ["GiantEagle"] = true,
    ["Ghoul"] = true,
    ["UndeadFace"] = true,
    ["CoinHalberd"] = true,
    ["Surgeon"] = false,
    ["OliverFriend"] = false,
    ["Mummy"] = false,
    ["Mummy Lord"] = false,
    ["Tressym"] = true,
    ["SkeletalDragon"] = true,
    ["Hollyphant"] = true,
    ["Steelwatcher"] = true,
    ["Shambling Mound"] = true,
    ["Alioramus"] = true,
    ["|Raven|"] = true,
    ["Butler"] = false,
    ["DeathKnight"] = false,
    ["Ghast"] = true,
    ["Incubus"] = false,
    ["Succubus"] = false,
    ["Vampire"] = false,
    ["VampireSpawn"] = false,
    ["Vengeful Imp"] = true,
    ["Vengeful Boar"] = true,
    ["Vengeful Cambion"] = false,
    ["Raphaelian Merregon"] = false,
    ["Redcap Pirate"] = false,
    ["Blink Dog"] = true,
    ["Aasimar"] = false,
    ["Doppelganger"] = true,
    ["Bat"] = true,
    ["Displacer Beast"] = true,
    ["Drider"] = false,
}

-- it's better to save them as integers
---chance of a race being given pred passive
---@class SP_RaceConfigVars
DEFAULT_RACE_TABLE = {
    ["Humanoid"] = 100,
    ["Human"] = 100,
    ["Elf"] = 100,
    ["Elf_HighElf"] = 100,
    ["Elf_WoodElf"] = 100,
    ["Drow"] = 100,
    ["Drow_LolthSworn"] = 100,
    ["Drow_Seldarine"] = 100,
    ["Dwarf"] = 100,
    ["Dwarf_GoldHill"] = 100,
    ["Dwarf_ShieldMountain"] = 100,
    ["Duergar"] = 100,
    ["HalfElf"] = 100,
    ["HalfElf_High"] = 100,
    ["HalfElf_Wood"] = 100,
    ["HalfElf_Drow"] = 100,
    ["Gnome"] = 100,
    ["Gnome_Rock"] = 100,
    ["Gnome_Deep"] = 100,
    ["Gnome_Forest"] = 100,
    ["Halfling"] = 100,
    ["Halfling_Lightfoot"] = 100,
    ["Halfling_Strongheart"] = 100,
    ["Tiefling"] = 100,
    ["Tiefling_Asmodeus"] = 100,
    ["Tiefling_Mephistopeles"] = 100,
    ["Tiefling_Zariel"] = 100,
    ["Githyanki"] = 100,
    ["Goblin"] = 100,
    ["Hobgoblin"] = 100,
    ["Bugbear"] = 100,
    ["Gnoll"] = 100,
    ["Gnoll Flind"] = 100,
    ["Werewolf"] = 100,
    ["Kuotoa"] = 100,
    ["Undead"] = 100,
    ["Skeleton"] = 100,
    ["Monstrosity"] = 100,
    ["Ettercap"] = 100,
    ["Harpy"] = 100,
    ["PhaseSpider"] = 100,
    ["Giant"] = 100,
    ["Ogre"] = 100,
    ["Ooze"] = 100,
    ["Aberration"] = 100,
    ["Beholder"] = 100,
    ["Mindflayer"] = 100,
    ["Celestial"] = 100,
    ["Elemental"] = 100,
    ["Elemental_Mud"] = 100,
    ["Elemental_Lava"] = 100,
    ["Mephit"] = 100,
    ["Azer"] = 100,
    ["Fey"] = 100,
    ["Redcap"] = 100,
    ["Fiend"] = 100,
    ["Devil"] = 100,
    ["Demon"] = 100,
    ["Construct"] = 100,
    ["ScryingEye"] = 100,
    ["Automaton"] = 100,
    ["AdamantineGolem"] = 100,
    ["AnimatedArmor"] = 100,
    ["Plant"] = 100,
    ["Myconid"] = 100,
    ["Bulette"] = 100,
    ["Hook Horror"] = 100,
    ["Beast"] = 100,
    ["Spider"] = 100,
    ["Dragon"] = 100,
    ["Critter"] = 100,
    ["Rat"] = 100,
    ["Bird"] = 100,
    ["Frog"] = 100,
    ["Crab"] = 100,
    ["EMPTY"] = 100,
    ["UndeadHighElfHidden"] = 100,
    ["UndeadHighElfRevealed"] = 100,
    ["MagicalSpecter"] = 100,
    ["Zombie"] = 100,
    ["Hellsboar"] = 100,
    ["Imp"] = 100,
    ["Cambion"] = 100,
    ["Hag"] = 100,
    ["Badger"] = 100,
    ["Merregon"] = 100,
    ["Wolf"] = 100,
    ["Raven"] = 100,
    ["Bear"] = 100,
    ["Boar"] = 100,
    ["Hyena"] = 100,
    ["Dragonborn"] = 100,
    ["Dragonborn_Black"] = 100,
    ["Dragonborn_Blue"] = 100,
    ["Dragonborn_Brass"] = 100,
    ["Dragonborn_Bronze"] = 100,
    ["Dragonborn_Copper"] = 100,
    ["Dragonborn_Gold"] = 100,
    ["Dragonborn_Green"] = 100,
    ["Dragonborn_Red"] = 100,
    ["Dragonborn_Silver"] = 100,
    ["Dragonborn_White"] = 100,
    ["HalfOrc"] = 100,
    ["Kobold"] = 100,
    ["DarkJusticiar"] = 100,
    ["Blight"] = 100,
    ["Meazel"] = 100,
    ["Brewer"] = 100,
    ["ShadarKai"] = 100,
    ["Ghost"] = 100,
    ["CrawlingClaw"] = 100,
    ["TollCollector"] = 100,
    ["Gremishka"] = 100,
    ["ApostleOfMyrkul"] = 100,
    ["ShadowMastiff"] = 100,
    ["Phasm"] = 100,
    ["FleshGolem"] = 100,
    ["Meenlock"] = 100,
    ["Shadow"] = 100,
    ["Wraith"] = 100,
    ["Cloaker"] = 100,
    ["FlyingGhoul"] = 100,
    ["GiantEagle"] = 100,
    ["Ghoul"] = 100,
    ["UndeadFace"] = 100,
    ["CoinHalberd"] = 100,
    ["Surgeon"] = 100,
    ["OliverFriend"] = 100,
    ["Mummy"] = 100,
    ["Mummy Lord"] = 100,
    ["Tressym"] = 100,
    ["SkeletalDragon"] = 100,
    ["Hollyphant"] = 100,
    ["Steelwatcher"] = 100,
    ["Shambling Mound"] = 100,
    ["Alioramus"] = 100,
    ["|Raven|"] = 100,
    ["Butler"] = 100,
    ["DeathKnight"] = 100,
    ["Ghast"] = 100,
    ["Incubus"] = 100,
    ["Succubus"] = 100,
    ["Vampire"] = 100,
    ["VampireSpawn"] = 100,
    ["Vengeful Imp"] = 100,
    ["Vengeful Boar"] = 100,
    ["Vengeful Cambion"] = 100,
    ["Raphaelian Merregon"] = 100,
    ["Redcap Pirate"] = 100,
    ["Blink Dog"] = 100,
    ["Aasimar"] = 100,
    ["Doppelganger"] = 100,
    ["Bat"] = 100,
    ["Displacer Beast"] = 100,
    ["Drider"] = 100,
}

EXAMPLE_RACECONFIG = {
    ["Humanoid"] = 100,
    ["Human"] = 100,
    ["Elf"] = 120,
    ["Elf_HighElf"] = 120,
    ["Elf_WoodElf"] = 130,
    ["Drow"] = 200,
    ["Drow_LolthSworn"] = 200,
    ["Drow_Seldarine"] = 150,
    ["Dwarf"] = 80,
    ["Dwarf_GoldHill"] = 80,
    ["Dwarf_ShieldMountain"] = 80,
    ["Duergar"] = 100,
    ["HalfElf"] = 110,
    ["HalfElf_High"] = 110,
    ["HalfElf_Wood"] = 110,
    ["HalfElf_Drow"] = 140,
    ["Gnome"] = 50,
    ["Gnome_Rock"] = 50,
    ["Gnome_Deep"] = 50,
    ["Gnome_Forest"] = 50,
    ["Halfling"] = 60,
    ["Halfling_Lightfoot"] = 60,
    ["Halfling_Strongheart"] = 70,
    ["Tiefling"] = 170,
    ["Tiefling_Asmodeus"] = 170,
    ["Tiefling_Mephistopeles"] = 170,
    ["Tiefling_Zariel"] = 170,
    ["Githyanki"] = 150,
    ["Goblin"] = 60,
    ["Hobgoblin"] = 200,
    ["Bugbear"] = 200,
    ["Gnoll"] = 170,
    ["Gnoll Flind"] = 250,
    ["Werewolf"] = 300,
    ["Kuotoa"] = 150,
    ["Undead"] = 100,
    ["Skeleton"] = 0,
    ["Monstrosity"] = 150,
    ["Ettercap"] = 150,
    ["Harpy"] = 250,
    ["PhaseSpider"] = 200,
    ["Giant"] = 400,
    ["Ogre"] = 400,
    ["Ooze"] = 300,
    ["Aberration"] = 200,
    ["Beholder"] = 200,
    ["Mindflayer"] = 100,
    ["Celestial"] = 150,
    ["Elemental"] = 50,
    ["Elemental_Mud"] = 50,
    ["Elemental_Lava"] = 50,
    ["Mephit"] = 20,
    ["Azer"] = 60,
    ["Fey"] = 200,
    ["Redcap"] = 60,
    ["Fiend"] = 200,
    ["Devil"] = 200,
    ["Demon"] = 300,
    ["Construct"] = 0,
    ["ScryingEye"] = 0,
    ["Automaton"] = 0,
    ["AdamantineGolem"] = 0,
    ["AnimatedArmor"] = 0,
    ["Plant"] = 0,
    ["Myconid"] = 50,
    ["Bulette"] = 300,
    ["Hook Horror"] = 150,
    ["Beast"] = 100,
    ["Spider"] = 200,
    ["Dragon"] = 10000,
    ["Critter"] = 0,
    ["Rat"] = 0,
    ["Bird"] = 0,
    ["Frog"] = 0,
    ["Crab"] = 0,
    ["EMPTY"] = 0,
    ["UndeadHighElfHidden"] = 200,
    ["UndeadHighElfRevealed"] = 200,
    ["MagicalSpecter"] = 0,
    ["Zombie"] = 50,
    ["Hellsboar"] = 70,
    ["Imp"] = 0,
    ["Cambion"] = 400,
    ["Hag"] = 300,
    ["Badger"] = 100,
    ["Merregon"] = 300,
    ["Wolf"] = 200,
    ["Raven"] = 0,
    ["Bear"] = 200,
    ["Boar"] = 50,
    ["Hyena"] = 50,
    ["Dragonborn"] = 200,
    ["Dragonborn_Black"] = 200,
    ["Dragonborn_Blue"] = 200,
    ["Dragonborn_Brass"] = 200,
    ["Dragonborn_Bronze"] = 200,
    ["Dragonborn_Copper"] = 200,
    ["Dragonborn_Gold"] = 200,
    ["Dragonborn_Green"] = 200,
    ["Dragonborn_Red"] = 200,
    ["Dragonborn_Silver"] = 200,
    ["Dragonborn_White"] = 200,
    ["HalfOrc"] = 200,
    ["Kobold"] = 50,
    ["DarkJusticiar"] = 100,
    ["Blight"] = 200,
    ["Meazel"] = 40,
    ["Brewer"] = 10000,
    ["ShadarKai"] = 100,
    ["Ghost"] = 0,
    ["CrawlingClaw"] = 0,
    ["TollCollector"] = 300,
    ["Gremishka"] = 0,
    ["ApostleOfMyrkul"] = 0,
    ["ShadowMastiff"] = 50,
    ["Phasm"] = 10000,
    ["FleshGolem"] = 150,
    ["Meenlock"] = 50,
    ["Shadow"] = 0,
    ["Wraith"] = 0,
    ["Cloaker"] = 100,
    ["FlyingGhoul"] = 100,
    ["GiantEagle"] = 150,
    ["Ghoul"] = 50,
    ["UndeadFace"] = 0,
    ["CoinHalberd"] = 0,
    ["Surgeon"] = 150,
    ["OliverFriend"] = 0,
    ["Mummy"] = 150,
    ["Mummy Lord"] = 150,
    ["Tressym"] = 0,
    ["SkeletalDragon"] = 0,
    ["Hollyphant"] = 0,
    ["Steelwatcher"] = 0,
    ["Shambling Mound"] = 400,
    ["Alioramus"] = 200,
    ["|Raven|"] = 0,
    ["Butler"] = 0,
    ["DeathKnight"] = 0,
    ["Ghast"] = 50,
    ["Incubus"] = 10000,
    ["Succubus"] = 10000,
    ["Vampire"] = 200,
    ["VampireSpawn"] = 200,
    ["Vengeful Imp"] = 0,
    ["Vengeful Boar"] = 50,
    ["Vengeful Cambion"] = 300,
    ["Raphaelian Merregon"] = 300,
    ["Redcap Pirate"] = 50,
    ["Blink Dog"] = 150,
    ["Aasimar"] = 200,
    ["Doppelganger"] = 100,
    ["Bat"] = 0,
    ["Displacer Beast"] = 200,
    ["Drider"] = 300,
}

function SP_SaveRaceWeightsConfig()
    local json = Ext.Json.Stringify(RaceWeightVars)
    Ext.IO.SaveFile(RACECONFIG_PATH, json)
    _P("Config saved: \"Script Extender\\" .. RACECONFIG_PATH .. "\".")
end

function SP_ResetRaceWeightsConfig()
    RaceWeightVars = SP_Deepcopy(DEFAULT_RACE_TABLE)
    _P("Default race weights loaded.")
end

function SP_ResetAndSaveRaceWeightsConfig()
    SP_ResetRaceWeightsConfig()
    SP_SaveRaceWeightsConfig()
end

function SP_LoadExampleRaceConfig()
    RaceWeightVars = SP_Deepcopy(EXAMPLE_RACECONFIG)
    for k, v in pairs(DEFAULT_RACE_TABLE) do
        if RaceConfigVars[k] == nil then
            RaceConfigVars[k] = v
        end
    end
    SP_SaveRaceWeightsConfig()
end

function SP_LoadRaceWeightsConfigFromFile()
    local content = Ext.IO.LoadFile(RACECONFIG_PATH)
    if content == nil then
        _P(
            "Race Weights Config not found. If this is your first time launching the game with this mod enabled, this is fine.")
            SP_ResetAndSaveRaceWeightsConfig()
        return
    end

    _P("Race Weights Config loaded: \"Script Extender\\" .. RACECONFIG_PATH .. "\".")

    RaceConfigVars = Ext.Json.Parse(content)
    if RaceConfigVars["Humanoid"] < 5 then
        SP_ResetAndSaveRaceWeightsConfig()
    end

    local needResave = false

    -- if any races are missing
    for k, v in pairs(DEFAULT_RACE_TABLE) do
        if RaceConfigVars[k] == nil then
            RaceConfigVars[k] = v
            needResave = true
        end
    end

    -- if there are any extra races in the saved file
    for k, _ in pairs(RaceConfigVars) do
        if DEFAULT_RACE_TABLE[k] == nil then
            RaceConfigVars[k] = nil
            needResave = true
        end
    end



    if needResave then
        SP_SaveRaceWeightsConfig()
    end
end
