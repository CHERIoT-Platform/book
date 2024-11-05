local visit

function itemTitle(textTree)
	if not (type(textTree) == "string") then
		if (textTree.kind == "item") then
			local dt = TextTree.new("font")
			if not textTree:has_attribute("tag") then
				textTree:error("missing tag attribute")
				return {textTree}
			end
			dt:attribute_set("weight", "700")
			dt:append_text(textTree:attribute("tag"))
			textTree:attribute_erase("tag")
			table.insert(textTree.children, 1, dt)
			textTree:visit(visit)
			return {textTree}
		end
	end
	return {textTree}
end

visit = function (textTree)
	if type(textTree) ~= "string" then
		if (textTree.kind == "description") then
			textTree.kind = "itemize"
			textTree:attribute_set("bullet", "")
			textTree:visit(itemTitle)
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
