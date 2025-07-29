import React, { useState, useEffect } from 'react';
import api from '../services/api';
import './Appointments.css';
import { useAuth } from '../contexts/AuthContext'; 
import { Navigate } from 'react-router-dom';       


const Appointments = () => {
  const { user, loading: authLoading } = useAuth();  // fetch auth status and user info
  const [appointments, setAppointments] = useState([]);
  const [activeTab, setActiveTab] = useState('scheduled');
  const [loading, setLoading] = useState(true);



  useEffect(() => {
    loadAppointments(activeTab);
  }, [activeTab]);

  const loadAppointments = async (status) => {
    setLoading(true);
    try {
      const url = status ? `/appointments?status=${status}` : '/appointments';
      const response = await api.get(url);
      setAppointments(response.data.appointments);
    } catch (error) {
      console.error('Error loading appointments:', error);
    } finally {
      setLoading(false);
    }
  };
  
  // Handle auth state before making API calls
  if (authLoading) return <div>Checking authentication...</div>;
  if (!user) return <Navigate to="/login" replace />;


  const handleCancelAppointment = async (appointmentId) => {
    if (!window.confirm('Are you sure you want to cancel this appointment?')) {
      return;
    }

    try {
      await api.delete(`/appointments/${appointmentId}`);
      alert('Appointment cancelled successfully');
      loadAppointments(activeTab);
    } catch (error) {
      alert(error.response?.data?.error || 'Failed to cancel appointment');
    }
  };

  const handleReschedule = (appointmentId) => {
    // In a real implementation, this would open a modal with available slots
    alert('Reschedule functionality would be implemented here');
  };

  const tabs = [
    { key: 'scheduled', label: 'Upcoming' },
    { key: 'completed', label: 'Completed' },
    { key: 'cancelled', label: 'Cancelled' },
    { key: '', label: 'All' }
  ];

  return (
    <div className="container">
      <h2>My Appointments</h2>
      
      <div className="tabs">
        {tabs.map(tab => (
          <button
            key={tab.key}
            className={`tab-button ${activeTab === tab.key ? 'active' : ''}`}
            onClick={() => setActiveTab(tab.key)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="loading">Loading appointments...</div>
      ) : (
        <div className="appointments-list">
          {appointments.length > 0 ? (
            appointments.map(apt => (
              <div key={apt.appointment_id} className={`appointment-card ${apt.status}`}>
                <div className="appointment-header">
                  <h3>{apt.doctor_name}</h3>
                  <span className={`status-badge ${apt.status}`}>
                    {apt.status}
                  </span>
                </div>
                <p className="department">{apt.department_name}</p>
                <p className="datetime">
                  <strong>Date:</strong> {new Date(apt.appointment_date).toLocaleDateString()}<br />
                  <strong>Time:</strong> {apt.appointment_time}
                </p>
                <p className="reason">
                  <strong>Reason:</strong> {apt.reason_for_visit}
                </p>
                <p className="fee">
                  <strong>Consultation Fee:</strong> ${apt.consultation_fee}
                </p>
                
                {apt.status === 'scheduled' && (
                  <div className="appointment-actions">
                    <button
                      onClick={() => handleReschedule(apt.appointment_id)}
                      className="btn btn-secondary"
                    >
                      Reschedule
                    </button>
                    <button
                      onClick={() => handleCancelAppointment(apt.appointment_id)}
                      className="btn btn-danger"
                    >
                      Cancel
                    </button>
                  </div>
                )}
                
                {apt.status === 'completed' && apt.prescription_id && (
                  <a
                    href={`/prescriptions?id=${apt.prescription_id}`}
                    className="btn btn-primary"
                  >
                    View Prescription
                  </a>
                )}
              </div>
            ))
          ) : (
            <p>No appointments found</p>
          )}
        </div>
      )}
    </div>
  );
};

export default Appointments;