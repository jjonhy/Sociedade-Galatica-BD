from flask import Flask, request, jsonify
from flask_cors import CORS
import oracledb

app = Flask(__name__)
CORS(app)  # Habilita CORS para todos os endpoints

# Informações de conexão
un = 'a12677492'
pw = 'a12677492'
host = 'orclgrad1.icmc.usp.br'
port = 1521
service_name = 'pdb_elaine.icmc.usp.br'

dsn = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST={host})(PORT={port}))(CONNECT_DATA=(SERVICE_NAME={service_name})))"

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                sql = "SELECT Userid FROM USERS WHERE IdLider = :username AND Password = :password"
                cursor.execute(sql, [username, password])
                result = cursor.fetchone()
                if result:
                    return jsonify({"message": "Login successful", "userid": result[0]}), 200
                else:
                    return jsonify({"message": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

@app.route('/role', methods=['POST'])  # Usando POST para receber JSON no corpo da requisição
def get_role():
    data = request.json
    cpi = data.get('username')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                sql = "SELECT cargo FROM LIDER WHERE CPI = :cpi"
                cursor.execute(sql, {'cpi': cpi})
                result = cursor.fetchone()
                
                if result:
                    return jsonify({"role": result[0]}), 200
                else:
                    return jsonify({"message": "Role not found"}), 404
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500
  
if __name__ == '__main__':
    app.run(debug=True)
