#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/gpio.h"
#include <time.h>
#include <math.h>
#include <sys/time.h>
#include "esp_sntp.h"

#include "sensors_manager.h"
#include "adc_manager.h"
#include "ds18x20.h"
#include "mqtt_service.h"
#include "device_info.h"

const static char *TAG = "sensors_manager";

static const gpio_num_t sensor_pins[] = {
    GPIO_NUM_16,
    GPIO_NUM_17,
    GPIO_NUM_18,
    GPIO_NUM_19
};

static const onewire_addr_t TEMPERATURE_SENSOR_ADDR = 0x5e00000000f59728;

static void initialize_sntp(void)
{
    ESP_LOGI(TAG, "Initializing SNTP");
    esp_sntp_setoperatingmode(SNTP_OPMODE_POLL);
    esp_sntp_setservername(0, "pool.ntp.org");
    esp_sntp_init();
}

static void obtain_time(void)
{
    initialize_sntp();

    time_t now = 0;
    struct tm timeinfo = { 0 };
    int retry = 0;
    const int retry_count = 10;

    while (timeinfo.tm_year < (2024 - 1900) && ++retry < retry_count) {
        ESP_LOGI(TAG, "Waiting for system time to be set... (%d/%d)", retry, retry_count);
        vTaskDelay(pdMS_TO_TICKS(2000));
        time(&now);
        localtime_r(&now, &timeinfo);
    }

    esp_sntp_stop();
}

static void enable_sensor(sensor_type_t sensor_type) {
    gpio_set_level(sensor_pins[sensor_type], 1);
}

static void disable_sensor(sensor_type_t sensor_type) {
    gpio_set_level(sensor_pins[sensor_type], 0);
}

static void sensors_manager_task(void *parm) {
    // Device id
    const char *device_id_str;
    // Sensors variables
    int turbidity_adc_value, turbidity;
    float tds_voltage, tds, compensationCoefficient, compensationVoltage;
    float temperature;
    // Time variables
    time_t now;
    struct tm timeinfo;
    char strftime_buf[64];
    // Buffer for mqtt messages
    char message[128];

    // Get device id
    device_id_str = device_info_get_id();

    // Set timezone to Brazil (Recife)
    setenv("TZ", "<-03>3", 1);
    tzset();
    // RTC config
    obtain_time();
    time(&now);
    localtime_r(&now, &timeinfo);

    for (int i = 0; i < sizeof(sensor_pins) / sizeof(sensor_pins[0]); i++) {
        gpio_set_direction(sensor_pins[i], GPIO_MODE_OUTPUT);
        ESP_LOGI(TAG, "GPIO %d successfully configured!", sensor_pins[i]);
    }

    while (1) {
        time(&now);
        localtime_r(&now, &timeinfo);
        if (timeinfo.tm_sec % 10 == 0) {
            // Read sensors
            adc_init();
            enable_sensor(TURBIDITY_SENSOR);
            get_adc_avarage(TURBIDITY_SENSOR, &turbidity_adc_value, 10);
            disable_sensor(TURBIDITY_SENSOR);

            enable_sensor(TDS_SENSOR);
            get_adc_avarage_voltage(TDS_SENSOR, &tds_voltage, 10);
            disable_sensor(TDS_SENSOR);
            adc_deinit();
    
            enable_sensor(TEMPERATURE_SENSOR);
            ds18b20_measure_and_read(GPIO_NUM_4, TEMPERATURE_SENSOR_ADDR, &temperature);
            disable_sensor(TEMPERATURE_SENSOR);

            // Prepare message to mqtt
            turbidity = fmaxf(0.0f, (1 - turbidity_adc_value/(float) TURBIDITY_MAX) * 100);
            compensationCoefficient = 1.0+0.02*(temperature-25.0);    //temperature compensation formula: fFinalResult(25^C) = fFinalResult(current)/(1.0+0.02*(fTP-25.0));
            compensationVoltage = tds_voltage/compensationCoefficient;
            tds = (133.42*compensationVoltage*compensationVoltage*compensationVoltage - 255.86*compensationVoltage*compensationVoltage + 857.39*compensationVoltage)*0.5;
            
            strftime(strftime_buf, sizeof(strftime_buf), "%Y-%m-%dT%H:%M:%S%z", &timeinfo);

            snprintf(message, sizeof(message), "{\"id\": \"%s\", \"timestamp\": \"%s\", \"turbidity\": %d}", device_id_str, strftime_buf, turbidity);
            mqtt_publish("sensor/turbidity", message);

            snprintf(message, sizeof(message), "{\"id\": \"%s\", \"timestamp\": \"%s\", \"tds\": %.2f}", device_id_str, strftime_buf, tds);
            mqtt_publish("sensor/tds", message);
    
            snprintf(message, sizeof(message), "{\"id\": \"%s\",\"timestamp\": \"%s\", \"temperature\": %.2f}", device_id_str, strftime_buf, temperature);
            mqtt_publish("sensor/temperature", message);
    
            ESP_LOGI(TAG, "Turbidity = %d", turbidity);
            ESP_LOGI(TAG, "Tds = %.2f", tds);
            ESP_LOGI(TAG, "Temperature = %.2f", temperature);
            ESP_LOGI(TAG, "The current date/time in Recife is: %s", strftime_buf);
            vTaskDelay(pdMS_TO_TICKS(1000));
        } else {
            vTaskDelay(pdMS_TO_TICKS(1000));
        }
    }
}

void init_sensors_task(void) {
    ESP_LOGI(TAG, "Initializing sensors manager task...");
    xTaskCreate(sensors_manager_task, "sensors_manager_task", 4096, NULL, 3, NULL);
}



