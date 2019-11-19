function ExamineFor_ReservePlayerRequest( numDays, gametype, fixture )
	local numDaysBeforeStart = Tuning.RESERVE.numDaysBeforeStart
	if( numDays == 0 ) then
		local storyActive = Engine.IsStoryIDActive( "RESERVEREQ", true )
		if( storyActive == false ) then		
			local matchImp = GetUserImportance()
			local minMatchImportance = Tuning.RESERVE.minMatchImportance
			if( matchImp <= minMatchImportance ) then
				local chanceToStart = Tuning.RESERVE.chanceToStart
				if( RollPercentageDice( chanceToStart ) == true ) then
					local teamId = Engine.GetUserTeam()
					local storyPlayer = 0
					teamId = Engine.StackRankTeamByOverall( teamId )
					local numPlayers = Engine.GetNumPlayers( teamId )
					local listPlayers = {}
					for playerCount = numPlayers, 1, -1 do
						storyPlayer = Engine.GetPlayer( teamId, playerCount )
						local overall = Engine.GetPlayerOverall( storyPlayer )					
						local inStarting11 = Engine.IsPlayerInStartingLineup( teamId, storyPlayer )
						local bench = Engine.IsPlayerOnBench( teamId, storyPlayer )
						local ableToPlay = IsAbleToPlay( teamId, storyPlayer )
						if( inStarting11 == false and bench == false and ableToPlay == true ) then
							local playerTier = Engine.GetPlayerTier( teamId, storyPlayer )
							local minPlayerTier = Tuning.RESERVE.minPlayerTier
							if( playerTier > minPlayerTier ) then
								local playedLast = Engine.DidPlayInLastGame( teamId, storyPlayer )
								local happiness = Engine.GetPlayTimeMorale( teamId, storyPlayer )
								if( happiness ~= "HIGH" or happiness ~= "VERY_HIGH" ) then
									if( playedLast == false ) then
										table.insert( listPlayers, storyPlayer )
									end
								end
							end
						end
					end
					local numList = # listPlayers
					if( numList > 0 ) then
						local randChoice = Engine.GetRandomNumber( 1, numList )
						local chosenPlayer = listPlayers[ randChoice ]
						StartStory_ReserveRequest( teamId, chosenPlayer )
					end
				end
			end
		end
	end
end

function StartStory_ReserveRequest( teamId, storyPlayer )
	local storyId = "RESERVEREQ"
	local category = "RESERVE"
	local success = false
	local reserveRequestCooldown = Tuning.RESERVE.reserveRequestCooldown
	if( Engine.MarkPlayerForStory( teamId, storyPlayer, category, storyId, reserveRequestCooldown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.AddConversation( storyPlayer, "popup_reserverequest_appeal_", 1, 1, "popup_reserverequest_appeal_subject", currentStory, true )
		Engine.UpdateStoryActivity( currentStory )
		success = true
	end
	return success
end

function ReserveRequest_PostMatch( matchResult, gametype, playType )
	local category = "RESERVE"
	local storyId = "RESERVEREQ"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		local playerPlayed = Engine.DidPlayerPlay( storyTeam, storyPlayer, matchResult )
		local goalCount = 0
		local redCount = 0
		local newsWeight = Tuning.RESERVE.newsWeight
		if( playerPlayed == true ) then
			local playerRating = Engine.GetPlayerMatchRating( storyTeam, storyPlayer, matchResult )
			local fixture = Engine.GetCurrentGameFixtureData()
			local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
			local userTeam, cpuTeam = GetUserCpuTeamFromIds( team1, team2 )
			Engine.AddConversation( storyPlayer, "popup_reserverequest_played_", 1, 1, "popup_reserverequest_played_subject", currentStory, true )
			Engine.SetStringTeams( storyTeam )
			Engine.SetStringPlayers( storyPlayer )
			local newNews = Engine.CreateNews( "RESERVE", "news_title_reserverequest_played_", 1 )
			Engine.AddParagraph( newNews, newsWeight, "news_body_reserverequest_played_", 1 )
			local goodPlayerRating = Tuning.RESERVE.goodPlayerRating
			if( playerRating > goodPlayerRating ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
				Engine.SetNewsBackgroundImage( "FOOTBALL", newNews )
				Engine.SetNewsHeadlineByObject( newNews, "news_title_reserverequest_played_well_", 1 )
				Engine.SetNewsPlayer( newNews, storyPlayer )
				Engine.AddParagraph( newNews, newsWeight - 1, "news_body_reserverequest_played_well_", 1 )
			end
			local playerPotential = Engine.GetPlayerPotential( storyTeam, storyPlayer )
			local minPlayerPotential = Tuning.RESERVE.minPlayerPotential
			if( playerPotential > minPlayerPotential ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, newsWeight - 3, "news_body_reserverequest_played_highpotential_", 1 )
			end
			-- Incedents
			local numIncidents = Engine.GetNumberOfIncidents( matchResult )
			for incidentCount = 1, numIncidents do
				local type = Engine.GetIncidentTypeByIndex( matchResult, incidentCount )
				local incident = Engine.GetMatchIncidentByIndex( matchResult, incidentCount )
				if( type == "GOAL" ) then
					local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, incident )
					if(  playerId == storyPlayer ) then
						goalCount = goalCount + 1
					end
				elseif( type == "CARD" ) then
					local cardType = Engine.GetCardType( incident )
					if( cardType == "RED" ) then
						if(  playerId == storyPlayer ) then
							redCount = redCount + 1
						end
					end
				end
			end
			if( goalCount > 0 ) then
				local replacer1 = "locme_news_goals_goal"
				if( goalCount == 2 ) then
					replacer1 = "locme_news_goals_brace"
				elseif( goalCount == 3 ) then
					replacer1 = "locme_news_goals_hattrick"
				elseif( goalCount > 3 ) then
					replacer1 = "locme_news_goals_goals"
				end
				Engine.SetStringTeams( storyTeam, cpuTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, newsWeight - 4, "news_body_reserverequest_played_goal_", 1, replacer1 )
				Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.RESERVE.moraleModifierGoal )
			end
			if( redCount > 0 ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, newsWeight - 5, "news_body_reserverequest_played_red_", 1 )
			end
			if( Engine.DidPlayerGetInjured( storyTeam, storyPlayer, matchResult ) == true ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, newsWeight - 6, "news_body_reserverequest_played_injured_", 1 )
			end
			local appearances = Engine.GetPlayerStat( storyTeam, storyPlayer, "APPEARANCES" )
			if( appearances == 1 ) then
				Engine.SetStringTeams( storyTeam, cpuTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, newsWeight - 2, "news_body_reserverequest_played_debut_", 1 )
			end
			PublishArticle( currentStory, newNews, "MAJOR", storyTeam, storyPlayer )
			Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.RESERVE.moraleModifierArticle )
		end
		Engine.EndStoryId( storyId )
	end
end