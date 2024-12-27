-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

-- An example compartment that we can call
compartment("compartment")
	add_files("compartment.cc")

-- An example compartment that we can call
library("library")
	add_files("library.cc")

-- Our entry-point compartment
compartment("entry")
	add_files("entry.cc")

-- Firmware image for the example.
firmware("library_or_compartment")
	-- RTOS-provided libraries
	add_deps("freestanding", "debug")
	-- Our compartments
	add_deps("entry", "compartment", "library")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "entry",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x600,
				trusted_stack_frames = 4
			}
		}, {expand = false})
	end)
