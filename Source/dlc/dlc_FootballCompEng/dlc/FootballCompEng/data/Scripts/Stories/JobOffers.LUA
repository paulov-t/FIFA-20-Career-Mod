----------------------------------------------------------------------
--INTERNATIONAL OFFERS
----------------------------------------------------------------------
function InternationalJob_OfferMade( teamId )
	local storyId = "INTJOBOFFER"
	local storyActive = Engine.IsStoryIDActive( "RENEW" )
	if( storyActive == false ) then
		StartStory_JobOffer( teamId, storyId )
	end
end

function InternationalJob_OfferAccepted( teamId )
	local storyId = "INTMANAGER"
	local userTeam = Engine.GetUserTeam()
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == true ) then
		storyId = "INTPLAYER"
	end
	local renewStoryId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( renewStoryId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( renewStoryId )
		local oldTeamId = tonumber( Engine.GetStoryVariable( currentStory ) )
		if( oldTeamId == teamId ) then
			InternationalJobRenewal_Renewed( teamId )
		else
			InternationalJobRenewal_Declined( oldTeamId )
		end
	else
		StartStory_NewJob( teamId, userTeam, storyId, false )
		
		JobOffer_Accepted( "INTJOBOFFER", teamId )
	end
end

function InternationalJob_OfferDeclined( teamId )
	local storyId = "INTJOBOFFER"
	local renewStoryId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( renewStoryId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( renewStoryId )
		local oldTeamId = tonumber( Engine.GetStoryVariable( currentStory ) )
		if( oldTeamId == teamId ) then
			InternationalJobRenewal_Declined( teamId )
		end
	else
		JobOffer_Declined( teamId, storyId )
	end
end

function InternationalJob_OfferStalled( teamId )
	local storyId = "INTJOBOFFER"
	local renewStoryId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( renewStoryId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( renewStoryId )
		local oldTeamId = tonumber( Engine.GetStoryVariable( currentStory ) )
		if( oldTeamId == teamId ) then
			InternationalJobRenewal_Stalled( teamId )
		end
	else
		JobOffer_Stalled( teamId, storyId )
	end
end

function InternationalJob_OfferRetracted( teamId ) --Trigger_InternationalJobOfferExpired
	local storyId = "INTJOBOFFER"
	local renewStoryId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( renewStoryId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( renewStoryId )
		local oldTeamId = tonumber( Engine.GetStoryVariable( currentStory ) )
		if( oldTeamId == teamId ) then
			local stage = Engine.GetStoryStage( currentStory )
			if( stage < 2 ) then
				InternationalJobRenewal_Retracted( teamId )
			end
		end
	else
		JobOffer_Retracted( teamId, storyId )
	end
end
----------------------------------------------------------------------
--JOB OFFERS DYNAMIC EVENTS
----------------------------------------------------------------------

function JobOffer_DynamicEvent( eventId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		if( eventId == "OFFERMADE" ) then
			JobOffer_News( eventId, storyId )
		elseif( eventId == "OFFERSMADE" ) then
			JobOffer_News( eventId, storyId )
		elseif( eventId == "DECLINED" ) then
			JobOffer_Declined_News( eventId, storyId )
		elseif( eventId == "STALLED" ) then
			JobOffer_Stalled_News( eventId, storyId )
		elseif( eventId == "RETRACTED" ) then
			JobOffer_Retracted_News( eventId, storyId )
		end
	end	
end

----------------------------------------------------------------------
--JOB OFFERS SORTING
----------------------------------------------------------------------
function JobOffer_OfferMade( teamId, isLoan )
	local storyId = "PAMJOBOFFER"
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == true ) then
		if( isLoan == true ) then
			storyId = "LOANOFFER"
		else
			storyId = "PAPJOBOFFER"
		end
	end
	StartStory_JobOffer( teamId, storyId )
end

function JobOffer_OfferAccepted( teamId )
	local storyId = "PAMJOBOFFER"
	local category = "JOBOFFER"
	local userTeam = Engine.GetUserTeam()
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == true ) then
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
			storyId = Engine.GetStoryId( currentStory )
		end
	end
	JobOffer_Accepted( storyId, teamId )
end

function JobOffer_OfferDeclined( teamId )
	local storyId = "PAMJOBOFFER"
	local category = "JOBOFFER"
	local userTeam = Engine.GetUserTeam()
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == true ) then
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
			storyId = Engine.GetStoryId( currentStory )
		end
	end
	JobOffer_Declined( teamId, storyId )
end

function JobOffer_OfferRetracted( teamId ) --  not ready yet
	local storyId = "PAMJOBOFFER"
	local category = "JOBOFFER"
	local userTeam = Engine.GetUserTeam()
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == true ) then
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
			storyId = Engine.GetStoryId( currentStory )
		end
	end
	JobOffer_Retracted( teamId, storyId )
end


----------------------------------------------------------------------
--FUNCTIONS
----------------------------------------------------------------------
function StartStory_JobOffer( teamId, storyId )
	local category = "JOBOFFER"
	local userTeam = Engine.GetUserTeam()
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == false ) then
		local storyPlayerId = 0
		local isPap = Engine.IsPlayAsPlayer()
		if( isPap == true ) then
			storyPlayerId = Engine.GetPlayAsPlayerID()
		end
		if( Engine.MarkPlayerForStory( userTeam, storyPlayerId, category, storyId ) == true ) then
			Engine.AddDateEvent( "OFFERMADE", 2, storyId )
			local currentStory = Engine.GetStoryById( storyId )
			Engine.SetStoryPriority( currentStory, 4 )
			Engine.SetStoryVariable( currentStory, teamId )
		end
	else
		Engine.AddDateEvent( "OFFERSMADE", 2, storyId )
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryVariable( currentStory, teamId )
		Engine.SetStoryStage( currentStory, 0 )
	end
end

function JobOffer_News( eventId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local stage = Engine.GetStoryStage( currentStory )
	if( stage <= 1 ) then
		local category = "JOBOFFER"
		local userTeam = Engine.GetUserTeam()
		local storyPlayerId = 0
		local stringId = "playeroffer_"
		local publishNews = true
		local teamId = tonumber( Engine.GetStoryVariable( currentStory ) )
		if( storyId == "INTJOBOFFER" ) then
			stringId = "internationaloffer_"
			local isPap = Engine.IsPlayAsPlayer()
			if( isPap == false ) then
				stringId = "manager_" .. stringId
			end
			publishNews = false
			local teamOvr = Engine.GetTeamOverall( teamId )
			if( teamOvr > Tuning.JOBOFFERS.teamOvrToPublish ) then
				publishNews = true
			end			
		elseif( storyId == "PAMJOBOFFER" ) then
			stringId = "manageroffer_"
		end
		local isPap = Engine.IsPlayAsPlayer()
		local type = ""
		local variations = 4
		if( isPap == true ) then
			storyPlayerId = Engine.GetPlayAsPlayerID()
			if( storyId == "LOANOFFER" ) then
				type = "loan"
				variations = 2
			end
		end
		if( eventId == "OFFERMADE" ) then
			Engine.SetStoryStage( currentStory, 1 )
		end
		local baseNewsWeight = Tuning.JOBOFFERS.baseNewsWeight
		if( publishNews == true ) then
			if( eventId == "OFFERMADE" ) then
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				local newNews = Engine.CreateNews( "JOB_OFFER", "news_title_" .. stringId .. type .. "offermade_", variations )
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				Engine.AddParagraph( newNews, baseNewsWeight + 1, "news_body_" .. stringId .. type .. "offermade_", variations )
				Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
				Engine.SetNewsBackgroundImage( "GLOBE", newNews )
				PublishArticle( currentStory, newNews, "MAJOR", userTeam, storyPlayerId, teamId )
			elseif( eventId == "OFFERSMADE" ) then
				local numOffers = 0
				if( storyId == "INTJOBOFFER" ) then
					numOffers = Engine.GetNumInternationalJobOffers()
				else
					numOffers = 1 --GetNumOffers()
				end
				if( numOffers > 0 ) then
					Engine.SetStringTeams( userTeam, teamId )
					Engine.SetStringPlayers( storyPlayerId )
					local newNews = Engine.CreateNews( "JOB_OFFER", "news_title_" .. stringId .. type .. "offermade_", variations )
					local newsWeight = baseNewsWeight
					local otherOffers = false
					for offerCount = 1, numOffers do
						local team = 0
						if( storyId == "INTJOBOFFER" ) then
							date, team = Engine.GetInternationalJobOfferByIndex( offerCount )
						else
							team = teamId --GetJobOfferByIndex( offerCount )
						end
						if( team == teamId ) then
							Engine.SetStringTeams( userTeam, team )
							Engine.SetStringPlayers( storyPlayerId )
							Engine.AddParagraph( newNews, baseNewsWeight + 1, "news_body_" .. stringId .. type .. "offermade_", variations )
						elseif( otherOffers == false ) then
							Engine.SetStringTeams( userTeam, team )
							Engine.SetStringPlayers( storyPlayerId )
							newsWeight = newsWeight - 1
							Engine.AddParagraph( newNews, newsWeight, "news_body_" .. stringId .. "otheroffersmade_", variations )
							otherOffers = true
						end
					end
					Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
					Engine.SetNewsBackgroundImage( "GLOBE", newNews )
					PublishArticle( currentStory, newNews, "MAJOR", userTeam, storyPlayerId, teamId )
				end
			end
		end
	end
end

function JobOffer_Accepted( storyId, teamId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local stringId = "playeroffer_"
		local scene = ""
		if( storyId == "INTJOBOFFER" ) then
			stringId = "manager_internationaloffer_"
			scene = "CM_News_ManagerActionPositive"
		elseif( storyId == "PAMJOBOFFER" ) then
			stringId = "manageroffer_"
		end
		local category = "JOBOFFER"
		local isPap = Engine.IsPlayAsPlayer()
		local type = ""
		local storyPlayerId = 0
		local variations = 4
		if( isPap == true ) then
			storyPlayerId = Engine.GetPlayAsPlayerID()
			if( storyId == "LOANOFFER" ) then
				type = "loan"
				variations = 2
				scene = ""
			end
		end
		local userTeam = Engine.GetUserTeam()
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStringTeams( userTeam, teamId )
		Engine.SetStringPlayers( storyPlayerId )
		local newNews = Engine.CreateNews( "JOB_OFFER", "news_title_" .. stringId .. type .. "offeraccepted_", variations )
		Engine.SetStringTeams( userTeam, teamId )
		Engine.SetStringPlayers( storyPlayerId )
		if( storyId == "PAPJOBOFFER" ) then
			local status, fee, wage, sellingTeam = Engine.GetPlayerTransferInfo( teamId, storyPlayerId )
			Engine.SetStringCurrency( fee )
		end
		Engine.AddParagraph( newNews, 2, "news_body_" .. stringId .. type .. "offeraccepted_", variations )
		local numStories = Engine.GetNumStoriesByCategory( "REQUEST" )
		if( numStories > 0 ) then
			local currentStory = Engine.GetStoryByCategoryAndIndex( "REQUEST", 1 )
			local requestStoryId = Engine.GetStoryId( currentStory )
			local requestStage = Engine.GetStoryStage( currentStory )
			if( requestStage > 1 ) then
				local playerRequest = "transferrequest_"
				if( requestStoryId == "LOANREQUEST" ) then
					playerRequest = "loanrequest_"
				else
					if( storyId ~= "PAPJOBOFFER" ) then
						if( requestStage == 5 ) then
							playerRequest = "loaninstead_"
						end
					end
				end
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				Engine.SetNewsHeadlineByObject( newNews, "news_title_request_offeraccepted_" .. playerRequest, 4 )
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				Engine.AddParagraph( newNews, 1, "news_body_request_offeraccepted_" .. playerRequest, 4 )
			end
		end
		if( stringId == "playeroffer_" ) then
			Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayerId, newNews )
			Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", userTeam, newNews )
		else
			if( storyId ~= "INTJOBOFFER" ) then
				Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
			end
		end
		Engine.SetNewsBackgroundImage( "CONTRACT", newNews )
		if( scene ~= "" ) then
			Engine.SetNewsCinematic( scene, newNews )
		end
		PublishArticle( currentStory, newNews, "MAJOR", userTeam, storyPlayerId, teamId )
		Engine.SetStoryStage( currentStory, 4 )
	end
end

function JobOffer_Declined( teamId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( stage ~= 2 ) then
			Engine.AddDateEvent( "DECLINED", 1, storyId )
			Engine.SetStoryVariable( currentStory, teamId )
			Engine.SetStoryStage( currentStory, 2 )
		end
	end
end

function JobOffer_Declined_News( eventId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( stage == 2 ) then
			local publishNews = true
			local teamId = tonumber( Engine.GetStoryVariable( currentStory ) )
			local stringId = "playeroffer_"
			if( storyId == "INTJOBOFFER" ) then
				stringId = "manager_internationaloffer_"
				publishNews = false
				local teamOvr = Engine.GetTeamOverall( teamId )
				if( teamOvr > Tuning.JOBOFFERS.teamOvrToPublish ) then
					publishNews = true
				end
			elseif( storyId == "PAMJOBOFFER" ) then
				stringId = "manageroffer_"
			end
			local isPap = Engine.IsPlayAsPlayer()
			local type = ""
			local variations = 4
			local storyPlayerId = 0
			if( isPap == true ) then
				storyPlayerId = Engine.GetPlayAsPlayerID()
				if( storyId == "LOANOFFER" ) then
					type = "loan"
					variations = 2
				end
			end
			local userTeam = Engine.GetUserTeam()
			local numOffer = 0
			if( storyId == "INTJOBOFFER" ) then
				numOffers = Engine.GetNumInternationalJobOffers()
			else
				numOffers = 1 --GetNumOffers()
			end
			if( numOffers == 0 ) then
				Engine.SetStoryStage( currentStory, 5 )
			end
			local baseNewsWeight = Tuning.JOBOFFERS.baseNewsWeight
			if( publishNews == true ) then
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				local newsWeight = baseNewsWeight
				local newNews = Engine.CreateNews( "JOB_OFFER", "news_title_" .. stringId .. type .. "offerrejected_", variations )
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				Engine.AddParagraph( newNews, newsWeight, "news_body_" .. stringId .. type .. "offerrejected_", variations )
				if( numOffers ~= 0 ) then
					local otherOffers = false
					for offerCount = 1, numOffers do
						local team = 0
						if( storyId == "INTJOBOFFER" ) then
							date, team = Engine.GetInternationalJobOfferByIndex( offerCount )
						else
							team = teamId --GetJobOfferByIndex( offerCount )
						end
						if( team ~= teamId ) then
							if( otherOffers == false ) then
								newsWeight = newsWeight - 1
								Engine.SetStringTeams( userTeam, team )
								Engine.SetStringPlayers( storyPlayerId )
								Engine.AddParagraph( newNews, newsWeight, "news_body_" .. stringId .. "otheroffers_", 4 )
								otherOffers = true
							end
						end
					end
				end
				PublishArticle( currentStory, newNews, "MAJOR", userTeam, storyPlayerId, teamId )
			end
		end
	end
end

function JobOffer_Stalled( teamId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( stage ~= 3 and stage ~= 2 ) then
			Engine.AddDateEvent( "STALLED", 1, storyId )
			Engine.SetStoryStage( currentStory, 3 )
			Engine.SetStoryVariable( currentStory, teamId )
		end
	end
end

function JobOffer_Stalled_News( eventId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( stage == 3 ) then
			local teamId = tonumber( Engine.GetStoryVariable( currentStory ) )
			local publishNews = true
			local stringId = "playeroffer_"
			if( storyId == "INTJOBOFFER" ) then
				stringId = "manager_internationaloffer_"
				publishNews = false
				local teamOvr = Engine.GetTeamOverall( teamId )
				if( teamOvr > Tuning.JOBOFFERS.teamOvrToPublish ) then
					publishNews = true
				end
			elseif( storyId == "PAMJOBOFFER" ) then
				stringId = "manageroffer_"
			end
			if( publishNews == true ) then
				local isPap = Engine.IsPlayAsPlayer()
				local type = ""
				local variations = 4
				local storyPlayerId = 0
				if( isPap == true ) then
					storyPlayerId = Engine.GetPlayAsPlayerID()
					if( storyId == "LOANOFFER" ) then
						type = "loan"
						variations = 2
					end
				end
				local userTeam = Engine.GetUserTeam()
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				local newNews = Engine.CreateNews( "JOB_OFFER", "news_title_" .. stringId .. type .. "offerstalled_", variations )
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				Engine.AddParagraph( newNews, 2, "news_body_" .. stringId .. type .. "offerstalled_", variations )
				PublishArticle( currentStory, newNews, "MAJOR", userTeam, storyPlayerId, teamId )
			end
		end
	end
end

function JobOffer_Retracted( teamId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( stage < 1 ) then
			Engine.SetStoryStage( currentStory, 1 )
			Engine.SetStoryVariable( currentStory, teamId )
			Engine.AddDateEvent( "RETRACTED", 1, storyId )
		end
	end
end

function JobOffer_Retracted_News( eventId, storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local stringId = "playeroffer_"
		local publishNews = true
		local currentStory = Engine.GetStoryById( storyId )
		local teamId = tonumber( Engine.GetStoryVariable( currentStory ) )
		if( storyId == "INTJOBOFFER" ) then
			stringId = "manager_internationaloffer_"
			publishNews = false
			local teamOvr = Engine.GetTeamOverall( teamId )
			if( teamOvr > Tuning.JOBOFFERS.teamOvrToPublish ) then
				publishNews = true
			end
		elseif( storyId == "PAMJOBOFFER" ) then
			stringId = "manageroffer_"
		end
		local userTeam = Engine.GetUserTeam()
		local category = "JOBOFFER"
		local stage = Engine.GetStoryStage( currentStory )
		if( stage == 1 ) then
			if( publishNews == true ) then
				local isPap = Engine.IsPlayAsPlayer()
				local type = ""
				local variations = 4
				local storyPlayerId = 0
				if( isPap == true ) then
					storyPlayerId = Engine.GetPlayAsPlayerID()
					if( storyId == "LOANOFFER" ) then
						type = "loan"
						variations = 2
					end
				end
				if( storyId == "INTJOBOFFER" ) then
					numOffers = Engine.GetNumInternationalJobOffers()
				else
					numOffers = 0 --GetNumOffers()
				end
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				local newNews = Engine.CreateNews( "JOB_OFFER", "news_title_" .. stringId .. type .. "offerretracted_", variations )
				Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", teamId, newNews )
				Engine.SetNewsBackgroundImage( "EMPTY_STADIUM", newNews )
				Engine.SetStringTeams( userTeam, teamId )
				Engine.SetStringPlayers( storyPlayerId )
				Engine.AddParagraph( newNews, 2, "news_body_" .. stringId .. type .. "offerretracted_", variations )
				PublishArticle( currentStory, newNews, "MAJOR", userTeam, storyPlayerId, teamId )
			end
			if( numOffers == 0 ) then
				Engine.EndStoryId( storyId, false )
			end
		end
	end
end

function ManagerJobOffers_PostMatch( matchResult, gametype, playType )
	local storyId = "INTJOBOFFER"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( stage >= 4 ) then
			Engine.EndStoryId( storyId, false )
		else
			Engine.SetStoryStage( currentStory, 0 )
		end
	end
end

-----------------------------------------------------------------------
function StartStory_InternationalJobRenewal( teamId )
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == false ) then
		local storyId = "RENEW"
		local category = "RENEW"
		local userTeam = Engine.GetUserTeam()
		if( Engine.MarkPlayerForStory( userTeam, 0, category, storyId ) == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			Engine.SetStoryPriority( currentStory, 4 )
			Engine.SetStoryVariable( currentStory, teamId )
			Engine.SetStringTeams( teamId )
			local newNews = Engine.CreateNews( "RENEW", "news_title_internationalrenewal_jobreview_", 4 )
			Engine.SetStringTeams( teamId )
			Engine.AddParagraph( newNews, 1, "news_body_internationalrenewal_jobreview_", 4 )
			PublishArticle( currentStory, newNews, "MAJOR", teamId, 0 )
			Engine.SetStoryStage( currentStory, 1 )
		end
	end
end

function InternationalJobRenewal_Renewed( teamId )
	local storyId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStringTeams( teamId )
		local newNews = Engine.CreateNews( "RENEW", "news_title_internationalrenewal_renewed_", 4 )
		Engine.SetStringTeams( teamId )
		Engine.AddParagraph( newNews, 1, "news_body_internationalrenewal_renewed_", 4 )
		Engine.SetNewsCinematic ( "CM_News_ManagerActionPositive", newNews ) 
		PublishArticle( currentStory, newNews, "MAJOR", teamId, 0 )
		Engine.SetStoryStage( currentStory, 2 )
		Engine.KillStoryAfterMatch( currentStory )
	end
end

function InternationalJobRenewal_Fired( teamId )
	local storyId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStringTeams( teamId )
		local newNews = Engine.CreateNews( "RENEW", "news_title_internationalrenewal_fired_", 4 )
		Engine.SetStringTeams( teamId )
		Engine.AddParagraph( newNews, 1, "news_body_internationalrenewal_fired_", 4 )
		Engine.SetNewsCinematic ( "CM_News_ManagerActionNegative", newNews ) 
		PublishArticle( currentStory, newNews, "MAJOR", teamId, 0 )
		Engine.SetStoryStage( currentStory, 3 )
		Engine.KillStoryAfterMatch( currentStory )
	end
end

function InternationalJobRenewal_Retracted( teamId )
	local storyId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStringTeams( teamId )
		local newNews = Engine.CreateNews( "RENEW", "news_title_internationalrenewal_retracted_", 4 )
		Engine.SetStringTeams( teamId )
		Engine.AddParagraph( newNews, 1, "news_body_internationalrenewal_retracted_", 4 )
		PublishArticle( currentStory, newNews, "MAJOR", teamId, 0 )
		Engine.SetStoryStage( currentStory, 4 )
		Engine.KillStoryAfterMatch( currentStory )
	end
end

function InternationalJobRenewal_Declined( teamId )
	local storyId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStringTeams( teamId )
		local newNews = Engine.CreateNews( "RENEW", "news_title_internationalrenewal_declined_", 4 )
		Engine.SetStringTeams( teamId )
		Engine.AddParagraph( newNews, 1, "news_body_internationalrenewal_declined_", 4 )
		PublishArticle( currentStory, newNews, "MAJOR", teamId, 0 )
		Engine.SetStoryStage( currentStory, 5 )
		Engine.KillStoryAfterMatch( currentStory )
	end
end

function InternationalJobRenewal_Stalled( teamId )
	local storyId = "RENEW"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStringTeams( teamId )
		local newNews = Engine.CreateNews( "RENEW", "news_title_internationalrenewal_Stalled_", 4 )
		Engine.SetStringTeams( teamId )
		Engine.AddParagraph( newNews, 1, "news_body_internationalrenewal_Stalled_", 4 )
		PublishArticle( currentStory, newNews, "MAJOR", teamId, 0 )
		Engine.SetStoryStage( currentStory, 1 )
	end
end

--------------------------------------------------------------------------
--INTERNATIONAL JOB RUMOURS
--------------------------------------------------------------------------
function ExamineFor_InternationalManagerRumours( months )	
	if( Engine.GetUserInternationalTeam() == -1 ) then		
		local monthsToStart = Tuning.JOBOFFERS.monthsToStart
		if( months == monthsToStart ) then
			local chance = Tuning.JOBOFFERS.chance
			if( RollPercentageDice( chance ) == true ) then
				local userTeam = Engine.GetUserTeam()
				local popularity = Engine.GetManagerPopularity()
				if( popularity > Tuning.JOBOFFERS.minManagerPopularity ) then
					local numoffers = Engine.GetNumPotentialInternationalJobOffers()
					if( numoffers > 0 ) then
						Engine.SetStringTeams( userTeam )
						local newNews = Engine.CreateNews( "JOB_OFFER", "news_title_internationalmanagerrumours_", 4 )
						Engine.SetNewsCinematic ( "CM_News_ManagerActionPositive", newNews ) 
						Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
						Engine.SetNewsBackgroundImage( "GLOBE", newNews )
						Engine.SetStringTeams( userTeam )
						Engine.AddParagraph( newNews, 1, "news_body_internationalmanagerrumours_intro_", 4 )
						local offerArray = { Engine.GetPotentialInternationalJobOffers() }
						if( numoffers > 5 ) then
							numoffers = 5
						end
						for offerCount = 1, numoffers do
							local teamId = offerArray[ offerCount ]
							if( teamId > 0 ) then
								Engine.SetStringTeams( userTeam, teamId )
								if( offerCount == 1 ) then
									Engine.AddParagraph( newNews, 1, "news_body_internationalmanagerrumours_firstrumour_", 4 )
								else
									Engine.AddParagraphForceVariation( newNews, 1, "news_body_internationalmanagerrumours_otherumours_", offerCount - 1 )
								end
							end
						end
						PublishArticle( nil, newNews, "MAJOR", userTeam, 0 )				
					end
				end
			end
		end
	end
end