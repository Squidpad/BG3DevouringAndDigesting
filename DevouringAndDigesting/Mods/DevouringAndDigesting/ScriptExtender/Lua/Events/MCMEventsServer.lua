
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
    elseif data.settingId == "AddVoreItems" and data.value == true then
        SP_GiveVoreItems()
        SP_MCMSet("AddVoreItems", false)
    elseif data.settingId == "PrintVoreData" and data.value == true then
        _D(VoreData)
        SP_MCMSet("PrintVoreData", false)
    end
end)

