from marshmallow import Schema, fields, validate

class SensoresGETSchema(Schema):
    id = fields.Int(dump_only=True)
    id_placa = fields.Int(required=True)
    local = fields.Str()
    latitude = fields.Str()
    longitude = fields.Str()
    temperatura_do_solo = fields.List(fields.Int())
    temperatura_do_ar = fields.List(fields.Int())
    umidade_do_solo = fields.List(fields.Int())
    umidade_do_ar = fields.List(fields.Int())
    iluminacao = fields.List(fields.Int())
    data = fields.List(fields.DateTime(required=True))

class SensoresPOSTSchema(Schema):
    id = fields.Int(dump_only=True)
    id_placa = fields.Int(required=True)
    temperatura_do_solo = fields.Int()
    temperatura_do_ar = fields.Int()
    umidade_do_solo = fields.Int()
    umidade_do_ar = fields.Int()
    iluminacao = fields.Int()
    data = fields.DateTime(required=True)

class PlacasSchema(Schema):
    id_placa = fields.Int(required=True)
    local = fields.Str()
    latitude = fields.Float()
    longitude = fields.Float()
    temperatura_do_solo = fields.Bool()
    temperatura_do_ar = fields.Bool()
    umidade_do_solo = fields.Bool()
    umidade_do_ar = fields.Bool()
    iluminacao = fields.Bool()

class UsersSchema(Schema):
    id = fields.Int(dump_only=True)
    username = fields.Str(required=True)
    password = fields.Str(required=True)
    role = fields.Str()

class ArgsRequestsSchema(Schema):
    data_inicial = fields.DateTime()
    data_final = fields.DateTime()
    local = fields.Str()
    dias_passados = fields.Number()
    id_placa = fields.Int()
    latitude = fields.Float()
    longitude = fields.Float()
    temperatura_do_solo = fields.Bool()
    temperatura_do_ar = fields.Bool()
    umidade_do_solo = fields.Bool()
    umidade_do_ar = fields.Bool()
    iluminacao = fields.Bool()
