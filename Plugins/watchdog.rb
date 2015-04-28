class Watchdog < Plugin
  def plugin_init
    @name = 'Watchdog'
    @author = 'umby24'
    @version = 1.0

    @bot.event.register_command('uptime', self.method(:handle_uptime), true)
    register_help
  end

  def register_help
    hm = Help.new(@bot, 'uptime')
    hm.add_description('Returns the length of time the bot has been running.')
    @bot.event.help['uptime'] = hm
  end

  def handle_uptime(host, channel, message, args, guest)
    current = Time.now
    uptime = current - @bot.start_time
    Time.at(uptime).gmtime.strftime("%H:%M:%S")
    @bot.network.send_privmsg(channel, "Bot uptime: #{Time.at(uptime).gmtime.strftime("%H:%M:%S").to_s}")
  end

end

wd = Watchdog.new()
