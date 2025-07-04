#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_http_client.h"
#include "esp_https_ota.h"
#include "esp_mac.h"
#include "esp_log.h"

#include "mqtt_service.h"

static const char *TAG = "simple_ota_example";

static esp_err_t _http_event_handler(esp_http_client_event_t *evt)
{
    switch (evt->event_id) {
    case HTTP_EVENT_ERROR:
        ESP_LOGD(TAG, "HTTP_EVENT_ERROR");
        break;
    case HTTP_EVENT_ON_CONNECTED:
        ESP_LOGD(TAG, "HTTP_EVENT_ON_CONNECTED");
        break;
    case HTTP_EVENT_HEADER_SENT:
        ESP_LOGD(TAG, "HTTP_EVENT_HEADER_SENT");
        break;
    case HTTP_EVENT_ON_HEADER:
        ESP_LOGD(TAG, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key, evt->header_value);
        break;
    case HTTP_EVENT_ON_DATA:
        ESP_LOGD(TAG, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
        break;
    case HTTP_EVENT_ON_FINISH:
        ESP_LOGD(TAG, "HTTP_EVENT_ON_FINISH");
        break;
    case HTTP_EVENT_DISCONNECTED:
        ESP_LOGD(TAG, "HTTP_EVENT_DISCONNECTED");
        break;
    case HTTP_EVENT_REDIRECT:
        ESP_LOGD(TAG, "HTTP_EVENT_REDIRECT");
        break;
    }
    return ESP_OK;
}

static void ota_task(void *pvParameter)
{
    EventBits_t uxBits;
    while (1) {
        uxBits = mqtt_event_get_bits();
        if (uxBits & MQTT_OTA_EVENT) {
            ESP_LOGI(TAG, "Starting OTA example task");
            esp_http_client_config_t config = {
                .url = ota_url,
                .event_handler = _http_event_handler,
                .keep_alive_enable = true,
            };

            esp_https_ota_config_t ota_config = {
                .http_config = &config,
            };
            ESP_LOGI(TAG, "Attempting to download update from %s", config.url);
            esp_err_t ret = esp_https_ota(&ota_config);
            if (ret == ESP_OK) {
                ESP_LOGI(TAG, "OTA Succeed, Rebooting...");
                esp_restart();
            } else {
                ESP_LOGE(TAG, "Firmware upgrade failed");
                mqtt_event_clear_bits();
            }
        }
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
}

void init_ota(void)
{
    xTaskCreate(&ota_task, "ota_example_task", 8192, NULL, 5, NULL);
}