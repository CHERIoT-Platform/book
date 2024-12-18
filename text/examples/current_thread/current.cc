// Copyright Microsoft and CHERIoT
// Contributors.
// SPDX-License-Identifier: MIT

#include <stdio.h>
#include <thread.h>

// entry#begin
/// Thread entry point.
void __cheri_compartment("current")
  entry()
{
	for (int i = 0; i < 2; i++)
	{
		printf(
		  "Current thread: %d of %d\n",
		  thread_id_get(),
		  thread_count());
	}
}
// entry#end
