

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
			local objectNode = textTree
			if textTree.kind == "caption" then
				objectNode = textTree:parent()
			end
			captionPrefix = objectNode.kind:gsub("^%l", string.upper);
			textTree:attribute_erase("label")
			local labelNode = TextTree.new("label")
			labelNode:attribute_set("marker", label)
			table.insert(textTree.children, 1, labelNode)
			xrefTargets[label] = captionPrefix
		elseif textTree:has_attribute("marker") then
			if textTree.kind == "listingcaption" then
				local label = textTree:attribute("marker")
				if xrefTargets[label] then
					textTree:error("Duplicate label: " .. label)
					xrefTargets[label].node:error("Previous occurrence was: ")
					return {textTree}
				end
				xrefTargets[label] = "Listing"
			end
		end
		textTree:visit(findLabels)
	end
	return {textTree}
end

function resolveXrefs(textTree)
	if type(textTree) ~= "string" then
		if textTree.kind == "ref" then
			local targetName = textTree.children[1]
			local targetKind = xrefTargets[targetName]
			if not targetKind then
				textTree:error("Unknown label: " .. targetName)
			end
			textTree:attribute_set("marker", targetName)
			textTree:attribute_set("type", "section")
			textTree:extract_children()
			return {targetKind .. " ", textTree}
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

