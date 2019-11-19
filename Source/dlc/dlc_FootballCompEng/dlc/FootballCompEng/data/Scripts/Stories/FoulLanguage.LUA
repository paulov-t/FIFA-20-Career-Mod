function ExamineFor_FoulLanguage( matchResult, gametype, playType )
	if( string.find( gametype, "INTERNATIONAL" ) == nil ) then
		local storyId = "FOULLANGUAGE"
		local storyActive = Engine.IsStoryIDActive( storyId )
		local success = false
		local swearArray = { Engine.GetLastSwearData() }
		local isPap = Engine.IsPlayAsPlayer()
		local playTypeReplacer = "manager"
		for arrayCount = 1, 6 do
			if( swearArray[ arrayCount ] > 0 )then
				success = true
				break
			end
		end
		if( isPap == true ) then
			local userTeam = Engine.GetUserTeam()
			local papId = Engine.GetPlayAsPlayerID()
			local played = Engine.DidPlayerPlay( userTeam, papId, matchResult )
			if( storyActive == true ) then
				local currentStory = Engine.GetStoryById( storyId )
				local stage = Engine.GetStoryStage( currentStory )
				if( stage > 3 ) then
					Engine.SetPapSelectionOverride( 0 )
					Engine.SetStoryStage( currentStory, 2 )
					if( played == false ) then
						success = false
						DiciplineNews_FoulLaunguage( storyId )
					end
				end
			end
			if( played == false ) then
				success = false
			end
			playTypeReplacer = "player"
		end
		if( success == true ) then
			local refArray = { "freekick", "yellowcard", "redcard", "penalty", "offside", "nocall" }
			local numUses = 0
			local replacer = ""
			for arrayCount = 1, 6 do
				if( swearArray[ arrayCount ] > numUses )then
					replacer = refArray[ arrayCount ]
				end
			end
			if( storyActive == true ) then
				local currentStory = Engine.GetStoryById( storyId )
				local stage = Engine.GetStoryStage( currentStory )
				if( stage == 1 ) then
					Stage2_FoulLaunguage( replacer, playTypeReplacer ) -- Stage 2
				elseif( stage == 2 ) then
					Stage3_FoulLaunguage( replacer, playTypeReplacer ) -- Stage 3
				elseif( stage == 3 ) then
					Stage4_FoulLaunguage( replacer, playTypeReplacer )-- Stage 4 / Player Dicipline
				elseif( stage > 3 ) then
					if( isPap == false ) then
						Stage4_FoulLaunguage( replacer, playTypeReplacer )
					end
				end
			else
				StarStory_FoulLaunguage()
				Stage1_FoulLanguage( replacer, playTypeReplacer )
			end
			Engine.ClearLastSwearData()
		end
	end
end

function StarStory_FoulLaunguage()
	local storyId = "FOULLANGUAGE"
	local userTeam = Engine.GetUserTeam()
	if( Engine.MarkPlayerForStory( userTeam, 0, storyId, storyId ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryStage( currentStory, 1 )
	end
end

function Stage1_FoulLanguage( replacer, playTypeReplacer )
	local storyId = "FOULLANGUAGE"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local fixture = Engine.GetCurrentGameFixtureData()
		local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
		local userTeam, cpuTeam = GetUserCpuTeamFromIds( team1, team2 )
		if( playTypeReplacer == "player" ) then
			local papId = Engine.GetPlayAsPlayerID()
			Engine.SetStringPlayers( papId )
		end
		Engine.SetStringTeams( userTeam, cpuTeam )
		local currentStory = Engine.GetStoryById( storyId )
		--PublishToReview( currentStory, "news_body_foullanguage_postmatch_stage1_" .. playTypeReplacer .. "_" .. replacer .. "_", 4, 100 )
		Engine.AddDateEvent( "EndStory1", Tuning.FOULLANGUAGE.daysToEndStory, storyId )
	end
end

function Stage2_FoulLaunguage( replacer, playTypeReplacer )
	local storyId = "FOULLANGUAGE"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local fixture = Engine.GetCurrentGameFixtureData()
		local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
		local userTeam, cpuTeam = GetUserCpuTeamFromIds( team1, team2 )
		if( playTypeReplacer == "player" ) then
			local papId = Engine.GetPlayAsPlayerID()
			Engine.SetStringPlayers( papId )
		end
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStringTeams( userTeam, cpuTeam )
		--PublishToReview( currentStory, "news_body_foullanguage_postmatch_stage2_" .. playTypeReplacer .. "_" .. replacer .. "_", 4, 100 )
		Engine.SetStoryStage( currentStory, 2 )
		Engine.AddDateEvent( "EndStory2", Tuning.FOULLANGUAGE.daysToEndStory, storyId )
		Engine.AddDateEvent( "FoulEmail", Tuning.FOULLANGUAGE.daysToEmail, storyId )
	end
end

function Stage3_FoulLaunguage( replacer, playTypeReplacer )
	local storyId = "FOULLANGUAGE"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local papId = 0
		local fixture = Engine.GetCurrentGameFixtureData()
		local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
		local userTeam, cpuTeam = GetUserCpuTeamFromIds( team1, team2 )
		if( playTypeReplacer == "player" ) then
			papId = Engine.GetPlayAsPlayerID()
			Engine.SetStringPlayers( papId )
		end
		Engine.SetStringTeams( userTeam, cpuTeam )
		--local newNews = Engine.CreateNews( "OBJ", "news_title_foullanguage_postmatch_stage3_" .. playTypeReplacer .. "_" .. replacer .. "_", 4 )
		if( playTypeReplacer == "player" ) then
			Engine.SetStringPlayers( papId )
		end
		Engine.SetStringTeams( userTeam, cpuTeam )
		--Engine.AddParagraph( newNews, 1, "news_body_foullanguage_postmatch_stage3_" .. playTypeReplacer .. "_" .. replacer .. "_", 4 )
		--PublishArticle( currentStory, newNews, "MAJOR", userTeam, papId )
		Engine.AddDateEvent( "EndStory3", Tuning.FOULLANGUAGE.daysToEndStory, storyId )
		Engine.SetStoryStage( currentStory, 3 )
		Engine.AddDateEvent( "FoulEmail", Tuning.FOULLANGUAGE.daysToEmail, storyId )
	end
end

function Stage4_FoulLaunguage( replacer, playTypeReplacer )
	local storyId = "FOULLANGUAGE"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local papId = 0
		local fixture = Engine.GetCurrentGameFixtureData()
		local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
		local userTeam, cpuTeam = GetUserCpuTeamFromIds( team1, team2 )
		local stage = Engine.GetStoryStage( currentStory )
		if( playTypeReplacer == "player" ) then
			papId = Engine.GetPlayAsPlayerID()
			Engine.SetStringPlayers( papId )
		end
		Engine.SetStringTeams( userTeam, cpuTeam )
		if( stage == 3 ) then
			--PublishToReview( currentStory, "news_body_foullanguage_postmatch_stage4_" .. playTypeReplacer .. "_", 4, newsWeight )
			if( Engine.DoesNewsExist( "REVIEW" ) == true ) then
				local review = Engine.GetNewsById( "REVIEW" )
				Engine.SetStringTeams( userTeam, cpuTeam )
				if( playTypeReplacer == "player" ) then
					Engine.SetStringPlayers( papId )
				end
				--Engine.SetNewsHeadlineByObject( review, "news_title_foullanguage_postmatch_stage4_" .. playTypeReplacer .. "_", 4 )
			end
		end
		if( playTypeReplacer == "player" ) then
			Engine.SetStringPlayers( papId )
			Disipline_FoulLaunguage( playTypeReplacer )
			Engine.SetStoryStage( currentStory, 4 )
		else
			if( stage == 4 ) then
				Disipline_FoulLaunguage( playTypeReplacer )
				DiciplineNews_FoulLaunguage( storyId )
			else
				Engine.SetStoryStage( currentStory, 4 )
				Engine.AddDateEvent( "EndStory4", Tuning.FOULLANGUAGE.daysToEndStory, storyId )
			end
		end
		Engine.AddDateEvent( "FoulEmail", Tuning.FOULLANGUAGE.daysToEmail, storyId )
	end
end

function Disipline_FoulLaunguage( playTypeReplacer ) -- Disipline
	local storyId = "FOULLANGUAGE"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		if( playTypeReplacer == "player" ) then
			Engine.SetPapSelectionOverride( Tuning.FOULLANGUAGE.PapSelectionOverride )
		else
			local userTeam = Engine.GetUserTeam()
			Engine.SackManager( userTeam )
			Engine.SetStoryVariable( currentStory, "FIRED" )
		end
	end
end

function DiciplineNews_FoulLaunguage( storyId ) -- News of Disipline
	local userTeam = Engine.GetUserTeam()
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local papId = 0
		local playTypeReplacer = "manager"
		local isPap = Engine.IsPlayAsPlayer()
		if( isPap == true ) then
			playTypeReplacer = "player"
			papId = Engine.GetPlayAsPlayerID()
			Engine.SetStringPlayers( papId )
		end
		Engine.SetStringTeams( userTeam, cpuTeam )
		--local newNews = Engine.CreateNews( "OBJ", "news_title_foullanguage_postmatch_stage5_" .. playTypeReplacer .. "_", 4 )
		if( isPap == true ) then
			Engine.SetStringPlayers( papId )
		end
		Engine.SetStringTeams( userTeam, cpuTeam )
		--Engine.AddParagraph( newNews, 1, "news_body_foullanguage_postmatch_stage5_" .. playTypeReplacer .. "_", 4 )
		--PublishArticle( currentStory, newNews, "MAJOR", userTeam, papId )
		Engine.SetStoryStage( currentStory, 5 )
	end
end

function Email_FoulLanguage( storyId )
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local isPap = Engine.IsPlayAsPlayer()
		local stage = Engine.GetStoryStage( currentStory )
		local playTypeReplacer = "manager"
		local sender = "CM_Inbox_Sender_Board"
		local userName = Engine.GetUsername()
		local userTeam = Engine.GetUserTeam()
		if( isPap == true ) then
			playTypeReplacer = "player"
			sender = "CM_Inbox_Sender_Assistant Coach"
			papId = Engine.GetPlayAsPlayerID()
			Engine.SetStringPlayers( papId )
		end
		Engine.SetStringTeams( userTeam )
		if( stage == 2 ) then
			TriggerEmail( true, userName, sender, "CM_Email_Subject_foullanguage_postmatch_stage2_" .. playTypeReplacer .. "_", 1, 4, "CM_Email_body_foullanguage_postmatch_stage2_" .. playTypeReplacer .. "_", 1, 4 )
		elseif( stage == 3 ) then
			TriggerEmail( true, userName, sender, "CM_Email_Subject_foullanguage_postmatch_stage3_" .. playTypeReplacer .. "_", 1, 4, "CM_Email_body_foullanguage_postmatch_stage3_" .. playTypeReplacer .. "_", 1, 4 )
		elseif( stage == 4 ) then
			TriggerEmail( true, userName, sender, "CM_Email_Subject_foullanguage_postmatch_stage4_" .. playTypeReplacer .. "_", 1, 4, "CM_Email_body_foullanguage_postmatch_stage4_" .. playTypeReplacer .. "_", 1, 4 )
		end
	end
end

function FoulLaunguage_DynamicEvent( eventId, storyId )
	local storyId = "FOULLANGUAGE"
	local storyActive = Engine.IsStoryIDActive( storyId )
	if( storyActive == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		local stage = Engine.GetStoryStage( currentStory )
		if( eventId == "EndStory1" ) then
			if( stage == 1 ) then
				Engine.EndStoryId( storyId )
			end
		elseif( eventId == "EndStory2" ) then
			if( stage == 2 ) then
				Engine.EndStoryId( storyId )
			end
		elseif( eventId == "EndStory3" ) then
			if( stage == 3 ) then
				Engine.EndStoryId( storyId )
			end
		elseif( eventId == "EndStory4" ) then
			if( stage == 4 ) then
				Engine.EndStoryId( storyId )
			end
		elseif( eventId == "FoulEmail" ) then
			Email_FoulLanguage( storyId )
		elseif( eventId == "DiciplineNews" ) then
			DiciplineNews_FoulLaunguage( storyId )
		end
	end
end