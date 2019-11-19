-- "PREVIEW" news are blocked from C++ code in SendNews(), even if their logic is still kept in Lua code. So, they no longer get sent.

function TriggerNews( title, titleMin, titleMax, body, bodyMin, bodyMax, currentStory, bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
	local titleRandNo = Engine.GetRandomNumber( titleMin, titleMax )
	local bodyRandNo = Engine.GetRandomNumber( bodyMin, bodyMax )
	if( currentStory ~= NIL ) then
		local storyId = Engine.GetStoryId( currentStory )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		local playerTier = 5
		local teamOvr = 1
		if( storyPlayer > 0 ) then
			Engine.SetNewsPlayer( storyPlayer )
		end
		
		if( storyTeam > 0 ) then
			Engine.SetNewsTeam( storyTeam )
			teamOvr = Engine.GetTeamOverall( storyTeam )
		end
		local userTeam = Engine.GetUserTeam()
		if( storyTeam == userTeam ) then
			if( string.find( storyId, "FUTURE" ) ~= nil ) then 
				Engine.SetNewsType( "WORLD" )
			else
				Engine.SetNewsType( "CLUB" )
			end
			if( storyPlayer > 0 ) then
				local playerTeam = Engine.GetTeamIdFromPlayerId( storyPlayer )
				if( playerTeam == userTeam ) then
					local playerTier = Engine.GetPlayerTier( storyTeam, storyPlayer )
					if( playerTier < Tuning.NEWS.playerTier and teamOvr >= Tuning.NEWS.teamOvr ) then
						Engine.AddNewsType( "WORLD" )
					end
				else
					Engine.AddNewsType( "WORLD" )
				end
			end
		end
		Engine.UpdateStoryActivity( currentStory )
	end
	Engine.SetNewsHeadline( title, titleRandNo )
	Engine.SetNewsBody( body, bodyRandNo, bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
	Engine.SendNews()
end

function TriggerClubNews( title, titleMin, titleMax, body, bodyMin, bodyMax, currentStory, bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
	Engine.SetNewsTeam( Engine.GetUserTeam() )
	Engine.SetNewsType( "CLUB" )
	TriggerNews( title, titleMin, titleMax, body, bodyMin, bodyMax, currentStory, bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
end

function TriggerWorldNews( title, titleMin, titleMax, body, bodyMin, bodyMax, currentStory, bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
	Engine.SetNewsType( "WORLD" )
	TriggerNews( title, titleMin, titleMax, body, bodyMin, bodyMax, currentStory, bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
end

function TriggerTransferNews( title, titleMin, titleMax, body, bodyMin, bodyMax, currentStory,bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
	Engine.SetNewsType( "TRANSFER" )
	TriggerNews( title, titleMin, titleMax, body, bodyMin, bodyMax, currentStory, bodyParam1, bodyParam2, bodyParam3, bodyParam4 )
end

function PublishArticle( currentStory, news, importance, storyTeam, storyPlayer, pictureFocus )
	Engine.SetNewsImportance( news, importance )
	if( storyTeam ~= 0 ) then
		if( pictureFocus ~= nil ) then
			Engine.SetNewsType( "CLUB", news )
			Engine.SetNewsTeam( news, pictureFocus )
		else
			Engine.SetNewsTeam( news, storyTeam )
		end
	end
	if( storyPlayer ~= 0 ) then
		Engine.SetNewsPlayer( news, storyPlayer )
	end
	Engine.SendNews( news )
	if( currentStory ~= nil ) then
		Engine.UpdateStoryActivity( currentStory )
	end
end

function PublishToPreview( currentStory, stringId, variation, weight, replacer1, replacer2, replacer3 )
	if( weight == nil ) then
		weight = Tuning.NEWS.previewWeight
	end
	local newNews = nil
	local previewReady = Engine.DoesNewsExist( "PREVIEW" )
	local success = false
	if( previewReady == false ) then
		newNews = Engine.CreateNews( "PREVIEW", "", 1 )
		Engine.AddParagraph( newNews, weight, stringId, variation, replacer1, replacer2, replacer3 )
		success = true
	else
		newNews = Engine.GetNewsById( "PREVIEW" )
		local maxParagraphs = ( Engine.GetMaxParagraphs() - 1 ) -- Need one space for the base preview article
		local numParagraphs = Engine.GetNumParagraphsFromBuild( newNews )
		local buildLength = Engine.GetNewsBuildLength( newNews )
		if( numParagraphs < maxParagraphs and buildLength < Tuning.NEWS.maxPreviewBuildLength ) then
			Engine.AddParagraphById( "PREVIEW", weight, stringId, variation, replacer1, replacer2, replacer3 )
			success = true
		end
	end
	if( success == true ) then
		if( currentStory ~= nil ) then
			Engine.UpdateStoryActivity( currentStory )
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			if( storyPlayer > 0 ) then
				Engine.SetNewsPlayer( newNews, storyPlayer )
			end
		end
	end
end

function PublishToReview( currentStory, stringId, variation, weight, replacer1, replacer2, replacer3 )
	if( weight == nil ) then
		weight = Tuning.NEWS.reviewWeight
	end
	local newNews = nil
	local success = false
	local previewReady = Engine.DoesNewsExist( "REVIEW" )
	if( previewReady == false ) then
		newNews = Engine.CreateNews( "REVIEW", "", 1 )
		Engine.AddParagraph( newNews, weight, stringId, variation, replacer1, replacer2, replacer3 )
		success = true
	else
		newNews = Engine.GetNewsById( "REVIEW" )
		local maxParagraphs = ( Engine.GetMaxParagraphs() - 1 ) -- Need one space for the base preview article
		local numParagraphs = Engine.GetNumParagraphsFromBuild( newNews )
		local buildLength = Engine.GetNewsBuildLength( newNews )
		if( numParagraphs < maxParagraphs and buildLength < Tuning.NEWS.maxReviewBuildLength ) then
			Engine.AddParagraphById( "REVIEW", weight, stringId, variation, replacer1, replacer2, replacer3 )
			success = true
		end
	end
	if( success == true ) then
		if( currentStory ~= nil ) then
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			if( storyPlayer > 0 ) then
				Engine.SetNewsPlayer( newNews, storyPlayer )
			end
		end
	end
end
