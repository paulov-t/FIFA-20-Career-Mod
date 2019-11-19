function StartStory_LostPlayer( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeVaue, realDate )
	local baseStoryId = "LOSTPLAYER"
	local category = "LOST"
	local numStories = Engine.GetNumStoriesByCategory( category )
	local storyId = baseStoryId .. numStories
	local sellingTeam = Engine.GetUserTeam()
	local teamToCheck = sellingTeam
	local replacement = true
	if( transfer == "REAL_WORLD" ) then
		teamToCheck = buyingTeam
	end
	local playerTier = Engine.GetPlayerTier( teamToCheck, playerId )
	local topTierPlayer = Tuning.LOSTPLAYER.topTierPlayer --2
	local allowNews = true
	local involved1 = Engine.IsPlayerInvolvedInStoryCategory( playerId, "OVERPRICED" )
	local involved2 = Engine.IsPlayerInvolvedInStoryCategory( playerId, "UNDERPRICED" )
	local endStoryPlayer = playerId
	local playerReplaced = false
	if( involved1 == true or involved2 == true ) then
		allowNews = false
	end
	if( playerTier < topTierPlayer ) then
		local storyActive = Engine.IsStoryIDActive( "LOSTTOP" )
		if( storyActive == false ) then
			storyId = "LOSTTOP"
		else
			local currentStory = Engine.GetStoryById( "LOSTTOP" )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			local oldPlayerOverall = Engine.GetPlayerOverall( storyPlayer )
			local newPlayerOverall = Engine.GetPlayerOverall( playerId )
			if( newPlayerOverall > oldPlayerOverall ) then
				Engine.EndAllStoriesForPlayer( endStoryPlayer )
				Engine.ReplaceStoryPlayer( currentStory, buyingTeam, playerId )
				Engine.UpdateStoryActivity( currentStory )
				Engine.SetStoryStage( currentStory, 1 )
				playerReplaced = true
				if( allowNews == true ) then
					LostTopPlayerNews( buyingTeam, playerId, currentStory, realDate )
				end
				Engine.SetStoryAllowTransferNews( currentStory, false )
				if( Engine.IsStoryIDActive( "LOSTREPLACE" ) == false ) then
					if( transfer ~= "REAL_WORLD" ) then
						if( Engine.IsPlayerInStartingLineup( teamToCheck, playerId ) == true or playerTier == 1 ) then
							StartStory_TopPlayerReplacement( buyingTeam, playerId, sellingTeam, transfer )
							replacement = false
						end
					end
				end
				playerId = storyPlayer
				buyingTeam = storyTeam
			else
				AcceptOffer_CounterOffer( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue )
			end
		end
	else
		AcceptOffer_CounterOffer( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue )
	end
	local saga = false
	if( IsPlayerInvolvedInSaga( playerId ) == true ) then
		if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "NEGOTIATE" ) == false ) then
			saga = true
		end
	end
	if( playerReplaced == false ) then
		Engine.EndAllStoriesForPlayer( endStoryPlayer )
	end
	local lostPlayerCoolDown = Tuning.LOSTPLAYER.lostPlayerCoolDown
	if( Engine.MarkPlayerForStory( buyingTeam, playerId, category, storyId, lostPlayerCoolDown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		if( playerReplaced == false and playerTier < 3 ) then
			Engine.UpdateStoryActivity( currentStory )
		end
		Engine.SetStoryPriority( currentStory, 1 )
		if( storyId == "LOSTTOP" ) then
			if( saga == false )then
				if( allowNews == true ) then
					LostTopPlayerNews( buyingTeam, playerId, currentStory, realDate )
				end
			end
			local clubProgressDelay = Tuning.LOSTPLAYER.clubProgressDelay
			local playerProgressDelay = Tuning.LOSTPLAYER.playerProgressDelay
			Engine.AddDateEvent( "LostClubProgress", clubProgressDelay, storyId ) -- 90 Days
			Engine.AddDateEvent( "LostPlayerProgress", playerProgressDelay, storyId ) -- 60 Days
			Engine.SetStoryAllowTransferNews( currentStory, false )
		end
		if( Engine.IsStoryIDActive( "LOSTREPLACE" ) == false ) then
			if( replacement == true ) then
				if( transfer ~= "REAL_WORLD" ) then
					if( playerTier <= 2 ) then
						if( Engine.IsPlayerInStartingLineup( teamToCheck, playerId ) == true or playerTier == 1 ) then
							StartStory_TopPlayerReplacement( buyingTeam, playerId, sellingTeam, transfer )
						end
					end
				end
			end
		end
		if( storyId == "LOSTTOP" or playerReplaced == true ) then
			if( realDate < 0 ) then
				ManagerAtRisk_SoldTopPlayer( sellingTeam, buyingTeam, endStoryPlayer, "LOSTTOP" )
			end
		end
		Engine.SetStoryVariable( currentStory, sellingTeam )
		Engine.SetStoryStage( currentStory, 1 )
	end
end

function LostTopPlayerNews( buyingTeam, playerId, currentStory, realDate )
	local displayNews = true
	local numStories = Engine.GetNumStoriesByCategory( "SIGNING" )
	if( numStories > 0 ) then
		for storyCount = 1, numStories do
			local currentStory = Engine.GetStoryByCategoryAndIndex( "SIGNING", storyCount )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )	
			local ovr1 = Engine.GetPlayerOverall( storyPlayer )
			local ovr2 = Engine.GetPlayerOverall( playerId )
			if( ( ovr1 - ovr2 ) < -5 ) then
				displayNews = false
				break
			end
		end
	end
	if( displayNews == true ) then
		local sellingTeam = Engine.GetUserTeam()
		local status, fee, wage = Engine.GetPlayerTransferInfo( buyingTeam, playerId )
		Engine.SetStringTeams( sellingTeam, buyingTeam )
		Engine.SetStringPlayers( playerId )
		Engine.SetStringCurrency( fee )
		local newNews = Engine.CreateNews( "LOST_PLAYER", "news_title_lost_topplayer_", 4 )
		Engine.SetNewsForegroundImage( "LEFT", "CLUB_CREST", sellingTeam, newNews )
		Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId, newNews )
		Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", buyingTeam, newNews )
		Engine.SetNewsBackgroundImage( "CONTRACT", newNews )
		Engine.SetStringTeams( sellingTeam, buyingTeam )
		Engine.SetStringPlayers( playerId )
		Engine.AddParagraph( newNews, 2, "news_body_lost_topplayer_", 4 )
		local isRival = Engine.AreTeamsRivals( buyingTeam, sellingTeam )
		local isDerby = Engine.AreTeamsDerby( buyingTeam, sellingTeam )
		if( isRival == true or isDerby == true ) then
			Engine.SetStringTeams( sellingTeam, buyingTeam )
			Engine.SetStringPlayers( playerId )
			Engine.AddParagraph( newNews, 1, "news_body_lost_topplayer_rivals_", 4 )
		end
		if( realDate > -1 ) then
			Engine.OverrideNewsDate( newNews, realDate )
		end
		PublishArticle( currentStory, newNews, "MAJOR", sellingTeam, playerId )
	end
end

function StartStory_TopPlayerReplacement( buyingTeam, playerId, sellingTeam, transfer )
	local storyId = "LOSTREPLACE"
	local category = "LOSTREPLACE"
	local teamToCheck = sellingTeam
	if( transfer == "REAL_WORLD" ) then
		teamToCheck = buyingTeam
	end
	local oldPlayerPos = Engine.GetPlayerPosition( teamToCheck, playerId )
	sellingTeam = Engine.StackRankTeamByOverall( sellingTeam )
	local numPlayers = Engine.GetNumPlayers( sellingTeam )
	local player1 = 0
	local player2 = 0
	local success = false
	for playerCount = 1, numPlayers do
		local player = Engine.GetPlayer( sellingTeam, playerCount )
		local newPlayerPos = Engine.GetPlayerPosition( sellingTeam, player )
		if( newPlayerPos == oldPlayerPos and player ~= playerId ) then -- tier
			local monthsJoined = Engine.GetNumberOfMonthsSincePlayerJoined( sellingTeam, player )
			local playerAge = Engine.GetPlayerAge( sellingTeam, player )
			local minMonthsJoined = Tuning.LOSTPLAYER.minMonthsJoined
			local maxPlayerAge = Tuning.LOSTPLAYER.maxPlayerAge
			if( monthsJoined > minMonthsJoined and playerAge < maxPlayerAge ) then
				local inStarting11 = Engine.IsPlayerInStartingLineup( sellingTeam, player )
				if( inStarting11 == false ) then
					local lostPlayerOverall = Engine.GetPlayerOverall( playerId )
					local replacementPlayerOverall = Engine.GetPlayerOverall( player )
					local replacementMinDiff = Tuning.LOSTPLAYER.replacementMinDiff --0
					local replacementMaxDiff = Tuning.LOSTPLAYER.replacementMaxDiff --15
					if( ( lostPlayerOverall - replacementPlayerOverall ) >= replacementMinDiff and ( lostPlayerOverall - replacementPlayerOverall ) <= replacementMaxDiff ) then
						if( player1 == 0 ) then
							player1 = player
						else
							player2 = player
							success = true
						end
						local storyPlayer = player1
						if( success == true ) then
							local chanceOfSecondBest = Tuning.LOSTPLAYER.chanceOfSecondBest
							local choice = RollPercentageDice( chanceOfSecondBest )
							if( choice == true ) then
								storyPlayer = player2
							end
						end
						local replacementPlayerCoolDown = Tuning.LOSTPLAYER.replacementPlayerCoolDown
						if( Engine.MarkPlayerForStory( sellingTeam, storyPlayer, category, storyId, replacementPlayerCoolDown ) == true ) then
							local currentStory = Engine.GetStoryById( storyId )
							Engine.SetStoryPriority( currentStory, 4 )
							Engine.SetStoryVariable( currentStory, playerId )
							local replacementPlayerDelay = Tuning.LOSTPLAYER.replacementPlayerDelay
							Engine.AddDateEvent( "LostReplacementPlayer", replacementPlayerDelay, storyId ) -- 2 Days
						end
					end
				end
			end
		end
	end
end

function LostPlayerDynamicEvent( eventId, storyId )
	if( string.find( eventId, "Lost" ) ~= nil ) then
		if( eventId == "LostReplacementPlayer" ) then
			LostTopPlayerReplacement( storyId )
		elseif( eventId == "LostPlayerProgress" ) then
			LostPlayerProgress( storyId )
		elseif( eventId == "LostReplacementProg" ) then
			LostPlayerReplacementProgress( storyId )
		elseif( eventId == "LostClubProgress" ) then
			LostPlayerClubProgress( storyId )
		elseif( eventId == "LostPlayerSummary" ) then
			LostPlayerSummary()
		end
	end
end

function LostTopPlayerReplacement( storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local storyVar = tonumber( Engine.GetStoryVariable( currentStory ) )
	Engine.SetStringPlayers( storyPlayer, storyVar )
	Engine.AddConversation( storyPlayer, "popup_lost_Replacement_", 1, 1, "popup_lost_Replacement_subject", currentStory, true )
	Engine.SetStoryStage( currentStory, 1 )
	local randDay = Engine.GetRandomNumber( 1, 2 )
	local numDay = Tuning.LOSTPLAYER.replacementProgDelayLow
	if( randDay == 2 ) then
		numDay = Tuning.LOSTPLAYER.replacementProgDelayHigh
	end
	Engine.AddDateEvent( "LostReplacementProg", numDay, storyId ) -- Either 30 or 60
end

function LostPlayer_WindowPassed( numDays )
	if( numDays == 0 ) then
		Engine.AddDateEvent( "LostPlayerSummary", 1 )
	end
end
	
function LostPlayerSummary()
	local storyId = "LOSTTOP"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local userTeam = Engine.GetUserTeam()
		local sellingTeam = tonumber( Engine.GetStoryVariable( currentStory ) )
		if( sellingTeam == userTeam ) then
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			local storyTeam = Engine.GetStoryTeam( currentStory )
			local status, fee, wage = Engine.GetPlayerTransferInfo( storyTeam, storyPlayer )
			Engine.SetStringTeams( sellingTeam, storyTeam )
			Engine.SetStringPlayers( storyPlayer, storyPlayer )
			local newNews = Engine.CreateNews( "LOSTPLAYERS", "news_title_lost_lostplayers_", 4 )
			Engine.SetNewsForegroundImage( "LEFT", "CLUB_CREST", sellingTeam, newNews )
			Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
			Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam, newNews )
			Engine.SetNewsBackgroundImage( "CONTRACT", newNews )
			Engine.SetStringTeams( sellingTeam, storyTeam )
			Engine.SetStringPlayers( storyPlayer, storyPlayer )
			Engine.SetStringCurrency( fee )
			local newsPriority = Tuning.LOSTPLAYER.summaryNewsPriority
			Engine.AddParagraph( newNews, newsPriority, "news_body_lost_topplayer_summary_", 4 )
			--Find Replacement
			local category = "SIGNING"
			local numStories = Engine.GetNumStoriesByCategory( category )
			if( numStories > 0 ) then
				local replacement = 0
				for storyCount = 1, numStories do
					local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
					local newPlayer = Engine.GetStoryPlayer( currentStory )
					local oldPlayerArea = Engine.GetPlayerPitchArea( storyTeam, storyPlayer )
					local newPlayerArea = Engine.GetPlayerPitchArea( sellingTeam, newPlayer )
					if( oldPlayerArea == newPlayerArea ) then
						if( replacement == 0 ) then
							replacement = newPlayer
						else
							local oldOvr = Engine.GetPlayerOverall( replacement )
							local newOvr = Engine.GetPlayerOverall( newPlayer )
							if( newOvr > oldOvr ) then
								replacement = newPlayer
							end
						end
					end
				end
				if( replacement > 0 ) then
					local replacementOvr = Engine.GetPlayerOverall( replacement )
					local lostOvr = Engine.GetPlayerOverall( storyPlayer )
					local secondStatus, secondFee, secondWage = Engine.GetPlayerTransferInfo( sellingTeam, replacement )
					Engine.SetStringTeams( sellingTeam, sellingTeam )
					Engine.SetStringPlayers( replacement, replacement )
					Engine.SetStringMultiCurrency( fee, secondFee )
					local newSigning = false
					if( replacementOvr > lostOvr ) then
						Engine.AddParagraph( newNews, newsPriority - 1, "news_body_lost_topplayer_summary_replacement_high_", 4 )
						newSigning = true
					elseif( lostOvr - replacementOvr < 3 ) then
						Engine.AddParagraph( newNews, newsPriority - 1, "news_body_lost_topplayer_summary_replacement_high_", 4 )
						newSigning = true
					else
						Engine.AddParagraph( newNews, newsPriority - 1, "news_body_lost_topplayer_summary_replacement_low_", 4 )
					end
					-- Manager At Risk - Sold Top Player Resolution
					if( newSigning == true ) then
						if( Engine.IsStoryIDActive( "AT_RISK" ) == true ) then
							local currentStory1 = Engine.GetStoryById( "AT_RISK" )
							local var = Engine.GetStoryVariable( currentStory1 )
							if( var == "soldtopplayer" ) then
								local season = Engine.GetSeasonCount()
								if( season == 1 ) then
									Engine.SetStoryVariable( currentStory1, "untested" )
								else
									Engine.EndStoryId( "AT_RISK" )
								end
							end
						end
					end
				end
			end
			PublishArticle( nil, newNews, "MAJOR", sellingTeam, storyPlayer )
		end
	end
end

function LostPlayerProgress( storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local userTeam = Engine.GetUserTeam()
	local playerForm = nil
	
	local storyTeamLeague = Engine.GetLeagueId( storyTeam )
	local userTeamLeague = Engine.GetLeagueId( userTeam )
	if( storyTeamLeague == userTeamLeague ) then
		playerForm = Engine.GetPlayerFormLevel( storyTeam, storyPlayer )
	else
		local randNum = Engine.GetRandomNumber( 1, 3 )
		if( randNum == 1 ) then
			playerForm = "GOOD"
		elseif( randNum == 2 ) then
			playerForm = "BAD"
		else
			playerForm = "NEUTRAL"
		end
	end
	Engine.SetStringTeams( storyTeam, userTeam )
	Engine.SetStringPlayers( storyPlayer )
	local newNews = Engine.CreateNews( "LOSTPLAYERPROG", "news_title_lost_lostplayerprogress_doingaverage_", 4 )
	Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
	Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam, newNews )
	Engine.SetNewsBackgroundImage( "FOOTBALL", newNews )
	Engine.SetStringTeams( storyTeam, userTeam )
	Engine.SetStringPlayers( storyPlayer )
	local status, fee, wage = Engine.GetPlayerTransferInfo( storyTeam, storyPlayer )
	local newsPriority = Tuning.LOSTPLAYER.progressNewsPriority
	Engine.SetStringCurrency( fee )
	if( playerForm == "GOOD" or playerForm == "VERY_GOOD" ) then
		Engine.SetNewsHeadlineByObject( newNews, "news_title_lost_lostplayerprogress_doingwell_", 4 )
		Engine.AddParagraph( newNews, newsPriority, "news_body_lost_lostplayerprogress_doingwell_", 4 )
		Engine.SetStoryStage( currentStory, 2 )
	elseif( playerForm == "BAD" or playerForm == "VERY_BAD" ) then
		Engine.SetNewsHeadlineByObject( newNews, "news_title_lost_lostplayerprogress_doingpoorly_", 4 )
		Engine.AddParagraph( newNews, newsPriority, "news_body_lost_lostplayerprogress_doingpoorly_", 4 )
		Engine.SetStoryStage( currentStory, 3 )
	else
		Engine.AddParagraph( newNews, newsPriority, "news_body_lost_lostplayerprogress_doingaverage_", 4 )
		Engine.SetStoryStage( currentStory, 3 )
	end
	Engine.SetNewsImportance( newNews, "MAJOR" )
	Engine.SetNewsTeamById( "LOSTPLAYERPROG", storyTeam )
	Engine.SetNewsPlayer( newNews, storyPlayer )
	Engine.SetNewsType( "CLUB", newNews )
	Engine.SendNews( newNews )
end

function LostPlayerReplacementProgress( storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local playerForm = Engine.GetPlayerFormLevel( storyTeam, storyPlayer )
	local storyVar = tonumber( Engine.GetStoryVariable( currentStory ) )
	local newTeam = Engine.GetTeamIdFromPlayerId( storyVar )
	Engine.SetStringTeams( storyTeam, newTeam )
	Engine.SetStringPlayers( storyPlayer, storyVar )
	local newNews = Engine.CreateNews( "REPLACEPLAYERPROG", "news_title_lost_replaceplayerprogress_doingaverage_", 4 )
	Engine.SetStringTeams( storyTeam, newTeam )
	Engine.SetStringPlayers( storyPlayer, storyVar )
	local newsPriority = Tuning.LOSTPLAYER.progressNewsPriority
	local status, fee, wage = Engine.GetPlayerTransferInfo( newTeam, storyVar )
	Engine.SetStringCurrency( fee )
	Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
	Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam, newNews )
	if( playerForm == "GOOD" or playerForm == "VERY_GOOD" ) then
		Engine.SetNewsBackgroundImage( "GRAPH_RISING", newNews )
		Engine.SetNewsHeadlineByObject( newNews, "news_title_lost_replaceplayerprogress_doingwell_", 4 )
		Engine.SetStringTeams( storyTeam, newTeam )
		Engine.SetStringPlayers( storyPlayer, storyVar )
		Engine.SetStoryStage( currentStory, 2 )
		Engine.AddParagraph( newNews, newsPriority, "news_body_lost_replaceplayerprogress_doingwell_", 4 )	
		-- Manager At Risk - Sold Top Player Resolution
		if( Engine.IsStoryIDActive( "AT_RISK" ) == true ) then
			local currentStory1 = Engine.GetStoryById( "AT_RISK" )
			local var = Engine.GetStoryVariable( currentStory1 )
			if( var == "soldtopplayer" ) then
				local season = Engine.GetSeasonCount()
				if( season == 1 ) then
					Engine.SetStoryVariable( currentStory1, "untested" )
				else
					Engine.EndStoryId( "AT_RISK" )
				end
			end
		end
	elseif( playerForm == "BAD" or playerForm == "VERY_BAD" ) then
		Engine.SetNewsBackgroundImage( "GRAPH_DROPPING", newNews )
		Engine.SetNewsHeadlineByObject( newNews, "news_title_lost_replaceplayerprogress_doingpoorly_", 4 )
		Engine.SetStringTeams( storyTeam, newTeam )
		Engine.SetStringPlayers( storyPlayer, storyVar )
		Engine.AddParagraph( newNews, newsPriority, "news_body_lost_replaceplayerprogress_doingpoorly_", 2 )
		Engine.SetStoryStage( currentStory, 3 )
	else
		Engine.SetNewsBackgroundImage( "FANS_CELEBRATING", newNews )
		Engine.AddParagraph( newNews, newsPriority, "news_body_lost_replaceplayerprogress_doingaverage_", 4 )
		Engine.SetStoryStage( currentStory, 3 )
	end
	Engine.KillStoryAfterMatch( currentStory )
	Engine.SetNewsImportance( newNews, "MAJOR" )
	Engine.SetNewsTeamById( "REPLACEPLAYERPROG", storyTeam )
	Engine.SetNewsPlayer( newNews, storyPlayer )
	Engine.SendNews( newNews )
end

function LostPlayerClubProgress( storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local oldTeam = Engine.GetStoryVariable( currentStory )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local meetingObj = IsMeetingObjective( oldTeam )
	Engine.SetStringTeams( oldTeam, storyTeam )
	Engine.SetStringPlayers( storyPlayer, storyPlayer )
	local newNews = Engine.CreateNews( "LOSTTEAMPROG", "news_title_lost_lostteamprogress_doingwell_", 4 )
	Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", storyTeam, newNews )
	Engine.SetStringTeams( oldTeam, storyTeam )
	Engine.SetStringPlayers( storyPlayer, storyPlayer )
	if( meetingObj == true ) then
		Engine.SetNewsBackgroundImage( "FULL_STADIUM", newNews )
		Engine.AddParagraph( newNews, 2, "news_body_lost_lostteamprogress_doingwell_", 4 )
		Engine.SetStoryStage( currentStory, 4 )
	else
		Engine.SetNewsBackgroundImage( "EMPTY_STADIUM", newNews )
		Engine.SetNewsHeadlineByObject( newNews, "news_title_lost_lostteamprogress_doingpoorly_", 4 )
		Engine.SetStringTeams( oldTeam, storyTeam )
		Engine.SetStringPlayers( storyPlayer )
		Engine.AddParagraph( newNews, 2, "news_body_lost_lostteamprogress_doingpoorly_", 4 )
		Engine.SetStoryStage( currentStory, 5 )
		ModifyTeamMorale( oldTeam, Tuning.LOSTPLAYER.teamMoraleModifier )
	end
	Engine.SetNewsImportance( newNews, "MAJOR" )
	Engine.SetNewsTeamById( "LOSTTEAMPROG", oldTeam )
	Engine.SetNewsPlayer( newNews, storyPlayer )
	Engine.SendNews( newNews )
end

function ExamineFor_CPULostPlayer( teamId, numPlayers, player1, player2, player3, player4, player5, player6, player7 )
	if( numPlayers > 0 ) then
		local category = "LOST"
		local baseStoryId = "LOSTPLAYER_CPU_"
		local currentCompObjId = Engine.GetCurrentGameCompObjId()
		local playerArray = { player1, player2, player3, player4, player5, player6, player7 }
		local audio = false
		for playerCount = 1, numPlayers do
			local playerId = playerArray[ playerCount ]
			if( playerId ~= nil ) then
				local newTeamId = Engine.GetTeamIdFromPlayerId( playerId )
				local monthsJoined = Engine.GetNumberOfMonthsSincePlayerJoined( newTeamId, playerId )
				if( monthsJoined < Tuning.LOSTPLAYER.monthsJoinedThreshold ) then
					local storyId = baseStoryId .. playerCount
					if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, 1 ) == true ) then
						local currentStory = Engine.GetStoryById( storyId )
						local teamOverall = Engine.GetTeamOverall( teamId )
						local overall = Engine.GetPlayerOverall( playerId )
						if( ( ( teamOverall * overall ) / 100 ) > 60  ) then
							if( audio == false ) then
								audio = true
								Engine.UpdateStoryActivity( currentStory )
							end
						end
						Engine.KillStoryAfterMatch( currentStory, false )
						if( playerCount >= 2 ) then
							break
						end
					end
				end
			end
		end
	end
end