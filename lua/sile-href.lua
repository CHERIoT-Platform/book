function process(textTree)
	if config.print then
		textTree:match("href", function(href)
			local children = href:extract_children()
			table.insert(children, " (")
			table.insert(children, href:attribute("src"))
			table.insert(children, ")")
			return children
		end)
	end
	return textTree
end
