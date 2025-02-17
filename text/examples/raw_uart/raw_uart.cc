// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <platform-uart.hh>

/// Thread entry point.
void __cheri_compartment("raw_uart") entry()
{
// uart#begin
	static const char hello[] = "Hello world!\n";
	for (char c : hello)
	{
		MMIO_CAPABILITY(Uart, uart)->blocking_write(c);
	}
// uart#end
}
