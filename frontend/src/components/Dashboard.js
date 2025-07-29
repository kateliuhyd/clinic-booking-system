import React, { useState, useEffect } from 'react';
import { Navigate } from 'react-router-dom'; 
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import './Dashboard.css';

const Dashboard = () => {
  
  const { user, loading: authLoading } = useAuth(); // useAuth hook to get user and auth loading state
  const [upcomingAppointments, setUpcomingAppointments] = useState([]);
  const [recentPrescriptions, setRecentPrescriptions] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user || loading) return;
    api.get('/test')
    .then(res => console.log('✅ CORS test passed:', res.data))
    .catch(err => console.error('❌ CORS test failed:', err));
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      // Fetch upcoming appointments
      const appointmentsRes = await api.get('/appointments?status=scheduled');
      setUpcomingAppointments(appointmentsRes.data.appointments.slice(0, 3));

      // Fetch recent prescriptions
      const prescriptionsRes = await api.get('/prescriptions');
      setRecentPrescriptions(prescriptionsRes.data.prescriptions.slice(0, 3));
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading || dashboardLoading) return <div>Loading dashboard...</div>;
  if (!user) return <Navigate to="/login" />;

  return (
    <div className="container">
      <h2>Welcome to Your Dashboard, {user?.first_name}!</h2>
      
      <div className="dashboard-grid">
        <div className="dashboard-card">
          <h3>Quick Actions</h3>
          <Link to="/doctors" className="btn btn-primary">
            Book New Appointment
          </Link>
        </div>
        
        <div className="dashboard-card">
          <h3>Upcoming Appointments</h3>
          {upcomingAppointments.length > 0 ? (
            upcomingAppointments.map(apt => (
              <div key={apt.appointment_id} className="appointment-item">
                <p><strong>{apt.doctor_name}</strong> - {apt.department_name}</p>
                <p>Date: {new Date(apt.appointment_date).toLocaleDateString()}</p>
                <p>Time: {apt.appointment_time}</p>
              </div>
            ))
          ) : (
            <p>No upcoming appointments</p>
          )}
          <Link to="/appointments" className="view-all-link">View all appointments</Link>
        </div>
        
        <div className="dashboard-card">
          <h3>Recent Prescriptions</h3>
          {recentPrescriptions.length > 0 ? (
            recentPrescriptions.map(presc => (
              <div key={presc.prescription_id} className="prescription-item">
                <p><strong>{presc.diagnosis}</strong></p>
                <p>By: {presc.doctor_name}</p>
                <p>Date: {new Date(presc.created_at).toLocaleDateString()}</p>
              </div>
            ))
          ) : (
            <p>No prescriptions found</p>
          )}
          <Link to="/prescriptions" className="view-all-link">View all prescriptions</Link>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;