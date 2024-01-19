-- B-Tree implementation by mindreframer on GitHub
-- what a legend, did it in 3 langauges in a single commit

--Ext.Require("Utils/")

PredPreyTable = {} -- Keeps track of who's in who. Preds are keys, values are a numerically indexed list of their prey
RegurgDist = 3 -- Determines how far prey spawn when regurgitated

---@param pred GUIDSTRING @guid of pred
---@param prey GUIDSTRING @guid of prey
---@param spell string @internal name of spell
function SP_FillPredPreyTable(pred, prey, spell) -- Populates the PredPreyTable
    _P("Filling Table")
    if spell == 'SP_prey_Vore_Endo' or spell == 'SP_prey_Vore_Lethal' then
        SP_AddWeight(pred, prey)
        if PredPreyTable[pred] == nil then
            PredPreyTable[pred] = {}
        end
        table.insert(PredPreyTable[pred], prey)
        --SP_AddCustomRegurgitate(pred, prey)
        Osi.AddSpell(pred, 'SP_Regurgitate', 0, 1)

        Osi.AddSpell(pred, "SP_Move_Prey_To_Me")
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
        _D(PredPreyTable)
    end
end

---@param pred GUIDSTRING @guid of pred
---@param prey GUIDSTRING @guid of prey
function SP_RegurgitatePrey(pred, prey)
    _P('Starting Regurgitation')

    _P('Targets: ' .. prey)
    local predX, predY, predZ = Osi.getPosition(caster)
    local predXRotation, predYRotation, predZRotation = Osi.GetRotation(caster) -- Y-rotation == yaw
    predYRotation = predYRotation * math.pi / 180 -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
    local markedForRemoval = {}
    for k, v in pairs(PredPreyTable[caster]) do
        if spell == "SP_Regurgitate_All" or v == prey then
            local newX = predX+RegurgDist*math.cos(predYRotation) -- equation for rotating a vector in the X dimension
            local newZ = predZ+RegurgDist*math.sin(predYRotation) -- equation for rotating a vector in the Z dimension
            Osi.TeleportToPosition(v, newX, predY, newZ, "", 0, 0, 0, 0, 0) -- places prey at pred's location, vaguely in front of them.
            Osi.RemoveStatus(v, 'SP_Swallowed_Endo', caster)
            Osi.RemoveStatus(v, 'SP_Swallowed_Lethal', caster)
            SP_ReduceWeight(caster, v)
            if v == prey then
                table.insert(markedForRemoval, k) -- mark indecies for delete instead of just deleting them since we're currently iterating through the table, we remove them later
            end
        end
    end
    if prey ~= "All" then
        Osi.RemoveSpell(caster, 'SP_Regurgitate_' .. prey, 1)
        --SP_RemoveCustomRegurgitate(prey)
        if Osi.HasSpell(characterGUID, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(characterGUID, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(characterGUID, 'SP_Regurgitate', 0, 0)
        for _, v in ipairs(markedForRemoval) do -- here's where we remove the prey from the table
            table.remove(PredPreyTable[caster], v)
            local remainingStatusTurns = Osi.GetStatusTurns(pred, statusID)
        end
        _P("prey removed: " .. prey)
        _D(PredPreyTable[caster])
    end
    _P(prey == 'All')
    _P("prey " .. prey)
    if next(PredPreyTable) == nil or prey == 'All' or next(PredPreyTable[caster]) == nil then -- if there's no prey anywhere, if the prey was 'All', or this pred's table is now empty
        _P("Clearing Table")
        PredPreyTable[caster] = nil
        Osi.RemoveStatus(caster, 'SP_Stuffed_Endo')
        Osi.RemoveStatus(caster, 'SP_Stuffed_Lethal')
        Osi.RemoveSpell(caster, 'SP_Regurgitate', 1)
        Osi.RemoveSpell(caster, "SP_Move_Prey_To_Me")
    end
end

---@param prey GUIDSTRING @guid of prey
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
    _P("Getting total weight of: " .. SP_GetDisplayNameFromGUID(prey))

    local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
    if weightPlaceholder.Weight == nil then
        weightPlaceholder.Weight = 0
    end

    weightPlaceholder.Weight = weightPlaceholder.Weight + SP_GetTotalCharacterWeight(prey)
    weightPlaceholder:Sync()
    
    _P("adding weight")
    SP_DelayCallTicks(5, 
    function()
        _P("Is potato in inventory: ")
        _P(Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred))
        if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then 
            Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1) 
        end 
        Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0) 
        SP_DelayCallTicks(1, function() SP_MakeWeightBound(pred) end)
    end
)   
end

function SP_AddWeightIndiv(pred, prey) -- UNUSED adds a single weight placeholder for each prey. Won't function til SE adds Dynamic Template Modification
    local preyName = SP_GetDisplayNameFromGUID(prey)
    _P("Getting total weight of: " .. preyName)

    local weightPlaceholder = Ext.Stats.Create(preyName .. "'s Body", "Object", "SP_Prey_Weight")

    local newWeight =  SP_GetTotalCharacterWeight(prey)

    _P("New Weight: " .. newWeight)
    weightPlaceholder.Weight = newWeight
    weightPlaceholder:Sync()

    _P("adding new weight object")
    SP_DelayCallTicks(5, function() if Osi.GetItemByTemplateInUserInventory(NEW_ROOT_TEMPLATE, pred) ~= nil then Osi.TemplateRemoveFrom(NEW_ROOT_TEMPLATE, pred, 1) end Osi.TemplateAddTo(NEW_ROOT_TEMPLATE, pred, 1, 0) end)
    return NEW_ROOT_TEMPLATE

end


function SP_ReduceWeight(pred, prey) -- Reduces the weight of the weight placeholder object, or removes it if it's weight is small

    _P("Getting total weight of: " .. SP_GetDisplayNameFromGUID(prey))

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

    SP_DelayCallTicks(5, 
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

function SP_TelePreyToPred(pred) -- Teleports prey to pred
    _P('Prey moved to Pred Location')
    for _, v in pairs(PredPreyTable[pred]) do
        Osi.TeleportTo(v, pred, "", 0, 0, 0, 0, 0)
    end
end




function SP_CanFitPrey(pred, prey) -- checks if eating a character would exceed your carry limit
    local predData = Ext.Entity.Get(pred)
    local predRoom = predData.EncumbranceStats["field_8"] - predData.InventoryWeight.Weight
    
    if SP_GetTotalCharacterWeight(prey) > predRoom then
        _P("Can't fit " .. SP_GetDisplayNameFromGUID(prey) .. " inside of " .. SP_GetDisplayNameFromGUID(pred) .. "'s stomach!")
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

function SP_AddCustomRegurgitate(pred, characterGUID) -- adds spell for regurgitating specific creature, currently bugged and unused
    if Ext.Stats.Get("SP_Regurgitate_" .. characterGUID) == nil then     
        local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. characterGUID, "SpellData", "SP_Regurgitate_One")
        newRegurgitate.DescriptionParams = SP_GetDisplayNameFromGUID(characterGUID)
        newRegurgitate:Sync()
    end

    SP_DelayCallTicks(5, 
    function() 
        local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
        local containerList = regurgitateBase.ContainerSpells
        containerList = containerList .. ";SP_Regurgitate_" .. characterGUID
        regurgitateBase.ContainerSpells = containerList
        regurgitateBase:Sync()
        _P("containerList: " .. containerList)
        if Osi.HasSpell(pred, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(pred, 'SP_Regurgitate', 0, 1) 
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

    SP_DelayCallTicks(5, 
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
        if SP_GetDisplayNameFromGUID(uuid) == 'Weight Placeholder' then
            Osi.ApplyStatus(uuid, 'SP_Item_Bound', -1)
        end
    end
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