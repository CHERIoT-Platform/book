// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "monotonic_counter.hh"
#include <fail-simulator-on-error.h>
#include <stdio.h>

// entry#begin
// Declare and define a counter for this to use.
DECLARE_AND_DEFINE_COUNTER(aCounter)

void __cheriot_compartment("caller") entry()
{
	// Get a pointer to the valid counter.
	auto validCounter = STATIC_SEALED_VALUE(aCounter);
	// Create an unsealed value of the correct type
	MonotonicCounterState invalidCounterState;
	auto invalidCounter = reinterpret_cast<MonotonicCounter>(
	  &invalidCounterState);
	auto invalidSealedCounter =
	  reinterpret_cast<MonotonicCounter>(MALLOC_CAPABILITY);

	// Try the valid capability
	printf("Valid counter increment returned %lld\n",
	       monotonic_counter_increment(validCounter));
	printf("Valid counter increment returned %lld\n",
	       monotonic_counter_increment(validCounter));
	// Try the invalid ones
	printf("Invalid counter increment returned %lld\n",
	       monotonic_counter_increment(invalidCounter));
	printf("Invalid counter increment returned %lld\n",
	       monotonic_counter_increment(invalidSealedCounter));
	// Try manipulating the counter directly
	auto underlyingCounter =
	  reinterpret_cast<MonotonicCounterState *>(validCounter);
	(*underlyingCounter)++;
}
// entry#end
