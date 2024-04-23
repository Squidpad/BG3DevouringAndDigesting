
---updates the values for the Stomach Sentinel's Knowledge Within status
---@param pred CHARACTER the pred to recieve buffs
function SP_SC_UpdateKnowledgeWithin(pred)
    local skillList = {"Deception", "Intimidation", "Performance", "Persuasion", "Acrobatics", "SleightOfHand",
        "Stealth", "Arcana", "History", "Investigation", "Nature", "Religion", "Athletics", "AnimalHandling",
        "Insight", "Medicine", "Perception", "Survival"}
    local abilityList = {nil, "Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"}
    -- these values are fixed; calculating them is a waste of time
    local abilityLength = 7
    local skillLength = 18
    for _, v in ipairs(skillList) do
        Osi.RemoveStatus(pred, "SP_SC_KnowledgeWithin_" .. v)
    end
    for _, v in ipairs(abilityList) do
        if v ~= nil then
            Osi.RemoveStatus(pred, "SP_SC_KnowledgeWithin_" .. v)
        end
    end
    if VoreData[pred] == nil then
        return
    end
    local predData = Ext.Entity.Get(pred)
    local predAbilities = predData.Stats.Abilities
    local predSkills = predData.Stats.Skills
    local everyoneAbilities = {predAbilities}
    local everyoneSkills = {predSkills}

    local partyPrey = SP_FilterPrey(pred, "All", true, DType.Endo)
    if #partyPrey == 0 then
        return
    end
    for _, prey in ipairs(partyPrey) do
        local charData = Ext.Entity.Get(prey)
        table.insert(everyoneAbilities, charData.Stats.Abilities)
        table.insert(everyoneSkills, charData.Stats.Skills)
    end

    for n = 1, skillLength do
        local highest = math.max(table.unpack(SP_ArrayMap(everyoneSkills, function (t) return t[n] end)))
        -- _P("Increased " ..
        --     skillList[n] .. " from " .. predSkills[n] .. " to " .. highest)
        Osi.ApplyStatus(pred, "SP_SC_KnowledgeWithin_" .. skillList[n], (highest - predSkills[n]) * SecondsPerTurn)
        if n <= abilityLength and n ~= 1 then
            highest = math.max(table.unpack(SP_ArrayMap(everyoneAbilities, function (t) return t[n] end)))
            -- _P("Increased " ..
            --     abilityList[n] .. " from " .. predAbilities[n] .. " to " .. highest)
            Osi.ApplyStatus(pred, "SP_SC_KnowledgeWithin_Raw" .. abilityList[n], (highest - predAbilities[n]) * SecondsPerTurn)
        end
    end
end
