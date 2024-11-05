
function visit(textTree)
	if type(textTree) ~= "string" then
		if (textTree.kind == "textem") then
			textTree.kind = "em"
		end
		textTree:visit(visit)
	end
	return {textTree}
end


function process(textTree)
	textTree:visit(visit)
	return textTree
end

