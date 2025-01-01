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

set_project("CHERIoT TLS Example")


option("board")
  set_default("sonata")

compartment("https_example")
  add_includedirs(path.join(networkstackdir,"include"))
  add_deps("freestanding")
  add_files("https.cc")
  on_load(function(target)
    target:add('options', "IPv6")
    local IPv6 = get_config("IPv6")
    target:add("defines",
        "CHERIOT_RTOS_OPTION_IPv6=" .. tostring(IPv6))
  end)

firmware("https")
  set_policy("build.warning", true)
  add_deps("atomic8", "debug")
  add_deps("DNS", "TCPIP", "Firewall", "NetAPI",
           "SNTP", "time_helpers", "TLS")
  add_deps("https_example")
  on_load(function(target)
    target:values_set("board", "$(board)")
    target:values_set("threads", {
      -- example_thread#begin
      {
        compartment = "https_example",
        priority = 1,
        entry_point = "example",
        -- TLS requires *huge* stacks!
        --stack_size = 8160,
        stack_size = 6144,
        trusted_stack_frames = 6
      },
      -- example_thread#end
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

