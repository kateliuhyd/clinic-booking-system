import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import './TimeSlotModal.css';

// This modal displays available time slots for a doctor and lets patients book appointments
const TimeSlotModal = ({ doctor, onClose, onBookingSuccess }) => {
  const [slots, setSlots] = useState({}); // Available time slots grouped by date
  const [loading, setLoading] = useState(true); // Loading indicator while fetching slots
  const [selectedSlot, setSelectedSlot] = useState(null); // User-selected slot
  const [reasonForVisit, setReasonForVisit] = useState(''); // Text input for reason
  const [booking, setBooking] = useState(false); // Booking state
  const navigate = useNavigate(); // Hook to programmatically navigate to other pages

  // Fetch available time slots on component mount or when doctor changes
  useEffect(() => {
    fetchTimeSlots();
  }, [doctor]);

  // Call backend API to get available slots
  const fetchTimeSlots = async () => {
    try {
      const response = await api.get(`/doctors/${doctor.doctor_id}/timeslots`);
      setSlots(response.data.slots);
    } catch (error) {
      console.error('Error fetching time slots:', error);
    } finally {
      setLoading(false);
    }
  };

  // Handle user selection of a time slot
  const handleSlotSelect = (slotId, date, time) => {
    setSelectedSlot({ slotId, date, time });
  };

  // Submit booking to backend
  const handleBookAppointment = async () => {
    if (!selectedSlot || !reasonForVisit.trim()) {
      alert('Please select a time slot and enter reason for visit');
      return;
    }

    setBooking(true);
    try {
      // Call backend to create appointment
      await api.post('/appointments', {
        doctor_id: doctor.doctor_id,
        slot_id: selectedSlot.slotId,
        reason_for_visit: reasonForVisit
      });

      alert('Appointment booked successfully!');
      onBookingSuccess();         // Notify parent component (to close modal, refresh list, etc.)
      navigate('/appointments');  // Redirect to appointments page
    } catch (error) {
      alert(error.response?.data?.error || 'Failed to book appointment');
    } finally {
      setBooking(false);
    }
  };

  return (
    <div className="modal" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <span className="close" onClick={onClose}>&times;</span>
        <h3>Available Time Slots - {doctor.doctor_name}</h3>

        {loading ? (
          <div className="loading">Loading time slots...</div>
        ) : Object.keys(slots).length > 0 ? (
          <>
            {/* Display slots grouped by date */}
            {Object.entries(slots).map(([date, dateSlots]) => (
              <div key={date} className="slot-date">
                <h4>
                  {new Date(date).toLocaleDateString('en-US', {
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}
                </h4>
                <div className="time-slots">
                  {dateSlots.map(slot => (
                    <button
                      key={slot.slot_id}
                      className={`slot-button ${selectedSlot?.slotId === slot.slot_id ? 'selected' : ''}`}
                      onClick={() => handleSlotSelect(slot.slot_id, date, slot.start_time)}
                    >
                      {slot.start_time} - {slot.end_time}
                    </button>
                  ))}
                </div>
              </div>
            ))}

            {/* Booking form appears after slot is selected */}
            {selectedSlot && (
              <div className="booking-form">
                <h4>Booking Details</h4>
                <p>
                  Selected: {new Date(selectedSlot.date).toLocaleDateString()} at {selectedSlot.time}
                </p>
                <textarea
                  placeholder="Reason for visit..."
                  value={reasonForVisit}
                  onChange={(e) => setReasonForVisit(e.target.value)}
                  required
                />
                <button
                  onClick={handleBookAppointment}
                  className="btn btn-primary"
                  disabled={booking}
                >
                  {booking ? 'Booking...' : 'Confirm Booking'}
                </button>
              </div>
            )}
          </>
        ) : (
          <p>No available slots in the next 7 days</p>
        )}
      </div>
    </div>
  );
};

export default TimeSlotModal;
