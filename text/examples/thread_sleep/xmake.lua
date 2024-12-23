-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

-- An single compartment for this example.
compartment("current")
	add_files("current.cc")


-- firmware#begin
-- Firmware image for the example.
firmware("current_thread")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio")
	-- Our compartments
	add_deps("current")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- threads#begin
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "current",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 2
			},
			{
				compartment = "current",
				priority = 2,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
		-- threads#end
	end)
-- firmware#end
