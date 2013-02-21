####################################
#         Ruby IRC Client          #
#            by Umby24             #
#        http://umby.d3s.co        #
# Feel free to distribute or edit, #
#   but leave credit where due.    #
####################################

require 'socket'

BEGIN {
  puts "#############################"
  puts "#        Ruby IRC bot       #"
  puts "#         Version 5         #"
  puts "#         by Umby24         #"
  puts "#############################"
}
END {
  puts "Thank you for using the bot."
}

$networks = Hash.new
$networks["networks"] = []
$pia = 1
$current = Hash.new

class Rubybot

	def initialize(ip,port,channel,botname,realname,ident,nspass,network,pause)
	
		$networks[network + "_id"] = false
		$networks[network + "_quit"] = 0
		$networks[network + "_topic"] = Hash.new
		$networks[network + "_authed"] = []
		
		load Dir.pwd + "/depends/reqfunc.rb"
		load Dir.pwd + "/plugins/func.rb"
		load Dir.pwd + "/plugins/libs.rb"
		load Dir.pwd + "/plugins/message.rb"
		
		#User added variables
		begin
			load Dir.pwd + "/plugins/vars.rb"
		rescue
			err_log("No variables file. Ignoring.")
		end
		

		#Call the external libraries to load the users and plugins.
		load_users(network)
		load_plugins()
		
		load Dir.pwd + "/depends/cmd.rb"
		#time to connect to the server.

		$networks[network + "_socket"] = TCPSocket.open(ip,port)
		
		send_raw("NICK #{botname}", network)
		send_raw("USER " + ident + " ruby ruby :" + realname, network)
		send_raw("MODE #{botname} +B-x",network)
		
		#load the loop, and then call them in their own threads.
		#there are two loops, one to accept console output
		#the other is to process incoming data from the socket.

		load Dir.pwd + "/depends/loop.rb"
		t1 = Thread.new{loop_load(network)}
		t2 = Thread.new{systemloop()}
		load Dir.pwd + "/plugins/thread.rb" # Load user made threads.
		if pause == true
			t1.join()
		end
	end
end

load "meh.rb"
load_settings()

$networks["networks"].each {|network|
	puts network
	if $networks["networks"][$networks["networks"].length - 1] == network
		puts network + "+"
		$current["net"] = network
		$current["chan"] = $networks[network + "_current"]
		instance_variable_set("@bot" + network, Rubybot.new($networks[network + "_serverip"],$networks[network + "_serverport"],$networks[network + "_current"],$networks[network + "_botname"],$networks[network + "_realname"],$networks[network + "_ident"],$networks[network + "_nspass"],network,true))
	else
		instance_variable_set("@bot" + network, Rubybot.new($networks[network + "_serverip"],$networks[network + "_serverport"],$networks[network + "_current"],$networks[network + "_botname"],$networks[network + "_realname"],$networks[network + "_ident"],$networks[network + "_nspass"],network,false))
	end
}
