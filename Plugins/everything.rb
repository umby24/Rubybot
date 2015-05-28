class Everything < Plugin
  Url = 'https://www.googleapis.com/youtube/v3/videos'
  ApiKey = 'GOOGLE API KEY'

  def plugin_init
    @author = "umby24"
    @title = "C0nt3xt"
    @version = 1.0

    @bot.event.register_library('openssl')
    @bot.event.register_library('cgi')
    @bot.event.register_library('open-uri')
    @bot.event.register_library('json')
    @bot.event.register_message('C0nt3xt', self.method(:handle_message))
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
end

con = Everything.new