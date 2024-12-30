-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

-- uart#begin
-- An example compartment that we can call
compartment("uart")
	add_files("uart.cc")
	add_deps("unwind_error_handler")
-- uart#end

-- Our entry-point compartment
compartment("hello")
	add_files("hello.cc")

-- Firmware image for the example.
firmware("hello_world")
	-- RTOS-provided libraries
	add_deps("freestanding", "compartment_helpers")
	-- Our compartments
	add_deps("hello", "uart")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "hello",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 2
			}
		}, {expand = false})
	end)
