StatPaths={
    "Public/DevouringAndDigesting/Stats/Generated/Data/Armor.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Potions.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Spell_Vore.txt",
}

PersistentVars = {}
PredPreyTable = {} -- Keeps track of who's in who. Preds are keys, values are a numerically indexed list of their prey
RegurDist = 3 -- Determines how far prey spawn when regurgitated

function SP_SpellCast(caster, spell) -- Triggers on spell cast
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
                Osi.TeleportToPosition(v, predX+RegurDist*math.cos(predYRotation), predY, predZ+RegurDist*math.sin(predYRotation), "", 0, 0, 0, 0, 0)
                Osi.RemoveStatus(v, 'SP_Swallowed_Endo', caster)
                Osi.RemoveStatus(v, 'SP_Swallowed_Lethal', caster)
                SP_ReduceWeight(caster, v)
                if v == preyGUID then
                    indexToRemove = k
                end
            end
        end
        if preyGUID ~= "All" then
            Osi.RemoveSpell(caster, 'SP_Regurgitate_' .. preyGUID, 1)
            --SP_RemoveCustomRegurgitate(preyGUID)
            if Osi.HasSpell(characterGUID, 'SP_Regurgitate') ~= 0 then
                Osi.RemoveSpell(characterGUID, 'SP_Regurgitate', 1)
            end
            Osi.AddSpell(characterGUID, 'SP_Regurgitate', 0, 0)
            table.remove(PredPreyTable[caster], indexToRemove)
        end
        _P(preyGUID == 'All')
        _P("preyGUID " .. preyGUID)
        if PredPreyTable == nil or preyGUID == 'All' or next(PredPreyTable[caster]) == nil then
            _P("Clearing Table")
            PredPreyTable[caster] = nil
            Osi.RemoveStatus(caster, 'SP_Stuffed_Endo')
            Osi.RemoveStatus(caster, 'SP_Stuffed_Lethal')
            Osi.RemoveSpell(caster, 'SP_Regurgitate', 1)
            Osi.RemoveSpell(caster, "SP_Move_Prey_To_Me")
        end

        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
    elseif spell == "SP_Move_Prey_To_Me" then
        SP_TelePreyToPred(caster)
    end
end


function SP_OnSpellCastTarget(caster, target, spell) -- Triggers when a spell is cast with a target
    if(PredPreyTable[caster] ~= nil) then
        _P(SP_GetDisplayName(caster) .. " is already a pred; Nested Vore has not been implemented yet!")
        return
    end
    if spell == 'SP_Target_Vore_Endo' then
        _P('Endo Vore')
        if SP_CanFitPrey(caster, target) then
            SP_DelayCall(600, function()
                Osi.ApplyStatus(target, "SP_Swallowed_Endo", -1, 1, caster)
                Osi.ApplyStatus(caster, "SP_Stuffed_Endo", 1, 1, caster)
                SP_FillPredPreyTable(caster, target, 'SP_Target_Vore_Endo')
            end
        )
        end
    end
    if spell == 'SP_Target_Vore_Lethal' then
        _P('Lethal Vore')
        if SP_CanFitPrey(caster, target) then
            SP_DelayCall(600, function() SP_VoreCheck(caster, target, "SwallowLethalCheck") end)
        end
    end
end

function SP_FillPredPreyTable(caster, target, spell) -- Populates the PredPreyTable
    _P("Filling Table")
    if spell == 'SP_Target_Vore_Endo' or spell == 'SP_Target_Vore_Lethal' then
        SP_AddWeight(caster, target)
        if PredPreyTable[caster] == nil then
            PredPreyTable[caster] = {}
        end
        table.insert(PredPreyTable[caster], target)
        --SP_AddCustomRegurgitate(caster, target)
        Osi.AddSpell(caster, 'SP_Regurgitate', 0, 1)

        Osi.AddSpell(caster, "SP_Move_Prey_To_Me")
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
        _D(PredPreyTable)
    end
end

function SP_RollResults(eventName, roller, rollSubject, resultType, _, _) -- Triggers whenever there's a skill check
    if eventName == "SwallowLethalCheck" and resultType ~= 0 then
        _P('Lethal Swallow Success')
        Osi.ApplyStatus(rollSubject, "SP_Swallowed_Lethal", -1, 1, roller)
        Osi.ApplyStatus(roller, "SP_Stuffed_Lethal", 1, 1, roller)
        SP_FillPredPreyTable(roller, rollSubject, 'SP_Target_Vore_Lethal')
    end
    if eventName == "StruggleCheck" and resultType ~= 0 then
        _P('Struggle Success')
        Osi.RemoveStatus(roller, "SP_Swallowed_Lethal")
        SP_SpellCast(rollSubject, "SP_Regurgitate_All")
    end
end

function SP_GetPredFromPrey(prey) -- Given a prey, fetches their pred
    _P("Getting Pred from Prey")
    for k, v in pairs(PredPreyTable) do
        for _, j in pairs(v) do
            if prey == j then
                return k
            end
        end
    end
    return "Not a prey"
end

function SP_AddWeight(pred, prey) -- Adds the weight placeholder object to the pred's inventory
    _P("Getting total weight of: " .. SP_GetDisplayName(prey))

    local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
    if weightPlaceholder.Weight == nil then
        weightPlaceholder.Weight = 0
    end

    weightPlaceholder.Weight = weightPlaceholder.Weight + SP_GetTotalCharacterWeight(prey)
    weightPlaceholder:Sync()
    
    _P("adding weight")
    SP_DelayCall(600, 
    function()
        _P("Is potato in inventory: ")
        _P(Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred))
        if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then 
            Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1) 
        end 
        Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0) 
        SP_DelayCall(100, function() SP_MakeWeightBound(pred) end)
    end
)   
end

function SP_AddWeightIndiv(pred, prey) -- UNUSED adds a single weight placeholder for each prey. Won't function til SE adds Dynamic Template Modification
    local preyName = SP_GetDisplayName(prey)
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


function SP_ReduceWeight(pred, prey) -- Reduces the weight of the weight placeholder object, or removes it if it's weight is small

    _P("Getting total weight of: " .. SP_GetDisplayName(prey))

    local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
    if weightPlaceholder.Weight == nil then
        weightPlaceholder.Weight = 0
    end
    local newWeight = weightPlaceholder.Weight - SP_GetTotalCharacterWeight(prey)

    if newWeight <= 0.1 then
        newWeight = 0
    end
    _P("New Weight: " .. newWeight*2)
    weightPlaceholder.Weight = newWeight
    weightPlaceholder:Sync()

    _P("subtracting weight")

    SP_DelayCall(600, 
    function() 
        _P("Potato in inventory: ")
        _P(Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred))
        if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then 
            Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1) 
        end 
        if newWeight ~= 0 then 
            Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0) 
        end 
    end
)

end

function SP_RemoveWeightIndiv(pred, rootTemplate) -- UNUSED individually removes unique weight placeholder objects from pred's inventory. Won't function til SE adds Dynamic Template Modification
    _P("removing weight object")
    if Osi.GetItemByTemplateInUserInventory(rootTemplate, pred) ~= nil then 
        Osi.TemplateRemoveFrom(rootTemplate, pred, 1) 
    end

end


function SP_OnSessionLoaded() -- runs on session load
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
    if PersistentVars['PredPreyTable'] ~= nil then
        _P('updated it')
        PredPreyTable = table.deepcopy(PersistentVars['PredPreyTable'])
    end
    if PersistentVars['WeightPlaceholderByCategory'] == nil then
        _P('init WeightPlaceholderByCategory')
        PersistentVars['WeightPlaceholderByCategory'] = false
    end
    -- Nothing to config yet lmao
    -- Ext.RegisterConsoleCommand('VoreConfig', SP_VoreConfig);
    -- Ext.RegisterConsoleCommand('VoreConfigOptions', SP_VoreConfigOptions);
end

function SP_On_reset_completed() -- runs when reset command is sent to console
    for _, statPath in ipairs(StatPaths) do
        _P(statPath)
        Ext.Stats.LoadStatsFile(statPath,1)
    end
    _P('Reloading stats!')
end

function SP_UpdatePreyPosCombat(obj) -- runs each turn in combat
    _P("Turn Changed")
    for k, _ in pairs(PredPreyTable) do
        SP_TelePreyToPred(k)
    end
end

function SP_OnLevelChange(level) -- runs whenever you change game regions
    for k, v in pairs(PredPreyTable) do
        SP_SpellCast(k, 'SP_Regurgitate_All')
    end
end

function SP_OnStatusApplied(object, status, causee, storyActionID) -- runs each time a status is applied
    if status == 'SP_Swallowed_Lethal_Tick' then
        _P("Applied " .. status .. " Status to" .. object)
        for _, v in ipairs(PredPreyTable[object]) do
            if Osi.HasActiveStatus(v, 'SP_Swallowed_Lethal') then
                _P(object)
                _P(v)
                SP_VoreCheck(object, v, "StruggleCheck")
            end
        end
        
    elseif status == 'SP_Item_Bound' then
        _P("Applied " .. status .. " Status to" .. object)
    elseif status == "DOWNED" and Osi.HasActiveStatus(object, 'SP_Swallowed_Lethal') ~= 0 then
        _P(object .. " Digested")
        local pred = SP_GetPredFromPrey(object)
        _P("pred name: " .. SP_GetDisplayName(pred))
        _P("prey name: " .. SP_GetDisplayName(object))
        Osi.TransferItemsToCharacter(object, pred)
        _P("Inventory Transferred to " .. pred)
        
    end
end

function SP_OnDeath(character) -- runs when someone dies
    if Osi.HasActiveStatus('SP_Swallowed_Lethal') then
        local pred = SP_GetPredFromPrey(character)
        SP_SpellCast(pred, character)
    end

end

function SP_TelePreyToPred(pred) -- Teleports prey to pred
    _P('Prey moved to Pred Location')
    for _, v in pairs(PredPreyTable[pred]) do
        Osi.TeleportTo(v, pred, "", 0, 0, 0, 0, 0)
    end
end


function SP_GetTotalCharacterWeight(character) -- returns character weight + their inventory weight
    local chardata = Ext.Entity.Get(character)
    _P("Total weight of " .. SP_GetDisplayName(character) .. " is " .. (chardata.InventoryWeight.Weight + chardata.Data.Weight)/500 .. " lbs")
    return (chardata.InventoryWeight.Weight + chardata.Data.Weight)/1000
end

function SP_CanFitPrey(pred, prey) -- checks if eating a character would exceed your carry limit
    local predData = Ext.Entity.Get(pred)
    local predRoom = predData.EncumbranceStats["field_8"] - predData.InventoryWeight.Weight
    
    if SP_GetTotalCharacterWeight(prey) > predRoom then
        _P("Can't fit " .. SP_GetDisplayName(prey) .. " inside of " .. SP_GetDisplayName(pred) .. "'s stomach!")
        return false
    else
        return true
    end
    
end

function SP_VoreCheck(pred, prey, eventName) -- Handles rolling checks

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

function SP_AddCustomRegurgitate(caster, characterGUID) -- adds spell for regurgitating specific creature, currently bugged and unused
    if Ext.Stats.Get("SP_Regurgitate_" .. characterGUID) == nil then     
        local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. characterGUID, "SpellData", "SP_Regurgitate_One")
        newRegurgitate.DescriptionParams = SP_GetDisplayName(characterGUID)
        newRegurgitate:Sync()
    end

    SP_DelayCall(600, 
    function() 
        local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
        local containerList = regurgitateBase.ContainerSpells
        containerList = containerList .. ";SP_Regurgitate_" .. characterGUID
        regurgitateBase.ContainerSpells = containerList
        regurgitateBase:Sync()
        _P("containerList: " .. containerList)
        if Osi.HasSpell(caster, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(caster, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(caster, 'SP_Regurgitate', 0, 1) 
    end
    )
end

function SP_RemoveCustomRegurgitate(characterGUID) -- removes spell for regurgitating specific creature, currently bugged and unused
    local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
    local containerList = regurgitateBase.ContainerSpells
    containerList = string.removeSubstring(containerList, ";SP_Regurgitate_" .. characterGUID)
    _P("containerlist: " .. containerList)
    regurgitateBase.ContainerSpells = containerList
    regurgitateBase:Sync()

    SP_DelayCall(600, 
    function()     
        if Osi.HasSpell(characterGUID, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(characterGUID, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(characterGUID, 'SP_Regurgitate', 0, 1) 
    end
    )
end


function SP_MakeWeightBound(character) -- adds the 'Bound' status to the weight object so that players can't drop it
    local itemList = Ext.Entity.Get(character).InventoryOwner.PrimaryInventory:GetAllComponents().InventoryContainer.Items
    for _, v in ipairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
        if SP_GetDisplayName(uuid) == 'Weight Placeholder' then
            Osi.ApplyStatus(uuid, 'SP_Item_Bound', -1)
        end
    end
end

function SP_GetDisplayName(guid) -- fetches display name of a thing given its GUID
    return Osi.ResolveTranslatedString(Osi.GetDisplayName(guid))
end

function SP_VoreConfig(var, value) -- UNUSED. Console command for changing config variables
    if type(value) ~= "boolean"  and PersistentVars[var] ~= nil then
        PersistentVars[var] = value
    end
end

function SP_VoreConfigOptions() -- UNUSED. Console command for printing config options and states
    _P("Vore Mod Configuration Options: ")
    _P("WeightPlaceholderByCategory")
    _P(" - Divides Weight objects placed in the inventory by creature type. No gameplay difference, just might be fun.")
    _P("Current status: " .. PersistentVars["WeightPlaceholderByCategory"])
    _P("NestedVore")
    _P(" - Allows preds to be eaten by other preds. Very buggy right now, use at your own risk!")
    _P("Current status: " .. PersistentVars["NestedVore"])
end

function SP_DelayCall(msDelay, func) -- Delays a func call my msDelay milliseconds
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId;
    handlerId = Ext.Events.Tick:Subscribe(function()
        if (Ext.Utils.MonotonicTime() - startTime > msDelay) then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end) 
end

function string.removeSubstring(s, substring) -- returns a string with substring removed
    local x,y = string.find(s, substring)
    if x == nil or y == nil then
        return s
      end
    return string.sub(s,0,x-1) .. string.sub(s,y+1)
end

function table.deepcopy(orig, copies) -- returns a deepcopy of a table
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


Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_OnSpellCastTarget)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_SpellCast)
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", SP_UpdatePreyPosCombat)
Ext.Osiris.RegisterListener("RollResult", 6, "after", SP_RollResults)
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", SP_OnLevelChange)
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", SP_OnStatusApplied)
Ext.Osiris.RegisterListener("Died", 1, "after", SP_OnDeath)
Ext.Events.SessionLoaded:Subscribe(SP_OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(SP_On_reset_completed)
