StatPaths={
    "Public/VoreModAlpha2/Stats/Generated/Data/Armor.txt",
    "Public/VoreModAlpha2/Stats/Generated/Data/Potions.txt",
    "Public/VoreModAlpha2/Stats/Generated/Data/Spell_Vore.txt",
}

PersistentVars = {}
PredPreyTable = {}

function SP_SpellCast(caster, spell)
    if string.sub(spell,0,15) == 'SP_Regurgitate_' then
        _P('Starting Regurgitation')
        local preyGUID = string.sub(spell, 16)
        _P('Targets: ' .. preyGUID)
        local predX, predY, predZ = Osi.getPosition(caster)
        local predXRotation, predYRotation, predZRotation = Osi.getRotation(caster)
        predYRotation = predYRotation * math.pi / 180
        local indexToRemove = 0
        for k, v in pairs(PredPreyTable[caster]) do
            if spell == "SP_Regurgitate_All" or v == preyGUID then
                Osi.TeleportToPosition(v, predX+2*math.cos(predYRotation), predY, predZ+2*math.sin(predYRotation), "", 0, 0, 0, 0, 0)
                Osi.RemoveStatus(v, 'SP_Swallowed_Endo', caster)
                SP_ReduceWeight(caster, v)
                if v == preyGUID then
                    indexToRemove = k
                end
            end
        end
        if preyGUID ~= "All" then
            SP_RemoveCustomRegurgitate(preyGUID)
            table.remove(PredPreyTable[caster], indexToRemove)
        end
        _P(preyGUID == 'All')
        _P(preyGUID)
        if PredPreyTable == nil or preyGUID == 'All' or next(PredPreyTable[caster]) == nil then
            _P("Clearing Table")
            PredPreyTable[caster] = nil
            Osi.RemoveStatus(caster, 'SP_Stuffed_Endo')
            Osi.RemoveSpell(caster, 'SP_Regurgitate', 1)
            Osi.RemoveSpell(caster, "SP_Move_Prey_To_Me")
        end

        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
    elseif spell == "SP_Move_Prey_To_Me" then
        SP_TelePreyToPred(caster)
    end
end


function SP_InitialSwallowPass(caster, target, spell)
    if spell == 'SP_Target_Vore_Endo' then
        _P('Endo Vore')
        SP_DelayCall(600, function() Osi.ApplyStatus(target, "SP_Swallowed_Endo", -1, 1, caster) end)
        SP_DelayCall(600, function() Osi.ApplyStatus(caster, "SP_Stuffed_Endo", -1, 1, caster) end)
        SP_DelayCall(600, function() SP_FillPredPreyTable(caster, target, 'SP_Target_Vore_Endo') end)
    end
    if spell == 'SP_Target_Vore_Lethal' then
        _P('Lethal Vore')
        SP_DelayCall(600, function() SP_VoreCheck(caster, target, "SwallowLethalCheck") end)
    end
end

function SP_FillPredPreyTable(caster, target, spell)
    _P("Filling Table")
    if spell == 'SP_Target_Vore_Endo' or spell == 'SP_Target_Vore_Lethal' then
        SP_AddWeight(caster, target)
        if PredPreyTable[caster] == nil then
            PredPreyTable[caster] = {}
        end
        table.insert(PredPreyTable[caster], target)
        SP_AddCustomRegurgitate(caster, target)

        Osi.AddSpell(caster, "SP_Move_Prey_To_Me")
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
        _D(PredPreyTable)
    end
end

function SP_RollResults(eventName, roller, rollSubject, resultType, _, _)
    _P("Result: ")
    _P(resultType)
    if eventName == "SwallowLethalCheck" and resultType ~= 0 then
        _P('Lethal Swallow Success')
        Osi.ApplyStatus(rollSubject, "SP_Swallowed_Lethal", -1, 1, roller)
        Osi.ApplyStatus(roller, "SP_Stuffed_Lethal", -1, 1, roller)
        SP_FillPredPreyTable(roller, rollSubject, 'SP_Target_Vore_Lethal')
    end
    if eventName == "StruggleCheck" and resultType ~= 0 then
        _P('Struggle Success')
        Osi.RemoveStatus(roller, "SP_Swallowed_Lethal")
        SP_SpellCast(rollSubject, "SP_Regurgitate_All")
    end
end

function SP_OnDeath(character)
    if Osi.HasActiveStatus(character, 'SP_Swallowed_Lethal') ~= 0 then
        _P(character .. " Digested")
        local pred = SP_GetPredFromPrey(character)
        Osi.TransferItemsToCharacter(character, pred)
        _P("Inventory Transferred to " .. pred)
        Osi.RemoveStatus(character, 'SP_Swallowed_Lethal')
        _P('Prey Status Removed')
        _D(PredPreyTable)
        if PredPreyTable == nil or next(PredPreyTable[pred]) == nil then
            PredPreyTable[pred] = nil
            Osi.RemoveStatus(pred, 'SP_Stuffed')
            Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
            Osi.RemoveSpell(pred, "SP_Move_Prey_To_Me")
        end
        
    end
end

function SP_GetPredFromPrey(prey)
    _P("Getting Pred from Prey")
    for k, v in pairs(PredPreyTable) do
        for _, j in pairs(v) do
            if prey == j then
                return k
            end
        end
    end
end

function SP_AddWeight(pred, prey)
    _P("Getting total weight of: " .. Osi.ResolveTranslatedString(Osi.GetDisplayName(prey)))

    local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
    if weightPlaceholder.Weight == nil then
        weightPlaceholder.Weight = 0
    end

    weightPlaceholder.Weight = weightPlaceholder.Weight + SP_GetTotalCharacterWeight(prey)
    weightPlaceholder:Sync()
    
    _P("adding weight")
    SP_DelayCall(600, 
    function() 
        if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then 
            Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1) 
        end 
        Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0) 
        SP_DelayCall(100, function() SP_MakeWeightBound(pred) end)
    end
)   
end

function SP_AddWeightIndiv(pred, prey)
    local preyName = Osi.ResolveTranslatedString(Osi.GetDisplayName(prey))
    _P("Getting total weight of: " .. preyName)

    local weightPlaceholder = Ext.Stats.Create(preyName .. "'s Body", "Object", "SP_Prey_Weight")

    local newWeight =  SP_GetTotalCharacterWeight(prey)

    _P("New Weight: " .. newWeight)
    weightPlaceholder.Weight = newWeight
    weightPlaceholder:Sync()

    _P("adding new weight object")
    SP_DelayCall(600, function() if Osi.GetItemByTemplateInUserInventory(NEW_ROOT_TEMPLATE, pred) ~= nil then Osi.TemplateRemoveFrom(NEW_ROOT_TEMPLATE, pred, 1) end Osi.TemplateAddTo(NEW_ROOT_TEMPLATE, pred, 1, 0) end)
    return NEW_ROOT_TEMPLATE

end


function SP_ReduceWeight(pred, prey)

    _P("Getting total weight of: " .. Osi.ResolveTranslatedString(Osi.GetDisplayName(prey)))

    local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
    if weightPlaceholder.Weight == nil then
        weightPlaceholder.Weight = 0
    end



    local newWeight = weightPlaceholder.Weight - SP_GetTotalCharacterWeight(prey)

    if newWeight <= 0.01 then
        newWeight = 0
    end
    _P("New Weight: " .. newWeight*2)
    weightPlaceholder.Weight = newWeight
    weightPlaceholder:Sync()

    _P("subtracting weight")

    SP_DelayCall(600, 
    function() 
        if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then 
            Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1) 
        end 
        if newWeight ~= 0 then 
            Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0) 
        end 
    end
)

end

function SP_RemoveWeightIndiv(pred, rootTemplate)
    _P("removing weight object")
    if Osi.GetItemByTemplateInUserInventory(rootTemplate, pred) ~= nil then 
        Osi.TemplateRemoveFrom(rootTemplate, pred, 1) 
    end


end


function SP_OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
    if PersistentVars['PredPreyTable'] ~= nil then
        _P('updated it')
        PredPreyTable = table.deepcopy(PersistentVars['PredPreyTable'])
    end
end

function SP_On_reset_completed()
    for _, statPath in ipairs(StatPaths) do
        _P(statPath)
        Ext.Stats.LoadStatsFile(statPath,1)
    end
    _P('Reloading stats!')
end

function SP_UpdatePreyPosCombat(obj)
    _P("Turn Changed")
    for k, _ in pairs(PredPreyTable) do
        SP_TelePreyToPred(k)
    end
end

function SP_OnLevelChange(level)
    for k, v in pairs(PredPreyTable) do
        SP_SpellCast(k, 'SP_Regurgitate_All')
    end
end

function SP_OnStatusApplied(object, status, causee, storyActionID)
    if status == 'SP_Swallowed_Lethal_Tick' then
        _P("Applied " .. status .. " Status to" .. object)
        local pred = SP_GetPredFromPrey(object)
        SP_VoreCheck(pred, object, "StruggleCheck")
    elseif status == 'SP_Item_Bound' then
        _P("Applied " .. status .. " Status to" .. object)
    end
end

function SP_TelePreyToPred(pred)
    _P('Prey moved to Pred Location')
    for _, v in pairs(PredPreyTable[pred]) do
        Osi.TeleportTo(v, pred, "", 0, 0, 0, 0, 0)
    end
end


function SP_GetTotalCharacterWeight(character)
    local chardata = Ext.Entity.Get(character)
    _P("Total weight of " .. Osi.ResolveTranslatedString(Osi.GetDisplayName(character)) .. " is " .. (chardata.InventoryWeight.Weight + chardata.Data.Weight)/500 .. " lbs")
    return (chardata.InventoryWeight.Weight + chardata.Data.Weight)/1000
end


function SP_VoreCheck(pred, prey, eventName)

    if eventName == 'StruggleCheck' then
        _P("Rolling struggle check")
        Osi.RequestPassiveRollVersusSkill(prey, pred, "SkillCheck", "Strength", "Constitution", 0, 1, eventName)
    elseif eventName == 'SwallowLethalCheck' then
        _P('Rolling to resist swallow')

        if Osi.HasSkill(prey, "Acrobatics") > Osi.HasSkill(prey, "Athletics") then
            _P('Using Acrobatics')
            Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Acrobatics", 1, 0, eventName)
        else
            _P('Using Athletics')
            Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Athletics", 1, 0, eventName)
        end
    end
end

function SP_AddCustomRegurgitate(caster, characterGUID)
    if Ext.Stats.Get("SP_Regurgitate_" .. characterGUID) == nil then
        
        local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. characterGUID, "SpellData", "SP_Regurgitate_One")
        newRegurgitate.DescriptionParams = Osi.ResolveTranslatedString(Osi.GetDisplayName(characterGUID))
        newRegurgitate.SpellType = "Zone"
        newRegurgitate.Range = 0
        newRegurgitate.Base = 0
        newRegurgitate.Shape = "Square"
        newRegurgitate:Sync()
    end
    SP_DelayCall(600, function() SP_AddCustomRegurgitatePart2(caster, characterGUID) end)
    
end

function SP_AddCustomRegurgitatePart2(caster, characterGUID)
        local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
        local containerList = regurgitateBase.ContainerSpells
        containerList = containerList .. ";SP_Regurgitate_" .. characterGUID
        regurgitateBase.ContainerSpells = containerList
        regurgitateBase:Sync()
        _P(containerList)
        if Osi.HasSpell(caster, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(caster, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(caster, 'SP_Regurgitate', 0, 0)
 
end

function SP_RemoveCustomRegurgitate(characterGUID)
    local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
    local containerList = regurgitateBase.ContainerSpells
    containerList = string.removeSubstring(containerList, ";SP_Regurgitate_" .. characterGUID)
    regurgitateBase.ContainerSpells = containerList
    regurgitateBase:Sync()
    _D(regurgitateBase)
end

function SP_MakeWeightBound(character)
    local itemList = Ext.Entity.Get(character).InventoryOwner.PrimaryInventory:GetAllComponents().InventoryContainer.Items
    _D(itemList)
    for _, v in ipairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
        if Osi.ResolveTranslatedString(Osi.GetDisplayName(uuid)) == 'Weight Placeholder' then
            Osi.ApplyStatus(uuid, 'SP_Item_Bound', -1)
        end
    end
    
end

function SP_DelayCall(msDelay, func)
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId;
    handlerId = Ext.Events.Tick:Subscribe(function()
        if (Ext.Utils.MonotonicTime() - startTime > msDelay) then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end) 
end

function string.removeSubstring(s, substring)
    local x,y = string.find(s, substring)
    if x == nil or y == nil then
        return s
      end
    return string.sub(s,0,x-1) .. string.sub(s,y+1)
end

function table.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[table.deepcopy(orig_key, copies)] = table.deepcopy(orig_value, copies)
            end
            setmetatable(copy, table.deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_InitialSwallowPass)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_SpellCast)
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", SP_UpdatePreyPosCombat)
Ext.Osiris.RegisterListener("RollResult", 6, "after", SP_RollResults)
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", SP_OnLevelChange)
Ext.Osiris.RegisterListener("Died", 1, "after", SP_OnDeath)
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", SP_OnStatusApplied)
Ext.Events.SessionLoaded:Subscribe(SP_OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(SP_On_reset_completed)
