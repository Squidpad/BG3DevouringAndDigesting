local statFiles = {
    "Potions.txt",
    "Items.txt",
    "Spells_Projectile.txt",
    "Spells_Target.txt",
    "Spell_Vore_Core.txt",
    "Regurgitate_Vore_Core.txt",
    "Status_Vore_Core.txt",
    "Passive_Status_Vore_Core.txt",
    "Debug.txt",
    "Status_Spells.txt",
    "Status_Spells.txt",
    "Passive.txt",
    "Armor.txt",
}

local modPath = "Public/DevouringAndDigesting/Stats/Generated/Data/"



Ext.Require("Utils/Output.lua")
Ext.Require("Utils/Utils.lua")
Ext.Require("Utils/EventUtils.lua")
Ext.Require("Utils/VoreUtils.lua")
Ext.Require("Utils/Config.lua")
Ext.Require("Utils/Migrations/ConfigMigrations.lua")
Ext.Require("Utils/Migrations/PersistentVarsMigrations.lua")
Ext.Require("Utils/TableData.lua")
Ext.Require("Utils/RaceTable.lua")
Ext.Require("Utils/DCTable.lua")
Ext.Require("Utils/ExtEvents.lua")

--this script is missing
Ext.Require("Subclasses/StomachSentinel.lua")

Ext.Vars.RegisterModVariable(ModuleUUID, "ModVoreData", {})



PersistentVars = {}

CalculateRest = true

---Triggers on spell cast.
---@param caster CHARACTER
---@param spell string
---@param spellType string
---@param spellElement string Like fire, lightning, etc I think.
---@param storyActionID integer
function SP_OnSpellCast(caster, spell, spellType, spellElement, storyActionID)
    if string.sub(spell, 1, 3) ~= 'SP_' then
        return
    end
    if VoreData[caster] ~= nil then
        if string.sub(spell, 0, 15) == 'SP_Regurgitate_' then
            if Osi.HasActiveStatus(caster, "SP_RegurgitationCooldown2") ~= 0 or
            Osi.HasActiveStatus(caster, "SP_SC_BlockVoreTotal") ~= 0 then
                return
            end
            local prey = string.sub(spell, 16)
            SP_RegurgitatePrey(caster, prey, 10, '', 'O')
        elseif string.sub(spell, 0, 12) == 'SP_Disposal_' then
            if Osi.HasActiveStatus(caster, "SP_SC_BlockVoreTotal") ~= 0 then
                return
            end
            local prey = string.sub(spell, 13)
            SP_RegurgitatePrey(caster, prey, 10, '', 'A')
        elseif string.sub(spell, 0, 11) == 'SP_Release_' then
            if Osi.HasActiveStatus(caster, "SP_SC_BlockVoreTotal") ~= 0 then
                return
            end
            local locus = string.sub(spell, 12, 12)
            local prey = string.sub(spell, 14)
            SP_RegurgitatePrey(caster, prey, 10, '', locus)
        elseif string.sub(spell, 0, 10) == 'SP_Absorb_' then
            local prey = string.sub(spell, 11)
            SP_RegurgitatePrey(caster, prey, 1, "Absorb")
        elseif string.sub(spell, 0, 18) == "SP_SwitchToLethal_" then
            if VoreData[caster] ~= nil then
                local locus = string.sub(spell, 19)
                if locus == "O" or locus == "All" then
                    VoreData[caster].DigestItems = true
                end
                for k, v in pairs(VoreData[caster].Prey) do
                    if locus == v or locus == "All" then
                        SP_SwitchToDigestionType(caster, k, 0, 2)
                    end
                end
            end
        elseif spell == 'SP_SwallowDown' then
            for k, v in pairs(VoreData[caster].Prey) do
                if VoreData[k].SwallowProcess > 0 then
                    if VoreData[k].Digestion ~= 0 then
                        SP_VoreCheck(caster, k, "SwallowDownCheck")
                    else
                        VoreData[k].SwallowProcess = VoreData[k].SwallowProcess - 1

                        if VoreData[k].SwallowProcess == 0 then
                            SP_FullySwallow(caster, k)
                        end
                    end
                end
            end
            -- deal small amount of damage to prey
        elseif spell == 'SP_SpeedUpDigestion' then
            if VoreData[caster] ~= nil then
                for k, v in pairs(VoreData[caster].Prey) do
                    if VoreData[k].Digestion == 2 then
                        Osi.ApplyStatus(k, 'SP_SpeedUpDigestion_Status', 0, 1, caster)
                    end
                end
            end
            -- ask pred to release me
        elseif spell == 'SP_ReleaseMe' then
            if VoreData[caster].Pred ~= "" then
                --SP_RegurgitatePrey(VoreData[caster].Pred, caster, 0)
                SP_VoreCheck(VoreData[caster].Pred, caster, "ReleaseMeCheck")
            end
        elseif spell == 'SP_SC_BoundPrey_Spell' then
            if VoreData[caster] ~= nil then
                for k, v in pairs(VoreData[caster].Prey) do
                    if Osi.IsAlly(caster, k) == 1 and VoreData[k].Digestion == 0 then
                        Osi.ApplyStatus(caster, "SP_SC_BoundPrey_Pred", -1, 1, k)
                        Osi.ApplyStatus(k, "SP_SC_BoundPrey_Prey", -1, 1, caster)

                        Osi.ApplyStatus(caster, "SP_SC_BlockVoreTotal", -1, 1, k)
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
---@param spellType? string
---@param spellElement? string Like fire, lightning, etc I think.
---@param storyActionID? integer
function SP_OnSpellCastTarget(caster, target, spell, spellType, spellElement, storyActionID)
    if string.sub(spell, 1, 10) ~= 'SP_Target_' then
        return
    end
    local locus = string.sub(spell, -1)
    spell = string.sub(spell, 11)
    -- main vore spell
    if string.sub(spell, 1, 8) == 'Swallow_' then
        _P("Swallowing")
        spell = string.sub(spell, 9)
        -- if pred can swallow prey
        if not SP_VorePossible(caster, target) then
            _P("Can't vore")
            return
        end
        -- ai vore cooldown
        local cooldown = ConfigVars.NPCVore.CooldownMax.value - ConfigVars.NPCVore.CooldownMin.value + 1
            cooldown = Osi.Random(cooldown) + ConfigVars.NPCVore.CooldownMin.value
        Osi.ApplyStatus(caster, "SP_AI_HELPER_BLOCKVORE", SecondsPerTurn * cooldown, 1, caster)
        -- vore check end
        -- spell type check
        if string.sub(spell, 1, 4) == 'Endo' then
            if Osi.IsItem(target) == 1 then
                SP_DelayCallTicks(12, function ()
                    SP_SwallowItem(caster, target)
                end)
            else
                if Osi.IsAlly(caster, target) == 1 then
                    SP_DelayCallTicks(12, function ()
                        SP_SwallowPrey(caster, target, 0, true, true, locus)
                    end)
                else
                    SP_DelayCallTicks(6, function ()
                        SP_VoreCheck(caster, target, "SwallowCheck_Endo_" .. locus)
                    end)
                end
            end
        elseif string.sub(spell, 1, 6) == 'Lethal' then
            if Osi.IsItem(target) == 1 then
                SP_DelayCallTicks(12, function ()
                    SP_SwallowItem(caster, target)
                    VoreData[caster].DigestItems = true
                end)
            else
                SP_DelayCallTicks(6, function ()
                    SP_VoreCheck(caster, target, "SwallowCheck_Lethal_" .. locus)
                end)
            end
        end
    -- other swallow-related spells
    elseif string.sub(spell, 1, 21) == "Bellyport_Destination" then
        local predData = Ext.Entity.Get(caster)
        local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight) /
            1000
        local preyTable = {}
        for prey, v in pairs(VoreData[caster].SpellTargets) do
            if v == "Bellyport" then
                if Osi.IsCharacter(prey) == 1 and Osi.HasActiveStatus(prey, "SP_Hit_Bellyport") == 1 then
                    -- this will teleport the exact amount of prey that fit inside pred
                    if (SP_GetTotalCharacterWeight(prey) <= predRoom or
                            ConfigVars.Mechanics.AllowOverstuffing.value) and SP_VorePossible(target, prey) then
                        predRoom = predRoom - SP_GetTotalCharacterWeight(prey)
                        table.insert(preyTable, prey)
                    end
                end
                Osi.RemoveStatus(prey, "SP_Hit_Bellyport")
                VoreData[caster].SpellTargets[prey] = nil
            end
        end
        SP_DelayCallTicks(5, function ()
            if #preyTable > 0 then
                SP_SwallowPreyMultiple(target, preyTable, 2, true, false, locus)
            end
            Osi.RemoveSpell(caster, "SP_Target_Bellyport_Destination")
        end)
    -- swallow me spells
    elseif string.sub(spell, 1, 8) == 'Offer_Me' then
        -- prey should not target their preds
        if VoreData[caster] ~= nil and VoreData[caster].Pred == target then
            return
        end
        if not SP_VorePossible(target, caster) then
            return
        end 
        if Osi.IsAlly(caster, target) == 1 then
            SP_DelayCallTicks(12, function ()
                SP_SwallowPrey(target, caster, 0, true, false, locus)
            end)
        else
            SP_DelayCallTicks(12, function ()
                SP_SwallowPrey(target, caster, 2, true, false, locus)
            end)
        end
    -- non swallow-related spells
    else
        if spell == 'Massage_Pred' then
            if VoreData[target] ~= nil then
                Osi.RemoveStatus(target, 'SP_Indigestion')
                for k, v in pairs(VoreData[target].Prey) do
                    if VoreData[k].Digestion == 2 then
                        Osi.ApplyStatus(k, 'SP_MassageAcid', 0, 1, target)
                    end
                end
            end
        elseif spell == 'AssignNPCPred' then
            _P(target)
            if Osi.HasPassive(target, "SP_BlockGluttony") == 1 then
                _P("Was prey")
                Osi.RemovePassive(target, "SP_BlockGluttony")
            end
            if Ext.Entity.Get(target).ServerCharacter.Temporary == false then
                Osi.AddPassive(target, "SP_Gluttony")
            end
        elseif spell == 'AssignNPCPrey' then
            _P(target)
            if Osi.HasPassive(target, "SP_Gluttony") == 1 then
                _P("Was predator")
                Osi.RemovePassive(target, "SP_Gluttony")
            end
            if Ext.Entity.Get(target).ServerCharacter.Temporary == false then
                Osi.AddPassive(target, "SP_BlockGluttony")
            end
        elseif spell == 'Acidify' then
            if VoreData[caster] ~= nil then
                for k, v in pairs(VoreData[caster].Prey) do
                    if VoreData[k].Digestion == 2 then
                        Osi.ApplyStatus(k, 'SP_Acidify_Status', 0, 1, caster)
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
---@param isActiveRoll? integer Whether or not the rolling GUI popped up. 0 == no, 1 == yes.
---@param criticality? CRITICALITYTYPE Whether or not it was a crit and what kind. 0 == no crit, 1 == crit success, 2 == crit fail.
function SP_OnRollResults(eventName, roller, rollSubject, resultType, isActiveRoll, criticality)
    if string.sub(eventName, 1, 20) == 'SwallowCheck_Lethal_' and (resultType ~= 0 or ConfigVars.Mechanics.VoreDifficulty.value == 'cheat') then
        _P('Lethal Swallow Success by ' .. roller)
        local voreLocus = string.sub(eventName, -1)
        SP_SwallowPrey(roller, rollSubject, 2, true, true, voreLocus)

        if ConfigVars.Mechanics.SwitchEndoLethal.value and Osi.HasPassive(roller, 'SP_MuscleControl') == 0 then
            if voreLocus == 'O' then
                VoreData[roller].DigestItems = true
            end
            for k, v in pairs(VoreData[roller].Prey) do
                if voreLocus == v then
                    SP_SwitchToDigestionType(roller, k, 0, 2)
                end
            end
        end
    elseif string.sub(eventName, 1, 18) == 'SwallowCheck_Endo_' and (resultType ~= 0 or ConfigVars.Mechanics.VoreDifficulty.value == 'cheat') then
        _P('Endo Swallow Success by ' .. roller)
        local voreLocus = string.sub(eventName, -1)
        SP_SwallowPrey(roller, rollSubject, 0, true, true, voreLocus)
    elseif eventName == "StruggleCheck" and resultType ~= 0 then
        _P('Struggle Success by ' .. roller .. ' against ' .. rollSubject)
        _P("rollresult: " .. tostring(resultType))
        -- Warlock passive
        if Osi.HasPassive(rollSubject, "SP_SC_Inescapable") == 0 then
            Osi.ApplyStatus(rollSubject, "SP_Indigestion", 1 * SecondsPerTurn)
        end
        if Osi.HasPassive(roller, 'SP_Dense') == 1 then
            Osi.ApplyStatus(rollSubject, "PRONE", 1 * SecondsPerTurn, 1, roller)
        end
        if Osi.GetStatusTurns(rollSubject, "SP_Indigestion") >= 5 then
            Osi.RemoveStatus(rollSubject, "SP_Indigestion")
            -- evey prey will be regurgitated
            SP_RegurgitatePrey(rollSubject, "All", 0, "", VoreData[roller].Locus)
            -- preds will not try to vore anyone after forced regurgitation
            Osi.ApplyStatus(rollSubject, "SP_AI_HELPER_BLOCKVORE", SecondsPerTurn * 10, 1, rollSubject)
        end
    elseif eventName == "SwallowDownCheck" then
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
                Osi.RemoveSpell(roller, 'SP_SwallowDown')
            end
            SP_RegurgitatePrey(roller, rollSubject, -1)
        end
    elseif eventName == "ReleaseMeCheck" then
        _P("event: " .. eventName)
        _P("rollresult: " .. tostring(resultType))
        if resultType == 0 and VoreData[roller] ~= nil and VoreData[rollSubject] ~= nil then
            -- add animation here
            SP_RegurgitatePrey(roller, "All", 0, "", VoreData[rollSubject].Locus)
        end
    end
end

---digests a random item in pred's inventory
---@param pred CHARACTER
function SP_DigestItem(pred)
    if not ConfigVars.Digestion.DigestItems.value then
        return
    end
    -- the chance of an item being digested is 1/10 per Digestion tick
    if VoreData[pred].Items == "" and Osi.Random(10) ~= 1 then
        return
    end

    local itemList = Ext.Entity.Get(VoreData[pred].Items).InventoryOwner.PrimaryInventory:GetAllComponents()
        .InventoryContainer.Items
    local i = 0
    for k, v in pairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
        i = i + 1
        if Osi.IsStoryItem(uuid) == 0 and Osi.IsTagged(uuid, '983087c8-c9d3-4a87-bc69-65f9329666c8') == 0 and
            Osi.IsTagged(uuid, '7b96246c-54ba-43ea-b01d-4e0b20ad35f1') == 0 then
            _P("item" .. uuid)
            if Osi.IsConsumable(uuid) == 1 then
                Osi.Use(pred, uuid, "")
            else
                VoreData[pred].AddWeight = VoreData[pred].AddWeight + Ext.Entity.Get(uuid).Data.Weight // 1000
                Osi.RequestDelete(uuid)
                Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', VoreData[pred].Items, 1, 0)
                SP_UpdateWeight(pred, true)
            end
            return
        end
    end
    -- removes empty stomach item
    if i == 0 then
        Osi.RequestDelete(VoreData[pred].Items)
        VoreData[pred].Items = ""
        Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)
    end
end

---Runs each time a status is applied.
---@param object CHARACTER Recipient of status.
---@param status string Internal name of status.
---@param causee GUIDSTRING Thing that caused status to be applied.
---@param storyActionID? integer
function SP_OnStatusApplied(object, status, causee, storyActionID)
    if string.sub(status, 1, 3) ~= 'SP_' then
        return
    end
    if status == 'SP_Digesting' then
        --Randomly start digesting prey because of hunger
        local lethalRandomSwitch = false
        if VoreData[object] == nil then
            return
        end
        if ConfigVars.Hunger.Hunger.value then
            local hungerStacks = Osi.GetStatusTurns(object, "SP_Hunger")
            if hungerStacks >= ConfigVars.Hunger.HungerBreakpoint1.value then
                if hungerStacks >= ConfigVars.Hunger.HungerBreakpoint3.value then
                    lethalRandomSwitch = true
                elseif hungerStacks >= ConfigVars.Hunger.HungerBreakpoint2.value then
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
            if VoreData[k].Digestion ~= 1 and (ConfigVars.Debug.TeleportPrey.value == true or VoreData[k].Combat ~= "") then
                local predX, predY, predZ = Osi.GetPosition(object)
                Osi.TeleportToPosition(k, predX, predY, predZ, "", 0, 0, 0, 0, 0)
            end
            if lethalRandomSwitch and ConfigVars.Hunger.LethalRandomSwitch.value then
                _P("Random lethal switch")
                SP_SwitchToDigestionType(object, k, 0, 2)
            end
        end
        if lethalRandomSwitch and ConfigVars.Hunger.LethalRandomSwitch.value then
            VoreData[object].DigestItems = true
        end
        if VoreData[object].DigestItems and VoreData[object].Items ~= "" then
            SP_DigestItem(object)
        end
        SP_PlayGurgle(object)
        --add random role to characters around host
    elseif status == "SP_ROLESELECTOR_AURA" then
        SP_AssignRoleRandom(object)
    elseif status == 'SP_Struggle' then
        if VoreData[object] == nil or VoreData[object].Pred == "" then
            return
        end
        if Osi.HasPassive(VoreData[object].Pred, 'SP_BoilingInsides') == 1 then
            Osi.ApplyStatus(object, "SP_BoilingInsidesAcid", 0, 1, VoreData[object].Pred)
        end
        if ConfigVars.Mechanics.SwitchEndoLethal.value and Osi.HasPassive(VoreData[object].Pred, 'SP_MuscleControl') == 0 then
            local pred = VoreData[object].Pred
            if VoreData[object].Locus == 'O' then
                VoreData[pred].DigestItems = true
            end
            for k, v in pairs(VoreData[pred].Prey) do
                if VoreData[object].Locus == v then
                    SP_SwitchToDigestionType(pred, k, 0, 2)
                end
            end
        end
        SP_VoreCheck(VoreData[object].Pred, object, "StruggleCheck")
    elseif status == "SP_Hit_Bellyport" then
        local pred = SP_CharacterFromGUID(causee)
        if VoreData[pred] == nil then
            SP_VoreDataEntry(pred, true)
        end
        VoreData[pred].SpellTargets[object] = "Bellyport"
        Osi.AddSpell(pred, "SP_Target_Bellyport_Destination")
    elseif status == 'SP_BellySlamStatus' then
        -- causee is a uuid not a guidstring so we need to convert it
        local pred = SP_CharacterFromGUID(causee)
        if VoreData[pred] ~= nil then
            local damage = 0
            for _ = 1, SP_Clamp(VoreData[pred].StuffedStacks * (Osi.GetLevel(pred) // 5 + 1), 1, 3) do
                damage = damage + (Osi.Random(8) + 1)
            end
            Osi.ApplyDamage(object, damage, "Bludgeoning", pred)
        end
    elseif status == 'SP_BellyCompressed' then
        if VoreData[object] ~= nil then
            SP_UpdateWeight(object)
        end
    elseif string.sub(status, 0, 20) == 'SP_HealingAcid_Tick_' then
        _P("Healing Acid Tick")
        local locus = string.sub(status, 21)
        if VoreData[object] ~= nil then
            for k, v in pairs(VoreData[object].Prey) do
                if v == locus then
                    SP_SwitchToDigestionType(object, k, 2, 0)
                    Osi.ApplyStatus(k, "SP_HealingAcid_RegainHP", 1, 1, object)
                end
            end
            if locus == "O" then
                VoreData[object].DigestItems = false
            end
        end
    end
end

---@param character CHARACTER
---@param item ITEM
---@param success integer
function SP_ItemUsed(character, item, success)
    if string.sub(item, 1, 3) == 'SP_' then
        local template = Osi.GetTemplate(item)
        _P(template)
        -- item name + map key
        if template == 'SP_PotionOfAnalVore_04987160-cb88-4d3e-b219-1843e5253d51' then
            if Osi.HasPassive(character, "SP_CanAnalVore") == 0 then
                Osi.AddPassive(character, "SP_CanAnalVore")
            else
                Osi.RemovePassive(character, "SP_CanAnalVore")
            end
        elseif template == 'SP_PotionOfUnbirth_92067c3c-547e-4451-9377-632391702de9' then
            if Osi.HasPassive(character, "SP_CanUnbirth") == 0 and (Osi.IsTagged(character, 'a0738fdf-ca0c-446f-a11d-6211ecac3291') == 1 or not
                    ConfigVars.Mechanics.RequireProperAnatomy.value or Osi.GetBodyType(character, 1) == "Female") then
                Osi.AddPassive(character, "SP_CanUnbirth")
            else
                Osi.RemovePassive(character, "SP_CanUnbirth")
            end
        elseif template == 'SP_PotionOfCockVore_04cbdeb4-a98e-44cd-b032-972df0ba3ca1' then
            if Osi.HasPassive(character, "SP_CanCockVore") == 0 and (Osi.IsTagged(character, 'd27831df-2891-42e4-b615-ae555404918b') == 1 or not
                    ConfigVars.Mechanics.RequireProperAnatomy.value) then
                Osi.AddPassive(character, "SP_CanCockVore")
            else
                Osi.RemovePassive(character, "SP_CanCockVore")
            end
        elseif template == 'SP_PotionOfGluttony_f3914e54-2c48-426a-a338-8e1c86ebc7be' then
            if Osi.HasPassive(character, "SP_Gluttony") == 0 then
                Osi.AddPassive(character, "SP_Gluttony")
            else
                Osi.RemovePassive(character, "SP_Gluttony")
            end
        elseif template == 'SP_PotionOfPrey_02ee5321-7bcd-4712-ba06-89eb1850c2e4' then
            if Osi.HasPassive(character, "SP_IsPrey") == 0 then
                Osi.AddPassive(character, "SP_IsPrey")
            else
                Osi.RemovePassive(character, "SP_IsPrey")
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
        end
    end
end

---@param character CHARACTER
function SP_OnLevelUp(character)
    SP_DelayCallTicks(10, function ()
        if Osi.HasPassive(character, 'SP_BottomlessStomach') == 1 then
            if Osi.HasPassive(character, "SP_CanAnalVore") == 0 then
                Osi.AddPassive(character, "SP_CanAnalVore")
            end
        elseif Osi.HasPassive(character, 'SP_BoilingInsides') == 1 then
            if Osi.HasPassive(character, "SP_CanCockVore") == 0 and (Osi.IsTagged(character, 'd27831df-2891-42e4-b615-ae555404918b') == 1 or not
                    ConfigVars.Mechanics.RequireProperAnatomy.value) then
                Osi.AddPassive(character, "SP_CanCockVore")
            end
        elseif Osi.HasPassive(character, 'SP_SoothingStomach') == 1 then
            if Osi.HasPassive(character, "SP_CanUnbirth") == 0 and (Osi.IsTagged(character, 'a0738fdf-ca0c-446f-a11d-6211ecac3291') == 1 or not
                    ConfigVars.Mechanics.RequireProperAnatomy.value or Osi.GetBodyType(character, 1) == "Female") then
                Osi.AddPassive(character, "SP_CanUnbirth")
            end
        end
    end)
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
    -- regurgitates prey it they are not fully swallowed
    if status == 'SP_PartiallySwallowed' or status == 'SP_PartiallySwallowedGentle' then
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
                    Osi.RemoveSpell(pred, 'SP_SwallowDown')
                end
                SP_RegurgitatePrey(pred, object, -1)
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
    end
end

---Runs when character leaves combat
---@param object GUIDSTRING
---@param combatGuid GUIDSTRING
function SP_OnCombatLeave(object, combatGuid)
    if VoreData[object] ~= nil then
        VoreData[object].Combat = ""
    end
end

---Runs when someone dies.
---@param character CHARACTER
function SP_OnBeforeDeath(character)
    if VoreData[character] == nil then
        return
    end
    -- If character was pred.
    VoreData[character].Fat = 0
    VoreData[character].Satiation = 0
    if VoreData[character].Pred ~= "" then
        VoreData[VoreData[character].Pred].AddWeight = VoreData[VoreData[character].Pred].AddWeight +
            VoreData[character].AddWeight
    end
    VoreData[character].AddWeight = 0
    if next(VoreData[character].Prey) ~= nil then
        _P(character .. " was pred and DIED")
        SP_RegurgitatePrey(character, 'All', -1)
    end

    -- If character was prey (both can be true at the same time)
    if VoreData[character] ~= nil and VoreData[character].Pred ~= "" then
        local pred = VoreData[character].Pred
        VoreData[character].Digestion = 1
        if VoreData[character].Locus == 'O' then
            SP_SwitchToLocus(pred, character, 'A')
        end
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
            SP_SwitchToDigestionType(pred, character, 1, 1)
            -- Digested but not released prey will be stored out of bounds.
            -- investigate if teleporting char out of bounds and reloading breaks them
            Osi.TeleportToPosition(character, -100000, 0, -100000, "", 0, 0, 0, 1, 0)
            -- Implementation for fast digestion.
            if ConfigVars.Digestion.SlowDigestion.value == false then
                local preyToDigest = {}
                preyToDigest[character] = VoreData[character].Locus
                SP_FastDigestion(pred, preyToDigest, 0)
            end
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
        if ConfigVars.Debug.LockStomach.value then
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
    CalculateRest = false
    _P('SP_OnShortRest')
    SP_SlowDigestion(ConfigVars.Digestion.DigestionRateShort.value, ConfigVars.WeightGain.WeightLossShort.value)

    --Osi.IteratePlayerCharacters("HungerCalculateShort", "")
    SP_HungerSystem(ConfigVars.Hunger.HungerShort.value, false)

    for k, v in pairs(VoreData) do
        if Osi.HasActiveStatus(k, "SP_SC_GreatHunger_RestoreSlot") == 1 then
            Osi.RemoveStatus(k, "SP_SC_GreatHunger_RestoreSlot")
        end
    end

    _D(VoreData)
    SP_DelayCallTicks(5, function ()
        CalculateRest = true
    end)
end

---Fires once after long rest.
function SP_OnLongRest()
    _P('SP_OnLongRest')
    SP_SlowDigestion(ConfigVars.Digestion.DigestionRateLong.value, ConfigVars.WeightGain.WeightLossLong.value)

    SP_HungerSystem(ConfigVars.Hunger.HungerLong.value, true)

    SP_DelayCallTicks(15, function ()
        for k, v in pairs(VoreData) do
            -- makes npcs release their prey if they are digested or endoed (with a random chance)
            if next(v.Prey) ~= nil and Osi.IsPlayer(k) == 0 then
                if Osi.Random(2) == 1 then
                    SP_RegurgitatePrey(k, "All", 10, "Rest")
                else
                    SP_RegurgitatePrey(k, "All", 1, "Rest")
                end
            end
        end
    end)
    _D(VoreData)
end

---hunger system
---@param stacks integer how much hunger stacks to add
---@param isLong boolean is long rest
function SP_HungerSystem(stacks, isLong)
    -- hunger system
    if not ConfigVars.Hunger.Hunger.value then
        return
    end
    local party = Ext.Entity.Get(Osi.GetHostCharacter()).PartyMember.Party.PartyView.Characters

    for k, v in pairs(party) do
        local predData = v:GetAllComponents()
        local pred = predData.ServerCharacter.Template.Name .. "_" .. predData.Uuid.EntityUuid
        local hungerStacks = stacks + Osi.GetStatusTurns(pred, "SP_Hunger")
        local newhungerStacks = hungerStacks
        if VoreData[pred] ~= nil then
            local satiationDiff = VoreData[pred].Satiation // ConfigVars.Hunger.HungerSatiation.value
            newhungerStacks = hungerStacks - satiationDiff
            if newhungerStacks > 0 then
                VoreData[pred].Satiation = VoreData[pred].Satiation -
                    satiationDiff * ConfigVars.Hunger.HungerSatiation.value
            else
                VoreData[pred].Satiation = VoreData[pred].Satiation -
                    hungerStacks * ConfigVars.Hunger.HungerSatiation.value
                newhungerStacks = 0
            end
            -- half of hunger stacks (rounded up) are removed with fat
            if newhungerStacks > 1 and ConfigVars.Hunger.HungerUseFat.value then
                local hungerCompensation = (newhungerStacks + 1) // 2
                satiationDiff = VoreData[pred].Fat // ConfigVars.Hunger.HungerSatiation.value
                local newHungerCompensation = hungerCompensation - satiationDiff
                if newHungerCompensation > 0 then
                    VoreData[pred].Fat = VoreData[pred].Fat -
                        satiationDiff * ConfigVars.Hunger.HungerSatiation.value
                else
                    VoreData[pred].Fat = VoreData[pred].Fat -
                        hungerCompensation * ConfigVars.Hunger.HungerSatiation.value
                    newHungerCompensation = 0
                end
                newhungerStacks = newhungerStacks + newHungerCompensation - hungerCompensation
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
                if newhungerStacks >= ConfigVars.Hunger.HungerBreakpoint3.value then
                    lethalRandomSwitch = true
                    Osi.ApplyStatus(pred, 'SP_HungerStage3', -1, 1)
                elseif newhungerStacks >= ConfigVars.Hunger.HungerBreakpoint2.value then
                    Osi.ApplyStatus(pred, 'SP_HungerStage2', -1, 1)
                    if (not isLong and Osi.Random(2) == 1) or (isLong and Osi.Random(3) ~= 1) then
                        lethalRandomSwitch = true
                    end
                elseif newhungerStacks >= ConfigVars.Hunger.HungerBreakpoint1.value then
                    Osi.ApplyStatus(pred, 'SP_HungerStage1', -1, 1)
                    if (not isLong and Osi.Random(3) == 1) or (isLong and Osi.Random(2) == 1) then
                        lethalRandomSwitch = true
                    end
                end

                --Randomly start digesting prey because of hunger
                if VoreData[pred] ~= nil and lethalRandomSwitch then
                    for i, j in pairs(VoreData[pred].Prey) do
                        if ConfigVars.Hunger.LethalRandomSwitch.value then
                            _P("Random lethal switch")
                            SP_SwitchToDigestionType(pred, i, 0, 2)
                            -- prey is digested if the switch happens during long rest
                            if isLong then
                                Osi.ApplyDamage(i, 100, "Acid", pred)
                            end
                        end
                    end
                    if ConfigVars.Hunger.LethalRandomSwitch.value then
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
    SP_ResetConfig()
    SP_LoadConfigFromFile()
    if PersistentVars['VoreData'] == nil then
        PersistentVars['VoreData'] = {}
    end
    VoreData = PersistentVars['VoreData']
    SP_MigratePersistentVars()
end

function SP_OnLevelLoaded(level)
    SP_CheckVoreData()
    Osi.ApplyStatus(Osi.GetHostCharacter(), "SP_ROLESELECTOR", -1)
end

---Runs when reset command is sent to console.
function SP_OnResetCompleted()
    -- if statFiles and #statFiles then
    --     for _, filename in pairs(statFiles) do
    --         if filename then
    --             local filePath = string.format('%s%s', modPath, filename)
    --             if string.len(filename) > 0 then
    --                 _P(string.format('RELOADING %s', filePath))
    --                 ---@diagnostic disable-next-line: undefined-field
    --                 Ext.Stats.LoadStatsFile(filePath, false)
    --             else
    --                 _P(string.format('Invalid file: %s', filePath))
    --             end
    --         end
    --     end
    -- end
    VoreData = PersistentVars['VoreData']
    -- _P('Reloading stats!')
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
        if next(v.Prey) ~= nil then
            SP_RegurgitatePrey(k, "All", -1, "LevelChange")
        end
    end
    for k, v in pairs(VoreData) do
        VoreData[k].Prey = {}
        VoreData[k].Pred = ""
        SP_VoreDataEntry(k, false)
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


-- If you know where to get type hints for this, please let me know.
if Ext.Osiris == nil then
    Ext.Osiris = {}
end

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", SP_OnSpellCastTarget)
Ext.Osiris.RegisterListener("CastedSpell", 5, "after", SP_OnSpellCast)
Ext.Osiris.RegisterListener("LeveledUp", 1, "after", SP_OnLevelUp)
Ext.Osiris.RegisterListener("ShapeshiftChanged", 4, "after", SP_OnTransform)

Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", SP_OnCombatEnter)
Ext.Osiris.RegisterListener("LeftCombat", 2, "after", SP_OnCombatLeave)

Ext.Osiris.RegisterListener("RollResult", 6, "after", SP_OnRollResults)
Ext.Osiris.RegisterListener("LevelLoaded", 1, "after", SP_OnLevelLoaded)
Ext.Osiris.RegisterListener("LevelUnloading", 1, "before", SP_OnBeforeLevelUnloaded)
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", SP_OnStatusApplied)
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", SP_OnStatusRemoved)
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", SP_OnItemAdded)
Ext.Osiris.RegisterListener("Died", 1, "before", SP_OnBeforeDeath)
Ext.Osiris.RegisterListener("ShortRested", 1, "after", SP_OnShortRest)
Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", SP_OnLongRest)
Ext.Osiris.RegisterListener("UseFinished", 3, "after", SP_ItemUsed)



Ext.Events.SessionLoaded:Subscribe(SP_OnSessionLoaded)
Ext.Events.ResetCompleted:Subscribe(SP_OnResetCompleted)

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
