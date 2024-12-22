// Copyright Microsoft and CHERIoT
// Contributors.
// SPDX-License-Identifier: MIT

#include <atomic>
#include <stdio.h>
#include <thread.h>

// entry#begin
/// Thread entry point.
__cheri_compartment("barrier") void entry()
{
	static std::atomic<uint32_t> barrier = 2;
	printf("Thread: %d arrived at barrier\n",
	       thread_id_get());
	uint32_t value = --barrier;
	if (value == 0)
	{
		barrier.notify_all();
	}
	else
	{
		while (value != 0)
		{
			barrier.wait(value);
			value = barrier;
		}
	}
	printf("Thread: %d passed barrier\n", thread_id_get());
}
// entry#end
