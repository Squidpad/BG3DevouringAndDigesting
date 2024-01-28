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
            "fafef7ab-087f-4362-9436-3e63ef7bcd95", "4a404594-e28d-4f47-b1c2-2ef593961e33",
            "78fc1e05-ee83-4e6c-b14f-6f116e875b03", "b10b965b-9620-48c2-9037-0556fd23d472",
            "14388c37-34ab-4963-b61e-19cea0a90e39",
        }, {
            "4bfa882a-3bef-49b8-9e8a-21198a2dbee5", "4741a71a-8884-4d3d-929d-708e350953bb",
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
    and VoreData[character].Fat == 0 and VoreData[character].AddWeight == 0 and not create then
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
    -- if a tag that disables downed state was appled on swallow. Should be false for non-prey
    VoreData[character].DisableDowned = false
    -- 0 == endo, 1 == dead, 2 == lethal, 3 == none. Since the statuses might be changed in the future, 
    -- it's not reliable to ask osiris if a character has a status,
    -- so we make all non-dead prey count as endoed during migration
    VoreData[character].Digestion = 3
    VoreData[character].Combat = Osi.IsInCombat(character) == 1
    -- This is a set, not an array, for an easier search of a specific prey, so use k instead of v when iterating
    -- use next(VoreData[character].Prey) == nil instead of #VoreData[character].Prey == 0 to check if it's empty 
    VoreData[character].Prey = {}
    VoreData[character].Items = ""
    -- For wg maybe
    VoreData[character].Fat = 0
    -- Belly weight without prey
    VoreData[character].AddWeight = 0
end


---This adds a prey to pred without updating pred's weight or saving table
---Separated this from SP_SwallowPrey to create SP_SwallowPreyMultiple
---Otherwise the UpdateWeight will be called multiple times on the same tick, which will break osiris
---Also SP_Stuffed should not be applied and removed multiple times on the same tick
---@param pred CHARACTER
---@param prey CHARACTER
---@param swallowType integer Internal name of Status Effect.
---@param notNested boolean If prey is not transferred to another stomach.
---@return integer statusStacks
function SP_AddPrey(pred, prey, swallowType, notNested)
    SP_VoreDataEntry(prey, true)

    VoreData[prey].Digestion = swallowType

    if swallowType == 0 then
        Osi.ApplyStatus(prey, "SP_Swallowed_Endo", -1, 1, pred)
    elseif swallowType == 1 then
        Osi.ApplyStatus(prey, "SP_Swallowed_Dead", -1, 1, pred)
    elseif swallowType == 2 then
        Osi.ApplyStatus(prey, "SP_Swallowed_Lethal", -1, 1, pred)
    else
        _P("Swallow type wrong number, something is broken")
    end
    Osi.ApplyStatus(prey, "SP_Swallowed", -1, 1, pred)

    VoreData[prey].Pred = pred
    VoreData[pred].Prey[prey] = true

    local statusStacks = SP_TableLength(VoreData[pred].Prey)
    for k, v in pairs(VoreData[prey].Prey) do
        statusStacks = statusStacks + Osi.GetStatusTurns(k, 'SP_Stuffed') + 1
    end
    
    if notNested then
        Osi.SetDetached(prey, 1)
        Osi.SetVisible(prey, 0)
        -- Removes downed status if prey is already downed.
        Osi.ApplyStatus(prey, "SP_Being_Swallowed", 0, 1, pred)
        -- Instead of add weight.
        VoreData[prey].Weight = math.floor(SP_GetTotalCharacterWeight(prey))
        VoreData[prey].FixedWeight = math.floor(SP_GetTotalCharacterWeight(prey))
        -- Tag that disables downed state.
        if Osi.IsTagged(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22') ~= 1 then
            Osi.SetTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
            VoreData[prey].DisableDowned = true
        end
    end
    return statusStacks
end


---Should be called in any situation when prey must be swallowed.
---@param pred CHARACTER
---@param prey CHARACTER
---@param swallowType integer Internal name of Status Effect.
---@param notNested boolean If prey is not transferred to another stomach.
function SP_SwallowPrey(pred, prey, swallowType, notNested)
    _P('Swallowing')

    SP_VoreDataEntry(pred, true)

    local statusStacks = SP_AddPrey(pred, prey, swallowType, notNested)

    Osi.RemoveStatus(pred, "SP_Stuffed")
    Osi.ApplyStatus(pred, "SP_Stuffed", statusStacks * SecondsPerTurn, 1, pred)
    Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)

    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    SP_UpdateWeight(pred)
    _P('Swallowing END')
end

---Should be called in any situation when multiple prey must be swallowed.
---@param pred CHARACTER
---@param preys table
---@param swallowType integer Internal name of Status Effect.
---@param notNested boolean If prey is not transferred to another stomach.
function SP_SwallowPreyMultiple(pred, preys, swallowType, notNested)
    _P('Swallowing multiple')

    SP_VoreDataEntry(pred, true)

    local statusStacks = 0
    for _, v in ipairs(preys) do
        statusStacks = statusStacks + SP_AddPrey(pred, v, swallowType, notNested)
    end

    Osi.ApplyStatus(pred, "SP_Stuffed", statusStacks * SecondsPerTurn, 1, pred)
    Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)

    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    SP_UpdateWeight(pred)
    _P('Swallowing END')
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
        end
        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.ToInventory(item, VoreData[pred].Items, 9999, 0, 0)

        PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
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
        end
        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.MoveAllItemsTo(container, VoreData[pred].Items, 0, 0, 0, 0)
        Osi.MoveAllStoryItemsTo(container, VoreData[pred].Items, 0, 0)
        
        PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
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
---@param pr string
---@param preyState integer State of prey to regurgitate: 0 == alive, 1 == dead, 2 == all.
---@param spell string Internal name of spell (this does not reflect the in-game spell used).
function SP_RegurgitatePrey(pred, pr, preyState, spell)
    _P('Starting Regurgitation')

    SP_VoreDataEntry(pred, true)

    _P('Targets: ' .. pr)
    local markedForRemoval = {}
    local markedForSwallow = {}
    local markedForErase = {}

    -- Find prey to remove, clear their status, mark them for removal.
    for prey, v in pairs(VoreData[pred].Prey) do
        local isReal = Osi.IsCharacter(prey)
        if isReal ~= 1 then
            table.insert(markedForErase, prey)
        end

        -- this is needed to regurgitate lethal vore characters when using regurgitation spell
        local stateCheck = VoreData[prey].Digestion
        if stateCheck == 2 then
            stateCheck = 0
        end

        if isReal == 1 and (pr == "All" or prey == pr) and (preyState == -1 or (stateCheck == preyState and
            (preyState ~= 1 or (VoreData[prey].Weight <= VoreData[prey].FixedWeight // 5)))) then
            _P('Pred:' .. pred)
            _P('Prey:' .. prey)
            Osi.RemoveStatus(prey, 'SP_Swallowed_Endo', pred)
            Osi.RemoveStatus(prey, 'SP_Swallowed_Lethal', pred)
            Osi.RemoveStatus(prey, 'SP_Swallowed_Dead', pred)
            Osi.RemoveStatus(prey, 'SP_Swallowed', pred)
            -- Voreception
            if VoreData[pred].Pred ~= nil then
                -- reduce pred weight in prey weight tables, since they are both prey and pred
                VoreData[pred].Weight = VoreData[pred].Weight - VoreData[prey].Weight
                VoreData[pred].FixedWeight = VoreData[pred].FixedWeight - VoreData[prey].Weight
                table.insert(markedForSwallow, prey)
                -- If no voreception, free prey.
            else
                table.insert(markedForRemoval, prey)
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
                                -- Y-rotation == yaw.
                                local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
                                -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
                                predYRotation = (predYRotation + rotationOffset) * math.pi / 180
                                -- Equation for rotating a vector in the X dimension.
                                local newX = predX + 1 * math.cos(predYRotation)
                                -- Equation for rotating a vector in the Z dimension.
                                local newZ = predZ + 1 * math.sin(predYRotation)
                                -- Places prey at pred's location, vaguely in front of them.
                                Osi.ItemMoveToPosition(uuid, newX, predY, newZ, 100000, 100000)
                                rotationOffset = rotationOffset + rotationOffset1
                            end
                        end
                    end
                    Osi.TeleportToPosition(prey, 100000, 0, 100000, "", 0, 0, 0, 1, 0)
                else
                    local predX, predY, predZ = Osi.getPosition(pred)
                    -- Y-rotation == yaw.
                    local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
                    -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
                    predYRotation = predYRotation * math.pi / 180
                    -- Equation for rotating a vector in the X dimension.
                    local newX = predX + ConfigVars.RegurgDist.value * math.cos(predYRotation)
                    -- Equation for rotating a vector in the Z dimension.
                    local newZ = predZ + ConfigVars.RegurgDist.value * math.sin(predYRotation)
                    -- Places prey at pred's location, vaguely in front of them.
                    Osi.TeleportToPosition(prey, newX, predY, newZ, "", 0, 0, 0, 0, 0)
                end
            end
        end
    end

    local regItems = false
    if VoreData[pred].Items ~= "" and preyState ~= 1 and spell ~= "LevelChange" and pr == 'All' then

        regItems = true
        if VoreData[pred].Pred ~= nil then
            local weightDiff = Ext.Entity.Get(VoreData[pred].Items).InventoryWeight.Weight // 1000
            VoreData[pred].Weight = VoreData[pred].Weight - weightDiff
            VoreData[pred].FixedWeight = VoreData[pred].FixedWeight - weightDiff
            SP_SwallowAllItems(VoreData[pred].Pred, VoreData[pred].Items)
        else
            local itemList = Ext.Entity.Get(VoreData[pred].Items).InventoryOwner.PrimaryInventory:GetAllComponents()
                                 .InventoryContainer.Items

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
        SP_SwallowPreyMultiple(VoreData[pred].Pred, markedForSwallow, VoreData[pred].Digestion, false)
    end


    -- Remove regurgitated prey from the table.
    for _, prey in ipairs(markedForRemoval) do
        -- moved this whole section here, so all changes to prey in VoreData are located in one place
        -- remove weight.
        VoreData[prey].Weight = 0
        VoreData[prey].FixedWeight = 0
        -- Tag that disables downed state.
        if VoreData[prey].DisableDowned then
            Osi.ClearTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
            VoreData[prey].DisableDowned = false
        end
        VoreData[prey].Digestion = 3
        Osi.SetDetached(prey, 0)
        Osi.SetVisible(prey, 1)
        VoreData[prey].Pred = nil
        VoreData[pred].Prey[prey] = nil
        SP_VoreDataEntry(prey, false)
    end
    -- If pred has no more prey inside.
    if next(VoreData[pred].Prey) == nil and VoreData[pred].Items == "" then
        Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        Osi.RemoveStatus(pred, 'SP_Stuffed')
    elseif VoreData[pred].Pred == nil then

        Osi.RemoveStatus(pred, 'SP_Stuffed')
        local statusStacks = 0
        for k, v in pairs(VoreData[pred].Prey) do
            _P(k)
            statusStacks = statusStacks + Osi.GetStatusTurns(k, 'SP_Stuffed') + 1
        end
        Osi.ApplyStatus(pred, 'SP_Stuffed', statusStacks * SecondsPerTurn, 1)
    end

    for _, prey in ipairs(markedForErase) do
        VoreData[prey] = nil
    end

    _P("New table: ")
    _D(VoreData)

    -- Updates the weight of the pred if the items or prey were regurgitated.
    if #markedForRemoval > 0 or regItems then
        SP_UpdateWeight(pred)
    end
    SP_VoreDataEntry(pred, false)
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    _P('Ending Regurgitation')
end

---Changes the amount of Weight Placeholders by looking for weights of all prey in pred.
---DOES NOT CHANGE STORED WEIGHT
---@param pred CHARACTER
function SP_UpdateWeight(pred)
    local newWeight = 0
    local newWeightVisual = 0
    -- these will be modified by perks in the future
    local weightMultiplier = 1
    local weightDivider = 1
    local weightModifier = 0

    for k, v in pairs(VoreData[pred].Prey) do
        -- For the "Stomach Sentinel" subclass, which is built around
        -- protecting allies by swallowing them, and gets a feature that
        -- reduces the weight of swallowed allies.
        if SubclassAddOn and VoreData[k].Digestion == 0 then
            if Osi.HasPassive(pred, "SP_Improved_Stomach_Shelter") then
                weightModifier = VoreData[k].Weight
            elseif Osi.HasPassive(pred, "SP_Stomach_Shelter") then
                weightModifier = VoreData[k].Weight / 2
            end
        end


        newWeight = newWeight + (VoreData[k].Weight + weightModifier) * weightMultiplier // weightDivider
        newWeightVisual = newWeightVisual + VoreData[k].Weight
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
        weightStage = 7
    elseif weight > 300 then
        weightStage = 6
    elseif weight > 220 then
        weightStage = 5
    elseif weight > 135 then
        weightStage = 4
    elseif weight > 69 then
        weightStage = 3
    elseif weight > 35 then
        weightStage = 2
    elseif weight > 8 then
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
    elseif eventName == 'SwallowLethalCheck' then
        _P('Rolling to resist swallow')

        if Osi.HasSkill(prey, "Acrobatics") > Osi.HasSkill(prey, "Athletics") then
            _P('Using Acrobatics')
            Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Acrobatics", advantage, 0,
                                              eventName)
        else
            _P('Using Athletics')
            Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Athletics", advantage, 0,
                                              eventName)
        end
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
    for k, v in pairs(VoreData) do
        if VoreData[k].Fat > 0 then
            VoreData[k].Fat = VoreData[k].Fat - fatDiff
        end
        if VoreData[k].Fat < 0 then
            VoreData[k].Fat = 0
            SP_VoreDataEntry(k, false)
        end
    end

    for k, v in pairs(VoreData) do
        if v.Digestion == 1 then
            local thisDiff = weightDiff
            -- Prey's weight after digestion should not be smaller then 1/5th of their original (fake) weight.
            if (v.Weight - weightDiff) < (v.FixedWeight // 5) then
                thisDiff = v.Weight - v.FixedWeight // 5
            end
            VoreData[v.Pred].Fat = VoreData[v.Pred].Fat + thisDiff // ConfigVars.WeightGainRate.value
            SP_ReduceWeightRecursive(k, thisDiff, false)
        end
    end

    for k, v in pairs(VoreData) do
        if next(v.Prey) ~= nil then
            SP_UpdateWeight(k, true)
        end
    end
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    _D(VoreData)
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
    _P("Migration Finished, new table:")
    _D(VoreData)
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
		VoreData[character].Digestion = dead
		VoreData[character].Combat = Osi.IsInCombat(character) == 1 and dead == 0
		VoreData[character].Prey = {}
		VoreData[character].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', character) or ""
        -- weight that does not belong to any prey
        VoreData[character].Fat = 0
        VoreData[character].AddWeight = 0
		-- fills the prey table
		for k, v in pairs(PersistentVars['PreyTablePred']) do
			if v == character then
				VoreData[character].Prey[k] = true
			end
		end
    end
end


function SP_CheckVoreData()
	for k, v in pairs(PersistentVars['VoreData']) do
        local dead = Osi.IsDead(k)
        local character = Osi.IsCharacter(k)
		if dead == nil or character == 0 then
			_P(k .. " WAS ERASED FROM EXISTENSE")
			if next(v.Prey) ~= nil then
				_P(k .. " WAS A PRED")
			end
            if v.Pred ~= nil then
                local pred = v.Pred
                PersistentVars['VoreData'][pred].AddWeight = PersistentVars['VoreData'][pred].AddWeight + v.Weight
                PersistentVars['VoreData'][k] = nil
            end
		end
    end
end