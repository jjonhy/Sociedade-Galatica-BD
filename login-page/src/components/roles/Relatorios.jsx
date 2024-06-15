import React from 'react';

const Relatorios = () => {
  return (
    <div>
      <h2>Relatórios</h2>
      <button onClick={() => exibirRelatorio('estrela')}>Relatório de Estrelas</button>
      <button onClick={() => exibirRelatorio('planeta')}>Relatório de Planetas</button>
      <button onClick={() => exibirRelatorio('sistema')}>Relatório de Sistemas</button>
    </div>
  );
};

const exibirRelatorio = (tipo) => {
  // Suponha que você tenha uma função que chama a API do backend para obter o relatório
  fetch(`/api/relatorio/${tipo}`)
    .then(response => response.json())
    .then(data => {
      // Lógica para exibir o relatório
      console.log(data);
    })
    .catch(error => console.error('Erro ao obter relatório:', error));
};

export default Relatorios;
