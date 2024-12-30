// Copyright CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <compartment-macros.h>

/**
 * Write `msg` to the default UART, including a trailing
 * newline.
 *
 * Returns 0 on success, or a negative error code on
 * failure.
 *
 * If the string is not null-terminated, prints only the
 * length of the capability.
 */
int __cheri_compartment("uart") uart_puts(const char *msg);
