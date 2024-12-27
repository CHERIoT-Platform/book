// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "interface.h"
#include <debug.hh>

using Debug = ConditionalDebug<true, "Library">;

void library_function()
{
	// library_implementation#begin
	register void *cgp asm("cgp");
	asm("" : "=C"(cgp));
	// Print the stack capability from within the library.
	Debug::log("Stack pointer: {}",
	           __builtin_cheri_stack_get());
	Debug::log("Program counter: {}",
	           __builtin_cheri_program_counter_get());
	Debug::log("Globals pointer: {}", cgp);
	// library_implementation#end
}
