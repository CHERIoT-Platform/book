#include "safebox.h"
#include <riscvreg.h>
#include <debug.hh>

// safebox#begin
using Debug = ConditionalDebug<true, "Safebox">;

bool check_guess(int guess)
{
	static int secret = rdcycle64() % 10;
	if (guess != secret)
	{
		Debug::log("Guess was {}, secret was {}", guess, secret);
		secret = rdcycle64() % 10;
		return false;
	}
	return true;
}
// safebox#end
