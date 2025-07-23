#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_log.h"
#include "esp_event.h"
#include "mqtt_client.h"
#include "esp_mac.h"
#include "esp_wifi.h"

#include "mqtt_service.h"
#include "device_info.h"
#include "sensors_manager.h"

static const char *TAG = "mqtt";

static EventGroupHandle_t mqtt_event_group;
static esp_mqtt_client_handle_t client;

char ota_url[256];
char status_topic[64];
char status_message[64];
const char* device_id_str;
const char* firmware_version;

static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
    ESP_LOGD(TAG, "Event dispatched from event loop base=%s, event_id=%" PRIi32, base, event_id);
    esp_mqtt_event_handle_t event = event_data;
    esp_mqtt_client_handle_t client = event->client;
    static char firmware_update_topic[64];
    static char send_data_topic[64];
    static char ph_calibration_topic[64];
    static char tds_calibration_topic[64];
    // Sensor calibration
    static float ph_expected_value, tds_expected_value;
    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT_EVENT_CONNECTED");
        snprintf(status_message, sizeof(status_message), "{\"status\": \"1\", \"firmware_version\": \"%s\"}", firmware_version);
        esp_mqtt_client_publish(client, status_topic, status_message, 0, 1, 0);
        ESP_LOGI(TAG, "Published LWT status to topic='%s'", status_topic);

        snprintf(ph_calibration_topic, sizeof(ph_calibration_topic), "devices/%s/ph_calibration", device_id_str);
        esp_mqtt_client_subscribe(client, ph_calibration_topic, 0);
        ESP_LOGI(TAG, "Subscribed to topic %s", ph_calibration_topic);

        snprintf(tds_calibration_topic, sizeof(tds_calibration_topic), "devices/%s/tds_calibration", device_id_str);
        esp_mqtt_client_subscribe(client, tds_calibration_topic, 0);
        ESP_LOGI(TAG, "Subscribed to topic %s", tds_calibration_topic);

        snprintf(send_data_topic, sizeof(send_data_topic), "devices/%s/send_data", device_id_str);
        esp_mqtt_client_subscribe(client, send_data_topic, 0);
        ESP_LOGI(TAG, "Subscribed to topic %s", send_data_topic);

        snprintf(firmware_update_topic, sizeof(firmware_update_topic), "devices/%s/firmware_update", device_id_str);
        esp_mqtt_client_subscribe(client, firmware_update_topic, 0);
        ESP_LOGI(TAG, "Subscribed to topic %s", firmware_update_topic);

        break;
    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGI(TAG, "MQTT_EVENT_DISCONNECTED");
        break;
    case MQTT_EVENT_SUBSCRIBED:
        ESP_LOGI(TAG, "MQTT_EVENT_SUBSCRIBED, msg_id=%d", event->msg_id);
        break;
    case MQTT_EVENT_UNSUBSCRIBED:
        ESP_LOGI(TAG, "MQTT_EVENT_UNSUBSCRIBED, msg_id=%d", event->msg_id);
        break;
    case MQTT_EVENT_PUBLISHED:
        ESP_LOGI(TAG, "MQTT_EVENT_PUBLISHED, msg_id=%d", event->msg_id);
        break;
    case MQTT_EVENT_DATA:
        ESP_LOGI(TAG, "MQTT_EVENT_DATA");
        printf("TOPIC=%.*s\r\n", event->topic_len, event->topic);
        printf("DATA=%.*s\r\n", event->data_len, event->data);
        if (strncmp(event->topic, firmware_update_topic, event->topic_len) == 0) {
            xEventGroupSetBits(mqtt_event_group, MQTT_OTA_EVENT);
            strncpy(ota_url, event->data, event->data_len);
        }

        if (strncmp(event->topic, send_data_topic, event->topic_len) == 0) {
            xEventGroupSetBits(mqtt_event_group, MQTT_SEND_DATA_EVENT);
        }

        if (strncmp(event->topic, ph_calibration_topic, event->topic_len) == 0) {
            char data_str[32] = {0};
            snprintf(data_str, sizeof(data_str), "%.*s", event->data_len, event->data);
            ph_expected_value = atof(data_str);
            init_calibrate_ph_task(&ph_expected_value);
        }

        if (strncmp(event->topic, tds_calibration_topic, event->topic_len) == 0) {
            char data_str[32] = {0};
            snprintf(data_str, sizeof(data_str), "%.*s", event->data_len, event->data);
            tds_expected_value = atof(data_str);
            init_calibrate_tds_task(&tds_expected_value);
        }
        break;
    case MQTT_EVENT_ERROR:
        ESP_LOGI(TAG, "MQTT_EVENT_ERROR");
        if (event->error_handle->error_type == MQTT_ERROR_TYPE_TCP_TRANSPORT) {
            ESP_LOGI(TAG, "Last error code reported from esp-tls: 0x%x", event->error_handle->esp_tls_last_esp_err);
            ESP_LOGI(TAG, "Last tls stack error number: 0x%x", event->error_handle->esp_tls_stack_err);
            ESP_LOGI(TAG, "Last captured errno : %d (%s)",  event->error_handle->esp_transport_sock_errno,
                     strerror(event->error_handle->esp_transport_sock_errno));
        } else if (event->error_handle->error_type == MQTT_ERROR_TYPE_CONNECTION_REFUSED) {
            ESP_LOGI(TAG, "Connection refused error: 0x%x", event->error_handle->connect_return_code);
        } else {
            ESP_LOGW(TAG, "Unknown error type: 0x%x", event->error_handle->error_type);
        }
        break;
    default:
        ESP_LOGI(TAG, "Other event id:%d", event->event_id);
        break;
    }
}

void mqtt_app_start(void)
{
    device_id_str = device_info_get_id();
    firmware_version = get_firmware_version();
    
    snprintf(status_topic, sizeof(status_topic), "devices/%s/status", device_id_str);
    snprintf(status_message, sizeof(status_message), "{\"status\": \"0\", \"firmware_version\": \"%s\"}", firmware_version);

    const esp_mqtt_client_config_t mqtt_cfg = {
        .broker = {
            .address.uri = "mqtt://192.168.0.110:1883",
        },
        .session = {
            .last_will = {
                .topic = status_topic,
                .msg = status_message,
                .qos = 1,
                .retain = 1
            }
        }
        // .credentials = {
        //     .username = "usuario",
        //     .authentication = {
        //         .password = "senha"
        //     }
        // }
    };

    mqtt_event_group = xEventGroupCreate();

    client = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler, client);
    esp_mqtt_client_start(client);
}

void mqtt_publish(const char *topic, const char *message) {
    ESP_LOGI(TAG, "Sending message to topic %s.", topic);
    esp_mqtt_client_publish(client, topic, message, 0, 1, 0);
}

EventBits_t mqtt_event_get_bits(void)
{
    return xEventGroupGetBits(mqtt_event_group);
}

void mqtt_event_clear_bits(EventBits_t bit)
{
    xEventGroupClearBits(mqtt_event_group, bit);
}