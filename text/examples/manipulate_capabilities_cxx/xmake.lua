-- Copyright CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

compartment("example")
	add_files("example.cc")

-- firmware#begin
-- Firmware image for the example.
firmware("hello_world")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio")
	-- Our compartments
	add_deps("example")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "example",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
	end)
-- firmware#end
