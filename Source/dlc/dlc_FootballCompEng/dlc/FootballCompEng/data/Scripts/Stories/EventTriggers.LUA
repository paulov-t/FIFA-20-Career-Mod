function Trigger_AboutToInitMode()
	isFinalVar = Engine.IsFinal()
	local userTeam = Engine.GetUserTeam()
	local seasonNumber = 0
	if( Engine.UserNationalityHasTeam() == true ) then
		InternationalTeaser()
	end
	
	
end

function Trigger_PostLoadEvent()
	isFinalVar = Engine.IsFinal()
end

function Trigger_AboutToSwitchJob( seasonNumber, isLoanReturn, fromTeam, toTeam, wasFired, isLoan, retiring )
	Engine.EndAllStoriesForTeam( fromTeam, false )
	Engine.EndStoryCategory( "LOST", false )
	Engine.EndStoryCategory( "SIGNING", false )
	Engine.EndStoryCategory( "INJURY", false )
	Engine.EndStoryCategory( "SUSPENSION", false )
	Engine.KillAllDynamicEvents()
	if( isLoan == false ) then
		Engine.EndStoryCategory( "JOBCHANGE", false )
	end
end 

function Trigger_MainCompetitionScheduled()
	Engine.AddDateEvent( "SSNPRVDAY1", 2 )
	-- ExamineFor_RetiringPlayer()  NOTE: Retiring player currently removed
end

function Trigger_PostUserGame( matchResult, gametype, playType, matchSituationTypes )	
	local isInPreSeason = Engine.IsInPreSeason()
	
	NewJob_PostMatch( matchResult, gametype, playType )
	ManagerJobOffers_PostMatch( matchResult, gametype, playType )
	ExamineResultForIncident( matchResult, gametype, playType )
	if( string.find( gametype, "INTERNATIONAL" ) == nil ) then
		--PostMatch_PlayerVsFormerTeam( matchResult, gametype, playType )
		ImportantPostUserGame( matchResult, gametype, playType, matchSituationTypes )
	end
end

function Trigger_PostUserInternationalGame( matchResult, gametype, playType )
	NewJob_PostMatch( matchResult, gametype, playType )
end

function Trigger_PostCPUGame( matchResult, gametype )	
	ExamineResultForIncident( matchResult, gametype, "SIMMED" )
end

function Trigger_PlayerInjury( teamId, playerId, severity, returnDate )
	-- RetiringPlayerInjury( teamId, playerId, severity, returnDate )  NOTE: Retiring player currently removed
	PlayerSagaInjuryEnding( teamId, playerId, severity, returnDate )
end

function Trigger_UserTeamKnockedOutOfCup()

end

function Trigger_UserTeamAdvanceNextRound( numAdvancingTeams )
	-- RetiringPlayerAdvanceInCup( numAdvancingTeams )  NOTE: Retiring player currently removed
end

function Trigger_HourPassed( hoursRemaining )
	-- deadlineDayPassedLMTR( hoursRemaining )  NOTE: LMTR currently removed
end

function Trigger_DynamicEvent( eventId, linkId )
	-- RetiringDynamicEvent( eventId, linkId )           NOTE: Retiring player currently removed
	-- ForeignUpsetStoryDynamicEvent( eventId, linkId )  NOTE: Foreign upset player currently removed
	-- ContractRebelDynamicEvent( eventId, linkId )      NOTE: Contract rebel currently removed
	-- LMTRDynamicEvent( eventId, linkId )               NOTE: LMTR currently removed
	InvestorDynamicEvent( eventId, linkId )
	SagaEndingDynamicEvent( eventId, linkId )
	-- WeakSpot_DynamicEvent( eventId, linkId )          NOTE: Weak player replacement currently removed
	DynamicEvent_CounterOffer( eventId, linkId )
	MoveRequest_DynamicEvent( eventId, linkId )
	JobOffer_DynamicEvent( eventId, linkId )
	-- UnhappyWithWage_DynamicEvent( eventId, linkId )   NOTE: Player upset with wage currently removed
end

function Trigger_NumDaysBeforeUserGame( numDays, gametype, fixture )
	NewJob_PreMatch( numDays, gametype, fixture )
	if( string.find( gametype, "INTERNATIONAL" ) == nil ) then
		NewSigningPreMatch( numDays, gametype, fixture )
		--ExamineFor_PlayerVsFormerTeam( numDays, gametype, fixture )
		PreMatch_StartingXI( numDays, gametype, fixture )
		PreMatch_TopScorer( numDays, gametype, fixture )
		ExamineFor_IMP( numDays, gametype, fixture )
	end
end

function Trigger_NumDaysBeforeLastLeagueGame( numDays )
	-- RetiringPlayerLastLeagueGame( numDays ) NOTE: Retiring player currently removed
end

function Trigger_MonthPassed( months )
	-- ExamineFor_UFP( months )                NOTE: Foreign upset player currently removed
	ExamineFor_ForeignInvestor( months )
	-- MonthPassed_CPUContractRebel( months )  NOTE: Contract rebel currently removed
	local isPap = Engine.IsPlayAsPlayer()
	if( isPap == false ) then
		-- ExamineFor_WeakSpot( months )       NOTE: Weak player replacement currently removed
		if( Engine.IsStoryIDActive( "RENEW" ) == false ) then
			ExamineFor_InternationalManagerRumours( months )
		end
	end
end

function Trigger_EnteringTeamManagement( method )
end

function Trigger_LeavingTeamManagement()
end

function Trigger_TransferMoveCompleteUserSell( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue, realDate )
	-- NOTE: Contract rebel currently removed
	-- ContractRebelTransferComplete( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue )
	
	-- NOTE: LMTR currently removed
	-- if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "LOST" ) == false ) then
		-- if( Engine.IsPlayerInvolvedInStoryId( playerId, "LMTR_USR1" ) == true ) then
			-- PostSaleAudio_LMTR( playerId )
		-- end
	-- end
end

function Trigger_TransferMoveCompleteUserBuy( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue, realDate )
	if( sellingTeam ~= Tuning.TRANSFERS.exceptionSellingTeamId ) then
		ExamineFor_NewSigningCompleted( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue, realDate )
	end
	-- WeakSpot_TransferStage( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue )  NOTE: Weak player replacement currently removed
end

function Trigger_TransferMoveComplete( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue, realDate )
	-- ForeignUpsetStoryTransfered( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue )  NOTE: Foreign upset player currently removed
	InvestorClubPurchase( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue )
	-- ContractRebelTransferComplete( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue )  NOTE: Contract rebel currently removed
	
	-- NOTE: Last minute transfer disabled.
	-- if( Engine.IsPlayerInvolvedInStoryCategory( playerId, "LOST" ) == false ) then

		-- if( Engine.IsPlayerInvolvedInStoryId( playerId, "LMTR_USR1" ) == false ) then
			-- Engine.EndAllStoriesForPlayer( playerId )
		-- end
	-- end

end

function Trigger_TransferMoveAboutToCompleteUserBuy( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue, realDate )
	if( transfer == "TRANSFER" ) then
		if( sellingTeam ~= Tuning.TRANSFERS.exceptionSellingTeamId ) then
			if( price > 0 ) then
				ExamineFor_OverPricedDeal( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue )
			end
		end
	end
end

-- NOTE: Must uncomment call from C++ to receive this.
-- function Trigger_TransferMoveAboutToComplete( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue, exchangeValue, realDate )
	-- LastMinTransferComplete( buyingTeam, sellingTeam, playerId, transfer, contract, price, wage, playerValue )  NOTE: LMTR currently removed
-- end

function Trigger_TransferBidCounterRejected( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
	RejectOffer_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
end

function Trigger_TransferBidRetracted( buyingTeamId, playerId, marketValue, marketWage, moneyOffered, sellingTeamId )
	-- NOTE: Contract rebel currently removed
	-- local userTeam = Engine.GetUserTeam()
	-- if( userTeam == sellingTeamId ) then
		-- ContractRebelBidRejected( buyingTeamId, playerId, marketValue, marketWage, moneyOffered, sellingTeamId )
	-- end
end

function Trigger_TransferBidCounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
	ExamineFor_CounterOffer( buyingTeamId, playerId, sellingTeamId, moneyOffered, moneyDesired, counterOfferNum )
end

-- NOTE: Must uncomment call from C++ to receive this.
-- function Trigger_PlayerContractNegotiation( teamId, playerId, status )
	-- local userTeam = Engine.GetUserTeam()
	-- if( userTeam == teamId ) then
		-- if( status == "NEGOTIATING" ) then
			-- ExamineFor_ContractRebel( teamId, playerId )
			-- UnhappyWithWage_ContractAccept( teamId, playerId )
		-- end
		-- NewContractForeignPlayer( teamId, playerId, status )
	-- end	
-- end

-- NOTE: Must uncomment call from C++ to receive this.
-- function Trigger_PlayerContractAccept( teamId, playerId )
	-- UnhappyWithWage_ContractAccept( teamId, playerId )
-- end

function Trigger_TransferWindowCloseDayReached()
	-- ForeignUpsetStoryEndOfWindow( 0 )
	MoveRequest_TransferWindowClose( 0 )
	EndOfWindow_CounterOffer( 0 )
end

-- NOTE: Must uncomment call from C++ to receive this.
-- function Trigger_TransferWindowNumDaysTillClose( numDays )
	-- ExamineFor_LMTR( numDays )              NOTE: LMTR currently removed
	-- LMTREndOfTransferWindow( numDays )      NOTE: LMTR currently removed
	-- WeakSpot_Stage4( numDays )              NOTE: Weak player replacement currently removed
	-- NumDaysLeft_CPUTransferRebel( numDays ) NOTE: Contract rebel currently removed
-- end

function Trigger_PlayerUnhappyWithWage( teamId, playerId )
	-- ExamineFor_UnhappyWithWage( teamId, playerId )  NOTE: Player upset with wage currently removed
end

function Trigger_TalkToPress_Player( teamId, playerId, appearances, goals, yellows, reds, option )
	TalkToPress_Player( teamId, playerId, appearances, goals, yellows, reds, option )
end

function Trigger_TalkToPress_Manager( teamId, managerName, option )
	TalkToPress_Manager( teamId, managerName, option )
end

function Trigger_TalkToPress_Team( teamId, option )
	TalkToPress_Team( teamId, option )
end

function Trigger_TalkToPress_Match( option, fixture )
	TalkToPress_Match( option, fixture )
end

function Trigger_PlayerReleased( teamId, playerId )
	PlayerSagaReleasedEnding( teamId, playerId )
	local userTeam = Engine.GetUserTeam()
	if( userTeam == teamId ) then
		if( IsPlayerInvolvedInSaga( playerId ) == false ) then
			Engine.EndAllStoriesForPlayer( playerId )
		end
	end
end


function Trigger_SoakStarted()
	--Debug_StartSoak()
end

function Trigger_InternationalsJobOfferAccepted( teamId )
	InternationalJob_OfferAccepted( teamId )
end

function Trigger_InternationalsJobOfferMade( teamId )
	InternationalJob_OfferMade( teamId )
end

function Trigger_InternationalsJobOfferDeclined( teamId )
	InternationalJob_OfferDeclined( teamId )
end

function Trigger_InternationalsJobOfferStalled( teamId )
	InternationalJob_OfferStalled( teamId )
end

function Trigger_InternationalJobOfferExpired( teamId )
	InternationalJob_OfferRetracted( teamId )
end

function Trigger_PapJobSwitchAccepted( teamId, isLoan )
	JobOffer_OfferAccepted( teamId )
end

function Trigger_PapJobSwitchRejected( teamId, wasLoan )
	JobOffer_OfferDeclined( teamId )
end

function Trigger_PapRequestMove( isLoan )
	ExamineFor_MoveRequest( isLoan )
end

function Trigger_PapRequestManagerDecision( allow, loanInstead, numRequests )
	MoveRequest_ManagerDecision( allow, loanInstead )
end

function Trigger_PapOfferReceived( teamId, isLoan )
	local category = "REQUEST"
	local numStories = Engine.GetNumStoriesByCategory( category )
	if( numStories > 0 ) then
		MoveRequest_OfferReceived( teamId, isLoan )
	else
		JobOffer_OfferMade( teamId, isLoan )
	end
end

function Trigger_PapOfferExpired( teamId, isLoan )
	JobOffer_OfferRetracted( teamId )
end

function Trigger_JobOfferReceived( teamId )
	JobOffer_OfferMade( teamId, false )
end

function Trigger_JobOfferAccepted( teamId )
	JobOffer_OfferAccepted( teamId )
end

function Trigger_JobOfferRejected( teamId )
	JobOffer_OfferDeclined( teamId )
end

function Trigger_JobOfferExpired( teamId )
	JobOffer_OfferRetracted( teamId )
end

function Trigger_InternationalJobFired( teamId )
	InternationalJobRenewal_Fired( teamId )
end

function Trigger_InternationalPAPSelected( teamId )
	local userTeam = Engine.GetUserTeam()
	StartStory_NewJob( teamId, userTeam, "INTPLAYER", false, false )
end

function Trigger_InternationalPAPNotSelected( teamId )
	
end

function Trigger_WeekBeforeInternationalJobReview( teamId )
	StartStory_InternationalJobRenewal( teamId )
end

function Trigger_InternationalJobReview( teamId )
	
end

function Trigger_JobOffersGenerated( numJobs, job1, job2, job3, job4, job5 )
end

function Trigger_PapRequestListWithdraw( listed, loaned )

end

function Trigger_PapListWithdrawalResponse( listed, loaned, allowWithdraw )
	if( allowWithdraw == true ) then
		local category = "REQUEST"
		local numStories = Engine.GetNumStoriesByCategory( category )
		if( numStories > 0 ) then
			Engine.EndStoryCategory( category, false )
		end
	end
end

function Trigger_InternationalJobResign( teamId )
	InternationalJob_Resign( teamId )
end

function Trigger_CPUOpponentTransferIn( teamId, checkForDebuts, numTransfers, player1, player2, player3, player4, player5, player6, player7 )
	ExamineFor_CPUNewSigning( teamId, checkForDebuts, numTransfers, player1, player2, player3, player4, player5, player6, player7 )
end

function Trigger_TableRivalMatch( userTeamId, userTeamLeaguePos, opponentTeamId, opponentTeamLeaguePos, numTeamsInLeague )

end
