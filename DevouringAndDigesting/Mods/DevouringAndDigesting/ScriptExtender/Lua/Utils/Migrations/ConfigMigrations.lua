---@type table<string, fun(config: SP_ConfigVars): boolean>
SP_ConfigMigrations = {
    To1 = function ()
        return false
    end,
    -- ToVERSION = function(config)
    --     -- Upgrade config here.
    --     return true
    -- end,
    -- 1->2 will never happen because the config version is stored differently
    -- so we just reset it
    -- same with 2->3
    To2 = function ()
        return false
    end,
    To3 = function ()
        return false
    end
}

