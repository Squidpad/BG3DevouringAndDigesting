

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
        -- 2 == medium size
        DefaultSize = 2,
        Sex = {
            --if there are different bellies for different body types
            BodyShapes = false,
            [0] = {},
        },
    },
    Human = {
        Sexes = true,
        DefaultSize = 2,
        Female = {
            BodyShapes = true,
            [0] = {
                [16088] = "b05f207e-3c56-4dd7-af44-7b99cb55a285",
                [14657] = "47406605-fb05-4865-b906-b5f38ee5a668",
                [13313] = "b878e803-6a75-4f36-b43e-07f6261b432c",
                [12040] = "2cc36b45-11bf-438a-a242-70dae67e76aa",
                [10855] = "545185bc-c385-406a-8e58-da77d0b63d36",
                [9750] = "7b359948-cbe3-4af8-8533-8418205c76ec",
                [8720] = "d19124ac-1686-4358-87f4-c1b4854f7fd5",
                [7769] = "86f6c9bb-81cb-439d-9858-7558dc6276da",
                [6889] = "6bf5bfa4-70fe-49a8-bd69-59a88d6128f1",
                [6080] = "e5a1fae8-dc02-4e18-8250-8866d7453236",
                [5336] = "d7d6a745-537f-4a51-8f5a-508a6b7f2882",
                [4654] = "3ed0d483-c8bb-40f5-9e3f-ee28560add0b",
                [4033] = "ac0f1fdd-149f-4215-b5d4-741eaaaf3bdf",
                [3465] = "90d668e0-0239-4f3a-847f-9e9c475e4a14",
                [2952] = "ddc64738-f0a3-4fdb-abab-017292d32e93",
                [2493] = "cd2ed4a2-4349-4a3f-88c2-74e7f28206b4",
                [2085] = "26e95f64-a832-4da8-8cfd-a19e1f7aef55",
                [1722] = "3a7688b5-1375-483c-b8ec-af4b50a01c94",
                [1404] = "a4681c3b-0f4d-41b4-b3b9-f33230424925",
                [1127] = "c57803ff-5b9c-4c8d-96dc-b3953de9b119",
                [887] = "68b2b26c-7ca1-4f25-8b8f-616f889081f5",
                [683] = "dd02adba-a82b-46db-8b17-cd871679f5f8",
                [521] = "51ea5c15-25ed-4143-bc62-bce1f7e0e4de",
                [380] = "16d64654-9b25-45db-96d0-e2f960eb96ee",
                [203] = "8fd33edf-9ad6-4261-b36b-6ec969dc897a",
                [116] = "fd19b688-da29-4efd-b412-882bb59d26e3",
                [55] = "04379aaa-56c1-47d7-85d2-08ff77626863",
                [24] = "da3d9b65-deb4-4032-bcb8-96595daf426d",
                [11] = "a8a7157c-6a94-4610-bf0b-2709d8fce640",
                [3] = "301edefc-fe08-447a-8b19-a7813020dec9",

            },
            [1] = {
                [16088] = "bb388903-88fb-4ff8-90d6-cec96ec67a64",
                [14657] = "71c0d81e-2952-482d-8d21-5a3f36945a86",
                [13313] = "d5ceebe6-4c05-4ad5-97f8-9bf55573e643",
                [12040] = "14a8d2d7-a2dc-4485-89cf-017d832d80f5",
                [10855] = "c4e407f7-9032-42d3-94f6-44be78894c39",
                [9750] = "97f16d4b-a09e-49c8-8f20-07fc7fbe02a1",
                [8720] = "01d6c230-b8cc-4f33-99a1-7c2be6b686ff",
                [7769] = "123f6453-6456-46d5-9942-ad046db9a17e",
                [6889] = "af25e117-7f46-44fc-8ccb-526f3e517236",
                [6080] = "fc348463-3ff8-432f-9d94-80e7e6dab519",
                [5336] = "ac69790c-620a-4549-801d-24ccba8441ce",
                [4654] = "873552de-8a50-448c-87ac-a41c63b8b325",
                [4033] = "b515d849-0f0d-46ed-8665-dc3ac66662c7",
                [3465] = "9fb82846-9a83-4342-9df2-331833bd828d",
                [2952] = "4a64c451-d852-4f5f-ae23-019ac407364e",
                [2493] = "160c3420-30c3-4a86-9535-ca8c4776534f",
                [2085] = "8336e027-4709-42e4-a937-642b012aaea7",
                [1722] = "6648e0fa-ad21-4faf-990d-7ebfa328ba12",
                [1404] = "8b45d574-3793-4d7e-9bf6-e5c10f178891",
                [1127] = "fb6d56fa-450f-47dd-80ca-0f418fda5b98",
                [887] = "de89ecc9-92a1-457d-b596-28c3a800bc68",
                [683] = "22b93fc7-858d-4064-b7f7-a343c9f1496f",
                [521] = "d0a52a57-6592-4ca1-bd18-c710ba63ab44",
                [380] = "6b5d7b46-ff99-4449-8b8a-53ea3786714a",
                [203] = "3d4a531b-f100-4565-b574-f9c41e173cf7",
                [116] = "6a557a46-2f00-4f3c-abbc-aabd52ac9a9d",
                [55] = "68b7a432-d41a-47f6-8504-037e2b917396",
                [24] = "7c9c3016-dc4c-402b-a8c5-929c0783ebfd",
                [11] = "bd813f43-e8e0-4788-a50d-39719f7f7720",
                [3] = "54dbad45-69ed-4fe6-bb14-d979fb7f8754",
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
        DefaultSize = 2,
        Female = {
            BodyShapes = false,
            [0] = {
                [16088] = "b05f207e-3c56-4dd7-af44-7b99cb55a285",
                [14657] = "47406605-fb05-4865-b906-b5f38ee5a668",
                [13313] = "b878e803-6a75-4f36-b43e-07f6261b432c",
                [12040] = "2cc36b45-11bf-438a-a242-70dae67e76aa",
                [10855] = "545185bc-c385-406a-8e58-da77d0b63d36",
                [9750] = "7b359948-cbe3-4af8-8533-8418205c76ec",
                [8720] = "d19124ac-1686-4358-87f4-c1b4854f7fd5",
                [7769] = "86f6c9bb-81cb-439d-9858-7558dc6276da",
                [6889] = "6bf5bfa4-70fe-49a8-bd69-59a88d6128f1",
                [6080] = "e5a1fae8-dc02-4e18-8250-8866d7453236",
                [5336] = "d7d6a745-537f-4a51-8f5a-508a6b7f2882",
                [4654] = "3ed0d483-c8bb-40f5-9e3f-ee28560add0b",
                [4033] = "ac0f1fdd-149f-4215-b5d4-741eaaaf3bdf",
                [3465] = "90d668e0-0239-4f3a-847f-9e9c475e4a14",
                [2952] = "ddc64738-f0a3-4fdb-abab-017292d32e93",
                [2493] = "cd2ed4a2-4349-4a3f-88c2-74e7f28206b4",
                [2085] = "26e95f64-a832-4da8-8cfd-a19e1f7aef55",
                [1722] = "3a7688b5-1375-483c-b8ec-af4b50a01c94",
                [1404] = "a4681c3b-0f4d-41b4-b3b9-f33230424925",
                [1127] = "c57803ff-5b9c-4c8d-96dc-b3953de9b119",
                [887] = "68b2b26c-7ca1-4f25-8b8f-616f889081f5",
                [683] = "dd02adba-a82b-46db-8b17-cd871679f5f8",
                [521] = "51ea5c15-25ed-4143-bc62-bce1f7e0e4de",
                [380] = "16d64654-9b25-45db-96d0-e2f960eb96ee",
                [203] = "8fd33edf-9ad6-4261-b36b-6ec969dc897a",
                [116] = "fd19b688-da29-4efd-b412-882bb59d26e3",
                [55] = "04379aaa-56c1-47d7-85d2-08ff77626863",
                [24] = "da3d9b65-deb4-4032-bcb8-96595daf426d",
                [11] = "a8a7157c-6a94-4610-bf0b-2709d8fce640",
                [3] = "301edefc-fe08-447a-8b19-a7813020dec9",
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
        DefaultSize = 2,
        Female = {
            BodyShapes = false,
            [0] = {
                [16088] = "bb388903-88fb-4ff8-90d6-cec96ec67a64",
                [14657] = "71c0d81e-2952-482d-8d21-5a3f36945a86",
                [13313] = "d5ceebe6-4c05-4ad5-97f8-9bf55573e643",
                [12040] = "14a8d2d7-a2dc-4485-89cf-017d832d80f5",
                [10855] = "c4e407f7-9032-42d3-94f6-44be78894c39",
                [9750] = "97f16d4b-a09e-49c8-8f20-07fc7fbe02a1",
                [8720] = "01d6c230-b8cc-4f33-99a1-7c2be6b686ff",
                [7769] = "123f6453-6456-46d5-9942-ad046db9a17e",
                [6889] = "af25e117-7f46-44fc-8ccb-526f3e517236",
                [6080] = "fc348463-3ff8-432f-9d94-80e7e6dab519",
                [5336] = "ac69790c-620a-4549-801d-24ccba8441ce",
                [4654] = "873552de-8a50-448c-87ac-a41c63b8b325",
                [4033] = "b515d849-0f0d-46ed-8665-dc3ac66662c7",
                [3465] = "9fb82846-9a83-4342-9df2-331833bd828d",
                [2952] = "4a64c451-d852-4f5f-ae23-019ac407364e",
                [2493] = "160c3420-30c3-4a86-9535-ca8c4776534f",
                [2085] = "8336e027-4709-42e4-a937-642b012aaea7",
                [1722] = "6648e0fa-ad21-4faf-990d-7ebfa328ba12",
                [1404] = "8b45d574-3793-4d7e-9bf6-e5c10f178891",
                [1127] = "fb6d56fa-450f-47dd-80ca-0f418fda5b98",
                [887] = "de89ecc9-92a1-457d-b596-28c3a800bc68",
                [683] = "22b93fc7-858d-4064-b7f7-a343c9f1496f",
                [521] = "d0a52a57-6592-4ca1-bd18-c710ba63ab44",
                [380] = "6b5d7b46-ff99-4449-8b8a-53ea3786714a",
                [203] = "3d4a531b-f100-4565-b574-f9c41e173cf7",
                [116] = "6a557a46-2f00-4f3c-abbc-aabd52ac9a9d",
                [55] = "68b7a432-d41a-47f6-8504-037e2b917396",
                [24] = "7c9c3016-dc4c-402b-a8c5-929c0783ebfd",
                [11] = "bd813f43-e8e0-4788-a50d-39719f7f7720",
                [3] = "54dbad45-69ed-4fe6-bb14-d979fb7f8754",
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

local FemaleBellies = {
    ["b05f207e-3c56-4dd7-af44-7b99cb55a285"] = true,
    ["47406605-fb05-4865-b906-b5f38ee5a668"] = true,
    ["b878e803-6a75-4f36-b43e-07f6261b432c"] = true,
    ["2cc36b45-11bf-438a-a242-70dae67e76aa"] = true,
    ["545185bc-c385-406a-8e58-da77d0b63d36"] = true,
    ["7b359948-cbe3-4af8-8533-8418205c76ec"] = true,
    ["d19124ac-1686-4358-87f4-c1b4854f7fd5"] = true,
    ["86f6c9bb-81cb-439d-9858-7558dc6276da"] = true,
    ["6bf5bfa4-70fe-49a8-bd69-59a88d6128f1"] = true,
    ["e5a1fae8-dc02-4e18-8250-8866d7453236"] = true,
    ["d7d6a745-537f-4a51-8f5a-508a6b7f2882"] = true,
    ["3ed0d483-c8bb-40f5-9e3f-ee28560add0b"] = true,
    ["ac0f1fdd-149f-4215-b5d4-741eaaaf3bdf"] = true,
    ["90d668e0-0239-4f3a-847f-9e9c475e4a14"] = true,
    ["ddc64738-f0a3-4fdb-abab-017292d32e93"] = true,
    ["cd2ed4a2-4349-4a3f-88c2-74e7f28206b4"] = true,
    ["26e95f64-a832-4da8-8cfd-a19e1f7aef55"] = true,
    ["3a7688b5-1375-483c-b8ec-af4b50a01c94"] = true,
    ["a4681c3b-0f4d-41b4-b3b9-f33230424925"] = true,
    ["c57803ff-5b9c-4c8d-96dc-b3953de9b119"] = true,
    ["68b2b26c-7ca1-4f25-8b8f-616f889081f5"] = true,
    ["dd02adba-a82b-46db-8b17-cd871679f5f8"] = true,
    ["51ea5c15-25ed-4143-bc62-bce1f7e0e4de"] = true,
    ["16d64654-9b25-45db-96d0-e2f960eb96ee"] = true,
    ["8fd33edf-9ad6-4261-b36b-6ec969dc897a"] = true,
    ["fd19b688-da29-4efd-b412-882bb59d26e3"] = true,
    ["04379aaa-56c1-47d7-85d2-08ff77626863"] = true,
    ["da3d9b65-deb4-4032-bcb8-96595daf426d"] = true,
    ["a8a7157c-6a94-4610-bf0b-2709d8fce640"] = true,
    ["301edefc-fe08-447a-8b19-a7813020dec9"] = true,
}

local FemaleStrongBellies = {
    ["bb388903-88fb-4ff8-90d6-cec96ec67a64"] = true,
    ["71c0d81e-2952-482d-8d21-5a3f36945a86"] = true,
    ["d5ceebe6-4c05-4ad5-97f8-9bf55573e643"] = true,
    ["14a8d2d7-a2dc-4485-89cf-017d832d80f5"] = true,
    ["c4e407f7-9032-42d3-94f6-44be78894c39"] = true,
    ["97f16d4b-a09e-49c8-8f20-07fc7fbe02a1"] = true,
    ["01d6c230-b8cc-4f33-99a1-7c2be6b686ff"] = true,
    ["123f6453-6456-46d5-9942-ad046db9a17e"] = true,
    ["af25e117-7f46-44fc-8ccb-526f3e517236"] = true,
    ["fc348463-3ff8-432f-9d94-80e7e6dab519"] = true,
    ["ac69790c-620a-4549-801d-24ccba8441ce"] = true,
    ["873552de-8a50-448c-87ac-a41c63b8b325"] = true,
    ["b515d849-0f0d-46ed-8665-dc3ac66662c7"] = true,
    ["9fb82846-9a83-4342-9df2-331833bd828d"] = true,
    ["4a64c451-d852-4f5f-ae23-019ac407364e"] = true,
    ["160c3420-30c3-4a86-9535-ca8c4776534f"] = true,
    ["8336e027-4709-42e4-a937-642b012aaea7"] = true,
    ["6648e0fa-ad21-4faf-990d-7ebfa328ba12"] = true,
    ["8b45d574-3793-4d7e-9bf6-e5c10f178891"] = true,
    ["fb6d56fa-450f-47dd-80ca-0f418fda5b98"] = true,
    ["de89ecc9-92a1-457d-b596-28c3a800bc68"] = true,
    ["22b93fc7-858d-4064-b7f7-a343c9f1496f"] = true,
    ["d0a52a57-6592-4ca1-bd18-c710ba63ab44"] = true,
    ["6b5d7b46-ff99-4449-8b8a-53ea3786714a"] = true,
    ["3d4a531b-f100-4565-b574-f9c41e173cf7"] = true,
    ["6a557a46-2f00-4f3c-abbc-aabd52ac9a9d"] = true,
    ["68b7a432-d41a-47f6-8504-037e2b917396"] = true,
    ["7c9c3016-dc4c-402b-a8c5-929c0783ebfd"] = true,
    ["bd813f43-e8e0-4788-a50d-39719f7f7720"] = true,
    ["54dbad45-69ed-4fe6-bb14-d979fb7f8754"] = true,
}

local MaleBellies = {
    ["5d54a45f-38b7-459e-b892-e51fc32c6f87"] = true,
    ["5c21b0f0-2869-4f15-acad-f6ff02713a03"] = true,
    ["018d3e5d-ee2d-4cce-8c02-fa09c9f1412c"] = true,
    ["8351fdde-c5a4-4377-9074-352ee80655c5"] = true,
    ["70494217-271e-4516-ada4-7cabc7b90689"] = true,
}

local MaleStrongBellies = {
    ["90752779-7c70-4a6f-bebf-e8afe4639ac6"] = true,
    ["1fe0747f-cb0b-4c8f-9ea9-3b970d02f28f"] = true,
    ["2eb4c2e1-8df1-4634-9476-e70b631e1acc"] = true,
    ["e2e6a8fa-152a-4eef-b483-f08525b6a25d"] = true,
    ["695daec1-1dab-4aee-a3b3-d7851c12bae3"] = true,
}

---all bellies (used for removing viusal overrides)
AllBellies = SP_TableConcatMany({FemaleBellies, FemaleStrongBellies, MaleBellies, MaleStrongBellies})

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
