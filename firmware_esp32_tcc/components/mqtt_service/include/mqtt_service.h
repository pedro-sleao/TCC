#pragma once

#include "freertos/event_groups.h"

#define MQTT_OTA_EVENT BIT0

extern char ota_url[256];

void mqtt_app_start(void);
void mqtt_publish(const char *topic, const char *message);
EventBits_t mqtt_event_get_bits(void);