// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "interface.h"
#include <debug.hh>

/**
 * A global that exists to make sure that the compartment's
 * cgp is not zero-length.
 */
int global;

using Debug = ConditionalDebug<true, "Entry">;

__cheri_compartment("entry") int entry()
{
	register void *cgp __asm__("cgp");
	asm("" : "=C"(cgp));
	Debug::log("Stack pointer: {}",
	           __builtin_cheri_stack_get());
	Debug::log("Program counter: {}",
	           __builtin_cheri_program_counter_get());
	Debug::log("Globals pointer: {}", cgp);
	library_function();
	compartment_function();
	// A use of the global to make sure that it exists in the
	// final binary.
	return global;
}
