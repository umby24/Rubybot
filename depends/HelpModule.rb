class Help
	@command = ""
	@custom_help = false
	@custom_function = ""
	@arguments = []
	@subcommands = {}
	@baseDescription = []
	
	attr_accessor :command, :custom_help, :custom_function, :arguments, :subcommands, :baseDescription
	
	def initialize(command)
		@command = command
		@custom_help = false
		@custom_function = ""
		@arguments = {}
		@arguments["args"] = []
		@arguments["desc"] = []
		@arguments["opt"] = []
		@subcommands = {}
		@baseDescription = []
	end
	def addCustomHelp(function) # Sets the function to forward all help requests to.
		@custom_help = true
		@custom_function = function
	end
	def addArgument(argument, description, optional = false)
		@arguments["args"].push(argument)
		@arguments["desc"].push(description)
		@arguments["opt"].push(optional)
	end
	def addSubCommand(subcommand)
		@subcommands[subcommand] = Hash.new()
		@subcommands[subcommand]["arguments"] = {}
		@subcommands[subcommand]["arguments"]["args"] = []
		@subcommands[subcommand]["arguments"]["desc"] = []
		@subcommands[subcommand]["arguments"]["opt"] = []
		@subcommands[subcommand]["baseDescription"] = []
		@subcommands[subcommand]["command"] = subcommand
	end
	def addDescription(descript)
		@baseDescription.push(descript)
	end
	def addSubCommandDescription(command, descript)
		if @subcommands[command] == nil
			watchdog_Log("Error: Attempted to add to a sub-command that does not exist", "HelpModule: " + @command)
			#err_log("Error: Attempted to add to a sub-command that does not exist")
			return # sub-command does not exist.
		end
		
		@subcommands[command]["baseDescription"].push(descript)
	end
	def addSubCommandArgument(command, argument, description, optional = false)
		if @subcommands[command] == nil
			watchdog_Log("Error: Attempted to add to a sub-command that does not exist", "HelpModule: " + @command)
			#err_log("Error: Attempted to add to a sub-command that does not exist")
			return # sub-command does not exist.
		end
		
		@subcommands[command]["arguments"]["args"].push(argument)
		@subcommands[command]["arguments"]["desc"].push(description)
		@subcommands[command]["arguments"]["opt"].push(optional)
	end
	# Get functions
	def SendBaseHelp(sender)
		if @custom_help == false
			arg_string = ""
			
			if @arguments["args"].length > 0
				@arguments["args"].each do |arg|
					arg_string += "[" + arg + "]"
					
					if @arguments["opt"][@arguments["args"].index(arg)] == true
						arg_string += "(optional)"
					end
					
					arg_string += " "
				end
			end
			
			send_notice(sender,  $prefix + @command + " " + arg_string)
			
			@baseDescription.each do |d|
				send_notice(sender,  d)
			end
			
			if @subcommands.length > 0
				send_notice(sender, "This command has " + @subcommands.length.to_s + " sub-commands: " + @subcommands.keys.join(", "))
			end
		else
			begin
				send(@custom_function.to_sym)
			rescue Exception => e
				watchdog_Log("Custom Help Error (" + @custom_function + "): " + e.message, e.backtrace)
				#err_log("Error in custom help function " + @custom_function + ".")
				#err_log("Message: " + e.message)
				#err_log("Stack Trace: " + e.backtrace)
			end
		end
	end
	
	def SendSubHelp(sender, subcommand)
		if @custom_help == true
			begin
				send(@custom_function.to_sym)
			rescue Exception => e
				watchdog_Log("Custom Help Error (" + @custom_function + "): " + e.message, e.backtrace)
				#err_log("Error in custom help function " + @custom_function + ".")
				#err_log("Message: " + e.message)
				#err_log("Stack Trace: " + e.backtrace)
			end
			
			return
		end
		
		if @subcommands[subcommand] == nil
			send_notice(sender, "Sub-command " + subcommand + " does not exist.")
			return
		end
		
		arg_string = ""
		
		if @subcommands[subcommand]["arguments"]["args"].length > 0
			@subcommands[subcommand]["arguments"]["args"].each do |arg|
				arg_string += "[" + arg + "]"
				
				if @subcommands[subcommand]["arguments"]["opt"][@subcommands[subcommand]["arguments"]["args"].index(arg)] == true
					arg_string += "(optional)"
				end
				
				arg_string += " "
			end
		end
		
		send_notice(sender,  $prefix + @command + " " + subcommand + " " + arg_string)
		
		@subcommands[subcommand]["baseDescription"].each do |f|
			send_notice(sender, f)
		end
		#send_notice(sender,  @subcommands[subcommand]["baseDescription"])
	end
	def SendArgHelp(sender, arg)
		if @custom_help == true
			begin
				send(@custom_function.to_sym)
			rescue Exception => e
				watchdog_Log("Custom Help Error (" + @custom_function + "): " + e.message, e.backtrace)
				#err_log("Error in custom help function " + @custom_function + ".")
				#err_log("Message: " + e.message)
				#err_log("Stack Trace: " + e.backtrace)
			end
			
			return
		end
		
		if @arguments["args"].include?(arg) == false and @subcommands[arg] == nil
			send_notice(sender, "Argument not found.")
			return
		end
		
		if @subcommands[arg] != nil # This is actually a sub-command, not an argument :P
			SendSubHelp(sender, arg)
			return
		end
		
		# Send arg help.
		send_notice(sender, $prefix + @command + ": Argument " + 2.chr + arg)
		send_notice(sender, @arguments["desc"][@arguments["args"].index(arg)])
		
		#Done :)
	end
	def SendSubargHelp(sender, subcommand, arg)
		if @custom_help == true
			begin
				send(@custom_function.to_sym)
			rescue Exception => e
				watchdog_Log("Custom Help Error (" + @custom_function + "): " + e.message, e.backtrace)
				#err_log("Error in custom help function " + @custom_function + ".")
				#err_log("Message: " + e.message)
				#err_log("Stack Trace: " + e.backtrace)
			end
			
			return
		end
		
		if @subcommands[subcommand]["arguments"]["args"].include?(arg) == false
			send_notice(sender,  arg + " is not an argument of " + subcommand + ".")
			return
		end
		
		send_notice(sender, $prefix + @command + " " + subcommand + ": Argument " + 2.chr + arg)
		send_notice(sender, @subcommands[subcommand]["arguments"]["desc"][@subcommands[subcommand]["arguments"]["args"].index(arg)])
	end
end
