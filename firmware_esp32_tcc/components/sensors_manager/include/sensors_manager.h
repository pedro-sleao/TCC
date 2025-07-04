#pragma once

typedef enum {
    TEMPERATURE_SENSOR,
    TDS_SENSOR,
    PH_SENSOR,
    TURBIDITY_SENSOR
} sensor_type_t;

#define TURBIDITY_MAX 2034

void init_sensors_task(void);
