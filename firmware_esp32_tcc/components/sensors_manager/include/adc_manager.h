#pragma once

#include "sensors_manager.h"

void adc_init(void);
void adc_deinit(void);
void read_adc_value(sensor_type_t sensor_type, int *sensor);
