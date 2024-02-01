---@type SP_ConfigVars
ConfigVars = {}

local CONFIG_PATH = "DevouringAndDigesting\\VoreConfig.json"
local MAX_BACKUPS = 5

-- If you're making non-backward compatible changes,
-- increment CURRENT_VERSION by 1 and write a migration in Migrations/ConfigMigrations.lua.
local CURRENT_VERSION = 1

---@class SP_ConfigVars
local DEFAULT_VARS = {
    Version = {
        description = "Do not change this manually. Helps maintain your config file when upgrading the mod version.",
        value = 1,
    },
	VoreDifficulty = {
		description = "Determines how hard it is to swallow non-consenting characters. Possible values: \"default\" = checks rolled normally, \"easy\" = you make checks with advantage, \"debug\" = you always succeed",
		value = "default"
	},
	SlowDigestion = {
		description = "If true, you will not lose weight until you rest. If false, you lose it immediately upon finishing digestion and you will be immidiately able to absorb / dispose of prey",
		value = true
	},
	DigestionRateShort = {
		description = "Determines by how much the weight of a prey who is being digested is reduced after each short rest",
		value = 20
	},
	DigestionRateLong = {
		description = "Determines by how much the weight of a prey who is being digested is reduced after a long rest",
		value = 60
	},
	TeleportPrey = {
		description = "Determines if a living prey is teleported to their predator at the end of each turn (or every 6 seconds outside of turn-based mode). By default is on, should be only turned off in case of performance issues",
		value = true
	},
	RegurgDist = {
		description = "Determines how far prey spawn when regurgitated. Default is 2",
		value = 2
	},
	WeightGain = {
		description = "TEST. Stores and adds \"fat\" value to belly size. Fat is increased during digestion of dead prey and reduced upon resting.",
		value = true
	},
	WeightLossShort = {
		description = "TEST. How much fat a character looses on short resting.",
		value = 3
	},
	WeightLossLong = {
		description = "TEST. How much fat a character looses on long resting.",
		value = 11
	},
	WeightGainRate = {
		description = "TEST. By how much DigestionRate is divided for fat gain rate. DO NOT SET THIS TO 0",
		value = 4
	},
	LockStomach = {
		description = "Whether to lock the stomach object used for storing items during item vore or not. Please do not remove or add items inside the stomach manually.",
		value = true
	},
	SwitchEndoLethal = {
		description = "When you start digesting prey, you will start digesting endo prey as well.",
		value = true
	},
	DigestItems = {
		description = "When you start digesting prey, the items in your stomach might be digested. WARNING: THIS WILL DELETE STORY ITEMS IN YOUR STOMACH",
		value = true
	},
	RegurgitationCooldown = {
		description = "Preds are unable to swallow prey for a number of turn after regurgitation. Set to 0 to disable",
		value = 2
	},
	RegurgitationCooldown2 = {
		description = "Preds are unable to regurgitate prey for a number of turn after regurgitation. Set to 0 to disable",
		value = 0
	},
	SwallowDown = {
		description = "Preds will need to use a 'Contine Swallowing' spell to fully swallow a prey.",
		value = true
	},
	Hunger = {
		description = "Enables hunger system for party member preds. If a pred does not digest prey for a long time, they will recieve debuffs. Setting this to false disables hunger completely.",
		value = true
	},
	LethalRandomSwitch = {
		description = "If set to true, as you gain Hunger, it will become increasingly likely that you'll accidently start digesting your non-lethally swallowed prey. Works independently from SwitchEndoLethal.",
		value = true
	},
	HungerShort = {
		description = "Hunger stacks gained on short rest.",
		value = 1
	},
	HungerLong = {
		description = "Hunger stacks gained on long rest.",
		value = 4
	},
	HungerSatiation = {
		description = "Satiation stacks needed to remove one hunger stack.",
		value = 3
	},
	HungerSatiationRate = {
		description = "By how much digestion rate is divided for satiation gain. DO NOT SET THIS TO 0",
		value = 4
	},
	HungerBreakpoint1 = {
		description = "Stacks of hunger at which a debuff is appled",
		value = 8
	},
	HungerBreakpoint2 = {
		description = "Stacks of hunger at which a debuff is appled",
		value = 12
	},
	HungerBreakpoint3 = {
		description = "Stacks of hunger at which a debuff is appled",
		value = 16
	},
	BoilingInsidesFast = {
		description = "Dead prey are digested twice as fast if you have 'Boiling insides' feat.",
		value = false
	},
	StatusBonusStomach = {
		description = "Only prey who are in your stomach (oral vore) recieve benefits from feats.",
		value = true
	}
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

function SP_LoadConfigFromFile()
    local content = Ext.IO.LoadFile(CONFIG_PATH)
    if content == nil then
        _P("Config not found. But it's okay if you've installed the mod for the first time!")
        SP_ResetConfig()
        SP_SaveConfig()
        return
    end

    local loadedConfig = Ext.Json.Parse(content)

    _P("Config loaded: \"Script Extender\\" .. CONFIG_PATH .. "\".")

    local isVersionValid = (
        loadedConfig.Version ~= nil and loadedConfig.Version.value ~= nil and
        SP_IsInt(loadedConfig.Version.value) and loadedConfig.Version.value > 0
    )
    if not isVersionValid then
        _F("Invalid config version detected. Your config will be reset.")
        SP_ShowMessageBox(
            Ext.Loca.GetTranslatedString("h035645a0g5808g4618ga1b6g0e23a8ecb0ab") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("h86742a8fga59cg4597g8b7dg30e4788a1ed0")
        )
        SP_BackupConfig()
        SP_ResetConfig()
        SP_SaveConfig()
        return
    end

    if loadedConfig.Version.value > CURRENT_VERSION then
        _F(
            "Newer config version detected " ..
            "(current: " .. CURRENT_VERSION .. "; yours: " .. loadedConfig.Version.value .. "). " ..
            "Sorry, your config isn't compatible with the current mod version installed. " ..
            "Default config will be loaded."
        )
        SP_ShowMessageBox(
            Ext.Loca.GetTranslatedString("h35ebd26bg84c7g4efag8be1gefde311b9f2e") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("hfdb0ed11gd3abg47eag9e99g0140813ddb06") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("h31c7c480g72c9g44ebg9b2eg80f5f0f9e78d") .. "\n\n" ..
            Ext.Loca.GetTranslatedString("h79032db6g7469g4f1cgaca2g743d89c7b335")
        )
        -- Let's not overwrite config file so player can easily
        -- get back to compatible mod version. Just load defaults.
        SP_ResetConfig()
        return
    end

    local saveRequired = false

    if loadedConfig.Version.value < CURRENT_VERSION then
        _P(
            "Old version config detected " ..
            "(current: " .. CURRENT_VERSION .. "; yours: " .. loadedConfig.Version.value .. ")."
        )
        saveRequired = true
        for i = loadedConfig.Version.value + 1, CURRENT_VERSION, 1 do
            if SP_ConfigMigrations["To" .. i] ~= nil then
                _P("Migrating config from version " .. loadedConfig.Version.value .. " to " .. i .. ".")
                local newConfigVars = SP_Deepcopy(loadedConfig)
                newConfigVars.Version.value = i
                local successful = SP_ConfigMigrations["To" .. i](newConfigVars)
                if successful then
                    loadedConfig = newConfigVars
                end
            end
            if loadedConfig.Version.value ~= i then
                _F(
                    "Sorry, your config isn't compatible with the current mod version installed " ..
                    "and can't be upgraded: failed to migrate " ..
                    "from " .. loadedConfig.Version.value .. " to " .. i .. ". " ..
                    "Default config will be loaded."
                )
                SP_ShowMessageBox(
                    Ext.Loca.GetTranslatedString("haff912c3gf2afg4723ga736gf534cb4f5352") .. "\n\n" ..
                    Ext.Loca.GetTranslatedString("h1c89714ag5f55g44f0g9a4fg6beac7723a20") .. "\n\n" ..
                    Ext.Loca.GetTranslatedString("h31c7c480g72c9g44ebg9b2eg80f5f0f9e78d")
                )
                SP_ResetConfig()
                saveRequired = false
                break
            end
        end
    end

    -- Looking for unknown keys.
    for k, _ in pairs(loadedConfig) do
        if DEFAULT_VARS[k] == nil then
            _P("Unknown config parameter: \"" .. k .. "\". Removing parameter.")
            loadedConfig[k] = nil
            saveRequired = true
        end
    end
    -- Looking for known keys.
    for k, _ in pairs(DEFAULT_VARS) do
        if loadedConfig[k] == nil then
            _F("Missing config parameter: \"" .. k .. "\". Resetting parameter.")
            loadedConfig[k] = DEFAULT_VARS[k]
            saveRequired = true
        end
    end
    -- Looking for mismatched descriptions.
    for k, _ in pairs(DEFAULT_VARS) do
        if loadedConfig[k]["description"] ~= DEFAULT_VARS[k]["description"] then
            _P("Updating config parameter description: \"" .. k .. "\".")
            loadedConfig[k]["description"] = DEFAULT_VARS[k]["description"]
            saveRequired = true
        end
    end

    ConfigVars = loadedConfig

    if saveRequired then
        SP_BackupConfig()
        SP_SaveConfig()
    end
end
