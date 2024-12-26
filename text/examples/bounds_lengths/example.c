#define MALLOC_QUOTA 320000
#include <cheri-builtins.h>
#include <stdio.h>
#include <stdlib.h>

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

__cheri_compartment("example") int entry(void)
{
	// representable_range#begin
	const size_t Size = 160000;
	printf("Smallest representable size of %d-byte "
	       "allocation: %d (0x%x). Alignment mask: 0x%x\n",
	       Size,
	       cheri_round_representable_length(Size),
	       cheri_round_representable_length(Size),
	       cheri_representable_alignment_mask(Size));
	void *allocation = malloc(Size);
	print_capability(allocation);
	// representable_range#end
	return 0;
}
