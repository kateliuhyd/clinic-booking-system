import React, { useState, useEffect } from 'react';
import api from '../services/api';
import TimeSlotModal from './TimeSlotModal';
import './Doctors.css';

const Doctors = () => {
  // State variables
  const [doctors, setDoctors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    name: '',
    department: '',
    specialization: ''
  });
  const [selectedDoctor, setSelectedDoctor] = useState(null);
  const [showSlotModal, setShowSlotModal] = useState(false);

  // Load all doctors when component mounts
  useEffect(() => {
    searchDoctors();
  }, []);

  // Fetch doctors from backend with filters
  const searchDoctors = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (filters.name) params.append('name', filters.name);
      if (filters.department) params.append('department', filters.department);
      if (filters.specialization) params.append('specialization', filters.specialization);

      const response = await api.get(`/doctors?${params.toString()}`);
      setDoctors(response.data.doctors);
    } catch (error) {
      console.error('Error fetching doctors:', error);
    } finally {
      setLoading(false);
    }
  };

  // Update filters when input fields change
  const handleFilterChange = (e) => {
    setFilters({
      ...filters,
      [e.target.name]: e.target.value
    });
  };

  // Trigger doctor search on form submission
  const handleSearch = (e) => {
    e.preventDefault();
    searchDoctors();
  };

  // Open modal to view time slots
  const handleViewSlots = (doctor) => {
    setSelectedDoctor(doctor);
    setShowSlotModal(true);
  };

  return (
    <div className="container">
      <h2>Find Doctors</h2>

      {/* Search Filters */}
      <form onSubmit={handleSearch} className="search-filters">
        <input
          type="text"
          name="name"
          placeholder="Search by name..."
          value={filters.name}
          onChange={handleFilterChange}
        />
        <select
          name="department"
          value={filters.department}
          onChange={handleFilterChange}
        >
          <option value="">All Departments</option>
          <option value="General Medicine">General Medicine</option>
          <option value="Cardiology">Cardiology</option>
          <option value="Orthopedics">Orthopedics</option>
          <option value="Pediatrics">Pediatrics</option>
          <option value="Dermatology">Dermatology</option>
        </select>
        <input
          type="text"
          name="specialization"
          placeholder="Specialization..."
          value={filters.specialization}
          onChange={handleFilterChange}
        />
        <button type="submit" className="btn btn-primary">
          Search
        </button>
      </form>

      {/* Loading state */}
      {loading ? (
        <div className="loading">Loading doctors...</div>
      ) : (
        <div className="doctors-grid">
          {/* Display doctor cards */}
          {doctors.length > 0 ? (
            doctors.map(doctor => (
              <div key={doctor.doctor_id} className="doctor-card">
                <h3>{doctor.doctor_name}</h3>
                <p className="department">{doctor.department_name}</p>
                <p className="specializations">
                  {doctor.specializations || 'General Practice'}
                </p>
                <p className="experience">{doctor.experience_years} years experience</p>
                <p className="fee">Consultation Fee: ${doctor.consultation_fee}</p>
                <div className="rating">
                  Rating: {doctor.average_rating ? doctor.average_rating.toFixed(1) : 'N/A'} 
                  ({doctor.review_count} reviews)
                </div>
                <button
                  onClick={() => handleViewSlots(doctor)}
                  className="btn btn-primary"
                >
                  View Available Slots
                </button>
              </div>
            ))
          ) : (
            <p>No doctors found</p>
          )}
        </div>
      )}

      {/* Time Slot Booking Modal */}
      {showSlotModal && (
        <TimeSlotModal
          doctor={selectedDoctor}
          onClose={() => setShowSlotModal(false)}
          onBookingSuccess={() => {
            setShowSlotModal(false);
            // Optionally: show a toast or reload appointments
          }}
        />
      )}
    </div>
  );
};

export default Doctors;