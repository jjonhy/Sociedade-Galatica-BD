import React, { useContext } from "react";
import { Container } from "reactstrap";
import { Link } from "react-router-dom";
import { AuthContext } from "../context/AuthContext";
import "./Header.css";

const navLinks = [
  { title: "Líder de facção", url: "lider", role: "LIDER" },
  { title: "Cientista", url: "cientista", role: "CIENTISTA" },
  { title: "Comandante", url: "comandante", role: "COMANDANTE" },
  { title: "Oficial", url: "oficial", role: "OFICIAL" },
];

const handleLogout = () => {
  console.log("Logging out");
};

function Header() {
  const { isAuthenticated, role } = useContext(AuthContext);

  console.log("isAuthenticated:", isAuthenticated);
  console.log("role:", role);

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
                    isAuthenticated && item.role === role ? "active" : "disabled"
                  }`}
                  key={index}
                >
                  {isAuthenticated && item.role === role ? (
                    <Link to={`/${item.url}`}>{item.title}</Link>
                  ) : (
                    <span>{item.title}</span>
                  )}
                </li>
              ))}
            </ul>
          </div>
          <div className="user_icon">
            <span>
              <Link to="/">
                <button className="logout-button" onClick={handleLogout}>
                  Logout
                </button>
              </Link>
            </span>
          </div>
        </div>
      </Container>
    </header>
  );
}

export default Header;
