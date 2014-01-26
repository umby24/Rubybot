#Required Functions
def logtext(text, channel)
	time = Time.new
	
	if channel.include?(":") == false
		if File.directory?("logs") == false
			Dir.mkdir("logs")
		end

		if File.directory?("logs/" + channel) == false
			Dir.mkdir("logs/" + channel)
		end

		afile = File.new(Dir.pwd + "/logs/" + channel + "/" + time.strftime("%m-%d-%Y") + ".txt", "a+")
		afile.syswrite("[" + time.strftime("%I:%M:%S %p") + "]" + text + "\r")
		afile.close
	end
end

def _log(type, plugin, function, message, channel=nil)
	time = Time.now()
	mystring = time.strftime("%I:%M:%S %p") + "  [" + type.upcase + "]"
	
	if plugin != ""
		mystring += "[" + plugin.upcase #:" + function.upcase + "] " + message
		
		if function != ""
			mystring += ":"
		end
	else
		if function != ""
			mystring += "["
		end
	end
	
	if function != ""
		mystring += function.upcase + "]"
	end
	if channel != nil
		mystring += "[" + channel + "]"
	end
	
	mystring += " " + message
	
	puts mystring
	
	if channel != nil
		logtext(mystring, channel)
	end
end

def err_log(message)
  afile = File.new("error.log","a")
  afile.write("\n" + message)
  afile.close()
end

def send_raw(data)
 $socket.send(data + "\r\n", 0)
end

def pm(message,user)
	messages = thisSplitMessage(message)
	messages.each {|b|
		if b != nil
			send_raw("PRIVMSG " + user + " :" + b)
			_log("Chat", "", "", "<" + $botname + "> " + b, user)
		end
	}
end

def sendmessage(message)
  begin
	pm(message, $current)
  rescue Exception => e
    watchdog_Log("Failed to sendmessage." + e.message, e.backtrace)
  end
end

def send_notice(user, message)
	send_raw("NOTICE " + user + " :" + message)
	_log("NOTICE", "", "SendNotice", message, user)
end

def thisSplitMessage(string)
	loopback = false
	splits = []
	counter = 0
	
	begin
		if string.length > 400
			loopback = true
		else
			loopback = false
		end
		if loopback
			index = string[0, 400].rindex(" ")
			temptext = string[index + 1, string.length - (index + 1)]
			string = string[0, index]
		end
		splits[counter] = string
		if loopback
			string = temptext
		end
		counter += 1
	end while (loopback == true)
	return splits
end

def load_settings()
	begin
		reader = IO.readlines("settings.txt")
		reader.each {|line|
			a = line[0, line.index("=")]
			d = line[line.index("=") + 1, line.length - (line.index("=") + 1)]
		
			if d.include?("\n") then
				d = d.chop
			end
			
			case a.downcase
			  when "username"
				$botname = d
			  when "channel"
				channels = d.split(",",10)
				if $current == ""
					$current = channels[0]
				end
				#$serverchannel = [d]
				$serverchannel = channels
			  when "server"
				$serverip = d
			  when "port"
				$serverport = d
			  when "ident"
				$ident = d
			  when "realname"
				$realname = d
			  when "ns_pass"
				$nspass = d
               when "prefix"
                $prefix = d
			end
		}
	rescue Exception => e
		watchdog_Log(e.message, e.backtrace)
		#err_log("Error loading settings: #{e.message}")
	end
end

def load_users()
	begin
		$access = []
		IO.foreach("settings/users.txt") {|line|
			$access.push(line.gsub("\n","").gsub("\r",""))
		}
	rescue
		watchdog_Log("ERROR: Users file not found.", "load_users()")
	end
	_log("INFO", "", "Load_Users", "Users loaded")
end

def load_plugins()
	$plugins = []
	plugins = []
	IO.foreach("settings/plugins.txt") {|line|
		plugins.push(line.gsub("\n","").gsub("\r",""))
	}
	
	plugins.each {|item|
		if item[0,1] != "#" and (item != "" and item != " " and item != nil and item != "\r" and item != "\n" and item != "\r\n")
			begin
				load Dir.pwd + "/plugins/" + item
				$plugins.push(item)
			rescue Exception => e
				watchdog_Log("Error loading #{item}: #{e.message}", e.backtrace)
				next
			end
		end
	}
	
	_log("INFO", "", "Load_Plugins", "Plugins loaded.")
end

def loop_load()
  while $quit == 0
    begin
	if $tolerance == $tol
		$quit = 1
		Thread.kill($t1)
		return
	end
    load Dir.pwd + "/depends/loop.rb"
    socketloop()
    rescue Exception => e
      # This enables you to correct your mistakes infinatly until you find the issue
      # as all errors will be logged, it shouldn't be too hard to pinpoint.
	  watchdog_Log("Error reloading loop: " + e.message, e.backtrace)
	  $tol += 1
      loop_load()
    end
  end
  if $quit == 1
    $socket.close()
  end
end

def systemloop()
	while $pia == 1
		message = gets
		message = message.chop()
		
		if message[0,3] == "/c "
			mmessage = message[3, message.length - 3]
			$current = mmessage
			message = "/null\\" # Keeps the channel changing from being sent to the new channel
		end
		
		case message
			when "/null\\"
				#Do nothing :D
			when "/join"
				send_raw("JOIN " + $current)
			when "/r"
				$pie = 0
				$reloaded = 1
				load Dir.pwd + "/depends/reqfunc.rb"
				load Dir.pwd + "/plugins/func.rb"
				load Dir.pwd + "/depends/HelpModule.rb"
				load_plugins()
				load_users()
				_log("Info", "", "SystemLoop", "Reloaded")
			else
				sendmessage(message)
		end
	end
end

def ping_loop()
	while $quit == 0
		sleep(1)
		$timer += 1
		
		begin
			if $timer > 600
					$quit = 1
					Thread.kill($t1)
			if $socket.closed? == false
					$socket.close()
			end
					system("ruby Main.rb")
					puts "RECOVERED"
			end
		rescue Exception => e
			watchdog_Log("Pingloop error: " + e.message, e.backtrace)
		end
	end
end
