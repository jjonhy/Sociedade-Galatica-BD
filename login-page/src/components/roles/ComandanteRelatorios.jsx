import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Container, Table } from "reactstrap";

const Relatorios = () => {
  const [planetas, setPlanetas] = useState([]);

  const exibirRelatorio = async (tipo) => {
    console.log(tipo)
    try {
      const response = await axios.post(`http://localhost:5000/api/relatorio/comandante/planetas_em_potencial`);
      setPlanetas(response.data.dados);
    } catch (error) {
      console.error('Erro ao obter relatório:', error);
    }
  };

  return (
    <div>
      <h2>Relatórios</h2>
      <button onClick={() => exibirRelatorio('estrela')}>Relatório de Estrelas</button>
      <Table striped>
        <thead>
          <tr>
            <th>Id Astronomico</th>
            <th>Massa</th>
            <th>Raio</th>
            <th>Classificacao</th>
            <th>Sistema</th>
          </tr>
        </thead>
        <tbody>
          {planetas.map((planeta, index) => (
            <tr key={index}>
              <td>{planeta[0]}</td>
              <td>{planeta[1]}</td>
              <td>{planeta[2]}</td>
              <td>{planeta[3]}</td>
              <td>{planeta[4]}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  );
};

export default Relatorios;
