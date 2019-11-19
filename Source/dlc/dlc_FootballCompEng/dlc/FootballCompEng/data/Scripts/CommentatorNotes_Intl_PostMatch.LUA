--#############################################################################
--Entry point of CNotes logic, flow of data
function ProcessCommentatorNotes_POST(timesliceStr)
	Print ("############# COMMENTATOR NOTES INTL POSTMATCH LOGIC!!! slice was " .. timesliceStr)

	local isPlayAsPlayerMode, isManagerMode, cupAssetId, userTeamFavoredStatus, teamExpectation, tournamentStage = GetIntlGeneralInfo()

	if(isPlayAsPlayerMode) then
	
		local isInternationalPlayerDebut, isCleanSheetEligible, playerRole = GetIntlPlayerInfo()
		if(isInternationalPlayerDebut) then
			IntlPlayerDebut(cupAssetId, isCleanSheetEligible, playerRole)
		end
		
		PAP_MOTM(cupAssetId)
		PAPGoldenGloveCheck(cupAssetId, tournamentStage, playerRole)
		PAPTopScorerCheck(cupAssetId, tournamentStage)
		
	elseif(isManagerMode) then
	
		local isInternationalManagerDebut = GetIntlManagerInfo()
		if(isInternationalManagerDebut) then
			IntlManagerDebut(cupAssetId, userTeamFavoredStatus)
		end
		
		CheckIntlManagerObjectives(cupAssetId, teamExpectation, tournamentStage)
		
	end
end

--#############################################################################
function IntlManagerDebut(cupAssetId, userTeamFavoredStatus)
	if(userTeamFavoredStatus == 0) then
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVORED_WIN_CONVINCING", "TRIGGER_POST_WIN_UP3PLUSGOALS", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVORED_WIN", "TRIGGER_POST_WIN", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVORED_DRAW", "TRIGGER_POST_DRAW", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVORED_LOSS_TOUGH", "TRIGGER_POST_LOSS_DOWN3PLUSGOALS", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVORED_LOSS", "TRIGGER_POST_LOSS", cupAssetId, userTeamFavoredStatus)
	elseif(userTeamFavoredStatus == 1) then
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVOR_EVEN_WIN_CONVINCING", "TRIGGER_POST_WIN_UP3PLUSGOALS", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVOR_EVEN_WIN", "TRIGGER_POST_WIN", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVOR_EVEN_DRAW", "TRIGGER_POST_DRAW", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVOR_EVEN_LOSS_TOUGH", "TRIGGER_POST_LOSS_DOWN3PLUSGOALS", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_FAVOR_EVEN_LOSS", "TRIGGER_POST_LOSS", cupAssetId, userTeamFavoredStatus)
	else
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_NOT_FAVORED_WIN_CONVINCING", "TRIGGER_POST_WIN_UP3PLUSGOALS", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_NOT_FAVORED_WIN", "TRIGGER_POST_WIN", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_NOT_FAVORED_DRAW", "TRIGGER_POST_DRAW", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_NOT_FAVORED_LOSS_TOUGH", "TRIGGER_POST_LOSS_DOWN3PLUSGOALS", cupAssetId, userTeamFavoredStatus)
		AddCommentatorNotesAudioEvent("INTL_MANAGER_DEBUT_TEAM_NOT_FAVORED_LOSS", "TRIGGER_POST_LOSS", cupAssetId, userTeamFavoredStatus)
	end
end

--#############################################################################
function IntlPlayerDebut(cupAssetId, isCleanSheetEligible, playerRole)
	AddCommentatorNotesAudioEvent("INTL_PAP_DEBUT_MATCHRATING_LOW", "TRIGGER_POST_MATCHRATING_LOW", cupAssetId)
	AddCommentatorNotesAudioEvent("INTL_PAP_DEBUT_MATCHRATING_MED", "TRIGGER_POST_MATCHRATING_MED", cupAssetId)
	AddCommentatorNotesAudioEvent("INTL_PAP_DEBUT_MATCHRATING_HIGH", "TRIGGER_POST_MATCHRATING_HIGH", cupAssetId)
	if(isCleanSheetEligible) then
		if(playerRole == "PLAYER_GENERAL_POSITION_RB" or playerRole == "PLAYER_GENERAL_POSITION_CB" or playerRole == "PLAYER_GENERAL_POSITION_LB") then
			AddCommentatorNotesAudioEvent("INTL_PAP_DEBUT_CLEANSHEET_DEFENSE", "TRIGGER_POST_CLEANSHEET", cupAssetId)
		elseif(playerRole == "PLAYER_GENERAL_POSITION_GK") then
			AddCommentatorNotesAudioEvent("INTL_PAP_DEBUT_CLEANSHEET_GK", "TRIGGER_POST_CLEANSHEET", cupAssetId)
		end
	end
end

--#############################################################################
function PAPGoldenGloveCheck(cupAssetId, tournamentStage, playerRole)
	if(tournamentStage == "SITUATION_TYPE_FINAL") then
		--SHOULD TRIGGER THIS IF IN POST MATCH HAS WON GOLDENGLOVE
		if(playerRole == "PLAYER_GENERAL_POSITION_GK") then
			AddCommentatorNotesAudioEvent("INTL_PAP_WON_GOLDENGLOVE", "TRIGGER_POST_GOLDENGLOVE", cupAssetId)
		end
	end
end

--#############################################################################
function PAPTopScorerCheck(cupAssetId, tournamentStage)
	if(tournamentStage == "SITUATION_TYPE_FINAL") then
		--SHOULD TRIGGER THIS IF IN POST MATCH HAS WON TOP SCORER
		AddCommentatorNotesAudioEvent("INTL_PAP_WON_TOPSCORER", "TRIGGER_POST_TOPSCORER", cupAssetId)
	end
end

--#############################################################################
function PAP_MOTM(cupAssetId)
	--SHOULD TRIGGER THIS IF IN POST MATCH HAS WON MOTM
	AddCommentatorNotesAudioEvent("INTL_PAP_WON_MOTM", "TRIGGER_POST_MOTM", cupAssetId)
end

function CheckIntlManagerObjectives(cupAssetId, teamExpectation, tournamentStage)

	Print("cupAssetId:"..cupAssetId)
	Print("teamExpectation:"..teamExpectation)
	Print("tournamentStage:"..tournamentStage)
	if(tournamentStage == "SITUATION_TYPE_FINAL") then
		if(teamExpectation == "CUPOBJECTIVE_WIN_CUP") then
			--Team needs to win to reach objective
			AddCommentatorNotesAudioEvent("INTL_AT_FINALS_ISGOAL_WIN", "TRIGGER_POST_WIN", cupAssetId)
			AddCommentatorNotesAudioEvent("INTL_AT_FINALS_ISGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		elseif(teamExpectation == "CUPOBJECTIVE_REACH_FINALS") then
			--Team reached and it was their objective
			AddCommentatorNotesAudioEvent("INTL_AT_FINALS_ABOVEGOAL_WIN", "TRIGGER_POST_WIN", cupAssetId)
			AddCommentatorNotesAudioEvent("INTL_AT_FINALS_ISGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		else
			--reached and above their objective
			AddCommentatorNotesAudioEvent("INTL_AT_FINALS_ABOVEGOAL_WIN", "TRIGGER_POST_WIN", cupAssetId)
			AddCommentatorNotesAudioEvent("INTL_AT_FINALS_ABOVEGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		end
	elseif(tournamentStage == "SITUATION_TYPE_SEMIFINAL") then
		if(teamExpectation == "CUPOBJECTIVE_REACH_FINALS" or teamExpectation == "CUPOBJECTIVE_WIN_CUP") then
			--team exp is higher
			AddCommentatorNotesAudioEvent("INTL_AT_SEMI_BELOWGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		elseif(teamExpectation == "CUPOBJECTIVE_REACH_SEMI_FINALS") then
			--team met expectation
			AddCommentatorNotesAudioEvent("INTL_AT_SEMI_ISGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		else
			--team exceeded
			AddCommentatorNotesAudioEvent("INTL_AT_SEMI_ABOVEGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		end
	elseif(tournamentStage == "SITUATION_TYPE_QUARTERFINAL") then
		if(teamExpectation == "CUPOBJECTIVE_REACH_FINALS" or teamExpectation == "CUPOBJECTIVE_REACH_SEMI_FINALS" or teamExpectation == "CUPOBJECTIVE_WIN_CUP") then
			--team exp is higher
			AddCommentatorNotesAudioEvent("INTL_AT_QUARTER_BELOWGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		elseif(teamExpectation == "CUPOBJECTIVE_REACH_QUARTER_FINALS") then
			--team exp met
			AddCommentatorNotesAudioEvent("INTL_AT_QUARTER_ISGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		else
			--team exceeding
			AddCommentatorNotesAudioEvent("INTL_AT_QUARTER_ABOVEGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		end
	elseif(tournamentStage == "SITUATION_TYPE_ROUND") then
		--ROUND OF 16
		if(teamExpectation == "CUPOBJECTIVE_REACH_FINALS" or teamExpectation == "CUPOBJECTIVE_REACH_SEMI_FINALS" or teamExpectation == "CUPOBJECTIVE_REACH_QUARTER_FINALS" or teamExpectation == "CUPOBJECTIVE_WIN_CUP") then
			--team exp is higher
			AddCommentatorNotesAudioEvent("INTL_AT_ROUND_BELOWGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		elseif(teamExpectation == "CUPOBJECTIVE_REACH_ROUND_16" or teamExpectation == "CUPOBJECTIVE_REACH_KNOCKOUT") then
			--team exp met
			AddCommentatorNotesAudioEvent("INTL_AT_ROUND_ISGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		else
			--team exceeding
			AddCommentatorNotesAudioEvent("INTL_AT_ROUND_ABOVEGOAL_LOSS", "TRIGGER_POST_LOSS", cupAssetId)
		end
	end
end



















