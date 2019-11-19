function ExamineFor_OverPricedDeal( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue )
	local userTeam = Engine.GetUserTeam()
	local teamId = Engine.GetTeamIdFromPlayerId( playerId )
	if( teamId ~= buyingTeam ) then
		if( buyingTeam == userTeam or sellingTeam == userTeam ) then
			local differenceLesser = Tuning.OVERPRICED.differenceLesser
			local differenceGreater = Tuning.OVERPRICED.differenceGreater
			price = price + exchangeValue
			local difference = ( price / playerValue ) * 100
			local storyId = ""
			if( difference <= differenceLesser ) then
				storyId = "UNDERPRICED"
			elseif( difference >= differenceGreater ) then
				storyId = "OVERPRICED"
			end
			local isCpu = true
			if( sellingTeam == userTeam ) then
				isCpu = false
			end
			if( storyId ~= "" ) then
				StartStory_OverPricedDeal( sellingTeam, playerId, storyId, buyingTeam, price, wage, playerValue, isCpu )
			end
		end
	end
end

function StartStory_OverPricedDeal( teamId, playerId, category, buyingTeam, price, wage, playerValue, isCpu  )
	local numStories = Engine.GetNumStoriesByCategory( category )
	storyId = category .. "_" .. numStories
	local userTeam = Engine.GetUserTeam()
	local overPricedCooldown = Tuning.OVERPRICED.overPricedCooldown
	if( Engine.MarkPlayerForStory( userTeam, playerId, category, storyId, overPricedCooldown ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		Engine.SetStoryPriority( currentStory, 2 )
		local form = GetFormValueUserCpu( teamId, playerId, isCpu )
		local morale = Engine.GetPlayerMoraleLevel( teamId, playerId )
		Engine.SetStringPlayers( playerId )
		Engine.SetStringTeams( teamId, buyingTeam )
		Engine.SetStringCurrency( price )
		local newNews = Engine.CreateNews( "OVERPRICED", "news_title_overpriceddeal_overpriced_", 4 )
		Engine.SetNewsForegroundImage( "LEFT", "CLUB_CREST", teamId, newNews )
		Engine.SetNewsForegroundImage( "CENTER", "PLAYER_IMG", playerId, newNews )
		Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", buyingTeam, newNews )
		Engine.SetNewsBackgroundImage( "MONEY", newNews )
		local newsWeight = Tuning.OVERPRICED.newsWeight
		for paragraphCount = 1, 3 do
			local append = ""
			local numVar = 3
			if( paragraphCount == 1 ) then
				local priceType = ""
				local formType = ""
				local formSuccess = false
				local ageSuccess = false
				if( category == "OVERPRICED" ) then
					priceType = "overpriced_"
				else
					Engine.SetStringPlayers( playerId )
					Engine.SetStringTeams( teamId, buyingTeam )
					Engine.SetStringCurrency( price )
					priceType = "underpriced_"
					Engine.SetNewsHeadlineByObject( newNews, "news_title_overpriceddeal_underpriced_", 4 )
				end
				
				if( form == "GOOD" or form == "VERY_GOOD" ) then
					formType = "goodform_"
					formSuccess = true
				elseif( form == "BAD" or form == "VERY_BAD" ) then
					formType = "poorform_"
					formSuccess = true
				end
				if( formSuccess == true ) then
					append = priceType .. formType
				else
					if( priceType == "overpriced_" ) then
						local ageType = ""
						local age = Engine.GetPlayerAge( teamId, playerId )
						local overpricedOldAge = Tuning.OVERPRICED.overpricedOldAge
						local overpricedYoungAge = Tuning.OVERPRICED.overpricedYoungAge
						if( age > 28 ) then
							ageType = "old_"
						elseif( age < 24 ) then
							ageType = "young_"
						end
						append = ageType
					end
				end
				if( append == "" ) then
					formType = "neutralform_"
					append = priceType .. formType
				end
			elseif( paragraphCount == 2 ) then
				local moraleType = ""
				if( morale == "HIGH" or morale == "VERY_HIGH" ) then
					moraleType = "highmorale_"
					numVar = 2
				elseif( morale == "LOW" or morale == "VERY_LOW" ) then
					moraleType = "lowmorale_"
					numVar = 2
				else
					moraleType = "neutralmorale_"
				end
				append = moraleType
			else
				local area = Engine.GetPlayerPitchArea( teamId, playerId )
				local percThroughSeason = Engine.GetPercentageThroughSeason()
				if( percThroughSeason > Tuning.OVERPRICED.minPercentageThroughSeason ) then
					local statType = ""
					if( Engine.IsPlayerTopInStatLeagueOnly( teamId, playerId, "GOALS" ) == true ) then
						if( area ~= "GK" ) then
							statType = "topscorer_"
						end
					elseif( Engine.IsPlayerTopInStatLeagueOnly( teamId, playerId, "ASSISTS" ) == true ) then
						if( area ~= "GK" ) then
							statType = "topassists_"
						end
					elseif( Engine.IsPlayerTopInStatLeagueOnly( teamId, playerId, "CLEAN_SHEETS" ) == true ) then
						statType = "topcleansheets_"
					end
					append = statType
				end
			end
			Engine.SetStringPlayers( playerId )
			Engine.SetStringTeams( teamId, buyingTeam )
			Engine.SetStringCurrency( price )
			if( append ~= "" ) then
				newsWeight = newsWeight - 1
				Engine.AddParagraph( newNews, newsWeight, "news_body_overpriceddeal_" .. append, numVar )
			end
		end
		local isRival = Engine.AreTeamsRivals( buyingTeam, teamId )
		local isDerby = Engine.AreTeamsDerby( buyingTeam, teamId )
		if( isRival == true or isDerby == true ) then
			Engine.SetStringTeams( teamId, buyingTeam )
			Engine.SetStringPlayers( playerId )
			newsWeight = newsWeight - 1
			Engine.AddParagraph( newNews, newsWeight, "news_body_lost_topplayer_rivals_", 4 )
		end
		Engine.SetStoryAllowTransferNews( currentStory, false )
		PublishArticle( currentStory, newNews, "MAJOR", userTeam, playerId )
		Engine.KillStoryAfterMatch( currentStory )
	end
end

function GetFormValueUserCpu( teamId, playerId, isCpu )
	local form = ""
	if( isCpu == true ) then
		local teamStatObj, numStats = Engine.GetTeamStatObj( teamId )
		local matchNumber = Engine.GetCPUFormMatchNumber( teamStatObj, numStats )
		form = Engine.GetCPUPlayerForm( teamId, playerId, teamStatObj, numStats, matchNumber )
	else
		form = Engine.GetPlayerFormLevel( teamId, playerId )
	end
	return form
end
