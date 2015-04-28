class Interaction < Plugin
  def plugin_init
    @name = 'Interaction'
    @author = 'umby24'
    @version = 1.0

    $pre_words = Hash.new()
    $post_words = Hash.new()

    @bot.event.register_message('Interaction', self.method(:interaction_do))
    #register_help
    load_keywords
  end

  def register_help

  end

  def load_keywords
    begin
      type = "pre"
      suppress = 0
      file = IO.readlines("Settings/keywords.txt")

      file.each { |line|
        line = line.gsub("\n", "")
        line = line.gsub("\r", "")

        if line.include?("[") and line.include?("]")
          type = line[1, line.length - 2]
          suppress = 0
          next
        end

        if type != "pre" and type != "post" and suppress == 0
          suppress = 1
        end

        key = line[0, line.index("=")].downcase.strip
        value = line[line.index("=") + 1, line.length - (line.index("=") + 1)].strip

        if type == "pre"
          $pre_words[key] = value
        elsif type == "post"
          $post_words[key] = value
        end
      }
    rescue Exception => e
      @bot.log.progname = 'Interaction'
      @bot.log.error(e.message)
      @bot.log.debug(e.backtrace)
      @bot.log.progname = 'CORE'
    end

    @bot.log.progname = 'Interaction'
    @bot.log.info('Keywords loaded.')
    @bot.log.progname = 'CORE'
  end

  def interaction_do(name, channel, message)
    #Post Words: Rubybot: [Command]
    #Pre words: [command] rubybot  (I.E. hi there rubybot)
    splits = message.split(' ', 300)

    if (splits[splits.length - 1].downcase == @bot.network.bot_name.downcase) and $pre_words.fetch(splits[0].downcase, nil) != nil # Pre words
      begin
        send($pre_words.fetch(splits[0].downcase).to_sym, @bot, name, channel, message)
      rescue Exception => e
        @bot.log.progname = 'Interaction'
        @bot.log.error(e.message)
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end

    end

    if (splits[0].downcase == @bot.network.bot_name.downcase or splits[0].downcase == (@bot.network.bot_name + ':').downcase) and $pre_words.fetch(splits[1].downcase, nil) != nil
      begin
        send($pre_words.fetch(splits[1].downcase).to_sym, @bot, name, channel, message)
      rescue Exception => e
        @bot.log.progname = 'Interaction'
        @bot.log.error(e.message)
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end
    end

    if (splits[0].downcase == @bot.network.bot_name.downcase or splits[0].downcase == (@bot.network.bot_name + ':').downcase) and $post_words.fetch(splits[1].downcase, nil) != nil
      begin
        send($post_words.fetch(splits[1].downcase).to_sym, @bot, name, channel, message)
      rescue Exception => e
        @bot.log.progname = 'Interaction'
        @bot.log.error(e.message)
        @bot.log.debug(e.backtrace)
        @bot.log.progname = 'CORE'
      end
    end
=begin
    if $pre_words.fetch($splits[2], nil) != nil and $splits[3].downcase == $botname.downcase
      if $splits[1] == $botname
        $current = $host[0,$host.index("!")]
      else
        $current = $splits[1]
      end
      begin
        send($preWords.fetch($splits[2]).to_sym)
      rescue Exception => e
        watchdog_Log("Interaction(Interaction run): #{e.message}", e.backtrace)
        #err_log("Interaction(Interaction run): #{e.message}")
      end
    elsif ($splits[2].downcase == ':' + $botname.downcase or $splits[2].downcase == ':' + $botname.downcase + ':') and $postWords.fetch($splits[3], nil) != nil
      if $splits[1] == $botname
        $current = $host[0,$host.index('!')]
      else
        $current = $splits[1]
      end
      begin
        send($postWords.fetch($splits[3]).to_sym)
      rescue Exception => e
        watchdog_Log("Interaction(Interaction run): #{e.message}", e.backtrace)
      end
    end
=end
  end

  def inter_hello(bot, name, channel, message)
    bot.network.send_privmsg(channel, "Hello #{name}.")
  end

  def inter_bye(bot, name, channel, message)
    @bot.network.send_privmsg(channel, "Bye #{name}, I'll miss you :'(")
  end

  def inter_fuck(bot, name, channel, message)
    @bot.network.send_privmsg(channel, "See you in bed then, #{name}")
  end

  def inter_hey(bot, name, channel, message)
    @bot.network.send_privmsg(channel, '.. is for horses')
  end
  
  def inter_love(bot, name, channel, message)
    @bot.network.send_privmsg(channel, "#{name} <3")
  end

  def inter_question(bot, name, channel, message)
    @bot.network.send_privmsg(channel, 'Can I help you?')
  end

  def inter_commands(bot, name, channel, message)
    #(command, host, channel, message, args, guest)
    @bot.event.call_command('commands', name + '@fake.host.net', channel, message, message.split(' '), true)
  end
end

inter = Interaction.new
