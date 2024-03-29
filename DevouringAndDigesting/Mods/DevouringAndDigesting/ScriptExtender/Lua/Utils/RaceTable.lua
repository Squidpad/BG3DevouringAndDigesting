-- I am too lazy to create a save system for these tables (like for config)

---races that are considered creatures for config
---@type table<string, boolean>
SINGLE_GENDER_CREATURE = {
    ["Humanoid"] = false,
    ["Human"] = false,
    ["Elf"] = false,
    ["HighElf"] = false,
    ["WoodElf"] = false,
    ["Drow"] = false,
    ["LolthDrow"] = false,
    ["SeldarineDrow"] = false,
    ["Dwarf"] = false,
    ["HillDwarf"] = false,
    ["MountainDwarf"] = false,
    ["Duergar"] = false,
    ["HalfElf"] = false,
    ["HighHalfElf"] = false,
    ["WoodHalfElf"] = false,
    ["HalfDrow"] = false,
    ["Gnome"] = false,
    ["RockGnome"] = false,
    ["DeepGnome"] = false,
    ["ForestGnome"] = false,
    ["Halfling"] = false,
    ["LightfootHalfling"] = false,
    ["StoutHalfling"] = false,
    ["Tiefling"] = false,
    ["AsmodeusTiefling"] = false,
    ["MephistophelesTiefling"] = false,
    ["ZarielTiefling"] = false,
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
    ["BlackDragonborn"] = false,
    ["BlueDragonborn"] = false,
    ["BrassDragonborn"] = false,
    ["BronzeDragonborn"] = false,
    ["CopperDragonborn"] = false,
    ["GoldDragonborn"] = false,
    ["GreenDragonborn"] = false,
    ["RedDragonborn"] = false,
    ["SilverDragonborn"] = false,
    ["WhiteDragonborn"] = false,
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
}

---chance of a race being given pred passive
---@type table<string, integer>
RACE_TABLE = {
    ["Humanoid"] = 100,
    ["Human"] = 100,
    ["Elf"] = 120,
    ["HighElf"] = 120,
    ["WoodElf"] = 130,
    ["Drow"] = 200,
    ["LolthDrow"] = 200,
    ["SeldarineDrow"] = 170,
    ["Dwarf"] = 30,
    ["HillDwarf"] = 30,
    ["MountainDwarf"] = 30,
    ["Duergar"] = 40,
    ["HalfElf"] = 110,
    ["HighHalfElf"] = 110,
    ["WoodHalfElf"] = 110,
    ["HalfDrow"] = 140,
    ["Gnome"] = 20,
    ["RockGnome"] = 20,
    ["DeepGnome"] = 20,
    ["ForestGnome"] = 20,
    ["Halfling"] = 20,
    ["LightfootHalfling"] = 20,
    ["StoutHalfling"] = 20,
    ["Tiefling"] = 170,
    ["AsmodeusTiefling"] = 170,
    ["MephistophelesTiefling"] = 170,
    ["ZarielTiefling"] = 170,
    ["Githyanki"] = 130,
    ["Goblin"] = 30,
    ["Hobgoblin"] = 220,
    ["Bugbear"] = 200,
    ["Gnoll"] = 180,
    ["Gnoll Flind"] = 300,
    ["Werewolf"] = 300,
    ["Kuotoa"] = 70,
    ["Undead"] = 40,
    ["Skeleton"] = 0,
    ["Monstrosity"] = 150,
    ["Ettercap"] = 150,
    ["Harpy"] = 250,
    ["PhaseSpider"] = 200,
    ["Giant"] = 400,
    ["Ogre"] = 400,
    ["Ooze"] = 200,
    ["Aberration"] = 200,
    ["Beholder"] = 300,
    ["Mindflayer"] = 120,
    ["Celestial"] = 150,
    ["Elemental"] = 50,
    ["Elemental_Mud"] = 50,
    ["Elemental_Lava"] = 50,
    ["Mephit"] = 20,
    ["Azer"] = 40,
    ["Fey"] = 130,
    ["Redcap"] = 30,
    ["Fiend"] = 150,
    ["Devil"] = 300,
    ["Demon"] = 150,
    ["Construct"] = 0,
    ["ScryingEye"] = 0,
    ["Automaton"] = 0,
    ["AdamantineGolem"] = 100,
    ["AnimatedArmor"] = 0,
    ["Plant"] = 0,
    ["Myconid"] = 60,
    ["Bulette"] = 300,
    ["Hook Horror"] = 170,
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
    ["Zombie"] = 70,
    ["Hellsboar"] = 70,
    ["Imp"] = 0,
    ["Cambion"] = 400,
    ["Hag"] = 300,
    ["Badger"] = 100,
    ["Merregon"] = 250,
    ["Wolf"] = 20,
    ["Raven"] = 0,
    ["Bear"] = 180,
    ["Boar"] = 40,
    ["Hyena"] = 40,
    ["Dragonborn"] = 180,
    ["BlackDragonborn"] = 180,
    ["BlueDragonborn"] = 180,
    ["BrassDragonborn"] = 180,
    ["BronzeDragonborn"] = 180,
    ["CopperDragonborn"] = 180,
    ["GoldDragonborn"] = 180,
    ["GreenDragonborn"] = 180,
    ["RedDragonborn"] = 180,
    ["SilverDragonborn"] = 180,
    ["WhiteDragonborn"] = 180,
    ["HalfOrc"] = 180,
    ["Kobold"] = 50,
    ["DarkJusticiar"] = 70,
    ["Blight"] = 0,
    ["Meazel"] = 0,
    ["Brewer"] = 10000,
    ["ShadarKai"] = 120,
    ["Ghost"] = 0,
    ["CrawlingClaw"] = 0,
    ["TollCollector"] = 200,
    ["Gremishka"] = 0,
    ["ApostleOfMyrkul"] = 0,
    ["ShadowMastiff"] = 30,
    ["Phasm"] = 10000,
    ["FleshGolem"] = 250,
    ["Meenlock"] = 60,
    ["Shadow"] = 40,
    ["Wraith"] = 40,
    ["Cloaker"] = 100,
    ["FlyingGhoul"] = 70,
    ["GiantEagle"] = 70,
    ["Ghoul"] = 70,
    ["UndeadFace"] = 0,
    ["CoinHalberd"] = 0,
    ["Surgeon"] = 0,
    ["OliverFriend"] = 0,
    ["Mummy"] = 0,
    ["Mummy Lord"] = 0,
    ["Tressym"] = 0,
    ["SkeletalDragon"] = 0,
    ["Hollyphant"] = 0,
    ["Steelwatcher"] = 0,
    ["Shambling Mound"] = 400,
    ["Alioramus"] = 250,
    ["Butler"] = 0,
    ["DeathKnight"] = 0,
    ["Ghast"] = 30,
    ["Incubus"] = 400,
    ["Succubus"] = 400,
    ["Vampire"] = 250,
    ["VampireSpawn"] = 250,
    ["Vengeful Imp"] = 0,
    ["Vengeful Boar"] = 70,
    ["Vengeful Cambion"] = 400,
    ["Raphaelian Merregon"] = 400,
    ["Redcap Pirate"] = 30,
    ["Blink Dog"] = 20,
    ["Aasimar"] = 400,
    ["Doppelganger"] = 100,
    ["Bat"] = 0,
    ["Displacer Beast"] = 400,
}

---these npcs will always become preds
---@type table<string, boolean>
PRED_NPC_TABLE = {
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = true,
    ["S_GLO_Nightsong_6c55edb0-901b-4ba4-b9e8-3475a8392d9b"] = true,
    ["LOW_Slayer_Orin_ced6bfeb-8f6f-47d0-943f-77833f643318"] = true,
    ["S_GLO_Orin_bf24e0ec-a3a6-4905-bd2d-45dc8edf8101"] = true,
    ["Ooze_Jelly_Phasm_41a2b951-d2cf-48fe-bdd8-945fdec653b2"] = true,
}