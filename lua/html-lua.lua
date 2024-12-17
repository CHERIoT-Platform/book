function visit(tree)
	if type(tree) ~= "string" then
		if tree.kind == "cxxsnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "regosnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "jsonsnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "asmsnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "luasnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "console" then
			tree.kind = "pre"
		elseif tree.kind == "verbatim" then
			tree.kind = "pre"
		else
			tree:visit(visit)
		end
	end
	return { tree }
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
