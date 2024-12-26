#include <cheri.hh>
#include <stdio.h>
#include <stdlib.h>

// print_capability#begin
void print_capability(CHERI::Capability<void> ptr)
{
	using P                          = CHERI::Permission;
	ptraddr_t            address     = ptr.address();
	CHERI::PermissionSet permissions = ptr.permissions();
	printf("0x%x (valid:%d length: 0x%x 0x%x-0x%x otype:%d "
	       "permissions: %c "
	       "%c%c%c%c%c%c %c%c %c%c%c)\n",
	       address,
	       ptr.is_valid(),
	       ptr.length(),
	       ptr.base(),
	       ptr.top(),
	       ptr.type(),
	       (permissions.contains(P::Global)) ? 'G' : '-',
	       (permissions.contains(P::Load)) ? 'R' : '-',
	       (permissions.contains(P::Store)) ? 'W' : '-',
	       (permissions.contains(P::LoadStoreCapability))
	         ? 'c'
	         : '-',
	       (permissions.contains(P::LoadGlobal)) ? 'g' : '-',
	       (permissions.contains(P::LoadMutable)) ? 'm' : '-',
	       (permissions.contains(P::StoreLocal)) ? 'l' : '-',
	       (permissions.contains(P::Seal)) ? 'S' : '-',
	       (permissions.contains(P::Unseal)) ? 'U' : '-',
	       (permissions.contains(P::Global)) ? '0' : '-');
}
// print_capability#end

__cheri_compartment("example") int entry(void)
{
	// capability_manipulation#begin
	// A stack allocation
	char stackBuffer[23];
	print_capability(stackBuffer);
	// A heap allocation
	CHERI::Capability<void> heapBuffer = new char[23];
	print_capability(heapBuffer);
	// Setting the bounds of a heap capability
	auto bounded     = heapBuffer;
	bounded.bounds() = 23;
	print_capability(bounded);
	// Removing permissions from a heap capability
	bounded.permissions() &= CHERI::Permission::Load;
	print_capability(bounded);
	print_capability(heapBuffer);
	// capability_manipulation#end

	// capability_equality#begin
	printf("heapBuffer == bounded? %d\n",
	       heapBuffer == bounded);
	printf("heapBuffer == bounded (as raw pointers)? %d\n",
	       heapBuffer.get() == bounded.get());
	printf(
	  "heapBuffer == bounded (as address comparison)? %d\n",
	  heapBuffer.address() == bounded.address());
	// capability_equality#end
	return 0;
}
