Ext.Require("Utils/Config.lua")

-- Needs to be here to prevent PCs from being teleported beneath the map.
-- Maybe it is better to teleport them.
-- 1. When you click on companion's portrait, camera will move to them, which
-- will force the game to load the world around them. If they are teleported
-- outside of the map (not beneath), there is nothing to load.
-- 2. When an character dies, their body becomes lootable. Even if they are
-- invisible and detached, the player can still highlight & loot them with alt key.
local CompanionsSet = {
    ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = true,
    ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = true,
    ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = true,
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = true,
    ["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = true,
    ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = true,
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = true,
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = true,
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = true,
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = true,
}

-- Keys and Names of Digestion type statuses, keys are value of VoreData[character].Digestion
DigestionTypes = {
    [0] = "SP_Swallowed_Endo",
    [1] = "SP_Swallowed_Dead",
    [2] = "SP_Swallowed_Lethal",
    [3] = "None"
}


-- Keys and Names of Locus type statuses, keys are values of VoreData[character].Prey
VoreLoci = {
    ['O'] = "SP_Swallowed_Oral",
    ['A'] = "SP_Swallowed_Anal",
    ['U'] = "SP_Swallowed_Unbirth",
    ['C'] = "SP_Swallowed_Cock",
}

-- A new way to store data about every character that is involved in vore
VoreData = {}

-- ApplyStatus applies statuses for a number of seconds instead of turns.
-- Multiply the duration by this.
SecondsPerTurn = 6

-- CharacterCreationAppearanceVisuals table for women.
-- Goes like this: race -> bodyshape (1 == weak, 2 == strong) -> belly size.
BellyTableFemale = {
    Human = {
        {
            "5b04165d-2ec9-47f9-beff-0660640fc602", "5660e004-e2af-4f3a-ae76-375408cb78c3",
            "65a6eeac-9a14-4937-92b8-5e50bb960074",
            "fafef7ab-087f-4362-9436-3e63ef7bcd95", "4a404594-e28d-4f47-b1c2-2ef593961e33",
            "78fc1e05-ee83-4e6c-b14f-6f116e875b03", "b10b965b-9620-48c2-9037-0556fd23d472",
            "14388c37-34ab-4963-b61e-19cea0a90e39",
        }, {
            "4bfa882a-3bef-49b8-9e8a-21198a2dbee5", "4741a71a-8884-4d3d-929d-708e350953bb",
            "c2042e11-0626-440b-bee0-bb1d631fd979",
            "9950ba83-28ea-4680-9905-a070d6eabfe7", "4e698e03-94b8-4526-9fa5-5feb1f78c3b0",
            "e250ffe9-a94c-44b4-a225-f8cf61ad430d", "02c9846c-200d-47cb-b381-1ceeb4280774",
            "73aae7c2-49ef-4cac-b1b9-b3cfa6a4a31a",
        },
    },
}

-- Set to true on load if the subclass addon mod is detected.
-- Seems to me like the best way to properly integrate things without making
-- the addon a requirement.
SubclassAddOn = false

---Adds or deletes VoreData of a character
---@param character CHARACTER
---@param create boolean? will not delete entry if true
function SP_VoreDataEntry(character, create)
    if VoreData[character] == nil and create then
        _P("Adding character " .. character)
        SP_NewVoreDataEntry(character)
    elseif VoreData[character].Pred == nil and next(VoreData[character].Prey) == nil and VoreData[character].Items == ""
    and VoreData[character].Fat == 0 and VoreData[character].AddWeight == 0 and VoreData[character].Satiation == 0 and
    not create then
        _P("Removing character " .. character)
        VoreData[character] = nil
    else
        _P("Skipping character " .. character)
    end
end

---@param character CHARACTER
function SP_NewVoreDataEntry(character)
    VoreData[character] = {}
    -- pred of this character
    VoreData[character].Pred = nil
    -- weight of this character, only for prey, 0 for preds. This is dynamically changed
    VoreData[character].Weight = 0
    -- weight of this character, only for prey, 0 for preds. This is stored to keep the track of digestion process
    VoreData[character].FixedWeight = 0
    -- by how much prey's weight was reduced by pred's perks
    VoreData[character].WeightReduction = 0
    -- if a tag that disables downed state was appled on swallow. Should be false for non-prey
    VoreData[character].DisableDowned = false
    --- "O" == Oral, "A" == Anal, "U" == Unbirth
    -- 0 == endo, 1 == dead, 2 == lethal, 3 == none. Since the statuses might be changed in the future, 
    -- it's not reliable to ask osiris if a character has a status,
    -- so we make all non-dead prey count as endoed during migration
    VoreData[character].Digestion = {["O"]=3, ["A"]=3, ["U"]=3}
    -- if the items are being digested
    VoreData[character].DigestItems = false
    -- guid of combat character is in
    VoreData[character].Combat = Osi.CombatGetGuidFor(character) or ""
    -- This is a set, not an array, for an easier search of a specific prey, so use k instead of v when iterating
   -- use next(VoreData[character].Prey) == nil instead of #VoreData[character].Prey == 0 to check if it's empty
    -- value of the prey is the method used to eat them: "O" == "Oral", "A" == "Anal", "U" == "Unbirth", "C" == "Cock"
    VoreData[character].Prey = {}
    VoreData[character].Items = ""
    -- For weigth gain, only visually increases the size of belly
    VoreData[character].Fat = 0
    -- Belly weight that does not belong to a specific prey
    -- The difference between this and fat is that fat does not affect carry capacity and is purely visual
    -- AddWeight is reduced at the same rate as normal prey digestion, while Fat uses a separate value
    VoreData[character].AddWeight = 0
    VoreData[character].SwallowProcess = 0
    -- stores satiation that decreases hunger stacks
    VoreData[character].Satiation = 0
    -- prey only
    VoreData[character].Locus = ""
    VoreData[character].Swallowed = ""
end


---This adds a prey to pred without updating pred's weight or saving table
---Separated this from SP_SwallowPrey to create SP_SwallowPreyMultiple
---Otherwise the UpdateWeight will be called multiple times on the same tick, which will break osiris
---Also SP_Stuffed should not be applied and removed multiple times on the same tick
---Remember to save VoreData after calling this
---@param pred CHARACTER
---@param prey CHARACTER
---@param digestionType integer type of digestion 0 == endo, 1 == dead, 2 == lethal, 3 == none.
---@param notNested boolean If prey is not transferred to another stomach.
---@param swallowStages boolean? If swallow happens in multiple stages
---@return integer statusStacks
---@param locus string
function SP_AddPrey(pred, prey, digestionType, notNested, swallowStages, locus)
    SP_VoreDataEntry(prey, true)

    if digestionType >= 3 then
        _P("Swallowng a character with a wrong status, error")
        return -1
    end

    VoreData[prey].Digestion = digestionType
    VoreData[prey].Locus = locus
    
    VoreData[pred].Prey[prey] = locus
    local statusStacks = SP_TableLength(VoreData[pred].Prey)
    for k, v in pairs(VoreData[prey].Prey) do
        statusStacks = statusStacks + Osi.GetStatusTurns(k, 'SP_Stuffed') + 1
    end
    
    if notNested then
        Osi.SetDetached(prey, 1)
        Osi.SetVisible(prey, 0)
        
        -- Instead of add weight.
        local weight = math.floor(SP_GetTotalCharacterWeight(prey)) - VoreData[prey].AddWeight
        -- in case the weight of prey's prey was reduced by prey's passive and
        -- prey's inventory weight + character weight does not reflect the full weight of their prey
        for k, v in pairs(VoreData[prey].Prey) do
            weight = weight + VoreData[k].WeightReduction
        end
        VoreData[prey].Weight = weight
        VoreData[prey].FixedWeight = weight
        -- Tag that disables downed state.
        if Osi.IsTagged(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22') ~= 1 then
            Osi.SetTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
            VoreData[prey].DisableDowned = true
        end

        if ConfigVars.SwallowDown.value and swallowStages then
            VoreData[prey].SwallowProcess = 1
            --if swallowType == 0 then
            --    VoreData[prey].SwallowProcess = VoreData[prey].SwallowProcess - 1
            --end
        end
        if VoreData[prey].SwallowProcess > 0 then

            Osi.ApplyStatus(prey, "SP_PartiallySwallowed", VoreData[prey].SwallowProcess * SecondsPerTurn, 1, pred)
            Osi.AddSpell(pred, 'SP_SwallowDown', 0, 0)
            VoreData[prey].Swallowed = "SP_PartiallySwallowed"
        else
            VoreData[prey].SwallowProcess = 0
            Osi.ApplyStatus(prey, DigestionTypes[digestionType], 1 * SecondsPerTurn, 1, pred)
            Osi.ApplyStatus(prey, VoreLoci[locus], 1 * SecondsPerTurn, 1, pred)
            Osi.ApplyStatus(prey, "SP_Swallowed", 100 * SecondsPerTurn, 1, pred)
            VoreData[prey].Swallowed = "SP_Swallowed"
        end
    else
        Osi.ApplyStatus(prey, DigestionTypes[digestionType], 1 * SecondsPerTurn, 1, pred)
        Osi.ApplyStatus(prey, VoreLoci[locus], 1 * SecondsPerTurn, 1, pred)
    end
    -- if a character who is inside of stomach swallows someone else who is in the same stomach
    if VoreData[pred].Pred ~= nil and VoreData[pred].Pred == VoreData[prey].Pred then
        VoreData[pred].Weight = VoreData[pred].Weight + VoreData[prey].Weight + VoreData[prey].AddWeight
        VoreData[pred].FixedWeight = VoreData[pred].FixedWeight + VoreData[prey].Weight + VoreData[prey].AddWeight
    end

    VoreData[prey].Pred = pred

    return statusStacks
end


---Should be called in any situation when prey must be swallowed.
---@param pred CHARACTER
---@param prey CHARACTER
---@param swallowType integer Internal name of Status Effect.
---@param notNested boolean If prey is not transferred to another stomach.
---@param swallowStages boolean If swallow happens in multiple stages
---@param locus string
function SP_SwallowPrey(pred, prey, swallowType, notNested, swallowStages, locus)
    _P('Swallowing')

    SP_VoreDataEntry(pred, true)

    local statusStacks = SP_AddPrey(pred, prey, swallowType, notNested, swallowStages, locus)

    Osi.RemoveStatus(pred, "SP_Stuffed")
    Osi.ApplyStatus(pred, "SP_Stuffed", statusStacks * SecondsPerTurn, 1, pred)
    Osi.ApplyStatus(pred, "SP_Pacifist_Aura_Pred", -1)
    Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
    Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)

    SP_UpdateWeight(pred)
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
    _D(VoreData)
    _P('Swallowing END')
end


---Should be called in any situation when multiple prey must be swallowed.
---@param pred CHARACTER
---@param preys table array of preys
---@param swallowType integer
---@param notNested boolean If prey is not transferred to another stomach.
---@param swallowStages boolean If swallow happens in multiple stages
---@param locus string
function SP_SwallowPreyMultiple(pred, preys, swallowType, notNested, swallowStages, locus)
    _P('Swallowing multiple')

    SP_VoreDataEntry(pred, true)

    local statusStacks = 0
    for _, v in ipairs(preys) do
        statusStacks = statusStacks + SP_AddPrey(pred, v, swallowType, notNested, swallowStages, locus)
    end

    Osi.ApplyStatus(pred, "SP_Stuffed", statusStacks * SecondsPerTurn, 1, pred)
    Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
    Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)


    SP_UpdateWeight(pred)
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
    _P('Swallowing END')
end

---finishes swallowing a character in SwallowDown is enabled
---@param pred CHARACTER
---@param prey CHARACTER
---@param digestionType integer Internal name of Status Effect.
---@param voreLocus string type of vore Oral, Anal, or Unbirth
function SP_FullySwallow(pred, prey, digestionType, voreLocus)
    _P('Full swallow')
    Osi.ApplyStatus(prey, DigestionTypes[digestionType], 1 * SecondsPerTurn, 1, pred)
    Osi.ApplyStatus(prey, VoreLoci[voreLocus], 1 * SecondsPerTurn, 1, pred)
    Osi.ApplyStatus(prey, "SP_Swallowed", 100 * SecondsPerTurn, 1, pred)
    local removeSD = true
    for k, v in pairs(VoreData[pred].Prey) do
        if VoreData[k].SwallowProcess > 0 then
            removeSD = false
        end
    end
    if removeSD then
        Osi.RemoveSpell(pred, 'SP_SwallowDown')
        Osi.AddSpell(pred, "SP_Target_Swallow_Endo", 0, 0)
        Osi.AddSpell(pred, "SP_Target_Swallow_Lethal", 0, 0)
    end
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
end



---finishes swallowing a character in SwallowDown is enabled
---@param pred CHARACTER
---@param prey CHARACTER
function SP_FullySwallow(pred, prey)
    _P('Full swallow')
    Osi.ApplyStatus(prey, DigestionTypes[VoreData[prey].Digestion], 1 * SecondsPerTurn, 1, pred)
    Osi.ApplyStatus(prey, VoreLoci[VoreData[prey].Locus], 1 * SecondsPerTurn, 1, pred)
    Osi.ApplyStatus(prey, "SP_Swallowed", 100 * SecondsPerTurn, 1, pred)
    VoreData[prey].Swallowed = "SP_Swallowed"
    local removeSD = true
    for k, v in pairs(VoreData[pred].Prey) do
        if VoreData[k].SwallowProcess > 0 then
            removeSD = false
        end
    end
    if removeSD then
        Osi.RemoveSpell(pred, 'SP_SwallowDown')
    end
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
end


---Swallow an item.
---@param pred CHARACTER
---@param item GUIDSTRING
function SP_SwallowItem(pred, item)

    SP_VoreDataEntry(pred, true)

    if  Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1 then
        if next(VoreData[pred].Prey) == nil and VoreData[pred].Items == "" then
            Osi.ApplyStatus(pred, "SP_Stuffed", 1 * SecondsPerTurn, 1, pred)
            Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
            Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)
        end
        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.ToInventory(item, VoreData[pred].Items, 9999, 0, 0)

        PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
        if Ext.Debug.IsDeveloperMode then
            local modvars = GetVoreData()
            modvars.VoreData = SP_Deepcopy(VoreData)
        end
        SP_DelayCallTicks(4, function()
            SP_UpdateWeight(pred)
        end)
    else
        Osi.TemplateAddTo('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1, 0)
        SP_DelayCallTicks(4, function()
            SP_SwallowItem(pred, item)
        end)
    end
end

---Swallow all items from a container.
---This should be only used for moving items between prey and pred during nested vore,
---since it does not check if items fit in pred's inventory.
---@param pred CHARACTER
---@param container GUIDSTRING
function SP_SwallowAllItems(pred, container)

    SP_VoreDataEntry(pred, true)

    if Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1 then
        if next(VoreData[pred].Prey) == nil and VoreData[pred].Items == "" then
            Osi.ApplyStatus(pred, "SP_Stuffed", 1 * SecondsPerTurn, 1, pred)
            Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
            Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)
        end
        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.MoveAllItemsTo(container, VoreData[pred].Items, 0, 0, 0, 0)
        Osi.MoveAllStoryItemsTo(container, VoreData[pred].Items, 0, 0)
        
        PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
        if Ext.Debug.IsDeveloperMode then
            local modvars = GetVoreData()
            modvars.VoreData = SP_Deepcopy(VoreData)
        end
        SP_DelayCallTicks(4, function()
            SP_UpdateWeight(pred)
        end)
    else
        Osi.TemplateAddTo('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1, 0)
        SP_DelayCallTicks(4, function()
            SP_SwallowAllItems(pred, container)
        end)
    end
end

---Should be called in any situation when prey must be released, including pred's death.
---@param pred CHARACTER
---@param preyString GUIDSTRING | string either guid of prey, or "All" to regurigitate all prey in given locus
---@param preyState integer State of prey to regurgitate: 0 == alive, 1 == dead, -1 == all.
---@param spell? string Internal name of spell (this does not reflect the in-game spell used).
---@param locus? string 
function SP_RegurgitatePrey(pred, preyString, preyState, spell, locus)
    _P('Starting Regurgitation')

    SP_VoreDataEntry(pred, true)

    _P('Targets: ' .. preyString)
    local markedForRemoval = {}
    local markedForSwallow = {}
    local markedForErase = {}

    -- Find prey to remove, clear their status, mark them for removal.
    for prey, v in pairs(VoreData[pred].Prey) do
        if not locus or v == locus then
            local isReal = Osi.IsCharacter(prey)
            if isReal ~= 1 then
                table.insert(markedForErase, prey)
            end
        

            -- this is needed to regurgitate lethal vore characters when using regurgitation spell
            local stateCheck = VoreData[prey].Digestion
            if stateCheck == 2 then
                stateCheck = 0
            end
            if locus == "" then
                locus = nil
            end

            if isReal == 1 and (locus == nil or v == locus) and (preyString == "All" or prey == preyString) and (preyState == -1 or
            (stateCheck == preyState and (preyState ~= 1 or (VoreData[prey].Weight <= VoreData[prey].FixedWeight // 5)))) then
                _P('Pred:' .. pred)
                _P('Prey:' .. prey)
                VoreData[pred].Prey[prey] = nil
                -- Voreception
                if VoreData[pred].Pred ~= nil then
                    -- reduce pred weight in prey weight tables, since they are both prey and pred
                    VoreData[pred].Weight = VoreData[pred].Weight - VoreData[prey].Weight - VoreData[prey].AddWeight
                    VoreData[pred].FixedWeight = VoreData[pred].FixedWeight - VoreData[prey].Weight - VoreData[prey].AddWeight
                    table.insert(markedForSwallow, prey)
                    -- If no voreception, free prey.
                else
                    table.insert(markedForRemoval, prey)
                end
            end
        end
    end

    local regItems = false
    if VoreData[pred].Items ~= "" and preyState ~= 1 and spell ~= "LevelChange" and preyString == 'All' then

        regItems = true
        if VoreData[pred].Pred ~= nil then
            local weightDiff = Ext.Entity.Get(VoreData[pred].Items).InventoryWeight.Weight // 1000
            VoreData[pred].Weight = VoreData[pred].Weight - weightDiff
            VoreData[pred].FixedWeight = VoreData[pred].FixedWeight - weightDiff
            SP_SwallowAllItems(VoreData[pred].Pred, VoreData[pred].Items)
        else
            local itemList = Ext.Entity.Get(VoreData[pred].Items).InventoryOwner.PrimaryInventory:GetAllComponents()
                                 .InventoryContainer.Items

            if #itemList > 0 then
                -- Prevents items from being stuck in each other by placing them in circle around pred.
                local rotationOffset = 0
                local rotationOffset1 = 360 // (#itemList)
                for k, v in pairs(itemList) do
                    local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
                    local predX, predY, predZ = Osi.getPosition(pred)
                    -- Y-rotation == yaw.
                    local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
                    -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
                    predYRotation = (predYRotation + rotationOffset) * math.pi / 180
                    -- Equation for rotating a vector in the X dimension.
                    local newX = predX + ConfigVars.RegurgDist.value * math.cos(predYRotation)
                    -- Equation for rotating a vector in the Z dimension.
                    local newZ = predZ + ConfigVars.RegurgDist.value * math.sin(predYRotation)
                    -- Places prey at pred's location, vaguely in front of them.
                    Osi.ItemMoveToPosition(uuid, newX, predY, newZ, 100000, 100000)
                    _P("Moved Item " .. uuid)
                    rotationOffset = rotationOffset + rotationOffset1
                end
            end 
        end
        -- This delay is important, otherwise items would be deleted.
        VoreData[pred].Items = ""
        SP_DelayCallTicks(4, function()
            Osi.TemplateRemoveFrom('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1)
        end)
    end

    -- Check if no one was regurgitated, just for debug
    if #markedForRemoval == 0 then
        _P("WARNING, no character was regurgitated by " .. pred)
    end

    -- transfers prey to pred's pred for nested vore
    if #markedForSwallow > 0 then
        SP_SwallowPreyMultiple(VoreData[pred].Pred, markedForSwallow, VoreData[pred].Digestion, false, false, VoreData[pred].Locus)
    end

    -- stops digesting items if nothing is being digested in the stomach of the pred
    local stopDigestingItems = true
    for k, v in pairs(VoreData[pred].Prey) do
        if VoreData[k].Digestion[v] == 2 then
            stopDigestingItems = false
        end
    end
    if stopDigestingItems and VoreData[pred].Items == "" then
        VoreData[pred].DigestItems = false
    end

    -- Remove regurgitated prey from the table and release them
    for _, prey in ipairs(markedForRemoval) do
        -- moved this whole section here, so all changes to prey in VoreData are located in one place
        -- remove weight.
        if spell == 'Absorb' then
            local predData = Ext.Entity.Get(pred)
            local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] -
                                 predData.InventoryWeight.Weight - 100)
            _P("Predroom: " .. predRoom)
            local itemList = Ext.Entity.Get(prey).InventoryOwner.Inventories

            local rotationOffset = 0
            local rotationOffset1 = 360 // 30

            for _, t in pairs(itemList) do
                local nextInventory = t:GetAllComponents().InventoryContainer.Items

                for _, v2 in pairs(nextInventory) do
                    local uuid = v2.Item:GetAllComponents().Uuid.EntityUuid
                    local itemWeight = v2.Item.Data.Weight

                    if predRoom > itemWeight then
                        Osi.ToInventory(uuid, pred, 9999, 0, 0)
                        predRoom = predRoom - itemWeight
                    else
                        local predX, predY, predZ = Osi.getPosition(pred)
                        local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
                        predYRotation = (predYRotation + rotationOffset) * math.pi / 180
                        local newX = predX + 1 * math.cos(predYRotation)
                        local newZ = predZ + 1 * math.sin(predYRotation)
                        Osi.ItemMoveToPosition(uuid, newX, predY, newZ, 100000, 100000)
                        rotationOffset = rotationOffset + rotationOffset1
                    end
                end
            end
            Osi.TeleportToPosition(prey, 100000, 0, 100000, "", 0, 0, 0, 1, 1)
        else
            local predX, predY, predZ = Osi.getPosition(pred)
            local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
            predYRotation = predYRotation * math.pi / 180
            local newX = predX + ConfigVars.RegurgDist.value * math.cos(predYRotation)
            local newZ = predZ + ConfigVars.RegurgDist.value * math.sin(predYRotation)
            Osi.TeleportToPosition(prey, newX, predY, newZ, "", 0, 0, 0, 0, 1)
            Osi.ApplyStatus(prey, "PRONE", 1 * SecondsPerTurn, 1, pred)
        end
        VoreData[prey].Weight = 0
        VoreData[prey].FixedWeight = 0
        -- Tag that disables downed state.
        if VoreData[prey].DisableDowned then
            Osi.ClearTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
            VoreData[prey].DisableDowned = false
        end
        Osi.SetDetached(prey, 0)
        Osi.SetVisible(prey, 1)
        Osi.RemoveStatus(prey, DigestionTypes[VoreData[prey].Digestion], pred)
        Osi.RemoveStatus(prey, VoreLoci[VoreData[prey].Locus], pred)
        Osi.RemoveStatus(prey, 'SP_Swallowed', pred)
        Osi.RemoveStatus(prey, 'SP_PartiallySwallowed', pred)
        VoreData[prey].Digestion = 3
        VoreData[prey].Locus = ""
        VoreData[prey].Pred = nil
        SP_VoreDataEntry(prey, false)
    end

    -- If pred has no more prey inside.
    if next(VoreData[pred].Prey) == nil and VoreData[pred].Items == "" then
        Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        Osi.RemoveSpell(pred, 'SP_SwallowDown')
        Osi.RemoveSpell(pred, 'SP_SwitchToLethal', 1)
        Osi.AddSpell(pred, "SP_Target_Swallow_Endo", 0, 0)
        Osi.AddSpell(pred, "SP_Target_Swallow_Lethal", 0, 0)
        Osi.ApplyStatus(pred, "SP_Pacifist_Aura_Pred", -1)
        Osi.RemoveStatus(pred, 'SP_Stuffed')
    else
        Osi.RemoveStatus(pred, 'SP_Stuffed')
        local statusStacks = 0
        for k, v in pairs(VoreData[pred].Prey) do
            _P(k)
            statusStacks = statusStacks + Osi.GetStatusTurns(k, 'SP_Stuffed') + 1
        end

        if VoreData[pred].Items ~= "" and statusStacks == 0 then
            Osi.ApplyStatus(pred, 'SP_Stuffed', 1 * SecondsPerTurn, 1)
        elseif statusStacks > 0 then
            Osi.ApplyStatus(pred, 'SP_Stuffed', statusStacks * SecondsPerTurn, 1)
        end   
    end

    for _, prey in ipairs(markedForErase) do
        VoreData[prey] = nil
    end

    -- add swallow cooldown after regurgitation
    if (preyState ~= -1) and ConfigVars.RegurgitationCooldown.value > 0 then
        Osi.ApplyStatus(pred, 'SP_RegurgitationCooldown', ConfigVars.RegurgitationCooldown.value * SecondsPerTurn, 1)
    end


    _P("New table: ")
    _D(VoreData)

    -- Updates the weight of the pred if the items or prey were regurgitated.
    if #markedForRemoval > 0 or regItems then
        SP_UpdateWeight(pred)
    end
    SP_VoreDataEntry(pred, false)
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
    _P('Ending Regurgitation')
end

---Changes the amount of Weight Placeholders by looking for weights of all prey in pred.
---Remember to save VoreData after calling this
---@param pred CHARACTER
function SP_UpdateWeight(pred)
    local newWeight = 0
    local newWeightVisual = 0
    -- these will be modified by perks in the future
    local weightReduction = 0

    for k, v in pairs(VoreData[pred].Prey) do
        -- For the "Stomach Sentinel" subclass, which is built around
        -- protecting allies by swallowing them, and gets a feature that
        -- reduces the weight of swallowed allies.
        if SubclassAddOn and VoreData[k].Digestion[v] == 0 then
            if Osi.HasPassive(pred, "SP_Improved_Stomach_Shelter") then
                weightReduction = (VoreData[k].Weight + VoreData[k].AddWeight)
            elseif Osi.HasPassive(pred, "SP_Stomach_Shelter") then
                weightReduction = (VoreData[k].Weight + VoreData[k].AddWeight) / 2
            end
        end
        -- stores by how much the weight of prey was reduced, so we can add this to the weight of pred if they are swallowed
        VoreData[k].WeightReduction = weightReduction

        newWeight = newWeight + VoreData[k].Weight + VoreData[k].AddWeight - weightReduction
        if VoreData[k].Locus ~= 'C' then
            newWeightVisual = newWeightVisual + VoreData[k].Weight + VoreData[k].AddWeight
        end
    end

    -- add weight that does not belong to a prey
    newWeight = newWeight + VoreData[pred].AddWeight
    -- add weight that does not belong to a prey
    newWeightVisual = newWeightVisual + VoreData[pred].Fat + VoreData[pred].AddWeight

    if VoreData[pred].Items ~= "" then
        newWeightVisual = newWeightVisual + Ext.Entity.Get(VoreData[pred].Items).InventoryWeight.Weight // 1000
    end

    _P("Changing weight of " .. pred .. " to " .. newWeightVisual)
    Osi.CharacterRemoveTaggedItems(pred, '0e2988df-3863-4678-8d49-caf308d22f2a', 9999)
    Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, newWeight, 0)
    -- This is very important, it fixes inventory weight not updating properly when removing items.
    -- This is the only solution that worked. 8d3b74d4-0fe6-465f-9e96-36b416f4ea6f is removed
    -- immediately after being added (in the main script).
    Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)

    SP_UpdateBelly(pred, newWeightVisual)
end

--- purely visual updating
---@param pred CHARACTER
---@param weight integer How many weight placeholders in inventory.
function SP_UpdateBelly(pred, weight)
    -- Only female belly is currently implemented.
    if Osi.GetBodyType(pred, 1) ~= "Female" then
        _P("Character is not female, they are " .. Osi.GetBodyType(pred, 1))
        return
    end
    local predRace = Osi.GetRace(pred, 1)
    -- These races use the same or similar model.
    if string.find(predRace, 'Drow') ~= nil or string.find(predRace, 'Elf') ~= nil or string.find(predRace, 'Human') ~=
        nil or string.find(predRace, 'Gith') ~= nil or string.find(predRace, 'Orc') ~= nil or
        string.find(predRace, 'Aasimar') ~= nil or string.find(predRace, 'Tiefling') ~= nil then
        predRace = 'Human'
    end
    if BellyTableFemale[predRace] == nil then
        return
    end
    -- 1 == normal body, 2 == strong body. Did not check orks.
    local bodyShape = 1
    local tags = Ext.Entity.Get(pred).Tag.Tags
    for _, v in pairs(tags) do
        if v == "d3116e58-c55a-4853-a700-bee996207397" then
            bodyShape = 2
        end
    end

    -- Remove when separacte orc bellies are added. Their body is closer to the strong body, so a strong belly is used.
    if string.find(Osi.GetRace(pred, 1), 'Orc') ~= nil then
        bodyShape = 2
    end

    -- Determines the belly weight thresholds.
    local weightStage = 0
    if weight > 420 then
        weightStage = 8
    elseif weight > 300 then
        weightStage = 7
    elseif weight > 220 then
        weightStage = 6
    elseif weight > 135 then
        weightStage = 5
    elseif weight > 70 then
        weightStage = 4
    elseif weight > 45 then
        weightStage = 3
    elseif weight > 25 then
        weightStage = 2
    elseif weight > 10 then
        weightStage = 1
    end
    -- Clears overrives. Might break if you change bodyshape or race or gender.
    for _, v in ipairs(BellyTableFemale[predRace][bodyShape]) do
        Osi.RemoveCustomVisualOvirride(pred, v)
    end

    -- Delay is necessary, otherwise will not work.
    SP_DelayCallTicks(2, function()
        if weightStage > 0 then
            Osi.AddCustomVisualOverride(pred, BellyTableFemale[predRace][bodyShape][weightStage])
        end
    end)
end

---Checks if eating a character would exceed pred's carry limit.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_CanFitPrey(pred, prey)
    local predData = Ext.Entity.Get(pred)
    local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight) / 1000
    if SP_GetTotalCharacterWeight(prey) > predRoom then
        _P("Can't fit " .. SP_GetDisplayNameFromGUID(prey) .. " inside of " .. SP_GetDisplayNameFromGUID(pred) ..
               "'s stomach!")
        return false
    else
        return true
    end
end

---Checks if eating an item would exceed pred's carry limit.
---@param pred CHARACTER
---@param item GUIDSTRING
function SP_CanFitItem(pred, item)
    local predData = Ext.Entity.Get(pred)
    local predRoom = predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight
    local itemData = Ext.Entity.Get(item).Data.Weight
    if predRoom > itemData then
        return true
    else
        _P("Can't fit " .. item " inside " .. pred)
        return false
    end
end

---Handles rolling checks.
---@param pred CHARACTER
---@param prey CHARACTER
---@param eventName string Name that RollResult should look for. No predetermined values, can be whatever.
function SP_VoreCheck(pred, prey, eventName)
    local advantage = 0
    if ConfigVars.VoreDifficulty.value == 'easy' then
        advantage = 1
    end
    if eventName == 'StruggleCheck' then
        _P("Rolling struggle check")
        Osi.RequestPassiveRollVersusSkill(prey, pred, "SkillCheck", "Strength", "Constitution", 0, advantage, eventName)
    elseif string.sub(eventName, 1, #eventName-2) == 'SwallowLethalCheck' then
        _P('Rolling to resist swallow')
        local predStat = 'Athletics'
        local preyStat = 'Athletics'
        if Osi.HasSkill(pred, "Acrobatics") > Osi.HasSkill(pred, "Athletics") then
            predStat = "Acrobatics"
        end
        if Osi.HasSkill(prey, "Acrobatics") > Osi.HasSkill(prey, "Athletics") then
            preyStat = "Acrobatics"
        end
        Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", predStat, preyStat, advantage, 0, eventName)
    elseif string.sub(eventName, 1, #eventName-2) == "Bellyport" then
        _P("Rolling Dex Save to resist Bellyport")
        --always uses wisdom as stat until I get around to fixing it
        Osi.RequestPassiveRoll(prey, pred, "SavingThrow", "Dexterity", SP_GetSaveDC(pred, 5), 0, "BellyportSave_" .. string.sub(eventName, #eventName))
    elseif eventName == 'SwallowDownCheck' then
        _P('Rolling to resist secondary swallow')
        local predStat = 'Athletics'
        local preyStat = 'Athletics'
        if Osi.HasSkill(pred, "Acrobatics") > Osi.HasSkill(pred, "Athletics") then
            _P("Pred Acrobatics")
            predStat = "Acrobatics"
        end
        if Osi.HasSkill(prey, "Acrobatics") > Osi.HasSkill(prey, "Athletics") then
            _P("Prey Acrobatics")
            preyStat = "Acrobatics"
        end
        Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", predStat, preyStat, advantage, 0, eventName)
    end
end

---Reduces weight of prey and their preds, do not use this for regurgitation during voreception,
---since pred's weight would stay the same.
---@param character CHARACTER
---@param diff integer Amount to subtract.
---@param updateWeight boolean? Update visual weight / placeholders of characters.
---       This should be false in the OnReset functions, otherwise it might
---       update the weight of a single pred multiple times during one tick
---       and bug out Osiris.
function SP_ReduceWeightRecursive(character, diff, updateWeight)
    if character == nil then
        return
    end
    if VoreData[character].Pred ~= nil then
        VoreData[character].Weight = VoreData[character].Weight - diff
        if updateWeight then
            SP_UpdateWeight(character)
        end
        if VoreData[VoreData[character].Pred].Pred ~= nil then
            VoreData[VoreData[character].Pred].FixedWeight = VoreData[VoreData[character].Pred].FixedWeight - diff
            SP_ReduceWeightRecursive(VoreData[character].Pred, diff)
        elseif updateWeight then
            SP_UpdateWeight(VoreData[character].Pred)
        end
    end
end


---one function for slow digestion
---@param weightDiff integer
function SP_SlowDigestion(weightDiff, fatDiff)

    _P("Slow Digestion:" .. weightDiff .. " " .. fatDiff)

    -- reduces fat and addWeight of a pred
    for k, v in pairs(VoreData) do
        if v.Fat > 0 and v.Fat - fatDiff > 0 then
            VoreData[k].Fat = VoreData[k].Fat - fatDiff
        else
            VoreData[k].Fat = 0
        end
        if v.AddWeight > 0 then
            local thisAddDiff = weightDiff
            -- 
            if (v.AddWeight - weightDiff) < 0 then
                thisAddDiff = v.AddWeight
            end
            VoreData[k].AddWeight =  VoreData[k].AddWeight - thisAddDiff
            SP_ReduceWeightRecursive(v.Pred, thisAddDiff, false)
        end
        SP_VoreDataEntry(k, false)
    end

    -- reduces prey weight
    for k, v in pairs(VoreData) do
        if v.Digestion == 1 then
            local thisDiff = weightDiff
            -- Prey's weight after digestion should not be smaller then 1/5th of their original (fake) weight.
            if (v.Weight - weightDiff) < (v.FixedWeight // 5) then
                thisDiff = v.Weight - v.FixedWeight // 5
            end
            if ConfigVars.WeightGain.value then
                VoreData[v.Pred].Fat = VoreData[v.Pred].Fat + thisDiff // ConfigVars.WeightGainRate.value
            end
            if ConfigVars.Hunger.value and Osi.IsPartyMember(v.Pred, 0) == 1 then
                VoreData[v.Pred].Satiation = VoreData[v.Pred].Satiation + thisDiff // ConfigVars.HungerSatiationRate.value
            end
            SP_ReduceWeightRecursive(k, thisDiff, false)
        end
    end
    for k, v in pairs(VoreData) do
        if next(v.Prey) ~= nil then
            SP_UpdateWeight(k)
        end
    end
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
    _D(VoreData)
end

---Recursively generates a list of all nested prey
---@param pred GUIDSTRING
---@param voreLocus string "O" == Oral, "A" == Anal, "U" == Unbirth, "All" == all prey in any locus
---@param digestionType integer? Only count prey of this type: 0 == endo, 1 == dead, 2 == lethal, 3 == none
---@return table
function SP_GetNestedPrey(pred, voreLocus, digestionType)
    if VoreData[pred] == nil or VoreData[pred].Prey == nil then
        return {}
    end
    _D(VoreData[pred])
    local allPrey = VoreData[pred].Prey
    if digestionType ~= nil then
        allPrey = SP_FilterPrey(allPrey, voreLocus, digestionType)
    end
    for k, _ in pairs(allPrey) do
        ---@diagnostic disable-next-line: param-type-mismatch
        allPrey = SP_TableConcat(allPrey, SP_GetNestedPrey(VoreData[k].Prey, digestionType))
    end
    return allPrey
end

---Filters out prey with a specific prey type and returns them
---@param preyTable table
---@param locus string "O" == Oral, "A" == Anal, "U" == Unbirth, "All" == all prey in any locus
---@param digestionType integer? 0 == endo, 1 == dead, 2 == lethal, 3 == none
---@return table
function SP_FilterPrey(preyTable, locus, digestionType)
    local output = {}
    for k, v in pairs(preyTable) do
        if (VoreData[k].Digestion == digestionType or digestionType == nil) and (locus == VoreData[k].Locus or locus == "All") then
            output[k] = k
        end
    end
    return output
end

---returns what locus the character is in, if any
---@param character CHARACTER
---@return string | nil voreLocus either "O" == Oral, "A" == Anal, "U" == Unbirth. nil if character not a prey
function SP_WhereAmI(character)
    local pred = VoreData[character].Pred
    if pred == nil then return nil end
    return VoreData[pred].Prey[character]

end


---switches to a different type of digestion
---do not forget to copy VoreData after using this
---@param pred CHARACTER
---@param prey CHARACTER
---@param fromDig integer fromDig switch from this digestion type
---@param toDig integer fromDig switch from this digestion type
---@param voreLocus string "O" == Oral, "A" == Anal, "U" == Unbirth
function SP_SwitchToDigestionType(pred, prey, fromDig, toDig, voreLocus)
    if VoreData[prey].Digestion[voreLocus] == fromDig then
        VoreData[prey].Digestion[voreLocus] = toDig
        Osi.ApplyStatus(prey, DigestionTypes[toDig], 1 * SecondsPerTurn, 1, pred)
    end
end

---switches to a different type of locus
---do not forget to copy VoreData after using this
---@param pred CHARACTER
---@param prey CHARACTER
---@param toLoc string fromDig switch to this locus
function SP_SwitchToLocus(pred, prey, toLoc)
    VoreData[prey].Locus = toLoc
    VoreData[pred].Prey[prey] = toLoc
    Osi.ApplyStatus(prey, VoreLoci[toLoc], 1 * SecondsPerTurn, 1, pred)
end

---switches to a different type of locus
---do not forget to copy VoreData after using this
---@param pred CHARACTER
---@param prey CHARACTER
---@param toLoc string fromDig switch to this locus
function SP_SwitchToLocus(pred, prey, toLoc)
    VoreData[prey].Locus = toLoc
    VoreData[pred].Prey[prey] = toLoc
    Osi.ApplyStatus(prey, VoreLoci[toLoc], 1 * SecondsPerTurn, 1, pred)
end

---@param spell string name of the spell we're extracting data from
---@return string, string spellParams the type of spell and type of vore
function SP_GetSpellParams(spell)
    local pattern = "^SP_Target_S?w?a?l?l?o?w?_?([%a_]+)_([OAU])$"
    return string.match(spell, pattern)
end

---Console command for changing config variables.
---@param var string Name of the variable to change.
---@param val any Value to change the variable to.
function VoreConfig(var, val)
    if ConfigVars.var ~= nil then
        if type(val) == type(ConfigVars.var) then
            ConfigVars.var.value = val
            local json = Ext.Json.Stringify(ConfigVars, {Beautify = true})
            Ext.IO.SaveFile("DevouringAndDigesting/VoreConfig.json", json)
            _P(var .. " updated to have value " .. val)
        else
            _P("Entered value " .. val .. " is of type " .. type(val) .. " while " .. var ..
                   " requires a value of type " .. type(ConfigVars.var.value))
        end
    end
end

---Console command for printing config options and states.
function VoreConfigOptions()
    _P("Vore Mod Configuration Options: ")
    for k, v in pairs(ConfigVars) do
        _P(k .. ": " .. v.description)
        _P("Currently set to " .. tostring(v.value))
    end
end

function SP_MigrateTables()
	_P("Migrating between PreyTablePred and VoreData")
	-- adds all prey to the table
	for k, v in pairs(PersistentVars['PreyTablePred']) do
		SP_FillVoreData(k, v)
    end
	local allPreds = {}
	for _, v in pairs(PersistentVars['PreyTablePred']) do
        allPreds[v] = (allPreds[v] or 0) + 1
    end
	for k, v in pairs(allPreds) do
        SP_FillVoreData(k, nil)
    end
	PersistentVars['PreyTablePred'] = nil
	PersistentVars['PreyWeightTable'] = nil
	PersistentVars['FakePreyWeightTable'] = nil
	PersistentVars['DisableDownedPreyTable'] = nil
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
    _P("Migration Finished, new table:")
    _D(VoreData)
end

--updates VoreData to the version with loci support
function SP_UpdateVoreDataToLoci(pred)

    VoreData[pred].Digestion = {["O"]=VoreData[pred].Digestion, ["A"]=3, ["U"]=3}
    for k, _ in pairs(VoreData[pred].Prey) do
        VoreData[pred].Prey[k] = "O"
    end

end

function SP_FillVoreData(character, pred)
	local dead = Osi.IsDead(character)
	if dead ~= nil and Osi.IsCharacter(character) == 1 then
		_P(character)
		VoreData[character] = {}
		VoreData[character].Pred = pred
		VoreData[character].Weight = PersistentVars['PreyWeightTable'][character] or 0
		VoreData[character].FixedWeight = PersistentVars['FakePreyWeightTable'][character] or 0
		VoreData[character].DisableDowned = PersistentVars['DisableDownedPreyTable'][character] or false
        -- all previous prey are considered to be Oral
		VoreData[character].Digestion["O"] = dead
		VoreData[character].Combat = Osi.CombatGetGuidFor(character) or ""
		VoreData[character].Prey = {}
		VoreData[character].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', character) or ""
        -- weight that does not belong to any prey
        VoreData[character].Fat = 0
        VoreData[character].AddWeight = 0
        VoreData[character].WeightReduction = 0
        VoreData[character].DigestItems = false
        VoreData[character].SwallowProcess = 0
        VoreData[character].Satiation = 0
        if pred ~= nil then
            VoreData[character].Locus = "O"
        else
            VoreData[character].Locus = ""
        end
        VoreData[character].Swallowed = ""
		-- fills the prey table
		for k, v in pairs(PersistentVars['PreyTablePred']) do
			if v == character then
                -- all previous prey are considered to be Oral
				VoreData[character].Prey[k] = "O"
			end
		end
    end
end


function SP_CheckVoreData()
	for k, v in pairs(VoreData) do
        local dead = Osi.IsDead(k)
        local character = Osi.IsCharacter(k)
		if dead == nil or character == 0 then
			_P(k .. " WAS ERASED FROM EXISTENSE")
			if next(v.Prey) ~= nil then
				_P(k .. " WAS A PRED")
			end
            if v.Pred ~= nil then
                local pred = v.Pred
                VoreData[pred].AddWeight = VoreData[pred].AddWeight + v.Weight
                VoreData[k] = nil
            end
		end
    end
end