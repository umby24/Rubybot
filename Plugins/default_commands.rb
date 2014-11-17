class Default_Commands < Plugin
  def plugin_init
    @name = 'Default Plugins'
    @author = 'umby24'
    @version = 1.0
    @bot.event.register_command('say', self.method(:handle_say))
    @bot.event.register_command('reload', self.method(:handle_reload))
    @bot.event.register_command('join', self.method(:handle_join))
    @bot.event.register_command('commands', self.method(:handle_commands))
  end

  def handle_say(name, host, mid, splits, message, raw)
    all_message = message[message.index(' ') + 1, message.length - (message.index(' ') + 1)]
    @bot.network.send_privmsg(splits[1], all_message)
  end

  def handle_reload(name, host, mid, splits, message, raw)
    @bot.network.send_privmsg(splits[1], 'Reloading Plugins...')
    pm = get_plugin_manager
    pm.load_plugins
    @bot.network.send_privmsg(splits[1], 'Done.')
  end

  def handle_join(name, host, mid, splits, message, raw)
    all_message = message[message.index(' ') + 1, message.length - (message.index(' ') + 1)]
    @bot.channels << all_message.strip
    @bot.network.send_raw("JOIN #{all_message.strip}")
    @bot.sets.save_all
  end

  def handle_commands(name, host, mid, splits, message, raw)
    cmdlisting = @bot.event.commands.keys.sort().join(', ')
    @bot.network.send_notice(name, 'Ruby IRC Bot version ' + @bot.version + ' by Umby24')
    @bot.network.send_notice(name, 'Total Commands: ' + cmdlisting.length)
    @bot.network.send_notice(name, cmdlisting)
  end
end

dc = Default_Commands.new
