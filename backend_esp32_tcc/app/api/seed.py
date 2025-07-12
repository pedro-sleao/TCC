from flask import Flask
from flask_cors import CORS
from werkzeug.security import generate_password_hash
from datetime import datetime

from .models import db, Users
from config import Config

def seed_admin():
    app = Flask(__name__)
    CORS(app)
    app.app_context().push()
    app.config.from_object(Config)

    db.init_app(app)

    with app.app_context():
        admin = Users.query.filter_by(username='admin').first()
        if not admin:
            admin = Users(username='admin', password=generate_password_hash('admin'), datetime=datetime.now())
            admin.role = 'admin'
            db.session.add(admin)
            db.session.commit()
            print("Usuário admin criado com sucesso!")
        else:
            print("Usuário admin já existe.")

if __name__ == '__main__':
    seed_admin()
