class Everything < Plugin
  Url = 'https://www.googleapis.com/youtube/v3/videos'
  ApiKey = 'GOOGLE API KEY'

  def plugin_init
    @author = "umby24"
    @name = "C0nt3xt"
    @version = 1.0

    @bot.event.register_library('openssl')
    @bot.event.register_library('cgi')
    @bot.event.register_library('open-uri')
    @bot.event.register_library('json')
    @bot.event.register_message('C0nt3xt', self.method(:handle_message))
    @bot.event.register_command('google', self.method(:handle_google), true)
  end

  def is_numeric(variable)
    variable.class.to_s == "Fixnum"
  end

  def handle_message(name, channel, message)
    blchans = ''

    if File.exists?('settings/bl.txt') # Check to see if this channel has blacklisted broadcasts
      blchans = IO.readlines('settings/bl.txt')
    end

    if blchans != nil && (blchans.include?(channel) || blchans.include?(channel + "\n"))
        return
    end

    if message.downcase.include?('youtube.com/watch?v=')
      indx = message.index('/watch?v=')
      indx += 9
      video_id = message[indx, message.length - indx]
      video_id = video_id.gsub(' ', '')
      if video_id.include?('&')
        video_id = video_id[0, video_id.index('&')]
      end

      info = youtube_info(video_id)

      str = "[Youtube: #{2.chr}#{info["items"][0]["snippet"]["title"]}#{2.chr} - #{info["items"][0]["snippet"]["channelTitle"]}]"
      @bot.network.send_privmsg(channel, str)
    end
  end

  private

  def youtube_info(video_id)
    begin
      asdf = open(Url + "?id=#{video_id}&key=#{ApiKey}&part=snippet", {'User-Agent' => 'Rubybot/5.0 (+http://umby.d3s.co/)', :read_timeout => 10, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE})
      content = asdf.sysread(90000)
      jsonObj = JSON.parse(content)
    rescue Exception => e
      @bot.log.error("Failed to get Youtube info: #{e.message}")
    end

    return jsonObj
  end

  def google_lookup(term, num_results)
    begin
      something = open('http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=' + term.gsub(" ","+"))
      content = something.read
      something.close()

      parsed = JSON.parse(content)
    rescue Exception => e
      @bot.log.warn("Exception during google lookup and parse: #{e.message}")
      @bot.log.debug("Stacktrace: #{e.backtrace}")
      return
    end

    #I want split #1 (url),#6 (title no formatting).
    begin
      title = parsed['responseData']['results'][num_results - 1]['titleNoFormatting']
      url = parsed['responseData']['results'][num_results - 1]['url']
      return "Title: #{CGI.unescape_html(title)} ( #{CGI.unescape(url)} ) "
    rescue Exception => e
      #err_log("error! (Google plugin)")
      @bot.log.warn("Google plugin exception #{e.message} - #{e.backtrace}")
    end
  end

  def handle_google(host, channel, message, args, guest)
    result = 1
    mmessage = ''

    if is_numeric(args[1])
      result = args[1].to_i
      isearch = "#{args[0]} #{args[1]} "
      mmessage = message[message.index(isearch), message.length - (message.index(isearch))]
    else
      mmessage = message[message.index(" ") + 1, message.length - (message.index(" ") + 1)]
    end

    @bot.network.send_privmsg(channel, google_lookup(mmessage,result))
  end
end

con = Everything.new