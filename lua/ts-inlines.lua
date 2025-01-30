function process(textTree)
	local luaBuilder = LuaTextBuilder.new()
	local regoBuilder = RegoTextBuilder.new()
	textTree:match("lua", function(lua)
		return luaBuilder:process_string(lua:text(), ""):extract_children()
	end)
	textTree:match("rego", function(rego)
		return regoBuilder:process_string(rego:text(), ""):extract_children()
	end)
	return textTree
end
