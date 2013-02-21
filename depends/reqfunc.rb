#Required Functions
def logtext(text, channel, network)
	time = Time.new
	mytext = ""
	
	if channel.include?(":") == false
		if File.directory?("logs") == false
			Dir.mkdir("logs")
		end
		if File.directory?("logs/" + network) == false
			Dir.mkdir("logs/" + network)
		end
		if File.directory?("logs/" + network + "/" + channel) == false
			Dir.mkdir("logs/" + network + "/" + channel)
		end

		afile = File.new(Dir.pwd + "/logs/" + network + "/" + channel + "/" + time.strftime("%m-%d-%Y") + ".txt", "a+")
		afile.syswrite("[" + time.strftime("%I:%M:%S %p") + "]" + text + "\r")
		afile.close
	end
end

def err_log(message)
  afile = File.new("error.log","a")
  afile.write("\n" + message)  
end

def send_raw(data, network)
	puts $networks[network + "_serverip"]
	$networks[network + "_socket"].send(data + "\r\n", 0)
end

def pm(message,user,network)
  send_raw("PRIVMSG " + user + " :" + message,network)
  logtext("<#{$networks[network + "_botname"]}> #{message}", user,network)
end

def sendmessage(message,network)
  begin

    pm(message,$networks[network + "_current"],network)
    puts "(" + $networks[network + "_current"] + ") <" + $networks[network + "_botname"] + "> " + message
    logtext("<#{$networks[network + "_botname"]}> #{message}", $networks[network + "_current"],network)

  rescue Exception => e
    err_log("Failed to sendmessage. #{e.message}")
  end
end


def load_users(network)
	begin
	  $networks[network + "_access"] = IO.readlines("settings/users_" + network + ".txt")
	rescue
	  err_log("ERROR: Users file not found.")
	end
	puts "Users loaded"
end

def load_plugins()
$networks["networks"].each {|network|
  begin
  $networks[network + "_plugins"] = IO.readlines("settings/plugins.txt")
  $networks[network + "_plugins"].each {|item|
  if item[0,1] != "#"
  if item[0,1] == "\n"
	next
  end
  if item.include?("\n")
    load Dir.pwd + "/plugins/" + item.chop
	else
	load Dir.pwd + "/plugins/" + item
	end
	end
  }
  rescue Exception => e
    err_log("Error loading plugins: #{e.message}")
  end
 }
 begin
    load_commands()
  rescue Exception => e
    err_log("Error generating cmd.rb: #{e.message}")
  end
end

def load_commands()

  #load commands
  commands = Dir.entries(Dir.pwd + "/plugins/cmd")
  commandhash = Hash.new
  
  commands.each do |f|
    if f != "." && f != ".."
    afile = File.new(Dir.pwd + "/plugins/cmd/#{f}","r")
    content = afile.sysread(90000)
    afile.close()
    commandhash.store(f,content)
    end
  end
  
  #Load help
  helps = Dir.entries(Dir.pwd + "/plugins/help")
  helphash = Hash.new
  
  helps.each do |f|
    if f != "." && f != ".."
    afile = File.new(Dir.pwd + "/plugins/help/#{f}","r")
    content = afile.sysread(90000)
    afile.close()
    newcontent = ""
    content.each_line do |z|
      z = z.gsub("\r","")
      z = z.strip
      newcontent += "sendmessage(\"#{z}\",network)\n"
    end
    helphash.store(f,newcontent)
    end
  end
  
  #Guest help and commands loader
  gcommands = Dir.entries(Dir.pwd + "/plugins/gcmd")
  gcommandhash = Hash.new
  
  gcommands.each do |f|
    if f != "." && f != ".."
    afile = File.new(Dir.pwd + "/plugins/gcmd/#{f}","r")
    content = afile.sysread(90000)
    afile.close()
    gcommandhash.store(f,content)
    end
  end
  
  cmdfile = "def docmd(network)\nif $networks[network + \"_okay\"] == true\nif $networks[network + \"_splits\"][1] == $networks[network + \"_botname\"]\n$networks[network + \"_current\"] = $networks[network + \"_host\"][0,$networks[network + \"_host\"].index(\"!\")]\nelse\n$networks[network + \"_current\"] = $networks[network + \"_splits\"][1]\nend\noverride = false\nif $networks[network + \"_authed\"].include?($networks[network + \"_host\"][0,$networks[network + \"_host\"].index(\"!\")]) == false && $networks[network + \"_cmd\"] != \"auth \" && override == false\nsend_raw(\"whois \" + $networks[network + \"_host\"][0,$networks[network + \"_host\"].index(\"!\")],network)\nelse\n$networks[network + \"_args\"] = $networks[network + \"_message\"].split(\" \",30)"
  #Now to generate the main commands list, and the help command.
  cmdfile += "\nif $networks[network + \"_cmd\"][0,9] == \"commands \"\n"
  cmdfile += "\nsendmessage(\"Rubybot version 5 by Umby24 - http://umby.d3s.co\",network)\n"
  cmdlisting = "+commands, +help, "
  
  commandhash.each_key do |z|
    cmdlisting += "+#{z}, "
  end
  
  cmdfile += "sendmessage(\"#{cmdlisting}\",network)"
  cmdfile += "\nsendmessage(\"Total #{commandhash.length + 2} commands.\",network)\nend\n"
  
  #help command.. oh boy.
  cmdfile += "if $networks[network + \"_cmd\"][0,5] == \"help \"\ncase $networks[network + \"_args\"][1]\n"
  helphash.each_pair do |z,s|
    cmdfile += "when \"#{z}\"\n#{s}"
  end
    cmdfile += "\nelse\nsendmessage(\"Help file for '\" + $networks[network + \"_args\"][1] + \"' not found.\",network)\nsendmessage(\"If you are looking for a full list of commands, see +commands.\",network)"
  cmdfile += "\nend\nend\n"
  #Write in commands
  commandhash.each_pair do |z,s|
    mylength = z.length + 1
    cmdfile += "if $networks[network + \"_cmd\"][0,#{mylength}] == \"#{z} \"\n#{s}\nend\n"
  end
  #END ADMIN COMMANDS: BEGIN GUEST COMMANDS.
  cmdfile += "end\nelse\n$networks[network + \"_args\"] = $networks[network + \"_message\"].split(\" \",30)\n"
  cmdfile += "if $networks[network + \"_cmd\"][0,9] == \"commands \"\n"
  cmdfile += "\nsendmessage(\"Rubybot version 5 by Umby24 - http://umby.d3s.co\",network)\n"
  cmdlisting = "Guest Commands: +commands, +help, "
  gcommandhash.each_key do |z|
    cmdlisting += "+#{z}, "
  end
  cmdfile += "sendmessage(\"#{cmdlisting}\",network)"
  cmdfile += "\nsendmessage(\"Total #{gcommandhash.length + 2} commands.\",network)\nend\n"
  #help command.. oh boy.
  cmdfile += "if $networks[network + \"_cmd\"][0,5] == \"help \"\ncase $networks[network + \"_args\"][1].downcase\n"
  helphash.each_pair do |z,s|
    cmdfile += "when \"#{z}\"\n#{s}"
  end
  cmdfile += "\nelse\nsendmessage(\"Help file for '\" + $networks[network + \"_args\"][1] + \"' not found.\",network)\nsendmessage(\"If you are looking for a full list of commands, see +commands.\",network)"
  cmdfile += "end\nend\n"
  #Write in commands
  gcommandhash.each_pair do |z,s|
    mylength = z.length + 1
    cmdfile += "if $networks[network + \"_cmd\"][0,#{mylength}] == \"#{z.downcase} \"\n#{s}\nend\n"
  end
  cmdfile += "\nend\nend"
  myfile = File.new("depends/cmd.rb","w+")
  myfile.syswrite(cmdfile)
  myfile.close()
  load "depends/cmd.rb"
end



def loop_load(network)
  while $networks[network + "_quit"] == 0
    begin
    load Dir.pwd + "/depends/loop.rb"
    socketloop(network)
    rescue Exception => e
      # This enables you to correct your mistakes infinatly until you find the issue
      # as all errors will be logged, it shouldn't be too hard to pinpoint.
      err_log("Error Reloading loop; Attempting to use current version.")
      err_log("Error message: #{e.message}")
	  err_log("Err trace: #{e.backtrace}")
      loop_load(network)
    end
  end
  if $networks[network + "_quit"] == 1
    $networks[network + "_socket"].close()
  end
end
