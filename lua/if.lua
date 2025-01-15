function visitConditional(ifNode)
	ifNode:match_any({"if", "else"}, visitConditional)
	local attributes = ifNode:attributes()
	if #attributes ~= 1 then
		ifNode:error("if and else nodes must have exactly one attribute")
		return {}
	end
	local condition = false
	for k,v in pairs(attributes) do
		local configValue = config[k]
		print("Config value:", k, configValue)
		if v and v ~= "" then
			if v == configValue then
				condition = true
			end
		end
	end
	if ifNode.kind == "else" then
		condition = not condition
	end
	if condition then
		print("Treating as true:")
		ifNode:dump()
		return ifNode:extract_children();
	end
		print("Treating as false:")
		ifNode:dump()
	return {}
end

function process(textTree)
	textTree:match_any({"if", "else"}, visitConditional)
	return textTree
end
