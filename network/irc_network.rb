require 'socket'

class IRC_Network
  attr_accessor :socket, :ip, :port, :bot_name, :channels, :ident, :real_name, :ns_pass

  # @param [Bot] bot
  def initialize(bot)
    @bot = bot
    @bot_name = ''
    @ident = 'ruby'
    @real_name = 'rubybot'
    @channels = Hash.new
    @ip = '127.0.0.1'
    @port = 2
    @timer = 0
  end

  def connect
    @socket = TCPSocket.open(@ip, @port) # Create the socket

    send_raw("NICK #{@bot_name}") # Register with the server
    send_raw("USER #{@ident} ruby ruby :#{@real_name}")
    send_raw("MODE #{@bot_name} +B-x")
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

    messages.each do |z|
      next unless z != nil
      send_raw("PRIVMSG #{dest} :#{z}")
      @bot.log.info("<#{@bot_name}> #{z}")
    end

    @bot.log.progname = 'CORE'
  end

  def send_notice(dest, msg)
    messages = split_message(msg)
    @bot.log.progname = "NOTICE - #{dest}"

    messages.each do |z|
      next unless z != nil
      send_raw("NOTICE #{dest} :#{z}")
      @bot.log.info("-#{@bot_name}- #{z}")
    end

    @bot.log.progname = 'CORE'
  end

  def send_all(msg)
    @channels.each do |z|
      send_privmsg(z, msg)
    end
  end

  def parse
    until @bot.quit
      raw = read_line
      @bot.event.call_read(raw)
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

  def timeout
    until @bot.quit
      sleep(1)
      @timer += 1

      begin
        if @timer > 500
          @bot.quit = 1

          unless @socket.closed?
            @socket.close
          end

          system('ruby main.rb')
          puts 'Recovered.'
        end
      rescue Exception => e
        @bot.log.error("Timeout error #{e.message}")
        @bot.log.debug(e.backtrace)
      end
    end
  end

  def to_s
    'IRC Handler Class'
  end

  private

  def split_message(string)
    if string.length < 400
      return [string]
    end

    splits = []
    counter = 0

    until string.length < 400
      index = string[0, 400].rindex(' ')
      temp_text = string[index + 1, string.length - (index + 1)]
      string = string[0, index]
      splits[counter] = string
      string = temp_text
      counter += 1
    end

    splits
  end
end