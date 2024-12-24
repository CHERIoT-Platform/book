// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "interface.h"
#include <debug.hh>

using Debug = ConditionalDebug<true, "Library">;

// library_implementation#begin
void library_function()
{
	// Print the stack capability from within the library.
	Debug::log("Stack pointer: {}",
	           __builtin_cheri_stack_get());
}
// library_implementation#end
