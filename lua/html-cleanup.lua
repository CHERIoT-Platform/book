function process(textTree)
	textTree:match_any({ "h1", "h2", "h3", "h4" }, function(heading)
		if heading:has_attribute("number") then
			heading:insert_text(1, heading:attribute("number") .. ". ", 1)
			heading:attribute_erase("number")
		end
		return { heading }
	end)
	textTree:match("caption", function(caption)
		local parent = caption:parent()
		if parent.kind == "table" then
			if parent:has_attribute("number") then
				caption:insert_text(1, "Table " .. parent:attribute("number") .. ". ")
				parent:attribute_erase("number")
			end
		end
		return { caption }
	end)
	return textTree
end
