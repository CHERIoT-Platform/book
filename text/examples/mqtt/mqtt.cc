// Copyright SCI Semiconductor and CHERIoT Contributors.
// SPDX-License-Identifier: MIT

#include <NetAPI.h>
#include <cstdlib>
#include <debug.hh>
#include <fail-simulator-on-error.h>
#include <mqtt.h>
#include <sntp.h>
#include <tick_macros.h>

#include "mosquitto.org.h"

using CHERI::Capability;

using Debug = ConditionalDebug<true, "MQTT example">;
constexpr bool UseIPv6 = CHERIOT_RTOS_OPTION_IPv6;

/// Maximum permitted MQTT client identifier length (from
/// the MQTT specification)
constexpr size_t MQTTMaximumClientLength = 23;
/// Space for the random client ID.
std::array<char, MQTTMaximumClientLength> clientID;

// MQTT network buffer sizes
constexpr const size_t networkBufferSize    = 1024;
constexpr const size_t incomingPublishCount = 20;
constexpr const size_t outgoingPublishCount = 20;

// MQTT test broker: https://test.mosquitto.org/
// Note: port 8883 is encrypted and unautenticated
DECLARE_AND_DEFINE_CONNECTION_CAPABILITY(
  MosquittoOrgMQTT,
  "test.mosquitto.org",
  8883,
  ConnectionTypeTCP);

DECLARE_AND_DEFINE_ALLOCATOR_CAPABILITY(mqttTestMalloc,
                                        32 * 1024);

constexpr std::string_view testTopic{
  "cheriot-book-example"};
constexpr std::string_view testPayload{"Cheriots of fire!"};

static int ackReceived     = 0;
static int publishReceived = 0;

// publish_callback#begin
void __cheri_callback
publishCallback(const char *topicName,
                size_t      topicNameLength,
                const void *payload,
                size_t      payloadLength)
{
	Debug::log(
	  "Got a PUBLISH for topic {}: {}",
	  std::string_view{topicName, topicNameLength},
	  std::string_view{static_cast<const char *>(payload),
	                   payloadLength});
	publishReceived++;
}
// publish_callback#end

// ack_callback#begin
void __cheri_callback ackCallback(uint16_t packetID,
                                  bool     isReject)
{
	Debug::log("Got an ACK for packet {}", packetID);
	if (isReject)
	{
		Debug::log(
		  "However the ACK is a SUBSCRIBE REJECT notification");
	}
	ackReceived++;
}
// ack_callback#end

void __cheri_compartment("mqtt_example") example()
{
	int     ret;
	Timeout t{MS_TO_TICKS(5000)};

	network_start();

	// SNTP must be run for the TLS stack to be able to check
	// certificate dates.
	while (sntp_update(&t) != 0)
	{
		Debug::log("Failed to update NTP time");
		Timeout oneSecond{MS_TO_TICKS(1000)};
		t = Timeout{MS_TO_TICKS(5000)};
	}
	t = UnlimitedTimeout;

	// client_id#begin
	Debug::log("Generating client ID...");
	constexpr std::string_view clientIDPrefix{"cheriotMQTT"};
	// Prefix with something recognizable, for convenience.
	memcpy(clientID.data(),
	       clientIDPrefix.data(),
	       clientIDPrefix.size());
	// Suffix with random character chain.
	mqtt_generate_client_id(
	  clientID.data() + clientIDPrefix.size(),
	  clientID.size() - clientIDPrefix.size());
	// client_id#end

	// connecting#begin
	Debug::log("Connecting to MQTT broker...");
	auto handle =
	  mqtt_connect(&t,
	               STATIC_SEALED_VALUE(mqttTestMalloc),
	               CONNECTION_CAPABILITY(MosquittoOrgMQTT),
	               publishCallback,
	               ackCallback,
	               TAs,
	               TAs_NUM,
	               networkBufferSize,
	               incomingPublishCount,
	               outgoingPublishCount,
	               clientID.data(),
	               clientID.size());

	if (!Capability{handle}.is_valid())
	{
		Debug::log("Failed to connect.");
		return;
	}
	// connecting#end

	Debug::log("Connected to MQTT broker!");

	Debug::log("Subscribing to test topic '{}'.", testTopic);

	// subscribe#begin
	ret = mqtt_subscribe(&t,
	                     handle,
	                     1, // QoS 1 = delivered at least once
	                     testTopic.data(),
	                     testTopic.size());
	Debug::Assert(
	  ret >= 0, "Failed to subscribe, error {}.", ret);
	// subscribe#end

	Debug::log("Now fetching the SUBACK.");

	// suback#begin
	while (ackReceived == 0)
	{
		t   = Timeout{MS_TO_TICKS(1000)};
		ret = mqtt_run(&t, handle);
		Debug::Assert(
		  ret >= 0,
		  "Failed to wait for the SUBACK, error {}.",
		  ret);
	}
	// suback#end

	Debug::log("Publishing a value to test topic '{}'.",
	           testTopic);

	t = Timeout{MS_TO_TICKS(5000)};
	// publish#begin
	ret = mqtt_publish(
	  &t,
	  handle,
	  1, // QoS 1 = delivered at least once
	  testTopic.data(),
	  testTopic.size(),
	  static_cast<const void *>(testPayload.data()),
	  testPayload.size());
	Debug::Assert(
	  ret >= 0, "Failed to publish, error {}.", ret);
	// publish#end

	Debug::log("Now fetching the PUBACK and waiting for the "
	           "publish notification.");

	while (publishReceived < 5)
	{
		t   = UnlimitedTimeout;
		ret = mqtt_run(&t, handle);

		if (ret < 0)
		{
			Debug::log(
			  "Failed to wait for the PUBACK/PUBLISH, error {}.",
			  ret);
			return;
		}
	}

	Debug::log("Unsubscribing from topic '{}'.", testTopic);

	t = Timeout{MS_TO_TICKS(5000)};
	ret =
	  mqtt_unsubscribe(&t,
	                   handle,
	                   1, // QoS 1 = delivered at least once
	                   testTopic.data(),
	                   testTopic.size());

	if (ret < 0)
	{
		Debug::log("Failed to unsubscribe, error {}.", ret);
		return;
	}

	while (ackReceived == 2)
	{
		t   = Timeout{MS_TO_TICKS(100)};
		ret = mqtt_run(&t, handle);

		if (ret < 0)
		{
			Debug::log(
			  "Failed to wait for the UNSUBACK, error {}.", ret);
			return;
		}
	}

	Debug::log("Disconnecting from the broker.");

	t   = Timeout{MS_TO_TICKS(5000)};
	// disconnect#begin
	ret = mqtt_disconnect(
	  &t, STATIC_SEALED_VALUE(mqttTestMalloc), handle);
	Debug::Assert(
	  ret == 0, "Failed to disconnect, error {}.", ret);
	// disconnect#end
}
