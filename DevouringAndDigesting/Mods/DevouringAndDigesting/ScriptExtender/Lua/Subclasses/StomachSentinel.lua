
---removes Stomach Sentinel Statuses, other than Knowledge Within
---@param pred CHARACTER
local function SP_SC_RemoveSentinelStatuses(pred)
    Osi.RemoveStatus(pred, "SP_SC_GastricBulwark_Status")
    Osi.RemoveStatus(pred, "SP_SC_StrengthFromMany_Status")
end

---updates the values for Knowledge Within
---@param pred CHARACTER
---@param prey CHARACTER
local function SP_SC_UpdateKnowledgeWithin(pred, prey)
    local skillList = {"Deception", "Intimidation", "Performance", "Persuasion", "Acrobatics", "SleightOfHand",
        "Stealth", "Arcana", "History", "Investigation", "Nature", "Religion", "Athletics", "AnimalHandling",
        "Insight", "Medicine", "Perception", "Survival"}
    local abilityList = {nil, "Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"}
    for _, v in ipairs(skillList) do
        Osi.RemoveStatus(pred, "SP_SC_KnowledgeWithin_" .. v)
    end
    for _, v in ipairs(abilityList) do
        if v ~= nil then
            Osi.RemoveStatus(pred, "SP_SC_KnowledgeWithin_" .. v)
        end
    end
    if VoreData[pred] ~= nil then
        if Osi.isPartyMember(prey, 0) == 1 then
            local predData = Ext.Entity.Get(pred)
            local predAbilities = predData.Stats.Abilities
            local predSkills = predData.Stats.Skills
            local maxAbilities = {}
            local maxSkills = {}

            local charData = Ext.Entity.Get(prey)
            local charAbilities = charData.Stats.Abilities
            local charSkills = charData.Stats.Skills
            for k, v in ipairs(predAbilities) do
                if maxAbilities[k] == nil then
                    maxAbilities[k] = -1
                end
                if k ~= 1 and v < charAbilities[k] and maxAbilities[k] < charAbilities[k] then
                    maxAbilities[k] = charAbilities[k]
                end
            end
            for k, v in ipairs(predSkills) do
                if maxSkills[k] == nil then
                    maxSkills[k] = -1
                end
                if v < charSkills[k] and maxSkills[k] < charSkills[k] then
                    maxSkills[k] = charSkills[k]
                end
            end
            _P("maxSkills: ")
            _D(maxSkills)
            for k, v in ipairs(maxSkills) do
                if v > -1 then
                    _P("Increased " ..
                        skillList[k] .. " by " .. v .. " - " .. predSkills[k] .. " = " .. (v - predSkills[k]))
                    Osi.ApplyStatus(pred, "SP_SC_KnowledgeWithin_" .. skillList[k], (v - predSkills[k]) * SecondsPerTurn)
                end
            end
            for k, v in ipairs(maxAbilities) do
                if v > -1 then
                    _P("Increased " ..
                        abilityList[k] .. " by " .. v .. " - " .. predAbilities[k] .. " = " .. (v - predAbilities[k]))
                    Osi.ApplyStatus(pred, "SP_SC_KnowledgeWithin_Raw" .. abilityList[k],
                                    (v - predAbilities[k]) * SecondsPerTurn)
                end
            end
        end
    end
end

---Updates subclass statuses
---@param pred CHARACTER pred to update
local function SP_SC_UpdateScaledStatuses(pred)
    if VoreData[pred] ~= nil then
        local alliedPrey = SP_FilterPrey(pred, "All", true, 0)
        if Osi.HasPassive(pred, "SP_SC_KnowledgeWithin") == 1 and #alliedPrey > 0 then
                

            _P("Pred: " ..
                Osi.ResolveTranslatedString(Osi.GetDisplayName(pred)) ..
                " has passives: Gastric Bulwark " ..
                Osi.HasPassive(pred, "SP_SC_GastricBulwark") ..
                " and Strength From Many " .. Osi.HasPassive(pred, "SP_SC_StrengthFromMany") .. " numpPrey: " .. #alliedPrey)
            _P("numPrey: " .. #alliedPrey)
            if Osi.HasPassive(pred, "SP_SC_GastricBulwark") == 1 then
                Osi.ApplyStatus(pred, "SP_SC_GastricBulwark_Status", SecondsPerTurn)
            end
            if Osi.HasPassive(pred, "SP_SC_StrengthFromMany") == 1 then
                Osi.ApplyStatus(pred, "SP_SC_StrengthFromMany_Status", #alliedPrey * SecondsPerTurn)
            end
        end
        return
    end
    SP_SC_RemoveSentinelStatuses(pred)
end




---Runs each time a status is applied
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee? GUIDSTRING Thing that caused status to be applied.
---@param storyActionID? integer
local function SP_SC_OnStatusApplyUpdate(object, status, causee, storyActionID)
    if status == "SP_Stuffed" then
        SP_DelayCallTicks(5, function () SP_SC_UpdateScaledStatuses(object) end)
    elseif status == "SP_SC_GastricBulwark_TempHP" then
        local numPrey = 0
        _P("VoreData: ")
        _D(VoreData[object])
        if VoreData[object] ~= nil then
            numPrey = #SP_FilterPrey(object, "All", true, 0)
        end
        _P("numPrey: " .. numPrey)
        if numPrey > 0 then
            if numPrey > 3 then
                numPrey = 3
            end
            Osi.ApplyStatus(object, "SP_SC_GastricBulwark_TempHP_" .. numPrey, SecondsPerTurn)
        else
            Osi.RemoveStatus(object, "SP_SC_GastricBulwark_TempHP_1")
            Osi.RemoveStatus(object, "SP_SC_GastricBulwark_TempHP_2")
            Osi.RemoveStatus(object, "SP_SC_GastricBulwark_TempHP_3")
        end
    end
end

---Runs each time a status is removed
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee? GUIDSTRING Thing that caused status to be applied.
---@param storyActionID? integer
local function SP_SC_OnStatusRemoveUpdate(object, status, causee, storyActionID)
    if status == "SP_Stuffed" then
        SP_SC_UpdateScaledStatuses(object)
        local prey = SP_CharacterFromGUID(causee)
        SP_SC_UpdateKnowledgeWithin(object, prey)
    end
end



Ext.Osiris.RegisterListener("StatusApplied", 4, "after", SP_SC_OnStatusApplyUpdate)
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", SP_SC_OnStatusRemoveUpdate)
