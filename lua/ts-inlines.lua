function process(textTree)
	local luaBuilder = LuaTextBuilder.new()
	local regoBuilder = RegoTextBuilder.new()
	textTree:match("lua", function(lua)
		return luaBuilder:process_string(lua:text(), ""):extract_children()
	end)
	-- The tree sitter rego plugin generates nonsense for incomplete parses, so
	-- give up on it for now.
	--textTree:match("rego", function(rego)
	--	return regoBuilder:process_string(rego:text(), ""):extract_children()
	--end)
	return textTree
end
