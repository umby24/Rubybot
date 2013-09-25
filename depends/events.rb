def eventMessage()
begin
$evtmsg.each do |method|
send(method[1].to_sym)
end
rescue Exception => e
    err_log("Event error: #{e.message}")
end
end
def eventRead()
	begin
		$evtread.each do |method|
			send(method[1].to_sym)
		end
	rescue Excetpion => e
		err_log("Read event error: #{e.message}")
	end
end
def eventConnected()
	begin
		$evtcon.each do |method|
			send(method[1].to_sym)
		end
	rescue Exception => e
		err_log("Connected error: #{e.message}")
	end
end