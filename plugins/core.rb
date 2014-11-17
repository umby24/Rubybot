def command_add()
    mmessage = $message[$message.index(" ") + 1, $message.length - ($message.index(" ") + 1)]
    #Add admin.
    $access.push(mmessage)
    afile = File.new("settings/users.txt","w+")
    afile.syswrite($access.join("\n"))
    afile.close()
    load_users()
    sendmessage("Admin added.") 
end
def command_admin()
    send_raw("MODE " + $current + " +ao " + $args[1])
end
def command_admins()
    mystring = $access.join(", ")
    sendmessage("My admins are: " + mystring.gsub("\r", "").gsub("\n",""))
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
    cmdlisting = $command.keys.sort().join(", ")
    #$command.each_key do |z|
    #    cmdlisting += $prefix + z + ","
    #end
    send_notice($name, "Rubybot version 4.4 by Umby24")
    send_notice($name, "Commands are: #{cmdlisting}")
    send_notice($name, "Total #{$command.length} commands.")
end
def command_gcommands()
    cmdlisting = $gcommand.keys.sort().join(", ")
    #$gcommand.each_key do |z|
    #    cmdlisting += $prefix + z + ","
    #end
    send_notice($name, "Rubybot version 4.4 by Umby24")
    send_notice($name, "Commands are: #{cmdlisting}")
    send_notice($name, "Total #{$gcommand.length} commands.")
end

def command_help()
    if $args[1] == nil
        send_notice($name, "No arguments provided. For a commands listing see " + $prefix + "commands.")
        return
    end
    
    found = false
    helpmodule = nil
    
    $help.each do |hm|
        if hm.command == $args[1]
            found = true
            helpmodule = hm
        end
    end
    
    if found == false
        send_notice($name, "Help for " + $args[1] + " not found.")
        return
    end
    
    if $args[2] == nil
        helpmodule.SendBaseHelp($name)
        return
    end
    
    if $args[2].downcase == "arg" # Person is looking for an argument.
        index = $message.index($args[2]) + $args[2].length + 1
        mmessage = $message[index, $message.length - index]
        puts "|" + mmessage + "|"
        helpmodule.SendArgHelp($name, mmessage) #TODO: Make this an mmessage
    elsif $args[2] != "arg" and $args[3] == nil
        helpmodule.SendSubHelp($name, $args[2])
    elsif $args[3].downcase == "arg" and $args[4] != nil
        index = $message.index($args[3]) + $args[3].length + 1
        mmessage = $message[index, $message.length - index]
        helpmodule.SendSubargHelp($name, $args[2], mmessage) #TODO: Make this and mmessage.
    else
        send_notice($name, "There was an error with your help request.")
        send_notice($name, "Usage is " + $prefix + "help [command] [subcommand or 'arg'](optional) [argument or 'arg'](optional) [argument](optional)")
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
        puts e.backtrace
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
    mystring = $plugins.join(", ")
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
    $access.remove(mmessage)
    afile = File.new("settings/users.txt","w+")
    afile.syswrite($access.join("\n"))
    afile.close()
    load_users()
    sendmessage("Admin removed.")
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
        send_notice($name, $topic[$current].gsub("\r\n",""))
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
    sendmessage("Plugin loaded.")
end
def command_unload()
    if File.exist?("plugins/#{$args[1]}") == false
        sendmessage($name + ": Plugin not found.")
        return
    end
    if $plugins.include?($args[1]) == false
        sendmessage($name + ": Plugin is not loaded")
        return
    end
    #IO.foreach("settings/plugins.txt") {|line|
    #   if line.gsub("\n", "") != $args[1]
    #       newfile = newfile + line + "\n"
    #   end
    #}
    #File.open("settings/plugins.txt", "w+") do |aFile|
    #   aFile.syswrite(newfile)
    #end
    File.open("settings/plugins.txt", "w+") do |aFile|
        aFile.syswrite($plugins.join("\n"))
    end
    load_plugins()
    sendmessage("Plugin unloaded.")
end
def command_voice()
    send_raw("MODE " + $current + " +v " + $args[1])
end
regCmd("add","command_add")

help = Help.new("add")
help.addDescription("Add a person to the bot's Admin list.")
help.addArgument("name","The name of the person to add to the admin list.")
$help.push(help)

regCmd("admin","command_admin")

help = Help.new("admin")
help.addDescription("Gives [name] admin rank on the current channel.")
help.addArgument("name", "The person to give admin to.")
$help.push(help)

regCmd("admins","command_admins")
regGCmd("admins","command_admins")

help = Help.new("admins")
help.addDescription("Lists the current bot admins.")
$help.push(help)

regCmd("bold","command_bold")

help = Help.new("bold")
help.addDescription("Returns [text] in bold.")
help.addArgument("text", "The text to send in bold.")
$help.push(help)

regCmd("channel","command_channel")

help = Help.new("channel")
help.addDescription("Makes the bot join [channel].")
help.addArgument("channel", "The channel to make the bot join.")
$help.push(help)

regCmd("eval","command_eval")

help = Help.new("eval")
help.addDescription("Evaluates the given ruby string. Only works for umby24.")
help.addArgument("string", "The ruby string to evaluate.")
$help.push(help)

regCmd("kick","command_kick")

help = Help.new("kick")
help.addDescription("Kick [name] out of the channel because of [reason]. (Requires Channel OP+)")
help.addArgument("name", "The nick of the person to kick out.")
help.addArgument("reason", "The reason the person is being kicked.")
$help.push(help)

regCmd("load", "command_load")

help = Help.new("load")
help.addDescription("Loads the plugin [filename].")
help.addArgument("filename", "The plugin to load. Must include .rb at the end. Loads from plugins folder.")
$help.push(help)

regCmd("me","command_me")

help = Help.new("me")
help.addDescription("Bot returns the actiontext [text].")
help.addArgument("text", "The text to have the bot send as an action.")
$help.push(help)

regCmd("nick","command_nick")

help = Help.new("nick")
help.addDescription("Changes the bot's nick to [name].")
help.addArgument("name", "The bot's new nick.")
$help.push(help)

regCmd("now","command_now")
regGCmd("now","command_now")

help = Help.new("now")
help.addDescription("Returns the current time and date, and possibly other information, Depending on Operating system.")
$help.push(help)

regCmd("op","command_op")

help = Help.new("op")
help.addDescription("Gives [name] +o on the current channel.")
help.addArgument("name", "the name of the person to give +o.")
$help.push(help)

regCmd("owner","command_owner")

help = Help.new("owner")
help.addDescription("Gives [name] +q on the current channel.")
help.addArgument("name", "The person to give +q to.")
$help.push(help)

regCmd("part","command_part")

help = Help.new("part")
help.addDescription("Makes the bot leave the current channel.")
$help.push(help)

regCmd("plugins","command_plugins")

help = Help.new("plugins")
help.addDescription("Lists the currently loaded plugins.")
$help.push(help)

regCmd("quit","command_quit")

help = Help.new("quit")
help.addDescription("Makes the bot quit IRC and close.")
$help.push(help)

regCmd("radmin","command_radmin")

help = Help.new("radmin")
help.addDescription("Sets mode -a on [name].")
help.addArgument("name", "The user to apply -a to.")
$help.push(help)

regCmd("reload","command_reload")

help = Help.new("reload")
help.addDescription("Makes the bot reload all settings and plugins. (Or just a plugin if [file] is given.)")
help.addArgument("file", "The individual file to reload.", true)
$help.push(help)

regCmd("rem","command_rem")

help = Help.new("rem")
help.addDescription("Removes [name] from the bot's admin list.")
help.addArgument("name", "The person to purge from the admin list.")
$help.push(help)

regCmd("rop","command_rop")

help = Help.new("rop")
help.addDescription("Sets mode -o on [name].")
help.addArgument("name", "The name of the person to set -o on.")
$help.push(help)

regCmd("rowner","command_rowner")

help = Help.new("rowner")
help.addDescription("Sets mode -q on [name].")
help.addArgument("name", "The name of the person to set -q on.")
$help.push(help)

regCmd("rvoice","command_rvoice")

help = Help.new("rvoice")
help.addDescription("Sets mode -v on [name].")
help.addArgument("name", "The name of the person to set -v on.")
$help.push(help)

regCmd("say","command_say")

help = Help.new("say")
help.addDescription("Makes the bot say [text].")
help.addArgument("text", "The text to make the bot say.")
$help.push(help)

regCmd("time","command_time")
regGCmd("time","command_time")

help = Help.new("time")
help.addDescription("Returns the system local time for the bot.")
$help.push(help)

regCmd("topic","command_topic")
regGCmd("topic","command_topic")

help = Help.new("topic")
help.addDescription("Returns the current topic on this channel.")
$help.push(help)

regCmd("unload", "command_unload")

help = Help.new("unload")
help.addDescription("Unloads the plugin [file].")
help.addArgument("file", "The file to unload. Must include the .rb extension.")
$help.push(help)

regCmd("voice","command_voice")

help = Help.new("voice")
help.addArgument("name","Name of the person to give voice")
help.addDescription("Sets mode +v on [name].")
$help.push(help)

regCmd("commands","command_commands")
regGCmd("commands","command_gcommands")
help = Help.new("commands")
help.addDescription("Returns a list of commands that you can use.")
$help.push(help)

regCmd("help","command_help")
regGCmd("help","command_help")

regCmd("nping","command_nping")
regGCmd("nping","command_nping")

help = Help.new("nping")
help.addDescription("Returns the bot's ping to the IRC server in MS.")
$help.push(help)
