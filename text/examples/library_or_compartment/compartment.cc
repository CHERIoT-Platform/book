// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "interface.h"
#include <debug.hh>

using Debug = ConditionalDebug<true, "Compartment">;

/**
 * A global that exists to make sure that the compartment's
 * cgp is not zero-length.
 */
int global;

int compartment_function()
{
	// Print the stack capability from within the library.
	Debug::log("Stack pointer: {}",
	           __builtin_cheri_stack_get());
	Debug::log("Program counter: {}",
	           __builtin_cheri_program_counter_get());
	register void *cgp asm("cgp");
	asm("" : "=C"(cgp));
	Debug::log("Globals pointer: {}", cgp);
	// A use of the global to make sure that it exists in the
	// final binary.
	return global;
}
