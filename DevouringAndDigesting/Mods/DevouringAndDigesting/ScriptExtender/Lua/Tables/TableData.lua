

CompanionsSet = {
    ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = true,
    ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = true,
    ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = true,
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = true,
    ["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = true,
    ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = true,
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = true,
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = true,
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = true,
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = true,
}


---table that stores all additional statuses that are applied when a character is stuffed under certain conditions
---@type table<string,integer>
StuffedAdditions = {
    ["SP_StuffedDebuff"] = 0,
    ["SP_MusclegutIntimidate"] = 0,
    ["SP_SC_StomachShelterStuffed"] = 0,
    ["SP_SC_StomachSanctuaryStuffed"] = 0,
    ["SP_SC_StrengthFromMany_Status"] = 0
}

---table that stores all names of digestion statuses
---@type table<string, table<integer, string>>
DigestionStatuses = {
    ['O'] = {
        [0] = "SP_Swallowed_Endo_O",
        [1] = "SP_Swallowed_Dead_O",
        [2] = "SP_Swallowed_Lethal_O",
    },
    ['A'] = {
        [0] = "SP_Swallowed_Endo_A",
        [1] = "SP_Swallowed_Dead_A",
        [2] = "SP_Swallowed_Lethal_A",
    },
    ['U'] = {
        [0] = "SP_Swallowed_Endo_U",
        [1] = "SP_Swallowed_Dead_U",
        [2] = "SP_Swallowed_Lethal_U",
    },
    ['C'] = {
        [0] = "SP_Swallowed_Endo_C",
        [1] = "SP_Swallowed_Dead_C",
        [2] = "SP_Swallowed_Lethal_C",
    },
}

---enum for digestion types
DType = {
    Any = -1,
    Endo = 0,
    Dead = 1,
    Lethal = 2,
    None = 3,
}

---enum for loci
EnumLoci = {
    ["O"] = true,
    ["A"] = true,
    ["U"] = true,
    ["C"] = true
}

-- List of gurgle sounds randomly played for stuffed preds
GurgleSounds = {
    "LOW_BlushingMermaid_HagVomitsOutDeadVanra_StomachGurgle_A",
    "LOW_BlushingMermaid_HagVomitsOutDeadVanra_StomachGurgle_B",
    "LOW_BlushingMermaid_HagVomitsOutDeadVanra_StomachGurgle_C",
    "SHA_SpiderMeatHunk_StomachGurgle_A",
    "SHA_SpiderMeatHunk_StomachGurgle_B",
}

-- ApplyStatus applies statuses for a number of seconds instead of turns.
-- Multiply the duration by this.
SecondsPerTurn = 6

-- should stats be reloaded on reset
ReloadStats = false

---for converting internal weight to be displayed
GramsPerKilo = 1000

-- Instead of hacking together half-solutions to spell modification, we can just make new copies of spells with what we want!
-- Will this create a huge bloat of files? Maybe. It'd be funny, though
ComplexCustomSpells = false

---a template for a new entry in VoreData
---@class VoreDataEntry
---@field Pred CHARACTER pred of this character
---@field Weight integer weight of this character, only for prey, 0 for preds. This is dynamically changed
---@field FixedWeight integer weight of this character, only for prey, 0 for preds. This is stored to keep the track of digestion process
---@field WeightReduction integer by how much preys weight was reduced by preds perks
---@field DisableDowned boolean if a tag that disables downed state was appled on swallow. Should be false for non-prey
---@field Unpreferred boolean if a tag that makes AI prefer attacking other targets was applied on swallow. Should be false for non-prey
---@field Digestion integer dygestion types 0 == endo, 1 == dead, 2 == lethal, 3 == none. for prey only
---@field Combat string guid of combat character is in
---@field Prey table<CHARACTER, string> value of the prey is the locus they are in
---@field Items GUIDSTRING id of stomach item that contains swallowed items in preds inventory
---@field Fat integer For weigth gain, only visually increases the size of belly
---@field AddWeight integer AddWeight is weight that does not belong to any prey and is reduced at the same rate as normal prey digestion
---@field SwallowProcess integer this is 0 when the prey is fully swallowed, for prey only
---@field Satiation integer stores satiation that decreases hunger stacks
---@field Locus string Locus where this prey is stored "O" == Oral, "A" == Anal, "U" == Unbirth, "C" = pp
---@field Swallowed string what swallowed status is appled (prey only)
---@field StuffedStacks integer number of stuffed stacks
---@field GradualDigestionTimer integer how close this pred is to doing gradual digestion
---@field SpellTargets table<CHARACTER, string> table of prey this character has cast a vore-related spell on. Used for multi-stage spells
VoreDataEntry = {
    Pred = "",
    Weight = 0,
    FixedWeight = 0,
    WeightReduction = 0,
    DisableDowned = false,
    Unpreferred = false,
    Digestion = DType.None,
    Combat = "",
    Prey = {},
    Items = "",
    Fat = 0,
    AddWeight = 0,
    SwallowProcess = 0,
    Satiation = 0,
    Locus = "",
    Swallowed = "",
    StuffedStacks = 0,
    GradualDigestionTimer = 0,
    SpellTargets = {},
}
