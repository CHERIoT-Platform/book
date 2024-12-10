
function visit(tree)
	if type(tree) ~= 'string' then
		if tree.kind == 'cxxsnippet' then
			tree.kind = 'verbatim'
		elseif tree.kind == 'luasnippet' then
			tree.kind = 'verbatim'
		elseif tree.kind == 'console' then
			tree.kind = 'verbatim'
		elseif tree.kind == 'regosnippet' then
			tree.kind = 'verbatim'
		elseif tree.kind == 'jsonsnippet' then
			tree.kind = 'verbatim'
		elseif tree.kind == 'lualisting' then
			tree.kind = 'verbatim'
			tree:append_text("FIXME: Lua listings not implemented yet")
		else
			tree:visit(visit)
		end
	end
	return {tree}
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
