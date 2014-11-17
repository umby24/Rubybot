if $splits[1] == $botname
	$current = $host[0,$host.index("!")]
else
	$current = $splits[1]
end

if $okay == true
	override = true
	if $authed.include?($name) == false && override == false
		send_raw("whois " + $name)
		
		$args = $message.split(" ",30)
		
		if $gcommand[$cmd] == nil
			send_notice($name, "Command not found.")
		else
			begin
				send($gcommand[$cmd])
			rescue Exception => e
				watchdog_Log("Command Error (#{$cmd}): #{e.message}", e.backtrace)
				#err_log("Command Error (#{$cmd}): #{e.message}\n#{e.backtrace}")
			end
		end
	elsif override == true
		$args = $message.split(" ",30)
		
		if $command[$cmd] == nil
			send_notice($name, "Command not found.")
		else
			begin
				send($command[$cmd])
			rescue Exception => e
				watchdog_Log("Command Error (#{$cmd}): #{e.message}", e.backtrace)
				#err_log("Command Error (#{$cmd}): #{e.message}\n#{e.backtrace}")
			end
		end
	end
else
	$args = $message.split(" ",30)
	
	if $gcommand[$cmd] == nil
		send_notice($name, "Command not found.")
	else
		begin
			send($gcommand[$cmd])
		rescue Exception => e
			watchdog_Log("Command Error (#{$cmd}): #{e.message}", e.backtrace)
			#err_log("Command Error (#{$cmd}): #{e.message}\n#{e.backtrace}")
		end
	end
end
