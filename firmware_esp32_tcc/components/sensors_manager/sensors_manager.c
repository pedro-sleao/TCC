#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/gpio.h"

#include "sensors_manager.h"
#include "adc_manager.h"

const static char *TAG = "sensors_manager";

static const gpio_num_t sensor_pins[] = {
    GPIO_NUM_16,
    GPIO_NUM_17,
    GPIO_NUM_18,
    GPIO_NUM_19
};

static void enable_sensor(sensor_type_t sensor_type) {
    gpio_set_level(sensor_pins[sensor_type], 1);
}

static void disable_sensor(sensor_type_t sensor_type) {
    gpio_set_level(sensor_pins[sensor_type], 0);
}

static void sensors_manager_task(void *parm) {
    for (int i = 0; i < sizeof(sensor_pins) / sizeof(sensor_pins[0]); i++) {
        gpio_set_direction(sensor_pins[i], GPIO_MODE_OUTPUT);
        ESP_LOGI(TAG, "GPIO %d successfully configured!", sensor_pins[i]);
    }

    int turbidity;

    while (1) {
        adc_init();
        enable_sensor(TURBIDITY_SENSOR);
        read_adc_value(TURBIDITY_SENSOR, &turbidity);
        disable_sensor(TURBIDITY_SENSOR);
        adc_deinit();

        ESP_LOGI(TAG, "Turbidity = %d", turbidity);
        vTaskDelay(pdMS_TO_TICKS(10000));
    }
}

void init_sensors_task(void) {
    ESP_LOGI(TAG, "Initializing sensors manager task...");
    xTaskCreate(sensors_manager_task, "sensors_manager_task", 4096, NULL, 3, NULL);
}

