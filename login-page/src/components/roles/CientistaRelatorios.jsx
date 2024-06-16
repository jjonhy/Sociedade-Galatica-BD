import React, { useState } from 'react';
import axios from 'axios';

const CientistaRelatorio = () => {
  const [tipo, setTipo] = useState('estrela');
  const [limite, setLimite] = useState(10);
  const [dados, setDados] = useState([]);

  const fetchRelatorio = async () => {
    try {
      const response = await axios.post(`http://localhost:5000/api/relatorio/cientista/${tipo}/${limite}`);
      setDados(response.data.dados);
    } catch (error) {
      console.error('Erro ao buscar relatório', error);
    }
  };

  return (
    <div>
      <h1>Relatórios</h1>
      <select onChange={(e) => setTipo(e.target.value)}>
        <option value="estrela">Estrelas</option>
        <option value="planeta">Planetas</option>
        <option value="sistema">Sistemas</option>
      </select>
      <input type="number" value={limite} onChange={(e) => setLimite(e.target.value)} />
      <button onClick={fetchRelatorio}>Buscar Relatório</button>
      <table>
        <thead>
            {tipo === 'estrela' && (
              <tr>
                <th>Id Estrela</th>
                <th>Nome</th>
                <th>Classificação</th>
                <th>Massa</th>
                <th>X</th>
                <th>Y</th>
                <th>Z</th>
              </tr>
            )}
            {tipo === 'planeta' && (
              <tr>
                <th>Id Astronomico</th>
                <th>Massa</th>
                <th>Raio</th>
                <th>Classificacao</th>
              </tr>
            )}
            {tipo === 'sistema' && (
              <tr>
                <th>Estrela</th>
                <th>Nome</th>
              </tr>
            )}
        </thead>
        <tbody>
          {dados.map((item, index) => (
            <tr key={index}>
              <td>{item[0]}</td>
              <td>{item[1]}</td>
              <td>{item[2]}</td>
              <td>{item[3]}</td>
              <td>{item[4]}</td>
              <td>{item[5]}</td>
              <td>{item[6]}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default CientistaRelatorio;
