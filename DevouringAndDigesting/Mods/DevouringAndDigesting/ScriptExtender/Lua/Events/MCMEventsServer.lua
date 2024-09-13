
---@diagnostic disable-next-line: undefined-field
Ext.ModEvents.BG3MCM["MCM_Setting_Saved"]:Subscribe(function(data)

    if not data or data.modUUID ~= ModuleUUID or not data.settingId then
        return
    end

    if data.settingId == "UpdateBellyVisuals" then
        if data.value == "Updating" then
            _P("Updating Visuals")
            
            for pred, _ in pairs(VoreData) do
                SP_UpdateWeight(pred)
            end
            SP_DelayCallTicks(30, function ()
                SP_MCMSet("UpdateBellyVisuals", "Ready")
                _P("Update Complete")
            end)
        end
    elseif data.settingId == "AddVoreItems" and data.value == true then
        SP_GiveVoreItems()
        SP_DelayCallTicks(5, function ()
            SP_MCMSet("AddVoreItems", false)
        end)
    elseif data.settingId == "PrintVoreData" and data.value == true then
        _D(VoreData)
        SP_DelayCallTicks(5, function ()
            SP_MCMSet("PrintVoreData", false)
        end)
    elseif data.settingId == "ResetVore" then
        if data.value == "Running" then
            SP_ResetVore()
        end
    elseif data.settingId == "rResetRaceConfig" and data.value == true then
        SP_ResetAndSaveRaceWeightsConfig()
        SP_DelayCallTicks(5, function ()
            SP_MCMSet("rResetRaceConfig", false)
        end)
    elseif data.settingId == "rLoadExample" and data.value == true then
        SP_LoadExampleRaceConfig()
        SP_DelayCallTicks(5, function ()
            SP_MCMSet("rLoadExample", false)
        end)
    elseif data.settingId == "rReloadRaceConfig" and data.value == true then
        SP_LoadRaceWeightsConfigFromFile()
        SP_DelayCallTicks(5, function ()
            SP_MCMSet("rReloadRaceConfig", false)
        end)
    elseif data.settingId == "DetachPrey" then
        for k, v in pairs(VoreData) do
            if v.Pred ~= "" then
                if data.value == true then
                    Osi.SetDetached(k, 1)
                else
                    Osi.SetDetached(k, 0)
                end
            end
        end
    end
end)

