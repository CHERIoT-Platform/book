local italic = {
	"keyword",
	"textem",
}

local monospace = {
	"command",
	"flag",
	"json",
	"rego",
	"file",
	"c",
	"cxx",
	"reg",
	"lua",
}

function process(textTree)
	--textTree:visit(visit)
	textTree:match_any(italic, function(textTree)
		textTree.kind = "em"
		return { textTree }
	end)
	textTree:match_any(monospace, function(textTree)
		textTree:attribute_set("class", textTree.kind)
		textTree.kind = "span"
		return { textTree }
	end)
	return textTree
end
