function ExamineFor_StupidBid( buyingTeamId, playerId, marketValue, marketWage, moneyOffered, sellingTeamId )
	local overallDiff = Tuning.STUPID.overallDiff --15
	local numPlayersToAvg = Tuning.STUPID.numPlayersToAvg
	local teamAvg = GetTeamPlayerAvg( buyingTeamId, numPlayersToAvg )
	local bidPlayerOverall = Engine.GetPlayerOverall( playerId )
	if( ( teamAvg + overallDiff ) < bidPlayerOverall ) then	
		StartStory_StupidBid( buyingTeamId, sellingTeamId, playerId, moneyOffered )
	end
end

function StartStory_StupidBid( buyingTeamId, sellingTeamId, playerId, moneyOffered )
	local storyId = "STUPID"
	local category = "STUPID"
	local storyActive = Engine.IsStoryIDActive( storyId )
	Engine.SetStringTeams( buyingTeamId, sellingTeamId )
	Engine.SetStringPlayer( playerId )
	Engine.SetStringCurrency( moneyOffered )
	if( storyActive == false ) then
		if( Engine.MarkPlayerForStory( buyingTeamId, playerId, category, storyId ) == true ) then
			local story = Engine.GetStoryById( storyId )
			TriggerNews( "News_Title_StupidTransfer_First_", 1, 4, "News_Body_StupidTransfer_First_", 1, 4, story )
			Engine.SetStoryStage( story, 1 )
			Engine.UpdateStoryActivity( story )
		end --if( Engine.MarkPlayerForStory( buyingTeamId, playerId, category, storyId ) == true ) then
	else
		local story = Engine.GetStoryById( "STUPID" )
		Engine.ReplaceStoryPlayer( story, buyingTeamId, playerId )
		local storyStage = Engine.GetStoryStage( story )
		if( storyStage ==  1 ) then
			TriggerNews( "News_Title_StupidTransfer_Second_", 1, 4, "News_Body_StupidTransfer_Second_", 1, 4, story )
			Engine.ModifyBoardConfidence( buyingTeamId, Tuning.STUPID.boardConfidencePen_1st )
			Engine.SetStoryStage( story, 2 )		
			Engine.UpdateStoryActivity( story )			
		elseif( storyStage == 2 ) then
			local userName = Engine.GetUsername()			
			TriggerNews( "News_Title_StupidTransfer_Third_", 1, 4, "News_Body_StupidTransfer_Third_", 1, 4, story )
			TriggerEmail( false, userName, "CM_Inbox_Sender_Board", "CM_Email_Subject_StupidTransfer_Warning_", 1, 4, "CM_Email_Body_StupidTransfer_Warning_", 1, 4 )
			Engine.ModifyBoardConfidence( buyingTeamId, Tuning.STUPID.boardConfidencePen_2nd )
			Engine.SetStoryStage( story, 3 )
			Engine.UpdateStoryActivity( story )
		end -- if( storyStage ==  1 ) then
	end -- if( storyActive == false ) then
end

-- Will be moved to misc funcs
function GetTeamPlayerAvg( teamId, numPlayers )
	local totalAvg = 0
	teamId = Engine.StackRankTeamByOverall( teamId )
	local loopToPlayers = numPlayers
	local numPlayersOnTeam = Engine.GetNumPlayers( teamId )
	if( numPlayersOnTeam < loopToPlayers ) then
		loopToPlayers = numPlayersOnTeam
	end
	for playerCount = 1, loopToPlayers do
		local currPlayer = Engine.GetPlayer( teamId, playerCount )
		local playerOverall = Engine.GetPlayerOverall( currPlayer )
		totalAvg = totalAvg + playerOverall
	end
	totalAvg = totalAvg / numPlayers
	return totalAvg
end
-- Will be moved to misc funcs

function StupidTransferClose( numDays )
	if( numDays == 0 ) then
		local storyId = "STUPID"
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive ) then			
			Engine.EndStoryId( storyId )
		end	-- if( storyActive ) then
	end -- if( numDays == 0 ) then
end