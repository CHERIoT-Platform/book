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
compartment("priority_inheritance")
	add_files("priority_inheritance.cc")


-- firmware#begin
-- Firmware image for the example.
firmware("priority_inheritance_thread")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio")
	-- Our compartments
	add_deps("priority_inheritance")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- threads#begin
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "priority_inheritance",
				priority = 1,
				entry_point = "low",
				stack_size = 0x400,
				trusted_stack_frames = 2
			},
			{
				compartment = "priority_inheritance",
				priority = 2,
				entry_point = "medium",
				stack_size = 0x400,
				trusted_stack_frames = 2
			},
			{
				compartment = "priority_inheritance",
				priority = 3,
				entry_point = "high",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
		-- threads#end
	end)
-- firmware#end
