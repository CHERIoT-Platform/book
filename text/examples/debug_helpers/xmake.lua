-- Copyright CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
	set_default("sail")

-- debug_option#begin
debugOption("debug_compartment")
-- debug_option#end

-- use_debug#begin
compartment("debug_compartment")
	add_rules("cheriot.component-debug")
	add_deps("unwind_error_handler")
	add_files("example.cc", "example.c")
-- use_debug#end
-- Explicitly setting the debug option name is not necessary
-- here because it matches the compartment name, but if we
-- did it explicitly then it would look like this:
-- set_debug_option#begin
	on_load(function (target)
		target:set('cheriot.debug-name', "debug_compartment")
	end)
-- set_debug_option#end



-- firmware#begin
-- Firmware image for the example.
firmware("debug_example")
	-- RTOS-provided libraries
	add_deps("freestanding", "debug", "string", "stdio")
	-- Our compartments
	add_deps("debug_compartment")
	on_load(function(target)
		-- The board to target
		target:values_set("board", "$(board)")
		-- Threads to select
		target:values_set("threads", {
			{
				compartment = "debug_compartment",
				priority = 1,
				entry_point = "entry",
				stack_size = 0x800,
				trusted_stack_frames = 3
			}
		}, {expand = false})
	end)
-- firmware#end
