




-- utils for handling events
Ext.Require("Events/EventUtils.lua")
-- for Ext events (but not Osiris events)
Ext.Require("Events/ExtEvents.lua")
-- for Osiris events (but not Ext events)
Ext.Require("Events/OsiEvents.lua")

-- config, it's saving and loading
Ext.Require("IO/Config.lua")
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

-- utils that use osi but are not vore-related
Ext.Require("Utils/OsiUtils.lua")
-- non vore or ext/osi related utils
Ext.Require("Utils/Utils.lua")

-- utils that are directly related to vore but do not use voredata
Ext.Require("Vore Processing/OsiVoreUtils.lua")
-- VoreData management
Ext.Require("Vore Processing/VoreUtils.lua")







Ext.Vars.RegisterModVariable(ModuleUUID, "ModVoreData", {})


PersistentVars = {}

-- If you know where to get type hints for this, please let me know.
if Ext.Osiris == nil then
    Ext.Osiris = {}
end



