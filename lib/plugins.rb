# - Rubybot Plugin System
# - Inspired by rbot (ruby-rbot.org)
# - How it works, to help out others:
# - 1. PluginManager class, which includes Singleton
# - This means there can only be one PluginManager class globally, ever.
# - This ensures that it can be accessed anywhere anytime in the global scope.
# - The get_plugin_manager method returns the PluginManager instance anywhere in code.
# -
# - 2. Plugin class, which is what all plugins will extend
# - Plugins will not override initialize (as that would keep the plugin from registering with the manager)
# - Plugins will instead be checked for plugin_init function, which will set variables, register methods, ect.
# - The init method calls the singleton manager method to register itself.
# -
# - 3. Loading plugins
# - Uses an anonymous module call to keep things clean, and allows things to be reloaded
# - The anonymous method should include something that creates an instance of the plugin's class
# - This will call the superclass (Plugin) init method, which will register the anon method
# - with the plugin manager. Viola.

require 'singleton'

# All plugins should extend this class
# Plugins should NOT override the init method.
# Plugins SHOULD include a 'plugin_init' method.

def get_plugin_manager
  return PluginManager.instance
end

class Plugin
  attr_reader :name, :version, :author

  def initialize
    @manager = get_plugin_manager
    @bot = @manager.bot
    @name = "Unknown"
    @version = 0.0
    @author = "Unknown"

    if self.respond_to?('plugin_init')
      plugin_init
    end

    @manager.register_plugin(self)
  end

end

class PluginManager
  include Singleton
  attr_reader :plugins, :bot

  def initialize
    @plugins = Hash.new

    if !File.directory?('Plugins')
      Dir.mkdir('Plugins')
    end
  end

  def associate_bot(bot)
    @bot = bot
  end

  def register_plugin(plugin_class)
    raise TypeError "Plugin does not inherit plugin class" unless plugin_class.kind_of?(Plugin)
    return unless plugin_class.name != 'Unknown' and plugin_class.author != 'Unknown' and plugin_class.version != 0.0

    @plugins[plugin_class.name] = plugin_class
    @bot.log.progname = 'PluginManager'
    @bot.log.info("Loaded #{plugin_class.name} by #{plugin_class.author}, Version #{plugin_class.version}")
    @bot.log.progname = 'CORE'
  end

  def load_plugins
    sets = @bot.sets.settings_files[0]
    sets.select_group('Plugins')

    sets.settings_hash['Plugins'].each do |k,v|
      load_plugin(File.join('Plugins', k))
    end
  end

  def unload_plugin

  end

  def load_plugin(file)
    plugin_module = Module.new

    begin
      plugin_string = IO.read(file)
      plugin_module.module_eval(plugin_string, file)
    rescue Exception => e
      @bot.log.progname = 'PluginManager'
      @bot.log.error("Failed to load #{file}: #{e.message}")
      @bot.log.debug(e.backtrace)
      @bot.log.progname = 'CORE'
    end

  end
end