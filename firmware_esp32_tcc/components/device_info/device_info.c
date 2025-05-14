#include "device_info.h"
#include "esp_system.h"
#include "esp_mac.h"
#include <stdio.h>

static char device_id_str[18];

void device_info_init(void) {
    uint8_t mac[6];
    esp_efuse_mac_get_default(mac);
    snprintf(device_id_str, sizeof(device_id_str),
             "%02X:%02X:%02X:%02X:%02X:%02X",
             mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}

const char* device_info_get_id(void) {
    return device_id_str;
}
