// Copyright Microsoft and CHERIoT
// Contributors.
// SPDX-License-Identifier: MIT

#include <locks.hh>
#include <stdio.h>
#include <thread.h>

// declare#begin
// Comment out this line and uncomment
// the next one to see how ticket locks
// behave.
FlagLock lock;
// TicketLock lock;
// declare#end

/**
 * Function that serves as a placeholder
 * for something that does work with the
 * lock held.
 */
void do_useful_work()
{
	Timeout t{MS_TO_TICKS(1000)};
	thread_sleep(
	  &t, ThreadSleepNoEarlyWake);
}

// low#begin
__cheri_compartment(
  "locking") void low()
{
	while (true)
	{
		lock.lock();
		printf("Low priority thread "
		       "acquired lock\n");
		do_useful_work();
		lock.unlock();
	}
}
// low#end

// medium#begin
__cheri_compartment(
  "locking") void medium()
{
	while (true)
	{
		lock.lock();
		printf("Medium priority thread "
		       "acquired lock\n");
		do_useful_work();
		lock.unlock();
	}
}
// medium#end

// high#begin
__cheri_compartment(
  "locking") void high()
{
	while (true)
	{
		lock.lock();
		printf("High priority thread "
		       "acquired lock\n");
		do_useful_work();
		lock.unlock();
	}
}
// high#end
