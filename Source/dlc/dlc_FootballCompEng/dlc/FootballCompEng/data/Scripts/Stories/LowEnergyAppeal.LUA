function ExamineFor_LEA( numDays, gametype, fixture )
	if( numDays == Tuning.FATIGUE.numDays ) then -- Day Before Match
		local seasonPerc = Engine.GetPercentageThroughSeason()
		if( seasonPerc < Tuning.FATIGUE.seasonPercent ) then
			local category = "FATIGUE"
			local storyId = "LOWENERGY"
			local storyActive = Engine.IsStoryIDActive( storyId, true )
			if( storyActive == false ) then					
				local maxPlayersToCheck = Tuning.FATIGUE.maxPlayersToCheck
				local userTeam = Engine.GetUserTeam()
				local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
				local matchImportance1, matchImportance2 = Engine.GetMatchImportance( fixture )
				local matchImportance = matchImportance1
				if( team2 == userTeam ) then
					matchImportance = matchImportance2
				end
				userTeam = Engine.StackRankTeamByOverall( userTeam )
				for playerCount = 1, maxPlayersToCheck do
					local currentPlayer = Engine.GetPlayer( userTeam, playerCount )
					local playerEnergy = Engine.GetPlayerEnergy( userTeam, currentPlayer )
					local playerTier = Engine.GetPlayerTier( userTeam, currentPlayer )
					local inStarting11 = Engine.IsPlayerInStartingLineup( userTeam, currentPlayer )
					local playAsPlayerId = Engine.GetPlayAsPlayerID()
					if( playAsPlayerId ~= currentPlayer ) then -- Dont allow user Player.
						if( playerTier < Tuning.FATIGUE.playerTier and inStarting11 == true ) then --Player Tier
							if( playerEnergy <= Tuning.FATIGUE.playerEnergy ) then -- Check if player energy <70%
								if( matchImportance <= Tuning.FATIGUE.matchImportance ) then --Match Importance
									if( IsAbleToPlay( userTeam, currentPlayer ) == true ) then
										StartStory_LEA( userTeam, currentPlayer, category, storyId )
										break
									end --if( Engine.IsInjured( userTeam, currentPlayer ) ~= true ) then
								end --if( matchImportance <= 50 ) then
							end --if( playerEnergy <= 60 ) then -- Check if player energy <60%
						end --if( playerTier < 3 and inStarting11 == true ) then	
					end --if( storyActive == false ) then		
				end --if( playAsPlayerId ~= currentPlayer ) then
			end --for playerCount = 1, maxPlayersToCheck do
		end --if( seasonPerc < Tuning.FATIGUE.seasonPercent ) then
	end--if( numDays == 1 ) then 
end

function StartStory_LEA( teamId, playerId, category, storyId )								
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.FATIGUE.storyCoolDown ) == true ) then					
		Engine.SetStringPlayer( playerId )
		Engine.AddConversation( playerId, "PlayerFeedbackPopUp_PlayerLowEnergyAppeal_", 1, 3, "PlayerFeedbackPopUp_PlayerLowEnergyAppeal_subject", currentStory, true )
	end --if( Engine.MarkPlayerForStory( userTeam, currentPlayer, category, "LOWENERGY" ) == true ) then
end

function LowEnergyAppealMatch( matchResult )
	local storyId = "LOWENERGY"
	local numStories = Engine.GetNumStoriesWithId( storyId )
	if( numStories > 0 ) then
		local currentStory = Engine.GetStoryById( storyId )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )	
		local team = Engine.GetStoryTeam( currentStory )
		Engine.SetStringTeam( team )
		Engine.SetStringPlayer( storyPlayer )
		local selfish = Engine.HasPlayerTrait( team, storyPlayer, "SELFISH" )
		local teamPlayer = Engine.HasPlayerTrait( team, storyPlayer, "TEAM_PLAYER" )
		if( Engine.WasMatchForfeited( matchResult ) == false ) then
			local played = Engine.DidPlayerPlay( team, storyPlayer, matchResult )
			if( played == true ) then
				local minPlayed = Engine.GetPlayerMinutesPlayed( team, storyPlayer, matchResult )					
				local subbedOn = Engine.DidPlayerGetSubbedOn( team, storyPlayer, matchResult )
				local subbedOff = Engine.DidPlayerGetSubbedOff( team, storyPlayer, matchResult )
				local wasInjured = Engine.DidPlayerGetInjured( team, storyPlayer, matchResult )
				local playerRating = Engine.GetPlayerMatchRating( team, storyPlayer, matchResult )
				if( playerRating < Tuning.FATIGUE.playerRating_Good ) then
					if( wasInjured == true ) then
						Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_Injured_", 1, 3, "PlayerFeedbackPopUp_Injured_subject", currentStory )
						Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.injuredFatigued_Morale )
					elseif( subbedOn == false ) then
						if( selfish == true ) then
							TriggerNews( "News_Title_InStarting11_SelfishPlayer_", 1, 4, "News_Body_InStarting11_SelfishPlayer_", 1, 4, currentStory )
							Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.startingFatigued_Selfish_Morale )
						else
							Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_InStarting11_TeamPlayer_", 1, 3, "PlayerFeedbackPopUp_InStarting11_TeamPlayer_subject", currentStory )
							Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.startingFatigued_Team_Morale )
						end
					else
						if( selfish == true ) then														
							Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_StartFromBench_SelfishPlayer_", 1, 3, "PlayerFeedbackPopUp_StartFromBench_SelfishPlayer_subject", currentStory )
							if( minPlayed <= Tuning.FATIGUE.minPlayed_Short ) then
								Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.benchStart_Short_Selfish_Morale )
							elseif( minPlayed >= Tuning.FATIGUE.minPlayed_Med_Low and minPlayed <= Tuning.FATIGUE.minPlayed_Med_High ) then
								Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.benchStart_Med_Selfish_Morale )
							else
								Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.benchStart_Long_Selfish_Morale )
							end
						else
							if( minPlayed <= Tuning.FATIGUE.minPlayed_Short ) then
								Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_StartFromBench_TeamPlayer_Shortplay_", 1, 3, "PlayerFeedbackPopUp_NotPlayed_subject", currentStory )
								Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.benchStart_Short_Team_Morale )
							elseif( minPlayed >= Tuning.FATIGUE.minPlayed_Med_Low and minPlayed <= Tuning.FATIGUE.minPlayed_Med_High ) then
								Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_StartFromBench_TeamPlayer_Shortplay_", 1, 3, "PlayerFeedbackPopUp_NotPlayed_subject", currentStory )
								Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.benchStart_Med_Team_Morale )
							else
								Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_StartFromBench_TeamPlayer_Longplay_", 1, 3, "PlayerFeedbackPopUp_StartFromBench_TeamPlayer_Longplay_subject", currentStory )
								Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.benchStart_Long_Team_Morale )
							end --if( minPlayed <= 30 ) then
						end --if( selfish == true ) then
					end --if( subbedOn == false ) then
				end
			else
				Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_NotPlayed_", 1, 3, "PlayerFeedbackPopUp_NotPlayed_subject", currentStory, true )
				Engine.ModifyPlayerMorale( team, storyPlayer, Tuning.FATIGUE.notPlayed_Morale )					
			end --if( played == true ) then
		end --if( Engine.WasMatchForfeited( matchResult ) == false ) then
		Engine.EndStoryId( storyId )
	end --if( numStories > 0 ) then
end