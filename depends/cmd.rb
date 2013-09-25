if $okay == true
	if $splits[1] == $botname
		$current = $host[0,$host.index("!")]
	else
		$current = $splits[1]
	end
	override = false
	if $authed.include?($host[0,$host.index("!")]) == false && override == false
		send_raw("whois " + $host[0,$host.index("!")])
		
		if $gcommand[$cmd] == nil
			sendmessage("Command not found.")
		else
			send($gcommand[$cmd])
		end
	else
		$args = $message.split(" ",30)
		
		if $command[$cmd] == nil
			sendmessage("Command not found.")
		else
			send($command[$cmd])
		end
	end
else
	$args = $message.split(" ",30)
	
	if $gcommand[$cmd] == nil
		sendmessage("Command not found.")
	else
		send($gcommand[$cmd])
	end
end