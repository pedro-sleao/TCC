#pragma once

#include "freertos/event_groups.h"

#define MQTT_OTA_EVENT BIT0
#define MQTT_SEND_DATA_EVENT BIT1

extern char ota_url[256];

void mqtt_app_start(void);
void mqtt_publish(const char *topic, const char *message);
EventBits_t mqtt_event_get_bits(void);
void mqtt_event_clear_bits(EventBits_t bit);
