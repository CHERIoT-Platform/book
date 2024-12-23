-- Copyright CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT Error Handling")
sdkdir = os.getenv("CHERIOT_SDK") or "../../../rtos-source/sdk/"
includes(sdkdir)
set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

compartment("errors")
	-- memcpy
	add_deps("freestanding", "debug", "unwind_error_handler")
	add_files("errors.cc")

-- Firmware image for the example.
firmware("error_handling")
	add_deps("errors")
	on_load(function(target)
		target:values_set("board", "$(board)")
		target:values_set("threads", {
			{
				compartment = "errors",
				priority = 1,
				entry_point = "error_handling",
				stack_size = 0x600,
				trusted_stack_frames = 1
			}
		}, {expand = false})
	end)
