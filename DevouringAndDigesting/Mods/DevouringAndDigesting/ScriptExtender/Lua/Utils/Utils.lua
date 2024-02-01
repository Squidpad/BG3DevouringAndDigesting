---Fetches display name of a thing given its GUIDSTRING.
---@param target GUIDSTRING
---@return string
function SP_GetDisplayNameFromGUID(target)
    return Osi.ResolveTranslatedString(Osi.GetDisplayName(target))
end

---@param character CHARACTER guid of character
---@param stat number stat to get save DC of 1 == Str, 2 == Dex, 3 == Con, 4 == Wis, 5 == Int, 6 == Cha
function SP_GetSaveDC(character, stat)
    local entity = Ext.Entity.Get(character)
    local total_boosts  = 0;
    for _, boost in pairs(entity.BoostsContainer.Boosts.SpellSaveDC) do
        total_boosts = total_boosts + boost.SpellSaveDCBoost.DC;
    end
    local DC = 8 + total_boosts + entity.Stats.ProficiencyBonus + entity.Stats.AbilityModifiers[stat];
    return DC;
end

---Returns character weight + their inventory weight.
---@param character CHARACTER
---@return number
function SP_GetTotalCharacterWeight(character)
    local charData = Ext.Entity.Get(character)
    _P("Total weight of " .. SP_GetDisplayNameFromGUID(character) .. " is " ..
           (charData.InventoryWeight.Weight + charData.Data.Weight) / 1000 .. " kg")
    return (charData.InventoryWeight.Weight + charData.Data.Weight) / 1000
end

---@param spell string name of the spell we're extracting data from
---@return string, string spellParams the type of spell and type of vore
function SP_GetSpellParams(spell)
    local pattern = "^SP_Target_S?w?a?l?l?o?w?_?([%a_]+)_([OAUC])$"
    return string.match(spell, pattern)
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
    eventID = Ext.Events.Tick:Subscribe(function()
        ticksPassed = ticksPassed + 1
        if ticksPassed >= ticks then
            fn()
            Ext.Events.Tick:Unsubscribe(eventID)
        end
    end)
end

---Returns a string with substring removed.
---@param string string
---@param substring string
---@return string
function SP_RemoveSubstring(string, substring)
    local startPos, endPos = string.find(string, substring)
    if startPos == nil or endPos == nil then
        return string
    end
    return string.sub(string, 0, startPos - 1) .. string.sub(string, endPos + 1)
end

---Checks if value is an integer.
---@param value any
---@return boolean
function SP_IsInt(value)
    return type(value) == "number" and math.floor(value) == value
end

---Returns a deepcopy of a table.
---@param table table
---@param copies table?
function SP_Deepcopy(table, copies)
    copies = copies or {}
    local origType = type(table)
    local copy
    if origType == 'table' then
        if copies[table] then
            copy = copies[table]
        else
            copy = {}
            copies[table] = copy
            for orig_key, orig_value in next, table, nil do
                copy[SP_Deepcopy(orig_key, copies)] = SP_Deepcopy(orig_value, copies)
            end
            setmetatable(copy, SP_Deepcopy(getmetatable(table), copies))
        end
    else
        -- number, string, boolean, etc
        copy = table
    end
    return copy
end

---Checks if an element is in the values of a table
---@param table table table to query
---@param element any element to query with
function SP_TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

---Checks if an element is in the keys of a table
---@param table table table to query
---@param element any element to query with
function SP_TableContainsKey(table, element)
    for key, _ in pairs(table) do
        if key == element then
            return true
        end
    end
    return false
end

---Swaps the keys and values of a table. Will get funky if the values are not strictly unique
---@param t table table with strictly unique keys
function SP_TableInvert(t)
    local newTable = {}
     for k,v in pairs(t) do
       newTable[v] = k
     end
     return newTable
 end

---returns t2 merged into t1
---@param t1 table
---@param t2 table
function SP_TableConcat(t1,t2)
    for i=1,#t2 do
       t1[#t1+1] = t2[i]
    end
    return t1
 end

---returns length of a table when # does not work (table is not an array)
---@param table table table to query
function SP_TableLength(table)
    local l = 0
    for k, v in pairs(table) do
        l = l + 1
    end
    return l
end
