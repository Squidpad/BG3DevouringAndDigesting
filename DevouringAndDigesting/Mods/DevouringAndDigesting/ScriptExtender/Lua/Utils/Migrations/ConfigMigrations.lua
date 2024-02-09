---@type table<string, fun(config: SP_ConfigVars): boolean>
SP_ConfigMigrations = {
    To1 = function ()
        return false
    end,
    -- Example. Add new before this, keep this at the end.
    -- ToVERSION = function(config)
    --     -- Upgrade config here.
    --     return true
    -- end,
}

