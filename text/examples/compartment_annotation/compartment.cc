// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "interface.h"
#include <atomic>

namespace
{
	std::atomic<int> counter;
}

// increment#begin
int increment()
{
	counter++;
	return 0;
}
// increment#end

// monotonic#begin
int monotonic(Callback callback)
{
	return callback(++counter);
}
// monotonic#end
