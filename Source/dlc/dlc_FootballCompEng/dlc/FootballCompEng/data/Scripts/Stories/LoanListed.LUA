function ExamineFor_PlayerLoanListed( teamId, playerId, leagueId )
	local userTeamId = Engine.GetUserTeam()
	if( IsPlayerInvolvedInSaga( playerId ) == false ) then
		local category = "LOAN"
		local storyId = "LOANLIST"
		if( teamId == userTeamId ) then
			storyId = storyId .. "_USR"
		end
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == false ) then		
			StartStory_PlayerLoanListed( teamId, playerId )
		else 
			ExamineFor_PlayerLoanListedReplacement( storyId, playerId )
		end --if( storyActive == false ) then
	end --if( IsPlayerInvolvedInSaga( playerId ) == false ) then
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('ExamineFor_PlayerLoanListed\n')
	v2k4debugfile:close()
end

function StartStory_PlayerLoanListed( teamId, playerId )
	local category = "LOAN"
	local storyId = "LOANLIST"
	local userTeamId = Engine.GetUserTeam()
	if( teamId == userTeamId ) then
		storyId = storyId .. "_USR"
	end
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.LOANLIST.storyCoolDown ) == true ) then
		Engine.AddDateEvent( "LOAN_LISTED", 1, storyId )
		local Ovr = Engine.GetPlayerOverall( playerId )
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 10 )
		Engine.SetStoryVariable( currentStory, Ovr )
	end --if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId ) == true ) then
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('StartStory_PlayerLoanListed\n')
	v2k4debugfile:close()
end

function ExamineFor_PlayerLoanListedReplacement( storyId, playerId )
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
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('ExamineFor_PlayerLoanListedReplacement\n')
	v2k4debugfile:close()
end

function LoanListedDynamicEvent( eventId, storyId )
	if( eventId == "LOAN_LISTED" ) then
		local currentStory = Engine.GetStoryById( storyId )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		local loanListed = Engine.IsPlayerOnLoanList( storyPlayer )
		local happiness = IsPlayerHappyOrUnhappyWithLoan( storyTeam, storyPlayer )
		if( loanListed == true ) then				
			local playerAge = Engine.GetPlayerAge( storyTeam, storyPlayer )
			local playerOverall = Engine.GetPlayerOverall( storyPlayer )
			local playerPotential = Engine.GetPlayerPotential( storyTeam, storyPlayer )
			local playerQuality = ( playerPotential + playerOverall ) / 2
			local numPlayersForAvg = Tuning.LOANLIST.numPlayersToAvg
			local teamAvg = DetermineAvgRatingForTeam( storyTeam, numPlayersForAvg )
			Engine.SetStringPlayer( storyPlayer )
			Engine.SetStringTeam( storyTeam )
			local isAboveAvg = ( playerQuality > teamAvg )
			if( playerAge < 20 ) then 
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
				Engine.SetNewsBackgroundImage( "EXIT_DOOR" )
				if( isAboveAvg ) then
					TriggerNews( "news_title_loanlisted_under20_above_avg_", 1, 4, "news_body_loanlisted_under20_above_avg_", 1, 4, currentStory )							
					if( happiness == "UNHAPPY" ) then
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.und20_AbvAvg_Unhappy_Morale )
					else
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.und20_AbvAvg_Happy_Morale )
					end
				else
					TriggerNews( "news_title_loanlisted_under20_below_avg_", 1, 4, "news_body_loanlisted_under20_below_avg_", 1, 4, currentStory )
					if( happiness == "UNHAPPY" ) then
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.und20_BlwAvg_Unhappy_Morale )
					else
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.und20_BlwAvg_Happy_Morale )
					end
				end
			elseif( playerAge > 19 and playerAge < 30 ) then
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
				Engine.SetNewsBackgroundImage( "EXIT_DOOR" )
				if( isAboveAvg ) then
					TriggerNews( "news_title_loanlisted_above20_above_avg_", 1, 4, "news_body_loanlisted_above20_above_avg_", 1, 4, currentStory )							
					if( happiness == "UNHAPPY" ) then
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr20_AbvAvg_Unhappy_Morale )
					else
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr20_AbvAvg_Happy_Morale )
					end
				else
					TriggerNews( "news_title_loanlisted_above20_below_avg_", 1, 4, "news_body_loanlisted_above20_below_avg_", 1, 4, currentStory )
					if( happiness == "UNHAPPY" ) then
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr20_BlwAvg_Unhappy_Morale )
					else
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr20_BlwAvg_Happy_Morale )
					end
				end
			elseif( playerAge > 29 ) then
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
				Engine.SetNewsBackgroundImage( "EXIT_DOOR" )
				if( isAboveAvg ) then
					TriggerNews( "news_title_loanlisted_above30_above_avg_", 1, 4, "news_body_loanlisted_above30_above_avg_", 1, 4, currentStory )
					if( happiness == "UNHAPPY" ) then
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr30_AbvAvg_Unhappy_Morale )
					else
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr30_AbvAvg_Happy_Morale )
					end
				else
					TriggerNews( "news_title_loanlisted_above30_below_avg_", 1, 4, "news_body_loanlisted_above30_below_avg_", 1, 4, currentStory )
					if( happiness == "UNHAPPY" ) then
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr30_BlwAvg_Unhappy_Morale )
					else
						Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.LOANLIST.ovr30_BlwAvg_Happy_Morale )
					end
				end
			end
			Engine.KillStoryAfterMatch( currentStory )
		end ----if( loanListed == true ) then	
		if( storyId == "LOANLIST" ) then
			Engine.EndStoryId( storyId, false )
		end
	end --for storyCount = numStories, 1,  -1 do -- go backwards in loop
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('LoanListedDynamicEvent\n')
	v2k4debugfile:close()
end

function IsPlayerHappyOrUnhappyWithLoan( teamId, playerId )
	local mood = "HAPPY"
	local happiness = Engine.GetPlayTimeMorale( teamId, playerId )
	if( happiness == "LOW" or happiness == "VERY_LOW" ) then
		mood = "UNHAPPY"
	end
	
	local v2k4debugfile = io.open("v2k4debugfile-career.txt", "w")
	v2k4debugfile:write('IsPlayerHappyOrUnhappyWithLoan\n')
	v2k4debugfile:close()
	return mood
end
