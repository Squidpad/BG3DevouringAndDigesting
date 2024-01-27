StatPaths = {
    "Public/DevouringAndDigesting/Stats/Generated/Data/Armor.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Potions.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Spell_Vore.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Items.txt",
}

Ext.Require("Utils/Utils.lua")
Ext.Require("Utils/VoreUtils.lua")
Ext.Require("Utils/Config.lua")

PersistentVars = {}

CalculateRest = true

---Triggers on spell cast.
---@param caster CHARACTER
---@param spell string
---@param spellType string?
---@param spellElement string? Like fire, lightning, etc I think.
---@param storyActionID integer?
function SP_OnSpellCast(caster, spell, spellType, spellElement, storyActionID)
	-- Spell's format will always be like 'SP_Spell_' followed by either the
	-- GUID of the prey, or 'All'. Probably possible to add some sort of extra
	-- data to the custom spell, but this is way easier.
    if string.sub(spell, 0, 15) == 'SP_Regurgitate_' then
        local prey = string.sub(spell, 16)
        SP_RegurgitatePrey(caster, prey, 0, spell)
    elseif string.sub(spell, 0, 12) == 'SP_Disposal_' then
        local prey = string.sub(spell, 13)
        SP_RegurgitatePrey(caster, prey, 1, spell)
    elseif string.sub(spell, 0, 10) == 'SP_Absorb_' then
        local prey = string.sub(spell, 11)
        SP_RegurgitatePrey(caster, prey, 1, 'Absorb')
    end
end

---Triggers when a spell is cast with a target.
---@param caster CHARACTER
---@param target CHARACTER
---@param spell string
---@param spellType string?
---@param spellElement string? Like fire, lightning, etc I think.
---@param storyActionID integer?
function SP_OnSpellCastTarget(caster, target, spell, spellType, spellElement, storyActionID)
    if Osi.HasActiveStatus(target, "SP_Inedible") ~= 0 then
        return
    end
    if spell == 'SP_Target_Vore_Endo' then
        _P('Endo Vore attempt')
        if Osi.GetCanPickUp(target) == 1 then
            _P("Item")
            if SP_CanFitItem(caster, target) then
                SP_DelayCallTicks(12, function()
                    SP_SwallowItem(caster, target)
                end)
            else
                Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
            end
        else
            _P("Not Item")
            if SP_CanFitPrey(caster, target) then
                SP_DelayCallTicks(12, function()
                    SP_SwallowPrey(caster, target, 'SP_Swallowed_Endo', true)
                end)
            else
                Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
            end
        end
    end
    if spell == 'SP_Target_Vore_Lethal' then
        _P('Lethal Vore')
        if SP_CanFitPrey(caster, target) then
            SP_DelayCallTicks(7, function()
                SP_VoreCheck(caster, target, "SwallowLethalCheck")
            end)
        else
            Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
        end
    end
end

---Triggers whenever there's a skill check.
---@param eventName string Name of event passed from the func that called the roll.
---@param roller CHARACTER Roller.
---@param rollSubject CHARACTER Character they rolled against.
---@param resultType integer Result of roll. 0 == fail, 1 == success.
---@param isActiveRoll integer? Whether or not the rolling GUI popped up. 0 == no, 1 == yes.
---@param criticality CRITICALITYTYPE? Whether or not it was a crit and what kind. 0 == no crit, 1 == crit success, 2 == crit fail.
function SP_OnRollResults(eventName, roller, rollSubject, resultType, isActiveRoll, criticality)
    if eventName == "SwallowLethalCheck" and (resultType ~= 0 or ConfigVars.VoreDifficulty.value == 'debug') then
        _P('Lethal Swallow Success by ' .. roller)
        SP_SwallowPrey(roller, rollSubject, 'SP_Swallowed_Lethal', true)
    end
    if eventName == "StruggleCheck" and resultType ~= 0 then
        _P('Struggle Success by ' .. roller .. ' against ' .. rollSubject)
        Osi.ApplyStatus(rollSubject, "SP_Indigestion", 1 * SecondsPerTurn)
        if Osi.GetStatusTurns(rollSubject, "SP_Indigestion") >= 6 then
            Osi.RemoveStatus(rollSubject, "SP_Indigestion")
			-- Now only the prey who struggled out will escape
            SP_RegurgitatePrey(rollSubject, "All", 0, "")
        end
    end
end

---Runs on session load.
function SP_OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
    SP_GetConfigFromFile()
    if PersistentVars['PreyTablePred'] ~= nil then
        _P('loading table')
        PreyTablePred = SP_Deepcopy(PersistentVars['PreyTablePred'])
    else
        PersistentVars['PreyTablePred'] = {}
    end
    -- Tables to store prey weight, since it can change while in stomach for some reason.
    -- Fake table is for their pre-digestion weight.
    if PersistentVars['PreyWeightTable'] == nil then
        PersistentVars['PreyWeightTable'] = {}
    end
    if PersistentVars['FakePreyWeightTable'] == nil then
        PersistentVars['FakePreyWeightTable'] = {}
    end
    -- If death throw passive should be restored.
    if PersistentVars['DisableDownedPreyTable'] == nil then
        PersistentVars['DisableDownedPreyTable'] = {}
    end
    -- UUID of subclass addon.
    if Ext.Mod.IsModLoaded("8cde9804-68a7-4bd2-a85e-1fb2c7216790") then
        SubclassAddOn = true
    end
end

---Runs when reset command is sent to console.
function SP_OnResetCompleted()
    for _, statPath in ipairs(StatPaths) do
        _P(statPath)
        ---@diagnostic disable-next-line: undefined-field
        Ext.Stats.LoadStatsFile(statPath, 1)
    end
    _P('Reloading stats!')
end

---Runs whenever you change game regions.
---@param level string? Name of new game region.
function SP_OnBeforeLevelUnloaded(level)
    -- For some reason this triggers when you load game from main menu, tried changing to what event it's subscribed.
    _P('LEVEL CHANGE')
    _D(level)
    _P('Level changed to ' .. level)

    for k, v in pairs(PreyTablePred) do
        SP_RegurgitatePrey(v, k, 2, "LevelChange")
    end
    PreyTablePred = {}
    PersistentVars['PreyTablePred'] = {}
    PersistentVars['PreyWeightTable'] = {}
    PersistentVars['FakePreyWeightTable'] = {}
    PersistentVars['DisableDownedPreyTable'] = {}
end

---Runs each time a status is applied.
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee GUIDSTRING? Thing that caused status to be applied.
---@param storyActionID integer?
function SP_OnStatusApplied(object, status, causee, storyActionID)
    if status == 'SP_Digesting' then
        for _, v in ipairs(SP_GetAllPrey(object)) do
			if Osi.IsDead(v) == 0 and Osi.IsInCombat(object) == 0 then
				if ConfigVars.TeleportPrey.value == true then
					Osi.TeleportTo(v, object, "", 0, 0, 0, 0, 0)
				end
				if Osi.HasActiveStatus(v, 'SP_Swallowed_Lethal') == 1 then
					SP_VoreCheck(object, v, "StruggleCheck")
				end
			end
        end
    elseif status == 'SP_Inedible' and Osi.GetStatusTurns(object, 'SP_Inedible') > 1 then
        Osi.RemoveStatus(object, 'SP_Inedible', "")
    elseif status == 'SP_PotionOfGluttony_Status' and Osi.GetStatusTurns(object, 'SP_PotionOfGluttony_Status') > 1 then
        Osi.RemoveStatus(object, 'SP_PotionOfGluttony_Status', "")
    elseif status == 'SP_Item_Bound' then
        _P("Applied " .. status .. " Status to " .. object)
    end
end

---Runs just before the end of a character's turn in combat.
---@param character CHARACTER
function SP_OnBeforeTurnEnds(character)
    if Osi.HasActiveStatus(character, 'SP_Stuffed') then
        for _, v in ipairs(SP_GetAllPrey(character)) do
			if Osi.IsDead(v) == 0 then
				Osi.TeleportTo(v, character, "", 0, 0, 0, 0, 0)
				if Osi.HasActiveStatus(v, 'SP_Swallowed_Lethal') == 1 then
					SP_VoreCheck(character, v, "StruggleCheck")
				end
			end
        end
    end
end

---Runs just after combat starts.
---@param combatGuid GUIDSTRING
function SP_OnCombatStart(combatGuid)
    for _, pred in ipairs(SP_GetUniquePreds()) do
        if Osi.IsInCombat(pred) then
            for _, v in ipairs(SP_GetAllPrey(pred)) do
                if Osi.IsDead(v) == 0 then
                    Osi.EnterCombat(v, combatGuid)
                end
            end
        end
    end
end

---Runs when someone dies.
---@param character CHARACTER
function SP_OnBeforeDeath(character)
    -- If character was prey.
    if PreyTablePred[character] ~= nil then
        local pred = PreyTablePred[character]
        _P(character .. " was digested by " .. pred .. " and DIED")
        SP_RegurgitatePrey(character, 'All', 2, "")
        Osi.RemoveStatus(character, 'SP_Swallowed_Endo', pred)
        Osi.RemoveStatus(character, 'SP_Swallowed_Lethal', pred)
        Osi.ApplyStatus(character, 'SP_Swallowed_Dead', -1, 1, pred)
        -- Temp characters' corpses are not saved is save file, so they might cause issues unless disposed of on death.
        if Ext.Entity.Get(character).ServerCharacter.Temporary == true then
            _P("Absorbing temp character")
            SP_DelayCallTicks(10, function()
                SP_RegurgitatePrey(pred, character, 2, "Absorb")
            end)
        else
            -- Digested but not released prey will be stored out of bounds.
            Osi.TeleportToPosition(character, -100000, 0, -100000, "", 0, 0, 0, 1, 0)
            -- Implementation for fast digestion.
            if ConfigVars.SlowDigestion.value == false then
                SP_DelayCallTicks(10, function()
                    local preyWeightDiff = PersistentVars['PreyWeightTable'][character] -
                                               PersistentVars['FakePreyWeightTable'][character] // 5
                    SP_ReduceWeightRecursive(character, preyWeightDiff, true)
                end)
            end
        end

    end
    -- If character was pred, free their prey.
    if Osi.HasActiveStatus(character, "SP_Stuffed") ~= 0 then
        SP_RegurgitatePrey(character, 'All', 2, "")
    end
end

---Runs whenever item is added.
---@param objectTemplate ROOT
---@param object GUIDSTRING
---@param inventoryHolder GUIDSTRING
---@param addType string
function SP_OnItemAdded(objectTemplate, object, inventoryHolder, addType)
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
        Osi.Lock(object, 'amogus')
    end
end

---Fires once per short rest.
---@param character CHARACTER
function SP_OnShortRest(character)
    -- This is necessary to avoid multiple calls of this function (for each party member).
    if CalculateRest == false then
        return
    end
    CalculateRest = false

    _P('SP_OnShortRest')

    for k, v in pairs(PersistentVars['PreyWeightTable']) do
        if Osi.IsDead(k) == 1 then
            local preyWeightDiff = tonumber(ConfigVars.DigestionRateShort.value)
            assert(type(preyWeightDiff) == 'number')
            -- Prey's weight after digestion should not be smaller then 1/5th of their original (fake) weight.
            if (v - preyWeightDiff) < (PersistentVars['FakePreyWeightTable'][k] // 5) then
                preyWeightDiff = v - PersistentVars['FakePreyWeightTable'][k] // 5
            end
            SP_ReduceWeightRecursive(k, preyWeightDiff, false)
        end
    end

    local preds = SP_GetUniquePreds()
    for k, v in pairs(preds) do
        SP_UpdateWeight(k, true)
    end
    _D(PersistentVars['PreyWeightTable'])
    _D(PersistentVars['FakePreyWeightTable'])
    -- This is necessary to avoid multiple calls of this function (for each party member).
    SP_DelayCallTicks(5, function()
        CalculateRest = true
    end)
end

---Fires once after long rest.
function SP_OnLongRest()
    _P('SP_OnLongRest')

    for k, v in pairs(PersistentVars['PreyWeightTable']) do
        if Osi.IsDead(k) == 1 then
            local preyWeightDiff = tonumber(ConfigVars.DigestionRateLong.value)
            assert(type(preyWeightDiff) == 'number')
            -- Prey's weight after digestion should not be smaller then 1/5th of their original (fake) weight.
            if (v - preyWeightDiff) < (PersistentVars['FakePreyWeightTable'][k] // 5) then
                preyWeightDiff = v - PersistentVars['FakePreyWeightTable'][k] // 5
            end
            SP_ReduceWeightRecursive(k, preyWeightDiff, false)
        end
    end

    local preds = SP_GetUniquePreds()
    for k, v in pairs(preds) do
        SP_UpdateWeight(k, true)
    end
    _D(PersistentVars['PreyWeightTable'])
    _D(PersistentVars['FakePreyWeightTable'])
end

function SP_ResetVore()
    local preds = SP_GetUniquePreds()
    for k, v in pairs(preds) do
        SP_RegurgitatePrey(k, "All", 2, "ResetVore")
    end
    PreyTablePred = {}
    PersistentVars['PreyTablePred'] = {}
    PersistentVars['PreyWeightTable'] = {}
    PersistentVars['FakePreyWeightTable'] = {}
    PersistentVars['DisableDownedPreyTable'] = {}
end

-- If you know where to get type hints for this, please let me know.
if Ext.Osiris == nil then
    Ext.Osiris = {}
end

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_OnSpellCastTarget)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_OnSpellCast)
Ext.Osiris.RegisterListener("TurnEnded", 1, "before", SP_OnBeforeTurnEnds)
Ext.Osiris.RegisterListener("CombatStarted", 1, "after", SP_OnCombatStart)
Ext.Osiris.RegisterListener("RollResult", 6, "after", SP_OnRollResults)
Ext.Osiris.RegisterListener("LevelUnloading", 1, "before", SP_OnBeforeLevelUnloaded)
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", SP_OnStatusApplied)
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", SP_OnItemAdded)
Ext.Osiris.RegisterListener("Died", 1, "before", SP_OnBeforeDeath)
Ext.Osiris.RegisterListener("ShortRested", 1, "after", SP_OnShortRest)
Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", SP_OnLongRest)

Ext.Events.SessionLoaded:Subscribe(SP_OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(SP_OnResetCompleted)

-- Lets you config during runtime.
Ext.RegisterConsoleCommand('VoreConfig', VoreConfig);
Ext.RegisterConsoleCommand('VoreConfigOptions', VoreConfigOptions);

Ext.RegisterConsoleCommand("ResetVore", SP_ResetVore);
