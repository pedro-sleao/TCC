from datetime import timedelta

class Config:
    JSON_SORT_KEYS = False

    # db config
    SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:db_esp32_tcc@localhost/postgres'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # api config
    API_KEY = 'U2FsdGVkX1+/NFD9Q8L0gGIddIW+ULsOBvHi+LTQD3s='
    
    # JWT config
    JWT_SECRET_KEY = 'U2FsdGVkX185+S007ffKbYVD+XDqjA/7heeI7BTv+z2qhYqDTyS0A4OMwLQYHAQV'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=1)

    # MQTT config
    MQTT_BROKER_URL = "localhost"
    MQTT_BROKER_PORT = 1883
    MQTT_CLIENT_ID = "flask_mqtt"
    MQTT_USERNAME = ''
    MQTT_PASSWORD = ''
    MQTT_KEEPALIVE = 5

    # ip config
    LOCAL_IP = "192.168.1.10"