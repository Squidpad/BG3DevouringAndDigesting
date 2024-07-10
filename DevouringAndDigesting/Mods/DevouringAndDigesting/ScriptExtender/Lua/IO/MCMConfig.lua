
-- gives player all usable non-debug items from mod (to avoid using SummonTutorialChest)
function SP_GiveVoreItems()
    Osi.TemplateAddTo('68dc579e-d3aa-4277-ab1f-5ccd6f78d113', Osi.GetHostCharacter(), 1)
end
-- used to make getting values from the MCM less verbose
function SP_MCMGet(settingID)
    return Mods.BG3MCM.MCMAPI:GetSettingValue(settingID, ModuleUUID)
end

function SP_MCMSet(settingID, newVal)
    Mods.BG3MCM.MCMAPI:SetSettingValue(settingID, newVal, ModuleUUID)
end


