Ext.Require("Utils/Utils.lua")
Ext.Require("Utils/Config.lua")

PredPreyTable = {} -- Keeps track of who's in who. Preds are keys, values are aa numerically indexed table of their prey. Used for top-down searches.
PreyPredPairs = {} -- Pair dict where keys are prey and values are preds. Way faster to search when going up.
RegurgDist = 3 -- Determines how far prey spawn when regurgitated

-- CharacterCreationAppearanceVisuals table for women. Goes like this: race -> bodyshape (1 == weak / 2 == strong) -> belly size (1/2/3/4/5)
BellyTableFemale = {Human = {{
		"5b04165d-2ec9-47f9-beff-0660640fc602",
		"5660e004-e2af-4f3a-ae76-375408cb78c3",
		"fafef7ab-087f-4362-9436-3e63ef7bcd95",
		"4a404594-e28d-4f47-b1c2-2ef593961e33",
		"78fc1e05-ee83-4e6c-b14f-6f116e875b03"
	}, {
		"4bfa882a-3bef-49b8-9e8a-21198a2dbee5",
		"4741a71a-8884-4d3d-929d-708e350953bb",
		"9950ba83-28ea-4680-9905-a070d6eabfe7",
		"4e698e03-94b8-4526-9fa5-5feb1f78c3b0",
		"e250ffe9-a94c-44b4-a225-f8cf61ad430d"
	}}}

---Populates the PredPreyTable and PreyPredPairs.
---@param pred CHARACTER guid of pred
---@param prey CHARACTER guid of prey
function SP_FillPredPreyTable(pred, prey)
    _P("Filling Table")
	
	if PreyPredPairs[prey] ~= nil then
		_P("Transferring prey " .. prey .. " from " .. PreyPredPairs[prey] .. " to " .. pred)
	end
	PreyPredPairs[prey] = pred
	if(PredPreyTable[pred] == nil) then
		PredPreyTable[pred] = {}
	end
	table.insert(PredPreyTable[pred], prey)
	
	_P("ADDING SPELL")
	Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
	
	PersistentVars['PreyTablePred'] = SP_Deepcopy(PreyPredPairs)
	PersistentVars['PredPreyTable'] = SP_Deepcopy(PredPreyTable)
	_D(PreyPredPairs)

end

---should be called in any situation when prey must be released
---@param pred GUIDSTRING 	guid of pred
---@param prey GUIDSTRING 	guid of prey
---@param swallowType string internal name of Status Effect
function SP_SwallowPrey(pred, prey, swallowType)
	Osi.ApplyStatus(prey, swallowType, -1, 1, pred)
	Osi.ApplyStatus(pred, "SP_Stuffed", 1*6, 1, pred)
	SP_FillPredPreyTable(pred, prey)
	if PreyPredPairs[prey] then
		Osi.SetDetached(prey, 1)
		Osi.SetVisible(prey, 0)
		PersistentVars['PreyWeightTable'][prey] = math.floor(SP_GetTotalCharacterWeight(prey)) -- instead of addweight
		PersistentVars['FakePreyWeightTable'][prey] = math.floor(SP_GetTotalCharacterWeight(prey)) -- instead of addweight
		-- Tag that disables downed state
		if Osi.IsTagged(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22') ~= 1 then
			Osi.SetTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
			PersistentVars['DisableDownedPreyTable'][prey] = true
			_P('DisableDownedPreyTable')
			_D(PersistentVars['DisableDownedPreyTable'])
		end
	end
	SP_DelayCallTicks(5, function() SP_UpdateWeight(pred) end)
end

---should be called in any situation when prey must be released, including pred's death
---@param pred CHARACTER	guid of pred
---@param prey CHARACTER	guid of prey
---@param preyState integer state of prey to regurgitate 0 == alive, 1 == dead, 2 == all
---@param spell string	internal name of spell
function SP_RegurgitatePrey(pred, prey, preyState, spell)
    _P('Starting Regurgitation')

    _P('Targets: ' .. prey)
    local markedForRemoval = {}
	-- find prey to remove, clear their status, mark them for removal
    for k, v in pairs(PreyPredPairs) do
		local preyAlive = Osi.IsDead(k)
		_P("Prey dead: " .. preyAlive .. " " .. k)
        if v == pred and (prey == "All" or k == prey) and (preyState == 2 or (preyAlive == preyState and (preyState == 0 or (PersistentVars['PreyWeightTable'][k] <= PersistentVars['FakePreyWeightTable'][k] // 5)))) then
			_P('Pred:' .. v)
			_P('Prey:' .. k)
			Osi.RemoveStatus(k, 'SP_Swallowed_Endo', pred)
			Osi.RemoveStatus(k, 'SP_Swallowed_Lethal', pred)
			Osi.RemoveStatus(k, 'SP_Swallowed_Dead', pred)
			-- if pred is a prey of another pred, prey will be transferred to the outer pred. Used when prey struggles out or pred dies, since pred cannot use regurgitate while being swallowed (INCAPACITATED)
			if PreyPredPairs[pred] ~= nil then
				PersistentVars['PreyWeightTable'][pred] = PersistentVars['PreyWeightTable'][pred] - PersistentVars['PreyWeightTable'][k]
				PersistentVars['FakePreyWeightTable'][pred] = PersistentVars['FakePreyWeightTable'][pred] - PersistentVars['FakePreyWeightTable'][k]
				if Osi.HasActiveStatus(pred, 'SP_Swallowed_Lethal') ~= 0 then
					SP_SwallowPrey(PreyPredPairs[pred], k, 'SP_Swallowed_Lethal', false)
				elseif Osi.HasActiveStatus(pred, 'SP_Swallowed_Endo') ~= 0 then
					SP_SwallowPrey(PreyPredPairs[pred], k, 'SP_Swallowed_Endo', false)
				else
					SP_SwallowPrey(PreyPredPairs[pred], k, 'SP_Swallowed_Dead', false)
				end
			-- if no nesting, free prey
			else
				PersistentVars['PreyWeightTable'][k] = nil -- instead of removeweight
				PersistentVars['FakePreyWeightTable'][k] = nil -- instead of removeweight
				-- Tag that disables downed state
				if PersistentVars['DisableDownedPreyTable'][k] ~= nil then
					Osi.ClearTag(k, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
					PersistentVars['DisableDownedPreyTable'][k] = nil
					_P('DisableDownedPreyTable')
					_D(PersistentVars['DisableDownedPreyTable'])
				end
				Osi.SetDetached(k, 0)
				Osi.SetVisible(k, 1)
				table.insert(markedForRemoval, k)
				if spell == 'Absorb' then
					Osi.MoveAllItemsTo(k, pred, 1, 1, 0, 1)
					Osi.MoveAllStoryItemsTo(k, pred, 1, 0)
					Osi.TeleportToPosition(k, 100000, 0, 100000, "", 0, 0, 0, 1, 0)
				else
					local predX, predY, predZ = Osi.getPosition(pred)
					local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred) -- Y-rotation == yaw
					predYRotation = predYRotation * math.pi / 180 -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
					local newX = predX+RegurgDist*math.cos(predYRotation) -- equation for rotating a vector in the X dimension
					local newZ = predZ+RegurgDist*math.sin(predYRotation) -- equation for rotating a vector in the Z dimension
					Osi.TeleportToPosition(k, newX, predY, newZ, "", 0, 0, 0, 0, 0) -- places prey at pred's location, vaguely in front of them.
				end
			end
            
        end
    end
	
	-- check if no one was regurgitated - shouldn't happen
	if #markedForRemoval == 0 then
		_P("WARNING, no one was regurgitated by " .. pred)
	end
	-- remove regurgitated prey from the table
	_P("Clearing Table")
	for _, v in ipairs(markedForRemoval) do
		PreyPredPairs[v] = nil
		_P("prey removed: " .. v)
	end
	
	-- if pred has no more prey inside
    if PredPreyTable[pred] == nil or #PredPreyTable[pred] <= 0 then
        Osi.RemoveStatus(pred, 'SP_Stuffed')
        Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
    end
	_P("New table: ")
	_D(PreyPredPairs)
	-- since SP_RegurgitatePrey is used when a prey is released for any reason (including death), I moved this here to avoid desync
	PersistentVars['PreyPredPairs'] = SP_Deepcopy(PreyPredPairs)
	PersistentVars['PredPreyTable'] = SP_Deepcopy(PredPreyTable)
	
	-- updates the weight of the pred
	SP_UpdateWeight(pred)
	_P('Ending Regurgitation')
end

---changes the amount of Weight Placeholders by looking for weights of all prey in pred
---@param pred GUIDSTRING @guid of pred
function SP_UpdateWeight(pred)
	local allPrey = PredPreyTable[pred]
	_P("ALLPREY")
	_D(allPrey)
	local newWeight = 0
	for _, v in pairs(allPrey) do
		newWeight = newWeight + (PersistentVars['PreyWeightTable'][v] or 0)
	end
	_P("Changing weight of " .. pred .. " to " .. newWeight)
	Osi.CharacterRemoveTaggedItems(pred, '0e2988df-3863-4678-8d49-caf308d22f2a', 9999)

	Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, newWeight, 0)
	-- this is very important, it fixes inventory weight not updationg properly when removing items. this is the only solution that worked. 8d3b74d4-0fe6-465f-9e96-36b416f4ea6f is removed immediately after being added (in the main script)
	Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)
	
	SP_UpdateBelly(pred, newWeight)
	
	_P('NEW WEIGHTS ' .. pred)
	_D(PersistentVars['PreyWeightTable'])
	SP_DelayCallTicks(5, function() SP_MakeWeightBound(pred) end)
end

---@param pred GUIDSTRING @guid of pred
---@param weight integer @how many weight placeholders in inventory
function SP_UpdateBelly(pred, weight)
	-- only female belly is currently implemented
	if Osi.GetBodyType(pred, 1) ~= "Female" then
		_P("Character is not female, they are " .. Osi.GetBodyType(pred, 1))
		return
	end
	local predRace = Osi.GetRace(pred, 1)
	-- these races use the same or similar model
	if string.find(predRace, 'Drow') ~= nil or string.find(predRace, 'Elf') ~= nil or string.find(predRace, 'Human') ~= nil or string.find(predRace, 'Gith') ~= nil or string.find(predRace, 'Orc') ~= nil or string.find(predRace, 'Aasimar') ~= nil or string.find(predRace, 'Tiefling') ~= nil then
		predRace = 'Human'
	end
	if BellyTableFemale[predRace] == nil then
		return
	end
	-- 1 == normal body, 2 == strong body. Did not check orks
	local bodyShape = Ext.Entity.Get(pred).CharacterCreationStats.BodyShape + 1
	-- should not happen
	if bodyShape > 2 then
		bodyShape = 1
	end
	
	-- remove when separacte orc bellies are added. Their body is closer to the strong body, so a strong belly is used
	if string.find(Osi.GetRace(pred, 1), 'Orc') ~= nil then
		bodyShape = 2
	end
	
	-- determines the belly weight thresholds
	local weightStage = 0
	if weight > 235 then
		weightStage = 5
	elseif weight > 150 then
		weightStage = 4
	elseif weight > 70 then
		weightStage = 3
	elseif weight > 39 then
		weightStage = 2
	elseif weight > 8 then
		weightStage = 1
	end
	
	-- clears overrives. might break if you change bodyshape or race or gender
	for _, v in ipairs(BellyTableFemale[predRace][bodyShape]) do
		Osi.RemoveCustomVisualOvirride(pred, v)
	end
	
	-- delay is necessary, otherwise will not work
	SP_DelayCall(100, function() 
		if weightStage > 0 then
			Osi.AddCustomVisualOverride(pred, BellyTableFemale[predRace][bodyShape][weightStage])
		end
	end)
end

---Reduces weight of prey and their preds
---@param character GUIDSTRING
---@param diff integer the amount to subtract
function SP_ReduceWeightRecursive(character, diff)
	if PersistentVars['PreyWeightTable'][character] ~= nil then
		PersistentVars['PreyWeightTable'][character] = PersistentVars['PreyWeightTable'][character] - diff
		if PersistentVars['FakePreyWeightTable'][PreyPredPairs[character]] ~= nil then
			PersistentVars['FakePreyWeightTable'][PreyPredPairs[character]] = PersistentVars['FakePreyWeightTable'][PreyPredPairs[character]] - diff
			SP_ReduceWeightRecursive(PreyPredPairs[character], diff)
		end
	end
end

-- ---Adds the weight placeholder object to the pred's inventory.
-- ---@param pred CHARACTER
-- ---@param prey CHARACTER
-- function SP_AddWeight(pred, prey)
--     _P("Getting total weight of: " .. SP_GetDisplayNameFromGUID(prey))

--     local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
--     if weightPlaceholder.Weight == nil then
--         weightPlaceholder.Weight = 0
--     end

--     weightPlaceholder.Weight = weightPlaceholder.Weight + SP_GetTotalCharacterWeight(prey)
--     weightPlaceholder:Sync()

--     _P("adding weight")
--     SP_DelayCallTicks(5, function()
--         _P("Is potato in inventory: ")
--         _P(Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred))
--         if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then
--             Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1)
--         end
--         Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0)
--         SP_DelayCallTicks(1, function()
--             SP_MakeWeightBound(pred)
--         end)
--     end)
-- end

-- ---UNUSED. Adds a single weight placeholder for each prey.
-- ---Won't function til SE adds dynamic template modification,
-- ---or I do something truly gormless like make a rootTemplate
-- ---and item stats for every creature in the game.
-- ---@param pred CHARACTER
-- ---@param prey CHARACTER
-- function SP_AddWeightIndiv(pred, prey)
--     local preyName = SP_GetDisplayNameFromGUID(prey)
--     _P("Getting total weight of: " .. preyName)

--     local weightPlaceholder = Ext.Stats.Create(preyName .. "'s Body", "Object", "SP_Prey_Weight")

--     local newWeight = SP_GetTotalCharacterWeight(prey)

--     _P("New Weight: " .. newWeight)
--     weightPlaceholder.Weight = newWeight
--     weightPlaceholder:Sync()

--     _P("adding new weight object")
--     local NEW_ROOT_TEMPLATE = '' -- don't know what's supposed to be here, I'll leave it to Squidpad
--     SP_DelayCallTicks(5, function()
--         if Osi.GetItemByTemplateInUserInventory(NEW_ROOT_TEMPLATE, pred) ~= nil then
--             Osi.TemplateRemoveFrom(NEW_ROOT_TEMPLATE, pred, 1)
--         end
--         Osi.TemplateAddTo(NEW_ROOT_TEMPLATE, pred, 1, 0)
--     end)
--     return NEW_ROOT_TEMPLATE
-- end

-- ---Reduces the weight of the weight placeholder object, or removes it if it's weight is small.
-- ---@param pred CHARACTER
-- ---@param prey CHARACTER
-- function SP_ReduceWeight(pred, prey)
--     _P("Getting total weight of: " .. SP_GetDisplayNameFromGUID(prey))

--     local weightPlaceholder = Ext.Stats.Get('SP_Prey_Weight')
--     if weightPlaceholder.Weight == nil then
--         weightPlaceholder.Weight = 0
--     end
--     local newWeight = weightPlaceholder.Weight - SP_GetTotalCharacterWeight(prey)

--     if newWeight <= 0.1 then
--         newWeight = 0
--     end
--     _P("New Weight: " .. newWeight * 2)
--     weightPlaceholder.Weight = newWeight
--     weightPlaceholder:Sync()

--     _P("subtracting weight")

--     SP_DelayCallTicks(5, function()
--         _P("Potato in inventory: ")
--         _P(Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred))
--         if Osi.GetItemByTemplateInUserInventory('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred) ~= nil then
--             Osi.TemplateRemoveFrom('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1)
--         end
--         if newWeight ~= 0 then
--             Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, 1, 0)
--         end
--     end)
-- end

-- ---UNUSED. Individually removes unique weight placeholder objects from pred's inventory.
-- ---Won't function til SE adds dynamic template modification,
-- ---or I do something truly gormless like make a rootTemplate
-- ---and item stats for every creature in the game.
-- ---@param pred CHARACTER
-- ---@param itemTemplate ITEMROOT rootTemplate of weight placeholder item.
-- function SP_RemoveWeightIndiv(pred, itemTemplate)
--     _P("removing weight object")
--     if Osi.GetItemByTemplateInUserInventory(itemTemplate, pred) ~= nil then
--         Osi.TemplateRemoveFrom(itemTemplate, pred, 1)
--     end
-- end

---Teleports prey to pred.
---@param pred CHARACTER
function SP_TelePreyToPred(pred)
    _P('Prey moved to Pred Location')
    for _, v in pairs(PredPreyTable[pred]) do
        Osi.TeleportTo(v, pred, "", 0, 0, 0, 0, 0)
    end
end

---Checks if eating a character would exceed your carry limit.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_CanFitPrey(pred, prey)
    local predData = Ext.Entity.Get(pred)
    local predRoom = predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight

    if SP_GetTotalCharacterWeight(prey) > predRoom then
        _P("Can't fit " .. SP_GetDisplayNameFromGUID(prey) .. " inside of " .. SP_GetDisplayNameFromGUID(pred) ..
               "'s stomach!")
        return false
    else
        return true
    end
end

---Recursively finds the top-level predator, given a prey
---@param prey CHARACTER
function SP_GetApexPred(prey)
    if PreyPredPairs[prey] == nil then
        return prey
    else
        return SP_GetApexPred(PreyPredPairs[prey])
    end
end

---Handles rolling checks.
---@param pred CHARACTER
---@param prey CHARACTER
---@param eventName string Name that RollResult should look for. No predetermined values, can be whatever.
function SP_VoreCheck(pred, prey, eventName)
	local advantage = 0
	if ConfigVars.VoreDifficulty.value == "easy" then
		advantage = 1
	end
    if eventName == 'StruggleCheck' then
        _P("Rolling struggle check")
        Osi.RequestPassiveRollVersusSkill(prey, pred, "SkillCheck", "Strength", "Constitution", 0, advantage, eventName)
    elseif eventName == 'SwallowLethalCheck' then
        _P('Rolling to resist swallow')

        if Osi.HasSkill(prey, "Acrobatics") > Osi.HasSkill(prey, "Athletics") then
            _P('Using Acrobatics')
            Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Acrobatics", advantage, 0, eventName)
        else
            _P('Using Athletics')
            Osi.RequestPassiveRollVersusSkill(pred, prey, "SkillCheck", "Athletics", "Athletics", advantage, 0, eventName)
        end
    end
end

---UNUSED. Adds spell for regurgitating specific creature, currently bugged.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_AddCustomRegurgitate(pred, prey)
    if Ext.Stats.Get("SP_Regurgitate_" .. prey) == nil then
        local newRegurgitate = Ext.Stats.Create("SP_Regurgitate_" .. prey, "SpellData", "SP_Regurgitate_One")
        newRegurgitate.DescriptionParams = SP_GetDisplayNameFromGUID(prey)
        newRegurgitate:Sync()
    end

    SP_DelayCallTicks(5, function()
        local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
        local containerList = regurgitateBase.ContainerSpells
        containerList = containerList .. ";SP_Regurgitate_" .. prey
        regurgitateBase.ContainerSpells = containerList
        regurgitateBase:Sync()
        _P("containerList: " .. containerList)
        if Osi.HasSpell(pred, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(pred, 'SP_Regurgitate', 0, 1)
    end)
end

---UNUSED. Removes spell for regurgitating specific creature, currently bugged.
---@param pred CHARACTER
---@param prey CHARACTER
function SP_RemoveCustomRegurgitate(pred, prey)
    local regurgitateBase = Ext.Stats.Get("SP_Regurgitate")
    local containerList = regurgitateBase.ContainerSpells
    containerList = SP_RemoveSubstring(containerList, ";SP_Regurgitate_" .. prey)
    _P("containerlist: " .. containerList)
    regurgitateBase.ContainerSpells = containerList
    regurgitateBase:Sync()

    SP_DelayCallTicks(5, function()
        if Osi.HasSpell(pred, 'SP_Regurgitate') ~= 0 then
            Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
        end
        Osi.AddSpell(pred, 'SP_Regurgitate', 0, 1)
    end)
end

---Adds the 'Bound' status to the weight object so that players can't drop it.
---@param pred CHARACTER
function SP_MakeWeightBound(pred)
    local itemList = Ext.Entity.Get(pred).InventoryOwner.PrimaryInventory:GetAllComponents().InventoryContainer.Items
    for _, v in ipairs(itemList) do
        local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
        if SP_GetDisplayNameFromGUID(uuid) == 'Weight Placeholder' then
            Osi.ApplyStatus(uuid, 'SP_Item_Bound', -1)
        end
    end
end



---Console command for changing config variables.
---@param var string Name of the variable to change.
---@param value any Value to change the variable to.
function VoreConfig(var, value)
    if ConfigVars.var ~= nil then
        if type(value) == type(ConfigVars.var) then
            ConfigVars.var = value
			local json = Ext.Json.Stringify(ConfigVars, {Beautify = true})
			Ext.IO.SaveFile("DevouringAndDigesting/VoreConfig.json", json)
        else
            _P("Entered value " .. value .. " is of type " .. type(value) .. " while " .. var .. " requires a value of type " .. type(ConfigVars.var))
		end
    end
end

---Console command for printing config options and states.
function VoreConfigOptions()
    _P("Vore Mod Configuration Options: ")
    for k, v in pairs(ConfigVars) do
        _P(k .. ": " .. k.description)
        _P("Currently set to " .. k.value)
    end

end
