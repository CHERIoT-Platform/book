function visit(textTree)
	if type(textTree) ~= "string" then
		if (textTree:has_attribute("label")) then
			local label = textTree:attribute("label")
			textTree:attribute_erase("label")
			textTree:attribute_set("id", label)
		end
		textTree:visit(visit)
	end
	return {textTree}
end


function process(textTree)
	textTree:visit(visit)
	return textTree
end

