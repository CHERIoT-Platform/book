// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "hello.h"
#include <stdio.h>

// entry#begin
/// Thread entry point.
void __cheri_compartment("hello") entry()
{
	printf("compartment returned %d\n",
	       exported_function());
}
// entry#end
