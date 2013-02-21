def load_settings()
	puts "Loading settings"
	$networks["networks"] = []
	network = ""
	begin
		reader = IO.readlines("settings.txt")
		reader.each {|line|
			if line.include?("=") == false
				if line.include?("[") == false
					puts "Illegally formatted string detected. Skipping line."
					next
				else
					network = line.gsub("[","").gsub("]","")
						if $networks["networks"].include?(network) == false
						network = network.gsub("\n","")
							$networks["networks"] += [network]
							next
						end
				end
			end
			a = line[0, line.index("=")]
			d = line[line.index("=") + 1, line.length - (line.index("=") + 1)]
		
			if d.include?("\n") then
				d = d.chop
			end
			
			case a.downcase
			  when "username"
				$networks[network + "_botname"] = d
			  when "channel"
				$networks[network + "_current"] = d
				$networks[network + "_serverchannel"] = [d]
			  when "server"
				$networks[network + "_serverip"] = d
			  when "port"
				$networks[network + "_serverport"] = d
			  when "ident"
				$networks[network + "_ident"] = d
			  when "realname"
				$networks[network + "_realname"] = d
			  when "ns_pass"
				$networks[network + "_nspass"] = d
			end
		}
	rescue Exception => e
		err_log("Error loading settings: #{e.message}")
		err_log("Error loading settings: #{e.backtrace}")
	end
end