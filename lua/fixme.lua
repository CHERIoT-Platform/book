function process(textTree)
	textTree:match("fixme", function(fixme)
		fixme:error("FIXME")
		return {}
	end)
	return textTree
end
