-- ////////////////////////////////////////////////////////
function ExamineFor_FormChange( teamId, playerId, formString )
	local percThroughSeason = Engine.GetPercentageThroughSeason()
	if( percThroughSeason < Tuning.FORM.maxWayThroughSeason ) then
		local userTeam = Engine.GetUserTeam()		
		if( teamId == userTeam ) then
			if( Engine.GetPlayAsPlayerID() ~= playerId ) then
				if( Engine.DidPlayInLastGame( teamId, playerId ) == true ) then
					local playerForm = Engine.GetPlayerFormData( teamId, playerId )
					local isVeryBadForm = ( formString == "VERY_BAD" )
					local isVeryGoodForm = ( formString == "VERY_GOOD" )
					local area = Engine.GetPlayerPitchArea( teamId, playerId )
					if( area == "ATT" or area == "MID" ) then
						if( isVeryBadForm == true or isVeryGoodForm == true ) then
							StartStory_FormChange( teamId, playerId, isVeryBadForm, isVeryGoodForm, false )
						end
					end
				end --if( Engine.DidPlayInLastGame( teamId, playerId ) == true ) then
			end --if( Engine.GetPlayAsPlayerID() ~= playerId ) then
		end -- if( teamId == userTeam ) then
	end -- if( percThroughSeason < 85 ) then
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('ExamineFor_FormChange\n')
	v2k4debugfile:close()
end

function ExamineFor_CPUForm( numDays, gametype, fixture )
	if( numDays == 0 ) then
		if( gametype == "LEAGUE" ) then
			local category = "FORM"
			fixture = Engine.GetCurrentGameFixtureData()
			local userTeam, cpuTeam = GetTeamsFromFixture( fixture )
			local teamStatObj, numStats = Engine.GetTeamStatObj( cpuTeam )
			local matchNumber = Engine.GetCPUFormMatchNumber( teamStatObj, numStats )
			local numPlayersOnTeam = Engine.GetNumPlayers( cpuTeam )
			cpuTeam = Engine.StackRankTeamByOverall( cpuTeam )
			local baseStoryid = "CPU_PF_"
			local storyCounter = 0
			
			--Capture top player
			local topPlayer = 0
			
			--Create Dumb Story
			
			for playerCount = 1, numPlayersOnTeam do
				local playerId = Engine.GetPlayer( cpuTeam, playerCount )
				local formString, playerForm = Engine.GetCPUPlayerForm( cpuTeam, playerId, teamStatObj, numStats, matchNumber )
				local playerTier = 0
				local storyId = baseStoryid
				if( Engine.IsStarPlayer( playerId ) == true ) then
					storyId = storyId .. "SP"
				else
					playerTier = Engine.GetPlayerTier( cpuTeam, playerId )
					if( playerTier == 1 ) then
						storyId = storyId .. "T1"
					elseif( playerTier == 2 ) then
						storyId = storyId .. "T2"
					else
						storyId = storyId .. "T3"
					end
				end
				local numStories = Engine.GetNumStoriesByCategory( category )
				storyId = storyId .. "_" .. numStories
				if( topPlayer > 0 ) then
					local Ovr = Engine.GetPlayerOverall( playerId )
					local topOvr = Engine.GetPlayerOverall( topPlayer )
					if( Ovr < topOvr ) then
						if( formString == "VERY_GOOD" )then
							if( Engine.MarkPlayerForStory( cpuTeam, playerId, category, storyId ) == true ) then
								local currentStory = Engine.GetStoryById( storyId )
								storyCounter = storyCounter + 1
								Engine.UpdateStoryActivity( currentStory )
								Engine.KillStoryAfterMatch( currentStory, false )
							end
						elseif( formString == "VERY_BAD"  )then
							if( Engine.MarkPlayerForStory( cpuTeam, playerId, category, storyId ) == true ) then
								local currentStory = Engine.GetStoryById( storyId )
								storyCounter = storyCounter + 1
								Engine.UpdateStoryActivity( currentStory )
								Engine.KillStoryAfterMatch( currentStory, false )
							end				
						end
					else
						if( formString == "VERY_GOOD" )then
							if( Engine.MarkPlayerForStory( cpuTeam, topPlayer, category, storyId ) == true ) then
								local currentStory = Engine.GetStoryById( storyId )
								storyCounter = storyCounter + 1
								Engine.UpdateStoryActivity( currentStory )
								Engine.KillStoryAfterMatch( currentStory, false )
							end
						elseif( formString == "VERY_BAD"  )then
							if( Engine.MarkPlayerForStory( cpuTeam, topPlayer, category, storyId ) == true ) then
								local currentStory = Engine.GetStoryById( storyId )
								storyCounter = storyCounter + 1
								Engine.UpdateStoryActivity( currentStory )
								Engine.KillStoryAfterMatch( currentStory, false )
							end				
						end
						topPlayer = playerId
					end
				else
					topPlayer = playerId
				end
				if( storyCounter == 1 ) then
					break
				end
			end
			
			--Send Top Player to Regular News
			if( topPlayer > 0 )then
				StartStory_FormChange( cpuTeam, topPlayer, isVeryBadForm, isVeryGoodForm, true )
			end
		end
	end
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('ExamineFor_CPUForm\n')
	v2k4debugfile:close()
end

function StartStory_FormChange( teamId, playerId, isVeryBadForm, isVeryGoodForm, isCpu )
	Engine.SetStringPlayer( playerId )
	Engine.SetStringTeam( teamId )
	local starPlayer = Engine.IsStarPlayer( playerId )
	local category = "FORM"
	Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
	Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
	if( starPlayer == true ) then
		local storyId = "PF_SP"
		if( isCpu == true ) then
			storyId = "CPU_" .. storyId
		end
		if( isVeryGoodForm == true ) then
			if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown ) == true ) then
				local currentStory = Engine.GetStoryById( storyId )
				Engine.SetStoryPriority( currentStory, 2 )
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
				Engine.SetNewsBackgroundImage("GRAPH_RISING")
				Engine.SetNewsCinematic( "CM_News_TeamPromo" )
				TriggerNews( "News_Title_Star_VeryGoodForm_", 1, 4, "News_Item_Star_VeryGoodForm_", 1, 4, currentStory )
				Engine.UpdateStoryActivity( currentStory )
				Engine.KillStoryAfterMatch( currentStory )
			end
		elseif( isVeryBadForm == true ) then
			if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown  ) == true ) then
				local currentStory = Engine.GetStoryById( storyId )
				Engine.SetStoryPriority( currentStory, 2 )
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
				Engine.SetNewsBackgroundImage("GRAPH_DROPPING")
				TriggerNews( "News_Title_Star_VeryBadForm_", 1, 4, "News_Item_Star_VeryBadForm_", 1, 4, currentStory )
				Engine.UpdateStoryActivity( currentStory )
				Engine.KillStoryAfterMatch( currentStory )
			end
		end -- elseif( playerForm == "VERY_BAD" ) then
	else				
		local playerTier = Engine.GetPlayerTier( teamId, playerId )
		
		if( playerTier == 1 ) then
			local storyId = "PF_T1"
			if( isCpu == true ) then
				storyId = "CPU_" .. storyId
			end
			if( isVeryGoodForm == true ) then
				if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown ) == true ) then
					local currentStory = Engine.GetStoryById( storyId )
					Engine.SetStoryPriority( currentStory, 2 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
					Engine.SetNewsBackgroundImage("GRAPH_RISING")
					Engine.SetNewsCinematic ( "CM_News_TeamPromo" )
					TriggerNews( "News_Title_Tier1_VeryGoodForm_", 1, 4, "News_Item_Tier1_VeryGoodForm_", 1, 4, currentStory )
					Engine.UpdateStoryActivity( currentStory )
					Engine.KillStoryAfterMatch( currentStory )
				end
			elseif( isVeryBadForm == true ) then
				if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown ) == true ) then
					local currentStory = Engine.GetStoryById( storyId )
					Engine.SetStoryPriority( currentStory, 2 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
					Engine.SetNewsBackgroundImage("GRAPH_DROPPING")
					Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" )
					TriggerNews( "News_Title_Tier1_VeryBadForm_", 1, 4, "News_Item_Tier1_VeryBadForm_", 1, 4, currentStory )
					Engine.UpdateStoryActivity( currentStory )
					Engine.KillStoryAfterMatch( currentStory )
				end
			end -- elseif( playerForm == "VERY_BAD" ) then
		
		elseif( playerTier == 2 ) then
			local storyId = "PF_T2"
			if( isCpu == true ) then
				storyId = "CPU_" .. storyId
			end
			if( isVeryGoodForm == true ) then
				if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown ) == true ) then
					local currentStory = Engine.GetStoryById( storyId )
					Engine.SetStoryPriority( currentStory, 2 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
					Engine.SetNewsBackgroundImage( "GRAPH_RISING" )
					TriggerNews( "News_Title_Tier2_VeryGoodForm_", 1, 4, "News_Item_Tier2_VeryGoodForm_", 1, 4, currentStory )
					Engine.UpdateStoryActivity( currentStory )
					Engine.KillStoryAfterMatch( currentStory )
				end
			elseif( isVeryBadForm == true ) then
				if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown ) == true ) then
					local currentStory = Engine.GetStoryById( storyId )
					Engine.SetStoryPriority( currentStory, 2 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
					Engine.SetNewsBackgroundImage( "GRAPH_DROPPING" )
					TriggerNews( "News_Title_Tier2_VeryBadForm_", 1, 4, "News_Item_Tier2_VeryBadForm_", 1, 4, currentStory )
					Engine.UpdateStoryActivity( currentStory )
					Engine.KillStoryAfterMatch( currentStory )
				end
			end -- elseif( playerForm == "VERY_BAD" ) then
		
		elseif( playerTier == 3 ) then
			local storyId = "PF_T3"
			if( isCpu == true ) then
				storyId = "CPU_" .. storyId
			end
			if( isVeryGoodForm == true ) then
				if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown ) == true ) then
					local currentStory = Engine.GetStoryById( storyId )
					Engine.SetStoryPriority( currentStory, 2 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
					Engine.SetNewsBackgroundImage( "GRAPH_RISING" )
					TriggerNews( "News_Title_Tier3_VeryGoodForm_", 1, 4, "News_Item_Tier3_VeryGoodForm_", 1, 4, currentStory )
					Engine.UpdateStoryActivity( currentStory )
					Engine.KillStoryAfterMatch( currentStory )
				end
			elseif( isVeryBadForm == true ) then
				if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FORM.storyCoolDown ) == true ) then
					local currentStory = Engine.GetStoryById( storyId )
					Engine.SetStoryPriority( currentStory, 2 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
					Engine.SetNewsBackgroundImage( "GRAPH_DROPPING" )
					TriggerNews( "News_Title_Tier3_VeryBadForm_", 1, 4, "News_Item_Tier3_VeryBadForm_", 1, 4, currentStory )
					Engine.UpdateStoryActivity( currentStory )
					Engine.KillStoryAfterMatch( currentStory )
				end
			end -- elseif( playerForm == "VERY_BAD" ) then
		end -- elseif( playerTier == 3 ) then 
	end -- if( starPlayer == true ) then
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('StartStory_FormChange\n')
	v2k4debugfile:close()
end
-- ////////////////////////////////////////////////////////
function ExamineFor_PreSeasonForm( userTeam, playerId, formString )
	local nextFixture = Engine.GetCurrentGameFixtureData()
	local fixtureType = Engine.GetFixtureType( nextFixture )
	if( fixtureType == "FRIENDLY" ) then
		local gameNum = Engine.GetNumberOfFixturesPlayedFromFixture( nextFixture )
		local totalNum = Engine.GetTotalFixturesPlayedFromFixture( nextFixture )
		if( totalNum == gameNum ) then -- last game
			local category = "FORM_PRESEASON"
			if( Engine.GetPlayAsPlayerID() ~= playerId ) then
				StartStory_PreSeasonForm( userTeam, playerId, formString )
			end --if( Engine.GetPlayAsPlayerID() ~= playerId ) then
		end --if( totalNum - 1 == gameNum ) then
	end -- if( fixtureType == "FRIENDLY" ) then
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('ExamineFor_PreSeasonForm\n')
	v2k4debugfile:close()
end

function StartStory_PreSeasonForm( teamId, playerId, formString )
	local category = "FORM_PRESEASON"
	local playerTier = Engine.GetPlayerTier( teamId, playerId )
	local userTeam = Engine.GetUserTeam()		
	if( playerTier < 3 ) then
		local isBadForm = ( formString == "BAD" or formString == "VERY_BAD" )
		if( isBadForm ) then
			if( Engine.MarkPlayerForStory( teamId, playerId, category, "PSF_1" ) == true ) then
				local currentStory = Engine.GetStoryById( "PSF_1" )
				local storyId = Engine.GetStoryId( currentStory )
				Engine.SetStringTeam( teamId )
				Engine.SetStringPlayer( playerId )
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )
				Engine.SetNewsBackgroundImage( "TRAINING_GROUNDS" )
				if( teamId == userTeam ) then
					Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" )
				end
				TriggerNews( "News_Title_BadPreSeasonForm_Tier1_", 1, 4, "News_Item_BadPreSeasonForm_Tier1_", 1, 4, currentStory )
				Engine.UpdateStoryActivity( currentStory )
			end --if( Engine.MarkPlayerForStory( teamId, playerId, category, "PSF_1" ) == true ) then			
		end
	elseif( playerTier > 2 ) then
		local isGoodForm = ( formString == "GOOD" or formString == "VERY_GOOD" )
		if( isGoodForm ) then
			if( Engine.MarkPlayerForStory( teamId, playerId, category, "PSF_3" ) == true ) then
				local currentStory = Engine.GetStoryById( "PSF_3" )
				local storyId = Engine.GetStoryId( currentStory )
				Engine.SetStringTeam( teamId )
				Engine.SetStringPlayer( playerId )
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", teamId )				
				Engine.SetNewsBackgroundImage( "TRAINING_GROUNDS" )
				if( teamId == userTeam ) then
					local starPlayer = Engine.IsStarPlayer( playerId )
					local scene = "CM_News_PlayerActionPositive"
					local rand = Engine.GetRandomNumber( 1, 2 )
					if(starPlayer == true and rand == 1 ) then
						scene = "CM_News_PlayerPromo"
					end
					Engine.SetNewsCinematic ( scene )
				end
				TriggerNews( "News_Title_GoodPreSeasonForm_Tier3_", 1, 4, "News_Item_GoodPreSeasonForm_Tier3_", 1, 4, currentStory )
				Engine.UpdateStoryActivity( currentStory )
			end --if( Engine.MarkPlayerForStory( teamId, playerId, category, "PSF_3" ) == true ) then			
		end
	end -- if( playerTier == 1 ) the
end
-- ////////////////////////////////////////////////////////

function PUG_CheckPreSeasonFormStory( matchResult, gametype )
	if( gametype ~= "FRIENDLY" ) then
		local category = "FORM_PRESEASON"
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			for storyCount = numStories, 1,  -1 do -- go backwards in loop
				local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
				local storyId = Engine.GetStoryId( currentStory )
				local storyPlayer = Engine.GetStoryPlayer( currentStory )	
				local team = Engine.GetStoryTeam( currentStory )
				local playerTier = Engine.GetPlayerTier( team, storyPlayer )
				local playerPlayed = Engine.DidPlayerPlay( team, storyPlayer, matchResult )
				local playerForm = Engine.GetPlayerFormData( team, storyPlayer, "CheckPreSeasonFormStory" )		
				local isAbleToPlay = IsAbleToPlay( team, storyPlayer )
				local minPlayed = 0
				local userTeam = Engine.GetUserTeam()		
				if( playerPlayed == true ) then
					minPlayed = Engine.GetPlayerMinutesPlayed( team, storyPlayer, matchResult )
				end				
				Engine.SetStringTeam( team )
				Engine.SetStringPlayer( storyPlayer )
				if( playerTier < 3 ) then
					if( playerPlayed == false ) then
						if( isAbleToPlay == true ) then
							Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
							if( team == userTeam ) then
								Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" )
							end
							TriggerNews( "News_Title_BadPreseasonNotPicked_Tier1_", 1, 4, "News_Item_BadPreseasonNotPicked_Tier1_", 1, 4, currentStory )
							Engine.UpdateStoryActivity( currentStory )
						end
					else
						if( minPlayed > 15 ) then
							local playerRating = Engine.GetPlayerMatchRating( team, storyPlayer, matchResult )
							if( playerRating > Tuning.FORM.goodPlayerRating ) then
								Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )	
								if( team == userTeam ) then
									Engine.SetNewsCinematic ( "CM_News_PlayerActionPositive" ) 
								end
								TriggerNews( "News_Title_BadPreseasonGoodMatch_Tier1_", 1, 4, "News_Item_BadPreseasonGoodMatch_Tier1_", 1, 4, currentStory )
								Engine.UpdateStoryActivity( currentStory )
							else
								Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
								if( team == userTeam ) then
									Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" ) 
								end
								TriggerNews( "News_Title_BadPreseasonBadMatch_Tier1_", 1, 4, "News_Item_BadPreseasonBadMatch_Tier1_", 1, 4, currentStory )
								Engine.UpdateStoryActivity( currentStory )
							end
						end
					end							
				elseif( playerTier > 2 ) then
					if( playerPlayed == false ) then
						if( isAbleToPlay == true ) then
							Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
							Engine.SetNewsBackgroundImage( "MANAGER_SUIT" )
							if( team == userTeam ) then
								Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" ) 
							end
							TriggerNews( "News_Title_GoodPreseasonNotPicked_Tier3_", 1, 4, "News_Item_GoodPreseasonNotPicked_Tier3_", 1, 4, currentStory )
							Engine.UpdateStoryActivity( currentStory )
						end
					else
						if( minPlayed > 15 ) then
							local playerRating = Engine.GetPlayerMatchRating( team, storyPlayer, matchResult )
							if( playerRating > Tuning.FORM.goodPlayerRating ) then
								Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
								Engine.SetNewsBackgroundImage( "GLOBE" )
								if( team == userTeam ) then
									local starPlayer = Engine.IsStarPlayer( storyPlayer )
									local scene = "CM_News_PlayerActionPositive"
									local rand = Engine.GetRandomNumber( 1, 2 )
									if( starPlayer == true and rand == 1) then
										scene = "CM_News_PlayerPromo"
									end
									Engine.SetNewsCinematic ( scene ) 
								end
								TriggerNews( "News_Title_GoodPreseasonGoodMatch_Tier3_", 1, 4, "News_Item_GoodPreseasonGoodMatch_Tier3_", 1, 4, currentStory )
								Engine.UpdateStoryActivity( currentStory )
							else
								Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
								Engine.SetNewsBackgroundImage( "GLOBE" )
								if( team == userTeam ) then
									Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" ) 
								end
								TriggerNews( "News_Title_GoodPreseasonBadMatch_Tier3_", 1, 4, "News_Item_GoodPreseasonBadMatch_Tier3_", 1, 4, currentStory )
								Engine.UpdateStoryActivity( currentStory )
							end
						end
					end	
				end --if( playerTier == 2 ) then
				Engine.EndStoryId( storyId )
			end -- for playerCount = 1, numStories do
		end --if( numStories > 1 ) then
	end
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('PUG_CheckPreSeasonFormStory\n')
	v2k4debugfile:close()
end

function PreSeasonFormPlayerDaysBeforeGame( numDays, gametype, fixture )
	if( gametype ~= "FRIENDLY" ) then
		if( numDays == Tuning.FORM.numDaysBefore ) then		
			local storyId = "PSF_1"
			local storyActive = Engine.IsStoryIDActive( storyId )
			if( storyActive == true ) then
				local currentStory = Engine.GetStoryById( storyId )
				local storyPlayer = Engine.GetStoryPlayer( currentStory )	
				local team = Engine.GetStoryTeam( currentStory )
				local inStarting11 = Engine.IsPlayerInStartingLineup( team, storyPlayer )
				local bench = Engine.IsPlayerOnBench( team, storyPlayer )
				if( inStarting11 == false or bench == false ) then
					if( IsAbleToPlay( team, storyPlayer ) == true ) then
						Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_BadPreSeasonFormNotStarting_", 1, 4, "PlayerFeedbackPopUp_UpcomingMatch_subject", currentStory, true )
					else
						Engine.EndStoryId( storyId )
					end
				end --if( inStarting11 == false or bench == false ) then
			else --if( storyActive == true ) then
				storyId = "PSF_3"
				storyActive = Engine.IsStoryIDActive( storyId )
				if( storyActive == true ) then
					local currentStory = Engine.GetStoryById( storyId )
					local storyPlayer = Engine.GetStoryPlayer( currentStory )	
					local team = Engine.GetStoryTeam( currentStory )
					local inStarting11 = Engine.IsPlayerInStartingLineup( team, storyPlayer )
					local bench = Engine.IsPlayerOnBench( team, storyPlayer )
					if( inStarting11 == false or bench == false ) then
						if( IsAbleToPlay( team, storyPlayer ) == true ) then
							Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_GoodPreSeasonFormNotStarting_", 1, 4, "PlayerFeedbackPopUp_UpcomingMatch_subject", currentStory, true )
						else
							Engine.EndStoryId( storyId )
						end
					end --if( inStarting11 == false or bench == false ) then
				end --if( storyActive == true ) then
			end --if( storyActive == true ) then
		end -- if( numDays == 2 ) then
	end --if( gametype ~= "FRIENDLY" ) then
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('PreSeasonFormPlayerDaysBeforeGame\n')
	v2k4debugfile:close()
end

function EndFormStoriesForPlayer( teamId, playerId )
	EndFormStoriesByCategory( teamId, playerId, "FORM" )
	EndFormStoriesByCategory( teamId, playerId, "FORM_PRESEASON" )
end

function EndFormStoriesByCategory( teamId, playerId, category )
	local numStories = Engine.GetNumStoriesByCategory( category )
	for storyCount = numStories, 1,  -1 do -- go backwards in loop
		local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		if( storyPlayer == playerId ) then
			Engine.EndStoryId( Engine.GetStoryId( currentStory ) )
		end
	end --for storyCount = numStories, 1,  -1 do -- go backwards in loop
end