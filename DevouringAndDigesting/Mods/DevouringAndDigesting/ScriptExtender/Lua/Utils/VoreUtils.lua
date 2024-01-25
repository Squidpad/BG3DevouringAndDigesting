Ext.Require("Utils.lua")

PredPreyTable = {} -- Keeps track of who's in who. Preds are keys, values are aa numerically indexed table of their prey. Used for top-down searches.
PreyPredPairs = {} -- Pair dict where keys are prey and values are preds. Way faster to search when going up.
RegurgDist = 3 -- Determines how far prey spawn when regurgitated

---Populates the PredPreyTable and PreyPredPairs.
---@param pred CHARACTER
---@param prey CHARACTER
---@param spell string
function SP_FillPredPreyTable(pred, prey, spell)
    _P("Filling Table")
    if spell == 'SP_Target_Vore_Endo' or spell == 'SP_Target_Vore_Lethal' then
        SP_AddWeight(pred, prey)
        if PredPreyTable[pred] == nil then
            PredPreyTable[pred] = {}
        end
        table.insert(PredPreyTable[pred], prey)
        PreyPredPairs[prey] = pred
        SP_AddCustomRegurgitate(pred, prey)
        Osi.AddSpell(pred, "SP_Regurgitate", 0, 0)
        Osi.AddSpell(pred, "SP_Move_Prey_To_Me")
        PersistentVars['PredPreyTable'] = SP_Deepcopy(PredPreyTable)
        PersistentVars['PreyPredPairs'] = SP_Deepcopy(PreyPredPairs)
        _D(PredPreyTable)
        _D(PreyPredPairs)
    end
end

---@param pred CHARACTER
---@param prey CHARACTER
---@param spell string
function SP_RegurgitatePrey(pred, prey, spell)
    _P('Starting Regurgitation')

    _P('Targets: ' .. prey)
    local predX, predY, predZ = Osi.getPosition(pred)
    -- Y-rotation == yaw
    local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
    -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
    predYRotation = predYRotation * math.pi / 180
    local markedForRemoval = {}
    for tableIndex, predsPrey in pairs(PredPreyTable[pred]) do
        if spell == "SP_Regurgitate_All" or predsPrey == prey then
            -- equation for rotating a vector in the X dimension
            local newX = predX + RegurgDist * math.cos(predYRotation)
            -- equation for rotating a vector in the Z dimension
            local newZ = predZ + RegurgDist * math.sin(predYRotation)
            -- places prey at pred's location, vaguely in front of them
            Osi.TeleportToPosition(predsPrey, newX, predY, newZ, "", 0, 0, 0, 0, 0)
            Osi.RemoveStatus(predsPrey, 'SP_Swallowed_Endo', pred)
            Osi.RemoveStatus(predsPrey, 'SP_Swallowed_Lethal', pred)
            SP_ReduceWeight(pred, predsPrey)
            if predsPrey == prey or prey == 'All' then
                -- mark indexes for delete instead of just deleting them since we're currently iterating through the table, we remove them later
                table.insert(markedForRemoval, tableIndex)
            end
        end
    end
    if prey ~= "All" then
        Osi.RemoveSpell(pred, 'SP_Regurgitate_' .. prey, 1)
        -- SP_RemoveCustomRegurgitate(prey)
        if Osi.HasSpell(pred, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
        for i=#PredPreyTable[pred], 1, -1 do
            -- here's where we remove the prey from the table
            if(SP_TableContains(markedForRemoval, i)) then
                table.remove(PredPreyTable[pred], i)
                local remainingStatusTurns = Osi.GetStatusTurns(pred, 'SP_Stuffed')
                Osi.RemoveStatus(pred, 'SP_Stuffed')
                Ext.OnNextTick(Osi.ApplyStatus(pred, 'SP_Stuffed', (remainingStatusTurns-1) * 6, 1, pred))
            end
        end
        _P("prey removed: " .. prey)
        _D(PredPreyTable[pred])
    end
    _P(prey == 'All')
    _P("prey " .. prey)
    -- if there's no prey anywhere, if the prey was 'All', or this pred's table is now empty
    if next(PredPreyTable) == nil or prey == 'All' or next(PredPreyTable[pred]) == nil then
        _P("Clearing Table")
        PredPreyTable[pred] = nil
        Osi.RemoveStatus(pred, 'SP_Stuffed')
        Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        Osi.RemoveSpell(pred, "SP_Move_Prey_To_Me")
    end
end


---Adds the weight placeholder object to the pred's inventory.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_AddWeight(pred, prey)
    _P("Getting total weight of: " .. SP_GetDisplayNameFromGUID(prey))

    local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
    if weightPlaceholder.Weight == nil then
        weightPlaceholder.Weight = 0
    end

    weightPlaceholder.Weight = weightPlaceholder.Weight + SP_GetTotalCharacterWeight(prey)
    weightPlaceholder:Sync()

    _P("adding weight")
    SP_DelayCallTicks(5, function()
        _P("Is potato in inventory: ")
        _P(Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred))
        if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then
            Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1)
        end
        Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0)
        SP_DelayCallTicks(1, function()
            SP_MakeWeightBound(pred)
        end)
    end)
end

---UNUSED. Adds a single weight placeholder for each prey.
---Won't function til SE adds dynamic template modification,
---or I do something truly gormless like make a rootTemplate
---and item stats for every creature in the game.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_AddWeightIndiv(pred, prey)
    local preyName = SP_GetDisplayNameFromGUID(prey)
    _P("Getting total weight of: " .. preyName)

    local weightPlaceholder = Ext.Stats.Create(preyName .. "'s Body", "Object", "SP_Prey_Weight")

    local newWeight = SP_GetTotalCharacterWeight(prey)

    _P("New Weight: " .. newWeight)
    weightPlaceholder.Weight = newWeight
    weightPlaceholder:Sync()

    _P("adding new weight object")
    local NEW_ROOT_TEMPLATE = '' -- don't know what's supposed to be here, I'll leave it to Squidpad
    SP_DelayCallTicks(5, function()
        if Osi.GetItemByTemplateInUserInventory(NEW_ROOT_TEMPLATE, pred) ~= nil then
            Osi.TemplateRemoveFrom(NEW_ROOT_TEMPLATE, pred, 1)
        end
        Osi.TemplateAddTo(NEW_ROOT_TEMPLATE, pred, 1, 0)
    end)
    return NEW_ROOT_TEMPLATE
end

---Reduces the weight of the weight placeholder object, or removes it if it's weight is small.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_ReduceWeight(pred, prey)
    _P("Getting total weight of: " .. SP_GetDisplayNameFromGUID(prey))

    local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
    if weightPlaceholder.Weight == nil then
        weightPlaceholder.Weight = 0
    end
    local newWeight = weightPlaceholder.Weight - SP_GetTotalCharacterWeight(prey)

    if newWeight <= 0.1 then
        newWeight = 0
    end
    _P("New Weight: " .. newWeight * 2)
    weightPlaceholder.Weight = newWeight
    weightPlaceholder:Sync()

    _P("subtracting weight")

    SP_DelayCallTicks(5, function()
        _P("Potato in inventory: ")
        _P(Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred))
        if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then
            Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1)
        end
        if newWeight ~= 0 then
            Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0)
        end
    end)
end

---UNUSED. Individually removes unique weight placeholder objects from pred's inventory.
---Won't function til SE adds dynamic template modification,
---or I do something truly gormless like make a rootTemplate
---and item stats for every creature in the game.
---@param pred CHARACTER
---@param itemTemplate ITEMROOT rootTemplate of weight placeholder item.
function SP_RemoveWeightIndiv(pred, itemTemplate)
    _P("removing weight object")
    if Osi.GetItemByTemplateInUserInventory(itemTemplate, pred) ~= nil then
        Osi.TemplateRemoveFrom(itemTemplate, pred, 1)
    end
end

---Teleports prey to pred.
---@param pred CHARACTER
function SP_TelePreyToPred(pred)
    _P('Prey moved to Pred Location')
    for _, v in pairs(PredPreyTable[pred]) do
        Osi.TeleportTo(v, pred, "", 0, 0, 0, 0, 0)
    end
end

---Checks if eating a character would exceed your carry limit.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_CanFitPrey(pred, prey)
    local predData = Ext.Entity.Get(pred)
    local predRoom = predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight

    if SP_GetTotalCharacterWeight(prey) > predRoom then
        _P("Can't fit " .. SP_GetDisplayNameFromGUID(prey) .. " inside of " .. SP_GetDisplayNameFromGUID(pred) ..
               "'s stomach!")
        return false
    else
        return true
    end
end

---Recursively finds the top-level predator, given a prey
---@param prey CHARACTER
function SP_GetApexPred(prey)
    if PreyPredPairs[prey] == nil then
        return prey
    else
        return SP_GetApexPred(PreyPredPairs[prey])
    end
end

---Handles rolling checks.
---@param pred CHARACTER
---@param prey CHARACTER
---@param eventName string Name that RollResult should look for. No predetermined values, can be whatever.
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

---UNUSED. Adds spell for regurgitating specific creature, currently bugged.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_AddCustomRegurgitate(pred, prey)
    if Ext.Stats.Get("SP_Regurgitate_" .. prey) == nil then
        local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. prey, "SpellData", "SP_Regurgitate_One")
        newRegurgitate.DescriptionParams = SP_GetDisplayNameFromGUID(prey)
        newRegurgitate:Sync()
    end

    SP_DelayCallTicks(5, function()
        local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
        local containerList = regurgitateBase.ContainerSpells
        containerList = containerList .. ";SP_Regurgitate_" .. prey
        regurgitateBase.ContainerSpells = containerList
        regurgitateBase:Sync()
        _P("containerList: " .. containerList)
        if Osi.HasSpell(pred, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(pred, 'SP_Regurgitate', 0, 1)
    end)
end

---UNUSED. Removes spell for regurgitating specific creature, currently bugged.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_RemoveCustomRegurgitate(pred, prey)
    local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
    local containerList = regurgitateBase.ContainerSpells
    containerList = SP_RemoveSubstring(containerList, ";SP_Regurgitate_" .. prey)
    _P("containerlist: " .. containerList)
    regurgitateBase.ContainerSpells = containerList
    regurgitateBase:Sync()

    SP_DelayCallTicks(5, function()
        if Osi.HasSpell(pred, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(pred, 'SP_Regurgitate', 0, 1)
    end)
end

---Adds the 'Bound' status to the weight object so that players can't drop it.
---@param pred CHARACTER
function SP_MakeWeightBound(pred)
    local itemList = Ext.Entity.Get(pred).InventoryOwner.PrimaryInventory:GetAllComponents().InventoryContainer.Items
    for _, v in ipairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
        if SP_GetDisplayNameFromGUID(uuid) == 'Weight Placeholder' then
            Osi.ApplyStatus(uuid, 'SP_Item_Bound', -1)
        end
    end
end

---UNUSED. Console command for changing config variables.
---@param var string Name of the variable to change.
---@param value boolean Value to change the variable to. If omitted, the variable will be inverted, if possible.
function SP_VoreConfig(var, value)
    if PersistentVars[var] ~= nil then
        if type(value) == "boolean" then
            PersistentVars[var] = value
        elseif type(value) == nil then
            if type(PersistentVars[var]) == "boolean" then
                PersistentVars[var] = not PersistentVars[var]
            else
                _P("Not a boolean value")
            end
        end
    end
end

---UNUSED. Console command for printing config options and states.
function SP_VoreConfigOptions()
    _P("Vore Mod Configuration Options: ")
    _P("WeightPlaceholderByCategory")
    _P(" - Divides Weight objects placed in the inventory by creature type. No gameplay difference, just might be fun.")
    _P("Current status: " .. PersistentVars["WeightPlaceholderByCategory"])
    _P("NestedVore")
    _P(" - Allows preds to be eaten by other preds. Very buggy right now, use at your own risk!")
    _P("Current status: " .. PersistentVars["NestedVore"])
end
