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
    sendmessage("Rubybot version 4.2 by Umby24")
    sendmessage("Commands are: #{cmdlisting}")
    sendmessage("Total #{$command.length} commands.")
end
def command_gcommands()
    cmdlisting = ""
    $gcommand.each_key do |z|
        cmdlisting += $prefix + z + ","
    end
    sendmessage("Rubybot version 4.2 by Umby24")
    sendmessage("Commands are: #{cmdlisting}")
    sendmessage("Total #{$command.length} commands.")
end
def command_help()
    listing = IO.readlines("plugins/help/#{$args[1]}")
    listing.each do |a|
        sendmessage(a)
    end
end
def command_eval()
    if $host[0, $host.index("!")] != "umby24"
		send_raw("NOTICE " + $host[0, $host.index("!")] + " :You are not authorized to use eval.")
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
        send_raw("QUIT :Quit command by #{$host[0,$host.index("!")]}") 
end
def command_radmin()
    send_raw("MODE " + $current + " -ao " + $args[1])
end
def command_reload()
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
def command_unload()

end
def command_voice()
    send_raw("MODE " + $current + " +v " + $args[1])
end
regCmd("add","command_add")
regCmd("admin","command_admin")
regCmd("admins","command_admins")
regGCmd("admins","command_admins")
regCmd("bold","command_bold")
regCmd("channel","command_channel")
regCmd("eval","command_eval")
regCmd("kick","command_kick")
regCmd("me","command_me")
regCmd("nick","command_nick")
regCmd("now","command_now")
regGCmd("now","command_now")
regCmd("op","command_op")
regCmd("owner","command_owner")
regCmd("part","command_part")
regCmd("plugins","command_plugins")
regCmd("quit","command_quit")
regCmd("radmin","command_radmin")
regCmd("reload","command_reload")
regCmd("rem","command_rem")
regCmd("rop","command_rop")
regCmd("rowner","command_rowner")
regCmd("rvoice","command_rvoice")
regCmd("say","command_say")
regCmd("time","command_time")
regGCmd("time","command_time")
regCmd("topic","command_topic")
regGCmd("topic","command_topic")
regCmd("voice","command_voice")
regCmd("commands","command_commands")
regGCmd("commands","command_gcommands")
regCmd("help","command_help")
regGCmd("help","command_help")
regCmd("nping","command_nping")
regGCmd("nping","command_nping")