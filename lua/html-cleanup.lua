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
		local src = figure:attribute("src")
		-- SVGs may include other files.  Some of the SVGs are actually
		-- directories, look for the real file inside.
		local nestedSVG = string.gsub(src, "(.*/)(.*%.svg)$", "%1%2/%2")
		if file_exists(nestedSVG) then
			src = nestedSVG
		end

		-- SVG images need special handling because modern web specs are a
		-- mess.  At least here the major browsers are consistently weird.
		if string.match(src, "%.svg$") then
			img.kind = "object"
			img:attribute_set("data", src)
			img:attribute_set("type", "image/svg+xml")
			img:attribute_set("aria-label", figure:attribute("alt"))
		else
			img:attribute_set("src", src)
			img:attribute_set("alt", figure:attribute("alt"))
		end

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
