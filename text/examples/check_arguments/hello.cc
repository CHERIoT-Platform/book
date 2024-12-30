// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "hello.h"
#include <cheri.hh>

using namespace CHERI;

/// Thread entry point.
void __cheri_compartment("hello") entry()
{
	// attacks#begin
	char unterminatedString[] = {
	  'N', 'o', ' ', 'n', 'u', 'l', 'l'};
	uart_puts(unterminatedString);
	Capability invalidPermissions = "Invalid permissions";
	invalidPermissions.permissions() &= Permission::Store;
	uart_puts(invalidPermissions);
	char *invalidPointer = reinterpret_cast<char *>(12345);
	uart_puts(invalidPointer);
	uart_puts("Non-malicious string");
	// attacks#end
}
