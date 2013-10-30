def socketloop()
	$pie = 1
	
	if $reloaded == 1
		sendmessage("Reloaded")
	end
	
	while $pie == 1
		$host = ""
		$dat = ""  # I'm terrible at naming and have no clue what to call this. so dat it is.
		$message = ""

		begin
			$raw = $socket.gets()
		rescue Exception => e
			$socket.close()
			$pie = 0
			$reloaded = 0
			$quit = 1
			err_log("Socket error: #{e.message}")
			break
		end

		eventRead()

		if $raw == nil
			$socket.close()
			$pie = 0
			$reloaded = 0
			break
		end

		if $raw[0,1] == ":"
			$host = $raw[1, $raw.index(" ") - 1]
		else
			$host = $raw[0, $raw.index(" ")]
		end

		$dat = $raw[$raw.index(" ") + 1, $raw.length - ($raw.index(" ") - 1)]

		if $dat.include?(":")
			$message = $dat[$dat.index(":") + 1, $dat.length - ($dat.index(":") + 1)]
		end

		if $host == "PING"
			$timer = 0
			send_raw("PONG #{$dat}")
			next
		end

		$second = $dat[0, $dat.index(" ")]
		$splits = $dat.split(" ", 10)

		if $host.include?("!")
			$name = $host[0,$host.index("!")]
		end

		$message = $message.strip


		case $second
			when "PRIVMSG"
				puts "(#{$splits[1]}) <#{$name}> #{$message}"

				if $splits[1] != $botname
					logtext("<#{$name}> #{$message}", $splits[1])
				else
					logtext("<#{$name}> #{$message}", $name)  
				end

				if $message[1,$message.length - 2] == "VERSION"
					send_raw("NOTICE " + $name + " :" + 1.chr + "VERSION Ruby-irc bot Version 4.2 by Umby24" + 1.chr) #CTCP Version.
					puts "Received CTCP Version"
				end

				if $message[0, 5] == 1.chr + "PING" # Handles CTCP Pings.
					if $splits[3].gsub(1.chr,"") != ""
						thisid = $splits[3].gsub(1.chr,"")[0, $splits[3].gsub(1.chr,"").index(13.chr)]
						send_raw("NOTICE " + $name + " :" + 1.chr + "PING " + thisid + 1.chr)
					else
						send_raw("NOTICE " + $name + " :" + 1.chr + "PING" + 1.chr)
					end
					puts "Received CTCP PING"
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

				next

			when "NOTICE"
				puts "-#{$host}- #{$message}"
				if $pinging == true && $message == "PING"
					newtime = Time.now.to_f
					theping = newtime - $pingtime
					theping = theping.round(2)
					sendmessage("Ping is #{theping.to_s} s")
					$pinging = false
				end
				next
			when "TOPIC"
				$topic[$splits[1]] = $message
				puts "Topic Updated to #{$message}"
				next

			when "QUIT"
				puts "**** #{$name} left #{$splits[1]} (#{$splits[2]})"
				$authed.delete($name)
				next

			when "PART"
				puts "**** #{$name} left #{$splits[1]} (#{$splits[2]})"
				$authed.delete($name)
				next

			when "NICK"
				puts $name + "has changed their nick to " + $message
				send_raw("WHOIS #{$message}") # This is for our user verification.. we use WHOIS to ensure they're verified. if not, we can't verify its really them. This avoids imposters.
				next

			when "307"
				if $authed.include?($splits[2]) == false
					$authed[$authed.length] = $splits[2]
				end   
				next

			when "330"
				if $authed.include?($splits[2]) == false
					$authed[$authed.length] = $splits[2]
				end      
				next

			when "376"
				#send_raw("JOIN #{$current}")
				$serverchannel.each {|channel|
					send_raw("JOIN #{channel}")
				}
				if $nspass != "" && $id == false
					send_raw("NICKSERV IDENTIFY " + $nspass)
					$id = true
				end
				eventConnected()
				next
				
			when "353"
				$arr = $message.split(" ",120)
				$players[$splits[3]] = $arr
				$arr.each do |f|
					if f.include?("~") || f.include?("@") || f.include?("+")
						f = f.gsub("~","")
						f = f.gsub("@","")
						f = f.gsub("+","")
						f = f.gsub(" ","")
						$authed[$authed.length] = f
						next
					end
					f = f.gsub("~","")
					f = f.gsub("@","")
					f = f.gsub("+","")
					f = f.gsub(" ","")
					send_raw("whois #{f}")
				end
				next
			when "433"
				$botname = $botname + "_"
				send_raw("NICK #{$botname}")
				send_raw("USER " + $ident + " ruby ruby :" + $realname)
				send_raw("MODE #{$botname} +B-x")
				next
			when "MODE"
				what3 = 0
				what2 = 0    
				if $splits[2].index(" ") == nil
					what3 = 0
					what2 = $splits[2].length
				else
					what3 = $splits[2].index(" ")
					what2 = $splits[2].length - $splits[2].index(" ") 
				end    
					what = $splits[2][what3, what2]
					send_raw("WHOIS #{what}")
				next

			when "JOIN"
				puts "** #{$name} joined #{$splits[1]}."
				send_raw("WHOIS #{$name}")
			next

			when "332"
				$topic[$splits[2]] = $message
				next

		end
		puts $message
	end
end
