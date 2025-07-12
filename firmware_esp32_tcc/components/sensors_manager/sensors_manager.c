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
#include "time_sync.h"

const static char *TAG = "sensors_manager";

static const gpio_num_t sensor_pins[] = {
    GPIO_NUM_16,
    GPIO_NUM_17,
    GPIO_NUM_18,
    GPIO_NUM_19
};

static const onewire_addr_t TEMPERATURE_SENSOR_ADDR = 0x5e00000000f59728;

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
    float tds_correction_factor = 842 / (float) 930;
    float temperature;
    float ph, ph_voltage, m, b;
    // Time variables
    time_t now;
    struct tm timeinfo;
    char strftime_buf[64];
    // Buffer for mqtt messages
    char topic[64];
    char message[128];

    // Get device id
    device_id_str = device_info_get_id();

    // Set timezone to Brazil (Recife)
    time_sync_set_timezone("<-03>3");

    // RTC config
    obtain_time();
    time_sync_get_localtime(&now, &timeinfo);

    for (int i = 0; i < sizeof(sensor_pins) / sizeof(sensor_pins[0]); i++) {
        gpio_set_direction(sensor_pins[i], GPIO_MODE_OUTPUT);
        ESP_LOGI(TAG, "GPIO %d successfully configured!", sensor_pins[i]);
    }

    while (1) {
        time(&now);
        localtime_r(&now, &timeinfo);
        if (timeinfo.tm_sec % 1 == 0) {
            // Read sensors
            adc_init();
            enable_sensor(TURBIDITY_SENSOR);
            get_adc_avarage(TURBIDITY_SENSOR, &turbidity_adc_value, 10);
            disable_sensor(TURBIDITY_SENSOR);

            enable_sensor(TDS_SENSOR);
            get_adc_avarage_voltage(TDS_SENSOR, &tds_voltage, 10);
            disable_sensor(TDS_SENSOR);

            enable_sensor(PH_SENSOR);
            get_adc_avarage_voltage(PH_SENSOR, &ph_voltage, 10);
            disable_sensor(PH_SENSOR);
            adc_deinit();
    
            enable_sensor(TEMPERATURE_SENSOR);
            ds18b20_measure_and_read(GPIO_NUM_4, TEMPERATURE_SENSOR_ADDR, &temperature);
            disable_sensor(TEMPERATURE_SENSOR);

            // Prepare message to mqtt
            // turbidity
            turbidity = fmaxf(0.0f, (1 - turbidity_adc_value/(float) TURBIDITY_MAX) * 100);

            // tds
            compensationCoefficient = 1.0+0.02*(temperature-25.0);    //temperature compensation formula: fFinalResult(25^C) = fFinalResult(current)/(1.0+0.02*(fTP-25.0));
            compensationVoltage = tds_voltage/compensationCoefficient;
            tds = fmaxf(0.0f, tds_correction_factor*(133.42*compensationVoltage*compensationVoltage*compensationVoltage - 255.86*compensationVoltage*compensationVoltage + 857.39*compensationVoltage)*0.5 - 59);
            
            // pH
            // m = (9.18 - 6.86)/(CALIBRACAO_PH6_86 - CALIBRACAO_PH_9_18);
            // b = 9.18 - m*CALIBRACAO_PH6_86;
            ph = -8.85*ph_voltage + 22.2;

            strftime(strftime_buf, sizeof(strftime_buf), "%Y-%m-%dT%H:%M:%S%z", &timeinfo);
            
            snprintf(topic, sizeof(topic), "sensors/%s/turbidity", device_id_str);
            snprintf(message, sizeof(message), "{\"timestamp\": \"%s\", \"turbidity\": %d}", strftime_buf, turbidity);
            mqtt_publish(topic, message);
            
            snprintf(topic, sizeof(topic), "sensors/%s/tds", device_id_str);
            snprintf(message, sizeof(message), "{\"timestamp\": \"%s\", \"tds\": %.2f}", strftime_buf, tds);
            mqtt_publish(topic, message);
            
            snprintf(topic, sizeof(topic), "sensors/%s/temperature", device_id_str);
            snprintf(message, sizeof(message), "{\"timestamp\": \"%s\", \"temperature\": %.2f}", strftime_buf, temperature);
            mqtt_publish(topic, message);

            snprintf(topic, sizeof(topic), "sensors/%s/ph", device_id_str);
            snprintf(message, sizeof(message), "{\"timestamp\": \"%s\", \"ph\": %.2f}", strftime_buf, ph);
            mqtt_publish(topic, message);
    
            ESP_LOGI(TAG, "Turbidity = %d", turbidity);
            ESP_LOGI(TAG, "Tds = %.2f", tds);
            ESP_LOGI(TAG, "Temperature = %.2f", temperature);
            ESP_LOGI(TAG, "pH = %.4f", ph);
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



