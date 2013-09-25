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

[To be done later, for now see examples]
	
	