class UtcPlugin < Plugin
  def plugin_init
    @name = 'UTC Plugin'
    @author = 'umby24'
    @version = 1.0

    @bot.event.register_command('utc', self.method(:handle_utc), true)
    register_help
  end

  def register_help
    hm = Help.new(@bot, 'utc')
    hm.add_description('Returns the current time at the given utc offset.')
    hm.add_argument('offset', 'The UTC offset to retreive.')
    @bot.event.help['utc'] = hm
  end

  def handle_utc(host, channel, message, args, guest)
    if args[1].length == 3
      args[1] = args[1] + ":00"
    elsif args[1].length == 2
      args[1] = args[1][0, 1] + "0" + args[1][1, 1] + ":00"
    elsif args[1].length != 6
      @bot.network.send_privmsg(channel, host[0, host.index('!')] + ": Incorrect format for Time zone.")
      @bot.network.send_privmsg(channel, "Format is: [+/-][offset], ex. -02:00")
      return
    end

    @bot.network.send_privmsg(channel, host[0, host.index('!')] + ": " + Time.now.localtime(args[1]).strftime("%I:%M:%S %p, %d %B %Y"))
  end
end

mutc = UtcPlugin.new