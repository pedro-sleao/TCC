from flask_socketio import SocketIO, emit

socketio = SocketIO(cors_allowed_origins="*")

def init_websocket(app):
    socketio.init_app(app)

    @socketio.on('connect')
    def handle_connect():
        print('Client connected!')

    @socketio.on('message')
    def handle_message(msg):
        print(f'New message: {msg}')
