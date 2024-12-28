#include "safebox.h"
#include <platform-uart.hh>
#include <debug.hh>

// runner#begin
using Debug = ConditionalDebug<true, "Runner">;

__cheri_compartment("runner") void entry()
{
	Debug::log("Guess a number between 0 and 9 (inclusive)");
	while (int c = MMIO_CAPABILITY(Uart, uart)->blocking_read())
	{
		if ((c < '0') || (c > '9'))
		{
			Debug::log("Invalid guess: {}", c);
			continue;
		}
		c -= '0';
		if (check_guess(c))
		{
			Debug::log("Correct!  You guessed the secret was {}", c);
		}
	}
}
// runner#end
