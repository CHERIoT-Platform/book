local xrefTargets = {}

function findLabels(textTree)
	if type(textTree) ~= "string" then
		if textTree:has_attribute("label") then
			local label = textTree:attribute("label")
			if label == "" then
				textTree:error("Empty label")
				textTree:dump()
				return {textTree}
			end
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
			if textTree.kind == "p" and textTree:has_attribute("class") and (textTree:attribute("class") == "listing-caption") then
				captionPrefix = "Listing"
				captionNode = TextTree.new()
			else
				captionPrefix = objectNode.kind:gsub("^%l", string.upper);
			end
			if objectNode:has_attribute("number") then
				captionPrefix = captionPrefix .. " " .. objectNode:attribute("number")
				if #captionNode.children > 0 then
					captionPrefix = captionPrefix .. ". "
				end
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
				textTree:dump()
				return {textTree}
			end
			local linkNode = TextTree.new("a")
			linkNode:attribute_set("href", "#" .. targetName)
			linkNode:append_text(target.captionPrefix)
			-- Append all of the children of the target node.  This lets us
			-- handle captions that include other markup.
			linkNode:take_children(target.node:deep_clone())
			local caption = linkNode.children
			if type(caption[#caption]) == "string" then
				local captionEndText = caption[#caption]
				captionEndText = string.gsub(captionEndText, "%.?%s*$", "")
				caption[#caption] = captionEndText
			end
			return {linkNode}
		else
			textTree:visit(resolveXrefs)
		end
	end
	return {textTree}
end


function process(textTree)
	textTree:visit(findLabels)
	textTree:visit(resolveXrefs)
	return textTree
end


