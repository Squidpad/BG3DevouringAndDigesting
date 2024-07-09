

function SP_DebugStatus()
    local v = Osi.GetHostCharacter()
    Osi.ApplyStatus(v, "SP_DebugActionStatus", -1)
    Osi.ApplyStatus(v, "SP_DebugInitStatus", -1)
    Osi.ApplyStatus(v, "SP_DebugSpellSaveStatus", -1)
    Osi.ApplyStatus(v, "FEATHER_FALL", -1)
end

function SP_DebugTestFunc()
    SP_TeleportToPred("ALL")
end

--- Removes spells from Host
function SP_RemoveBrokenSpells()
    local brokenSpells = {
        "SP_SwitchToLethal",
        "SP_SwitchToLethal_O",
        "SP_SwitchToLethal_A",
        "SP_SwitchToLethal_U",
        "SP_SwitchToLethal_C",
        "SP_SwitchToLethal_All",

    }
    local host = Osi.GetHostCharacter()
    local hData = Ext.Entity.Get(host)
    for _, brokenSpell in ipairs(brokenSpells) do
        local new1 = {}
        for i, j in pairs(hData.AddedSpells.Spells) do
            if j.SpellId.OriginatorPrototype ~= brokenSpell then
                table.insert(new1, j)
            end
        end
        hData.AddedSpells.Spells = new1
        for i, j in pairs(hData.HotbarContainer.Containers.DefaultBarContainer) do
            local new2 = {}
            for k, v in pairs(hData.HotbarContainer.Containers.DefaultBarContainer[i].Elements) do
                if v.SpellId.OriginatorPrototype ~= brokenSpell then
                    table.insert(new2, v)
                end
            end
            hData.HotbarContainer.Containers.DefaultBarContainer[i].Elements = new2
        end
        local new3 = {}
        for i, j in pairs(hData.SpellBookPrepares.PreparedSpells) do
            if j.OriginatorPrototype ~= brokenSpell then
                table.insert(new3, j)
            end
        end
        hData.SpellBookPrepares.PreparedSpells = new3
        local new4 = {}
        for i, j in pairs(hData.SpellContainer.Spells) do
            if j.SpellId.OriginatorPrototype ~= brokenSpell then
                table.insert(new4, j)
            end
        end
        hData.SpellContainer.Spells = new4
        Osi.RemoveSpell(host, brokenSpell, 1)
    end
end


function SP_ResetVore()
    for k, v in pairs(VoreData or {}) do
        if next(v.Prey) ~= nil or v.Items ~= "" then
            SP_RegurgitatePrey(k, "All", -1, "ResetVore")
        end
    end
    SP_DelayCallTicks(15, function ()
        for k, v in pairs(VoreData or {}) do
            v.AddWeight = 0
            v.Fat = 0
            v.Satiation = 0
            SP_UpdateWeight(k)
        end
        SP_DelayCallTicks(10, function ()
            VoreData = {}
            PersistentVars['VoreData'] = {}
            _P("Vore reset complete")
        end)
    end)
end

-- deletes every vore-related variable and possibly fixed broken saves
function SP_KillVore()
    PersistentVars['PreyTablePred'] = nil
    PersistentVars['PreyWeightTable'] = nil
    PersistentVars['FakePreyWeightTable'] = nil
    PersistentVars['DisableDownedPreyTable'] = nil
    VoreData = {}
    PersistentVars['VoreData'] = {}
end

-- gives player debug items
function SP_GiveDebugItems()
    local player = Osi.GetHostCharacter()
    Osi.TemplateAddTo('91cb93c0-0e07-4b3a-a1e9-a836585146a9', player, 1)
    Osi.TemplateAddTo('69d2df14-6d8a-4f94-92b5-cc48bc60f132', player, 1)
end

function SP_DebugVore()
    local party = Ext.Entity.Get(Osi.GetHostCharacter()).PartyMember.Party.PartyView.Characters
    for k, v in pairs(party) do
        local predData = v:GetAllComponents()
        local pred = predData.ServerCharacter.Template.Name .. "_" .. predData.Uuid.EntityUuid
        Osi.SetLevel(pred, 6)
    end
end


Ext.RegisterConsoleCommand('DebugStatus', SP_DebugStatus)

Ext.RegisterConsoleCommand('FixSpell', SP_RemoveBrokenSpells)


Ext.RegisterConsoleCommand("ResetVore", SP_ResetVore)
Ext.RegisterConsoleCommand("KillVore", SP_KillVore)
Ext.RegisterConsoleCommand("GiveDebugItems", SP_GiveDebugItems)
Ext.RegisterConsoleCommand("DebugVore", SP_DebugVore)
Ext.RegisterConsoleCommand("DebugFunc", SP_DebugTestFunc)

