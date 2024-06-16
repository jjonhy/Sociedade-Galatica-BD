import React, { useState } from "react";
import { Container, Form } from "reactstrap";
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import "./Login.css";

const Login = () => {
  // State variables
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState('');

  // Hook to use history for navigation
  const navigate = useNavigate();

  // Event handlers
  const handleUsernameChange = (e) => {
    setUsername(e.target.value);
  };

  const handlePasswordChange = (e) => {
    setPassword(e.target.value);
  };

const handleSubmit = async (e) => {
  e.preventDefault();
  
  // Basic input validation
  if (!username || !password) {
    setMessage('Username and password are required.');
    return;
  }

  try {
    const response = await axios.post('http://localhost:5000/login', { username, password });
    if (response.status === 200) {
      setMessage('Login successful');
      localStorage.setItem('username', username); // Armazena o username no localStorage
      const role_response = await axios.post('http://localhost:5000/role', { username });
      const role = role_response.data.role;
      if (role === 'OFICIAL   ') { // tambem nao mudar
        navigate('/oficial');
      } else if (role === 'LIDER') {
        navigate('/lider');
      } else if (role === 'CIENTISTA ') { // Espaço mantido conforme mencionado
        navigate('/cientista');
      } else if (role === 'COMANDANTE') {
        navigate('/comandante');
      }
    }
  } catch (error) {
    // Handle Axios error response
    if (error.response) {
      setMessage(error.response.data.message || 'An error occurred. Please try again later.');
    } else if (error.request) {
      setMessage('No response received from server. Please try again later.');
    } else {
      setMessage('An error occurred. Please try again later.');
    }
  }
};


  return (
    <section className="Form">
      <Container>
        <Form onSubmit={handleSubmit}>
          <div className="form_container">
            <div className="form_heading">
              <h1>Sign In</h1>
            </div>
            <div className="input_container">
              <div className="username_input">
                <input
                  type="text"
                  placeholder="Username"
                  id="username"
                  value={username}
                  onChange={handleUsernameChange}
                />
              </div>
              <div className="password_input">
                <input
                  type="password"
                  placeholder="Password"
                  id="password"
                  value={password}
                  onChange={handlePasswordChange}
                />
              </div>
            </div>
            <div className="button_submit">
              <button type="submit" id="submit">
                <span></span>Login
              </button>
            </div>
            {message && <p className={message.includes('error') ? 'error-message' : 'success-message'}>{message}</p>}
          </div>
        </Form>
      </Container>
    </section>
  );
};

export default Login;
