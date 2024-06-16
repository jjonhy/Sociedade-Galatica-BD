import React, { useState } from 'react';
import axios from 'axios';

const CientistaRelatorio = () => {
  const [tipo, setTipo] = useState('estrelas');
  const [limite, setLimite] = useState(10);
  const [dados, setDados] = useState([]);

  const fetchRelatorio = async () => {
    try {
      const response = await axios.get(`http://localhost:5000/relatorios/${tipo}?limite=${limite}`);
      setDados(response.data);
    } catch (error) {
      console.error('Erro ao buscar relatório', error);
    }
  };

  return (
    <div>
      <h1>Relatórios</h1>
      <select onChange={(e) => setTipo(e.target.value)}>
        <option value="estrelas">Estrelas</option>
        <option value="planetas">Planetas</option>
        <option value="sistemas">Sistemas</option>
      </select>
      <input type="number" value={limite} onChange={(e) => setLimite(e.target.value)} />
      <button onClick={fetchRelatorio}>Buscar Relatório</button>
      <ul>
        {dados.map((item, index) => (
          <li key={index}>{JSON.stringify(item)}</li>
        ))}
      </ul>
    </div>
  );
};

export default CientistaRelatorio;
