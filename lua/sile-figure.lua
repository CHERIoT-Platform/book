function process(textTree)
	textTree:match("figure", function(figure)
		local figureBlock = TextTree.new("figure")
		local img = figureBlock:new_child("img")
		img:attribute_set("src", figure:attribute("src"))
		img:attribute_set("width", "100%fw")
		local caption = figureBlock:new_child("caption")
		if figure:has_attribute("label") then
			caption:attribute_set("label", figure:attribute("label"))
		end
		caption:take_children(figure)
		return { figureBlock }
	end)
	return textTree
end
