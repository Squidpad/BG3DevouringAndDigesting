-- A new way to store data about every character that is involved in vore
---@type table<string, VoreDataEntry>
VoreData = {}

---Adds or deletes VoreData of a character
---@param character CHARACTER
---@param create? boolean will not delete entry if true
function SP_VoreDataEntry(character, create)
    if VoreData[character] == nil and create then
        _P("Adding character " .. character)
        SP_NewVoreDataEntry(character)
    elseif VoreData[character].Pred == "" and next(VoreData[character].Prey) == nil and VoreData[character].Items == ""
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
    VoreData[character] = SP_Deepcopy(VoreDataEntry)
    VoreData[character].Combat = Osi.CombatGetGuidFor(character) or ""
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
---@param swallowStages? boolean If swallow happens in multiple stages
---@return integer statusStacks
---@param locus string
function SP_AddPrey(pred, prey, digestionType, notNested, swallowStages, locus)
    SP_VoreDataEntry(prey, true)

    if digestionType >= 3 then
        _P("Swallowng a character with a wrong status, error")
        return -1
    end

    ---For debugging and general fun
    if Osi.HasActiveStatus(pred, "SP_AlwaysEndoStatus") == 1 then
        digestionType = 0
        Osi.LeaveCombat(prey)
    end

    VoreData[prey].Digestion = digestionType
    VoreData[prey].Locus = locus
    VoreData[prey].Swallowed = SP_GetSwallowedVoreStatus(pred, prey, digestionType == 0, locus)

    VoreData[pred].Prey[prey] = locus
    local predSize = SP_GetCharacterSize(pred)
    local preySize = SP_GetCharacterSize(prey)
    if notNested then
        Osi.AddSpell(prey, 'SP_ReleaseMe', 0, 0)
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

        if ConfigVars.Mechanics.SwallowDown.value and swallowStages then
            VoreData[prey].SwallowProcess = preySize - predSize + 1
            if VoreData[prey].SwallowProcess < 0 then
                VoreData[prey].SwallowProcess = 0
            end
            --if swallowType == 0 then
            --    VoreData[prey].SwallowProcess = VoreData[prey].SwallowProcess - 1
            --end
        end
        if VoreData[prey].SwallowProcess > 0 then
            local pswallow = SP_GetSwallowVoreStatus(pred, digestionType == 0)
            Osi.ApplyStatus(prey, pswallow, (VoreData[prey].SwallowProcess + 1) * SecondsPerTurn, 1, pred)
            Osi.AddSpell(pred, 'SP_SwallowDown', 0, 0)
            VoreData[prey].Swallowed = pswallow
        else
            VoreData[prey].SwallowProcess = 0
            Osi.ApplyStatus(prey, DigestionTypes[digestionType], 1 * SecondsPerTurn, 1, pred)
            Osi.ApplyStatus(prey, VoreLoci[locus], 1 * SecondsPerTurn, 1, pred)
            Osi.ApplyStatus(prey, VoreData[prey].Swallowed, 100 * SecondsPerTurn, 1, pred)
        end
    else
        Osi.ApplyStatus(prey, DigestionTypes[digestionType], 1 * SecondsPerTurn, 1, pred)
        Osi.ApplyStatus(prey, VoreLoci[locus], 1 * SecondsPerTurn, 1, pred)
        Osi.ApplyStatus(prey, VoreData[prey].Swallowed, 100 * SecondsPerTurn, 1, pred)
    end
    -- if a character who is inside of stomach swallows someone else who is in the same stomach
    if VoreData[pred].Pred ~= "" and VoreData[pred].Pred == VoreData[prey].Pred then
        VoreData[pred].Weight = VoreData[pred].Weight + VoreData[prey].Weight + VoreData[prey].AddWeight
        VoreData[pred].FixedWeight = VoreData[pred].FixedWeight + VoreData[prey].Weight + VoreData[prey].AddWeight
    end

    VoreData[prey].Pred = pred
    SP_ApplyOverstuffing(pred)
    -- Now accounts for the size of each prey when determining how many stacks of Stuffed you should get
    return VoreData[prey].StuffedStacks + SP_GetStuffedStacksBySize(preySize)
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
    if VoreData[pred].StuffedStacks < 1 and statusStacks < 1 then
        statusStacks = 1
    end
    if notNested then
        local stuffedStatus = SP_GetStuffedVoreStatus(pred, statusStacks)

        -- if the status used to stuff pred changed for some reason (picked feat)
        if stuffedStatus ~= VoreData[pred].Stuffed and VoreData[pred].Stuffed ~= "" then
            Osi.RemoveStatus(pred, VoreData[pred].Stuffed)
            statusStacks = statusStacks + VoreData[pred].StuffedStacks
            VoreData[pred].StuffedStacks = 0
        end
        Osi.ApplyStatus(pred, stuffedStatus, statusStacks * SecondsPerTurn, 1, pred)
        VoreData[pred].StuffedStacks = VoreData[pred].StuffedStacks + statusStacks
        VoreData[pred].Stuffed = stuffedStatus
    end

    Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
    Osi.AddSpell(pred, 'SP_SpeedUpDigestion', 0, 0)
    Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)

    SP_UpdateWeight(pred)
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
    if VoreData[pred].StuffedStacks < 1 and statusStacks < 1 then
        statusStacks = 1
    end
    if notNested then
        local stuffedStatus = SP_GetStuffedVoreStatus(pred, statusStacks)

        -- if the status used to stuff pred changed for some reason (picked feat)
        if stuffedStatus ~= VoreData[pred].Stuffed and VoreData[pred].Stuffed ~= "" then
            Osi.RemoveStatus(pred, VoreData[pred].Stuffed)
            statusStacks = statusStacks + VoreData[pred].StuffedStacks
            VoreData[pred].StuffedStacks = 0
        end
        Osi.ApplyStatus(pred, stuffedStatus, statusStacks * SecondsPerTurn, 1, pred)
        VoreData[pred].StuffedStacks = VoreData[pred].StuffedStacks + statusStacks
        VoreData[pred].Stuffed = stuffedStatus
    end

    Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
    Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)
    Osi.AddSpell(pred, 'SP_SpeedUpDigestion', 0, 0)

    SP_UpdateWeight(pred)
    _P('Swallowing END')
end

---finishes swallowing a character in SwallowDown is enabled
---@param pred CHARACTER
---@param prey CHARACTER
function SP_FullySwallow(pred, prey)
    _P('Full swallow')
    Osi.ApplyStatus(prey, DigestionTypes[VoreData[prey].Digestion], 1 * SecondsPerTurn, 1, pred)
    Osi.ApplyStatus(prey, VoreLoci[VoreData[prey].Locus], 1 * SecondsPerTurn, 1, pred)
    Osi.ApplyStatus(prey, SP_GetSwallowedVoreStatus(pred, prey, VoreData[prey].Digestion == 0, VoreData[prey].Locus),
                    100 * SecondsPerTurn, 1, pred)
    VoreData[prey].Swallowed = SP_GetSwallowedVoreStatus(pred, prey, VoreData[prey].Digestion == 0, VoreData[prey].Locus)
    local removeSD = true
    for k, v in pairs(VoreData[pred].Prey) do
        if VoreData[k].SwallowProcess > 0 then
            removeSD = false
        end
    end
    if removeSD then
        Osi.RemoveSpell(pred, 'SP_SwallowDown')
    end
end

---Swallow an item.
---@param pred CHARACTER
---@param item GUIDSTRING
function SP_SwallowItem(pred, item)
    SP_VoreDataEntry(pred, true)

    if Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1 then
        if VoreData[pred].StuffedStacks == 0 then
            local stuffedStatus = SP_GetStuffedVoreStatus(pred, 1)
            VoreData[pred].StuffedStacks = 1
            VoreData[pred].Stuffed = stuffedStatus
            Osi.ApplyStatus(pred, stuffedStatus, 1 * SecondsPerTurn, 1, pred)

            Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
            Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)
        end
        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.ToInventory(item, VoreData[pred].Items, 9999, 0, 0)

        SP_DelayCallTicks(4, function ()
            SP_UpdateWeight(pred)
        end)
    else
        Osi.TemplateAddTo('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1, 0)
        SP_DelayCallTicks(4, function ()
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
        if VoreData[pred].StuffedStacks == 0 then
            local stuffedStatus = SP_GetStuffedVoreStatus(pred, 1)
            VoreData[pred].StuffedStacks = 1
            VoreData[pred].Stuffed = stuffedStatus
            Osi.ApplyStatus(pred, stuffedStatus, 1 * SecondsPerTurn, 1, pred)

            Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
            Osi.AddSpell(pred, 'SP_SwitchToLethal', 0, 0)
        end
        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.MoveAllItemsTo(container, VoreData[pred].Items, 0, 0, 0, 0)
        Osi.MoveAllStoryItemsTo(container, VoreData[pred].Items, 0, 0)

        SP_DelayCallTicks(4, function ()
            SP_UpdateWeight(pred)
        end)
    else
        Osi.TemplateAddTo('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1, 0)
        SP_DelayCallTicks(4, function ()
            SP_SwallowAllItems(pred, container)
        end)
    end
end

---Should be called in any situation when prey must be released, including pred's death.
---@param pred CHARACTER
---@param preyString GUIDSTRING | string either guid of prey, or "All" to regurigitate all prey in given locus
---@param preyState integer State of prey to regurgitate: 0 == alive, 1 == dead, -1 == all, 10 == alive and digested.
---@param spell? string Internal name of spell (this does not reflect the in-game spell used).
---@param locus? string locus to regurgiate from
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
                    ((stateCheck == preyState or preyState == 10) and
                        (stateCheck ~= 1 or (VoreData[prey].Weight <= VoreData[prey].FixedWeight // 5)))) then
                _P('Pred:' .. pred)
                _P('Prey:' .. prey)
                VoreData[pred].Prey[prey] = nil
                -- Voreception
                if VoreData[pred].Pred ~= "" then
                    -- reduce pred weight in prey weight tables, since they are both prey and pred
                    VoreData[pred].Weight = VoreData[pred].Weight - VoreData[prey].Weight - VoreData[prey].AddWeight
                    VoreData[pred].FixedWeight = VoreData[pred].FixedWeight - VoreData[prey].Weight -
                        VoreData[prey].AddWeight
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
        if VoreData[pred].Pred ~= "" then
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
                    local newX = predX + ConfigVars.Regurgitation.RegurgitationDistance.value * math.cos(predYRotation)
                    -- Equation for rotating a vector in the Z dimension.
                    local newZ = predZ + ConfigVars.Regurgitation.RegurgitationDistance.value * math.sin(predYRotation)
                    -- Places prey at pred's location, vaguely in front of them.
                    Osi.ItemMoveToPosition(uuid, newX, predY, newZ, 100000, 100000)
                    _P("Moved Item " .. uuid)
                    rotationOffset = rotationOffset + rotationOffset1
                end
            end
        end
        -- This delay is important, otherwise items would be deleted.
        VoreData[pred].Items = ""
        SP_DelayCallTicks(4, function ()
            Osi.TemplateRemoveFrom('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1)
        end)
    end

    -- Check if no one was regurgitated, just for debug
    if #markedForRemoval == 0 then
        _P("WARNING, no character was regurgitated by " .. pred)
    end

    -- transfers prey to pred's pred for nested vore
    if #markedForSwallow > 0 then
        SP_SwallowPreyMultiple(VoreData[pred].Pred, markedForSwallow, VoreData[pred].Digestion, false, false,
                               VoreData[pred].Locus)
    end

    -- stops digesting items if nothing is being digested in the stomach of the pred
    local stopDigestingItems = true
    for k, v in pairs(VoreData[pred].Prey) do
        if VoreData[k].Digestion == 2 and VoreData[k].Locus == 'O' then
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
            local newX = predX + ConfigVars.Regurgitation.RegurgitationDistance.value * math.cos(predYRotation)
            local newZ = predZ + ConfigVars.Regurgitation.RegurgitationDistance.value * math.sin(predYRotation)
            Osi.TeleportToPosition(prey, newX, predY, newZ, "", 0, 0, 0, 0, 1)
            if Osi.HasPassive(prey, 'SP_EscapeArtist') == 0 then
                Osi.ApplyStatus(prey, "PRONE", 1 * SecondsPerTurn, 1, pred)
            end
        end
        VoreData[prey].Weight = 0
        VoreData[prey].FixedWeight = 0
        -- Tag that disables downed state.
        if VoreData[prey].DisableDowned then
            Osi.ClearTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
            VoreData[prey].DisableDowned = false
        end
        Osi.RemoveSpell(prey, 'SP_ReleaseMe')
        Osi.SetDetached(prey, 0)
        Osi.SetVisible(prey, 1)
        Osi.RemoveStatus(prey, DigestionTypes[VoreData[prey].Digestion], pred)
        Osi.RemoveStatus(prey, VoreLoci[VoreData[prey].Locus], pred)
        Osi.RemoveStatus(prey, VoreData[prey].Swallowed, pred)
        VoreData[prey].Digestion = 3
        VoreData[prey].Locus = ""
        VoreData[prey].Swallowed = ""
        VoreData[prey].Pred = ""
        SP_VoreDataEntry(prey, false)
    end

    -- If pred has no more prey inside.
    if next(VoreData[pred].Prey) == nil and VoreData[pred].Items == "" then
        Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        Osi.RemoveSpell(pred, 'SP_SwallowDown')
        Osi.RemoveSpell(pred, 'SP_SwitchToLethal', 1)
        Osi.RemoveSpell(pred, 'SP_SpeedUpDigestion', 1)
        Osi.RemoveStatus(pred, VoreData[pred].Stuffed)
        VoreData[pred].Stuffed = ""
        VoreData[pred].StuffedStacks = 0
    else
        Osi.RemoveStatus(pred, VoreData[pred].Stuffed)
        local statusStacks = 0
        for k, v in pairs(VoreData[pred].Prey) do
            _P(k)
            local preySize = SP_GetCharacterSize(k)
            statusStacks = statusStacks + VoreData[k].StuffedStacks + SP_GetStuffedStacksBySize(preySize)
        end
        local stuffedStatus = SP_GetStuffedVoreStatus(pred, statusStacks)
        if statusStacks == 0 and (VoreData[pred].Items ~= "" or next(VoreData[pred].Prey) ~= nil) then
            stuffedStatus = SP_GetStuffedVoreStatus(pred, 1)
            VoreData[pred].StuffedStacks = 1
            Osi.ApplyStatus(pred, stuffedStatus, 1 * SecondsPerTurn, 1, pred)
        else
            VoreData[pred].StuffedStacks = statusStacks
            if statusStacks > 0 then
                Osi.ApplyStatus(pred, stuffedStatus, statusStacks * SecondsPerTurn, 1, pred)
            end
        end
        VoreData[pred].Stuffed = stuffedStatus
    end

    for _, prey in ipairs(markedForErase) do
        VoreData[prey] = nil
    end

    -- add swallow cooldown after regurgitation
    if locus ~= "A" and preyString == "All" and ConfigVars.Regurgitation.CooldownSwallow.value > 0 then
        Osi.ApplyStatus(pred, 'SP_RegurgitationCooldown', ConfigVars.Regurgitation.CooldownSwallow.value * SecondsPerTurn, 1)
    end
    if locus ~= "A" and preyString == "All" and ConfigVars.Regurgitation.CooldownRegurgitate.value > 0 then
        Osi.ApplyStatus(pred, 'SP_RegurgitationCooldown2', ConfigVars.Regurgitation.CooldownRegurgitate.value * SecondsPerTurn, 1)
    end


    _P("New table: ")
    _D(VoreData)

    Osi.RemoveStatus(pred, "SP_Cant_Fit_Prey")
    -- Updates the weight of the pred if the items or prey were regurgitated.
    if #markedForRemoval > 0 or #markedForSwallow > 0 or #markedForErase > 0 or regItems then
        SP_UpdateWeight(pred)
    end
    SP_VoreDataEntry(pred, false)
    _P('Ending Regurgitation')
end

---Changes the amount of Weight Placeholders by looking for weights of all prey in pred.
---Remember to save VoreData after calling this
---@param pred CHARACTER
---@param noVisual? boolean when we need to change the amount of weight placeholders but not the actual weight
function SP_UpdateWeight(pred, noVisual)
    if VoreData[pred] == nil then
        Osi.CharacterRemoveTaggedItems(pred, '0e2988df-3863-4678-8d49-caf308d22f2a', 9999)
        Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)
        SP_UpdateBelly(pred, 0)
        return
    end
    local newWeight = 0
    local newWeightVisual = 0
    -- these will be modified by perks in the future
    local weightReduction = 0

    for k, v in pairs(VoreData[pred].Prey) do
        -- For the "Stomach Sentinel" subclass, which is built around
        -- protecting allies by swallowing them, and gets a feature that
        -- reduces the weight of swallowed allies.
        local fullWeight = VoreData[k].Weight + VoreData[k].AddWeight
        if VoreData[k].Digestion == 0 and Osi.IsPartyMember(k, 0) == 1 then
            if Osi.HasPassive(pred, "SP_Improved_Stomach_Shelter") == 1 then
                weightReduction = fullWeight
            elseif Osi.HasPassive(pred, "SP_Stomach_Shelter") == 1 then
                weightReduction = fullWeight / 2
            end
            fullWeight = fullWeight - weightReduction
        end
        if Osi.HasPassive(pred, "SP_BottomlessStomach") == 1 then
            weightReduction = fullWeight / 2
            fullWeight = fullWeight - weightReduction
        end
        if Osi.HasPassive(k, 'SP_Dense') == 1 and VoreData[k].Digestion ~= 0 then
            weightReduction = -fullWeight
            fullWeight = fullWeight - weightReduction
        end
        -- stores by how much the weight of prey was reduced, so we can add this to the weight of pred if they are swallowed
        VoreData[k].WeightReduction = (VoreData[k].Weight + VoreData[k].AddWeight) - fullWeight

        newWeight = newWeight + fullWeight
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

    if Osi.HasActiveStatus(pred, "SP_BellyCompressed") == 1 then
        newWeightVisual = 0
    end

    _P("Changing weight of " .. pred .. " to " .. newWeightVisual)
    Osi.CharacterRemoveTaggedItems(pred, '0e2988df-3863-4678-8d49-caf308d22f2a', 9999)
    Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, newWeight, 0)
    -- This is very important, it fixes inventory weight not updating properly when removing items.
    -- This is the only solution that worked. 8d3b74d4-0fe6-465f-9e96-36b416f4ea6f is removed
    -- immediately after being added (in the main script).
    Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)
    if noVisual == true then
        return
    end
    SP_UpdateBelly(pred, newWeightVisual)
    SP_DelayCallTicks(4, function ()
        SP_ApplyOverstuffing(pred)
    end)
end

--- purely visual updating
---@param pred CHARACTER
---@param weight integer How many weight placeholders in inventory.
function SP_UpdateBelly(pred, weight)
    local predRace = Osi.GetRace(pred, 1)
    -- These races use the same or similar model.
    if string.find(predRace, 'Drow') ~= nil or string.find(predRace, 'Elf') ~= nil or string.find(predRace, 'Human') ~= nil or
        string.find(predRace, 'Aasimar') ~= nil or string.find(predRace, 'Tiefling') ~= nil then
        predRace = 'Human'
    elseif string.find(predRace, 'Gith') ~= nil then
        predRace = 'Gith'
    elseif string.find(predRace, 'Orc') ~= nil then
        predRace = 'Orc'
    end
    if BellyTable[predRace] == nil then
        _P("Race " .. predRace .. " does not support bellies")
        return
    end
    local sex = Osi.GetBodyType(pred, 1)
    -- Only female belly is currently implemented.
    if BellyTable[predRace].Sexes == false then
        sex = "Sex"
    end
    if BellyTable[predRace][sex] == nil then
        _P("Sex " .. sex .. " does not support bellies")
        return
    end
    local bodyShape = 0
    if BellyTable[predRace][sex].BodyShapes then
        local tags = Ext.Entity.Get(pred).Tag.Tags
        for _, v in pairs(tags) do
            if v == "d3116e58-c55a-4853-a700-bee996207397" then
                bodyShape = 1
            end
        end
    end
    if BellyTable[predRace][sex][bodyShape] == nil then
        _P("Body shape " .. bodyShape .. " does not support bellies")
        return
    end
    -- fixes most npcs not having a field that stores visual overrides
    local predData = Ext.Entity.Get(pred)
    if predData.CharacterCreationAppearance == nil then
        predData:CreateComponent("CharacterCreationAppearance")
    end
    -- Clears overrides. Changed this so it will remove all belly-related visual overrides, meaning it should not break on polymorph
    -- need to test ObjectTransformed (I hope that means polymorph)
    for k, v in pairs(predData.CharacterCreationAppearance.Visuals) do
        if AllBellies[v] == true then
            Osi.RemoveCustomVisualOvirride(pred, v)
        end
    end

    -- for size change
    local predSizeCategory = predData.ObjectSize.Size

    if predSizeCategory ~= nil then
        if predSizeCategory > BellyTable[predRace].DefaultSize then
            weight = weight // (predSizeCategory - BellyTable[predRace].DefaultSize + 1)
        elseif predSizeCategory < BellyTable[predRace].DefaultSize then
            weight = weight * (BellyTable[predRace].DefaultSize - predSizeCategory + 1)
        end
    end

    local bellySize = 0
    for k, v in pairs(BellyTable[predRace][sex][bodyShape]) do
        if weight > k and k > bellySize then
            bellySize = k
        end
    end
    -- Delay is necessary, otherwise will not work.
    if bellySize > 0 then
        SP_DelayCallTicks(2, function ()
            Osi.AddCustomVisualOverride(pred, BellyTable[predRace][sex][bodyShape][bellySize])
        end)
    end
end

---Gets the proper number of stuffed stacks based on prey size
---@param preySize number size of the prey
function SP_GetStuffedStacksBySize(preySize)
    preySize = preySize - 2
    if preySize < 0 then
        preySize = 0
    elseif preySize == 0 then
        preySize = 1
    elseif preySize == 1 then
        preySize = 8
    elseif preySize == 2 then
        preySize = 64
    elseif preySize == 3 then
        preySize = 512
    end
    return preySize
end

---Checks if eating a character would exceed pred's carry limit.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_CanFitPrey(pred, prey)
    local predData = Ext.Entity.Get(pred)
    local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight) / 1000
    if Osi.HasPassive(pred, "SP_BottomlessStomach") == 1 then
        predRoom = predRoom * 2
    end
    if Osi.HasPassive(prey, "SP_Dense") == 1 then
        predRoom = predRoom // 2
    end
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
    -- bottomless stomach passive does not reduce the weight of items because of how it works
    local itemData = Ext.Entity.Get(item).Data.Weight
    if predRoom > itemData then
        return true
    else
        _P("Can't fit " .. item " inside " .. pred)
        return false
    end
end

---Determines how overstuffed a pred is and applies the proper status stacks
---@param pred CHARACTER
function SP_ApplyOverstuffing(pred)
    local mediumCharacterWeight = 75000
    local predData = Ext.Entity.Get(pred)
    local overStuff = (predData.InventoryWeight.Weight - predData.EncumbranceStats["HeavilyEncumberedWeight"]) // mediumCharacterWeight
    Osi.RemoveStatus(pred, "SP_OverstuffedDamage")
    if overStuff > 0 then
        Osi.ApplyStatus(pred, "SP_OverstuffedDamage", overStuff * SecondsPerTurn)
    end
end

---Handles rolling checks.
---@param pred CHARACTER
---@param prey CHARACTER
---@param eventName string Name that RollResult should look for. No predetermined values, can be whatever.
function SP_VoreCheck(pred, prey, eventName)
    local advantage = 0
    local preyAdvantage = 0
    if ConfigVars.Mechanics.VoreDifficulty.value == 'easy' then
        advantage = 1
    end
    if eventName == 'StruggleCheck' then
        _P("Rolling struggle check")
        if Osi.HasPassive(pred, 'SP_StretchyMaw') == 1 then
            advantage = 1
        end
        if Osi.HasPassive(prey, 'SP_EscapeArtist') == 1 then
            preyAdvantage = 1
        end
        Osi.RequestPassiveRollVersusSkill(prey, pred, "SkillCheck", "Strength", "Constitution", preyAdvantage, advantage,
                                          eventName)
    elseif string.sub(eventName, 1, #eventName - 2) == 'SwallowLethalCheck' then
        _P('Rolling to resist swallow')
        if Osi.HasPassive(pred, 'SP_StretchyMaw') == 1 or Osi.HasActiveStatusWithGroup(prey, 'SG_Charmed') == 1 or
            Osi.HasActiveStatusWithGroup(prey, 'SG_Restrained') == 1 or Osi.HasActiveStatusWithGroup(prey, 'SG_Unconscious') == 1 or
            Osi.HasActiveStatus(prey, "SP_Tasty") == 1 then
            advantage = 1
        end
        if Osi.HasActiveStatus(prey, "SP_Disgusting") == 1 then
            advantage = 2 - advantage * 2
        end
        if VoreData[prey] ~= nil and VoreData[prey].StuffedStacks > 0 then
            preyAdvantage = 1
        end
        local predStat = 'Athletics'
        local preyStat = 'Athletics'
        if Osi.HasSkill(pred, "Acrobatics") > Osi.HasSkill(pred, "Athletics") then
            predStat = "Acrobatics"
        end
        if Osi.HasSkill(prey, "Acrobatics") > Osi.HasSkill(prey, "Athletics") then
            preyStat = "Acrobatics"
        end
        Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", predStat, preyStat, advantage, preyAdvantage, eventName)
    elseif eventName == 'SwallowDownCheck' then
        _P('Rolling to resist secondary swallow')
        if Osi.HasPassive(pred, 'SP_StretchyMaw') == 1 or Osi.HasActiveStatusWithGroup(prey, 'SG_Charmed') == 1 or
            Osi.HasActiveStatusWithGroup(prey, 'SG_Restrained') == 1 or Osi.HasActiveStatusWithGroup(prey, 'SG_Unconscious') == 1 or
            Osi.HasActiveStatus(prey, "SP_Tasty") == 1 then
            advantage = 1
        end
        if Osi.HasActiveStatus(prey, "SP_Disgusting") == 1 then
            advantage = 2 - advantage * 2
        end
        if VoreData[prey] ~= nil and VoreData[prey].StuffedStacks > 0 then
            preyAdvantage = 1
        end
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
        Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", predStat, preyStat, advantage, preyAdvantage, eventName)
    elseif eventName == 'ReleaseMeCheck' then
        _P('Rolling to free me')
        if VoreData[prey].Digestion == 1 then
            advantage = 1
        else
            preyAdvantage = 1
        end
        Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Wisdom", "Charisma", advantage, preyAdvantage, eventName)
    end
end

---Reduces weight of prey and their preds, do not use this for regurgitation during voreception,
---since pred's weight would stay the same.
---@param character CHARACTER
---@param diff integer Amount to subtract.
---@param updateWeight? boolean Update visual weight / placeholders of characters.
---       This should be false in the OnReset functions, otherwise it might
---       update the weight of a single pred multiple times during one tick
---       and bug out Osiris.
function SP_ReduceWeightRecursive(character, diff, updateWeight)
    if character == nil then
        return
    end
    if VoreData[character].Pred ~= "" then
        VoreData[character].Weight = VoreData[character].Weight - diff
        if updateWeight then
            SP_UpdateWeight(character)
        end
        if VoreData[VoreData[character].Pred].Pred ~= "" then
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

            if ConfigVars.Mechanics.BoilingInsidesFast.value and Osi.HasPassive(v.Pred, "SP_BoilingInsides") == 1 then
                thisAddDiff = thisAddDiff * 2
            end
            --
            if (v.AddWeight - weightDiff) < 0 then
                thisAddDiff = v.AddWeight
            end
            VoreData[k].AddWeight = VoreData[k].AddWeight - thisAddDiff
            if ConfigVars.Hunger.Hunger.value and Osi.IsPartyMember(k, 0) == 1 then
                VoreData[k].Satiation = VoreData[k].Satiation +
                    thisAddDiff * ConfigVars.Hunger.HungerSatiationRate.value // 100
            end
            SP_ReduceWeightRecursive(v.Pred, thisAddDiff, false)
        end
    end

    -- reduces prey weight
    for k, v in pairs(VoreData) do
        if v.Digestion == 1 then
            local thisDiff = weightDiff
            if ConfigVars.Mechanics.BoilingInsidesFast.value and Osi.HasPassive(v.Pred, "SP_BoilingInsides") == 1 then
                thisDiff = thisDiff * 2
            end
            -- Prey's weight after digestion should not be smaller then 1/5th of their original (fake) weight.
            if (v.Weight - weightDiff) < (v.FixedWeight // 5) then
                thisDiff = v.Weight - v.FixedWeight // 5
            end
            if ConfigVars.WeightGain.WeightGain.value then
                VoreData[v.Pred].Fat = VoreData[v.Pred].Fat +
                    thisDiff * ConfigVars.WeightGain.WeightGainRate.value // 100
            end
            -- if prey is not aberration or elemental or pred has boilinginsides, add satiation
            if ConfigVars.Hunger.Hunger.value and Osi.IsPartyMember(v.Pred, 0) == 1 and
                (Osi.IsTagged(k, "f6fd70e6-73d3-4a12-a77e-f24f30b3b424") == 0 and
                    Osi.IsTagged(k, "196351e2-ff25-4e2b-8560-222ac6b94a54") == 0 and
                    Osi.IsTagged(k, "22e5209c-eaeb-40dc-b6ef-a371794110c2") == 0 and
                    Osi.IsTagged(k, "33c625aa-6982-4c27-904f-e47029a9b140") == 0 or
                    Osi.HasPassive(v.Pred, "SP_BoilingInsides") == 1) then
                VoreData[v.Pred].Satiation = VoreData[v.Pred].Satiation +
                    thisDiff * ConfigVars.Hunger.HungerSatiationRate.value // 100
            end
            SP_ReduceWeightRecursive(k, thisDiff, false)
            -- if prey is endoed and pred has soothing stomach, add satiation
        elseif v.Digestion == 0 then
            if ConfigVars.Hunger.Hunger.value and Osi.IsPartyMember(v.Pred, 0) == 1 and Osi.HasPassive(v.Pred, "SP_SoothingStomach") == 1 then
                VoreData[v.Pred].Satiation = VoreData[v.Pred].Satiation +
                    weightDiff * ConfigVars.Hunger.HungerSatiationRate.value // 100
            end
        end
    end
    for k, v in pairs(VoreData) do
        SP_UpdateWeight(k)
    end
    for k, v in pairs(VoreData) do
        SP_VoreDataEntry(k, false)
    end
end

---Recursively generates a list of all nested prey
---@param pred GUIDSTRING
---@param voreLocus string options: "O" == Oral, "A" == Anal, "U" == Unbirth, "All" == all prey in any locus
---@param digestionType? integer Only count prey of this type: 0 == endo, 1 == dead, 2 == lethal, 3 == none
---@return table
function SP_GetNestedPrey(pred, voreLocus, digestionType)
    if VoreData[pred] == nil or next(VoreData[pred].Prey) == nil then
        return {}
    end
    _D(VoreData[pred])
    local allPrey = SP_FilterPrey(pred, voreLocus, nil, digestionType)
    for k, _ in pairs(allPrey) do
        allPrey = SP_TableConcat(allPrey, SP_GetNestedPrey(k, voreLocus, digestionType))
    end
    return allPrey
end

---Filters out prey with a specific prey type and returns them
---@param pred CHARACTER pred to querey
---@param locus string options: "O" == Oral, "A" == Anal, "U" == Unbirth, "All" == all prey in any locus
---@param partyMember? boolean if true, will only return prey in the party
---@param digestionType? integer options: 0 == endo, 1 == dead, 2 == lethal, 3 == none
---@return table
function SP_FilterPrey(pred, locus, partyMember, digestionType)
    local output = {}
    for k, v in pairs(VoreData[pred].Prey) do
        if (VoreData[k].Digestion == digestionType or digestionType == nil) and (locus == v or locus == "All") and (Osi.IsPartyMember(k, 0) == 1 or partyMember == nil) then
            table.insert(output, k)
        end
    end
    return output
end

---switches to a different type of digestion
---do not forget to copy VoreData after using this
---@param pred CHARACTER
---@param prey CHARACTER
---@param fromDig integer fromDig switch from this digestion type
---@param toDig integer fromDig switch from this digestion type
function SP_SwitchToDigestionType(pred, prey, fromDig, toDig)
    if VoreData[prey].Digestion == fromDig then
        VoreData[prey].Digestion = toDig
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

---returns what swallowed status should be appled to a prey
---@param pred CHARACTER
---@param prey CHARACTER
---@param endo boolean
---@param locus string
---@return string
function SP_GetSwallowedVoreStatus(pred, prey, endo, locus)
    local correctlocus = false
    for k, v in pairs(ConfigVars.Mechanics.StatusBonusLocus.value) do
        if string.sub(v, 1, 1) == locus then
            correctlocus = true
        end
    end
    if correctlocus then
        if endo then
            if Osi.HasPassive(prey, "SP_Gastronaut") == 1 or Osi.HasPassive(pred, "SP_MuscleControl") == 1 then
                return "SP_SwallowedXray"
            elseif Osi.HasPassive(prey, "SP_BellyDiver") == 1 then
                return "SP_SwallowedDiver"
            else
                return "SP_SwallowedGentle"
            end
        elseif Osi.HasPassive(prey, "SP_BellyDiver") == 1 then
            return "SP_SwallowedDiver"
        else
            return "SP_Swallowed"
        end
    else
        return "SP_Swallowed"
    end
end

---returns what swallowed status should be appled to a pred
---@param pred CHARACTER
---@param stacks integer
---@return string
function SP_GetStuffedVoreStatus(pred, stacks)
    if Osi.HasPassive(pred, "SP_Musclegut") == 1 then
        if stacks > 2 then
            return "SP_ImprovedStuffedIntimidate"
        else
            return "SP_ImprovedStuffed"
        end
    else
        return "SP_Stuffed"
    end
end

---returns what swallowed status should be appled to a prey on swallow
---@param pred CHARACTER
---@param endo boolean
---@return string
function SP_GetSwallowVoreStatus(pred, endo)
    if Osi.HasPassive(pred, "SP_MuscleControl") == 1 and endo then
        return "SP_PartiallySwallowedGentle"
    else
        return "SP_PartiallySwallowed"
    end
end

---plays a random gurgle
---@param pred GUIDSTRING
function SP_PlayGurgle(pred)
    local basePercentage = ConfigVars.VisualsAndAudio.GurgleProbability.value
    if basePercentage > 100 then
        basePercentage = 100
    elseif basePercentage == 0 or #GurgleSounds == 0 then
        return
    end
    ---convert the percentage
    basePercentage = 100 * #GurgleSounds // basePercentage
    local randomResult = Osi.Random(basePercentage) + 1
    if randomResult <= #GurgleSounds then
        Osi.PlaySound(pred, GurgleSounds[randomResult])
    end
end

---@param character CHARACTER
function SP_AssignRoleRandom(character)
    if Osi.HasPassive(character, "SP_BlockGluttony") == 1 or Osi.HasPassive(character, "SP_Gluttony") == 1 then
        return
    end
    if Osi.IsTagged(character, "ee978587-6c68-4186-9bfc-3b3cc719a835") == 1 then
        Osi.AddPassive(character, "SP_BlockGluttony")
        Osi.AddPassive(character, "SP_Inedible")
        return
    end
    if Ext.Entity.Get(character).ServerCharacter.Temporary == true then
        Osi.AddPassive(character, "SP_BlockGluttony")
        return
    end
    local race = Osi.GetRace(character, 0)
    if RaceConfigVars[race] == nil then
        _P("Race not supported " .. race)
        Osi.AddPassive(character, "SP_BlockGluttony")
        return
    end
    local selectedPobability = 0
    if RaceConfigVars[race] == nil then
        selectedPobability = 0
    elseif SINGLE_GENDER_CREATURE[race] == true then
        selectedPobability = ConfigVars.NPCVore.ProbabilityCreature.value * RaceConfigVars[race]
    elseif Osi.GetBodyType(character, 0) == "Female" then
        selectedPobability = ConfigVars.NPCVore.ProbabilityFemale.value * RaceConfigVars[race]
    elseif Osi.GetBodyType(character, 0) == "Male" then
        selectedPobability = ConfigVars.NPCVore.ProbabilityMale.value * RaceConfigVars[race]
    end
    local size = SP_GetCharacterSize(character)
    if size == 0 and selectedPobability > ConfigVars.NPCVore.ClampTiny.value then
        selectedPobability = ConfigVars.NPCVore.ClampTiny.value
    elseif size == 1 and selectedPobability > ConfigVars.NPCVore.ClampSmall.value then
        selectedPobability = ConfigVars.NPCVore.ClampSmall.value
    end
    if PRED_NPC_TABLE[character] ~= nil and (selectedPobability > 0 or ConfigVars.NPCVore.SpecialNPCsOverridePreferences.value) then
        Osi.AddPassive(character, "SP_Gluttony")
    elseif selectedPobability > 0 then
        local randomRoll = Osi.Random(100) + 1
        if randomRoll <= selectedPobability then
            _P("Adding PRED to " .. character)
            Osi.AddPassive(character, "SP_Gluttony")
        else
            _P("Adding PREY to " .. character)
            Osi.AddPassive(character, "SP_BlockGluttony")
        end
    end
end


---finds and removes prey that were erased from existence for some unknown reason
function SP_CheckVoreData()
    for k, v in pairs(VoreData) do
        local dead = Osi.IsDead(k)
        local character = Osi.IsCharacter(k)
        if dead == nil or character == 0 then
            _F(k .. " WAS ERASED FROM EXISTENSE")
            if next(v.Prey) ~= nil then
                _P(k .. " WAS A PRED")
            end
            if v.Pred ~= "" then
                local pred = v.Pred
                VoreData[pred].AddWeight = VoreData[pred].AddWeight + v.Weight
                VoreData[k] = nil
                VoreData[pred].Prey[k] = nil
            end
        end
    end
end

---resets missing values in VoreData to default value from VoreDataEntry
---not usable for something more complex
function SP_MigratePersistentVars()
    for k, v in pairs(VoreData) do
        for i, j in pairs(VoreDataEntry) do
            if v[i] == nil then
                _F('Character: ' .. k)
                _F('Missing value: ' .. i)
                if type(j) == "table" then
                    VoreData[k][i] = SP_Deepcopy(j)
                else
                    VoreData[k][i] = j
                end
            end
        end
    end
end

---Console command for printing config options and states.
function VoreConfigOptions()
    _P("Vore Mod Configuration Options: ")
    for k, v in pairs(ConfigVars) do
        _P(k .. ": ")
        for i, j in pairs(v) do
            _P(i .. ": " .. j.description)
            _P("Currently set to " .. tostring(j.value))
        end
    end
end
