-- "PREVIEW" news are blocked from C++ code in SendNews(), even if their logic is still kept in Lua code. So, they no longer get sent.

function ExamineFor_IMP( numDays, gametype, fixture )
	if( string.find( gametype, "INTERNATIONAL" ) == nil ) then
		if( numDays == Tuning.IMP.numDays ) then
			fixture = Engine.GetCurrentGameFixtureData()
			local matchImp = GetUserImportance()
			local canPreview = false
			local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
			local userTeam = Engine.GetUserTeam()
			local cpuId = team1
			if( team1 == userTeam ) then
				cpuId = team2
			end
			local secondLeg = false
            local matchSituationTypes = Engine.GetMatchSituationFromFixture(fixture)
            local hasSituationTypeLeague = Engine.HasMatchSituationType("SITUATION_TYPE_LEAGUE", matchSituationTypes)
            local isLeaguePlayoff = gametype == "LEAGUE" and hasSituationTypeLeague == false

            if( gametype == "CUP" or gametype == "SUPERCUP" or gametype == "PLAYOFF" or gametype == "CONTINENTAL" or gametype == "CUP_REPLAY" or isLeaguePlayoff == true) then
				local numGamesPlayed = Engine.GetNumberOfFixturesPlayedFromFixture( fixture )
				local numTotalGames = Engine.GetTotalFixturesPlayedFromFixture( fixture )
				if( numTotalGames == 2 and numGamesPlayed == 2  ) then
					secondLeg = true
				end
			end

			local chanceFormStory = RollPercentageDice( Tuning.IMP.chanceFormStoryPerc ) -- 50%
			if( chanceFormStory == true ) then
				local previewReady = Engine.DoesNewsExist( "PREVIEW" )
				local isCpu = false
				if( previewReady == true )then
					canPreview = true
					local percThroughSeason = Engine.GetPercentageThroughSeason()
					if( percThroughSeason > Tuning.IMP.percThroughSeason_FormStories ) then -- 30% through
						local chanceCpu = RollPercentageDice( Tuning.IMP.chanceCpuPerc ) -- 50%
						if( chanceCpu == true ) then
							isCpu = true
							teamId = userTeam
						else
							teamId = cpuId
						end
						--ExamineFor_FormStories( teamId, cpuId, isCpu )
					end
				elseif( matchImp >= Tuning.IMP.matchImp and secondLeg == false ) then --85
					canPreview = true
					local percThroughSeason = Engine.GetPercentageThroughSeason()
					if( percThroughSeason > Tuning.IMP.percThroughSeason_FormStories ) then  -- 30% through
						local chanceCpu = RollPercentageDice( Tuning.IMP.chanceCpuPerc ) -- 50%
						if( chanceCpu == true ) then
							isCpu = true
							teamId = userTeam
						else
							teamId = cpuId
						end
						--ExamineFor_FormStories( teamId, cpuId, isCpu )
					end
				end
			end
			ImportantMatchPreviewTableProcess( gametype, canPreview )
		end
	end
end

function ImportantMatchPreviewTableProcess( gametype, canPreview )
	local category = "IMPORTANT"
	if( Engine.GetNumStoriesByCategory( category ) > 0 ) then
		Engine.EndStoryCategory( category, false )
	end
	ImportantMatch( gametype, canPreview )
end

function CreateString_IMP( isPreview, type, time, subject, idType, idTime, idSubject )
	local stringId = ""
	local storyId = ""
	if( isPreview == true ) then
		stringId = type .. time .. subject
		storyId = idType .. "_" .. idSubject .. "_" .. idTime
	else
		stringId = type .. time .. subject
	end
	return stringId, storyId
end

function ImportantMatch( gametype, canPreview )
	local fixture = Engine.GetCurrentGameFixtureData()
	local comp = Engine.GetCompetitionFromFixture( fixture )
	local team1, team2 = Engine.GetTeamsFromFixtureData( fixture )
	local category = "IMPORTANT"
	local userTeam = Engine.GetUserTeam()
	local rivals = Engine.AreTeamsRivals( team1, team2 )
	local bigmatchups = Engine.AreTeamsBigMatchUps( team1, team2 )
	local derby = bigmatchups or Engine.AreTeamsDerby( team1, team2 )
	local teamPos1 = 0
	local teamPos2 = 0
	local teamFavourite = 0
	local teamUnder = 0
	local user = Engine.GetTeamName( team1 )
	local cpu = Engine.GetTeamName( team2 )
	local team1Pos = 0
	local team2Pos = 0
	local team1Skill = 0
	local team2Skill = 0
	local stringId = ""
	local storyId = ""
	
	local time = ""
	local type = ""
	local subject = ""
	local idType = ""
	local idTime = ""
	local idSubject = ""
	local isPreview = true
	
	if( team1 ~= userTeam ) then
		user = Engine.GetTeamName( team2 )
		cpu = Engine.GetTeamName( team1 )
	end	
	
    local matchSituationTypes = Engine.GetMatchSituationFromFixture(fixture)
    local hasSituationTypeLeague = Engine.HasMatchSituationType("SITUATION_TYPE_LEAGUE", matchSituationTypes)
    local isLeaguePlayoff = gametype == "LEAGUE" and hasSituationTypeLeague == false
    
--	if( gametype == "LEAGUE" and isLeaguePlayoff == false) then
--		local leagueId = Engine.GetLeagueId( userTeam )
--		team1Pos = Engine.GetLeaguePosition( team1 )
--		team2Pos = Engine.GetLeaguePosition( team2 )
--		local teamRelegated1 = Engine.IsTeamInRelegationZone( team1 )
--		local teamRelegated2 = Engine.IsTeamInRelegationZone( team2 )
--		local teamPromoted1 = Engine.IsTeamInPromotionZone( team1 )
--		local teamPromoted2 = Engine.IsTeamInPromotionZone( team2 )
--		local numTeams = Engine.GetNumberOfTeamsInLeague()
--		subject = "Generic_"
--		idSubject = "Generic"
--		
--		local numGamesPlayed = Engine.GetNumberOfFixturesPlayedFromFixture( fixture )
--		local numTotalGames = Engine.GetTotalFixturesPlayedFromFixture( fixture )
--		
--		if( team1Pos < team2Pos ) then
--			teamPos1 = Engine.GetLeaguePosition( team1 )
--			teamPos2 = Engine.GetLeaguePosition( team2 )
--		else
--			teamPos1 = Engine.GetLeaguePosition( team2 )
--			teamPos2 = Engine.GetLeaguePosition( team1 )
--		end
--		
--		--Tuning for Position Ranges
--		local percPos1 = ( ( teamPos1 / numTeams ) * 100 )
--		local percPos2 = ( ( teamPos2 / numTeams ) * 100 )
--		local bottom = Tuning.IMP.bottom -- Below 60%
--		local high = Tuning.IMP.high -- Above 25%
--		local low = Tuning.IMP.low -- Below 75%
--		local midHigh = Tuning.IMP.midHigh -- Range 1
--		local midLow = Tuning.IMP.midLow -- Range 2 between 66% and 33%
--		
--		--Tuning for Timing ( % through season )
--		local numGames = ( ( numGamesPlayed / numTotalGames ) * 100 )
--		local early = Tuning.IMP.early -- Below
--		local late = Tuning.IMP.late -- Above
--		
--		if( numGames >= late ) then
--			time = "Late_"
--			idTime = "Late"
--		elseif( numGames <= early ) then
--			time = "Early_"
--			idTime = "Early"
--		else
--			time = "Mid_"
--			idTime = "Mid"
--		end
--		
--		if( teamPos1 == 1 and numGames >= 10 ) then
--			if( teamPos2 == 2 ) then
--				subject = "FirstvsSecond_"
--				idSubject = "1v2"
--			elseif( teamPos2 <= 5 and teamPos2 >= 3 ) then
--				subject = "FirstvsThirdtoFifth_"
--				idSubject = "1v3to5"
--			elseif( time ~= "Early_" ) then
--				if( teamPos2 == numTeams ) then
--					subject = "FirstvsLast_"
--					idSubject = "1vLast"
--				elseif( teamRelegated2 == true or teamRelegated1 == true ) then
--					subject = "FirstvsRelegatedTeam_"
--					idSubject = "1vRel"
--				elseif( percPos2 >= bottom and teamRelegated2 == false and teamRelegated1 == false and teamPos2 ~= numTeams ) then
--					subject = "FirstvsBottom_"
--					idSubject = "1vBottom"
--				end
--			end
--		elseif( teamPos1 == 2 and teamPos2 <= 5 and teamPos2 >= 3 and numGames >= 10 ) then
--			subject = "SecondvsThirdtoFifth_"
--			idSubject = "2v3to5"
--		elseif( time ~= "Early_" ) then
--			if( percPos1 <= high and percPos2 <= high ) then
--				subject = "BothFifthOrAbove_"
--				idSubject = "BothHigh"
--			elseif( percPos1 <= high and percPos2 >= low ) then
--				subject = "HighvsLow_"
--				idSubject = "HvL"
--			elseif( percPos1 >= midLow and percPos1 <= midHigh and percPos2 >= midLow and percPos2 <= midHigh ) then
--				subject = "BothMidTable_"
--				idSubject = "BothMid"
--			elseif( percPos1 >= low and percPos2 >= low ) then
--				subject = "BothLow_"
--				idSubject = "BothLow"
--			elseif( time == "Late_" ) then
--				if( Engine.IsTeamInRelegationZone( team1 ) == true or Engine.IsTeamInRelegationZone( team2 ) ) then
--					subject = "AnyvsRelegatedTeam_"
--					idSubject = "Rel"
--				elseif( Engine.IsTeamInPromotionZone( userTeam ) == true or Engine.IsTeamInPromotionZone( userTeam ) == true ) then
--					subject = "AnyvsPromotedTeam_"
--					idSubject = "Pro"
--				end
--			end
--		else
--			subject = "Generic_"
--			idSubject = "Generic"
--		end
--		local previewExist = Engine.DoesNewsExist( "PREVIEW" )
--		if( previewExist == true ) then
--			canPreview = true
--		elseif( subject == "Generic_" and time == "Early_" ) then
--			if( rivals == false and derby == false ) then
--				local matchImportanceFix = RollPercentageDice( Tuning.IMP.matchImportanceFixPerc )
--				if( matchImportanceFix == true ) then
--					canPreview = false
--				end
--			end
--		end
--	else
	if( string.find( gametype, "LEAGUE" ) == nil) then
		team1Skill = Engine.GetTeamOverall( team1 )
		team2Skill = Engine.GetTeamOverall( team2 )
		
		if( team1Skill < team2Skill ) then
			teamFavourite = team2Skill
			teamUnder = team1Skill
		else
			teamFavourite = team1Skill
			teamUnder = team2Skill
		end
		
		if( gametype == "FRIENDLY" ) then
			type = "Friendly_"
			time = "Generic_"
			subject = "Generic_"
			idType = "FRIENDLY"
			idTime = "Gen"
			idSubject = "Generic"
		else
			-- Team Ranking
			local round = Engine.GetRoundFromCupFixtureData( fixture )
			local equal = Tuning.IMP.equal
			local goodHigh = Tuning.IMP.goodHigh
			local goodLow = Tuning.IMP.goodLow
			local averageHigh = Tuning.IMP.averageHigh
			local averageLow = Tuning.IMP.averageLow
			local small = Tuning.IMP.small
            
			if( round == "FINAL" ) then
				idTime = "Fin"
				time = "Final_"
			elseif( round == "SEMI" ) then
				idTime = "Semi"
				time = "SemiFinal_"
			elseif( round == "QTR" ) then
				idTime = "Qtr"
				time = "QuarterFinal_"
			else
				idTime = "Gen"
				time = "Generic_"
			end
			
			if( gametype == "CUP" or gametype == "CONTINENTAL" or gametype == "CUP_REPLAY" or isLeaguePlayoff == true) then
                if (isLeaguePlayoff == false) then
                    if( rivals == true ) then
                        idType = "CUPRIVALS"
                    elseif( derby == true ) then
                        idType = "CUPDERBY"
                    else
                        idType = "CUPM"
                    end
                    type = "Cup_"
                end
				
				if( ( teamFavourite - teamUnder ) <= equal ) then
					idSubject = "Equal"
					subject = "EqualTeams_"
				elseif( ( teamFavourite - teamUnder ) <= goodHigh and ( teamFavourite - teamUnder ) >= goodLow ) then
					idSubject = "BigvGood"
					subject = "BigvsGood_"
				elseif( ( teamFavourite - teamUnder ) >= small ) then
					idSubject = "BigvSmall"
					subject = "BigvsSmall_"
				elseif( ( teamFavourite - teamUnder ) <= averageHigh and ( teamFavourite - teamUnder ) >= averageLow ) then
					idSubject = "BigvAvg"
					subject = "BigvsAverage_"
				end
				
			elseif( gametype == "SUPERCUP" ) then
				idType = "SUPERCUP"
				type = "SuperCup_"
				idSubject= "Generic"
			
			elseif( gametype == "PLAYOFF" ) then
				if( rivals == true or derby == true ) then
					idType = "PORivals"
					idSubject= "Generic_"
				else	
					idType = "PO"
					idSubject= "Generic"
				end
				type = "Playoff_"
				
				if( round == "FINAL" ) then
					idTime = "Fin"
					time = "Final_"
				else
					idTime = "Gen"
					time = "Generic_"
				end
				
			end
		end
	end
	if( gametype ~= "SUPERCUP" and gametype ~= "FRIENDLY" ) then
        if (isLeaguePlayoff == true) then
            idType = "CUPM"
            type = "Cup_"
        elseif( rivals == true ) then
			if( gametype ~= "CUP" and gametype ~= "CONTINENTAL" and gametype ~= "PLAYOFF" and gametype ~= "CUP_REPLAY" ) then
				idType = "RIVALS"
				--type = "League_"
				subject = subject .. "Rivals_"
			else
				subject = "Rivals_"
			end
		elseif( derby == true ) then
			if( gametype ~= "CUP" and gametype ~= "CONTINENTAL" and gametype ~= "PLAYOFF" and gametype ~= "CUP_REPLAY" ) then
				idType = "DERBY"
				--type = "League_"
				subject = subject .. "Rivals_"
			else
				subject = "Rivals_"
			end
--		else
--			if( gametype == "LEAGUE" ) then
--                idType = "IMP"
--                type = "League_"
--			end
		end
	end
	stringId, storyId = CreateString_IMP( isPreview, type, time, subject, idType, idTime, idSubject )
	if( Engine.MarkPlayerForStory( userTeam, 0, "IMPORTANT", storyId ) == true ) then
		local currentStory = Engine.GetStoryById( storyId )
		if( canPreview == true ) then
			Engine.SetStringCompetition( comp )
			Engine.SetStringTeam( team1, 1 ) -- Home team
			Engine.SetStringTeam( team2, 2 ) -- Away
			
--			if( gametype == "LEAGUE" ) then			
--				if( team1Pos < team2Pos ) then
--					Engine.SetStringTeam( team1, 3 ) -- Stronger Team
--					Engine.SetStringTeam( team2, 4 ) -- Weaker
--				else
--					Engine.SetStringTeam( team2, 3 ) -- Stronger Team
--					Engine.SetStringTeam( team1, 4 ) -- Weaker
--				end
--			else
			if( string.find( gametype, "LEAGUE" ) == nil ) then
				if( team1Skill < team2Skill ) then
					Engine.SetStringTeam( team2, 3 ) -- Stronger Team
					Engine.SetStringTeam( team1, 4 ) -- Weaker
				else
					Engine.SetStringTeam( team1, 3 ) -- Stronger Team
					Engine.SetStringTeam( team2, 4 ) -- Weaker
				end
			end
			
			-- News Sending-------------------
			local previewReady = Engine.DoesNewsExist( "PREVIEW" )
			local newNews = nil
			if( previewReady == false ) then
				if( gametype ~= "FRIENDLY" ) then
					newNews = Engine.CreateNews( "PREVIEW", "News_Title_ImportantMatch_" .. stringId, 1 )
				end
			else
				newNews = Engine.GetNewsById( "PREVIEW" )
			end
			previewReady = Engine.DoesNewsExist( "PREVIEW" )
			if( previewReady == true ) then
				local validHeadline = Engine.HasValidHeadline( newNews )
				if( validHeadline == false ) then
					Engine.SetNewsHeadlineByObject( newNews, "News_Title_ImportantMatch_" .. stringId, 1 )
				end
				Engine.SetStringTeam( team1, 1 ) -- Home team
				Engine.SetStringTeam( team2, 2 ) -- Away
				local newsWeight = Tuning.IMP.importantMatchNewsWeight
				Engine.AddParagraph( newNews, newsWeight, "News_Body_ImportantMatch_" .. stringId, 1, user, cpu, user, cpu )
				Engine.SetNewsImportance( newNews, "PREVIEW" )
				Engine.SetNewsTeam( newNews, userTeam )
				Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", team1, newNews ) 
				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team2, newNews )
				Engine.SetNewsBackgroundImage( "FOOTBALL_PITCH", newNews )

				Engine.SendNews( newNews )
			end
			--News  Sending--------------------
		end
		
		Engine.SetStoryStage( currentStory, 1 )
--		if( gametype == "LEAGUE" ) then
--			if( team1Pos < team2Pos ) then
--				Engine.SetStoryVariable( currentStory, team1 )
--			else
--				Engine.SetStoryVariable( currentStory, team2 )
--			end
--		else
		if( string.find( gametype, "LEAGUE" ) == nil ) then		
			if( team1Skill < team2Skill ) then
				Engine.SetStoryVariable( currentStory, team2 )
			else
				Engine.SetStoryVariable( currentStory, team1 )
			end
		end
	end
	local previewNotFired = Engine.DoesNewsExist( "PREVIEW" )
	if( previewNotFired == true ) then
		Engine.DeleteNews( "PREVIEW" )
	end
end
-- remove news for league
function ImportantPostUserGame( matchResult, gametype, playType, matchSituationTypes )
	if( string.find( gametype, "INTERNATIONAL" ) == nil and string.find( gametype, "LEAGUE" ) == nil) then
		local category = "IMPORTANT"
		local matchImp = GetUserImportance()
		local numStories = Engine.GetNumStoriesByCategory( category )
		local reviewReady = Engine.DoesNewsExist( "REVIEW" )
		if( reviewReady == true or matchImp >= Tuning.IMP.matchImp ) then
			if( numStories < 1 ) then
				ImportantMatch( gametype, false )
			end
			if( numStories > 0 ) then
				local canReview = true
				local result = ""
				local type = ""
				local time = ""
				local subject = ""
				local team1, team2 = Engine.GetMatchResultTeamIds( matchResult )
				local currentStory = Engine.GetStoryByCategoryAndIndex( category, 1 )
				local storyId = Engine.GetStoryId( currentStory )
				local strongerTeam = tonumber( Engine.GetStoryVariable( currentStory ) )
				local weakerTeam = -1
				local comp = Engine.GetCompetitionFromResult( matchResult )
				local matchWinner = Engine.GetMatchWinner( matchResult )
				local matchLoser = -1
				local wasGameWon = Engine.WasGameWon( matchResult )
				local userTeam = Engine.GetUserTeam()
				local homeScore, awayScore = Engine.GetFinalScore( matchResult )
				local homeAgg, awayAgg = Engine.GetAggregateScore( matchResult )
				local winScore = homeScore
				local loseScore = awayScore
				local twoLeg = false
                local hasSituationTypeLeague = Engine.HasMatchSituationType("SITUATION_TYPE_LEAGUE", matchSituationTypes)
                local isLeaguePlayoff = gametype == "LEAGUE" and hasSituationTypeLeague == false
				
				local gamesPlayed = Engine.GetNumberOfFixturesPlayedFromResult( matchResult )
				local totalGames = Engine.GetTotalNumberOfFixturesFromResult( matchResult )
				if( reviewReady == false ) then
					if( gametype == "CUP" or gametype == "SUPERCUP" or gametype == "PLAYOFF" or gametype == "CONTINENTAL" or gametype == "CUP_REPLAY" or isLeaguePlayoff == true) then
						if( totalGames == 2 and gamesPlayed ~= totalGames ) then
							canReview = false
						end
					end
				end
				
				if( Engine.WasMatchForfeited( matchResult ) == false and team1 > 0 and team2 > 0 ) then
					local stringId = ""
					local situationTypeGroup = Engine.HasMatchSituationType("SITUATION_TYPE_GROUP", matchSituationTypes);
					
					if( awayScore > homeScore ) then
						winScore = awayScore
						loseScore = homeScore
					end
					
					if( matchWinner == team1 ) then
						matchLoser = team2
					else
						matchLoser = team1
					end
					
					if( strongerTeam == team1 ) then
						weakerTeam = team2
					else
						weakerTeam = team1
					end
					
					if( weakerTeam > 0 and matchLoser > 0 and matchWinner > 0 and strongerTeam > 0 ) then
						local penaltiesScore1, penaltiesScore2 = Engine.GetPenaltyScore( matchResult )
						if( gametype == "CUP" or gametype == "SUPERCUP" or gametype == "PLAYOFF" or gametype == "CUP_REPLAY" or (gametype == "CONTINENTAL" and not situationTypeGroup) ) then
							if( totalGames > 1 and gamesPlayed == totalGames ) then
								local homeTeamWon = false
								if (homeAgg ~= awayAgg) then
									homeTeamWon = homeAgg > awayAgg
								else
									homeTeamWon = penaltiesScore1 > penaltiesScore2
								end
								if( homeTeamWon ) then
									matchLoser = team2
									matchWinner = team1
									loseScore = loseScore .. " " .. "(" .. homeAgg .. "-" .. awayAgg .. " " .. Engine.LocaliseString( "aggregate_abbr3" ) .. ")"
								else
									matchLoser = team1
									matchWinner = team2
									loseScore = loseScore .. " " .. "(" .. awayAgg .. "-" .. homeAgg .. " " .. Engine.LocaliseString( "aggregate_abbr3" ) .. ")"
								end
							elseif( totalGames == 2 and gamesPlayed ~= totalGames ) then
								twoLeg = true
							end
						end
						
						local penScore1 = penaltiesScore1
						local penScore2 = penaltiesScore2
						if( penaltiesScore1 > 0 or penaltiesScore2 > 0 ) then
							if( penaltiesScore2 > penaltiesScore1 ) then
								penScore1 = penaltiesScore2
								penScore2 = penaltiesScore1
							end
							stringId = "wenttopenalties_"
						else						
							--if( gametype == "LEAGUE" and isLeaguePlayoff == false) then
								--------------------------------- League subject
							--	if( string.find( storyId, "1v2" ) ~= nil ) then
							----		subject = "FirstvsSecond_"
							--	elseif( string.find( storyId, "1v3to5" ) ~= nil ) then
							--		subject = "FirstvsThirdtoFifth_"
							--	elseif( string.find( storyId, "1vLast" ) ~= nil ) then
							--		subject = "FirstvsLast_"
							--	elseif( string.find( storyId, "1vRel" ) ~= nil ) then
							--		subject = "FirstvsRelegatedTeam_"
							--	elseif( string.find( storyId, "1vBottom" ) ~= nil ) then
							--		subject = "FirstvsBottom_"	
							--	elseif( string.find( storyId, "2v3to5" ) ~= nil ) then
							--		subject = "SecondvsThirdtoFifth_"
							--	elseif( string.find( storyId, "BothHigh" ) ~= nil ) then
							--		subject = "BothFifthOrAbove_"
							--	elseif( string.find( storyId, "HvL" ) ~= nil ) then
							--		subject = "HighvsLow_"
							--	elseif( string.find( storyId, "BothMid" ) ~= nil ) then
							--		subject = "BothMidTable_"
							--	elseif( string.find( storyId, "BothLow" ) ~= nil ) then
							--		subject = "BothLow_"
							--	elseif( string.find( storyId, "Rel" ) ~= nil ) then
							--		subject = "AnyvsRelegatedTeam_"
							--	elseif( string.find( storyId, "Pro_Late" ) ~= nil ) then
							--		subject = "AnyvsPromotedTeam_"
							--	elseif( string.find( storyId, "Generic" ) ~= nil ) then
							--		subject = "Generic_"
							--	end
							if( gametype == "CUP" or gametype == "CONTINENTAL" or gametype == "CUP_REPLAY" or isLeaguePlayoff == true) then
								if( string.find( storyId, "Equal" ) ~= nil ) then
									subject = "EqualTeams_"
								elseif( string.find( storyId, "CUPM_BigvGood" ) ~= nil ) then
									subject = "BigvsGood_"
								elseif( string.find( storyId, "BigvSmall" ) ~= nil ) then
									subject = "BigvsSmall_"
								elseif( string.find( storyId, "BigvAvg" ) ~= nil ) then
									subject = "BigvsAverage_"
								end
							end

							--------------------------------- CUP Subject
							if( string.find( storyId, "CUPRIVALS" ) ~= nil or string.find( storyId, "CUPDERBY" ) ~= nil ) then
								subject = "Rivals_"
								type = "Cup_"
							elseif( string.find( storyId, "IMP" ) ~= nil ) then
								type = "Cup_"
							elseif( string.find( storyId, "DERBY_" ) ~= nil or string.find( storyId, "RIVALS_" ) ~= nil ) then
								type = "Cup_"
							elseif( string.find( storyId, "CUPM" ) ~= nil ) then
								type = "Cup_"
							elseif( string.find( storyId, "SUPERCUP" ) ~= nil ) then
								type = "SuperCup_"
							elseif( string.find( storyId, "PO" ) ~= nil ) then
								type = "Playoff_"
							elseif( string.find( storyId, "FRIENDLY" ) ~= nil ) then
								type = "Friendly_"
							end
                            
                            if (isLeaguePlayoff == true) then
                                type = "Cup_"
                            end
							
						--	if( gametype == "LEAGUE" and isLeaguePlayoff == false) then
						--		if( string.find( storyId, "Late" )~= nil ) then
						--			time = "Late_"
						--		elseif( string.find( storyId, "Mid" )~= nil ) then
						--			time = "Mid_"
						--		elseif( string.find( storyId, "Early" )~= nil ) then
						--			time = "Early_"
						--		end
						--	else
								if( string.find( storyId, "Fin" )~= nil ) then
									if( twoLeg == true ) then
										time = "Generic_"
									else
										time = "Final_"
									end
								elseif( string.find( storyId, "Semi" )~= nil ) then
									time = "SemiFinal_"
								elseif( string.find( storyId, "Qtr" )~= nil ) then
									time = "QuarterFinal_"
								elseif( string.find( storyId, "Gen" )~= nil ) then
									time = "Generic_"
								end
						--	end
							
							if( wasGameWon ~= true ) then
								result = "Draw_"
							else
								if( matchWinner == strongerTeam ) then
									result = "Higher_Won_"
								else
									result = "Lower_Won_"
								end
							end
							stringId = CreateString_IMP( false, type, time, subject, "", "", "" )
						
						end
						
						local reviewExist = Engine.DoesNewsExist( "REVIEW" )
						if( subject == "Generic_" and time == "Early_" and reviewExist == false ) then
							local rivals = Engine.AreTeamsRivals( team1, team2 )
							local bigmatchups = Engine.AreTeamsBigMatchUps( team1, team2 )
							local derby = bigmatchups or Engine.AreTeamsDerby( team1, team2 )
							if( rivals == false and derby == false ) then
								local matchImportanceFix = RollPercentageDice( 25 )
								if( matchImportanceFix == true ) then
									canReview = false
								end
							end
						end
						if( canReview == true ) then
							Engine.SetStringCompetition( comp )
							Engine.SetStringTeam( team1, 1 ) -- Home team
							Engine.SetStringTeam( team2, 2 ) -- Away
							Engine.SetStringTeam( strongerTeam, 3 ) -- Stronger Team
							Engine.SetStringTeam( weakerTeam, 4 ) -- Weaker
							if( wasGameWon == true ) then
								Engine.SetStringTeam( matchWinner, 5 ) -- Winning Team
								Engine.SetStringTeam( matchLoser, 6 ) -- Losing
							end
							
							-- News Sending-------------------
							reviewReady = Engine.DoesNewsExist( "REVIEW" )
							local newNews = nil
							if( reviewReady == false ) then
								if( gametype ~= "FRIENDLY" ) then
									newNews = Engine.CreateNews( "REVIEW", "News_Title_ImportantMatch_" .. stringId .. "Result_", 1 )
								end
							else
								newNews = Engine.GetNewsById( "REVIEW" )
							end
							reviewReady = Engine.DoesNewsExist( "REVIEW" )
							if( reviewReady == true ) then
								local validHeadline = Engine.HasValidHeadline( newNews )
								if( validHeadline == false ) then
									Engine.SetNewsHeadlineByObject( newNews, "News_Title_ImportantMatch_" .. stringId .. "Result_", 1 )
								end
								Engine.SetStringTeam( team1, 1 ) -- Home team
								Engine.SetStringTeam( team2, 2 ) -- Away
								local newsWeight = Tuning.IMP.importantMatchNewsWeight
								Engine.AddParagraph( newNews, newsWeight, "News_Body_ImportantMatch_" .. stringId .. result, 1, winScore, loseScore, penScore1, penScore2 )
								Engine.SetNewsImportance( newNews, "REVIEW" )
								Engine.SetNewsTeam( newNews, userTeam )
								Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", team1, newNews ) 
								Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", team2, newNews )
								Engine.SetNewsBackgroundImage( "FOOTBALL_PITCH", newNews )
								
								if( type == "Cup_" and time == "Generic_" and subject == "BigvsAverage_" and result == "Higher_Won_" ) then
									Engine.SetNewsCinematic( "CM_News_TeamPromo", newNews )
								end
								if( type == "League_" and time == "Late_" and subject == "BothFifthOrAbove_" and result == "Higher_Won_" ) then
									Engine.SetNewsCinematic( "CM_News_TeamPromo", newNews )
								end
								
								Engine.SendNews( newNews )
							end
							--News  Sending--------------------
							Engine.SetStoryStage( currentStory, 2 )
						else
							Engine.DeleteNews( "REVIEW" )
						end --if( canReview == true ) then
					else
						Engine.DeleteNews( "REVIEW" )
					end
				else
					Engine.DeleteNews( "REVIEW" )
				end -- if( Engine.WasMatchForfeited( matchResult ) == false ) then
			else
				Engine.DeleteNews( "REVIEW" )
			end -- if( numStories > 0 or reviewReady == true ) then
		else
			Engine.DeleteNews( "REVIEW" )
		end
		Engine.EndStoryCategory( category, false )
	else
		Engine.DeleteNews( "REVIEW" )
	end --	if( INTERNATIONAL GAME )
end

-- function AddRivalMoraleAffect( matchResult )
-- 	local team1, team2 = Engine.GetMatchResultTeamIds( matchResult )
-- 	local bigmatchups = Engine.AreTeamsBigMatchUps( team1, team2 )
-- 	local derby = bigmatchups or Engine.AreTeamsDerby( team1, team2 )
-- 	local rivals = Engine.AreTeamsRivals( team1, team2 )
-- 	if( derby == true or rivals == true ) then
-- 		local teamId = Engine.GetUserTeam()
-- 		local matchWinner = Engine.GetMatchWinner( matchResult )
-- 		local userWon = "Draw"
-- 		local wasGameWon = Engine.WasGameWon( matchResult )
-- 		if( wasGameWon == true ) then
-- 			if( matchWinner == teamId ) then
-- 				userWon = "Won"
-- 			else
-- 				userWon = "Lost"
-- 			end
-- 		end
-- 		local moraleAffect = 0
-- 		if( userWon == "Won" ) then
-- 			if( derby == true ) then
-- 				moraleAffect = Tuning.IMP.moraleAffectWonDerby
-- 			else
-- 				moraleAffect = Tuning.IMP.moraleAffectWonNonDerby
-- 			end
-- 		elseif( userWon == "Lost" ) then
-- 			if( derby == true ) then
-- 				moraleAffect = Tuning.IMP.moraleAffectLostDerby
-- 			else
-- 				moraleAffect = Tuning.IMP.moraleAffectLostNonDerby
-- 			end
-- 		end
-- 		local numPlayersOnTeam = Engine.GetNumPlayers( teamId )
-- 		for playerCount = 1, numPlayersOnTeam do
-- 			local currentPlayer = Engine.GetPlayer( teamId, playerCount )
-- 			if( Engine.DidPlayerPlay( teamId, currentPlayer, matchResult ) == true ) then
-- 				Engine.ModifyPlayerMorale( teamId, currentPlayer, moraleAffect )
-- 			end
-- 		end
-- 	end
-- end
-- 
-- function PreMatch_ReverseFixture( numDays, gametype, fixture )
-- 	if( numDays == 0 ) then
-- 		local storyId = "REVERSE-FIX"
-- 		if( Engine.IsStoryIDActive( storyId ) == true ) then
-- 			local currentStory = Engine.GetStoryById( storyId )
-- 			local var = Engine.GetStoryVariable( currentStory )
-- 			local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
-- 			local lastHomeTeam = awayTeam
-- 			local lastAwayTeam = homeTeam
-- 			local lastHomeScore = tonumber( string.sub( var,1,2) )
-- 			local lastAwayScore = tonumber( string.sub( var,3,4) )
-- 			local lastMatchWinner = lastHomeTeam
-- 			local lastMatchLoser = lastAwayTeam
-- 			local lastResult = "homewon"
-- 			local severity = "generic"
-- 			local lastResultVar = "00"
-- 			local severityVar = "00"
-- 			local topScore = lastHomeScore
-- 			local lowScore = lastAwayScore
-- 			if( lastHomeScore < lastAwayScore ) then
-- 				lastMatchWinner = lastAwayTeam
-- 				lastMatchLoser = lastHomeTeam
-- 				topScore = lastAwayScore
-- 				lowScore = lastHomeScore
-- 				lastResultVar = "01"
-- 			elseif( lastHomeScore == lastAwayScore ) then
-- 				lastResult = "draw"
-- 				lastResultVar = "02"
-- 			end
-- 			if( lastResult == "draw" ) then
-- 				if( lastHomeScore == 0 and lastAwayScore == 0 ) then
-- 					severity = "nilnil"
-- 					severityVar = "04"
-- 				elseif( lastHomeScore >= Tuning.IMP.highScoreGoals ) then
-- 					severity = "highscore"
-- 					severityVar = "05"
-- 				end
-- 			else
-- 				if( topScore - lowScore >= Tuning.IMP.scoreDiffTrashing )then--Thrashing
-- 					severity = "thrashing"
-- 					severityVar = "03"
-- 				elseif( topScore >= Tuning.IMP.thrillingGoals and lowScore >= Tuning.IMP.thrillingGoals )then --Thrilling
-- 					severity = "thrilling"
-- 					severityVar = "02"
-- 				elseif( topScore - lowScore >= Tuning.IMP.scoreDiffEasily ) then -- Easily
-- 					severity = "easily"
-- 					severityVar = "01"
-- 				end
-- 			end
-- 			Engine.SetStringTeams( lastMatchWinner, lastMatchLoser, homeTeam, awayTeam )
-- 			local weight = Tuning.IMP.reverseFixturePreviewWeight
-- 			PublishToPreview( currentStory, "news_body_reversefixture_" .. lastResult .. "_" .. severity .. "_", 4, weight, lastHomeScore, lastAwayScore )
-- 			Engine.SetStoryVariable( currentStory, severityVar .. lastResultVar )
-- 		end
-- 	end
-- end
-- 
-- function PostMatch_ReverseFixture( matchResult, gametype, playType )
-- 	local storyId = "REVERSE-FIX"
-- 	if( Engine.IsStoryIDActive( storyId ) == true ) then
-- 		local currentStory = Engine.GetStoryById( storyId )
-- 		local var = Engine.GetStoryVariable( currentStory )
-- 		local lastResultVar = string.sub( var,3,4)
-- 		local homeTeam, awayTeam = Engine.GetMatchResultTeamIds( matchResult )
-- 		local matchWinner = Engine.GetMatchWinner( matchResult )
-- 		local lastResult = "homewonlast"
-- 		local thisResult = "wonthis"
-- 		local pastMatchWinner = awayTeam
-- 		local pastMatchLoser = homeTeam
-- 		if( lastResultVar == "01" ) then -- Lose 
-- 			pastMatchWinner = homeTeam
-- 			pastMatchLoser = awayTeam
-- 		elseif( lastResultVar == "02" ) then -- Draw
-- 			lastResult = "drawlast"
-- 		end
-- 		local wasGameWon = Engine.WasGameWon( matchResult )
-- 		if( wasGameWon == true ) then
-- 			if( matchWinner ~= pastMatchWinner ) then
-- 				thisResult = "lostthis"
-- 			end
-- 		else
-- 			thisResult = "drawthis"
-- 		end
-- 		Engine.SetStringTeams( pastMatchWinner, pastMatchLoser, homeTeam, awayTeam )
-- 		local weight = Tuning.IMP.reverseFixtureReviewWeight
-- 		PublishToReview( currentStory, "news_body_reversefixture_result_" .. lastResult .. "_" .. thisResult .. "_", 4, weight )
-- 	end
-- end
-- 
-- function PreMatch_Streak( numDays, gametype, fixture )
-- 	if( numDays == 0 )then
-- 		local category = "STREAK"
-- 		local numStories = Engine.GetNumStoriesByCategory( category )
-- 		if( numStories > 0 ) then
-- 			local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
-- 			for storyCount = 1, numStories do
-- 				local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
-- 				local storyId = Engine.GetStoryId( currentStory )
-- 				local storyTeam = Engine.GetStoryTeam( currentStory )
-- 				local otherTeam = awayTeam
-- 				local variation = 4
-- 				if( storyTeam == awayTeam ) then
-- 					otherTeam = homeTeam
-- 				end
-- 				local storyType = "win"
-- 				local var = Engine.GetStoryVariable( currentStory )
-- 				local numGames = tonumber( var )
-- 				if( numGames >= 2 ) then
-- 					Engine.UpdateStoryActivity( currentStory )
-- 				end
-- 				local newsWeight = Tuning.IMP.streakPreMatchNewsWeight
-- 				local stage = Engine.GetStoryStage( currentStory )
-- 				if( numGames >= 5 ) then
-- 					if( string.find( storyId, "CPU" ) ~= nil ) then
-- 						newsWeight = Tuning.IMP.streakPreMatchNewsWeightCpu
-- 					end
-- 					if( string.find( storyId, "DRAW" ) ~= nil ) then
-- 						storyType = "draw"
-- 						if( numGames == 2 ) then
-- 							var = "2"
-- 						else
-- 							var = "generic_"
-- 						end
-- 					else
-- 						if( numGames > 10 ) then
-- 							var = "greaterthan10"
-- 						elseif( numGames == 10 ) then
-- 							var = "10"
-- 						elseif( numGames == 5 ) then
-- 							var = "5"
-- 						elseif( numGames == 2 ) then
-- 							var = "2"
-- 						else
-- 							var = "generic_"
-- 						end			
-- 						if( string.find( storyId, "LOSS" ) ~= nil ) then
-- 							storyType = "loss"
-- 							if( numGames >= 10 )then
-- 								variation = 2
-- 							end
-- 						end
-- 					end
-- 					Engine.SetStringTeams( storyTeam, otherTeam, homeTeam, awayTeam )
-- 					PublishToPreview( currentStory, "news_body_streak_prematch_" .. storyType .. "_" .. var .. "games_", variation, newsWeight, numGames )
-- 					Engine.SetStoryStage( currentStory, 1 )
-- 				end
-- 			end
-- 		end
-- 	end
-- end
-- 
-- function PostMatch_Streak( matchResult, gametype, playType )
-- 	local category = "STREAK"
-- 	local numStories = Engine.GetNumStoriesByCategory( category )
-- 	if( numStories > 0 ) then
-- 		local homeTeam, awayTeam = Engine.GetMatchResultTeamIds( matchResult )
-- 		for storyCount = 1, numStories do
-- 			local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
-- 			local storyId = Engine.GetStoryId( currentStory )
-- 			local storyTeam = Engine.GetStoryTeam( currentStory )
-- 			local var = Engine.GetStoryVariable( currentStory )
-- 			local numGames = tonumber( var )
-- 			local otherTeam = awayTeam
-- 			if( storyTeam == awayTeam ) then
-- 				otherTeam = homeTeam
-- 			end
-- 			local storyType = "win"
-- 			local newsWeight = Tuning.IMP.streakPostMatchNewsWeight
-- 			local stage = Engine.GetStoryStage( currentStory )
-- 			local thisResult = "wonthis"
-- 			local outcome = "continues"
-- 			if( stage == 1 ) then
-- 				if( string.find( storyId, "CPU" ) ~= nil ) then
-- 					newsWeight = Tuning.IMP.streakPostMatchNewsWeightCpu
-- 				end
-- 				if( string.find( storyId, "DRAW" ) ~= nil ) then
-- 					storyType = "draw"
-- 				else	
-- 					if( string.find( storyId, "LOSS" ) ~= nil ) then
-- 						storyType = "loss"
-- 					end
-- 				end
-- 				local matchWinner = Engine.GetMatchWinner( matchResult )
-- 				local wasGameWon = Engine.WasGameWon( matchResult )
-- 				if( wasGameWon == true ) then
-- 					if( matchWinner ~= storyTeam ) then
-- 						thisResult = "lostthis"
-- 					end
-- 				else
-- 					thisResult = "drawthis"
-- 				end
-- 				if( storyType == "win" ) then
-- 					if( thisResult ~= "wonthis" ) then
-- 						outcome = "ended"
-- 					end
-- 				elseif( storyType == "loss" ) then
-- 					if( thisResult ~= "lostthis" ) then
-- 						outcome = "ended"
-- 					end
-- 				else
-- 					if( thisResult ~= "drawthis" ) then
-- 						outcome = "ended"
-- 					end
-- 				end
-- 				Engine.SetStringTeams( storyTeam, otherTeam, homeTeam, awayTeam )
-- 				PublishToReview( currentStory, "news_body_streak_postmatch_" .. storyType .. "_" .. thisResult .. "_", 4, newsWeight, numGames )
-- 				Engine.UpdateStoryActivity( currentStory )
-- 				local review = Engine.GetNewsById( "REVIEW" )
-- 				Engine.SetNewsForegroundImage( "CENTER", "CLUB_CREST", homeTeam, review )
-- 				Engine.SetNewsForegroundImage( "RIGHT", "CLUB_CREST", awayTeam, review )
-- 				Engine.SetNewsBackgroundImage( "EMPTY_STADIUM", review )
-- 				Engine.SetStringTeams( storyTeam, otherTeam, homeTeam, awayTeam )
-- 				Engine.SetNewsHeadlineByObject( review, "news_title_streak_postmatch_" .. storyType .. "_" .. outcome .. "_", 4, numGames )
-- 				local scene = ""
-- 				if( storyType == "win" and thisResult == "wonthis" ) then
-- 					scene = "CM_News_ManagerActionPositive"
-- 				end
-- 				if( storyType == "loss" and thisResult == "lostthis" ) then
-- 					scene = "CM_News_ManagerActionNegative"
-- 				end
-- 				if( scene ~= "" ) then
-- 					Engine.SetNewsCinematic( scene, review )
-- 				end
-- 			end
-- 		end
-- 	end
-- end
-- 
-- function PreMatch_5GameForm( numDays, gametype, fixture )
-- 	if( numDays == 0 ) then
-- 		local category = "5GAMEFORM"
-- 		local numStories = Engine.GetNumStoriesByCategory( category )
-- 		if( numStories > 0 ) then
-- 			local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
-- 			for storyCount = 1, numStories do
-- 				local currentStory = Engine.GetStoryByCategoryAndIndex( category, storyCount )
-- 				local storyId = Engine.GetStoryId( currentStory )
-- 				local storyTeam = Engine.GetStoryTeam( currentStory )
-- 				local otherTeam = awayTeam
-- 				if( storyTeam == awayTeam ) then
-- 					otherTeam = homeTeam
-- 				end
-- 				local var = Engine.GetStoryVariable( currentStory )
-- 				local numPoints = tonumber( var )
-- 				local newsWeight = Tuning.IMP.fiveGameFormNewsWeight
-- 				local status = "okay"
-- 				local extra = ""
-- 				local scene = ""
-- 				if( string.find( storyId, "CPU" ) ~= nil ) then
-- 					newsWeight = Tuning.IMP.fiveGameFormNewsWeightCpu
-- 					if( numStories > 1 ) then
-- 						extra = "cpu_"
-- 					end
-- 				end
-- 				if( numPoints <= Tuning.IMP.fiveGamePointsLow ) then -- Low ( Less than 2 Games Won )
-- 					status = "poor"
-- 				elseif( numPoints < 15 and numPoints >= Tuning.IMP.fiveGamePointsGood ) then -- High
-- 					status = "good"
-- 					if( extra == "" ) then -- only for user, not for CPU team
-- 						scene = "CM_News_TeamPromo"
-- 					end
-- 				elseif ( numPoints == 15 ) then -- flawless
-- 					status = "undefeated"
-- 				end
-- 				Engine.SetStringTeams( storyTeam, otherTeam, homeTeam, awayTeam )
-- 				PublishToPreview( currentStory, "news_body_fivegameform_" .. status .. "_" .. extra, 4, newsWeight, numPoints )
-- 				
-- --				local preview = Engine.GetNewsById( "PREVIEW" )
-- --				if( scene ~= "" ) then
-- --					Engine.SetNewsCinematic( scene, preview )
-- --				end
-- 			end
-- 		end
-- 	end
-- end

function PreMatch_TopScorer( numDays, gametype, fixture )
	if( gametype == "LEAGUE" ) then
		if( numDays == 0 ) then
			local storyId = "TOPSCORER"
			local category = "TOPSCORER"
			local numGamesPlayed = Engine.GetNumberOfFixturesPlayedFromFixture( fixture )
			if( numGamesPlayed > 1 ) then
				local stage = "early"
				local percThroughSeason = Engine.GetPercentageThroughSeason()
				if(  percThroughSeason <= Tuning.IMP.earlySeasonThreshold ) then
					if( numGamesPlayed == 2 ) then
						stage = "secondmatch"
					elseif( numGamesPlayed == 3 ) then
						stage = "thirdmatch"
					end
				elseif( percThroughSeason <= Tuning.IMP.earlyMidSeasonThreshold ) then
					stage = "earlymid"
				elseif( percThroughSeason <= Tuning.IMP.lateMidSeasonThreshold ) then
					stage = "latemid"
				else
					stage = "late"
				end
				local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
				for teamCount = 1, 2 do
					local teamToUse = homeTeam
					if( teamCount == 2 ) then
						teamToUse = awayTeam
					end
					teamToUse = Engine.StackRankTeamByStat( teamToUse, "GOALS" )
					local playerId = Engine.GetPlayer( teamToUse, 1 )
					local teamId, topScorer = Engine.GetTopScorerPlayerByIndex( 1 )
					if( topScorer == playerId ) then
						if( area ~= "GK" ) then
							if( Engine.MarkPlayerForStory( teamToUse, playerId, category, storyId ) == true ) then
								local currentStory = Engine.GetStoryById( storyId )
								local goals = Engine.GetPlayerStat( teamToUse, playerId, "GOALS" )
								Engine.SetStoryVariable( currentStory, stage )
								Engine.SetStoryStage( currentStory, goals )
								if( stage == "latemid" or stage == "late" ) then
									local storyTeam = Engine.GetStoryTeam( currentStory )
									local otherTeam = awayTeam
									if( storyTeam == awayTeam ) then
										otherTeam = homeTeam
									end
									Engine.SetStringTeams( storyTeam, otherTeam, homeTeam, awayTeam )
									Engine.SetStringPlayers( playerId )
									PublishToPreview( currentStory, "news_body_topscorer_", 4, Tuning.IMP.topScorerNewsWeight )
								end
								Engine.UpdateStoryActivity( currentStory )
								Engine.KillStoryAfterMatch( currentStory, false )
								break
							end
						end
					end
				end
			end
		end
	end
end

function PreMatch_StartingXI( numDays, gametype, fixture )
	if( numDays == 0 ) then
		local homeTeam, awayTeam = Engine.GetTeamsFromFixtureData( fixture )
		local homeImportance, awayImportance = Engine.GetMatchImportance( fixture )
		local teamToUse = homeTeam
		local importanceToUse = homeImportance
		for teamCount = 1, 2 do
			if( teamCount == 2 ) then
				teamToUse = awayTeam
				importanceToUse = awayImportance
			end
			
			local importanceOffsets = Tuning.IMP.importanceOffsets
			local randNum = Engine.GetRandomNumber( 1, #importanceOffsets )
			local importanceVariation = importanceToUse + importanceOffsets[randNum]
			
			if( importanceVariation > 100 ) then
				importanceVariation = 100
			end
			
			Engine.ForceTeamCacheRefresh()	
			Engine.PickTeam( teamToUse, importanceVariation )
			
			local def, mid, att = Engine.GetFormation( teamToUse )
			
			local first = { 0 }
			local second = { 0, 0, 0, 0, 0 }
			local third = { 0, 0, 0, 0, 0 }
			
			local chosenList = first
			local playerIndex = 0
			for playerCount = 1, 11 do
				if( playerCount > 1 and playerCount < 7 ) then
					chosenList = second
					playerIndex = 0
				elseif( playerCount > 6 ) then
					playerIndex = 0
					chosenList = third
				end
				local playerId = Engine.GetPlayer( teamToUse, playerCount )
				playerIndex = playerIndex + 1
				table.insert( chosenList, playerIndex, playerId )
			end
			
			Engine.CleanupPickTeam()
			--Add players to text
			local weight = Tuning.IMP.startingElevenHomeNewsWeight
			if( teamCount == 2 ) then
				weight = Tuning.IMP.startingElevenAwayNewsWeight
			end
			
			Engine.SetStringTeams( teamToUse )
			PublishToPreview( nil, "news_body_startingeleven_header_", 1, weight )
			local listToUse = first
			for posCount = 1, 3 do
				--Set String and Publish Article
				weight = weight - 1
				if( posCount == 2 ) then
					listToUse = second
				elseif( posCount == 3 ) then
					listToUse = third
				end
				--Set String and Publish Article
				if( listToUse == first ) then
					Engine.SetStringPlayers( listToUse[1] )
					PublishToPreview( nil, "news_body_startingeleven_first_", 1, weight )
				else
					Engine.SetStringPlayers( listToUse[5], listToUse[4], listToUse[3], listToUse[2], listToUse[1]  )
					PublishToPreview( nil, "news_body_startingeleven_", 1, weight )
				end
			end
		end
	end
end
