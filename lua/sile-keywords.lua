local italic = {
	"keyword",
	"textem",
}

local monospace = {
	"command",
	"flag",
	"json",
	"file",
	"c",
	"cxx",
	"lua",
}

function process(textTree)
	--textTree:visit(visit)
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

	return textTree
end
