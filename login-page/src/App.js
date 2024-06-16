import { Fragment } from "react";
import "./App.css";
import Header from "./components/header/Header";
import Login from "./components/login/Login";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Lider } from "./components/roles/Lider";
import { Cientista } from "./components/roles/Cientista";
import { Comandante } from "./components/roles/Comandante";
import { Oficial } from "./components/roles/Oficial";
import ComandanteGerenciar from "./components/roles/ComandanteGerenciar";
import ComandanteRelatorios from "./components/roles/ComandanteRelatorios";
import OficialGerenciar from "./components/roles/OficialGerenciar";
import OficialRelatorios from "./components/roles/OficialRelatorios";
import LiderGerenciar from "./components/roles/LiderGerenciar";
import LiderRelatorios from "./components/roles/LiderRelatorios";
import CientistaGerenciar from "./components/roles/CientistaGerenciar";
import CientistaRelatorios from "./components/roles/CientistaRelatorios";

function App() {
  return (
    <BrowserRouter>
      <Fragment>
        <Header />
        <div className="body">
          <Routes>
            <Route path="/" element={<Login />} />
            <Route path="/login-page" element={<Login />} />
            <Route path="/cientista" element={<Cientista />} />
            <Route path="/cientista/gerenciar" element={<CientistaGerenciar />} />
            <Route path="/cientista/relatorios" element={<CientistaRelatorios />} />
            <Route path="/oficial" element={<Oficial />} />
            <Route path="/oficial/gerenciar" element={<OficialGerenciar />} />
            <Route path="/oficial/relatorios" element={<OficialRelatorios />} />
            <Route path="/lider" element={<Lider />} />
            <Route path="/lider/gerenciar" element={<LiderGerenciar />} />
            <Route path="/lider/relatorios" element={<LiderRelatorios />} />
            <Route path="/comandante" element={<Comandante />} />
            <Route path="/comandante/gerenciar" element={<ComandanteGerenciar />} />
            <Route path="/comandante/relatorios" element={<ComandanteRelatorios />} />
          </Routes>
        </div>
      </Fragment>
    </BrowserRouter>
  );
}

export default App;
