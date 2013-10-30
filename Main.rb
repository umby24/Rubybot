####################################
#         Ruby IRC Client          #
#            by Umby24             #
#        http://umby.d3s.co        #
# Feel free to distribute or edit, #
#   but leave credit where due.    #
####################################

#First declare my required libs, and required variables.

require 'socket'

$tol = 0
$tolerance = 10
$access = []
$plugins = []
$quit = 0
$players = Hash.new
$topic = Hash.new
$pia = 1
$reloaded = 0
$botname = ""
$realname = ""
$nspass = ""
$ident = ""
$serverip = ""
$serverport = 6667
$serverchannel = []
$current = ""
$authed = []
$command = Hash.new
$gcommand = Hash.new
$evtmsg = Hash.new
$evtread = Hash.new
$help = Hash.new
$prefix = "+"
$id = false
$timer = 0
$evtcon = Hash.new

BEGIN {
  load Dir.pwd + "/depends/reqfunc.rb"
  load Dir.pwd + "/depends/events.rb"
  puts "#############################"
  puts "#        Ruby IRC bot       #"
  puts "#        Version 4.3        #"
  puts "#         by Umby24         #"
  puts "#############################"
}
END {
  sleep(5)
  puts "Thank you for using the bot."
}

#Call the external libraries to load the users and plugins.
load_settings()
load_users()
load_plugins()

#time to connect to the server.

$socket = TCPSocket.open($serverip,$serverport)
send_raw("NICK #{$botname}")
send_raw("USER " + $ident + " ruby ruby :" + $realname)
send_raw("MODE #{$botname} +B-x")

#load the loop, and then call them in their own threads.
#there are two loops, one to accept console output
#the other is to process incoming data from the socket.

$t2 = Thread.new{systemloop()}
$t3 = Thread.new{ping_loop()}

while $quit == 0
  load Dir.pwd + "/depends/loop.rb"
  $t1 = Thread.new{loop_load()}
  $t1.join()
end
