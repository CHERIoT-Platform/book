local base = require("packages.base")

-- The floating command is a thin wrapper around parbox that sets a moveable
-- flag on the result.  This is a hack, but it works.
local parboxPackage = require("packages.parbox")

local package = pl.class(base)

package._name = "toyfloat"

-- Helper to print log messages for this package
function log(...)
	local args = { ... }
	SU.debug("toyfloat", unpack(args))
end

-- Results for calculating glue size
local GlueResult = {
	-- Result is fine within the constraints
	Valid = 0,
	-- Result is under full, glue cannot be extended to make it the right length
	Underfull = 1,
	-- Result is over full, glue cannot be shrunk to make it the right length
	Overfull = 2,
}

-- Calculate the glue size.  This returns the adjustment that will need to be
-- applied to glue to make it fit (can be positive or negative) and whether
-- this overflows as a GlueResult value.
--
-- This is the same calculation as setVerticalGlue but without the side effects.
function calculateGlueSize(pageNodeList, target)
	local totalHeight = SILE.types.length()
	local gTotal = SILE.types.length()
	local pastTop = false
	for _, node in ipairs(pageNodeList) do
		if not pastTop and not node.discardable and not node.explicit then
			-- "Ignore discardable and explicit glues at the top of a frame."
			-- See typesetter:outputLinesToPage()
			-- Note the test here doesn't check is_vglue, so will skip other
			-- discardable nodes (e.g. penalties), but it shouldn't matter
			-- for the type of computing performed here.
			pastTop = true
		end
		if pastTop then
			if not node.is_insertion then
				totalHeight:___add(node.height)
				totalHeight:___add(node.depth)
			end
			if node.is_vglue then
				gTotal:___add(node.height)
			end
		end
	end

	local adjustment = target - totalHeight
	local result = GlueResult.Valid
	if adjustment:tonumber() > 0 then
		if adjustment > gTotal.stretch then
			if
				(adjustment - gTotal.stretch):tonumber() > SILE.settings:get("typesetter.underfulltolerance"):tonumber()
			then
				result = GlueResult.Underfull
			end
		end
	elseif adjustment:tonumber() < 0 then
		adjustment = 0 - adjustment
		if adjustment > gTotal.shrink then
			if
				(adjustment - gTotal.shrink):tonumber() > SILE.settings:get("typesetter.overfulltolerance"):tonumber()
			then
				result = GlueResult.Overfull
			end
		end
	end
	return adjustment:tonumber(), result
end

-- This is mostly copied from sile/typesetters/base.lua.
-- It could be refactored if there were a hook that let you discard the
-- best-fit page and try again.
function tryBuildPage(self)
	local pageNodeList
	local res
	if self:isQueueEmpty() then
		return false, nil
	end
	if SILE.scratch.insertions then
		SILE.scratch.insertions.thisPage = {}
	end
	local vboxlist = pl.tablex.copy(self.state.outputQueue)
	local initialEntries = #vboxlist
	-- Run the page builder on a copy of the output queue.  Th means that any
	-- side effects that mutate vboxes will still occur, which is unfortunate,
	-- but fixing this requires refactoring the interface with the page
	-- builder.
	pageNodeList, res = SILE.pagebuilder:findBestBreak({
		vboxlist = vboxlist,
		target = self:getTargetLength(),
		restart = self.frame.state.pageRestart,
	})
	if not pageNodeList then -- No break yet
		-- TODO: These hooks are now run multiple times, it's not clear if
		-- that's a bad thing (I believe they were anyway).
		self:runHooks("noframebreak")
		return false, nil, 0
	end
	self.state.lastPenalty = res
	self.frame.state.pageRestart = nil
	return true, pageNodeList, initialEntries - #vboxlist
end

-- Helper to see if a frame is moveable (floating).  Ideally this would
function isMoveable(vbox)
	if vbox.nodes then
		for _, v in ipairs(vbox.nodes) do
			if v.moveable then
				log("Found movable vbox:", vbox)
				return true
			end
		end
	end
	return false
end

function buildPage(self)
	--log("Output queue before tryBuildPage", #self.state.outputQueue)
	local res, pageNodeList, consumed = tryBuildPage(self)
	if not res then
		return false
	end
	local adjustment, result = calculateGlueSize(pageNodeList, self:getTargetLength())

	log("Adjustment: ", adjustment, " result: ", result)

	-- Use the current result, or a better one if we have seen one while trying
	-- to rejig the queue and reset state.
	local function finish()
		-- Anything that we've moved goes back on the front of the queue
		local moveState = self.state.movefloatstate
		if self.state.movefloatstate then
			if math.abs(adjustment) > moveState.bestPenalty then
				log("Moving floats made things worse, resetting to a previous queue state")
			else
				log("Moving floats improved layout, had ", moveState.bestPenalty, " now have ", adjustment)
			end
		end
		-- Redo the break calculation, this time with the real output queue
		pageNodeList, res = SILE.pagebuilder:findBestBreak({
			vboxlist = self.state.outputQueue,
			target = self:getTargetLength(),
			restart = self.frame.state.pageRestart,
		})
		pageNodeList = self:runHooks("framebreak", pageNodeList)
		self:setVerticalGlue(pageNodeList, self:getTargetLength())
		self:outputLinesToPage(pageNodeList)
		-- FIXME: This is not reinserting things.
		if moveState then
			local start = 1
			for _, v in ipairs(moveState.moved) do
				-- If we moved something but it was not in the range consumed,
				-- put it back where we found it, otherwise put it back at the
				-- start of the output queue.  We will have another go at
				-- moving it later.
				if v.location >= consumed then
					table.insert(self.state.outputQueue, v.location - consumed + start, v.entry)
				else
					table.insert(self.state.outputQueue, start, v.entry)
					start = start + 1
				end
			end
		end
		-- We aren't now moving anything else
		self.state.movefloatstate = nil
	end

	if result ~= GlueResult.Valid then
		local moveState
		if not self.state.movefloatstate then
			moveState = {
				-- What's the smallest glue adjustment that we've found so far?
				bestPenalty = math.abs(adjustment),
				-- How many things were on this list before we got there?
				bestConsumed = consumed,
				-- How many things did we have to move to get there?
				bestMoved = 0,
				-- What were they?
				moved = {},
			}
		else
			moveState = self.state.movefloatstate
			if math.abs(adjustment) < moveState.bestPenalty then
				log(
					"Fallback made things a bit better, had ",
					moveState.bestPenalty,
					" now have ",
					math.abs(adjustment)
				)
				moveState.bestPenalty = math.abs(adjustment)
				moveState.bestConsumed = consumed
				moveState.bestFound = #moveState.moved
			end
		end

		-- Helper function to extract a moveable
		local extractMoveable = function(movedVBoxIndex)
			log("Trying to move", self.state.outputQueue[movedVBoxIndex])

			-- Helper to extract a single vbox from the queue.  Takes the
			-- current location and where it was in the queue before we started
			-- messing with things as arguments.
			--
			-- TODO: I think tablex has a helper that lets us just collect
			-- indexes and do this as a single extract.
			local function moveVBox(currentIndex, originalIndex)
				table.insert(
					moveState.moved,
					{ entry = table.remove(self.state.outputQueue, currentIndex), location = originalIndex }
				)
			end
			-- Move the moveable box.
			moveVBox(movedVBoxIndex, movedVBoxIndex)
			-- If there is any glue after the moved thing, move that as well
			local glue = 1
			while (movedVBoxIndex < #self.state.outputQueue) and self.state.outputQueue[movedVBoxIndex].is_vglue do
				log("Also moving glue (after): ", self.state.outputQueue[movedVBoxIndex])
				moveVBox(movedVBoxIndex, movedVBoxIndex + glue)
				glue = glue + 1
			end

			if movedVBoxIndex < #self.state.outputQueue then
				log("First thing after moved box: ", self.state.outputQueue[movedVBoxIndex])
			end

			-- If there is any glue before the moved thing, also move that.
			glue = -1
			movedVBoxIndex = movedVBoxIndex - 1
			if movedVBoxIndex >= 1 then
				while (movedVBoxIndex < #self.state.outputQueue) and self.state.outputQueue[movedVBoxIndex].is_vglue do
					log("Also moving glue (before): ", self.state.outputQueue[movedVBoxIndex])
					moveVBox(movedVBoxIndex, movedVBoxIndex + glue)
					glue = glue - 1
				end
			end
		end

		-- If we saw an overfull page then we're going to try moving things
		-- forwards.
		if result == GlueResult.Overfull then
			local maybeMoveable = consumed
			-- Skip backwards over glue at the end of the page.
			while (maybeMoveable > 0) and self.state.outputQueue[maybeMoveable].is_vglue do
				maybeMoveable = maybeMoveable - 1
			end
			if not isMoveable(self.state.outputQueue[maybeMoveable]) then
				log("Page is overfull but last item is not moveable", self.state.outputQueue[maybeMoveable])
				finish()
				return true
			end
			extractMoveable(maybeMoveable)
		else
			-- If the page is underfull, try to move things from the next page.
			local maybeMoveable = consumed + 1
			-- Skip forwards over glue at the start of the next page.
			while (maybeMoveable <= #self.state.outputQueue) and self.state.outputQueue[maybeMoveable].is_vglue do
				maybeMoveable = maybeMoveable + 1
			end
			if maybeMoveable < #self.state.outputQueue then
				if not isMoveable(self.state.outputQueue[maybeMoveable]) then
					log("Page is underfull but next item is not moveable", self.state.outputQueue[maybeMoveable])
					finish()
					return true
				end
				extractMoveable(maybeMoveable)
			end
		end
		self.state.movefloatstate = moveState
		return false
	end
	finish()
	return true
end

function package:_init(options)
	base._init(self)
	-- Hook into the type setter and replace the build-page logic.
	SILE.typesetter.buildPage = buildPage
end

function package:registerCommands()
	-- Hacky \floating command.  Just wraps a parbox and sets a flag on the ouput.
	self:registerCommand("floating", function(options, content)
		local parbox, hlist = parboxPackage:makeParbox(options, content)
		parbox.moveable = true
		SILE.typesetter:pushHbox(parbox)
		for _, h in ipairs(hlist) do
			SILE.typesetter:pushHorizontal(h)
		end
		return parbox
	end)
end

return package
