--#############################################################################
--Entry point of CNotes logic, flow of data
function ProcessCommentatorNotes(timesliceStr)
	Print ("############# COMMENTATOR NOTES INTL PREMATCH LOGIC!!! slice was " .. timesliceStr)
	
	ProcessCommentatorNotes_POST(timesliceStr)
	
	--TRIGGER SEND OF DATA TO AUDIO!
	SendCommentatorNotes()

end