----------------------------------------------------------------------
--GLOBAL TRANSFER NETWORK
----------------------------------------------------------------------
function Test_GTNFunctions()
	local numScouts = Engine.GetNumOfScouts()
	print("GTN: Test GetNumOfScouts: " .. numScouts)
	
	for scoutIndex = 1, numScouts do
		scoutData = {Engine.GetScoutByIndex( scoutIndex-1 )}
		Test_GTNPrintScoutData( scoutData, scoutIndex )
	end
	
	local numShoppingListItems = Engine.GetNumOfShoppingListItems()
	print("GTN: Number of shopping list items: " .. numShoppingListItems )
	
	for shopListItemIndex = 1, numShoppingListItems do
		Test_GTNShoppingListItems(shopListItemIndex)
	end
end

-- These "enums" are defined so that you can access data directly from the arrays that are returned by the function calls (look in the triggers)
SCOUT_DATA_SCOUTID = 1
SCOUT_DATA_REGIONID = SCOUT_DATA_SCOUTID + 1
SCOUT_DATA_NATIONALITY_ID = SCOUT_DATA_REGIONID + 1
SCOUT_DATA_EXPERIENCE = SCOUT_DATA_NATIONALITY_ID + 1
SCOUT_DATA_KNOWLEDGE = SCOUT_DATA_EXPERIENCE + 1
SCOUT_DATA_LEVEL = SCOUT_DATA_KNOWLEDGE + 1
SCOUT_DATA_HIRING_FEE = SCOUT_DATA_LEVEL + 1
SCOUT_DATA_FIRST_NAME = SCOUT_DATA_HIRING_FEE + 1
SCOUT_DATA_LAST_NAME = SCOUT_DATA_FIRST_NAME + 1
SCOUT_DATA_MAX = SCOUT_DATA_LAST_NAME + 1

PLAYER_DATA_PLAYER_ID = 1
PLAYER_DATA_REPORT_STATUS = PLAYER_DATA_PLAYER_ID + 1
PLAYER_DATA_SHOPPING_LIST_INDEX= PLAYER_DATA_REPORT_STATUS + 1
PLAYER_DATA_MAX = PLAYER_DATA_SHOPPING_LIST_INDEX + 1

AREA_MISSION_DATA_COUNTRY_ID = 1
AREA_MISSION_DATA_START_DATE = AREA_MISSION_DATA_COUNTRY_ID + 1
AREA_MISSION_NUM_PLAYERS_FOUND = AREA_MISSION_DATA_START_DATE + 1
AREA_MISSION_MAX = AREA_MISSION_NUM_PLAYERS_FOUND + 1

----------------------------------------------------------------------
function Test_GTNPrintScoutData( scoutData, scoutIndex )
	local scoutDataFields = { "SCOUT_ID", "REGION_ID", "NATIONALITY_ID", "EXPERIENCE", "KNOWLEDGE", "LEVEL", "HIRING_FEE", "FIRST_NAME", "LAST_NAME" }
	local playerDataFields = { "PLAYER_ID", "REPORT_STATUS", "CURRENT_SHOPPING_LIST_INDEX" }
	local areaMissionDataFields = { "COUNTRY_ID", "START_DATE", "NUM_PLAYERS_FOUND" }
	
	print("GTN: ------- Scout #" .. scoutIndex .. " --------");
	
	-- Information about the scout
	for fieldIndex = 1, #scoutDataFields do
		print(" GTN: " .. fieldIndex .. ") " .. scoutDataFields[fieldIndex] .. ": " .. scoutData[fieldIndex] )
	end
	
	local scoutId = scoutDataFields[1];
	
	-- Found Players Information
	local numPlayersFound = Engine.GetNumPlayersFoundByScout(scoutId)
	print(" GTN: Total num of players found = " .. numPlayersFound )
	
	for playerIndex = 1, numPlayersFound do
		playerData = {Engine.GetPlayerFoundByScoutByIndex(scoutId, playerIndex-1)}
		
		print(" GTN: Player: -------- " .. playerIndex .. " ---------")
		for playerDataFieldIndex = 1, #playerDataFields do
			print(" GTN: " .. playerIndex .. ") " .. playerDataFields[playerDataFieldIndex] .. " = " .. playerData[playerDataFieldIndex] )
		end
	end
	
	-- Mission Information
	areaMissionData = { Engine.GetAreaMissionForScout( scoutId ) }
	if( #areaMissionData > 0 ) then
		print(" GTN: Area Mission found ")
		for missiondataFieldIndex = 1, #areaMissionDataFields do
			print(" GTN: " .. missiondataFieldIndex .. ") " .. areaMissionDataFields[missiondataFieldIndex] .. " = " .. areaMissionData[missiondataFieldIndex] )
		end
	end 
	
	playerMissionData = {Engine.GetPlayerMissionForScout( scoutId )}
	if( #playerMissionData > 0 ) then
		print(" GTN: Player Mission: Players Found = " .. playerMissionData[1] )
	end
end

----------------------------------------------------------------------
function Test_GTNShoppingListItems( shopListItemIndex )
	print("GTN: ------- ShoppingListItem #" .. shopListItemIndex .. " --------");
	local roleData = {Engine.GetRoleForShoppingListItemAt(shopListItemIndex-1)}
	if( #roleData > 0 ) then
		print(" GTN: Role = " .. roleData[1] )
	else
		print(" GTN: ShoppingListItem " .. shopListItemIndex .. " has role = Any" )
	end
	
	local adjectives = {Engine.GetAdjectivesForShoppingListItemAt(shopListItemIndex-1)}
	for adjIndex = 1, #adjectives do
		print(" GTN: Adj " .. adjIndex .. ") " .. adjectives[adjIndex] )
	end
end

----------------------------------------------------------------------
function Trigger_GTN_ScoutIsSent( scoutId, countryId )
	areaMissionData = { Engine.GetAreaMissionForScout( scoutId ) }
	print( "GTN: Scout " .. scoutId .. " was sent to country " .. areaMissionData[AREA_MISSION_DATA_COUNTRY_ID] )
end

----------------------------------------------------------------------
function Trigger_GTN_ScoutReturnsWithReport( scoutId, noOfNewFoundScouts )
	local numPlayersFound = Engine.GetNumPlayersFoundByScout( scoutId )
	print(" GTN: Scout " .. scoutId .. " returns with report about " .. numPlayersFound .. " players")
	
	-- You can go through all of them and test stuff for each
	for playerIndex = 1, numPlayersFound do
		playerData = {Engine.GetPlayerFoundByScoutByIndex(scoutId, playerIndex-1)}
		
		-- PLAYER_DATA_REPORT_STATUS = 0 (OLD), 1 (NEW), 2 (UPDATED)
		if( playerData[PLAYER_DATA_REPORT_STATUS] == 1 ) then
			print(" GTN: New Player Found: " .. playerData[PLAYER_DATA_PLAYER_ID] )
		end
	end
	
	-- Or you can get it from the parameter
	print(" GTN: Total Additions: " .. noOfNewFoundScouts )
	
end

----------------------------------------------------------------------
function Trigger_GTN_TransferMoveComplete( scoutId, playerId, researchLevel, lastDayScouted )
	print(" GTN: Player: " .. playerId .. " which was scouted by Scout: " .. scoutId .. " has transfered! " )
end
