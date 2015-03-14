class Settings
  attr_reader :filename
  attr_reader :current_group
  attr_reader :last_modified
  attr_reader :settings_hash

  # @param [Bot] bot
  def initialize(bot, filename, load_function, folder = 'Settings', save_file=true)
    # -- Setup the initial variables.
    @filename = File.join(Dir.pwd, folder, filename)
    @current_group = ''
    @last_modified = Time.now
    @settings_hash = {}
    @load_settings = load_function
    @save = save_file
    @bot = bot
  end

  def load_file
    unless File.exist?(@filename)
      File.open(@filename, 'w+') { |f|
        f.write('')
      }
    end

    load_file!
    @last_modified = Time.now

    begin
      send(@load_settings.to_sym, @bot, self)
    rescue Exception => e
      @bot.log.error("Load File Error: #{e.message}")
      @bot.log.debug("Load File Error: #{e.backtrace}")
    end
  end

  def save_file
    return unless @save

    File.open(@filename, 'w+') { |f|
      @settings_hash.each { |k, v|
        if k != ''
          f.write("[#{k}]\n")
        end

        v.each { |sk, sv|
          f.write("#{sk} = #{sv}\n")
        }
      }
    }

    @last_modified = Time.now
  end

  def select_group(group)
    if @settings_hash.fetch(group, nil) != nil
      @current_group = group
      return
    end

    @settings_hash[group] = {}
    @current_group = group
  end

  def read(key, default='')
    if @settings_hash[@current_group][key] != default and @settings_hash[@current_group][key] != nil
      return @settings_hash[@current_group][key]
    end
    @settings_hash[@current_group][key] = default
    default
  end

  def write(key, value)
    @settings_hash[@current_group][key] = value
  end

  private

  def load_file!
    @current_group = ''
    @settings_hash = {}
    @settings_hash[''] = Hash.new

    File.open(@filename, 'r') { |f|
      until f.eof
        line = f.readline

        # -- Deal with comments that begin in the middle of a line.
        if line.include?(';')
          line = line[0, line.index(';')]
        end

        next if line == nil # -- Probably EOF
        next if line[0, 1] == ';' # -- Whole line comment
        # -- Filter non-valid input.
        next unless line.include?('=') or (line.include?('[') and line.include?(']'))

        if line[0, 1] == '[' && line[line.length - 2, 1] == ']'
          # -- Settings Group
          grp_name = line[1, line.length - 3]

          # -- If group already exists, skip.
          @current_group = grp_name
          next if @settings_hash.fetch(grp_name, nil) != nil

          # -- Add new settings group
          @settings_hash[grp_name] = Hash.new
          next
        end

        if line.include?('=')
          @settings_hash[''] = Hash.new if @current_group == '' && @settings_hash.fetch('', nil) == nil
          key = line[0, line.index('=')].strip
          value = line[line.index('=') + 1, line.length - (line.index('=') + 1)].strip
          @settings_hash[@current_group][key] = value
        end
      end
    }
  end
end

class Settings_Container
  attr_accessor :settings_files

  def initialize
    Dir.mkdir('Settings') unless File.directory?('Settings')
    @settings_files = []
  end

  # @param [Settings] file
  def register_file(file)
    @settings_files.push(file)
  end

  def save_all
    @settings_files.each do |z|
      z.save_file
    end
  end

  def settings_loop
    @settings_files.each do |z|
      next if File.mtime(z.filename) == z.last_modified
      
      z.load_file
      z.last_Modified = File.mtime(z.filename)
    end
  end
end