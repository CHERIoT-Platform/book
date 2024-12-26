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
	// capability_equality#begin
	// A stack allocation
	char  stackBuffer[23];
	char *offset = stackBuffer + 4;
	print_capability(offset);
	// Reduce the bounds
	char *bounded = cheri_bounds_set(offset, 4);
	print_capability(bounded);
	printf("Equal? %d\n", bounded == offset);
	printf("Exactly equal? %d\n",
	       cheri_is_equal_exact(bounded, offset));
	// Remove permissions
	char *restricted =
	  cheri_permissions_and(bounded, CHERI_PERM_LOAD);
	print_capability(restricted);
	printf("Equal? %d\n", bounded == restricted);
	printf("Exactly equal? %d\n",
	       cheri_is_equal_exact(bounded, restricted));
	char *untagged = cheri_tag_clear(restricted);
	print_capability(untagged);
	printf("Equal? %d\n", untagged == restricted);
	printf("Exactly equal? %d\n",
	       cheri_is_equal_exact(untagged, restricted));
	// capability_equality#end

	// capability_ordering#begin
	if (bounded > offset)
	{
		printf("bounded > offset\n");
	}
	else if (bounded < offset)
	{
		printf("bounded < offset\n");
	}
	else if (cheri_is_equal_exact(bounded, offset))
	{
		printf("bounded exactly equals offset\n");
	}
	else
	{
		printf("bounded is not greater than, less than, nor "
		       "equal to, offset\n");
	}
	// capability_ordering#end

	// capability_subset#begin
	printf("bounded ⊂ offset? %d\n",
	       cheri_subset_test(offset, bounded));
	printf("restricted ⊂ bounded? %d\n",
	       cheri_subset_test(bounded, restricted));
	printf("untagged ⊂ restricted? %d\n",
	       cheri_subset_test(restricted, untagged));
	printf("offset ⊂ bounded? %d\n",
	       cheri_subset_test(bounded, offset));
	// capability_subset#end
	return 0;
}
