// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <debug.hh>
#include <fail-simulator-on-error.h>
#include <queue.h>
#include <timeout.hh>
#include <token.h>

using Debug = ConditionalDebug<true, "Queue">;

MessageQueue *queue;

/**
 * Run the producer thread, sending integers to the
 * consumer.
 */
void __cheriot_compartment("queue") producer()
{
	// queue_allocate#begin
	// Allocate the queue
	non_blocking<queue_create>(
	  MALLOC_CAPABILITY, &queue, sizeof(int), 16);
	// Wake the consumer thread
	futex_wake(reinterpret_cast<uint32_t *>(&queue), 1);
	// queue_allocate#end
	Debug::log("Starting producer loop");
	// queue_send#begin
	// Loop, sending some numbers to the other thread.
	for (int i = 1; i < 200; i++)
	{
		Debug::log("Producer sending {} to queue", i);
		int ret = blocking_forever<queue_send>(queue, &i);
		// Abort if the queue send errors.
		Debug::Invariant(ret == 0, "Queue send failed {}", ret);
	}
	// queue_send#end
	Debug::log("Producer sent all messages to consumer");
}

/**
 * Run loop for the consumer thread.
 */
void __cheriot_compartment("queue") consumer()
{
	// consumer#begin
	// Use the queue pointer as a futex.  It is initialised to
	// 0, if the other thread has stored a valid pointer here
	// then it will not be zero and so futex_wait will return
	// immediately.
	futex_wait(reinterpret_cast<uint32_t *>(&queue), 0);
	Debug::log("Waiting for messages");
	// Get a message from the queue and print it.
	int     value = 0;
	while ((value != 199) &&
	       (blocking_forever<queue_receive>(queue, &value) == 0))
	{
		Debug::log("Read {} from queue", value);
	}
	Debug::log("Destroying the queue");
	queue_destroy(MALLOC_CAPABILITY, queue);
	// consumer#end
	Debug::log("{} cycles elapsed", rdcycle64());
}
