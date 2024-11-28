function addLabel(textTree)
	if not textTree:has_attribute("label") then
		local label = string.lower(textTree:text())
		label = string.gsub(label, " ", "_")
		textTree:attribute_set("label", "_" .. label)
	end
	return { textTree }
end

function process(textTree)
	textTree:match("chapter", addLabel)
	textTree:match("section", addLabel)
	textTree:match("subsection", addLabel)
	return textTree
end
