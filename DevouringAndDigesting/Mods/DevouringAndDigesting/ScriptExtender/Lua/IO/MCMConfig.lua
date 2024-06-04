

-- used to make getting values from the MCM less verbose
function SP_MCMGet(settingID)
    return Mods.BG3MCM.MCMAPI:GetSettingValue(settingID, ModuleUUID)
end

function SP_MCMSet(settingID, newVal)
    Mods.BG3MCM.MCMAPI:SetSettingValue(settingID, newVal, ModuleUUID)
end


