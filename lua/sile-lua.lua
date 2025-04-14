local snippets = {
	"cxxsnippet",
	"luasnippet",
	"console",
	"asmsnippet",
	"regosnippet",
	"jsonsnippet",
}

function visit(tree)
	--local center = TextTree.new("center")
	--local parbox = center:new_child("parbox")
	local parbox = TextTree.new("parbox")
	parbox:attribute_set("width", "100%fw")
	parbox:attribute_set("valign", "middle")
	parbox:attribute_set("minimize", "true")
	parbox:append_child(tree)
	tree.kind = "verbatim"
	return {TextTree.new("noindent"), parbox}
end

function process(textTree)
	textTree:match_any(snippets, visit)
	return textTree
end
