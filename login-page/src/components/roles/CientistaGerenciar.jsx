import React, { useState } from 'react';
import { Container, FormGroup, Label, Input, Button } from "reactstrap";
import axios from 'axios';

const CientistaGerenciar = () => {
  const [idEstrela, setIdEstrela] = useState('');
  const [idEstrelaApagar, setEstrelaApagar] = useState('');
  const [formData, setFormData] = useState({
    userId: localStorage.getItem('username'),
    id: '',
    x: '',
    y: '',
    z: '',
    nome: '',
    classificacao: '',
    massa: ''
  });
  const [formData2, setFormData2] = useState({
    userId: localStorage.getItem('username'),
    id: '',
    idNovo: '',
    x: '',
    y: '',
    z: '',
    nome: '',
    classificacao: '',
    massa: ''
  });
  const [estrelaInfo, setEstrelaInfo] = useState(null);

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleInputChange2 = (e) => {
    setFormData2({ ...formData2, [e.target.name]: e.target.value });
  };

  const handleIdEstrela = (e) => {
    setIdEstrela(e.target.value);
  };

  const handleidEstrelaApagar = (e) => {
    setEstrelaApagar(e.target.value);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:5000/criar_estrela', formData);
      alert("Estrela criada com sucesso!");
    } catch (error) {
      console.error('Erro ao criar estrela', error);
    }
  };

  const handleSubmitReadEstrela = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:5000/buscar_estrela', { id_estrela: idEstrela, userId: localStorage.getItem("username") });
      const dados = response.data.dados[0]; // Acessando o array de dados
      const estrela = {
        id_estrela: dados[0],
        nome: dados[1],
        classificacao: dados[2],
        massa: dados[3],
        x: dados[4],
        y: dados[5],
        z: dados[6]
      };
      setEstrelaInfo(estrela); // Armazena a informação da estrela no estado
      alert("Estrela encontrada com sucesso!");
    } catch (error) {
      console.error('Erro ao buscar estrela', error);
    }
  };

  const handleSubmitUpdate = async (e) => {
    e.preventDefault();
    try {
      await axios.put('http://localhost:5000/editar_estrela', formData2);
      alert("Estrela atualizada com sucesso!");
    } catch (error) {
      console.error('Erro ao atualizar estrela', error);
    }
  };

  const handleSubmitDeleteEstrela = async (e) => {
    e.preventDefault();
    const userId = localStorage.getItem('username'); // Assuming 'userId' is stored in localStorage
    try {
      await axios.delete(`http://localhost:5000/deletar_estrela/${idEstrelaApagar}?user_id=${userId}`);
      alert("Estrela apagada com sucesso!");
    } catch (error) {
      console.error('Erro ao apagar estrela', error);
    }
  };
  

  return (
    <Container className="gerenciar-cientista">
      <div>
        <h1>Gerenciar Estrelas</h1>
        <h3>Criar Estrela</h3>
        <form onSubmit={handleSubmit}>
          <input type="text" name="id" placeholder="ID" value={formData.id} onChange={handleInputChange} required />
          <input type="text" name="x" placeholder="X" value={formData.x} onChange={handleInputChange} required />
          <input type="text" name="y" placeholder="Y" value={formData.y} onChange={handleInputChange} required />
          <input type="text" name="z" placeholder="Z" value={formData.z} onChange={handleInputChange} required />
          <input type="text" name="nome" placeholder="Nome" value={formData.nome} onChange={handleInputChange} />
          <input type="text" name="classificacao" placeholder="Classificação" value={formData.classificacao} onChange={handleInputChange} />
          <input type="text" name="massa" placeholder="Massa" value={formData.massa} onChange={handleInputChange} />
          <button type="submit">Criar</button>
        </form>

        <form onSubmit={handleSubmitReadEstrela}>
          <FormGroup>
            <Label for="idEstrela">Id da estrela que deseja buscar:</Label>
            <Input
              type="text"
              id="idEstrela"
              value={idEstrela}
              onChange={handleIdEstrela}
              required
            />
          </FormGroup>
          <Button type="submit" color="primary">Buscar</Button>
        </form>

        {estrelaInfo && (
          <div>
            <h3>Informações da Estrela</h3>
            <p>ID: {estrelaInfo.id_estrela}</p>
            <p>X: {estrelaInfo.x}</p>
            <p>Y: {estrelaInfo.y}</p>
            <p>Z: {estrelaInfo.z}</p>
            <p>Nome: {estrelaInfo.nome}</p>
            <p>Classificação: {estrelaInfo.classificacao}</p>
            <p>Massa: {estrelaInfo.massa}</p>
          </div>
        )}

        <form onSubmit={handleSubmitUpdate}>
          <input type="text" name="id" placeholder="ID" value={formData2.id} onChange={handleInputChange2} required />
          <input type="text" name="idNovo" placeholder="IDNOVO" value={formData2.idNovo} onChange={handleInputChange2} required />
          <input type="text" name="x" placeholder="X" value={formData2.x} onChange={handleInputChange2} required />
          <input type="text" name="y" placeholder="Y" value={formData2.y} onChange={handleInputChange2} required />
          <input type="text" name="z" placeholder="Z" value={formData2.z} onChange={handleInputChange2} required />
          <input type="text" name="nome" placeholder="Nome" value={formData2.nome} onChange={handleInputChange2} />
          <input type="text" name="classificacao" placeholder="Classificação" value={formData2.classificacao} onChange={handleInputChange2} />
          <input type="text" name="massa" placeholder="Massa" value={formData2.massa} onChange={handleInputChange2} />
          <button type="submit">Atualizar</button>
        </form>

        <form onSubmit={handleSubmitDeleteEstrela}>
          <FormGroup>
            <Label for="idEstrelaApagar">Id da estrela que deseja apagar:</Label>
            <Input
              type="text"
              id="idEstrelaApagar"
              value={idEstrelaApagar}
              onChange={handleidEstrelaApagar}
              required
            />
          </FormGroup>
          <Button type="submit" color="primary">Apagar</Button>
        </form>
      </div>
    </Container>
  );
};

export default CientistaGerenciar;
