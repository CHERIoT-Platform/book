// Give this compartment a larger allocation quota
#define MALLOC_QUOTA (32 * 1024)

#include <NetAPI.h>
#include <debug.hh>
#include <platform-uart.hh>
#include <sntp.h>
#include <thread.h>
#include <tick_macros.h>

using Debug = ConditionalDebug<true, "TCP Example">;

constexpr bool UseIPv6 = CHERIOT_RTOS_OPTION_IPv6;

// server_capability#begin
DECLARE_AND_DEFINE_CONNECTION_CAPABILITY(
  Server,
  "towel.blinkenlights.nl",
  23,
  ConnectionTypeTCP);
// server_capability#end

void __cheriot_compartment("tcp_example") example()
{
	Debug::log("Starting network stack");
	network_start();

	Debug::log("Creating connection");
	// connect#begin
	Timeout unlimited{UnlimitedTimeout};
	auto    socket =
	  network_socket_connect_tcp(&unlimited,
	                             MALLOC_CAPABILITY,
	                             STATIC_SEALED_VALUE(Server));
	if (!CHERI::Capability{socket}.is_valid())
	{
		Debug::log("Failed to connect");
		return;
	}
	// connect#end

	// receive#begin
	while (true)
	{
		auto [received, buffer] = network_socket_receive(
		  &unlimited, MALLOC_CAPABILITY, socket);
		if (received < 0)
		{
			Debug::log("Error: {}", received);
			return;
		}
		for (size_t i = 0; i < received; i++)
		{
			MMIO_CAPABILITY(Uart, uart)
			  ->blocking_write(buffer[i]);
		}
		free(buffer);
	}
	// receive#end
}
