--#############################################################################
--COMMON helpers for CNotes
--#############################################################################

function SetCommonDataBlock()

	local teamId = GetUserTeam()
	local currentGameFixture = GetCurrentGameFixtureData()
	local side = GetTeamSideInFixture(teamId, currentGameFixture)
	
	--TEAMFORM
	local overallWins, overallDraws, overallLosses, overallHomeWins, overallHomeDraws, overallHomeLosses, overallAwayWins, overallAwayDraws, overallAwayLosses, leagueWins, leagueDraws, leagueLosses, leagueHomeWins, leagueHomeDraws, leagueHomeLosses, leagueAwayWins, leagueAwayDraws, leagueAwayLosses = GetSeasonRecordFromFixtures()
	
	local leagueTotalGames = leagueWins + leagueDraws + leagueLosses
	
	local numGamesToCheck = 5
	if(numGamesToCheck>leagueTotalGames) then
		numGamesToCheck = leagueTotalGames --IN CASE WE HAVEN'T PLAYED ENOUGH TO CHECK LAST 5 LEAGUE GAMES
	end
	
	local wins,losses,draws = GetRecordForLastXGames(numGamesToCheck, true)
	local possiblePoints = numGamesToCheck*3
	local points = wins*3 + draws
	local formScoreShort = 0
	if(possiblePoints>0) then
		formScoreShort = math.floor (((points/possiblePoints)*100) + 0.5) --this will round
	end
	
	numGamesToCheck = 10
	if(numGamesToCheck>leagueTotalGames) then
		numGamesToCheck = leagueTotalGames --IN CASE WE HAVEN'T PLAYED ENOUGH TO CHECK LAST 10 LEAGUE GAMES
	end
	
	wins,losses,draws = GetRecordForLastXGames(numGamesToCheck, true)
	possiblePoints = numGamesToCheck*3
	points = wins*3 + draws
	local formScoreLong = 0
	if(possiblePoints>0) then
		formScoreLong = math.floor (((points/possiblePoints)*100) + 0.5) --this will round
	end
	
	local lastXForm = GetFormEnumForLastGames()
	
	local teamExpectation = GetTeamLeagueObjectiveAsInt(teamId)
	
	local currentLeagueGrouping = GetTeamLeagueGrouping(teamId)
	
	local actualVsExpectations = GetTeamLeague_ActualVsExpectations(teamId)
	
	local predictedGapResult = GetTeamLeague_PredictedVsExpectations(teamId)
	
	local opponentTeamId = GetTeamOpponent(teamId, currentGameFixture)
	
	local opponentTeamExpectation = GetTeamLeagueObjectiveAsInt(opponentTeamId)
	
	--SetC++ side data block
	SetCommentatorNotesCommonDataBlock(teamId, side, formScoreShort, formScoreLong, lastXForm, teamExpectation, currentLeagueGrouping, actualVsExpectations, predictedGapResult, opponentTeamId, opponentTeamExpectation )
end

--#############################################################################
function IsPreseason(timesliceStr)
	if( timesliceStr == "CAREER_TIMELINE_SLICE_PRESEASON_GAME1" or timesliceStr == "CAREER_TIMELINE_SLICE_PRESEASON_GAME2" or timesliceStr == "CAREER_TIMELINE_SLICE_PRESEASON_GAME3PLUS") then
		return true
	end
	
	return false
end

--#############################################################################
function IsFirstHalfOfSeason(timesliceStr)
	if(not IsPreseason(timesliceStr)) then
		if(timesliceStr == "CAREER_TIMELINE_SLICE_GAME1" or timesliceStr == "CAREER_TIMELINE_SLICE_GAME2" or timesliceStr == "CAREER_TIMELINE_SLICE_GAME3" or timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_EARLY" or timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_Q2") then
			return true
		end
	end
	
	return false
end

--#############################################################################
function IsLastHalfOfSeason(timesliceStr)
	if(not IsPreseason(timesliceStr)) then
		if(timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_Q3" or timesliceStr == "CAREER_TIMELINE_SLICE_SEASON_LATE" or timesliceStr == "CAREER_TIMELINE_SLICE_GAME_END4" or timesliceStr == "CAREER_TIMELINE_SLICE_GAME_END3" or timesliceStr == "CAREER_TIMELINE_SLICE_GAME_END_PENUL" or timesliceStr == "CAREER_TIMELINE_SLICE_GAME_FINAL") then
			return true
		end
	end
	
	return false
end

--#############################################################################
function IsCupGame(timesliceStr)
	if(not IsPreseason(timesliceStr)) then
		if(timesliceStr == "CAREER_TIMELINE_SLICE_SUPERCUP" or timesliceStr == "CAREER_TIMELINE_SLICE_CONTINENTAL_CUP_ROUND" or timesliceStr == "CAREER_TIMELINE_SLICE_CONTINENTAL_CUP_FINAL" or timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_FINAL" or timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_SEMIFINAL" or timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_QUARTERFINAL" or timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_ROUND" or timesliceStr == "CAREER_TIMELINE_SLICE_DOMESTIC_CUP_QUALIFYING") then
			return true	
		end
	end
	
	return false
end

--#############################################################################
function CheckLastSeasonResults(lastSeasonsResults, lastSeasonWasChamp, side, teamId)

	--IF THEY WERE PROMOTED then we don't care if they were champion for this messaging, since they were champion in another league
	--only report the promotion

	if(lastSeasonsResults <= 0) then
		--PROMOTED OR RELEGATED
		if(lastSeasonsResults == -1) then
			AddCommentatorNotesAudioEvent("TEAM_LAST_SEASON_RELEGATED", "TRIGGER_PREMATCH_STITCH", side, teamId)
		else
			AddCommentatorNotesAudioEvent("TEAM_LAST_SEASON_PROMOTED", "TRIGGER_PREMATCH_STITCH", side, teamId)
		end
	elseif(lastSeasonWasChamp == 1) then
		AddCommentatorNotesAudioEvent("TEAM_LAST_SEASON_CHAMPION", "TRIGGER_PREMATCH_STITCH", side, teamId)
	else
		--REPORT POSITION since lastSeasonResult will be > 0
		AddCommentatorNotesAudioEvent("TEAM_LAST_SEASON_RESULTS", "TRIGGER_PREMATCH", lastSeasonsResults, side, teamId)
	end
end