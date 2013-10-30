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
			puts "(" + user + ") <" + $botname + "> " + b
			logtext("<#{$botname}> #{b}", user)
		end
	}
end

def sendmessage(message)
  begin
	messages = thisSplitMessage(message)
	messages.each {|b|
		$socket.send("PRIVMSG " + $current + " :" + b + "\r\n", 0)
		puts "(" + $current + ") <" + $botname + "> " + b
		logtext("<#{$botname}> #{b}", $current)
	}

  rescue Exception => e
    err_log("Failed to sendmessage. #{e.message}")
  end
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
def splitMessage(string)
	puts string
	counter = 0
	splitting = true
	splits = []
	
	if string.length > 300
		#We must split the lines!
		while (splitting)
			splits[counter] = string[(counter * 300), string.length - ((counter + 1) * 300)]
			counter += 1
			string = string.gsub(splits[counter] - 1, "")
			
			if string != nil
				if string.length < 300
					splits[counter] = string
					splitting = false
				end
			else
				splitting = false
			end
		end
	else
		splits[0] = string
	end
	
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
		err_log("Error loading settings: #{e.message}")
	end
end

def load_users()
	begin
	  $access = IO.readlines("settings/users.txt")
	rescue
	  err_log("ERROR: Users file not found.")
	end
	puts "Users loaded"
end

def load_plugins()
	$plugins = []
	plugins = IO.readlines("settings/plugins.txt")

	plugins.each {|item|
		#item = item.gsub("/^[a-zA-Z0-9]+$/", "")
		if item.include?("\n")
			item = item.gsub("\n", "")
		end

		if item[0,1] != "#" and (item != "" and item != " " and item != nil and item != "\r" and item != "\n" and item != "\r\n")
			begin
				load Dir.pwd + "/plugins/" + item
				$plugins[$plugins.length] = item
			rescue Exception => e
				err_log("Error loading #{item}: #{e.message}")
				err_log("BT: #{e.backtrace}")
				next
			end
		end
	}
	puts "Plugins loaded."
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
      err_log("Error Reloading loop; Attempting to use current version.")
      err_log("Error message: #{e.message}")
	  err_log("Trace: #{e.backtrace}")
	  $tol += 1
      loop_load()
    end
  end
  if $quit == 1
    $socket.close()
  end
end

def regMsg(name, method)
	$evtmsg[name] = method
end

def regCmd(cmd, method)
	$command[cmd] = method
end

def regGCmd(cmd, method)
	$gcommand[cmd] = method
end

def regLib(library)
	require library
end

def regCon(name, method)
	$evtcon[name] = method
end

def regRead(name, method)
	$evtread[name] = method
end

def regHelp(command, subcommand, string)
	if subcommand == nil
		$help[command] = string
	else
		oldHash = $help[command]
		if oldHash.class.to_s == "Hash"
			oldHash[subcommand] = string
			$help[command] = oldHash
		else
			$help[command] = {subcommand => string}
		end
		
		
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
								load_plugins()
								load_users()
								puts "Reloaded"
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
						err_log("Pingloop error: #{e.message} \n\n\n #{e.backtrace}")
				end
		end
end