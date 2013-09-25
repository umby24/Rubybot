# Ruby IRC Bot

This is one of my side-projects that has grown into a decent, fairly extensible IRC bot.

Tested verisons of Ruby are 1.9.3 +

This is just a base installation, no plugins. You can find a few examples for plugins in my other github projects, and I will provide documentation on writing your own here (Eventually).

## Configuration

Configuration is pretty straightforward, in the settings.txt in the root directory, you will find options for the bot's nick, ident, realname, the server and port to connect to (no SSL, sorry!), the initial channel to connect to, nickserv pass for the bot (if any), and the command prefix.

Inside the settings directory, there are two files. plugins.txt, and users.txt.

To make the bot load a plugin, put the name of the plugin file inside of plugins.txt. One file per line.

Example:
	core.rb
	title.rb
	raw.rb
	ping.rb
	google.rb

users.txt is the file for the bot's admins. Again, one nick per line.

When using commands, the bot will check to see if the user is in this list. If so, it will check to ensure the are logged in to Nickserv. If either of these conditions fails, the user will be limited to the "Guest" commands.

In core.rb (in the plugins directory), the Eval command is limited to a hard-coded user to prevent abuse. You must go and search for "command_eval" in this file, and change it to your nick if you wish to use this command. (Same rules for commands above still apply).

## Included commands

	add [name] - Adds [name] to list of allowed bot admins.
	admin [name] - Gives [name] channel admin (if possible).
	admins - Lists bot admins.
	bold [text] - Sends [text] in bold.
	channel [channel] - Makes the bot join [channel].
	commands - Lists all available commands to the user.
	eval [string] - Makes the bot run the ruby script [string].
	help [command] - Lists help for [command] (If available).
	kick [name] - Kicks [name] from the channel (if possible).
	me [text] - Sends [text] in a /me fasion.
	nick [nickname] - changes the bots nickname.
	now - Gives the system time, date, and timezone.
	nping - Returns the bot's current network latency.
	op [name] - Gives [name] Channel Op (if possible).
	part - Makes the bot part from the current channel.
	plugins - Lists the bot's loaded plugins.
	quit - Quits the bot.
	radmin [name] - Removes Channel Admin from [name].
	reload - Reloads all plugins, settings, and admins.
	rem [name] - Removes [name] from bot allowed admins.
	rop [name] - Removes Channel Op from [name].
	rowner [name] - Removes channel Owner from [name].
	rvoice [name] - Removes voice from [name].
	say [text] - Makes the bot say [text].
	time - Makes the bot give the current time in AM/PM format.
	topic - Gives the topic of the current channel.
	voice [name] - Gives voice to [name] (if possible).

## Plugin API

First part of the plugin API is of course making your code, you can make classes or methods of pretty much any name, just make sure they are unique so they don't interfere with other plugins.
If two plugins have a method with the same name, the one that is loaded last will overwrite the method of the earlier loaded plugin.

If your plugin requires any external libraries, at the top of the file register those with the bot and they will be loaded.

Other than that, there are a number of events you can register within your plugin to allow functionality to be added to the bot by your plugin.

	regMsg(name, method) -- Every time a chat message (PRIVMSG) is received, the bot will run [method]. [name] is just an identifier.
	regCmd(cmd, method) -- Registers [cmd] as an admin command. When the command is run, the bot will call [method]. Command is added to command listing.
	regGCmd(cmd, method) -- Registers [cmd] as a guest command. When the command is run, the bot will call [method]. Command is added to command listing.
	regLib(library) -- Calls the bot to load [library].
	regCon(name, method) -- once connected to an irc server fully (MOTD received), the bot will call [method]. [name] is just an identifier.
	regRead(name, method) -- calls [method] every time data is read off the socket. [name] is an identifier.

### Methods
These are methods included by the bot, what they do, and what arguments they require. They may be used by any plugin.

	logtext(text, channel) -- adds [text] to the end of the log file for [channel]. If a log does not exist for that channel, one will be created.
	err_log(message) -- Adds [message] to the end of the error.log file found in the root directory of the bot.
	send_raw(data) -- sends the raw [data] to the server. (IRC line terminator is automatically added to [data]).
	pm(message, user) -- sends PRIVMSG [message] to [user]. [user] can be a user or a channel.
	sendmessage(message) -- Sends [message] to the currently active channel. ($current).
	load_settings() -- Loads the bot's settings
	load_users() -- Loads the bot's admins.
	load_plugins() -- Loads the bot's plugins.

### Global Variables

These are the variables that are used throughout the bot, that you can use or manipulate from your plugins. You may also create your own global variables and they will persist and be readable by other plugins.

The first section contains fully global variables, second section is only after a message has been received from IRC, and the third group is after a command has been triggered.
	----------------------------------------------------------------------------------------------------------------------
	Variable (Type)        | Use                                                                                         |
	----------------------------------------------------------------------------------------------------------------------	
	$access (Array)        | Holds the names of bot admins.
	$plugins (Array)       | Holds the filenames of loaded plugins.
	$quit (Int)            | Determines if the bot is quitting. If set to 1, the bot will exit.
	$players (Hash)        | Key is channel name, value is an array holding the names of each player in that channel.
	$topic (Hash)          | Key is channel name, value is a string holding the topic for that channel.
	$botname (string)      | Holds the current nick for the bot.
	$realname (string)     | Holds the current real name for the bot.
	$nspass (string)       | Holds the Nickserv password for the bot.
	$ident (string)        | Holds the Ident name for the bot.
	$serverip (string)     | Holds the IP of the current IRC server.
	$serverport (int)      | Holds the port of the current IRC server.
	$serverchannel (Array) | Holds a list of all channels the bot is connected to.
	$current (string)      | Holds the name of the currently selected channel (where chat messages will go to by default).
	$authed (Array)        | Holds the names of all who are authed with Nickserv.
	$prefix (string)       | Holds the current command prefix for the bot.
	$id (bool)             | True if the bot is authed with Nickserv.
	$t1 (Thread)           | Thread that handles incoming data from IRC server.
	$t2 (Thread)           | Thread that handles console input.
	$t3 (Thread)           | Thread that handles auto-reconnection if no ping is received from the irc server after 8 minutes.
	$socket (TCPSocket)    | The socket that is connected to the irc server.
	----------------------------------------------------------------------------------------------------------------------
	$raw (String)    | Contains the raw data pulled from the IRC server.
	$host(String)    | Contains the hostname for the incoming data (All data up to the first space from $raw).
	$dat (String)    | Contains all data after the first space from $raw.
	$second (String) | Contains the IRC code for this message (PRIVMSG, NOTICE, TOPIC, 330, ect.)
	$splits (Array)  | Contains $dat split by spaces, up to 10 times.
	$message (String)| Contains the message for this string. (All data after the ':' in $dat).
	----------------------------------------------------------------------------------------------------------------------
	$cmd (String) | The command that is being called.
	$args (Array) | A list of string that contains the chat message used to trigger the command, split by spaces. (Includes the command itself as $args[0]).
	----------------------------------------------------------------------------------------------------------------------
	
### That's it!

That's all of the variables and methods available to rubybot plugins. If you need more and feel comfortable with it, feel free to dive into the core bot files and add your own!

	