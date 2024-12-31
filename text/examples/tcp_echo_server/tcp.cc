// Give this compartment a larger allocation quota
#define MALLOC_QUOTA (32 * 1024)

#include <NetAPI.h>
#include <debug.hh>
#include <platform-uart.hh>
#include <sntp.h>
#include <thread.h>
#include <tick_macros.h>

using Debug = ConditionalDebug<true, "TCP Server Example">;

// FIXME: Move this into the TCP/IP header.
void debug_network_address(uintptr_t    value,
                           DebugWriter &writer)
{
	auto *address = reinterpret_cast<NetworkAddress *>(value);
	if (address->kind == NetworkAddress::AddressKindIPv6)
	{
		for (int i = 0; i < 14; i += 2)
		{
			writer.write(uint32_t(address->ipv6[i]));
			writer.write(uint32_t(address->ipv6[i + 1]));
			writer.write(':');
		}
		writer.write(uint32_t(address->ipv6[14]));
		writer.write(uint32_t(address->ipv6[15]));
	}
	else if (address->kind == NetworkAddress::AddressKindIPv4)
	{
		writer.write(int32_t((address->ipv4 >> 0) & 0xff));
		writer.write('.');
		writer.write(int32_t((address->ipv4 >> 8) & 0xff));
		writer.write('.');
		writer.write(int32_t((address->ipv4 >> 16) & 0xff));
		writer.write('.');
		writer.write(int32_t((address->ipv4 >> 24) & 0xff));
	}
	else
	{
		writer.write("<invalid address>");
	}
};

template<>
struct DebugFormatArgumentAdaptor<NetworkAddress>
{
	static DebugFormatArgument
	construct(NetworkAddress &address)
	{
		return {
		  reinterpret_cast<uintptr_t>(&address),
		  reinterpret_cast<uintptr_t>(debug_network_address)};
	}
};

constexpr bool UseIPv6 = CHERIOT_RTOS_OPTION_IPv6;

// server_capability#begin
DECLARE_AND_DEFINE_BIND_CAPABILITY(
  /* Name */ ServerPort,
  /* Bind on IPv6? */ UseIPv6,
  /* Port number */ 1234,
  /* Concurrent connection limit */ 1);
// server_capability#end

void __cheri_compartment("tcp_example") example()
{
	Debug::log("Starting network stack");
	network_start();

	Debug::log("Creating listening socket");

	// listen#begin
	Timeout unlimited{UnlimitedTimeout};
	auto    socket = network_socket_listen_tcp(
    &unlimited,
    MALLOC_CAPABILITY,
    STATIC_SEALED_VALUE(ServerPort));
	if (!CHERI::Capability{socket}.is_valid())
	{
		Debug::log("Failed to bind to local port");
		return;
	}
	// listen#end

	// accept#begin
	while (true)
	{
		Debug::log("Listening for connections...");
		NetworkAddress address;
		uint16_t       port;
		auto           accepted =
		  network_socket_accept_tcp(&unlimited,
		                            MALLOC_CAPABILITY,
		                            socket,
		                            &address,
		                            &port);
		if (!CHERI::Capability{accepted}.is_valid())
		{
			continue;
		}
		Debug::log("Received connection from {} on port {}",
		           address,
		           int32_t(port));
		char byte;
		while (network_socket_receive_preallocated(
		         &unlimited, accepted, &byte, 1) == 1)
		{
			network_socket_send(&unlimited, accepted, &byte, 1);
			MMIO_CAPABILITY(Uart, uart)->blocking_write(byte);
		}
		network_socket_close(
		  &unlimited, MALLOC_CAPABILITY, accepted);
	}
	// accept#end
}
