// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "monotonic_counter.hh"
#include <errno.h>
#include <token.h>

// increment#begin
int64_t
monotonic_counter_increment(MonotonicCounter sealedCounter)
{
	if (auto *counter = token_unseal(
	      STATIC_SEALING_TYPE(CounterKey), sealedCounter))
	{
		return ++(*counter);
	}
	return -EINVAL;
}
// increment#end
