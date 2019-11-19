function ExamineFor_POB( numDays, gametype, fixture )
	if( numDays == Tuning.ONBENCH.numDays ) then -- Day of Match
		local storyId = "PLAYERONBENCH"
		local storyActive = Engine.IsStoryIDActive( storyId, true )
		if( storyActive == false ) then		
			local userTeam = Engine.GetUserTeam()
			local maxPlayersToCheck = Engine.GetNumPlayers( userTeam )
			userTeam = Engine.StackRankTeamByOverall( userTeam )			
			for playerCount = 1, maxPlayersToCheck do
				local currentPlayer = Engine.GetPlayer( userTeam, playerCount )
				local playerTier = Engine.GetPlayerTier( userTeam, currentPlayer )
				local playerForm = Engine.GetPlayerFormData( userTeam, currentPlayer )
				local isInGoodForm = Engine.IsInGoodForm( playerForm )
				local isInVeryGoodForm = Engine.IsInVeryGoodForm( playerForm )
				local inStarting11 = Engine.IsPlayerInStartingLineup( userTeam, currentPlayer )
				local isInjured = Engine.IsInjured( userTeam, currentPlayer )
				local isAbleToPlay = IsAbleToPlay( userTeam, currentPlayer )
				local isPlayerInSaga = IsPlayerInvolvedInSaga( currentPlayer )
				playAsPlayerId = Engine.GetPlayAsPlayerID()
				if( playAsPlayerId ~= currentPlayer and isPlayerInSaga == false  ) then
					if( playerTier < 3 and inStarting11 == false ) then
						if( isInVeryGoodForm == true ) then 
							if( isInjured == false and isAbleToPlay == true ) then
								if( StartStory_POB( userTeam, currentPlayer ) == true ) then
									break
								end
							end --if( isInjured = false ) then
						end --if ( isInGoodForm = true or isInVeryGoodForm == true ) then
					elseif( playerTier >= 3 and inStarting11 == false ) then 
						if( isInGoodForm == true or isInVeryGoodForm == true ) then
							if( isInjured == false and isAbleToPlay == true ) then
								if( StartStory_POB( userTeam, currentPlayer ) == true ) then
									break
								end
							end
						end
					end --if( playerTier < 3 and inStarting11 == false ) then 
				end --if( playAsPlayerId ~= currentPlayer ) then
			end --for playerCount = 1, numPlayers do
		end --if( storyActive == false ) then		
	end --if( numDays == 1 ) then
end --function 

function StartStory_POB( teamId, playerId )
	local success = false
	local category = "ONBENCH"
	local storyId = "PLAYERONBENCH"
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.ONBENCH.storyCoolDown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 3 )
		Engine.SetStringPlayer( playerId )
		Engine.AddConversation( playerId, "PlayerFeedbackPopUp_PlayerOnBench_", 1, 4, "PlayerFeedbackPopUp_PlayerOnBench_subject", currentStory, true )
		success = true
	end --if( Engine.MarkPlayerForStory( userTeam, currentPlayer, category, "PLAYERONBENCH" ) == true ) then
	return success
end --if( isInjured == false and isPlayerSuspended == false ) then

function PlayerOnBenchPostMatch( matchResult, gametype, playType )
	local category = "ONBENCH"
	local storyId = "PLAYERONBENCH"
	local numStories = Engine.GetNumStoriesWithId( storyId )
	if( numStories > 0 ) then
		for storyCount = 1, numStories do
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )	
			local team = Engine.GetStoryTeam( currentStory )
			local played = Engine.DidPlayerPlay( team, storyPlayer, matchResult )
			local homeTeam, awayTeam = Engine.GetMatchResultTeamIds( matchResult )
			
			if( homeTeam == Engine.GetUserTeam() ) then
				Engine.SetStringTeams( homeTeam, awayTeam )
			else
				Engine.SetStringTeams( awayTeam, homeTeam )
			end
			Engine.SetStringPlayer( storyPlayer )
			if( Engine.WasMatchForfeited( matchResult ) == false ) then
				if( played == true ) then
					local playerForm = Engine.GetPlayerFormData( team, storyPlayer )
					local isInGoodForm = Engine.IsInGoodForm( playerForm )
					local isInVeryGoodForm = Engine.IsInVeryGoodForm( playerForm )
					local injuryLengthMin = 5 --The amount of days to determine a severe injury
					local wasInjured = Engine.DidPlayerGetInjured( team, storyPlayer, matchResult )
					
					if( wasInjured == false ) then
						Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
						Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
						if( isInGoodForm == true or isInVeryGoodForm == true ) then
							--Player Played good form
							Engine.SetNewsBackgroundImage( "GRAPH_RISING" )
							Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.ONBENCH.streakContinues_Morale )
							TriggerNews( "news_title_PlayerStreakContinues_", 1, 4, "news_body_PlayerStreakContinues_", 1, 4, currentStory )
							Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_PlayerPlayedWell_", 1, 4, "PlayerFeedbackPopUp_PlayerPlayedWell_subject", currentStory )
						else	
							--Player Played no longer good form
							Engine.SetNewsBackgroundImage( "GRAPH_DROPPING" )
							TriggerNews( "news_title_PlayerStreakThwarted_", 1, 4, "news_body_PlayerStreakThwarted_", 1, 4, currentStory )
							Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_PlayerPlayedPoorly_", 1, 4, "PlayerFeedbackPopUp_PlayerPlayedPoorly_subject", currentStory )
						end --if( isInGoodForm == true or isInVeryGoodForm == true ) then
					
					elseif( wasInjured == true ) then
						Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
						Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
						--Player Injured
						Engine.SetNewsBackgroundImage( "HOSPITAL" )
						Engine.ForceTeamCacheRefresh()
						local injuryDuration = Engine.GetInjuryDuration( team, storyPlayer )
						if( injuryDuration > injuryLengthMin ) then 
							--Is the injury severe
							TriggerNews( "news_title_PlayerStreakInjuredSevere_", 1, 4, "news_body_PlayerStreakInjuredSevere_", 1, 4, currentStory )
						else --if( injuryDuration <= injuryLengthMin ) then --Is the injury minor
							TriggerNews( "news_title_PlayerStreakInjuredLight_", 1, 4, "news_body_PlayerStreakInjuredLight_", 1, 4, currentStory )
						end --if( injuryDuration > injuryLengthMin ) then	
						Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_PlayerPlayedInjured_", 1, 2, "PlayerFeedbackPopUp_PlayerPlayedInjured_injured", currentStory )
					end
					
				elseif( played == false ) then
					--Player Not Played
					Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_PlayerNotPlayed_", 1, 4, "PlayerFeedbackPopUp_PlayerNotPlayed_subject", currentStory )
					Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.ONBENCH.notPlayed_Morale )
				end -- if ( played == true ) then
			end
			Engine.EndStoryId( storyId )
		end --for storyCount = 1, numStories do
	end --if( numStories > 0 ) then
end