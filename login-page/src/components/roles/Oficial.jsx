import React, { useState, useEffect } from 'react';
import axios from 'axios';

export const Oficial = () => {
  const [nomeUsuario, setNomeUsuario] = useState('');

  useEffect(() => {
    // Função assíncrona para buscar o nome do usuário (cientista)
    const fetchNomeUsuario = async () => {
      try {
        // Faz a requisição para obter o nome do usuário (cientista)
        const username = localStorage.getItem('username'); // Obtém o username do localStorage

        const response = await axios.post('http://localhost:5000/username', { username });

        if (response.status === 200) {
          // Define o nome do usuário no estado local
          setNomeUsuario(response.data.name);
        } else {
          console.error('Erro ao obter o nome do usuário');
        }
      } catch (error) {
        console.error('Erro ao obter o nome do usuário', error);
      }
    };

    fetchNomeUsuario();
  }, []); // Executa apenas uma vez ao montar o componente


  const [relatorio, setRelatorio] = useState([]);
  const [agrupamento, setAgrupamento] = useState(null);

  const exibirRelatorioOficial = async (agrupar = null) => {
    try {
      setAgrupamento(agrupar);
      const username = localStorage.getItem('username')
      let endpoint = agrupar != null ? `http://localhost:5000/api/relatorio/oficial/${agrupar}` : "http://localhost:5000/api/relatorio/oficial";
      const response = await axios.post(endpoint, { username });
      setRelatorio(response.data.dados); // Atualiza o estado com os dados do relatório
    } catch (error) {
      console.error('Erro ao obter relatório oficial:', error);
    }
  };

  return (
    <div>
      <h1>Oficial</h1>
      {nomeUsuario ? (
        <p>Bem-vindo, {nomeUsuario}</p>
      ) : (
        <p>Carregando...</p>
      )}
      <div>
    </div>
      <button onClick={() => exibirRelatorioOficial()}>Relatório simples</button>
      <button onClick={() => exibirRelatorioOficial('planeta')}>Relatório agrupado por planeta</button>
      <button onClick={() => exibirRelatorioOficial('especie')}>Relatório agrupado por especie</button>
      <button onClick={() => exibirRelatorioOficial('faccao')}>Relatório agrupado por faccao</button>
      <button onClick={() => exibirRelatorioOficial('sistema')}>Relatório agrupado por sistema</button>
      {relatorio.length > 0 && (
        <div>
          <h2>Relatório de Evolução de Habitantes</h2>
          <table>
            <thead>
              <tr>
                <th>Planeta</th>
                <th>Espécie</th>
                <th>Facção</th>
                <th>Sistema</th>
                <th>Data</th>
                <th>Habitantes Atuais</th>
              </tr>
            </thead>
            <tbody>
              {relatorio.map(item => (
                <tr key={item[0] + item[1] + item[4]}>
                  <td>{item[0]}</td>
                  <td>{item[1]}</td>
                  <td>{item[2]}</td>
                  <td>{item[3]}</td>
                  <td>{item[4]}</td>
                  <td>{item[5]}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default Oficial;
