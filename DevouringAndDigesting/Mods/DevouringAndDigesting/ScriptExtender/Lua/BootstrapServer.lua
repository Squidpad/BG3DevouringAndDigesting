StatPaths = {
    "Public/DevouringAndDigesting/Stats/Generated/Data/Items/Armor.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Items/Potions.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Items/Items.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Spells/Spells_Projectile.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Spells/Spells_Target.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Spells/Vore_Core_Spell.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Spells/Vore_Core_Regurgitate.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Status/Vore_Core_Status.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Experiments.txt",
    "Public/DevouringAndDigesting/Stats/Generated/Data/Status.txt",
}

Ext.Require("Utils/Utils.lua")
Ext.Require("Utils/VoreUtils.lua")
Ext.Require("Utils/Config.lua")
--Ext.Require("Subclasses/StomachSentinel.lua")

Ext.Vars.RegisterModVariable(ModuleUUID, "VoreData", {});


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
    if VoreData[caster] ~= nil then
        if string.sub(spell, 0, 15) == 'SP_Regurgitate_' then
            if Osi.HasActiveStatus(caster, "SP_RegurgitationCooldown2") ~= 0 then
                return
            end
            local prey = string.sub(spell, 16)
            SP_RegurgitatePrey(caster, prey, 10, '', 'O')
        elseif string.sub(spell, 0, 12) == 'SP_Disposal_' then
            local prey = string.sub(spell, 13)
            SP_RegurgitatePrey(caster, prey, 10, '', 'A')
        elseif string.sub(spell, 0, 8) == 'SP_Come_' then
            local prey = string.sub(spell, 10)
            SP_RegurgitatePrey(caster, prey, 10, '', 'UC')
        elseif string.sub(spell, 0, 10) == 'SP_Absorb_' then
            local prey = string.sub(spell, 11)
            SP_RegurgitatePrey(caster, prey, 1, "Absorb")
        elseif spell == "SP_SwitchToLethal" then
            if VoreData[caster] ~= nil then
                VoreData[caster].DigestItems = true
                for k, v in pairs(VoreData[caster].Prey) do
                    SP_SwitchToDigestionType(caster, k, 0, 2)
                end
                PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
            end
        elseif spell == 'SP_SwallowDown' then
            for k, v in pairs(VoreData[caster].Prey) do
                if VoreData[k].SwallowProcess > 0 then
                    if VoreData[k].Digestion ~= 0 then
                        SP_VoreCheck(caster, k, "SwallowDownCheck")
                    else
                        VoreData[k].SwallowProcess = VoreData[k].SwallowProcess - 1

                        PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
                        if Ext.Debug.IsDeveloperMode then
                            local modvars = GetVoreData()
                            modvars.VoreData = SP_Deepcopy(VoreData)
                        end
                        if VoreData[k].SwallowProcess == 0 then
                            SP_FullySwallow(caster, k)
                        end
                    end
                end
            end
        elseif spell == 'SP_SpeedUpDigestion' then
            if VoreData[caster] ~= nil then
                for k, v in pairs(VoreData[caster].Prey) do
                    if VoreData[k].Digestion == 2 then
                        Osi.ApplyStatus(k, 'SP_SpeedUpDigestion_Status', 0, 1, caster)
                    end
                end
            end
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
    local voreSpellType, voreLocus = SP_GetSpellParams(spell)
    if voreSpellType ~= nil then
        _P(voreSpellType .. voreLocus)
        if Osi.HasActiveStatus(target, "SP_Inedible") == 0 then
            if voreSpellType == 'Endo' then
                if Osi.HasActiveStatus(caster, "SP_RegurgitationCooldown") ~= 0 then
                    return
                end
                if Osi.IsItem(target) == 1 then
                    if Osi.GetCanPickUp(target) == 1 then

                        if SP_CanFitItem(caster, target) then
                            SP_DelayCallTicks(12, function()
                                SP_SwallowItem(caster, target)
                            end)
                        else
                            Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
                        end
                    end
                else
                    if SP_CanFitPrey(caster, target) then
                        SP_DelayCallTicks(12, function()
                            SP_SwallowPrey(caster, target, 0, true, true, voreLocus)
                        end)
                    else
                        Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
                    end
                end
            elseif voreSpellType == 'Lethal' then
                if Osi.HasActiveStatus(caster, "SP_RegurgitationCooldown") ~= 0 then
                    return
                end
                if SP_CanFitPrey(caster, target) then
                    SP_DelayCallTicks(6, function()
                        SP_VoreCheck(caster, target, "SwallowLethalCheck_" .. voreLocus)
                    end)
                else
                    Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
                end
            elseif voreSpellType == 'Bellyport' then
                if Osi.HasActiveStatus(caster, "SP_RegurgitationCooldown") ~= 0 then
                    return
                end
                if SP_CanFitPrey(caster, target) then
                    SP_DelayCallTicks(7, function()
                        SP_VoreCheck(caster, target, "Bellyport_" .. voreLocus)
                    end)
                else
                    Osi.ApplyStatus(caster, "SP_Cant_Fit_Prey", 1, 1, target)
                end
            end
        end
        if voreSpellType == 'Me' then
            if SP_CanFitPrey(target, caster) then
                if Osi.IsAlly(caster, target) == 1 then
                    SP_DelayCallTicks(12, function()
                        SP_SwallowPrey(target, caster, 0, true,  false, voreLocus)
                    end)
                else
                    SP_DelayCallTicks(12, function()
                        SP_SwallowPrey(target, caster, 2, true, false, voreLocus)
                    end)
                end
            end
        end
    elseif string.sub(spell, 1, 3) == 'SP_' then
        if spell == 'SP_Target_Massage_Pred' then
            if VoreData[target] ~= nil then
                Osi.RemoveStatus(target, 'SP_Indigestion')
                for k, v in pairs(VoreData[target].Prey) do
                    if VoreData[k].Digestion == 2 then
                        Osi.ApplyStatus(k, 'SP_MassageAcid', 0, 1, target)
                    end
                end
            end
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
    local eventVoreName = string.sub(eventName, 1, #eventName-2)
    local voreLocus = string.sub(eventName, #eventName)
    if (string.sub(eventVoreName, 1, #eventName-2) == "SwallowLethalCheck" or string.sub(eventName, 1, #eventName-2) == "BellyportSave" ) and (resultType ~= 0 or ConfigVars.VoreDifficulty.value == 'debug') then

        _P('Lethal Swallow Success by ' .. roller)

        SP_SwallowPrey(roller, rollSubject, 2, true, true, voreLocus)

        if ConfigVars.SwitchEndoLethal.value and Osi.HasPassive(roller, 'SP_SoothingStomach') == 0 then
            if voreLocus == 'O' then
                VoreData[roller].DigestItems = true
            end
            for k, v in pairs(VoreData[roller].Prey) do
                if voreLocus == v then
                    SP_SwitchToDigestionType(roller, k, 0, 2)
                end
            end
            PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
            if Ext.Debug.IsDeveloperMode then
                local modvars = GetVoreData()
                modvars.VoreData = SP_Deepcopy(VoreData)
            end
        end
    elseif eventName == "StruggleCheck" and resultType ~= 0 then
        _P('Struggle Success by ' .. roller .. ' against ' .. rollSubject)
        Osi.ApplyStatus(rollSubject, "SP_Indigestion", 1 * SecondsPerTurn)
        if Osi.HasPassive(roller, 'SP_Dense') == 1 then
            Osi.ApplyStatus(rollSubject, "PRONE", 1 * SecondsPerTurn, 1, roller)
        end
        if Osi.GetStatusTurns(rollSubject, "SP_Indigestion") >= 6 then
            Osi.RemoveStatus(rollSubject, "SP_Indigestion")
			-- evey prey will be regurgitated
            SP_RegurgitatePrey(rollSubject, "All", 0, "", voreLocus)
        end
    elseif eventName == "SwallowDownCheck" then
        if resultType ~= 0 then
            VoreData[rollSubject].SwallowProcess = VoreData[rollSubject].SwallowProcess - 1
            if VoreData[rollSubject].SwallowProcess == 0 then
                SP_FullySwallow(roller, rollSubject)
            end
        else
            SP_RegurgitatePrey(roller, rollSubject, -1)
        end
    end
end


---digests a random item in pred's inventory
---@param pred CHARACTER
function SP_DigestItem(pred)
    if not ConfigVars.DigestItems.value then
        return
    end
    -- the chance of an item being digested is 1/3 per Digestion tick
    if VoreData[pred].Items == nil and Osi.Random(3) ~= 1 then
        return
    end
    
    local itemList = Ext.Entity.Get(VoreData[pred].Items).InventoryOwner.PrimaryInventory:GetAllComponents()
                                 .InventoryContainer.Items
    for k, v in pairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
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
        --Randomly start digesting prey because of hunger
        local lethalRandomSwitch = false
        if ConfigVars.Hunger.value then
            local hungerStacks = Osi.GetStatusTurns(object, "SP_Hunger")
            if hungerStacks >= ConfigVars.HungerBreakpoint1.value then
                if hungerStacks >=  ConfigVars.HungerBreakpoint3.value then
                    lethalRandomSwitch = true
                elseif hungerStacks >= ConfigVars.HungerBreakpoint2.value then
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
        for k, v in pairs(VoreData[object].Prey) do
            --local predData = Ext.Entity.Get(object).Transform.Transform.Translate
			if VoreData[k].Digestion ~= 1 and (ConfigVars.TeleportPrey.value == true or VoreData[k].Combat ~= "") then
                -- I have no idea how to teleport prey to the exact same position as pred, not just near them
                local predX, predY, predZ = Osi.GetPosition(object)
				Osi.TeleportToPosition(k, predX, predY, predZ, "", 0, 0, 0, 0, 0)
            end
            if lethalRandomSwitch and ConfigVars.LethalRandomSwitch.value then
                _P("Random lethal switch")
                SP_SwitchToDigestionType(object, k, 0, 2)
            end
        end
        if lethalRandomSwitch and ConfigVars.LethalRandomSwitch.value then
            VoreData[object].DigestItems = true
        end
        if VoreData[object].DigestItems and VoreData[object].Items ~= "" then
            SP_DigestItem(object)
        end
    -- elseif status == "SP_Pacifist_Applicator" then
    --     _P("Applied " .. status .. " Status to " .. object .. " and the causee was " .. causee)
    --     SP_DelayCallTicks(10, function()
    --         if VoreData[causee] ~= nil and next(VoreData[causee].Prey) ~= nil then
    --             for prey, _ in pairs(VoreData[causee].Prey) do
    --                 Osi.ApplyStatus(prey, "SP_Pacifist", -1, 1, object)
    --             end
    --         end
    --     end
    --     )
    elseif status == 'SP_Item_Bound' then
        _P("Applied " .. status .. " Status to " .. object)
    elseif status == 'SP_Struggle' then
        _P("Applied " .. status .. " Status to " .. object .. " and the causee was " .. causee)
        if Osi.HasPassive(VoreData[object].Pred, 'SP_BoilingInsides') == 1 then
            Osi.ApplyStatus(object, "SP_BoilingInsidesAcid", 0, 1, VoreData[object].Pred)
        end
        if ConfigVars.SwitchEndoLethal.value and Osi.HasPassive(VoreData[object].Pred, 'SP_SoothingStomach') == 0 then
            local pred = VoreData[object].Pred
            if VoreData[object].Locus == 'O' then
                VoreData[pred].DigestItems = true
            end
            for k, v in pairs(VoreData[pred].Prey) do
                if VoreData[object].Locus == v then
                    SP_SwitchToDigestionType(pred, k, 0, 2)
                end
            end
            PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
            if Ext.Debug.IsDeveloperMode then
                local modvars = GetVoreData()
                modvars.VoreData = SP_Deepcopy(VoreData)
            end
        end
        SP_VoreCheck(VoreData[object].Pred, object, "StruggleCheck")
    end
end


---to avoid checking every status and improve performance
---@param character CHARACTER
---@param item ITEM
---@param sucess integer
function SP_ItemUsed(character, item, sucess)
    if string.sub(item, 1, 3) == 'SP_' then
        local template = Osi.GetTemplate(item)
        -- item name + map key
        if template == 'SP_PotionOfGluttony_O_d2d6a43b-3413-4efd-928f-d15e2ad9e38d' and
        Osi.GetStatusTurns(character, "SP_PotionOfGluttony_Status_O") > 1 then
            Osi.RemoveStatus(character, "SP_PotionOfGluttony_Status_O", "")

        elseif template == 'SP_PotionOfGluttony_f3914e54-2c48-426a-a338-8e1c86ebc7be' and
        Osi.GetStatusTurns(character, "SP_PotionOfGluttony_Status") > 1 then
            Osi.RemoveStatus(character, "SP_PotionOfGluttony_Status", "")

        elseif template == 'SP_PotionOfPrey_02ee5321-7bcd-4712-ba06-89eb1850c2e4' and
        Osi.GetStatusTurns(character, "SP_PotionOfPrey_Status") > 1 then
            Osi.RemoveStatus(character, "SP_PotionOfPrey_Status", "")

        elseif template == 'SP_PotionOfInedibility_319379c2-3627-4c26-b14d-3ce8abb676c3' and
        Osi.GetStatusTurns(character, "SP_Inedible") > 1 then
            Osi.RemoveStatus(character, "SP_Inedible", "")
        end
    end
end


---Runs each time a status is removed.
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee GUIDSTRING? Thing that caused status to be applied.
---@param storyActionID integer?
function SP_OnStatusRemoved(object, status, causee, storyActionID)
    -- regurgitates prey it they are not fully swallowed
    if status == 'SP_PartiallySwallowed' or status == 'SP_PartiallySwallowedGentle' then
        if VoreData[object] ~= nil then
            if VoreData[object].Pred ~= nil and VoreData[object].SwallowProcess > 0 then
                VoreData[object].SwallowProcess = 0
                SP_RegurgitatePrey(VoreData[object].Pred, object, -1)
            end
        end
    end
end



---Runs when character enters combat
---@param object GUIDSTRING
---@param combatGuid GUIDSTRING
function SP_OnCombatEnter(object, combatGuid)
    if VoreData[object] ~= nil then
        VoreData[object].Combat = combatGuid
        PersistentVars['VoreData'][object].Combat = combatGuid
        if Ext.Debug.IsDeveloperMode then
            local modvars = GetVoreData()
            modvars.VoreData = SP_Deepcopy(VoreData)
        end
    end
end

---Runs when character leaves combat
---@param object GUIDSTRING
---@param combatGuid GUIDSTRING
function SP_OnCombatLeave(object, combatGuid)
    if VoreData[object] ~= nil then
        VoreData[object].Combat = ""
        PersistentVars['VoreData'][object].Combat = ""
        if Ext.Debug.IsDeveloperMode then
            local modvars = GetVoreData()
            modvars.VoreData = SP_Deepcopy(VoreData)
        end
    end
end

---Runs when someone dies.
---@param character CHARACTER
function SP_OnBeforeDeath(character)
    if VoreData[character] ~= nil then
        -- If character was pred.
        VoreData[character].Fat = 0
        VoreData[character].Satiation = 0
        if VoreData[character].Pred ~= nil then
            VoreData[VoreData[character].Pred].AddWeight = VoreData[VoreData[character].Pred].AddWeight +
             VoreData[character].AddWeight
        end
        VoreData[character].AddWeight = 0
        if next(VoreData[character].Prey) ~= nil then
            _P(character .. " was pred and DIED")
            SP_RegurgitatePrey(character, 'All', -1)
        end
        -- If character was prey (both can be true at the same time)
        if VoreData[character] ~= nil and VoreData[character].Pred ~= nil then
            local pred = VoreData[character].Pred
            VoreData[character].Digestion = 1
            if VoreData[character].Locus == 'O' then
                SP_SwitchToLocus(pred, character, 'A')
            end
            _P(character .. " was digested by " .. pred .. " and DIED")
            -- Temp characters' corpses are not saved is save file, so they might cause issues unless disposed of on death.
            if Ext.Entity.Get(character).ServerCharacter.Temporary == true then
                _P("Absorbing temp character")
                SP_DelayCallTicks(15, function()
                    SP_RegurgitatePrey(pred, character, -1, "Absorb", VoreData[character].Locus)
                end)
            else
                SP_SwitchToDigestionType(pred, character, 1, 1)
                -- Digested but not released prey will be stored out of bounds.
                -- investigate if teleporting char out of bounds and reloading breaks them
                Osi.TeleportToPosition(character, -100000, 0, -100000, "", 0, 0, 0, 1, 0)
                -- Implementation for fast digestion.
                if ConfigVars.SlowDigestion.value == false then
                    local preyWeightDiff = VoreData[character].Weight - VoreData[character].FixedWeight // 5

                    if ConfigVars.WeightGain.value then
                        VoreData[pred].Fat = VoreData[pred].Fat + preyWeightDiff // ConfigVars.WeightGainRate.value
                    end

                    if ConfigVars.Hunger.value and Osi.IsPartyMember(pred, 0) == 1  and
                    (Osi.IsTagged(character, "f6fd70e6-73d3-4a12-a77e-f24f30b3b424") == 0 and
                    Osi.IsTagged(character, "196351e2-ff25-4e2b-8560-222ac6b94a54") == 0 and
                    Osi.IsTagged(character, "33c625aa-6982-4c27-904f-e47029a9b140") == 0 or
                     Osi.HasPassive(pred, "SP_BoilingInsides") == 1) then
                        VoreData[pred].Satiation = VoreData[pred].Satiation + preyWeightDiff // ConfigVars.HungerSatiationRate.value
                    end
                    
                    SP_DelayCallTicks(10, function()
                        SP_ReduceWeightRecursive(character, preyWeightDiff, true)
                    end)
                end
            end
        end
        PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
        if Ext.Debug.IsDeveloperMode then
            local modvars = GetVoreData()
            modvars.VoreData = SP_Deepcopy(VoreData)
        end
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

    --Osi.IteratePlayerCharacters("HungerCalculateShort", "")
    SP_HungerSystem(ConfigVars.HungerShort.value, false)

    
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
    _D(VoreData)
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

    SP_HungerSystem(ConfigVars.HungerLong.value, true)
    PersistentVars['VoreData'] = SP_Deepcopy(VoreData)
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
    _D(VoreData)

end


---hunger system
---@param stacks integer how much hunger stacks to add
---@param isLong boolean is long rest
function SP_HungerSystem(stacks, isLong)
    -- hunger system
    if not ConfigVars.Hunger.value then
        return
    end
    local party = Ext.Entity.Get(Osi.GetHostCharacter()).PartyMember.Party.PartyView.Characters

    for k, v in pairs(party) do
        local predData = v:GetAllComponents()
        local pred = predData.ServerCharacter.Template.Name .. "_" .. predData.Uuid.EntityUuid
        local hungerStacks = stacks + Osi.GetStatusTurns(pred, "SP_Hunger")
        local newhungerStacks = hungerStacks
        if VoreData[pred] ~= nil then
            local satiationDiff = VoreData[pred].Satiation // ConfigVars.HungerSatiation.value
            newhungerStacks = hungerStacks - satiationDiff
            if newhungerStacks > 0 then
                VoreData[pred].Satiation = VoreData[pred].Satiation - satiationDiff * ConfigVars.HungerSatiation.value
            else
                VoreData[pred].Satiation = VoreData[pred].Satiation - hungerStacks * ConfigVars.HungerSatiation.value
                newhungerStacks = 0
            end
        end 
        if Osi.IsTagged(pred, 'f7265d55-e88e-429e-88df-93f8e41c821c') == 1 then
            Osi.RemoveStatus(pred, 'SP_Hunger')
            Osi.RemoveStatus(pred, 'SP_HungerStage3')
            Osi.RemoveStatus(pred, 'SP_HungerStage2')
            Osi.RemoveStatus(pred, 'SP_HungerStage1')
            if newhungerStacks > 0 then
                Osi.ApplyStatus(pred, 'SP_Hunger', newhungerStacks * SecondsPerTurn, 1)
                -- random switch to lethal
                local lethalRandomSwitch = false
                if newhungerStacks >= ConfigVars.HungerBreakpoint3.value then
                    lethalRandomSwitch = true
                    Osi.ApplyStatus(pred, 'SP_HungerStage3', -1, 1)
                elseif newhungerStacks >= ConfigVars.HungerBreakpoint2.value then
                    Osi.ApplyStatus(pred, 'SP_HungerStage2', -1, 1)
                    if (not isLong and Osi.Random(2) == 1) or (isLong and Osi.Random(3) ~= 1) then
                        lethalRandomSwitch = true
                    end
                elseif newhungerStacks >= ConfigVars.HungerBreakpoint1.value then
                    Osi.ApplyStatus(pred, 'SP_HungerStage1', -1, 1)
                    if (not isLong and Osi.Random(3) == 1) or (isLong and Osi.Random(2) == 1) then
                        lethalRandomSwitch = true
                    end
                end

                --Randomly start digesting prey because of hunger
                if VoreData[pred] ~= nil and lethalRandomSwitch then
                    for i, j in pairs(VoreData[pred].Prey) do
                        if ConfigVars.LethalRandomSwitch.value then
                            _P("Random lethal switch")
                            SP_SwitchToDigestionType(pred, i, 0, 2)
                            -- prey is digested if the switch happens during long rest
                            if isLong then
                                Osi.ApplyDamage(i, 100, "Acid", pred)
                            end
                        end
                    end
                    if ConfigVars.LethalRandomSwitch.value then
                        VoreData[pred].DigestItems = true
                    end
                end
            end
        end
        
    end
end

---Runs on session load
function SP_OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
	SP_GetConfigFromFile()
    if PersistentVars['VoreData'] == nil then	
        PersistentVars['VoreData'] = {}
        if Ext.Debug.IsDeveloperMode then
            local modvars = GetVoreData()
            modvars.VoreData = {}
        end
    else
        VoreData = SP_Deepcopy(PersistentVars['VoreData'])
        if Ext.Debug.IsDeveloperMode then
            local modvars = GetVoreData()
            modvars.VoreData = SP_Deepcopy(VoreData)
        end
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
    VoreData = SP_Deepcopy(PersistentVars['VoreData'])
    SP_CheckVoreData()
    

    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
end

---Runs when reset command is sent to console.
function SP_OnResetCompleted()
    for _, statPath in ipairs(StatPaths) do
        _P(statPath)
        ---@diagnostic disable-next-line: undefined-field
        Ext.Stats.LoadStatsFile(statPath, 1)
    end
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        VoreData = modvars.VoreData
        PersistentVars['VoreData'] = VoreData
    end
    _P('Reloading stats!')
end

function GetVoreData()
    local modvars = Ext.Vars.GetModVariables(ModuleUUID);
    if modvars.VoreData == nil then
        modvars.VoreData = {};
    end
    return modvars
end

---Runs whenever you change game regions.
---@param level string? Name of new game region.
function SP_OnBeforeLevelUnloaded(level)
    _P('LEVEL CHANGE')
    _D(level)
    _P('Level changed to ' .. level)

    for k, v in pairs(VoreData) do
        if next(v.Prey) ~= nil then
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
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = SP_Deepcopy(VoreData)
    end
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
            v.Satiation = 0
            SP_UpdateWeight(k)
        end
        SP_DelayCallTicks(10, function()
            VoreData = {}
            PersistentVars['VoreData'] = {}
            if Ext.Debug.IsDeveloperMode then
                local modvars = GetVoreData()
                modvars.VoreData = SP_Deepcopy(VoreData)
            end
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
	PersistentVars['VoreData'] = nil
    if Ext.Debug.IsDeveloperMode then
        local modvars = GetVoreData()
        modvars.VoreData = nil
    end
end

-- deletes every vore-related variable and possibly fixed broken saves
function SP_GiveMeVore()
    local player = Osi.GetHostCharacter()
    Osi.TemplateAddTo('d2d6a43b-3413-4efd-928f-d15e2ad9e38d', player, 1)
    Osi.TemplateAddTo('91cb93c0-0e07-4b3a-a1e9-a836585146a9', player, 1)
    Osi.TemplateAddTo('f3914e54-2c48-426a-a338-8e1c86ebc7be', player, 1)
    Osi.TemplateAddTo('02ee5321-7bcd-4712-ba06-89eb1850c2e4', player, 1)
    Osi.TemplateAddTo('319379c2-3627-4c26-b14d-3ce8abb676c3', player, 1)
end


function SP_DebugVore()
    local player = Osi.GetHostCharacter()
    Osi.SetLevel(player, 4)
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
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", SP_OnStatusRemoved)
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", SP_OnItemAdded)
Ext.Osiris.RegisterListener("Died", 1, "before", SP_OnBeforeDeath)
Ext.Osiris.RegisterListener("ShortRested", 1, "after", SP_OnShortRest)
Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", SP_OnLongRest)
--Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", SP_SpellCastAtPosition)

Ext.Osiris.RegisterListener("UseFinished", 3, "after", SP_ItemUsed)

Ext.Osiris.RegisterListener("LevelLoaded", 1, "after", SP_OnLevelLoaded)

Ext.Events.SessionLoaded:Subscribe(SP_OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(SP_OnResetCompleted)

-- Lets you config during runtime.
Ext.RegisterConsoleCommand('VoreConfig', VoreConfig);
Ext.RegisterConsoleCommand('VoreConfigOptions', VoreConfigOptions);

Ext.RegisterConsoleCommand("ResetVore", SP_ResetVore);
Ext.RegisterConsoleCommand("KillVore", SP_KillVore);
Ext.RegisterConsoleCommand("GiveMeVore", SP_GiveMeVore);
Ext.RegisterConsoleCommand("DebugVore", SP_DebugVore);
