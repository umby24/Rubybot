class Events
  attr_accessor :help
  attr_reader :command, :gcommand

  def initialize(bot)
    @help = Hash.new # Key: Command. Value: HelpModule
    @msg = Hash.new
    @read = Hash.new
    @command = Hash.new
    @gcommand = Hash.new
    @join = Hash.new
    @packet = Hash.new
    @bot = bot
  end

  # -- Registration methods
  def register_message(name, method)
    @msg[name] = method
    @bot.log.debug("Registered Message Event: #{name} [Method: #{method}]")
  end

  def register_read(name, method)
    @read[name] = method
    @bot.log.debug("Registered Read Event: #{name} [Method: #{method}]")
  end

  def register_command(cmd, method, guest)
    @command[cmd] = method

    if guest
      @gcommand[cmd] = method
    end

    @bot.log.debug("Registered Command: #{cmd} [Method: #{method.name}]")
  end

  def register_library(library)
    begin
      require library
    rescue Exception => e
      @bot.log.progname = 'RegLib'
      @bot.log.error(e.message)
      @bot.log.progname = 'CORE'
    end
  end

  def register_join(name, method)
    @join[name] = method
    @bot.log.debug("Registered Join Event: #{name} [Method: #{method}]")
  end

  def register_packet(id, method)
    @packet[id] = method
    @bot.log.debug("Registered Packet: #{id} [Method: #{method}]")
  end

  # -- Execution methods

  def call_message(name, channel, message)
    @msg.each do |z,f|
      if f.nil?
        next
      end

      begin
        f.call(name, channel, message)
      rescue Exception => e
        @bot.log.progname = 'MessageEvent'
        @bot.log.error("Error Handling Message Event #{z}, #{e.message}")
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end
    end
  end

  def call_read(string)
    @read.each do |z, _|
      if z.nil?
        next
      end

      begin
        z.call(string)
      rescue Exception => e
        @bot.log.progname = 'ReadEvent'
        @bot.log.error("Error Handling Read Event #{z}, #{e.message}")
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end
    end
  end

  def call_command(command, host, channel, message, args, guest)
    if guest
      method = @gcommand.fetch command, nil
    else
      method = @command.fetch(command, nil)
    end

    method.nil? ?
        false :
        begin
          method.call(host, channel, message, args, guest)
          true
        rescue Exception => e
          @bot.log.progname = 'Command'
          @bot.log.error("Error Handling command #{command}, #{e.message}")
          @bot.log.debug(e.backtrace)
          @bot.log.progname = 'CORE'
          @bot.network.send_privmsg(channel, 'There was an error handling this request.')
        end
  end

  def call_join(channel)
    @join.each do |z, _|
      if z.nil?
        next
      end

      begin
        z.call(channel)
      rescue Exception => e
        @bot.log.progname = 'JoinEvent'
        @bot.log.error("Error Handling Join Event #{z}, #{e.message}")
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end
    end
  end

  def call_packet(prefix, command, args, raw)
    method = @packet.fetch(command, nil)

    if method.nil?
      false
    else
      begin
        method.call(prefix, command, args, raw)
      rescue Exception => e
        @bot.log.progname = 'Packet'
        @bot.log.error("Error Handling packet #{command}, #{e.message}")
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end

      true
    end
  end

  # -- Class Methods
  def to_s
    number = @msg.length + @read.length + @command.length + @join.length + @packet.length
    "Rubybot Event Class, Tracking #{number} Events."
  end
end