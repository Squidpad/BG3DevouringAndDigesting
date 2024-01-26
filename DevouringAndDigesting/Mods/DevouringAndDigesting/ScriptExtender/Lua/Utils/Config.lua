
function SP_ResetConfig() --reset config to standard version
    ConfigFailed = 0
   local vrs = [[
    {
      "VoreDifficulty": {
        "description": "Determines how hard it is to swallow non-consenting characters. Possible values: \"default\" = checks rolled normally, \"easy\" = you make checks with advantage, \"debug\" = you always succeed",
        "value": "default"
      },
      "SlowDigestion": {
        "description": "If true, you will not lose weight until you rest. If false, you lose it immediately upon finishing digestion",
        "value": "true"
      },
      "DigestionRate": {
        "description": "Determines how much weight a pred loses after each short rest. You lose quadruple this value after a long rest",
        "value": "20"
      }
    }
    ]]
    Ext.IO.SaveFile("DevouringAndDigesting/VoreConfig.json", vrs)
    SP_GetConfigFromFile()
end

function SP_GetConfigFromFile()

    local json = Ext.IO.LoadFile("DevouringAndDigesting/VoreConfig.json")
    if (json == nil) then
        print("Devouring and Digesting - Configuration file not found. Creating one.")
        SP_ResetConfig()
    end
    ConfigVars = Ext.Json.Parse(json)
end