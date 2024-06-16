const username = '123.456.789-00';
const password = '123';

// Construa e execute a consulta SQL
const sql = `SELECT Userid FROM USERS WHERE IdLider = :username AND Password = :password`;
const binds = { username, password };

// Execute a consulta usando a biblioteca oracledb
connection.execute(sql, binds, (err, result) => {
  if (err) {
    console.error('Erro ao executar a consulta:', err.message);
    return;
  }
  
  if (result.rows.length > 0) {
    console.log('Login bem-sucedido! UserID:', result.rows[0].Userid);
  } else {
    console.log('Credenciais inválidas. Login falhou.');
  }
});
