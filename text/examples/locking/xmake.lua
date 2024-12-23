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
compartment("locking")
	add_files("locking.cc")


-- firmware#begin
-- Firmware image for the example.
firmware("locking_thread")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio")
	-- Our compartments
	add_deps("locking")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- threads#begin
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "locking",
				priority = 1,
				entry_point = "low",
				stack_size = 0x400,
				trusted_stack_frames = 2
			},
			{
				compartment = "locking",
				priority = 2,
				entry_point = "medium",
				stack_size = 0x400,
				trusted_stack_frames = 2
			},
			{
				compartment = "locking",
				priority = 3,
				entry_point = "high",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
		-- threads#end
	end)
-- firmware#end
