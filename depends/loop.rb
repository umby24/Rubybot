def socketloop(network)
  $networks[network + "_pie"] = 1
  if $networks[network + "_reloaded"] == 1
    sendmessage("Reloaded",network)
  end
    while $networks[network + "_pie"] == 1
	  $networks[network + "_host"] = ""
	  $networks[network + "_dat"] = ""  # I'm terrible at naming and have no clue what to call this. so dat it is.
	  $networks[network + "_message"] = ""
	  begin
	    $networks[network + "_raw"] = $networks[network + "_socket"].gets()
	  rescue Exception => e
        $networks[network + "_socket"].close()
        $networks[network + "_pie"] = 0
        $networks[network + "_reloaded"] = 0
        err_log("Socket error: #{e.message}")
		break
      end

	  if $networks[network + "_raw"][0,1] == ":"
	    $networks[network + "_host"] = $networks[network + "_raw"][1, $networks[network + "_raw"].index(" ") - 1]
	  else
	    $networks[network + "_host"] = $networks[network + "_raw"][0, $networks[network + "_raw"].index(" ")]
	  end

	  $networks[network + "_dat"] = $networks[network + "_raw"][$networks[network + "_raw"].index(" ") + 1, $networks[network + "_raw"].length - ($networks[network + "_raw"].index(" ") - 1)]

	  if $networks[network + "_dat"].include?(":")
	    $networks[network + "_message"] = $networks[network + "_dat"][$networks[network + "_dat"].index(":") + 1, $networks[network + "_dat"].length - ($networks[network + "_dat"].index(":") + 1)]
	  end

	if $networks[network + "_host"] == "PING"
        send_raw("PONG #{$networks[network + "_dat"]}",network)
	    next
	end

      $networks[network + "_second"] = $networks[network + "_dat"][0, $networks[network + "_dat"].index(" ")]
	  $networks[network + "_splits"] = $networks[network + "_dat"].split(" ", 4)
	  $networks[network + "_message"] = $networks[network + "_message"].strip
	  
	  case $networks[network + "_second"]
	    when "PRIVMSG"
		  puts "(#{$networks[network + "_splits"][1]}) <#{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]}> #{$networks[network + "_message"]}"
		  
		  if $networks[network + "_message"][1,$networks[network + "_message"].length - 2] == "VERSION"
            send_raw("NOTICE " + $networks[network + "_host"][0, $networks[network + "_host"].index("!")] + " :" + 1.chr + "VERSION Ruby-irc bot Version 4.1 by Umby24" + 1.chr,network) #CTCP Version.
            puts "Received CTCP Version"
          end
		  
		  if $networks[network + "_message"][0, 5] == 1.chr + "PING" # Handles CTCP Pings.
			if $networks[network + "_splits"][3].gsub(1.chr,"") != ""
			thisid = $networks[network + "_splits"][3].gsub(1.chr,"")[0, $networks[network + "_splits"][3].gsub(1.chr,"").index(13.chr)]
            send_raw("NOTICE " + $networks[network + "_host"][0, $networks[network + "_host"].index("!")] + " :" + 1.chr + "PING " + thisid + 1.chr,network)
			else
			send_raw("NOTICE " + $networks[network + "_host"][0, $networks[network + "_host"].index("!")] + " :" + 1.chr + "PING" + 1.chr,network)
			end
            puts "Received CTCP PING"
          end
		  
		  domsg(network) # For user defined message handling (Keeps this file uncluttered)
		  
		  if $networks[network + "_message"][0,1] == "+"
		  
		    if $networks[network + "_message"].include?(" ") == false
			  $networks[network + "_message"] += " "
			end
			
			$networks[network + "_cmd"] = $networks[network + "_message"][1, $networks[network + "_message"].length - 1]
			if $networks[network + "_cmd"].include?(" ") == false
			  $networks[network + "_cmd"] += " "
			end
			
            $networks[network + "_okay"] = false
			
            $networks[network + "_access"].each {|item|
              if item.strip.downcase == $networks[network + "_host"][0,$networks[network + "_host"].index("!")].strip.downcase
                $networks[network + "_okay"] = true
              end
            }
			
			$networks[network + "_cmd"][0, $networks[network + "_cmd"].index(" ")] = $networks[network + "_cmd"][0, $networks[network + "_cmd"].index(" ")].downcase
			
			docmd(network) #Handle commands.
		  end
		  next
		  
		when "NOTICE"
		  puts "-#{$networks[network + "_host"]}- #{$networks[network + "_message"]}"
		  next
		  
		when "TOPIC"
		  $networks[network + "_topic"][$networks[network + "_splits"][1]] = $networks[network + "_splits"][2][1, $networks[network + "_splits"][2].length - 1]
		  puts "Topic Updated to #{$networks[network + "_splits"][2][1, $networks[network + "_splits"][2].length - 1]}"
		  next
		  
		when "QUIT"
	      puts "** #{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]} left #{$networks[network + "_splits"][1]} (#{$networks[network + "_splits"][2]})"
          $networks[network + "_authed"].delete($networks[network + "_host"][0,$networks[network + "_host"].index("!")])
		  next
		  
		when "PART"
		  puts "** #{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]} left #{$networks[network + "_splits"][1]} (#{$networks[network + "_splits"][2]})"
          $networks[network + "_authed"].delete($networks[network + "_host"][0,$networks[network + "_host"].index("!")])
		  next
		  
		when "NICK"
		  send_raw("WHOIS #{$networks[network + "_message"]}",network) # This is for our user verification.. we use WHOIS to ensure they're verified. if not, we can't verify its really them. This avoids imposters.
		  next
		  
		when "307"
		  $networks[network + "_authed"][$networks[network + "_authed"].length] = $networks[network + "_splits"][2] 
		  next
		  
		when "330"
		  $networks[network + "_authed"][$networks[network + "_authed"].length] = $networks[network + "_splits"][2]
		  next
		  
		when "376"
			send_raw("JOIN #{$networks[network + "_current"]}",network)
			if $networks[network + "_nspass"] != "" && $networks[network + "_id"] == false
				send_raw("NICKSERV IDENTIFY " + $networks[network + "_nspass"],network)
				@@id = true
			end
			
		when "353"
		  $networks[network + "_arr"] = $networks[network + "_message"].split(" ",120)
          $networks[network + "_players"] = $networks[network + "_arr"]
          $networks[network + "_players"].each do |f|
            f = f.gsub("~","")
            f = f.gsub("@","")
            send_raw("WHOIS #{f}",network)
          end
		  next
		  
		when "MODE"
		  what3 = 0
          what2 = 0    
          if $networks[network + "_splits"][2].index(" ") == nil
            what3 = 0
            what2 = $networks[network + "_splits"][2].length
          else
            what3 = $networks[network + "_splits"][2].index(" ")
            what2 = $networks[network + "_splits"][2].length - $networks[network + "_splits"][2].index(" ") 
          end    
          what = $networks[network + "_splits"][2][what3, what2]
          send_raw("WHOIS #{what}",network)
		  next
		  
		when "JOIN"
		  puts "** #{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]} joined #{$networks[network + "_splits"][1]}."
		  send_raw("WHOIS #{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]}",network)
		  next
		  
		when "332"
          $networks[network + "_topic"][$networks[network + "_splits"][2]] = $networks[network + "_message"]
		  next
		  
	  end
	  puts $networks[network + "_message"]
	end
  end
