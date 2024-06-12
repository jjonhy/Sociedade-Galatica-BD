import { Fragment } from "react";
import "./App.css";
import Header from "./components/header/Header";
import Login from "./components/login/Login";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Lider } from "./components/roles/Lider";
import { Cientista } from "./components/roles/Cientista";
import { Comandante } from "./components/roles/Comandante";
import { Oficial } from "./components/roles/Oficial";

function App() {
  return (
    <BrowserRouter>
      <Fragment>
        <Header />
        <div className="body">
          <Routes>
            <Route path="/" element={<Login />} />
            <Route path="/login-page" element={<Login />} />
            <Route path="/lider" element={<Lider />} />
            <Route path="/cientista" element={<Cientista />} />
            <Route path="/comandante" element={<Comandante />} />
            <Route path="/oficial" element={<Oficial />} />
          </Routes>
        </div>
      </Fragment>
    </BrowserRouter>
  );
}

export default App;
