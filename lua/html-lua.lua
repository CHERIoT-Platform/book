function visit(tree)
	if type(tree) ~= "string" then
		if tree.kind == "cxxsnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "jsonsnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "luasnippet" then
			tree:attribute_set("class", "listing-code")
			tree.kind = "pre"
		elseif tree.kind == "lualisting" then
			tree.kind = "pre"
			tree:attribute_set("class", "listing-code")
			tree:append_text("FIXME: Lua listings not implemented yet")
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
