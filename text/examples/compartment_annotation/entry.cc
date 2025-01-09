// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <stdio.h>

// callback#begin
int __cheri_callback callback(int counter)
{
	printf("Counter value: %d\n", counter);
	return 0;
}
// callback#end

int increment();
typedef __cheri_callback int (*Callback)(int);
int monotonic(Callback);

/// Thread entry point.
void __cheri_compartment("entry") entry()
{
	// compartment_call#begin
	increment();
	monotonic(callback);
	monotonic(&callback);
	// compartment_call#end
}
