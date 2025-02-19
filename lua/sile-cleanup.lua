-- Recursively find any font notes with no children or the empty string as a
-- child.
function clean(tree)
	if #tree.children == 0 then
		return {}
	end
	if #tree.children == 1 then
		if tree.children[1] == "" then
			return {}
		end
	end
	tree:match("font", clean)
	return { tree }
end

-- Remove empty \font elements.  SILE interprets these as affecting all
-- subsequent things, so we end up with weird typesetting.
function process(textTree)
	textTree:match("font", clean)
	return textTree
end
