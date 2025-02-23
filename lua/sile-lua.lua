local snippets = {
	"cxxsnippet",
	"luasnippet",
	"console",
	"asmsnippet",
	"regosnippet",
	"jsonsnippet",
}

function visit(tree)
	tree.kind = "verbatim"
	return {tree}
end

function process(textTree)
	textTree:match_any(snippets, visit)
	return textTree
end
