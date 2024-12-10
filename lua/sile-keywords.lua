local italic = {
	"keyword",
	"textem",
}

local monospace = {
	"command",
	"flag",
	"json",
	"file",
	"rego",
	"c",
	"cxx",
	"lua",
}

function process(textTree)
	textTree:match_any(italic, function(textTree)
		textTree.kind = "font"
		textTree:attribute_set("style", "italic")
		return { textTree }
	end)
	textTree:match_any(monospace, function(textTree)
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
