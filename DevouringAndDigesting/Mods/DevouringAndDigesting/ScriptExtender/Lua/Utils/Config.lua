---@type SP_ConfigVars
ConfigVars = {}

local CONFIG_PATH = "DevouringAndDigesting\\VoreConfig.json"
local MAX_BACKUPS = 5

-- If you're making non-backward compatible changes,
-- increment CURRENT_VERSION by 1 and write a migration in Migrations/ConfigMigrations.lua.
-- Only once per release!
local CURRENT_VERSION = 1

---@class SP_ConfigVars
local DEFAULT_VARS = {
    VisualsAndAudio = {
        GurgleProbability = {
            description = "The % chance of a gurgle being played every 6 seconds (a turn). Set to 0 to disable.",
            value = 8,
            default = 8,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
    },
    Debug = {
        TeleportPrey = {
            description =
            "Determines if a living prey is teleported to their predator at the end of each turn (or every 6 seconds outside of turn-based mode). By default is on, should be only turned off in case of performance issues",
            value = true,
            default = true,
        },
        LockStomach = {
            description =
            "Whether to lock the stomach object used for storing items during item vore or not. This is for you to be able to LOOK inside, actually removing the items will lead to unintended consequences.",
            value = true,
            default = true,
        },
    },
    WeightGain = {
        WeightGain = {
            description =
            "Stores and adds \"fat\" value to belly size. Fat is increased during digestion of dead prey and reduced upon resting.",
            value = false,
            default = false,
        },
        WeightGainRate = {
            description = "% of a prey's weight you gain as fat.",
            value = 25,
            default = 25,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
        WeightLossLong = {
            description = "How much fat a character loses on long resting.",
            value = 11,
            default = 11,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
        WeightLossShort = {
            description = "How much fat a character loses on short resting.",
            value = 3,
            default = 3,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
    },
    Mechanics = {
        BoilingInsidesFast = {
            description = "Dead prey are digested twice as fast if you have 'Boiling insides' feat.",
            value = false,
            default = false,
        },
        VoreDifficulty = {
            description =
            "Determines how hard it is to swallow non-consenting characters. \"default\" = checks rolled normally, \"easy\" = you make checks with advantage, \"cheat\" = you always succeed",
            value = "default",
            default = "default",
            choices = {"default", "easy", "cheat"},
        },
        StatusBonusLocus = {
            description = "Prey in the following loci will receive benefits from feats.",
            value = {"Oral", "Anal", "Unbirth", "Cock"},
            default = {"Oral", "Anal", "Unbirth", "Cock"},
            choices = {"Oral", "Anal", "Unbirth", "Cock"},
        },
        SwallowDown = {
            description = "Preds will need to use a 'Contine Swallowing' spell to fully swallow a prey.",
            value = true,
            default = true,
        },
        RequireProperAnatomy = {
            description =
            "If true, special types of vore will require you to have a body part that would enable that type of vore.",
            value = true,
            default = true,
        },
        SwitchEndoLethal = {
            description = "When you start digesting prey, you will start digesting endo prey as well.",
            value = true,
            default = true,
        },
    },
    Regurgitation = {
        RegurgitationDistance = {
            description = "Determines how far prey spawn when regurgitated.",
            value = 2,
            default = 2,
            range = {0, 5, 1},
            extras = {
                slider = true,
            },
        },
        RegurgitationCooldownSwallow = {
            description =
            "Preds are unable to swallow prey for a number of turn after regurgitation. Set to 0 to disable",
            value = 2,
            default = 2,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
        RegurgitationCooldownRegurgitate = {
            description =
            "Preds are unable to regurgitate prey for a number of turn after regurgitation. Set to 0 to disable",
            value = 0,
            default = 0,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
    },
    Digestion = {
        SlowDigestion = {
            description =
            "If true, you will not lose weight until you rest. If false, you lose it immediately upon finishing digestion and you will be immediately able to absorb / dispose of prey",
            value = true,
            default = true,
        },
        DigestItems = {
            description =
            "When you start digesting prey, the items in your stomach might be digested. WARNING: THIS WILL DELETE STORY ITEMS IN YOUR STOMACH AND COULD SOFTLOCK YOUR SAVE",
            value = false,
            default = false,
        },
        DigestionRateLong = {
            description =
            "Determines by how much the weight of a prey who is being digested is reduced after a long rest",
            value = 60,
            default = 60,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
        DigestionRateShort = {
            description =
            "Determines by how much the weight of a prey who is being digested is reduced after each short rest",
            value = 20,
            default = 20,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
    },
    Hunger = {
        Hunger = {
            description =
            "Enables hunger system for party member preds. If a pred does not digest prey for a long time, they will receive debuffs. Setting this to false disables hunger completely.",
            value = false,
            default = false,
        },
        HungerBreakpoint1 = {
            description = "Stacks of hunger at which a debuff is applied",
            value = 8,
            default = 8,
            range = {1, 100, 1},
            extras = {
                slider = true,
            },
        },
        HungerBreakpoint2 = {
            description = "Stacks of hunger at which a second debuff is applied",
            value = 12,
            default = 12,
            range = {1, 100, 1},
            extras = {
                slider = true,
            },
        },
        HungerBreakpoint3 = {
            description = "Stacks of hunger at which a third debuff is applied",
            value = 16,
            default = 16,
            range = {1, 100, 1},
            extras = {
                slider = true,
            },
        },
        HungerLong = {
            description = "Hunger stacks gained on long rest.",
            value = 3,
            default = 3,
            range = {1, 100, 1},
            extras = {
                slider = true,
            },
        },
        HungerShort = {
            description = "Hunger stacks gained on short rest.",
            value = 1,
            default = 1,
            range = {1, 100, 1},
            extras = {
                slider = true,
            },
        },
        HungerSatiation = {
            description = "Satiation stacks needed to remove one hunger stack.",
            value = 3,
            default = 3,
            range = {1, 100, 1},
            extras = {
                slider = true,
            },
        },
        HungerSatiationRate = {
            description = "% of digestion rate for satiation gain.",
            value = 25,
            default = 25,
            range = {0, 100, 1},
            extras = {
                slider = true,
            },
        },
        LethalRandomSwitch = {
            description =
            "If set to true, as you gain Hunger, it will become increasingly likely that you'll accidentally start digesting your non-lethally swallowed prey. Works independently from SwitchEndoLethal.",
            value = false,
            default = false,
        },
    },
    __Version = CURRENT_VERSION,
    __CephelosModConfigVersion = 1,
}

local function SP_BackupConfig()
    if MAX_BACKUPS < 1 then
        return
    end

    local content = Ext.IO.LoadFile(CONFIG_PATH)
    if content == nil then
        return
    end

    -- Shift config files:
    -- .1.bak->.2.bak .. .4.bak->.5.bak;
    -- .5.bak -> (not transferred, overwriten).
    for i = MAX_BACKUPS - 1, 1, -1 do
        local path1 = CONFIG_PATH .. "." .. i .. ".bak"
        local path2 = CONFIG_PATH .. "." .. (i + 1) .. ".bak"
        local bakContent = Ext.IO.LoadFile(path1)
        if bakContent ~= nil then
            Ext.IO.SaveFile(path2, bakContent)
        end
    end

    local path = CONFIG_PATH .. ".1.bak"
    Ext.IO.SaveFile(path, content)
    _P("Config backup saved: \"Script Extender\\" .. path .. "\".")
end

function SP_SaveConfig()
    local json = Ext.Json.Stringify(ConfigVars)
    Ext.IO.SaveFile(CONFIG_PATH, json)
    _P("Config saved: \"Script Extender\\" .. CONFIG_PATH .. "\".")
end

function SP_ResetConfig()
    ConfigVars = SP_Deepcopy(DEFAULT_VARS)
    _P("Default config loaded.")
end

function SP_ResetAndSaveConfig()
    SP_ResetConfig()
    SP_SaveConfig()
end

function SP_LoadConfigFromFile()
    local content = Ext.IO.LoadFile(CONFIG_PATH)
    if content == nil then
        _P("Config not found. If this is your first time launching the game with this mod enabled, this is fine.")
        SP_ResetConfig()
        SP_SaveConfig()
        return
    end

    ---@type SP_ConfigVars
    local loadedConfig = Ext.Json.Parse(content)

    _P("Config loaded: \"Script Extender\\" .. CONFIG_PATH .. "\".")

    local isVersionValid = (
        loadedConfig.__Version ~= nil and SP_IsInt(loadedConfig.__Version) and loadedConfig.__Version > 0
    )
    if not isVersionValid then
        _F("Invalid config version detected. Your config will be reset.")
        SP_ShowMessageBox(
            Ext.Loca.GetTranslatedString("h035645a0g5808g4618ga1b6g0e23a8ecb0ab") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("h86742a8fga59cg4597g8b7dg30e4788a1ed0")
        )
        SP_BackupConfig()
        SP_ResetAndSaveConfig()
        return
    end

    if loadedConfig.__Version > CURRENT_VERSION then
        _F(
            "Newer config version detected " ..
            "(current: " .. CURRENT_VERSION .. "; yours: " .. loadedConfig.__Version .. "). " ..
            "Sorry, your config isn't compatible with the current mod version installed. " ..
            "Default config will be loaded."
        )
        SP_ShowMessageBox(
            Ext.Loca.GetTranslatedString("h35ebd26bg84c7g4efag8be1gefde311b9f2e") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("hfdb0ed11gd3abg47eag9e99g0140813ddb06") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("h31c7c480g72c9g44ebg9b2eg80f5f0f9e78d") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("h79032db6g7469g4f1cgaca2g743d89c7b335")
        )
        SP_BackupConfig()
        SP_ResetAndSaveConfig()
        return
    end

    local saveRequired = false

    if loadedConfig.__Version < CURRENT_VERSION then
        _P(
            "Old version config detected " ..
            "(current: " .. CURRENT_VERSION .. "; yours: " .. loadedConfig.__Version .. ")."
        )
        saveRequired = true
        for i = loadedConfig.__Version + 1, CURRENT_VERSION, 1 do
            if SP_ConfigMigrations["To" .. i] ~= nil then
                _P("Migrating config from version " .. loadedConfig.__Version .. " to " .. i .. ".")
                local newConfigVars = SP_Deepcopy(loadedConfig)
                newConfigVars.__Version = i
                local successful = SP_ConfigMigrations["To" .. i](newConfigVars)
                if successful then
                    loadedConfig = SP_Deepcopy(newConfigVars)
                end
            end
            if loadedConfig.__Version ~= i then
                _F(
                    "Sorry, your config isn't compatible with the current mod version installed " ..
                    "and can't be upgraded: failed to migrate " ..
                    "from " .. loadedConfig.__Version .. " to " .. i .. ". " ..
                    "Default config will be loaded."
                )
                SP_ShowMessageBox(
                    Ext.Loca.GetTranslatedString("haff912c3gf2afg4723ga736gf534cb4f5352") .. "\n\n" ..
                    Ext.Loca.GetTranslatedString("h1c89714ag5f55g44f0g9a4fg6beac7723a20") .. "\n\n" ..
                    Ext.Loca.GetTranslatedString("h31c7c480g72c9g44ebg9b2eg80f5f0f9e78d")
                )
                SP_BackupConfig()
                SP_ResetAndSaveConfig()
                saveRequired = false
                break
            end
        end
    end

    -- Looking for unknown keys.
    for k, v in pairs(loadedConfig) do
        if DEFAULT_VARS[k] == nil then
            _P("Unknown config category: \"" .. k .. "\". Removing category.")
            loadedConfig[k] = nil
            saveRequired = true
        end
        for i, _ in pairs(v) do
            if DEFAULT_VARS[k][i] == nil then
                _P("Unknown config parameter: \"" .. i .. "\". Removing parameter.")
                loadedConfig[k][i] = nil
                saveRequired = true
            end
        end
    end
    -- Looking for known keys.
    for k, v in pairs(DEFAULT_VARS) do
        if loadedConfig[k] == nil then
            _F("Missing config category: \"" .. k .. "\". Resetting category.")
            loadedConfig[k] = SP_Deepcopy(v)
            saveRequired = true
        end
        for i, _ in pairs(v) do
            if loadedConfig[k][i] == nil then
                _F("Missing config parameter: \"" .. i .. "\". Resetting parameter.")
                loadedConfig[k][i] = SP_Deepcopy(v)
                saveRequired = true
            end
        end
    end
    -- Looking for mismatched descriptions.
    for k, v in pairs(DEFAULT_VARS) do
        for i, j in pairs(v) do
            if loadedConfig[k][i].description ~= j.description then
                _P("Updating config parameter description: \"" .. i .. "\".")
                loadedConfig[k][i].description = j.description
                saveRequired = true
            end
        end
    end
    -- Looking for mismatched default values.
    for k, v in pairs(DEFAULT_VARS) do
        for i, j in pairs(v) do
            if loadedConfig[k][i].default ~= j.default and type(j.default) ~= "table" then
                _P("Updating config default value for: \"" .. i .. "\".")
                loadedConfig[k][i].default = j.default
                saveRequired = true
            end
        end
    end
    -- Looking for invalid value types.
    for k, v in pairs(DEFAULT_VARS) do
        for i, j in pairs(v) do
            if type(loadedConfig[k][i].value) ~= type((j.value)) then
                _P("Invalid value set for \"" ..
                    i .. "\", resetting to default value of \"" .. tostring(j.value) .. "\"")
                loadedConfig[k][i].value = j.value
                saveRequired = true
            end
        end
    end

    ConfigVars = loadedConfig

    if saveRequired then
        SP_BackupConfig()
        SP_SaveConfig()
    end
end
