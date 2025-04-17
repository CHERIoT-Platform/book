-- Hack to work around incompatibilities between resilient and SILE 0.15.12.
-- This can be removed once silex (resilient's broken dependency) is fixed

require("silex") -- so our base overrides are already enforced
local base = require("classes.base")
SU.debug("silex", "Hacking plain for SILE 0.15.12")
local plain = require("classes.plain")
local function hack (method) -- re-wire inheritance for plain
    local old = plain[method]
    plain[method] = function (self, ...)
        base[method](self, ...)
        old(self, ...)
    end
end
hack("declareOptions")
hack("declareSettings")
hack("registerCommands")
