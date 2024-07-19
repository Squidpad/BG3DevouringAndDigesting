-- for calculating short rest
local calculateRest = true


---Triggers on spell cast.
---@param caster CHARACTER
---@param spell string
---@param spellType string
---@param spellElement string Like fire, lightning, etc I think.
---@param storyActionID integer
function SP_OnSpellCast(caster, spell, spellType, spellElement, storyActionID)
    --_P("SpellCast")
    local spellParams = SP_StringSplit(spell, "_")
    if spellParams[1] ~= 'SP' then
        return
    end
    local spellName = spellParams[3]

    if spellName == "SwitchToLethal" then
        local locus = spellParams[4]

        if Osi.HasActiveStatus(caster, "SP_LocusLethal_" .. locus) == 1 then
            SP_SetLocusDigestion(caster, locus, false)
        else
            SP_SetLocusDigestion(caster, locus, true)
        end
    -- a shitty way to do this, but idk how to add statuses in zone spells
    -- and shout is incompatible with detach
    elseif spellName == 'ResistAcid' then
        _P("Applying protection")
        Osi.ApplyStatus(caster, "PROTECTION_FROM_ENERGY_ACID", 2 * SecondsPerTurn, 1, caster)
    elseif VoreData[caster] ~= nil then

        if spellName == 'Regurgitate' then
            local locus = spellParams[4]
            if Osi.HasActiveStatus(caster, "SP_CooldownRegurgitate") ~= 0 and locus ~= "A" then
                return
            end
            local prey = table.concat({table.unpack(spellParams, 6, #spellParams)}, "_")
            if locus == "X" then
                locus = nil
            end
            SP_RegurgitatePrey(caster, prey, 10, '', locus)
        elseif spellName == 'Absorb' then
            local prey = spellParams[4]
            SP_RegurgitatePrey(caster, prey, 1, "Absorb")
        elseif spellName == 'SwallowDown' then
            for k, v in pairs(VoreData[caster].Prey) do
                if VoreData[k].SwallowProcess > 0 then
                    _P("Ally: " .. Osi.IsAlly(caster, k))
                    if Osi.IsAlly(caster, k) == 1 then
                        VoreData[k].SwallowProcess = VoreData[k].SwallowProcess - 1

                        if VoreData[k].SwallowProcess == 0 then
                            SP_FullySwallow(caster, k)
                        end
                    else
                        SP_VoreCheck(caster, k, "SwallowDownCheck")
                    end
                end
            end
            -- deal small amount of damage to prey
        elseif spellName == 'FlexBelly' then
            for k, v in pairs(VoreData[caster].Prey) do
                if VoreData[k].Digestion == DType.Lethal then
                    Osi.ApplyStatus(k, 'SP_FlexBelly_Status', 0, 1, caster)
                end
            end
            -- ask pred to release me
        elseif spellName == 'ReleaseMe' then
            if VoreData[caster].Pred ~= "" then
                --SP_RegurgitatePrey(VoreData[caster].Pred, caster, 0)
                SP_VoreCheck(VoreData[caster].Pred, caster, "ReleaseMeCheck")
            end
        elseif spell == 'SP_SC_BoundPrey_Spell' then
            for k, v in pairs(VoreData[caster].Prey) do
                if Osi.IsAlly(caster, k) == 1 and VoreData[k].Digestion == DType.Endo then
                    Osi.ApplyStatus(caster, "SP_SC_BoundPrey_Pred", -1, 1, k)
                    Osi.ApplyStatus(k, "SP_SC_BoundPrey_Prey", -1, 1, caster)

                    Osi.ApplyStatus(caster, "SP_SC_BlockVoreTotal", -1, 1, k)
                    return
                end
            end
        elseif spellName == "MoveToPred" then
            SP_TeleportToPred(caster)
        elseif spellName == 'DoLongRest' then
            if VoreData[caster].Pred ~= "" then
                _P("Attempting to start a long rest")
                Osi.RemoveStatus(caster, VoreData[caster].Swallowed)
                SP_DelayCallTicks(3, function ()
                    
                    Osi.RequestEndTheDay(caster)

                    SP_DelayCallTicks(180, function ()
                        Osi.ApplyStatus(caster, VoreData[caster].Swallowed, 100 * SecondsPerTurn, 1, VoreData[caster].Pred)
                    end)
                end)
            end
        end
    end
end


---Triggers when a spell is cast with a target.
---@param caster CHARACTER
---@param target CHARACTER
---@param spell string
---@param spellType string
---@param spellElement? string Like fire, lightning, etc I think.
---@param storyActionID? integer
function SP_OnSpellCastTarget(caster, target, spell, spellType, spellElement, storyActionID)
    --_P("SpellCastTarget")
    local spellParams = SP_StringSplit(spell, "_")
    if spellParams[1] ~= "SP" then
        return
    end
    local locus = spellParams[#spellParams]
    if DigestionStatuses[locus] == nil then
        locus = nil
    end
    local spellName = spellParams[3]
    -- main vore spell
    if spellName == 'Swallow' then
        local digestionType = spellParams[4]
        -- if pred can swallow prey
        if not SP_VorePossible(caster, target) then
            _P("Can't vore")
            return
        end
        -- ai vore cooldown
        local cooldown = SP_MCMGet("CooldownMax") - SP_MCMGet("CooldownMin") + 1
        cooldown = Osi.Random(cooldown) + SP_MCMGet("CooldownMin")
        Osi.ApplyStatus(caster, "SP_AI_HELPER_BLOCKVORE", SecondsPerTurn * cooldown, 1, caster)
        -- vore check end
        -- spell type check
        if digestionType == 'Endo' then
            -- why remove the delays here?
            -- they made it look better
            if Osi.IsItem(target) == 1 then
                -- Item Vore
                SP_DelayCallTicks(12, function ()
                    SP_SwallowItem(caster, target)
                    SP_SetLocusDigestion(caster, "O", false)
                end)
            else
                _P("Ally: " .. Osi.IsAlly(caster, target))
                if Osi.IsAlly(caster, target) == 1 then
                    SP_DelayCallTicks(12, function ()
                        SP_SwallowPrey(caster, target, DType.Endo, true, true, locus)
                    end)
                else
                    SP_DelayCallTicks(6, function ()
                        SP_VoreCheck(caster, target, "SwallowCheck_Endo_" .. locus)
                    end)
                end
            end
        elseif digestionType == 'Lethal' then
            if Osi.IsItem(target) == 1 then
                -- Item Vore
                SP_DelayCallTicks(12, function ()
                    SP_SwallowItem(caster, target)
                    SP_SetLocusDigestion(caster, "O", true)
                end)
            else
                _P("Ally: " .. Osi.IsAlly(caster, target))
                if Osi.IsAlly(caster, target) == 1 then
                    SP_DelayCallTicks(12, function ()
                        SP_SwallowPrey(caster, target, DType.Lethal, true, true, locus)
                    end)
                else
                    SP_DelayCallTicks(6, function ()
                        SP_VoreCheck(caster, target, "SwallowCheck_Lethal_" .. locus)
                    end)
                end
            end
        end
        -- other swallow-related spells
    elseif spellName == "BellyportDestination" or spellName == "PowerWordSwallowDestination" then
        local predData = Ext.Entity.Get(target)
        local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight) / 1000
        local preyTable = {}
        for prey, v in pairs(VoreData[caster].SpellTargets) do
            if v == "SP_HitBellyport" and spellName == "BellyportDestination"
                    or v == "SP_HitPowerWordSwallow" and spellName == "PowerWordSwallowDestination" then
                if Osi.IsCharacter(prey) == 1 then
                    -- this will teleport the exact amount of prey that fit inside pred
                    -- reverted this to working version pre-commit ed75ffb
                    if SP_VorePossible(target, prey) and (SP_GetTotalCharacterWeight(prey) <= predRoom or
                            SP_MCMGet("AllowOverstuffing")) then
                        predRoom = predRoom - SP_GetTotalCharacterWeight(prey)
                        table.insert(preyTable, prey)
                    end
                end
                Osi.RemoveStatus(prey, "SP_HitBellyport")
                Osi.RemoveStatus(prey, "SP_HitPowerWordSwallow")
                -- knock out prey for PW Swallow
                if v == "SP_HitPowerWordSwallow" then
                    Osi.ApplyStatus(prey, "SP_StunnedPrey", 1 * SecondsPerTurn, 1, target)
                end
                -- this allows teleporting prey out of another stomach correctly
                if VoreData[prey] ~= nil and VoreData[prey].Pred ~= "" then
                    SP_RegurgitatePrey(VoreData[prey].Pred, prey, -1, "Transfer")
                end
                VoreData[caster].SpellTargets[prey] = nil
            end
        end
        SP_DelayCallTicks(5, function ()
            if #preyTable > 0 then
                SP_SwallowPreyMultiple(target, preyTable, DType.Lethal, true, false, locus)
            end
            if spellName == "BellyportDestination" then
                Osi.RemoveSpell(caster, "SP_Target_BellyportDestination")
            elseif spellName == "PowerWordSwallowDestination" then
                Osi.RemoveSpell(caster, "SP_Target_PowerWordSwallowDestination")
            end
        end)
        -- swallow me spells
    elseif spellName == 'OfferMe' then
        -- prey should not target their preds
        if VoreData[caster] ~= nil and VoreData[caster].Pred == target then
            return
        end
        if not SP_VorePossible(target, caster) then
            return
        end
        if Osi.IsEnemy(caster, target) == 0 then
            SP_DelayCallTicks(12, function ()
                SP_SwallowPrey(target, caster, DType.Endo, true, false, locus)
            end)
        else
            SP_DelayCallTicks(12, function ()
                SP_SwallowPrey(target, caster, DType.Lethal, true, false, locus)
            end)
        end
        -- non swallow-related spells
    else
        if spellName == 'MassagePred' then
            if VoreData[target] ~= nil then
                Osi.RemoveStatus(target, 'SP_Indigestion')
                for k, v in pairs(VoreData[target].Prey) do
                    if VoreData[k].Digestion == DType.Lethal then
                        Osi.ApplyStatus(k, 'SP_MassageAcid', 0, 1, target)
                    end
                end
            end
        elseif spellName == 'AssignNPCPred' then
            _P(target)
            if Ext.Entity.Get(target).ServerCharacter.Temporary == false then
                if Osi.HasPassive(target, "SP_NotPred") == 1 then
                    _P("Was prey")
                    Osi.RemovePassive(target, "SP_NotPred")
                    if Osi.HasPassive(target, "SP_IsPred") == 0 then
                        Osi.AddPassive(target, "SP_IsPred")
                        if Osi.HasPassive(target, "SP_CanOralVore") == 0 then
                            Osi.AddPassive(target, "SP_CanOralVore")
                        end
                    end
                end
            end
        elseif spellName == 'AssignNPCPrey' then
            _P(target)
            if Osi.HasPassive(target, "SP_IsPred") == 1 then
                _P("Was predator")
                Osi.RemovePassive(target, "SP_CanOralVore")
                Osi.RemovePassive(target, "SP_CanAnalVore")
                Osi.RemovePassive(target, "SP_CanUnbirth")
                Osi.RemovePassive(target, "SP_CanCockVore")
                Osi.RemovePassive(target, "SP_IsPred")
            end
            if Osi.HasPassive(target, "SP_NotPred") == 0 then
                Osi.AddPassive(target, "SP_NotPred")
            end
        elseif spellName == 'Acidify' then
            local powerLevel = spellParams[4]
            if VoreData[caster] ~= nil then
                for k, v in pairs(VoreData[caster].Prey) do
                    if VoreData[k].Digestion == DType.Lethal then
                        Osi.ApplyStatus(k, 'SP_AcidifyStatus_' ..powerLevel , 0, 1, caster)
                    end
                end
            end
        elseif spellName == 'Churn' then
            if VoreData[caster] ~= nil then
                local fullDigestThese = {}
                for k, v in pairs(VoreData[caster].Prey) do
                    if VoreData[k].Digestion == DType.Lethal then
                        Osi.ApplyStatus(k, 'SP_ChurnStatus' , 0, 1, caster)
                    elseif VoreData[k].Digestion == DType.Dead then
                        fullDigestThese[k] = v
                    end
                end
                if next(fullDigestThese) ~= nil then
                    SP_FastDigestion(caster, fullDigestThese, 0)
                end
            end
        elseif spellName == 'Rescue' then
            SP_DelayCall (12, function ()
                if VoreData[target] ~= nil then
                    for k, v in pairs(VoreData[target].Prey) do
                        if Osi.IsEnemy(caster, k) ~= 1 then
                            SP_RegurgitatePrey(target, k, -1, "Transfer")
                            if VoreData[k].Digestion == DType.Dead then
                                SP_SwallowPrey(caster, k, DType.Dead, false, false, locus)
                            else
                                SP_SwallowPrey(caster, k, DType.Endo, false, false, locus)
                            end
                            return
                        end
                    end
                end
            end)
        elseif spellName == 'Rebirth' then
            SP_DelayCall (12, function ()
                Osi.ApplyStatus(target, "SP_ReformationStatus", 1 * SecondsPerTurn, 1, caster)
                SP_SwallowPrey(caster, target, DType.Dead, true, false, locus)
                VoreData[target].Weight = VoreData[target].FixedWeight // 5 + 1
                _D(VoreData)
            end)
        end
    end
end

---Triggers whenever there's a skill check.
---@param eventName string Name of event passed from the func that called the roll.
---@param roller CHARACTER Roller.
---@param rollSubject CHARACTER Character they rolled against.
---@param resultType integer Result of roll. 0 == fail, 1 == success.
---@param isActiveRoll? integer Whether or not the rolling GUI popped up. 0 == no, 1 == yes.
---@param criticality? CRITICALITYTYPE Whether or not it was a crit and what kind. 0 == no crit, 1 == crit success, 2 == crit fail.
function SP_OnRollResults(eventName, roller, rollSubject, resultType, isActiveRoll, criticality)
    --_P("Roll")
    local eventArgs = SP_StringSplit(eventName, '_')
    if eventArgs[1] == 'SwallowCheck' then
        local voreLocus = eventArgs[3]
        if eventArgs[2] == 'Lethal' and (resultType ~= 0 or SP_MCMGet("AlwaysSucceedVore")) then
            _P('Lethal Swallow Success by ' .. roller)         
            SP_SwallowPrey(roller, rollSubject, DType.Lethal, true, true, voreLocus)

        elseif eventArgs[2] == 'Endo' and (resultType ~= 0 or SP_MCMGet("AlwaysSucceedVore")) then
            _P('Endo Swallow Success by ' .. roller)
            SP_SwallowPrey(roller, rollSubject, DType.Endo, true, true, voreLocus)
        end
    elseif eventArgs[1] == "StruggleCheck" and resultType ~= 0 then
        _P('Struggle Success by ' .. roller .. ' against ' .. rollSubject)
        _P("rollresult: " .. tostring(resultType))
        
        if Osi.HasPassive(rollSubject, "SP_SC_EldritchPrison") == 0 and SP_MCMGet("IndigestionLimit") ~= 0 then
            Osi.ApplyStatus(rollSubject, "SP_Indigestion", 1 * SecondsPerTurn)
        
            if Osi.GetStatusTurns(rollSubject, "SP_Indigestion") >= SP_MCMGet("IndigestionLimit") then
                Osi.RemoveStatus(rollSubject, "SP_Indigestion")
                -- evey prey will be regurgitated
                SP_RegurgitatePrey(rollSubject, "All", 0, "", VoreData[roller].Locus)
                -- preds will not try to vore anyone after forced regurgitation
                Osi.ApplyStatus(rollSubject, "SP_AI_HELPER_BLOCKVORE", SecondsPerTurn * 10, 1, rollSubject)
            end
        end
        if Osi.HasPassive(roller, 'SP_Dense') == 1 then
            Osi.ApplyStatus(rollSubject, "PRONE", 1 * SecondsPerTurn, 1, roller)
        end

    elseif eventArgs[1] == "SwallowDownCheck" then
        _P("event: " .. eventName)
        _P("rollresult: " .. tostring(resultType))
        if resultType ~= 0 then
            VoreData[rollSubject].SwallowProcess = VoreData[rollSubject].SwallowProcess - 1
            if VoreData[rollSubject].SwallowProcess == 0 then
                SP_FullySwallow(roller, rollSubject)
            end
        else
            local removeSD = true
            VoreData[rollSubject].SwallowProcess = 0
            for k, v in pairs(VoreData[roller].Prey) do
                if VoreData[k].SwallowProcess > 0 then
                    removeSD = false
                end
            end
            if removeSD then
                Osi.RemoveSpell(roller, 'SP_Zone_SwallowDown')
            end
            SP_RegurgitatePrey(roller, rollSubject, -1, "SwallowFail")
        end
    elseif eventArgs[1] == "ReleaseMeCheck" then
        _P("event: " .. eventName)
        _P("rollresult: " .. tostring(resultType))
        if resultType == 1 and VoreData[roller] ~= nil and VoreData[rollSubject] ~= nil then
            -- add animation here
            SP_RegurgitatePrey(rollSubject, roller, 0, "", VoreData[roller].Locus)
        end
    end
end

---Runs each time a status is applied.
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee GUIDSTRING Thing that caused status to be applied.
---@param storyActionID? integer
function SP_OnStatusApplied(object, status, causee, storyActionID)
    -- release all prey when knocked out
    if status == "KNOCKED_OUT" then
        if VoreData[object] ~= nil and next(VoreData[object].Prey) ~= nil then
            SP_RegurgitatePrey(object, "All", 10)
        end
    end

    if string.sub(status, 1, 2) ~= "SP" then
        return
    end
    local statusArgs = SP_StringSplit(status, '_')
    
    if statusArgs[1] ~= 'SP' then
        return
    end
    if statusArgs[2] == 'Digesting' then
        local pred = object
        --Randomly start digesting prey because of hunger
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
        --if not SP_HasLivingPrey(pred, true) then
        --    Osi.RemoveStatus(pred, "SP_Indigestion")
        --end
        SP_PlayGurgle(pred, lethalCount, gradualCount)

    --add random role to characters around host
    elseif statusArgs[2] == "ROLESELECTOR" and statusArgs[3] == 'AURA' then
        SP_AssignRoleRandom(object)
    elseif statusArgs[2] == 'Struggle' then
        local prey = object
        if VoreData[prey] == nil or VoreData[prey].Pred == "" or Osi.HasActiveStatus(prey, "SP_StilledPrey") == 1 or
                Osi.HasActiveStatus(prey, "SP_StunnedPrey") == 1 then
            return
        end
        if Osi.IsEnemy(prey, VoreData[prey].Pred) == 1 then
            local exLimit = SP_MCMGet("ExhaustionLimit")
            if exLimit > 0 then
                Osi.ApplyStatus(prey, "SP_StruggleExhaustion", 1 * SecondsPerTurn, 1, prey)
                if Osi.GetStatusTurns(prey, "SP_StruggleExhaustion") > exLimit then
                    Osi.ApplyStatus(prey, "SP_StunnedPrey", 1 * SecondsPerTurn, 1, prey)
                end
            end
            SP_VoreCheck(VoreData[prey].Pred, prey, "StruggleCheck")
        end
        if VoreData[prey].Digestion == DType.Lethal then
            if Osi.HasPassive(VoreData[prey].Pred, 'SP_BoilingInsides') == 1 then
                Osi.ApplyStatus(prey, "SP_BoilingInsidesAcid", 0, 1, VoreData[prey].Pred)
            end
            if Osi.HasActiveStatus(VoreData[prey].Pred, "SP_LeechingAcidStatus") == 1 then
                Osi.ApplyStatus(VoreData[prey].Pred, "SP_LeechingAcidHeal", 0, 1, VoreData[prey].Pred)
            end
        end

    elseif statusArgs[2] == "HitBellyport" then
        local prey = object
        local pred = SP_CharacterFromGUID(causee)
        SP_VoreDataEntry(pred, true)
        VoreData[pred].SpellTargets[prey] = status
        Osi.AddSpell(pred, "SP_Target_BellyportDestination")

    elseif statusArgs[2] == "HitPowerWordSwallow" then
        local prey = object
        local pred = SP_CharacterFromGUID(causee)
        SP_VoreDataEntry(pred, true)
        VoreData[pred].SpellTargets[prey] = status
        Osi.AddSpell(pred, "SP_Target_PowerWordSwallowDestination")

    -- all statuses that change the weight / visual weight
    elseif statusArgs[2] == 'BellyCompressed' or statusArgs[2] == 'Unburdened' or statusArgs[2] == 'Bottomless' then
        local pred = object
        if VoreData[pred] ~= nil then
            SP_UpdateWeight(pred)
        end
    elseif statusArgs[2] == 'HealingAcid' and statusArgs[3] == 'Tick' then
        _P("Healing Acid Tick")
        local spellLocus = statusArgs[4]
        local pred = object
        if VoreData[pred] ~= nil then
            for prey, preyLocus in pairs(VoreData[pred].Prey) do
                if preyLocus == spellLocus then
                    Osi.ApplyStatus(prey, "SP_HealingAcid_RegainHP", 1, 1, pred)
                end
            end
            if Osi.HasActiveStatus(pred, "SP_LocusLethal_" .. spellLocus) == 1 then
                SP_SetLocusDigestion(object, spellLocus, false, true)
            end
        end
    elseif statusArgs[2] == 'TongueStatus' then
        _P("Tongue success")
        SP_DelayCall(30, function ()
            
            local pred = SP_CharacterFromGUID(causee)
            local locus = "O"
            if Osi.IsEnemy(object, pred) == 1 then
                SP_VoreCheck(pred, object, "SwallowCheck_Lethal_" .. locus)
            else
                SP_SwallowPrey(pred, object, DType.Endo, true, true, locus)
            end
        end)
    elseif statusArgs[2] == 'HeaveStatus' then
        _P("Heave success")
        local pred = object
        if VoreData[pred] ~= nil then
            if next(VoreData[pred].Prey) ~= nil then
                SP_RegurgitatePrey(pred, "All", 0)
                return
            end
        end
        Osi.ApplyStatus(pred, "POISONED", 1 * SecondsPerTurn)
    elseif statusArgs[2] == 'HasStilledPrey' then
        _P("Stilled prey success")
        local pred = object
        if VoreData[pred] ~= nil and next(VoreData[pred].Prey) ~= nil then
            local doEndo = true
            -- lethal swallowed prey will take priority if Single-prey version of the spell is used 
            if statusArgs[2] == "Single" then
                doEndo = #SP_FilterPrey(pred, "All", false, DType.Lethal) <= 0
            end
            for prey, _ in pairs(VoreData[pred].Prey) do
                if VoreData[prey].Digestion ~= DType.Dead and (VoreData[prey].Digestion ~= DType.Endo or doEndo) then
                    if Osi.HasActiveStatus(prey, "SP_StilledPrey") == 0 then
                        
                        Osi.ApplyStatus(prey, "SP_StilledPrey", 1 * SecondsPerTurn)
                        if statusArgs[2] == "Single" then
                            return
                        end
                    end
                end
            end
        end
    elseif statusArgs[3] == "StomachShelterTick" then
        local pred = object
        local shelterTurns = Osi.GetStatusTurns(pred, "SP_SC_StomachShelterStuffed")
        local sanctuaryTurns = Osi.GetStatusTurns(pred, "SP_SC_StomachSanctuaryStuffed")
        Osi.ApplyStatus(pred, "SP_SC_StomachShelterStuffed_TempHP", (shelterTurns + sanctuaryTurns * 2) * SecondsPerTurn, 1, pred)
    -- release all prey when knocked out
    elseif statusArgs[3] == "StilledPrey" or statusArgs[3] == "StunnedPrey" then
        if VoreData[object] ~= nil and next(VoreData[object].Prey) ~= nil then
            SP_RegurgitatePrey(object, "All", 10)
        end

    -- damaging statuses
    elseif statusArgs[2] == "BellySlamStatus" then
        local pred = SP_CharacterFromGUID(causee)
        if VoreData[pred] ~= nil and VoreData[pred].StuffedStacks > 0 then
            local damage = 0
            local predLevel = Osi.GetLevel(pred) or 1
            for _ = 1, VoreData[pred].StuffedStacks do
                damage = damage + SP_LevelMapValue(predLevel, 8)
            end
            Osi.ApplyDamage(object, damage, "Bludgeoning", pred)
        end
    elseif statusArgs[2] == "BurpSuccess" then
        local pred = SP_CharacterFromGUID(causee)
        if VoreData[pred] ~= nil and VoreData[pred].StuffedStacks > 0 then
            local damage = 0
            local predLevel = Osi.GetLevel(pred) or 1
            for _ = 1, VoreData[pred].StuffedStacks do
                damage = damage + SP_LevelMapValue(predLevel, 6)
            end
            Osi.ApplyDamage(object, damage, "Thunder", pred)
        end
    elseif statusArgs[2] == "MegaBurpSuccess" or statusArgs[2] == "MegaBurpFail" then
        local pred = SP_CharacterFromGUID(causee)
        if VoreData[pred] ~= nil and VoreData[pred].StuffedStacks > 0 then
            -- 4d6 Thunder 4d6 Bludgeoning
            local damage1 = 0
            local damage2 = 0
            for _ = 1, VoreData[pred].StuffedStacks * 4 do
                damage1 = damage1 + Osi.Random(6) + 1
                damage2 = damage2 + Osi.Random(6) + 1
            end
            if statusArgs[2] == "MegaBurpFail" then
                damage1 = damage1 // 2
                damage2 = damage2 // 2
            end
            Osi.ApplyDamage(object, damage1, "Thunder", pred)
            Osi.ApplyDamage(object, damage2, "Bludgeoning", pred)
        end
    end
end

---triggers on item use
---@param character CHARACTER
---@param item ITEM
---@param success integer
function SP_OnItemUsed(character, item, success)
    --_P("ItemUsed")
    local itemParams = SP_StringSplit(item, '_')
    if itemParams[1] == 'SP' then
        local template = Osi.GetTemplate(item)
        -- check if a character lost a locus, to see if they are still a pred
        local changedLoci = 0
        _P(template)
        -- item name + map key
        if template == 'SP_PotionOfOralVore_1219e0c2-e893-4de0-8a92-6212d1348223' then
            if Osi.HasPassive(character, "SP_CanOralVore") == 0 then
                Osi.AddPassive(character, "SP_CanOralVore")
                changedLoci = 1
            else
                Osi.RemovePassive(character, "SP_CanOralVore")
                changedLoci = -1
            end
        elseif template == 'SP_PotionOfAnalVore_04987160-cb88-4d3e-b219-1843e5253d51' then
            if Osi.HasPassive(character, "SP_CanAnalVore") == 0 then
                Osi.AddPassive(character, "SP_CanAnalVore")
                changedLoci = 1
            else
                Osi.RemovePassive(character, "SP_CanAnalVore")
                changedLoci = -1
            end
        elseif template == 'SP_PotionOfUnbirth_92067c3c-547e-4451-9377-632391702de9' then
            if Osi.HasPassive(character, "SP_CanUnbirth") == 0 and (Osi.IsTagged(character, 'a0738fdf-ca0c-446f-a11d-6211ecac3291') == 1 or not
                    SP_MCMGet("RequireProperAnatomy") or Osi.GetBodyType(character, 1) == "Female") then
                Osi.AddPassive(character, "SP_CanUnbirth")
                changedLoci = 1
            elseif Osi.HasPassive(character, "SP_CanUnbirth") == 1 then
                Osi.RemovePassive(character, "SP_CanUnbirth")
                changedLoci = -1
            end
        elseif template == 'SP_PotionOfCockVore_04cbdeb4-a98e-44cd-b032-972df0ba3ca1' then
            if Osi.HasPassive(character, "SP_CanCockVore") == 0 and (Osi.IsTagged(character, 'd27831df-2891-42e4-b615-ae555404918b') == 1 or not
                    SP_MCMGet("RequireProperAnatomy")) then
                Osi.AddPassive(character, "SP_CanCockVore")
                changedLoci = 1
            elseif Osi.HasPassive(character, "SP_CanCockVore") == 1 then
                Osi.RemovePassive(character, "SP_CanCockVore")
                changedLoci = -1
            end
        elseif template == 'SP_PotionOfInedibility_319379c2-3627-4c26-b14d-3ce8abb676c3' then
            if Osi.HasPassive(character, "SP_Inedible") == 0 then
                Osi.AddPassive(character, "SP_Inedible")
            else
                Osi.RemovePassive(character, "SP_Inedible")
            end
        elseif template == 'SP_PotionOfDebugSpells_69d2df14-6d8a-4f94-92b5-cc48bc60f132' then
            if Osi.HasPassive(character, "SP_HasDebugSpells") == 0 then
                Osi.AddPassive(character, "SP_HasDebugSpells")
            else
                Osi.RemovePassive(character, "SP_HasDebugSpells")
            end
        elseif template == 'SP_PotionOfAssign_b8d700d0-681f-4c38-b444-fe69b361d9b3' then
            if Osi.HasPassive(character, "SP_Assigner") == 0 then
                Osi.AddPassive(character, "SP_Assigner")
            else
                Osi.RemovePassive(character, "SP_Assigner")
            end
        elseif template == 'SP_PotionOfPrey_02ee5321-7bcd-4712-ba06-89eb1850c2e4' then
            if Osi.HasPassive(character, "SP_IsPrey") == 0 then
                Osi.AddPassive(character, "SP_IsPrey")
            else
                Osi.RemovePassive(character, "SP_IsPrey")
            end
        end
        -- if no loci left, remove pred status
        SP_DelayCallTicks(2, function ()
            if changedLoci < 0 and SP_GetPredLoci(character) == "" then
                
                Osi.RemovePassive(character, "SP_IsPred")
                Osi.AddPassive(character, "SP_NotPred")
            elseif changedLoci > 0 and Osi.HasPassive(character, "SP_IsPred") == 0 then
                Osi.RemovePassive(character, "SP_NotPred")
                Osi.AddPassive(character, "SP_IsPred")
            end
        end)
    end
end

---@param character CHARACTER
function SP_OnLevelUp(character)
    if SP_MCMGet("FeatsAddLoci") then
        SP_DelayCallTicks(10, function ()
            local addedLoci = 0
            if Osi.HasPassive(character, 'SP_Cavernous') == 1 then
                if Osi.HasPassive(character, "SP_CanAnalVore") == 0 then
                    Osi.AddPassive(character, "SP_CanAnalVore")
                    addedLoci = 1
                end
            elseif Osi.HasPassive(character, 'SP_BoilingInsides') == 1 then
                if Osi.HasPassive(character, "SP_CanCockVore") == 0 and (Osi.IsTagged(character, 'd27831df-2891-42e4-b615-ae555404918b') == 1 or not
                        SP_MCMGet("RequireProperAnatomy")) then
                    Osi.AddPassive(character, "SP_CanCockVore")
                    addedLoci = 1
                end
            elseif Osi.HasPassive(character, 'SP_SoothingStomach') == 1 then
                if Osi.HasPassive(character, "SP_CanUnbirth") == 0 and (Osi.IsTagged(character, 'a0738fdf-ca0c-446f-a11d-6211ecac3291') == 1 or not
                        SP_MCMGet("RequireProperAnatomy") or Osi.GetBodyType(character, 1) == "Female") then
                    Osi.AddPassive(character, "SP_CanUnbirth")
                    addedLoci = 1
                end
            end
            if addedLoci > 0 and Osi.HasPassive(character, "SP_IsPred") == 0 then
                Osi.RemovePassive(character, "SP_NotPred")
                Osi.AddPassive(character, "SP_IsPred")
            end
        end)
    end
end

---@param character CHARACTER
---@param race string
---@param gender string
---@param shapeshiftStatus string
function SP_OnTransform(character, race, gender, shapeshiftStatus)
    _P("Transformed: " .. character)
    if VoreData[character] ~= nil then
        if next(VoreData[character].Prey) ~= nil or VoreData[character].AddWeight > 0 or VoreData[character].Fat > 0 or
            VoreData[character].Items ~= "" then
            SP_UpdateWeight(character)
        end
    end
end

---Runs each time a status is removed.
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee? GUIDSTRING Thing that caused status to be applied.
---@param storyActionID? integer
function SP_OnStatusRemoved(object, status, causee, storyActionID)
    --_P("StatusRemoved")
    -- regurgitates prey it they are not fully swallowed
    if string.sub(status, 1, 2) ~= "SP" then
        return
    end
    local statusArgs = SP_StringSplit(status, '_')
    
    if statusArgs[1] ~= 'SP' then
        return
    end
    if statusArgs[2] == 'PartiallySwallowed' or statusArgs[2] == 'PartiallySwallowedGentle' then
        if VoreData[object] ~= nil then
            if VoreData[object].Pred ~= "" and VoreData[object].SwallowProcess > 0 then
                local pred = VoreData[object].Pred
                local removeSD = true
                VoreData[object].SwallowProcess = 0
                for k, v in pairs(VoreData[pred].Prey) do
                    if VoreData[k].SwallowProcess > 0 then
                        removeSD = false
                    end
                end
                if removeSD then
                    Osi.RemoveSpell(pred, 'SP_Zone_SwallowDown')
                end
                SP_RegurgitatePrey(pred, object, -1, "SwallowFail")
            end
        end
    elseif statusArgs[2] == 'BellyCompressed' or statusArgs[2] == 'Unburdened' or statusArgs[2] == 'Bottomless' then
        local pred = object
        if VoreData[pred] ~= nil then
            SP_UpdateWeight(pred)
        end
    elseif statusArgs[2] == 'HasStilledPrey' then
        local pred = object
        -- the delay is necessary in case 
        SP_DelayCallTicks(3, function ()
            if Osi.HasActiveStatus(pred, "SP_HasStilledPrey_Single") == 0 and
                Osi.HasActiveStatus(pred, "SP_HasStilledPrey_All") == 0 then
                
                if VoreData[pred] ~= nil then
                    for prey, _ in pairs(VoreData[pred].Prey) do
                        Osi.RemoveStatus(prey, "SP_StilledPrey")
                    end
                end
            end
        end)
    end
end

---Runs when character enters combat
---@param object GUIDSTRING
---@param combatGuid GUIDSTRING
function SP_OnCombatEnter(object, combatGuid)
    if VoreData[object] ~= nil then
        VoreData[object].Combat = combatGuid
        if next(VoreData[object].Prey) ~= nil then
            for prey, _ in pairs(VoreData[object].Prey) do
                if VoreData[prey].Digestion ~= DType.Dead then
                    
                    SP_TeleportToPred(prey)
                    SP_DelayCallTicks(10, function ()
                        _P("Adding prey " .. prey .. " to combat")
                        VoreData[prey].Combat = combatGuid
                        Osi.EnterCombat(prey, object)
                    end)
                end
            end
        end
    end
end

---Runs when character leaves combat
---@param object GUIDSTRING
---@param combatGuid GUIDSTRING
function SP_OnCombatLeave(object, combatGuid)
    --_P("CombatLeave")
    if VoreData[object] ~= nil then
        _P("Removing " .. object .. " from combat")
        VoreData[object].Combat = ""
    end
end

---@param character CHARACTER
function SP_OnTurnStarted(character)
    -- _P(character .. "'s turn started")
    -- replaced all with character to improve performance
    if VoreData[character] ~= nil and VoreData[character].Pred ~= "" and
        VoreData[character].Digestion ~= DType.Dead then

        SP_TeleportToPred(character)
    end
end

---Runs when someone dies.
---@param character CHARACTER
function SP_OnBeforeDeath(character)
    --_P("BeforeDeath")
    if VoreData[character] == nil then
        return
    end
    -- If character was pred.
    VoreData[character].Fat = 0
    VoreData[character].Satiation = 0
    if next(VoreData[character].Prey) ~= nil or VoreData[character].Items ~= "" then
        _P(character .. " was pred and DIED")
        SP_RegurgitatePrey(character, 'All', -1)
    end

    -- If character was prey (both can be true at the same time)
    if VoreData[character] ~= nil and VoreData[character].Pred ~= "" then
        local pred = VoreData[character].Pred

        _P(character .. " was digested by " .. pred .. " and DIED")

        -- Warlock slot recovery
        if Osi.HasPassive(pred, "SP_SC_GreatHunger") == 1 and Osi.HasActiveStatus(pred, "SP_SC_GreatHunger_RestoreSlot") == 0 then
            Osi.ApplyStatus(pred, "SP_SC_GreatHunger_RestoreSlot", 1 * SecondsPerTurn, 1, pred)
        end
        -- Warlock bound prey remove
        if Osi.HasActiveStatus(character, "SP_SC_BoundPrey_Prey") == 1 then
            Osi.RemoveStatus(pred, "SP_SC_BlockVoreTotal")
            Osi.RemoveStatus(pred, "SP_SC_BoundPrey_Pred")
        end

        -- Temp characters' corpses are not saved is save file, so they might cause issues unless disposed of on death.
        if Ext.Entity.Get(character).ServerCharacter.Temporary == true then
            _P("Absorbing temp character")
            SP_DelayCallTicks(15, function ()
                SP_RegurgitatePrey(pred, character, -1, "Absorb", VoreData[character].Locus)
            end)
        else
            --the first line is necessary to properly switch to a locus
            VoreData[character].Digestion = DType.Dead
            if VoreData[character].Locus == 'O' then
                SP_SwitchToLocus(pred, character, 'A')
            end
            SP_SwitchToDigestionType(pred, character, DType.Dead, DType.Dead)
            -- Digested but not released prey will be stored out of bounds.
            -- investigate if teleporting char out of bounds and reloading breaks them
            Osi.TeleportToPosition(character, -100000, 0, -100000, "", 0, 0, 0, 1, 0)
            -- Implementation for fast digestion.
            if SP_MCMGet("InstantDigestion") == true then
                local preyToDigest = {}
                preyToDigest[character] = VoreData[character].Locus
                SP_FastDigestion(pred, preyToDigest, 0)
            end
        end
        -- it's not applied to dead characters by default
        -- Osi.RemoveStatus(pred, "SP_Indigestion")
    end
end

---Runs whenever item is added.
---@param objectTemplate ROOT
---@param object GUIDSTRING
---@param inventoryHolder GUIDSTRING
---@param addType string
function SP_OnItemAdded(objectTemplate, object, inventoryHolder, addType)
    --_P("ItemAdded")
    -- weight
    if objectTemplate == 'SP_Prey_Weight_f80c2fd2-5222-44aa-a68e-b2faa808171b' then
        Osi.ApplyStatus(object, 'SP_Item_Bound', -1)
        -- weight fixer
    elseif objectTemplate == 'SP_Prey_Weight_Fixer_8d3b74d4-0fe6-465f-9e96-36b416f4ea6f' then
        Osi.TemplateRemoveFrom('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', inventoryHolder, 9999)
        -- item stomach
    elseif objectTemplate == 'SP_Item_Stomach_eb1d0750-903e-44a9-927e-85200b9ecc5e' then
        Osi.ApplyStatus(object, 'SP_Item_Bound', -1)
        -- locks stomach with a random key that does not exist
        if SP_MCMGet("LockStomach") then
            Osi.Lock(object, 'amogus')
        end
    end
end

---Fires once per short rest.
---@param character CHARACTER
function SP_OnShortRest(character)
    -- This is necessary to avoid multiple calls of this function (for each party member).
    if calculateRest == false then
        return
    end
    calculateRest = false
    _P('SP_OnShortRest')
    SP_SlowDigestion(SP_MCMGet("DigestionRateShort"), SP_MCMGet("WeightLossShort"))

    --Osi.IteratePlayerCharacters("HungerCalculateShort", "")
    SP_HungerSystem(SP_MCMGet("HungerShort"), false)

    for k, v in pairs(VoreData) do
        if Osi.HasActiveStatus(k, "SP_SC_GreatHunger_RestoreSlot") == 1 then
            Osi.RemoveStatus(k, "SP_SC_GreatHunger_RestoreSlot")
        end
    end

    _D(VoreData)
    SP_DelayCallTicks(5, function ()
        calculateRest = true
    end)
end

---Fires once after long rest.
function SP_OnLongRest()
    --_P('SP_OnLongRest')
    SP_SlowDigestion(SP_MCMGet("DigestionRateLong"), SP_MCMGet("WeightLossLong"))

    SP_HungerSystem(SP_MCMGet("HungerLong"), true)

    SP_DelayCallTicks(15, function ()
        for k, v in pairs(VoreData) do
            -- makes npcs release their prey if they are digested or endoed (with a random chance)
            if next(v.Prey) ~= nil then
                SP_SetLocusDigestion(k, "All", false, true)
                if Osi.IsPlayer(k) == 0 then
                    if Osi.Random(2) == 1 then
                        SP_RegurgitatePrey(k, "All", 10, "Rest")
                    else
                        SP_RegurgitatePrey(k, "All", 1, "Rest")
                    end
                end
            end
        end
    end)
    _D(VoreData)
end



function SP_OnLevelLoaded(level)
    --_P("LevelLoaded")
    SP_CheckVoreData()
    Osi.ApplyStatus(Osi.GetHostCharacter(), "SP_ROLESELECTOR", -1)
end



---Runs whenever you change game regions.
---@param level? string Name of new game region.
function SP_OnBeforeLevelUnloaded(level)
    _P('LEVEL CHANGE')
    if type(level) == "string" then
        _D(level)
        _P('Level changed to ' .. level)
    end

    for k, v in pairs(VoreData) do
        if next(v.Prey) ~= nil or v.Items ~= "" then
            -- party members should not regurgitate items
            if Osi.IsPartyMember(k, 1) == 1 then
                SP_RegurgitatePrey(k, "All", -1, "LevelChangeParty")
            else
                SP_RegurgitatePrey(k, "All", -1, "LevelChange")
            end
        end
    end
    for k, v in pairs(VoreData) do
        VoreData[k].Prey = {}
        VoreData[k].Pred = ""
        SP_VoreDataEntry(k, false)
        if Osi.IsPartyMember(k, 1) == 0 then
            VoreData[k] = nil
        end
    end
end


Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_OnSpellCastTarget)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_OnSpellCast)
Ext.Osiris.RegisterListener("LeveledUp", 1, "after", SP_OnLevelUp)
Ext.Osiris.RegisterListener("ShapeshiftChanged", 4, "after", SP_OnTransform)

Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", SP_OnCombatEnter)
Ext.Osiris.RegisterListener("LeftCombat", 2, "after", SP_OnCombatLeave)
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", SP_OnTurnStarted)

Ext.Osiris.RegisterListener("RollResult", 6, "after", SP_OnRollResults)
Ext.Osiris.RegisterListener("LevelLoaded", 1, "after", SP_OnLevelLoaded)
Ext.Osiris.RegisterListener("LevelUnloading", 1, "before", SP_OnBeforeLevelUnloaded)
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", SP_OnStatusApplied)
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", SP_OnStatusRemoved)
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", SP_OnItemAdded)
Ext.Osiris.RegisterListener("Died", 1, "before", SP_OnBeforeDeath)
Ext.Osiris.RegisterListener("ShortRested", 1, "after", SP_OnShortRest)
Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", SP_OnLongRest)
Ext.Osiris.RegisterListener("UseFinished", 3, "after", SP_OnItemUsed)
