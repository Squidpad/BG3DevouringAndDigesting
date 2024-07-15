-- unused
---@type table<string, table<string>>
local tablealltemp = {
    allCantrips = {
        "SP_Target_Lick",
        "SP_Target_BellySlam",
        "SP_Target_FlavorDisgust",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },

    all1st = {
        "SP_Target_Compress",
        "SP_Target_Tongue"
    },
    all2nd = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave"
    },
    all3rd = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth"
    },
    all4th = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth"
    },
    all5th = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch"
    },
    all6th = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    }
}

local cantripListSP = {
    SpellSniper = "64784e08-e31e-4850-a743-ecfb3fd434d7",
    BardCantrip = "61f79a30-2cac-4a7a-b5fe-50c89d307dd6",
    ClericCantrip = "2f43a103-5bf1-4534-b14f-663decc0c525",
    DruidCantrip = "b8faf12f-ca42-45c0-84f8-6951b526182a",
    SorcererCantrip = "485a68b4-c678-4888-be63-4a702efbe391",
    WarlockCantrip = "f5c4af9c-5d8d-4526-9057-94a4b243cd40",
    WizardCantrip = "3cae2e56-9871-4cef-bba6-96845ea765fa"
}

local Level1ListSP = {
    Bard = "dcb45167-86bd-4297-9b9d-c295be51af5b",
    Cleric = "269d1a3b-eed8-4131-8901-a562238f5289",
    Druid1st = "2cd54137-2fe5-4100-aad3-df64735a8145",
    FighterEK = "32aeba85-13bd-4a6f-8e06-cd4447b746d8",
    Paladin = "c6288ac5-c68b-40ed-bbdd-2ff388575831",
    Ranger = "458be063-60d4-4548-ae7d-50117fa0226f",
    RogueAT = "4b629bbb-203b-4382-9786-755bf897567f",
    Sorcerer = "92c4751f-6255-4f67-822c-a75d53830b27",
    WFiend = "4823a292-f584-4f7f-8434-6630c72e5411",
    WGoO = "65952d48-bb16-4ad7-b173-532182bf7770",
    WArchfey = "e0099b15-2599-4cba-a54b-b25ae03d6519",
    Wizard = "11f331b0-e8b7-473b-9d1f-19e8e4178d7d"
}

local Level2ListSP = {
    Bard = "7ea8f476-97a1-4256-8f10-afa76a845cce",
    Cleric = "2968a3e6-6c8a-4c2e-882a-ad295a2ad8ac",
    Druid = "92126d17-7f1a-41d2-ae6c-a8d254d2b135",
    FighterEK = "4a86443c-6a21-4b8d-b1bf-55a99e021354",
    Paladin = "c14c9564-1503-47a1-be19-98e77f22ff59",
    Ranger = "e7cfb80a-f5c2-4304-8446-9b00ea6a9814",
    RogueAT = "f9fd64f1-f417-4544-94a9-51d8876d68df",
    Sorcerer = "f80396e2-cb76-4694-b0db-5c34da61a478",
    WFiend = "835aeca7-c64a-4aaa-a25c-143aa14a5cec",
    WGoO = "fe101a94-8619-49b2-859d-a68c2c291054",
    WArchfey = "0cc2c8ab-9bbc-43a7-a66d-08e47da4c172",
    Wizard = "80c6b070-c3a6-4864-84ca-e78626784eb4"
}

local Level3ListSP = {
    Bard = "c213ca01-3767-457b-a5c8-fd4c1dd656e2",
    BardMS = "175ceed7-5a53-4f48-823c-41c4f72d18ae",
    Cleric = "21be0992-499f-4c7a-a77a-4430085e947a",
    Druid = "3156daf5-9266-41d0-b52c-5bc559a98654",
    FighterEK = "9ca503db-0e4b-4325-b1eb-e2f794a075d6",
    Paladin = "d18dec04-478f-41c3-b816-239d5cfcf2a2",
    Ranger = "9a60f649-7f82-4152-90b1-0499c5c9f3e2",
    RogueAT = "c707cc1f-e5ed-4798-909a-3652ad497d24",
    Sorcerer = "dcbaf2ae-1f45-453e-ab83-cd154f8277a4",
    WFiend = "5dec41aa-f16a-434e-b209-50c07e64e4ed",
    WGoO = "30e9b761-6be0-418e-bb28-5103c00c663b",
    WArchfey = "f18ad912-e2f4-47a9-8744-73d6a51c2941",
    Wizard = "22755771-ca11-49f4-b772-13d8b8fecd93"
}

  local Level4ListSP = {
    Bard = "75e04c40-be8f-40a5-9acc-0b5d59d5f3a6",
    Cleric = "37e9b20b-5fd1-45c5-b1c5-159c42397c83",
    Druid = "09c326c9-672c-4198-a4c0-6f07323bde27",
    FighterEK = "5798e5a8-da36-40bc-acf5-2b736cf607a2",
    Paladin = "11d0c2a0-41c6-4ec0-98fe-5d987f7e1665",
    Ranger = "7022d937-b2e4-4b6e-a3c5-e168f5c00194",
    RogueAT = "0329cc67-3e67-409c-9b22-fb510a564c98",
    Sorcerer = "5fe40622-1d3e-4cc1-8d89-e66fe51d8c5c",
    WFiend = "7ad7dbd0-751b-4bcd-8034-53bcc7bfb19d",
    WGoO = "b64e527e-1f97-4125-84f7-78376ab1440b",
    WArchfey = "c3d8a4a5-9dae-4193-8322-a5d1c5b89f47",
    Wizard = "820b1220-0385-426d-ae15-458dc8a6f5c0"
}

local Level5ListSP = {
    Bard = "bd71fffb-e4d2-4233-9a31-13d43fba36e3",
    BardMS = "858d4322-9e9f-4aa4-aada-9c68835dc6fe",
    Cleric = "b73aeea5-1ff9-4cac-b61d-b5aa6dfe31c2",
    Druid = "ff711c12-b59f-4fde-b9ea-6e5c38ec8f23",
    Paladin = "f351595c-90f7-4804-9e55-18c4d624593c",
    Ranger = "412d77e1-4aa2-4149-aa0e-c835b8c79f32",
    Sorcerer = "3276fcfe-e143-4559-b6e0-7d7aa0ffcb53",
    WFiend = "deab57bf-4eec-4085-82f7-87335bce3f5d",
    WGoO = "6d2edca9-71a7-4f3f-89f0-fccfff0bdee5",
    WArchfey = "0a9b924f-64fb-4f22-b975-5eeedc99b2fd",
    Wizard = "f781a25e-d288-43b4-bf5d-3d8d98846687"
}

local Level6ListSP = {
    Bard = "586a8796-34f4-41f5-a3ef-95738561d55d",
    Cleric = "f8ba7b05-1237-4eaa-97fa-1d3623d5862b",
    Druid = "6a4e2167-55f3-4ba8-900f-14666b293e93",
    Sorcerer = "1270a6db-980b-4e3b-bf26-2924da61dfd5",
    Warlock = "e6ccab5e-3b3b-4b34-8fa2-1058dff2b3e6",
    Wizard = "bc917f22-7f71-4a25-9a77-7d2f91a96a65"
}

local Level7ListSP = {
    Bard7thOther = "f923e058-b1d9-4b02-98ef-9daaa82a71b6",
    BardMS7thOther = "95f80109-32b7-43f8-a99a-7ee2286a993a",
    Cleric7thOther = "11862b36-c2d6-4d2f-b2d7-4af29f8fe31a",
    Druid7thOther = "29c9cf78-3bd6-47dc-88b4-2dce54710124",
    Sorcerer7thOther = "9e38e5ae-51e8-4dd4-aad5-869a571b1519",
    Warlock7thOther = "388cd3b0-914a-44b6-a828-1315323b9fd7",
    Wizard7thOther = "dff7917a-0abc-4671-b68f-c03e56212549"
  }
  
  local Level8ListSP = {
    Bard8thOther = "073c09e5-ccb9-4153-a210-001225a30cbb",
    Cleric8thOther = "a0df1e32-1c61-4017-939f-44cc7695a924",
    Druid8thOther = "bdff0cba-d631-4b83-9562-63c0187df380",
    Sorcerer8thOther = "5a8a002c-352b-44e9-8233-da7e6112f4b0",
    Warlock8thOther = "070495e1-ccf4-4c05-9add-61c5010b8204",
    Wizard8thOther = "f27a2d0a-0d6c-4c01-98a5-60081abf4807"
  }
  
  local Level9ListSP = {
    Bard9thOther = "2bbd99d0-21b4-41cc-836e-e386a96fc8e6",
    BardMS9thOther = "cd83187f-c886-45c2-be81-34083981f240",
    Cleric9thOther = "9ea2891d-f0f9-42d0-b13d-7f1a5df154c3",
    Druid9thOther = "9e388f0f-7432-4f29-bfe5-5358ebde4491",
    Sorcerer9thOther = "d58ac072-e079-410b-b167-a5e43723b59f",
    Warlock9thOther = "47766c27-e791-4e6e-9b3d-2bb379106e62",
    Wizard9thOther = "cb123d97-8809-4d71-a0cb-0ecb66177d15"
}
