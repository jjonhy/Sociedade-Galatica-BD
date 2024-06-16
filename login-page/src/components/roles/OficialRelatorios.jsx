import React, { useState } from 'react';

const GerenciarEstrelas = () => {
  const [cpi, setCpi] = useState('');
  const [nomeFd, setNomeFd] = useState('');
  const [planeta, setPlaneta] = useState('');
  const [dataFund, setDataFund] = useState('');
  const [dataIni, setDataIni] = useState('');

  const incluirFederacao = async () => {
    const response = await fetch('http://localhost:5000/incluir_federacao', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cpi, nome_fd: nomeFd })
    });
    const data = await response.json();
    alert(data.message);
  };

  const excluirFederacao = async () => {
    const response = await fetch('http://localhost:5000/excluir_federacao', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cpi })
    });
    const data = await response.json();
    alert(data.message);
  };

  const criarFederacao = async () => {
    const response = await fetch('http://localhost:5000/criar_federacao', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cpi, nome_fd: nomeFd, data_fund: dataFund })
    });
    const data = await response.json();
    alert(data.message);
  };

  const inserirDominancia = async () => {
    const response = await fetch('http://localhost:5000/inserir_dominancia', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cpi, planeta, data_ini: dataIni })
    });
    const data = await response.json();
    alert(data.message);
  };

  return (
    <div>
      <h2>Gerenciar Comandante</h2>
      <div>
        <label>
          CPI:
          <input type="text" value={cpi} onChange={(e) => setCpi(e.target.value)} />
        </label>
      </div>
      <div>
        <label>
          Nome da Federação:
          <input type="text" value={nomeFd} onChange={(e) => setNomeFd(e.target.value)} />
        </label>
      </div>
      <div>
        <label>
          Data de Fundação:
          <input type="date" value={dataFund} onChange={(e) => setDataFund(e.target.value)} />
        </label>
      </div>
      <button onClick={incluirFederacao}>Incluir Federação</button>
      <button onClick={excluirFederacao}>Excluir Federação</button>
      <button onClick={criarFederacao}>Criar Federação</button>
      <div>
        <label>
          Planeta:
          <input type="text" value={planeta} onChange={(e) => setPlaneta(e.target.value)} />
        </label>
      </div>
      <div>
        <label>
          Data de Início da Dominância:
          <input type="date" value={dataIni} onChange={(e) => setDataIni(e.target.value)} />
        </label>
      </div>
      <button onClick={inserirDominancia}>Inserir Dominância</button>
    </div>
  );
};

export default GerenciarEstrelas;
