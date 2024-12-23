// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <atomic>
#include "interface.h"

namespace {
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
