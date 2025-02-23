// Copyright Contributors.
// SPDX-License-Identifier: MIT

#include <compartment.h>

// export#begin
/**
 * Example of a function in a compartment.
 */
__cheriot_compartment(
  "example_compartment") int exported_function(void);
// export#end
