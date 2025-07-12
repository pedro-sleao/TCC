from functools import wraps
from flask import request, jsonify
from config import Config

def require_apikey(function):
    @wraps(function)
    def decorated_function(*args, **kwargs):
        if request.method:
            if request.headers.get('x-api-key') == Config.API_KEY:
                return function(*args, **kwargs)
            else:
                response = jsonify({'message': 'Não autorizado.'})
                return response, 401
        else:
            return function(*args, **kwargs)
    return decorated_function
