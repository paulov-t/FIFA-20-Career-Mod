function ExamineFor_NewSigningCompleted( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue, realDate )
	local userTeam = Engine.GetUserTeam()
	if( buyingTeam == userTeam ) then
		if( transfer == "REAL_WORLD" ) then
			StartStory_NewSigning(  userTeam, sellingTeam, playerId )
		end
	end
end

function ExamineFor_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
	local playerTier = Engine.GetPlayerTier( sellingTeamId, playerId )
	if( playerTier <= Tuning.NEGOTIATE.maxCounterOfferPlayerTier ) then
		if( counterOfferNum == 1 ) then
			StartStory_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired )
		else
			CounterOffer_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
		end
	end
end

function StartStory_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired )
	local category = "NEGOTIATE"
	local numStories = Engine.GetNumStoriesByCategory( category )
	local success = true
	if( numStories > 0 ) then
		for storyCount = 1, numStories do
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			if( storyPlayer == playerId ) then
				success = false
			end
		end
	end
	if( success == true ) then
		local storyId = category .. "_" .. numStories
		local negotiateCooldown = Tuning.NEGOTIATE.negotiateCooldown
		if( Engine.MarkPlayerForStory( sellingTeamId, playerId, category, storyId, negotiateCooldown ) == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			Engine.UpdateStoryActivity( currentStory )
			Engine.SetStoryVariable( currentStory, buyingTeamId )
		end
	end
end

function DynamicEvent_CounterOffer( eventId, storyId )
	if( string.find( storyId, "NEGOTIATE" ) ~= nil ) then
		if( eventId == "NEG_ENDWINDOW" ) then
			EndOfWindowCounterOffer_DynamicEvent( storyId )
		end
	end
end

function RejectOffer_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
	local category = "NEGOTIATE"
	local numStories = Engine.GetNumStoriesByCategory( category )
	if( numStories > 0 ) then
		for storyCount = 1, numStories do
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			if( storyPlayer == playerId ) then
				Engine.SetStringTeams( sellingTeamId, buyingTeamId )
				Engine.SetStringPlayers( playerId )
				Engine.SetStringCurrency( moneyDesired )
				local newNews = Engine.CreateNews( "NEGOTIATE", "news_title_negotiate_reject_", 1 )
				Engine.SetStringTeams( sellingTeamId, buyingTeamId )
				Engine.SetStringPlayers( playerId )
				Engine.SetStringCurrency( moneyDesired )
				Engine.AddParagraph( newNews, Tuning.NEGOTIATE.newsWeight, "news_body_negotiate_reject_", 1 )
				Engine.SetNewsForegroundImage( "LEFT", "CLUB_CREST", sellingTeamId, newNews )
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId, newNews )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", buyingTeamId, newNews )
				Engine.SetNewsBackgroundImage( "WRITING_LETTER", newNews )
				PublishArticle( currentStory, newNews, "MAJOR", sellingTeamId, storyPlayer )
				Engine.SetStoryStage( currentStory, 1 )
				Engine.KillStoryAfterMatch( currentStory )
				break
			end
		end
	end
end

function AcceptOffer_CounterOffer( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue )
	local category = "NEGOTIATE"
	local numStories = Engine.GetNumStoriesByCategory( category )
	if( numStories > 0 ) then
		for storyCount = 1, numStories do
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			if( storyPlayer == playerId ) then
				local involved1 = Engine.IsPlayerInvolvedInStoryCategory( playerId, "OVERPRICED" )
				local involved2 = Engine.IsPlayerInvolvedInStoryCategory( playerId, "UNDERPRICED" )
				if( involved1 == false and involved2 == false ) then
					Engine.SetStringTeams( sellingTeam, buyingTeam )
					Engine.SetStringPlayers( storyPlayer )
					Engine.SetStringMultiCurrency( price, wage )
					local newNews = Engine.CreateNews( "NEGOTIATE", "news_title_negotiate_accept_", 1 )
					Engine.SetStringTeams( sellingTeam, buyingTeam )
					Engine.SetStringPlayers( storyPlayer )
					Engine.SetStringMultiCurrency( price, wage )
					Engine.AddParagraph( newNews, Tuning.NEGOTIATE.newsWeight, "news_body_negotiate_accept_", 1 )
					Engine.SetNewsForegroundImage( "LEFT", "CLUB_CREST", sellingTeam, newNews )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId, newNews )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", buyingTeam, newNews )
					Engine.SetNewsBackgroundImage( "MONEY", newNews )
					PublishArticle( currentStory, newNews, "MAJOR", sellingTeam, playerId )
				end
				Engine.SetStoryStage( currentStory, 2 )
				Engine.KillStoryAfterMatch( currentStory )
				break
			end
		end
	end
end

function CounterOffer_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
	local category = "NEGOTIATE"
	local numStories = Engine.GetNumStoriesByCategory( category )
	for storyCount = 1, numStories do
		local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		if( storyPlayer == playerId ) then
			local stage = Engine.GetStoryStage( currentStory )
			if( stage == 0 ) then
				Engine.SetStoryStage( currentStory, 3 )
				Engine.KillStoryAfterMatch( currentStory )
				Engine.SetStringTeams( sellingTeamId, buyingTeamId )
				Engine.SetStringPlayers( playerId )
				Engine.SetStringMultiCurrency( moneyOffered, moneyDesired )
				local newNews = Engine.CreateNews( "NEGOTIATE", "news_title_negotiate_CPUcounter_", 1 )
				Engine.SetStringTeams( sellingTeamId, buyingTeamId )
				Engine.SetStringPlayers( playerId )
				Engine.SetStringMultiCurrency( moneyOffered, moneyDesired )
				Engine.SetNewsForegroundImage( "LEFT", "CLUB_CREST", sellingTeamId, newNews )
				Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId, newNews )
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", buyingTeamId, newNews )
				Engine.SetNewsBackgroundImage( "WRITING_LETTER", newNews )
				Engine.AddParagraph( newNews, Tuning.NEGOTIATE.newsWeight, "news_body_negotiate_CPUcounter_", 1 )
				PublishArticle( currentStory, newNews, "MAJOR", sellingTeamId, storyPlayer )
				break
			end
		end
	end
end

function EndOfWindow_CounterOffer( numDays )
	if( numDays == 0 ) then
		local category = "NEGOTIATE"
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			for storyCount = numStories, 1, -1 do
				local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
				local storyId = Engine.GetStoryId( currentStory )
				Engine.AddDateEvent( "NEG_ENDWINDOW", 1, storyId )
			end
		end
	end
end

function EndOfWindowCounterOffer_DynamicEvent( storyId )
	Engine.EndStoryId( storyId, false )
end