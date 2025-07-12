import marshmallow.exceptions
from datetime import datetime, timedelta
from flask_jwt_extended import create_access_token, jwt_required, get_jwt, get_jwt_identity
from flask import request, jsonify
from sqlalchemy import and_
from sqlalchemy.dialects.postgresql import  aggregate_order_by
from werkzeug.security import generate_password_hash, check_password_hash
from statistics import mean

from . import api_bp
from .models import Sensores, Placas, Users
from .schemas import SensoresGETSchema, SensoresPOSTSchema, PlacasSchema, UsersSchema, ArgsRequestsSchema
from ..db import db
from ..socketio.sockets import socketio
from .helper import require_apikey


@api_bp.route('/api/dados/id', methods=['GET'])
@require_apikey
def register_new_node():
    last_row = (db.session.query(
        Placas.id_placa,
    ).order_by(Placas.id_placa.desc()).first())

    id_placa = last_row.id_placa + 1 if last_row else 1

    placas = Placas(id_placa=id_placa)

    db.session.add(placas)
    db.session.commit()

    return str(id_placa)

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
        placa.latitude = validated_data.get('latitude')
        placa.longitude = validated_data.get('longitude')
        placa.temperatura_do_solo = validated_data.get('temperatura_do_solo')
        placa.temperatura_do_ar = validated_data.get('temperatura_do_ar')
        placa.umidade_do_solo = validated_data.get('umidade_do_solo')
        placa.umidade_do_ar = validated_data.get('umidade_do_ar')
        placa.iluminacao = validated_data.get('iluminacao')

        db.session.commit()

        return jsonify({'message': 'Dados adicionados corretamente.'})

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
        Placas.latitude,
        Placas.longitude,
        db.func.array_agg(aggregate_order_by(Sensores.temperatura_do_solo, Sensores.data.asc())).label(
            'temperatura_do_solo'),
        db.func.array_agg(aggregate_order_by(Sensores.temperatura_do_ar, Sensores.data.asc())).label(
            'temperatura_do_ar'),
        db.func.array_agg(aggregate_order_by(Sensores.umidade_do_solo, Sensores.data.asc())).label('umidade_do_solo'),
        db.func.array_agg(aggregate_order_by(Sensores.umidade_do_ar, Sensores.data.asc())).label('umidade_do_ar'),
        db.func.array_agg(aggregate_order_by(Sensores.iluminacao, Sensores.data.asc())).label('iluminacao'),
        db.func.array_agg(aggregate_order_by(Sensores.data, Sensores.data.asc())).label('data'),
    ).join(Sensores, Sensores.id_placa == Placas.id_placa).filter(and_(*filters))
     .group_by(Sensores.id_placa, Placas.local, Placas.latitude, Placas.longitude).all())

    dados_formatados = SensoresGETSchema(many=True).dump(dados)

    return jsonify(dados_formatados)

@api_bp.route('/api/dados/sensores', methods=['POST'])
@require_apikey
def send_sensor_data():
    columns = Sensores.__table__.columns.keys()

    new_data = request.get_json()

    try:
        validated_data = SensoresPOSTSchema().load(new_data)
    except marshmallow.exceptions.ValidationError as err:
        return jsonify({'error': err.messages}), 400

    id_placa = validated_data.get('id_placa')
    temperatura_do_solo = validated_data.get('temperatura_do_solo')
    temperatura_do_ar = validated_data.get('temperatura_do_ar')
    umidade_do_solo = validated_data.get('umidade_do_solo')
    umidade_do_ar = validated_data.get('umidade_do_ar')
    iluminacao = validated_data.get('iluminacao')
    data = validated_data.get('data')

    # Verifica se as chaves da requisição existem
    received_keys = set(new_data.keys())
    invalid_keys = received_keys - set(columns)
    if invalid_keys:
        return jsonify({'error': f'Chave(s) inválida(s) detectada(s): {", ".join(invalid_keys)}'}), 400

    # Verifica se a placa ja foi registrada
    query_id_placa = Placas.query.filter_by(id_placa=id_placa).first()
    if not query_id_placa:
        return jsonify({'error': 'ID não encontrado no banco de dados'}), 401

    # Adiciona os dados nas tabelas
    sensores = Sensores(id_placa, temperatura_do_solo, temperatura_do_ar, umidade_do_solo, umidade_do_ar, iluminacao,
                        data)
    db.session.add(sensores)
    db.session.commit()

    # Avisa aos clientes que chegaram novos dados
    socketio.emit('message', 'New data')

    return jsonify({'message': 'Dados adicionados corretamente.'})

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
        Placas.latitude,
        Placas.longitude,
        db.func.array_agg(aggregate_order_by(Sensores.temperatura_do_solo, Sensores.data.asc())).label(
            'temperatura_do_solo'),
        db.func.array_agg(aggregate_order_by(Sensores.temperatura_do_ar, Sensores.data.asc())).label(
            'temperatura_do_ar'),
        db.func.array_agg(aggregate_order_by(Sensores.umidade_do_solo, Sensores.data.asc())).label('umidade_do_solo'),
        db.func.array_agg(aggregate_order_by(Sensores.umidade_do_ar, Sensores.data.asc())).label('umidade_do_ar'),
        db.func.array_agg(aggregate_order_by(Sensores.iluminacao, Sensores.data.asc())).label('iluminacao'),
        db.func.array_agg(aggregate_order_by(Sensores.data, Sensores.data.asc())).label('data'),
    ).join(Placas, Sensores.id_placa == Placas.id_placa).filter(and_(*filters))
     .group_by(Placas.local, Placas.latitude, Placas.longitude).all())

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
                if key != 'local' and key != 'latitude' and key != 'longitude' and key != 'data':
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

    return jsonify({'message': 'Nenhum usuário encontrado'})

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
