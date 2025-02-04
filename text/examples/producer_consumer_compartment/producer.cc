// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include "consumer.h"
#include <debug.hh>
#include <fail-simulator-on-error.h>
#include <queue.h>
#include <thread.h>
#include <timeout.hh>
#include <token.h>

using Debug = ConditionalDebug<true, "Producer">;

/**
 * Run the producer thread, sending integers to the
 * consumer.
 */
void __cheri_compartment("producer") run()
{
	// queue_allocate#begin
	// Allocate the queue
	CHERI_SEALED(MessageQueue *) queue;
	non_blocking<queue_create_sealed>(
	  MALLOC_CAPABILITY, &queue, sizeof(int), 16);
	// Pass the queue handle to the consumer.
	set_queue(queue);
	// queue_allocate#end
	Debug::log("Starting producer loop");
	// Loop, sending some numbers to the other thread.
	for (int i = 1; i < 200; i++)
	{
		Debug::log("Producer sending {} to queue", i);
		int ret =
		  blocking_forever<queue_send_sealed>(queue, &i);
		// Abort if the queue send errors.
		Debug::Invariant(ret == 0, "Queue send failed {}", ret);
	}
	Debug::log("Producer sent all messages to consumer");

	// queue_cleanup#begin
	size_t itemsRemaining;
	while ((queue_items_remaining_sealed(
	          queue, &itemsRemaining) == 0) &&
	       (itemsRemaining > 0))
	{
		Timeout t{1};
		thread_sleep(&t);
	}
	int ret = blocking_forever<queue_destroy_sealed>(
	  MALLOC_CAPABILITY, queue);
	Debug::Assert(
	  ret == 0, "Failed to destroy queue: {}", ret);
	Debug::log("Destroyed queue");
	// queue_cleanup#end
}
