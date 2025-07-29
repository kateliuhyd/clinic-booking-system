# API Documentation - Clinic Booking System

## Base URL
```
http://localhost:5000/api
```

## Authentication
The API uses session-based authentication. Include credentials in requests:
```javascript
fetch(url, {
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  }
})
```

## Endpoints

### 1. Authentication

#### Register New Patient
```http
POST /api/register
```

**Request Body:**
```json
{
  "email": "john.doe@email.com",
  "password": "securepassword123",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "555-0123",
  "date_of_birth": "1990-01-15",
  "gender": "M",
  "blood_group": "O+",
  "emergency_contact": "555-9999",
  "address": "123 Main St, City, State 12345",
  "medical_history": "No major health issues"
}
```

**Success Response (201):**
```json
{
  "message": "Registration successful",
  "user_id": 42
}
```

**Error Response (400):**
```json
{
  "error": "Email already registered"
}
```

---

#### User Login
```http
POST /api/login
```

**Request Body:**
```json
{
  "email": "john.doe@email.com",
  "password": "securepassword123"
}
```

**Success Response (200):**
```json
{
  "message": "Login successful",
  "user": {
    "user_id": 1,
    "email": "john.doe@email.com",
    "user_type": "patient",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

**Error Response (401):**
```json
{
  "error": "Invalid credentials"
}
```

---

#### User Logout
```http
POST /api/logout
```

**Success Response (200):**
```json
{
  "message": "Logout successful"
}
```

---

#### Get Current User
```http
GET /api/me
```

**Success Response (200):**
```json
{
  "user": {
    "user_id": 1,
    "email": "john.doe@email.com",
    "user_type": "patient",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "555-0123"
  }
}
```

**Error Response (401):**
```json
{
  "error": "Not authenticated"
}
```

---

### 2. Doctors

#### List All Doctors
```http
GET /api/doctors?name=sarah&department=cardiology&specialization=heart
```

**Query Parameters:**
- `name` (optional): Search by doctor name
- `department` (optional): Filter by department
- `specialization` (optional): Filter by specialization

**Success Response (200):**
```json
{
  "doctors": [
    {
      "doctor_id": 4,
      "doctor_name": "Dr. Sarah Johnson",
      "email": "dr.sarah.johnson@clinic.com",
      "phone": "555-0201",
      "department_name": "General Medicine",
      "qualification": "MD, General Medicine",
      "experience_years": 15,
      "consultation_fee": 150.00,
      "bio": "Experienced general practitioner",
      "available_days": "Mon,Tue,Wed,Thu,Fri",
      "specializations": "Internal Medicine, Preventive Medicine",
      "average_rating": 4.5,
      "review_count": 25
    }
  ]
}
```

---

#### Get Doctor Details
```http
GET /api/doctors/{doctor_id}
```

**Success Response (200):**
```json
{
  "doctor": {
    "doctor_id": 4,
    "doctor_name": "Dr. Sarah Johnson",
    "email": "dr.sarah.johnson@clinic.com",
    "phone": "555-0201",
    "department_name": "General Medicine",
    "department_location": "Building A, Floor 1",
    "license_number": "LIC001",
    "qualification": "MD, General Medicine",
    "experience_years": 15,
    "consultation_fee": 150.00,
    "bio": "Experienced general practitioner",
    "available_days": "Mon,Tue,Wed,Thu,Fri",
    "specializations": [
      {
        "specialization_name": "Internal Medicine",
        "description": "Diagnosis and treatment of adult diseases"
      }
    ],
    "reviews": {
      "average_rating": 4.5,
      "total_reviews": 25,
      "five_star": 15,
      "four_star": 8,
      "three_star": 2,
      "two_star": 0,
      "one_star": 0
    }
  }
}
```

---

#### Get Doctor Time Slots
```http
GET /api/doctors/{doctor_id}/timeslots?date=2024-03-15&days=7
```

**Query Parameters:**
- `date` (optional): Specific date to check
- `days` (optional): Number of days to check (default: 7)

**Success Response (200):**
```json
{
  "slots": {
    "2024-03-15": [
      {
        "slot_id": 101,
        "start_time": "09:00:00",
        "end_time": "09:30:00"
      },
      {
        "slot_id": 102,
        "start_time": "10:00:00",
        "end_time": "10:30:00"
      }
    ],
    "2024-03-16": [
      {
        "slot_id": 105,
        "start_time": "14:00:00",
        "end_time": "14:30:00"
      }
    ]
  }
}
```

---

### 3. Appointments

#### Book Appointment
```http
POST /api/appointments
```

**Request Body:**
```json
{
  "doctor_id": 4,
  "slot_id": 101,
  "reason_for_visit": "Regular checkup and blood pressure monitoring"
}
```

**Success Response (201):**
```json
{
  "message": "Appointment booked successfully",
  "appointment_id": 123
}
```

**Error Response (400):**
```json
{
  "error": "Slot not available"
}
```

---

#### Get User's Appointments
```http
GET /api/appointments?status=scheduled
```

**Query Parameters:**
- `status` (optional): Filter by status (scheduled, completed, cancelled)

**Success Response (200):**
```json
{
  "appointments": [
    {
      "appointment_id": 123,
      "appointment_date": "2024-03-15",
      "appointment_time": "09:00:00",
      "status": "scheduled",
      "reason_for_visit": "Regular checkup",
      "doctor_name": "Dr. Sarah Johnson",
      "department_name": "General Medicine",
      "consultation_fee": 150.00
    }
  ]
}
```

---

#### Reschedule Appointment
```http
PUT /api/appointments/{appointment_id}
```

**Request Body:**
```json
{
  "new_slot_id": 105
}
```

**Success Response (200):**
```json
{
  "message": "Appointment rescheduled successfully"
}
```

---

#### Cancel Appointment
```http
DELETE /api/appointments/{appointment_id}
```

**Success Response (200):**
```json
{
  "message": "Appointment cancelled successfully"
}
```

---

#### Get Appointment History
```http
GET /api/appointments/history
```

**Success Response (200):**
```json
{
  "history": [
    {
      "appointment_id": 100,
      "appointment_date": "2024-02-15",
      "appointment_time": "10:00:00",
      "status": "completed",
      "reason_for_visit": "Follow-up",
      "doctor_name": "Dr. Sarah Johnson",
      "department_name": "General Medicine",
      "prescription_id": 50,
      "diagnosis": "Mild hypertension",
      "prescription_date": "2024-02-15 10:30:00"
    }
  ]
}
```

---

### 4. Prescriptions

#### Create Prescription (Doctors Only)
```http
POST /api/prescriptions
```

**Request Body:**
```json
{
  "appointment_id": 123,
  "diagnosis": "Mild hypertension",
  "instructions": "Monitor blood pressure daily",
  "follow_up_date": "2024-04-15",
  "medicines": [
    {
      "medicine_id": 1,
      "dosage": "10mg",
      "frequency": "Once daily",
      "duration": "30 days",
      "quantity": 30,
      "instructions": "Take in the morning"
    }
  ]
}
```

**Success Response (201):**
```json
{
  "message": "Prescription uploaded successfully",
  "prescription_id": 51
}
```

---

#### Get Prescription Details
```http
GET /api/prescriptions/{prescription_id}
```

**Success Response (200):**
```json
{
  "prescription": {
    "prescription_id": 51,
    "diagnosis": "Mild hypertension",
    "instructions": "Monitor blood pressure daily",
    "follow_up_date": "2024-04-15",
    "created_at": "2024-03-15 10:30:00",
    "appointment_date": "2024-03-15",
    "patient_id": 1,
    "doctor_id": 4,
    "doctor_name": "Dr. Sarah Johnson",
    "qualification": "MD, General Medicine",
    "department_name": "General Medicine",
    "patient_name": "John Doe",
    "date_of_birth": "1990-01-15",
    "gender": "M",
    "medicines": [
      {
        "medicine_name": "Lisinopril 10mg",
        "generic_name": "Lisinopril",
        "medicine_type": "tablet",
        "dosage": "10mg",
        "frequency": "Once daily",
        "duration": "30 days",
        "quantity": 30,
        "instructions": "Take in the morning"
      }
    ]
  }
}
```

---

#### List User's Prescriptions
```http
GET /api/prescriptions
```

**Success Response (200):**
```json
{
  "prescriptions": [
    {
      "prescription_id": 51,
      "diagnosis": "Mild hypertension",
      "created_at": "2024-03-15 10:30:00",
      "appointment_date": "2024-03-15",
      "doctor_name": "Dr. Sarah Johnson",
      "department_