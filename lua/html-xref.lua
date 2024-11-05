

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
			xrefTargets[label] = {node = captionNode, captionPrefix = captionPrefix}
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
				return {textTree}
			end
			local linkNode = TextTree.new("a")
			linkNode:attribute_set("href", "#" .. targetName)
			linkNode:append_text(target.captionPrefix)
			-- Append all of the children of the target node.  This lets us
			-- handle captions that include other markup.
			linkNode:take_children(target.node:deep_clone())
			return {linkNode}
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

