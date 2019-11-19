function TriggerEmail( canShowInPap, to, sender, subject, subjectMin, subjectMax, body, bodyMin, bodyMax, cc, linkText, linkDest, teamId, playerId )
	teamId = teamId or -1
	playerId = playerId or -1
	local isPap = Engine.IsPlayAsPlayer()
	if( ( isPap == true and canShowInPap == true ) or isPap == false ) then		
		Engine.SetEmailTo( to )	
		Engine.SetEmailSender( sender )	
		local senderRandNo = Engine.GetRandomNumber( subjectMin, subjectMax )	
		local bodyRandNo = Engine.GetRandomNumber( bodyMin, bodyMax )
		Engine.SetEmailSubject( subject, senderRandNo )
		Engine.SetEmailBody( body, bodyRandNo )
		Engine.SetEmailCC( cc )
		Engine.SetEmailLink( linkText, linkDest )
		if (teamId ~= -1) then
			Engine.SetEmailTeamId(teamId)
		end	
		if (playerId ~= -1) then
			Engine.SetEmailPlayerId(playerId)
		end		
		Engine.SendEmail()
	end --if( ( isPap == true and canShow == true ) or isPap ~= true ) then
end