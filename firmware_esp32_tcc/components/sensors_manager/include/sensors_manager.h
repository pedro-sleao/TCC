#pragma once

#define TURBIDITY_MAX 2300
#define CALIBRACAO_PH6_86 1.735
#define CALIBRACAO_PH_9_18 1.473

extern SemaphoreHandle_t adc_mutex;

typedef enum {
    TEMPERATURE_SENSOR,
    TDS_SENSOR,
    PH_SENSOR,
    TURBIDITY_SENSOR
} sensor_type_t;


void init_sensors_task(void);
void init_calibrate_ph_task(float *expected_value);
