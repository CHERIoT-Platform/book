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
	textTree:match_any({ "h1", "h2", "h3", "h4", "p", "pre" }, function(heading)
		if heading:has_attribute("number") then
			if string.sub(heading.kind, 1, 1) == "h" then
				heading:insert_text(1, heading:attribute("number") .. ". ", 1)
			end
			heading:attribute_erase("number")
		end
		-- FIXME: Ideally, the HTML output would skip numbering for these.
		heading:attribute_erase("numbering")
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
		local nestedSVGName = string.gsub(src, "(.*/)(.*%.svg)$", "%1%2/%2")
		local nestedSVG = (nestedSVGName ~= src) and file_exists(nestedSVGName)
		if nestedSVG then
			src = nestedSVGName
		end

		-- SVG images that load other things need special handling because
		-- modern web specs are a mess of legacy nonsense.  At least here the
		-- major browsers are consistent: The source for img must be able to be
		-- fetched by a single HTTP request.  Unfortunately, alt and aria-label
		-- are not well supported in browsers, so this is not wonderful for
		-- accessibility.
		if nestedSVG then
			img.kind = "object"
			img:attribute_set("data", src)
			img:attribute_set("type", "image/svg+xml")
			img:append_text(figure:attribute("alt"))
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
	-- Tabular is left over from SILE-style tables.
	textTree:match("tabular", function(tabular)
		return tabular:extract_children()
	end)

	-- Tables must have the caption as their first child.
	textTree:match("table", function(tableTree)
		-- Find a caption and pull it out
		local caption = nil
		tableTree:match("caption", function(c)
			caption = c
			return {}
		end)
		-- If we found one, pop it back in as the first child
		if caption then
			table.insert(tableTree.children, 1, caption)
		end
		return { tableTree }
	end)

	-- Remove empty <p>, <span> and <div> tags.
	local changed = false
	repeat
		changed = false
		function deleteEmpty(node)
			node:match_any({ "p", "span", "div" }, deleteEmpty)
			if #node.children == 0 then
				changed = true
				return {}
			end
			return { node }
		end
		textTree:match_any({ "p", "span", "div" }, deleteEmpty)
	until changed == false
	return textTree
end
