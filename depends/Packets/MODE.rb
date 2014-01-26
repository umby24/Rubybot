what3 = 0
what2 = 0    
if $splits[2].index(" ") == nil
	what3 = 0
	what2 = $splits[2].length
else
	what3 = $splits[2].index(" ")
	what2 = $splits[2].length - $splits[2].index(" ") 
end    
	what = $splits[2][what3, what2]
	send_raw("WHOIS #{what}")