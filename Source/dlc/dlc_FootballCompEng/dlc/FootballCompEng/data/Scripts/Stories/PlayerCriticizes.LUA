function ExamineFor_PlayerCriticizes( numDays, gametype, fixture ) -- Pre match
	local maxNumDays = Tuning.CRITICIZE.maxNumDays
	if( numDays == maxNumDays ) then
		if( gametype ~= "FRIENDLY" ) then
			local storyId = "PLAYERCRIT"
			local storyActive = Engine.IsStoryIDActive( storyId, true )	
			if( storyActive == false ) then
				local matchImp = GetUserImportance()
				local minMatchImportance = Tuning.CRITICIZE.minMatchImportance
				if( matchImp > minMatchImportance ) then
					local userTeam = Engine.GetUserTeam()
					local maxPlayersToCheck = Engine.GetNumPlayers( userTeam )
					userTeam = Engine.StackRankTeamByOverall( userTeam )
					for playerCount = 1, maxPlayersToCheck do
						local storyPlayer = Engine.GetPlayer( userTeam, playerCount )
						local playerTier = Engine.GetPlayerTier( userTeam, storyPlayer )
						local ableToPlay = IsAbleToPlay( userTeam, storyPlayer )
						local inStarting11 = Engine.IsPlayerInStartingLineup( userTeam, storyPlayer )
						local playerPos = Engine.GetPlayerPosition( userTeam, storyPlayer )
						local minPlayerTier = Tuning.CRITICIZE.minPlayerTier
						if( playerTier <= minPlayerTier ) then
							if( ableToPlay == true ) then
								if( inStarting11 == false ) then
									if( Engine.GetNumberOfMonthsSincePlayerJoined( userTeam, storyPlayer ) >= Tuning.CRITICIZE.minMonthsToCriticize ) then
										local chanceOfStarting = Tuning.CRITICIZE.chanceOfStarting
										local selfish = Engine.HasPlayerTrait( userTeam, storyPlayer, "SELFISH" )
										if( selfish == true ) then
											chanceOfStarting = 100
										end
										if( RollPercentageDice( chanceOfStarting ) == true ) then
											local weakerPlayer = FindWeakerPlayerPlaying( userTeam, storyPlayer )
											if( weakerPlayer ~= nil ) then
												if( StartStory_PlayerCriticizes( userTeam, storyPlayer, weakerPlayer ) == true ) then
													break
												end
											end
										else
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function StartStory_PlayerCriticizes( userTeam, storyPlayer, weakerPlayer )
	local category = "CRITICIZE"
	local storyId = "PLAYERCRIT"
	local success = false
	local criticizeCooldown = Tuning.CRITICIZE.criticizeCooldown
	if( Engine.MarkPlayerForStory( userTeam, storyPlayer, category, storyId, criticizeCooldown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryVariable( currentStory, weakerPlayer )
		Engine.SetStringPlayers( storyPlayer, weakerPlayer )
		Engine.AddConversation( storyPlayer, "popup_criticizes_appeal_", 1, 4, "popup_criticizes_appeal_subject", currentStory, true )
		Engine.SetStoryStage( currentStory, 1 )
		success = true
	end
	return success
end

function FindWeakerPlayerPlaying( userTeam, storyPlayer )
	local weakPlayerFound = nil
	local maxPlayersToCheck = Engine.GetNumPlayers( userTeam )
	for playerCount = 1, maxPlayersToCheck do
		local weakerPlayer = Engine.GetPlayer( userTeam, playerCount )
		if( weakerPlayer ~= storyPlayer ) then
			local isStarting = Engine.IsPlayerInStartingLineup( userTeam, weakerPlayer )
			if( isStarting == true ) then
				local playerPos = Engine.GetPlayerPosition( userTeam, storyPlayer )
				local weakPlayerPos = Engine.GetPlayerCurrentPosition( userTeam, weakerPlayer )
				local positionsEquate = Engine.DoPositionsEquate ( weakPlayerPos, playerPos )
				if( positionsEquate == true ) then
					local playerOvr = Engine.GetPlayerOverall( storyPlayer )
					local weakerPlayerOvr = Engine.GetPlayerOverall( weakerPlayer )
					local playerOvrDifference = Tuning.CRITICIZE.playerOvrDifference
					if( ( playerOvr - weakerPlayerOvr ) >= playerOvrDifference ) then -- 10
						if( IsAbleToPlay( userTeam, weakerPlayer ) == true ) then
							weakPlayerFound = weakerPlayer
							break
						end
					end
				end
			end
		end
	end
	return weakPlayerFound	
end

function PlayerCriticizes_Stages( matchResult, gametype, playType ) -- Post Match
	local category = "CRITICIZE"
	local storyId = "PLAYERCRIT"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local minMatchImportance = Tuning.CRITICIZE.minMatchImportance
		if( GetUserImportance() > minMatchImportance ) then -- 85
			local wasGameWon = Engine.WasGameWon( matchResult )
			local matchWinner = Engine.GetMatchWinner( matchResult )
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			local playerPlayed = Engine.DidPlayerPlay( storyTeam, storyPlayer, matchResult )
			local weakerPlayer = Engine.GetStoryVariable( currentStory )
			local stage = Engine.GetStoryStage( currentStory )
			if( stage < 2 ) then
				local chanceOfCriticize = Tuning.CRITICIZE.chanceOfCriticize
				local selfish = Engine.HasPlayerTrait( storyTeam, storyPlayer, "SELFISH" )
				if( selfish == true ) then
					chanceOfCriticize = 100
				end
				if( RollPercentageDice( chanceOfCriticize ) == true ) then --50
					if( playerPlayed == true ) then
						if( matchWinner == storyTeam ) then
							Engine.AddConversation( storyPlayer, "popup_criticizes_played_won_", 1, 4, "popup_criticizes_played_subject", currentStory )
						else
							Engine.AddConversation( storyPlayer, "popup_criticizes_played_", 1, 4, "popup_criticizes_played_subject", currentStory )
							Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.CRITICIZE.moraleModifierWinner )
						end
						Engine.EndStoryId( storyId )
					else
						local weakPlayerScored = false
						local numIncidents = Engine.GetNumberOfIncidents( matchResult )
						for incidentCount = 1, numIncidents do
							local type = Engine.GetIncidentTypeByIndex( matchResult, incidentCount )
							if( type == "GOAL" ) then
								local incident = Engine.GetMatchIncidentByIndex( matchResult, incidentCount )
								local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, incident )
								if( playerId == weakerPlayer ) then
									weakPlayerScored = true
								end
							end
						end
						if( weakPlayerScored == false ) then
							if( wasGameWon == true ) then
								if( matchWinner ~= storyTeam ) then
									Engine.AddConversation( storyPlayer, "popup_criticizes_notplayed_", 1, 4, "popup_criticizes_notplayed_subject", currentStory )
								end
							else
								Engine.AddConversation( storyPlayer, "popup_criticizes_notplayed_", 1, 4, "popup_criticizes_notplayed_subject", currentStory )
							end
						end
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.CRITICIZE.moraleModifierLoser )
					end
				end
				Engine.SetStoryStage( currentStory, 2 )
			elseif( stage == 2 ) then
				if( playerPlayed == false ) then
					Engine.SetStringTeams( storyTeam )
					Engine.SetStringPlayers( storyPlayer, weakerPlayer )
					local newNews = Engine.CreateNews( "CRITICIZE", "news_title_criticizes_notplayed_", 4 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam, newNews )
					Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE", newNews )
					Engine.SetStringTeams( storyTeam )
					Engine.SetStringPlayers( storyPlayer, weakerPlayer )
					local chanceToRequestTransfer = Tuning.CRITICIZE.chanceToRequestTransfer
					local selfish = Engine.HasPlayerTrait( storyTeam, storyPlayer, "SELFISH" )
					if( selfish == true ) then
						chanceToRequestTransfer = 100
					end
					if( RollPercentageDice( chanceToRequestTransfer ) == true ) then -- 50
						Engine.AddParagraph( newNews, 2, "news_body_criticizes_selfish_", 3 )
					else
						Engine.AddParagraph( newNews, 2, "news_body_criticizes_team_", 4 )
					end
					PublishArticle( currentStory, newNews, "MAJOR", storyTeam, storyPlayer )
					Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.CRITICIZE.moraleModifierStage2 )
				end
				Engine.SetStoryStage( currentStory, 3 )
			elseif( stage == 3 ) then
				Engine.EndStoryId( storyId )
			end
		end
	end
end

function PlayerCriticizes_TransferListed( teamId, playerId, leagueId, marketValue, currency )
	local userTeam = Engine.GetUserTeam()
	if( teamId == userTeam ) then
		local category = "CRITICIZE"
		local storyId = "PLAYERCRIT"
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			if( playerId == storyPlayer ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				local newNews = Engine.CreateNews( "LOSTPLAYERS", "news_title_criticizes_transferListed_", 4 )
				Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE", newNews )
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, 1, "news_body_criticizes_transferListed_", 4 )
				PublishArticle( currentStory, newNews, "MAJOR", userTeam, playerId )
				Engine.EndStoryId( storyId )
			end
		end
	end
end

function PlayerCriticizes_LoanListed( teamId, playerId, leagueId )
	local userTeam = Engine.GetUserTeam()
	if( teamId == userTeam ) then
		local category = "CRITICIZE"
		local storyId = "PLAYERCRIT"
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			if( playerId == storyPlayer ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				local newNews = Engine.CreateNews( "LOSTPLAYERS", "news_title_criticizes_loanlisted_", 4 )
				Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE", newNews )
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, 1, "news_body_criticizes_loanlisted_", 4 )
				PublishArticle( currentStory, newNews, "MAJOR", userTeam, playerId )
				Engine.EndStoryId( storyId )
			end	
		end
	end
end

function PlayerCriticizes_Released( teamId, playerId )
	local userTeam = Engine.GetUserTeam()
	if( teamId == userTeam ) then
		local category = "CRITICIZE"
		local storyId = "PLAYERCRIT"
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			if( playerId == storyPlayer ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				local newNews = Engine.CreateNews( "LOSTPLAYERS", "news_title_criticizes_Released_", 4 )
				Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE", newNews )
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer )
				Engine.AddParagraph( newNews, 1, "news_body_criticizes_Released_", 4 )
				PublishArticle( currentStory, newNews, "MAJOR", userTeam, playerId )
				Engine.EndStoryId( storyId )
			end	
		end
	end
end