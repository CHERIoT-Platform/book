// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <debug.hh>
#include <fail-simulator-on-error.h>
#include <queue.h>
#include <timeout.hh>
#include <token.h>

using Debug = ConditionalDebug<true, "Queue">;

std::array<MessageQueue *, 2> queues;

/**
 * Create two message queues.
 */
void init()
{
	// Use C++ thread-safe static initialisation to ensure
	// that the queues are created exactly once.
	static bool initialize = []() {
		blocking_forever<queue_create>(
		  MALLOC_CAPABILITY, &queues[0], sizeof(int), 16);
		blocking_forever<queue_create>(
		  MALLOC_CAPABILITY, &queues[1], sizeof(int), 16);
		return true;
	}();
}

/**
 * Send the numbers 0-199 to the message queue given by
 * `number`.
 */
void send(int number)
{
	Debug::log("Starting producer loop for queue {}", number);
	// queue_send#begin
	// Loop, sending some numbers to the other thread.
	for (int i = 1; i < 200; i++)
	{
		Debug::log(
		  "Producer sending {} to queue {}", i, number);
		int ret =
		  blocking_forever<queue_send>(queues[number], &i);
		// Abort if the queue send errors.
		Debug::Invariant(ret == 0,
		                 "Queue send failed {} on queue {}",
		                 ret,
		                 number);
	}
	// queue_send#end
	Debug::log(
	  "Producer sent all messages to consumer on queue {}",
	  number);
}

/**
 * Run the first producer thread, sending integers to the
 * consumer.
 */
void __cheri_compartment("queue") producer1()
{
	init();
	send(0);
}

/**
 * Run the second producer thread, sending integers to the
 * consumer.
 */
void __cheri_compartment("queue") producer2()
{
	init();
	send(1);
}

/**
 * Run loop for the consumer thread.
 */
void __cheri_compartment("queue") consumer()
{
	init();
	// multiwaiter_create#begin
	// Create the multiwaiter object in the scheduler with
	// space for two event sources.
	MultiWaiter *multiwaiter;
	blocking_forever<multiwaiter_create>(
	  MALLOC_CAPABILITY, &multiwaiter, 2);
	// multiwaiter_create#end

	int values[] = {0, 0};
	do
	{
		// multiwaiter_use#begin
		// Initialise the events for this wait.
		std::array<EventWaiterSource, queues.size()> events;
		multiwaiter_queue_receive_init(&events[0], queues[0]);
		multiwaiter_queue_receive_init(&events[1], queues[1]);
		// Block until at least one event fires.
		int ret = blocking_forever<multiwaiter_wait>(
		  multiwaiter, events.data(), events.size());
		Debug::Assert(ret == 0, "Multiwaiter failed: {}", ret);
		// For each message queue, fetch a message if the
		// multiwaiter indicated that one was available.
		for (int i = 0; i < queues.size(); i++)
		{
			if (events[i].value)
			{
				ret = non_blocking<queue_receive>(queues[i],
				                                  &values[i]);
				Debug::Assert(
				  ret == 0,
				  "Failed to receive message from queue: {}",
				  ret);
				Debug::log("Received {} on queue {}", values[i], i);
			}
		}
		// multiwaiter_use#end
	} while ((values[0] != 199) && (values[1] != 199));
}
