// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "interface.h"
#include <debug.hh>
#include <stdio.h>

using Debug = ConditionalDebug<true, "Entry compartment">;

// entry#begin
/// Thread entry point.
void __cheri_compartment("entry") entry()
{
	// Print the current stack capability.
	Debug::log("Stack pointer: {}",
	           __builtin_cheri_stack_get());
	// Call the function exported from the library.
	library_function();
}
// entry#end
