function process(textTree)
	textTree:match_any({"if", "else"}, function(ifNode)
		local attributes = ifNode:attributes()
		if #attributes ~= 1 then
			ifNode:error("if and else nodes must have exactly one attribute")
			return {}
		end
		local condition = false
		for k,v in pairs(attributes) do
			local configValue = config[k]
			if v and v ~= "" then
				if v == configValue then
					condition = true
				end
			end
			if configValue then
				condition = true
			end
		end
		if ifNode.kind == "else" then
			condition = not condition
		end
		if condition then
			return ifNode:extract_children();
		end
		return {}
	end)
	return textTree
end
