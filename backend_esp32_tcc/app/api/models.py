import datetime

from app import db

class Sensores(db.Model):
    __tablename__ = 'sensors'
    id = db.Column(db.Integer, primary_key=True)
    id_placa = db.Column(db.String(40))
    temperature = db.Column(db.Float, nullable=True)
    turbidity = db.Column(db.Integer, nullable=True)
    ph = db.Column(db.Float, nullable=True)
    tds = db.Column(db.Float, nullable=True)
    data = db.Column(db.DateTime)


class Placas(db.Model):
    __tablename__ = 'devices'
    id_placa = db.Column(db.String(40), primary_key=True)
    local = db.Column(db.String(40))
    temperature = db.Column(db.Boolean)
    turbidity = db.Column(db.Boolean)
    ph = db.Column(db.Boolean)
    tds = db.Column(db.Boolean)
    status = db.Column(db.Boolean)
    firmware_version = db.Column(db.String(40))

    def __init__(self, id_placa, status, firmware_version):
        self.id_placa = id_placa
        self.local = ""
        self.temperature = None
        self.turbidity = None
        self.ph = None
        self.tds = None
        self.status = status
        self.firmware_version = firmware_version

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

