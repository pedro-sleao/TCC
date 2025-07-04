#pragma once

#include "sensors_manager.h"

#define V_MAX 2.45
#define D_MAX 4095

void adc_init(void);
void adc_deinit(void);
void read_adc_value(sensor_type_t sensor_type, int *sensor);
void read_adc_voltage(sensor_type_t sensor_type, float *sensor);
