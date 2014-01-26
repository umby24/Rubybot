$watchdog_headers = <<htmlhead
<!-- Begin Header -->
<html>
<head>
<title>Rubybot Error Log</title>
htmlhead
$watchdog_css = <<htmlcss
<style type="text/css">
body {
	font-family: "Microsoft PhagsPa";
	color:#2f2f2f;
	background-color:#F7F7F7;
}
p.gen {
	font-weight:bold;
	text-align:center;
	font-size:14px;
}
h1.header {
	background-color:darkred;
	text-shadow:2px 1px 0px rgba(0,0,0,.2); 
	font-size:25px;
	font-weight:bold;
	text-decoration:none;
	text-align:center;
	color:white;
	margin:0;
	height:42px; 
	width:auto;
	border-bottom: 1px black solid;
	height: 42px;
	margin: -8px;
	line-height: 42px;
}
table {
	border: 1px solid #A0A0A0;
	table-layout: auto;
	empty-cells: hide;
	border-collapse: collapse;
}

tr {
	border: 1px solid #A0A0A0;
	background-color: #D0D0D0;
	color: #212121;
	font-weight: bold;
	opacity:1.0;
}
td {
	border-right: 1px solid #A0A0A0;
}
td.bt {
	padding-left:20px;
}
</style>
</head>
<body>
htmlcss
$watchdog_footer = <<htmlfoot
</body>
</html>
htmlfoot

def generate_ErrorHTML()
	time = Time.new
	htmlFile = File.open("Watchdog.html", "w+")
	htmlFile.syswrite($watchdog_headers)
	htmlFile.syswrite($watchdog_css)
	htmlFile.syswrite("<h1 class=\"header\">Rubybot Error Log</h1>\n<p class=\"gen\">Generated at #{time.strftime("%I:%M:%S %p")}</p>\n<p style=\"font-weight:bold;\">Errors:</p>")
	htmlFile.syswrite(getEntries())
	htmlFile.syswrite($watchdog_footer)
	htmlFile.close()
end
def getEntries()
	mytable = "<table>\n"
	if File.exists?("logs/watchdog.txt")
	IO.foreach("logs/watchdog.txt") { |line|
		jsonobj = JSON.parse(line)
		mytable += "<tr>\n"
		mytable += "<td>" + jsonobj["Date"] + "</td>\n"
		mytable += "<td>" + jsonobj["Message"] + "</td>\n"
		mytable += "</tr>\n"
		mytable += "<tr>\n"
		mytable += "<td></td>\n"
		mytable += "<td class=\"bt\"> - " + jsonobj["BT"] + "</td>\n"
		mytable += "</tr>\n"
	}
	end
	mytable += "</table>\n"
	return mytable
end
def watchdog_Log(message, backtrace)
	backtrace = backtrace.to_s
	message = message.gsub("\\", "\\\\")
	message = message.gsub("\"", "\\\"")
	backtrace = backtrace.gsub("\\", "\\\\")
	backtrace = backtrace.gsub("\"", "\\\"")	
	time = Time.new
	entryfile = File.open("logs/watchdog.txt", "a+")
	entryfile.syswrite("{\"Date\": \"#{time.strftime("%I:%M:%S %p")}\", \"Message\": \"#{message}\", \"BT\": \"#{backtrace}\"}\n")
	entryfile.close()
end
def reload_system() # Just a little macro..
	load Dir.pwd + "/depends/Watchdog.rb"
end
