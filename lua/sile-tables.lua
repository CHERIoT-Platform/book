function visit(textTree)
	if type(textTree) ~= "string" then
		if textTree.kind == "table" then
			local parbox = TextTree.new("floating")
			parbox:attribute_set("width", "100%fw")
			parbox:append_child(textTree)
			textTree:visit(visit)
			return {TextTree.new("goodbreak"), parbox}
		elseif textTree.kind == "tabular" then
			textTree.kind = "ptable"
			textTree:attribute_set("cellborder", "0")
			local columns = textTree:attribute("cols")
			if columns == "" then
				local columnCount = 0
				textTree:visit(function(row)
					if columnCount ~= 0 then
						return { row }
					end
					if type(row) ~= "string" then
						if row.kind == "tr" then
							row:visit(function(cell)
								if type(cell) ~= "string" then
									if cell.kind == "th" then
										columnCount = columnCount + 1
									elseif cell.kind == "td" then
										columnCount = columnCount + 1
									end
								end
								return { cell }
							end)
						end
					end
					return { row }
				end)
				columns = ""
				for i = 1, columnCount do
					columns = columns .. tostring(100 / columnCount) .. "%fw "
				end
			end
			textTree:visit(function(row)
				if type(row) ~= "string" then
					if row.kind == "tr" then
						row.kind = "row"
						row:visit(function(cell)
							if type(cell) ~= "string" then
								if cell.kind == "th" then
									cell:attribute_set("border", "0.8pt 0.4pt 0 0")
									cell:attribute_set("halign", "center")
									-- FIXME: Style headings
									cell.kind = "cell"
								elseif cell.kind == "td" then
									cell.kind = "cell"
								else
									return { cell }
								end
								-- Here we know it is some kind of cell
								local noindent = TextTree.new("noindent")
								table.insert(cell.children, 1, noindent)
							end
							return { cell }
						end)
					end
				end
				return { row }
			end)
			textTree:attribute_set("cols", tostring(columns))
		else
			textTree:visit(visit)
		end
	end
	return { textTree }
end

function process(textTree)
	textTree:visit(visit)
	return textTree
end
