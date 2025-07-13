from . import mqtt_client
from ..db import db
from ..api.models import Sensores, Placas, Users
from flask import current_app
import json

@mqtt_client.on_connect()
def handle_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    mqtt_client.subscribe('devices/+/status')
    mqtt_client.subscribe('sensors/+/temperature')
    mqtt_client.subscribe('sensors/+/tds')
    mqtt_client.subscribe('sensors/+/ph')
    mqtt_client.subscribe('sensors/+/turbidity')

@mqtt_client.on_message()
def handle_mqtt_message(client, userdata, message):
    print('Received message on topic {}: {}'.format(
        message.topic, message.payload.decode()))

    topic = message.topic
    payload = message.payload.decode()

    if "devices" in topic:
        handle_devices(topic, payload)
    else:
        handle_sensors(topic, payload)


def handle_devices(topic, payload):
    with mqtt_client.app.app_context():
        device_id = topic.split('/')[1]

        status_str = str(payload).strip()

        if status_str.isdigit():
            status = int(status_str) != 0
        else:
            status = False
            
        device = Placas.query.filter_by(id_placa=device_id).first()

        if device:
            # Se a placa existe, atualiza o status
            device.status = status
        else:
            # Se não existe, cria uma nova placa
            device = Placas(id_placa=device_id, status=status)
        
        db.session.add(device)
        db.session.commit()

def handle_sensors(topic, payload):
    with mqtt_client.app.app_context():
        topic_split = topic.split('/')
        device_id = topic_split[1]
        sensor_type = topic_split[2]

        payload_json = json.loads(payload)
        sensor_value = payload_json[sensor_type]
        timestamp = payload_json["timestamp"]

        sensor = Sensores.query.filter_by(id_placa=device_id, data=timestamp).first()

        if sensor:
            setattr(sensor, sensor_type, sensor_value)
            print(f"[INFO] Atualizando sensores: {device_id} - {timestamp}")
        else:
            sensor = Sensores(
                id_placa=device_id,
                data=timestamp,
                **{sensor_type: sensor_value}
            )
            db.session.add(sensor)
            print(f"[INFO] Criando uma nova medicao: {device_id} - {timestamp}")

        db.session.commit()
