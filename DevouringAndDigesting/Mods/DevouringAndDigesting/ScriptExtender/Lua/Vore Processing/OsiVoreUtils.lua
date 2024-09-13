--- purely visual updating
---@param pred CHARACTER
---@param weight integer How many weight placeholders in inventory.
function SP_UpdateBelly(pred, weight)

    -- base volume ~ base weight
    -- offset is to account for some empty space inside the pred, which allows the pred to swallow light items without belly sticking out
    local baseVolume = 150
    local baseWeight = 80
    local offset = 10
    local volume = (weight * baseVolume / baseWeight - offset) * (SP_MCMGet("BellyScale") / 100)

    local predRace = Osi.GetRace(pred, 1)
    -- These races use the same or similar model.
    if string.find(predRace, 'Drow') ~= nil or string.find(predRace, 'Elf') ~= nil or string.find(predRace, 'Human') ~= nil or
        string.find(predRace, 'Aasimar') ~= nil or string.find(predRace, 'Tiefling') ~= nil then
        predRace = 'Human'
    elseif string.find(predRace, 'Gith') ~= nil then
        predRace = 'Gith'
    elseif string.find(predRace, 'Orc') ~= nil then
        predRace = 'Orc'
    elseif string.find(predRace, 'Dragonborn') ~= nil then
        predRace = 'Dragonborn'
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

    -- for size change
    local predSizeCategory = predData.ObjectSize.Size

    if predSizeCategory ~= nil then
        if predSizeCategory > BellyTable[predRace].DefaultSize then
            volume = volume / (predSizeCategory - BellyTable[predRace].DefaultSize + 1)
        elseif predSizeCategory < BellyTable[predRace].DefaultSize then
            volume = volume * (BellyTable[predRace].DefaultSize - predSizeCategory + 1)
        end
    end

    local bellySize = 0
    local bellyShape = ""
    for k, v in pairs(BellyTable[predRace][sex][bodyShape]) do
        if volume > k and k > bellySize then
            bellySize = k
            bellyShape = v
        end
    end
    

    -- Clears overrides. Changed this so it will remove all belly-related visual overrides, meaning it should not break on polymorph
    for k, v in pairs(predData.CharacterCreationAppearance.Visuals) do
        if AllBellies[v] == true and bellyShape ~= v then
            Osi.RemoveCustomVisualOvirride(pred, v)
        elseif bellyShape == v then
            bellyShape = ""
        end
    end
    -- Delay is necessary, otherwise will not work.
    if bellyShape ~= "" then
        SP_DelayCallTicks(2, function ()
            _P("Updating belly visual; Race: " .. predRace .. " Sex: " .. sex .. " Belly: " .. bellyShape)
            Osi.AddCustomVisualOverride(pred, bellyShape)
        end)
    end
end

---Checks if eating an item would exceed pred's carry limit.
---@param pred CHARACTER
---@param item GUIDSTRING
function SP_CanFitItem(pred, item)
    local predData = Ext.Entity.Get(pred)
    local predRoom = predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight
    -- Cavernous passive does not reduce the weight of items because of how it works
    local itemData = Ext.Entity.Get(item).Data.Weight
    if predRoom > itemData then
        return true
    else
        _P("Can't fit " .. item " inside " .. pred)
        return false
    end
end

---Checks if any of the pred's prey are still alive
---@param pred CHARACTER the pred to querey
---@param onlyLethal? boolean if true, only check prey being digested
---@return boolean
function SP_HasLivingPrey(pred, onlyLethal)
    for prey, _ in pairs(VoreData[pred].Prey) do
        if VoreData[prey].Digestion ~= DType.Dead and (VoreData[prey].Digestion == DType.Lethal or not onlyLethal) then
            return true
        end
    end
    return false
end


---Checks if eating a character would exceed pred's carry limit.
---@param pred CHARACTER
---@param prey CHARACTER
---@param digestionType integer
---@return boolean
function SP_CanFitPrey(pred, prey, digestionType)
    local predData = Ext.Entity.Get(pred)
    local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight) // GramsPerKilo

    local preyWeight = SP_CalculateWeightReduction(pred, prey, digestionType)

    if preyWeight > predRoom then
        _P("Can't fit " .. SP_GetDisplayNameFromGUID(prey) .. " inside of " .. SP_GetDisplayNameFromGUID(pred) ..
            "'s stomach!")
        return false
    else
        return true
    end
end

---returns what swallowed status should be appled to a prey on swallow
---@param pred CHARACTER
---@param prey CHARACTER
---@return string
function SP_GetPartialSwallowStatus(pred, prey)
    if Osi.HasPassive(pred, "SP_MuscleControl") == 1 and Osi.IsEnemy(pred, prey) == 0 then
        return "SP_PartiallySwallowedGentle"
    else
        return "SP_PartiallySwallowed"
    end
end



---returns what swallowed status should be appled to a prey
---@param pred CHARACTER
---@param prey CHARACTER
---@param digestionType integer
---@param locus string
---@return string
function SP_GetSwallowedVoreStatus(pred, prey, digestionType, locus)
    local correctlocus = locus == 'O' or SP_MCMGet("StatusBonusLocus") ~= 'Stomach'
    -- for k, v in pairs(SP_MCMGet("StatusBonusLocus")) do
    --     if string.sub(v, 1, 1) == locus then
    --         correctlocus = true
    --     end
    -- end

    --- !!! when adding status here's don't forget to add it to condition.khn !!!
    if correctlocus then
        if digestionType == DType.Endo then
            if Osi.HasPassive(prey, "SP_Gastronaut") == 1 or Osi.HasPassive(pred, "SP_MuscleControl") == 1 or Osi.HasPassive(pred, "SP_SC_StomachShelter") == 1 then
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

---@param pred CHARACTER
---@param prey CHARACTER
---@return string, string
function SP_GetSwallowSkill(pred, prey)
    local predStat = 'Athletics'
    local preyStat = 'Athletics'
    if Osi.HasSkill(pred, "Acrobatics") > Osi.HasSkill(pred, "Athletics") then
        predStat = "Acrobatics"
    end
    if Osi.HasSkill(prey, "Acrobatics") > Osi.HasSkill(prey, "Athletics") then
        preyStat = "Acrobatics"
    end
    if Osi.HasPassive(pred, "SP_SC_GreatHunger") == 1 and Osi.HasSkill(pred, "Intimidation") > Osi.HasSkill(pred, predStat) then
        predStat = "Intimidation"
    end
    return predStat, preyStat
end

---Teleports a prey to a pred. If prey is "ALL", teleports all prey to their respective preds.
---@param prey CHARACTER | string
function SP_TeleportToPred(prey)
    if prey == "ALL" then
        for k, v in pairs(VoreData) do
            
            -- _P(v.Pred)
            if v.Pred ~= "" then
                local predX, predY, predZ = Osi.GetPosition(v.Pred)
                Osi.TeleportToPosition(k, predX, predY, predZ, "", 0, 0, 0, 0, 1)
            end
        end
    -- .Pred is always a string
    elseif VoreData[prey] ~= nil and VoreData[prey].Pred ~= "" then
        local predX, predY, predZ = Osi.GetPosition(VoreData[prey].Pred)
        Osi.TeleportToPosition(prey, predX, predY, predZ, "", 0, 0, 0, 0, 1)
    end

end

---@param pred CHARACTER
---@param forRegurgitate? boolean set this to true if this function is used to get loci for regurgitation spells
function SP_GetPredLoci(pred, forRegurgitate)

    if forRegurgitate then
        return 'OAUC'
    end
    local loci = ''
    local skipA = false
    if Osi.HasPassive(pred, "SP_CanOralVore") == 1 then
        if forRegurgitate then
            loci = loci .. 'OA'
            skipA = true
        else
            loci = loci .. 'O'
        end
    end
    if not skipA and Osi.HasPassive(pred, "SP_CanAnalVore") == 1 then
        loci = loci .. 'A'
    end
    if Osi.HasPassive(pred, "SP_CanUnbirth") == 1 then
        loci = loci .. 'U'
    end
    if Osi.HasPassive(pred, "SP_CanCockVore") == 1 then
        loci = loci .. 'C'
    end
    _P("Pred Loci are: " .. loci)
    return loci
end

---plays a random gurgle
---@param pred GUIDSTRING
---@param preyLethal integer
---@param preyDigestion integer how many prey are dead and being digested
function SP_PlayGurgle(pred, preyLethal, preyDigestion)
    local basePercentage = SP_MCMGet("GurgleProbability")

    -- base percentage is increased based on the number of preys of certain types
    basePercentage = basePercentage * (1 + preyLethal + preyDigestion * 0.5)

    if basePercentage > 100 then
        basePercentage = 100
    elseif basePercentage == 0 or #GurgleSounds == 0 then
        return
    end
    -- convert the percentage
    basePercentage = 100 * #GurgleSounds // basePercentage
    local randomResult = Osi.Random(basePercentage) + 1
    if randomResult <= #GurgleSounds then
        Osi.PlaySound(pred, GurgleSounds[randomResult])
    end
end

---@param level integer
---@param num integer
---@return integer
function SP_LevelMapValue(level, num)
    local rollcount = 1
    if level >= 17 then
        rollcount = 4
    elseif level >= 10 then
        rollcount = 3
    elseif level >= 5 then
        rollcount = 2
    end
    local result = 0
    for i = 1, rollcount do
        result = result + Osi.Random(num) + 1
    end
    return result
end

---@param prey CHARACTER
function SP_Resurrect(prey)
    Osi.Resurrect(prey)
    Osi.RemoveStatus(prey, "SP_ReformationStatus")
    -- statuses from 5e spells
    Osi.RemoveStatus(prey, "DEAD_TECHNICAL")
    Osi.RemoveStatus(prey, "DEAD_ONE_MINUTE")
end

---@param pred CHARACTER
---@param force? boolean
function SP_AddPredSpells(pred, force)
    if not SP_IsPred(pred) or force then
        Osi.AddSpell(pred, "SP_Zone_RegurgitateContainer_OAUC", 0, 0)
        Osi.AddSpell(pred, "SP_Zone_Absorb_All", 0, 0)
        Osi.AddSpell(pred, 'SP_Zone_FlexBelly', 0, 0)
        Osi.AddSpell(pred, "SP_Zone_MovePrey", 0, 0)
        --Osi.AddSpell(pred, "SP_Zone_TalkToPrey")
    end
end

---@param pred CHARACTER
function SP_RemovePredSpells(pred)
    if not SP_IsPred(pred) then
        Osi.RemoveSpell(pred, "SP_Zone_RegurgitateContainer_OAUC", 1)
        Osi.RemoveSpell(pred, 'SP_Zone_Absorb_All', 1)
        Osi.RemoveSpell(pred, 'SP_Zone_SwallowDown', 1)
        Osi.RemoveSpell(pred, 'SP_Zone_FlexBelly', 1)
        Osi.RemoveSpell(pred, "SP_Zone_MovePrey", 1)
        --Osi.RemoveSpell(prey, "SP_Zone_TalkToPrey")
    end
end