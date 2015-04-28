class Title < Plugin
  def plugin_init
    @name = 'Title Plugin'
    @author = 'umby24'
    @version = 1.0
    @bot.event.register_library('openssl')
    @bot.event.register_library('cgi')
    @bot.event.register_library('open-uri')
    @bot.event.register_message('Title', self.method(:handle_message))
  end

  def handle_message(name, channel, message)
    if message.include?('http://') || message.include?('https://')
      message += ' '

      url = message.index('http://')

      url = message.index('https://') if url.nil?

      substring = message[url, message.length - url]
      index2 = substring.index(' ')
      my_url = substring[0, index2]
      my_url = my_url.strip

      if File.exists?('settings/bl.txt')
        blchans = IO.readlines('settings/bl.txt')
      end

      if blchans != nil
        if blchans.include?(channel) || blchans.include?(channel + "\n")
          return
        end
      end
      @bot.network.send_privmsg(channel, get_title(my_url))
    end
  end

  def get_title(url)
    url = url.gsub("^[a-zA-Z0-9\-\.]+\.(com|org|net|mil|edu|info|io|IO|gl|GL|co|CO|INFO|COM|ORG|NET|MIL|EDU)$","")
    url = url.gsub("^(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\?\'\\\+&amp;%\$#\=~_\-]+))*$","")

    begin
      asdf = open(url, {'User-Agent' => 'Rubybot/5.0 (+http://umby.d3s.co/)', :read_timeout => 10, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE})
      content = asdf.sysread(90000)
      content2 = content.downcase

      if !content2.include?("<title>")
        return ''
      else
        place1 = content2.index('<title>')
        place2 = content2.index('</title>')
        length = place2 - place1
        length -= 7
        place1 += 7
        title = content[place1,length]
        title = CGI.unescape_html(title).strip().gsub("\r",'').gsub("\n",'')
        title = title.gsub(/\s+/, ' ')
	return "[Title: #{title}]"
      end
    rescue Exception => e
      puts "Error: #{e.message} #{url}"
      return ''
    end
  end
end

mt = Title.new
