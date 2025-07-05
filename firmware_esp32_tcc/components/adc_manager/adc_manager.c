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
sensor_adc_config_t sensor_adc_map[SENSOR_LENGTH];

static bool adc_calibration_init(adc_unit_t unit, adc_channel_t channel, adc_atten_t atten, adc_cali_handle_t *out_handle)
{
    adc_cali_handle_t handle = NULL;
    esp_err_t ret = ESP_FAIL;
    bool calibrated = false;

    if (!calibrated) {
        ESP_LOGI(TAG, "calibration scheme version is %s", "Line Fitting");
        adc_cali_line_fitting_config_t cali_config = {
            .unit_id = unit,
            .atten = atten,
            .bitwidth = ADC_BITWIDTH_DEFAULT,
        };
        ret = adc_cali_create_scheme_line_fitting(&cali_config, &handle);
        if (ret == ESP_OK) {
            calibrated = true;
        }
    }

    *out_handle = handle;
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "Calibration Success");
    } else if (ret == ESP_ERR_NOT_SUPPORTED || !calibrated) {
        ESP_LOGW(TAG, "eFuse not burnt, skip software calibration");
    } else {
        ESP_LOGE(TAG, "Invalid arg or no memory");
    }

    return calibrated;
}

static void adc_calibration_deinit(adc_cali_handle_t handle)
{
    ESP_LOGI(TAG, "deregister %s calibration scheme", "Line Fitting");
    ESP_ERROR_CHECK(adc_cali_delete_scheme_line_fitting(handle));
}

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

    for (int i = 0; i < SENSOR_LENGTH; i++) {
        sensor_adc_map[i].channel = sensor_adc_channels[i];
        ESP_ERROR_CHECK(adc_oneshot_config_channel(adc1_handle, sensor_adc_channels[i], &config));
        ESP_LOGI(TAG, "Channel %d successfully configured!", sensor_adc_channels[i]);
    }
}

void adc_deinit(void) {
    ESP_LOGI(TAG, "Deinitializing ADC1...");
    ESP_ERROR_CHECK(adc_oneshot_del_unit(adc1_handle));
}

void read_adc_value(sensor_type_t sensor_type, int *sensor) {
    ESP_LOGI(TAG, "Starting to read the channel %d...", sensor_adc_channels[sensor_type]);

    vTaskDelay(pdMS_TO_TICKS(500));
    adc_oneshot_read(adc1_handle, sensor_adc_channels[sensor_type], sensor);
}

void read_adc_voltage(sensor_type_t sensor_type, float *sensor) {
    int adc_value;
    int temp;
    ESP_LOGI(TAG, "Starting to read the channel %d...", sensor_adc_channels[sensor_type]);

    adc_calibration_init(ADC_UNIT_1, sensor_adc_map[sensor_type].channel, ADC_ATTEN_DB_12, &sensor_adc_map[sensor_type].cali_handle);

    vTaskDelay(pdMS_TO_TICKS(500));
    adc_oneshot_read(adc1_handle, sensor_adc_channels[sensor_type], &adc_value);

    adc_cali_raw_to_voltage(sensor_adc_map[sensor_type].cali_handle, adc_value, &temp);

    adc_calibration_deinit(sensor_adc_map[sensor_type].cali_handle);

    *sensor = temp/(float)1000;
}

void get_adc_avarage(sensor_type_t sensor_type, int *sensor, int n) {
    ESP_LOGI(TAG, "Starting to read the channel %d...", sensor_adc_channels[sensor_type]);

    int adc_value = 0;
    int temp = 0;

    for (int i = 0; i < n; i++) {
        vTaskDelay(pdMS_TO_TICKS(100));
        adc_oneshot_read(adc1_handle, sensor_adc_channels[sensor_type], &temp);
        adc_value += temp;
    }

    *sensor = adc_value/n;
}

void get_adc_avarage_voltage(sensor_type_t sensor_type, float *sensor, int n) {
    ESP_LOGI(TAG, "Starting to read the channel %d...", sensor_adc_channels[sensor_type]);

    int voltage_value = 0;
    float sum = 0;
    int temp = 0;

    adc_calibration_init(ADC_UNIT_1, sensor_adc_map[sensor_type].channel, ADC_ATTEN_DB_12, &sensor_adc_map[sensor_type].cali_handle);

    for (int i = 0; i < n; i++) {
        vTaskDelay(pdMS_TO_TICKS(100));
        adc_oneshot_read(adc1_handle, sensor_adc_channels[sensor_type], &temp);
        adc_cali_raw_to_voltage(sensor_adc_map[sensor_type].cali_handle, temp, &voltage_value);
        sum += voltage_value/(float)1000;
    }

    adc_calibration_deinit(sensor_adc_map[sensor_type].cali_handle);

    *sensor = sum/n;
}



