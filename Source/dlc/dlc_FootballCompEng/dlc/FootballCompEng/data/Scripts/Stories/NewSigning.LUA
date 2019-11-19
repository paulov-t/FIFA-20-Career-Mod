function StartStory_NewSigning( userTeam, sellingTeam, playerId )
	local category = "SIGNING"
	local baseStoryId = "NEWSIGNING_"
	local numStories = Engine.GetNumStoriesByCategory( category )
	local storyId = baseStoryId .. numStories
	local newSigningCooldown = Tuning.NEWSIGNING.newSigningCooldown
	if( Engine.MarkPlayerForStory( userTeam, playerId, category, storyId, newSigningCooldown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 1 )		
		local fixture = Engine.GetCurrentGameFixtureData()
		if( fixture ~= nil ) then
			if( Engine.IsDayOfFixture( fixture ) == true ) then
				NewSigningPreMatch( 0, gametype, fixture )
			end
		end
	end
end

function NewSigningPreMatch( numDays, gametype, fixture )
	if( numDays == 0 ) then
		local category = "SIGNING"
		if( string.find( gametype, "FRIENDLY" ) == nil ) then
			local numStories = Engine.GetNumStoriesByCategory( category )
			local topPlayer = 0
			local topTeam = 0
			local newNews = nil
			local topStory = nil
			local topCpuStory = nil
			local topCpuPlayer = 0
			local topCpuTeam = 0
			local type = 0
			if( numStories > 0 ) then
				local extraPlayerCount = 1
				for storyCount = 1, numStories do
					local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
					local storyId = Engine.GetStoryId( currentStory )
					local stage = Engine.GetStoryStage( currentStory )
					local storyTeam = Engine.GetStoryTeam( currentStory )
					local storyPlayer = Engine.GetStoryPlayer( currentStory )
					local playerTier = Engine.GetPlayerTier( storyTeam, storyPlayer )
					if( string.find( storyId, "_CPU_" ) ~= nil ) then
						local Ovr = Engine.GetPlayerOverall( storyPlayer )
						if( Ovr > Tuning.NEWSIGNING.minPlayerOvr )then
							if( stage <= 2 ) then
								if( topCpuPlayer > 0 )then
									local topOvr = Engine.GetPlayerOverall( topCpuPlayer )
									if( Ovr > topOvr ) then
										topCpuPlayer = storyPlayer
										topCpuTeam = storyTeam
										topCpuStory = currentStory
									end
								else
									topCpuPlayer = storyPlayer
									topCpuTeam = storyTeam
									topCpuStory = currentStory
									type = type + 2
								end
							end
						end
					end
					if( stage < 2 ) then  -- only user player on this condition, because the match is not friendly; see ExamineFor_CPUNewSigning()
						if( string.find( storyId, "_CPU_" ) == nil ) then
							local newsPlayer = storyPlayer
							Engine.SetStoryStage( currentStory, 2 )
							Engine.UpdateStoryActivity( currentStory )
							if( playerTier < 4 ) then
								if( newNews == nil ) then
									Engine.SetStringTeams( storyTeam )
									Engine.SetStringPlayers( newsPlayer )
									newNews = Engine.CreateNews( "NEWSIGNING_PREMATCH", "news_title_newsigning_prematch_", 4 )
									Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", newsPlayer, newNews )
									Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam, newNews )
									Engine.SetNewsBackgroundImage( "FANS_CELEBRATING", newNews )
									Engine.SetNewsCinematic( "CM_News_PlayerActionPositive", newNews )
								end
								if( topPlayer == 0 ) then
									topPlayer = storyPlayer
									topTeam = storyTeam
									topStory = currentStory
									type = type + 1
								else
									local Ovr = Engine.GetPlayerOverall( storyPlayer )
									local topOvr = Engine.GetPlayerOverall( topPlayer )
									if( Ovr > topOvr ) then
										newsPlayer = topPlayer
										topPlayer = storyPlayer
										topStory = currentStory
										Engine.SetStringPlayers( topPlayer )
										Engine.SetNewsHeadlineByObject( newNews, "news_title_newsigning_prematch_", 4 )
										Engine.SetNewsPlayer( newNews, topPlayer )
									end
									if( extraPlayerCount < 5 ) then
										local status, fee, wage, sellingTeam = Engine.GetPlayerTransferInfo( storyTeam, newsPlayer )
										Engine.SetStringTeams( storyTeam, sellingTeam )
										Engine.SetStringPlayers( newsPlayer )
										Engine.SetStringCurrency( fee )
										Engine.AddParagraphForceVariation( newNews, 1, "news_body_newsigning_prematch_extra_", extraPlayerCount )
										extraPlayerCount = extraPlayerCount + 1
									else
										break
									end
								end
								local newSigningProgressDelay = Tuning.NEWSIGNING.newSigningProgressDelay
								local playerTier = Engine.GetPlayerTier( storyTeam, topPlayer )
								if( playerTier < 2 ) then
									Engine.AddDateEvent( "NEWSIGNING", newSigningProgressDelay, storyId )
								end
							end
						end
					elseif( stage == 3 or stage == 4 or stage == 5 ) then
						if( stage == 3 ) then
							Engine.UpdateStoryActivity( currentStory )
						else
							if( stage == 4 ) then
								if( Engine.GetPercentageThroughSeason() > Tuning.NEWSIGNING.percentageThroughSeason ) then
									Engine.SetStoryStage( currentStory, 5 )
									Engine.UpdateStoryActivity( currentStory )
								end
							end
							local chance = RollPercentageDice( Tuning.NEWSIGNING.chancePercentage )
							if( chance == true ) then
								Engine.UpdateStoryActivity( currentStory )
							end
						end
					end
				end

				------------------ News
				if( type == 2 ) then  -- only one CPU player when type is 2
					topPlayer = topCpuPlayer
					topTeam = topCpuTeam
					topStory = topCpuStory
					Engine.SetStringTeams( topTeam )
					Engine.SetStringPlayers( topPlayer )						
					newNews = Engine.CreateNews( "NEWSIGNING_PREMATCH_CPU", "news_title_newsigning_prematch_", 4 )
					Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", topPlayer, newNews )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", topTeam, newNews )
					Engine.SetNewsBackgroundImage( "FANS_CELEBRATING", newNews )
					Engine.SetNewsCinematic( "CM_News_PlayerActionPositive", newNews )
					local status, fee, wage, sellingTeam = Engine.GetPlayerTransferInfo( topTeam, topPlayer )
					local userTeam = Engine.GetUserTeam()	
					Engine.SetStringTeams( topTeam, sellingTeam, userTeam )
					Engine.SetStringPlayers( topPlayer )
					-- PublishToPreview( nil, "news_body_newsigning_prematch_debut_cpu_", 1, 800 )
				end
				if( newNews ~= nil ) then
					local status, fee, wage, sellingTeam = Engine.GetPlayerTransferInfo( topTeam, topPlayer )
					local variation = 4
					local body = "news_body_newsigning_prematch_"
					if( sellingTeam < 1 or sellingTeam == 112264 ) then
						body = "news_body_newsigning_prematch_untested_"
					elseif( sellingTeam == 111592 ) then
						body = "news_body_newsigning_prematch_freeagent_"
						variation = 2
					end
					Engine.SetStringTeams( topTeam, sellingTeam )
					Engine.SetStringPlayers( topPlayer )
					Engine.SetStringCurrency( fee )
					Engine.AddParagraph( newNews, 5, body, variation )
					if( type == 3 ) then  -- CPU and player stories both present when this variable 3
						local stage = Engine.GetStoryStage( topCpuStory )
						if( stage <= 2 ) then
							local status, fee, wage, sellingTeam = Engine.GetPlayerTransferInfo( topCpuTeam, topCpuPlayer )
							local userTeam = Engine.GetUserTeam()	
							Engine.SetStringTeams( topCpuTeam, sellingTeam, userTeam )
							Engine.SetStringPlayers( topCpuPlayer )
							Engine.AddParagraph( newNews, 4, "news_body_newsigning_prematch_debut_cpu_", 1 )
						end
					end
					PublishArticle( topStory, newNews, "MAJOR", topTeam, topPlayer )				
				end
			end
		else
			local numStories = Engine.GetNumStoriesByCategory( category )
			if( numStories > 0 ) then
				for storyCount = 1, numStories do
					local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
					local stage = Engine.GetStoryStage( currentStory )
					if( stage == 0 ) then
						Engine.UpdateStoryActivity( currentStory )
					end
				end
			end
		end
	end
end
--
--function DetermineStoryUserOrCpu( category, numStories )
--	local val = ""
--	for storyCount = 1, numStories do
--		local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
--		local storyId = Engine.GetStoryId( currentStory )
--		if( string.find( storyId, "_CPU_" ) ~= nil ) then
--			if( val == "" ) then
--				val = "cpu"
--			elseif( val == "user" ) then
--				val = "both"
--				break
--			end
--		else
--			if( val == "" ) then
--				val = "user"
--			elseif( val == "cpu" ) then
--				val = "both"
--				break
--			end
--		end
--	end
--	return val
--end
--
--function NewSigningPostMatch( matchResult, gametype, playType ) --Post User Game
--	local category = "SIGNING"
--	local numStories = Engine.GetNumStoriesByCategory( category )
--	local val = DetermineStoryUserOrCpu( category, numStories )
--	local topPlayer = 0
--	local topTeam = 0
--	local newsWeight = Tuning.NEWSIGNING.postMatchNewsWeight
--	local addPar = false
--	local topCpuPlayer = 0
--	local topCpuTeam = 0
--	local topCpuStory = nil
--	local counter = 0
--	local cpuCounter = 0
--	local goalStory = 0
--	local redStory = 0
--	local injuryStory = 0
--	local publishCounter = 0
--	if( numStories > 0 ) then
--		local debutPlayers = {}
--		for storyCount = 1, numStories do
--			local cpuStory = false
--			local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
--			local storyId = Engine.GetStoryId( currentStory )
--			local stage = Engine.GetStoryStage( currentStory )
--			local var = Engine.GetStoryVariable( currentStory )
--			local storyPlayer = Engine.GetStoryPlayer( currentStory )
--			local storyTeam = Engine.GetStoryTeam( currentStory )
--			local goalCount = 0
--			local redCount = 0
--			if( stage == 6 or stage == 7 ) then
--				Engine.SetStoryStage( currentStory, 4 )
--				Engine.UpdateStoryActivity( currentStory )
--			elseif( stage > 7 ) then
--				Engine.SetStoryStage( currentStory, 5 )
--				Engine.UpdateStoryActivity( currentStory )
--			end
--			if( string.find( storyId, "_CPU_" ) ~= nil and val == "both" ) then
--				cpuStory = true
--				if( topCpuPlayer > 0 )then
--					local Ovr = Engine.GetPlayerOverall( storyPlayer )
--					local topOvr = Engine.GetPlayerOverall( topCpuPlayer )
--					if( Ovr > topOvr ) then
--						topCpuPlayer = storyPlayer
--						topCpuTeam = storyTeam
--						topCpuStory = currentStory
--					end
--				else
--					topCpuPlayer = storyPlayer
--					topCpuTeam = storyTeam
--					topCpuStory = currentStory
--				end
--			else
--				counter = counter + 1
--				if( topPlayer == 0 ) then
--					topPlayer = storyPlayer
--					topTeam = storyTeam
--				else
--					local Ovr = Engine.GetPlayerOverall( storyPlayer )
--					local topOvr = Engine.GetPlayerOverall( topPlayer )
--					if( Ovr > topOvr ) then
--						topPlayer = storyPlayer
--						topTeam = storyTeam
--					end
--				end
--			end
--			
--			--First Appearance			
--			if( cpuStory ~= true ) then
--				if( Engine.DidPlayerPlay( storyTeam, storyPlayer, matchResult ) == true ) then
--					newsWeight = newsWeight - 1
--					if( counter == 1 ) then  -- either only User, or first of the only CPU stories
--						Engine.SetStringTeams( storyTeam )
--						Engine.SetStringPlayers( storyPlayer )
--						if( gametype == "FRIENDLY" ) then
--							if( stage < 1 ) then
--								PublishToReview( currentStory, "news_body_newsigning_postmatch_debut_friendly_", 4, newsWeight )
--								publishCounter = publishCounter + 1
--								Engine.SetStoryStage( currentStory, 1 )
--							end
--						else
--							if( stage <= 2 ) then
--								PublishToReview( currentStory, "news_body_newsigning_postmatch_debut_", 4, newsWeight )
--								publishCounter = publishCounter + 1
--								local area = Engine.GetPlayerPitchArea( storyTeam, storyPlayer )
--								local position = Engine.GetPlayerPosition( storyTeam, storyPlayer )
--								if( area == "ATT" or position == "CAM" ) then
--									Engine.SetStoryStage( currentStory, 3 )
--								else
--									Engine.SetStoryStage( currentStory, 4 )
--								end
--								if( Engine.DoesNewsExist( "REVIEW" ) == true ) then
--									Engine.SetStringTeams( topTeam )
--									Engine.SetStringPlayers( topPlayer )
--									local review = Engine.GetNewsById( "REVIEW" )
--									if( gametype ~= "FRIENDLY" ) then
--										if( val ~= "cpu" )then
--											Engine.SetNewsHeadlineByObject( review, "news_title_newsigning_postmatch_played_", 4 )
--											Engine.SetNewsPlayer( review, topPlayer )
--										end
--									end
--								end
--							end
--						end
--					elseif( counter == 2 ) then
--						local status, fee, wage = Engine.GetPlayerTransferInfo( storyTeam, storyPlayer )
--						Engine.SetStringTeams( storyTeam )
--						Engine.SetStringPlayers( storyPlayer )
--						Engine.SetStringCurrency( fee )
--						if( gametype == "FRIENDLY" ) then
--							if( stage < 1 ) then
--								PublishToReview( nil, "news_body_newsigning_postmatch_debut_friendly_extra_", 4, newsWeight )
--								Engine.SetStoryStage( currentStory, 1 )
--							end
--						else
--							if( stage <= 2 ) then
--								PublishToReview( nil, "news_body_newsigning_postmatch_debut_extra_", 4, newsWeight )
--								local area = Engine.GetPlayerPitchArea( storyTeam, storyPlayer )
--								local position = Engine.GetPlayerPosition( storyTeam, storyPlayer )
--								if( area == "ATT" or position == "CAM" ) then
--									Engine.SetStoryStage( currentStory, 3 )
--								else
--									Engine.SetStoryStage( currentStory, 4 )
--								end
--							end
--						end
--					else
--						if( gametype == "FRIENDLY" ) then
--							if( stage < 1 ) then
--								addPar = true
--								Engine.SetStoryStage( currentStory, 1 )
--							end
--						elseif( stage <= 2 ) then
--							addPar = true
--							local area = Engine.GetPlayerPitchArea( storyTeam, storyPlayer )
--							local position = Engine.GetPlayerPosition( storyTeam, storyPlayer )
--							if( area == "ATT" or position == "CAM" ) then
--								Engine.SetStoryStage( currentStory, 3 )
--							else
--								Engine.SetStoryStage( currentStory, 4 )
--							end
--							table.insert( debutPlayers, storyPlayer )
--						end
--					end
--					-- In Game Actions
--					if( gametype ~= "FRIENDLY" ) then
--						-- Subbed On
--						if( counter == 1 ) then
--							if( stage <= 2 ) then
--								if( Engine.DidPlayerGetSubbedOn( storyTeam, storyPlayer, matchResult ) == true ) then
--									Engine.SetStringTeams( storyTeam )
--									Engine.SetStringPlayers( storyPlayer )
--									newsWeight = newsWeight - 1
--									PublishToReview( nil, "news_body_newsigning_postmatch_subbedon_", 4, newsWeight )
--								end
--							end
--						end
--						-- Goal Count
--						local numIncidents = Engine.GetNumberOfIncidents( matchResult )
--						for incidentCount = 1, numIncidents do
--							local type = Engine.GetIncidentTypeByIndex( matchResult, incidentCount )
--							local incident = Engine.GetMatchIncidentByIndex( matchResult, incidentCount )
--							local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, incident )
--							if( type == "GOAL" ) then
--								if(  playerId == storyPlayer ) then
--									goalCount = goalCount + 1
--								end
--						-- Red Card Count
--							elseif( type == "CARD" ) then
--								local cardType = Engine.GetCardType( incident )
--								if( cardType == "RED" ) then
--									if(  playerId == storyPlayer ) then
--										redCount = redCount + 1
--									end
--								end
--							end
--						end
--						-- Goal News
--						if( goalCount > 0 ) then
--							local replacer1 = "locme_news_goals_goal"
--							if( goalCount == 2 ) then
--								replacer1 = "locme_news_goals_brace"
--							elseif( goalCount == 3 ) then
--								replacer1 = "locme_news_goals_hattrick"
--							elseif( goalCount > 3 ) then
--								replacer1 = "locme_news_goals_goals"
--							end
--							Engine.SetStringTeams( storyTeam )
--							Engine.SetStringPlayers( storyPlayer )
--							newsWeight = newsWeight - 1
--							if( stage <= 2 ) then
--								if( counter == 1 ) then
--									PublishToReview( nil, "news_body_newsigning_postmatch_goal_", 4, newsWeight, replacer1 )
--								end
--								Engine.SetStoryStage( currentStory, 4 )
--								Engine.SetStoryVariable( currentStory, var .. "4" )
--							elseif( stage == 3 ) then
--								if( string.find( var, "4" ) == nil ) then
--									if( goalStory < 1 ) then
--										PublishToReview( nil, "news_body_newsigning_postmatch_firstgoal_", 4, newsWeight, replacer1 )
--										local review = Engine.GetNewsById( "REVIEW" )
--										local scene = "CM_News_PlayerActionPositive"
--										if( Engine.GetRandomNumber( 1, 2 ) == 2 ) then
--											scene = "CM_News_PlayerPromo"
--										end
--										Engine.SetNewsCinematic( scene, review )
--										goalStory = 1
--									end
--									Engine.SetStoryStage( currentStory, 4 )
--									Engine.UpdateStoryActivity( currentStory )
--									Engine.SetStoryVariable( currentStory, var .. "4" )
--								end
--							end
--						end
--						-- Red Card News
--						if( redCount > 0 ) then
--							newsWeight = newsWeight - 1
--							Engine.SetStringTeams( storyTeam )
--							Engine.SetStringPlayers( storyPlayer )
--							if( stage <= 2 ) then
--								if( counter == 1 ) then
--									PublishToReview( nil, "news_body_newsigning_postmatch_red_", 4, newsWeight )
--								end
--								Engine.SetStoryVariable( currentStory, var .. "5" )
--							elseif( stage > 2 ) then
--								if( string.find( var, "5" ) == nil ) then
--									--Start Here ******************
--									if( redStory < 1 ) then
--										PublishToReview( nil, "news_body_newsigning_postmatch_firstred_", 4, newsWeight )
--										redStory = 1
--									end
--									Engine.UpdateStoryActivity( currentStory )
--									Engine.SetStoryVariable( currentStory, var .. "5" )
--								end
--							end
--						end
--						-- Injured News
--						Engine.SetStringTeams( storyTeam )
--						Engine.SetStringPlayers( storyPlayer )
--						if( Engine.DidPlayerGetInjured( storyTeam, storyPlayer, matchResult ) == true ) then
--							newsWeight = newsWeight - 1
--							if( stage <= 2 ) then
--								if( counter == 1 ) then
--									PublishToReview( nil, "news_body_newsigning_postmatch_injured_", 4, newsWeight )
--								end
--								Engine.SetStoryVariable( currentStory, var .. "6" )
--							elseif( stage > 2 ) then
--								if( string.find( var, "6" ) == nil ) then
--									Engine.UpdateStoryActivity( currentStory )
--									if( injuryStory < 1 ) then
--										PublishToReview( nil, "news_body_newsigning_postmatch_firstinjured_", 4, newsWeight )
--										injuryStory = 1
--									end
--									Engine.SetStoryVariable( currentStory, var .. "6" )
--								end
--							end
--						elseif( Engine.DidPlayerGetSubbedOff( storyTeam, storyPlayer, matchResult ) == true ) then
--							if( counter == 1 ) then
--								if( stage <= 2 ) then
--									newsWeight = newsWeight - 1
--									PublishToReview( nil, "news_body_newsigning_postmatch_subbedoff_", 4, newsWeight )
--								end
--							end
--						end
--						-- Form News
--						if( counter == 1 ) then
--							if( Engine.DoesNewsExist( "REVIEW" ) == true ) then
--								if( stage <= 2 ) then
--									local playerRating = Engine.GetPlayerMatchRating( storyTeam, storyPlayer, matchResult )
--									local goodFormRating = Tuning.NEWSIGNING.goodFormRating
--									local poorFormRating = Tuning.NEWSIGNING.poorFormRating
--									Engine.SetStringTeams( storyTeam )
--									Engine.SetStringPlayers( storyPlayer )
--									local review = Engine.GetNewsById( "REVIEW" )
--									if( playerRating >= goodFormRating ) then
--										newsWeight = newsWeight - 1
--										if( val ~= "cpu" )then
--											Engine.SetNewsHeadlineByObject( review, "news_title_newsigning_postmatch_played_well_", 4 )
--											Engine.SetNewsPlayer( review, storyPlayer )
--										end
--										Engine.SetStringTeams( storyTeam )
--										Engine.SetStringPlayers( storyPlayer )
--										Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, review )
--										Engine.SetNewsBackgroundImage( "GRAPH_RISING", review )
--										PublishToReview( nil, "news_body_newsigning_postmatch_goodform_", 4, newsWeight )
--									elseif( playerRating <= poorFormRating ) then
--										newsWeight = newsWeight - 1
--										if( val ~= "cpu" )then
--											Engine.SetNewsHeadlineByObject( review, "news_title_newsigning_postmatch_played_poorly_", 4 )
--											Engine.SetNewsPlayer( review, storyPlayer )
--										end
--										Engine.SetStringTeams( storyTeam )
--										Engine.SetStringPlayers( storyPlayer )
--										Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, review )
--										Engine.SetNewsBackgroundImage( "GRAPH_DROPPING", review )
--										PublishToReview( nil, "news_body_newsigning_postmatch_poorform_", 4, newsWeight )
--									else
--										if( val ~= "cpu" )then
--											Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, review )
--											Engine.SetNewsBackgroundImage( "FULL_STADIUM", review )
--											Engine.SetNewsHeadlineByObject( review, "news_title_newsigning_postmatch_played_", 4 )
--											Engine.SetNewsPlayer( review, storyPlayer )
--										end
--									end
--								end
--							end
--						end
--					end
--				end
--			else
--				if( counter == 1 ) then
--					if( gametype ~= "FRIENDLY" ) then
--						if( stage <= 2 ) then
--							counter = counter + 1
--							newsWeight = newsWeight - 1
--							Engine.SetStringTeams( storyTeam )
--							Engine.SetStringPlayers( storyPlayer )
--							PublishToReview( nil, "news_body_newsigning_postmatch_notplayed_", 4, newsWeight )
--							local area = Engine.GetPlayerPitchArea( storyTeam, storyPlayer )
--							local position = Engine.GetPlayerPosition( storyTeam, storyPlayer )
--							if( area == "ATT" or position == "CAM" ) then
--								Engine.SetStoryStage( currentStory, 3 )
--							else
--								Engine.SetStoryStage( currentStory, 4 )
--							end
--						end
--					end
--				end
--			end
--		end
--		if( val == "both" and topCpuPlayer > 0 ) then
--			 -- CPU Work Goes Here --------------------------------------
--			 --Debut
--			local stage = Engine.GetStoryStage( topCpuStory )
--			local goalCountCpu = 0
--			local redCountCpu = 0
--			if( Engine.DidPlayerPlay( topCpuTeam, topCpuPlayer, matchResult ) == true ) then
--				cpuCounter = cpuCounter + 1
--				local debutInsert = "cpu_"
--				if( publishCounter == 0 ) then
--					debutInsert = ""
--				end
--				if( gametype == "FRIENDLY" ) then
--					newsWeight = newsWeight - 1
--					Engine.SetStringTeams( topCpuTeam )
--					Engine.SetStringPlayers( topCpuPlayer )
--					PublishToReview( nil, "news_body_newsigning_postmatch_debut_friendly_" .. debutInsert, 1, newsWeight )
--				 --friendly
--				elseif( stage <= 2 ) then
--					newsWeight = newsWeight - 1
--					local status, fee, wage, sellingTeam = Engine.GetPlayerTransferInfo( topCpuTeam, topCpuPlayer )
--					local userTeam = Engine.GetUserTeam()	
--					Engine.SetStringTeams( topCpuTeam, sellingTeam, userTeam )
--					Engine.SetStringPlayers( topCpuPlayer )
--					PublishToReview( nil, "news_body_newsigning_postmatch_debut_" .. debutInsert, 1, newsWeight )
--				 --debut
--				end
--			
--			-- Goal Count
--				if( stage <= 2 and gametype ~= "FRIENDLY" ) then
--					local numIncidents = Engine.GetNumberOfIncidents( matchResult )
--					for incidentCount = 1, numIncidents do
--						local type = Engine.GetIncidentTypeByIndex( matchResult, incidentCount )
--						local incident = Engine.GetMatchIncidentByIndex( matchResult, incidentCount )
--						local teamId, playerId, incidentTime = Engine.GetIncidentTeamPlayerAndTime( matchResult, incident )
--						if( type == "GOAL" ) then
--							if(  playerId == topCpuPlayer ) then
--								goalCountCpu = goalCountCpu + 1
--							end
--					-- Red Card Count
--						elseif( type == "CARD" ) then
--							local cardType = Engine.GetCardType( incident )
--							if( cardType == "RED" ) then
--								if(  playerId == topCpuPlayer ) then
--									redCountCpu = redCountCpu + 1
--								end
--							end
--						end
--					end
--					--Score
--					if( goalCountCpu > 0 ) then
--						local replacer1 = "locme_news_goals_goal"
--						if( goalCountCpu == 2 ) then
--							replacer1 = "locme_news_goals_brace"
--						elseif( goalCountCpu == 3 ) then
--							replacer1 = "locme_news_goals_hattrick"
--						elseif( goalCountCpu > 3 ) then
--							replacer1 = "locme_news_goals_goals"
--						end
--						Engine.SetStringTeams( topCpuTeam )
--						Engine.SetStringPlayers( topCpuPlayer )
--						newsWeight = newsWeight - 1
--						if( stage <= 2 ) then
--							PublishToReview( nil, "news_body_newsigning_postmatch_goal_cpu_", 1, newsWeight, replacer1 )
--						end
--					end
--					--Sent off
--					if( redCountCpu > 0 ) then
--						newsWeight = newsWeight - 1
--						Engine.SetStringTeams( topCpuTeam )
--						Engine.SetStringPlayers( topCpuPlayer )
--						if( stage <= 2 ) then
--							PublishToReview( nil, "news_body_newsigning_postmatch_red_cpu_", 1, newsWeight )
--						end
--					end
--					--Injured
--					if( Engine.DidPlayerGetInjured( topCpuTeam, topCpuPlayer, matchResult ) == true ) then
--						newsWeight = newsWeight - 1
--						Engine.SetStringTeams( topCpuTeam )
--						Engine.SetStringPlayers( topCpuPlayer )
--						if( stage <= 2 ) then
--							PublishToReview( nil, "news_body_newsigning_postmatch_injured_cpu_", 1, newsWeight )
--						end
--					end
--					--Form Comparison
--					if( Engine.DoesNewsExist( "REVIEW" ) == true ) then
--						if( stage <= 2 ) then
--							local cpuPlayerRating = Engine.GetPlayerMatchRating( topCpuTeam, topCpuPlayer, matchResult )
--							local topPlayerRating = Engine.GetPlayerMatchRating( topTeam, topPlayer, matchResult )
--							local goodFormRating = Tuning.NEWSIGNING.goodFormRating
--							local poorFormRating = Tuning.NEWSIGNING.poorFormRating
--							Engine.SetStringTeams( topCpuTeam )
--							Engine.SetStringPlayers( topCpuPlayer )
--							local review = Engine.GetNewsById( "REVIEW" )
--							if( cpuPlayerRating >= goodFormRating ) then
--								newsWeight = newsWeight - 1
--								Engine.SetStringTeams( topCpuTeam )
--								Engine.SetStringPlayers( topCpuPlayer )
--								PublishToReview( nil, "news_body_newsigning_postmatch_debut_goodform_cpu_", 1, newsWeight )
--							elseif( cpuPlayerRating <= poorFormRating ) then
--								newsWeight = newsWeight - 1
--								Engine.SetStringTeams( topCpuTeam )
--								Engine.SetStringPlayers( topCpuPlayer )
--								PublishToReview( nil, "news_body_newsigning_postmatch_debut_poorform_cpu_", 1, newsWeight )
--							end
--						end
--					end
--				end
--			else
--				if( gametype ~= "FRIENDLY" ) then
--					if( stage <= 2 ) then
--						if( cpuCounter < 1 ) then
--							cpuCounter = cpuCounter + 1
--							newsWeight = newsWeight - 1
--							Engine.SetStringTeams( topCpuTeam )
--							Engine.SetStringPlayers( topCpuPlayer )
--							PublishToReview( nil, "news_body_newsigning_postmatch_cpunotplayed_", 1, newsWeight )
--						end
--					end
--				end
--			end
--		end
--		if( numStories > 2 ) then
--			local tableSize = # debutPlayers
--			if( tableSize < 10 ) then
--				local numExtra = 10 - tableSize
--				for extraLoop = 1, numExtra do
--					table.insert( debutPlayers, 0 ) -- Questionable
--				end
--			end
--			if( tableSize > 0 ) then
--				if( addPar == true ) then
--					for loop = 1, 5 do
--						Engine.SetStringPlayer( debutPlayers[ loop ], loop )
--					end
--					newsWeight = newsWeight - 1
--					PublishToReview( nil, "news_body_newsigning_postmatch_debut_extra_player_", 1, newsWeight )
--				end
--			end
--		end
--	end
--end
--
--function NewSigningDynamicEvent( eventId, storyId )
--	if( eventId == "NEWSIGNING" ) then
--		NewSigningProgress( storyId )
--	elseif( eventId == "VERY_BAD" or eventId == "VERY_GOOD" )then
--		NewSigning_FormChange_News( eventId, storyId )
--	end
--end
--
--function NewSigningProgress( storyId )
--	local currentStory = Engine.GetStoryById( storyId )
--	local storyPlayer = Engine.GetStoryPlayer( currentStory )
--	local storyTeam = Engine.GetStoryTeam( currentStory )
--	local appearances = Engine.GetPlayerStat( storyTeam, storyPlayer, "APPEARANCES" )
--	if( appearances > 0 ) then
--		local playerForm = Engine.GetPlayerFormLevel( storyTeam, storyPlayer )
--		local newNews = nil
--		local newsWeight = Tuning.NEWSIGNING.progressNewsWeight
--		Engine.SetStringTeams( storyTeam )
--		Engine.SetStringPlayers( storyPlayer )
--		if( playerForm == "GOOD" or playerForm == "VERY_GOOD" ) then
--			newNews = Engine.CreateNews( "NEWSIGNING_PROGRESS", "news_title_newsigning_progress_goodform_", 4 )
--			Engine.AddParagraph( newNews, newsWeight, "news_body_newsigning_progress_goodform_", 4 )
--			Engine.SetStoryStage( currentStory, 8 )
--			local scene = "CM_News_PlayerActionPositive"
--			if( Engine.GetRandomNumber( 1, 2 ) == 2 ) then
--				scene = "CM_News_PlayerPromo"
--			end
--			Engine.SetNewsCinematic ( scene, newNews )
--		elseif( playerForm == "BAD" or playerForm == "VERY_BAD" ) then
--			newNews = Engine.CreateNews( "NEWSIGNING_PROGRESS", "news_title_newsigning_progress_poorform_", 4 )
--			Engine.AddParagraph( newNews, newsWeight, "news_body_newsigning_progress_poorform_", 4 )
--			Engine.SetStoryStage( currentStory, 9 )
--			Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative", newNews )
--		else
--			newNews = Engine.CreateNews( "NEWSIGNING_PROGRESS", "news_title_newsigning_progress_neutralform_", 4 )
--			Engine.AddParagraph( newNews, newsWeight, "news_body_newsigning_progress_neutralform_", 4 )
--			Engine.SetStoryStage( currentStory, 10 )
--		end
--		--Add morale check
--		local playerArea = Engine.GetPlayerPitchArea( storyTeam, storyPlayer )
--		if( playerArea == "ATT" ) then
--			local var = Engine.GetStoryVariable( currentStory )
--			if( string.find( var, "4" ) == nil ) then
--				Engine.SetStringTeams( storyTeam )
--				Engine.SetStringPlayers( storyPlayer )
--				Engine.AddParagraph( newNews, newsWeight, "news_body_newsigning_progress_neverscored_", 2 )
--			end
--		end
--		Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
--		Engine.SetNewsBackgroundImage( "TRAINING_GROUNDS", newNews )
--		PublishArticle( nil, newNews, "MAJOR", storyTeam, storyPlayer )
--	end
--end
--
--function NewSigning_FormChange( teamId, playerId, formString)
--	if( formString == "VERY_BAD" or formString == "VERY_GOOD" ) then
--		local numStories = Engine.GetNumStoriesByCategory( "SIGNING" )
--		for storyCount = 1, numStories do
--			local currentStory = Engine.GetStoryByCategoryAndIndex( "SIGNING", storyCount )
--			local storyId = Engine.GetStoryId( currentStory )
--			local storyPlayer = Engine.GetStoryPlayer( currentStory )
--			if( storyPlayer == playerId ) then
--				local stage = Engine.GetStoryStage( currentStory )
--				if( stage < 5 ) then
--					local var = Engine.GetStoryVariable( currentStory )
--					if( string.find( var, "7" ) == nil and string.find( var, "8" ) == nil ) then
--						Engine.AddDateEvent( formString, 1, storyId )
--					end
--				end
--			end
--		end
--	end
--end
--
--function NewSigning_FormChange_News( eventId, storyId )
--	local currentStory = Engine.GetStoryById( storyId )
--	local teamId = Engine.GetStoryTeam( currentStory )
--	local storyPlayer = Engine.GetStoryPlayer( currentStory )
--	local var = Engine.GetStoryVariable( currentStory )
--	local newsWeight = Tuning.NEWSIGNING.formChangeNewsWeight
--	if( eventId == "VERY_BAD" )then
--		Engine.SetStoryStage( currentStory, 6 )
--		Engine.SetStoryVariable( currentStory, var .. "7" ) -- Concatination issues
--		Engine.SetStringTeams( teamId )
--		Engine.SetStringPlayers( storyPlayer )
--		local newNews = Engine.CreateNews( "NEWSIGNING_FORM", "news_title_newsigning_poorformchange_", 4 )
--		Engine.SetStringTeams( teamId )
--		Engine.SetStringPlayers( storyPlayer )
--		Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
--		Engine.SetNewsBackgroundImage( "FOOTBALL_BOOT", newNews )
--		Engine.AddParagraph( newNews, newsWeight, "news_body_newsigning_poorformchange_", 2 )
--		Engine.SetNewsCinematic( "CM_News_PlayerActionNegative", newNews )
--		PublishArticle( nil, newNews, "MAJOR", teamId, storyPlayer )
--		Engine.UpdateStoryActivity( currentStory )
--	elseif( eventId == "VERY_GOOD" )then
--		Engine.SetStoryStage( currentStory, 6 )
--		Engine.SetStoryVariable( currentStory, var .. "8" )
--		Engine.SetStringTeams( teamId )
--		Engine.SetStringPlayers( storyPlayer )
--		local newNews = Engine.CreateNews( "NEWSIGNING_FORM", "news_title_newsigning_goodformchange_", 4 )
--		Engine.SetStringTeams( teamId )
--		Engine.SetStringPlayers( storyPlayer )
--		Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer, newNews )
--		Engine.SetNewsBackgroundImage( "FOOTBALL_BOOT", newNews )
--		Engine.AddParagraph( newNews, newsWeight, "news_body_newsigning_goodformchange_", 2 )
--		Engine.SetNewsCinematic( "CM_News_PlayerPromo", newNews )
--		PublishArticle( nil, newNews, "MAJOR", teamId, storyPlayer )
--		Engine.UpdateStoryActivity( currentStory )
--	end
--end
--
---- function NewSigning_MoraleChange()
---- end
--
--------------------------------------------------------------------------------------------------------------------------------------
----CPU New Signing
--------------------------------------------------------------------------------------------------------------------------------------
function AddUserCPUNewSigningStory ( teamId, playerId, category, storyId, coolDown, checkForDebuts, playerAppearances )
	if ( checkForDebuts == true ) then
		if ( playerAppearances == 0 ) then
			return Engine.MarkPlayerForDebutStory( teamId, playerId )
		else
			return false
		end
	else
		return Engine.MarkPlayerForStory( teamId, playerId, category, storyId, coolDown )
	end
end

function ExamineFor_CPUNewSigning( teamId, checkForDebuts, numPlayers, player1, player2, player3, player4, player5, player6, player7 )
	if( numPlayers > 0 ) then
		local category = "SIGNING"
		local baseStoryId = "NEWSIGNING_CPU_"
		local currentCompObjId = Engine.GetCurrentGameCompObjId()
		local playerArray = { player1, player2, player3, player4, player5, player6, player7 }
		
		for playerCount = 1, numPlayers do
			local playerId = playerArray[ playerCount ]
			if( playerId ~= nil ) then
				local storyId = baseStoryId .. playerCount
				local fixture = Engine.GetCurrentGameFixtureData()
				local gameType = Engine.GetFixtureType( fixture )
				if( gameType == "LEAGUE" or gameType == "SUPERCUP" or gameType == "FRIENDLY" or gameType == "CUP" )then
					local playerAppearances = Engine.GetPlayerStat( teamId, playerId, "APPEARANCES", currentCompObjId, checkForDebuts )
					local playerTier = Engine.GetPlayerTier( teamId, playerId )
					if( playerAppearances == 0 and playerTier <= 3 ) then
						if( AddUserCPUNewSigningStory( teamId, playerId, category, storyId, 1, checkForDebuts, playerAppearances ) == true ) then
							local currentStory = Engine.GetStoryById( storyId )
							if( gameType == "FRIENDLY" ) then
								Engine.SetStoryStage( currentStory, 0 )
							else
								Engine.SetStoryStage( currentStory, 2 )
							end
							Engine.UpdateStoryActivity( currentStory )
							Engine.KillStoryAfterMatch( currentStory, false )
						end
					else
						if( AddUserCPUNewSigningStory( teamId, playerId, category, storyId, 1, checkForDebuts, playerAppearances ) == true ) then
							local currentStory = Engine.GetStoryById( storyId )
							local monthsJoined = Engine.GetNumberOfMonthsSincePlayerJoined( teamId, playerId )
							if( monthsJoined < 3 ) then
								Engine.SetStoryStage( currentStory, 4 )
							else
								Engine.SetStoryStage( currentStory, 5 )
							end
							Engine.UpdateStoryActivity( currentStory )
							Engine.KillStoryAfterMatch( currentStory, false )
						end
					end
				else
					if( AddUserCPUNewSigningStory( teamId, playerId, category, storyId, 1, checkForDebuts, 1 ) == true ) then
						local currentStory = Engine.GetStoryById( storyId )
						local monthsJoined = Engine.GetNumberOfMonthsSincePlayerJoined( teamId, playerId )
						if( monthsJoined < 3 ) then
							Engine.SetStoryStage( currentStory, 4 )
						else
							Engine.SetStoryStage( currentStory, 5 )
						end
						Engine.UpdateStoryActivity( currentStory )
						Engine.KillStoryAfterMatch( currentStory, false )
					end
				end
			end
		end
	end
end
