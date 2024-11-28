function makeMonospace(textTree)
	textTree.kind = "font"
	textTree:attribute_set("family", "Hack")
	textTree:attribute_set("size", "0.8em")
	return textTree
end

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
	elseif textTree.kind == "flag" then
		makeMonospace(textTree)
	elseif textTree.kind == "file" then
		makeMonospace(textTree)
		-- TODO: Keyword matching
	elseif textTree.kind == "c" then
		makeMonospace(textTree)
	elseif textTree.kind == "cxx" then
		makeMonospace(textTree)
	elseif textTree.kind == "lua" then
		makeMonospace(textTree)
	end
	textTree:visit(visit)
	return { textTree }
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
