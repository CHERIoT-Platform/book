// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "hello.h"
#include <debug.hh>
#include <futex.h>
#include <locks.hh>
#include <platform-uart.hh>
#include <unwind.h>

// Import some useful things from the CHERI namespace.
using namespace CHERI;

// safe_uart#begin
/// Write a message to the UART.
int uart_puts(const char *msg)
{
	// Prevent information disclosure, check that this does
	// not overlap with our stack region.  Check for obvious
	// errors at the same time.
	if (!check_pointer(msg))
	{
		return -EINVAL;
	}
	static FlagLockPriorityInherited lock;
	// Prevent concurrent invocation
	LockGuard g(lock);
	int       result = 0;
	// Assume this is a null-terminated string, report an
	// error on exceptions if not.
	on_error(
	  [&]() {
		  for (const char *m = msg; *m != '\0'; m++)
		  {
			  MMIO_CAPABILITY(Uart, uart)->blocking_write(*m);
		  }
	  },
	  [&]() { result = -EINVAL; });
	MMIO_CAPABILITY(Uart, uart)->blocking_write('\n');
	return result;
}
// safe_uart#end
