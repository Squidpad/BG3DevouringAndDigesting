StatPaths={
    "Public/ModName/Stats/Generated/Data/Armor.txt",
    "Public/ModName/Stats/Generated/Data/Potions.txt",
    "Public/ModName/Stats/Generated/Data/Spell_Vore.txt",
}

PersistentVars = {}
PredPreyTable = {}

function SP_SpellCast(caster, spell)
    if string.sub(spell,0,15) == 'SP_Regurgitate_' then
        _P('Starting Regurgitation')
        local preyGUID = string.sub(spell, 16)
        _P('Targets: ' .. preyGUID)
        local predX, predY, predZ = Osi.getPosition(caster)
        local predXRotation, predYRotation, predZRotation = Osi.getRotation(caster)
        predYRotation = predYRotation * math.pi / 180
        local indexToRemove = 0
        for k, v in pairs(PredPreyTable[caster]) do
            if spell == "SP_Regurgitate_All" or v == preyGUID then
                Osi.TeleportToPosition(v, predX+2*math.cos(predYRotation), predY, predZ+2*math.sin(predYRotation), "", 0, 0, 0, 0, 0)
                Osi.RemoveStatus(v, 'SP_Swallowed_Endo', caster)
                if v == preyGUID then
                    indexToRemove = k
                end
            end
        end
        if preyGUID ~= "All" then
            SP_RemoveCustomRegurgitate(preyGUID)
            table.remove(PredPreyTable[caster], indexToRemove)
        end
        if preyGUID == 'All' or next(PredPreyTable[caster]) == nil then
            PredPreyTable[caster] = nil
            Osi.RemoveStatus(caster, 'SP_Stuffed')
            --Osi.RemoveSpell(caster, 'SP_Regurgitate', 1)
            Osi.RemoveSpell(caster, 'SP_Regurgitate_All', 1)
            --Osi.RemoveSpell(caster, 'SP_Walk_With_Prey')
            Osi.RemoveSpell(caster, "SP_Move_Prey_To_Me")
        end
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
    elseif spell == "SP_Move_Prey_To_Me" then
        TelePreyToPred(caster)
    end
end

function SP_InitialSwallowPass(caster, target, spell)
    if spell == 'SP_Target_Vore_Endo' then
        _P('Endo Vore')
        DelayCall(600, function() Osi.ApplyStatus(target, "SP_Swallowed_Endo", -1, 1, caster) end)
        DelayCall(600, function() Osi.ApplyStatus(caster, "SP_Stuffed_Endo", -1, 1, caster) end)
        DelayCall(600, function() Osi.TemplateAddTo("f80c2fd2-5222-44aa-a68e-b2faa808171b", caster, 1, 1) end)
        DelayCall(600, function() SP_FillPredPreyTable(caster, target, 'SP_Target_Vore_Endo') end)
    end
    if spell == 'SP_Target_Vore_Lethal' then
        _P('Lethal Vore')
        DelayCall(600, function() SwallowCheck(caster, target, "SwallowLethalCheck") end)
    end
end

function SP_FillPredPreyTable(caster, target, spell)
    _P("Filling Table")
    if spell == 'SP_Target_Vore_Endo' or spell == 'SP_Target_Vore_Lethal' then
        if PredPreyTable[caster] == nil then
            PredPreyTable[caster] = {}
        end
        table.insert(PredPreyTable[caster], target)
        --SP_AddCustomRegurgitate(target)

        --Osi.AddSpell(caster, 'SP_Regurgitate', 1, 1)
        Osi.AddSpell(caster, 'SP_Regurgitate_All', 1, 1)
        --Osi.AddSpell(caster, 'SP_Walk_With_Prey', 1)
        Osi.AddSpell(caster, "SP_Move_Prey_To_Me")
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
        _D(PredPreyTable)
    end
end

function SP_RollResults(eventName, roller, rollSubject, resultType, _, _)
    if eventName == "SwallowLethalCheck" and resultType ~= 0 then
        _P('Lethal Swallow Success')
        Osi.ApplyStatus(rollSubject, "SP_Swallowed_Lethal", 10, 1, roller)
        Osi.ApplyStatus(roller, "SP_Stuffed_Lethal", 10, 1, roller)
        SP_FillPredPreyTable(roller, rollSubject, 'SP_Target_Vore_Lethal')
    end
    if eventName == "StruggleCheck" and resultType ~= 0 then
        _P('Struggle Success')
        Osi.RemoveStatus(roller, "SP_Swallowed_Lethal")
        SP_SpellCast(rollSubject, "SP_Regurgitate_All")
    end
end

function SP_OnDeath(character)
    if Osi.HasActiveStatus(character, 'SP_Swallowed_Lethal') then
        _P("Creature Digested")
        local pred = SP_GetPredFromPrey(character)
        Osi.TransferItemsToCharacter(character, pred)
        _P("Inventory Transferred")
        Osi.RemoveStatus(character, 'SP_Swallowed_Lethal')
        _P('Prey Status Removed')
        if next(PredPreyTable[pred]) == nil then
            PredPreyTable[pred] = nil
            Osi.RemoveStatus(pred, 'SP_Stuffed')
            --Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
            Osi.RemoveSpell(pred, 'SP_Regurgitate_All', 1)
            --Osi.RemoveSpell(pred, 'SP_Walk_With_Prey')
            Osi.RemoveSpell(pred, "SP_Move_Prey_To_Me")
        end
        
    end
end

function SP_GetPredFromPrey(prey)
    _P("Getting Pred from Prey")
    for k, v in pairs(PredPreyTable) do
        for _, j in pairs(v) do
            if prey == j then
                return k
            end
        end
    end
end

-- function SP_AddWeight(prey)
--     _P("adding weight")
--     local weightPlaceholder = Ext.Stats.Get("SP_Weight_Placeholder")
--     weightPlaceholder.Weight = 
--     weightPlaceholder:Sync()

-- end

function OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
    if PersistentVars['PredPreyTable'] ~= nil then
        _P('updated it')
        PredPreyTable = table.deepcopy(PersistentVars['PredPreyTable'])
    end
end

function On_reset_completed()
    for _, statPath in ipairs(StatPaths) do
        Ext.Stats.LoadStatsFile(statPath,1)
    end
    _P('Reloading stats!')
end

function SP_UpdatePreyPosCombat(obj)
    _P("Turn Changed")
    for k, _ in pairs(PredPreyTable) do
        TelePreyToPred(k)
    end
end

function SP_OnLevelChange(level)
    for k, v in pairs(PredPreyTable) do
        SP_SpellCast(k, 'SP_Regurgitate_All')
    end
end

function SP_OnStatusFail(object, status, causee, storyActionID)
    if status == 'SP_Swallowed_Lethal_Tick' then
        _P('LethalTick')
        local pred = SP_GetPredFromPrey(object)
        StruggleCheck(pred, object, "StruggleCheck")
    end
end

function TelePreyToPred(pred)
    _P('Prey moved to Pred Location')
    for _, v in pairs(PredPreyTable[pred]) do
        Osi.TeleportTo(v, pred, "", 0, 0, 0, 0, 0)
    end
end

function SwallowCheck(pred, prey, eventName)
    _P('Rolling to resist swallow')
    if Osi.HasSkill(target, "Acrobatics") > Osi.HasSkill(target, "Athletics") then
        _P('Using Acrobatics')
        Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Acrobatics", 0, 0, eventName)
    else
        _P('Using Athletics')
        Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Athletics", 0, 0, eventName)
    end
end

function StruggleCheck(pred, prey, eventName)
    _P("Attempting Struggle")
    Osi.RequestPassiveRollVersusSkill(prey, pred, "AbilityCheck", "Strength", "Constitution", 0, 1, eventName)
end

function SP_AddCustomRegurgitate(characterGUID)
    local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. characterGUID, "SpellData", "SP_Regurgitate_All")
    --newRegurgitate.DisplayName = "h339b4a78ga0a6g4b55g93fag7c8fb6725002"
    --newRegurgitate.Description = "hfed57717ga1feg4c72gad20gbaaa9d1adf1b"
    newRegurgitate.DescriptionParams = "Regurgitate " .. Osi.getDisplayName(characterGUID)
    newRegurgitate:Sync()

    local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
    local containerList = regurgitateBase.ContainerSpells
    containerList = containerList .. ";SP_Regurgitate_" .. characterGUID
    regurgitateBase.ContainerSpells = containerList
    regurgitateBase:Sync()
    _P(containerList)
end

function SP_RemoveCustomRegurgitate(characterGUID)
    local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
    local containerList = regurgitateBase.ContainerSpells
    containerList = string.removeSubstring(containerList, ";SP_Regurgitate_" .. characterGUID)
    regurgitateBase.ContainerSpells = containerList
    regurgitateBase:Sync()
    _D(regurgitateBase)
end

function DelayCall(msDelay, func)
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId;
    handlerId = Ext.Events.Tick:Subscribe(function()
        if (Ext.Utils.MonotonicTime() - startTime > msDelay) then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end) 
end

function string.removeSubstring(s, substring)
    local x,y = string.find(s, substring)
    if x == nil or y == nil then
        return s
      end
    return string.sub(t,0,x-1) .. string.sub(t,y+1)
end

function ArrayRemove(t)
    local j, n = 1, #t;

    for i=1,n do
        if (t[i] == 'deleteme') then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end

    return t;
end

function table.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[table.deepcopy(orig_key, copies)] = table.deepcopy(orig_value, copies)
            end
            setmetatable(copy, table.deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_InitialSwallowPass)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_SpellCast)
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", SP_UpdatePreyPosCombat)
Ext.Osiris.RegisterListener("RollResult", 6, "after", SP_RollResults)
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", SP_OnLevelChange)
Ext.Osiris.RegisterListener("Died", 1, "after", SP_OnDeath)
Ext.Osiris.RegisterListener("StatusAttemptFailed", 4, "after", SP_OnStatusFail)
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(On_reset_completed)
