#puts "-#{$host}- #{$message}"
_log("NOTICE", "", "", $message, $host)

if $pinging == true && $message == "PING"
    newtime = Time.now.to_f
    theping = newtime - $pingtime
    theping = theping.round(2)
    sendmessage("Ping is #{theping.to_s} s")
    $pinging = false
end