// Copyright Microsoft and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <compartment.h>
#include <cstdlib>
#include <queue.h>

void __cheriot_compartment("consumer")
  set_queue(CHERI_SEALED(MessageQueue *) queueHandle);
