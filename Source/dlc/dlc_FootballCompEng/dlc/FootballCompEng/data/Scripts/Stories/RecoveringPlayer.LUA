
function StartStory_OffSeason_PNFR( teamId, playerId, category, storyId )
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.INJURY.storyCoolDown ) == true ) then
		local userName = Engine.GetUsername()
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryVariable( currentStory, "OFFSEASON" )
		Engine.SetStringPlayer( playerId )
		Engine.SetStringTeam( teamId )
		TriggerEmail( false, userName, "CM_Inbox_Sender_Assistant Coach", "CM_Email_OffSeasonInjury_Subject_", 1, 1, "CM_Email_OffSeasonInjury_", 1, 1, "", "CM_Email_Transit_ToTeamManagement", "TEAM_MANAGEMENT", teamId, playerId )
	end --if( Engine.MarkPlayerForStory( teamId, playerId, category, "REC" ) == true ) then
end --if( Engine.InjurePlayerStillPlayable( userTeam, playerId, 50 ) ) then

function HasRecoveringPlayerTrigger()
	local category = "INJURED"
	local storyId = "REC"
	local userTeam = Engine.GetUserTeam()	
	if( Engine.GetNumStoriesWithId( storyId ) > 0 ) then
		local currentStory = Engine.GetStoryById( storyId )
		if( Engine.GetStoryVariable( currentStory ) == "OFFSEASON" ) then
			local storyPlayer = Engine.GetStoryPlayer( currentStory )
			Engine.SetStringTeam( userTeam )
			Engine.SetStringPlayer( storyPlayer )
			Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
			Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", userTeam )
			Engine.SetNewsBackgroundImage( "EXIT_DOOR" )
			TriggerNews( "News_Title_PlayerRecovery_", 1, 4, "News_Item_PlayerRecovery_SeasonOpener_", 1, 4, currentStory )
			Engine.SetStoryVariable( currentStory, "JUSTINJURED" )
		end
	end
end

function ExamineFor_PNFR( teamId, playerId, severity, returnDate )
	local category = "INJURED"
	local storyId = "REC"
	if( teamId == Engine.GetUserTeam() ) then
		local playerTier = Engine.GetPlayerTier( teamId, playerId )
		if( playerTier <= Tuning.INJURY.playerTier_TopPlayer ) then
			local currDate = Engine.GetCurrentDate()
			local daysBetween = Engine.GetNumDaysBetween( currDate, returnDate )
			if( daysBetween >= Tuning.INJURY.injuryDurationNeeded ) then
				if( Engine.IsPlayerInvolvedInStoryId( playerId, "POTRET" ) == false )then
					StartStory_PNFR( teamId, playerId, category, storyId )
				end --if( Engine.IsPlayerInvolvedInStoryId( playerId, "POTRET" ) == false )then
			end --if( daysBetween >= 14 ) then
		end --if( playerTier <= 2 ) then
	end --if( teamId == Engine.GetUserTeam() ) then
end

function StartStory_PNFR( teamId, playerId, category, storyId )
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryVariable( currentStory, "JUSTINJURED" )
	end
end

-- Triggered post user game
function InjuredPlayerRecoveredStoryLine( matchResult, gametype )
	if( gametype ~= "FRIENDLY" ) then
		local storyId = "REC"
		local numStories = Engine.GetNumStoriesWithId( "REC" )
		if( numStories > 0 ) then		
			for storyCount = 1, numStories do
				local currentStory = Engine.GetStoryById( storyId )
				local storyPlayer = Engine.GetStoryPlayer( currentStory )
				local injDate = Engine.GetStoryVariable( currentStory )
				local team = Engine.GetStoryTeam( currentStory )
				local playerPlayed = Engine.DidPlayerPlay( team, storyPlayer, matchResult )
				local matchWinner = Engine.GetMatchWinner( matchResult )
				local didStoryTeamWinGame = false
				local wasGameWon = Engine.WasGameWon( matchResult )
				local homeTeam, awayTeam = Engine.GetMatchResultTeamIds( matchResult )
				Engine.SetStringPlayer( storyPlayer )
				
				if( homeTeam == Engine.GetUserTeam() ) then
					Engine.SetStringTeam( homeTeam, 1 )
					Engine.SetStringTeam( awayTeam, 2 )
				else
					Engine.SetStringTeam( homeTeam, 2 )
					Engine.SetStringTeam( awayTeam, 1 )
				end
				
				if( injDate ~= "JUSTINJURED" ) then
					if( matchWinner == team ) then
						didStoryTeamWinGame = true
					end
					if( playerPlayed == true ) then		
						local didPlayerGetInjured = Engine.DidPlayerGetReinjured( team, storyPlayer, matchResult )
						local playerSubbedOff = Engine.DidPlayerGetSubbedOff( team, storyPlayer, matchResult )
						local playerRating = Engine.GetPlayerMatchRating( team, storyPlayer, matchResult )
						
						if( playerSubbedOff == true ) then
							if( didPlayerGetInjured == true ) then
								Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
								Engine.SetNewsBackgroundImage( "HOSPITAL" )
								TriggerNews( "News_Title_PlayerReinjured_", 1, 4, "News_Item_PlayerReinjured_", 1, 4, currentStory )
								
							else 
								Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
								Engine.SetNewsBackgroundImage( "EMPTY_STADIUM" )
								if( team == Engine.GetUserTeam() ) then
									Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" ) 
								end
								TriggerNews( "News_Title_InjuredPlayerSubbedEarly_", 1, 4, "News_Item_InjuredPlayerSubbedEarly_", 1, 4, currentStory )
								
							end
						else -- not subbed off	
							if( team == Engine.GetUserTeam() ) then
								Engine.SetNewsCinematic ( "CM_News_PlayerActionPositive" )
							end
							if( wasGameWon == true ) then
								if( playerRating > Tuning.INJURY.matchRating_Good ) then
									if( didStoryTeamWinGame == true ) then
										Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
										Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
										Engine.SetNewsBackgroundImage( "FULL_STADIUM" )
										TriggerNews( "News_Title_InjuredPlayer_PlayingWell_TeamWins_", 1, 4, "News_Item_InjuredPlayer_PlayingWell_TeamWins_", 1, 4, currentStory )
										
									else
										Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
										Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
										Engine.SetNewsBackgroundImage( "EMPTY_STADIUM" )
										TriggerNews( "News_Title_InjuredPlayer_PlayingWell_TeamLoses_", 1, 4, "News_Item_InjuredPlayer_PlayingWell_TeamLoses_", 1, 4, currentStory )
										
									end
								else 
									if( didStoryTeamWinGame == true ) then
										Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
										Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
										Engine.SetNewsBackgroundImage( "FULL_STADIUM" )
										TriggerNews( "News_Title_InjuredPlayer_PlayingBad_TeamWins_", 1, 4, "News_Item_InjuredPlayer_PlayingBad_TeamWins_", 1, 4, currentStory )
										
									else
										Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
										Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
										Engine.SetNewsBackgroundImage( "EMPTY_STADIUM" )
										TriggerNews( "News_Title_InjuredPlayer_PlayingBad_TeamLoses_", 1, 4, "News_Item_InjuredPlayer_PlayingBad_TeamLoses_", 1, 4, currentStory )
										
									end
								end	-- if( playerRating > 59 ) then	
							else	-- Drawn Game
								if( playerRating > Tuning.INJURY.matchRating_Good ) then
									Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
									Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
									Engine.SetNewsBackgroundImage( "FULL_STADIUM" )
									TriggerNews( "News_Title_InjuredPlayer_PlayingWell_TeamDraws_", 1, 4, "News_Item_InjuredPlayer_PlayingWell_TeamDraws_", 1, 4, currentStory )
									
								else 
									Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
									Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
									Engine.SetNewsBackgroundImage( "EMPTY_STADIUM" )
									TriggerNews( "News_Title_InjuredPlayer_PlayingBad_TeamDraws_", 1, 4, "News_Item_InjuredPlayer_PlayingBad_TeamDraws_", 1, 4, currentStory )
									
								end --if( playerRating > 59 ) then
							end	-- if( wasGameWon == true ) then
						end	-- if( playerSubbedOff == true ) then
					else	-- PLAYER DID NOT PLAY
						if( didStoryTeamWinGame == true ) then
							Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
							Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
							Engine.SetNewsBackgroundImage( "FOOTBALL_BOOT" )
							TriggerNews( "News_Title_InjuredPlayer_DidNotPlay_Won_", 1, 4, "News_Body_InjuredPlayer_DidNotPlay_Won_", 1, 4, currentStory )
							
						elseif( wasGameWon == true ) then
							Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
							Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
							Engine.SetNewsBackgroundImage( "FANS_CELEBRATING" )
							TriggerNews( "News_Title_InjuredPlayer_DidNotPlay_Lose_", 1, 4, "News_Body_InjuredPlayer_DidNotPlay_Lose_", 1, 4, currentStory )
							
						else
							Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
							Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team )
							Engine.SetNewsBackgroundImage( "HOSPITAL" )
							TriggerNews( "News_Title_InjuredPlayer_DidNotPlay_Draw_", 1, 4, "News_Body_InjuredPlayer_DidNotPlay_Draw_", 1, 4, currentStory )
							
						end -- if( didStoryTeamWinGame == true ) then
					end	-- if( playerPlayed == true ) then
					Engine.EndStoryId( storyId )
				end
			end --for storyCount = 1, numStories do
		end --if( numStories > 0 ) then
	end --if( gametype ~= "FRIENDLY" ) then
end

function RecoveringPlayerDaysBeforeGame( numDays, gametype, fixture )
	if( gametype ~= "FRIENDLY" ) then
		if( numDays == Tuning.INJURY.numDaysBeforeMatch ) then
			local storyId = "REC"
			local numStories = Engine.GetNumStoriesWithId( storyId )
			if( numStories > 0 ) then			
				for storyCount = 1, numStories do
					local currentStory = Engine.GetStoryById( storyId )
					local injDate = Engine.GetStoryVariable( currentStory )
					local storyPlayer = Engine.GetStoryPlayer( currentStory )	
					local team = Engine.GetStoryTeam( currentStory )
					if( injDate == "JUSTINJURED" ) then
						if( Engine.IsRecoveringFromInjury( team, storyPlayer ) == true or Engine.IsInjured( team, storyPlayer ) == false ) then
							Engine.AddConversation( storyPlayer, "PlayerFeedbackPopUp_PlayerRecoveringFromInjuryNotStarting_", 1, 8, "PlayerFeedbackPopUp_PlayerRecoveringFromInjuryNotStarting_subject", currentStory, true )
							Engine.SetStoryVariable( currentStory, "RECOVERED" )
						end
					end
				end --for storyCount = 1, numStories do
			end --if( numStories > 0 ) then
		end --if( numDays == 0 ) then
	end --if( gametype ~= "FRIENDLY" ) then
end