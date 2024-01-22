
function SP_GetDisplayNameFromGUID(guid) -- fetches display name of a thing given its GUID
    return Osi.ResolveTranslatedString(Osi.GetDisplayName(guid))
end

function SP_GetTotalCharacterWeight(character) -- returns character weight + their inventory weight
    local chardata = Ext.Entity.Get(character)
    _P("Total weight of " .. SP_GetDisplayNameFromGUID(character) .. " is " .. (chardata.InventoryWeight.Weight + chardata.Data.Weight)/500 .. " lbs")
    return (chardata.InventoryWeight.Weight + chardata.Data.Weight)/1000
end

function SP_DelayCall(msDelay, func) -- Delays a func call by msDelay milliseconds. Preferable not to use, as time is not properly synced between server and client
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId;
    handlerId = Ext.Events.Tick:Subscribe(function()
        if (Ext.Utils.MonotonicTime() - startTime > msDelay) then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end) 
end

function SP_DelayCallTicks(ticks, func) -- Delays a func call by ticks Ticks. Server runs at a target of 30hz, so each tick is ~33ms and 30 ticks is ~1 second. This IS synced between server and client
    if ticks <= 0 then
        func()
    else
        Ext.OnNextTick(function() SP_DelayCallTicks(ticks-1, func) end)
    end
end

function SP_RemoveSubstring(s, substring) -- returns a string with substring removed
    local x,y = string.find(s, substring)
    if x == nil or y == nil then
        return s
    end
    return string.sub(s,0,x-1) .. string.sub(s,y+1)
end

function SP_Deepcopy(orig, copies) -- returns a deepcopy of a table
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[SP_Deepcopy(orig_key, copies)] = SP_Deepcopy(orig_value, copies)
            end
            setmetatable(copy, SP_Deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end