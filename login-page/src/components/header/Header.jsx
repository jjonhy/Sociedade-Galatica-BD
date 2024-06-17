import React, { useContext } from "react";
import { Container } from "reactstrap";
import { Link } from "react-router-dom";
import { AuthContext } from "../context/AuthContext";
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

import "./Header.css";

const navLinks = [
  { title: "Líder de facção", url: "lider", role: "LIDER" },
  { title: "Cientista", url: "cientista", role: "CIENTISTA " },
  { title: "Comandante", url: "comandante", role: "COMANDANTE" },
  { title: "Oficial", url: "oficial", role: "OFICIAL   " },
];

const Header = () => {
  const navigate = useNavigate();

  var { isAuthenticated, role } = useContext(AuthContext);

  const handleLogout = async (e) => {
    console.log("Logging out");
    var uid = localStorage.getItem("username")
    await axios.post('http://localhost:5000/logout', {  uid: uid });
    localStorage.removeItem('username');
    isAuthenticated = false;
    role = '';
    navigate('/');
    window.location.reload(); // Recarrega a página após o redirecionamento
  };

  console.log(role);

  return (
    <header>
      <Container>
        <div className="nav_bar">
          <div className="nav_bar_logo">
            <h2 className="d-flex align-items-center gap-1" id="h2">
              <span>
                <i className="ri-file-user-line"></i>
              </span>{" "}
              | BD
            </h2>
          </div>
          <div className="nav_bar_links">
            <ul className="nav_list">
              {navLinks.map((item, index) => (
                <li
                  className={`nav_link ${
                    isAuthenticated && (item.role === role || item.role === "LIDER") ? "active" : "disabled"
                  }`}
                  key={index}
                >
                  {(isAuthenticated && (item.role === role || item.role === "LIDER")) ? (
                    <Link to={`/${item.url}`}>{item.title}</Link>
                  ) : (
                    <span>{item.title}</span>
                  )}
                </li>
              ))}
            </ul>
          </div>
          {isAuthenticated && (
            <div className="user_icon">
              <span>
                <button className="logout-button" onClick={handleLogout}>
                  Logout
                </button>
              </span>
            </div>
          )}
        </div>
      </Container>
    </header>
  );
};

export default Header;
