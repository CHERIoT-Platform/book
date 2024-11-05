
function process(textTree)
	textTree:visit(function (tree)
		if type(tree) == "string" then
			return {tree}
		end
		-- FIXME: This should create an admonition block, but for now just promote it to a normal paragraph
		if tree.kind == "note" then
			return tree:extract_children()
		end
		return {tree}
	end)
	return textTree
end
