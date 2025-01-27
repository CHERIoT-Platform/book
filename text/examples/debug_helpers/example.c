#include <debug.h>
#include <stdio.h>
#include <unwind.h>

void print_from_c(void)
{
	// all#begin
	CHERIOT_DEBUG_LOG("C example",
	                  "Printing a number {} and a string {}",
	                  42,
	                  "hello from C");
	CHERIOT_DURING
	{
		CHERIOT_INVARIANT(
		  false, "Invariant check in C failed: {}", 12);
	}
	CHERIOT_HANDLER
	{
		printf("Invariant triggered unwind in C\n");
	}
	CHERIOT_END_HANDLER
	// all#end
}
