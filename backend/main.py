from flask import Flask, request, jsonify, session, redirect
from flask_cors import CORS
import oracledb
import json

app = Flask(__name__)
CORS(app)  # Habilita CORS para todos os endpoints
app.secret_key = 'your_secret_key'  # Chave secreta para gerenciar sessões, altere para uma chave segura

# Informações de conexão
cred = json.load(open('credentials_oracle.json'))

un = cred['username']
pw = cred['password']
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
                    session['username'] = username  # Armazena o username na sessão
                    return jsonify({"message": "Login successful", "username": username}), 200
                else:
                    return jsonify({"message": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

@app.route('/role', methods=['POST'])
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

@app.route('/check_auth', methods=['GET'])
def check_auth():
    if 'username' in session:
        username = session['username']
        try:
            with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
                with connection.cursor() as cursor:
                    sql = "SELECT cargo FROM LIDER WHERE CPI = :username"
                    cursor.execute(sql, [username])
                    result = cursor.fetchone()
                    if result:
                        return jsonify({"role": result[0]}), 200
                    else:
                        return jsonify({"message": "Role not found"}), 404
        except Exception as e:
            return jsonify({"message": f"An error occurred: {e}"}), 500
    else:
        return jsonify({"message": "User not authenticated"}), 401

@app.route('/username', methods=['POST'])
def username():
    username = request.json.get('username')  
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                sql = "SELECT nome FROM LIDER WHERE CPI = :username"
                cursor.execute(sql, [username])
                result = cursor.fetchone()
                if result:
                    return jsonify({"name": result[0]}), 200
                else:
                    return jsonify({"message": "Name not found"}), 404
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

    
@app.route('/incluir_federacao', methods=['POST'])
def incluir_federacao():
    data = request.json
    cpi = data.get('cpi')
    nome_fd = data.get('nome_fd')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteComandante.incluir_federacao_na_nacao', [cpi, nome_fd])
        return jsonify({"message": "Federação incluída com sucesso"}), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

@app.route('/excluir_federacao', methods=['POST'])
def excluir_federacao():
    data = request.json
    cpi = data.get('cpi')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteComandante.excluir_federacao_da_nacao', [cpi])
        return jsonify({"message": "Federação excluída com sucesso"}), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500


@app.route('/criar_federacao', methods=['POST'])
def criar_federacao():
    data = request.json
    cpi = data.get('cpi')
    nome_fd = data.get('nome_fd')
    data_fund = data.get('data_fund', 'SYSDATE')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteComandante.criar_federacao', [cpi, nome_fd, data_fund])
        return jsonify({"message": "Federação criada com sucesso"}), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

@app.route('/inserir_dominancia', methods=['POST'])
def inserir_dominancia():
    data = request.json
    cpi = data.get('cpi')
    planeta = data.get('planeta')
    data_ini = data.get('data_ini', 'SYSDATE')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteComandante.insere_dominancia', [cpi, planeta, data_ini])
        return jsonify({"message": "Dominância inserida com sucesso"}), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

@app.route('/api/relatorio/cientista/<tipo>', methods=['GET'])
def obter_relatorio(tipo):
    try:
        if tipo == 'estrela':
            relatorio = consulta_relatorio_estrelas()
        elif tipo == 'planeta':
            relatorio = consulta_relatorio_planetas()
        elif tipo == 'sistema':
            relatorio = consulta_relatorio_sistemas()
        else:
            return jsonify({"message": f"Tipo de relatório não suportado: {tipo}"}), 400
        
        return jsonify(relatorio), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

def consulta_relatorio_estrelas():
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                # Chamar a função do package PacoteComandante para obter informações de estrelas
                cursor.callproc('PacoteComandante.consulta_informacoes_estrategicas', [None, None])
                # Exemplo básico de como obter os resultados
                result = cursor.fetchall()
                return {"tipo": "estrela", "dados": result}
    except Exception as e:
        raise e

def consulta_relatorio_planetas():
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                # Chamar a função do package PacoteComandante para obter informações de planetas
                cursor.callproc('PacoteComandante.consulta_informacoes_estrategicas', [None, None])
                # Exemplo básico de como obter os resultados
                result = cursor.fetchall()
                return {"tipo": "planeta", "dados": result}
    except Exception as e:
        raise e

def consulta_relatorio_sistemas():
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                # Chamar a função do package PacoteComandante para obter informações de sistemas
                cursor.callproc('PacoteComandante.consulta_informacoes_estrategicas', [None, None])
                # Exemplo básico de como obter os resultados
                result = cursor.fetchall()
                return {"tipo": "sistema", "dados": result}
    except Exception as e:
        raise e
    
@app.route('/api/relatorio/oficial', defaults={'agrupamento': None}, methods=['POST'])
@app.route('/api/relatorio/oficial/<agrupamento>', methods=['POST'])
def consulta_relatorio_oficial(agrupamento = None):
    try:
        data = request.json
        cpi = data.get('username')
        if agrupamento in ['planeta', 'especie', 'faccao', 'sistema']:
            relatorio = executa_funcao('Oficial', 'evolucao_habitantes_por_{agrupamento}', [cpi])
        else:
            relatorio = executa_funcao('Oficial', 'evolucao_habitantes', [cpi])
        return jsonify(relatorio), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500
    
def executa_funcao(pacote: str, funcao: str, parametros: list):
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                refcursor = cursor.callfunc(f'Pacote{pacote}.{funcao}', oracledb.CURSOR, parametros)
                result = refcursor.fetchall()
                return {"tipo": pacote, "dados": result}
    except Exception as e:
        raise e

@app.route('/api/comunidades_faccao', methods=['GET'])
def consulta_relatorio_lider():
    try:
        relatorio = consulta_comunidades_faccao()
        return jsonify(relatorio), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

def consulta_comunidades_faccao():
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                # Chamar a função do package PacoteLider para obter informações de evolução de habitantes
                refcursor = cursor.callfunc('PacoteLider.comunidades_faccao', oracledb.CURSOR, session['username'])  # Substitua pelo CPI do oficial correto
                result = refcursor.fetchall()
                # Exemplo básico de como obter os resultados
                return {"tipo": "lider", "dados": result}
    except Exception as e:
        raise e


if __name__ == '__main__':
    app.run(debug=True)
