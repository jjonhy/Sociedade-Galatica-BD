import React from "react";
import { Container } from "reactstrap";
import "./Header.css";
import { Link } from "react-router-dom";

const navLinks = [
  {
    title: "Líder de facção",
    url: "lider",
  },
  {
    title: "Cientista",
    url: "cientista",
  },
  {
    title: "Comandante",
    url: "comandante",
  },
  {
    title: "Oficial",
    url: "oficial",
  },
];

const handleLogout = () => {
  console.log(`loging out`);
};

function Header() {
  return (
    <header>
      {/* Your header content goes here */}
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
                <li className="nav_link" key={index}>
                  <a href={item.url}>{item.title}</a>
                </li>
              ))}
            </ul>
          </div>
          <div className="user_icon">
            <span>
              <Link to="/">
                <button className="logout-button" onClick={handleLogout}>
                  Home
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
