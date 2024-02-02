local levelGameplayStarted = false

---@type table<string, function[]> event_arity_when: [func...]
local osiListenersQueue = {}

---Registers a function as a one-time callback for a specified Osiris event.
---@param event FixedString
---@param arity integer
---@param when FixedString
---@param handler function
function SP_OsirisRegisterOneTimeListener(event, arity, when, handler)
    local key = event .. "_" .. arity .. "_" .. when
    _V("Adding one-time Osiris event callback in the queue: " .. key)
    if osiListenersQueue[key] == nil then
        _V("Registering new one-time Osiris callback for: " .. key)
        osiListenersQueue[key] = {}
        local realHandler = function ()
            for _, fn in ipairs(osiListenersQueue[key]) do
                _V("Calling one-time Osiris callback for: " .. key)
                fn()
            end
            osiListenersQueue[key] = {}
        end
        Ext.Osiris.RegisterListener(event, arity, when, realHandler)
    end
    table.insert(osiListenersQueue[key], handler)
end

---Executes the function after the LevelGameplayStarted event,
---or immediately if it was already triggered.
---@param tickDelayAfterEvent integer
---@param func function
function SP_ExecOnGameplayStarted(tickDelayAfterEvent, func)
    if levelGameplayStarted then
        func()
    else
        local fn
        if tickDelayAfterEvent > 0 then
            fn = function ()
                SP_DelayCallTicks(tickDelayAfterEvent, func)
            end
        else
            fn = func
        end
        SP_OsirisRegisterOneTimeListener("LevelGameplayStarted", 2, "after", fn)
    end
end

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function ()
    levelGameplayStarted = true
end)
Ext.Osiris.RegisterListener("LevelUnloading", 1, "before", function ()
    levelGameplayStarted = false
end)
