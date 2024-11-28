function process(textTree)
	textTree:match("textem", function(tree)
		tree.kind = "em"
		return { tree }
	end)
	return textTree
end
