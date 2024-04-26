local statFiles = {
    -- 'Armor.txt',
    -- 'Items.txt',
    -- 'Potions.txt',
    -- 'Passive.txt',
    -- 'Passive_Feat.txt',
    -- 'Regurgitate_Vore_Core.txt',
    -- 'Spells_Projectile.txt',
    -- 'Spells_Spellbook.txt',
    -- 'Spells_Target.txt',
    -- 'Spells_Upcasting.txt',
    -- 'Spell_Vore_Core.txt',
    -- 'Passive_Status.txt',
    'Status_Debug.txt',
    -- 'Status_Spells_Spellbook.txt',
    -- 'Status_Vore_Core.txt',
    -- 'GreatHunger_Interrupt.txt',
    -- 'GreatHunger_Passive.txt',
    -- 'GreatHunger_Spell.txt',
    -- 'GreatHunger_Status.txt',
    -- 'StomachSentinel_Passive.txt',
    -- 'StomachSentinel_Status.txt',
    -- 'StomachSentinel_EveryonesStrength.txt',
    -- 'StomachSentinel_KnowledgeWithin.txt',
}

local modPath = "Public/DevouringAndDigesting/Stats/Generated/Data/"


-- output
Ext.Require("Utils/Output.lua")
-- all global tables except for VoreData
Ext.Require("Utils/TableData.lua")
-- difficulty classes
Ext.Require("Utils/DCTable.lua")
-- non vore or ext/osi related utils
Ext.Require("Utils/Utils.lua")
-- for npc vore destribution databases
Ext.Require("Utils/RaceTable.lua")
-- migration of config
Ext.Require("Utils/Migrations/ConfigMigrations.lua")
-- config, it's saving and loading
Ext.Require("Utils/Config.lua")
-- utils for handling events
Ext.Require("Utils/EventUtils.lua")
-- utils that use osi but are not vore-related
Ext.Require("Utils/OsiUtils.lua")
-- utils that are directly related to vore but do not use voredata
Ext.Require("Utils/OsiVoreUtils.lua")
-- VoreData management
Ext.Require("Utils/VoreUtils.lua")
-- migration of VoreData
Ext.Require("Utils/Migrations/PersistentVarsMigrations.lua")
-- for Ext events (but not osiris events)
Ext.Require("Utils/ExtEvents.lua")
-- for console commands
Ext.Require("Utils/ConsoleCommands.lua")

-- subclasses
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
    local spellParams = SP_StringSplit(spell, "_")
    if spellParams[1] ~= 'SP' then
        return
    end
    local spellName = spellParams[3]

    if VoreData[caster] ~= nil then

        if spellName == 'Regurgitate' then
            if Osi.HasActiveStatus(caster, "SP_RegurgitationCooldown2") ~= 0 then
                return
            end
            local prey = table.concat({table.unpack(spellParams, 5, #spellParams)}, "_")
            local locus = spellParams[4]
            if locus == "X" then
                locus = nil
            end
            SP_RegurgitatePrey(caster, prey, 10, '', locus)
        elseif spellName == 'Absorb' then
            local prey = spellParams[4]
            SP_RegurgitatePrey(caster, prey, 1, "Absorb")
        elseif spellName == "SwitchToLethal" then
            if VoreData[caster] ~= nil then
                local locus = spellParams[4]
                if locus == "O" or locus == "All" then
                    VoreData[caster].DigestItems = true
                end
                for k, v in pairs(VoreData[caster].Prey) do
                    if locus == v or locus == "All" then
                        SP_SwitchToDigestionType(caster, k, 0, 2)
                    end
                end
            end
        elseif spellName == 'SwallowDown' then
            for k, v in pairs(VoreData[caster].Prey) do
                if VoreData[k].SwallowProcess > 0 then
                    _P("Ally: " .. Osi.IsAlly(caster, k))
                    if Osi.IsAlly(caster, k) == 1 then
                        VoreData[k].SwallowProcess = VoreData[k].SwallowProcess - 1

                        if VoreData[k].SwallowProcess == 0 then
                            SP_FullySwallow(caster, k)
                        end
                    else
                        SP_VoreCheck(caster, k, "SwallowDownCheck")
                    end
                end
            end
            -- deal small amount of damage to prey
        elseif spellName == 'SpeedUpDigestion' then
            if VoreData[caster] ~= nil then
                for k, v in pairs(VoreData[caster].Prey) do
                    if VoreData[k].Digestion == DType.Lethal then
                        Osi.ApplyStatus(k, 'SP_SpeedUpDigestion_Status', 0, 1, caster)
                    end
                end
            end
            -- ask pred to release me
        elseif spellName == 'ReleaseMe' then
            if VoreData[caster].Pred ~= "" then
                --SP_RegurgitatePrey(VoreData[caster].Pred, caster, 0)
                SP_VoreCheck(VoreData[caster].Pred, caster, "ReleaseMeCheck")
            end
        elseif spell == 'SP_SC_BoundPrey_Spell' then
            if VoreData[caster] ~= nil then
                for k, v in pairs(VoreData[caster].Prey) do
                    if Osi.IsAlly(caster, k) == 1 and VoreData[k].Digestion == DType.Endo then
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
---@param spellType string
---@param spellElement? string Like fire, lightning, etc I think.
---@param storyActionID? integer
function SP_OnSpellCastTarget(caster, target, spell, spellType, spellElement, storyActionID)
    local spellParams = SP_StringSplit(spell, "_")
    if spellParams[1] ~= "SP" then
        return
    end
    if spellParams[2] ~= "Target" and spellParams[2] ~= "Projectile" then
        return
    end
    local locus = spellParams[#spellParams]
    if not SP_TableContainsKey(DigestionStatuses, locus) then
        locus = nil
    end
    local spellName = spellParams[3]
    -- main vore spell
    if spellName == 'Swallow' then
        local digestionType = spellParams[4]
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
        if digestionType == 'Endo' then
            if Osi.IsItem(target) == 1 then
                SP_DelayCallTicks(12, function ()
                    SP_SwallowItem(caster, target)
                end)
            else
                _P("Ally: " .. Osi.IsAlly(caster, target))
                if Osi.IsAlly(caster, target) == 1 then
                    SP_DelayCallTicks(12, function ()
                        SP_SwallowPrey(caster, target, DType.Endo, true, true, locus)
                    end)
                else
                    SP_DelayCallTicks(6, function ()
                        SP_VoreCheck(caster, target, "SwallowCheck_Endo_" .. locus)
                    end)
                end
            end
        elseif digestionType == 'Lethal' then
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
    elseif spellName == "BellyportDestination" then
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
                SP_SwallowPreyMultiple(target, preyTable, DType.Lethal, true, false, locus)
            end
            Osi.RemoveSpell(caster, "SP_Target_BellyportDestination")
        end)
        -- swallow me spells
    elseif spellName == 'OfferMe' then
        -- prey should not target their preds
        if VoreData[caster] ~= nil and VoreData[caster].Pred == target then
            return
        end
        if not SP_VorePossible(target, caster) then
            return
        end
        if Osi.IsEnemy(caster, target) == 0 then
            SP_DelayCallTicks(12, function ()
                SP_SwallowPrey(target, caster, DType.Endo, true, false, locus)
            end)
        else
            SP_DelayCallTicks(12, function ()
                SP_SwallowPrey(target, caster, DType.Lethal, true, false, locus)
            end)
        end
        -- non swallow-related spells
    else
        if spell == 'Massage_Pred' then
            if VoreData[target] ~= nil then
                Osi.RemoveStatus(target, 'SP_Indigestion')
                for k, v in pairs(VoreData[target].Prey) do
                    if VoreData[k].Digestion == DType.Lethal then
                        Osi.ApplyStatus(k, 'SP_MassageAcid', 0, 1, target)
                    end
                end
            end
        elseif spell == 'AssignNPCPred' then
            _P(target)
            if Ext.Entity.Get(target).ServerCharacter.Temporary == false then
                if Osi.HasPassive(target, "SP_BlockGluttony") == 1 then
                    _P("Was prey")
                    Osi.RemovePassive(target, "SP_BlockGluttony")
                end
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
                    if VoreData[k].Digestion == DType.Lethal then
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
    if string.sub(eventName, 1, 20) == 'SwallowCheck_Lethal_' and (resultType ~= 0 or ConfigVars.Debug.AlwaysSucceedVore.value) then
        _P('Lethal Swallow Success by ' .. roller)
        local voreLocus = string.sub(eventName, -1)
        local preyNotStolen = SP_SwallowPrey(roller, rollSubject, DType.Lethal, true, true, voreLocus)

        if ConfigVars.Mechanics.SwitchEndoLethal.value and preyNotStolen and Osi.HasPassive(roller, 'SP_MuscleControl') == 0 then
            if voreLocus == 'O' then
                VoreData[roller].DigestItems = true
            end
            for k, v in pairs(VoreData[roller].Prey) do
                if voreLocus == v then
                    SP_SwitchToDigestionType(roller, k, 0, 2)
                end
            end
        end
    elseif string.sub(eventName, 1, 18) == 'SwallowCheck_Endo_' and (resultType ~= 0 or ConfigVars.Debug.AlwaysSucceedVore.value) then
        _P('Endo Swallow Success by ' .. roller)
        local voreLocus = string.sub(eventName, -1)
        SP_SwallowPrey(roller, rollSubject, DType.Endo, true, true, voreLocus)
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
                Osi.RemoveSpell(roller, 'SP_Zone_SwallowDown')
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
            if VoreData[k].Digestion ~= DType.Dead and (ConfigVars.Debug.TeleportPrey.value == true or VoreData[k].Combat ~= "") then
                local predX, predY, predZ = Osi.GetPosition(object)
                Osi.TeleportToPosition(k, predX, predY, predZ, "", 0, 0, 0, 0, 0)
            end
            if VoreData[k].Digestion == DType.Endo then
                local shelterTurns = Osi.GetStatusTurns(object, "SP_SC_StomachShelterStuffed")
                local sanctuaryTurns = Osi.GetStatusTurns(object, "SP_SC_StomachSanctuaryStuffed")
                
                Osi.ApplyStatus(object, "SP_SC_StomachShelterStuffed_TempHP", (shelterTurns + sanctuaryTurns) * SecondsPerTurn, 1, object)
            end
            if lethalRandomSwitch and ConfigVars.Hunger.LethalRandomSwitch.value then
                _P("Random lethal switch")
                SP_SwitchToDigestionType(object, k, DType.Endo, DType.Lethal)
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
        if Osi.IsEnemy(object, VoreData[object].Pred) == 1 then
            SP_VoreCheck(VoreData[object].Pred, object, "StruggleCheck")
        end
        if VoreData[object].Digestion == DType.Lethal then
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
                        SP_SwitchToDigestionType(pred, k, DType.Endo, DType.Lethal)
                    end
                end
            end
        end
    elseif status == "SP_Hit_Bellyport" then
        local pred = SP_CharacterFromGUID(causee)
        _P(pred)
        if VoreData[pred] == nil then
            SP_VoreDataEntry(pred, true)
        end
        VoreData[pred].SpellTargets[object] = "Bellyport"
        Osi.AddSpell(pred, "SP_Target_BellyportDestination")
    elseif status == 'SP_BellySlamStatus' then
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
                    Osi.RemoveSpell(pred, 'SP_Zone_SwallowDown')
                end
                SP_RegurgitatePrey(pred, object, -1, "SwallowFail")
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
    if next(VoreData[character].Prey) ~= nil or VoreData[character].Items ~= "" then
        _P(character .. " was pred and DIED")
        SP_RegurgitatePrey(character, 'All', -1)
    end

    -- If character was prey (both can be true at the same time)
    if VoreData[character] ~= nil and VoreData[character].Pred ~= "" then
        local pred = VoreData[character].Pred
        VoreData[character].Digestion = DType.Dead
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

---Runs on session load
function SP_OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
    SP_ResetConfig()
    SP_ResetRaceWeightsConfig()
    SP_LoadConfigFromFile()
    SP_LoadRaceWeightsConfigFromFile()
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
local function SP_OnResetCompleted()
    if statFiles and #statFiles then
        _P('Reloading stats!')
        for _, filename in pairs(statFiles) do
            if filename then
                local filePath = string.format('%s%s', modPath, filename)
                if string.len(filename) > 0 then
                    _P(string.format('RELOADING %s', filePath))
                    ---@diagnostic disable-next-line: undefined-field
                    Ext.Stats.LoadStatsFile(filePath, 1)
                else
                    _P(string.format('Invalid file: %s', filePath))
                end
            end
        end
    end
    VoreData = PersistentVars['VoreData']
end

local function SP_OnStatsLoaded()
    local stat = Ext.Stats.Create("SP_teststatus", "StatusData", "SP_DebugInitStatus")
    stat.Boosts = "Ability(Constitution,100)"
    stat:Sync()

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
Ext.Events.StatsLoaded:Subscribe(SP_OnStatsLoaded)
