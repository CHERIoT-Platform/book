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

	local figures = {}
	-- Run the passes to generate the final output
	for _, chapter in pairs(chapters) do
		local tinyTOC = TextTree.new("ul")
		local root
		if config.epub then
			root = TextTree.create({
				kind = "div",
				attributes = {
					class = "body",
				},
				children = {
					{
						kind = "div",
						attributes = {
							class = "content",
						},
						children = { chapter.root },
					},
				},
			})
		else
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
			root = TextTree.create({
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
		end
		root = create_pass("html-headings"):process(root)
		root = create_pass("html-boilerplate"):process(root)
		root = create_pass("clean-empty"):process(root)
		root = create_pass("html-hoist-pre"):process(root)
		root = create_pass("html-href"):process(root)
		root = create_pass("html-cleanup"):process(root)
		root = create_pass("html-label-id"):process(root)
		root = create_pass("html-hoist-pre"):process(root)
		if config.epub then
			root:attribute_set("xmlns", "http://www.w3.org/1999/xhtml")
			root:attribute_set("xmlns:epub", "http://www.idpf.org/2007/ops")
			root:match("img", function(img)
				table.insert(figures, img:attribute("src"))
				return { img }
			end)
			root:match("object", function(img)
				table.insert(figures, img:attribute("data"))
				return { img }
			end)
		end
		local out = create_pass(config.epub and "XMLOutputPass" or "HTMLOutputPass"):as_output_pass()
		if root then
			print("Writing " .. chapter.file)
			local directory = config.output_directory or "."
			if config.epub then
				directory = directory .. "/EPUB"
			end
			out:output_file(directory .. "/" .. chapter.file)
			out:process(root)
		end
	end
	if config.epub then
		local toc = TextTree.new("ol")
		toc:attribute_set("class", "epub-toc")
		for _, chapterForToC in pairs(chapters) do
			local li = toc:new_child("li")
			local a = li:new_child("a")
			a:attribute_set("href", chapterForToC.file)
			if chapterForToC.number == "" then
				a:append_text(chapterForToC.name)
			else
				a:append_text(chapterForToC.number .. ". " .. chapterForToC.name)
			end
			local sections = chapterForToC.sections:deep_clone()
			sections.kind = "ol"
			sections:match("a", function(a)
				a:attribute_set("href", chapterForToC.file .. a:attribute("href"))
				return { a }
			end)
			if #sections.children > 0 then
				li:append_child(sections)
			end
		end

		local tocDocument = TextTree.create({
			kind = "html",
			attributes = {
				xmlns = "http://www.w3.org/1999/xhtml",
				["xmlns:epub"] = "http://www.idpf.org/2007/ops",
			},
			children = {
				{
					kind = "head",
					children = {
						{
							kind = "title",
							children = { config.title },
						},
						{
							kind = "link",
							attributes = {
								rel = "stylesheet",
								href = "book.css",
								type = "text/css",
							},
						},
						{
							kind = "meta",
							attributes = {
								charset = "utf-8",
							},
						},
					},
				},
				{
					kind = "body",
					children = {
						{
							kind = "section",
							children = {
								{
									kind = "h1",
									children = { "Contents" },
								},
								{
									kind = "nav",
								attributes = {
									["xmlns:epub"] = "http://www.idpf.org/2007/ops",
									["epub:type"] = "toc",
									id = "toc",
								},
								children = {toc}
								},
							},
						},
					},
				},
			},
		})

		local out = create_pass("XMLOutputPass"):as_output_pass()
		config.DTD = '<?xml version="1.0" encoding="UTF-8" ?>'
		local root = config.output_directory or "."

		out:output_file(root .. "/EPUB/contents.xhtml")
		out:process(tocDocument)

		local mimetype = io.open(root .. "/mimetype", "w")
		mimetype:write("application/epub+zip")
		mimetype:close()
		local contents = TextTree.create({
			kind = "container",
			attributes = {
				version = "1.0",
				xmlns = "urn:oasis:names:tc:opendocument:xmlns:container",
			},
			children = {
				{
					kind = "rootfiles",
					children = {
						{
							kind = "rootfile",
							attributes = {
								["full-path"] = "EPUB/contents.opf",
								["media-type"] = "application/oebps-package+xml",
							},
						},
					},
				},
			},
		})
		out:output_file(root .. "/META-INF/container.xml")
		out:process(contents)
		local package = TextTree.create({
			kind = "package",
			attributes = {

				xmlns = "http://www.idpf.org/2007/opf",
				version = "3.0",
				["xml:lang"] = "en",
				["unique-identifier"] = "pub-id",
				prefix = "cc: http://creativecommons.org/ns#",
			},
		})
		local metadata = package:new_child("metadata")
		metadata:attribute_set("xmlns:dc", "http://purl.org/dc/elements/1.1/")
		local addMetadata = function(name, text, attributes)
			if (not attributes) and (type(text) ~= "string") then
				attributes = text
				text = nil
			end
			local child = metadata:new_child(name)
			if text then
				child:append_text(text)
			end
			for k, v in pairs(attributes or {}) do
				child:attribute_set(k, v)
			end
		end
		addMetadata("dc:title", config.title)
		addMetadata("dc:language", config.language)
		addMetadata("dc:creator", config.author)
		addMetadata("dc:identifier", "org.cheriot.programmers-handbook", { id = "pub-id" })
		addMetadata("meta", os.date("%Y-%m-%dT%H:%M:%SZ"), { property = "dcterms:modified" })
		local manifest = package:new_child("manifest")
		local addManifest = function(id, href, media, properties)
			local item = manifest:new_child("item")
			id = string.gsub(id, "[^%a%d]", "")
			item:attribute_set("id", id)
			item:attribute_set("href", href)
			item:attribute_set("media-type", media)
			if properties then
				item:attribute_set("properties", properties)
			end
		end
		addManifest("style", "book.css", "text/css")
		for _, img in ipairs(figures) do
			local mimes = {
				jpg = "image/jpeg",
				svg = "image/svg+xml",
				png = "image/png",
			}
			local _, _, extension = string.find(img, "%.([^%.]*)$")
			addManifest(img, img, mimes[extension])
		end

		-- FIXME: Hack
		addManifest("hughimg1", "figures/HughDisplay.svg/image1.jpg", "image/jpeg")
		addManifest("hughimg2", "figures/HughDisplay.svg/image2.jpg", "image/jpeg")

		-- TODO: Fonts
		addManifest("nav", "contents.xhtml", "application/xhtml+xml", "nav")
		for _, chapter in pairs(chapters) do
			addManifest(chapter.name, chapter.file, "application/xhtml+xml")
		end
		addManifest("cover", "Cover.jpg", "image/jpeg", "cover-image")

		local spine = package:new_child("spine")
		local addSpine = function(id, linear)
			local item = spine:new_child("itemref")
			id = string.gsub(id, "[^%a]", "")
			item:attribute_set("idref", id)
			item:attribute_set("linear", linear or "yes")
		end
		--addSpine("cover", "no")
		for _, chapter in pairs(chapters) do
			addSpine(chapter.name)
		end

		out:output_file(root .. "/EPUB/contents.opf")
		out:process(package)
	end
	return TextTree.new()
end
