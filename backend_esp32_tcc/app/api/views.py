import marshmallow.exceptions
import os
from datetime import datetime, timedelta
from flask_jwt_extended import create_access_token, jwt_required, get_jwt, get_jwt_identity
from flask import request, jsonify, send_from_directory, current_app
from sqlalchemy import and_
from sqlalchemy.dialects.postgresql import  aggregate_order_by
from werkzeug.security import generate_password_hash, check_password_hash
from statistics import mean

from . import api_bp
from .models import Sensores, Placas, Users
from .schemas import SensoresGETSchema, PlacasSchema, UsersSchema, ArgsRequestsSchema
from ..db import db
from ..socketio.sockets import socketio
from .helper import require_apikey
from ..mqtt import mqtt_client

# Caminho para a pasta do firmware
current_path = os.path.abspath(__file__)
app_folder = os.path.dirname(current_path)
firmware_folder = os.path.join(app_folder, 'firmware_file')

@api_bp.route('/api/dados/placas', methods=['GET', 'POST'])
@jwt_required()
def get_nodes_data():
    columns = Placas.__table__.columns.keys()

    if request.method == 'GET':
        args = request.args

        try:
            validated_args = ArgsRequestsSchema().load(args)
        except marshmallow.exceptions.ValidationError as err:
            return jsonify({'message': err.messages}), 400

        filtered_args = {k: v for k, v in validated_args.items() if v is not None and k in columns}
        filters = []

        for key, value in filtered_args.items():
            filters.append(getattr(Placas, key) == value)

        dados = Placas.query.filter(and_(*filters)).all()

        dados_formatados = PlacasSchema(many=True).dump(dados)

        return jsonify(dados_formatados)

    if request.method == 'POST':
        new_data = request.get_json()

        try:
            validated_data = PlacasSchema().load(new_data)
        except marshmallow.exceptions.ValidationError as err:
            return jsonify({'error': err.messages}), 400

        # Verifica se as chaves da requisição existem
        received_keys = set(new_data.keys())
        invalid_keys = received_keys - set(columns)
        if invalid_keys:
            return jsonify({'error': f'Chave(s) inválida(s) detectada(s): {", ".join(invalid_keys)}'}), 400

        id_placa = new_data.get('id_placa')
        placa = Placas.query.filter_by(id_placa=id_placa).first()

        if not placa:
            return jsonify({'error': 'ID não encontrado no banco de dados'}), 400

        placa.local = validated_data.get('local')
        placa.temperature = validated_data.get('temperature')
        placa.tds = validated_data.get('tds')
        placa.turbidity = validated_data.get('turbidity')
        placa.ph = validated_data.get('ph')

        db.session.commit()

        return jsonify({'message': 'Dados adicionados corretamente.'})

@api_bp.route('/api/placas/ota', methods=['POST'])
@jwt_required()
def upload_file():
    if 'firmware' not in request.files:
        return 'Arquivo não encontrado', 400
    file = request.files['firmware']

    os.makedirs(firmware_folder, exist_ok=True)

    file.save(os.path.join(firmware_folder, file.filename))

    # URL do firmware
    ota_url = f"http://{current_app.config['LOCAL_IP']}:5000/firmware/{file.filename}"

    # Busca todos os devices do banco
    devices = Placas.query.all()

    # Publica a URL para cada device
    for device in devices:
        topic = f"devices/{device.id_placa}/firmware_update"
        mqtt_client.publish(topic, ota_url)


    return jsonify({'message': 'Dados adicionados corretamente.'}), 200

@api_bp.route('/api/sensores/calibracao', methods=['POST'])
@jwt_required()
def calibrate_sensors():
    calibration_json = request.get_json()

    # Verifica se as chaves da requisição existem
    received_keys = set(calibration_json.keys())
    invalid_keys = received_keys - set(["id_placa", "ph", "tds"])
    if invalid_keys:
        return jsonify({'error': f'Chave(s) inválida(s) detectada(s): {", ".join(invalid_keys)}'}), 400

    id_placa = calibration_json.get('id_placa')
    
    ph_value = calibration_json.get('ph')
    if ph_value is not None:
        sensor_value = ph_value
        topic = f"devices/{id_placa}/ph_calibration"
        mqtt_client.publish(topic, sensor_value)
    else:
        sensor_value = calibration_json.get('tds')
        topic = f"devices/{id_placa}/tds_calibration"
        mqtt_client.publish(topic, sensor_value)

    return jsonify({'message': 'Dados enviados corretamente.'}), 200


@api_bp.route('/api/dados/sensores', methods=['GET'])
@jwt_required()
def get_sensor_data():
    args = request.args

    try:
        validated_args = ArgsRequestsSchema().load(args)
    except marshmallow.exceptions.ValidationError as err:
        return jsonify({'message': err.messages}), 400

    filtered_args = {k: v for k, v in validated_args.items() if v is not None}
    filters = []

    for key, value in filtered_args.items():
        if key == 'data_inicial':
            filters.append(getattr(Sensores, 'data') >= value)
        if key == 'data_final':
            filters.append(getattr(Sensores, 'data') <= value)
        if key == 'dias_passados':
            filters.append(getattr(Sensores, 'data') >= datetime.now() - timedelta(days=value))
        if key == 'id_placa':
            filters.append(getattr(Sensores, 'id_placa') == value)
        if key == 'local':
            filters.append(getattr(Placas, 'local') == value)

    dados = (db.session.query(
        Sensores.id_placa,
        Placas.local,
        db.func.array_agg(aggregate_order_by(Sensores.temperature, Sensores.data.asc())).label('temperature'),
        db.func.array_agg(aggregate_order_by(Sensores.tds, Sensores.data.asc())).label('tds'),
        db.func.array_agg(aggregate_order_by(Sensores.turbidity, Sensores.data.asc())).label('turbidity'),
        db.func.array_agg(aggregate_order_by(Sensores.ph, Sensores.data.asc())).label('ph'),
        db.func.array_agg(aggregate_order_by(Sensores.data, Sensores.data.asc())).label('data'),
    ).join(Sensores, Sensores.id_placa == Placas.id_placa).filter(and_(*filters))
     .group_by(Sensores.id_placa, Placas.local).all())

    dados_formatados = SensoresGETSchema(many=True).dump(dados)

    return jsonify(dados_formatados)

@api_bp.route('/api/sensores/novos_dados', methods=['POST'])
@jwt_required()
def send_new_data():
    data = request.get_json()

    local_req = data.get("local")

    placas = Placas.query.filter_by(local=local_req).all()

    for placa in placas:
        topic = f"devices/{placa.id_placa}/send_data"
        mqtt_client.publish(topic, "1")

    return jsonify({'message': 'Novos dados solicitados.'}), 200

@api_bp.route('/api/dados/local', methods=['GET'])
@jwt_required()
def get_data_by_local():
    args = request.args

    try:
        validated_args = ArgsRequestsSchema().load(args)
    except marshmallow.exceptions.ValidationError as err:
        return jsonify({'message': err.messages}), 400

    filtered_args = {k: v for k, v in validated_args.items() if v is not None}
    filters = []

    for key, value in filtered_args.items():
        if key == 'data_inicial':
            filters.append(getattr(Sensores, 'data') >= value)
        if key == 'data_final':
            filters.append(getattr(Sensores, 'data') <= value)
        if key == 'dias_passados':
            filters.append(getattr(Sensores, 'data') >= datetime.now() - timedelta(days=value))
        if key == 'local':
            filters.append(getattr(Placas, 'local') == value)

    dados = (db.session.query(
        Placas.local,
        db.func.array_agg(aggregate_order_by(Sensores.temperature, Sensores.data.asc())).label('temperature'),
        db.func.array_agg(aggregate_order_by(Sensores.tds, Sensores.data.asc())).label(
            'tds'),
        db.func.array_agg(aggregate_order_by(Sensores.turbidity, Sensores.data.asc())).label('turbidity'),
        db.func.array_agg(aggregate_order_by(Sensores.ph, Sensores.data.asc())).label('ph'),
        db.func.array_agg(aggregate_order_by(Sensores.data, Sensores.data.asc())).label('data'),
    ).join(Placas, Sensores.id_placa == Placas.id_placa).filter(and_(*filters))
     .group_by(Placas.local).all())

    dados_formatados = SensoresGETSchema(many=True).dump(dados)
    metrics = {}

    if dados_formatados:
        for sensor, sensor_data in dados_formatados[0].items():
            if isinstance(sensor_data, list) and sensor != 'data':
                sensor_data = list(filter(None, sensor_data))
                max_value = max(sensor_data) if sensor_data else None
                min_value = min(sensor_data) if sensor_data else None
                mov_avg = round(mean(sensor_data)) if sensor_data and len(sensor_data) > 0 else None
                metrics[sensor] = {
                    'valor_maximo': max_value,
                    'valor_minimo': min_value,
                    'media': mov_avg
                }

    if dados_formatados:
        if 'dias_passados' not in filtered_args.keys() or filtered_args['dias_passados'] == 30:
            days_list = []
            for data in dados_formatados[0]['data']:
                day = data.split('T')[0]
                if day not in days_list:
                    days_list.append(day)

            day_values = []
            new_sensor_list = []
            min_values = []
            max_values = []
            for key, value in dados_formatados[0].copy().items():
                if key != 'local' and key != 'data':
                    for i in days_list:
                        for j in range(len(value)):
                            if i == dados_formatados[0]['data'][j].split('T')[0]:
                                day_values.append(value[j])
                            else:
                                pass
                        if any(day_values):
                            day_values = [i for i in day_values if i is not None]
                            min_values.append(min(day_values))
                            max_values.append(max(day_values))
                            new_sensor_list.append(round(mean(day_values)))
                            day_values = []
                        else:
                            new_sensor_list.append(None)
                    dados_formatados[0][key] = new_sensor_list
                    dados_formatados[0][key + '_min'] = min_values
                    dados_formatados[0][key + '_max'] = max_values
                    new_sensor_list = []
                    min_values = []
                    max_values = []

            dados_formatados[0]['data'] = days_list

    return jsonify({'dados': dados_formatados, 'metricas': metrics})

@api_bp.route('/usuarios/cadastro', methods=['POST'])
@jwt_required()
def post_user():
    claims = get_jwt()

    if claims['role'] == 'admin':
        username = request.json['username']
        password = request.json['password']

        try:
            UsersSchema().load(request.get_json())
        except marshmallow.exceptions.ValidationError as err:
            return jsonify({'error': err.messages}), 400

        password_hash = generate_password_hash(password)

        if username and password and not Users.query.filter(Users.username == username).first():
            user = Users(username=username, password=password_hash, datetime=datetime.now())
        else:
            return jsonify({'message': 'Nome de usuário indisponível.'}), 409

        try:
            db.session.add(user)
            db.session.commit()
            result = UsersSchema().dump(user)
            return jsonify({'message': 'Usuário cadastrado com sucesso.', 'data': result}), 201
        except Exception as e:
            return jsonify({'message': f'Erro ao tentar realizar o cadastro: {str(e)}'}), 500
    else:
        return jsonify({'message': 'Não autorizado'}), 401

@api_bp.route('/usuarios/<username>', methods=['DELETE'])
@jwt_required()
def delete_user(username):
    user = Users.query.filter_by(username=username).first()

    if not user:
        return jsonify({'message': 'Usuário não encontrado.'}), 404

    try:
        db.session.delete(user)
        db.session.commit()
        result = UsersSchema().dump(user)
        return jsonify({'message': 'Usuário deletado com sucesso.', 'data': result})
    except Exception as e:
        return jsonify({'message': f'Erro ao deletar usuário: {str(e)}'}), 500

@api_bp.route('/usuarios', methods=['GET'])
@jwt_required()
def get_users():
    users = Users.query.filter(Users.role != 'admin').all()

    if users:
        result = UsersSchema(many=True).dump(users)
        return jsonify({'message': 'Dados dos usuários obtidos com sucesso.', 'data': result})

    return jsonify({'message': 'Nenhum usuário encontrado', 'data': []})

@api_bp.route('/usuario', methods=['GET'])
@jwt_required()
def get_user_by_jwt():
    username = get_jwt_identity()

    user = Users.query.filter_by(username=username).first()

    if user:
        result = UsersSchema().dump(user)
        return jsonify({'message': 'Dados dos usuários obtidos com sucesso.', 'data': result})

    return jsonify({'message': 'Nenhum usuário encontrado'})

@api_bp.route('/login', methods=['GET'])
@require_apikey
def auth():
    auth = request.authorization

    if not auth or not auth.username or not auth.password:
        return jsonify({'message': 'Não foi possível verificar a autorização'}), 401

    try:
        user = Users.query.filter(Users.username == auth.username).one()
    except Exception as e:
        return jsonify({'message': 'Usuário não encontrado'}), 401

    if user and check_password_hash(user.password, auth.password):
        access_token = create_access_token(identity=auth.username, additional_claims={'role': user.role})
        return jsonify({'message': 'Usuário validado com sucesso.', 'access_token': access_token, 'role': user.role}), 200
    else:
        return jsonify({'message': 'Usuário e/ou senha inválidos.'}), 401
    
@api_bp.route('/firmware/<filename>')
def download_firmware(filename):
    return send_from_directory(firmware_folder, filename, as_attachment=True)
    
