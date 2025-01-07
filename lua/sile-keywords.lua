local italic = {
	"keyword",
	"textem",
}

local monospace = {
	"command",
	"flag",
	"json",
	"file",
	"tty",
	"rego",
	"c",
	"cxx",
	"lua",
	"output",
	"library",
	"compartment",
	"host",
}

local bold = {
	"command",
}

function process(textTree)
	textTree:match("keyword", function(textTree)
		local index = TextTree.new("indexentry")
		index:append_text(textTree:text())
		textTree.kind = "font"
		textTree:attribute_set("style", "italic")
		return { index, textTree }
	end)
	textTree:match_any(italic, function(textTree)
		textTree.kind = "font"
		textTree:attribute_set("style", "italic")
		return { textTree }
	end)
	textTree:match_any(monospace, function(textTree)
		if bold[textTree.kind] then
			textTree:attribute_set("weight", "700")
		end
		textTree.kind = "font"
		textTree:attribute_set("family", "Hack")
		textTree:attribute_set("size", "0.8em")
		return { textTree }
	end)
	textTree:match("reg", function(textTree)
		textTree.kind = "font"
		textTree:attribute_set("family", "Hack")
		textTree:attribute_set("size", "0.8em")
		textTree:attribute_set("variant", "smallcaps")
		return { textTree }
	end)

	return textTree
end
