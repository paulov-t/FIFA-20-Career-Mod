function ExamineFor_MoveRequest( isLoan )
	local storyId = "TRANSREQUEST"
	if( isLoan == true ) then
		storyId = "LOANREQUEST"
	end
	Engine.EndStoryCategory( "REQUEST", false )
	Engine.AddDateEvent( "REQUEST", 2, storyId )
end

function MoveRequest_DynamicEvent( eventId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		if( eventId == "DECISION" ) then
			MoveRequest_DecisionNews( eventId, storyId )
		elseif( string.find( eventId, "_OFFER" ) ~= nil ) then
			MoveRequest_OfferNews( eventId, storyId )
		elseif( eventId == "WINDOWCLOSE" ) then
			MoveRequest_TransferWindowOver( eventId, storyId )
		end
	else
		if( eventId == "REQUEST" ) then
			StartStory_MoveRequest( storyId )
		end
	end
end

function StartStory_MoveRequest( storyId )
	local category = "REQUEST"
	local userTeam = Engine.GetUserTeam()
	local playerId = Engine.GetPlayAsPlayerID()
	if( Engine.MarkPlayerForStory( userTeam, playerId, category, storyId ) == true ) then
		local numTransferReq, numLoanReq, numWithdraws = Engine.GetNumTransferRequests()
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 2 )
		local request = "transfer"
		if( storyId == "LOANREQUEST" ) then
			request = "loan"
		end
		local success = true
		local request = "transfer"
		if( storyId == "LOANREQUEST" ) then
			request = "loan"
			if( numLoanReq > 1 ) then
				success = false
			end
		else
			if( numTransferReq > 1 ) then
				success = false
			end
		end
		if( success == true ) then
			Engine.SetStringTeams( userTeam )
			Engine.SetStringPlayers( playerId )
			local newNews = Engine.CreateNews( "REQUEST", "news_title_request_requestmade_" .. request .. "_", 2 )
			Engine.SetStringTeams( userTeam )
			Engine.SetStringPlayers( playerId )
			Engine.AddParagraph( newNews, Tuning.REQUEST.newsWeight, "news_body_request_requestmade_" .. request .. "_", 2 )
			local playerTier = Engine.GetPlayerTier( userTeam, playerId )
			local topTier = Tuning.REQUEST.topTier
			Engine.SetStringTeams( userTeam )
			Engine.SetStringPlayers( playerId )
			if( playerTier < topTier ) then
				Engine.AddParagraph( newNews, Tuning.REQUEST.newsWeight, "news_body_request_requestmade_" .. request .. "_toptier_", 2 )
				Engine.SetStoryStage( currentStory, 1 )
			else
				Engine.AddParagraph( newNews, Tuning.REQUEST.newsWeight, "news_body_request_requestmade_" .. request .. "_lowtier_", 2 )
				Engine.SetStoryStage( currentStory, 2 )
			end
			PublishArticle( currentStory, newNews, "MAJOR", userTeam, playerId )
		else
			local playerTier = Engine.GetPlayerTier( userTeam, playerId )
			local topTier = Tuning.REQUEST.topTier
			if( playerTier < topTier ) then
				Engine.SetStoryStage( currentStory, 1 )
			else
				Engine.SetStoryStage( currentStory, 2 )
			end
		end
	end
end

function MoveRequest_ManagerDecision( allow, loanInstead )
	if( allow == false ) then
		local category = "REQUEST"
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
			local storyId = Engine.GetStoryId( currentStory )
			if( loanInstead == false ) then
				Engine.SetStoryVariable( currentStory, "DENIED" )
			else
				Engine.SetStoryVariable( currentStory, "LOANEDINSTEAD" )
			end
			Engine.AddDateEvent( "DECISION", 1, storyId )
		end
	end
end

function MoveRequest_Listed( teamId, playerId, leagueId, type)
	local category = "REQUEST"
	local numStories = Engine.GetNumStoriesByCategory( category )
	if( numStories > 0 ) then
		local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		if( storyPlayer == playerId ) then
			local storyId = Engine.GetStoryId( currentStory )
			Engine.SetStoryVariable( currentStory, type )
			Engine.AddDateEvent( "DECISION", 1, storyId )
		end
	end
end

function MoveRequest_DecisionNews( eventId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local request = "transfer_"
	local decision = "requestaccepted_"
	local storyVar = Engine.GetStoryVariable( currentStory )
	local userTeam = Engine.GetUserTeam()
	local playerId = Engine.GetPlayAsPlayerID()
	local success = true
	if( storyId == "LOANREQUEST" ) then
		request = "loan_"
	end
	if( storyVar == "DENIED" ) then
		decision = "denied_"
	elseif( storyVar == "LOANEDINSTEAD" ) then
		decision = "loanedinstead_"
		request = ""
	end
	local numTransferReq, numLoanReq, numWithdraws = Engine.GetNumTransferRequests()
	if( decision == "requestaccepted_" ) then
		Engine.SetStoryStage( currentStory, 3 )
	elseif( decision == "loanedinstead_" ) then
		Engine.SetStoryStage( currentStory, 5 )
	else
		Engine.SetStoryStage( currentStory, 4 )
		Engine.KillStoryAfterMatch( currentStory )
		if( storyId == "LOANREQUEST" ) then
			if( numLoanReq > 1 ) then
				success = false
			end
		else
			if( numTransferReq > 1 ) then
				success = false
			end
		end
	end
	if( success == true ) then
		Engine.SetStringTeams( userTeam )
		Engine.SetStringPlayers( playerId )
		local newNews = Engine.CreateNews( "REQUEST", "news_title_request_" .. request .. decision, 2 )
		Engine.SetStringTeams( userTeam )
		Engine.SetStringPlayers( playerId )
		Engine.AddParagraph( newNews, Tuning.REQUEST.newsWeight, "news_body_request_" .. request .. decision, 2 )
		PublishArticle( currentStory, newNews, "MAJOR", userTeam, playerId )
	end
end

function MoveRequest_OfferReceived( teamId, isLoan )
	local category = "REQUEST"
	local numStories = Engine.GetNumStoriesByCategory( category )
	if( numStories > 0 ) then
		local idName = "TRANS_OFFER"
		if( isLoan == true ) then
			idName = "LOAN_OFFER"
		end
		local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
		local storyId = Engine.GetStoryId( currentStory )
		MoveRequest_OfferNews( idName, storyId, teamId )
		Engine.SetStoryVariable( currentStory, teamId )
		local userTeam = Engine.GetUserTeam()
		local playerId = Engine.GetPlayAsPlayerID()
		local newStoryId = ""
		if( isLoan == true ) then
			newStoryId = "LOANOFFER"
		else
			newStoryId = "PAPJOBOFFER"
		end
		if( Engine.MarkPlayerForStory( userTeam, playerId, "JOBOFFER", newStoryId ) == true ) then
			local currentStory = Engine.GetStoryById( newStoryId )
			Engine.SetStoryStage( currentStory, 1 )
		end
	end
end

function MoveRequest_OfferNews( eventId, storyId, offerTeam )
	local currentStory = Engine.GetStoryById( storyId )
	--local offerTeam = tonumber( Engine.GetStoryVariable( currentStory ) )
	local stage = Engine.GetStoryStage( currentStory )
	local userTeam = Engine.GetUserTeam()
	local playerId = Engine.GetPlayAsPlayerID()
	local wrongOffer = false
	local type = "transfer_"
	if( eventId == "LOAN_OFFER" ) then
		type = "loan_"
	end
	if( stage == 5 ) then
		actual = "loanlistedinstead_"
		if( storyId == "TRANSREQUEST" ) then
			wrongOffer = true
		end
	end
	Engine.SetStringTeams( userTeam, offerTeam )
	Engine.SetStringPlayers( playerId )
	local newNews = Engine.CreateNews( "REQUEST", "news_title_request_offerreceived_" .. type, 2 )
	Engine.SetStringTeams( userTeam, offerTeam )
	Engine.SetStringPlayers( playerId )
	Engine.AddParagraph( newNews, Tuning.REQUEST.newsWeight, "news_body_request_offerreceived_" .. type, 2 )
	if( wrongOffer == true ) then
		Engine.SetStringTeams( userTeam, offerTeam )
		Engine.SetStringPlayers( playerId )
		Engine.AddParagraph( newNews, Tuning.REQUEST.newsWeight, "news_body_request_offerreceived_" .. actual, 2 )
	end
	PublishArticle( nil, newNews, "MAJOR", userTeam, playerId )
end

function MoveRequest_TransferWindowClose( numDays )
	if( numDays == 0 ) then
		local category = "REQUEST"
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
			local storyId = Engine.GetStoryId( currentStory )
			Engine.AddDateEvent( "WINDOWCLOSE", 1, storyId )
		end
	end
end

function MoveRequest_TransferWindowOver( eventId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local userTeam = Engine.GetUserTeam()
	local playerId = Engine.GetPlayAsPlayerID()
	local request = "transferrequest_"
	if( storyId == "LOANREQUEST" ) then
		request = "loanrequest_"
	end
	Engine.SetStringTeams( userTeam )
	Engine.SetStringPlayers( playerId )
	local newNews = Engine.CreateNews( "REQUEST", "news_title_request_endofwindow_" .. request, 2 )
	Engine.AddParagraph( newNews, Tuning.REQUEST.newsWeight, "news_body_request_endofwindow_" .. request, 2 )
	PublishArticle( currentStory, newNews, "MAJOR", userTeam, playerId )
	Engine.EndStoryId( storyId, false )
end
