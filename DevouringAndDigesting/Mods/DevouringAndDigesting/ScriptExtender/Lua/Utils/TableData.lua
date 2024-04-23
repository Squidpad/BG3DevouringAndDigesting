

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
    Endo = 0,
    Dead = 1,
    Lethal = 2,
    None = 3,
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

---for converting internal weight to be displayed
GramsPerKilo = 1000

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

                [3] = "14d58243-66c8-4c23-8701-010648cbbf06",
                [13] = "caa54fef-4ae5-4ad4-af8d-384b07c53eff",
                [31] = "43138beb-a6b1-485c-83f2-da31cd775f07",
                [71] = "8a614dba-c815-411e-8605-4d80b2caa389",
                [150] = "fe9093c4-235f-4357-a06b-7f8cb43eaa14",
                [261] = "8dbde3e5-79ba-4ab3-9367-7c9af41ed293",
                [490] = "502edf57-9616-4d2d-a00b-2b61a2fe7a25",
                [673] = "f1eacf5d-333a-4c83-9a10-dfaeefac4576",
                [882] = "f4758a20-102b-4675-bf5d-c2e4b0e73e40",
                [1145] = "434fa34f-86c6-4c99-8ac0-2b38de3afe5b",
                [1454] = "1d2516b6-f217-4ea7-b60b-32e6d895856f",
                [1811] = "e39f5e80-d5da-4ff6-8536-2c16a6a28d05",
                [2222] = "c0ae4b77-456a-4cdd-bde4-7927b5dc3bce",
                [2690] = "824f90cc-5f9d-4bbe-8589-7e8c012efd7a",
                [3217] = "d2352c74-e648-4503-8bde-9615ebc99789",
                [3808] = "fc3b79c3-66bf-4f87-9b9d-3b2db9e25184",
                [4471] = "2eff82bb-2f94-4a32-8cd9-a9064acae451",
                [5204] = "f66519db-1768-4039-9743-c69e25160bef",
                [6005] = "da37884e-5400-49cb-a724-e2e4cb3c302c",
                [6886] = "399156ef-c054-4a83-8fa3-db7a9beb4232",
                [7845] = "69b69a43-7086-46ec-a197-6fd931da89c3",
                [8889] = "166daea8-b473-4c15-819b-04bfa9f849b2",
                [10024] = "544c034e-6025-4f52-b6b8-dfe97a11ebf8",
                [11251] = "61929cbe-a63e-453c-86c6-01b3930bce89",
                [12581] = "83d235af-c53a-4706-a412-e44993029681",
                [14006] = "a91b0083-9940-42bb-b17d-9c8f2d9e2ff0",
                [15536] = "5791c922-827a-46f6-a428-fb7ba20f6a0e",
                [17177] = "7d9408fc-5626-4bbe-a6cc-57f5e2ee701a",
                [18912] = "ae738c8f-f60a-43ba-9e3f-eb317e689e23",
                [20758] = "b520bf0e-eb86-4836-86e2-9e8830cb2915",
            },
            [1] = {
                [3] = "ae6e74b4-1ce9-4071-b4e3-976ded2b81f5",
                [13] = "d8e78b98-18f0-4fb8-bd78-b36b8a7fee1d",
                [31] = "ce3586ad-50b7-44eb-b326-7effe1b97022",
                [71] = "0f9eb800-5108-4487-a0c4-d0a6b4382f4c",
                [150] = "f6af0ec7-ec43-4259-a79b-f9bd65efe4f1",
                [261] = "bd21191f-d45c-47f1-91b0-87e77b775b9e",
                [490] = "98f3811d-4d2d-4d2d-b90e-8b2103ed38ea",
                [673] = "9da787d4-175f-44d3-8a19-4c40dc239f18",
                [882] = "1f5a18ce-a3a7-4ed9-9473-0c449ca16f38",
                [1145] = "d24ff2bc-e099-4ab1-b8ba-2eb5a1821562",
                [1454] = "3058f5d6-5a32-46ca-b89b-4905036ac0d0",
                [1811] = "e9972b90-76d7-4eba-a49b-ab3146e2eb06",
                [2222] = "9264f9fe-69ba-42c8-a3c2-fe0f8dbc2184",
                [2690] = "19415f55-3009-4d5b-bbf2-9640dc52151a",
                [3217] = "6f8abb71-d7d7-49a6-951c-cd264c1796fb",
                [3808] = "3ae24528-7f96-4273-818e-b37eae6da5bc",
                [4471] = "fc17583f-c202-4cbb-abed-cf4ff99235a6",
                [5204] = "24c67b70-893d-41c3-b768-8ed12ee8301a",
                [6005] = "c4278a43-1ac5-4380-a14d-d767e8200ae3",
                [6886] = "a0a18761-d890-42ef-83a4-c8c58f0db943",
                [7845] = "925fa8d6-bcae-4483-8561-5db67fc44555",
                [8889] = "651c0529-dc0e-40ff-97b2-7c1af20bc37e",
                [10024] = "6da98aeb-4316-4686-8b37-030b78851da6",
                [11251] = "055ea464-a2c6-4229-8f4a-5832e023f7b4",
                [12581] = "0830b66e-662d-46a9-9ca6-00f0c11bad32",
                [14006] = "10b38257-1efd-42b4-afe2-0afbd613902d",
                [15536] = "792e4641-0efd-4137-9cc2-32ce96e824cf",
                [17177] = "3d194286-2895-433a-a4a4-a561cce2feeb",
                [18912] = "4b6452bc-0a75-457b-9b7a-2b71f45bd033",
                [20758] = "09486420-2ec2-4b55-a792-0d17df96c86c",
            },
        },
        Male = {
            BodyShapes = true,
            [0] = {
                [15] = "5d54a45f-38b7-459e-b892-e51fc32c6f87",
                [30] = "5c21b0f0-2869-4f15-acad-f6ff02713a03",
                [45] = "018d3e5d-ee2d-4cce-8c02-fa09c9f1412c",
                [70] = "8351fdde-c5a4-4377-9074-352ee80655c5",
                [135] = "70494217-271e-4516-ada4-7cabc7b90689",
            },
            [1] = {
                [15] = "90752779-7c70-4a6f-bebf-e8afe4639ac6",
                [35] = "1fe0747f-cb0b-4c8f-9ea9-3b970d02f28f",
                [55] = "2eb4c2e1-8df1-4634-9476-e70b631e1acc",
                [85] = "e2e6a8fa-152a-4eef-b483-f08525b6a25d",
                [135] = "695daec1-1dab-4aee-a3b3-d7851c12bae3",
            },
        },
    },
    Gith = {
        Sexes = true,
        DefaultSize = 2,
        Female = {
            BodyShapes = false,
            [0] = {

                [3] = "14d58243-66c8-4c23-8701-010648cbbf06",
                [13] = "caa54fef-4ae5-4ad4-af8d-384b07c53eff",
                [31] = "43138beb-a6b1-485c-83f2-da31cd775f07",
                [71] = "8a614dba-c815-411e-8605-4d80b2caa389",
                [150] = "fe9093c4-235f-4357-a06b-7f8cb43eaa14",
                [261] = "8dbde3e5-79ba-4ab3-9367-7c9af41ed293",
                [490] = "502edf57-9616-4d2d-a00b-2b61a2fe7a25",
                [673] = "f1eacf5d-333a-4c83-9a10-dfaeefac4576",
                [882] = "f4758a20-102b-4675-bf5d-c2e4b0e73e40",
                [1145] = "434fa34f-86c6-4c99-8ac0-2b38de3afe5b",
                [1454] = "1d2516b6-f217-4ea7-b60b-32e6d895856f",
                [1811] = "e39f5e80-d5da-4ff6-8536-2c16a6a28d05",
                [2222] = "c0ae4b77-456a-4cdd-bde4-7927b5dc3bce",
                [2690] = "824f90cc-5f9d-4bbe-8589-7e8c012efd7a",
                [3217] = "d2352c74-e648-4503-8bde-9615ebc99789",
                [3808] = "fc3b79c3-66bf-4f87-9b9d-3b2db9e25184",
                [4471] = "2eff82bb-2f94-4a32-8cd9-a9064acae451",
                [5204] = "f66519db-1768-4039-9743-c69e25160bef",
                [6005] = "da37884e-5400-49cb-a724-e2e4cb3c302c",
                [6886] = "399156ef-c054-4a83-8fa3-db7a9beb4232",
                [7845] = "69b69a43-7086-46ec-a197-6fd931da89c3",
                [8889] = "166daea8-b473-4c15-819b-04bfa9f849b2",
                [10024] = "544c034e-6025-4f52-b6b8-dfe97a11ebf8",
                [11251] = "61929cbe-a63e-453c-86c6-01b3930bce89",
                [12581] = "83d235af-c53a-4706-a412-e44993029681",
                [14006] = "a91b0083-9940-42bb-b17d-9c8f2d9e2ff0",
                [15536] = "5791c922-827a-46f6-a428-fb7ba20f6a0e",
                [17177] = "7d9408fc-5626-4bbe-a6cc-57f5e2ee701a",
                [18912] = "ae738c8f-f60a-43ba-9e3f-eb317e689e23",
                [20758] = "b520bf0e-eb86-4836-86e2-9e8830cb2915",
            },
        },
        Male = {
            BodyShapes = false,
            [0] = {
                [15] = "5d54a45f-38b7-459e-b892-e51fc32c6f87",
                [30] = "5c21b0f0-2869-4f15-acad-f6ff02713a03",
                [45] = "018d3e5d-ee2d-4cce-8c02-fa09c9f1412c",
                [70] = "8351fdde-c5a4-4377-9074-352ee80655c5",
                [135] = "70494217-271e-4516-ada4-7cabc7b90689",
            },
        },
    },
    Orc = {
        Sexes = true,
        DefaultSize = 2,
        Female = {
            BodyShapes = false,
            [0] = {

                [3] = "ae6e74b4-1ce9-4071-b4e3-976ded2b81f5",
                [13] = "d8e78b98-18f0-4fb8-bd78-b36b8a7fee1d",
                [31] = "ce3586ad-50b7-44eb-b326-7effe1b97022",
                [71] = "0f9eb800-5108-4487-a0c4-d0a6b4382f4c",
                [150] = "f6af0ec7-ec43-4259-a79b-f9bd65efe4f1",
                [261] = "bd21191f-d45c-47f1-91b0-87e77b775b9e",
                [490] = "98f3811d-4d2d-4d2d-b90e-8b2103ed38ea",
                [673] = "9da787d4-175f-44d3-8a19-4c40dc239f18",
                [882] = "1f5a18ce-a3a7-4ed9-9473-0c449ca16f38",
                [1145] = "d24ff2bc-e099-4ab1-b8ba-2eb5a1821562",
                [1454] = "3058f5d6-5a32-46ca-b89b-4905036ac0d0",
                [1811] = "e9972b90-76d7-4eba-a49b-ab3146e2eb06",
                [2222] = "9264f9fe-69ba-42c8-a3c2-fe0f8dbc2184",
                [2690] = "19415f55-3009-4d5b-bbf2-9640dc52151a",
                [3217] = "6f8abb71-d7d7-49a6-951c-cd264c1796fb",
                [3808] = "3ae24528-7f96-4273-818e-b37eae6da5bc",
                [4471] = "fc17583f-c202-4cbb-abed-cf4ff99235a6",
                [5204] = "24c67b70-893d-41c3-b768-8ed12ee8301a",
                [6005] = "c4278a43-1ac5-4380-a14d-d767e8200ae3",
                [6886] = "a0a18761-d890-42ef-83a4-c8c58f0db943",
                [7845] = "925fa8d6-bcae-4483-8561-5db67fc44555",
                [8889] = "651c0529-dc0e-40ff-97b2-7c1af20bc37e",
                [10024] = "6da98aeb-4316-4686-8b37-030b78851da6",
                [11251] = "055ea464-a2c6-4229-8f4a-5832e023f7b4",
                [12581] = "0830b66e-662d-46a9-9ca6-00f0c11bad32",
                [14006] = "10b38257-1efd-42b4-afe2-0afbd613902d",
                [15536] = "792e4641-0efd-4137-9cc2-32ce96e824cf",
                [17177] = "3d194286-2895-433a-a4a4-a561cce2feeb",
                [18912] = "4b6452bc-0a75-457b-9b7a-2b71f45bd033",
                [20758] = "09486420-2ec2-4b55-a792-0d17df96c86c",
            },
        },
        Male = {
            BodyShapes = false,
            [0] = {
                [15] = "90752779-7c70-4a6f-bebf-e8afe4639ac6",
                [35] = "1fe0747f-cb0b-4c8f-9ea9-3b970d02f28f",
                [55] = "2eb4c2e1-8df1-4634-9476-e70b631e1acc",
                [85] = "e2e6a8fa-152a-4eef-b483-f08525b6a25d",
                [135] = "695daec1-1dab-4aee-a3b3-d7851c12bae3",
            },
        },
    },
}
---all bellies (used for removing viusal overrides)
AllBellies = {
    -- female regular
    ["14d58243-66c8-4c23-8701-010648cbbf06"] = true,
    ["caa54fef-4ae5-4ad4-af8d-384b07c53eff"] = true,
    ["43138beb-a6b1-485c-83f2-da31cd775f07"] = true,
    ["8a614dba-c815-411e-8605-4d80b2caa389"] = true,
    ["fe9093c4-235f-4357-a06b-7f8cb43eaa14"] = true,
    ["8dbde3e5-79ba-4ab3-9367-7c9af41ed293"] = true,
    ["502edf57-9616-4d2d-a00b-2b61a2fe7a25"] = true,
    ["f1eacf5d-333a-4c83-9a10-dfaeefac4576"] = true,
    ["f4758a20-102b-4675-bf5d-c2e4b0e73e40"] = true,
    ["434fa34f-86c6-4c99-8ac0-2b38de3afe5b"] = true,
    ["1d2516b6-f217-4ea7-b60b-32e6d895856f"] = true,
    ["e39f5e80-d5da-4ff6-8536-2c16a6a28d05"] = true,
    ["c0ae4b77-456a-4cdd-bde4-7927b5dc3bce"] = true,
    ["824f90cc-5f9d-4bbe-8589-7e8c012efd7a"] = true,
    ["d2352c74-e648-4503-8bde-9615ebc99789"] = true,
    ["fc3b79c3-66bf-4f87-9b9d-3b2db9e25184"] = true,
    ["2eff82bb-2f94-4a32-8cd9-a9064acae451"] = true,
    ["f66519db-1768-4039-9743-c69e25160bef"] = true,
    ["da37884e-5400-49cb-a724-e2e4cb3c302c"] = true,
    ["399156ef-c054-4a83-8fa3-db7a9beb4232"] = true,
    ["69b69a43-7086-46ec-a197-6fd931da89c3"] = true,
    ["166daea8-b473-4c15-819b-04bfa9f849b2"] = true,
    ["544c034e-6025-4f52-b6b8-dfe97a11ebf8"] = true,
    ["61929cbe-a63e-453c-86c6-01b3930bce89"] = true,
    ["83d235af-c53a-4706-a412-e44993029681"] = true,
    ["a91b0083-9940-42bb-b17d-9c8f2d9e2ff0"] = true,
    ["5791c922-827a-46f6-a428-fb7ba20f6a0e"] = true,
    ["7d9408fc-5626-4bbe-a6cc-57f5e2ee701a"] = true,
    ["ae738c8f-f60a-43ba-9e3f-eb317e689e23"] = true,
    ["b520bf0e-eb86-4836-86e2-9e8830cb2915"] = true,
    -- female strong
    ["ae6e74b4-1ce9-4071-b4e3-976ded2b81f5"] = true,
    ["d8e78b98-18f0-4fb8-bd78-b36b8a7fee1d"] = true,
    ["ce3586ad-50b7-44eb-b326-7effe1b97022"] = true,
    ["0f9eb800-5108-4487-a0c4-d0a6b4382f4c"] = true,
    ["f6af0ec7-ec43-4259-a79b-f9bd65efe4f1"] = true,
    ["bd21191f-d45c-47f1-91b0-87e77b775b9e"] = true,
    ["98f3811d-4d2d-4d2d-b90e-8b2103ed38ea"] = true,
    ["9da787d4-175f-44d3-8a19-4c40dc239f18"] = true,
    ["1f5a18ce-a3a7-4ed9-9473-0c449ca16f38"] = true,
    ["d24ff2bc-e099-4ab1-b8ba-2eb5a1821562"] = true,
    ["3058f5d6-5a32-46ca-b89b-4905036ac0d0"] = true,
    ["e9972b90-76d7-4eba-a49b-ab3146e2eb06"] = true,
    ["9264f9fe-69ba-42c8-a3c2-fe0f8dbc2184"] = true,
    ["19415f55-3009-4d5b-bbf2-9640dc52151a"] = true,
    ["6f8abb71-d7d7-49a6-951c-cd264c1796fb"] = true,
    ["3ae24528-7f96-4273-818e-b37eae6da5bc"] = true,
    ["fc17583f-c202-4cbb-abed-cf4ff99235a6"] = true,
    ["24c67b70-893d-41c3-b768-8ed12ee8301a"] = true,
    ["c4278a43-1ac5-4380-a14d-d767e8200ae3"] = true,
    ["a0a18761-d890-42ef-83a4-c8c58f0db943"] = true,
    ["925fa8d6-bcae-4483-8561-5db67fc44555"] = true,
    ["651c0529-dc0e-40ff-97b2-7c1af20bc37e"] = true,
    ["6da98aeb-4316-4686-8b37-030b78851da6"] = true,
    ["055ea464-a2c6-4229-8f4a-5832e023f7b4"] = true,
    ["0830b66e-662d-46a9-9ca6-00f0c11bad32"] = true,
    ["10b38257-1efd-42b4-afe2-0afbd613902d"] = true,
    ["792e4641-0efd-4137-9cc2-32ce96e824cf"] = true,
    ["3d194286-2895-433a-a4a4-a561cce2feeb"] = true,
    ["4b6452bc-0a75-457b-9b7a-2b71f45bd033"] = true,
    ["09486420-2ec2-4b55-a792-0d17df96c86c"] = true,
    -- Male regular
    ["5d54a45f-38b7-459e-b892-e51fc32c6f87"] = true,
    ["5c21b0f0-2869-4f15-acad-f6ff02713a03"] = true,
    ["018d3e5d-ee2d-4cce-8c02-fa09c9f1412c"] = true,
    ["8351fdde-c5a4-4377-9074-352ee80655c5"] = true,
    ["70494217-271e-4516-ada4-7cabc7b90689"] = true,
    -- Male strong
    ["90752779-7c70-4a6f-bebf-e8afe4639ac6"] = true,
    ["1fe0747f-cb0b-4c8f-9ea9-3b970d02f28f"] = true,
    ["2eb4c2e1-8df1-4634-9476-e70b631e1acc"] = true,
    ["e2e6a8fa-152a-4eef-b483-f08525b6a25d"] = true,
    ["695daec1-1dab-4aee-a3b3-d7851c12bae3"] = true,
}

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
---@field StuffedStacks integer number of stuffed stacks
---@field SpellTargets table<CHARACTER, string> table of prey this character has cast a vore-related spell on
VoreDataEntry = {
    Pred = "",
    Weight = 0,
    FixedWeight = 0,
    WeightReduction = 0,
    DisableDowned = false,
    Digestion = DType.None,
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
    StuffedStacks = 0,
    SpellTargets = {},
}
