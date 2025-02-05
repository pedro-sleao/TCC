#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"
#include "esp_log.h"

#include "adc_manager.h"

const static char *TAG = "adc_manager";

static const adc_channel_t sensor_adc_channels[] = {
    ADC_CHANNEL_0,
    ADC_CHANNEL_3,
    ADC_CHANNEL_4,
    ADC_CHANNEL_5
};

adc_oneshot_unit_handle_t adc1_handle;

void adc_init(void) {
    ESP_LOGI(TAG, "Initializing ADC1...");

    adc_oneshot_unit_init_cfg_t init_config1 = {
        .unit_id = ADC_UNIT_1,
    };

    ESP_ERROR_CHECK(adc_oneshot_new_unit(&init_config1, &adc1_handle));

    adc_oneshot_chan_cfg_t config = {
        .atten = ADC_ATTEN_DB_12,
        .bitwidth = ADC_BITWIDTH_DEFAULT,
    };

    for (int i = 0; i < sizeof(sensor_adc_channels) / sizeof(sensor_adc_channels[0]); i++) {
        ESP_ERROR_CHECK(adc_oneshot_config_channel(adc1_handle, sensor_adc_channels[i], &config));
        ESP_LOGI(TAG, "Channel %d successfully configured!", sensor_adc_channels[i]);
    }
}

void read_adc_value(sensor_type_t sensor_type, int *sensor) {
    ESP_LOGI(TAG, "Starting to read the channel %d...", sensor_adc_channels[sensor_type]);

    adc_oneshot_read(adc1_handle, sensor_adc_channels[sensor_type], sensor);
}
