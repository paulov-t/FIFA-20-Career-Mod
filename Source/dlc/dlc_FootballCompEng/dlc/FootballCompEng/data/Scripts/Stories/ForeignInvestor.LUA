function ExamineFor_ForeignInvestor( months )
	local storyId = "INVESTOR"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == false ) then
		local userTeam = Engine.GetUserTeam()
		local leagueId = Engine.GetLeagueId( userTeam )
		local canTakeOver = CanClubBeTakenOver( leagueId )
		if( canTakeOver == true ) then
			local month1 = Tuning.INVESTOR.monthLow
			local month2 = Tuning.INVESTOR.monthHigh
			if( months >= month1 and months <= month2 ) then
				local season = Engine.GetSeasonCount()
				local chance = Tuning.INVESTOR.chanceDefault
				if( season == 1 ) then
					chance = Tuning.INVESTOR.chanceOneSeason
				elseif( season == 2 ) then
					chance = Tuning.INVESTOR.chanceTwoSeasons
				end
				local success = RollPercentageDice( chance )
				if( success ) then
					RequestLeagueForInvestor()
				end --if( success ) then
			end --if( months >= month1 and months <= month2 ) then		
		end --if( canTakeOver == true ) then
	end --if( storyActive == false ) then
end

function StartStory_ForeignInvestor( teamId )
	local category = "INVESTOR"
	local storyId = "INVESTOR"
	local userTeam = Engine.GetUserTeam()
	local dateEvent = "INVESTOR_ST1"
	if( teamId == userTeam ) then
		storyId = "INVESTOR_USR"
		dateEvent = "INVESTOR_MONEY"
	end
	if( Engine.MarkPlayerForStory( teamId, 0, category, storyId ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 3 )
		Engine.AddDateEvent( dateEvent, 1, storyId )
	end --if( Engine.MarkPlayerForStory( chosenTeam, 0, category, storyId ) == true ) then
end

function RequestLeagueForInvestor()
	local userTeam = Engine.GetUserTeam()
	local leagueId = Engine.GetLeagueId( userTeam )
	local nationId = Engine.GetLeagueNationId( leagueId )
	-- Do if check here of valid leagues for foreign ownership
	ExamineLeagueForInvestor()
end

function ExamineLeagueForInvestor()
	local numTeams = Engine.GetNumberOfTeamsInLeague()	
	local currTeamId = 0
	local teamData = {}
	local currTotal = 0
	local currOvr = 0
	local numPlayers = 0
	local teamBudget = 0
	for teamCount = 1, numTeams do
		currTeamId = Engine.GetTeamIdByIndex( teamCount )
		if( currTeamId ~= -1 ) then
			currOvr = Engine.GetTeamOverall( currTeamId )
			currTotal = currTotal + currOvr
			numPlayers = Engine.GetNumPlayers( currTeamId, true )
			teamBudget = Engine.GetTeamBudget( currTeamId )
			teamData[ teamCount ] = {}
			teamData[ teamCount ][ 0 ] = currTeamId
			teamData[ teamCount ][ 1 ] = currOvr
			teamData[ teamCount ][ 2 ] = numPlayers
			teamData[ teamCount ][ 3 ] = teamBudget		
			if( isFinal == false and IsLogging() ) then
				Print( "[" .. teamCount .. "]" .. Engine.GetTeamName( currTeamId ) .. " - Overall: " .. currOvr .. " - Players: " .. numPlayers .. " - Budget: " .. teamBudget )
			end
		end -- if( currTeamId ~= -1 ) then
	end --for teamCount = 1, numTeams do
	
	if( currTotal > 0 ) then		
		local avgLeagueRtg = currTotal / numTeams
		
		local avgRange = 2
		local lowRange = avgLeagueRtg - avgRange
		local highRange = avgLeagueRtg + avgRange
		Print( "Avg: " .. avgLeagueRtg .. " Low: " .. lowRange .. " High: " .. highRange )
		
		local matchingTeams = {}
		local matchingCount = 0
		local maxPlayers = 42
		local richValue = Tuning.INVESTOR.alreadyRichBudget
		local lessThanMax = maxPlayers - 3 -- was 5
		local userTeam = Engine.GetUserTeam()
		local hasRoom = false
		local inRange = false
		local isUserTeam = false
		local alreadyRich = false
		for teamCount = 1, numTeams do
			hasRoom = ( teamData[ teamCount ][ 2 ] < lessThanMax )	-- plenty of room on team
			if( hasRoom ) then 
				inRange = ( teamData[ teamCount ][ 1 ] >= lowRange and teamData[ teamCount ][ 1 ] <= highRange )
				isUserTeam = ( teamData[ teamCount ][ 0 ] == userTeam )
				alreadyRich = ( teamData[ teamCount ][ 3 ] >= richValue )
				if( inRange == true and isUserTeam == false and alreadyRich == false ) then
					matchingCount = matchingCount + 1
					matchingTeams[ matchingCount ] = teamData[ teamCount ][ 0 ]
					Print( "Matching Team: " .. Engine.GetTeamName( matchingTeams[ matchingCount ] ) .. " Overall: '" .. teamData[ teamCount ][ 1 ] )
				end --if( teamData[ teamCount ][ 1 ] >= lowRange and teamData[ teamCount ][ 1 ] <= highRange ) then
			end
		end --for teamCount = 1, numTeams do

		if( matchingCount > 0 ) then
			local randNo = Engine.GetRandomNumber( 1, matchingCount )
			local chosenTeam = matchingTeams[ randNo ]
			Print( "Chosen Team: ", Engine.GetTeamName( chosenTeam ) )
			StartStory_ForeignInvestor( chosenTeam )
		end -- if( matchingCount > 0 ) then
	end --if( currTotal > 0 ) then
end

function InvestorDynamicEvent( eventId, linkId )
	local storyId = linkId
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		Engine.SetStringTeam( storyTeam )
		if( eventId == "INVESTOR_ST1" ) then
			Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", storyTeam )
			Engine.SetNewsBackgroundImage( "MONEY" )
			--TriggerNews( "news_title_investor_stage1_", 1, 10, "news_body_investor_stage1_", 1, 5, currentStory )
			local nextEventLow = Tuning.INVESTOR.stage2_Delay_Low
			local nextEventHigh = Tuning.INVESTOR.stage2_Delay_High
			local randDays = Engine.GetRandomNumber( nextEventLow, nextEventHigh )
			Engine.AddDateEvent( "INVESTOR_MONEY", randDays, storyId )
			-- Add more stages
		elseif( eventId == "INVESTOR_MONEY" ) then
			local userTeam = Engine.GetUserTeam()
			local newBudget = Tuning.INVESTOR.userBudget
			local variation = 1
			local sum = Tuning.INVESTOR.cpuBudget
			if( storyTeam == userTeam ) then
				local teamBudget = Engine.GetTeamBudget( storyTeam )
				variation = 5
				if( teamBudget > newBudget ) then
					newBudget = ( teamBudget * 2 )
				else
					newBudget = ( teamBudget + newBudget )
				end
				local isPap = Engine.IsPlayAsPlayer()
				if( isPap == true ) then
					Engine.GenerateTransferActivityForTeam( storyTeam )
				end
				if( newBudget > sum ) then
					newBudget = sum
				end
			else
				newBudget = sum -- 100million for now
				Engine.GenerateTransferActivityForTeam( storyTeam )	-- Fix pacing
			end
			Engine.UpdateTeamBudget( storyTeam, newBudget )
			Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", storyTeam )
			Engine.SetNewsBackgroundImage( "MONEY" )
			--TriggerNews( "news_title_investor_stagemoney_", 1, 10, "news_body_investor_stagemoney_", variation, 5, currentStory )
			Engine.SetStoryVariable( currentStory, "0" )
		end --if( event == "INVESTOR_ST1" ) then 
	end -- if( storyActive == true ) then
end

function InvestorClubPurchase( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue )
	local category = "INVESTOR"
	local numStories = Engine.GetNumStoriesByCategory( category )
	if( numStories > 0 ) then
		for storyCount = numStories, 1, -1 do
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
			local storyId = Engine.GetStoryId( currentStory )
			local storyActive = Engine.IsStoryIDActive( storyId )
			if( storyActive == true ) then
				local currentStory = Engine.GetStoryById( storyId )
				local storyTeam = Engine.GetStoryTeam( currentStory )
				if( buyingTeam == storyTeam ) then
					local contractInYears = contract / 12
					Engine.SetStringTeams( storyTeam, sellingTeam )
					Engine.SetStringPlayer( playerId, 1 )
					Engine.SetStringCurrency( price )
					local storyVar = Engine.GetStoryVariable( currentStory )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
					Engine.SetNewsBackgroundImage( "CONTRACT" )
					if( storyVar == "0" ) then
						--TriggerNews( "news_title_investor_firstplayer_", 1, 10, "news_body_investor_firstplayer_", 1, 5, currentStory, contractInYears )
						Engine.SetStoryVariable( currentStory, "1" )
					elseif( storyVar == "1" ) then
						--TriggerNews( "news_title_investor_secondplayer_", 1, 10, "news_body_investor_secondplayer_", 1, 5, currentStory )
						Engine.SetStoryVariable( currentStory, "2" )
					else
						--TriggerNews( "news_title_investor_GenericPurchase_", 1, 10, "news_body_investor_GenericPurchase_", 1, 5, currentStory, contractInYears )
						if( storyVar == "2" ) then
							Engine.SetStoryVariable( currentStory, "3" )
						elseif( storyVar == "3" ) then
							Engine.SetStoryVariable( currentStory, "4" )
						elseif( storyVar == "4" ) then
							Engine.SetStoryVariable( currentStory, "5" )
						else
							Engine.EndStoryId( storyId )					
						end				
					end --if( storyVar == "0" ) then
				end --if( buyingTeam == storyTeam ) then
			end --if( storyActive == true ) then
		end
	end
end

function CanClubBeTakenOver( leagueId )
	local canTakeOver = false
	local validLeagues = Tuning.INVESTOR.validLeagues
	local numLeagues = #validLeagues	
	for leagueCount = 1, numLeagues do
		if( leagueId == validLeagues[ leagueCount ] ) then
			canTakeOver = true
			break
		end
	end --for leagueCount = 1, numLeagues do
	return canTakeOver
end
