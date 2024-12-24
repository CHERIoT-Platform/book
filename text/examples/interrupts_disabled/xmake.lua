-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

-- Default the board to a cycle-accurate simulator.
option("board")
	set_default("ibex-safe-simulator")

-- An single compartment for this example.
compartment("interrupts")
	add_files("interrupts.cc")


-- firmware#begin
-- Firmware image for the example.
firmware("interrupts_disabled")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio", "debug")
	-- Our compartments
	add_deps("interrupts")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- threads#begin
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "interrupts",
				priority = 1,
				entry_point = "low",
				stack_size = 0x400,
				trusted_stack_frames = 2
			},
			{
				compartment = "interrupts",
				priority = 2,
				entry_point = "high",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
		-- threads#end
	end)
-- firmware#end
