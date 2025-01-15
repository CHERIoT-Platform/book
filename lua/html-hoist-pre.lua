local singleNodes = {
	pre = true,
	ul = true,
	ol = true,
	dl = true,
	div = true,
	table = true,
}

function cleanRedundantP(p)
	local singleChild = nil
	local replace = true;
	p:visit(function(child)
		if type(child) == "string" then
			local nonEmpty = child:gsub("%s+", "")
			if #nonEmpty > 0 then
				replace = false
			end
		else
			child:match("p", cleanRedundantP)
			if singleNodes[child.kind] and singleChild == nil then
				singleChild = child
			else
				replace = false;
			end
		end
		return {child}
	end)
	return replace and {singleChild} or {p}
end

function process(textTree)
	textTree:match("p", cleanRedundantP)
	return textTree
end
