idf_component_register(SRCS "sensors_manager.c"
                    INCLUDE_DIRS "include"
                    REQUIRES "driver" "adc_manager" "ds18x20" "mqtt_service" "device_info" "time_sync" "nvs_flash")
