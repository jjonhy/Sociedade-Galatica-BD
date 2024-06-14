import React, { createContext, useState, useEffect } from "react";
import axios from 'axios';

export const AuthContext = createContext();

const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [role, setRole] = useState('');

  useEffect(() => {
    // Verifique a autenticação e papel do usuário aqui
    const checkAuth = async () => {
      try {
        const response = await axios.get('http://localhost:5000/check_auth');
        if (response.status === 200) {
          setIsAuthenticated(true);
          setRole(response.data.role);
        }
      } catch (error) {
        setIsAuthenticated(false);
        setRole('');
      }
    };

    checkAuth();
  }, []);

  return (
    <AuthContext.Provider value={{ isAuthenticated, role }}>
      {children}
    </AuthContext.Provider>
  );
};

export default AuthProvider;
