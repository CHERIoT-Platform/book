

local xrefTargets = {}

function findLabels(textTree)
	if type(textTree) ~= "string" then
		if textTree:has_attribute("label") then
			local label = textTree:attribute("label")
			if xrefTargets[label] then
				textTree:error("Duplicate label: " .. label)
				xrefTargets[label].node:error("Previous occurrence was: ")
				return {textTree}
			end
			-- Capitalise the first letter of the node kind.
			local captionPrefix = ""
			local captionNode = textTree
			local objectNode = textTree
			if textTree.kind == "caption" then
				objectNode = textTree:parent()
			end
			captionPrefix = objectNode.kind:gsub("^%l", string.upper);
			if objectNode:has_attribute("number") then
				captionPrefix = captionPrefix .. " " .. objectNode:attribute("number") .. ". "
			end
			textTree:attribute_erase("label")
			local labelNode = TextTree.new("label")
			labelNode:attribute_set("marker", label)
			table.insert(textTree.children, 1, labelNode)
			xrefTargets[label] = {node = labelNode, captionPrefix = captionPrefix}
		end
		textTree:visit(findLabels)
	end
	return {textTree}
end

function resolveXrefs(textTree)
	if type(textTree) ~= "string" then
		if textTree.kind == "ref" then
			local targetName = textTree.children[1]
			local target = xrefTargets[targetName]
			if not target then
				textTree:error("Unknown label: " .. targetName)
			end
			textTree:attribute_set("marker", targetName)
			textTree:attribute_set("type", "section")
			textTree:extract_children()
		else
			textTree:visit(resolveXrefs)
		end
	end
	return {textTree}
end


function process(textTree)
	print("Collecting link targets")
	textTree:visit(findLabels)
	print("Resolving cross references")
	textTree:visit(resolveXrefs)
	return textTree
end
