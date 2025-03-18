function process(textTree)
	local comments = 0
	textTree:match_any({ "phil", "hugo", "amanda" }, function(review)
		comments = comments + 1
		review:error("Remaining review comment")
		if not config.review then
			return {}
		end
		table.insert(review.children, 1, "[ ")
		review:append_text(" - " .. review.kind .. " ]")
		if config.output == "sile" then
			review.kind = "color"
			review:attribute_set("color", "blue")
		else
			review.kind = "span"
			review:attribute_set("class", "review")
		end
		return { review }
	end)
	print("Document contains " .. tostring(comments) .. " unaddressed review comments")
	return textTree
end
