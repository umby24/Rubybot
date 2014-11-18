class Default_Commands < Plugin
  def plugin_init
    @name = 'Default Plugins'
    @author = 'umby24'
    @version = 1.0
    @bot.event.register_command('say', self.method(:handle_say), false)
    @bot.event.register_command('reload', self.method(:handle_reload), false)
    @bot.event.register_command('join', self.method(:handle_join), false)
    @bot.event.register_command('commands', self.method(:handle_commands), true)
    @bot.event.register_command('part', self.method(:handle_part), false)
    @bot.event.register_command('plugins', self.method(:handle_plugins), true)
    @bot.event.register_command('time', self.method(:handle_time), true)
    @bot.event.register_command('channels', self.method(:handle_channels), true)
  end

  def handle_say(host, channel, message, args, guest)
    all_message = message[message.index(' ') + 1, message.length - (message.index(' ') + 1)]
    @bot.network.send_privmsg(channel, all_message)
  end

  def handle_reload(host, channel, message, args, guest)
    @bot.network.send_privmsg(channel, 'Reloading Plugins...')
    pm = get_plugin_manager
    pm.load_plugins
    @bot.network.send_privmsg(channel, 'Done.')
  end

  def handle_join(host, channel, message, args, guest)
    all_message = message[message.index(' ') + 1, message.length - (message.index(' ') + 1)]
    @bot.channels << all_message.strip
    @bot.network.send_raw("JOIN #{all_message.strip}")
    @bot.sets.save_all
  end

  def handle_part(host, channel, message, args, guest)
    @bot.network.send_raw("PART #{channel}")
    @bot.channels.delete(channel)

    if @bot.channels.length == 0
      @bot.quit = true
    end
  end

  def handle_commands(host, channel, message, args, guest)
    if host.include?('!')
      name = host[0, host.index('!')]
    else
      name = host
    end

    @bot.network.send_notice(name, 'Ruby IRC Bot version ' + @bot.version.to_s + ' by Umby24')

    if guest
      cmd_listing = @bot.event.gcommand.keys.sort().join(', ')
      @bot.network.send_notice(name, 'You are a guest.')
    else
      cmd_listing = @bot.event.command.keys.sort().join(', ')
      @bot.network.send_notice(name, 'You are an admin.')
    end

    @bot.network.send_notice(name, cmd_listing)

  end

  def handle_plugins(host, channel, message, args, guest)
    pm = get_plugin_manager
    @bot.network.send_privmsg(channel, pm.plugins.keys.join(', '))
  end

  def handle_time(host, channel, message, args, guest)
    time = Time.new
    @bot.network.send_privmsg(channel, time.strftime('%I:%M:%S %p'))
  end

  def handle_channels(host, channel, message, args, guest)
    @bot.network.send_privmsg(channel, @bot.channels.join(', '))
  end


end

dc = Default_Commands.new
