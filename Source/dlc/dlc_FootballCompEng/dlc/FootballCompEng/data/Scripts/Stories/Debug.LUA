function DebugRunGetReasonForPlayerUpsetLeague()
	local userTeam = Engine.GetUserTeam()
	RequestTeamLeagueTable( userTeam, "DebugRunGetReasonForPlayerUpsetLeagueReceived" )
end

function DebugRunGetReasonForPlayerUpsetLeagueReceived()
	local numTeams = Engine.GetNumberOfTeamsInLeague()	
	local currTeamId = 0
	for teamCount = 1, numTeams do
		currTeamId = Engine.GetTeamIdByIndex( teamCount )
		DebugRunGetReasonForPlayerUpset( currTeamId )
	end --for teamCount = 1, numTeams do
end

function DebugRunGetReasonForPlayerUpset( teamId )
	local numPlayers = Engine.GetNumPlayers( teamId )
	teamId = Engine.StackRankTeamByOverall( teamId )	
	Engine.LogString( "\nPlayers Contract Happiness " .. Engine.GetTeamName( teamId ) .."\n" )
	Engine.LogString( "-------------------------------------------------------------\n" )
	for playerCount = 1, numPlayers do		
		local currPlayer = Engine.GetPlayer( teamId, playerCount )
		local oneClubPlayer = Engine.HasPlayerTrait( teamId, currPlayer, "ONE_CLUB_PLAYER" )		
		local reason = GetReasonForPlayerUpset( teamId, currPlayer )
		local wouldLeave = WouldPlayerEvenLeaveClub( teamId, currPlayer )
		if( reason == 0 ) then
			Engine.LogString( "[".. playerCount .."] " .. Engine.GetPlayerName( currPlayer ) .. " [ID: " .. currPlayer .. "] - Happy\n" )
		elseif( reason == 1 ) then
			Engine.LogString( "[".. playerCount .."] " .. Engine.GetPlayerName( currPlayer ) .. " [ID: " .. currPlayer .. "] - Team Under Achieving\n" )
		elseif( reason == 2 ) then
			Engine.LogString( "[".. playerCount .."] " .. Engine.GetPlayerName( currPlayer ) .. " [ID: " .. currPlayer .. "] - Too Big For Team\n" )
		else
			Engine.LogString( "[".. playerCount .."] " .. Engine.GetPlayerName( currPlayer ) .. " [ID: " .. currPlayer .. "] - Bad Wage\n" )
		end
		if( oneClubPlayer == true ) then
			Engine.LogString( "    - Is a One Club Player\n" )
		end
		if( wouldLeave == false ) then
			Engine.LogString( "    - Wouldn't leave the club\n" )
		end
	end
end

function DebugOutputLeagueInformation( teamId )
	RequestTeamLeagueTable( teamId, "DebugOutputTeamInfoGotLeague" )
end

function DebugOutputTeamInfoGotLeague()
	local numTeams = Engine.GetNumberOfTeamsInLeague()	
	local currTeamId = 0
	Engine.LogString( "\nTeam Info for League" )
	Engine.LogString( "----------------------\n" )
	for teamCount = 1, numTeams do
		currTeamId = Engine.GetTeamIdByIndex( teamCount )
		Engine.LogString( "TeamId: " .. currTeamId .. " " .. Engine.GetTeamName( currTeamId ) .. " Overall: " .. Engine.GetTeamOverall( currTeamId ) .. "\n" )
	end --for teamCount = 1, numTeams do
end

function DebugOutputLeagueAndNormalizationInformation( teamId )
	RequestTeamLeagueTable( teamId, "DebugOutputTeamInfoPlusNormalizationGotLeague" )
end

function DebugOutputTeamInfoPlusNormalizationGotLeague()
	local numTeams = Engine.GetNumberOfTeamsInLeague()	
	local currTeamId = 0
	Engine.LogString( "\nTeam Info for League" )
	Engine.LogString( "----------------------\n" )
	
	--GET MIN AND MAX
	local minVal = 100
	local maxVal = 0
	for teamCount = 1, numTeams do
		currTeamId = Engine.GetTeamIdByIndex( teamCount )
		local teamOverall = Engine.GetTeamOverall( currTeamId )
		if(teamOverall < minVal) then
			minVal = teamOverall
		end
		if(teamOverall>maxVal) then
			maxVal = teamOverall
		end
	end
	
	local delta = maxVal - minVal
	
	for teamCount = 1, numTeams do
		currTeamId = Engine.GetTeamIdByIndex( teamCount )
		local teamOverall = Engine.GetTeamOverall( currTeamId )
		local normalizedRating = teamOverall
		if(delta ~= 0) then
			normalizedRating = (100.0/delta)*(teamOverall-minVal)
		end
		Engine.LogString( "TeamId: " .. currTeamId .. " " .. Engine.GetTeamName( currTeamId ) .. " Overall: " .. Engine.GetTeamOverall( currTeamId ) .. " NormalizedRating: " .. normalizedRating .. "\n" )
	end --for teamCount = 1, numTeams do
end

function DebugOutputOFTFPlayers()
	Engine.ClearLastPlayerQuery()
	Engine.QueryPlayersByPotentialAndAge( 81, 99, 1, 19, 1000 )
	local numPlayers = Engine.GetNumPlayersFromQuery()
	local playerId = 0
	Engine.LogString( "\n\nOFTF - Higher Rated\n" )
	Engine.LogString( "-------------------\n" )
	for playerCount = 1, numPlayers do
		playerId = Engine.GetPlayerIdFromQueryByIndex( playerCount )
		Engine.LogString( "\nOFTF - (" .. playerId .. ") " .. Engine.GetPlayerName( playerId ) )
	end
	Engine.ClearLastPlayerQuery()
	Engine.QueryPlayersByPotentialAndAge( 71, 80, 1, 19, 1000 )
	numPlayers = Engine.GetNumPlayersFromQuery()
	playerId = 0
	Engine.LogString( "\n\nOFTF - Middle Rated\n" )
	Engine.LogString( "-------------------\n" ) 
	for playerCount = 1, numPlayers do
		playerId = Engine.GetPlayerIdFromQueryByIndex( playerCount )
		Engine.LogString( "\nOFTF - (" .. playerId .. ") " .. Engine.GetPlayerName( playerId ) )
	end
	Engine.ClearLastPlayerQuery()
	Engine.QueryPlayersByPotentialAndAge( 60, 70, 1, 19, 1000 )
	numPlayers = Engine.GetNumPlayersFromQuery()
	playerId = 0
	Engine.LogString( "\n\nOFTF - Lower Rated\n" )
	Engine.LogString( "-------------------\n" )
	for playerCount = 1, numPlayers do
		playerId = Engine.GetPlayerIdFromQueryByIndex( playerCount )
		Engine.LogString( "\nOFTF - (" .. playerId .. ") " .. Engine.GetPlayerName( playerId ) )
	end
end

function Debug_StatsReceived()
	local teamStatObj, numStats = Engine.GetTeamStatObj( 11 )
	local matchNumber = Engine.GetCPUFormMatchNumber( teamStatObj, numStats )
	--local formRating, avgRating = Engine.GetCPUPlayerForm( 11, 178224, teamStatObj, numStats, matchNumber )
	local formRating, avgRating = Engine.GetCPUPlayerFormByIndex( 11, 25, teamStatObj, numStats, matchNumber )
	Engine.LuaAssert( formRating )		
end

-- Have a soak.lua?  Only if we have a lot of soak functions
function Debug_StartSoak()
	local userTeam = Engine.GetUserTeam()
	local numPlayersOnTeam = Engine.GetNumPlayers( userTeam )	
	local playerIndex = 5
	StartStory_ForeignInvestor( userTeam )
	StartStory_FormChange( userTeam, Engine.GetPlayer( userTeam, playerIndex ), false, true )
	playerIndex = playerIndex + 1
	StartStory_FormChange( userTeam, Engine.GetPlayer( userTeam, playerIndex ), true, false )
	playerIndex = playerIndex + 1
	StartStory_PreSeasonForm( userTeam, Engine.GetPlayer( userTeam, playerIndex ) )
	playerIndex = playerIndex + 1
	StartStory_PlayerLoanListed( userTeam, Engine.GetPlayer( userTeam, playerIndex ) )
	playerIndex = playerIndex + 1
	StartStory_PlayerListed( userTeam, Engine.GetPlayer( userTeam, playerIndex ) )
	playerIndex = playerIndex + 1
	if( userTeam == 243 ) then
		StartStory_StupidBid( userTeam, 11, 54050, 100000000 )
	else
		StartStory_StupidBid( userTeam, 243, 158023, 100000000 )
	end
end

function TestNewsBuild()
	local selfish = Engine.HasPlayerTrait( 11, 241, "SELFISH" )
	local newNews = Engine.CreateNews( "CRITICIZE", "news_title_criticizes_notplayed_", 1 )
	Engine.AddParagraph( newNews, 1, "news_body_criticizes_generic_", 1 )
	if( selfish == true ) then
		Engine.AddParagraph( newNews, 1, "news_body_criticizes_selfish_", 1 )
	else
		Engine.AddParagraph( newNews, 1, "news_body_criticizes_team_", 1 )
	end
	PublishArticle( nil, newNews, "MAJOR", 11, 241 )
end

function DebugTestStackRank( teamId )
	local numPlayers = Engine.GetNumPlayers( teamId )
	teamId = Engine.StackRankTeamByStat( teamId, "GOALS" )	
	Engine.LogString( "\nStack Rank " .. Engine.GetTeamName( teamId ) .."\n" )
	Engine.LogString( "-------------------------------------------------------------\n" )
	for playerCount = 1, numPlayers do		
		local currPlayer = Engine.GetPlayer( teamId, playerCount )
		Engine.LogString( "[".. playerCount .."] " .. Engine.GetPlayerName( currPlayer ) .. " Val: " .. Engine.GetStackRankValueByIndex( teamId, playerCount ) .. "\n" )
	end
end

function DebugSetStoryStage( storyId, stage )
	local currentStory = Engine.GetStoryById( storyId )
	Engine.SetStoryStage( currentStory, stage )
end

function DebugSetStoryVariable( storyId, storyVar )
	local currentStory = Engine.GetStoryById( storyId )
	Engine.SetStoryVariable( currentStory, storyVar )
end

function TestBuildNews()
	local titleRandNo = Engine.GetRandomNumber( 1, 1 )
	local paraRandNo = Engine.GetRandomNumber( 1, 1 )
	local newNews = Engine.CreateNews( "TEST_NEWS", "Title_Adam_", titleRandNo )
	Engine.AddParagraphById( "TEST_NEWS", 50, "Para_Bell_", paraRandNo )
	Engine.AddParagraphById( "TEST_NEWS", 10, "Para_Marc_", paraRandNo )
	Engine.AddParagraph( newNews, 40, "Para_Blah_", paraRandNo )
	Engine.AddParagraph( newNews, 100, "Para_Blah2_", paraRandNo )
	Engine.SetNewsImportance( newNews, "MAJOR" )
	Engine.SetNewsTeamById( "TEST_NEWS", 11 )
	Engine.SetNewsPlayer( newNews, 54050 )
	Engine.SendNews( newNews )
end