--#############################################################################
--Entry point of CNotes logic, flow of data
function ProcessCommentatorNotes_POST(timesliceStr)
	Print ("############# COMMENTATOR NOTES LEAGUE POSTMATCH LOGIC!!! slice was " .. timesliceStr)
	
	-- if( (not(IsPreseason(timesliceStr))) and (not(IsCupGame(timesliceStr)))) then
		-- --LEAGUE GAME SO CHECK CLINCHINGS
		-- if( IsLastHalfOfSeason(timesliceStr) ) then
			-- GenerateGameResultsClinchings()
		-- end
	-- end
	
end


--#############################################################################
-- function GenerateGameResultsClinchings()
	-- local teamId = GetCNotesCDB_UserTeamId()
	-- local opponentTeamId = GetCNotesCDB_OpponentTeamId()
	
	-- --SIDE??
	
	-- local postMatchTriggerArray = {"TRIGGER_POST_WIN", "TRIGGER_POST_DRAW", "TRIGGER_POST_LOSS"}
	-- local maxObjectivesPerGroup = GetMaxNumLeagueObjectivesPerGrouping()

	-- for i, v in ipairs(postMatchTriggerArray) do
		-- GenerateGameResultsClinchingsForOutcome(teamId, opponentTeamId, v, maxObjectivesPerGroup)
		-- GenerateGameResultsClinchingsForOutcome(opponentTeamId, teamId, v, maxObjectivesPerGroup)
	-- end
-- end

--#############################################################################
-- function GenerateGameResultsClinchingsForOutcome(teamId, opponentId, postMatchTrigger, maxObjectivesPerGroup)
	-- local maxObjectivesPerGroup = GetMaxNumLeagueObjectivesPerGrouping()
	
	-- -- WE do '-2' here because we don't care about clinching bottom group since really you always clinch bottom group
	-- for groupObjectiveIndex=0,maxObjectivesPerGroup-2 do 
		-- Print("GenerateGameResultsClinchingsForOutcome teamId:"..teamId.." opponentId:"..opponentId.." objective:"..groupObjectiveIndex.." Result:"..postMatchTrigger)
		-- if(postMatchTrigger == "TRIGGER_POST_WIN" or postMatchTrigger == "TRIGGER_POST_DRAW") then
			-- Print("WillResultClinchGrouping()")
			-- local willResClinch = WillResultClinchGrouping(teamId, opponentId, groupObjectiveIndex, postMatchTrigger)
			-- if(willResClinch) then
				-- --TRIGGER CNOTES
				-- if(postMatchTrigger == "TRIGGER_POST_WIN") then
					-- AddCommentatorNotesAudioEvent("POST_RESULT_WIN_CLINCH", postMatchTrigger, teamId, groupObjectiveIndex, 0)
				-- else
					-- AddCommentatorNotesAudioEvent("POST_RESULT_DRAW_CLINCH", postMatchTrigger, teamId, groupObjectiveIndex, 0)
				-- end
			-- end
		-- end
		
		-- if(postMatchTrigger == "TRIGGER_POST_DRAW" or postMatchTrigger == "TRIGGER_POST_LOSS") then
			-- Print("WillResultGuaranteeRelegation()")
			-- local willResGuaranteeRelegation = WillResultGuaranteeRelegation(teamId, postMatchTrigger)
			-- if(willResGuaranteeRelegation) then
				-- --TRIGGER CNOTES
				-- if(postMatchTrigger == "TRIGGER_POST_DRAW") then
					-- AddCommentatorNotesAudioEvent("POST_RESULT_DRAW_GUARANTEE_RELEGATION", postMatchTrigger, teamId, groupObjectiveIndex, 0)
				-- else
					-- AddCommentatorNotesAudioEvent("POST_RESULT_LOSS_GUARANTEE_RELEGATION", postMatchTrigger, teamId, groupObjectiveIndex, 0)
				-- end
			-- end
		-- end
	-- end
-- end