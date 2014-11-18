class Default_Commands < Plugin
  def plugin_init
    @name = 'Default Plugins'
    @author = 'umby24'
    @version = 1.0
    @bot.event.register_command('say', self.method(:handle_say), false)
    @bot.event.register_command('reload', self.method(:handle_reload), false)
    @bot.event.register_command('join', self.method(:handle_join), false)
    @bot.event.register_command('commands', self.method(:handle_commands), true)
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
end

dc = Default_Commands.new
