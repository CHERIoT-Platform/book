function process(textTree)
	textTree:match("comment", function() return {} end)
	return textTree
end
