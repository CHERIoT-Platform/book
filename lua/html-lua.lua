function visit(tree)
	if type(tree) ~= "string" then
		if tree.kind == "luasnippet" then
			tree.kind = "pre"
		elseif tree.kind == "lualisting" then
			tree.kind = "pre"
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