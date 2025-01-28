idf_component_register(SRCS "ota.c"
                    INCLUDE_DIRS "include"
                    REQUIRES "mqtt_service" "esp_http_client" "esp_https_ota" "esp_partition")
