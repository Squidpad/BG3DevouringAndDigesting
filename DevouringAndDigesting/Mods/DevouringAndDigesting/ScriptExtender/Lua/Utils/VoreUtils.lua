
Ext.Require("Utils/Config.lua")

-- needs to be here to prevent PCs from being teleported beneath the map
-- maybe it's better to teleport them
-- 1. When you click on companion's portrait, camera will move to them, which will force the game to load the world around them. If they are teleporten outside of the map (not beneath), there is nothing to load
-- 2. When an character dies, their body becomes lootable. Even if they are invisible and detached, the player can still highlight & loot them with alt key.
local CompanionsSet = {
	["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = true,
	["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = true,
	["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = true,
	["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = true,
	["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = true,
	["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = true,
	["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = true,
	["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = true,
	["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = true,
	["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = true,
}

-- A prey can only exist within one stomach, so it's better to use them as unique keys in a dictionary/table, and it allows easier implementation of multiple prey and voreception (nested vore) without nested tables
PreyTablePred = {}

-- CharacterCreationAppearanceVisuals table for women. Goes like this: race -> bodyshape (1 == weak / 2 == strong) -> belly size (1/2/3/4/5)
BellyTableFemale = {Human = {{
	"5b04165d-2ec9-47f9-beff-0660640fc602",
	"5660e004-e2af-4f3a-ae76-375408cb78c3",
	"fafef7ab-087f-4362-9436-3e63ef7bcd95",
	"4a404594-e28d-4f47-b1c2-2ef593961e33",
	"78fc1e05-ee83-4e6c-b14f-6f116e875b03",
	"b10b965b-9620-48c2-9037-0556fd23d472",
	"14388c37-34ab-4963-b61e-19cea0a90e39"
}, {
	"4bfa882a-3bef-49b8-9e8a-21198a2dbee5",
	"4741a71a-8884-4d3d-929d-708e350953bb",
	"9950ba83-28ea-4680-9905-a070d6eabfe7",
	"4e698e03-94b8-4526-9fa5-5feb1f78c3b0", 
	"e250ffe9-a94c-44b4-a225-f8cf61ad430d",
	"02c9846c-200d-47cb-b381-1ceeb4280774",
	"73aae7c2-49ef-4cac-b1b9-b3cfa6a4a31a"

}}}

---Populates the PreyTablePred
---@param pred GUIDSTRING @guid of pred
---@param prey GUIDSTRING @guid of prey
function SP_FillPredPreyTable(pred, prey)
    _P("Filling Table")
	
	if PreyTablePred[prey] ~= nil then
		_P("Transferring prey " .. prey .. " from " .. PreyTablePred[prey] .. " to " .. pred)
	end
	PreyTablePred[prey] = pred
	
	_P("ADDING SPELL")
	Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
	
	PersistentVars['PreyTablePred'] = SP_Deepcopy(PreyTablePred)
	_D(PreyTablePred)
end

---should be called in any situation when prey must be released
---@param pred GUIDSTRING guid of pred
---@param prey GUIDSTRING guid of prey
---@param swallowType string internal name of Status Effect
---@param notNested bool if prey is not transferred to another stomach
function SP_SwallowPrey(pred, prey, swallowType, notNested)
	_P('Swallowing')
	Osi.ApplyStatus(prey, swallowType, -1, 1, pred)
	Osi.ApplyStatus(pred, "SP_Stuffed", 1, 1, pred)
	SP_FillPredPreyTable(pred, prey)
	if notNested then
		Osi.SetDetached(prey, 1)
		Osi.SetVisible(prey, 0)
		-- removes downed status if prey is already downed
		Osi.ApplyStatus(prey, "SP_Being_Swallowed", 0, 1, pred)
		PersistentVars['PreyWeightTable'][prey] = math.floor(SP_GetTotalCharacterWeight(prey)) -- instead of addweight
		PersistentVars['FakePreyWeightTable'][prey] = math.floor(SP_GetTotalCharacterWeight(prey)) -- instead of addweight
		-- Tag that disables downed state
		if Osi.IsTagged(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22') ~= 1 then
			Osi.SetTag(prey, '7095912e-fcb9-41dd-aec3-3cf7803e4b22')
			PersistentVars['DisableDownedPreyTable'][prey] = true
			_P('DisableDownedPreyTable')
			_D(PersistentVars['DisableDownedPreyTable'])
		end
		SP_UpdateWeight(pred, true)
	end
	_P('Swallowing END')
end


---swallow an item
---@param pred GUIDSTRING guid of pred
---@param item GUIDSTRING guid of item
function SP_SwallowItem(pred, item)
	if Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1 then
		local stomach = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
		Osi.ToInventory(item, stomach, 9999, 0, 0)
		if Osi.HasActiveStatus(pred, "SP_Stuffed") == 0 then
			Osi.ApplyStatus(pred, "SP_Stuffed", 1, 1, pred)
		end
		Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
		SP_DelayCallTicks(4, function() SP_UpdateWeight(pred, true) end)
    else	
		Osi.TemplateAddTo('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1, 0)
		SP_DelayCallTicks(4, function() SP_SwallowItem(pred, item) end)
	end
end

---swallow all items from a container
---this should be only used for moving items between prey and pred during nested vore, since it does not check if items fit in pred's inventory
---@param pred GUIDSTRING guid of pred
---@param container GUIDSTRING guid of item
function SP_SwallowAllItems(pred, container)
	if Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1 then
		local stomach = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
		Osi.MoveAllItemsTo(container, stomach, 0, 0, 0, 0)
		Osi.MoveAllStoryItemsTo(container, stomach, 0, 0)
		if Osi.HasActiveStatus(pred, "SP_Stuffed") == 0 then
			Osi.ApplyStatus(pred, "SP_Stuffed", 1, 1, pred)
		end
		Osi.AddSpell(pred, 'SP_Regurgitate', 0, 0)
		SP_DelayCallTicks(4, function() SP_UpdateWeight(pred, true) end)
    else	
		Osi.TemplateAddTo('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1, 0)
		SP_DelayCallTicks(4, function() SP_SwallowAllItems(pred, container) end)
	end
end

---should be called in any situation when prey must be released, including pred's death
---@param pred CHARACTER	guid of pred
---@param prey CHARACTER	guid of prey
---@param preyState integer state of prey to regurgitate 0 == alive, 1 == dead, 2 == all
---@param spell string	internal name of spell (this does not reflect the in-game spell used)
function SP_RegurgitatePrey(pred, prey, preyState, spell)
    _P('Starting Regurgitation')

    _P('Targets: ' .. prey)
    local markedForRemoval = {}
	-- find prey to remove, clear their status, mark them for removal
    for k, v in pairs(PreyTablePred) do
		local preyAlive = Osi.IsDead(k)
		_P('Prey is dead: ' .. preyAlive .. '        ' .. k)
        if v == pred and (prey == "All" or k == prey) and (preyState == 2 or (preyAlive == preyState and (preyState == 0 or (PersistentVars['PreyWeightTable'][k] <= PersistentVars['FakePreyWeightTable'][k] // 5)))) then
			_P('Pred:' .. v)
			_P('Prey:' .. k)
			Osi.RemoveStatus(k, 'SP_Swallowed_Endo', pred)
			Osi.RemoveStatus(k, 'SP_Swallowed_Lethal', pred)
			Osi.RemoveStatus(k, 'SP_Swallowed_Dead', pred)
			-- (voreception) if pred is a prey of another pred, prey will be transferred to the outer pred. Used when prey struggles out or pred dies, since pred cannot use regurgitate while being swallowed (INCAPACITATED)
			if PreyTablePred[pred] ~= nil then
				-- reduce pred weight in prey weight tables, since they are both prey and pred
				PersistentVars['PreyWeightTable'][pred] = PersistentVars['PreyWeightTable'][pred] - PersistentVars['PreyWeightTable'][k]
				PersistentVars['FakePreyWeightTable'][pred] = PersistentVars['FakePreyWeightTable'][pred] - PersistentVars['PreyWeightTable'][k]
				if Osi.HasActiveStatus(pred, 'SP_Swallowed_Lethal') ~= 0 then
					SP_SwallowPrey(PreyTablePred[pred], k, 'SP_Swallowed_Lethal', false)
				elseif Osi.HasActiveStatus(pred, 'SP_Swallowed_Endo') ~= 0 then
					SP_SwallowPrey(PreyTablePred[pred], k, 'SP_Swallowed_Endo', false)
				else
					SP_SwallowPrey(PreyTablePred[pred], k, 'SP_Swallowed_Dead', false)
				end
			-- if no voreception, free prey
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
					local predData = Ext.Entity.Get(pred)
					local predRoom = predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight - 100
					_P("Predroom: " .. predRoom)
					local itemList = Ext.Entity.Get(k).InventoryOwner.Inventories

					local rotationOffset = 0
					local rotationOffset1 = 360 // (#itemList)
					
					for _, t in pairs(itemList) do
						local nextInventory = t:GetAllComponents().InventoryContainer.Items
						
						for k, v in pairs(nextInventory) do
							local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
							local itemWeight = v.Item.Data.Weight
							
							if predRoom > itemWeight then
								Osi.ToInventory(uuid, pred, 9999, 0, 0)
								predRoom = predRoom - itemWeight
							else
								local predX, predY, predZ = Osi.getPosition(pred)
								local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred) -- Y-rotation == yaw
								predYRotation = (predYRotation + rotationOffset) * math.pi / 180 -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
								local newX = predX+1*math.cos(predYRotation) -- equation for rotating a vector in the X dimension
								local newZ = predZ+1*math.sin(predYRotation) -- equation for rotating a vector in the Z dimension
								Osi.ItemMoveToPosition(uuid, newX, predY, newZ, 100000, 100000) -- places prey at pred's location, vaguely in front of them.
								rotationOffset = rotationOffset + rotationOffset1
							end
						end
					end
					Osi.TeleportToPosition(k, 100000, 0, 100000, "", 0, 0, 0, 1, 0)
				else
					local predX, predY, predZ = Osi.getPosition(pred)
					local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred) -- Y-rotation == yaw
					predYRotation = predYRotation * math.pi / 180 -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
					local newX = predX + ConfigVars.RegurgDist.value * math.cos(predYRotation) -- equation for rotating a vector in the X dimension
					local newZ = predZ + ConfigVars.RegurgDist.value * math.sin(predYRotation) -- equation for rotating a vector in the Z dimension
					Osi.TeleportToPosition(k, newX, predY, newZ, "", 0, 0, 0, 0, 0) -- places prey at pred's location, vaguely in front of them.
				end
			end
            
        end
    end
	
	local regItems = false
	local hasStomach = Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1
	if hasStomach and preyState ~= 1 and spell ~= "LevelChange" and prey == 'All' then
		-- since (item) stomach is removed after a delay, this is necessary to tell the weight update function that it is empty
		regItems = true
		local stomach = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
		if PreyTablePred[pred] ~= nil then
			local weightDiff = Ext.Entity.Get(stomach).InventoryWeight.Weight // 1000
			PersistentVars['PreyWeightTable'][pred] = PersistentVars['PreyWeightTable'][pred] - weightDiff
			PersistentVars['FakePreyWeightTable'][pred] = PersistentVars['FakePreyWeightTable'][pred] - weightDiff
			SP_SwallowAllItems(PreyTablePred[pred], stomach)
		else
			local itemList = Ext.Entity.Get(stomach).InventoryOwner.PrimaryInventory:GetAllComponents().InventoryContainer.Items
			
			-- prevents items from being stuck in each other by placing theim in circle around pred
			local rotationOffset = 0
			local rotationOffset1 = 360 // (#itemList)
			for k, v in pairs(itemList) do
				local uuid = v.Item:GetAllComponents().Uuid.EntityUuid
				local predX, predY, predZ = Osi.getPosition(pred)
				local predXRotation, predYRotation, predZRotation = Osi.GetRotation(pred) -- Y-rotation == yaw
				predYRotation = (predYRotation + rotationOffset) * math.pi / 180 -- Osi.GetRotation() returns degrees for some ungodly reason, let's fix that :)
				local newX = predX + ConfigVars.RegurgDist.value * math.cos(predYRotation) -- equation for rotating a vector in the X dimension
				local newZ = predZ + ConfigVars.RegurgDist.value * math.sin(predYRotation) -- equation for rotating a vector in the Z dimension
				Osi.ItemMoveToPosition(uuid, newX, predY, newZ, 100000, 100000) -- places prey at pred's location, vaguely in front of them.
				_P("Moved Item " .. uuid)
				rotationOffset = rotationOffset + rotationOffset1
			end
		end
		-- this delay is important, otherwise items would be deleted
		SP_DelayCallTicks(4, function() Osi.TemplateRemoveFrom('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred, 1) end)
	end
	-- check if no one was regurgitated - shouldn't happen
	if #markedForRemoval == 0 then
		_P("WARNING, no prey was regurgitated by " .. pred)
	end
	-- remove regurgitated prey from the table
	for _, v in ipairs(markedForRemoval) do
		PreyTablePred[v] = nil
	end
	
	-- if pred has no more prey inside
    if #SP_GetAllPrey(pred) <= 0 and (hasStomach and regItems or not hasStomach) then
        Osi.RemoveStatus(pred, 'SP_Stuffed')
        Osi.RemoveSpell(pred, 'SP_Regurgitate', 1)
    end
	_P("New table: ")
	_D(PreyTablePred)
	-- since SP_RegurgitatePrey is used when a prey is released for any reason (including death), I moved this here to avoid desync
	PersistentVars['PreyTablePred'] = SP_Deepcopy(PreyTablePred)
	
	-- updates the weight of the pred if the items or prey were regurgitated
	if regItems or (#markedForRemoval > 0) then
		SP_UpdateWeight(pred, not regItems)
	end

	_P('Ending Regurgitation')
end

---Given a pred, fetches all their prey
---@param pred GUIDSTRING guid of pred
function SP_GetAllPrey(pred)
	local allPrey = {}
    for k, v in pairs(PreyTablePred) do
        if v == pred then
			table.insert(allPrey, k)
		end
    end
    return allPrey
end

---finds all unique Preds
function SP_GetUniquePreds()
	local allPreds = {}
	for k, v in pairs(PreyTablePred) do
        allPreds[v] = (allPreds[v] or 0) + 1
    end
	return allPreds
end

---changes the amount of Weight Placeholders by looking for weights of all prey in pred
---@param pred GUIDSTRING guid of pred
---@param items boolean look for stomach item in pred?
function SP_UpdateWeight(pred, items)
	local allPrey = SP_GetAllPrey(pred)
	local newWeight = 0
	for _, v in pairs(allPrey) do
		newWeight = newWeight + (PersistentVars['PreyWeightTable'][v] or 0)
	end
	-- for item vore
	local newWeightVisual = newWeight
	if items and Osi.TemplateIsInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred) == 1 then
		local stomach = Osi.GetItemByTemplateInInventory('eb1d0750-903e-44a9-927e-85200b9ecc5e', pred)
		newWeightVisual = newWeightVisual + Ext.Entity.Get(stomach).InventoryWeight.Weight // 1000
	end
	_P("Changing weight of " .. pred .. " to " .. newWeightVisual)
	Osi.CharacterRemoveTaggedItems(pred, '0e2988df-3863-4678-8d49-caf308d22f2a', 9999)
	Osi.TemplateAddTo('f80c2fd2-5222-44aa-a68e-b2faa808171b', pred, newWeight, 0)
	-- this is very important, it fixes inventory weight not updating properly when removing items. this is the only solution that worked. 8d3b74d4-0fe6-465f-9e96-36b416f4ea6f is removed immediately after being added (in the main script)
	Osi.TemplateAddTo('8d3b74d4-0fe6-465f-9e96-36b416f4ea6f', pred, 1, 0)
	
	SP_UpdateBelly(pred, newWeightVisual)
	-- this will break stuff, SP_ReduceWeightRecursive should be used on prey when their weight was changed for a reson other than regurgitation, and the weight of preds should be updated
	-- if I understand correctly what the !SlowDigestion should do - instantly reduce prey's weight on their death and make them absorbable/disposable - I have impemented it in SP_OnDeath 
	-- if !ConfigVars.SlowDigestion.value then
		-- SP_ReduceWeightRecursive(pred, 999999999)
	-- end
end

---@param pred GUIDSTRING guid of pred
---@param weight integer how many weight placeholders in inventory
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
	local bodyShape = 1
	local tags = Ext.Entity.Get(pred).Tag.Tags
	for k, v in pairs(tags) do
		if v == "d3116e58-c55a-4853-a700-bee996207397" then
			bodyShape = 2
		end
	end

	-- remove when separacte orc bellies are added. Their body is closer to the strong body, so a strong belly is used
	if string.find(Osi.GetRace(pred, 1), 'Orc') ~= nil then
		bodyShape = 2
	end
	
	-- determines the belly weight thresholds. Slightly reduced them because of realistic carry weight limits
	local weightStage = 0
	if weight > 420 then
		weightStage = 7
	elseif weight > 300 then
		weightStage = 6
	elseif weight > 220 then
		weightStage = 5
	elseif weight > 135 then
		weightStage = 4
	elseif weight > 69 then
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
	SP_DelayCallTicks(2, function() 
		if weightStage > 0 then
			Osi.AddCustomVisualOverride(pred, BellyTableFemale[predRace][bodyShape][weightStage])
		end
	end)
end

---checks if eating a character would exceed your carry limit
---@param pred GUIDSTRING guid of pred
---@param prey GUIDSTRING guid of prey
function SP_CanFitPrey(pred, prey)
    local predData = Ext.Entity.Get(pred)
    local predRoom = (predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight) / 1000
    if SP_GetTotalCharacterWeight(prey) > predRoom then
        _P("Can't fit " .. SP_GetDisplayNameFromGUID(prey) .. " inside of " .. SP_GetDisplayNameFromGUID(pred) .. "'s stomach!")
        return false
    else
        return true
    end 
end

---checks if eating an item would exceed your carry limit
---@param pred GUIDSTRING guid of pred
---@param item GUIDSTRING guid of item
function SP_CanFitItem(pred, item)
	local predData = Ext.Entity.Get(pred)
    local predRoom = predData.EncumbranceStats["HeavilyEncumberedWeight"] - predData.InventoryWeight.Weight
    local itemData = Ext.Entity.Get(item).Data.Weight
	if predRoom > itemData then
		return true
	else
		_P("Can't fit " .. item " inside " .. pred)
		return false
	end

end

---Handles rolling checks
---@param pred GUIDSTRING guid of pred
---@param prey GUIDSTRING guid of prey
---@param eventName string name that RollResult should look for. No predetermined values, can be whatever
function SP_VoreCheck(pred, prey, eventName)
	local advantage = 0
	if ConfigVars.VoreDifficulty.value == 'easy' then
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


---Reduces weight of prey and their preds, do not use this for regurgitation during voreception, since pred's weight would stay the same
---@param character GUIDSTRING guid of character
---@param diff integer the amount to subtract
---@param updateWeight bool update visual weight / placeholders of characters? this should be false in the OnReset functions, otherwise it might update the weight of a single pred multiple times during one tick and bug out osiris
function SP_ReduceWeightRecursive(character, diff, updateWeight)
	if PersistentVars['PreyWeightTable'][character] ~= nil then
		PersistentVars['PreyWeightTable'][character] = PersistentVars['PreyWeightTable'][character] - diff
		if updateWeight then
			SP_UpdateWeight(character, true)
		end
		if PersistentVars['FakePreyWeightTable'][PreyTablePred[character]] ~= nil then
			PersistentVars['FakePreyWeightTable'][PreyTablePred[character]] = PersistentVars['FakePreyWeightTable'][PreyTablePred[character]] - diff
			SP_ReduceWeightRecursive(PreyTablePred[character], diff)
		elseif updateWeight and PreyTablePred[character] ~= nil then
			SP_UpdateWeight(PreyTablePred[character], true)
		end
	end
end

---Console command for changing config variables.
---@param var string Name of the variable to change.
---@param val any Value to change the variable to.
function VoreConfig(var, val)
    if ConfigVars.var ~= nil then
        if type(val) == type(ConfigVars.var) then
            ConfigVars.var.value = val
			local json = Ext.Json.Stringify(ConfigVars, {Beautify = true})
			Ext.IO.SaveFile("DevouringAndDigesting/VoreConfig.json", json)
			_P(var .. " updated to have value " .. val)
        else
            _P("Entered value " .. val .. " is of type " .. type(val) .. " while " .. var .. " requires a value of type " .. type(ConfigVars.var.value))
		end
    end
end

---Console command for printing config options and states.
function VoreConfigOptions()
    _P("Vore Mod Configuration Options: ")
	_D(ConfigVars)
    for k, v in pairs(ConfigVars) do
        _P(k .. ": " .. v.description)
        _P("Currently set to " .. tostring(v.value))
    end

end
