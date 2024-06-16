from flask import Flask, request, jsonify, session, redirect
from flask_cors import CORS
import oracledb

app = Flask(__name__)
CORS(app)  # Habilita CORS para todos os endpoints
app.secret_key = 'your_secret_key'  # Chave secreta para gerenciar sessões, altere para uma chave segura

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

@app.route('/api/alterar_nome_faccao', methods=['POST'])
def alterar_nome_faccao():
    data = request.json
    cpi = data.get('cpi')
    novoNome = data.get('novoNome')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteLider.alterar_nome_faccao', [cpi, novoNome])
        return jsonify({"message": "Nome alterado com sucesso"}), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500
    
@app.route('/api/indicar_novo_lider_faccao', methods=['POST'])
def indicar_novo_lider_faccao():
    data = request.json
    cpi = data.get('cpi')
    novoLider = data.get('novoLider')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteLider.indicar_novo_lider_faccao', [cpi, novoLider])
        return jsonify({"message": "Nome alterado com sucesso"}), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500
    
@app.route('/api/remover_faccao_de_nacao', methods=['POST'])
def remover_faccao_de_nacao():
    data = request.json
    cpi = data.get('cpi')
    faccao = data.get('faccao')
    nacao = data.get('nacao')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteLider.remove_faccao_da_nacao', [cpi, nacao, faccao])
        return jsonify({"message": "Nome alterado com sucesso"}), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500
    
@app.route('/api/credenciar_comunidades', methods=['POST'])
def credenciar_comunidades():
    data = request.json
    cpi = data.get('cpi')
    
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                cursor.callproc('PacoteLider.credenciar_comunidades', [cpi])
        return jsonify({"message": "Credenciamento realizado com sucesso"}), 200
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

@app.route('/api/relatorio/<tipo>', methods=['GET'])
def obter_relatorio(tipo):
    try:
        if tipo == 'estrela':
            relatorio = consulta_informacoes_estrategicas()
        elif tipo == 'planeta':
            relatorio = consulta_relatorio_planetas()
        elif tipo == 'sistema':
            relatorio = consulta_relatorio_sistemas()
        else:
            return jsonify({"message": f"Tipo de relatório não suportado: {tipo}"}), 400
        
        return jsonify(relatorio), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

def consulta_informacoes_estrategicas():
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                # Criar tipos de dados Oracle para os parâmetros de saída
                type_informacoes_1 = cursor.var(oracledb.DB_TYPE_OBJECT, typename="T_INFORMACOES_1_TYPE", arraysize=100)
                type_informacoes_2 = cursor.var(oracledb.DB_TYPE_OBJECT, typename="T_INFORMACOES_2_TYPE", arraysize=100)

                # Chamar a procedure do package PacoteComandante para obter informações estratégicas
                cursor.callproc('PacoteComandante.consulta_informacoes_estrategicas', [type_informacoes_1, type_informacoes_2])

                # Obter os resultados dos parâmetros de saída
                informacoes_1 = type_informacoes_1.getvalue()
                informacoes_2 = type_informacoes_2.getvalue()

                result_1 = [dict(zip(row.keys(), row)) for row in informacoes_1]
                result_2 = [dict(zip(row.keys(), row)) for row in informacoes_2]

                return {"informacoes_1": result_1, "informacoes_2": result_2}
    except Exception as e:
        raise e
    
def consulta_relatorio_estrelas():
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                # Chamar a função do package PacoteComandante para obter informações de estrelas
                cursor.callfunc('PacoteComandante.consulta_informacoes_estrategicas', [None, None])
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
    
@app.route('/api/relatorio/oficial', methods=['GET'])
def consulta_relatorio_oficial():
    try:
        relatorio = consulta_evolucao_habitantes_oficial()
        return jsonify(relatorio), 200
    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500

def consulta_evolucao_habitantes_oficial():
    try:
        with oracledb.connect(user=un, password=pw, dsn=dsn) as connection:
            with connection.cursor() as cursor:
                # Chamar a função do package PacoteOficial para obter informações de evolução de habitantes
                cursor.callproc('PacoteOficial.evolucao_habitantes', ['111.111.111-15'])  # Substitua pelo CPI do oficial correto
                # Exemplo básico de como obter os resultados
                result = cursor.fetchall()
                return {"tipo": "oficial", "dados": result}
    except Exception as e:
        raise e


@app.route('/estrelas', methods=['GET', 'POST'])
def gerenciar_estrelas():
    if request.method == 'GET':
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM ESTRELA")
        estrelas = cursor.fetchall()
        cursor.close()
        return jsonify(estrelas)
    
    if request.method == 'POST':
        data = request.get_json()
        cursor = conn.cursor()
        try:
            cursor.callproc('PacoteCientista.cria_estrela', [data['id'], data['x'], data['y'], data['z'], data['nome'], data['classificacao'], data['massa']])
            conn.commit()
            return '', 201
        except cx_Oracle.Error as error:
            return str(error), 400
        finally:
            cursor.close()

@app.route('/estrelas/<int:id>', methods=['DELETE'])
def deletar_estrela(id):
    cursor = conn.cursor()
    try:
        cursor.callproc('PacoteCientista.deleta_estrela', [id])
        conn.commit()
        return '', 204
    except cx_Oracle.Error as error:
        return str(error), 400
    finally:
        cursor.close()

@app.route('/relatorios/<string:tipo>', methods=['GET'])
def relatorios(tipo):
    limite = request.args.get('limite', default=10, type=int)
    cursor = conn.cursor()
    try:
        if tipo == 'estrelas':
            cursor.callproc('PacoteCientista.relatorio_estrela', [limite])
        elif tipo == 'planetas':
            cursor.callproc('PacoteCientista.relatorio_planeta', [limite])
        elif tipo == 'sistemas':
            cursor.callproc('PacoteCientista.relatorio_sistema', [limite])
        else:
            return 'Tipo inválido', 400

        result = []
        for row in cursor:
            result.append(row)
        return jsonify(result)
    except cx_Oracle.Error as error:
        return str(error), 400
    finally:
        cursor.close()

if __name__ == '__main__':
    app.run(debug=True)
