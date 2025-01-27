#include <stdio.h>
#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define LED_BUILTIN 2

void app_main(void)
{
    gpio_reset_pin(LED_BUILTIN);
    gpio_set_direction(LED_BUILTIN, GPIO_MODE_OUTPUT);

    while(1) {
        gpio_set_level(LED_BUILTIN, 0);
        vTaskDelay(250/portTICK_PERIOD_MS);
        gpio_set_level(LED_BUILTIN, 1);
        vTaskDelay(250/portTICK_PERIOD_MS);
    }
}