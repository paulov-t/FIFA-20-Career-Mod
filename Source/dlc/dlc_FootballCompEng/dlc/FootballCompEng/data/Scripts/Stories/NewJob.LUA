function InternationalTeaser()
	local isPap = Engine.IsPlayAsPlayer()
	local userTeam = Engine.GetUserTeam()
	Engine.SetStringTeams( userTeam )
	local papId = 0
	if( isPap == true ) then
		papId = Engine.GetPlayAsPlayerID()
		Engine.SetStringPlayers( papId )
		
		local newNews = Engine.CreateNews( "INT_TEASER", "news_title_intteaser_createdplayer_", 2 )
		Engine.SetStringTeams( userTeam )
	
		local createdPlayer = Engine.IsCreatedPlayer()
		Engine.SetStringPlayers( papId )
		if( createdPlayer == true ) then
			Engine.AddParagraph( newNews, 1, "news_body_intteaser_createdplayer_", 2 )
		else
			Engine.SetNewsHeadlineByObject( newNews, "news_title_intteaser_realplayer_", 2 )
			Engine.SetStringPlayers( papId )
			Engine.SetStringTeams( userTeam )
			Engine.AddParagraph( newNews, 1, "news_body_intteaser_realplayer_", 2 )
			Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", papId, newNews )
			Engine.SetNewsBackgroundImage( "GLOBE", newNews )
		end
		Engine.SetNewsCinematic( "CM_News_PlayerActionPositive", newNews )
		
		PublishArticle( nil, newNews, "MAJOR", userTeam, papId )
	end
end

function StartStory_NewJob( toTeam, fromTeam, storyId, wasFired, retiring )
	local category = "JOBCHANGE"
	local storyPlayerId = 0
	local isPap = Engine.IsPlayAsPlayer()
	local coolDown = Tuning.NEWJOB.storyCooldown
	local scene = ""
	if( storyId == "INTPLAYER" ) then
		coolDown = Tuning.NEWJOB.storyCooldownInt
	end
	if( retiring == false ) then
		if( isPap == true ) then
			storyPlayerId = Engine.GetPlayAsPlayerID()
		end
	end
	if( Engine.MarkPlayerForStory( toTeam, storyPlayerId, category, storyId, coolDown ) == true ) then
		local storyString = "intmanager_"
		if( storyId == "INTMANAGER" ) then
			storyString = "intmanager_"
		elseif( storyId == "INTPLAYER" ) then
			storyString = "intplayer_"
		end
		local oldTeam = fromTeam
		if( fromTeam < 1 ) then
			oldTeam = toTeam
		end
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 1 )
		if( storyId == "INTPLAYER" ) then
			Engine.SetNoDeathAtEOS( currentStory )
		end
		Engine.SetStoryVariable( currentStory, fromTeam )
		Engine.SetStringTeams( toTeam, oldTeam )
		local starPlayer = false
		local randomScene = Engine.GetRandomNumber( 1, 2 )
		local papId = 0
		if( isPap == true ) then
			papId = storyPlayerId
			Engine.SetStringPlayers( storyPlayerId, storyPlayerId )
			starPlayer = Engine.IsStarPlayer( papId )
		end
		local newNews = Engine.CreateNews( "New_Job", "news_title_" .. storyString .. "arrives_", 4 )
		if( storyId == "INTMANAGER" ) then
			Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", toTeam, newNews )
			Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
		elseif( storyId == "INTPLAYER" ) then
			Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayerId, newNews )
			Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", toTeam, newNews )
			Engine.SetNewsBackgroundImage( "FANS_CELEBRATING", newNews )
			if( starPlayer == true ) then
				if( randomScene == 1 ) then
					scene = "CM_News_PlayerPromo"
				else
					scene = "CM_News_PlayerActionPositive"
				end
			end
		else	
			Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", toTeam, newNews )
			Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
		end
		Engine.SetStringTeams( toTeam, oldTeam )
		if( isPap == true ) then
			Engine.SetStringPlayers( storyPlayerId, storyPlayerId )
		end
		Engine.AddParagraph( newNews, 4, "news_body_" .. storyString .. "arrives_", 4 )
		Engine.SetStringTeams( toTeam, oldTeam )
		if( isPap == true ) then
			Engine.SetStringPlayers( storyPlayerId, storyPlayerId )
		end
		if( retiring == true ) then
			Engine.AddParagraph( newNews, 3, "news_body_" .. storyString .. "arrives_retired_", 4 )
			if( storyId == "NEWMANAGER" ) then
				scene = "CM_News_ManagerActionPositive"
			end
		else
			if( fromTeam > 0 ) then
				if( wasFired == true ) then
					Engine.SetStringTeams( toTeam, oldTeam )
					if( isPap == true ) then
						Engine.SetStringPlayers( storyPlayerId, storyPlayerId )
					end
					Engine.AddParagraph( newNews, 2, "news_body_" .. storyString .. "arrives_fired_", 4 )
					Engine.SetNewsHeadlineByObject( newNews, "news_title_" .. storyString .. "arrives_fired_", 2 )
					if( storyId == "NEWMANAGER" ) then
						scene = "CM_News_ManagerActionNegative"
					end
				else
					if( storyId == "INTPLAYER" ) then
						scene = "CM_News_PlayerActionPositive"
					elseif( storyId == "INTMANAGER" or storyId == "NEWMANAGER" ) then
						scene = "CM_News_ManagerActionPositive"
					end
					local percThroughSeason = Engine.GetPercentageThroughSeason()
					if( percThroughSeason > Tuning.NEWJOB.percThroughSeason_News_OldTeam ) then
						local meetingObj = IsMeetingObjective( fromTeam )
						if( meetingObj == true ) then
							Engine.AddParagraph( newNews, 3, "news_body_" .. storyString .. "arrives_oldteamgood_", 4 )
						else
							Engine.AddParagraph( newNews, 3, "news_body_" .. storyString .. "arrives_oldteampoor_", 4 )
							if( storyId == "INTPLAYER" ) then
								scene = ""
							elseif( storyId == "INTMANAGER" ) then
								scene = "CM_News_ManagerActionNegative"
							end
						end
					end
				end
			else
				Engine.AddParagraph( newNews, 2, "news_body_" .. storyString .. "arrives_untested_", 4 )
			end
		end
		if( storyId == "NEWMANAGER" ) then
			local keepsManagers = Engine.HasTeamTrait( toTeam, "LOYAL_BOARD" )
			if( keepsManagers == false ) then
				local domPrestige, intPrestige = Engine.GetTeamPrestige( toTeam )
				local cycleManagers = Engine.HasTeamTrait( toTeam, "IMPATIENT_BOARD" )
				local domPrestigeWeight = Tuning.NEWJOB.domPrestigeWeight
				local prestigeThreshold = Tuning.NEWJOB.prestigeThreshold
				if( cycleManagers == true ) then
					Engine.SetStringTeams( toTeam, oldTeam )
					Engine.AddParagraph( newNews, 1, "news_body_newmanager_arrives_manageratrisk_cyclesmanagers_", 2 )
					Engine.SetStringTeams( toTeam, oldTeam )
					Engine.SetNewsHeadlineByObject( newNews, "news_title_newmanager_arrives_manageratrisk_", 2 )
					Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", toTeam, newNews )
					Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
					scene = ""
				elseif( (domPrestige * domPrestigeWeight + intPrestige * (1 - domPrestigeWeight)) > prestigeThreshold ) then
					local chanceToStart = RollPercentageDice( 100 )
					if( chanceToStart == true ) then
						Engine.SetStringTeams( toTeam, oldTeam )
						Engine.AddParagraph( newNews, 1, "news_body_newmanager_arrives_manageratrisk_", 2 )
						Engine.SetStringTeams( toTeam, oldTeam )
						Engine.SetNewsHeadlineByObject( newNews, "news_title_newmanager_arrives_manageratrisk_", 2 )
						Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", toTeam, newNews )
						Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
						scene = ""
					end
				end
			end
		end
		if( scene ~= "" ) then		
			Engine.SetNewsCinematic( scene, newNews )
		end
		Engine.SetNewsType( "CLUB", newNews )
		PublishArticle( currentStory, newNews, "MAJOR", toTeam, papId )
	end
end

function NewJob_PreMatch( numDays, gametype, fixture )
	if( numDays == 0 ) then
		local success = true
		local stringType = "new"
		local idType = "NEW"
		local playerIdType = "MANAGER"
		local playerStringType = "manager_"
		local isPap = Engine.IsPlayAsPlayer()
		local starPlayer = false
		local randomScene = Engine.GetRandomNumber( 1, 2 )
		if( isPap == true ) then
			starPlayer = Engine.IsStarPlayer( Engine.GetPlayAsPlayerID() )
		end
		if( string.find( gametype, "INTERNATIONAL" ) ~= nil ) then
			stringType = "int"
			idType = "INT"
			if( isPap == true ) then
				playerIdType = "PLAYER"
				playerStringType = "player_"
			end
		else
			if( isPap == true ) then
				success = false
			end
		end
		if( success == true ) then
			local titleString = ""
			local bodyString = ""
			local addString = ""
			local storyId = idType .. playerIdType
			local storyString = stringType .. playerStringType
			local storyActive = Engine.IsStoryIDActive( storyId )
			local prematchDebut = false
			if( storyActive == true ) then
				local currentStory = Engine.GetStoryById( storyId )
				local storyTeam = Engine.GetStoryTeam( currentStory )
				local storyVar = Engine.GetStoryVariable( currentStory )
				local stage = Engine.GetStoryStage( currentStory )
				local success = false
				if( string.find( gametype, "FRIENDLY" ) ~= nil ) then
					if( stage == 0 ) then
						if( storyString ~= "intplayer_" ) then
							success = true
						end
					end
				else
					success = true
				end
				if( success == true ) then
					if( string.find( gametype, "FRIENDLY" ) ~= nil ) then
						if( stage == 0 ) then
							if( storyVar ~= "STAGE0.5" ) then
								bodyString = "news_body_" .. storyString .. "prematch_debutfriendly_"
								titleString = "news_title_" .. storyString .. "prematch_debutfriendly_"
								Engine.SetStoryVariable( currentStory, "STAGE0.5" )
							end
						end
					else
						if( stage < 1 or stage == 10 ) then
							prematchDebut = true
							bodyString = "news_body_" .. storyString .. "prematch_debut_"
							titleString = "news_title_" .. storyString .. "prematch_debut_"
							Engine.SetStoryStage( currentStory, 1 )
						elseif( stage > 1 and stage < 5 ) then
							bodyString = "news_body_" .. storyString .. "prematch_secondmatch_"
							titleString = "news_title_" .. storyString .. "prematch_secondmatch_"
							if( string.find( storyVar, "1" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_secondmatch_wonfirst_"
							elseif( string.find( storyVar, "2" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_secondmatch_lostfirst_"
							elseif( string.find( storyVar, "3" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_secondmatch_drawfirst_"
							end
						elseif( stage > 4 ) then
							bodyString = "news_body_" .. storyString .. "prematch_thirdmatch_"
							titleString = "news_title_" .. storyString .. "prematch_thirdmatch_"
							if( string.find( storyVar, "14" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_wonfirst_wonsecond_"
							elseif( string.find( storyVar, "15" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_wonfirst_lostsecond_"
							elseif( string.find( storyVar, "16" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_wonfirst_drawsecond_"
							elseif( string.find( storyVar, "24" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_lostfirst_wonsecond_"
							elseif( string.find( storyVar, "25" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_lostfirst_lostsecond_"
							elseif( string.find( storyVar, "26" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_lostfirst_drawsecond_"
							elseif( string.find( storyVar, "35" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_drawfirst_lostsecond_"
							elseif( string.find( storyVar, "34" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_drawfirst_wonsecond_"
							elseif( string.find( storyVar, "36" ) ~= nil ) then
								addString = "news_body_" .. storyString .. "prematch_thirdmatch_drawfirst_drawsecond_"
							end
						end
					end
					fixture = Engine.GetCurrentGameFixtureData()
					local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
					local userTeam = 0
					local cpuTeam = 0
					if( idType == "INT" ) then
						userTeam = Engine.GetUserInternationalTeam()
						cpuTeam = team1
						if( team1 == userTeam ) then
							cpuTeam = team2
						end						
					else
						userTeam, cpuTeam = GetUserCpuTeamFromIds( team1, team2 )
					end
					local papId = 0
					local comp = Engine.GetCompetitionFromFixture( fixture )
					Engine.SetStringCompetition( comp )
					Engine.SetStringTeams( userTeam, cpuTeam )
					if( isPap == true ) then
						papId = Engine.GetPlayAsPlayerID()
						Engine.SetStringPlayers( papId )
					end
					if( idType == "INT" ) then
						if( bodyString ~= "" ) then
							local scene = ""
							local newNews = Engine.CreateNews( "NEWJOB", titleString, 4 )
							Engine.AddParagraph( newNews, 2, bodyString, 4 )
							if( addString ~= "" ) then
								Engine.SetStringCompetition( comp )
								Engine.SetStringTeams( userTeam, cpuTeam )
								if( isPap == true ) then
									Engine.SetStringPlayers( papId )
								end
								Engine.AddParagraph( newNews, 1, addString, 4 )
							end
							Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
							Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", cpuTeam, newNews )
							Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
							if( playerIdType == "PLAYER" ) then
								if( starPlayer == true ) then
									if( randomScene == 1 ) then
										scene = "CM_News_PlayerPromo"
									else
										scene = "CM_News_PlayerActionPositive"
									end
								end
							elseif( playerIdType == "MANAGER" ) then
								if( prematchDebut == true ) then
									scene = "CM_News_ManagerActionPositive" 
								end
							end
							if( scene ~= "" ) then		
								Engine.SetNewsCinematic( scene, newNews )
							end
							PublishArticle( currentStory, newNews, "MAJOR", storyTeam, papId )
						end
					else
						if( bodyString ~= "" ) then
							PublishToPreview( currentStory, bodyString, 1, 700 )
							local newNews = Engine.GetNewsById( "PREVIEW" )
							if( addString ~= "" ) then
								Engine.SetStringCompetition( comp )
								Engine.SetStringTeams( userTeam, cpuTeam )
								if( isPap == true ) then
									Engine.SetStringPlayers( papId )
								end
								Engine.AddParagraph( newNews, 700, addString, 1 )
							end
							Engine.SetStringCompetition( comp )
							Engine.SetStringTeams( userTeam, cpuTeam )
							if( isPap == true ) then
								Engine.SetStringPlayers( papId )
							end
							Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
							Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", cpuTeam, newNews )
							Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
							Engine.SetNewsHeadlineByObject( newNews, titleString, 4 )
						end
					end
				end
			end
		end
	end
end

function NewJob_PostMatch( matchResult, gametype, playType )
	local isPap = Engine.IsPlayAsPlayer()
	local stringType = "new"
	local idType = "NEW"
	local playerIdType = "MANAGER"
	local playerStringType = "manager_"
	local titleString = ""
	local bodyString = ""
	local addString = ""
	local emoString = ""
	local success = true
	local starPlayer = false
	local randomScene = Engine.GetRandomNumber( 1, 2 )
	if( isPap == true ) then
		starPlayer = Engine.IsStarPlayer( Engine.GetPlayAsPlayerID() )
	end
	if( string.find( gametype, "INTERNATIONAL" ) ~= nil ) then
		stringType = "int"
		idType = "INT"
		if( isPap == true ) then
			local userTeam = Engine.GetUserInternationalTeam()
			local papId = Engine.GetPlayAsPlayerID()
			local played = Engine.DidPlayerPlay( userTeam, papId, matchResult )
			if( played == true ) then
				playerIdType = "PLAYER"
				playerStringType = "player_"
			else
				success = false
			end
		end
	else
		if( isPap == true) then
			local category = "JOBCHANGE"
			local numStories = Engine.GetNumStoriesByCategory( category )
			if( numStories > 0 ) then
				local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
				local storyId = Engine.GetStoryId( currentStory )
				if( storyId ~= "INTPLAYER" ) then
					Engine.EndStoryId( storyId, false )
					success = false
				end
			end
		end
	end
	if( success == true ) then
		local scene = ""
		local storyString = stringType .. playerStringType
		local storyId = idType .. playerIdType
		local storyActive = Engine.IsStoryIDActive( storyId )
		if( storyActive == true ) then
			local currentStory = Engine.GetStoryById( storyId )
			local stage = Engine.GetStoryStage( currentStory )
			local success = false
			if( string.find( gametype, "FRIENDLY" ) ~= nil ) then
				if( stage == 0 ) then
					if( storyString ~= "intplayer_" ) then
						success = true
					end
				end
			else
				success = true
			end
			if( success == true ) then
				local storyTeam = Engine.GetStoryTeam( currentStory )
				local storyVar = Engine.GetStoryVariable( currentStory )
				local wasGameWon = Engine.WasGameWon( matchResult )
				local result = ""
				local emotion = ""
				local fixture = Engine.GetCurrentGameFixtureData()
				local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
				local cpuTeam = 0
				local userTeam = 0
				local postmatchDebut = false
				if( idType == "INT" ) then
					userTeam = Engine.GetUserInternationalTeam()
					cpuTeam = team1
					if( team1 == userTeam ) then
						cpuTeam = team2
					end						
				else
					userTeam, cpuTeam = GetUserCpuTeamFromIds( team1, team2 )
				end
				local papId = 0
				Engine.SetStringTeams( userTeam, cpuTeam )
				if( isPap == true ) then
					papId = Engine.GetPlayAsPlayerID()
					Engine.SetStringPlayers( papId )
				end
				if( wasGameWon == true ) then
					local matchWinner = Engine.GetMatchWinner( matchResult )
					if( matchWinner == storyTeam ) then
						result = "won_"
						if( stage < 2 ) then
							Engine.SetStoryVariable( currentStory, "1" )
						else
							Engine.SetStoryVariable( currentStory, storyVar .. "4" )
						end
					else
						result = "lost_"
						if( stage < 2 ) then
							Engine.SetStoryVariable( currentStory, "2" )
						else
							Engine.SetStoryVariable( currentStory, storyVar .. "5" )
						end
					end
				else
					result = "draw_"
					if( stage < 2 ) then
						Engine.SetStoryVariable( currentStory, "3" )
					else
						Engine.SetStoryVariable( currentStory, storyVar .. "6" )
					end
				end
				if( string.find( gametype, "FRIENDLY" ) ~= nil ) then
					if( stage == 0 ) then
						if( isPap == false ) then
							titleString = "news_title_" .. storyString .. "postmatch_debutfriendly_" .. result
							bodyString = "news_body_" .. storyString .. "postmatch_debutfriendly_" .. result
						end
						Engine.SetStoryStage( currentStory, 10 )
					end
				else
					if( stage < 2 ) then
						postmatchDebut = true
						titleString = "news_title_" .. storyString .. "postmatch_debut_" .. result
						bodyString = "news_body_" .. storyString .. "postmatch_debut_" .. result
						if( result == "won_" ) then
							Engine.SetStoryStage( currentStory, 2 )
						elseif( result == "lost_" or result == "forfeit_" ) then
							Engine.SetStoryStage( currentStory, 3 )
						else
							Engine.SetStoryStage( currentStory, 4 )
						end
					elseif( stage > 1 and stage < 5 ) then
						titleString = "news_title_" .. storyString .. "postmatch_secondmatch_" .. result
						bodyString = "news_body_" .. storyString .. "postmatch_secondmatch_" .. result
						if( string.find( storyVar, "1" ) ~= nil ) then
							addString = "news_body_" .. storyString .. "postmatch_secondmatch_wonfirst_"
						elseif( string.find( storyVar, "2" ) ~= nil ) then
							addString = "news_body_" .. storyString .. "postmatch_secondmatch_lostfirst_"
						elseif( string.find( storyVar, "3" ) ~= nil ) then
							addString = "news_body_" .. storyString .. "postmatch_secondmatch_drawfirst_"
						end
						if( result == "won_" ) then
							Engine.SetStoryStage( currentStory, 5 )
						elseif( result == "lost_" or result =="forfeit_" ) then
							Engine.SetStoryStage( currentStory, 6 )
						else
							Engine.SetStoryStage( currentStory, 7 )
						end
					elseif( stage > 4 ) then
						bodyString = "news_body_" .. storyString .. "postmatch_thirdmatch_" .. result
						if( string.find( storyVar, "14" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "positive_"
							else
								emotion = "neutral_"
							end
						elseif( string.find( storyVar, "15" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "positive_"
							elseif( result == "lost_" or result == "forfeit_" ) then
								emotion = "negative_"
							else
								emotion = "neutral_"
							end
						elseif( string.find( storyVar, "16" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "positive_"
							elseif( result == "lost_" or result == "forfeit_" ) then
								emotion = "negative_"
							else
								emotion = "neutral_"
							end
						elseif( string.find( storyVar, "24" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "positive_"
							elseif( result == "lost_" ) then
								emotion = "negative_"
							else
								emotion = "neutral_"
							end
						elseif( string.find( storyVar, "25" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "neutral_"
							else
								emotion = "negative_"
							end
						elseif( string.find( storyVar, "26" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "neutral_"
							else
								emotion = "negative_"
							end
						elseif( string.find( storyVar, "34" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "neutral_"
							else
								emotion = "negative_"
							end
						elseif( string.find( storyVar, "35" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "neutral_"
							else
								emotion = "negative_"
							end
						elseif( string.find( storyVar, "36" ) ~= nil ) then
							if( result == "won_" ) then
								emotion = "neutral_"
							else
								emotion = "negative_"
							end
						end
						if( emotion == "" ) then
							emotion = "neutral_"
						end
						emoString = "news_body_" .. storyString .. "postmatch_" .. emotion
						titleString = "news_title_" .. storyString .. "postmatch_" .. emotion
						Engine.SetStoryStage( currentStory, 8 )
					end
				end
				local comp = Engine.GetCompetitionFromResult( matchResult )
				Engine.SetStringCompetition( comp )
				Engine.SetStringTeams( userTeam, cpuTeam )
				if( isPap == true ) then
					Engine.SetStringPlayers( papId )
				end
				if( idType == "INT" ) then
					if( titleString ~= "" ) then
						local newNews = Engine.CreateNews( "NEWJOB", titleString, 4 )
						Engine.SetStringCompetition( comp )
						Engine.SetStringTeams( userTeam, cpuTeam )
						if( isPap == true ) then
							Engine.SetStringPlayers( papId )
						end
						if( bodyString ~= "" ) then
							Engine.AddParagraph( newNews, 3, bodyString, 4 )
						end
						if( addString ~= "" ) then
							Engine.SetStringCompetition( comp )
							Engine.SetStringTeams( userTeam, cpuTeam )
							if( isPap == true ) then
								Engine.SetStringPlayers( papId )
							end
							Engine.AddParagraph( newNews, 2, addString, 4 )
						end
						if( emoString ~= "" ) then
							Engine.SetStringCompetition( comp )
							Engine.SetStringTeams( userTeam, cpuTeam )
							if( isPap == true ) then
								Engine.SetStringPlayers( papId )
							end
							Engine.AddParagraph( newNews, 1, emoString, 4 )
						end
						Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
						Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", cpuTeam, newNews )
						Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
						if( playerIdType == "PLAYER" ) then
							if( postmatchDebut == true ) then
								if( result == "won_" ) then
									if( starPlayer == true and randomScene == 1 ) then
										scene = "CM_News_PlayerPromo"
									else
										scene = "CM_News_PlayerActionPositive"
									end
								else
									scene = "CM_News_PlayerActionNegative"
								end
							end
						elseif( playerIdType == "MANAGER" ) then
							if( result == "won_" or emotion == "positive_" ) then
								scene = "CM_News_ManagerActionPositive" 
							else
								scene = "CM_News_ManagerActionNegative"
							end
						end
						if( scene ~= "" ) then		
							Engine.SetNewsCinematic( scene, newNews )
						end
						PublishArticle( nil, newNews, "MAJOR", storyTeam, papId )
					end
				else
					PublishToReview( currentStory, bodyString, 4, 3 )
					local newNews = Engine.GetNewsById( "REVIEW" )
					if( addString ~= "" ) then
						Engine.SetStringCompetition( comp )
						Engine.SetStringTeams( userTeam, cpuTeam )
						if( isPap == true ) then
							Engine.SetStringPlayers( papId )
						end
						Engine.AddParagraph( newNews, 2, addString, 4 )
					end
					if( emoString ~= "" ) then
						Engine.SetStringCompetition( comp )
						Engine.SetStringTeams( userTeam, cpuTeam )
						if( isPap == true ) then
							Engine.SetStringPlayers( papId )
						end
						Engine.AddParagraph( newNews, 1, emoString, 4 )
					end
					Engine.SetStringCompetition( comp )
					Engine.SetStringTeams( userTeam, cpuTeam )
					if( isPap == true ) then
						Engine.SetStringPlayers( papId )
					end
					Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", userTeam, newNews )
					Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", cpuTeam, newNews )
					Engine.SetNewsBackgroundImage( "MANAGER_SUIT", newNews )
					Engine.SetNewsHeadlineByObject( newNews, titleString, 4 )
					if( idType == "NEW" and playerIdType == "MANAGER" and stage > 4 and stage < 8 ) then
						scene = ""
						if( string.find( emotion, "positive" ) ~= nil ) then
							scene = "CM_News_ManagerActionPositive"
						elseif( string.find( emotion, "negative" ) ~= nil ) then
							scene = "CM_News_ManagerActionNegative"
						end
						if( scene ~= "" ) then
							Engine.SetNewsCinematic( scene, newNews )
						end
					end
				end
				stage = Engine.GetStoryStage( currentStory )
				if( isPap == true) then
					if( stage > 1 ) then
						Engine.EndStoryId( storyId )
					end
				else
					if( stage > 7 and stage ~= 10 ) then
						Engine.EndStoryId( storyId, false )
					end
				end
			end
		end
	end
end

function InternationalJob_Resign( teamId )
	Engine.EndStoryId( "INTMANAGER" )
	Engine.SetStringTeams( teamId )
	local newNews = Engine.CreateNews( "INT_RESIGN", "news_title_intmanager_resigns_", 1 )
	Engine.SetStringTeams( teamId )
	Engine.AddParagraph( newNews, 1, "news_body_intmanager_resigns_", 1 )
	PublishArticle( nil, newNews, "MAJOR", teamId, 0 )
end

--------------------------------------- MANAGER AT RISK ---------------------------------------

--Examine
--Sold Top Player
function ManagerAtRisk_SoldTopPlayer( sellingTeam, buyingTeam, playerId, storyId )
	local isPap = IsPlayAsPlayer()
	if( isPap == false ) then
		-- Best Player
		local chance = False
		local playerTier = GetPlayerTier( sellingTeam, playerId )
		local oneClubPlayer = HasPlayerTrait( sellingTeam, playerId, "ONE_CLUB_PLAYER" )
		local crowdFavourite = HasPlayerTrait( sellingTeam, playerId, "CROWD_FAVOURITE" )
		if( oneClubPlayer == true or crowdFavourite == true ) then
			chance = true
		elseif( playerTier == 1 ) then
			chance = RollPercentageDice( 85 ) -- 85%
		end
		--[[
		if( chance == true ) then
			ExamineFor_ManagerAtRisk( "soldtopplayer" )
		end
		--]]
	end
end
