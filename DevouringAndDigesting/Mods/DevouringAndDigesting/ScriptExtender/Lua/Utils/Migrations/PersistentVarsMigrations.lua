---@type table<string, fun(persistentVars: table): boolean>
SP_PersistentVarsMigrations = {
    To1 = function (persistentVars)
        return false
    end,
    -- Example. Add new before this, keep this at the end.
    -- ToVERSION = function(persistentVars)
    --     -- Upgrade persistentVars here.
    --     return true
    -- end,
}
