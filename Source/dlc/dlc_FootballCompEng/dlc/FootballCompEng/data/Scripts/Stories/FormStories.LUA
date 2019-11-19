function ExamineFor_FormStories( teamId, cpuTeam, isCpu )
	local areaArray = { "ATT", "MID", "DEF", "GK" }
	Engine.PickTeam( teamId )
	local teamStatObj, numStats = Engine.GetTeamStatObj( teamId )
	local matchNumber = Engine.GetCPUFormMatchNumber( teamStatObj, numStats )
	local newsWeight = Tuning.FORMSTORIES.newsWeight
	local storyMade = false
	local formType = ""
	local playerId = 0
	local area = ""
	local userTeam = Engine.GetUserTeam()
	if( isCpu == true ) then
		userTeam = cpuTeam
	end
	
	for areaIndex = 1, 4 do
		local chosenPlayer = 0
		local chosenForm = ""
		local chosenArea = areaArray[ areaIndex ]
		local validPlayers = {}
		local playerCountHigh = Tuning.FORMSTORIES.playerCountHigh
		for playerCount = 1, playerCountHigh do
			local currentPlayer = Engine.GetPlayer( teamId, playerCount )
			local playerArea = Engine.GetPlayerPitchArea( teamId, currentPlayer )	
			if( playerArea == chosenArea ) then
				table.insert( validPlayers, currentPlayer )
			end
		end
		chosenPlayer, chosenForm = FormStories_GetBestPlayerAndFormType( teamId, validPlayers, teamStatObj, numStats, matchNumber )
		if( chosenPlayer > 0 ) then
			if( playerId > 0 )then
				local topOvr = Engine.GetPlayerOverall( playerId )
				local Ovr = Engine.GetPlayerOverall( chosenPlayer )
				if( Ovr > topOvr ) then
					formType = chosenForm
					playerId = chosenPlayer
					area = chosenArea
				end
			else
				formType = chosenForm
				playerId = chosenPlayer
				area = chosenArea
			end
		end
	end
	Engine.CleanupPickTeam()
	if( playerId > 0 ) then
		Engine.SetStringPlayers( playerId, playerId )
		Engine.SetStringTeams( teamId, userTeam )
		PublishToPreview( nil, "news_body_formstories_" .. area .. "_" .. formType .. "_", 4, newsWeight )
		newsWeight = newsWeight + Tuning.FORMSTORIES.newsWeightStep
		Engine.SetStringPlayers( playerId, playerId )
		Engine.SetStringTeams( userTeam, teamId )
		PublishToPreview( nil, "news_body_formstories_cpu_", 1, newsWeight )
	end
end

function FormStories_GetBestPlayerAndFormType( teamId, validPlayers, teamStatObj, numStats, matchNumber  )
	local bestPlayer = 0
	local bestFormType = ""
	local bestdifference = 0
	local numPlayers = # validPlayers
	if( numPlayers > 0 ) then
		for playerCount = 1, numPlayers do
			local playerId = validPlayers[ playerCount ]
			local formString, playerForm = Engine.GetCPUPlayerForm( teamId, playerId, teamStatObj, numStats, matchNumber )
			local formType = ""
			local difference = 0
			if( formString == "GOOD" or formString == "VERY_GOOD" )then
				formType = "good"
				difference = ( 100 - playerForm )
			elseif( formString == "BAD" or formString == "VERY_BAD"  )then
				formType = "bad"
			end
			if( formType ~= "" ) then
				if( bestPlayer == 0 ) then
					bestPlayer = playerId
					bestFormType = formType
					bestdifference = playerForm
				else
					if( formType == "bad" ) then
						success = true
					elseif( formType == "good" ) then
						if( difference < bestdifference ) then
							success = true
						end
					end
					if( success == true ) then
						bestFormType = formType
						bestdifference = difference
						bestPlayer = playerId
					end
				end
			end
		end
	end
	return bestPlayer, bestFormType
end