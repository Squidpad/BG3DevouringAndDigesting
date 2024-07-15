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


local function spHandleBeforeDealDamage(e)
    if (e.Hit ~= nil and e.Hit.InflicterOwner ~= nil and e.Hit.Results ~= nil and e.Hit.InflicterOwner.ServerCharacter ~= nil) then
        local inflicterEntityUuid = e.Hit.InflicterOwner.ServerCharacter.Template.Name .. "_" .. e.Hit.InflicterOwner.Uuid.EntityUuid
        if VoreData[inflicterEntityUuid] ~= nil then
            -- when prey inflicts damage
            if VoreData[inflicterEntityUuid].Pred ~= "" then
                if Osi.HasPassive(VoreData[inflicterEntityUuid].Pred, "SP_LeadBelly") == 1 then
                    -- Cache the original DamageType to use it when converting to Force if need
                    local originalDamageType = e.Hit.DamageType
                    
                    e.Hit.Results.FinalDamagePerType[originalDamageType] = e.Hit.Results.FinalDamagePerType[originalDamageType] // 2
                    e.Hit.Results.FinalDamage = e.Hit.Results.FinalDamage // 2
                    e.Hit.TotalDamageDone = e.Hit.TotalDamageDone // 2
        
                    for k, v in pairs(e.Hit.DamageList) do
                        e.Hit.DamageList[k].Amount = v.Amount // 2
                    end
                end
            -- elseif next(VoreData[inflicterEntityUuid].Prey) ~= nil then
            --     if Osi.HasActiveStatus(inflicterEntityUuid, "SP_LeechingAcidStatus") == 1 then
            --         _P("Pred " .. inflicterEntityUuid .. " dealt damage")
            --         _P("Has leeching insides")
            --         _D(e.Hit.field_158:GetAllComponents())
            --     end
            end
        end
    end
end

---Runs when reset command is sent to console.
local function SP_OnResetCompleted()

end

---Runs on session load
function SP_OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
    _D(PersistentVars)
    -- SP_ResetConfig()
    SP_ResetRaceWeightsConfig()
    --SP_LoadConfigFromFile()
    SP_LoadRaceWeightsConfigFromFile()
    if PersistentVars['VoreData'] == nil then
        PersistentVars['VoreData'] = {}
    end
    VoreData = PersistentVars['VoreData']
    SP_MigratePersistentVars()
    
end

function SP_Tick()
    SP_BellyQueueUpdate()
end

Ext.Events.BeforeDealDamage:Subscribe(spHandleBeforeDealDamage)
Ext.Events.SessionLoaded:Subscribe(SP_OnSessionLoaded)
-- Ext.Events.ResetCompleted:Subscribe(SP_OnResetCompleted)
Ext.Events.Tick:Subscribe(SP_Tick)


