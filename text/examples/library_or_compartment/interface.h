// Copyright Contributors.
// SPDX-License-Identifier: MIT

#include <compartment.h>

// exports#begin
/**
 * A simple example library function.
 */
__cheriot_libcall void library_function();

/**
 * A simple example compartment function.
 */
__cheriot_compartment(
  "compartment") int compartment_function();
// exports#end
