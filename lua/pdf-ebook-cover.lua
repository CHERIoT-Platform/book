function process(textTree)
	if config.print then
		return textTree
	end
	for i, child in ipairs(textTree.children) do
		if child.kind ~= "use" then
			child:dump()
			local cover = TextTree.new("background")
			cover:attribute_set("allpages", "false")
			cover:attribute_set("src", "../cover/Cover-eBook.pdf")
			table.insert(textTree.children, i, TextTree.new("par"))
			table.insert(textTree.children, i, TextTree.new("eject"))
			table.insert(textTree.children, i, cover)
			table.insert(textTree.children, i, TextTree.new("nofolios"))
			return textTree
		end
	end
end
