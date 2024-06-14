import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import AuthProvider from './components/context/AuthContext'; // Certifique-se do caminho correto

ReactDOM.render(
  <AuthProvider>
    <App />
  </AuthProvider>,
  document.getElementById('root')
);
