
Ext.RegisterNetListener("MCM_Saved_Setting", function(call, payload)
    local data = Ext.Json.Parse(payload)
    if not data or data.modGUID ~= ModuleUUID or not data.settingId then
        return
    end

    if data.settingId == "UpdateBellyVisuals" then
        if data.value == "Update" then
            _P("Updating Visuals")
            
            for pred, _ in pairs(VoreData) do
                SP_UpdateWeight(pred)
            end
            SP_DelayCallTicks(30, function ()
                SP_MCMSet("UpdateBellyVisuals", "Ready")
                _P("Update Complete")
            end)
        end
    end
end)

