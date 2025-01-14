local fonts = {
	note = "fonts/Twemoji.Mozilla.ttf",
	warning = "fonts/Twemoji.Mozilla.ttf",
	caution = "fonts/NotoEmoji-VariableFont_wght.ttf",
}
local glyphs = {
	note = {
		kind = "font",
		attributes = { size = "3em", filename = "fonts/Twemoji.Mozilla.ttf" },
		children = { "ℹ️ " },
	},
	warning = {
		kind = "font",
		attributes = { size = "3em", filename = "fonts/Twemoji.Mozilla.ttf" },
		children = { "⚠️ " },
	},
	caution = {
		kind = "font",
		attributes = { size = "3em", filename = "fonts/NotoEmoji-VariableFont_wght.ttf" },
		children = {
			{
				kind = "color",
				attributes = { color = "#ff0000" },
				children = { "⚠" },
			},
		},
	},
}
function process(textTree)
	textTree:match_any({ "note", "warning", "caution" }, function(admonition)
		local glyph = glyphs[admonition.kind]
		admonition.kind = "cell"
		local table = TextTree.create({
			kind = "floating",
			attributes = { width = "100%fw" },
			children = {
				{
					kind = "ptable",
					attributes = { cols = "14%fw 86%fw", cellborder = "0" },
					children = {
						{
							kind = "row",
							children = {
								{
									kind = "cell",
									attributes = {
										valign = "center",
										halign = "center",
										border = "0 0 0 0.3pt",
									},
									children = { glyph },
								},
								admonition,
							},
						},
					},
				},
			},
		})
		return { table }
	end)
	return textTree
end
