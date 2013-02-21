def domsg(network)
	#what once was a plugin, is now a feature.
	#This logs all chat.
	if $networks[network + "_splits"][1] != $networks[network + "_botname"]
	logtext("<#{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]}> #{$networks[network + "_message"]}", $networks[network + "_splits"][1],network)
	else
	logtext("<#{$networks[network + "_host"][0,$networks[network + "_host"].index("!")]}> #{$networks[network + "_message"]}", $networks[network + "_host"][0,$networks[network + "_host"].index("!")],network)  
	end
	
	if $networks[network + "_message"][0,1] != "+" && $networks[network + "_message"].include?(":") && $networks[network + "_host"][0,$networks[network + "_host"].index("!")] == "SinZationalBot"
	orighost = $networks[network + "_host"]
	origmess = $networks[network + "_message"]
	$networks[network + "_host"] = $networks[network + "_message"][0, $networks[network + "_message"].index(":")] + "!"
	$networks[network + "_message"] = $networks[network + "_message"][$networks[network + "_message"].index(":") + 1, $networks[network + "_message"].length - $networks[network + "_message"].index(":") + 1]
	if $networks[network + "_message"].include?("  ") == false
		$networks[network + "_host"] = orighost
		$networks[network + "_message"] = origmess
	else
		$networks[network + "_message"] = $networks[network + "_message"][2, $networks[network + "_message"].length - 2]
	end
	if $networks[network + "_access"].include?($networks[network + "_host"].gsub("!","") + "\n") == false
		$networks[network + "_access"] += [$networks[network + "_host"].gsub("!","") + "\n"]
	end
	if $networks[network + "_authed"].include?($networks[network + "_host"].gsub("!","")) == false
		$networks[network + "_authed"] += [$networks[network + "_host"].gsub("!","")]
	end
end
end