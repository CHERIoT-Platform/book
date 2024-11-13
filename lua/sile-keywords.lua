function visit(textTree)
	if type(textTree) == "string" then
		return { textTree }
	end
	if textTree.kind == "keyword" then
		textTree.kind = "font"
		textTree:attribute_set("style", "italic")
	elseif textTree.kind == "textem" then
		textTree.kind = "font"
		textTree:attribute_set("style", "italic")
	elseif textTree.kind == "file" then
		textTree.kind = "font"
		textTree:attribute_set("family", "Source Code Pro")
		-- TODO: Keyword matching
	elseif textTree.kind == "c" then
		textTree.kind = "font"
		textTree:attribute_set("family", "Source Code Pro")
	elseif textTree.kind == "lua" then
		textTree.kind = "font"
		textTree:attribute_set("family", "Source Code Pro")
	end
	textTree:visit(visit)
	return { textTree }
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
