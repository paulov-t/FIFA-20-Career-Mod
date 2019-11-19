function ExamineFor_PlayerListed( teamId, playerId, leagueId, marketValue, currency )
	local userTeamId = Engine.GetUserTeam()
	if( IsPlayerInvolvedInSaga( playerId ) == false ) then
		local category = "TRANSFER"
		local storyId = "LISTED"
		if( teamId == userTeamId ) then
			storyId = storyId .. "_USR"
		end
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == false ) then		
			StartStory_PlayerListed( teamId, playerId )
		else
			ExamineFor_PlayerListedReplacement( storyId, playerId )		
		end --if( storyActive == false ) then
	end --if( IsPlayerInvolvedInSaga( playerId ) == false ) then
end

function StartStory_PlayerListed( teamId, playerId )
	local category = "TRANSFER"
	local storyId = "LISTED"
	local userTeamId = Engine.GetUserTeam()
	if( teamId == userTeamId ) then
		storyId = storyId .. "_USR"
	end
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.LISTED.storyCoolDown ) == true ) then
		Engine.AddDateEvent( "TRAN_LISTED", 1, storyId )
		local Ovr = Engine.GetPlayerOverall( playerId )
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryVariable( currentStory, Ovr )
		Engine.SetStoryPriority( currentStory, Tuning.LISTED.storyPriority )
	end --if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId ) == true ) then
end

function ExamineFor_PlayerListedReplacement( storyId, playerId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local dateAdded = Engine.GetStoryStartDate( currentStory )
	local currentDate = Engine.GetCurrentDate()
	if( Engine.GetNumDaysBetween( dateAdded, currentDate ) == 0 ) then
		if( teamId == storyTeam ) then
			local oldPlayerOverall = Engine.GetPlayerOverall( storyPlayer )
			local newPlayerOverall = Engine.GetPlayerOverall( playerId )
			if( newPlayerOverall > oldPlayerOverall ) then
				Engine.ReplaceStoryPlayer( currentStory, storyTeam, playerId )
				local Ovr = Engine.GetPlayerOverall( playerId )
				Engine.SetStoryVariable( currentStory, Ovr )
			end --if( newPlayerOverall > oldPlayerOverall ) then
		end --if( teamId == storyTeam ) then
	end --if( Engine.GetNumDaysBetween( dateAdded, currentDate ) == 0 ) then
end

function TransferListedDynamicEvent( eventId, storyId )
	if( eventId == "TRAN_LISTED" ) then
		local category = "TRANSFER"
		local currentStory = Engine.GetStoryById( storyId )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		local isListed = Engine.IsPlayerOnTransferList( storyPlayer )
		if( isListed == true ) then
			local playerAge = Engine.GetPlayerAge( storyTeam, storyPlayer )
			local playerOverall = Engine.GetPlayerOverall( storyPlayer )
			local playerPotential = Engine.GetPlayerPotential( storyTeam, storyPlayer )
			local playerQuality = ( playerPotential + playerOverall ) / 2
			local numPlayersForAvg = Tuning.LISTED.numPlayersToAvg
			local teamAvg = DetermineAvgRatingForTeam( storyTeam, numPlayersForAvg )
			Engine.SetStringPlayer( storyPlayer )
			Engine.SetStringTeam( storyTeam )
			local isAboveAvg = ( playerQuality > teamAvg )
			if( playerAge <= Tuning.LISTED.maxYoungPlayerAge ) then 
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
				Engine.SetNewsBackgroundImage( "FOR_SALE" )
				if( isAboveAvg ) then
					TriggerTransferNews( "news_title_transferlisted_under20_above_avg_", 1, 4, "news_body_transferlisted_under20_above_avg_", 1, 4, currentStory )
					Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LISTED.und20_AbvAvg_Morale )
				else
					TriggerTransferNews( "news_title_transferlisted_under20_below_avg_", 1, 4, "news_body_transferlisted_under20_below_avg_", 1, 4, currentStory )
					Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LISTED.und20_BlwAvg_Morale )		
				end
			elseif( playerAge > Tuning.LISTED.maxYoungPlayerAge and playerAge < Tuning.LISTED.minOldPlayerAge ) then
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
				Engine.SetNewsBackgroundImage( "FOR_SALE" )
				if( isAboveAvg ) then
					TriggerTransferNews( "news_title_transferlisted_above20_above_avg_", 1, 4, "news_body_transferlisted_above20_above_avg_", 1, 4, currentStory )
					Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LISTED.ovr20_AbvAvg_Morale )
				else
					TriggerTransferNews( "news_title_transferlisted_above20_below_avg_", 1, 4, "news_body_transferlisted_above20_below_avg_", 1, 4, currentStory )
					Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LISTED.ovr20_BlwAvg_Morale )
				end
			elseif( playerAge >= Tuning.LISTED.minOldPlayerAge ) then
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
				Engine.SetNewsBackgroundImage( "FOR_SALE" )
				if( isAboveAvg ) then
					TriggerTransferNews( "news_title_transferlisted_above30_above_avg_", 1, 4, "news_body_transferlisted_above30_above_avg_", 1, 4, currentStory )
					Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LISTED.ovr30_AbvAvg_Morale )
				else
					TriggerTransferNews( "news_title_transferlisted_above30_below_avg_", 1, 4, "news_body_transferlisted_above30_below_avg_", 1, 4, currentStory )
					Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LISTED.ovr30_BlwAvg_Morale )
				end --if( isAboveAvg ) then
			end --if( playerAge < 20 ) then
			Engine.KillStoryAfterMatch( currentStory )
			local morale = Engine.GetPlayerMoraleLevel( storyTeam, storyPlayer )
			if( morale == "VERY_GOOD" ) then
				Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_PlayerListedHappy_", 1, 4, "PlayerFeedbackPopUp_PlayerListed_subject", currentStory  )
			elseif( morale == "VERY_BAD" ) then
				Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_PlayerListedUnhappy_", 1, 4, "PlayerFeedbackPopUp_PlayerListed_subject", currentStory  )
			end
		end --if( isListed ) then
		if( storyId == "LISTED" ) then
			Engine.EndStoryId( storyId, false ) 
		end
	end--if( eventId == "TRANSFER_LISTED" ) then
end
