-- Copyright Microsoft and CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

set_project("CHERIoT example")

sdkdir = os.getenv("CHERIOT_SDK") or
	"../../../rtos-source/sdk/"
includes(sdkdir)

set_toolchains("cheriot-clang")

option("board")
    set_default("sail")

compartment("queue")
    add_files("queue.cc")

-- Firmware image for the example.
firmware("multiwaiter")
    -- Both compartments need memcpy and the message queue compartment.
    add_deps("freestanding", "message_queue", "debug", "cxxrt")
    add_deps("queue")
    on_load(function(target)
        target:values_set("board", "$(board)")
        target:values_set("threads", {
            {
                compartment = "queue",
                priority = 1,
                entry_point = "producer1",
                stack_size = 0x500,
                trusted_stack_frames = 5
            },
            {
                compartment = "queue",
                priority = 1,
                entry_point = "producer2",
                stack_size = 0x500,
                trusted_stack_frames = 5
            },
            {
                compartment = "queue",
                priority = 1,
                entry_point = "consumer",
                stack_size = 0x400,
                trusted_stack_frames = 3
            }
        }, {expand = false})
    end)
