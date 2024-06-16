import React, { useState } from "react";
import { Container, Form, FormGroup, Label, Input, Button } from "reactstrap";
import axios from "axios"; // Importe o Axios ou outro cliente HTTP que você esteja usando

const GerenciarFaccao = () => {
  const [novoNomeFaccao, setNovoNomeFaccao] = useState("");
  const [novoLider, setNovoLider] = useState("");

  const handleChangeNomeFaccao = (e) => {
    setNovoNomeFaccao(e.target.value);
  };

  const handleChangeNovoLider = (e) => {
    setNovoLider(e.target.value);
  };

  const handleSubmitAlterarNome = async (e) => {
    e.preventDefault();
    try {
      await axios.post("/api/alterar_nome_faccao", {
        novoNome: novoNomeFaccao,
      });
      alert("Nome da facção alterado com sucesso!");
      setNovoNomeFaccao("");
    } catch (error) {
      console.error("Erro ao alterar nome da facção:", error);
      alert("Erro ao alterar nome da facção. Verifique o console para mais detalhes.");
    }
  };

  const handleSubmitIndicarNovoLider = async (e) => {
    e.preventDefault();
    try {
      await axios.post("/api/indicar_novo_lider_faccao", {
        novoLider: novoLider,
      });
      alert("Novo líder indicado com sucesso!");
      setNovoLider("");
    } catch (error) {
      console.error("Erro ao indicar novo líder:", error);
      alert("Erro ao indicar novo líder. Verifique o console para mais detalhes.");
    }
  };

  const handleCredenciarComunidades = async () => {
    try {
      await axios.post("/api/credenciar_comunidades");
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

      <Button onClick={handleCredenciarComunidades} color="primary">
        Credenciar Comunidades
      </Button>
    </Container>
  );
};

export default GerenciarFaccao;
