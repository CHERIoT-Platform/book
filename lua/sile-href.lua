function process(textTree)
	if config.print then
		textTree:match("href", function(href)
			local footnote = TextTree.new("footnote")
			footnote:append_text(href:attribute("src"))
			return { href, footnote }
		end)
	end
	return textTree
end
