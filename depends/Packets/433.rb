$botname = $botname + "_"
send_raw("NICK #{$botname}")
send_raw("USER " + $ident + " ruby ruby :" + $realname)
send_raw("MODE #{$botname} +B-x")