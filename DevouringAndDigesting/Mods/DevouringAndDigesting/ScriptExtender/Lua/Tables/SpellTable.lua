---@type table<string, table<string>>
local SpellTable = {
    -- feats
    spellSniper = {
        "SP_Target_Lick",
        "SP_Target_BellySlam",
        "SP_Target_FlavorDisgust",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },

    --bard
    bardCantrips = {
        "SP_Target_Lick",
        "SP_Target_BellySlam",
        "SP_Target_FlavorDisgust",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },
    bard1 = {
        "SP_Target_Compress"
    },
    bard2 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave"
    },
    bard3 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single"
    },
    bard4 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single"
    },
    bard5 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single",
        "SP_Zone_SuperBelch"
    },
    bard6 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All"
    },
    bard7 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All"
    },
    bard8 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All"
    },
    bard9 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All"
    },
    bardMS3 = {
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
    bardMS5 = {
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
    bardMS7 = {
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
    },
    bardMS9 = {
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
    },

    -- cleric
    clericCantrips = {
        "SP_Target_Lick",
        "SP_Target_BellySlam",
        "SP_Target_FlavorDisgust",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },
    cleric1 = {
        "SP_Target_Compress"
    },
    cleric2 = {
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2"
    },
    cleric3 = {
        "SP_Target_HealingAcid",
        "SP_Target_Rebirth"
    },
    cleric4 = {

    },
    cleric5 = {
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch"
    },
    cleric6 = {
        "SP_Target_Churn"
    },
    cleric7 = {
    },
    cleric8 = {
    },
    cleric9 = {
    },

    -- druid 
    druidCantrips = {
        "SP_Target_Lick",
        "SP_Target_BellySlam",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },
    druid1 = {
        "SP_Target_Tongue"
    },
    druid2 = {
        "SP_Target_Ravenous",
        "SP_Target_Acidify_2",
        "SP_Target_Heave"
    },
    druid3 = {
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_Rebirth"
    },
    druid4 = {
    },
    druid5 = {
        "SP_Zone_SuperBelch"
    },
    druid6 = {
        "SP_Target_Churn"
    },
    druid7 = {
    },
    druid8 = {
    },
    druid9 = {
    },

    -- eldritch knight
    fighterEK1 = {
        "SP_Target_Tongue"
    },
    fighterEK2 = {
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue"
    },
    fighterEK3 = {
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_StillPrey_Single"
    },
    fighterEK4 = {
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_StillPrey_Single"
    },

    -- paladin
    paladin1 = {
        "SP_Target_Tongue"
    },
    paladin2 = {
        "SP_Target_Tongue",
        "SP_Target_Rescue",
        "SP_Target_Heave"
    },
    paladin3 = {
        "SP_Target_Tongue",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth"
    },
    paladin4 = {
        "SP_Target_Tongue",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth"
    },
    paladin5 = {
        "SP_Target_Tongue",
        "SP_Target_Rescue",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch"
    },

    -- ranger
    ranger1 = {
        "SP_Target_Compress",
        "SP_Target_Tongue"
    },
    ranger2 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Acidify_2",
        "SP_Target_Heave"
    },
    ranger3 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single"
    },
    ranger4 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single"
    },
    ranger5 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_HealingAcid",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch"
    },

    -- arcane trickster
    rogueAT1 = {
        "SP_Target_Compress"
    },
    rogueAT2 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Acidify_2",
        "SP_Target_Heave"
    },
    rogueAT3 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single"
    },
    rogueAT4 = {
        "SP_Target_Compress",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_StillPrey_Single"
    },

    -- sorcerer
    sorcererCantrips = {
        "SP_Target_Lick",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },
    sorcerer1 = {
        "SP_Target_Compress",
        "SP_Target_Tongue"
    },
    sorcerer2 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2"
    },
    sorcerer3 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_LeechingAcid"
    },
    sorcerer4 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_LeechingAcid"
    },
    sorcerer5 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_LeechingAcid",
        "SP_Zone_SuperBelch"
    },
    sorcerer6 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_LeechingAcid",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_Churn"
    },
    sorcerer7 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_LeechingAcid",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_Churn"
    },
    sorcerer8 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_LeechingAcid",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_Churn"
    },
    sorcerer9 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_LeechingAcid",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_Churn"
    },

    -- warlock
    warlockCantrips = {
        "SP_Target_Lick",
        "SP_Target_BellySlam",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },
    warlock1 = {
        "SP_Target_Compress",
        "SP_Target_Tongue"
    },
    warlock2 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave"
    },
    warlock3 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth"
    },
    warlock4 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth"
    },
    warlock5 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch"
    },
    warlock6 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    },
    warlock7 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    },
    warlock8 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    },
    warlock9 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Rebirth",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    },

    -- wizard
    wizardCantrips = {
        "SP_Target_Lick",
        "SP_Target_BellySlam",
        "SP_Target_FlavorDisgust",
        "SP_Zone_ResistAcid",
        "SP_Zone_Burping"
    },
    wizard1 = {
        "SP_Target_Compress",
        "SP_Target_Tongue"
    },
    wizard2 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave"
    },
    wizard3 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single"
    },
    wizard4 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single"
    },
    wizard5 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch"
    },
    wizard6 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    },
    wizard7 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    },
    wizard8 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    },
    wizard9 = {
        "SP_Target_Compress",
        "SP_Target_Tongue",
        "SP_Target_Unburden",
        "SP_Target_Ravenous",
        "SP_Target_Bellyport",
        "SP_Target_Rescue",
        "SP_Target_Acidify_2",
        "SP_Target_Heave",
        "SP_Target_LeechingAcid",
        "SP_Target_StillPrey_Single",
        "SP_Target_Bottomless",
        "SP_Zone_SuperBelch",
        "SP_Target_PowerWordSwallow",
        "SP_Target_StillPrey_All",
        "SP_Target_Churn"
    }
}


---@type table<string, table<GUIDSTRING>>
local ProgTable = {
    -- feats
    spellSniper = {
        "64784e08-e31e-4850-a743-ecfb3fd434d7"
    },

    --bard
    bardCantrips = {
        "61f79a30-2cac-4a7a-b5fe-50c89d307dd6"
    },
    bard1 = {
        "dcb45167-86bd-4297-9b9d-c295be51af5b"
    },
    bard2 = {
        "7ea8f476-97a1-4256-8f10-afa76a845cce"
    },
    bard3 = {
        "c213ca01-3767-457b-a5c8-fd4c1dd656e2"
    },
    bard4 = {
        "75e04c40-be8f-40a5-9acc-0b5d59d5f3a6"
    },
    bard5 = {
        "bd71fffb-e4d2-4233-9a31-13d43fba36e3"
    },
    bard6 = {
        "586a8796-34f4-41f5-a3ef-95738561d55d"
    },
    bard7 = {
        "f923e058-b1d9-4b02-98ef-9daaa82a71b6"
    },
    bard8 = {
        "073c09e5-ccb9-4153-a210-001225a30cbb"
    },
    bard9 = {
        "2bbd99d0-21b4-41cc-836e-e386a96fc8e6"
    },
    bardMS3 = {
        "175ceed7-5a53-4f48-823c-41c4f72d18ae"
    },
    bardMS5 = {
        "858d4322-9e9f-4aa4-aada-9c68835dc6fe"
    },
    bardMS7 = {
        "95f80109-32b7-43f8-a99a-7ee2286a993a"
    },
    bardMS9 = {
        "cd83187f-c886-45c2-be81-34083981f240"
    },

    -- cleric
    clericCantrips = {
        "2f43a103-5bf1-4534-b14f-663decc0c525"
    },
    cleric1 = {
        "269d1a3b-eed8-4131-8901-a562238f5289"
    },
    cleric2 = {
        "2968a3e6-6c8a-4c2e-882a-ad295a2ad8ac"
    },
    cleric3 = {
        "21be0992-499f-4c7a-a77a-4430085e947a"
    },
    cleric4 = {
        "37e9b20b-5fd1-45c5-b1c5-159c42397c83"
    },
    cleric5 = {
        "b73aeea5-1ff9-4cac-b61d-b5aa6dfe31c2"
    },
    cleric6 = {
        "f8ba7b05-1237-4eaa-97fa-1d3623d5862b"
    },
    cleric7 = {
        "11862b36-c2d6-4d2f-b2d7-4af29f8fe31a"
    },
    cleric8 = {
        "a0df1e32-1c61-4017-939f-44cc7695a924"
    },
    cleric9 = {
        "9ea2891d-f0f9-42d0-b13d-7f1a5df154c3"
    },

    -- druid 
    druidCantrips = {
        "b8faf12f-ca42-45c0-84f8-6951b526182a"
    },
    druid1 = {
        "2cd54137-2fe5-4100-aad3-df64735a8145"
    },
    druid2 = {
        "92126d17-7f1a-41d2-ae6c-a8d254d2b135"
    },
    druid3 = {
        "3156daf5-9266-41d0-b52c-5bc559a98654"
    },
    druid4 = {
        "09c326c9-672c-4198-a4c0-6f07323bde27"
    },
    druid5 = {
        "ff711c12-b59f-4fde-b9ea-6e5c38ec8f23"
    },
    druid6 = {
        "6a4e2167-55f3-4ba8-900f-14666b293e93"
    },
    druid7 = {
        "29c9cf78-3bd6-47dc-88b4-2dce54710124"
    },
    druid8 = {
        "bdff0cba-d631-4b83-9562-63c0187df380"
    },
    druid9 = {
        "9e388f0f-7432-4f29-bfe5-5358ebde4491"
    },

    -- eldritch knight
    fighterEK1 = {
        "32aeba85-13bd-4a6f-8e06-cd4447b746d8"
    },
    fighterEK2 = {
        "4a86443c-6a21-4b8d-b1bf-55a99e021354"
    },
    fighterEK3 = {
        "9ca503db-0e4b-4325-b1eb-e2f794a075d6"
    },
    fighterEK4 = {
        "5798e5a8-da36-40bc-acf5-2b736cf607a2"
    },

    -- paladin
    paladin1 = {
        "c6288ac5-c68b-40ed-bbdd-2ff388575831"
    },
    paladin2 = {
        "c14c9564-1503-47a1-be19-98e77f22ff59"
    },
    paladin3 = {
        "d18dec04-478f-41c3-b816-239d5cfcf2a2"
    },
    paladin4 = {
        "11d0c2a0-41c6-4ec0-98fe-5d987f7e1665"
    },
    paladin5 = {
        "f351595c-90f7-4804-9e55-18c4d624593c"
    },

    -- ranger
    ranger1 = {
        "458be063-60d4-4548-ae7d-50117fa0226f"
    },
    ranger2 = {
        "e7cfb80a-f5c2-4304-8446-9b00ea6a9814"
    },
    ranger3 = {
        "9a60f649-7f82-4152-90b1-0499c5c9f3e2"
    },
    ranger4 = {
        "7022d937-b2e4-4b6e-a3c5-e168f5c00194"
    },
    ranger5 = {
        "412d77e1-4aa2-4149-aa0e-c835b8c79f32"
    },

    -- arcane trickster
    rogueAT1 = {
        "4b629bbb-203b-4382-9786-755bf897567f"
    },
    rogueAT2 = {
        "f9fd64f1-f417-4544-94a9-51d8876d68df"
    },
    rogueAT3 = {
        "c707cc1f-e5ed-4798-909a-3652ad497d24"
    },
    rogueAT4 = {
        "0329cc67-3e67-409c-9b22-fb510a564c98"
    },

    -- sorcerer
    sorcererCantrips = {
        "485a68b4-c678-4888-be63-4a702efbe391"
    },
    sorcerer1 = {
        "92c4751f-6255-4f67-822c-a75d53830b27"
    },
    sorcerer2 = {
        "f80396e2-cb76-4694-b0db-5c34da61a478"
    },
    sorcerer3 = {
        "dcbaf2ae-1f45-453e-ab83-cd154f8277a4"
    },
    sorcerer4 = {
        "5fe40622-1d3e-4cc1-8d89-e66fe51d8c5c"
    },
    sorcerer5 = {
        "3276fcfe-e143-4559-b6e0-7d7aa0ffcb53"
    },
    sorcerer6 = {
        "1270a6db-980b-4e3b-bf26-2924da61dfd5"
    },
    sorcerer7 = {
        "9e38e5ae-51e8-4dd4-aad5-869a571b1519"
    },
    sorcerer8 = {
        "5a8a002c-352b-44e9-8233-da7e6112f4b0"
    },
    sorcerer9 = {
        "d58ac072-e079-410b-b167-a5e43723b59f"
    },

    -- warlock
    warlockCantrips = {
        "f5c4af9c-5d8d-4526-9057-94a4b243cd40"
    },
    warlock1 = {
        "4823a292-f584-4f7f-8434-6630c72e5411",
        "65952d48-bb16-4ad7-b173-532182bf7770",
        "e0099b15-2599-4cba-a54b-b25ae03d6519"
    },
    warlock2 = {
        "835aeca7-c64a-4aaa-a25c-143aa14a5cec",
        "fe101a94-8619-49b2-859d-a68c2c291054",
        "0cc2c8ab-9bbc-43a7-a66d-08e47da4c172"
    },
    warlock3 = {
        "5dec41aa-f16a-434e-b209-50c07e64e4ed",
        "30e9b761-6be0-418e-bb28-5103c00c663b",
        "f18ad912-e2f4-47a9-8744-73d6a51c2941"
    },
    warlock4 = {
        "7ad7dbd0-751b-4bcd-8034-53bcc7bfb19d",
        "b64e527e-1f97-4125-84f7-78376ab1440b",
        "c3d8a4a5-9dae-4193-8322-a5d1c5b89f47"
    },
    warlock5 = {
        "deab57bf-4eec-4085-82f7-87335bce3f5d",
        "6d2edca9-71a7-4f3f-89f0-fccfff0bdee5",
        "0a9b924f-64fb-4f22-b975-5eeedc99b2fd"
    },
    warlock6 = {
        "e6ccab5e-3b3b-4b34-8fa2-1058dff2b3e6"
    },
    warlock7 = {
        "388cd3b0-914a-44b6-a828-1315323b9fd7"
    },
    warlock8 = {
        "070495e1-ccf4-4c05-9add-61c5010b8204"
    },
    warlock9 = {
        "47766c27-e791-4e6e-9b3d-2bb379106e62"
    },

    -- wizard
    wizardCantrips = {
        "3cae2e56-9871-4cef-bba6-96845ea765fa"
    },
    wizard1 = {
        "11f331b0-e8b7-473b-9d1f-19e8e4178d7d"
    },
    wizard2 = {
        "80c6b070-c3a6-4864-84ca-e78626784eb4"
    },
    wizard3 = {
        "22755771-ca11-49f4-b772-13d8b8fecd93"
    },
    wizard4 = {
        "820b1220-0385-426d-ae15-458dc8a6f5c0"
    },
    wizard5 = {
        "f781a25e-d288-43b4-bf5d-3d8d98846687"
    },
    wizard6 = {
        "bc917f22-7f71-4a25-9a77-7d2f91a96a65"
    },
    wizard7 = {
        "dff7917a-0abc-4671-b68f-c03e56212549"
    },
    wizard8 = {
        "f27a2d0a-0d6c-4c01-98a5-60081abf4807"
    },
    wizard9 = {
        "cb123d97-8809-4d71-a0cb-0ecb66177d15"
    }
}

---@param source table<string>
---@param newelements table<string>
---@return table<string>
local function FillSpellList(source, newelements)
    local newList = {}
    for _, oldSpell in pairs(source) do
        table.insert(newList, oldSpell)
    end
    for _, newSpell in pairs(newelements) do
        local flag = true
        for m, oldSpell in pairs(source) do
            if oldSpell == newSpell then flag = false end
        end
        if flag then
            table.insert(newList, newSpell)
        end
    end

    return newList
end

function SP_InitializeSpells()
    _P("Begin adding spells")
    for name, listofprogs in pairs(ProgTable) do
        for _, prog in ipairs(listofprogs) do

            local list = Ext.StaticData.Get(prog, "SpellList")
            if not list then
                _P("Bad progression uuid: " .. prog)
            else

                if SpellTable[name] ~= nil and #SpellTable[name] > 0 then
                    list["Spells"] = FillSpellList(list["Spells"], SpellTable[name])
                end
            end
        end
    end
    _P("Finished adding spells")
end
