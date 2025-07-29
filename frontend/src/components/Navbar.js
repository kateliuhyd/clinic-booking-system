import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import './Navbar.css';

const Navbar = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  return (
    <nav className="navbar">
      <div className="container">
        <h1>
          <Link to="/">Clinic Booking System</Link>
        </h1>
        <div className="nav-links">
          {user ? (
            <>
              <span className="user-info">Welcome, {user.first_name}!</span>
              <Link to="/dashboard">Dashboard</Link>
              <Link to="/doctors">Find Doctors</Link>
              <Link to="/appointments">My Appointments</Link>
              <Link to="/prescriptions">Prescriptions</Link>
              <button onClick={handleLogout} className="logout-btn">
                Logout
              </button>
            </>
          ) : (
            <>
              <Link to="/login">Login</Link>
              <Link to="/register">Register</Link>
            </>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navbar;