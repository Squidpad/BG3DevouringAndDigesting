function SP_DebugFeats()
    local v = Osi.GetHostCharacter()
    Osi.AddPassive(v, "SP_EveryonesStrength")
    Osi.AddPassive(v, "SP_Improved_Stomach_Shelter")
    Osi.AddPassive(v, "SP_Gastric_Bulwark")
    Osi.AddPassive(v, "SP_BottomlessStomach")
    Osi.AddPassive(v, "SP_EndoAnyone")
    Osi.AddPassive(v, "SP_AlwaysEndoToggle")
end

function SP_DebugStatus()
    local v = Osi.GetHostCharacter()
    Osi.ApplyStatus(v, "SP_DebugActionStatus", -1)
    Osi.ApplyStatus(v, "SP_DebugInitStatus", -1)
    Osi.ApplyStatus(v, "SP_DebugSpellSaveStatus", -1)
    Osi.ApplyStatus(v, "FEATHER_FALL", -1)
end

function SP_DebugTest()
    local v = Osi.GetHostCharacter()
    Osi.AddCustomVisualOverride(v, "895fcd5b-dc72-4926-811f-c4c2e12903e9")
end

function SP_DebugTest2()
    local v = Osi.GetHostCharacter()
    Osi.RemoveCustomVisualOvirride(v, "895fcd5b-dc72-4926-811f-c4c2e12903e9")
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


---Console command for printing config options and states.
function VoreConfigOptions()
    _P("Vore Mod Configuration Options: ")
    for k, v in pairs(ConfigVars) do
        _P(k .. ": ")
        for i, j in pairs(v) do
            _P(i .. ": " .. j.description)
            _P("Currently set to " .. tostring(j.value))
        end
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
end

-- gives player all usable items from mod (to avoid using SummonTutorialChest)
function SP_GiveMeVore()
    local player = Osi.GetHostCharacter()
    Osi.TemplateAddTo('b8d700d0-681f-4c38-b444-fe69b361d9b3', player, 1)
    -- Osi.TemplateAddTo('91cb93c0-0e07-4b3a-a1e9-a836585146a9', player, 1)
    -- Osi.TemplateAddTo('04987160-cb88-4d3e-b219-1843e5253d51', player, 1)
    -- Osi.TemplateAddTo('f3914e54-2c48-426a-a338-8e1c86ebc7be', player, 1)
    -- Osi.TemplateAddTo('92067c3c-547e-4451-9377-632391702de9', player, 1)
    -- Osi.TemplateAddTo('04cbdeb4-a98e-44cd-b032-972df0ba3ca1', player, 1)
    -- Osi.TemplateAddTo('69d2df14-6d8a-4f94-92b5-cc48bc60f132', player, 1)
    -- Osi.TemplateAddTo('02ee5321-7bcd-4712-ba06-89eb1850c2e4', player, 1)
    -- Osi.TemplateAddTo('319379c2-3627-4c26-b14d-3ce8abb676c3', player, 1)
end

function SP_DebugVore()
    local party = Ext.Entity.Get(Osi.GetHostCharacter()).PartyMember.Party.PartyView.Characters
    for k, v in pairs(party) do
        local predData = v:GetAllComponents()
        local pred = predData.ServerCharacter.Template.Name .. "_" .. predData.Uuid.EntityUuid
        Osi.SetLevel(pred, 6)
    end
end




Ext.RegisterConsoleCommand('DebugFeats', SP_DebugFeats)
Ext.RegisterConsoleCommand('DebugStatus', SP_DebugStatus)
Ext.RegisterConsoleCommand('Test', SP_DebugTest)
Ext.RegisterConsoleCommand('Test2', SP_DebugTest2)

Ext.RegisterConsoleCommand('FixSpell', SP_RemoveBrokenSpells)

-- Lets you config during runtime.
Ext.RegisterConsoleCommand('VoreConfigOptions', VoreConfigOptions)
Ext.RegisterConsoleCommand('VoreConfigReload', SP_LoadConfigFromFile)
Ext.RegisterConsoleCommand('VoreConfigReset', SP_ResetAndSaveConfig)

Ext.RegisterConsoleCommand("ResetVore", SP_ResetVore)
Ext.RegisterConsoleCommand("KillVore", SP_KillVore)
Ext.RegisterConsoleCommand("GiveMeVore", SP_GiveMeVore)
Ext.RegisterConsoleCommand("DebugVore", SP_DebugVore)
