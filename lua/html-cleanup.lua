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
	textTree:match("figure", function(figure)
		local figureBlock = TextTree.new("div")
		figureBlock:attribute_set("class", "figure")
		local img = figureBlock:new_child("img")
		img:attribute_set("src", figure:attribute("src"))
		img:attribute_set("alt", figure:attribute("alt"))
		if figure:has_attribute("number") then
			figure:insert_text(1, "Figure " .. figure:attribute("number") .. ". ")
		end
		local caption = figureBlock:new_child("div")
		caption = caption:new_child("p")
		caption:attribute_set("class", "figure-caption")
		caption:take_children(figure)
		if figure:has_attribute("label") then
			caption:attribute_set("id", figure:attribute("label"))
		end
		return { figureBlock }
	end)
	return textTree
end
