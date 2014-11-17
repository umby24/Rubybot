puts "** #{$name} joined #{$splits[1]}."
$joinName = $name
$joinChan = $splits[1]

eventPlayerJoin()

send_raw("WHOIS #{$name}")