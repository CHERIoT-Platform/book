local tableNumber = 1
local listingNumber = 1
local figureNumber = 1
local sectionNumbers = { 0, 0, 0, 0 }
local skipNumberDepth = 9
local depths = {
	chapter = 1,
	section = 2,
	subsection = 3,
	subsubsection = 4,
}

function visit(textTree)
	if type(textTree) ~= "string" then
		if textTree.kind == "table" then
			textTree:attribute_set("number", tostring(tableNumber))
			tableNumber = tableNumber + 1
		end
		if textTree.kind == "code" and textTree:has_attribute("caption") then
			textTree:attribute_set("number", tostring(listingNumber))
			listingNumber = listingNumber + 1
		end
		if textTree.kind == "figure" then
			textTree:attribute_set("number", tostring(figureNumber))
			figureNumber = figureNumber + 1
		end
		local depth = depths[textTree.kind]
		if depth then
			if textTree:attribute("numbering") == "false" then
				skipNumberDepth = depth + 1
			elseif depth < skipNumberDepth then
				local number = sectionNumbers[depth]
				sectionNumbers[depth] = number + 1
				for i = depth + 1, #sectionNumbers do
					sectionNumbers[i] = 0
				end
				local numberString = ""
				for i = 1, depth do
					numberString = numberString .. sectionNumbers[i] .. "."
				end
				numberString = numberString:sub(1, -2)
				textTree:attribute_set("number", numberString)
				skipNumberDepth = 9
			end
		end
		textTree:visit(visit)
	end
	return { textTree }
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
