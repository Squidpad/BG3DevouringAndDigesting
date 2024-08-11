---process pred each turn
---@param pred CHARACTER Recipient of status.
function SP_Digesting(pred)
    -- Randomly start digesting prey because of hunger
    local lethalRandomSwitch = false
    local gradualCount = 0
    local lethalCount = 0
    if VoreData[pred] == nil then
        return
    end
    -- hunger
    if SP_MCMGet("Hunger") then
        local hungerStacks = Osi.GetStatusTurns(pred, "SP_Hunger")
        if hungerStacks >= SP_MCMGet("HungerBreakpoint1") then
            if hungerStacks >= SP_MCMGet("HungerBreakpoint3") then
                lethalRandomSwitch = true
            elseif hungerStacks >= SP_MCMGet("HungerBreakpoint2") then
                if Osi.Random(10) == 1 then
                    lethalRandomSwitch = true
                end
            else
                if Osi.Random(50) == 1 then
                    lethalRandomSwitch = true
                end
            end
        end
    end
    -- iterate through prey
    for prey, locus in pairs(VoreData[pred].Prey) do
        if VoreData[prey].Digestion ~= DType.Dead and (SP_MCMGet("TeleportPrey") or VoreData[prey].Combat ~= "") then
            SP_TeleportToPred(prey)
        end
        if VoreData[prey].Digestion == DType.Dead and VoreData[prey].Weight > VoreData[prey].FixedWeight // 5 then
            gradualCount = gradualCount + 1
        elseif VoreData[prey].Digestion == DType.Lethal then
            lethalCount = lethalCount + 1
        end

    end
    if lethalRandomSwitch and SP_MCMGet("LethalRandomSwitch") then
        SP_SetLocusDigestion(pred, "All", true)
    end
    if Osi.HasActiveStatus(pred, "SP_LocusLethal_O") == 1 and VoreData[pred].Items ~= "" then
        SP_DigestItem(pred)
    end
    -- gradual digestion
    if SP_MCMGet("GradualDigestionAmount") > 0 and SP_MCMGet("GradualDigestionTurns") > 0 then
        VoreData[pred].GradualDigestionTimer = VoreData[pred].GradualDigestionTimer + 1
        if VoreData[pred].GradualDigestionTimer >= SP_MCMGet("GradualDigestionTurns") then
            VoreData[pred].GradualDigestionTimer = 0
            if gradualCount > 0 then
                _P("Gradual digestion for " .. pred)
                SP_FastDigestion(pred, VoreData[pred].Prey, SP_MCMGet("GradualDigestionAmount"))
            end
        end
    end
    SP_PlayGurgle(pred, lethalCount, gradualCount)
end

--- turns a character into a pred or a prey
---@param character CHARACTER
function SP_AssignRoleRandom(character)
    if Osi.HasPassive(character, "SP_NotPred") == 1 or Osi.HasPassive(character, "SP_IsPred") == 1 then
        return
    end
    if Ext.Entity.Get(character).ServerCharacter.Temporary == true then
        Osi.AddPassive(character, "SP_NotPred")
        return
    end
    if Osi.IsTagged(character, "ee978587-6c68-4186-9bfc-3b3cc719a835") == 1 then
        Osi.AddPassive(character, "SP_NotPred")
        return
    end
    local race = Osi.GetRace(character, 0)
    local selectedPobability = 0

    if not RaceConfigVars[race] then
        _P("Race not supported " .. race)
        selectedPobability = SP_MCMGet("ProbabilityFemale")
    elseif SINGLE_GENDER_CREATURE[race] == true then
        selectedPobability = SP_MCMGet("ProbabilityCreature") * RaceConfigVars[race] // 100
    elseif Osi.GetBodyType(character, 0) == "Female" then
        selectedPobability = SP_MCMGet("ProbabilityFemale") * RaceConfigVars[race] // 100
    else
        selectedPobability = SP_MCMGet("ProbabilityMale") * RaceConfigVars[race] // 100
    end

    local size = SP_GetCharacterSize(character)
    if size == 0 and selectedPobability > SP_MCMGet("ClampTiny") then
        selectedPobability = SP_MCMGet("ClampTiny")
    elseif size == 1 and selectedPobability > SP_MCMGet("ClampSmall") then
        selectedPobability = SP_MCMGet("ClampSmall")
    elseif size == 2 and selectedPobability > SP_MCMGet("ClampMedium") then
        selectedPobability = SP_MCMGet("ClampMedium")
    end
    if Osi.HasPassive(character, "SP_CanOralVore") == 1 or Osi.HasPassive(character, "SP_CanAnalVore") == 1 or
        Osi.HasPassive(character, "SP_CanUnbirth") == 1 or Osi.HasPassive(character, "SP_CanCockVore") == 1 then
        Osi.AddPassive(character, "SP_IsPred")
        return
    end
    if selectedPobability > 0 then
        local randomRoll = Osi.Random(100) + 1
        if randomRoll <= selectedPobability then
            _P("Adding PRED to " .. character)
            Osi.AddPassive(character, "SP_IsPred")
            Osi.AddPassive(character, "SP_CanOralVore")
            return
        end
    end
    _P("Adding PREY to " .. character)
    Osi.AddPassive(character, "SP_NotPred")
end

---process prey struggle each turn
---@param prey CHARACTER Recipient of status.
function SP_DoStruggle(prey)
    if VoreData[prey] ~= nil and VoreData[prey].Pred ~= "" then
        if Osi.HasActiveStatus(prey, "SP_StilledPrey") ~= 1 and Osi.HasActiveStatus(prey, "SP_StunnedPrey") ~= 1 and
            Osi.IsEnemy(prey, VoreData[prey].Pred) == 1 then

            local exLimit = SP_MCMGet("ExhaustionLimit")
            if exLimit > 0 then
                Osi.ApplyStatus(prey, "SP_StruggleExhaustion", 1 * SecondsPerTurn, 1, prey)
                if Osi.GetStatusTurns(prey, "SP_StruggleExhaustion") >= exLimit then
                    Osi.ApplyStatus(prey, "SP_StunnedPrey", 1 * SecondsPerTurn, 1, prey)
                end
            end
            SP_VoreCheck(VoreData[prey].Pred, prey, "StruggleCheck")
        end
        if VoreData[prey].Digestion == DType.Lethal then
            if Osi.HasActiveStatus(VoreData[prey].Pred, "SP_LeechingAcidStatus") == 1 then
                Osi.ApplyStatus(VoreData[prey].Pred, "SP_LeechingAcidHeal", 0, 1, VoreData[prey].Pred)
            end
        end
    end
end

---perform swallowing of a prey. Mostly used as a wrapper for swallow prey and continue swallowing
---@param pred CHARACTER
---@param prey CHARACTER|ITEM
---@param swallowType string|integer endo/lethal
---@param locus string O/A/U/C
---false will force pred to "continue swallowing" in the opposite direction, even if the prey is fully swallowed
---aka it can be used to start multi-step regurgitation
---@param swallowStages? boolean for initial swallow only
function SP_SwallowSuccess(pred, prey, swallowType, locus, swallowStages)
    if swallowType == "Endo" then
        swallowType = DType.Endo
    elseif swallowType == "Lethal" then
        swallowType = DType.Lethal
    end
    if type(swallowType) == "string" then
        swallowType = DType.None
    end
    -- for preys that are already inside of a pred
    if VoreData[prey] ~= nil and VoreData[prey].Pred == pred and VoreData[prey].SwallowProcess > 0 then
        VoreData[prey].SwallowProcess = VoreData[prey].SwallowProcess - 1
        if VoreData[prey].SwallowProcess == 0 then
            _P('Full swallow')
            SP_SwitchToDigestionType(pred, prey, VoreData[prey].Digestion)
        end

        local removeSwallowDownSpell = true
        for k, v in pairs(VoreData[pred].Prey) do
            if VoreData[k].SwallowProcess > 0 then
                removeSwallowDownSpell = false
            end
        end
        if removeSwallowDownSpell then
            Osi.RemoveSpell(pred, 'SP_Zone_SwallowDown')
        end
    elseif SP_VorePossible(pred, prey, swallowType) then
        -- being swallowed by a different predator
        if Osi.IsItem(prey) == 1 then
            SP_SwallowItem(pred, prey)
            SP_SetLocusDigestion(pred, "O", swallowType == DType.Lethal)
        elseif Osi.IsCharacter(prey) == 1 and (VoreData[prey] == nil or VoreData[prey].Pred ~= pred) then

            local cooldown = SP_MCMGet("CooldownMax") - SP_MCMGet("CooldownMin") + 1
            cooldown = Osi.Random(cooldown) + SP_MCMGet("CooldownMin")
            Osi.ApplyStatus(pred, "SP_AI_HELPER_BLOCKVORE", SecondsPerTurn * cooldown, 1, pred)

            SP_SwallowPrey(pred, prey, swallowType, swallowStages, locus)
        end
    end
end

---fail a swallow down check
---@param pred CHARACTER
---@param prey GUIDSTRING
---@param superFail boolean prey will be automatically fully regurgitated
function SP_SwallowFail(pred, prey, superFail)
    if VoreData[prey] ~= nil and VoreData[prey].Pred == pred then

        local maxSwallowProcess = math.max(SP_GetCharacterSize(prey) - SP_GetCharacterSize(pred) + 1, 1)
        -- if we begin multi-step regurgitation
        if VoreData[prey].SwallowProcess == 0 then
            local pswallow = SP_GetPartialSwallowStatus(pred, prey)
            Osi.ApplyStatus(prey, pswallow, (maxSwallowProcess + 1) * SecondsPerTurn, 1, pred)
        end
        VoreData[prey].SwallowProcess = VoreData[prey].SwallowProcess + 1

        if superFail then
            VoreData[prey].SwallowProcess = maxSwallowProcess + 1
        end
        -- if the prey managed to struggle out
        if VoreData[prey].SwallowProcess > maxSwallowProcess then
            SP_RegurgitatePrey(pred, prey, -1, "SwallowFail")
        end

        local removeSwallowDownSpell = true
        for k, v in pairs(VoreData[pred].Prey) do
            if VoreData[k].SwallowProcess > 0 then
                removeSwallowDownSpell = false
            end
        end
        if removeSwallowDownSpell then
            Osi.RemoveSpell(pred, 'SP_Zone_SwallowDown')
        end
    else
        if Osi.IsPlayer(pred) ~= 1 then
            local cooldown = SP_MCMGet("CooldownMax") - SP_MCMGet("CooldownMin") + 1
            cooldown = Osi.Random(cooldown) + SP_MCMGet("CooldownMin")
            Osi.ApplyStatus(pred, "SP_AI_HELPER_BLOCKVORE", SecondsPerTurn * cooldown, 1, pred)
        end
    end
end
