StatPaths={
    "Public/ModName/Stats/Generated/Data/Armor.txt",
    "Public/ModName/Stats/Generated/Data/Potions.txt",
    "Public/ModName/Stats/Generated/Data/Spell_Vore.txt",
}

PersistentVars = {}
PredPreyTable = {}

function SP_RegurgitatePrey(caster, spell)
    if string.sub(spell,0,15) == 'SP_Regurgitate_' then
        local predX, predY, predZ = Osi.getPosition(caster)
        local predXRotation, predYRotation, predZRotation = Osi.getRotation(caster)
        predYRotation = predYRotation * math.pi / 180
        local preyGUID = string.sub(spell, 16)
        local indexToRemove = 0
        for k, v in pairs(PredPreyTable[caster]) do
            if spell == "SP_Regurgitate_All" or v == preyGUID then
                Osi.TeleportToPosition(v, predX+1.5*math.cos(predYRotation), predY, predZ+1.5*math.sin(predYRotation), "", 0, 0, 0, 0, 0)
                Osi.RemoveStatus(v, 'SP_Vore_Swallowed_Endo')
                if v == preyGUID then
                    indexToRemove = k
                end
            end
        end
        if preyGUID ~= "All" then
            _P('preyGUID')
            _P(preyGUID)
            SP_RemoveCustomRegurgitate(preyGUID)
            table.remove(PredPreyTable[caster], indexToRemove)
        else
            PredPreyTable[caster] = nil
            Osi.RemoveStatus(caster, 'SP_Vore_Stuffed')
            Osi.RemoveSpell(caster, 'SP_Regurgitate', 1)
        end
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
    end
end

function SP_FillPredPreyTable(caster, target, spell)
    if spell == 'SP_Target_Vore_Endo' or spell == 'SP_Target_Vore_Lethal' then
        if PredPreyTable[caster] == nil then
            PredPreyTable[caster] = {}
        end
        table.insert(PredPreyTable[caster], target)
        SP_AddCustomRegurgitate(target)

        Osi.AddSpell(caster, 'SP_Regurgitate', 1, 1)
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
        _D(PredPreyTable)
    end
end

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
    _P(obj)
end

function SP_UpdatePreyPos(character)
    _P("character made player")
    _P(character)

end

function SP_GetAllPreds()
    local currentPreds = {}
    for _, v in pairs(PredPreyTable) do
        table.insert(currentPreds, v)
    end
    return currentPreds
end

function SP_AddCustomRegurgitate(characterGUID)
    local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. characterGUID, "SpellData", "SP_Regurgitate_All")
    --newRegurgitate.DisplayName = "h339b4a78ga0a6g4b55g93fag7c8fb6725002"
    --newRegurgitate.Description = "hfed57717ga1feg4c72gad20gbaaa9d1adf1b"
    _P(Osi.getDisplayName(characterGUID))
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


Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_FillPredPreyTable)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_RegurgitatePrey)
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", SP_UpdatePreyPosCombat)
Ext.Osiris.RegisterListener("CharacterMadePlayer", 1, "after", SP_UpdatePreyPos)
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(On_reset_completed)
