import { useAuth } from '../contexts/AuthContext';
import { Navigate } from 'react-router-dom';
import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import api from '../services/api';
import PrescriptionDetail from './PrescriptionDetail';
import './Prescriptions.css';

const Prescriptions = () => {
  const { user, loading: authLoading } = useAuth();
  
  const [prescriptions, setPrescriptions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedPrescription, setSelectedPrescription] = useState(null);
  const [showDetail, setShowDetail] = useState(false);
  const [searchParams] = useSearchParams();

  useEffect(() => {
    const prescriptionId = searchParams.get('id');
    if (prescriptionId) {
      viewPrescriptionDetail(prescriptionId);
    } else {
      loadPrescriptions();
    }
  }, [searchParams]);

  const loadPrescriptions = async () => {
    try {
      const response = await api.get('/prescriptions');
      setPrescriptions(response.data.prescriptions);
    } catch (error) {
      console.error('Error loading prescriptions:', error);
    } finally {
      setLoading(false);
    }
  };
  
  // Handle auth state before making API calls
  if (authLoading) return <div>Checking authentication...</div>;
  if (!user) return <Navigate to="/login" replace />;


  const viewPrescriptionDetail = async (prescriptionId) => {
    try {
      const response = await api.get(`/prescriptions/${prescriptionId}`);
      setSelectedPrescription(response.data.prescription);
      setShowDetail(true);
    } catch (error) {
      alert(error.response?.data?.error || 'Failed to load prescription');
    }
  };

  return (
    <div className="container">
      <h2>My Prescriptions</h2>
      
      {loading ? (
        <div className="loading">Loading prescriptions...</div>
      ) : (
        <div className="prescriptions-list">
          {prescriptions.length > 0 ? (
            prescriptions.map(presc => (
              <div key={presc.prescription_id} className="prescription-card">
                <h3>{presc.diagnosis}</h3>
                <p className="doctor">Prescribed by: {presc.doctor_name}</p>
                <p className="department">{presc.department_name}</p>
                <p className="date">
                  Appointment: {new Date(presc.appointment_date).toLocaleDateString()}<br />
                  Prescribed: {new Date(presc.created_at).toLocaleDateString()}
                </p>
                <button
                  onClick={() => viewPrescriptionDetail(presc.prescription_id)}
                  className="btn btn-primary"
                >
                  View Details
                </button>
              </div>
            ))
          ) : (
            <p>No prescriptions found</p>
          )}
        </div>
      )}

      {showDetail && selectedPrescription && (
        <PrescriptionDetail
          prescription={selectedPrescription}
          onClose={() => {
            setShowDetail(false);
            setSelectedPrescription(null);
            loadPrescriptions();
          }}
        />
      )}
    </div>
  );
};

export default Prescriptions;