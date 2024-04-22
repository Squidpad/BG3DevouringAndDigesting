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
            end
        end
    end
end

Ext.Events.BeforeDealDamage:Subscribe(spHandleBeforeDealDamage)
