-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

-- library#begin
-- An example library that we can call
library("example_library")
	add_files("library.cc")
-- library#end

-- Our entry-point compartment
compartment("entry")
	add_files("entry.cc")

-- Firmware image for the example.
firmware("library_example")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio", "debug")
	-- Our compartments
	add_deps("entry", "example_library")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "entry",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
	end)
