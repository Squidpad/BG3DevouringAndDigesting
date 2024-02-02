---@type table<string, fun(persistentVars: table): boolean>
SP_PersistentVarsMigrations = {
    To1 = function (persistentVars)
        return false
    end,
    -- ToVERSION = function(persistentVars)
    --     -- Upgrade persistentVars here.
    --     return true
    -- end,
}
