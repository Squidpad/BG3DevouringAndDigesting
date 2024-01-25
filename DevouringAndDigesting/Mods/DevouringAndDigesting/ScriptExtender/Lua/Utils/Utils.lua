---Fetches display name of a thing given its GUIDSTRING.
---@param target GUIDSTRING
---@return string
function SP_GetDisplayNameFromGUID(target)
    return Osi.ResolveTranslatedString(Osi.GetDisplayName(target))
end

---Returns character weight + their inventory weight.
---@param character CHARACTER
---@return string
function SP_GetTotalCharacterWeight(character)
    local charData = Ext.Entity.Get(character)
    _P("Total weight of " .. SP_GetDisplayNameFromGUID(character) .. " is " ..
           (charData.InventoryWeight.Weight + charData.Data.Weight) / 500 .. " lbs")
    return (charData.InventoryWeight.Weight + charData.Data.Weight) / 1000
end

---Delays a function call by given milliseconds.
---Preferable not to use, as time is not properly synced between server and client.
---@param ms integer
---@param func function
function SP_DelayCall(ms, func)
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId
    handlerId = Ext.Events.Tick:Subscribe(function()
        if (Ext.Utils.MonotonicTime() - startTime > ms) then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end)
end

---Delays a function call for a given number of ticks.
---Server runs at a target of 30hz, so each tick is ~33ms and 30 ticks is ~1 second. This IS synced between server and client.
---@param ticks integer
---@param func function
function SP_DelayCallTicks(ticks, func)
    if ticks <= 0 then
        func()
    else
        _P("delay")
        Ext.OnNextTick(function()
            SP_DelayCallTicks(ticks - 1, func)
        end)
    end
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

function SP_TableContains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end
