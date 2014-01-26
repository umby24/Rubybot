$serverchannel.each {|channel|
	send_raw("JOIN #{channel}")
}
if $nspass != "" && $id == false
	send_raw("NICKSERV IDENTIFY " + $nspass)
	$id = true
end
eventConnected()