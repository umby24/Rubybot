def docmd(network)
if $networks[network + "_okay"] == true
if $networks[network + "_splits"][1] == $networks[network + "_botname"]
$networks[network + "_current"] = $networks[network + "_host"][0,$networks[network + "_host"].index("!")]
else
$networks[network + "_current"] = $networks[network + "_splits"][1]
end
override = false
if $networks[network + "_authed"].include?($networks[network + "_host"][0,$networks[network + "_host"].index("!")]) == false && $networks[network + "_cmd"] != "auth " && override == false
send_raw("whois " + $networks[network + "_host"][0,$networks[network + "_host"].index("!")],network)
else
$networks[network + "_args"] = $networks[network + "_message"].split(" ",30)
if $networks[network + "_cmd"][0,9] == "commands "

sendmessage("Rubybot version 5 by Umby24 - http://umby.d3s.co",network)
sendmessage("+commands, +help, +add, +admin, +admins, +bold, +channel, +eval, +kick, +me, +nick, +now, +op, +owner, +part, +plugins, +quit, +radmin, +reload, +rem, +rop, +rowner, +rvoice, +say, +time, +topic, +voice, ",network)
sendmessage("Total 27 commands.",network)
end
if $networks[network + "_cmd"][0,5] == "help "
case $networks[network + "_args"][1]
when "add"
sendmessage("+add [name] -- Add a person to the bot's Admin list.",network)
when "admin"
sendmessage("+admin [name] -- Gives [name] admin rank on the current channel.",network)
when "admins"
sendmessage("+admins -- Lists the current bot admins.",network)
when "bold"
sendmessage("+bold [text] -- Returns [text] in bold.",network)
when "channel"
sendmessage("+channel [channel] -- Makes the bot join [channel]",network)
when "eval"
sendmessage("+eval [string] -- Evaluates the given ruby string.",network)
when "help"
sendmessage("Help [command] -- gives you the correct functionality and acceptable aruguments for [command].",network)
sendmessage("-- For a full list of commands, see the command '+commands'.",network)
when "kick"
sendmessage("Kick [name] [reason] (Requires chanop) -- Kick [name] out of the channel because of [reason].",network)
when "me"
sendmessage("+me [text] -- Bot returns the actiontext [text].",network)
when "nick"
sendmessage("+nick [name] -- Changes the bot's nick to [name].",network)
when "now"
sendmessage("+now -- Returns the current time and date, and possibly other information, Depending on Operating system.",network)
when "op"
sendmessage("+op [name] -- Gives [name] +o on the current channel.",network)
when "owner"
sendmessage("+owner [name] -- Gives [name] +q on the current channel.",network)
when "part"
sendmessage("+part -- Makes the bot leave the current channel.",network)
when "plugins"
sendmessage("Plugins -- Tells you what plugins the bot currently has loaded.",network)
when "quit"
sendmessage("+quit -- Closes the bot.",network)
when "radmin"
sendmessage("+radmin [name] -- Sets mode -a on [name].",network)
when "reload"
sendmessage("+reload -- Force a reload of all the bot's plugins, and re-creation of the commands script.",network)
when "rem"
sendmessage("+rem [name] -- Removes [name] from the bot's admin list.",network)
when "rop"
sendmessage("+rop [name] -- Sets mode -o on [name]",network)
when "rowner"
sendmessage("+rowner [name] -- Sets mode -q on [name]",network)
when "rvoice"
sendmessage("+rvoice [name] -- Sets mode -v on [name]",network)
when "say"
sendmessage("+say [text] -- has the bot say [text]",network)
when "time"
sendmessage("" + 2.chr + @@rname + ":" + 2.chr + " +time - Displays the current 12-hour time. (GMT +0100)",network)
sendmessage("",network)
when "topic"
sendmessage("+topic -- Displays the topic of the current channel.",network)
when "voice"
sendmessage("+voice [name] -- Sets mode +v on [name].",network)

else
sendmessage("Help file for '" + $networks[network + "_args"][1] + "' not found.",network)
sendmessage("If you are looking for a full list of commands, see +commands.",network)
end
end
if $networks[network + "_cmd"][0,4] == "add "
      mmessage = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
      #Add admin.
      afile = File.new("settings/users_" + network + ".txt","a+")
      afile.syswrite(mmessage + "\r\n")
      afile.close
      load_users(network)
      sendmessage("Admin added.",network) 

end
if $networks[network + "_cmd"][0,6] == "admin "
 send_raw("MODE " + $networks[network + "_current"] + " +ao " + $networks[network + "_args"][1])

end
if $networks[network + "_cmd"][0,7] == "admins "
mystring = ""
        $networks[network + "_access"].each {|what| mystring = mystring + what.chop + ","}
        sendmessage("My admins are: " + mystring,network) 

end
if $networks[network + "_cmd"][0,5] == "bold "
begin         
        mmessage = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
        sendmessage(2.chr + mmessage,network)
      rescue Exception => e
        sendmessage(e.message,network)
      end 

end
if $networks[network + "_cmd"][0,8] == "channel "
mmessage = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
       $networks[network + "_serverchannel"][$networks[network + "_serverchannel"].length] = mmessage.strip
       send_raw("JOIN " + mmessage.strip)
       $networks[network + "_current"] = mmessage.strip 

end
if $networks[network + "_cmd"][0,5] == "eval "
myeval = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
      begin
        sendmessage(eval(myeval).to_s,network)
      rescue Exception => e
        sendmessage("Error: " + e.message,network)
      end 

end
if $networks[network + "_cmd"][0,5] == "kick "
send_raw("KICK " + $networks[network + "_current"] + " " + $networks[network + "_args"][1] + " :" + $networks[network + "_args"][2]) 

end
if $networks[network + "_cmd"][0,3] == "me "
mmessage = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
sendmessage(1.chr + "ACTION " + mmessage + 1.chr,network)

end
if $networks[network + "_cmd"][0,5] == "nick "
mmessage = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
       send_raw("NICK " + mmessage,network)
       $networks[network + "_botname"] = mmessage 

end
if $networks[network + "_cmd"][0,4] == "now "
sendmessage(Time.new.to_s,network) 

end
if $networks[network + "_cmd"][0,3] == "op "
send_raw("MODE " + $networks[network + "_current"] + " +o " + $networks[network + "_args"][1]) 

end
if $networks[network + "_cmd"][0,6] == "owner "
send_raw("MODE " + $networks[network + "_current"] + " +q " + $networks[network + "_args"][1]) 

end
if $networks[network + "_cmd"][0,5] == "part "
senda("PART #{$networks[network + "_current"]}")
        $networks[network + "_serverchannel"].delete($networks[network + "_current"])
        if $networks[network + "_serverchannel"].length == 0
          $networks[network + "_serverchannel"][0] = "#minebot"
        else
          $networks[network + "_current"] = $networks[network + "_serverchannel"][$networks[network + "_serverchannel"].length - 1]
        end 

end
if $networks[network + "_cmd"][0,8] == "plugins "
mystring = ""
$networks[network + "_plugins"].each {|plug| mystring += plug + ","}
sendmessage("Currently loaded plugins: " + mystring,network)
end
if $networks[network + "_cmd"][0,5] == "quit "
        pie = 0
        $networks[network + "_pia"] = 0
        $networks[network + "_quit"] = 1
        send_raw("QUIT :Quit command by #{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]}",network) 

end
if $networks[network + "_cmd"][0,7] == "radmin "
send_raw("MODE " + $networks[network + "_current"] + " -ao " + $networks[network + "_args"][1],network) 

end
if $networks[network + "_cmd"][0,7] == "reload "
		$networks[network + "_pie"] = 0
        $networks[network + "_reloaded"] = 1
        load Dir.pwd + "/depends/reqfunc.rb"
        load Dir.pwd + "/plugins/func.rb"
		load Dir.pwd + "/plugins/libs.rb"
        load_plugins()
        load_users(network)
		load_settings()
		load Dir.pwd + "/depends/cmd.rb"
		load Dir.pwd + "/plugins/message.rb"
		puts "Reloaded.. kinda?"
end
if $networks[network + "_cmd"][0,4] == "rem "
      mmessage = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
      #remove admin.
       begin
         afile = File.new("settings/users_" + network + ".txt","r")
         content = afile.sysread(afile.size)
         content = content.gsub(mmessage + "\r\n", "")
		 content = content.gsub(mmessage + "\n", "")
		 content = content.gsub(mmessage,"")
         afile.close
         afile = File.new("settings/users_" + network + ".txt","w+")
         afile.syswrite(content)
         afile.close
         load_users()
         sendmessage("Admin removed.",network)
       rescue Exception => e
         sendmessage(e.message,network)
		 err_log(e.backtrace)
       end 

end
if $networks[network + "_cmd"][0,4] == "rop "
send_raw("MODE " + $networks[network + "_current"] + " -o " + $networks[network + "_args"][1],network) 

end
if $networks[network + "_cmd"][0,7] == "rowner "
 send_raw("MODE " + $networks[network + "_current"] + " -q " + $networks[network + "_args"][1],network)

end
if $networks[network + "_cmd"][0,7] == "rvoice "
send_raw("MODE " + $networks[network + "_current"] + " -v " + $networks[network + "_args"][1],network) 

end
if $networks[network + "_cmd"][0,4] == "say "
 
mmessage = $networks[network + "_message"][$networks[network + "_message"].index(" ") + 1, $networks[network + "_message"].length - ($networks[network + "_message"].index(" ") + 1)]
      sendmessage(mmessage,network)
end
if $networks[network + "_cmd"][0,5] == "time "
time = Time.new
sendmessage(time.strftime("%I:%M:%S %p"),network) 

end
if $networks[network + "_cmd"][0,6] == "topic "
if $networks[network + "_topic"][$networks[network + "_current"]] == nil
puts $networks[network + "_current"]
send_raw("TOPIC  #{$networks[network + "_current"]}",network)
else
sendmessage($networks[network + "_topic"][$networks[network + "_current"]].gsub("\r\n",""),network)
end
 

end
if $networks[network + "_cmd"][0,6] == "voice "
send_raw("MODE " + $networks[network + "_current"] + " +v " + $networks[network + "_args"][1],network) 

end
end
else
$networks[network + "_args"] = $networks[network + "_message"].split(" ",30)
if $networks[network + "_cmd"][0,9] == "commands "

sendmessage("Rubybot version 5 by Umby24 - http://umby.d3s.co",network)
sendmessage("Guest Commands: +commands, +help, +admins, +now, +plugins, +time, +topic, ",network)
sendmessage("Total 7 commands.",network)
end
if $networks[network + "_cmd"][0,5] == "help "
case $networks[network + "_args"][1].downcase
when "add"
sendmessage("+add [name] -- Add a person to the bot's Admin list.",network)
when "admin"
sendmessage("+admin [name] -- Gives [name] admin rank on the current channel.",network)
when "admins"
sendmessage("+admins -- Lists the current bot admins.",network)
when "bold"
sendmessage("+bold [text] -- Returns [text] in bold.",network)
when "channel"
sendmessage("+channel [channel] -- Makes the bot join [channel]",network)
when "eval"
sendmessage("+eval [string] -- Evaluates the given ruby string.",network)
when "help"
sendmessage("Help [command] -- gives you the correct functionality and acceptable aruguments for [command].",network)
sendmessage("-- For a full list of commands, see the command '+commands'.",network)
when "kick"
sendmessage("Kick [name] [reason] (Requires chanop) -- Kick [name] out of the channel because of [reason].",network)
when "me"
sendmessage("+me [text] -- Bot returns the actiontext [text].",network)
when "nick"
sendmessage("+nick [name] -- Changes the bot's nick to [name].",network)
when "now"
sendmessage("+now -- Returns the current time and date, and possibly other information, Depending on Operating system.",network)
when "op"
sendmessage("+op [name] -- Gives [name] +o on the current channel.",network)
when "owner"
sendmessage("+owner [name] -- Gives [name] +q on the current channel.",network)
when "part"
sendmessage("+part -- Makes the bot leave the current channel.",network)
when "plugins"
sendmessage("Plugins -- Tells you what plugins the bot currently has loaded.",network)
when "quit"
sendmessage("+quit -- Closes the bot.",network)
when "radmin"
sendmessage("+radmin [name] -- Sets mode -a on [name].",network)
when "reload"
sendmessage("+reload -- Force a reload of all the bot's plugins, and re-creation of the commands script.",network)
when "rem"
sendmessage("+rem [name] -- Removes [name] from the bot's admin list.",network)
when "rop"
sendmessage("+rop [name] -- Sets mode -o on [name]",network)
when "rowner"
sendmessage("+rowner [name] -- Sets mode -q on [name]",network)
when "rvoice"
sendmessage("+rvoice [name] -- Sets mode -v on [name]",network)
when "say"
sendmessage("+say [text] -- has the bot say [text]",network)
when "time"
sendmessage("" + 2.chr + @@rname + ":" + 2.chr + " +time - Displays the current 12-hour time. (GMT +0100)",network)
sendmessage("",network)
when "topic"
sendmessage("+topic -- Displays the topic of the current channel.",network)
when "voice"
sendmessage("+voice [name] -- Sets mode +v on [name].",network)

else
sendmessage("Help file for '" + $networks[network + "_args"][1] + "' not found.",network)
sendmessage("If you are looking for a full list of commands, see +commands.",network)end
end
if $networks[network + "_cmd"][0,7] == "admins "
mystring = ""
        $networks[network + "_access"].each {|what| mystring = mystring + what.chop + ","}
        sendmessage("My admins are: " + mystring,network) 

end
if $networks[network + "_cmd"][0,4] == "now "
sendmessage(Time.new.to_s,network) 

end
if $networks[network + "_cmd"][0,8] == "plugins "
mystring = ""
$networks[network + "_plugins"].each {|plug| mystring += plug + ","}
sendmessage("Currently loaded plugins: " + mystring,network)
end
if $networks[network + "_cmd"][0,5] == "time "
time = Time.new
sendmessage(time.strftime("%I:%M:%S %p"),network) 

end
if $networks[network + "_cmd"][0,6] == "topic "
if $networks[network + "_topic"][$networks[network + "_current"]] == nil
puts $networks[network + "_current"]
send_raw("TOPIC  #{$networks[network + "_current"]}",network)
else
sendmessage($networks[network + "_topic"][$networks[network + "_current"]].gsub("\r\n",""),network)
end
 

end

end
end