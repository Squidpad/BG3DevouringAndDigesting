StatPaths={
    "Public/ModName/Stats/Generated/Data/Armor.txt",
    "Public/ModName/Stats/Generated/Data/Potions.txt",
    "Public/ModName/Stats/Generated/Data/Spell_Vore.txt",
}

PersistentVars = {}
PredPreyTable = {}

local function SP_Regurgitate(caster, spell)
    if string.sub(spell,0,20) == 'SP_Vore_Regurgitate_' then
        local predX, predY, predZ = Osi.getPosition(caster)
        local predXRotation, predYRotation, predZRotation = Osi.getRotation(caster)
        predYRotation = predYRotation * math.pi / 180
        local preyGUID = string.sub(spell, 21)
        for k, v in pairs(PredPreyTable[caster]) do
            if spell == "SP_Vore_Regurgitate_All" or v == preyGUID then
                Osi.TeleportToPosition(v, predX+1*math.cos(predYRotation), predY, predZ+1*math.sin(predYRotation), "", 0, 0, 0, 0, 0)
                Osi.RemoveStatus(v, 'SP_Vore_Swallowed_Endo')
                PredPreyTable[caster][k] = 'deleteme'
            end
        end
        if preyGUID ~= "All" then
            SP_RemoveCustomRegurgitate(preyGUID)
        end
        
        PredPreyTable[caster] = ArrayRemove(PredPreyTable[caster])
        if next(PredPreyTable[caster]) == nil then
            Osi.RemoveStatus(caster, 'SP_Vore_Stuffed')
            Osi.RemoveSpell(caster, 'SP_Vore_Regurgitate', 0)
            table.remove(PredPreyTable, caster)
        end
        PersistentVars['PredPreyTable'] = table.deepcopy(PredPreyTable)
        _D(PredPreyTable)
    end
end


local function SP_FillPredPreyTable(caster, target, spell)
    _D(PredPreyTable)
    _P(spell)
    if spell == 'SP_Target_Vore_Endo' or spell == 'SP_Target_Vore_Lethal' then
        if PredPreyTable[caster] == nil then
            PredPreyTable[caster] = {}
        end
        table.insert(PredPreyTable[caster], target)
        SP_AddCustomRegurgitate(target)
        Osi.AddSpell(caster, 'SP_Vore_Regurgitate', 1, 1)
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

local function on_reset_completed()
    for _, statPath in ipairs(StatPaths) do
        Ext.Stats.LoadStatsFile(statPath,1)
    end
    _P('Reloading stats!')
end

local function SP_UpdatePreyPosCombat(obj)
    _P(obj)
end

local function SP_UpdatePreyPos(oldLeader, newLeader, group)
    _P(oldLeader)
    _P(newLeader)
    _P(group)

end

function SP_GetAllPreds()
    local currentPreds = {}
    for _, v in pairs(PredPreyTable) do
        table.insert(currentPreds, v)
    end
    return currentPreds
end

function SP_AddCustomRegurgitate(characterGUID)
    local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. characterGUID, "SpellData", "SP_Vore_Regurgitate")
    newRegurgitate.DisplayName = "h339b4a78ga0a6g4b55g93fag7c8fb6725002"
    newRegurgitate.Description = "hfed57717ga1feg4c72gad20gbaaa9d1adf1b"
    newRegurgitate.DescriptionParams = Osi.getDisplayName(characterGUID)
    newRegurgitate:Sync()
    local regurgitateBase = Ext.Stats.Get("SP_Vore_Regurgitate", "SpellData")
    regurgitateBase.ContainerSpells = regurgitateBase.ContainerSpells .. ";SP_Regurgitate_" .. characterGUID
    regurgitateBase:Sync()
end

function SP_RemoveCustomRegurgitate(characterGUID)
    local regurgitateBase = Ext.Stats.Get("SP_Vore_Regurgitate", "SpellData")
    regurgitateBase.ContainerSpells = string.removeSubstring(regurgitateBase.ContainerSpells, "SP_Regurgitate_" .. characterGUID)
    regurgitateBase:Sync()
end

function string.removeSubstring(s, substring)
    local x,y = string.find(s, substring)
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
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_Regurgitate)
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", SP_UpdatePreyPosCombat)
Ext.Osiris.RegisterListener("EscortGroupLeaderChanged", 3, "after", SP_UpdatePreyPos)
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(on_reset_completed)
