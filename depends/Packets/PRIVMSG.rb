#puts "(#{$splits[1]}) <#{$name}> #{$message}"
_log("Chat", "", "", "<#{$name}> #{$message}", $splits[1])

#if $splits[1] != $botname
#	logtext("<#{$name}> #{$message}", $splits[1])
#else
#	logtext("<#{$name}> #{$message}", $name)  
#end

if $message[1,$message.length - 2] == "VERSION"
	send_raw("NOTICE " + $name + " :" + 1.chr + "VERSION Ruby-irc bot Version 4.4 by Umby24" + 1.chr) #CTCP Version.
	_log("INFO", "PRIVMSG", "VERSION", "Received CTCP Version.")
	#puts "Received CTCP Version"
end

if $message[0, 5] == 1.chr + "PING" # Handles CTCP Pings.
	pingid = $message[5, $message.length - 6]
	send_raw("NOTICE " + $name + " :" + 1.chr + "PING" + pingid + 1.chr)
	_log("INFO", "PRIVMSG", "PING", "Received CTCP PING.")
	#puts "Received CTCP PING"
end

eventMessage()

if $message[0,1] == $prefix
	if $message.include?(" ") == false
		$message += " "
	end

	$cmd = $message[1, $message.length - 1]

	if $cmd.include?(" ") == false
		$cmd += " "
	end

	$okay = false
	if $access != nil
		$access.each {|item|
		if item.strip.downcase == $name.strip.downcase
			$okay = true
		end
		}
	end

	$cmd = $cmd[0, $cmd.index(" ")].downcase.gsub(" ","")

	load "depends/cmd.rb" #Handle commands.
end
