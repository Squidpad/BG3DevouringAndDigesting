
PersistentVars = {}
PredPreyTable = {}


local function SP_Regurgitate(caster, spell)
    if spell == 'SP_Vore_Regurgitate' then
        Osi.RemoveStatus(caster, 'SP_Vore_Stuffed')
        Osi.RemoveSpell(caster, 'SP_Regurgitate', 0)
        local predX, predY, predZ = Osi.getPosition(caster)
        local predXRotation, predYRotation, predZRotation = Osi.getRotation(caster)
        _P(predX, predY, predZ)
        _P(predXRotation, predYRotation, predZRotation)
        predYRotation = predYRotation * math.pi / 180
        _D(PredPreyTable)
        for k, v in pairs(PredPreyTable[caster]) do
            Osi.TeleportToPosition(v, predX+5*math.cos(predYRotation), predY, predZ+5*math.sin(predYRotation))
            Osi.RemoveStatus(v, 'SP_Vore_Swallowed_Endo')
            PredPreyTable[caster][k] = 'deleteme'
        end
        if next(PredPreyTable[caster]) == nil then
            table.remove(PredPreyTable, caster)
        end
        ArrayRemove(PredPreyTable[caster])
        PersistentVars['PredPreyTable'] = PredPreyTable
        _D(PredPreyTable)
    end
end


local function SP_fillPredPreyTable(caster, target, spell)
    if spell == 'SP_Target_Vore_Endo' or spell == 'SP_Target_Vore_Lethal' then
        _P('step 1')
        if PredPreyTable[caster] == nil then
            _P('step 2')
            PredPreyTable[caster] = {}
        end
        table.insert(PredPreyTable[caster], target)
        _P('step 3')
        Osi.AddSpell(caster, 'SP_Vore_Regurgitate', 1, 0)
        PersistentVars['PredPreyTable'] = PredPreyTable
        _D(PredPreyTable)


    end
end

function OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D('PersistenVars: ' .. PersistentVars)
end

function SP_getAllPreds()
    local currentPreds = {}
    for _, v in pairs(PredPreyTable) do
        table.insert(currentPreds, v)
    end
    return currentPreds
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


Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_fillPredPreyTable)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_Regurgitate)
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
