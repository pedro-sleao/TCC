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
    

def handle_devices(topic, payload):
    with mqtt_client.app.app_context():
        id_placa = topic.split('/')[1]

        status_str = str(payload).strip()

        if status_str.isdigit():
            status = int(status_str) != 0
        else:
            status = False
            
        placa = Placas.query.filter_by(id_placa=id_placa).first()

        print(placa, status)
        if placa:
            # Se a placa existe, atualiza o status
            placa.status = status
        else:
            # Se não existe, cria uma nova placa
            placa = Placas(id_placa=id_placa, status=status)
        
        db.session.add(placa)
        db.session.commit()
