import React from "react";
import LiderGerenciar from "./LiderGerenciar";
import LiderRelatorios from "./LiderRelatorios";
import "./styles/Lider.css";

export const Lider = () => {
  return (
    <div className="lider-container">
      <h1>Líder de Facção</h1>
      <div className="lider-content">
        <LiderGerenciar />
        <LiderRelatorios />
      </div>
    </div>
  );
};

export default Lider;
