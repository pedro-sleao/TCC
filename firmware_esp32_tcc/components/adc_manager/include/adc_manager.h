#pragma once

#include "sensors_manager.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"

#define V_MAX 2.45
#define D_MAX 4095
#define SENSOR_LENGTH 4

typedef struct {
    adc_channel_t channel;
    adc_cali_handle_t cali_handle;
} sensor_adc_config_t;

void adc_init(void);
void adc_deinit(void);
void read_adc_value(sensor_type_t sensor_type, int *sensor);
void read_adc_voltage(sensor_type_t sensor_type, float *sensor);
void get_adc_avarage(sensor_type_t sensor_type, int *sensor, int n);
