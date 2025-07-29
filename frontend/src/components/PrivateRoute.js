import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

// This component restricts access to authenticated users only
const PrivateRoute = ({ children }) => {
  const { user, loading } = useAuth(); // Get authentication state

  // While checking authentication status, show loading indicator
  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  // If the user is authenticated, show the protected component
  // Otherwise, redirect to the login page
  return user ? children : <Navigate to="/login" />;
};

export default PrivateRoute;
