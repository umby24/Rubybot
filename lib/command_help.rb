class Help
  attr_accessor :command, :custom_help, :custom_function, :arguments, :subcommands, :base_description

  def initialize(bot, command)
    @bot = bot
    @command = command
    @custom_help = false
    @custom_function = ''
    @arguments = {}
    @arguments['args'] = []
    @arguments['desc'] = []
    @arguments['opt'] = []
    @subcommands = {}
    @base_description = []
  end

  def add_custom_help(function) # Sets the function to forward all help requests to.
    @custom_help = true
    @custom_function = function
  end

  def add_argument(argument, description, optional = false)
    @arguments['args'].push(argument)
    @arguments['desc'].push(description)
    @arguments['opt'].push(optional)
  end

  def add_sub_command(subcommand)
    @subcommands[subcommand] = Hash.new
    @subcommands[subcommand]['arguments'] = {}
    @subcommands[subcommand]['arguments']['args'] = []
    @subcommands[subcommand]['arguments']['desc'] = []
    @subcommands[subcommand]['arguments']['opt'] = []
    @subcommands[subcommand]['baseDescription'] = []
    @subcommands[subcommand]['command'] = subcommand
  end

  def add_description(description)
    @base_description.push(description)
  end

  def add_sub_cmd_description(command, description)
    if @subcommands[command] == nil
      @bot.log.warning("Error: Attempted to add to a sub-command that does not exist. HelpModule: #{@command}")
      return # sub-command does not exist.
    end

    @subcommands[command]['baseDescription'].push(description)
  end

  def add_sub_command_argument(command, argument, description, optional = false)
    if @subcommands[command] == nil
      @bot.log.warning("Attempted to add to a sub-command that does not exist. HelpModule: #{@command}")
      return # sub-command does not exist.
    end

    @subcommands[command]['arguments']['args'].push(argument)
    @subcommands[command]['arguments']['desc'].push(description)
    @subcommands[command]['arguments']['opt'].push(optional)
  end

  # Get functions
  def send_base_help(sender)
    unless @custom_help
      arg_string = ''

      if @arguments['args'].length > 0
        @arguments['args'].each do |arg|
          arg_string += "[#{arg}]"

          arg_string += '(optional)' if @arguments['opt'][@arguments['args'].index(arg)]

          arg_string += ' '
        end
      end

      @bot.network.send_notice(sender, "#{@bot.prefix}#{@command} #{arg_string}")

      @base_description.each do |d|
        @bot.network.send_notice(sender, d)
      end

      @bot.network.send_notice(sender, "This command has #{@subcommands.length.to_s} sub-commands: #{@subcommands.keys.join(', ')}") if @subcommands.length > 0
      return
    end

    begin
      send(@custom_function)
    rescue Exception => e
      @bot.log.error("Custom Help Error (#{@custom_function}): #{e.message}")
      @bot.log.debug(e.backtrace)
    end
  end

  def send_sub_help(sender, subcommand)
    if @custom_help
      begin
        send(@custom_function)
      rescue Exception => e
        @bot.log.error("Custom Help Error (#{@custom_function}): #{e.message}")
        @bot.log.debug(e.backtrace)
      end

      return
    end

    if @subcommands[subcommand] == nil
      @bot.network.send_notice(sender, "Sub-command #{subcommand} does not exist.")
      return
    end

    arg_string = ''

    if @subcommands[subcommand]['arguments']['args'].length > 0
      @subcommands[subcommand]['arguments']['args'].each do |arg|
        arg_string += "[#{arg}]"

        if @subcommands[subcommand]['arguments']['opt'][@subcommands[subcommand]['arguments']['args'].index(arg)]
          arg_string += '(optional)'
        end

        arg_string += ' '
      end
    end

    @bot.network.send_notice(sender, "#{@bot.prefix}#{@command} #{subcommand} #{arg_string}")

    @subcommands[subcommand]['baseDescription'].each do |f|
      @bot.network.send_notice(sender, f)
    end
  end

  def send_arg_help(sender, arg)
    if @custom_help
      begin
        send(@custom_function)
      rescue Exception => e
        @bot.log.error("Custom Help Error (#{@custom_function}): #{e.message}")
        @bot.log.debug(e.backtrace)
      end

      return
    end
    
    if @arguments['args'].include?(arg) == false and @subcommands[arg] == nil
      @bot.network.send_notice(sender, 'Argument not found.') 
      return
    end

    if @subcommands[arg] != nil # This is actually a sub-command, not an argument :P
      send_sub_help(sender, arg)
      return
    end

    # Send arg help.
    @bot.network.send_notice(sender, "#{@bot.prefix}#{@command}: Argument #{2.chr}#{arg}")
    @bot.network.send_notice(sender, @arguments['desc'][@arguments['args'].index(arg)])

    #Done :)
  end

  def send_sub_arg_help(sender, subcommand, arg)
    if @custom_help
      begin
        send(@custom_function)
      rescue Exception => e
        @bot.log.error("Custom Help Error (#{@custom_function}): #{e.message}")
        @bot.log.debug(e.backtrace)
      end

      return
    end

    unless @subcommands[subcommand]['arguments']['args'].include?(arg)
      @bot.network.send_notice(sender, "#{arg} is not an argument of #{subcommand}.")
      return
    end

    @bot.network.send_notice(sender, "#{@bot.prefix}#{@command} #{subcommand}: Argument #{2.chr}#{arg}")
    @bot.network.send_notice(sender, @subcommands[subcommand]['arguments']['desc'][@subcommands[subcommand]['arguments']['args'].index(arg)])
  end
end
