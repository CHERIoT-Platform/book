// Copyright Contributors.
// SPDX-License-Identifier: MIT

#include <compartment.h>

// compartment_export#begin
/**
 * A function to increment a private variable inside a
 * compartment.
 */
__cheriot_compartment(
  "example_compartment") int increment();
// compartment_export#end

// compartment_export_callback#begin

/**
 * A cross-compartment callback that takes an integer and
 * returns an integer.
 */
typedef __cheriot_callback int (*Callback)(int);

/**
 * Example of a function that takes a cross-compartment
 * callback as an argument.
 */
__cheriot_compartment("example_compartment") int monotonic(
  Callback);
// compartment_export_callback#end
