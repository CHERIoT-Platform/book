// Copyright Contributors.
// SPDX-License-Identifier: MIT

#include <atomic>
#include <compartment.h>

// export#begin
using MonotonicCounterState = std::atomic<int64_t>;

#define DECLARE_AND_DEFINE_COUNTER(name)                   \
	DECLARE_AND_DEFINE_STATIC_SEALED_VALUE(                  \
	  MonotonicCounterState, monotonic, CounterKey, name, 0)

typedef MonotonicCounterState
  *__sealed_capability MonotonicCounter;

/**
 * Increments a monotonic counter and returns the new value.
 *
 * Returns a negative value for errors.
 */
int64_t __cheriot_compartment("monotonic")
  monotonic_counter_increment(
    MonotonicCounter allocatorCapability);
// export#end
