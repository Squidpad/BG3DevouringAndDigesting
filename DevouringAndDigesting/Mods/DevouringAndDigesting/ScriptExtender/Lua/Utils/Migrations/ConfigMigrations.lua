---@type table<string, fun(config: SP_ConfigVars): boolean>
SP_ConfigMigrations = {
    To1 = function ()
        return false
    end,
    To2 = function (configV1, configV2)
        for k, v in pairs(configV2) do
            for i, j in pairs(configV1) do
                if (v == i) then
                    configV2[k][i] = j
                end
            end
        end
        configV1 = configV2
        return true
    end,
}

