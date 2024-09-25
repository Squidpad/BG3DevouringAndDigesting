---Fetches display name of a thing given its GUIDSTRING.
---@param target GUIDSTRING
---@return string
function SP_GetDisplayNameFromGUID(target)
    return Osi.ResolveTranslatedString(Osi.GetDisplayName(target))
end

---Returns a character's name given it's GUID
---@param guid GUIDSTRING
---@return CHARACTER
function SP_CharacterFromGUID(guid)
    local name = Ext.Entity.Get(guid).ServerCharacter.Template.Name
    return name .. "_" .. guid
end

---@param character CHARACTER guid of character
---@param stat number stat to get save DC of 1 == Str, 2 == Dex, 3 == Con, 4 == Wis, 5 == Int, 6 == Cha, 0 = Highest
---@return DIFFICULTYCLASS guid that corresponds to that DC
function SP_GetSaveDC(character, stat)
    local entity = Ext.Entity.Get(character)
    local total_boosts = 0
    if entity.BoostsContainer.Boosts.SpellSaveDC ~= nil then
        for _, boost in pairs(entity.BoostsContainer.Boosts.SpellSaveDC) do
            total_boosts = total_boosts + boost.SpellSaveDCBoost.DC
        end
    end
    local highest = 0
    if stat == 0 then
        for i = 1, 6 do
            if entity.Stats.AbilityModifiers[i] > highest then
                highest = entity.Stats.AbilityModifiers[i]
            end
        end
    end
    local DC = 8 + total_boosts + entity.Stats.ProficiencyBonus + (highest or entity.Stats.AbilityModifiers[stat])
    
    return DCTable[DC]
end

---@param character CHARACTER the character to query
---@return number size of the character
function SP_GetCharacterSize(character)
    local charData = Ext.Entity.Get(character)
    return charData.ObjectSize.Size
end

---Checks if a character has a status caused by another character
---@param character CHARACTER
---@param status string
---@param cause CHARACTER
---@return boolean
function SP_HasStatusWithCause(character, status, cause)
    local causeGUID = string.sub(cause, -36)
    local charStatusData = Ext.Entity.Get(character).ServerCharacter.StatusManager.Statuses
    for _, i in ipairs(charStatusData) do
        if i.CauseGUID == causeGUID and i.StatusId == status then
            _P("Found status " .. status .. " in " .. character)
            return true
        end
    end
    return false
end

---Delays a function call by given milliseconds.
---Preferable not to use, as time is not properly synced between server and client.
---@param ms integer
---@param func function
function SP_DelayCall(ms, func)
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId
    handlerId = Ext.Events.Tick:Subscribe(function ()
        if (Ext.Utils.MonotonicTime() - startTime >= ms) then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end)
end

---Delays a function call for a given number of ticks.
---Server runs at a target of 30hz, so each tick is ~33ms and 30 ticks is ~1 second. This IS synced between server and client.
---@param ticks integer
---@param fn function
function SP_DelayCallTicks(ticks, fn)
    local ticksPassed = 0
    local eventID
    eventID = Ext.Events.Tick:Subscribe(function ()
        ticksPassed = ticksPassed + 1
        if ticksPassed >= ticks then
            fn()
            Ext.Events.Tick:Unsubscribe(eventID)
        end
    end)
end
