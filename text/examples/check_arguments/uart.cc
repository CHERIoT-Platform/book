// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "hello.h"
#include <debug.hh>
#include <futex.h>
#include <locks.hh>
#include <platform-uart.hh>

// Import some useful things from the CHERI namespace.
using namespace CHERI;

// safe_uart#begin
/// Write a message to the UART.
int uart_puts(const char *msg)
{
	static FlagLockPriorityInherited lock;
	// Prevent concurrent invocation
	LockGuard g(lock);
	Timeout   t{UnlimitedTimeout};
	// Make sure that this is not going to be deallocated out
	// from under us.
	if (heap_claim_fast(&t, msg) != 0)
	{
		return -EINVAL;
	}
	// Check that this is a valid pointer with the correct
	// permissions.
	if (!check_pointer<PermissionSet{Permission::Load}>(msg))
	{
		return -EINVAL;
	}
	// Get the bounds (distance from address to top) of the
	// pointer.
	Capability buffer{msg};
	size_t     length = buffer.bounds();
	// Write the data, one byte at a time.
	for (size_t i = 0; i < length; i++)
	{
		char c = msg[i];
		if (c == '\0')
		{
			break;
		}
		MMIO_CAPABILITY(Uart, uart)->blocking_write(c);
	}
	MMIO_CAPABILITY(Uart, uart)->blocking_write('\n');
	return 0;
}
// safe_uart#end
