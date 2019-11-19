function CreateAudioIdLua( id1, id2, id3, id4 )
	id1 = id1 * 1000000
	id2 = id2 * 10000
	id3 = id3 * 100
	return id1 + id2 + id3 + id4
end

function GetAudioID( story, stageId, storyCategory, storyId, teamId, playerId, isPlayingId, positionId, usage )
	local audioId = 0
	local id1 = 0
	local id2 = 0
	local id3 = 0
	local id4 = 0
	if( storyCategory == "FORM" ) then -- USAGE ISSUES
		local formRatingId = 0
		if( teamId == Engine.GetUserTeam() ) then
			formRatingId = GetFormRatingAudioID( teamId, playerId )
		else
			local currentTeamId = Engine.GetTeamIdFromPlayerId( playerId )
			if( currentTeamId == teamId ) then
				local teamStatObj, numStats = Engine.GetTeamStatObj( teamId )
				local matchNumber = Engine.GetCPUFormMatchNumber( teamStatObj, numStats )
				form = Engine.GetCPUPlayerForm( teamId, playerId, teamStatObj, numStats, matchNumber )
				formRatingId = GetFormRatingAudioIDByLevel( form )
			end
		end
		local storyAudioId = 1		
		id1 = 0
		id2 = formRatingId
		id3 = -1
		id4 = storyAudioId
		
	elseif( storyCategory == "INJURED" ) then
		local storyAudioId = 2
		id1 = 0
		id2 = 0
		id3 = -1
		id4 = storyAudioId
		
	elseif( storyCategory == "RETIRE" ) then  -- USAGE ISSUES
		local storyAudioId = 3
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
		
	elseif( storyCategory == "CPU_RETIRING" ) then  -- USAGE ISSUES
		local storyAudioId = 3
		id1 = 0
		id2 = 0
		id3 = -1
		id4 = storyAudioId

	elseif( storyCategory == "SIGNING" ) then  -- USAGE ISSUES
		local storyAudioId = 4
		local useStage = 0
		local form = 0
		if( stageId >= 6 ) then
			useStage = 5
			local playerForm = Engine.GetPlayerFormLevel( teamId, playerId )
			if( playerForm == "VERY_GOOD" ) then
				form = 01
			elseif( playerForm == "VERY_BAD" ) then
				form = 02
			end
		else
			if( stageId == 5 ) then
				useStage = stageId
			elseif( stageId == 3 ) then
				useStage = stageId
			else
				local playerTier = Engine.GetPlayerTier( teamId, playerId )
				if( playerTier > 2 ) then 
					useStage = 4
				else
					useStage = stageId
				end
			end
		end
		id1 = form
		id2 = useStage
		id3 = -1
		id4 = storyAudioId

	elseif( storyId == "LOWENERGY" ) then	-- USAGE ISSUES	
		local storyAudioId = 6
		id1 = 0
		id2 = 0
		id3 = -1
		id4 = storyAudioId
		
	elseif( storyCategory == "LOAN" ) then  -- USAGE ISSUES
		local storyAudioId = 7
		id1 = 0
		id2 = -1
		id3 = 01
		id4 = storyAudioId
		
	elseif( storyCategory == "TRANSFER" ) then  -- USAGE ISSUES
		local storyAudioId = 7
		id1 = 0
		id2 = -1
		id3 = 00
		id4 = storyAudioId

	elseif( storyCategory == "TRANSREQ" ) then
		local storyVar = Engine.GetStoryVariable( story )
		local storyAudioId = 8
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId		
		
	elseif( storyCategory == "CONT_REB" ) then
		local storyAudioId = 9
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId	
	
	elseif( storyCategory == "REQTRANS" ) then  -- USAGE ISSUES
		local storyAudioId = 10
		id1 = 0
		id2 = -1
		id3 = stageId
		id4 = storyAudioId	
		
	elseif( storyCategory == "STUPID" ) then
		local storyAudioId = 13
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId	
	
	elseif( string.find( storyId, "NEGOTIATE" ) ~= nil ) then
		local storyAudioId = 15
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
		
	elseif( string.find( storyId, "LOSTPLAYER" ) ~= nil ) then
		local storyAudioId = 16	
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId	
		
	elseif( storyId == "LOSTTOP" ) then
		local storyAudioId = 17		
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId	
	
	elseif( storyId == "LOSTREPLACE" ) then
		local storyAudioId = 18
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId	
	
	elseif( storyId == "PFR" ) then
		local storyAudioId = 19
		id1 = 0
		id2 = -1
		id3 = stageId
		id4 = storyAudioId
	
	elseif( storyId == "PLAYERCRIT" ) then
		local storyAudioId = 20
		id1 = 0
		id2 = -1
		id3 = stageId
		id4 = storyAudioId
	
	elseif( storyCategory == "POORFORM" ) then  -- USAGE ISSUES
		local storyAudioId = 21
		local stage = 3
		local storyType = 0
		if( storyId == "NOGOAL" ) then
			if( usage == 1 ) then
				if( stageId == 5 ) then
					stage = 0
				elseif( stageId > 5 and stageId < 11 ) then
					stage = 1
				elseif( stageId > 10 ) then
					stage = 2
				end		
			end
		end
		if( storyId == "POORRUN" ) then
			storyType = 1
		end
		id1 = stage
		id2 = usage
		id3 = storyType
		id4 = storyAudioId
	
	elseif( string.find( storyId, "FORMERTEAM" ) ~= nil ) then
		if( isPlayingId <= 1 ) then
			local storyAudioId = 22
			id1 = 0
			id2 = 0
			id3 = -1
			id4 = storyAudioId
		end
	elseif( storyId == "RESERVEREQ" ) then
		if( isPlayingId <= 1 ) then
			local storyAudioId = 23
			id1 = 0
			id2 = 0
			id3 = -1
			id4 = storyAudioId
		end
	elseif( storyId == "WEAKSPOT" ) then
		local storyAudioId = 25
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
	
	elseif( string.find( storyId, "OVERPRICED" ) ~= nil ) then
		local storyAudioId = 26
		id1 = 0
		id2 = 0
		id3 = -1
		id4 = storyAudioId
	
	elseif( string.find( storyId, "UNDERPRICED" ) ~= nil ) then
		local storyAudioId = 27
		id1 = 0
		id2 = 0
		id3 = -1
		id4 = storyAudioId
			
	elseif( storyId == "INTPLAYER" ) then
		local storyAudioId = 39
		local storyVar = Engine.GetStoryVariable( story )
		local subStage = 0
		if( storyVar == "STAGE0.5" ) then
			subStage = 1
		end
		id1 = subStage
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
	
	elseif( storyId == "INTMANAGER" ) then
		local storyAudioId = 36
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
	
	elseif( storyId == "NEWMANAGER" ) then
		local storyAudioId = 31
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
	
	elseif( storyId == "LOANPLAYER" or storyId == "LOANRETURN" ) then
		local storyAudioId = 32
		local stage = 1
		if( storyId == "LOANRETURN" ) then
			stage = 2
		end
		id1 = 0
		id2 = stage
		id3 = -1
		id4 = storyAudioId
		
	elseif( storyId == "INTJOBOFFER" ) then
		local storyAudioId = 35
		if( stageId == 5 ) then
			stageId = 2
		end
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
		
	elseif( storyId == "PAMJOBOFFER" ) then
		local storyAudioId = 28
		if( stageId == 5 ) then
			stageId = 2
		end
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
		
	elseif( storyId == "MANAGERRUMOURS" ) then
		local storyAudioId = 29
		id1 = 0
		id2 = 0
		id3 = -1
		id4 = storyAudioId		
		
	elseif( storyId == "LOANOFFER" ) then
		local storyAudioId = 37		
		if( stageId == 5 ) then
			stageId = 2
		end
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId		
		
	elseif( storyId == "PAPJOBOFFER" ) then
		local storyAudioId = 30
		if( stageId == 5 ) then
			stageId = 2
		end
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId		
		
	elseif( storyId == "TRANSREQUEST" ) then
		local storyAudioId = 33
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId		
		
	elseif( storyId == "LOANREQUEST" ) then
		local storyAudioId = 34
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId	
		
	elseif( storyId == "RENEW" ) then
		local storyAudioId = 40
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId		
		
	elseif( storyId == "AT_RISK" ) then
		local storyAudioId = 41
		id1 = 0
		id2 = stageId
		id3 = -1
		id4 = storyAudioId		
		
	elseif( storyCategory == "INJURY" ) then
		local storyAudioId = 42
		local fixture = Engine.GetCurrentGameFixtureData()
		local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
		local homeAway = 00
		if( teamId == awayTeam ) then
			homeAway = 01
		end
		id1 = homeAway
		id2 = stageId
		id3 = -1
		id4 = storyAudioId
	elseif( storyCategory == "SUSPENSION" ) then
		local storyAudioId = 43
		local fixture = Engine.GetCurrentGameFixtureData()
		local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
		local homeAway = 00
		if( teamId == awayTeam ) then
			homeAway = 01
		end
		if( stageId > 0 or string.find( storyId, "CRISIS" ) ~= nil  ) then
			id1 = homeAway
			id2 = stageId
			id3 = -1
			id4 = storyAudioId	
		end
		
	elseif( storyCategory == "REVERSE-FIX" ) then
		local storyAudioId = 45
		local var = Engine.GetStoryVariable( story )
		local severityVar = tonumber( string.sub( var,1,2) )
		local lastResultVar = 00
		local lastResult = tonumber( string.sub( var,3,4) )
		if( lastResult == 00 ) then
			lastResultVar = 01
		elseif( lastResult == 02 ) then
			lastResultVar = 02
		end
		id1 = severityVar
		id2 = lastResultVar
		id3 = -1
		id4 = storyAudioId	
		
	elseif( storyCategory == "STREAK" ) then
		local storyAudioId = 46
		local var = Engine.GetStoryVariable( story )
		local numGames = tonumber( var )
		if( numGames >= 2 ) then
			local fixture = Engine.GetCurrentGameFixtureData()
			local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
			local storyType = "win"
			local homeAway = "home"
			local situation = 00
			if( string.find( storyId, "DRAW" ) ~= nil ) then
				storyType = "draw"
			else	
				if( string.find( storyId, "LOSS" ) ~= nil ) then
					storyType = "loss"
				end
			end
			if( teamId == awayTeam ) then
				homeAway = "away"
			end
			if( homeAway == "home" and storyType == "loss" ) then
				situation = 02
			elseif( homeAway == "home" and storyType == "draw" ) then
				situation = 04
			elseif( homeAway == "away" and storyType == "win" ) then
				situation = 01
			elseif( homeAway == "away" and storyType == "loss" ) then
				situation = 03
			elseif( homeAway == "away" and storyType == "draw" ) then
				situation = 05
			end
			if( storyType == "draw" ) then
				if( numGames > 5 ) then
					numGames = 6
				end
			else
				if( numGames > 10 ) then
					numGames = 11
				end
			end
			numGames = numGames - 2
			id1 = numGames
			id2 = situation
			id3 = -1
			id4 = storyAudioId	
		end
	elseif( storyCategory == "5GAMEFORM" ) then
		local storyAudioId = 47
		local fixture = Engine.GetCurrentGameFixtureData()
		local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
		local homeAway = 00
		if( teamId == awayTeam ) then
			homeAway = 01
		end
		local var = Engine.GetStoryVariable( story )
		local numPoints = tonumber( var )
		id1 = numPoints
		id2 = homeAway
		id3 = -1
		id4 = storyAudioId	
		
	elseif( storyId == "TOPSCORER" ) then
		local storyAudioId = 48
		local var = Engine.GetStoryVariable( story )
		local time = 02
		
		if( var == "secondmatch" ) then
			time = 00
		elseif( var == "thirdmatch" ) then
			time = 01
		elseif( var == "earlymid" ) then
			time = 03
		elseif( var == "latemid" ) then
			time = 04
		elseif( var == "late" ) then
			time = 05
		end
		
		local goals = stageId
		if( goals > 30 ) then
			if( goals > 60 ) then
				goals = 37
			elseif( goals > 55 ) then
				goals = 36
			elseif( goals > 50 ) then
				goals = 35
			elseif( goals > 45 ) then
				goals = 34
			elseif( goals > 40 ) then
				goals = 33
			elseif( goals > 35 ) then
				goals = 32
			else
				goals = 31
			end
		end		
		id1 = goals
		id2 = time
		id3 = -1
		id4 = storyAudioId	
		
	end
	-- TODO TALK TO PRESS
	--return audioId
	Engine.SetAudioIds( id1, id2, id3, id4 )
	--return id1, id2, id3, id4
end

function GetFormRatingAudioID( teamId, playerId )
	local formLevel = Engine.GetPlayerFormLevel( teamId, playerId )
	return GetFormRatingAudioIDByLevel( formLevel )
end

function GetFormRatingAudioIDByLevel( formLevel )
	local formId = -1
	if( formLevel == "VERY_BAD" ) then
		formId = 1
	elseif( formLevel == "BAD" ) then
		formId = 2
	elseif( formLevel == "NEUTRAL" ) then
		formId = 3
	elseif( formLevel == "GOOD" ) then
		formId = 4
	elseif( formLevel == "VERY_GOOD" ) then
		formId = 5
	end
	return formId
end
