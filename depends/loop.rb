def socketloop()
    begin
    $pie = 1
    
    if $reloaded == 1
        sendmessage("Reloaded")
    end
    
    while $pie == 1
        $host = ""
        $dat = ""  # I'm terrible at naming and have no clue what to call this. so dat it is.
        $message = ""

        begin
            $raw = $socket.gets()
        rescue Exception => e
            $pie = 0
            $reloaded = 0
            $quit = 1
            watchdog_Log("Socket Error: " + e.message, e.backtrace)
            #err_log("Socket error: #{e.message}")
            break
        end

        eventRead()

        if $raw == nil
            $socket.close()
            $pie = 0
            $reloaded = 0
            break
        end

        if $raw[0,1] == ":"
            $host = $raw[1, $raw.index(" ") - 1]
        else
            $host = $raw[0, $raw.index(" ")]
        end

        $dat = $raw[$raw.index(" ") + 1, $raw.length - ($raw.index(" ") - 1)]

        if $dat.include?(":")
            $message = $dat[$dat.index(":") + 1, $dat.length - ($dat.index(":") + 1)]
        end

        if $host == "PING"
            $timer = 0
            send_raw("PONG #{$dat}")
            next
        end

        $second = $dat[0, $dat.index(" ")]
        $splits = $dat.split(" ", 10)

        if $host.include?("!")
            $name = $host[0,$host.index("!")]
        end

        $message = $message.strip

        if File.exists?(Dir.pwd + "/depends/Packets/#{$second}.rb")
            load Dir.pwd + "/depends/Packets/#{$second}.rb"
            next
        else
            _log("INFO", $second, "", $message)
            next
        end
    end
rescue Exception => e
    watchdog_Log(e.message, e.backtrace)
    #err_log(e.message)
    #err_log(e.backtrace)
end
end
