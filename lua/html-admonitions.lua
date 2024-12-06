function process(textTree)
	textTree:match_any({"note", "warning", "caution"}, function(admonition)
		local div = TextTree.new("div")
		div:attribute_set("class", admonition.kind)
		admonition.kind = "p"
		div:append_child(admonition)
		return {div}
	end)
	return textTree
end
