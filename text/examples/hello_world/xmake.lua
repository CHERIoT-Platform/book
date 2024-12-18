-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

-- boilerplate#begin
set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")
-- boilerplate#end

-- board#begin
option("board")
    set_default("sail")
-- board#end

-- compartments#begin
-- An example compartment that we can call
compartment("example_compartment")
    add_files("compartment.cc")

-- Our entry-point compartment
compartment("hello")
    add_files("hello.cc")
-- compartments#end

-- firmware#begin
-- Firmware image for the example.
firmware("hello_world")
    -- RTOS-provided libraries
    add_deps("freestanding", "stdio")
    -- Our compartments
    add_deps("hello", "example_compartment")
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
-- firmware#end
