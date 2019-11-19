--#############################################################################
--Entry point of CNotes logic, flow of data
function ProcessCommentatorNotes(timesliceStr)
	Print ("############# COMMENTATOR NOTES LEAGUE PREMATCH LOGIC!!! slice was " .. timesliceStr)
	
	--Set C++ side of data, which can be ignored if you are OVERRIDING with FLAP
	SetCommonDataBlock()
	
	--Process messages to send based on season time slice
	ProcessTimeSlice(timesliceStr)
	
	--process messages for common events like FORM
	ProcessCommonData(timesliceStr)
	
	--process user teams players for events
	PlayerMatchChecks()
	
	ProcessCommentatorNotes_POST(timesliceStr)
	
	--TRIGGER SEND OF DATA TO AUDIO!
	SendCommentatorNotes()

end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--#############################################################################
--#############################################################################

--#############################################################################
function ProcessTimeSlice(timesliceStr)

	--Available Time Slices
	--#####################################
	--CAREER_TIMELINE_SLICE_PRESEASON_GAME1
	--CAREER_TIMELINE_SLICE_PRESEASON_GAME2
	--CAREER_TIMELINE_SLICE_PRESEASON_GAME3PLUS
	--CAREER_TIMELINE_SLICE_GAME1
	--CAREER_TIMELINE_SLICE_GAME2
	--CAREER_TIMELINE_SLICE_GAME3
	--CAREER_TIMELINE_SLICE_SEASON_EARLY
	--CAREER_TIMELINE_SLICE_SEASON_Q2
	--CAREER_TIMELINE_SLICE_SEASON_Q3
	--CAREER_TIMELINE_SLICE_SEASON_LATE
	--CAREER_TIMELINE_SLICE_GAME_END4
	--CAREER_TIMELINE_SLICE_GAME_END3
	--CAREER_TIMELINE_SLICE_GAME_END_PENUL
	--CAREER_TIMELINE_SLICE_GAME_FINAL
	
	--CAREER_TIMELINE_SLICE_DOMESTIC_CUP_FINAL
	--CAREER_TIMELINE_SLICE_DOMESTIC_CUP_SEMIFINAL
	--CAREER_TIMELINE_SLICE_DOMESTIC_CUP_QUARTERFINAL
	--CAREER_TIMELINE_SLICE_DOMESTIC_CUP_ROUND
	--CAREER_TIMELINE_SLICE_DOMESTIC_CUP_QUALIFYING
	--CAREER_TIMELINE_SLICE_DOMESTIC_CUP_GROUP
	--CAREER_TIMELINE_SLICE_PROMOTION_PLAYOFF
	--CAREER_TIMELINE_SLICE_RELEGATION_PLAYOFF
	--CAREER_TIMELINE_SLICE_MLS_FINAL
	--CAREER_TIMELINE_SLICE_MLS_SEMIFINAL
	--CAREER_TIMELINE_SLICE_MLS_QUARTERFINAL
	--CAREER_TIMELINE_SLICE_MLS_PLAYOFF
	--CAREER_TIMELINE_SLICE_LEAGUE_FINAL
	--CAREER_TIMELINE_SLICE_LEAGUE_SEMIFINAL
	--CAREER_TIMELINE_SLICE_LEAGUE_QUARTERFINAL
	--CAREER_TIMELINE_SLICE_LEAGUE_PLAYOFF
	--CAREER_TIMELINE_SLICE_CONTINENTAL_CUP_FINAL
	--CAREER_TIMELINE_SLICE_CONTINENTAL_CUP_ROUND
	--CAREER_TIMELINE_SLICE_SUPERCUP
	--CAREER_TIMELINE_SLICE_INTERNATIONAL
	--#####################################
	
	if(timesliceStr == "CAREER_TIMELINE_SLICE_PRESEASON_GAME1") then
		PreSeasonGame1Checks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_PRESEASON_GAME2") then
		PreSeasonGame2Checks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_PRESEASON_GAME3PLUS") then
		PreSeasonGame3AndOnChecks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_GAME1") then
		Game1Checks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_GAME2") then
		Game2Checks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_GAME3") then
		Game3Checks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_EARLY") then
		SeasonEarlyChecks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_Q2") then
		SeasonQ2Checks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_Q3") then
		SeasonQ3Checks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_LATE") then
		SeasonLateChecks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_GAME_END4") then
		Game4thLastChecks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_GAME_END3") then
		Game3rdLastChecks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_GAME_END_PENUL") then
		GamePenulGameChecks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_GAME_FINAL") then
		GameFinalGameChecks()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_FINAL") then
		DomesticCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_SEMIFINAL") then
		DomesticCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_QUARTERFINAL") then
		DomesticCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_ROUND") then
		DomesticCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_QUALIFYING") then
		DomesticCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_GROUP") then
		DomesticCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_PROMOTION_PLAYOFF") then
		PromotionPlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_RELEGATION_PLAYOFF") then
		RelegationPlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_MLS_FINAL") then
		MLSPlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_MLS_SEMIFINAL") then
		MLSPlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_MLS_QUARTERFINAL") then
		MLSPlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_MLS_PLAYOFF") then
		MLSPlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_LEAGUE_FINAL") then
		LeaguePlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_LEAGUE_SEMIFINAL") then
		LeaguePlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_LEAGUE_QUARTERFINAL") then
		LeaguePlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_LEAGUE_PLAYOFF") then
		LeaguePlayoffChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_CONTINENTAL_CUP_FINAL") then
		ContinentalCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_CONTINENTAL_CUP_ROUND") then
		ContinentalCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_SUPERCUP") then
		SuperCupChecks()
		SendMatchImportance()
	elseif(timesliceStr == "CAREER_TIMELINE_SLICE_INTERNATIONAL") then
		InternationalChecks()
		SendMatchImportance()
	else
		Print("ERROR!!! ProcessCommentatorNotes timeslice UNHANDLED")
	end
end

--#############################################################################
function ProcessCommonData(timesliceStr)
	local teamId = GetCNotesCDB_UserTeamId()
	local side = GetCNotesCDB_UserSide()
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local opponentTeamSide = 0
	if(side == 0) then 
		opponentTeamSide = 1 
	end
	
	local formScoreShort, formScoreLong, lastXForm = GetCNotesCDB_UserForms()
	local expectation = GetCNotesCDB_UserExpectation()
	local currentLeagueGrouping = GetCNotesCDB_UserActualGrouping()
	local actualVsExpectations = GetCNotesCDB_ActualVsExpectation()
	local opponentExpectation = GetCNotesCDB_OpponentExpectation()
	
	--RIVALS
	if(AreTeamsRivals(teamId, opponentTeamId)==true) then
		AddCommentatorNotesAudioEvent("RIVALS", "TRIGGER_PREMATCH")
	end
	
	--DERBY
	if(AreTeamsDerby(teamId, opponentTeamId)==true) then
		AddCommentatorNotesAudioEvent("DERBY_GAME", "TRIGGER_PREMATCH")
	end
	
	local isPlayoffLeague = IsTeamIdPlayoffLeague(teamId)
	
	--MORE CHECKS HERE
	if( not IsCupGame(timesliceStr) ) then
		if(timesliceStr == "CAREER_TIMELINE_SLICE_GAME1" or timesliceStr == "CAREER_TIMELINE_SLICE_GAME2") then
			AddCommentatorNotesAudioEvent("TEAM_EXPECTATION", "TRIGGER_PREMATCH_STITCH", formScoreLong, expectation, teamId, side )
			AddCommentatorNotesAudioEvent("TEAM_EXPECTATION", "TRIGGER_PREMATCH_STITCH", -1, opponentExpectation, opponentTeamId, opponentTeamSide )
		else
			AddCommentatorNotesAudioEvent("TEAM_EXPECTATION", "TRIGGER_PREMATCH", formScoreLong, expectation, teamId, side )
		end
	end
	
	if( not IsPreseason(timesliceStr) ) then
		if( not IsCupGame(timesliceStr) ) then
			if( not IsInPlayOff() ) then
				AddCommentatorNotesAudioEvent("TEAM_ACTUAL_LEAGUE_GROUPING", "TRIGGER_PREMATCH", currentLeagueGrouping, side)
			end
			if( not (timesliceStr == "CAREER_TIMELINE_SLICE_GAME1") ) then
				AddCommentatorNotesAudioEvent("TEAM_ACTUAL_VS_EXPECTATION", "TRIGGER_PREMATCH", actualVsExpectations, teamId, side)
				if( IsLastHalfOfSeason(timesliceStr) ) then
					local predictedGapResult = GetTeamLeague_PredictedVsExpectations(teamId)
					if(predictedGapResult>=0) then
						AddCommentatorNotesAudioEvent("TEAM_PREDICTION_VS_EXPECTATION", "TRIGGER_PREMATCH", predictedGapResult, teamId, side)
					end
				end
			end
		end
	end
	
	if( lastXForm >= 0) then
		--old had formScoreShort, formScoreLong, side, lastXForm
		AddCommentatorNotesAudioEvent("TEAM_FORM", "TRIGGER_PREMATCH", lastXForm, formScoreShort, formScoreLong)
	end
end

--#############################################################################
function LastXGamesShortFormCheck(lastXGames, checkOnlyLeague)
	local numGamesToCheckHistory = lastXGames
	local possiblePoints = numGamesToCheckHistory * 3
	local wins,losses,draws = GetRecordForLastXGames(numGamesToCheckHistory, checkOnlyLeague)
	local points = wins*3 + draws
	local formScoreShort = math.floor (((points/possiblePoints)*100))
	local lastXForm = 3
	if(formScoreShort > 0) then
		lastXForm = 1
	end
	
	-- HACK 
	-- DUE TO THE COMM NOTES DOC USING THE WRONG VALUE AND AUDIO IS ALREADY HOOKED TO IT, the doc uses 15 when the value is 16.67 and a floor gives us value of 16 so no audio is triggered
	if(formScoreShort <= 17 and formScoreShort >= 15) then
		formScoreShort = 15
	end
	
	AddCommentatorNotesAudioEvent("TEAM_FORM", "TRIGGER_PREMATCH", lastXForm, formScoreShort, formScoreShort)
end

--#############################################################################
function PreSeasonGame1Checks()
end

--#############################################################################
function PreSeasonGame2Checks()
	--PREMATCH FORM
	LastXGamesShortFormCheck(1, false)
end

--#############################################################################
function PreSeasonGame3AndOnChecks()
	--PREMATCH FORM
	LastXGamesShortFormCheck(2, false)
	
	--SUPERCUP
	local upcomingGameFixture = GetUpcomingGameFixtureData()
	if(IsGameSuperCup(upcomingGameFixture)) then
		AddCommentatorNotesAudioEvent("SUPERCUP_NEXT_GAME", "TRIGGER_PREMATCH")
	end
end

--#############################################################################
function Game1Checks()
	local teamId = GetCNotesCDB_UserTeamId()
	local currentGameFixture = GetCurrentGameFixtureData()
	local side = GetCNotesCDB_UserSide()
	local lastSeasonsResults = GetTeamLastSeasonResults(teamId)
	local lastSeasonWasChamp = GetTeamLastSeasonChampions(teamId)
	--LAST SEASON RESULTS GOES LIKE THIS -2==CHAMPION    -1==RELEGATED  0==PROMOTED  1-MAX_TEAMS is position
	
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local opponentTeamSide = 0
	if(side == 0) then 
		opponentTeamSide = 1 
	end
	local opponentLastSeasonsResults = GetTeamLastSeasonResults(opponentTeamId)
	local opponentLastSeasonWasChamp = GetTeamLastSeasonChampions(opponentTeamId)
	
	--LAST SEASON RESULTS FOR USER AN OPPONENT
	CheckLastSeasonResults(lastSeasonsResults, lastSeasonWasChamp, side, teamId)
	CheckLastSeasonResults(opponentLastSeasonsResults, opponentLastSeasonWasChamp, opponentTeamSide, opponentTeamId)
	
	--LAST SEASON RESULTS CLASH CHECK
	if( (lastSeasonsResults <= 0 and lastSeasonsResults >=-1) and lastSeasonsResults == opponentLastSeasonsResults) then --if promoted last year or relegated last year clash
		local clashFlag = 0 --PROMOTED
		if(lastSeasonsResults ~= 0) then
			clashFlag = 1 -- RELEGATED_FLAG FOR AUDIO ONLY
		end
		AddCommentatorNotesAudioEvent("TEAM_LAST_SEASON_RESULTS_CLASH", "TRIGGER_PREMATCH", clashFlag )
	end
	
	--EXPECTATION CLASH CHECK
	local teamExpectation = GetCNotesCDB_UserExpectation()
	local opponentTeamExpectation = GetCNotesCDB_OpponentExpectation()
	if(teamExpectation == opponentTeamExpectation) then
		AddCommentatorNotesAudioEvent("TEAM_EXPECTATION_CLASH", "TRIGGER_PREMATCH", teamId )
	end
	
	--IS IN TRANSFER WINDOW
	local dateInt = GetDateFromFixture(currentGameFixture)
	if( IsWithinTransferWindow(dateInt) ) then
		AddCommentatorNotesAudioEvent("CAN_STILL_ADD_TO_SQUAD", "TRIGGER_PREMATCH")
	end
end

--#############################################################################
function Game2Checks()
	local teamId = GetCNotesCDB_UserTeamId()
	local currentGameFixture = GetCurrentGameFixtureData()
	local side = GetCNotesCDB_UserSide()
	local lastSeasonsResults = GetTeamLastSeasonResults(teamId)
	local lastSeasonWasChamp = GetTeamLastSeasonChampions(teamId)
	--LAST SEASON RESULTS GOES LIKE THIS -2==CHAMPION    -1==RELEGATED  0==PROMOTED  1-MAX_TEAMS is position
	
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local opponentTeamSide = 0
	if(side == 0) then 
		opponentTeamSide = 1 
	end
	
	LastXGamesShortFormCheck(1, true)
	
	local opponentLastSeasonsResults = GetTeamLastSeasonResults(opponentTeamId)
	local opponentLastSeasonWasChamp = GetTeamLastSeasonChampions(opponentTeamId)
	
	CheckLastLeagueGameResults()
	
	--LAST SEASON RESULTS FOR USER AN OPPONENT
	CheckLastSeasonResults(lastSeasonsResults, lastSeasonWasChamp, side, teamId)
	CheckLastSeasonResults(opponentLastSeasonsResults, opponentLastSeasonWasChamp, opponentTeamSide, opponentTeamId)
	
	--LAST SEASON RESULTS CLASH CHECK
	if( (lastSeasonsResults <= 0 and lastSeasonsResults >=-1) and lastSeasonsResults == opponentLastSeasonsResults) then --if promoted last year or relegated last year clash
		local clashFlag = 0 --PROMOTED
		if(lastSeasonsResults ~= 0) then
			clashFlag = 1 -- RELEGATED_FLAG FOR AUDIO ONLY
		end
		AddCommentatorNotesAudioEvent("TEAM_LAST_SEASON_RESULTS_CLASH", "TRIGGER_PREMATCH", clashFlag )
	end
	
	--EXPECTATION CLASH CHECK
	local teamExpectation = GetCNotesCDB_UserExpectation()
	local opponentTeamExpectation = GetCNotesCDB_OpponentExpectation()
	if(teamExpectation == opponentTeamExpectation) then
		AddCommentatorNotesAudioEvent("TEAM_EXPECTATION_CLASH", "TRIGGER_PREMATCH", teamId )
	end
	
	--IS IN TRANSFER WINDOW
	local dateInt = GetDateFromFixture(currentGameFixture)
	if( IsWithinTransferWindow(dateInt) ) then
		AddCommentatorNotesAudioEvent("CAN_STILL_ADD_TO_SQUAD", "TRIGGER_PREMATCH")
	end
	
end

--#############################################################################
function Game3Checks()	
	local teamId = GetCNotesCDB_UserTeamId()
	local currentGameFixture = GetCurrentGameFixtureData()
	local side = GetCNotesCDB_UserSide()
	
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local opponentTeamSide = 0
	if(side == 0) then 
		opponentTeamSide = 1 
	end
	local opponentLastSeasonsResults = GetTeamLastSeasonResults(opponentTeamId)
	
	CheckLastLeagueGameResults()
	
	LastXGamesShortFormCheck(2, true)
	
	local numTeams = GetNumberOfTeamsInLeague()
	local teamPosition = GetLeaguePosition(teamId)
	if(teamPosition==1) then
		AddCommentatorNotesAudioEvent("SEASON_LEADER", "TRIGGER_PREMATCH")
	end
	
	if(teamPosition==numTeams) then
		AddCommentatorNotesAudioEvent("SEASON_BOTTOM_PLACE", "TRIGGER_PREMATCH")
	end
	
	--IS IN TRANSFER WINDOW
	local dateInt = GetDateFromFixture(currentGameFixture)
	if( IsWithinTransferWindow(dateInt) ) then
		AddCommentatorNotesAudioEvent("CAN_STILL_ADD_TO_SQUAD", "TRIGGER_PREMATCH")
	end
end

--#############################################################################
function SeasonEarlyChecks()
	local teamId = GetCNotesCDB_UserTeamId()
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local side = GetCNotesCDB_UserSide()
	
	CheckLastLeagueGameResults()
	
	SpecificPositionMatchesChecks(teamId, opponentTeamId)
	
	local overallWins, overallDraws, overallLosses, overallHomeWins, overallHomeDraws, overallHomeLosses, overallAwayWins, overallAwayDraws, overallAwayLosses, leagueWins, leagueDraws, leagueLosses, leagueHomeWins, leagueHomeDraws, leagueHomeLosses, leagueAwayWins, leagueAwayDraws, leagueAwayLosses = GetSeasonRecordFromFixtures()
	
	local TEAM_HOME = 0
	local TEAM_AWAY = 1
		
	if(leagueLosses == 0) then
		AddCommentatorNotesAudioEvent("UNBEATEN_LEAGUE", "TRIGGER_PREMATCH", side)
	else
		if(side == TEAM_HOME and leagueHomeLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_HOME_LEAGUE", "TRIGGER_PREMATCH", side)
		end
		if(side == TEAM_AWAY and leagueAwayLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_AWAY_LEAGUE", "TRIGGER_PREMATCH", side)
		end
	end
	
	if(overallWins==0) then
		AddCommentatorNotesAudioEvent("YET_TO_WIN", "TRIGGER_PREMATCH", side)
	end
	
end

--#############################################################################
function SeasonQ2Checks()
	local teamId = GetCNotesCDB_UserTeamId()
	local actualVsExpectations = GetCNotesCDB_ActualVsExpectation()
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local side = GetCNotesCDB_UserSide()
	
	CheckLastLeagueGameResults()
	
	if( not(IsTeamIdPlayoffLeague(teamId))) then
		if( GetLeagueExpectationVsResultString(actualVsExpectations) == "EXPECTATION_EXCEEDING") then
			AddCommentatorNotesAudioEvent("EXCEEDING_EXPECTATIONS_GLORY", "TRIGGER_PREMATCH")
		end
		
		if( GetLeagueExpectationVsResultString(actualVsExpectations) == "EXPECTATION_BELOW") then
			AddCommentatorNotesAudioEvent("BELOW_EXPECTATIONS_PRESSURE", "TRIGGER_PREMATCH", actualVsExpectations, teamId)
		elseif( GetLeagueExpectationVsResultString(actualVsExpectations) == "EXPECTATION_FAR_BELOW") then
			AddCommentatorNotesAudioEvent("BELOW_EXPECTATIONS_PRESSURE", "TRIGGER_PREMATCH", actualVsExpectations, teamId)
		end
	end
	
	SpecificPositionMatchesChecks(teamId, opponentTeamId)
	
	local overallWins, overallDraws, overallLosses, overallHomeWins, overallHomeDraws, overallHomeLosses, overallAwayWins, overallAwayDraws, overallAwayLosses, leagueWins, leagueDraws, leagueLosses, leagueHomeWins, leagueHomeDraws, leagueHomeLosses, leagueAwayWins, leagueAwayDraws, leagueAwayLosses = GetSeasonRecordFromFixtures()
	
	local TEAM_HOME = 0
	local TEAM_AWAY = 1
		
	if(overallLosses == 0) then
		AddCommentatorNotesAudioEvent("UNBEATEN_ALL_COMPS", "TRIGGER_PREMATCH", side)
	elseif(leagueLosses == 0) then
		AddCommentatorNotesAudioEvent("UNBEATEN_LEAGUE", "TRIGGER_PREMATCH", side)
	else
		if(side == TEAM_HOME and leagueHomeLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_HOME_LEAGUE", "TRIGGER_PREMATCH", side)
		end
		if(side == TEAM_AWAY and leagueAwayLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_AWAY_LEAGUE", "TRIGGER_PREMATCH", side)
		end
	end
	
	if(overallWins==0) then
		AddCommentatorNotesAudioEvent("YET_TO_WIN", "TRIGGER_PREMATCH", side)
	end
	
	local isLastMatchBeforeChristmas = IsLastLeagueMatchBeforeChristmas(teamId)
	if(isLastMatchBeforeChristmas) then
		local numTeams = GetNumberOfTeamsInLeague()
		local teamPosition = GetLeaguePosition(teamId)
		
		if( teamPosition == 1 ) then
			AddCommentatorNotesAudioEvent("TOP_AT_CHRISTMAS", "TRIGGER_PREMATCH", side)
		elseif( teamPosition == numTeams ) then
			AddCommentatorNotesAudioEvent("BOTTOM_AT_CHRISTMAS", "TRIGGER_PREMATCH", side)
		end
	end
end

--#############################################################################
function SeasonQ3Checks()
	local teamId = GetCNotesCDB_UserTeamId()
	local actualVsExpectations = GetCNotesCDB_ActualVsExpectation()
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local side = GetCNotesCDB_UserSide()
	
	CheckLastLeagueGameResults()
	
	if( not(IsTeamIdPlayoffLeague(teamId))) then
		if( GetLeagueExpectationVsResultString(actualVsExpectations) == "EXPECTATION_EXCEEDING") then
			AddCommentatorNotesAudioEvent("EXCEEDING_EXPECTATIONS_GLORY", "TRIGGER_PREMATCH")
		end
		
		if( GetLeagueExpectationVsResultString(actualVsExpectations) == "EXPECTATION_BELOW") then
			AddCommentatorNotesAudioEvent("BELOW_EXPECTATIONS_PRESSURE", "TRIGGER_PREMATCH", actualVsExpectations, teamId)
		elseif( GetLeagueExpectationVsResultString(actualVsExpectations) == "EXPECTATION_FAR_BELOW") then
			AddCommentatorNotesAudioEvent("BELOW_EXPECTATIONS_PRESSURE", "TRIGGER_PREMATCH", actualVsExpectations, teamId)
		end
	end
	
	SpecificPositionMatchesChecks(teamId, opponentTeamId)
	
	local overallWins, overallDraws, overallLosses, overallHomeWins, overallHomeDraws, overallHomeLosses, overallAwayWins, overallAwayDraws, overallAwayLosses, leagueWins, leagueDraws, leagueLosses, leagueHomeWins, leagueHomeDraws, leagueHomeLosses, leagueAwayWins, leagueAwayDraws, leagueAwayLosses = GetSeasonRecordFromFixtures()
	
	local TEAM_HOME = 0
	local TEAM_AWAY = 1
	
	if(overallLosses == 0) then
		AddCommentatorNotesAudioEvent("UNBEATEN_ALL_COMPS", "TRIGGER_PREMATCH", side)
	elseif(leagueLosses == 0) then
		AddCommentatorNotesAudioEvent("UNBEATEN_LEAGUE", "TRIGGER_PREMATCH", side)
	else
		if(side == TEAM_HOME and leagueHomeLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_HOME_LEAGUE", "TRIGGER_PREMATCH", side)
		end
		if(side == TEAM_AWAY and leagueAwayLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_AWAY_LEAGUE", "TRIGGER_PREMATCH", side)
		end
	end
	
	if(overallWins==0) then
		AddCommentatorNotesAudioEvent("YET_TO_WIN", "TRIGGER_PREMATCH", side)
	end
end

--#############################################################################
function SeasonLateChecks()
	local teamId = GetCNotesCDB_UserTeamId()
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	local side = GetCNotesCDB_UserSide()
	local highestProbableFinish = GetTeamHighestProbableFinish(teamId)
	local highestPossibleFinish = GetTeamHighestPossibleFinish(teamId)
	
	CheckLastLeagueGameResults()
	
	SpecificPositionMatchesChecks(teamId, opponentTeamId)
	
	if(highestProbableFinish>=0) then
		AddCommentatorNotesAudioEvent("TEAM_HIGHEST_PROBABLE_FINISH", "TRIGGER_PREMATCH", highestProbableFinish, side)
	end
	
	--local bottomGroupButCanFinishHigher = highestPossibleFinish>=0 and currentLeagueGrouping<0
	if(highestPossibleFinish>=0) then
		AddCommentatorNotesAudioEvent("TEAM_HIGHEST_POSSIBLE_FINISH", "TRIGGER_PREMATCH", highestPossibleFinish, side)
	end
	
	local overallWins, overallDraws, overallLosses, overallHomeWins, overallHomeDraws, overallHomeLosses, overallAwayWins, overallAwayDraws, overallAwayLosses, leagueWins, leagueDraws, leagueLosses, leagueHomeWins, leagueHomeDraws, leagueHomeLosses, leagueAwayWins, leagueAwayDraws, leagueAwayLosses = GetSeasonRecordFromFixtures()
	
	local TEAM_HOME = 0
	local TEAM_AWAY = 1
	
	if(overallLosses == 0) then
		AddCommentatorNotesAudioEvent("UNBEATEN_ALL_COMPS", "TRIGGER_PREMATCH", side)
	elseif(leagueLosses == 0) then
		AddCommentatorNotesAudioEvent("UNBEATEN_LEAGUE", "TRIGGER_PREMATCH", side)
	else
		if(side == TEAM_HOME and leagueHomeLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_HOME_LEAGUE", "TRIGGER_PREMATCH", side)
		end
		if(side == TEAM_AWAY and leagueAwayLosses==0) then 
			AddCommentatorNotesAudioEvent("UNBEATEN_AWAY_LEAGUE", "TRIGGER_PREMATCH", side)
		end
	end
	
	if(overallWins==0) then
		AddCommentatorNotesAudioEvent("YET_TO_WIN", "TRIGGER_PREMATCH", side)
	end
end

--#############################################################################
function Game4thLastChecks()
	FinalGamesCheck()
end

--#############################################################################
function Game3rdLastChecks()
	FinalGamesCheck()
end

--#############################################################################
function GamePenulGameChecks()
	FinalGamesCheck()
end

--#############################################################################
function GameFinalGameChecks()
	FinalGamesCheck()
end

--#############################################################################
function TeamsSkillMatchupChecks()
	local teamId = GetCNotesCDB_UserTeamId()
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	
	local teamSkill = GetTeamSkillLevelInFixture(teamId)
	local opponentTeamSkill = GetTeamSkillLevelInFixture(opponentTeamId)
	
	local side = GetCNotesCDB_UserSide()
	
	local largestSkill = 0
	local otherSkill = 0
	
	--LOWER IS BETTER
	if(teamSkill < opponentTeamSkill) then
		largestSkill = teamSkill
		otherSkill = opponentTeamSkill
	else
		largestSkill = opponentTeamSkill
		otherSkill = teamSkill
	end

	AddCommentatorNotesAudioEvent("TEAMS_VS_TEAM_SKILL", "TRIGGER_PREMATCH", largestSkill, otherSkill)
end

--#############################################################################
function DomesticCupChecks()
	TeamsSkillMatchupChecks()
end

--#############################################################################
function PromotionPlayoffChecks()
end

--#############################################################################
function RelegationPlayoffChecks()
end

--#############################################################################
function MLSPlayoffChecks()
end

--#############################################################################
function LeaguePlayoffChecks()
end

--#############################################################################
function ContinentalCupChecks()
end

--#############################################################################
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
--#############################################################################
function SuperCupChecks()
	TeamsSkillMatchupChecks()
end

--#############################################################################
function InternationalChecks()
end

--#############################################################################
function SendMatchImportance()
	local currentGameFixture = GetCurrentGameFixtureData()
	local matchImportance = GetMatchImportance(currentGameFixture)
	AddCommentatorNotesAudioEvent("FIXTURE_MATCH_IMPORTANCE", "TRIGGER_PREMATCH", matchImportance)
end

--#############################################################################
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
--#############################################################################
function PlayerMatchChecks()
	local teamId = GetCNotesCDB_UserTeamId()
	local numPlayersOnTeam = GetNumPlayers( teamId )
	local currentGameFixture = GetCurrentGameFixtureData()
	
	local overallWins, overallDraws, overallLosses, overallHomeWins, overallHomeDraws, overallHomeLosses, overallAwayWins, overallAwayDraws, overallAwayLosses, leagueWins, leagueDraws, leagueLosses, leagueHomeWins, leagueHomeDraws, leagueHomeLosses, leagueAwayWins, leagueAwayDraws, leagueAwayLosses = GetSeasonRecordFromFixtures()
	local totalOverallGames = overallWins+overallDraws+overallLosses
	local totalLeagueGames = leagueWins+leagueDraws+leagueLosses
	
	local subsOnBench = GetSubsOnBenchFromFixture(currentGameFixture)
	local numPlayersInGame = 11 + subsOnBench
	
	for playerCount = 1, numPlayersOnTeam do
		if(playerCount <= numPlayersInGame) then
			local currPlayer = GetPlayer( teamId, playerCount )
			CheckPlayer(teamId, currPlayer, playerCount, currentGameFixture, totalOverallGames, totalLeagueGames)
		end
	end
	
	--CANT CHECK OPPONENT THE SAME AS THEY DON'T HAVE FORM, ETC
	--local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	--local numPlayersOnOpponentTeam = GetNumPlayers( opponentTeamId )
	--for playerCount = 1, numPlayersOnOpponentTeam do
	--	local currPlayer = GetPlayer( opponentTeamId, playerCount )
	--	CheckPlayer(opponentTeamId, currPlayer, currentGameFixture)
	--end
end

--#############################################################################
function CheckPlayer(teamId, playerId, playerIndex, currentGameFixture, totalOverallGames, totalLeagueGames)
	--local playerForm = GetPlayerFormData( teamId, playerId, "CNOTES - CheckPlayer" )
	local playerDOB = GetPlayerDOB( teamId, playerId )
	local currentDate = GetCurrentDate()
	
	local injuryNameId = GetInjuryNameAsId(teamId, playerId)
	if( injuryNameId > 0 ) then --IF PLAYING AND HAS AN INJURY HIGHER THEN NONE
		AddCommentatorNotesAudioEvent("PLAYER_PLAYING_WITH_INJURY", "TRIGGER_PLAYERINFO_PREMATCH", playerId, injuryNameId)
	end
	
	--local isTodayTheBirthday = DoDatesMatch(playerDOB, currentDate, "IGNORE_YEAR")
	--if(isTodayTheBirthday) then
		--AddCommentatorNotesAudioEvent("PLAYER_BIRTHDAY_TODAY", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
	--end
	
	local isVeryGoodForm = false --IsInVeryGoodForm( playerForm )
	if(isVeryGoodForm) then
		AddCommentatorNotesAudioEvent("PLAYER_GREAT_FORM", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
	end
	
	local isPlayerBadMorale = IsPlayerBadMorale(teamId, playerId)
	if(isPlayerBadMorale) then
		AddCommentatorNotesAudioEvent("PLAYER_BAD_MORALE", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
	end
	
	--CARDS ALL GAMES
	local currentCompObjId = GetCurrentGameCompObjId()
	local yellowCards = GetPlayerStatLeagueOnly(teamId, playerId, "YELLOWS", currentCompObjId)
	local redCards = GetPlayerStatLeagueOnly(teamId, playerId, "REDS", currentCompObjId)
	local yellowsPerGame = 0
	if(totalOverallGames > 0) then 
		yellowsPerGame = yellowCards/totalOverallGames
	end
	
	if(yellowCards>4 and yellowsPerGame > 0.2) then
		AddCommentatorNotesAudioEvent("PLAYER_YELLOWS_THIS_SEASON", "TRIGGER_PLAYERINFO_PREMATCH", playerId, yellowCards)
	end
	
	if(redCards > 2) then
		AddCommentatorNotesAudioEvent("PLAYER_REDS_THIS_SEASON", "TRIGGER_PLAYERINFO_PREMATCH", playerId, redCards)
	end
	
	local isOneYellowCardAwayFromSuspension = IsPlayerOneYellowCardAwayFromSuspension(teamId, playerId)
	if(isOneYellowCardAwayFromSuspension) then
		AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_ONE_YELLOW_FROM_SUSPENSION", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
	end
	
	--GOALS, ASSISTS ETC.
	
	--GOALS
	--local goalsAllComps = GetPlayerStat(teamId, playerId, "GOALS", currentCompObjId)
	local goalsLeague = GetPlayerStatLeagueOnly(teamId, playerId, "GOALS", currentCompObjId)
	local goalsAllCompPerGame = 0
	local goalsLeaguePerGame = 0
	
	-- if(totalOverallGames > 0) then 
		-- goalsAllCompPerGame = goalsAllComps/totalOverallGames
	-- end
	
	if(totalLeagueGames > 0) then 
		goalsLeaguePerGame = goalsLeague/totalLeagueGames
	end
	
	--ASSISTS
	--local assistsAllComps = GetPlayerStat(teamId, playerId, "ASSISTS", currentCompObjId)
	local assistsLeague = GetPlayerStatLeagueOnly(teamId, playerId, "ASSISTS", currentCompObjId)
	local assistsAllCompsPerGame = 0
	local assistsLeaguePerGame = 0
	-- if(totalOverallGames > 0) then 
		-- assistsAllCompsPerGame = assistsAllComps/totalOverallGames
	-- end
	if(totalLeagueGames > 0) then 
		assistsLeaguePerGame = assistsLeague/totalLeagueGames
	end
	
	--APPEARANCES
	-- local appearancesAllComps = GetPlayerStat(teamId, playerId, "APPEARANCES", currentCompObjId)
	local appearancesLeague = GetPlayerStatLeagueOnly(teamId, playerId, "APPEARANCES", currentCompObjId)
	
	--EVENTS
	-- if(goalsAllComps > 0 and goalsAllCompPerGame>0.2) then
		-- AddCommentatorNotesAudioEvent("PLAYER_ALL_GOALS_THIS_SEASON", "TRIGGER_PLAYERINFO_PREMATCH", playerId, goalsAllComps)
	-- end
	
	if(goalsLeague > 0 and goalsLeaguePerGame>0.2) then
		AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_GOALS_THIS_SEASON", "TRIGGER_PLAYERINFO_PREMATCH", playerId, goalsLeague)
	end
	
	if(assistsLeague > 2 and totalLeagueGames > 2 and assistsLeaguePerGame > 0.2) then
		AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_ASSISTS_THIS_SEASON", "TRIGGER_PLAYERINFO_PREMATCH", playerId, assistsLeague)
	end
	
	--NOT WORKING PROPERLY - This needs a fix on the c++ side data
	if(playerIndex <= 11 and appearancesLeague == 0 and totalLeagueGames > 5) then
		AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_FIRST_APPEARANCE_THIS_SEASON", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
	end
	
	if(playerIndex <= 11 and appearancesLeague == totalLeagueGames and totalLeagueGames > 5) then
		AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_PLAYED_ALL_GAMES", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
	end
	
	local currentCompObjId = GetCurrentGameCompObjId()
	local isPlayerTopScorerOnTeamLeagueGames = IsPlayerTopInStatLeagueOnly(teamId, playerId, "GOALS", currentCompObjId)
	
	if(isPlayerTopScorerOnTeamLeagueGames and totalLeagueGames > 3 and goalsLeague > 0) then
		AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_TOP_SCORER_FOR_TEAM", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
	end
	
	local positionInScorersTable = IsPlayerInTopScorersTable(playerId)
	
	--IF PLAYER IS IN THE SCORERS TABLE
	if(positionInScorersTable > 0 and goalsLeague > 0) then
		if(positionInScorersTable == 1) then
			AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_TOP_SCORER_IN_LEAGUE", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
		elseif(totalLeagueGames > 3) then
			AddCommentatorNotesAudioEvent("PLAYER_LEAGUE_AMONG_TOP_SCORERS_IN_LEAGUE", "TRIGGER_PLAYERINFO_PREMATCH", playerId)
		end
	end	
end

--#############################################################################
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
--HELPERS
--#############################################################################
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
function FinalGamesCheck()
	local teamId = GetCNotesCDB_UserTeamId()
	local currentLeagueGrouping = GetCNotesCDB_UserActualGrouping()
	local highestProbableFinish = GetTeamHighestProbableFinish(teamId)
	local highestPossibleFinish = GetTeamHighestPossibleFinish(teamId)
	local clinchedCurrentLeagueGrouping = HasClinchedLeagueGrouping(teamId, currentLeagueGrouping)
	local currentGameFixture = GetCurrentGameFixtureData()
	local side = GetCNotesCDB_UserSide()
	local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	
	CheckLastLeagueGameResults()
	
	--CHECK CLINCH
	
	local hasClinchedHighestProbable = HasClinchedLeagueGrouping(teamId, highestProbableFinish)
	if(highestProbableFinish>=0 and not(hasClinchedHighestProbable)) then
		AddCommentatorNotesAudioEvent("TEAM_HIGHEST_PROBABLE_FINISH", "TRIGGER_PREMATCH", highestProbableFinish, side)
	end
	
	--local bottomGroupButCanFinishHigher = highestPossibleFinish>=0 and currentLeagueGrouping<0
	local hasClinchedHighestPossible = HasClinchedLeagueGrouping(teamId, highestPossibleFinish)
	-- ALSO ONLY TRIGGER IF IT'S DIFFERENT THEN HIGHEST POSSIBLE, in the last four games what the audio guys hooked up is not entirely correct,
	-- so to fix it we only send this if it's different then the highest possible grouping
	if(highestPossibleFinish>=0 and not(hasClinchedHighestPossible) and (highestProbableFinish~=highestPossibleFinish)) then
		AddCommentatorNotesAudioEvent("TEAM_HIGHEST_POSSIBLE_FINISH", "TRIGGER_PREMATCH", highestPossibleFinish, side)
	end
	
	SpecificPositionMatchesChecks(teamId, opponentTeamId)
	
	
	--CHECKS team expectation
	--if(clinchedTeamExpectation and teamExpectation>=0) then
	--	AddCommentatorNotesAudioEvent("TEAM_CLINCHED_GROUPING", "TRIGGER_PREMATCH", teamExpectation, side)
	--end
	
	
	--TODO USE THE REAL SSS so we can send all clinched groups using the SSS flags
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	--FOR ALL GROUPS THAT ARE CLINCHED LOOP AND ADD MESSAGES
	--ON C++ SORT BY HIGHEST GROUPINGS
	--NEED TUDORS CHANGE TO GET THESE VALUES THOUGH	
	
	--Checks current grouping
	if(clinchedCurrentLeagueGrouping and currentLeagueGrouping>=0) then
		AddCommentatorNotesAudioEvent("TEAM_CLINCHED_GROUPING", "TRIGGER_PREMATCH", currentLeagueGrouping, side)
	end
	
end

function CheckLastLeagueGameResults()
	local numGamesToCheck = 1
	local wins,losses,draws = GetRecordForLastXGames(numGamesToCheck, true)
	local win_loss_draw_enum = 0
	if(wins > 0) then 
		win_loss_draw_enum = 0 --WIN
	elseif(draws > 0) then
		win_loss_draw_enum = 1 --DRAW
	else
		win_loss_draw_enum = 2 --LOSS
	end
	
	AddCommentatorNotesAudioEvent("LAST_GAME_RESULTS", "TRIGGER_PREMATCH", win_loss_draw_enum)
end

--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
function SpecificPositionMatchesChecks(teamId, opponentTeamId)

	--BASICALLY a quick check for MEXICO, SCOTLAND and MLS
	local isTeamFromSplitLeague = IsTeamFromSplitLeague(teamId)
	local ignoreLeague = IgnorePositionChecksForTeam(teamId)
	local areTeamsSameConference = false
	if(isTeamFromSplitLeague) then
		areTeamsSameConference = AreTeamsInSameConference(teamId, opponentTeamId)
	end
	
	local canCheckPositionEvents = not(ignoreLeague) and ( ( not (isTeamFromSplitLeague) ) or (isTeamFromSplitLeague and areTeamsSameConference ) )
	
	if( canCheckPositionEvents ) then
		local numTeams = GetNumberOfTeamsInLeague()
		local teamPosition = GetLeaguePosition(teamId)
		local opponentTeamPosition = GetLeaguePosition(opponentTeamId)
		
		--TOP
		if(teamPosition==1) then
			AddCommentatorNotesAudioEvent("SEASON_LEADER", "TRIGGER_PREMATCH")
		end
		
		--BOTTOM
		if(teamPosition==numTeams) then
			AddCommentatorNotesAudioEvent("SEASON_BOTTOM_PLACE", "TRIGGER_PREMATCH")
		end
		
		---------------------------------------------------------
		
		--1vLAST
		if( (teamPosition == 1 or teamPosition == numTeams) and (opponentTeamPosition == 1 or opponentTeamPosition == numTeams) ) then --Teams are 1andLAST
			AddCommentatorNotesAudioEvent("FIRST_VS_LAST", "TRIGGER_PREMATCH")
		end
		
		--LASTv2ndLAST
		local bottomTeamsPlayed = false
		if( (teamPosition == (numTeams-1) or teamPosition == numTeams) and (opponentTeamPosition == (numTeams-1) or opponentTeamPosition == numTeams) ) then --Teams are LASTvs2ndLAST
			bottomTeamsPlayed = true
			AddCommentatorNotesAudioEvent("LAST_VS_SECONDLAST", "TRIGGER_PREMATCH")
		end
		
		---------------------------------------------------------
		
		--IS TOP TEAMS GAME
		local topTeamsPlayed = false
		if(teamPosition == 1 or opponentTeamPosition==1) then
			if(teamPosition == 1) then
				if(opponentTeamPosition==2) then
					topTeamsPlayed = true
					AddCommentatorNotesAudioEvent("FIRST_VS_SECOND", "TRIGGER_PREMATCH")
				end
				
				if(opponentTeamPosition == 3 ) then
					topTeamsPlayed = true
					AddCommentatorNotesAudioEvent("FIRST_VS_THIRD", "TRIGGER_PREMATCH")
				end
				
				if(opponentTeamPosition == 4) then
					topTeamsPlayed = true
					AddCommentatorNotesAudioEvent("FIRST_VS_FOURTH", "TRIGGER_PREMATCH")
				end
			else --opponent is first(1)
				if(teamPosition==2) then
					topTeamsPlayed = true
					AddCommentatorNotesAudioEvent("FIRST_VS_SECOND", "TRIGGER_PREMATCH")
				end
				
				if(teamPosition == 3) then
					topTeamsPlayed = true
					AddCommentatorNotesAudioEvent("FIRST_VS_THIRD", "TRIGGER_PREMATCH")
				end
				
				if(teamPosition == 4) then
					topTeamsPlayed = true
					AddCommentatorNotesAudioEvent("FIRST_VS_FOURTH", "TRIGGER_PREMATCH")
				end
			end
		elseif( (teamPosition == 2 or teamPosition == 3) and (opponentTeamPosition == 2 or opponentTeamPosition == 3) ) then --Teams are 2and3
			topTeamsPlayed = true
			AddCommentatorNotesAudioEvent("SECOND_VS_THIRD", "TRIGGER_PREMATCH")
		end
		---------------------------------------------------------
		
		--IF WE HAVE NOT ALREADY REPORTED A CLASH MATCH
		if(not(topTeamsPlayed)) then
			--CHECK HIGH TEAM CLASH
			local HIGH_TEAM_PERCENT_TOP = 15
			local HIGH_TEAM_PERCENT_BOTTOM = 40
			local teamPositionPercentage = math.floor (((teamPosition/numTeams)*100) + 0.5)
			local opponentPositionPercentage = math.floor (((opponentTeamPosition/numTeams)*100) + 0.5)
			local isTeamHigh = (teamPositionPercentage >= HIGH_TEAM_PERCENT_TOP and teamPositionPercentage <= HIGH_TEAM_PERCENT_BOTTOM)
			local isOpponentHigh = (opponentPositionPercentage >= HIGH_TEAM_PERCENT_TOP and opponentPositionPercentage <= HIGH_TEAM_PERCENT_BOTTOM)
			if(isTeamHigh and isOpponentHigh) then
				AddCommentatorNotesAudioEvent("HIGH_TEAM_CLASH", "TRIGGER_PREMATCH")
			end
		end
		
		---------------------------------------------------------
		
		if(not(bottomTeamsPlayed)) then
			--CHECK LOW TEAM CLASH
			local LOWLY_TEAM_PERCENT = 67
			local isTeamLowly = (math.floor (((teamPosition/numTeams)*100) + 0.5) >= LOWLY_TEAM_PERCENT)
			local isOpponentLowly = (math.floor (((opponentTeamPosition/numTeams)*100) + 0.5) >= LOWLY_TEAM_PERCENT)
			if(isTeamLowly and isOpponentLowly) then
				AddCommentatorNotesAudioEvent("LOWLY_TEAM_CLASH", "TRIGGER_PREMATCH")
			end
		end
	end
	
	--IS RELEGATION CLASH
	local teamInRelegationZone = IsTeamInRelegationZone(teamId)
	local opponentTeamInRelegationZone = IsTeamInRelegationZone(opponentTeamId)
	if(teamInRelegationZone and opponentTeamInRelegationZone) then
		AddCommentatorNotesAudioEvent("RELEGATION_ZONE_CLASH", "TRIGGER_PREMATCH")
	end
end
