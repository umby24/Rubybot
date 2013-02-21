def systemloop()
	while $pia == 1
		message = gets
		message = message.chop()
		
		if message[0,3] == "/c "
			mmessage = message[3, message.length - 3]
			$current["chan"] = mmessage
			$networks[$current["net"] + "_current"] = mmessage
			message = "/null\\" # Keeps the channel changing from being sent to the new channel
		end
		
		if message[0,3] == "/n "
			mmessage = message[3, message.length - 3]
			$current["net"] = mmessage
			message = "/null\\"
		end
		
		case message
		when "/null\\"
				#Do nothing :D
		when "/join"
			send_raw("JOIN " + @@current)
		else
			sendmessage(message,$current["net"])
		end
	end
end