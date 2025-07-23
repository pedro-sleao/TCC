#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/gpio.h"
#include <time.h>
#include <math.h>
#include <sys/time.h>
#include "esp_sntp.h"
#include "nvs_flash.h"

#include "sensors_manager.h"
#include "adc_manager.h"
#include "ds18x20.h"
#include "mqtt_service.h"
#include "device_info.h"
#include "time_sync.h"

const static char *TAG = "sensors_manager";

SemaphoreHandle_t adc_mutex = NULL;

static const gpio_num_t sensor_pins[] = {
    GPIO_NUM_16,
    GPIO_NUM_17,
    GPIO_NUM_18,
    GPIO_NUM_19
};

static const onewire_addr_t TEMPERATURE_SENSOR_ADDR = 0x5e00000000f59728;

// Flash memory
nvs_handle_t my_handle;

// Sensors variables
float ph_voltage_6_86 = 1.735;
float ph_voltage_9_18 = 1.473;
float tds_correction_factor = 842 / (float) 930;

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
    float ph, ph_voltage, m, b;
    // Time variables
    time_t now;
    struct tm timeinfo;
    char strftime_buf[64];
    int last_measure_time = -1;
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

    // Event bits to check mqtt event
    EventBits_t uxBits;
    while (1) {
        time_sync_get_localtime(&now, &timeinfo);
        uxBits = mqtt_event_get_bits();
        if (((timeinfo.tm_hour % 3 == 0) && (timeinfo.tm_hour != last_measure_time)) || (uxBits & MQTT_SEND_DATA_EVENT)) {
            // Read sensors
            if (xSemaphoreTake(adc_mutex, pdMS_TO_TICKS(2500))) {
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

                xSemaphoreGive(adc_mutex);
            }
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
            // b = 6.86 + m*CALIBRACAO_PH6_86;
            m = (9.18 - 6.86)/(ph_voltage_6_86 - ph_voltage_9_18);
            b = 6.86 + m*ph_voltage_6_86;
            ph = -8.85*ph_voltage + 22.2;

            ESP_LOGI(TAG, "PH_M = %.2f", m);
            ESP_LOGI(TAG, "PH_B = %.2f", b);
            
            // Format time
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

            last_measure_time = timeinfo.tm_hour;
            mqtt_event_clear_bits(MQTT_SEND_DATA_EVENT);
            vTaskDelay(pdMS_TO_TICKS(1000));
        } else {
            vTaskDelay(pdMS_TO_TICKS(1000));
        }
    }
}

static void load_calibration() {
    esp_err_t err;

    ESP_LOGI(TAG, "Loading storaged calibration values");

    err = nvs_open("storage", NVS_READONLY, &my_handle);
    if (err != ESP_OK) {
        ESP_LOGW(TAG, "NVS open failed, using defaults: %s", esp_err_to_name(err));
    }

    size_t required_size = sizeof(ph_voltage_9_18);

    err = nvs_get_blob(my_handle, "calib_9_18", &ph_voltage_9_18, &required_size);
    if (err != ESP_OK) {
        ESP_LOGW(TAG, "Failed to read calib_9_18, using default");
    }

    required_size = sizeof(ph_voltage_6_86);
    err = nvs_get_blob(my_handle, "calib_6_86", &ph_voltage_6_86, &required_size);
    if (err != ESP_OK) {
        ESP_LOGW(TAG, "Failed to read calib_6_86, using default: %s", esp_err_to_name(err));
    }

    required_size = sizeof(tds_correction_factor);
    err = nvs_get_blob(my_handle, "calib_tds", &tds_correction_factor, &required_size);
    if (err != ESP_OK) {
        ESP_LOGW(TAG, "Failed to read calib_tds, using default: %s", esp_err_to_name(err));
    }

    nvs_close(my_handle);

    ESP_LOGI(TAG, "Calibration values loaded");
    ESP_LOGI(TAG, "calib_9_18 = %.2f", ph_voltage_9_18);
    ESP_LOGI(TAG, "calib_6_86 = %.2f", ph_voltage_6_86);
    ESP_LOGI(TAG, "calib_tds = %.2f", tds_correction_factor);
}

void init_sensors_task(void) {
    ESP_LOGI(TAG, "Initializing sensors manager task...");
    load_calibration();
    xTaskCreate(sensors_manager_task, "sensors_manager_task", 4096, NULL, 3, NULL);
}

static void calibrate_ph_task(void *parm) {
    esp_err_t err;

    float expected_value = *((float*)parm);
    float measured;

    if (xSemaphoreTake(adc_mutex, pdMS_TO_TICKS(6000))) {
        adc_init();
        enable_sensor(PH_SENSOR);
        get_adc_avarage_voltage(PH_SENSOR, &measured, 10);
        disable_sensor(PH_SENSOR);
        adc_deinit();
        xSemaphoreGive(adc_mutex);
    } else {
        ESP_LOGI(TAG, "Error on pH calibration");
        vTaskDelete(NULL);
    }

    err = nvs_open("storage", NVS_READWRITE, &my_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Error opening NVS handle!");
    }

    if (expected_value == 9.18) {
        ph_voltage_9_18 = measured;
        err = nvs_set_blob(my_handle, "calib_9_18", &ph_voltage_9_18, sizeof(ph_voltage_9_18));
        if (err != ESP_OK) {
            ESP_LOGE(TAG, "Failed to write calib_9_18");
        }
    } else {
        ph_voltage_6_86 = measured;
        err = nvs_set_blob(my_handle, "calib_6_86", &ph_voltage_6_86, sizeof(ph_voltage_6_86));
        if (err != ESP_OK) {
            ESP_LOGE(TAG, "Failed to write calib_6_86");
        }
    }

    err = nvs_commit(my_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to commit NVS");
    }   

    nvs_close(my_handle);

    ESP_LOGI(TAG, "pH calibration task done");
    vTaskDelete(NULL);
}

static void calibrate_tds_task(void *parm) {
    esp_err_t err;

    float expected_value = *((float*)parm);
    float measured;

    if (xSemaphoreTake(adc_mutex, pdMS_TO_TICKS(6000))) {
        adc_init();
        enable_sensor(TDS_SENSOR);
        get_adc_avarage_voltage(TDS_SENSOR, &measured, 10);
        disable_sensor(TDS_SENSOR);
        adc_deinit();
        xSemaphoreGive(adc_mutex);
    } else {
        ESP_LOGI(TAG, "Error on TDS calibration");
        vTaskDelete(NULL);
    }

    tds_correction_factor = expected_value / measured;

    err = nvs_open("storage", NVS_READWRITE, &my_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Error opening NVS handle!");
    }

    err = nvs_set_blob(my_handle, "calib_tds", &tds_correction_factor, sizeof(tds_correction_factor));
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to write calib_tds");
    }

    err = nvs_commit(my_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to commit NVS");
    }   

    nvs_close(my_handle);

    ESP_LOGI(TAG, "TDS calibration task done");
    vTaskDelete(NULL);
}

void init_calibrate_ph_task(float *expected_value) {
    ESP_LOGI(TAG, "Initializing ph calibration task...");
    xTaskCreate(calibrate_ph_task, "calibrate_ph_task", 2048, expected_value, 3, NULL);
}

void init_calibrate_tds_task(float *expected_value) {
    ESP_LOGI(TAG, "Initializing TDS calibration task...");
    xTaskCreate(calibrate_tds_task, "calibrate_tds_task", 2048, expected_value, 3, NULL);
}





