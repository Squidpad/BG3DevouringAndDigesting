-- A new way to store data about every character that is involved in vore
---@type table<CHARACTER, VoreDataEntry>
VoreData = {}

--- bellies that will be updated on next tick
---@type table<CHARACTER, boolean>
WeightQueue = {}

--- bellies that are currently being updated
---@type table<CHARACTER, boolean>
WeightQueueRunning = {}

--- bellies that we need to update again after they are finished being updated
---@type table<CHARACTER, boolean>
WeightQueueWaiting = {}

---Adds or deletes VoreData of a character
---@param character CHARACTER
---@param create boolean will not delete entry if true
function SP_VoreDataEntry(character, create)
    if VoreData[character] == nil and create then
        _P("Adding character " .. character)
        SP_NewVoreDataEntry(character)
    elseif VoreData[character].Pred == "" and next(VoreData[character].Prey) == nil and VoreData[character].Items == ""
        and VoreData[character].Fat == 0 and VoreData[character].AddWeight == 0 and VoreData[character].Satiation == 0 and
        next(VoreData[character].SpellTargets) == nil and not create then
        _P("Removing character " .. character)
        VoreData[character] = nil
    end
end

---@param character CHARACTER
function SP_NewVoreDataEntry(character)
    VoreData[character] = SP_Deepcopy(VoreDataEntry)
    VoreData[character].Combat = Osi.CombatGetGuidFor(character) or ""
end

---returns true is a character participates in vore as a pred
---@param character CHARACTER
---@param mode? integer 0/null = only if pred has acrive prey/items, 1 = if pred also has addweight, 2 = if pred has any of pred stats
---@return boolean
function SP_IsPred(character, mode)
    if VoreData[character] == nil then
        return false
    end
    if next(VoreData[character].Prey) ~= nil then
        return true
    end
    if VoreData[character].Items ~= "" then
        return true
    end
    if mode ~= nil then
        if mode > 0 and VoreData[character].AddWeight > 0 then
            return true
        end
        if mode > 1 and (VoreData[character].Fat > 0 or VoreData[character].Satiation > 0) then
            return true
        end
    end
    return false
end

---checks if pred can swallow prey
---@param pred CHARACTER
---@param prey CHARACTER
---@param digestionType integer
---@return boolean
function SP_VorePossible(pred, prey, digestionType)
    if Osi.HasPassive(prey, "SP_Inedible") ~= 0 or Osi.HasActiveStatus(pred, "SP_CooldownSwallow") ~= 0 or
        Osi.HasActiveStatus(pred, "SP_SC_BlockVoreTotal") ~= 0 then
        return false
    end
    if VoreData[pred] ~= nil and VoreData[pred].Pred == prey then
        Osi.ApplyStatus(pred, "SP_AI_HELPER_BLOCKVORE", SecondsPerTurn * SP_MCMGet("CooldownMax"), 1, prey)
        return false
    end
    local isItem = Osi.IsItem(prey) == 1
    if isItem and not SP_MCMGet("ItemVore") then
        return false
    end
    if not SP_MCMGet("AllowOverstuffing") and ((isItem and not SP_CanFitItem(pred, prey)) or
            (not isItem and not SP_CanFitPrey(pred, prey, digestionType))) then
        Osi.ApplyStatus(pred, "SP_Cant_Fit_Prey", SecondsPerTurn * 6, 1, prey)
        return false
    end
    return true
end

---Set's locus digestion for a pred
---@param pred CHARACTER
---@param locus string first letter of locus name or "All" for all loci
---@param lethal boolean true == to lethal, false == to endo
---@param force? boolean forcefully stop digestion and switch to endo
---@param initialize? boolean switches DType.None characters to DType.Dead if they are dead or current locus digestion if they are not. param lethal is ignored
function SP_SetLocusDigestion(pred, locus, lethal, force, initialize)
    if locus == "All" then
        for k, _ in pairs(EnumLoci) do
            SP_SetLocusDigestion(pred, k, lethal, force, initialize)
        end
        return
    end

    if EnumLociFeat[locus] == nil then
        _P("Trying to switch wrong locus name " .. locus .. " for " .. pred)
        return
    end
    -- can't print out boolean
    local dname = "Endo"
    if initialize then
        dname = "Initial"
    elseif lethal then
        dname = "Lethal"
    end
    _P("Switching ".. pred .." Locus ".. locus .. " to digestion " .. dname)

    -- only set prey without digestion to correct digestion for them
    if initialize and VoreData[pred] ~= nil then
        for prey, loc in pairs(VoreData[pred].Prey) do
            if loc == locus then
                if Osi.IsDead(prey) ~= 1 then
                    if Osi.HasActiveStatus(pred, "SP_LocusLethal_" .. locus) == 1 then
                        SP_SwitchToDigestionType(pred, prey, DType.Lethal)
                    else
                        SP_SwitchToDigestionType(pred, prey, DType.Endo)
                    end
                else
                    SP_SwitchToDigestionType(pred, prey, DType.Dead)
                end
            end
        end
        return
    end

    if VoreData[pred] == nil then
        if not lethal and Osi.HasActiveStatus(pred, "SP_LocusLethal_" .. locus) == 1 then
            Osi.RemoveStatus(pred, "SP_LocusLethal_" .. locus)
        elseif lethal and Osi.HasActiveStatus(pred, "SP_LocusLethal_".. locus) ~= 1 then
            Osi.ApplyStatus(pred, "SP_LocusLethal_" .. locus, -1, 1, pred)
        end
        _P("Returning because " .. pred .. " has no VoreData")
        return
    end
    -- pred has lethal swallowed prey in this locus
    local hasLethals = false
    for prey, loc in pairs(VoreData[pred].Prey) do
        if loc == locus and VoreData[prey].Digestion == DType.Lethal then
            hasLethals = true
        end
    end

    if hasLethals and not lethal and not SP_MCMGet("SwitchLethalEndo") and not force then
        _P("Cannot switch digestion from lethal to endo")
        SP_SetLocusDigestion(pred, locus, true)
        return
    end

    if not force and not initialize and lethal and Osi.HasPassive(pred, EnumLociFeat[locus]) == 0 then
        --_P("Cannot switch locus " .. locus .. " to lethal because " .. pred .. " doesn't have this vore type")
        return
    end

    if not lethal and Osi.HasActiveStatus(pred, "SP_LocusLethal_" .. locus) == 1 then
        Osi.RemoveStatus(pred, "SP_LocusLethal_" .. locus)
    elseif lethal and Osi.HasActiveStatus(pred, "SP_LocusLethal_".. locus) ~= 1 then
        Osi.ApplyStatus(pred, "SP_LocusLethal_" .. locus, -1, 1, pred)
    end


    for prey, loc in pairs(VoreData[pred].Prey) do
        if loc == locus and VoreData[prey].Digestion ~= DType.Dead then
            
            if lethal then
                SP_SwitchToDigestionType(pred, prey, DType.Lethal)
            else
                SP_SwitchToDigestionType(pred, prey, DType.Endo)
            end
        end
    end
end

---This adds a prey to pred without updating pred's weight
---Separated this from SP_SwallowPrey to create SP_SwallowPreyMultiple
---Otherwise the UpdateWeight will be called multiple times on the same tick, which will break osiris
---Also SP_Stuffed should not be applied and removed multiple times on the same tick
---@param pred CHARACTER
---@param prey CHARACTER
---@param swallowStages boolean If swallow happens in multiple stages
---@param locus string
function SP_AddPrey(pred, prey, swallowStages, locus)
    SP_VoreDataEntry(prey, true)

    local weight = SP_GetTotalCharacterWeight(prey)

    VoreData[prey].Locus = locus

    local predSize = SP_GetCharacterSize(pred)
    local preySize = SP_GetCharacterSize(prey)

    local oldPred = VoreData[prey].Pred

    VoreData[prey].Pred = pred
    VoreData[pred].Prey[prey] = locus

    -- reset swallow process in ALL cases
    VoreData[prey].SwallowProcess = 0

    if oldPred == "" then
        VoreData[prey].Weight = weight
        VoreData[prey].FixedWeight = weight

        Osi.AddSpell(prey, 'SP_Zone_ReleaseMe', 0, 0)
        Osi.AddSpell(prey, "SP_Zone_MoveToPred", 0, 0)
        if Osi.IsPlayer(prey) == 1 then
            if Osi.IsTagged(prey, "f7265d55-e88e-429e-88df-93f8e41c821c") == 1 then
                Osi.AddSpell(prey, "SP_Zone_PreySwallow_Endo_OAUC", 0, 0)
                Osi.AddSpell(prey, "SP_Zone_PreySwallow_Lethal_OAUC", 0, 0)
            end
        end

        Osi.SetVisible(prey, 0)
        if SP_MCMGet("DetachPrey") == true then
            Osi.SetDetached(prey, 1)
        end

        -- Tag that disables downed state.
        if Osi.IsTagged(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22') ~= 1 then
            Osi.SetTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
            VoreData[prey].DisableDowned = true
        end
        -- Tag that makes AI less likely to target prey, for edge cases
        if Osi.IsTagged(prey, '9787450d-f34d-43bd-be88-d2bac00bb8ee') ~= 1 then
            Osi.SetTag(prey, '9787450d-f34d-43bd-be88-d2bac00bb8ee')
            VoreData[prey].Unpreferred = true
        end

        if SP_MCMGet("SwallowDown") and swallowStages then
            VoreData[prey].SwallowProcess = preySize - predSize + 1
            --handle stretchy maw
            if Osi.HasPassive(pred, "SP_StretchyMaw") == 1 then
                VoreData[prey].SwallowProcess = VoreData[prey].SwallowProcess - 1
            end
            VoreData[prey].SwallowProcess = math.max(VoreData[prey].SwallowProcess, 0)
        end
        -- multi stage swallow
        if VoreData[prey].SwallowProcess > 0 then
            local pswallow = SP_GetPartialSwallowStatus(pred, prey)
            VoreData[prey].SwallowedStatus = pswallow
            Osi.ApplyStatus(prey, pswallow, (VoreData[prey].SwallowProcess + 1) * SecondsPerTurn, 1, pred)
            Osi.AddSpell(pred, 'SP_Zone_SwallowDown', 0, 0)
        else
            VoreData[prey].SwallowProcess = 0
        end
    -- character is being transferred from another stomach
    elseif VoreData[oldPred] ~= nil then

        -- if the old pred doesn't have this prey in it's prey list, this means the old prey has already regurigitated this prey
        -- for example this will happen when "swallow prey" is called from the regurigitate function (voreception)
        -- in this case, old pred has already been processed by the regurigitate function
        -- if it hasn't been processed by regurigitate function, we call the regurigitate function that will update the old pred
        if VoreData[oldPred].Prey[prey] ~= nil then
            SP_RegurgitatePrey(oldPred, prey, -1, "Transfer")
        end
    end

    SP_ReduceWeightRecursive(pred, -VoreData[prey].Weight, true, false)
end


---applies / removes the proper stuffed status to a pred
---@param pred CHARACTER pred to apply status to
function SP_UpdateStuffed(pred)
    -- removes all additional buffs/debuffs
    for status, _ in pairs(StuffedAdditions) do
        Osi.RemoveStatus(pred, status)
    end
    -- moved this here to allow it to function when VoreData[pred] == nil
    if Osi.HasPassive(pred, "SP_SC_KnowledgeWithin") == 1 then
        SP_SC_UpdateKnowledgeWithin(pred)
    end
    -- if no voredata, remove stuffed
    if VoreData[pred] == nil then
        Osi.RemoveStatus(pred, "SP_Stuffed")
        return
    end

    -- turn weight into stacks; 70 seems like a good number for 1 stack aka 2 goblins or slightly less than 1 human
    local weightPerStack = 70
    -- probability best to leave this as a constant
    local musclegutReduction = 4

    local stuffedStacks = 0
    local stacks = SP_Shallowcopy(StuffedAdditions)
    -- _D(stacks)
    -- calculate the weight of all preys
    for prey, locus in pairs(VoreData[pred].Prey) do
        -- initial prey weight
        -- the question is, should we also use VoreData[prey].WeightReduction here?
        local preyWeight = VoreData[prey].Weight
        -- reduction of prey weight
        -- it may not be yet calculated when UpdateStuffed is called, so it's re-calculated here
        -- more importantly, this weight reduction is not affected by things like SP_Cavernous
        local preyWeightReduction = 0

        -- handle passives here
        if Osi.IsPartyMember(prey, 0) == 1 then
            if Osi.HasPassive(pred, "SP_SC_StomachSanctuary") == 1 then
                -- how much stacks should be given by a single prey?
                stacks.SP_SC_StomachSanctuaryStuffed = stacks.SP_SC_StomachSanctuaryStuffed + 1
                preyWeightReduction = preyWeightReduction + preyWeight
            elseif Osi.HasPassive(pred, "SP_SC_StomachShelter") == 1 then
                -- how much stacks should be given by a single prey?
                stacks.SP_SC_StomachShelterStuffed = stacks.SP_SC_StomachShelterStuffed + 1
                preyWeightReduction = preyWeightReduction + preyWeight / 2
            end
            if Osi.HasPassive(pred, "SP_SC_StrengthFromMany") == 1 then
                stacks.SP_SC_StrengthFromMany_Status = stacks.SP_SC_StrengthFromMany_Status + 1
            end
        end
        -- end of passives

        -- total unmodified weight. Weight shouldn't be negative, but who knows
        stuffedStacks = stuffedStacks + math.max(preyWeight, 0)
        -- how much weight is counted for the debuff
        stacks.SP_StuffedDebuff = stacks.SP_StuffedDebuff + math.max(preyWeight - preyWeightReduction, 0)
    end

    -- calculate the weight of items
    if VoreData[pred].Items ~= "" and Osi.IsItem(VoreData[pred].Items) == 1 then
        local stomachWeight = Ext.Entity.Get(VoreData[pred].Items).InventoryWeight.Weight // GramsPerKilo

        stuffedStacks = stuffedStacks + stomachWeight
        stacks.SP_StuffedDebuff = stacks.SP_StuffedDebuff + stomachWeight
    end
    -- also add AddWeight
    stuffedStacks = stuffedStacks + VoreData[pred].AddWeight
    stacks.SP_StuffedDebuff = stacks.SP_StuffedDebuff + VoreData[pred].AddWeight

    
    stuffedStacks = stuffedStacks // weightPerStack
    stacks.SP_StuffedDebuff = stacks.SP_StuffedDebuff // weightPerStack


    -- here we handle passives that use the total amount of stacks
    if Osi.HasPassive(pred, "SP_Musclegut") == 1 then
        -- musclegut will now reduce the debuff stacks by flat 4
        stacks.SP_StuffedDebuff = stacks.SP_StuffedDebuff - musclegutReduction
        if stuffedStacks > 2 then
            stacks.SP_MusclegutIntimidate = 1
        end
    end
    -- we handle SP_Stuffed separately because it activates Digestion ticks, so it's better not to remove it every time a prey is swallowed
    -- if 0 stacks but the character is still a pred
    if stuffedStacks == 0 and (VoreData[pred].Items ~= "" or next(VoreData[pred].Prey) ~= nil) then
        stuffedStacks = 1
    end

    -- reduce the amount of stacks
    if stuffedStacks < VoreData[pred].StuffedStacks then
        Osi.RemoveStatus(pred, "SP_Stuffed")
        if stuffedStacks > 0 then
            Osi.ApplyStatus(pred, "SP_Stuffed", stuffedStacks * SecondsPerTurn, 1, pred)
        end
        -- increase the amount of stacks
    elseif stuffedStacks > VoreData[pred].StuffedStacks then
        Osi.ApplyStatus(pred, "SP_Stuffed", (stuffedStacks - VoreData[pred].StuffedStacks) * SecondsPerTurn, 1, pred)
    end
    -- save it to voredata
    VoreData[pred].StuffedStacks = stuffedStacks

    -- now apply everything else
    for k, v in pairs(stacks) do
        if v > 0 then
            Osi.ApplyStatus(pred, k, v * SecondsPerTurn, 1, pred)
        end
    end
end

---Should be called in any situation when prey must be swallowed.
---@param pred CHARACTER
---@param prey CHARACTER|table<CHARACTER>
---@param swallowType integer DType of swallow. DType.Dead/DType.None for initialization to pred's locus digestion
---@param swallowStages boolean If swallow happens in multiple stages
---@param locus string
function SP_SwallowPrey(pred, prey, swallowType, swallowStages, locus)

    if type(prey) == "string" then
        prey = {prey}
    end

    _P('Swallowing')

    SP_VoreDataEntry(pred, true)

    SP_AddPredSpells(pred)

    for _, oneprey in ipairs(prey) do
        SP_AddPrey(pred, oneprey, swallowStages, locus)
    end
    -- set prey digestion & update other prey
    if swallowType == DType.Endo then
        SP_SetLocusDigestion(pred, locus, false)
    elseif swallowType == DType.Lethal then
        SP_SetLocusDigestion(pred, locus, true)
    else
        SP_SetLocusDigestion(pred, locus, false, false, true)
    end
    -- DType.Dead only sets the digestion for preys without previously set digestion

    -- if it's nested vore, pred should already have prey inside his stomach (unless we're talking about preyStolen, but it's not implemented yet)
    -- one preyStolen is done, add a check here

    if SP_MCMGet("SweatyVore") == true then
        Osi.ApplyStatus(pred, "SWEATY", 5 * SecondsPerTurn)
    end
    _D(VoreData)
    _P('Swallowing END')
end


---Swallow an item.
---@param pred CHARACTER
---@param item ITEM
function SP_SwallowItem(pred, item)
    SP_VoreDataEntry(pred, true)

    if Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1 then
        if VoreData[pred].StuffedStacks == 0 then
            SP_AddPredSpells(pred, true)
        end
        local itemWeight = Ext.Entity.Get(item).Data.Weight // GramsPerKilo

        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.ToInventory(item, VoreData[pred].Items, 9999, 0, 0)


        SP_DelayCallTicks(4, function ()
            SP_ReduceWeightRecursive(pred, -itemWeight, true, false)
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
            SP_AddPredSpells(pred, true)
        end
        local itemWeight = Ext.Entity.Get(container).Data.InventoryWeight // GramsPerKilo

        VoreData[pred].Items = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
        Osi.MoveAllItemsTo(container, VoreData[pred].Items, 0, 0, 0, 0)
        Osi.MoveAllStoryItemsTo(container, VoreData[pred].Items, 0, 0)


        SP_DelayCallTicks(4, function ()
            SP_ReduceWeightRecursive(pred, -itemWeight, true, false)
        end)
    else
        Osi.TemplateAddTo('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1, 0)
        SP_DelayCallTicks(4, function ()
            SP_SwallowAllItems(pred, container)
        end)
    end
end

---digests a random item in pred's inventory
---@param pred CHARACTER
function SP_DigestItem(pred)
    if not SP_MCMGet("DigestItems") then
        return
    end
    -- the chance of an item being digested is 1/10 per Digestion tick
    if VoreData[pred].Items == "" and Osi.Random(10) ~= 1 then
        return
    end

    local itemList = Ext.Entity.Get(VoreData[pred].Items).InventoryOwner.PrimaryInventory:GetAllComponents()
        .InventoryContainer.Items
    local i = 0
    for k, v in pairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
        i = i + 1
        if Osi.IsStoryItem(uuid) == 0 and Osi.IsTagged(uuid, '983087c8-c9d3-4a87-bc69-65f9329666c8') == 0 and
            Osi.IsTagged(uuid, '7b96246c-54ba-43ea-b01d-4e0b20ad35f1') == 0 then
            _P("item" .. uuid)
            if Osi.IsConsumable(uuid) == 1 then
                Osi.Use(pred, uuid, "")
            else
                VoreData[pred].AddWeight = VoreData[pred].AddWeight + Ext.Entity.Get(uuid).Data.Weight // GramsPerKilo
                Osi.RequestDelete(uuid)
                Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', VoreData[pred].Items, 1, 0)
                SP_UpdateWeight(pred, true)
            end
            return
        end
    end
    -- removes empty stomach item
    if i == 0 then
        Osi.RequestDelete(VoreData[pred].Items)
        VoreData[pred].Items = ""
        Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)
    end
end

---Should be called in any situation when prey must be released, including pred's death.
---@param pred CHARACTER
---@param preyString GUIDSTRING | string either guid of prey, "All" to regurigitate all prey in given locus, or "Random" to regurgitate one prey at random
---@param preyState integer State of prey to regurgitate: 0 == alive, 1 == dead, -1 == all, 10 == alive and digested.
---@param spell? string Internal name of spell (this does not reflect the in-game spell used).
---@param locus? string locus to regurgitate from
function SP_RegurgitatePrey(pred, preyString, preyState, spell, locus)
    _P('Starting Regurgitation')

    SP_VoreDataEntry(pred, true)

    _P('Targets: ' .. preyString)
    local markedForRemoval = {}
    local markedForSwallow = {}
    local markedForErase = {}

    local regurgitatedLiving = 0

    local roll = -1
    if preyString == "Random" then
        roll = Osi.Roll(SP_TableLength(VoreData[pred].Prey))
    end
    -- Find prey to remove, clear their status, mark them for removal.
    for prey, v in pairs(VoreData[pred].Prey) do
        if preyString == "Random" then
            roll = roll - 1
        end
        if not locus or v == locus then
            local isReal = Osi.IsCharacter(prey)
            if isReal ~= 1 then
                _P("Trying to regurgitate a bad character " .. prey)
                VoreData[pred].Prey[prey] = nil
                table.insert(markedForErase, prey)
            end

            -- this is needed to regurgitate lethal vore characters when using regurgitation spell
            local stateCheck = VoreData[prey].Digestion
            if stateCheck == DType.Lethal then
                stateCheck = DType.Endo
            end
            if locus == "" then
                locus = nil
            end

            if isReal == 1 and (locus == nil or v == locus) and (preyString == "All" or prey == preyString or roll == 0) and (preyState == -1 or
                    ((stateCheck == preyState or preyState == 10) and
                        (stateCheck ~= 1 or (VoreData[prey].Weight <= VoreData[prey].FixedWeight // 5)))) then
                _P('Pred:' .. pred)
                _P('Prey:' .. prey)
                VoreData[pred].Prey[prey] = nil
                SP_ReduceWeightRecursive(pred, VoreData[prey].Weight, true, false)

                if VoreData[prey].Digestion == DType.Endo or VoreData[prey].Digestion == DType.Lethal then
                    regurgitatedLiving = regurgitatedLiving + 1
                end
                -- Voreception
                if VoreData[pred].Pred ~= "" and spell ~= "Transfer" then
                    table.insert(markedForSwallow, prey)
                    -- If no voreception, free prey.
                else
                    table.insert(markedForRemoval, prey)
                end
            end
        end
    end

    -- item regurigitation
    local regItems = false
    if VoreData[pred].Items ~= "" and (preyState ~= 1 and preyString == 'All' or spell == "ResetVore") and spell ~= "LevelChangeParty" and (locus == "O" or not locus) then
        regItems = true
        if VoreData[pred].Pred ~= "" then
            local weightDiff = Ext.Entity.Get(VoreData[pred].Items).InventoryWeight.Weight // GramsPerKilo
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
                    local predX, predY, predZ = Osi.GetPosition(pred)
                    -- Y-rotation == yaw.
                    local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
                    -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
                    predYRotation = (predYRotation + rotationOffset) * math.pi / 180
                    -- Equation for rotating a vector in the X dimension.
                    local newX = predX + SP_MCMGet("RegurgitationDistance") * math.cos(predYRotation)
                    -- Equation for rotating a vector in the Z dimension.
                    local newZ = predZ + SP_MCMGet("RegurgitationDistance") * math.sin(predYRotation)
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

    -- transfers prey to pred's pred for nested vore
    if #markedForSwallow > 0 then
        SP_SwallowPrey(VoreData[pred].Pred, markedForSwallow, VoreData[pred].Digestion, false, VoreData[pred].Locus)
    end

    -- offset to avoid placing prey into each other
    local rotationOffsetDisosal = 0
    local rotationOffsetDisosal1 = 30

    -- Remove regurgitated prey from the table and release them
    for _, prey in ipairs(markedForRemoval) do
        
        -- unique prey statuses
        -- they are here because they must be removed even during prey transfer
        Osi.RemoveStatus(prey, "SP_SC_GuardiansGift_Status")
        Osi.RemoveStatus(prey, "SP_StilledPrey")
        Osi.RemoveStatus(prey, "SP_StunnedPrey")
        Osi.RemoveStatus(prey, "SP_StruggleExhaustion")
        Osi.RemoveStatus(prey, "SP_ReformationStatus")

        if spell == "Transfer" then
            break
        elseif spell == 'Absorb' then
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
                        local predX, predY, predZ = Osi.GetPosition(pred)
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
            local predX, predY, predZ = Osi.GetPosition(pred)
            local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred)
            predYRotation = (predYRotation + rotationOffsetDisosal) * math.pi / 180
            local newX = predX + SP_MCMGet("RegurgitationDistance") * math.cos(predYRotation)
            local newZ = predZ + SP_MCMGet("RegurgitationDistance") * math.sin(predYRotation)
            Osi.TeleportToPosition(prey, newX, predY, newZ, "", 0, 0, 0, 0, 1)
            rotationOffsetDisosal = rotationOffsetDisosal + rotationOffsetDisosal1
            if Osi.HasPassive(prey, 'SP_EscapeArtist') == 0 then
                Osi.ApplyStatus(prey, "PRONE", 1 * SecondsPerTurn, 1, pred)
            end
            Osi.ApplyStatus(prey, "WET", 2 * SecondsPerTurn, 1, pred)
        end

        --clear universal prey statuses
        Osi.RemoveStatus(prey, VoreData[prey].DigestionStatus, pred)
        Osi.RemoveStatus(prey, VoreData[prey].SwallowedStatus, pred)
        Osi.RemoveStatus(prey, "SP_InLocus_" .. VoreData[prey].Locus, pred)

        -- clear prey spells
        Osi.RemoveSpell(prey, 'SP_Zone_ReleaseMe', 1)
        Osi.RemoveSpell(prey, 'SP_Zone_MoveToPred', 1)
        if Osi.IsPlayer(prey) == 1 then
            if Osi.IsTagged(prey, "f7265d55-e88e-429e-88df-93f8e41c821c") == 1 then
                Osi.RemoveSpell(prey, "SP_Zone_PreySwallow_Endo_OAUC", 1)
                Osi.RemoveSpell(prey, "SP_Zone_PreySwallow_Lethal_OAUC", 1)
            end
        end

        -- return prey to the world
        Osi.SetVisible(prey, 1)
        if SP_MCMGet("DetachPrey") == true then
            Osi.SetDetached(prey, 0)
        end

        --clear prey VoreDataEntry
        VoreData[prey].Locus = ""
        VoreData[prey].Digestion = DType.None
        VoreData[prey].SwallowedStatus = ""
        VoreData[prey].DigestionStatus = ""

        VoreData[prey].SwallowProcess = 0
        VoreData[prey].Weight = 0
        VoreData[prey].FixedWeight = 0

        if VoreData[prey].DisableDowned then
            Osi.ClearTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
            VoreData[prey].DisableDowned = false
        end
        if VoreData[prey].Unpreferred then
            Osi.ClearTag(prey, "9787450d-f34d-43bd-be88-d2bac00bb8ee")
            VoreData[prey].Unpreferred = false
        end
        VoreData[prey].Pred = ""
        SP_VoreDataEntry(prey, false)
        SP_UpdateWeight(prey)
    end


    --stop digestion if no living prey in locus
    local locpreycount = {["O"] = false, ["A"] = false, ["U"] = false, ["C"] = false}
    for py, loc in pairs(VoreData[pred].Prey) do
        if VoreData[py].Digestion == DType.Lethal then
            locpreycount[loc] = true
        end
    end
    for k, v in pairs(locpreycount) do
        if not v and Osi.HasActiveStatus(pred, "SP_LocusLethal_" .. k) == 1 then
            SP_SetLocusDigestion(pred, k, false)
        end
    end

    -- If pred has no more prey inside, remove spells
    SP_RemovePredSpells(pred)

    if not SP_HasLivingPrey(pred, true) and not SP_MCMGet("IndigestionRest") then
        Osi.RemoveStatus(pred, "SP_Indigestion")
    end

    for _, prey in ipairs(markedForErase) do
        VoreData[pred].AddWeight = VoreData[pred].AddWeight + VoreData[prey].Weight
        VoreData[prey] = nil
    end

    -- add swallow cooldown after regurgitation
    if (preyString == "All" and spell ~= "ResetVore" or spell == "SwallowFail") and regurgitatedLiving > 0 then
        if SP_MCMGet("CooldownSwallow") > 0 then
            Osi.ApplyStatus(pred, 'SP_CooldownSwallow', SP_MCMGet("CooldownSwallow") * SecondsPerTurn, 1)
        end
        if SP_MCMGet("CooldownRegurgitate") > 0 then
            Osi.ApplyStatus(pred, 'SP_CooldownRegurgitate', SP_MCMGet("CooldownRegurgitate") * SecondsPerTurn, 1)
        end
        if SP_MCMGet("RegurgitationHunger") > 0 and SP_MCMGet("Hunger") and Osi.IsPartyMember(pred, 0) == 1 then
            Osi.ApplyStatus(pred, 'SP_Hunger', SP_MCMGet("RegurgitationHunger") * SecondsPerTurn * regurgitatedLiving, 1)
        end
    end


    _P("New table: ")
    _D(VoreData)

    Osi.RemoveStatus(pred, "SP_Cant_Fit_Prey")

    SP_ReduceWeightRecursive(pred, 0, true, false)
    SP_VoreDataEntry(pred, false)
    _P('Ending Regurgitation')
end

-- the needs to be revised for the new extidehelpers.lua
-- ---Creates a new spell to regurgitate one specific prey TODO
-- ---@param prey GUIDSTRING guid of Prey
-- ---@return string spell
-- function SP_CreateCustomRegurgitate(pred, prey)
--     local stat = Ext.Stats.Create("SP_Zone_Regurgitate_X_" .. prey, "SpellData", "SP_Zone_Regurgitate")
--     stat.SpellFlags = "Temporary"
--     stat.DisplayName = "h339b4a78ga0a6g4b55g93fag7c8fb6725002"
--     stat.Description = "hfed57717ga1feg4c72gad20gbaaa9d1adf1b"
--     stat.DescriptionParams = SP_GetDisplayNameFromGUID(prey)
--     stat:Sync()
--     SP_DelayCallTicks(10, function () Osi.AddSpell(pred, "SP_Zone_Regurgitate_X_" .. prey, 0, 0) end)
--     return "SP_Zone_Regurgitate_X_" .. prey
-- end

---Handles rolling checks.
---@param pred CHARACTER
---@param prey CHARACTER
---@param eventName string Name that RollResult should look for. No predetermined values, can be whatever.
function SP_VoreCheck(pred, prey, eventName)
    local eventParams = SP_StringSplit(eventName, '_')
    local advantage = 0
    local preyAdvantage = 0
    if eventName == 'StruggleCheck' then
        _P("Rolling struggle check")
        if Osi.HasPassive(pred, 'SP_LeadBelly') == 1 then
            advantage = 1
        end
        if Osi.HasPassive(prey, 'SP_EscapeArtist') == 1 then
            preyAdvantage = 1
        end
        Osi.RequestPassiveRollVersusSkill(prey, pred, "SkillCheck", "Strength", "Constitution", preyAdvantage, advantage,
                                          eventName)
    elseif eventName == 'ReleaseMeCheck' then
        _P('Rolling to free me')
        local checkDC = 15
        local preyAdvantage = 0
        if VoreData[prey].Digestion == DType.Lethal then
            checkDC = checkDC + 5
        end
        Osi.RequestPassiveRoll(prey, pred, "SkillCheck", "Persuasion", DCTable[checkDC], preyAdvantage, eventName)
        -- Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Wisdom", "Charisma", advantage, preyAdvantage,
        --                                   eventName)
    end
end

--TODO: Reevaluate formula
---Determines how overstuffed a pred is and applies the proper status stacks
---@param pred CHARACTER
function SP_ApplyOverstuffing(pred)
    local mediumCharacterWeight = 75000
    local predData = Ext.Entity.Get(pred)
    local overStuff = math.ceil((predData.InventoryWeight.Weight - predData.EncumbranceStats["HeavilyEncumberedWeight"]) / mediumCharacterWeight)
    Osi.RemoveStatus(pred, "SP_OverstuffedDamage")
    if SP_IsPred(pred, 1) and overStuff > 0 then
        Osi.ApplyStatus(pred, "SP_OverstuffedDamage", overStuff * SecondsPerTurn)
    end
end

---@param pred CHARACTER
---@param prey CHARACTER
---@param digestionType integer
---@return number
function SP_CalculateWeightReduction(pred, prey, digestionType)

    local preyWeight = 0
    if VoreData[prey] ~= nil then
        preyWeight = VoreData[prey].Weight
    else
        preyWeight = SP_GetTotalCharacterWeight(prey)
    end

    -- there are two types of weight reduction - by increasing pred capacity multiplier, or by reducing the weight of a prey
    -- capacity increase is additive, prey weight reduction is multiplicative
    -- after that a total weight reduction is calculated for this prey

    local capacityMulti = 1

    if Osi.HasActiveStatus(pred, "SP_Bottomless") == 1 then
        preyWeight = 0
        return 0
    end
    if digestionType ~= DType.Lethal and Osi.IsPartyMember(prey, 0) == 1 then
        if Osi.HasPassive(pred, "SP_SC_StomachSanctuary") == 1 then
            preyWeight = 0
        elseif Osi.HasPassive(pred, "SP_SC_StomachShelter") == 1 then
            preyWeight = preyWeight / 2
        end
    end
    if Osi.HasPassive(pred, "SP_Cavernous") == 1 then
        capacityMulti = capacityMulti + 1
    end
    if Osi.HasActiveStatus(pred, "SP_Unburdened") == 1 then
        capacityMulti = capacityMulti + 1/3
    end
    if Osi.HasPassive(prey, 'SP_Dense') == 1 and digestionType == DType.Lethal then
        preyWeight = preyWeight * 2
    end

    preyWeight = math.max(preyWeight, 0)

    preyWeight = preyWeight // capacityMulti

    return preyWeight
end

---Changes the amount of Weight Placeholders by looking for weights of all prey in pred.
---Do not call manually call this
---@param pred CHARACTER
---@param noVisual boolean when we need to change the amount of weight placeholders but not the actual size of belly
function SP_DoUpdateWeight(pred, noVisual)
    WeightQueue[pred] = nil
    WeightQueueRunning[pred] = true

    local newWeight = 0
    local newWeightVisual = 0
    if SP_IsPred(pred, 2) then
        -- predator capacity multiplier
        for k, v in pairs(VoreData[pred].Prey) do

            local preyWeight = SP_CalculateWeightReduction(pred, k, VoreData[k].Digestion)

            -- stores by how much the weight of prey was reduced, so we can add this to the weight of pred if they are swallowed
            VoreData[k].WeightReduction = VoreData[k].Weight - preyWeight

            newWeight = newWeight + preyWeight
            if VoreData[k].Locus ~= 'C' then
                newWeightVisual = newWeightVisual + VoreData[k].Weight

            end
        end

        -- add weight that does not belong to a prey
        newWeight = newWeight + VoreData[pred].AddWeight
        -- add weight that does not belong to a prey
        newWeightVisual = newWeightVisual + VoreData[pred].Fat + VoreData[pred].AddWeight

        -- fat can be a float, so we round it
        newWeightVisual = math.floor(newWeightVisual)

        if VoreData[pred].Items ~= "" then
            newWeightVisual = newWeightVisual + Ext.Entity.Get(VoreData[pred].Items).InventoryWeight.Weight // GramsPerKilo
        end

        if Osi.HasActiveStatus(pred, "SP_BellyCompressed") == 1 then
            newWeightVisual = 0
        end

        Osi.CharacterRemoveTaggedItems(pred, '0e2988df-3863-4678-8d49-caf308d22f2a', 9999)
        _P("Changing weight of " .. pred .. " to " .. newWeightVisual)
        Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, newWeight, 0)
        -- This is very important, it fixes inventory weight not updating properly when removing items.
        -- This is the only solution that worked. 8d3b74d4-0fe6-465f-9e96-36b416f4ea6f is removed
        -- immediately after being added (in the main script).
        Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)

        SP_UpdateStuffed(pred)

    else
        if Osi.HasTaggedItem(pred, '0e2988df-3863-4678-8d49-caf308d22f2a') == 1 then
            _P("Removing weight placeholders from " .. pred)
            Osi.CharacterRemoveTaggedItems(pred, '0e2988df-3863-4678-8d49-caf308d22f2a', 9999)
            Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)
        end
        if Osi.HasActiveStatus(pred, "SP_Stuffed") == 1 then
            SP_UpdateStuffed(pred)
        end
    end

    if noVisual ~= true then
        if VoreData[pred] == nil then
            SP_UpdateBelly(pred, 0)
        elseif VoreData[pred].Pred == "" then
            SP_UpdateBelly(pred, newWeightVisual)
        end
    end
    -- the delay here is necessary because we wait until the potato is added
    SP_DelayCallTicks(6, function ()
        SP_ApplyOverstuffing(pred)
        -- once the belly update fully finishes, we update it again if necessary
        WeightQueueRunning[pred] = nil
        if WeightQueueWaiting[pred] ~= nil then
            local t = WeightQueueWaiting[pred]
            WeightQueueWaiting[pred] = nil
            SP_UpdateWeight(pred, t)
        end
    end)
end

---Enqueues this pred for weight update
---@param pred CHARACTER
---@param noVisual? boolean when we need to change the amount of weight placeholders but not the actual size of belly
function SP_UpdateWeight(pred, noVisual)
    if noVisual == nil then
        noVisual = false
    end
    -- if the belly needs to be updated but it's currently being updated, we queue it
    if WeightQueueRunning[pred] == true then
        if WeightQueueWaiting[pred] ~= false then
            WeightQueueWaiting[pred] = noVisual
        end
    -- otherwise we update it immediately
    elseif WeightQueue[pred] ~= false then
        WeightQueue[pred] = noVisual
    end
end

---updates all waiting bellies each tick
function SP_BellyQueueUpdate()
    if next(WeightQueue) ~= nil then
        for k, v in pairs(WeightQueue) do
            SP_DoUpdateWeight(k, v)
        end
    end
end

---Reduces weight of prey and their preds, do not use this for regurgitation during voreception,
---since pred's weight would stay the same.
---@param character CHARACTER
---@param diff integer Amount to subtract.
---@param reduceFixed boolean if we reduce the fixedweight of prey
---@param dontUpdateWeightFirst boolean will not update first character's belly size/weight placeholders.
---Set this to true when we're sure the amount of weight placeholders for this character should remain the same
function SP_ReduceWeightRecursive(character, diff, reduceFixed, dontUpdateWeightFirst)
    if character == nil or VoreData[character] == nil then
        return
    end
    local pred = VoreData[character].Pred
    if pred ~= "" then
        if reduceFixed then
            VoreData[character].FixedWeight = math.max(VoreData[character].FixedWeight - diff, 0)
        end
        VoreData[character].Weight = math.max(VoreData[character].Weight - diff, 0)
        if dontUpdateWeightFirst ~= true then
            SP_UpdateWeight(character)
        end
        SP_ReduceWeightRecursive(pred, diff, true, false)
    else
        SP_UpdateWeight(character)
    end
end

---one function for slow digestion
---@param weightDiff integer digestion amount
---@param fatDiff integer fat loss
function SP_SlowDigestion(weightDiff, fatDiff)
    _P("Slow Digestion:" .. weightDiff .. " " .. fatDiff)

    -- reduces fat and addWeight of a pred
    for k, v in pairs(VoreData) do
        if v.AddWeight > 0 then
            local thisAddDiff = weightDiff

            if SP_MCMGet("BoilingInsidesFast") and Osi.HasPassive(v.Pred, "SP_BoilingInsides") == 1 then
                thisAddDiff = thisAddDiff * 2
            end
            thisAddDiff = math.min(v.AddWeight, thisAddDiff)
            VoreData[k].AddWeight = math.max(0, v.AddWeight - thisAddDiff)
            if SP_MCMGet("Hunger") and Osi.IsPartyMember(k, 0) == 1 and v.Digestion ~= DType.Dead then
                VoreData[k].Satiation = v.Satiation + thisAddDiff * SP_MCMGet("HungerSatiationRate") / 100
            end
            if SP_MCMGet("WeightGain") and v.Digestion ~= DType.Dead then
                VoreData[k].Fat = v.Fat + thisAddDiff * SP_MCMGet("WeightGainRate") / 100
            end
            --since addweight is a part of character's weight if character with addweight is prey
            --we need to reduce weight of the character and all their preds
            --but because this is different from weight reduction from digestion, we also reduce fixedweight
            SP_ReduceWeightRecursive(k, thisAddDiff, true, false)
        end
        if SP_MCMGet("WeightGain") and VoreData[k].Fat > 0 then
            VoreData[k].Fat = math.max(0, VoreData[k].Fat - fatDiff)
            SP_UpdateWeight(k)
        end
    end

    -- reduces prey weight
    for k, v in pairs(VoreData) do
        local thisDiff = weightDiff
        if SP_MCMGet("BoilingInsidesFast") and Osi.HasPassive(v.Pred, "SP_BoilingInsides") == 1 and v.Digestion ~= DType.Endo then
            thisDiff = thisDiff * 2
        end
        -- reformation
        if v.Digestion == DType.Dead and Osi.HasActiveStatus(k, "SP_ReformationStatus") == 1 then
            thisDiff = math.min(v.FixedWeight - thisDiff, thisDiff)
            SP_ReduceWeightRecursive(k, -thisDiff, false, true)
            _P("Reformation: " .. thisDiff)
            -- end reformation
            if v.Weight >= v.FixedWeight then
                SP_Resurrect(k)
                _P("Reformation done")
            end
        -- digestion
        elseif v.Digestion == DType.Dead then
            -- Prey's weight after digestion should not be smaller then 1/5th of their original (fake) weight.
            thisDiff = math.min(v.Weight - v.FixedWeight // 5, thisDiff)
            if SP_MCMGet("WeightGain") then
                VoreData[v.Pred].Fat = VoreData[v.Pred].Fat +
                    thisDiff * SP_MCMGet("WeightGainRate") / 100
            end
            -- if prey is not aberration or elemental or pred has boilinginsides, add satiation
            if SP_MCMGet("Hunger") and Osi.IsPartyMember(v.Pred, 0) == 1 and
                (Osi.IsTagged(k, "f6fd70e6-73d3-4a12-a77e-f24f30b3b424") == 0 and
                    Osi.IsTagged(k, "196351e2-ff25-4e2b-8560-222ac6b94a54") == 0 and
                    Osi.IsTagged(k, "22e5209c-eaeb-40dc-b6ef-a371794110c2") == 0 and
                    Osi.IsTagged(k, "33c625aa-6982-4c27-904f-e47029a9b140") == 0 or
                    Osi.HasPassive(v.Pred, "SP_BoilingInsides") == 1) then
                VoreData[v.Pred].Satiation = VoreData[v.Pred].Satiation +
                    thisDiff * SP_MCMGet("HungerSatiationRate") / 100
            end
            SP_ReduceWeightRecursive(k, thisDiff, false, true)
        -- if prey is endoed and pred has soothing stomach, add satiation
        elseif v.Digestion == DType.Endo then
            if SP_MCMGet("Hunger") and Osi.IsPartyMember(v.Pred, 0) == 1 and Osi.HasPassive(v.Pred, "SP_SoothingStomach") == 1 then
                VoreData[v.Pred].Satiation = VoreData[v.Pred].Satiation +
                    weightDiff * SP_MCMGet("HungerSatiationRate") / 100
            end
        end
    end
end

---hunger system
---@param stacks integer how much hunger stacks to add
---@param isLong boolean is long rest
function SP_HungerSystem(stacks, isLong)
    -- hunger system
    if not SP_MCMGet("Hunger") then
        return
    end
    local party = Ext.Entity.Get(Osi.GetHostCharacter()).PartyMember.Party.PartyView.Characters

    for k, v in pairs(party) do
        local predData = v:GetAllComponents()
        local pred = predData.ServerCharacter.Template.Name .. "_" .. predData.Uuid.EntityUuid
        if Osi.IsTagged(pred, 'f7265d55-e88e-429e-88df-93f8e41c821c') == 1 and Osi.IsDead(pred) == 0 and Osi.IsPartyMember(pred, 0) == 1 then
            local hungerStacks = stacks + Osi.GetStatusTurns(pred, "SP_Hunger")
            local newhungerStacks = hungerStacks
            if VoreData[pred] ~= nil then
                local satiationDiff = VoreData[pred].Satiation // SP_MCMGet("HungerSatiation")
                newhungerStacks = hungerStacks - satiationDiff
                if newhungerStacks > 0 then
                    VoreData[pred].Satiation = 0
                else
                    VoreData[pred].Satiation = VoreData[pred].Satiation -
                        hungerStacks * SP_MCMGet("HungerSatiation")
                    newhungerStacks = 0
                end
                -- half of hunger stacks (rounded up) are removed with fat
                if newhungerStacks > 1 and SP_MCMGet("HungerUseFat") then
                    local hungerCompensation = (newhungerStacks + 1) // 2
                    satiationDiff = VoreData[pred].Fat // SP_MCMGet("HungerSatiation")
                    local newHungerCompensation = hungerCompensation - satiationDiff
                    if newHungerCompensation > 0 then
                        VoreData[pred].Fat = 0
                    else
                        VoreData[pred].Fat = VoreData[pred].Fat -
                            hungerCompensation * SP_MCMGet("HungerSatiation")
                        newHungerCompensation = 0
                    end
                    newhungerStacks = newhungerStacks + newHungerCompensation - hungerCompensation
                end
            end
            Osi.RemoveStatus(pred, 'SP_Hunger')
            Osi.RemoveStatus(pred, 'SP_HungerStage3')
            Osi.RemoveStatus(pred, 'SP_HungerStage2')
            Osi.RemoveStatus(pred, 'SP_HungerStage1')
            if newhungerStacks > 0 then
                Osi.ApplyStatus(pred, 'SP_Hunger', newhungerStacks * SecondsPerTurn, 1)
                -- random switch to lethal
                local lethalRandomSwitch = false
                if newhungerStacks >= SP_MCMGet("HungerBreakpoint3") then
                    lethalRandomSwitch = true
                    Osi.ApplyStatus(pred, 'SP_HungerStage3', -1, 1)
                elseif newhungerStacks >= SP_MCMGet("HungerBreakpoint2") then
                    Osi.ApplyStatus(pred, 'SP_HungerStage2', -1, 1)
                    if (not isLong and Osi.Random(2) == 1) or (isLong and Osi.Random(3) ~= 1) then
                        lethalRandomSwitch = true
                    end
                elseif newhungerStacks >= SP_MCMGet("HungerBreakpoint1") then
                    Osi.ApplyStatus(pred, 'SP_HungerStage1', -1, 1)
                    if (not isLong and Osi.Random(3) == 1) or (isLong and Osi.Random(2) == 1) then
                        lethalRandomSwitch = true
                    end
                end

                --Randomly start digesting prey because of hunger
                if VoreData[pred] ~= nil and lethalRandomSwitch and SP_MCMGet("LethalRandomSwitch") then
                    SP_SetLocusDigestion(pred, "All", true)
                    if isLong then
                        for i, j in pairs(VoreData[pred].Prey) do
                            Osi.ApplyDamage(i, 100, "Acid", pred)
                        end
                    end
                end
            end
        end
    end
end

---Digests dead prey by this amount.
---Can be used with a single prey or a table of prey
---@param pred CHARACTER
---@param allPrey table<CHARACTER, string>
---@param force integer set to 0 to fully digest
function SP_FastDigestion(pred, allPrey, force)
    if VoreData[pred] == nil then
        return
    end
    if Osi.HasPassive(pred, "SP_BoilingInsides") == 1 then
        force = force * 2
    end
    for prey, locus in pairs(allPrey) do
        if VoreData[prey] ~= nil then
            local preyWeightDiff = 0
            if VoreData[prey].Digestion == DType.Dead and Osi.HasActiveStatus(prey, "SP_ReformationStatus") == 1 then
                preyWeightDiff = math.min(VoreData[prey].FixedWeight - force, force)
                -- remembers all characters whose weight we need to update
                SP_ReduceWeightRecursive(prey, -preyWeightDiff, false, true)
                _P("Reformation: " .. preyWeightDiff)
                -- end reformation
                if VoreData[prey].Weight >= VoreData[prey].FixedWeight then
                    SP_Resurrect(prey)
                    _P("Reformation done")
                end
            elseif VoreData[prey].Digestion == DType.Dead then

                -- if force is 0 we fully digest the prey
                if force == 0 then
                    preyWeightDiff = VoreData[prey].Weight - VoreData[prey].FixedWeight // 5
                else
                    preyWeightDiff = math.min(VoreData[prey].Weight - VoreData[prey].FixedWeight // 5, force)
                end
                if SP_MCMGet("WeightGain") then
                    VoreData[pred].Fat = VoreData[pred].Fat +
                        preyWeightDiff * SP_MCMGet("WeightGainRate") / 100
                end
                if SP_MCMGet("Hunger") and Osi.IsPartyMember(pred, 0) == 1 and
                    (Osi.IsTagged(prey, "f6fd70e6-73d3-4a12-a77e-f24f30b3b424") == 0 and
                        Osi.IsTagged(prey, "196351e2-ff25-4e2b-8560-222ac6b94a54") == 0 and
                        Osi.IsTagged(prey, "22e5209c-eaeb-40dc-b6ef-a371794110c2") == 0 and
                        Osi.IsTagged(prey, "33c625aa-6982-4c27-904f-e47029a9b140") == 0 or
                        Osi.HasPassive(pred, "SP_BoilingInsides") == 1) then
                    VoreData[pred].Satiation = VoreData[pred].Satiation +
                        preyWeightDiff * SP_MCMGet("HungerSatiationRate") / 100
                end
                -- remembers all characters whose weight we need to update
                SP_ReduceWeightRecursive(prey, preyWeightDiff, false, true)
            end
        end
    end
end

---Returns character weight + their inventory weight.
---@param character CHARACTER character to querey
---@return integer total weight
function SP_GetTotalCharacterWeight(character)
    local charData = Ext.Entity.Get(character)
    local weight = 0
    -- in case the weight of prey's prey was reduced by prey's passive and
    -- prey's inventory weight + character weight does not reflect the full weight of their prey
    if VoreData[character] ~= nil then
        for k, v in pairs(VoreData[character].Prey) do
            weight = weight + VoreData[k].WeightReduction * GramsPerKilo
        end
    end
    if charData.Data ~= nil and charData.Data.Weight ~= nil then
        weight = weight + charData.Data.Weight
        if charData.InventoryWeight ~= nil then
            weight = weight + charData.InventoryWeight.Weight
        end
    end
    --_P("Total weight of " .. SP_GetDisplayNameFromGUID(character) .. " is " .. (weight // GramsPerKilo) .. " kg")
    return weight // GramsPerKilo
end

---Recursively generates a list of all nested prey
---@param pred GUIDSTRING
function SP_PlayGurgle(pred)
    local basePercentage = SP_MCMGet("GurgleProbability")
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

---returns what digestion status should be appled to a prey and if this digestion status is harmful
---@param pred CHARACTER
---@param prey CHARACTER
---@param digestionType integer
---@return string, boolean
function SP_GetDigestionVoreStatus(pred, prey, digestionType)

    local statusPrefix = "SP_Digestion_"
    local mainName = "Endo"
    local harmful = false

    if digestionType == DType.Dead then
        mainName = "Dead"
    elseif digestionType == DType.Endo then
        mainName = "Endo"
        if Osi.HasActiveStatus(pred, 'SP_HealingAcid_' .. VoreData[prey].Locus) == 1 then
            mainName = "HealingBig"
        end
    elseif digestionType == DType.Lethal then
        harmful = true
        mainName = "Lethal"
        if Osi.IsEnemy(pred, prey) ~= 1 and Osi.HasActiveStatus(pred, "SP_AN_Enable_HealingBelly") == 1 then
            harmful = false
            mainName = "HealingSmall"
        elseif Osi.HasPassive(pred, 'SP_BoilingInsides') == 1 then
            mainName = "LethalDouble"
        end
    end

    return statusPrefix .. mainName, harmful
end

---switches to a type of digestion
---@param pred CHARACTER
---@param prey CHARACTER
---@param toDig integer switch to this digestion type
function SP_SwitchToDigestionType(pred, prey, toDig)
    VoreData[prey].Digestion = toDig

    -- apply digestion status
    local harmful = false
    VoreData[prey].DigestionStatus, harmful = SP_GetDigestionVoreStatus(pred, prey, VoreData[prey].Digestion, VoreData[prey].Locus)
    if not SP_HasStatusWithCause(prey, VoreData[prey].DigestionStatus, pred) then
        Osi.ApplyStatus(prey, VoreData[prey].DigestionStatus, 1 * SecondsPerTurn, 1, pred)
    end
    -- apply restraining status
    if VoreData[prey].SwallowProcess == 0 then
        VoreData[prey].SwallowedStatus = SP_GetSwallowedVoreStatus(pred, prey, VoreData[prey].Digestion, VoreData[prey].Locus)
        if not SP_HasStatusWithCause(prey, VoreData[prey].SwallowedStatus, pred) then
            Osi.ApplyStatus(prey, VoreData[prey].SwallowedStatus, 100 * SecondsPerTurn, 1, pred)
        end
    end
    -- apply locus status
    if not SP_HasStatusWithCause(prey, "SP_InLocus_" .. VoreData[prey].Locus, pred) then
        Osi.ApplyStatus(prey, "SP_InLocus_" .. VoreData[prey].Locus, 1 * SecondsPerTurn, 1, pred)
    end
    --start combat
    if harmful and Osi.IsPartyMember(prey, 1) ~= 1 or Osi.IsAlly(pred, prey) ~= 1 then
        Osi.SetRelationTemporaryHostile(prey, pred)
        _P("Set hostile relationship")
    end
    if toDig ~= DType.Lethal then
        if not SP_MCMGet("IndigestionRest") and not SP_HasLivingPrey(pred, true) then
            Osi.RemoveStatus(pred, "SP_Indigestion")
        end
    end
    if toDig == DType.Endo and Osi.HasPassive(pred, "SP_SC_GuardiansGift") == 1 then
        Osi.ApplyStatus(prey, "SP_SC_GuardiansGift_Status", -1, 1, pred)
    elseif Osi.HasActiveStatus(prey, "SP_SC_GuardiansGift_Status") == 1 then
        Osi.RemoveStatus(prey, "SP_SC_GuardiansGift_Status")
    end
end

---switches to a different type of locus
---will automatically apply all the necessary statuses
---@param pred CHARACTER
---@param prey CHARACTER
---@param toLoc string fromDig switch to this locus
function SP_SwitchToLocus(pred, prey, toLoc)
    VoreData[prey].Locus = toLoc
    VoreData[pred].Prey[prey] = toLoc
    if VoreData[prey].Digestion ~= DType.Dead then
        if Osi.HasActiveStatus(pred, "SP_LocusLethal_" .. toLoc) == 1 then
            VoreData[prey].Digestion = DType.Lethal
        else
            VoreData[prey].Digestion = DType.Endo
        end
    end
    SP_SwitchToDigestionType(pred, prey, VoreData[prey].Digestion)
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
        if (VoreData[k].Digestion == digestionType or digestionType == nil) and (locus == v or locus == "All") and (Osi.IsPartyMember(k, 0) == 1 or partyMember ~= true) then
            table.insert(output, k)
        end
    end
    return output
end

---finds and removes prey that were erased from existence for some unknown reason
function SP_CheckVoreData()
    for k, v in pairs(VoreData) do
        local dead = Osi.IsDead(k)
        local character = Osi.IsCharacter(k)
        if dead == nil or character == nil or character == 0 then
            _F(k .. " WAS ERASED FROM EXISTENSE")
            if next(v.Prey) ~= nil then
                _P(k .. " WAS A PRED")
            end
            if v.Pred ~= "" then
                local pred = v.Pred
                VoreData[pred].AddWeight = VoreData[pred].AddWeight + v.Weight
                VoreData[pred].Prey[k] = nil
            end
            VoreData[k] = nil
        end
    end
end
