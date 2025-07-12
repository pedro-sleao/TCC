from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager

from .socketio import sockets
from .db import db
from config import Config
from .mqtt import init_mqtt

def create_app(config_class=Config):
    app = Flask(__name__)
    CORS(app)
    app.config.from_object(config_class)
    app.app_context().push()
    
    # Configuração do SocketIO
    sockets.init_websocket(app)

    db.init_app(app)
    jwt = JWTManager(app)

    from .api import api_bp
    from .socketio import socketio_bp

    app.register_blueprint(api_bp)
    app.register_blueprint(socketio_bp)

    db.create_all()

    init_mqtt(app)

    return app

