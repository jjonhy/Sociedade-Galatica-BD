import React, { useState } from "react";
import { Container, Form, FormGroup, Label, Input, Button } from "reactstrap";
import axios from "axios"; // Importe o Axios ou outro cliente HTTP que você esteja usando

const GerenciarFaccao = () => {
  const [novoNomeFaccao, setNovoNomeFaccao] = useState("");
  const [novoLider, setNovoLider] = useState("");
  const [faccao, setFaccao] = useState("");
  const [nacao, setNacao] = useState("");


  const handleChangeNomeFaccao = (e) => {
    setNovoNomeFaccao(e.target.value);
  };

  const handleChangeNovoLider = (e) => {
    setNovoLider(e.target.value);
  };

  const handleFaccao = (e) => {
    setFaccao(e.target.value);
  };

  const handleNacao = (e) => {
    setNacao(e.target.value);
  };

  const handleSubmitAlterarNome = async (e) => {
    e.preventDefault();
    try {
      await axios.post("http://localhost:5000/api/alterar_nome_faccao", {
        novoNome: novoNomeFaccao,
        cpi: localStorage.getItem('username')
      });
      alert("Nome da facção alterado com sucesso!");
      setNovoNomeFaccao("");
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
  

  const handleSubmitIndicarNovoLider = async (e) => {
    e.preventDefault();
    try {
      await axios.post("http://localhost:5000/api/indicar_novo_lider_faccao", {
        cpi: localStorage.getItem('username'),
        novoLider: novoLider,
      });
      alert("Novo líder indicado com sucesso!");
      setNovoLider("");

    }catch (error) {
      if (error.response) {
        alert(error.response.data.message);
      } else if (error.request) {
        alert("Erro na conexão com o servidor. Por favor, tente novamente mais tarde.");
      } else {
        alert("Ocorreu um erro inesperado.");
      }
    }
  };

  const handleSubmitRemoverFaccaoDeNacao = async (e) => {
    e.preventDefault();
    try {
      await axios.post("http://localhost:5000/api/remover_faccao_de_nacao", {
        cpi: localStorage.getItem('username'),
        faccao: faccao,
        nacao: nacao
      });
      alert("Faccao foi removida de nacao!");
      setNovoLider("");

    }catch (error) {
      if (error.response) {
        alert(error.response.data.message);
      } else if (error.request) {
        alert("Erro na conexão com o servidor. Por favor, tente novamente mais tarde.");
      } else {
        alert("Ocorreu um erro inesperado.");
      }
    }
  };

  const handleCredenciarComunidades = async () => {
    try {
      await axios.post("http://localhost:5000/api/credenciar_comunidades", {
        cpi: localStorage.getItem('username'),
      });
      alert("Comunidades credenciadas com sucesso!");
    } catch (error) {
      console.error("Erro ao credenciar comunidades:", error);
      alert("Erro ao credenciar comunidades. Verifique o console para mais detalhes.");
    }
  };

  return (
    <Container className="gerenciar-faccao">
      <h2>Gerenciar Facção</h2>
      <Form onSubmit={handleSubmitAlterarNome}>
        <FormGroup>
          <Label for="novoNomeFaccao">Novo Nome da Facção:</Label>
          <Input
            type="text"
            id="novoNomeFaccao"
            value={novoNomeFaccao}
            onChange={handleChangeNomeFaccao}
            required
          />
        </FormGroup>
        <Button type="submit" color="primary">Alterar Nome</Button>
      </Form>

      <Form onSubmit={handleSubmitIndicarNovoLider}>
        <FormGroup>
          <Label for="novoLider">Novo Líder (CPI):</Label>
          <Input
            type="text"
            id="novoLider"
            value={novoLider}
            onChange={handleChangeNovoLider}
            required
          />
        </FormGroup>
        <Button type="submit" color="primary">Indicar Novo Líder</Button>
      </Form>

      <Form onSubmit={handleSubmitRemoverFaccaoDeNacao}>
        <FormGroup>
          <Label for="RemoverFaccaoDeNacao">Remover Faccao de Nacao:</Label>
          <br></br>
          <Label for="RemoverFaccaoDeNacao">Nacao:</Label>
          <Input
            type="text"
            id="RemoverFaccaoDeNacao"
            value={nacao}
            onChange={handleNacao}
            required
          />
           <br></br>
          <Label for="RemoverFaccaoDeNacao">Faccao:</Label>
          <Input
            type="text"
            id="RemoverFaccaoDeNacao"
            value={faccao}
            onChange={handleFaccao}
            required
          />
        </FormGroup>
        <Button type="submit" color="primary">Remover</Button>
      </Form>

      <Button onClick={handleCredenciarComunidades} color="primary">
        Credenciar Comunidades
      </Button>
    </Container>
  );
};

export default GerenciarFaccao;
