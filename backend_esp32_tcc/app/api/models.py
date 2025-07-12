import datetime

from app import db

class Sensores(db.Model):
    __tablename__ = 'sensores'
    id = db.Column(db.Integer, primary_key=True)
    id_placa = db.Column(db.String(40))
    temperatura = db.Column(db.Float)
    turbidez = db.Column(db.Integer)
    ph = db.Column(db.Float)
    tds = db.Column(db.Float)
    data = db.Column(db.DateTime)

    def __init__(self, id_placa, temperatura, turbidez, ph, tds, data):
        self.id_placa = id_placa
        self.temperatura = temperatura
        self.turbidez = turbidez
        self.ph = ph
        self.tds = tds
        self.data = data

class Placas(db.Model):
    __tablename__ = 'placas'
    id_placa = db.Column(db.String(40), primary_key=True)
    local = db.Column(db.String(40))
    tempratura = db.Column(db.Boolean)
    turbidez = db.Column(db.Boolean)
    ph = db.Column(db.Boolean)
    tds = db.Column(db.Boolean)
    status = db.Column(db.Boolean)

    def __init__(self, id_placa, status):
        self.id_placa = id_placa
        self.local = None
        self.temperatura = None
        self.turbidez = None
        self.ph = None
        self.tds = None
        self.status = status

class Users(db.Model):
    __tablename__ = 'usuarios'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    role = db.Column(db.String(20), nullable=False, default='user')
    creation_date = db.Column(db.DateTime)

    def __init__(self, username, password, datetime):
        self.username = username
        self.password = password
        self.creation_date = datetime

