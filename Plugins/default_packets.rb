# noinspection RubyResolve
class Default_packets < Plugin
  def plugin_init
    @name = 'IRC Packets'
    @author = 'umby24'
    @version = 1.0
    @bot.event.register_packet('PRIVMSG', self.method(:handle_privmsg))
    @bot.event.register_packet('376', self.method(:handle_376))
    @bot.event.register_packet('307', self.method(:handle_307))
    @bot.event.register_packet('330', self.method(:handle_330))
    @bot.event.register_packet('353', self.method(:handle_353))
    @bot.event.register_packet('332', self.method(:handle_332))
    @bot.event.register_packet('433', self.method(:handle_433))
    @bot.event.register_packet('NICK', self.method(:handle_nick))
    @bot.event.register_packet('NOTICE', self.method(:handle_notice))
    @bot.event.register_packet('PART', self.method(:handle_part))
    @bot.event.register_packet('QUIT', self.method(:handle_quit))
    @bot.event.register_packet('TOPIC', self.method(:handle_topic))
    @bot.event.register_packet('JOIN', self.method(:handle_join))
  end

  def handle_privmsg(prefix, command, args, raw)
    if prefix.include?('!')
      name = prefix[0, prefix.index('!')]
    else
      name = prefix
    end

    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]
    @bot.event.call_message(name, args[0], message)

    if message[0, 1] == 1.chr # CTCP
      if message[1, message.length - 2] == 'VERSION'
        #CTCP Version
        @bot.network.send_notice(name, 1.chr + 'VERSION Ruby IRC bot Version ' + VERSION.to_s + ' by Umby24' + 1.chr)
        @bot.log.progname = 'VERSION'
        @bot.log.info('Handled CTCP Version')
        @bot.log.progname = 'CORE'
      end

      if message[0, 5] == 1.chr + 'PING'
        #Attempt at handling CTCP Pings.. never worked well.
        pinged = message[5, message.length - 6]
        @bot.network.send_notice(name, 1.chr + 'PING' + pinged + 1.chr)

        @bot.log.progname = 'PING'
        @bot.log.info('Handled CTCP PING')
        @bot.log.progname = 'CORE'
      end

      return
    end

    @bot.log.progname = args[0]
    @bot.log.info("<#{name}> #{message}")
    @bot.log.progname = 'CORE'

    if message[0, 1] == @bot.prefix
      unless message.include?(' ')
        message += ' '
      end

      guest = false

      unless @bot.admins.include?(name) and @bot.authed.include?(name)
        guest = true
      end

      cmd = message[1, message.index(' ') - 1].downcase.gsub(' ', '')

      unless @bot.event.call_command(cmd, prefix, args[0], message, message.split(' ', 25), guest)
        @bot.network.send_notice(name, 'Command not found.')
      end

    end
  end

  def handle_376(prefix, command, args, raw)
    @bot.network.channels.each_key do |z|
      @bot.network.send_raw("JOIN #{z}")
    end

    if !@bot.network.ns_pass.nil? and @bot.network.ns_pass != ''
      @bot.network.send_raw("NICKSERV IDENTIFY #{@bot.network.ns_pass}")
    end
  end

  def handle_307(prefix, command, args, raw)
    unless @bot.authed.include?(args[1])
      @bot.authed << args[1]
    end
  end

  def handle_330(prefix, command, args, raw)
    unless @bot.authed.include?(args[1])
      @bot.authed << args[1]
    end
  end

  def handle_353(prefix, command, args, raw)
    if @bot.network.channels.fetch(args[2], nil) == nil
      @bot.network.channels[args[2]] = Channel.new(args[2])
    end

    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]

    @bot.network.channels[args[2]].set_users(message)
    @bot.event.call_join(args[2])

    arr = message.split(' ', 120)

    arr.each do |z|
      if z.include?('~') || z.include?('@') || z.include?('+')
        z = z.gsub('~', '')
        z = z.gsub('@', '')
        z = z.gsub('+', '')
        z = z.gsub(' ', '')

        unless @bot.authed.include?(z)
          @bot.authed << z
        end

        next
      end

      z = z.gsub(' ', '')
      @bot.network.send_raw("whois #{z}")
    end
  end

  def handle_332(prefix, command, args, raw)
    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]
    @bot.network.channels[args[1]].topic = message
    @bot.log.progname = args[1]
    @bot.log.info("Topic updated to #{message} by #{prefix}")
    @bot.log.progname = 'CORE'
  end

  def handle_433(prefix, command, args, raw)
    @bot.network.bot_name += '_'
    @bot.network.send_raw("MODE #{@bot.network.bot_name} +B-x")
    @bot.network.send_raw("USER #{@bot.network.ident} ruby ruby :#{@bot.network.real_name}")

    @bot.log.warn('Username in use, appended a _.')
  end

  def handle_nick(prefix, command, args, raw)
    if prefix.include?('!')
      name = prefix[0, prefix.index('!')]
    else
      name = prefix
    end

    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]

    @bot.log.progname = 'NICK'
    @bot.log.info("#{name} has changed their nick to #{message}")
    @bot.log.progname = 'CORE'

    @bot.network.send_raw("WHOIS #{message}")
  end

  def handle_notice(prefix, command, args, raw)
    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]

    @bot.log.progname = 'NOTICE'
    @bot.log.info("-#{prefix}- #{message}")
    @bot.log.progname = 'CORE'
  end

  def handle_part(prefix, command, args, raw)
    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]

    @bot.log.progname = args[0]
    @bot.log.info("#{prefix} left. (#{message})")
    @bot.log.progname = 'CORE'
    @bot.authed.delete(prefix[0, prefix.index('!')])
  end

  def handle_quit(prefix, command, args, raw)
    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]

    @bot.log.progname = args[0]
    @bot.log.info("#{prefix} quit. (#{message})")
    @bot.log.progname = 'CORE'
    @bot.authed.delete(prefix[0, prefix.index('!')])
  end

  def handle_topic(prefix, command, args, raw)
    message = args[1, args.length - 1].join(' ')
    message = message[1, message.length - 1]

    @bot.network.channels[args[0]].topic = message
    @bot.log.progname = args[0]
    @bot.log.info("Topic updated to #{message} by #{prefix}")
    @bot.log.progname = 'CORE'
  end

  def handle_join(prefix, command, args, raw)
    @bot.log.progname = args[0]
    @bot.log.info("#{prefix[0, prefix.index('!')]} (#{prefix}) joined.")
    @bot.log.progname = 'CORE'
    @bot.network.send_raw("WHOIS #{prefix[0, prefix.index('!')]}")
  end
end

packets = Default_packets.new
