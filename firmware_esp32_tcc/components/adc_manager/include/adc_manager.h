#pragma once

typedef enum {
    TEMPERATURE_SENSOR,  // Sensor de temperatura
    TDS_SENSOR,     // Sensor de umidade
    PH_SENSOR,        // Sensor de luminosidade
    TURBIDITY_SENSOR       // Valor para sensores desconhecidos
} sensor_type_t;

void adc_init(void);
void read_adc_value(sensor_type_t sensor_type, int *sensor);
