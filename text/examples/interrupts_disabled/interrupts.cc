// Copyright Microsoft and CHERIoT
// Contributors.
// SPDX-License-Identifier: MIT

#include <riscvreg.h>
#include <stdio.h>
#include <thread.h>

// high#begin
/// High-priority thread entry point.
void __cheriot_compartment("interrupts") high()
{
	printf("One tick is %d cycles\n", TIMERCYCLES_PER_TICK);
	while (true)
	{
		// Get the current cycle time
		uint64_t start = rdcycle64();
		// Sleep for one scheduler tick
		Timeout t{1};
		thread_sleep(&t);
		// Report how long the sleep was
		printf("Cycles elapsed with high-priority thread "
		       "yielding: %lld\n",
		       rdcycle64() - start);
	}
}
// high#end

// low#begin

/**
 * A function that runs with interrupts disabled and
 * consumes CPU for the requested number of ticks.
 */
[[cheriot::interrupt_state(disabled)]] void
spin_for_ticks(uint32_t ticks)
{
	uint64_t end =
	  rdcycle64() + (uint64_t(ticks) * TIMERCYCLES_PER_TICK);
	while (rdcycle64() < end) {}
}

/// Low-priority thread entry point.
void __cheriot_compartment("interrupts") low()
{
	int sleeps = 2;
	while (true)
	{
		printf("low-priority thread running\n");
		spin_for_ticks(sleeps++);
	}
}
// low#end
