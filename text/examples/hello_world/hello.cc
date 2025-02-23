// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "compartment.hh"
#include <stdio.h>

// entry#begin
/// Thread entry point.
void __cheriot_compartment("hello") entry()
{
	printf("compartment returned %d\n", exported_function());
}
// entry#end
