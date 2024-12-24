#include <cheri-builtins.h>
#include <stdio.h>
#include <stdlib.h>

// print_capability#begin
void print_capability(void *ptr)
{
	unsigned permissions = cheri_permissions_get(ptr);
	printf(
	  "0x%x (valid:%d length: 0x%x 0x%x-0x%x otype:%d "
	  "permissions: %c "
	  "%c%c%c%c%c%c %c%c %c%c%c)\n",
	  cheri_address_get(ptr),
	  cheri_tag_get(ptr),
	  cheri_length_get(ptr),
	  cheri_base_get(ptr),
	  cheri_top_get(ptr),
	  cheri_type_get(ptr),
	  (permissions & CHERI_PERM_GLOBAL) ? 'G' : '-',
	  (permissions & CHERI_PERM_LOAD) ? 'R' : '-',
	  (permissions & CHERI_PERM_STORE) ? 'W' : '-',
	  (permissions & CHERI_PERM_LOAD_STORE_CAP) ? 'c' : '-',
	  (permissions & CHERI_PERM_LOAD_GLOBAL) ? 'g' : '-',
	  (permissions & CHERI_PERM_LOAD_MUTABLE) ? 'm' : '-',
	  (permissions & CHERI_PERM_STORE_LOCAL) ? 'l' : '-',
	  (permissions & CHERI_PERM_SEAL) ? 'S' : '-',
	  (permissions & CHERI_PERM_UNSEAL) ? 'U' : '-',
	  (permissions & CHERI_PERM_USER0) ? '0' : '-');
}
// print_capability#end

__cheri_compartment("example") int entry(void)
{
	// capability_manipulation#begin
	// A stack allocation
	char stackBuffer[23];
	print_capability(stackBuffer);
	// A heap allocation
	char *heapBuffer = malloc(23);
	print_capability(heapBuffer);
	// Setting the bounds of a heap capability
	char *bounded = cheri_bounds_set(heapBuffer, 23);
	print_capability(bounded);
	// Removing permissions from a heap capability
	bounded = cheri_permissions_and(bounded, CHERI_PERM_LOAD);
	print_capability(bounded);
	print_capability(heapBuffer);
	// capability_manipulation#end
	return 0;
}
