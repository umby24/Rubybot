def error_clear_logs()
    if File.exists?("logs/watchdog.txt")
        File.delete("logs/watchdog.txt")
    end

    sendmessage("Logs cleared.")
end
def error_generate_html()
    generate_ErrorHTML()
    sendmessage("HTML Error log generated.")
end

regCmd("clearerrors", "error_clear_logs")
regCmd("genhtml", "error_generate_html")

help = Help.new("clearerrors")
help.addDescription("Clears all error log entries.")
$help.push(help)

help = Help.new("genhtml")
help.addDescription("Generates the HTML Error log.")
$help.push(help)
