function process(textTree)
	local builder = LuaTextBuilder.new()
	textTree:match("lua", function(lua)
		return {TextTree.new("code"):take_children(builder:process_string(lua:text(), ""))}
	end)
	textTree:match("rego", function(lua)
		return {TextTree.new("code"):take_children(builder:process_string(lua:text(), ""))}
	end)
	return textTree
end
