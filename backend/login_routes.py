from flask import Blueprint, request, jsonify
from main import connect_to_oracle  # Importar a função connect_to_oracle

login_routes = Blueprint('login_routes', __name__)

@login_routes.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    try:
        with connect_to_oracle() as connection:
            with connection.cursor() as cursor:
                sql = "SELECT Userid FROM USERS WHERE IdLider = :username AND Password = :password"
                cursor.execute(sql, [username, password])
                result = cursor.fetchone()
                if result:
                    return jsonify({"message": "Login successful", "userid": result[0]}), 200
                else:
                    return jsonify({"message": "Invalid credentials"}), 401
    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({"message": f"An error occurred: {e}"}), 500

