# Ruby IRC Bot 'Rubybot'
# Made by Umby24
# Version 5.0 (Scratch rewrite)

# Required Classes
require_relative 'lib/multi_logger' # Provides multiple ruby logging access
require_relative 'lib/settings' # Provides a flexible key = value file loading system
require_relative 'network/irc_network' # Provides basic IRC network control
require_relative 'network/channel'
load 'lib/events.rb' # Lays a framework for calling events to handle bot functions
load 'lib/plugins.rb' # Lays a framework to load plugins, which register events, which make the bot work!
load 'lib/command_help.rb'


# Method is called by the bot's settings loader to set bot settings.
# @param [Bot] bot
# @param [Settings] file
def load_bot_settings(bot, file)
  file.select_group('Settings')
  bot.network.bot_name = file.read('username', '')

  file.read('channel','').split(',',20).each do |z|
    bot.network.channels[z] = Channel.new(z)
  end

  bot.network.ip = file.read('ip', '')
  bot.network.port = file.read('port', '6667')
  bot.network.ident = file.read('ident', 'ruby')
  bot.network.real_name = file.read('real_name', 'ruby')
  bot.network.ns_pass = file.read('ns_pass', '')
  bot.prefix = file.read('prefix', '+')

  if bot.network.bot_name == ''
    print('Enter a username for the bot: ')
    bot.network.bot_name = gets.chomp
    file.write('username', bot.network.bot_name)
  end

  if bot.network.channels.nil?
    print('Enter a channel for the bot to join: ')
    channel = gets.chomp
    bot.network.channels[channel] = Channel.new(channel)
    file.write('channel', channel)
  end

  if bot.network.ip == ''
    print('Enter the IP for the irc server: ')
    bot.network.ip = gets.chomp
    file.write('ip', bot.network.ip)
  end

  file.select_group('Admins')

  file.settings_hash['Admins'].each_key do |z|
    bot.admins << z
  end

  file.save_file
end

# Main class for the IRC Bot
class Bot
  attr_accessor :log, :event, :version, :quit, :sets, :network, :prefix, :authed, :admins

  def initialize
    @authed = []
    @admins = []

    @network = IRC_Network.new(self)

    setup_logger
    load_settings
    @event = Events.new(self)
    @version = 5.0

    @pm = get_plugin_manager
    @pm.associate_bot(self)
    @pm.load_plugins
  end

  def reload
    load 'lib/command_help.rb'

    load 'lib/events.rb'
    @event = Events.new(self)

    load 'lib/plugins.rb'
    @pm = get_plugin_manager
    @pm.associate_bot(self)
    @pm.load_plugins
  end

  def run
    @quit = false
    @network.connect

    until @quit
      @network_thread = Thread.new { @network.parse }
      @log.debug('Started parse thread.')
      @network_thread.join
    end
  end

  def to_s
    "Rubybot<#{ip}:#{port}-#{bot_name}>"
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