
# noinspection RubyResolve
class Default_Commands < Plugin
  def plugin_init
    @name = 'Default Plugins'
    @author = 'umby24'
    @version = 1.1

    # Register the commands with the bot
    @bot.event.register_command('auth', self.method(:handle_auth), true)
    @bot.event.register_command('add', self.method(:handle_add), false)
    @bot.event.register_command('admins', self.method(:handle_admins), false)
    @bot.event.register_command('channels', self.method(:handle_channels), true)
    @bot.event.register_command('commands', self.method(:handle_commands), true)
    @bot.event.register_command('eval', self.method(:handle_eval), false)
    @bot.event.register_command('help', self.method(:handle_help), true)
    @bot.event.register_command('join', self.method(:handle_join), false)
    @bot.event.register_command('load', self.method(:handle_load), false)
    @bot.event.register_command('nick', self.method(:handle_nick), false)
    @bot.event.register_command('part', self.method(:handle_part), false)
    @bot.event.register_command('plugins', self.method(:handle_plugins), true)
    @bot.event.register_command('quit', self.method(:handle_quit), false)
    @bot.event.register_command('reload', self.method(:handle_reload), false)
    @bot.event.register_command('rem', self.method(:handle_rem), false)
    @bot.event.register_command('say', self.method(:handle_say), false)
    @bot.event.register_command('time', self.method(:handle_time), true)
    @bot.event.register_command('topic', self.method(:handle_topic), true)
    @bot.event.register_command('ping', self.method(:handle_ping), true)

    register_help
  end

  def register_help
    hm = Help.new(@bot, 'add')
    hm.add_description('Adds a bot admin user')
    hm.add_argument('username', 'Username of the user to be an admin')
    @bot.event.help['add'] = hm

    hm = Help.new(@bot, 'admins')
    hm.add_description('Lists the admin users of this bot.')
    @bot.event.help['admins'] = hm

    hm = Help.new(@bot, 'channels')
    hm.add_description('Lists the channels this bot is joined to.')
    @bot.event.help['channels'] = hm

    hm = Help.new(@bot, 'commands')
    hm.add_description('Lists the commands recognized by this bot')
    @bot.event.help['commands'] = hm

    hm = Help.new(@bot, 'eval')
    hm.add_description('Evaluates a ruby command')
    hm.add_argument('command', 'The command to evaluate')
    @bot.event.help['eval'] = hm

    hm = Help.new(@bot, 'help')
    hm.add_description('Displays usage information for various bot commands.')
    hm.add_argument('command', 'The command to receive help for')
    hm.add_argument("'arg' or subcommand", 'The subcommand to receive help for, or the keyword arg', true)
    hm.add_argument('argument', 'When paired with arg keyword, the argument to receive specific detail about.', true)
    @bot.event.help['help'] = hm

    hm = Help.new(@bot, 'join')
    hm.add_description('Makes the bot join [channel]')
    hm.add_argument('channel', 'The channel for the bot to join')
    @bot.event.help['join'] = hm

    hm = Help.new(@bot, 'load')
    hm.add_description('Loads a ruby plugin')
    hm.add_argument('plugin', 'The plugin to load, ex. title.rb')
    @bot.event.help['load'] = hm

    hm = Help.new(@bot, 'nick')
    hm.add_description("Change the bot's IRC nickname.")
    hm.add_argument('nick', 'The nickname to use for the bot.')
    @bot.event.help['nick'] = hm
    
    hm = Help.new(@bot, 'say')
    hm.add_description('Makes the bot say [text]')
    hm.add_argument('text', 'The text the bot will echo.')
    @bot.event.help['say'] = hm

    #hm = Help.new(@bot, 'reload')
    #hm.add_description
  end

  def handle_auth(host, channel, message, args, guest)
    @bot.network.send_raw("WHOIS #{host[0, host.index('!')]}")
    @bot.network.send_notice(host[0, host.index('!')], "Sent an auth reqeust...")
  end

  def handle_add(host, channel, message, args, guest)
    unless @bot.admins.include?(args[1])
      @bot.admins << args[1]
      @bot.sets.settings_files[0].settings_hash['Admins'][args[1]] = 'nothing'
      @bot.sets.save_all
      @bot.network.send_privmsg(channel, 'Admin added.')
    end
  end

  def handle_admins(host, channel, message, args, guest)
    @bot.network.send_privmsg(channel, "My admins are #{@bot.admins.join(', ')}")
  end

  def handle_channels(host, channel, message, args, guest)
    @bot.network.send_privmsg(channel, @bot.network.channels.keys.join(', '))
  end

  def handle_commands(host, channel, message, args, guest)
    if host.include?('!')
      name = host[0, host.index('!')]
    else
      name = host
    end

    @bot.network.send_notice(name, 'Ruby IRC Bot version ' + VERSION.to_s + ' by Umby24 (Ruby: ' + RUBY_VERSION.to_s + ')')

    if guest
      cmd_listing = @bot.event.gcommand.keys.sort().join(', ')
      @bot.network.send_notice(name, 'You are a guest.')
    else
      cmd_listing = @bot.event.command.keys.sort().join(', ')
      @bot.network.send_notice(name, 'You are an admin.')
    end

    @bot.network.send_notice(name, cmd_listing)

  end

  def handle_eval(host, channel, message, args, guest)
    name = host[0, host.index('!')]

    unless name == "umby24"
      return
    end

    all_message = message[message.index(' ') + 1, message.length - (message.index(' ') + 1)]

    begin
      @bot.network.send_privmsg(channel, eval(all_message).to_s)
    rescue Exception => e
      @bot.network.send_privmsg(channel, "Error #{e.message}")
    end
  end

  def handle_help(host, channel, message, args, guest)
    if args[1].nil? or args[1] == ''
      @bot.network.send_notice(host[0, host.index('!')], "No arguments provided. For a commands listing see #{@bot.prefix}commands")
      return
    end

    hm = @bot.event.help.fetch(args[1], nil)

    if hm.nil?
      @bot.network.send_notice(host[0, host.index('!')], "No help for #{args[1]} found.")
      return
    end

    if args[2].nil? or args[2] == ''
      hm.send_base_help(host[0, host.index('!')])
      return
    end

    if args[2].downcase == 'arg'
      index = message.index(args[2]) + args[2].length + 1
      mmessage = message[index, message.length - index]
      hm.send_arg_help(host[0, host.index('!')], mmessage.strip)
    elsif args[3].nil? or args[3] == ''
      hm.send_sub_help(host[0, host.index('!')], args[2].strip)
    elsif args[3] == 'arg' and !(args[4].nil? or args[4] == '')
      index = message.index(args[3]) + args[3].length + 1
      mmessage = message[index, message.length - index]
      hm.send_sub_arg_help(host[0, host.index('!')], args[2], mmessage.strip)
    else
      @bot.network.send_notice(host[0, host.index('!')], 'There was an error with your help request.')
      @bot.network.send_notice(host[0, host.index('!')], "Usage is #{@bot.prefix}help [command] [subcommand or 'arg'](optional) [argument or 'arg'](optional) [argument](optional)")
    end
  end

  def handle_join(host, channel, message, args, guest)
    all_message = message[message.index(' ') + 1, message.length - (message.index(' ') + 1)].strip
    @bot.network.channels[all_message] = Channel.new(all_message)
    @bot.network.send_raw("JOIN #{all_message}")
    @bot.sets.save_all
  end

  def handle_load(host, channel, message, args, guest)
    unless File.exist?('Plugins/' + args[1])
      @bot.network.send_notice(host[0, host.index('!')], 'Plugin not found.')
      return
    end

    @bot.sets.settings_files[0].settings_hash["Plugins"][args[1]] = 'nothing'
    @bot.sets.save_all
    @bot.reload
    @bot.network.send_privmsg(channel, 'Plugin loaded.')
  end

  def handle_nick(host, channel, message, args, guest)
    @bot.network.send_raw('NICK ' + args[1])
    @bot.network.bot_name = args[1]
  end

  def handle_part(host, channel, message, args, guest)
    @bot.network.send_raw("PART #{channel}")
    @bot.network.channels.delete(channel)

    if @bot.channels.length == 0
      @bot.quit = true
    end
  end

  def handle_plugins(host, channel, message, args, guest)
    pm = get_plugin_manager
    @bot.network.send_privmsg(channel, pm.plugins.keys.join(', '))
  end

  def handle_quit(host, channel, message, args, guest)
    @bot.network.send_raw("QUIT :Quit command from #{host}")
    @bot.log.info("Quit command from #{host}")
    @bot.quit = true
  end

  def handle_reload(host, channel, message, args, guest)
    if (args[1] != nil and args[1] != '' and args[1] != ' ') and (File.exists?('Plugins/' + args[1] + '.rb'))
      @bot.network.send_privmsg(channel, "Reloading #{args[1]}...")
      pm = get_plugin_manager
      pm.load_plugin('Plugins/' + args[1] + '.rb')
      @bot.network.send_privmsg(channel, 'Done')
      return
    end

    @bot.network.send_privmsg(channel, 'Reloading...')
    @bot.reload
    @bot.network.send_privmsg(channel, 'Done.')
  end

  def handle_rem(host, channel, message, args, guest)
    if @bot.admins.include?(args[1])
      @bot.admins.delete(args[1])
      @bot.sets.settings_files[0].settings_hash['Admins'].delete(args[1])
      @bot.sets.save_all
      @bot.network.send_privmsg(channel, 'Admin removed.')
    end
  end

  def handle_say(host, channel, message, args, guest)
    all_message = message[message.index(' ') + 1, message.length - (message.index(' ') + 1)]
    @bot.network.send_privmsg(channel, all_message)
  end

  def handle_time(host, channel, message, args, guest)
    time = Time.new
    @bot.network.send_privmsg(channel, time.strftime('%I:%M:%S %p'))
  end

  def handle_topic(host, channel, message, args, guest)
    @bot.network.send_notice(host[0, host.index('!')], @bot.network.channels[channel].topic)
  end

  def handle_ping(host, channel, message, args, guest)
    @bot.network.send_privmsg(channel, 'Pong')
  end
end

dc = Default_Commands.new
