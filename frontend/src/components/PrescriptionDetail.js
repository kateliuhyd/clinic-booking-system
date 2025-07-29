import React from 'react';
import './PrescriptionDetail.css';

const PrescriptionDetail = ({ prescription, onClose }) => {
  if (!prescription) return null;
  const handleDownload = () => {
    // In a real implementation, this would generate and download a PDF
    alert('PDF download functionality would be implemented here');
  };

  return (
    <div className="modal" onClick={() => {
  if (window.confirm("Close prescription details?")) onClose();
}}
>
      <div className="modal-content large" onClick={(e) => e.stopPropagation()}>
        <span className="close" onClick={onClose}>&times;</span>
        
        <div className="prescription-detail">
          <h2>Prescription Details</h2>
          
          <div className="prescription-header">
            <div>
              <h3>Patient Information</h3>
              <p><strong>Name:</strong> {prescription.patient_name}</p>
              <p><strong>DOB:</strong> {new Date(prescription.date_of_birth).toLocaleDateString()}</p>
              <p><strong>Gender:</strong> {prescription.gender}</p>
            </div>
            <div>
              <h3>Doctor Information</h3>
              <p><strong>Doctor:</strong> {prescription.doctor_name}</p>
              <p><strong>Department:</strong> {prescription.department_name}</p>
              <p><strong>Qualification:</strong> {prescription.qualification}</p>
            </div>
          </div>
          
          <div className="prescription-body">
            <h3>Diagnosis</h3>
            <p>{prescription.diagnosis}</p>
            
            <h3>Prescribed Medicines</h3>
            <table className="medicines-table">
              <thead>
                <tr>
                  <th>Medicine</th>
                  <th>Dosage</th>
                  <th>Frequency</th>
                  <th>Duration</th>
                  <th>Quantity</th>
                  <th>Instructions</th>
                </tr>
              </thead>
              <tbody>
                {Array.isArray(prescription.medicines) && prescription.medicines.map((med, index) => (
                  <tr key={index}>
                    <td>
                      {med.medicine_name}<br />
                      <small>{med.generic_name}</small>
                    </td>
                    <td>{med.dosage}</td>
                    <td>{med.frequency}</td>
                    <td>{med.duration}</td>
                    <td>{med.quantity}</td>
                    <td>{med.instructions || '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            
            {prescription.instructions && (
              <>
                <h3>Additional Instructions</h3>
                <p>{prescription.instructions}</p>
              </>
            )}
            
            {prescription.follow_up_date && (
              <>
                <h3>Follow-up</h3>
                <p>Next visit: {new Date(prescription.follow_up_date).toLocaleDateString()}</p>
              </>
            )}
          </div>
          
          <div className="prescription-footer">
            <p><strong>Date:</strong> {new Date(prescription.created_at).toLocaleDateString()}</p>
            <button onClick={handleDownload} className="btn btn-primary">
              Download PDF
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PrescriptionDetail;