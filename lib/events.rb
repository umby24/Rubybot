class Events
  attr_reader :command

  def initialize(bot)
    @msg = Hash.new
    @read = Hash.new
    @command = Hash.new
    @join = Hash.new
    @packet = Hash.new
    @bot = bot
  end

  # -- Registration methods
  def register_message(name, method)
    @msg[name] = method
    @bot.log.debug("Registered Message Event: #{name} [Method: #{method}")
  end

  def register_read(name, method)
    @read[name] = method
    @bot.log.debug("Registered Read Event: #{name} [Method: #{method}")
  end

  def register_command(cmd, method)
    @command[cmd] = method
    @bot.log.debug("Registered Command: #{cmd} [Method: #{method}")
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
    @bot.log.debug("Registered Join Event: #{name} [Method: #{method}")
  end

  def register_packet(id, method)
    @packet[id] = method
    @bot.log.debug("Registered Packet: #{id} [Method: #{method}")
  end

  # -- Execution methods

  def call_message

  end

  def call_read

  end

  def call_command(name, command, host, mid, splits, message, raw)
    method = @command.fetch(command, nil)
    #TODO: Permissions
    if method.nil?
      false
    else
      begin
        method.call(name, host, mid, splits, message, raw)
      rescue Exception => e
        @bot.log.progname = 'Command'
        @bot.log.error("Error Handling command #{command}, #{e.message}")
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end
    end
  end

  def call_join

  end

  def call_packet(packet, host, mid, splits, message, raw)
    method = @packet.fetch(packet, nil)

    if method.nil?
      false
    else
      begin
        method.call(host, mid, splits, message, raw)
      rescue Exception => e
        @bot.log.progname = 'Packet'
        @bot.log.error("Error Handling packet #{packet}, #{e.message}")
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