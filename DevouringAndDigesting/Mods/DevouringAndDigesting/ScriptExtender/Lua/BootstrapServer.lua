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
    elseif spell == "SP_SwitchToLethal" then
        if VoreData[caster] ~= nil then
            if ConfigVars.DigestItems.value then
                VoreData[caster].DigestItems = true
            end
            for k, v in pairs(VoreData[caster].Prey) do
                SP_SwitchToDigestionType(caster, k, 0, 2)
            end
            PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
        end
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
        if Osi.IsItem(target) == 1 then
            if Osi.GetCanPickUp(target) == 1 then
                _P("Item")
                if SP_CanFitItem(caster, target) then
                    SP_DelayCallTicks(12, function()
                        SP_SwallowItem(caster, target)
                    end)
                else
                    Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
                end
            end
        else
            _P("Not Item")
            if SP_CanFitPrey(caster, target) then
                SP_DelayCallTicks(12, function()
                    SP_SwallowPrey(caster, target, 0, true)
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

        SP_SwallowPrey(roller, rollSubject, 2, true)

        if ConfigVars.SwitchEndoLethal.value then
            if ConfigVars.DigestItems.value then
                VoreData[roller].DigestItems = true
            end
            for k, v in pairs(VoreData[roller].Prey) do
                SP_SwitchToDigestionType(roller, k, 0, 2)
            end
            PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
        end
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


---digests a random item in pred's inventory
---@param pred CHARACTER
function SP_DigestItem(pred)
    -- the chance of an item being digested is 1/3 per Digestion tick
    if VoreData[pred].Items == nil and Osi.Random(2) ~= 1 then
        return
    end
    
    local itemList = Ext.Entity.Get(VoreData[pred].Items).InventoryOwner.PrimaryInventory:GetAllComponents()
                                 .InventoryContainer.Items
    for k, v in pairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
        _D(v.Item:GetAllComponents())
        if Osi.IsStoryItem(uuid) == 0 and Osi.IsTagged(uuid, '983087c8-c9d3-4a87-bc69-65f9329666c8') == 0 and
         Osi.IsTagged(uuid, '7b96246c-54ba-43ea-b01d-4e0b20ad35f1') == 0 then
            _P("item" .. uuid)
            if Osi.IsConsumable(uuid) == 1 then
                Osi.Use(pred, uuid, "")
            else
                VoreData[pred].AddWeight = VoreData[pred].AddWeight + Ext.Entity.Get(uuid).Data.Weight // 1000
                Osi.RequestDelete(uuid)
                Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', VoreData[pred].Items, 1, 0)
            end
            return
        end
    end
end

---Runs each time a status is applied.
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee GUIDSTRING? Thing that caused status to be applied.
---@param storyActionID integer?
function SP_OnStatusApplied(object, status, causee, storyActionID)
    if status == 'SP_Digesting' then
        for k, v in pairs(VoreData[object].Prey) do
			if VoreData[k].Digestion ~= 1 and (ConfigVars.TeleportPrey.value == true or VoreData[k].Combat ~= "") then
				Osi.TeleportTo(k, object, "", 0, 0, 0, 0, 0)
            end
        end
        if VoreData[object].DigestItems and VoreData[object].Items ~= "" then
            SP_DigestItem(object)
        end
    elseif status == 'SP_Inedible' and Osi.GetStatusTurns(object, 'SP_Inedible') > 1 then
        Osi.RemoveStatus(object, 'SP_Inedible', "")
    elseif status == 'SP_PotionOfGluttony_Status' and Osi.GetStatusTurns(object, 'SP_PotionOfGluttony_Status') > 1 then
        Osi.RemoveStatus(object, 'SP_PotionOfGluttony_Status', "")
    elseif status == 'SP_Item_Bound' then
        _P("Applied " .. status .. " Status to " .. object)
    elseif status == 'SP_Struggle' then
        _P("Applied " .. status .. " Status to " .. object .. " causee " .. causee)
        SP_VoreCheck(VoreData[object].Pred, object, "StruggleCheck")
    end
end

---Runs just before the end of a character's turn in combat.
-- ---@param character CHARACTER
-- function SP_OnBeforeTurnEnds(character)
--     if Osi.HasActiveStatus(character, 'SP_Stuffed') then
--         for _, v in ipairs(SP_GetAllPrey(character)) do
-- 			if Osi.IsDead(v) == 0 then
-- 				Osi.TeleportTo(v, character, "", 0, 0, 0, 0, 0)
-- 				if Osi.HasActiveStatus(v, 'SP_Swallowed_Lethal') == 1 then
-- 					SP_VoreCheck(character, v, "StruggleCheck")
-- 				end
-- 			end
--         end
--     end
-- end

---Runs when character enters combat
---@param object GUIDSTRING
---@param combatGuid GUIDSTRING
function SP_OnCombatEnter(object, combatGuid)
    if VoreData[object] ~= nil then
        VoreData[object].Combat = combatGuid
        PersistentVars['VoreData'][object].Combat = combatGuid
    end
end

---Runs when character leaves combat
---@param object GUIDSTRING
---@param combatGuid GUIDSTRING
function SP_OnCombatLeave(object, combatGuid)
    if VoreData[object] ~= nil then
        VoreData[object].Combat = ""
        PersistentVars['VoreData'][object].Combat = ""
    end
end

---Runs when someone dies.
---@param character CHARACTER
function SP_OnBeforeDeath(character)
    if VoreData[character] ~= nil then
        -- If character was pred.
        if VoreData[character].Fat > 0 then
            VoreData[character].Fat = 0
        end
        if VoreData[character].AddWeight > 0 then
            local thisAddDiff = VoreData[character].AddWeight
            VoreData[character].AddWeight =  0
            SP_ReduceWeightRecursive(VoreData[character].Pred, thisAddDiff, false)
        end
        if next(VoreData[character].Prey) ~= nil then
            _P(character .. " was pred and DIED")
            SP_RegurgitatePrey(character, 'All', -1, "")
        end
        -- If character was prey (both can be true at the same time)
        if VoreData[character].Pred ~= nil then
            local pred = VoreData[character].Pred
            VoreData[character].Digestion = 1
            _P(character .. " was digested by " .. pred .. " and DIED")
            -- Temp characters' corpses are not saved is save file, so they might cause issues unless disposed of on death.
            if Ext.Entity.Get(character).ServerCharacter.Temporary == true then
                _P("Absorbing temp character")
                SP_DelayCallTicks(15, function()
                    SP_RegurgitatePrey(pred, character, -1, "Absorb")
                end)
            else
                Osi.RemoveStatus(character, DigestionTypes[0], pred)
                Osi.RemoveStatus(character, DigestionTypes[2], pred)
                Osi.ApplyStatus(character, DigestionTypes[1], -1, 1, pred)
                -- Digested but not released prey will be stored out of bounds.
                -- investigate if teleporting char out of bounds and reloading breaks them
                Osi.TeleportToPosition(character, -100000, 0, -100000, "", 0, 0, 0, 1, 0)
                -- Implementation for fast digestion.
                if ConfigVars.SlowDigestion.value == false then
                    local preyWeightDiff = VoreData[character].Weight - VoreData[character].FixedWeight // 5
                    VoreData[pred].Fat = VoreData[pred].Fat + preyWeightDiff // ConfigVars.WeightGainRate.value
                    SP_DelayCallTicks(10, function()
                        SP_ReduceWeightRecursive(character, preyWeightDiff, true)
                    end)
                end
            end
        end
        PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
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
        if ConfigVars.LockStomach.value then
            Osi.Lock(object, 'amogus')
        end
    end
end

---Fires once per short rest.
---@param character CHARACTER
function SP_OnShortRest(character)
    -- This is necessary to avoid multiple calls of this function (for each party member).
    if CalculateRest == false then
        return
    end
    for k, v in pairs(VoreData) do
        if next(v.Prey) ~= nil then
            Osi.RemoveStatus(k, "SP_Indigestion")
        end
    end
    CalculateRest = false
    _P('SP_OnShortRest')
    SP_SlowDigestion(ConfigVars.DigestionRateShort.value, ConfigVars.WeightLossShort.value)
    SP_DelayCallTicks(5, function()
        CalculateRest = true
    end)
end

---Fires once after long rest.
function SP_OnLongRest()
    _P('SP_OnLongRest')
    for k, v in pairs(VoreData) do
        if next(v.Prey) ~= nil then
            Osi.RemoveStatus(k, "SP_Indigestion")
        end
    end
    SP_SlowDigestion(ConfigVars.DigestionRateLong.value, ConfigVars.WeightLossLong.value)
end

---Runs on session load
function SP_OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
	SP_GetConfigFromFile()
    if PersistentVars['VoreData'] == nil then	
        PersistentVars['VoreData'] = {}
    else
        VoreData = SP_Deepcopy(PersistentVars['VoreData'])
    end
	-- uuid of subclass addon
	if Ext.Mod.IsModLoaded("8cde9804-68a7-4bd2-a85e-1fb2c7216790") then 
		SubclassAddOn = true
	end
end

function SP_OnLevelLoaded(level)
    if PersistentVars['PreyTablePred'] ~= nil then
        SP_MigrateTables()
    end
    SP_CheckVoreData()
    
    VoreData = SP_Deepcopy(PersistentVars['VoreData'])
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
    _P('LEVEL CHANGE')
    _D(level)
    _P('Level changed to ' .. level)

    for k, v in pairs(VoreData) do
        if #v.Prey > 0 then
            SP_RegurgitatePrey(k, "All", -1, "LevelChange")
        end
    end
    -- only keeps those with items in stomach, need to test how item ids are transferred between levels,
    -- maybe remove this completely
    for k, v in pairs(VoreData) do
        VoreData[k].Prey = {}
        VoreData[k].Pred = nil
        if v.Items == "" then
            VoreData[k] = nil
        end
    end
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
end

function SP_ResetVore()
    for k, v in pairs(VoreData) do
        if next(v.Prey) ~= nil or v.Items ~= "" then
            SP_RegurgitatePrey(k, "All", -1, "ResetVore")
        end
    end
    SP_DelayCallTicks(15, function()
        for k, v in pairs(VoreData) do
            v.AddWeight = 0
            v.Fat = 0
            SP_UpdateWeight(k)
        end
        SP_DelayCallTicks(10, function() 
            VoreData = {}
            PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
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
    VoreData = nil
	PersistentVars['VoreData'] = nil
end

-- If you know where to get type hints for this, please let me know.
if Ext.Osiris == nil then
    Ext.Osiris = {}
end

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_OnSpellCastTarget)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_OnSpellCast)
-- Ext.Osiris.RegisterListener("TurnEnded", 1, "before", SP_OnBeforeTurnEnds)

Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", SP_OnCombatEnter)
Ext.Osiris.RegisterListener("LeftCombat", 2, "after", SP_OnCombatLeave)

Ext.Osiris.RegisterListener("RollResult", 6, "after", SP_OnRollResults)
Ext.Osiris.RegisterListener("LevelUnloading", 1, "before", SP_OnBeforeLevelUnloaded)
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", SP_OnStatusApplied)
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", SP_OnItemAdded)
Ext.Osiris.RegisterListener("Died", 1, "before", SP_OnBeforeDeath)
Ext.Osiris.RegisterListener("ShortRested", 1, "after", SP_OnShortRest)
Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", SP_OnLongRest)

Ext.Osiris.RegisterListener("LevelLoaded", 1, "after", SP_OnLevelLoaded)

Ext.Events.SessionLoaded:Subscribe(SP_OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(SP_OnResetCompleted)

-- Lets you config during runtime.
Ext.RegisterConsoleCommand('VoreConfig', VoreConfig);
Ext.RegisterConsoleCommand('VoreConfigOptions', VoreConfigOptions);

Ext.RegisterConsoleCommand("ResetVore", SP_ResetVore);
Ext.RegisterConsoleCommand("KillVore", SP_KillVore);
