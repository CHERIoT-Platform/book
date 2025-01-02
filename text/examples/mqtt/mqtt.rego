# Copyright CHERIoT Contributors.
# SPDX-License-Identifier: MIT

package mqtt

import future.keywords.every

# network_stack#begin
# Rule for defining 
valid(ethernetDevice) {
	# Check the integrity of the network stack
	data.network_stack.valid(ethernetDevice)
	# network_stack#end

	# connection_capabilities#begin
	# Check that only the authorised set of remote hosts are
	# allowed
	count(data.network_stack.all_connection_capabilities) == 2

	{
		"capability": {
			"connection_type": "UDP",
			"host": "pool.ntp.org",
			"port": 123
		},
		"owner": "SNTP"
	} in data.network_stack.all_connection_capabilities

	{
		"capability": {
			"connection_type": "TCP",
			"host": "test.mosquitto.org",
			"port": 8883
		},
		"owner": "mqtt_example"
	} in data.network_stack.all_connection_capabilities
	# connection_capabilities#end

	# send_restrictions#begin
	# Restrict which compartments can send data
	data.compartment.compartment_call_allow_list(
		"TCPIP",
		`network_socket_send\(.*`,
		{ "TLS" })
	data.compartment.compartment_call_allow_list(
		"TCPIP",
		`network_socket_send_to\(.*`,
		{ "SNTP" })
	# send_restrictions#end
}
