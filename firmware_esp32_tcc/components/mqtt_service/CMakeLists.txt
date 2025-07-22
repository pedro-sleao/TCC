idf_component_register(SRCS "mqtt_service.c"
                    INCLUDE_DIRS "include"
                    REQUIRES "esp_event" "mqtt" "esp_wifi" "device_info" "sensors_manager")
