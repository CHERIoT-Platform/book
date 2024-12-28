local visit

function itemTitle(textTree)
	textTree:visit(visit)
	local dd = TextTree.new()
	dd:take_children(textTree)
	local dt = TextTree.new("font")
	if not textTree:has_attribute("tag") then
		textTree:error("missing tag attribute")
		return {textTree}
	end
	dt:attribute_set("weight", "700")
	dt:append_text(textTree:attribute("tag"))
	dt:append_text("\n\n")
	textTree:attribute_erase("tag")
	local negativeIndent = textTree:new_child("glue")
	negativeIndent:attribute_set("width", "-2em")
	textTree:append_child(dt)
	textTree:append_child(dd)
	return {textTree}
end

visit = function (textTree)
	if type(textTree) ~= "string" then
		if (textTree.kind == "description") then
			textTree.kind = "itemize"
			textTree:attribute_set("bullet", "")
			textTree:match("item", itemTitle)
			return { textTree }
		else
			textTree:visit(visit)
		end
	end
	return {textTree}
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
