## Functions for registering events

def regMsg(name, method)
	$evtmsg[name] = method
end

def regCmd(cmd, method)
	$command[cmd] = method
end

def regGCmd(cmd, method)
	$gcommand[cmd] = method
end

def regLib(library)
	require library
end

def regCon(name, method)
	$evtcon[name] = method
end

def regRead(name, method)
	$evtread[name] = method
end

def regJoin(name, method)
	$evtjoin[name] = method
end

## Executes events

def eventMessage()
	begin
		$evtmsg.each do |method|
		send(method[1].to_sym)
	end
	rescue Exception => e
		watchdog_Log("Event Error: " + e.message, e.backtrace)
		#err_log("Event error: #{e.message}")
	end
end
def eventRead()
	begin
		$evtread.each do |method|
			send(method[1].to_sym)
		end
	rescue Excetpion => e
		watchdog_Log("Read Event Error: " + e.message, e.backtrace)
		#err_log("Read event error: #{e.message}")
	end
end
def eventConnected()
	begin
		$evtcon.each do |method|
			send(method[1].to_sym)
		end
	rescue Exception => e
		watchdog_Log("Connected Event Error: " + e.message, e.backtrace)
		#err_log("Connected error: #{e.message}")
	end
end
def eventPlayerJoin()
	begin
		$evtjoin.each do |method|
			send(method[1].to_sym)
		end
	rescue Exception => e
		watchdog_Log("Joined Event Error: " + e.message, e.backtrace)
		#err_log("Joined error: #{e.message}")
		#err_log("JOINED: #{e.backtrace}")
	end
end
