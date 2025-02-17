-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

-- Our entry-point compartment
compartment("raw_uart")
	add_files("raw_uart.cc")
-- compartments#end

-- firmware#begin
-- Firmware image for the example.
firmware("hello_uart")
	-- RTOS-provided libraries
	add_deps("freestanding")
	-- Our compartments
	add_deps("raw_uart")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "raw_uart",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x400,
				trusted_stack_frames = 1
			}
		}, {expand = false})
	end)
-- firmware#end
