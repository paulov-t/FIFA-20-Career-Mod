function ExamineFor_PTH( teamId, playerId, oldHappiness, newHappiness )
	if( CanRunHappinessStories( playerId ) == true ) then
		local happiness = "UNKNOWN"
		if( ( newHappiness == "HIGH" and oldHappiness == "NORMAL" ) or ( newHappiness == "VERY_HIGH" and oldHappiness == "HIGH" ) ) then
			happiness = "HAPPY"
		end
		if( ( newHappiness == "LOW" and oldHappiness == "NORMAL" ) or ( newHappiness == "VERY_LOW" and oldHappiness == "LOW" ) ) then
			happiness = "UNHAPPY"
		end	
		local replacementPlayer = nil --FindReplacementPlayer( teamId, playerId )
		if( replacementPlayer ~= nil ) then
			--StartStory_PlayerFeelsReplaced( teamId, replacementPlayer )
		else
			FindPlayTimeUnhappyPlayers( teamId, playerId, oldHappiness, newHappiness, happiness )
		end
	end
end

function CanRunHappinessStories( playerId ) --Percentage through Season Check
	local canRun = false
	local percThroughSeason = Engine.GetPercentageThroughSeason()
	if( percThroughSeason >= Tuning.PTM.percentageThrough_Low and percThroughSeason <= Tuning.PTM.percentageThrough_High ) then
		if( Engine.GetPlayAsPlayerID() ~= playerId ) then
			if( Engine.IsPlayerOnLoanList( playerId ) == false and Engine.IsPlayerOnTransferList( playerId ) == false and Engine.IsRetiring( playerId ) == false and Engine.IsPlayerInvolvedInStoryId( playerId, "POTRET" ) == false ) then
				canRun = true
			end
		end
	end
	return canRun
end

function ClearHappyUnhappyStories() -- Clear stories
	local category = "HAPPY"
	Engine.EndStoryCategory( category )
end

function IsPlayerHappyOrUnhappy( teamId, playerId, promise )
	local mood = "NEITHER"
	local happiness = Engine.GetPlayTimeMorale( teamId, playerId )
	local contractHappiness = Engine.GetContractMoraleLevel( teamId, playerId )
	local wouldEvenLeaveClub = false
	if( promise == true ) then
		local oneClubPlayer = Engine.HasPlayerTrait( teamId, playerId, "ONE_CLUB_PLAYER" )
		local isListed = Engine.IsPlayerOnTransferList( playerId )
		local loanListed = Engine.IsPlayerOnLoanList( playerId )
		local inOnLoan = Engine.IsPlayerInOnLoan( teamId, playerId )
		local isRetiring = Engine.IsRetiring( playerId )
		if( oneClubPlayer == false and isListed == false and loanListed == false and inOnLoan == false and isRetiring == false ) then
			wouldEvenLeaveClub = true
		end
	else
		wouldEvenLeaveClub = WouldPlayerEvenLeaveClub( teamId, playerId )
	end
	if( happiness == "LOW" or happiness == "VERY_LOW" ) then
		if( contractHappiness ~= "HIGH" or contractHappiness ~= "VERY_HIGH" ) then
			if( wouldEvenLeaveClub == true ) then
				mood = "UNHAPPY"
			end
		end
	else
		mood = "HAPPY"
	end
	return mood
end

function FindPlayTimeUnhappyPlayers( teamId, playerId, oldHappiness, newHappiness, happiness )
	if( happiness == "HAPPY" ) then
		local success = RollPercentageDice( Tuning.PTM.chanceOfHappyStory )
		if( success == true ) then
			if( Engine.GetNumStoriesByCategory( "H-PLAYTIME" ) < Tuning.PTM.limitHappyStory ) then
				if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "H-PLAYTIME" ) ~= true ) then
					if( Engine.DidPlayInLastGame( teamId, playerId ) == true ) then
						local category = "HAPPY"
						local storyId = "HAPPY"
						local numStories = Engine.GetNumStoriesWithId( storyId )
						if( numStories == 0 ) then
							StartStory_PTH( teamId, playerId, storyId, category )
						else
							ChooseBestPlayer( teamId, playerId, storyId )
						end --if( numStories == 0 ) then
					end --if( Engine.DidPlayInLastGame( teamId, playerId ) == true ) then
				end --if( Engine.IsPlayerInvolvedInStoryCategory( happyPlayers[ playerIndex ], "H-PLAYTIME" ) ~= true ) then
			end --if( Engine.GetRandomNumber( 1, 2 ) == 1 ) then
		end
	elseif( happiness == "UNHAPPY" ) then
		if( Engine.GetNumStoriesByCategory( "PLAYTIME" ) <= Tuning.PTM.limitUnhappyStory ) then
			if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "PLAYTIME" ) ~= true ) then
				if( IsPlayerInvolvedInSaga( playerId ) ~= true ) then
					local inOnLoan = Engine.IsPlayerInOnLoan( teamId, playerId )
					if( inOnLoan == false ) then
						if( IsAbleToPlay( teamId, playerId ) == true ) then
							if( Engine.DidPlayInLastGame( teamId, playerId ) ~= true ) then
								local category = "UNHAPPY"
								local storyId = "UNHAPPY"
								local numStories = Engine.GetNumStoriesWithId( storyId )
								if( numStories == 0 ) then
									StartStory_PTH( teamId, playerId, storyId, category )
								else
									ChooseBestPlayer( teamId, playerId, storyId )
								end --if( numStories == 0 ) then
							end --if( Engine.IsPlayerInStartingLineup( teamId, playerId ) ~= true ) then
						end --if( IsAbleToPlay( teamId, unhappyPlayers[ playerIndex ] ) == true ) then
					end --if( inOnLoan == false ) then
				end --if( IsPlayerInvolvedInSaga( playerId ) ~= true ) then
			end --if( Engine.IsPlayerInvolvedInStoryCategory( unhappyPlayers[ playerIndex ], "PLAYTIME" ) ~= true ) then
		end --if( Engine.GetNumStoriesByCategory( "PLAYTIME" ) <= 5 ) then
	end --if( chooseType == "UNHAPPY" ) then
end

function StartStory_PTH( teamId, playerId, storyId, category )
	if( Engine.MarkPlayerForStory( teamId, playerId, storyId, category, Tuning.PTM.storyCoolDown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 6 )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		if( storyId == "HAPPY" ) then
			Engine.AddDateEvent( "HAPPYSTART", Tuning.PTM.stage1_Delay, storyId )
		elseif( storyId == "UNHAPPY" ) then
			Engine.AddDateEvent( "UNHAPPYSTART", Tuning.PTM.stage1_Delay, storyId )	
			Engine.SetStoryMoraleOverride( currentStory, Tuning.PTM.moraleOverride )
		end
	end --if( Engine.MarkPlayerForStory( teamId, happyPlayers[ playerIndex ], category, category ) == true ) then
end

function ExamineFor_PlayTimePromise( teamId, playerId, oldHappiness, newHappiness )
	local numStoryCats = Engine.GetNumStoriesByCategory( "PT_PROMISE" )
	if( numStoryCats <= 5 ) then
		if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "PT_PROMISE" ) ~= true ) then
			if( IsPlayerInvolvedInSaga( playerId ) ~= true ) then
				if( IsAbleToPlay( teamId, playerId ) == true ) then
					if( Engine.DidPlayInLastGame( teamId, playerId ) ~= true ) then
						local category = "PT_PROMISE"
						local storyId = "UNHAPPY" .. numStoryCats + 1
						local numStories = Engine.GetNumStoriesWithId( storyId )
						if( numStories == 0 ) then
							StartStory_PlayTimePromise( teamId, playerId, storyId, category )				
						end --if( numStories == 0 ) then
					end --if( Engine.IsPlayerInStartingLineup( teamId, playerId ) ~= true ) then
				end --if( IsAbleToPlay( teamId, unhappyPlayers[ playerIndex ] ) == true ) then
			end --if( IsPlayerInvolvedInSaga( playerId ) ~= true ) then
		end --if( Engine.IsPlayerInvolvedInStoryCategory( unhappyPlayers[ playerIndex ], "PLAYTIME" ) ~= true ) then
	end --if( Engine.GetNumStoriesByCategory( "PLAYTIME" ) <= 5 ) then
end

function StartStory_PlayTimePromise( teamId, playerId, storyId, category )
	if( Engine.MarkPlayerForStory( teamId, playerId, category, storyId, Tuning.PTM.storyCoolDown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 6 )
		local storyTeam = Engine.GetStoryTeam( currentStory )
		Engine.AddDateEvent( "PROMISESTART", Tuning.PTM.stage1_Delay, storyId )	
		Engine.SetStoryMoraleOverride( currentStory, Tuning.PTM.moraleOverride )
	end --if( Engine.MarkPlayerForStory( teamId, happyPlayers[ playerIndex ], category, category ) == true ) then
end

function ChooseBestPlayer( teamId, playerId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local dateAdded = Engine.GetStoryStartDate( currentStory )
	local currentDate = Engine.GetCurrentDate()
	if( Engine.GetNumDaysBetween( dateAdded, currentDate ) == 0 ) then
		local storyTeam = Engine.GetStoryTeam( currentStory )
		local storyPlayer = Engine.GetStoryPlayer( currentStory )
		if( teamId == storyTeam ) then
			local oldPlayerOverall = Engine.GetPlayerOverall( storyPlayer )
			local newPlayerOverall = Engine.GetPlayerOverall( playerId )
			if( newPlayerOverall > oldPlayerOverall ) then
				Engine.ReplaceStoryPlayer( currentStory, storyTeam, playerId )
			end --if( newPlayerOverall > oldPlayerOverall ) then
		end --if( teamId == storyTeam ) then
	end --if( Engine.GetNumDaysBetween( dateAdded, currentDate ) == 0 ) then
end

-- Happy Stage 1
function StartHappyStory()
	local category = "HAPPY"
	local storyId = "HAPPY"
	local currentStory = Engine.GetStoryById( storyId )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local tier = Engine.GetPlayerTier( storyTeam, storyPlayer )
	Engine.SetStringTeam( storyTeam )
	Engine.SetStringPlayer( storyPlayer )
	Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
	Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
	Engine.SetNewsBackgroundImage( "CONTRACT" )
	local starPlayer = Engine.IsStarPlayer( storyPlayer )
	local rand = Engine.GetRandomNumber( 1, 2 )
	local scene = "CM_News_PlayerActionPositive"
	if( starPlayer == true and rand == 1) then
		scene = "CM_News_PlayerPromo"
	end
	Engine.SetNewsCinematic( scene )
	if( tier == 1 ) then
		TriggerNews( "news_title_happyplayer_tier1_", 1, 4, "news_body_happyplayer_tier1_", 1, 4, currentStory )
		Engine.AddConversation( storyPlayer, "popup_happy_tier1_", 1, 4, "popup_happy_subject", currentStory )
	elseif( tier == 2 ) then
		TriggerNews( "news_title_happyplayer_tier1_", 1, 4, "news_body_happyplayer_tier1_", 1, 4, currentStory )
		Engine.AddConversation( storyPlayer, "popup_happy_tier2_", 1, 4, "popup_happy_subject", currentStory )
	elseif( tier == 3 ) then	
		TriggerNews( "news_title_happyplayer_tier3_", 1, 4, "news_body_happyplayer_tier3_", 1, 4, currentStory )
		Engine.AddConversation( storyPlayer, "popup_happy_tier3_", 1, 4, "popup_happy_subject", currentStory )
	elseif( tier == 4 ) then
		TriggerNews( "news_title_happyplayer_tier3_", 1, 4, "news_body_happyplayer_tier3_", 1, 4, currentStory )
		Engine.AddConversation( storyPlayer, "popup_happy_tier4_", 1, 4, "popup_happy_subject", currentStory )
	else --if( tier == 4 ) then	
		TriggerNews( "news_title_happyplayer_tier3_", 1, 4, "news_body_happyplayer_tier3_", 1, 4, currentStory )
		Engine.AddConversation( storyPlayer, "popup_happy_tier5_", 1, 4, "popup_happy_subject", currentStory )
	end	
	local numCat = ( Engine.GetNumStoriesByCategory( "H-PLAYTIME" ) + 1 )
	if( Engine.MarkPlayerForStory( storyTeam, storyPlayer, "H-PLAYTIME", "H-PLAYTIME" .. numCat ) == true ) then
		Engine.EndStoryCategory( category, true )
	end
end

-- Unhappy Stage 1
function StartUnhappyStory( eventId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local tier = Engine.GetPlayerTier( storyTeam, storyPlayer )
	Engine.SetStoryStage( currentStory, 1 )
	Engine.SetStringTeam( storyTeam )
	Engine.SetStringPlayer( storyPlayer )
	if( eventId == "PROMISESTART" ) then
		Engine.AddConversation( storyPlayer, "popup_unhappy_playtimepromise_", 1, 4, "popup_unhappy_playtimepromise_subject", currentStory, true )
		Engine.AddDateEvent( "STORYDELAY", Tuning.PTM.stage1News_delay, storyId )
	else
		if( tier == 1 ) then				
			Engine.AddConversation( storyPlayer, "popup_unhappy_tier1_", 1, 4, "popup_unhappy_tier1_subject", currentStory, true )
			Engine.AddDateEvent( "STORYDELAY", Tuning.PTM.stage1News_delay, storyId )
		elseif( tier == 2 ) then				
			Engine.AddConversation( storyPlayer, "popup_unhappy_tier2_", 1, 4, "popup_unhappy_tier2_subject", currentStory, true )
			Engine.AddDateEvent( "STORYDELAY", Tuning.PTM.stage1News_delay, storyId )
		elseif( tier == 3 ) then				
			Engine.AddConversation( storyPlayer, "popup_unhappy_tier3_", 1, 4, "popup_unhappy_subject", currentStory, true )
			Engine.AddDateEvent( "STORYDELAY", Tuning.PTM.stage1News_delay, storyId )
		elseif( tier == 4 ) then
			Engine.AddConversation( storyPlayer, "popup_unhappy_tier4_", 1, 4, "popup_unhappy_subject", currentStory, true )
			Engine.AddDateEvent( "STORYDELAY", Tuning.PTM.stage1News_delay, storyId )
		else --if( tier == 5 ) then				
			Engine.AddConversation( storyPlayer, "popup_unhappy_tier5_", 1, 4, "popup_unhappy_subject", currentStory, true )
			Engine.AddDateEvent( "STORYDELAY", Tuning.PTM.stage1News_delay, storyId )
		end
	end
	local dateEventName = "UNHAPPY_ST"
	Engine.AddDateEvent( dateEventName, Tuning.PTM.stage2_Delay, storyId )
end

function PlayTimeUnhappyNewsStory( eventId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local tier = Engine.GetPlayerTier( storyTeam, storyPlayer )
	Engine.SetStringTeam( storyTeam )
	Engine.SetStringPlayer( storyPlayer )	
	Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", storyPlayer )
	Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", storyTeam )
	Engine.SetNewsBackgroundImage( "WRITING_LETTER" )
	if( tier == 1 ) then
		Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" )
		TriggerNews( "news_title_unhappyplayer_tier1_", 1, 4, "news_body_unhappyplayer_tier1_", 1, 4, currentStory )
	elseif( tier == 2 ) then
		Engine.SetNewsCinematic ( "CM_News_PlayerActionNegative" )
		TriggerNews( "news_title_unhappyplayer_tier1_", 1, 4, "news_body_unhappyplayer_tier1_", 1, 4, currentStory )
	elseif( tier == 3 ) then
		TriggerNews( "news_title_unhappyplayer_tier3_", 1, 4, "news_body_unhappyplayer_tier3_", 1, 4, currentStory )
	elseif( tier == 4 ) then
		TriggerNews( "news_title_unhappyplayer_tier3_", 1, 4, "news_body_unhappyplayer_tier3_", 1, 4, currentStory )
	else --if( tier == 5 ) then				
		TriggerNews( "news_title_unhappyplayer_tier3_", 1, 4, "news_body_unhappyplayer_tier3_", 1, 4, currentStory )
	end --if( tier == 1 ) then
end

-- Continue Unhappy now happy
function ContinueUnhappyNowHappyStory( teamId, playerId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local tier = Engine.GetPlayerTier( teamId, playerId )
	if( tier == 1 ) then
		Engine.AddConversation( playerId, "popup_unhappy_nowhappy_tier_1_", 1, 4, "popup_unhappy_nowhappy_subject", currentStory )
	elseif( tier == 2 ) then
		Engine.AddConversation( playerId, "popup_unhappy_nowhappy_tier_2_", 1, 4, "popup_unhappy_nowhappy_subject", currentStory )
	elseif( tier == 3 ) then
		Engine.AddConversation( playerId, "popup_unhappy_nowhappy_tier_3_", 1, 4, "popup_unhappy_nowhappy_subject", currentStory )
	elseif( tier == 4 ) then
		Engine.AddConversation( playerId, "popup_unhappy_nowhappy_tier_4_", 1, 4, "popup_unhappy_nowhappy_subject", currentStory )
	else
		Engine.AddConversation( playerId, "popup_unhappy_nowhappy_tier_5_", 1, 4, "popup_unhappy_nowhappy_subject", currentStory )
	end
	playTimeEnding( teamId, playerId, storyId )
end

function PlayTimeHappinessDynamicEvent( eventId, storyId )
	if( string.find( storyId, "HAPPY" ) ~= nil ) then
		if( eventId == "HAPPYSTART" ) then
			StartHappyStory( eventId, storyId  )
		elseif( eventId == "UNHAPPYSTART" or eventId == "PROMISESTART" ) then
			StartUnhappyStory( eventId, storyId )
		elseif( eventId == "UNHAPPY_ST" ) then
			PlayTimeUnhappinessStage2( eventId, storyId )
		elseif( eventId == "LOAN_ME" ) then
			PlayTimeListedNewsStory( eventId, storyId )
		elseif( eventId == "LIST_ME" ) then
			PlayTimeListedNewsStory( eventId, storyId  )
		elseif( eventId == "STORYDELAY" ) then
			PlayTimeUnhappyNewsStory( eventId, storyId  )
		elseif( eventId == "FINALDELAY" ) then
			PlayTimeUnhappinessListMeDynamic( eventId, storyId  )
		end --if( string.find( eventId, "UNHAPPY" ) ~= nil ) then
	end
end

-- Stage 2 still unhappy with playtime so list/loan me or now or I'm happy
function PlayTimeUnhappinessStage2( eventId, storyId ) -- Pay Special attention to this little fella
	local currentStory = Engine.GetStoryById( storyId )
	local playerId = Engine.GetStoryPlayer( currentStory )
	local teamId = Engine.GetStoryTeam( currentStory )
	local happiness = "HAPPY"
	local promise = Engine.IsPlayerInvolvedInStoryCategory( playerId, "PT_PROMISE" )
	if( promise == true ) then
		happiness = IsPlayerHappyOrUnhappy( teamId, playerId, true )
	else
		happiness = IsPlayerHappyOrUnhappy( teamId, playerId, false )
	end
	Engine.SetStoryStage( currentStory, 2 )
	if( happiness == "UNHAPPY" ) then
		local success = RollPercentageDice( Tuning.PTM.chanceTransferRequest )
		if( success == true ) then -- Chance to ask for transfer/loan listng -- <= 2
			if( CanRunHappinessStories( playerId ) == true ) then
				if( IsAbleToPlay( teamId, playerId ) == true ) then
					if( Engine.DidPlayInLastGame( teamId, playerId ) ~= true ) then
						local tier = Engine.GetPlayerTier( teamId, playerId )	
						Engine.SetStringTeam( teamId )
						Engine.SetStringPlayer( playerId )
						if( tier <= 2 ) then
							local listed = Engine.IsPlayerOnTransferList( playerId )
							if( listed == false ) then
								Engine.AddConversation( playerId, "popup_unhappy_stage2_tier1_", 1, 4, "popup_unhappy_stage2_tier1_subject", currentStory )
								Engine.SetStoryVariable( currentStory, "LIST_ME" )
								storyEnd = false
							end
						else
							local loaned = Engine.IsPlayerOnLoanList( playerId )
							if( loaned == false ) then
								Engine.AddConversation( playerId, "popup_unhappy_stage2_tier3_", 1, 4, "popup_unhappy_stage2_tier3_subject", currentStory )
								Engine.SetStoryVariable( currentStory, "LOAN_ME" )
								storyEnd = false
							end
						end
					end --if( Engine.IsPlayerInStartingLineup( teamId, playerId ) ~= true ) then
				end --if( IsAbleToPlay( teamId, playerId ) == true ) then
			end --if( CanRunHappinessStories( playerId ) == true ) then
		end --if( Engine.GetRandomNumber( 1, 5 ) <= 2 ) then
	elseif( happiness == "HAPPY" ) then
		storyEnd = false
		ContinueUnhappyNowHappyStory( teamId, playerId, storyId )
	end  --if( happiness == "UNHAPPY" ) then
	if( storyEnd == true ) then
		playTimeEnding( teamId, playerId, storyId )
	end
end

function PlayTimeListedNewsStory( eventId, storyId ) -- Dynamic Event to Follow up to being listed
	local currentStory = Engine.GetStoryById( storyId )
	local playerId = Engine.GetStoryPlayer( currentStory )
	local teamId = Engine.GetStoryTeam( currentStory )
	local storyVar = Engine.GetStoryVariable( currentStory )
	local listed = Engine.IsPlayerOnTransferList( playerId )
	local loaned = Engine.IsPlayerOnLoanList( playerId )
	Engine.SetStringTeam( teamId )
	Engine.SetStringPlayer( playerId )
	if( storyVar == "LOAN_ME" and loaned == true ) then
		Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE" )
		TriggerNews( "news_title_playtimemorale_tier3_PressCommentsOnListing_", 1,1, "news_body_playtimemorale_tier3_PressCommentsOnListing_", 1, 1, currentStory )
	elseif( storyVar == "LIST_ME" and listed == true ) then
		Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE" )
		TriggerNews( "news_title_playtimemorale_tier1_PressCommentsOnListing_", 1,1, "news_body_playtimemorale_tier1_PressCommentsOnListing_", 1, 1, currentStory )
	elseif( storyVar == "LIST_ME" and listed == false and loaned == true ) then	-- player put on wrong list
		Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE" )
		Engine.ModifyPlayerMorale( teamId, playerId, Tuning.PTM.wrongList_PTM_Morale )
		TriggerNews( "news_title_playtimemorale_listme_wronglist_", 1,4, "news_body_playtimemorale_listme_wronglist_", 1, 2, currentStory )
	elseif( storyVar == "LOAN_ME" and listed == false and loaned == true ) then	-- player put on wrong list
		Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE" )
		Engine.ModifyPlayerMorale( teamId, playerId, Tuning.PTM.wrongList_PTM_Morale )
		TriggerNews( "news_title_playtimemorale_loanme_wronglist_", 1,4, "news_body_playtimemorale_loanme_wronglist_", 1, 2, currentStory )
	end
	Engine.SetStoryStage( currentStory, 3 )
end

function PlayTimeUnhappinessMonthlyAppeal() --Month Passed Events
	local category = "UNHAPPY"
	for storyType = 1, 2 do
		if( storyType == 2 ) then
			category = "PT_PROMISE"
		end
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			for storyCount = numStories, 1, -1 do
				local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
				local storyId = Engine.GetStoryId( currentStory )
				if( Engine.GetStoryStage( currentStory ) >= 2 ) then
					local storyEnd = true
					local storyTeam = Engine.GetStoryTeam( currentStory )
					local storyPlayer = Engine.GetStoryPlayer( currentStory )
					local happiness = "HAPPY"
					local promise = Engine.IsPlayerInvolvedInStoryCategory( storyPlayer, "PT_PROMISE" )
					if( promise == true ) then
						happiness = IsPlayerHappyOrUnhappy( storyTeam, storyPlayer, true )
					else
						happiness = IsPlayerHappyOrUnhappy( storyTeam, storyPlayer, false )
					end
					if( happiness == "UNHAPPY" ) then
						if( IsAbleToPlay( storyTeam, storyPlayer ) == true ) then
							if( Engine.IsWithinTransferWindow() == true ) then
								if( Engine.GetPlayerTier( storyTeam, storyPlayer ) <= 2 ) then --Jan
									Engine.AddConversation( storyPlayer, "popup_unhappy_InsideWindow_tier1_", 1, 4, "popup_unhappy_InsideWindow_tier1_subject", currentStory )
								else
									Engine.AddConversation( storyPlayer, "popup_unhappy_InsideWindow_tier3_", 1, 4, "popup_unhappy_InsideWindow_tier1_subject", currentStory )
								end
							elseif( Engine.IsInPreSeason() == true ) then
								if( Engine.GetPlayerTier( storyTeam, storyPlayer ) <= 2 ) then --Summer transfer Window
									Engine.AddConversation( storyPlayer, "popup_unhappy_OffSeason_tier1_", 1, 4, "popup_unhappy_OffSeason_tier1_subject", currentStory )
								else
									Engine.AddConversation( storyPlayer, "popup_unhappy_OffSeason_tier3_", 1, 4, "popup_unhappy_OffSeason_tier1_subject", currentStory )
								end
							else
								if( Engine.GetPlayerTier( storyTeam, storyPlayer ) <= 2 ) then --Mid season
									Engine.AddConversation( storyPlayer, "popup_unhappy_MidSeason_tier1_", 1, 4, "popup_unhappy_MidSeason_tier1_subject", currentStory )
								else
									Engine.AddConversation( storyPlayer, "popup_unhappy_MidSeason_tier3_", 1, 4, "popup_unhappy_MidSeason_tier1_subject", currentStory )
								end
							end --if( Engine.IsWithinTransferWindow() == true ) then
							storyEnd = false
							Engine.SetStoryStage( currentStory, 5 )
						end --if( IsAbleToPlay( teamId, playerId ) == true ) then
					elseif( happiness == "HAPPY" ) then
						storyEnd = false
						ContinueUnhappyNowHappyStory( storyTeam, storyPlayer, storyId )
					end --if( IsPlayerHappyOrUnhappy( storyTeam, storyPlayer ) == "UNHAPPY" ) then
					if( storyEnd == true ) then
						playTimeEnding( storyTeam, storyPlayer, storyId )
					end
				end --if( Engine.GetStoryStage( currentStory ) > 2 ) then
			end
		end --if( numStories > 0 ) then
	end
end

function PlayTimeListedPlayer( teamId, playerId, leagueId, marketValue, currency )
	local category = "UNHAPPY"
	local numStories = 0
	if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "UNHAPPY" ) == true ) then
		numStories = Engine.GetNumStoriesByCategory( category )
	elseif( Engine.IsPlayerInvolvedInStoryCategory( playerId, "PT_PROMISE" ) == true ) then
		category = "PT_PROMISE"
		numStories = Engine.GetNumStoriesByCategory( category )
	end
	if( numStories > 0 ) then
		for storyCount = 1, numStories do
			local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
			local storyId = Engine.GetStoryId( currentStory )
			local storyVar = Engine.GetStoryVariable( currentStory )
			if( storyVar == "LOAN_ME" ) then
				Engine.AddDateEvent( "LOAN_ME", Tuning.PTM.listedNews_Delay, storyId )
			elseif( storyVar == "LIST_ME" ) then
				Engine.AddDateEvent( "LIST_ME", Tuning.PTM.listedNews_Delay, storyId )
			end
		end
	end --if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "UNHAPPY" ) ) then
end

function PlayTimeBoardWarning( numDays )
	if( numDays == 1 ) then
		local category = "UNHAPPY"
		for storyType = 1, 2 do
			if( storyType == 2 ) then
				category = "PT_PROMISE"
			end
			local numStories = Engine.GetNumStoriesByCategory( category )
			if( numStories > 0 ) then
				for storyCount = 1, numStories do
					local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
					if( Engine.GetStoryStage( currentStory ) >= 2 ) then
						local storyPlayer = Engine.GetStoryPlayer( currentStory )
						local storyTeam = Engine.GetStoryTeam( currentStory )
						local storyVar = Engine.GetStoryVariable( currentStory )
						local listed = Engine.IsPlayerOnTransferList( storyPlayer )
						local loaned = Engine.IsPlayerOnLoanList( storyPlayer )
						local userName = Engine.GetUsername()
						Engine.SetStringTeam( storyTeam )
						Engine.SetStringPlayer( storyPlayer )
						if( listed == false and loaned == false ) then
							if( storyVar == "LIST_ME" ) then
								TriggerEmail( false, userName, "CM_Inbox_Sender_Board", "CM_Email_Subject_playtimemorale_BoardSuggestion_Tier1_", 1, 1, "CM_Email_Body_playtimemorale_BoardSuggestion_Tier1_", 1, 1 )
							else
								TriggerEmail( false, userName, "CM_Inbox_Sender_Board", "CM_Email_Subject_playtimemorale_BoardSuggestion_Tier3_", 1, 1, "CM_Email_Body_playtimemorale_BoardSuggestion_Tier3_", 1, 1 )
							end
							Engine.SetStoryStage( currentStory, 4 )
						end --if( listed == false and loaned == false ) then
					end --if( Engine.GetStoryStage( currentStory ) >= 2 ) then
				end --if( numStories > 0 ) then
			end
		end --if( numDays == 1 ) then
	end
end

function PlayTimeUnhappinessListMe( numDays )
	if( numDays == 0 ) then
		local category = "UNHAPPY"
		for storyType = 1, 2 do
			if( storyType == 2 ) then
				category = "PT_PROMISE"
			end
			local numStories = Engine.GetNumStoriesByCategory( category )
			if( numStories > 0 ) then
				if( success == true ) then
					for storyCount = 1, numStories do
						local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
						local storyId = Engine.GetStoryId( currentStory )
						if( Engine.GetStoryStage( currentStory ) >= 2 ) then
							local randDay = Engine.GetRandomNumber( Tuning.PTM.stage3_Delay_Min, Tuning.PTM.stage3_Delay_Max )
							Engine.AddDateEvent( "FINALDELAY", randDay, storyId )
						end
					end
				end --if( numStories == 1 ) then
			end --if( numDays == 0 ) then
		end
	end -- if( numDays == 0 ) then
end

-- Marked As Stage 2.1 in the design, potentially not listed so unhappy
function PlayTimeUnhappinessListMeDynamic( eventId, storyId )
	local currentStory = Engine.GetStoryById( storyId )
	local storyPlayer = Engine.GetStoryPlayer( currentStory )
	local storyTeam = Engine.GetStoryTeam( currentStory )
	local storyVar = Engine.GetStoryVariable( currentStory )
	local listed = Engine.IsPlayerOnTransferList( storyPlayer )
	local loaned = Engine.IsPlayerOnLoanList( storyPlayer )
	--Start Fool
	Engine.SetStringTeam( storyTeam )
	Engine.SetStringPlayer( storyPlayer )
	if( storyVar == "LIST_ME" and listed == true and loaned == false ) then	-- player got what he wants
		-- Nothing
	elseif( storyVar == "LIST_ME" and listed == false and loaned == false ) then	-- player not on any list
		Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.PTM.ignored_PTM_Morale )
		Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE" )
		TriggerNews( "news_title_playtimemorale_listme_notlisted_", 1, 4, "news_body_playtimemorale_listme_notlisted_", 1, 2, currentStory )
	elseif( storyVar == "LOAN_ME" and listed == false and loaned == true ) then	-- player got what he wants
		--Nothing
	elseif( storyVar == "LOAN_ME" and listed == false and loaned == false ) then	-- player not on any list
		Engine.ModifyPlayerMorale( storyTeam, storyPlayer, Tuning.PTM.ignored_PTM_Morale )
		Engine.SetNewsBackgroundImage( "PRESS_CONFERENCE" )
		TriggerNews( "news_title_playtimemorale_loanme_notlisted_", 1, 4, "news_body_playtimemorale_loanme_notlisted_", 1, 2, currentStory )
	end
	Engine.SetStoryStage( currentStory, 6 )
	playTimeEnding( storyTeam, storyPlayer, storyId )
end

function playTimeEnding( teamId, playerId, storyId )
	local numCat = ( Engine.GetNumStoriesByCategory( "PLAYTIME" ) + 1 )
	if( Engine.MarkPlayerForStory( teamId, playerId, "PLAYTIME", "PLAYTIME" .. numCat ) == true ) then
		Engine.EndStoryId( storyId )
	end
end