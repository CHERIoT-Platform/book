function process(textTree)
	textTree:match("href", function(href)
		href:attribute_set("href", href:attribute("src"))
		href:attribute_erase("src")
		href.kind = "a"
		return { href }
	end)
	return textTree
end
