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

-- firmware#begin
-- The safebox compartment
compartment("safebox")
	add_files("safebox.cc")

compartment("runner")
	add_files("runner.cc")

-- Firmware image for the example.
firmware("safebox_example")
	-- RTOS-provided libraries
	add_deps("freestanding", "cxxrt", "debug")
	-- Our compartments
	add_deps("runner", "safebox")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		target:values_set("threads", {
			{
				compartment = "runner",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 2
			},
		}, {expand = false})
	end)
-- firmware#end
