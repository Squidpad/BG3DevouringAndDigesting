
-- utils for handling events
Ext.Require("Events/EventUtils.lua")
-- for Ext events (but not Osiris events)
Ext.Require("Events/ExtEvents.lua")
-- for Osiris events (but not Ext events)
Ext.Require("Events/OsiEvents.lua")
-- for events involving the MCM (Split into Server and Client)
Ext.Require("Events/MCMEventsServer.lua")

-- config, it's saving and loading
Ext.Require("IO/MCMConfig.lua")
-- for console commands
Ext.Require("IO/ConsoleCommands.lua")
-- output
Ext.Require("IO/Output.lua")

-- migration of config
Ext.Require("Migrations/ConfigMigrations.lua")
-- migration of VoreData
Ext.Require("Migrations/PersistentVarsMigrations.lua")

-- subclasses
Ext.Require("Subclasses/StomachSentinel.lua")

-- difficulty classes
Ext.Require("Tables/DCTable.lua")
-- for npc vore destribution databases
Ext.Require("Tables/RaceTable.lua")
-- all global tables except for VoreData
Ext.Require("Tables/TableData.lua")
-- all global tables except for VoreData
Ext.Require("Tables/BellyTable.lua")

-- utils that use osi but are not vore-related
Ext.Require("Utils/OsiUtils.lua")
-- non vore or ext/osi related utils
Ext.Require("Utils/Utils.lua")

-- functions that are called from certain event listeners, to avoid bloat in OsiEvents.lua
Ext.Require("Vore Processing/OsiEventsProcessing.lua")
-- utils that are directly related to vore but do not use voredata
Ext.Require("Vore Processing/OsiVoreUtils.lua")
-- VoreData management
Ext.Require("Vore Processing/VoreUtils.lua")

local deps = {
    MCMModuleUUID = "755a8a72-407f-4f0d-9a33-274ac0f0b53d"
}

if not Ext.Mod.IsModLoaded(deps.MCMModuleUUID) then
    Ext.Utils.Print(
        "BG3 Mod Configuration Menu is missing! This mod will not work properly without it. PLEASE MAKE SURE IT IS ENABLED IN YOUR MOD MANAGER.")
end


Ext.Vars.RegisterModVariable(ModuleUUID, "ModVoreData", {})


PersistentVars = {}

-- If you know where to get type hints for this, please let me know.
if Ext.Osiris == nil then
    Ext.Osiris = {}
end



