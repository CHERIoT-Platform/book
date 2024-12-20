// Copyright Microsoft and CHERIoT
// Contributors.
// SPDX-License-Identifier: MIT

#include <locks.hh>
#include <stdio.h>
#include <thread.h>

// Comment this line and uncomment the
// line below to fix the priority
// inversion in this example.
FlagLock lock;
//FlagLockPriorityInherited lock;

// high#begin
__cheri_compartment(
  "priority_"
  "inheritance") void high()
{
	// Let the low and
	// medium-priority threads start
	Timeout t(MS_TO_TICKS(1000));
	thread_sleep(&t);
	while (true)
	{
		t = Timeout(MS_TO_TICKS(1000));
		if (LockGuard g{lock, &t})
		{
			printf(
			  "High-priority thread "
			  "acquired the lock!\n");
		}
		else
		{
			printf(
			  "High-priority thread "
			  "failed to acquire the "
			  "lock!\n");
		}
	}
}
// high#end

std::atomic<int> x;

// medium#begin
__cheri_compartment(
  "priority_"
  "inheritance") void medium()
{
	// Let the low-priority thread run
	// until it yields
	Timeout t(MS_TO_TICKS(1000));
	thread_sleep(&t);
	printf("Medium priority thread "
	       "entering infinite loop and "
	       "not yielding\n");
	while (true)
	{
		x++;
	}
}
// medium#end

// low#begin
__cheri_compartment(
  "priority_"
  "inheritance") void low()
{
	while (true)
	{
		lock.lock();
		printf("Low-priority thread "
		       "acquired the lock\n");
		Timeout t(MS_TO_TICKS(500));
		thread_sleep(
		  &t, ThreadSleepNoEarlyWake);
		printf("Low-priority thread "
		       "releasing the lock\n");
		lock.unlock();
	}
}
// low#end
