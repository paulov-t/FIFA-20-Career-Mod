
function ExamineResultForIncident( matchResult, gametype, playType )
	if( gametype ~= "FRIENDLY" ) then
		local hadWinningGoal, winnerIncident = Engine.HadWinningGoal( matchResult )
		local storyAdded = false
		if( hadWinningGoal == true ) then
			storyAdded = ExamineWinningGoal( matchResult, winnerIncident )
		end --if( hadWinningGoal == true ) then

		if( storyAdded == false ) then
			local dodgyGoalId = LookForDodgyGoal( matchResult )
			local dodgyGoalCount = 0
			local redCardCount = 0
			local yellowCardCount = 0
			local redIncidents = {}
			-- Incidents
			local numIncidents = Engine.GetNumberOfIncidents( matchResult )
			for incidentCount = 1, numIncidents do
				if( storyAdded == true ) then
					break
				end
				local type = Engine.GetIncidentTypeByIndex( matchResult, incidentCount )
				local incident = Engine.GetMatchIncidentByIndex( matchResult, incidentCount )
				if( type == "CARD" ) then
					local cardType = Engine.GetCardType( incident )
					if( cardType == "RED" ) then
						redCardCount = redCardCount + 1
						redIncidents[ redCardCount ] = incident
						if( playType == "SIMMED" ) then
							storyAdded = ContentiousRedCard( matchResult, incident )					
						end --if( playType == "SIMMED" ) then
					elseif( cardType == "SECOND_YELLOW" ) then
						redCardCount = redCardCount + 1		
						redIncidents[ redCardCount ] = incident
					end --if( cardType == "RED" ) then
				elseif( type == "GOAL" ) then
					if( playType == "SIMMED" ) then
						dodgyGoalCount = dodgyGoalCount + 1
						if( dodgyGoalId == dodgyGoalCount ) then
							storyAdded = ReportDodgyGoal( matchResult, incident )
						end --if( dodgyGoalId == dodgyGoalCount ) then
					end --if( playType == "SIMMED" ) then
				end --elseif( type == "GOAL" ) then
			end --for incidentCount = 1, numIncidents do
			
			if( storyAdded == false ) then
				storyAdded = DirtyGameStory( redCardCount, redIncidents, matchResult )
			end --if( storyAdded == false ) then
			
		end --if( storyAdded == false ) then
	end --if( gametype ~= "FRIENDLY" ) then
end

function DirtyGameStory( redCardCount, redIncidents, matchResult )
	local storyAdded = false
	if( redCardCount >= Tuning.MATCHINCIDENT.redCardCount ) then
		local category = "MATCHINCIDENT"
		local storyId = "DIRTYGAME"		
		local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, redIncidents[ 1 ] )
		local teamId2, playerId2, incidentTime2 = Engine.GetIncidentTeamPlayerAndTime( matchResult, redIncidents[ 2 ] )
		local userTeam = Engine.GetUserTeam()
		if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.MATCHINCIDENT.dirtyGameStoryCoolDown ) == true and teamId2 == userTeam) then
			if( teamId2 == userTeam ) then
				Engine.SetNewsType( "CLUB" )
			end
			local currentStory = Engine.GetStoryByIdAndIndex( storyId, 1 )
			local homeTeamId, awayTeamId = Engine.GetMatchResultTeamIds( matchResult )
			local winningTeamId, losingTeamId = Engine.GetWinningLosingTeam( matchResult )
			Engine.SetStringTeam( homeTeamId, 1 )
			Engine.SetStringTeam( awayTeamId, 2 )
			Engine.SetStringPlayer( playerId, 1 )
			Engine.SetStringPlayer( playerId2, 2 )
			Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", homeTeamId )
			Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", awayTeamId )
			Engine.SetNewsBackgroundImage( "FOOTBALL_PITCH" )
			if( winningTeamId ~= -1 and losingTeamId ~= -1 ) then
				Engine.SetStringTeam( winningTeamId, 3 )
				Engine.SetStringTeam( losingTeamId, 4 )
				local homeScore, awayScore = Engine.GetFinalScore( matchResult )
				TriggerNews( "news_dirtygame_title_", 1, 10, "news_dirtygame_win_ body_", 1, 5, currentStory, homeScore, awayScore )
			else
				TriggerNews( "news_dirtygame_title_", 1, 10, "news_dirtygame_draw_body_", 1, 5, currentStory )
			end
			
			storyAdded = true
			Engine.EndStory( teamId, playerId, storyId )
		end --if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId ) == true ) then
	end --if( redCardCount >= 2 ) then
	return storyAdded
end

function LookForDodgyGoal( matchResult )
	local homeScore, awayScore = Engine.GetNormalTimeScore( matchResult )
	local totalGoals = homeScore + awayScore
	local dodgyGoalId = 0
	if( totalGoals > 0 ) then
		dodgyGoalId = Engine.GetRandomNumber( 1, totalGoals )			
	end --if( totalGoals > 0 ) then
	return dodgyGoalId
end

function ReportDodgyGoal( matchResult, incident )
	local category = "MATCHINCIDENT"
	local storyId = "DODGYGOAL"
	local storyAdded = false
	local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, incident )
	local compAssetId = Engine.GetCompetitionAssetIdFromResult( matchResult )
	local otherTeamId, focusTeamId = GetFocusTeamAndOther( matchResult, teamId )
	local userTeam = Engine.GetUserTeam()
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.MATCHINCIDENT.storyCoolDown ) == true and otherTeam == userTeam ) then
		local locMeStr = ""
		locMeStr = FillNewsAppendString( matchResult, otherTeamId )
		Engine.SetStringTeam( focusTeamId, 1 )
		Engine.SetStringTeam( otherTeamId, 2 )	
		Engine.SetStringPlayer( playerId, 1 )		
		local handballGoal = Tuning.MATCHINCIDENT.chanceOfHandballGoal
		local foulGoal = Tuning.MATCHINCIDENT.chanceOfFoulGoal
		local offsideGoal = Tuning.MATCHINCIDENT.chanceOfOffsideGoal
--		local technology = Tuning.MATCHINCIDENT.chanceOfTechnology
		local total = offsideGoal + handballGoal + foulGoal -- + technology
		local dodgyGoalType = Engine.GetRandomNumber( 1, total )
		local currentStory = Engine.GetStoryByIdAndIndex( storyId, 1 )
		if( otherTeamId == userTeam ) then
			Engine.SetNewsType( "CLUB" )
		end
		Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", otherTeamId )
		Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", focusTeamId )
		Engine.SetNewsBackgroundImage( "LINESMAN" )
		Engine.SetNewsCompetitionAssetId( compAssetId )
		if( dodgyGoalType <= foulGoal ) then			-- FOUL == bad luck
			TriggerNews( "news_dodgygoal_foul_title_", 1, 10, "news_dodgygoal_foul_body_", 1, 10, currentStory, locMeStr )
			Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" )
		elseif( dodgyGoalType <= foulGoal + handballGoal ) then		-- HANDBALL == bad defending
			TriggerNews( "news_dodgygoal_handball_title_", 1, 10, "news_dodgygoal_handball_body_", 1, 10, currentStory, locMeStr )
			Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" )
--		elseif( dodgyGoalType <= foulGoal + handballGoal + technology ) then
--			TriggerNews( "news_dodgygoal_technology_title_", 1, 5, "news_dodgygoal_technology_body_", 1, 5, currentStory, locMeStr )
		else
			TriggerNews( "news_dodgygoal_offside_title_", 1, 10, "news_dodgygoal_offside_body_", 1, 10, currentStory, locMeStr )
		end
		Engine.EndStory( teamId, playerId, storyId )
		storyAdded = true
	end --if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId ) == true ) then		
	return storyAdded
end

function ContentiousRedCard( matchResult, incident )
	local category = "MATCHINCIDENT"
	local storyId = "REDCARD"
	local storyAdded = false
	local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, incident )
	local focusTeamId, otherTeamId = GetFocusTeamAndOther( matchResult, teamId )
	local userTeam = Engine.GetUserTeam()
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.MATCHINCIDENT.storyCoolDown ) == true and otherTeam == userTeam ) then		
		local homeTeamId, awayTeamId = Engine.GetMatchResultTeamIds( matchResult )
		local currentStory = Engine.GetStoryByIdAndIndex( storyId, 1 )
		if( otherTeamId == userTeam ) then
			Engine.SetNewsType( "CLUB" )
		end
		Engine.SetStringTeam( focusTeamId, 1 )
		Engine.SetStringTeam( otherTeamId, 2 )
		Engine.SetStringPlayer( playerId, 1 )
	
		local locMeStr = FillNewsAppendString( matchResult, focusTeamId )	
		Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
		Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", focusTeamId )
		Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE" )		
		TriggerNews( "news_contentiousredcard_title_", 1, 10, "news_contentiousredcard_body_", 1, 10, currentStory, locMeStr )
		Engine.EndStory( focusTeamId, playerId, storyId )
		storyAdded = true
	end
	return storyAdded
end

function FillNewsAppendString( matchResult, focusTeamId )
	local locMeStr = ""
	local locString = "news_append_"
	local matchWinner = Engine.GetMatchWinner( matchResult )
	if( matchWinner == -1 ) then
		local randNo = Engine.GetRandomNumber( 1, 2 )
		locMeStr = "locme_" .. locString .. "draw_" .. randNo
	elseif( matchWinner == focusTeamId ) then
		local randNo = Engine.GetRandomNumber( 1, 2 )
		locMeStr = "locme_" .. locString .. "win_" .. randNo
	else
		local randNo = Engine.GetRandomNumber( 1, 2 )
		locMeStr = "locme_" .. locString .. "loss_" .. randNo
	end		
	return locMeStr
end

function GetFocusTeamAndOther( matchResult, focusTeam )
	local homeTeamId, awayTeamId = Engine.GetMatchResultTeamIds( matchResult ) 
	local team1 = 0
	local team2 = 0
	if( homeTeamId == focusTeam ) then
		team1 = homeTeamId
		team2 = awayTeamId
	else
		team2 = homeTeamId
		team1 = awayTeamId
	end
	return team1, team2
end

function ExamineWinningGoal( matchResult, winnerIncident )
	local storyAdded = false
	local category = "MATCHINCIDENT"
	local storyId = "LASTMINUTES"
	local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, winnerIncident )
	local compAssetId = Engine.GetCompetitionAssetIdFromResult( matchResult )
	if( incidentTime > Tuning.MATCHINCIDENT.winningGoalTime_Low and incidentTime <= 90 ) then
		local focusTeam, otherTeam = GetFocusTeamAndOther( matchResult, teamId )
		local userTeam = Engine.GetUserTeam()
		if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.MATCHINCIDENT.storyCoolDown ) == true and otherTeam == userTeam ) then		
			local currentStory = Engine.GetStoryByIdAndIndex( storyId, 1 )
			local randNo = Engine.GetRandomNumber( 1, 2 )
			local locMeStr = "locme_" .. "news_append_win_" .. randNo
			if( otherTeam == userTeam ) then
				Engine.SetNewsType( "CLUB" )
			end
			Engine.SetStringTeam( focusTeam, 1 )
			Engine.SetStringTeam( otherTeam, 2 )
			Engine.SetStringPlayer( playerId, 1 )
			Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", focusTeam )
			Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", otherTeam )
			Engine.SetNewsBackgroundImage( "FULL_STADIUM" )
			--if( focusTeam == userTeam ) then
			--	Engine.SetNewsCinematic ( "CM_News_PlayerActionPositive" ) 
			--end
			Engine.SetNewsCompetitionAssetId( compAssetId )
			TriggerNews( "news_lastminuteswinner_title_", 1, 10, "news_lastminuteswinner_body_", 1, 10, currentStory, locMeStr, incidentTime )	
			Engine.EndStory( focusTeam, playerId, storyId )
			storyAdded = true
		end --if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId ) == true ) then		
	end --if( incidentTime > 85 and incidentTime <= 90 ) then		
	return storyAdded
end
