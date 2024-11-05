
function visit(textTree)
		if type(textTree) == "string" then
			return {textTree}
		end
		if textTree.kind == "keyword" then
			textTree.kind = "font"
			textTree:attribute_set("style", "italic")
		end
		if textTree.kind == "textem" then
			textTree.kind = "font"
			textTree:attribute_set("style", "italic")
		end
		textTree:visit(visit)
		return {textTree}
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
