// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <compartment.h>
#include <debug.hh>
#include <unwind.h>

/// Expose debugging features unconditionally for this
/// compartment.
using Debug =
  ConditionalDebug<true, "Error handling example">;

void try_to_trap(bool shouldTrap)
{
	// error#begin
	Debug::log("About to try something unsafe.");
	CHERIOT_DURING
	{
		Debug::log("In during block");
		if (shouldTrap)
		{
			// This will unconditionally trap.
			__builtin_trap();
		}
	}
	CHERIOT_HANDLER
	{
		Debug::log("Something bad happened!");
	}
	CHERIOT_END_HANDLER
	Debug::log("Finished unsafe block.");
	// error#end
}

/// Thread entry point.
void __cheriot_compartment("errors") error_handling()
{
	try_to_trap(false);
	try_to_trap(true);
}
