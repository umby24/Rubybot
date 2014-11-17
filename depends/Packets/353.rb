$arr = $message.split(" ",120)
$players[$splits[3]] = $arr
$arr.each do |f|
	if f.include?("~") || f.include?("@") || f.include?("+")
		f = f.gsub("~","")
		f = f.gsub("@","")
		f = f.gsub("+","")
		f = f.gsub(" ","")
		
		if $authed.include?(f) == false
			$authed[$authed.length] = f
		end
		
		next
	end
	f = f.gsub("~","")
	f = f.gsub("@","")
	f = f.gsub("+","")
	f = f.gsub(" ","")
	send_raw("whois #{f}")
end