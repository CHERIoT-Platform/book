#include <cheri.hh>
#include <debug.hh>
#include <string_view>
#include <unwind.h>

extern "C" void print_from_c(void);

/**
 * Tagged union of a network address
 */
struct NetworkAddress
{
	/// Network address kind union discriminator
	enum
	{
		/// Invalid address
		AddressKindInvalid,
		/// IPv6 address
		AddressKindIPv6,
		/// IPv4 address
		AddressKindIPv4,
	} kind;
	/// data for the address
	union
	{
		/// IPv4 address data
		uint32_t ipv4;
		/// IPv6 address data
		char ipv6[16];
	};
};

// printer#begin
void debug_network_address(uintptr_t    value,
                           DebugWriter &writer)
{
	auto *address = reinterpret_cast<NetworkAddress *>(value);
	if (address->kind == NetworkAddress::AddressKindIPv6)
	{
		for (int i = 0; i < 14; i += 2)
		{
			writer.write_hex_byte(address->ipv6[i]);
			writer.write_hex_byte(address->ipv6[i + 1]);
			writer.write(':');
		}
		writer.write_hex_byte(address->ipv6[14]);
		writer.write_hex_byte(address->ipv6[15]);
	}
	else if (address->kind == NetworkAddress::AddressKindIPv4)
	{
		writer.write_decimal((address->ipv4 >> 0) & 0xff);
		writer.write('.');
		writer.write_decimal((address->ipv4 >> 8) & 0xff);
		writer.write('.');
		writer.write_decimal((address->ipv4 >> 16) & 0xff);
		writer.write('.');
		writer.write_decimal((address->ipv4 >> 24) & 0xff);
	}
	else
	{
		writer.write("<invalid address>");
	}
};
// printer#end

// type_adaptor#begin
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
// type_adaptor#end

// debug_type#begin
using Debug = ConditionalDebug<DEBUG_DEBUG_COMPARTMENT,
                               "Debug compartment">;
// debug_type#end

__cheri_compartment("debug_compartment") int entry()
{
	// log#begin
	Debug::log("Hello world!");
	Debug::log("Here is a C string {}, A C++ string view {}, "
	           "an int {}, and an unsigned 64-bit value {}",
	           "hello from a C string",
	           std::string_view{"hello from a C++ string"},
	           52,
	           0xabcdULL);
	auto enumValue = NetworkAddress::AddressKindIPv4;
	Debug::log("Here is an enum value: {}", enumValue);
	int x;
	Debug::log("Here is a pointer: {}", &x);
	// log#end

	// custom_log#begin
	NetworkAddress addr;
	addr.ipv4 = 0x0100007f;
	addr.kind = NetworkAddress::AddressKindIPv4;
	Debug::log("There's no place like {}", addr);
	memset(addr.ipv6, 0, sizeof(addr.ipv6));
	addr.ipv6[15] = 1;
	addr.kind     = NetworkAddress::AddressKindIPv6;
	Debug::log("There's no place like {}", addr);
	// custom_log#end

	// asserts#begin
	bool someCondition = false;
	CHERIOT_DURING
	{
		Debug::Assert(someCondition,
		              "Assertion failed, condition is {}",
		              someCondition);
	}
	CHERIOT_HANDLER
	{
		printf("Assertion triggered error handler\n");
	}
	CHERIOT_END_HANDLER

	CHERIOT_DURING
	{
		Debug::Invariant(someCondition,
		                 "Invariant failed, condition is {}",
		                 someCondition);
	}
	CHERIOT_HANDLER
	{
		printf("Invariant triggered error handler\n");
	}
	CHERIOT_END_HANDLER
	// asserts#end

	print_from_c();
	return 0;
}
