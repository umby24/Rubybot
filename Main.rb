# Ruby IRC Bot 'Rubybot'
# Made by Umby24
# Version 5.0 (Scratch rewrite)

# Required Classes
require_relative 'lib/multi_logger' # Provides multiple ruby logging access
require_relative 'lib/settings' # Provides a flexible key = value file loading system
require_relative 'lib/events' # Lays a framework for calling events to handle bot functions
require_relative 'lib/plugins' # Lays a framework to load plugins, which register events, which make the bot work!
require_relative 'network/irc_network' # Provides basic IRC network control


# Method is called by the bot's settings loader to set bot settings.
# @param [Bot] bot
# @param [Settings] file
def load_bot_settings(bot, file)
  file.select_group('Settings')
  bot.bot_name = file.read('username', '')
  bot.channels = file.read('channel','').split(',',20)
  bot.ip = file.read('ip', '')
  bot.port = file.read('port', '6667')
  bot.ident = file.read('ident', 'ruby')
  bot.real_name = file.read('real_name', 'ruby')
  bot.ns_pass = file.read('ns_pass', '')
  bot.prefix = file.read('prefix', '+')

  if bot.bot_name == ''
    print('Enter a username for the bot: ')
    bot.bot_name = gets.chomp
    file.write('username', bot.bot_name)
  end

  if bot.channels == []
    print('Enter a channel for the bot to join: ')
    bot.channels = [gets.chomp]
    file.write('channel', bot.channels[0])
  end

  if bot.ip == ''
    print('Enter the IP for the irc server: ')
    bot.ip = gets.chomp
    file.write('ip', bot.ip)
  end

  file.select_group('Admins')

  file.settings_hash['Admins'].each_key do |z|
    bot.admins << z
  end

  file.save_file
end

# Main class for the IRC Bot
class Bot
  attr_accessor :log, :bot_name, :channels, :ip, :port, :ident, :real_name
  attr_accessor :ns_pass, :prefix, :event, :version, :quit, :sets, :network
  attr_accessor :authed, :users, :topic, :admins

  def initialize
    @authed = []
    @users = Hash.new
    @topic = Hash.new
    @admins = []

    setup_logger
    load_settings
    @event = Events.new(self)
    @version = 5.0

    @pm = get_plugin_manager
    @pm.associate_bot(self)
    @pm.load_plugins
  end

  def run
    @network = IRC_Network.new(self)
    @quit = false
    @network.connect

    until @quit
      @network_thread = Thread.new { @network.parse }
      @log.debug('Started parse thread.')
      @network_thread.join
    end
  end

  private

  def setup_logger
    Dir.mkdir('Logs') unless File.directory?('Logs')

    log_1 = Logger.new(File.join('Logs', 'log.txt'), 'daily')
    log_2 = Logger.new(STDOUT)
    log_1.info("New Log Created at #{Time.now}")

    log_1.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime('%I:%M:%S %p')}> [#{severity}] -#{progname}- #{msg[0]}\n"
    end

    log_1.progname = 'CORE'

    log_2.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime('%I:%M:%S %p')}> [#{severity}] -#{progname}- #{msg[0]}\n"
    end
    log_2.progname = 'CORE'

    @log = MultiLogger.new(:level => Logger::DEBUG, :loggers => log_1, :progname => 'CORE')
    @log.add_logger(log_2)

    @log.info('Created logger.')
  end

  def load_settings
    @sets = Settings_Container.new

    new_file = Settings.new(self, 'settings.ini', 'load_bot_settings')
    new_file.load_file
    @sets.register_file(new_file)
    @sets.save_all
  end

end

ruby_bot = Bot.new # Create the bot
ruby_bot.run # Run the bot
gets # Wait for input before dying.