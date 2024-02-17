-- Needs to be here to prevent PCs from being teleported beneath the map.
-- Maybe it is better to teleport them.
-- 1. When you click on companion's portrait, camera will move to them, which
-- will force the game to load the world around them. If they are teleported
-- outside of the map (not beneath), there is nothing to load.
-- 2. When an character dies, their body becomes lootable. Even if they are
-- invisible and detached, the player can still highlight & loot them with alt key.
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

-- Keys and Names of Digestion type statuses, keys are value of VoreData[character].Digestion
DigestionTypes = {
    [0] = "SP_Swallowed_Endo",
    [1] = "SP_Swallowed_Dead",
    [2] = "SP_Swallowed_Lethal",
    [3] = "None",
}


-- Keys and Names of Locus type statuses, keys are values of VoreData[character].Prey
VoreLoci = {
    ['O'] = "SP_Swallowed_Oral",
    ['A'] = "SP_Swallowed_Anal",
    ['U'] = "SP_Swallowed_Unbirth",
    ['C'] = "SP_Swallowed_Cock",
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

-- CharacterCreationAppearanceVisuals table for women.
---@type table
BellyTable = {
    -- prototype
    Test123 = {
        --if there are different bellies for different sexes
        Sexes = false,
        Sex = {
            --if there are different bellies for different body types
            BodyShapes = false,
            [0] = {},
        },
    },
    Human = {
        Sexes = true,
        Female = {
            BodyShapes = true,
            [0] = {
                [420] = "14388c37-34ab-4963-b61e-19cea0a90e39",
                [300] = "b10b965b-9620-48c2-9037-0556fd23d472",
                [220] = "78fc1e05-ee83-4e6c-b14f-6f116e875b03",
                [135] = "4a404594-e28d-4f47-b1c2-2ef593961e33",
                [70] = "fafef7ab-087f-4362-9436-3e63ef7bcd95",
                [45] = "65a6eeac-9a14-4937-92b8-5e50bb960074",
                [30] = "5660e004-e2af-4f3a-ae76-375408cb78c3",
                [15] = "5b04165d-2ec9-47f9-beff-0660640fc602",
            },
            [1] = {
                [420] = "73aae7c2-49ef-4cac-b1b9-b3cfa6a4a31a",
                [300] = "02c9846c-200d-47cb-b381-1ceeb4280774",
                [220] = "e250ffe9-a94c-44b4-a225-f8cf61ad430d",
                [135] = "4e698e03-94b8-4526-9fa5-5feb1f78c3b0",
                [85] = "9950ba83-28ea-4680-9905-a070d6eabfe7",
                [55] = "c2042e11-0626-440b-bee0-bb1d631fd979",
                [35] = "4741a71a-8884-4d3d-929d-708e350953bb",
                [15] = "4bfa882a-3bef-49b8-9e8a-21198a2dbee5",
            },
        },
        Male = {
            BodyShapes = true,
            [0] = {
                [135] = "5d54a45f-38b7-459e-b892-e51fc32c6f87",
                [70] = "5c21b0f0-2869-4f15-acad-f6ff02713a03",
                [45] = "018d3e5d-ee2d-4cce-8c02-fa09c9f1412c",
                [30] = "8351fdde-c5a4-4377-9074-352ee80655c5",
                [15] = "70494217-271e-4516-ada4-7cabc7b90689",
            },
            [1] = {
                [135] = "90752779-7c70-4a6f-bebf-e8afe4639ac6",
                [85] = "1fe0747f-cb0b-4c8f-9ea9-3b970d02f28f",
                [55] = "2eb4c2e1-8df1-4634-9476-e70b631e1acc",
                [35] = "e2e6a8fa-152a-4eef-b483-f08525b6a25d",
                [15] = "695daec1-1dab-4aee-a3b3-d7851c12bae3",
            },
        },
    },
    Gith = {
        Sexes = true,
        Female = {
            BodyShapes = false,
            [0] = {
                [420] = "14388c37-34ab-4963-b61e-19cea0a90e39",
                [300] = "b10b965b-9620-48c2-9037-0556fd23d472",
                [220] = "78fc1e05-ee83-4e6c-b14f-6f116e875b03",
                [135] = "4a404594-e28d-4f47-b1c2-2ef593961e33",
                [70] = "fafef7ab-087f-4362-9436-3e63ef7bcd95",
                [45] = "65a6eeac-9a14-4937-92b8-5e50bb960074",
                [30] = "5660e004-e2af-4f3a-ae76-375408cb78c3",
                [15] = "5b04165d-2ec9-47f9-beff-0660640fc602",
            },
        },
        Male = {
            BodyShapes = true,
            [0] = {
                [135] = "5d54a45f-38b7-459e-b892-e51fc32c6f87",
                [70] = "5c21b0f0-2869-4f15-acad-f6ff02713a03",
                [45] = "018d3e5d-ee2d-4cce-8c02-fa09c9f1412c",
                [30] = "8351fdde-c5a4-4377-9074-352ee80655c5",
                [15] = "70494217-271e-4516-ada4-7cabc7b90689",
            },
        },
    },
    Orc = {
        Sexes = true,
        Female = {
            BodyShapes = false,
            [0] = {
                [420] = "73aae7c2-49ef-4cac-b1b9-b3cfa6a4a31a",
                [300] = "02c9846c-200d-47cb-b381-1ceeb4280774",
                [220] = "e250ffe9-a94c-44b4-a225-f8cf61ad430d",
                [135] = "4e698e03-94b8-4526-9fa5-5feb1f78c3b0",
                [85] = "9950ba83-28ea-4680-9905-a070d6eabfe7",
                [55] = "c2042e11-0626-440b-bee0-bb1d631fd979",
                [35] = "4741a71a-8884-4d3d-929d-708e350953bb",
                [15] = "4bfa882a-3bef-49b8-9e8a-21198a2dbee5",
            },
        },
        Male = {
            BodyShapes = true,
            [0] = {
                [135] = "90752779-7c70-4a6f-bebf-e8afe4639ac6",
                [85] = "1fe0747f-cb0b-4c8f-9ea9-3b970d02f28f",
                [55] = "2eb4c2e1-8df1-4634-9476-e70b631e1acc",
                [35] = "e2e6a8fa-152a-4eef-b483-f08525b6a25d",
                [15] = "695daec1-1dab-4aee-a3b3-d7851c12bae3",
            },
        },
    },
}


---all bellies (used for removing viusal overrides)
AllBellies = {
    ["14388c37-34ab-4963-b61e-19cea0a90e39"] = true,
    ["b10b965b-9620-48c2-9037-0556fd23d472"] = true,
    ["78fc1e05-ee83-4e6c-b14f-6f116e875b03"] = true,
    ["4a404594-e28d-4f47-b1c2-2ef593961e33"] = true,
    ["fafef7ab-087f-4362-9436-3e63ef7bcd95"] = true,
    ["65a6eeac-9a14-4937-92b8-5e50bb960074"] = true,
    ["5660e004-e2af-4f3a-ae76-375408cb78c3"] = true,
    ["5b04165d-2ec9-47f9-beff-0660640fc602"] = true,
    ["73aae7c2-49ef-4cac-b1b9-b3cfa6a4a31a"] = true,
    ["02c9846c-200d-47cb-b381-1ceeb4280774"] = true,
    ["e250ffe9-a94c-44b4-a225-f8cf61ad430d"] = true,
    ["4e698e03-94b8-4526-9fa5-5feb1f78c3b0"] = true,
    ["9950ba83-28ea-4680-9905-a070d6eabfe7"] = true,
    ["c2042e11-0626-440b-bee0-bb1d631fd979"] = true,
    ["4741a71a-8884-4d3d-929d-708e350953bb"] = true,
    ["4bfa882a-3bef-49b8-9e8a-21198a2dbee5"] = true,
    ["5d54a45f-38b7-459e-b892-e51fc32c6f87"] = true,
    ["5c21b0f0-2869-4f15-acad-f6ff02713a03"] = true,
    ["018d3e5d-ee2d-4cce-8c02-fa09c9f1412c"] = true,
    ["8351fdde-c5a4-4377-9074-352ee80655c5"] = true,
    ["70494217-271e-4516-ada4-7cabc7b90689"] = true,
    ["90752779-7c70-4a6f-bebf-e8afe4639ac6"] = true,
    ["1fe0747f-cb0b-4c8f-9ea9-3b970d02f28f"] = true,
    ["2eb4c2e1-8df1-4634-9476-e70b631e1acc"] = true,
    ["e2e6a8fa-152a-4eef-b483-f08525b6a25d"] = true,
    ["695daec1-1dab-4aee-a3b3-d7851c12bae3"] = true,
}

-- Instead of hacking together half-solutions to spell modification, we can just make new copies of spells with what we want!
-- Will this create a huge bloat of files? Maybe. It'd be funny, though
ComplexCustomSpells = true

---a template for a new entry in VoreData
---@class VoreDataEntry
---@field Pred CHARACTER pred of this character
---@field Weight integer weight of this character, only for prey, 0 for preds. This is dynamically changed
---@field FixedWeight integer weight of this character, only for prey, 0 for preds. This is stored to keep the track of digestion process
---@field WeightReduction integer by how much preys weight was reduced by preds perks
---@field DisableDowned boolean if a tag that disables downed state was appled on swallow. Should be false for non-prey
---@field Digestion integer dygestion types 0 == endo, 1 == dead, 2 == lethal, 3 == none. for prey only
---@field DigestItems boolean if the items are being digested
---@field Combat string guid of combat character is in
---@field Prey table<CHARACTER, string> value of the prey is the locus they are in
---@field Items GUIDSTRING id of stomach item that contains swallowed items in preds inventory
---@field Fat integer For weigth gain, only visually increases the size of belly
---@field AddWeight integer AddWeight is reduced at the same rate as normal prey digestion, while Fat uses a separate value
---@field SwallowProcess integer this is 0 when the prey is fully swallowed, for prey only
---@field Satiation integer stores satiation that decreases hunger stacks
---@field Locus string Locus where this prey is stored "O" == Oral, "A" == Anal, "U" == Unbirth, "C" = pp
---@field Swallowed string what swallowed status is appled (prey only)
---@field Stuffed string what stuffed status is appled (pred only)
---@field StuffedStacks integer number of stuffed stacks
---@field SpellTargets table<CHARACTER, string> table of prey this character has cast a vore-related spell on
VoreDataEntry = {
    Pred = "",
    Weight = 0,
    FixedWeight = 0,
    WeightReduction = 0,
    DisableDowned = false,
    Digestion = 3,
    DigestItems = false,
    Combat = "",
    Prey = {},
    Items = "",
    Fat = 0,
    AddWeight = 0,
    SwallowProcess = 0,
    Satiation = 0,
    Locus = "",
    Swallowed = "",
    Stuffed = "",
    StuffedStacks = 0,
    SpellTargets = {},
}
