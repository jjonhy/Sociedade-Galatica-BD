import React from 'react';
import axios from 'axios';

const Relatorios = () => {
  const exibirRelatorio = async (tipo) => {
    console.log(tipo)
    try {
      const response = await axios.get(`/api/relatorio/${tipo}`);
      console.log(response.data); // Aqui você pode fazer algo com os dados do relatório, como atualizar o estado no componente React
    } catch (error) {
      console.error('Erro ao obter relatório:', error);
    }
  };

  return (
    <div>
      <h2>Relatórios</h2>
      <button onClick={() => exibirRelatorio('estrela')}>Relatório de Estrelas</button>
      <button onClick={() => exibirRelatorio('planeta')}>Relatório de Planetas</button>
      <button onClick={() => exibirRelatorio('sistema')}>Relatório de Sistemas</button>
    </div>
  );
};

export default Relatorios;
