require 'socket'
#require_relative 'default_packets'

class IRC_Network
  attr_accessor :reloaded, :current

  # @param [Bot] bot
  def initialize(bot)
    @bot = bot
    @current = @bot.channels[0]
    @reloaded = false
    @timer = 0
  end

  def connect
    @socket = TCPSocket.open(@bot.ip, @bot.port)
    send_raw("NICK #{@bot.bot_name}")
    send_raw("USER #{@bot.ident} ruby ruby :#{@bot.real_name}")
    send_raw("MODE #{@bot.bot_name} +B-x")
  end

  def read_line
    @socket.gets
  end

  def send_raw(data)
    @socket.send(data + "\r\n", 0)
  end

  def send_privmsg(dest, msg)
    messages = split_message(msg)
    @bot.log.progname = dest
    puts messages
    puts msg
    messages.each do |z|
      puts z
      next unless z != nil
      send_raw("PRIVMSG #{dest} :#{z}")
      @bot.log.info("<#{@bot.bot_name}> #{z}")
    end

    @bot.log.progname = 'CORE'
  end

  def send_notice(dest, msg)
    messages = split_message(msg)
    @bot.log.progname = "NOTICE - #{dest}"

    messages.each do |z|
      next unless z != nil
      send_raw("NOTICE #{dest} :#{z}")
      @bot.log.info("-#{@bot.bot_name}- #{z}")
    end

    @bot.log.progname = 'CORE'
  end

  def send_all(msg)
    @bot.channels.each do |z|
      send_privmsg(z, msg)
    end
  end

  def send_msg(msg)
    send_privmsg(@current, msg)
  end

  def parse
    if reloaded
      send_msg('Reloaded')
      reloaded = false
    end

    while !reloaded
      raw = read_line
      @bot.event.call_read

      host = ''
      mid = ''
      message = ''

      if raw[0, 1] == ':'
        host = raw[1, raw.index(' ') - 1]
      else
        host = raw[0, raw.index(' ')]
      end

      mid = raw[raw.index(' ') + 1, raw.length - (raw.index(' ') - 1)]

      if mid.include?(':')
        message = mid[mid.index(':') + 1, mid.length - (mid.index(':') + 1)]
      end

      if host == 'PING' # Respond to IRC Server pings for aliveness.
        @timer = 0
        send_raw("PONG #{mid}")
        next
      end

      packet = mid[0, mid.index(' ')]
      splits = mid.split(' ', 15)
      message = message.strip

      if @bot.event.call_packet(packet, host, mid, splits, message, raw)
        next
      end

      @bot.log.progname = packet
      @bot.log.info(message)
      @bot.log.progname = 'CORE'
    end
  end

  def to_s
    'IRC Handler Class'
  end

  private

  def split_message(string)
    loopback = false
    splits = []
    counter = 0

    begin
      if string.length > 400
        loopback = true
      else
        loopback = false
      end
      if loopback
        index = string[0, 400].rindex(" ")
        temptext = string[index + 1, string.length - (index + 1)]
        string = string[0, index]
      end
      splits[counter] = string
      if loopback
        string = temptext
      end
      counter += 1
    end while (loopback == true)
    return splits
  end
end