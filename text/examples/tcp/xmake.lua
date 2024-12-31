-- Copyright CHERIoT Contributors.
-- SPDX-License-Identifier: MIT

-- Update this to point to the location of the CHERIoT SDK
sdkdir = os.getenv("CHERIOT_SDK") or
    "../../../rtos-source/sdk/"
includes(sdkdir)
set_toolchains("cheriot-clang")

-- include_network#begin
networkstackdir = os.getenv("CHERIOT_NETWORK") or
    "../../../network-stack/"
includes(path.join(networkstackdir,"lib"))
-- include_network#end

set_project("CHERIoT SNTP Example")


option("board")
  set_default("sonata")

compartment("tcp_example")
  add_includedirs(path.join(networkstackdir,"include"))
  add_deps("freestanding")
  add_files("tcp.cc")
  on_load(function(target)
    target:add('options', "IPv6")
    local IPv6 = get_config("IPv6")
    target:add("defines",
        "CHERIOT_RTOS_OPTION_IPv6=" .. tostring(IPv6))
  end)

firmware("tcp")
  set_policy("build.warning", true)
  add_deps("atomic8", "debug")
  add_deps("DNS", "TCPIP", "Firewall", "NetAPI",
           "SNTP", "time_helpers")
  add_deps("tcp_example")
  on_load(function(target)
    target:values_set("board", "$(board)")
    target:values_set("threads", {
      {
        compartment = "tcp_example",
        priority = 1,
        entry_point = "example",
        stack_size = 0xe00,
        trusted_stack_frames = 6
      },
      {
        -- TCP/IP stack thread.
        compartment = "TCPIP",
        priority = 1,
        entry_point = "ip_thread_entry",
        stack_size = 0xe00,
        trusted_stack_frames = 5
      },
      {
        -- Firewall thread, handles incoming packets as they
        -- arrive.
        compartment = "Firewall",
        -- Higher priority, this will be back-pressured by
        -- the message queue if the network stack can't keep
        -- up, but we want packets to arrive immediately.
        priority = 2,
        entry_point = "ethernet_run_driver",
        stack_size = 0x1000,
        trusted_stack_frames = 5
      }
    }, {expand = false})
  end)

