import React, { useState, useEffect } from 'react';
import axios from 'axios';

const CientistaGerenciar = () => {
  const [estrelas, setEstrelas] = useState([]);
  const [formData, setFormData] = useState({
    id: '',
    x: '',
    y: '',
    z: '',
    nome: '',
    classificacao: '',
    massa: ''
  });
  
  useEffect(() => {
    fetchEstrelas();
  }, []);

  const fetchEstrelas = async () => {
    try {
      const response = await axios.get('http://localhost:5000/estrelas');
      setEstrelas(response.data);
    } catch (error) {
      console.error('Erro ao buscar estrelas', error);
    }
  };

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:5000/estrelas', formData);
      fetchEstrelas();
    } catch (error) {
      console.error('Erro ao criar/editar estrela', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`http://localhost:5000/estrelas/${id}`);
      fetchEstrelas();
    } catch (error) {
      console.error('Erro ao deletar estrela', error);
    }
  };

  return (
    <div>
      <h1>Gerenciar Estrelas</h1>
      <form onSubmit={handleSubmit}>
        <input type="text" name="id" placeholder="ID" value={formData.id} onChange={handleInputChange} required />
        <input type="text" name="x" placeholder="X" value={formData.x} onChange={handleInputChange} required />
        <input type="text" name="y" placeholder="Y" value={formData.y} onChange={handleInputChange} required />
        <input type="text" name="z" placeholder="Z" value={formData.z} onChange={handleInputChange} required />
        <input type="text" name="nome" placeholder="Nome" value={formData.nome} onChange={handleInputChange} />
        <input type="text" name="classificacao" placeholder="Classificação" value={formData.classificacao} onChange={handleInputChange} />
        <input type="text" name="massa" placeholder="Massa" value={formData.massa} onChange={handleInputChange} />
        <button type="submit">Salvar</button>
      </form>
      <ul>
        {estrelas.map((estrela) => (
          <li key={estrela.id}>
            {estrela.nome} (ID: {estrela.id}) 
            <button onClick={() => handleDelete(estrela.id)}>Deletar</button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default CientistaGerenciar;
