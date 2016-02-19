# Ruby IRC Bot

This is one of my side-projects that has grown into a decent, fairly extensible IRC bot.

Tested verisons of Ruby are 1.9.3 +

This is just a base installation, no plugins. You can find a few examples for plugins in my other github projects, and I will provide documentation on writing your own here.

## Configuration

Configuration is pretty straightforward, in the settings.ini in the settings directory, you will find options for the bot's nick, ident, realname, the server and port to connect to (no SSL, sorry!), the initial channel to connect to, nickserv pass for the bot (if any), and the command prefix.

Additionally in this file is the list of loaded plugins and authorized bot usernames. (Must be nickserv logged in)

To make the bot load a plugin, put the name of the plugin file inside of settings.ini under [Plugins] One file per line.

Example:
	core.rb = nothing
	title.rb = nothing
	raw.rb = nothing
	ping.rb = nothing
	google.rb = nothing

When using commands, the bot will check to see if the user is in the autheorized users list. If so, it will check to ensure the are logged in to Nickserv. If either of these conditions fails, the user will be limited to the "Guest" commands.

In default_commands.rb (in the plugins directory), the Eval command is limited to a hard-coded user to prevent abuse. You must go and search for "handle_eval" in this file, and change it to your nick if you wish to use this command. (Same rules for commands above still apply).

## Included commands

	add [name] - Adds [name] to list of allowed bot admins.
	admins - Lists bot admins.
	blacklist - Blocks the current channel from displaying url titles
	channels - Makes the bot join [channel].
	commands - Lists all available commands to the user.
	eval [string] - Makes the bot run the ruby script [string].
	google [query] - Searches google for [query] and returns the first result.
	help [command] - Lists help for [command] (If available).
	join [channel] - Makes the bot join [channel]
	load [file] - Loads [file] from the plugins directory, and adds it to plugins.txt.
	nick [nickname] - changes the bots nickname.
	part - Makes the bot part from the current channel.
	ping - The bot says "Pong" to show you how fast it can react.
	plugins - Lists the bot's loaded plugins.
	quit - Quits the bot.
	reload [file] - Reloads all plugins, settings, and admins. If [file] is specified, only that plugin will be reloaded.
	rem [name] - Removes [name] from bot allowed admins.
	say [text] - Makes the bot say [text].
	time - Makes the bot give the current time in AM/PM format.
	topic - Gives the topic of the current channel.
	unblacklist - Unblocks the current channel from url titles.
	uptime - (Inaccurate) shows the bot's uptime
	utc [offset] - Shows the current time at the given utc offset. 
	wiki [query] - Searches wikipedia for the given query, and returns the first paragraph.

## Plugin API
Plugins must be written in their own class, which must inherit the Plugin superclass. The only required method for you to implement is 'plugin_init'. This method will be called when your plugin is loaded, and at a minimum you should set three instance variables, @name, @author, and @version.

After this what you decided to plugin with the bot is up to you.

Methods in your plugin class will be called based on various events that occur that you must subscribe to.

The events are:
	message - Event triggers when a message is received in any connected channel.
	read - Event triggers after a packet has been read off the wire.
	command - Event triggers when a command is called.
	join - Event triggers when a user joins a channel you are connected to.
	packet - Event triggers when a packet is received and is ready for parsing.

To register a method to be called on one of these events, call: 
	@bot.event.register_[event](name, self.method(:method_name)) 

Method signatures of each event:
	message - (name, channel, message)
	read - (fullpacket)
	command - (host, channel, message, args, guest)
	join - (channel)
	packet - (prefix, command, args, raw)


*Note:* When registering a command, you must specify if the command is accessible by non-authorized users or not. (True: guests can use, False: guests cannot.)
	@bot.event.register_command(name, self.method(:method_name), true)


### Useful things within plugins
Plugins get provided the @bot variable, which allows you access to several things. 

### Logging

The first useful item to you is logging.
	@bot.log.info("Hello from my plugin!")

Supported log levels are info, debug, warn, error, fatal, unknown.
All log levels will be logged to disk by default, and only informational, error, and fatal will log to console.

### Network
 (Each command here should be prefaced in your plugins with @bot.network.)

	send_raw(data) - Sends a raw packet to the irc server, \r\n is added for you.
	send_privmsg(dest, message) - Sends a privmsg to dest, with the message provided.
	send_notice(dest, message) - Sends a NOTICE to the given location, with the given message.
	send_all(message) - Sends a PRIVMSG to all connected channels with the given message.

 Example:
	@bot.network.send_notice("user1", "Hello from rubybot!")


### That's it!

If you need more and feel comfortable with it, feel free to dive into the core bot files and add your own!
If you think it will be useful to others as well, make a pull request!

There are a few more things you can dig into such as your plugins using the provided settings.ini file for storing settings, adding command help and so on, but there are examples of this in the code bas already.

