class Wikipedia < Plugin
  def plugin_init
    @name = 'Wikipedia'
    @author = 'umby24'
    @version = 1.0
    @bot.event.register_library('json')
    @bot.event.register_library('open-uri')
    @bot.event.register_command('wiki', self.method(:handle_wiki), true)
    register_help
  end

  def register_help
    hm = Help.new(@bot, 'wiki')
    hm.add_description('Preforms a lookup on wikipedia and returns the resulting first paragraph.')
    hm.add_argument('term', 'The terms to lookup in wikipedia.')
    @bot.event.help['wiki'] = hm
  end

  def handle_wiki(host, channel, message, args, guest)
    mmessage = message[message.index(" ") + 1, message.length - (message.index(" ") + 1)]
    @bot.network.send_privmsg(channel, do_lookup(mmessage))
  end

  def do_lookup(query)
    url = "http://en.wikipedia.org/w/api.php?action=parse&page=#{CGI.escape(query)}&format=json&prop=text&section=0"

    wSock = open(url)
    content = wSock.sysread(90000)
    wSock.close()

    jsonobj = JSON.parse(content)

    if jsonobj["error"] != nil
      return jsonobj["error"]["info"]
    end

    querydata = jsonobj["parse"]["text"]["*"]

    if querydata.include?("<ul class=\"redirectText\">")
      filtered = /<a(.*?)<\/a>/.match(querydata)[0]
      filtered = filtered.gsub(%r{</?[^>]+?>}, "")
      return wikipedia_lookup(filtered)
    end

    filtered = /<p>(.*?)<\/p>/.match(querydata)[0]
    filtered = filtered.gsub(%r{</?[^>]+?>}, "")

    return filtered
  end
end

mwiki = Wikipedia.new
