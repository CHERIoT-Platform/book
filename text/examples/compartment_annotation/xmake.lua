-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

-- compartment#begin
-- An example compartment that we can call
compartment("example_compartment")
	add_files("compartment.cc")
-- compartment#end

-- Our entry-point compartment
compartment("entry")
	add_files("entry.cc")

-- Firmware image for the example.
firmware("compartment_annotation")
	-- RTOS-provided libraries
	add_deps("freestanding", "stdio")
	-- Our compartments
	add_deps("entry", "example_compartment")
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
