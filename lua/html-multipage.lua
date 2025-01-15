local chapters = {}
local labelsByFile = {}

function newChapter(name, file)
	return {
		name = name,
		file = file,
		root = TextTree.new(),
		number = "",
		sections = TextTree.new("ul"),
	}
end

local currentChapter = nil
local toc = TextTree.new()

function pushChapter(name, file)
	if currentChapter then
		table.insert(chapters, currentChapter)
	end
	currentChapter = newChapter(name, file)
end

function pushNode(node)
	if currentChapter == nil then
		currentChapter = newChapter("Frontmatter", "index.html")
	end
	currentChapter.root:append_child(node)
end

function collectLabels(textTree)
	if type(textTree) ~= "string" then
		if textTree:has_attribute("label") then
			local label = textTree:attribute("label")
			labelsByFile["#" .. label] = currentChapter.file
		end
		textTree:visit(collectLabels)
	end
	return { textTree }
end

function collectChapters(textTree)
	if type(textTree) ~= "string" then
		if textTree.kind == "chapter" then
			local chapterFile = textTree:source_file_name()
			local _, _, suffix = string.find(chapterFile, ".*%.(.*)")
			-- Remove the source suffix and add .html
			chapterFile = string.sub(chapterFile, 1, #chapterFile - #suffix) .. "html"
			-- Remove path
			chapterFile = string.gsub(chapterFile, ".*/", "")
			pushChapter(textTree:text(), chapterFile)
			if textTree:has_attribute("number") then
				currentChapter.number = textTree:attribute("number")
			end
		elseif textTree.kind == "section" then
			local li = currentChapter.sections:new_child("li")
			local a = li:new_child("a")
			a:attribute_set("href", "#" .. textTree:attribute("label"))
			if textTree:has_attribute("number") then
				a:append_text(textTree:attribute("number") .. ". ")
			end
			a:take_children(textTree:deep_clone())
		end
		collectLabels(textTree)
	end
	pushNode(textTree)
	return {}
end

function process(textTree)
	-- Split out the chapters
	textTree:visit(collectChapters)
	table.insert(chapters, currentChapter)
	currentChapter = nil
	-- Rewrite all links to be to the right file, if they point to a different
	-- file.
	for _, chapter in pairs(chapters) do
		chapter.root:match("a", function(node)
			if node:has_attribute("href") then
				local label = node:attribute("href")
				local labelFile = labelsByFile[label]
				if labelFile ~= chapter.file then
					label = labelFile .. label
					node:attribute_set("href", label)
				end
			end
			return { node }
		end)
	end
	-- Run the passes to generate the final output
	for _, chapter in pairs(chapters) do
		local tinyTOC = TextTree.new("ul")
		for _, chapterForToC in pairs(chapters) do
			local li = tinyTOC:new_child("li")
			local a = li:new_child("a")
			a:attribute_set("href", chapterForToC.file)
			if chapterForToC.number == "" then
				a:append_text(chapterForToC.name)
			else
				a:append_text(chapterForToC.number .. ". " .. chapterForToC.name)
			end
			if chapter == chapterForToC then
				li:append_child(chapter.sections)
			end
		end
		local root = TextTree.create({
			kind = "div",
			attributes = {
				class = "body",
			},
			children = {
				{
					kind = "div",
					attributes = {
						class = "minitoc",
					},
					children = {
						{
							kind = "h1",
							attributes = {
								class = "minitoc",
							},
							children = { "Table of contents" },
						},
						tinyTOC,
					},
				},
				{
					kind = "div",
					attributes = {
						class = "content",
					},
					children = { chapter.root },
				},
			},
		})
		root = create_pass("html-headings"):process(root)
		root = create_pass("html-label-id"):process(root)
		root = create_pass("html-boilerplate"):process(root)
		root = create_pass("clean-empty"):process(root)
		root = create_pass("html-hoist-pre"):process(root)
		root = create_pass("html-href"):process(root)
		root = create_pass("html-cleanup"):process(root)
		root = create_pass("html-hoist-pre"):process(root)
		local out = create_pass("HTMLOutputPass"):as_output_pass()
		if root then
			print("Writing " .. chapter.file)
			local directory = config.output_directory or "."
			out:output_file(directory .. "/" .. chapter.file)
			out:process(root)
		end
	end
	return TextTree.new()
end
