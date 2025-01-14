function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function process(textTree)
	textTree:match("figure", function(figure)
		local parbox = TextTree.new("floating")
		parbox:attribute_set("width", "100%fw")
		local figureBlock = parbox:new_child("figure")
		local img = figureBlock:new_child("img")
		local src = figure:attribute("src")
		if string.match(src, "%.svg$") then
			local pdf = string.gsub(src, "%.svg$", ".pdf")
			if file_exists(pdf) then
				src = pdf
			else
				img.kind = "svg"
			end
		end
		img:attribute_set("src", src)
		img:attribute_set("width", "100%fw")
		local caption = figureBlock:new_child("caption")
		if figure:has_attribute("label") then
			caption:attribute_set("label", figure:attribute("label"))
		end
		caption:take_children(figure)
		return { parbox }
	end)
	return textTree
end
