def command_add()
    mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
    puts mmessage
    #Add admin.
    afile = File.new("settings/users.txt","a+")
    afile.syswrite(mmessage + "\r\n")
    afile.close
    load_users()
    sendmessage("Admin added.") 
end
def command_admin()
    send_raw("MODE " + $current + " +ao " + $args[1])
end
def command_admins()
    mystring = ""
    $access.each {|what| mystring = mystring + what.chop + ","}
    sendmessage(("My admins are: " + mystring).chop)
end
def command_bold()
    begin         
        mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
        sendmessage(2.chr + mmessage)
    rescue Exception => e
        sendmessage(e.message)
    end 
end
def command_channel()
    mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
    $serverchannel[$serverchannel.length] = mmessage.strip
    send_raw("JOIN " + mmessage.strip)
    $current = mmessage.strip 
end
def command_commands()
    cmdlisting = ""
    $command.each_key do |z|
        cmdlisting += $prefix + z + ","
    end
    sendmessage("Rubybot version 4.3 by Umby24")
    sendmessage("Commands are: #{cmdlisting}")
    sendmessage("Total #{$command.length} commands.")
end
def command_gcommands()
    cmdlisting = ""
    $gcommand.each_key do |z|
        cmdlisting += $prefix + z + ","
    end
    sendmessage("Rubybot version 4.3 by Umby24")
    sendmessage("Commands are: #{cmdlisting}")
    sendmessage("Total #{$gcommand.length} commands.")
end

def command_help()
	result = $help[$args[1]]
	
	if result.class.to_s == "Hash"
		if $args[2] == nil
			sendmessage($name + ": This command has multiple sub-commands. They are listed below. Please try #{$prefix}help #{$args[1]} <sub-command>.")
			helpListing = ""
			result.each_key do |z|
				helpListing += z + ", "	
			end
			helpListing = helpListing[0, helpListing.length - 2]
			
			sendmessage($name + ": " + helpListing)
		else
			sendmessage($name + ": " + result[$args[2]][0])
			sendmessage($name + ": " + result[$args[2]][1])
		end
	else
		sendmessage($name + ": " + result[0])
		sendmessage($name + ": " + result[1])
	end
	
end

def command_eval()
    if $name != "umby24"
		send_raw("NOTICE " + $name + " :You are not authorized to use eval.")
		return
	end
    myeval = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
    begin
        sendmessage(eval(myeval).to_s)
    rescue Exception => e
        sendmessage("Error: " + e.message)
    end 
end
def command_kick()
    send_raw("KICK " + $current + " " + $args[1] + " :" + $args[2]) 
end
def command_me()
    mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
    sendmessage(1.chr + "ACTION " + mmessage + 1.chr)
end
def command_nick()
    mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
    send_raw("NICK " + mmessage)
    $botname = mmessage 
end
def command_now()
    sendmessage(Time.new.to_s) 
end
def command_op()
    send_raw("MODE " + $current + " +o " + $args[1])
end
def command_owner()
    send_raw("MODE " + $current + " +q " + $args[1])
end
def command_part()
    send_raw("PART #{$current}")
    $serverchannel.delete($current)
    if $serverchannel.length == 0
        $serverchannel[0] = "#minebot"
    else
        $current = $serverchannel[$serverchannel.length - 1]
    end 
end
def command_nping()
	$pingtime = Time.now.to_f
	$pinging = true
	send_raw("NOTICE #{$botname} :PING")
end
def command_plugins()
    mystring = ""
    $plugins.each {|plug| mystring += plug + ","}
    sendmessage("Currently loaded plugins: " + mystring.gsub("\n",""))
end
def command_quit()
        pie = 0
        $pia = 0
        $quit = 1
        send_raw("QUIT :Quit command by #{$name}") 
end
def command_radmin()
    send_raw("MODE " + $current + " -ao " + $args[1])
end
def command_reload()
	if ($args[1] != nil or $args[1] != "" or $args[1] != " ") and (File.exists?("plugins/" + $args[1]) == true and File.directory?("plugins/" + $args[1]) == false)
		sendmessage("Reloading " + $args[1] + "...")
		load "plugins/" + $args[1]
		sendmessage("Done.")
		return
	end
		$pie = 0
        $reloaded = 1
        $command = Hash.new
        $gcommand = Hash.new
        $evtmsg = Hash.new
        load Dir.pwd + "/depends/reqfunc.rb"
        load_plugins()
        load_users()
		load_settings()
end
def command_rem()
      mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
      #remove admin.
       begin
         afile = File.new("settings/users.txt","r")
         content = afile.sysread(afile.size)
         content = content.gsub(mmessage + "\r\n", "")
		 content = content.gsub(mmessage + "\n", "")
		 content = content.gsub(mmessage,"")
         afile.close
         afile = File.new("settings/users.txt","w+")
         afile.syswrite(content)
         afile.close
         load_users()
         sendmessage("Admin removed.")
       rescue Exception => e
         err_log(e.message)
       end 
end
def command_rop()
    send_raw("MODE " + $current + " -o " + $args[1])
end
def command_rowner()
    send_raw("MODE " + $current + " -q " + $args[1])
end
def command_rvoice()
    send_raw("MODE " + $current + " -v " + $args[1])
end
def command_say()
    mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
    sendmessage(mmessage)
end
def command_time()
    time = Time.new
    sendmessage(time.strftime("%I:%M:%S %p"))
end
def command_topic()
    if $topic[$current] == nil
        send_raw("TOPIC  #{$current}")
    else
        sendmessage($topic[$current].gsub("\r\n",""))
    end
end
def command_load()
	if File.exist?("plugins/#{$args[1]}") == false
		sendmessage($name + ": Plugin not found.")
		return
	end
	File.open("settings/plugins.txt", "a+") do |aFile|
		aFile.syswrite("\n#{$args[1]}")
	end
	load_plugins()
	puts "Loaded."
end
def command_unload()
	if File.exist?("plugins/#{$args[1]}") == false
		sendmessage($name + ": Plugin not found.")
		return
	end
	newfile = ""
	IO.foreach("settings/plugins.txt") {|line|
		if line.gsub("\n", "") != $args[1]
			newfile = newfile + line + "\n"
		end
	}
	File.open("settings/plugins.txt", "w+") do |aFile|
		aFile.syswrite(newfile)
	end
	load_plugins()
	puts "Unloaded"
end
def command_voice()
    send_raw("MODE " + $current + " +v " + $args[1])
end
regCmd("add","command_add")
regHelp("add",nil,[$prefix + "add [name]", "Add a person to the bot's Admin list."])
regCmd("admin","command_admin")
regHelp("admin",nil,[$prefix + "admin [name]","Gives [name] admin rank on the current channel."])
regCmd("admins","command_admins")
regGCmd("admins","command_admins")
regHelp("admins", nil, [$prefix + "admins","Lists the current bot admins."])
regCmd("bold","command_bold")
regHelp("bold", nil, [$prefix + "bold [text]", "Returns [text] in bold."])
regCmd("channel","command_channel ")
regHelp("channel",nil, [$prefix + " [channel]","Makes the bot join [channel]."])
regCmd("eval","command_eval")
regHelp("eval", nil, [$prefix + "eval [string]","Evalutes the given ruby string. Only works for umby24."])
regCmd("kick","command_kick")
regHelp("kick",nil,[$prefix + "kick [name] [reason]", "Kick [name] out of the channel because of [reason]. (Requires Channel OP+"])
regCmd("load", "command_load")
regHelp("load",nil,[$prefix + "load [filename]", "Loads the plugin [filename]."])
regCmd("me","command_me")
regHelp("me", nil, [$prefix + "me [text]", "Bot returns the actiontext [text]."])
regCmd("nick","command_nick")
regHelp("nick", nil, [$prefix + "nick [name]", "Changes the bot's nick to [name]."])
regCmd("now","command_now")
regGCmd("now","command_now")
regHelp("now", nil, [$prefix + "now","Returns the current time and date, and possibly other information, Depending on Operating system."])
regCmd("op","command_op")
regHelp("op", nil, [$prefix + "op [name]","Gives [name] +o on the current channel."])
regCmd("owner","command_owner")
regHelp("owner", nil, [$prefix + "owner [name]","Gives [name] +q on the current channel."])
regCmd("part","command_part")
regHelp("part", nil, [$prefix + "part [name]", "Makes the bot leave the current channel."])
regCmd("plugins","command_plugins")
regHelp("plugins", nil, [$prefix + "plugins","Lists the currently loaded plugins."])
regCmd("quit","command_quit")
regHelp("quit",nil,[$prefix + "quit","Makes the bot quit IRC and close."])
regCmd("radmin","command_radmin")
regHelp("radmin",nil,[$prefix + "radmin [name]", "Sets mode -a on [name]."])
regCmd("reload","command_reload")
regHelp("reload", nil, [$prefix + "reload [file]", "Makes the bot reload all settings and plugins. (Or just a plugin if [file] is given.)"])
regCmd("rem","command_rem")
regHelp("rem", nil, [$prefix + "rem [name]", "Removes [name] from the bot's admin list."])
regCmd("rop","command_rop")
regHelp("rop", nil, [$prefix + "rop [name]", "Sets mode -o on [name]."])
regCmd("rowner","command_rowner")
regHelp("rowner", nil, [$prefix + "rowner [name]", "Sets mode -q on [name]."])
regCmd("rvoice","command_rvoice")
regHelp("rvoice", nil, [$prefix + "rvoice [name]", "Sets mode -v on [name]."])
regCmd("say","command_say")
regHelp("say",nil,[$prefix + "say [text]", "Makes the bot say [text]."])
regCmd("time","command_time")
regHelp("time",nil,[$prefix + "time","Returns the system local time for the bot."])
regGCmd("time","command_time")
regCmd("topic","command_topic")
regGCmd("topic","command_topic")
regHelp("topic", nil,[$prefix + "topic", "Returns the current topic on this channel."])
regCmd("unload", "command_unload")
regHelp("unload", nil, [$prefix + "unload [file]","Unloads the plugin [file]."])
regCmd("voice","command_voice")
regHelp("voice",nil,[$prefix + "voice [name]","Sets mode +v on [name]."])
regCmd("commands","command_commands")
regGCmd("commands","command_gcommands")
regHelp("commands", nil, [$prefix + "commands","Returns a list of commands that you can use."])
regCmd("help","command_help")
regGCmd("help","command_help")
regCmd("nping","command_nping")
regGCmd("nping","command_nping")
regHelp("nping", nil, [$prefix + "nping", "Returns the bot's ping to the IRC server in MS."])
