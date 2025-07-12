from flask_mqtt import Mqtt

mqtt_client = Mqtt()

def init_mqtt(app):
    from . import callbacks

    mqtt_client.init_app(app)
