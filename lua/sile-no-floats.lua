function removeFloating(textTree)
	textTree:match("floating", removeFloating)
	return textTree.children
end

function process(textTree)
	textTree:match("floating", removeFloating)
	return textTree
end
