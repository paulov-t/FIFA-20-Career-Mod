function ExamineFor_PlayerFeelsReplaced( storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	--if( Engine.GetPlayerTier( storyTeam, storyPlayer ) <= 2 ) then
	local chanceOfPfr = Tuning.PFR.chanceOfPfr
	if( RollPercentageDice( chanceOfPfr ) == true ) then
		local needPlayer = DoesTeamNeedPlayer( storyTeam, storyPlayer )
		if( needPlayer == false ) then
			StartStory_PlayerFeelsReplaced( storyTeam, storyPlayer )
		end
	end
	--end
end

function FindReplacedPlayer( teamId, playerId )
	local percThroughSeason = Engine.GetPercentageThroughSeason()
	if( percThroughSeason > Tuning.PFR.minPercentageThroughSeason ) then
		teamId = Engine.StackRankTeamByStat( teamId, "APPEARANCES" )
	else
		teamId = Engine.StackRankTeamByOverall( teamId )
	end
	local oldPlayerId = nil
	local topNumPlayers = Tuning.PFR.topNumPlayers
	local positionNew = Engine.GetPlayerPosition( teamId, playerId )
	local positionOld = nil
	local topTier = false
	for playerCount = 1, topNumPlayers do
		local oldPlayer = Engine.GetPlayer( teamId, playerCount )
		if( oldPlayer > 0 ) then
			local inStarting11 = Engine.IsPlayerInStartingLineup( teamId, oldPlayer )
			if( inStarting11 == false ) then
				positionOld = Engine.GetPlayerPosition( teamId, oldPlayer )
			else
				positionOld = Engine.GetPlayerCurrentPosition( teamId, oldPlayer )
			end
			local positionsEquate = Engine.DoPositionsEquate ( positionNew, positionOld )
			if( positionsEquate == true and oldPlayer ~= playerId ) then
				local oldTier = Engine.GetPlayerTier( teamId, oldPlayer )
				local numMonths = Engine.GetNumberOfMonthsSincePlayerJoined( teamId, oldPlayer )
				local minMonthsOnTeam = Tuning.PFR.minMonthsOnTeam
				if( numMonths >= minMonthsOnTeam ) then
					local playerAge = Engine.GetPlayerAge( teamId, oldPlayer )
					local maxPlayerAge = Tuning.PFR.maxPlayerAge
					if( playerAge < maxPlayerAge ) then
						local newPlayerOverall = Engine.GetPlayerOverall( playerId )
						local oldPlayerOverall = Engine.GetPlayerOverall( oldPlayer )
						local oldPlayerMinTier = Tuning.PFR.oldPlayerMinTier
						if( oldTier <= oldPlayerMinTier ) then
							local newUnderOldPlayerDiff = Tuning.PFR.newUnderOldPlayerDiff
							local newOverOldPlayerDiff = Tuning.PFR.newOverOldPlayerDiff
							if( ( oldPlayerOverall - newPlayerOverall ) <= newUnderOldPlayerDiff and ( newPlayerOverall - oldPlayerOverall ) <= newOverOldPlayerDiff ) then
								oldPlayerId = oldPlayer
								topTier = true
								break
							end
						else
							if( newPlayerOverall > oldPlayerOverall ) then
								oldPlayerId = oldPlayer
								break
							end
						end
					end
				end
			end
		end
	end
	return oldPlayerId, topTier
end

function DoesTeamNeedPlayer( teamId, playerId )
	local isTrue = true
	local area = Engine.GetPlayerPitchArea( teamId, playerId )
	teamId = Engine.StackRankTeamByOverall( teamId )
	local numberPlayers = 0
	for playerCount = 1, 18 do
		local player = Engine.GetPlayer( teamId, playerCount )
		local playerArea = Engine.GetPlayerPitchArea( teamId, player )
		if( playerArea == area ) then
			numberPlayers = numberPlayers + 1
		end
	end
	if( numberPlayers > 3 ) then
		isTrue = false
	end
	return isTrue
end

function StartStory_PlayerFeelsReplaced( teamId, playerId )
	local category = "REPLACEMENT"
	local storyId = "PFR"
	local oldPlayer, topTier = FindReplacedPlayer( teamId, playerId )
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == true ) then
		local userId = Engine.GetPlayAsPlayerID()
		if( oldPlayer == userId ) then
			storyId = "PFR_LOW"
		end
	end
	if( topTier == false ) then
		storyId = "PFR_LOW"
	end
	if( oldPlayer ~= nil ) then
		local pfrCooldown = Tuning.PFR.newOverOldPlayerDiff
		if( Engine.MarkPlayerForStory( teamId, oldPlayer, category, storyId, pfrCooldown ) == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			Engine.SetStoryVariable( currentStory, playerId )
			local pfrStartDelay = Tuning.PFR.pfrStartDelay
			Engine.AddDateEvent( "PFR", pfrStartDelay, storyId )
		end
	end
end

function PFR_Stage1( storyId )
	local category = "REPLACEMENT"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local teamId = Engine.GetStoryTeam( currentStory )
		local oldPlayer = Engine.GetStoryPlayer( currentStory )
		local playerId = Engine.GetStoryVariable( currentStory )
		local status, fee, wage, sellingTeam = Engine.GetPlayerTransferInfo( teamId, playerId )
		Engine.SetStringTeams( teamId, sellingTeam )
		Engine.SetStringPlayers( oldPlayer, playerId )
		local newNews = Engine.CreateNews( "FEELS_REPLACED", "news_title_pfr_speculation_", 4 )
		local newsWeight = Tuning.PFR.newsWeight
		Engine.SetStringTeams( teamId, sellingTeam )
		Engine.SetStringPlayers( oldPlayer, playerId )
		Engine.SetStringCurrency( fee )
		Engine.AddParagraph( newNews, newsWeight, "news_body_pfr_speculation_", 4 )
		local percThroughSeason = Engine.GetPercentageThroughSeason()
		if( percThroughSeason >= Tuning.PFR.minPercentageThroughSeasonStage1 ) then
			local playerForm = Engine.GetPlayerFormLevel( teamId, oldPlayer )
			Engine.SetStringTeams( teamId, sellingTeam )
			Engine.SetStringPlayers( oldPlayer, playerId )
			if( playerForm == "BAD" or playerForm == "VERY_BAD" ) then
				Engine.AddParagraph( newNews, newsWeight - 1, "news_body_pfr_speculation_poorform_", 4 )
			elseif( playerForm == "GOOD" or playerForm == "VERY_GOOD" ) then
				Engine.AddParagraph( newNews, newsWeight - 1, "news_body_pfr_speculation_goodform_", 4 )
			end
		end
		Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", oldPlayer, newNews )
		Engine.SetNewsForegroundImage( "RIGHT", "PLAYER_IMG", playerId, newNews )
		Engine.SetNewsBackgroundImage( "TRAINING_GROUNDS", newNews )
		PublishArticle( currentStory, newNews, "MAJOR", teamId, oldPlayer )
	end
	if( storyId == "PFR_LOW" ) then
		Engine.EndStoryId( storyId )
	end
end

function PFR_DynamicEvent( eventId, storyId )
	if( string.find( storyId, "PFR" ) ~= nil ) then
		if( eventId == "PFR" )then
			PFR_Stage1( storyId )
		elseif( eventId == "PFR4" )then
			PFR_Stage4( storyId )
		elseif( eventId == "PFR5" )then
			PFR_Stage5( storyId )
		end
	end
end

function PFR_Stage2_PostMatch( matchResult, gametype, playType )
	local storyId = "PFR"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( stage < 2 ) then
			fixture = Engine.GetCurrentGameFixtureData()
			local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
			local teamMI1, teamMI2 = Engine.GetMatchImportance( fixture )
			local matchImp = teamMI1
			if( team2 == Engine.GetUserTeam() ) then
				matchImp = teamMI2
			end
			local minMatchImportanceStage2 = Tuning.PFR.minMatchImportanceStage2
			if( matchImp > minMatchImportanceStage2 ) then
				local storyPlayer = Engine.GetStoryPlayer( currentStory )
				local storyTeam = Engine.GetStoryTeam( currentStory )
				local oldHappiness = Engine.GetPlayTimeMorale( storyTeam, storyPlayer )
				if( oldHappiness ~= "VERY_HAPPY" or oldHappiness ~= "HAPPY" ) then
					local newPlayerId = Engine.GetStoryVariable( currentStory )
					local newTeam = Engine.GetTeamIdFromPlayerId( newPlayerId )
					if( newTeam == storyTeam ) then
						local newPlayerRating = Engine.GetPlayerMatchRating( storyTeam, newPlayerId, matchResult )
						local oldPlayerPlayed = Engine.DidPlayerPlay( storyTeam, storyPlayer, matchResult )
						local newPlayerPlayed = Engine.DidPlayerPlay( storyTeam, newPlayerId, matchResult )
						if( oldPlayerPlayed == false ) then
							if( newPlayerPlayed == true ) then
								local newPlayerGoodRating = Tuning.PFR.newPlayerGoodRating
								if( newPlayerRating > newPlayerGoodRating ) then
									-- Replaced
									local newsWeight = Tuning.PFR.newsWeight
									Engine.SetStringTeams( storyTeam )
									Engine.SetStringPlayers( storyPlayer, newPlayerId )
									local newNews = Engine.CreateNews( "FEELS_REPLACED", "news_title_pfr_newplayerplayed_good_", 1 )
									Engine.AddParagraph( newNews, newsWeight, "news_body_pfr_newplayerplayed_good_", 1 )
									PublishArticle( currentStory, newNews, "MAJOR", storyTeam, newPlayerId )
								end
							end
						end
						Engine.SetStoryStage( currentStory, 2 )
					else
						Engine.EndStoryId( storyId )
					end
				end
			elseif( stage >= 5 ) then
				Engine.EndStoryId( storyId )
			end
		end
	end
end

function PFR_Stage3( teamId, playerId, oldHappiness, newHappiness )
	local storyId = "PFR"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		if( Engine.GetStoryStage( currentStory ) < 3 ) then
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			if( storyPlayer == playerId ) then
				local newPlayerId = Engine.GetStoryVariable( currentStory )
				local newPlayerHappiness = Engine.GetPlayTimeMorale( storyTeam, newPlayerId )
				if( Engine.DidPlayInLastGame( storyTeam, storyPlayer ) == false ) then
					local unhappy = false
					if( newHappiness == "LOW" ) then
						if( oldHappiness == "NORMAL" ) then
							unhappy = true
						end
					elseif( newHappiness == "VERY_LOW" ) then
						unhappy = true
					elseif( newHappiness == "NORMAL" ) then
						if( oldHappiness == "LOW" ) then
							Engine.EndStoryId( storyId )
						else
							unhappy = true
						end
					elseif( newHappiness == "HIGH" or newHappiness == "VERY_HIGH" ) then
						Engine.EndStoryId( storyId )
					end
					if( unhappy == true ) then
						Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_pfr_feelsreplaced_", 1, 1, "PlayerFeedbackPopUp_pfr_feelsreplaced_subject", currentStory, true )
						Engine.SetStoryMoraleOverride( currentStory, Tuning.PFR.moraleOverride )
						local pfrPlayerDecisionDelay = Tuning.PFR.pfrPlayerDecisionDelay
						Engine.AddDateEvent( "PFR4", pfrPlayerDecisionDelay, storyId )
						Engine.SetStoryStage( currentStory, 3 )
					end
				end
			end
		end
	end
end

function PFR_Stage4( storyId )
	local storyId = "PFR"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		local newPlayerId = Engine.GetStoryVariable( currentStory )
		local happiness = Engine.GetPlayTimeMorale( storyTeam, storyPlayer )
		if( happiness == "LOW" or happiness == "VERY_LOW" ) then
			Engine.SetStoryStage( currentStory, 5 )
			Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_pfr_transferrequest_", 1, 1, "PlayerFeedbackPopUp_pfr_transferrequest_subject", currentStory )
			Engine.MarkPlayerForStory( storyTeam, storyPlayer, "UNHAPPY", "UNHAPPY", 21 )
			Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.PFR.unhappyMoraleModifier )
		else
			Engine.SetStoryStage( currentStory, 6 )
			Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_pfr_happy_", 1, 1, "PlayerFeedbackPopUp_pfr_happy_subject", currentStory )
			Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.PFR.happyMoraleModifier )
		end
		Engine.AddDateEvent( "PFR5", 1, storyId )
	end
end

function PFR_Stage5( storyId )
	local storyId = "PFR"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		local storyStage = Engine.GetStoryStage( currentStory )
		local newPlayerId = Engine.GetStoryVariable( currentStory )
		if( storyStage > 3 ) then
			Engine.SetStringTeams( storyTeam )
			Engine.SetStringPlayers( storyPlayer, newPlayerId )
			local newsWeight = Tuning.PFR.newsWeight
			if( storyStage == 5 ) then
				local newNews = Engine.CreateNews( "FEELS_REPLACED", "news_title_pfr_transferrequest_", 1 )
				Engine.AddParagraph( newNews, newsWeight, "news_body_pfr_transferrequest_", 1 )
				PublishArticle( currentStory, newNews, "MAJOR", storyTeam, storyPlayer )
			elseif( storyStage == 6 ) then
				local newNews = Engine.CreateNews( "FEELS_REPLACED", "news_title_pfr_happy_", 1 )
				Engine.AddParagraph( newNews, newsWeight, "news_body_pfr_happy_", 1 )
				PublishArticle( currentStory, newNews, "MAJOR", storyTeam, storyPlayer )
			end
		end
	end
end

function PFR_TransferListed( teamId, playerId, leagueId, marketValue, currency )
	local userTeam = Engine.GetUserTeam()
	if( teamId == userTeam ) then
		local category = "REPLACEMENT"
		local storyId = "PFR"
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			local newPlayerId = Engine.GetStoryVariable( currentStory )
			if( playerId == storyPlayer ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer, newPlayerId )
				local newNews = Engine.CreateNews( "FEELS_REPLACED", "news_title_pfr_listed_", 1 )
				local newsWeight = Tuning.PFR.newsWeight
				Engine.AddParagraph( newNews, newsWeight, "news_body_pfr_listed_", 1 )
				Engine.SetNewsForegroundImage("CENTER", "PLAYER_IMG", storyPlayer, newNews)
				Engine.SetNewsForegroundImage("RIGHT", "CLUB_CREST", storyTeam, newNews)
				Engine.SetNewsBackgroundImage("FOR_SALE", newNews)
				PublishArticle( currentStory, newNews, "MAJOR", storyTeam, storyPlayer )
				Engine.EndStoryId( storyId )
			end	
		end
	end
end

function PFR_LoanListed( teamId, playerId, leagueId )
	local userTeam = Engine.GetUserTeam()
	if( teamId == userTeam ) then
		local category = "REPLACEMENT"
		local storyId = "PFR"
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			local newPlayerId = Engine.GetStoryVariable( currentStory )
			if( playerId == storyPlayer ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer, newPlayerId )
				local newNews = Engine.CreateNews( "FEELS_REPLACED", "news_title_pfr_loanlisted_", 1 )
				local newsWeight = Tuning.PFR.newsWeight
				Engine.AddParagraph( newNews, newsWeight, "news_body_pfr_loanlisted_", 1 )
				Engine.SetNewsForegroundImage("CENTER", "PLAYER_IMG", storyPlayer, newNews)
				Engine.SetNewsForegroundImage("RIGHT", "CLUB_CREST", storyTeam, newNews)
				Engine.SetNewsBackgroundImage("FOR_SALE", newNews)
				PublishArticle( currentStory, newNews, "MAJOR", storyTeam, storyPlayer )
				Engine.EndStoryId( storyId )
			end	
		end
	end
end

function PFR_Released( teamId, playerId )
	local userTeam = Engine.GetUserTeam()
	if( teamId == userTeam ) then
		local category = "REPLACEMENT"
		local storyId = "PFR"
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			local newPlayerId = Engine.GetStoryVariable( currentStory )
			if( playerId == storyPlayer ) then
				Engine.SetStringTeams( storyTeam )
				Engine.SetStringPlayers( storyPlayer, newPlayerId )
				local newNews = Engine.CreateNews( "FEELS_REPLACED", "news_title_pfr_released_", 1 )
				local newsWeight = Tuning.PFR.newsWeight
				Engine.AddParagraph( newNews, newsWeight, "news_body_pfr_released_", 1 )
				Engine.SetNewsForegroundImage("CENTER", "PLAYER_IMG", storyPlayer, newNews)
				Engine.SetNewsForegroundImage("RIGHT", "CLUB_CREST", storyTeam, newNews)
				Engine.SetNewsBackgroundImage("FOR_SALE", newNews)
				PublishArticle( currentStory, newNews, "MAJOR", storyTeam, storyPlayer )
			end	
		end
	end
end