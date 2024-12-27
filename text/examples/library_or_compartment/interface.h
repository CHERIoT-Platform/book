// Copyright Contributors.
// SPDX-License-Identifier: MIT

#include <compartment.h>

// exports#begin
/**
 * A simple example library function.
 */
__cheri_libcall void library_function();

/**
 * A simple example compartment function.
 */
__cheri_compartment(
  "compartment") int compartment_function();
// exports#end
