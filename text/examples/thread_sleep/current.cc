// Copyright Microsoft and CHERIoT
// Contributors.
// SPDX-License-Identifier: MIT

#include <riscvreg.h>
#include <stdio.h>
#include <thread.h>

// entry#begin
/// Thread entry point.
void __cheriot_compartment("current") entry()
{
	for (int i = 0; i < 2; i++)
	{
		printf("Current thread: %d of %d\n",
		       thread_id_get(),
		       thread_count());
		Timeout t{1};
		thread_sleep(&t);
	}
	printf("Cycles elapsed: %lld\n", rdcycle64());
}
// entry#end
