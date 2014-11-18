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

  def handle_privmsg(host, mid, splits, message, raw)
    if host.include?('!')
      name = host[0, host.index('!')]
    else
      name = host
    end

    if message[0, 1] == 1.chr # CTCP
      if message[1, message.length - 2] == 'VERSION'
        #CTCP Version
        @bot.network.send_notice(name, 1.chr + 'VERSION Ruby IRC bot Version ' + @bot.version.to_s + ' by Umby24' + 1.chr)
        @bot.log.progname = 'VERSION'
        @bot.log.info('Handled CTCP Version')
        @bot.log.progname = 'CORE'
      end

      if message[0, 5] == 1.chr + 'PING'
        #Attempt at handling CTCP Pings.. never worked well.
        pingid = message[5, message.length - 6]
        @bot.network.send_notice(name, 1.chr + 'PING' + pingid + 1.chr)

        @bot.log.progname = 'PING'
        @bot.log.info('Handled CTCP PING')
        @bot.log.progname = 'CORE'
      end

      return
    end

    @bot.log.progname = splits[1]
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

      unless @bot.event.call_command(cmd, host, splits[1], message, message.split(' ', 25), guest)
        @bot.network.send_notice(name, 'Command not found.')
      end

    end
  end

  def handle_376(host, mid, splits, message, raw)
    @bot.channels.each do |z|
      @bot.network.send_raw("JOIN #{z}")
    end

    if !@bot.ns_pass.nil? and @bot.ns_pass != ''
      @bot.network.send_raw("NICKSERV IDENTIFY #{@bot.ns_pass}")
    end

    #TODO: Connected events --
  end

  def handle_307(host, mid, splits, message, raw)
    unless @bot.authed.include?(splits[2])
      @bot.authed << splits[2]
    end
  end

  def handle_330(host, mid, splits, message, raw)
    unless @bot.authed.include?(splits[2])
      @bot.authed << splits[2]
    end
  end

  def handle_353(host, mid, splits, message, raw)
    arr = message.split(' ', 120)
    @bot.users[splits[3]] = arr
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

  def handle_332(host, mid, splits, message, raw)
    @bot.topic[splits[2]] = message
    @bot.log.progname = splits[2]
    @bot.log.info("Topic updated to #{message} by #{host}")
    @bot.log.progname = 'CORE'
  end

  def handle_433(host, mid, splits, message, raw)
    @bot.bot_name += '_'
    @bot.network.send_raw("USER #{@bot.ident} ruby ruby :#{@bot.real_name}")
    @bot.network.send_raw("MODE #{@bot.bot_name} +B-x")
    @bot.log.warn('Username in use, appended a _.')
  end

  def handle_nick(host, mid, splits, message, raw)
    if host.include?('!')
      name = host[0, host.index('!')]
    else
      name = host
    end

    @bot.log.progname = 'NICK'
    @bot.log.info("#{name} has changed their nick to #{message}")
    @bot.log.progname = 'CORE'
    @bot.network.send_raw("WHOIS #{message}")
  end

  def handle_notice(host, mid, splits, message, raw)
    @bot.log.progname = 'NOTICE'
    @bot.log.info("-#{host}- #{message}")
    @bot.log.progname = 'CORE'
  end

  def handle_part(host, mid, splits, message, raw)
    @bot.log.progname = splits[1]
    @bot.log.info("#{host} left. (#{message})")
    @bot.log.progname = 'CORE'
    @bot.authed.delete(host[0, host.index('!')])
  end

  def handle_quit(host, mid, splits, message, raw)
    @bot.log.progname = splits[1]
    @bot.log.info("#{host} quit. (#{message})")
    @bot.log.progname = 'CORE'
    @bot.authed.delete(host[0, host.index('!')])
  end

  def handle_topic(host, mid, splits, message, raw)
    @bot.topic[splits[1]] = message
    @bot.log.progname = splits[1]
    @bot.log.info("Topic updated to #{message} by #{host}")
    @bot.log.progname = 'CORE'
  end

  def handle_join(host, mid, splits, message, raw)
    @bot.log.progname = splits[1]
    @bot.log.info("#{host[0, host.index('!')]} (#{host}) joined.")
    @bot.log.progname = 'CORE'
    @bot.network.send_raw("WHOIS #{host[0, host.index('!')]}")
  end
end

packets = Default_packets.new
