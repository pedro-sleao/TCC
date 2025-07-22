from marshmallow import Schema, fields, validate

class SensoresGETSchema(Schema):
    id = fields.Int(dump_only=True)
    id_placa = fields.Str(required=True)
    local = fields.Str()
    temperature = fields.List(fields.Float())
    tds = fields.List(fields.Float())
    turbidity = fields.List(fields.Int())
    ph = fields.List(fields.Float())
    data = fields.List(fields.DateTime(required=True))

class PlacasSchema(Schema):
    id_placa = fields.Str(required=True)
    local = fields.Str()
    temperature = fields.Bool()
    turbidity = fields.Bool()
    tds = fields.Bool()
    ph = fields.Bool()
    status = fields.Bool()
    firmware_version = fields.Str()

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
    id_placa = fields.Str()
    temperature = fields.Bool()
    tds = fields.Bool()
    turbidity = fields.Bool()
    ph = fields.Bool()
    status = fields.Bool()
