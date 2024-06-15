import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

export const Cientista = ({ usuario }) => {
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

  return (
    <div>
      <h1>Cientista</h1>
      {nomeUsuario ? (
        <p>Bem-vindo, {nomeUsuario}</p>
      ) : (
        <p>Carregando...</p>
      )}
      <div>
        <h2>Overview</h2>
        <ul>
          <li><Link to="/cientista/gerenciar-estrelas">Gerenciar Estrelas</Link></li>
          <li><Link to="/cientista/relatorios">Relatórios</Link></li>
        </ul>
      </div>
    </div>
  );
};

export default Cientista;
