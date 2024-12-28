#include <compartment-macros.h>

/**
 * Check whether a guess is correct.  The compartment holds a secret value that
 * is a number from 0-9.  Returns true if the guess is correct.
 */
__cheri_compartment("safebox")
bool check_guess(int guess);

