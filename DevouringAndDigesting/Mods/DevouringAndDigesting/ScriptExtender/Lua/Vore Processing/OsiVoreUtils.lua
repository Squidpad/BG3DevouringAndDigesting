--- purely visual updating
---@param pred CHARACTER
---@param weight integer How many weight placeholders in inventory.
function SP_UpdateBelly(pred, weight)

    -- 160 (0.16) volume ~ 80 weight
    -- 30 is to account for some empty space inside the pred, which allows the pred to swallow light items without belly sticking out
    local volume = (weight * 160 / 80 - 30) * (ConfigVars.VisualsAndAudio.BellyScale.value / 100)

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
    -- bottomless stomach passive does not reduce the weight of items because of how it works
    local itemData = Ext.Entity.Get(item).Data.Weight
    if predRoom > itemData then
        return true
    else
        _P("Can't fit " .. item " inside " .. pred)
        return false
    end
end

---Checks if eating a character would exceed pred's carry limit.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_CanFitPrey(pred, prey)
    local predData = Ext.Entity.Get(pred)
    local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight) // GramsPerKilo
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

---plays a random gurgle
---@param pred GUIDSTRING
---@param preyLethal integer
---@param preyDigestion integer how many prey are dead and being digested
function SP_PlayGurgle(pred, preyLethal, preyDigestion)
    local basePercentage = ConfigVars.VisualsAndAudio.GurgleProbability.value

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

---@param character CHARACTER
function SP_AssignRoleRandom(character)
    if Osi.HasPassive(character, "SP_BlockGluttony") == 1 or Osi.HasPassive(character, "SP_Gluttony") == 1 then
        return
    end
    if Ext.Entity.Get(character).ServerCharacter.Temporary == true then
        Osi.AddPassive(character, "SP_BlockGluttony")
        return
    end
    if Osi.IsTagged(character, "ee978587-6c68-4186-9bfc-3b3cc719a835") == 1 then
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
        selectedPobability = ConfigVars.NPCVore.ProbabilityCreature.value * RaceConfigVars[race] // 100
    elseif Osi.GetBodyType(character, 0) == "Female" then
        selectedPobability = ConfigVars.NPCVore.ProbabilityFemale.value * RaceConfigVars[race] // 100
    elseif Osi.GetBodyType(character, 0) == "Male" then
        selectedPobability = ConfigVars.NPCVore.ProbabilityMale.value * RaceConfigVars[race] // 100
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
