class Default_packets < Plugin
  def plugin_init
    @name = 'IRC Packets'
    @author = 'umby24'
    @version = 1.0
    @bot.event.register_packet('PRIVMSG', self.method(:handle_privmsg))
    @bot.event.register_packet('376', self.method(:handle_376))
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

      cmd = message[1, message.index(' ') - 1].downcase.gsub(' ', '')

      unless @bot.event.call_command(name, cmd, host, mid, splits, message, raw)
        @bot.network.send_notice(name, 'Command not found.')
      end
      #TODO: Additional permission testing here.

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
end

packets = Default_packets.new
puts 'Loading default packets'
