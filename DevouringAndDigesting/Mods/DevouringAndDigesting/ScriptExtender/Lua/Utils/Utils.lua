---@param spell string name of the spell we're extracting data from
---@return string, string spellParams the type of spell and type of vore
function SP_GetSpellParams(spell)
    local pattern = "^SP_Target_S?w?a?l?l?o?w?_?([%a_]+)_([OAUC])$"
    return string.match(spell, pattern)
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
---@param table table table to be copied
---@param copies? table
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
    for k, v in pairs(t) do
        newTable[v] = k
    end
    return newTable
end

---returns t2 merged into t1
---@param t1 table
---@param t2 table
function SP_TableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

---returns length of a table when # does not work (table is not an array)
---@param table table table to query
function SP_TableLength(table)
    local l = 0
    for i, j in pairs(table) do
        l = l + 1
    end
    return l
end

---clamps the val between lower and upper values
---@param val number
---@param lower number
---@param upper number
function SP_Clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

