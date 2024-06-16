import React, { useState, useEffect } from "react";
import { Container, Table } from "reactstrap";
import axios from "axios"; // Importe o Axios ou outro cliente HTTP que você esteja usando

const Relatorios = () => {
  const [comunidades, setComunidades] = useState([]);
  const [agrupamento, setAgrupamento] = useState('');

  // useEffect(() => {
  //   fetchComunidadesFaccao();
  // }, []);

  const exibirRelatorioLider = async (agrupar = '') => {
    try {
      setAgrupamento(agrupar);
      const username = localStorage.getItem('username')
      let endpoint = agrupar != '' ? `http://localhost:5000/api/relatorio/lider/${agrupar}` : "http://localhost:5000/api/relatorio/lider";
      const response = await axios.post(endpoint, { username });
      setComunidades(response.data.dados);
    } catch (error) {
      console.error("Erro ao buscar comunidades da facção:", error);
    }
  };

  return (
    <Container className="relatorios">
      <h2>Relatórios</h2>
      <button onClick={() => exibirRelatorioLider()}>Relatório simples</button>
      <button onClick={() => exibirRelatorioLider('nacao')}>Relatório agrupado por nação</button>
      <button onClick={() => exibirRelatorioLider('planeta')}>Relatório agrupado por planeta</button>
      <button onClick={() => exibirRelatorioLider('especie')}>Relatório agrupado por especie</button>
      <button onClick={() => exibirRelatorioLider('sistema')}>Relatório agrupado por sistema</button>
      <Table striped>
        <thead>
          {agrupamento == '' && (
            <tr>
              <th>Comunidade</th>
              <th>Espécie</th>
              <th>Quantidade de Habitantes</th>
              <th>Planeta</th>
              <th>Nação</th>
              <th>Sistema</th>
            </tr>
          )}
          {agrupamento != '' && (
            <tr>
              <th>{agrupamento}</th>
              <th>Quantidade de comunidades</th>
              <th>Quantidade de Habitantes</th>
            </tr>
          )}
        </thead>
        <tbody>
          {comunidades.map((comunidade, index) => agrupamento == '' ? (
            <tr key={index}>
                <td>{comunidade[0]}</td>
                <td>{comunidade[1]}</td>
                <td>{comunidade[2]}</td>
                <td>{comunidade[3]}</td>
                <td>{comunidade[4]}</td>
                <td>{comunidade[5]}</td>
            </tr>
          ) : 
            <tr key={index}>
                <td>{comunidade[0]}</td>
                <td>{comunidade[1]}</td>
                <td>{comunidade[2]}</td>
            </tr>
          )}
        </tbody>
      </Table>
    </Container>
  );
};

export default Relatorios;
