local base = require("packages.resilient.base")
local package = pl.class(base)
package._name = "listings"

function package:registerStyles()
	self:registerStyle("listing-caption-base-number", {}, {})

	self:registerStyle("listing-caption-main-number", { inherit = "listing-caption-base-number" }, {
		numbering = { before = { text = "Listing " }, after = { text = ".", kern = "iwsp" } },
		font = { features = "+smcp" },
	})
	self:registerStyle("listing-caption-ref-number", { inherit = "listing-caption-base-number" }, {
		numbering = { before = { text = "listing " } },
	})

	self:registerStyle("listing-caption", {}, {
		font = { size = "0.95em" },
		paragraph = {
			before = { indent = false, vbreak = false },
			align = "center",
			after = { skip = "medskip" },
		},
		sectioning = {
			counter = { id = "listing", level = 1 },
			settings = {
				toclevel = 7,
				bookmark = false,
				goodbreak = false,
			},
			numberstyle = {
				main = "listing-caption-main-number",
				reference = "listing-caption-ref-number",
			},
		},
	})
end

function package:_init(options)
	base._init(self)

	self:registerStyles()

	self:registerCommand("listingcaption", function(options, content)
		options.style = "listing-caption"
		SILE.call("sectioning", options, content)
	end, "Listings caption")
end

return package
