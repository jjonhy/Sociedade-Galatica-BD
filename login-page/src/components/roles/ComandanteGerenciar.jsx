import React, { useState } from 'react';
import axios from "axios";

const GerenciarEstrelas = () => {
  const [cpi] = useState('');
  const [nomeFd, setNomeFd] = useState('');
  const [planeta, setPlaneta] = useState('');
  const [dataFund, setDataFund] = useState('');
  const [dataIni, setDataIni] = useState('');

  const incluirFederacao = async (e) => {
    e.preventDefault();
    try {
      await axios.post("http://localhost:5000/incluir_federacao", {
        cpi: localStorage.getItem('username'),
        nome_fd: nomeFd
      });
      alert("Federação incluída!");
      setNomeFd("");
    } catch (error) {
      if (error.response) {
        alert(error.response.data.message);
      } else if (error.request) {
        alert("Erro na conexão com o servidor. Por favor, tente novamente mais tarde.");
      } else {
        alert("Ocorreu um erro inesperado.");
      }
    }
  };

  const excluirFederacao = async (e) => {
    e.preventDefault();
    try {
      await axios.post("http://localhost:5000/excluir_federacao", {
        cpi: localStorage.getItem('username'),
      });
      alert("Federação excluída!");
    } catch (error) {
      if (error.response) {
        alert(error.response.data.message);
      } else if (error.request) {
        alert("Erro na conexão com o servidor. Por favor, tente novamente mais tarde.");
      } else {
        alert("Ocorreu um erro inesperado.");
      }
    }
  };

  const criarFederacao = async (e) => {
    e.preventDefault();
    try {
      await axios.post("http://localhost:5000/criar_federacao", {
        cpi: localStorage.getItem('username'),
        nome_fd: nomeFd,
        data_fund: dataFund
      });
      alert("Federação criada e incluída!");
      setNomeFd("");
      setDataFund("");
    } catch (error) {
      if (error.response) {
        alert(error.response.data.message);
      } else if (error.request) {
        alert("Erro na conexão com o servidor. Por favor, tente novamente mais tarde.");
      } else {
        alert("Ocorreu um erro inesperado.");
      }
    }
  };

  const inserirDominancia = async (e) => {
    e.preventDefault();
    try {
      await axios.post("http://localhost:5000/inserir_dominancia", {
        cpi: localStorage.getItem('username'),
        planeta: planeta,
        data_ini: dataIni
      });
      alert("Dominancia inserida!");
    } catch (error) {
      if (error.response) {
        alert(error.response.data.message);
      } else if (error.request) {
        alert("Erro na conexão com o servidor. Por favor, tente novamente mais tarde.");
      } else {
        alert("Ocorreu um erro inesperado.");
      }
    }
  };

  return (
    <div>
      <h2>Gerenciar Comandante</h2>
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
