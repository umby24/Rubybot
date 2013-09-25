#Required Functions
def logtext(text, channel)
	time = Time.new
	mytext = ""
	
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
end

def send_raw(data)
 $socket.send(data + "\r\n", 0)
end

def pm(message,user)
  send_raw("PRIVMSG " + user + " :" + message)
  logtext("<#{$botname}> #{message}", user)
end

def sendmessage(message)
  begin

    $socket.send("PRIVMSG " + $current + " :" + message + "\r\n", 0)
    puts "(" + $current + ") <" + $botname + "> " + message
    logtext("<#{$botname}> #{message}", $current)

  rescue Exception => e
    err_log("Failed to sendmessage. #{e.message}")
  end
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
				if $current == ""
					$current = d
				end
				$serverchannel = [d]
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
  $plugins = IO.readlines("settings/plugins.txt")
  
  $plugins.each {|item|
	if item.include?("\n")
		$plugins[$plugins.index(item)] = item.chop
		item = item.chop
	end
  if item[0,1] != "#"
	begin
	load Dir.pwd + "/plugins/" + item
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
	  #err_log("Trace: #{e.backtrace}")
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
		if $timer > 500
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