local visit

function itemTitle(textTree)
	local dt = TextTree.new("font")
	if not textTree:has_attribute("tag") then
		textTree:error("missing tag attribute")
		return {textTree}
	end
	dt:attribute_set("weight", "700")
	dt:append_text(textTree:attribute("tag"))
	dt:append_text(" ")
	textTree:attribute_erase("tag")
	table.insert(textTree.children, 1, dt)
	textTree:visit(visit)
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
