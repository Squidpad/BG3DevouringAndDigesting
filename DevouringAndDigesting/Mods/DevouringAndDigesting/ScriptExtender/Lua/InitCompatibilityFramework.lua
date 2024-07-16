local ModGuid = "c8e61d7e-9871-4548-a861-a8fced3ac4bd"
local BootStrap = {}

-- add new subclasses to this table and it should work
local NewSubClasses = {
    SP_GreatHunger = {
        subClassGuid = "a63af398-f070-4ecd-a1ec-e2ad9fbeab32",
        -- uuid of progression when subclass should be avalible
        baseClassProgressionGuid = "a7767dc5-e6ab-4e05-96fd-f0424256121c",
        -- for classes that select subclasses on level 1
        -- lvl 1 multiclass progression uuid is different
        -- nil for every other class
        baseClassProgressionMulticlassGuid = "20015e25-8aa9-41bf-b959-aa587ba0aa27",
        class = "warlock",
        subClassName = "The Great Hunger",
        -- if we need to add custom passives to existing passive lists
        Passives = {
            ['ab56f79f-95ec-48e5-bd83-e80ba9afc844'] = {
                "SP_SC_ShieldOfGluttony",
            },
            ['39efef92-9987-46e2-8c43-54052c1be535'] = {
                "SP_SC_ShieldOfGluttony",
            },
            ['a2d72748-0792-4f1e-a798-713a66d648eb'] = {
                "SP_SC_ShieldOfGluttony",
            },
        },
    },
    SP_StomachSentinel = {
        subClassGuid = "d170fe00-f9f1-4814-b456-1dc8981c7f2f",
        -- uuid of progression when subclass should be avalible
        baseClassProgressionGuid = "0d4a6b4b-8162-414b-81ef-1838e36e778a",
        -- for classes that select subclasses on level 1
        -- lvl 1 multiclass progression uuid is different
        -- nil for every other class
        baseClassProgressionMulticlassGuid = nil,
        class = "barbarian",
        subClassName = "Stomach Sentinel",
    },
}

-- if Ext.Mod.IsModLoaded("67fbbd53-7c7d-4cfa-9409-6d737b4d92a9") then
local function DetectSubClass(arr, subClass)
    for _, value in pairs(arr) do
        if value == subClass then return true end
    end
end

function BootStrap.loadSubClass(subClass, baseClass)
    local arr = Ext.StaticData.Get(baseClass, "Progression").SubClasses
    if arr ~= nil then
        local found = DetectSubClass(arr, subClass)
        if not found then
            local t = {}
            for _, value in pairs(arr) do
                table.insert(t, value)
            end
            table.insert(t, subClass)
            Ext.StaticData.Get(baseClass, "Progression").SubClasses = t
        end
    end
end



local function OnStatsLoaded()

    if false then
        local subClasses = {}
        for k, v in pairs(NewSubClasses) do
            subClasses[k] = {
                modGuid = ModGuid,
                subClassGuid = v.subClassGuid,
                class = v.class,
                subClassName = v.subClassName,
            }
        end

        Mods.SubclassCompatibilityFramework.Api.InsertSubClasses(subClasses)
    else
        for k, v in pairs(NewSubClasses) do
            BootStrap.loadSubClass(v.subClassGuid, v.baseClassProgressionGuid)
            if v.baseClassProgressionMulticlassGuid ~= nil and v.baseClassProgressionMulticlassGuid ~= "" then
                BootStrap.loadSubClass(v.subClassGuid, v.baseClassProgressionMulticlassGuid)
            end
            --_P(Ext.StaticData.Get(v.baseClassGuid, "Progression"))
        end
    end

    for k, v in pairs(NewSubClasses) do
        if v.Passives ~= nil then
            for i, j in pairs(v.Passives) do
                local pList = Ext.StaticData.Get(i, "PassiveList")
                if not pList then
                    _P("Bad passive list: " .. i)
                else
                    local arr = pList.Passives
                    local a = {}
                    for _, value in pairs(arr) do
                        table.insert(a, value)
                    end
                    for _, t in pairs(j) do
                        local flag = true
                        for m, n in pairs(arr) do
                            if n == t then flag = false end
                        end
                        if flag then
                            table.insert(a, t)
                        end
                    end
                    Ext.StaticData.Get(i, "PassiveList").Passives = a
                end
            end
        end
    end

    -- set this to true to enable spell distribution
    if true then
        SP_InitializeSpells()
    end
    _P("Finished Client Initialization")
end

Ext.Events.StatsLoaded:Subscribe(OnStatsLoaded)


