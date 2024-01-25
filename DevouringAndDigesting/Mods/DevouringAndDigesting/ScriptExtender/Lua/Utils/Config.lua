
function SP_ResetConfig() --reset config to standard version
    ConfigFailed = 0
    vrs = [[{
      "PerformanceMode": {
        "description": "For low-end systems. Currently just makes updating prey location outside of combat manual.",
        "value": "false"
      },
      "VoreSuccessChance": {
        "description": "Determines how hard it is to swallow non-consenting characters. This applies globally to all characters. Possible values: \"default\" = attempts made normally, \"adv\" = attempts made with advantage, \"debug\" = attempts always succeed",
        "value": "default"
      }
    }]]
    Ext.IO.SaveFile("VoreConfig.json",vrs)
    SP_GetConfigFromFile()
end

function SP_GetConfigFromFile()

    json = Ext.IO.LoadFile("VoreConfig.json")
    if (s == nil) then
        print("Devouring and Digesting - Configuration file not found. Creating one.")
        SP_ResetConfig()
    end
    ConfigVars = Ext.Json.Parse(json)
end