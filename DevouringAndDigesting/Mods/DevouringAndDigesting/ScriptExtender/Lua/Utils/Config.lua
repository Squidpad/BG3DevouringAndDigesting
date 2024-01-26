ConfigVars = {}

function SP_ResetConfig() --reset config to standard version
    ConfigFailed = 0
    local vrs = {
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
			value = 70
		},
		TeleportPrey = {
			description = "Determines if a living prey is teleported to their predator at the end of each turn (or every 6 seconds outside of turn-based mode). By default is on, should be only turned off in case of performance issues",
			value = true
		},
		RegurgDist = {
			description = "Determines how far prey spawn when regurgitated. Default is 2",
			value = 2
		}
	}
	local json = Ext.Json.Stringify(vrs)
    Ext.IO.SaveFile("DevouringAndDigesting/VoreConfig.json", json)
    SP_GetConfigFromFile()
end

function SP_GetConfigFromFile()

    local jsonFile = Ext.IO.LoadFile("DevouringAndDigesting/VoreConfig.json")
    if (jsonFile == nil) then
        print("Devouring and Digesting - Configuration file not found. Creating one.")
        SP_ResetConfig()
		return
    end
    ConfigVars = Ext.Json.Parse(jsonFile)
end