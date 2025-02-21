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
compartment("monotonic")
	add_files("monotonic.cc")

-- Our entry-point compartment
compartment("caller")
	add_files("caller.cc")

-- Firmware image for the example.
firmware("software_capability")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio", "atomic8", "debug")
	-- Our compartments
	add_deps("caller", "monotonic")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "caller",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
	end)
