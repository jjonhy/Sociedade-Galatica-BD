import React, { useState, useEffect } from "react";
import { Container, Table } from "reactstrap";
import axios from "axios"; // Importe o Axios ou outro cliente HTTP que você esteja usando

const Relatorios = () => {
  const [comunidades, setComunidades] = useState([]);

  useEffect(() => {
    fetchComunidadesFaccao();
  }, []);

  const fetchComunidadesFaccao = async () => {
    try {
      const response = await axios.get("http://localhost:5000/api/comunidades_faccao");
      setComunidades(response.data);
    } catch (error) {
      console.error("Erro ao buscar comunidades da facção:", error);
    }
  };

  return (
    <Container className="relatorios">
      <h2>Relatórios</h2>
      <Table striped>
        <thead>
          <tr>
            <th>Comunidade</th>
            <th>Espécie</th>
            <th>Quantidade de Habitantes</th>
            <th>Planeta</th>
            <th>Nação</th>
            <th>Sistema</th>
          </tr>
        </thead>
        <tbody>
          {comunidades.map((comunidade, index) => (
            <tr key={index}>
              <td>{comunidade.COMUNIDADE}</td>
              <td>{comunidade.ESPECIE}</td>
              <td>{comunidade.QTD_HABITANTES}</td>
              <td>{comunidade.PLANETA}</td>
              <td>{comunidade.NACAO}</td>
              <td>{comunidade.SISTEMA}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </Container>
  );
};

export default Relatorios;
