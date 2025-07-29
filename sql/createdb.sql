-- createdb.sql
-- Online Appointment Booking System Database Creation Script
-- Team: Jaspreet Aujla, Arav, Kate

-- Create database
CREATE DATABASE IF NOT EXISTS clinic_booking_system;
USE clinic_booking_system;

-- Table 1: users (base authentication table)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type ENUM('patient', 'doctor', 'admin') NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_user_type (user_type)
);

-- Table 2: departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,
    location VARCHAR(100),
    phone VARCHAR(15)
);

-- Table 3: patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other') NOT NULL,
    blood_group VARCHAR(5),
    emergency_contact VARCHAR(15),
    address TEXT,
    medical_history TEXT,
    FOREIGN KEY (patient_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table 4: doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    department_id INT NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    qualification VARCHAR(200) NOT NULL,
    experience_years INT NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL,
    bio TEXT,
    available_days VARCHAR(50), -- e.g., "Mon,Tue,Wed,Thu,Fri"
    FOREIGN KEY (doctor_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    INDEX idx_department (department_id)
);

-- Table 5: specializations
CREATE TABLE specializations (
    specialization_id INT PRIMARY KEY AUTO_INCREMENT,
    specialization_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- Table 6: doctor_specializations (M:N relationship)
CREATE TABLE doctor_specializations (
    doctor_id INT,
    specialization_id INT,
    PRIMARY KEY (doctor_id, specialization_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (specialization_id) REFERENCES specializations(specialization_id)
);

-- Table 7: time_slots
CREATE TABLE time_slots (
    slot_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    UNIQUE KEY unique_slot (doctor_id, slot_date, start_time),
    INDEX idx_doctor_date (doctor_id, slot_date),
    INDEX idx_availability (is_available, slot_date)
);

-- Table 8: appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    slot_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('scheduled', 'completed', 'cancelled', 'no-show') DEFAULT 'scheduled',
    reason_for_visit TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (slot_id) REFERENCES time_slots(slot_id),
    INDEX idx_patient (patient_id),
    INDEX idx_doctor (doctor_id),
    INDEX idx_date (appointment_date),
    INDEX idx_status (status)
);

-- Table 9: prescriptions
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    diagnosis TEXT NOT NULL,
    instructions TEXT,
    follow_up_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    UNIQUE KEY unique_appointment (appointment_id)
);

-- Table 10: medicines
CREATE TABLE medicines (
    medicine_id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_name VARCHAR(200) NOT NULL,
    generic_name VARCHAR(200),
    manufacturer VARCHAR(100),
    medicine_type VARCHAR(50) -- tablet, syrup, injection, etc.
);

-- Table 11: prescription_medicines (M:N relationship)
CREATE TABLE prescription_medicines (
    prescription_id INT,
    medicine_id INT,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(50) NOT NULL, -- e.g., "3 times daily"
    duration VARCHAR(50) NOT NULL, -- e.g., "7 days"
    quantity INT NOT NULL,
    instructions TEXT,
    PRIMARY KEY (prescription_id, medicine_id),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);

-- Table 12: medical_records
CREATE TABLE medical_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    appointment_id INT,
    record_type VARCHAR(50) NOT NULL, -- lab_result, imaging, report, etc.
    record_date DATE NOT NULL,
    description TEXT,
    file_path VARCHAR(500),
    uploaded_by INT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id),
    INDEX idx_patient_records (patient_id, record_date)
);

-- Table 13: reviews
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    UNIQUE KEY unique_review (appointment_id),
    INDEX idx_doctor_rating (doctor_id, rating)
);

-- Insert sample data

-- Insert users (3 patients, 5 doctors, 1 admin)
INSERT INTO users (email, password_hash, user_type, first_name, last_name, phone) VALUES
-- Patients (password: patient123)
('john.doe@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyNiLXCRLDsBO.', 'patient', 'John', 'Doe', '555-0101'),
('jane.smith@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyNiLXCRLDsBO.', 'patient', 'Jane', 'Smith', '555-0102'),
('bob.wilson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyNiLXCRLDsBO.', 'patient', 'Bob', 'Wilson', '555-0103'),
-- Doctors (password: doctor123)
('dr.sarah.johnson@clinic.com', '$2b$12$mI8kCGYtVRCkJHaNFrC8I.5VlXBLk2U2qKV3CfirSKnCUrAODmPp6', 'doctor', 'Sarah', 'Johnson', '555-0201'),
('dr.michael.chen@clinic.com', '$2b$12$mI8kCGYtVRCkJHaNFrC8I.5VlXBLk2U2qKV3CfirSKnCUrAODmPp6', 'doctor', 'Michael', 'Chen', '555-0202'),
('dr.emily.davis@clinic.com', '$2b$12$mI8kCGYtVRCkJHaNFrC8I.5VlXBLk2U2qKV3CfirSKnCUrAODmPp6', 'doctor', 'Emily', 'Davis', '555-0203'),
('dr.james.martinez@clinic.com', '$2b$12$mI8kCGYtVRCkJHaNFrC8I.5VlXBLk2U2qKV3CfirSKnCUrAODmPp6', 'doctor', 'James', 'Martinez', '555-0204'),
('dr.lisa.anderson@clinic.com', '$2b$12$mI8kCGYtVRCkJHaNFrC8I.5VlXBLk2U2qKV3CfirSKnCUrAODmPp6', 'doctor', 'Lisa', 'Anderson', '555-0205'),
-- Admin (password: admin123)
('admin@clinic.com', '$2b$12$rBg3vZk2nW8YZhYJbGB5YuQxMe3gD7G8HRzCLKnlcvqMEtpzB7gL6', 'admin', 'System', 'Admin', '555-0001');

-- Insert departments
INSERT INTO departments (department_name, description, location, phone) VALUES
('General Medicine', 'Primary care and general health services', 'Building A, Floor 1', '555-1001'),
('Cardiology', 'Heart and cardiovascular system care', 'Building A, Floor 2', '555-1002'),
('Orthopedics', 'Musculoskeletal system treatment', 'Building B, Floor 1', '555-1003'),
('Pediatrics', 'Medical care for infants, children, and adolescents', 'Building B, Floor 2', '555-1004'),
('Dermatology', 'Skin, hair, and nail treatments', 'Building C, Floor 1', '555-1005');

-- Insert patients
INSERT INTO patients (patient_id, date_of_birth, gender, blood_group, emergency_contact, address, medical_history) VALUES
(1, '1985-03-15', 'M', 'O+', '555-9101', '123 Main St, City, State 12345', 'No major health issues'),
(2, '1990-07-22', 'F', 'A+', '555-9102', '456 Oak Ave, City, State 12345', 'Allergic to penicillin'),
(3, '1978-11-08', 'M', 'B+', '555-9103', '789 Pine Rd, City, State 12345', 'Diabetes Type 2, Hypertension');

-- Insert doctors
INSERT INTO doctors (doctor_id, department_id, license_number, qualification, experience_years, consultation_fee, bio, available_days) VALUES
(4, 1, 'LIC001', 'MD, General Medicine', 15, 150.00, 'Experienced general practitioner with focus on preventive care', 'Mon,Tue,Wed,Thu,Fri'),
(5, 2, 'LIC002', 'MD, Cardiology, FACC', 12, 250.00, 'Specialist in interventional cardiology', 'Mon,Tue,Wed,Thu'),
(6, 3, 'LIC003', 'MD, Orthopedics', 10, 200.00, 'Expert in joint replacement and sports injuries', 'Tue,Wed,Thu,Fri'),
(7, 4, 'LIC004', 'MD, Pediatrics', 8, 175.00, 'Child healthcare specialist with focus on development', 'Mon,Wed,Fri'),
(8, 5, 'LIC005', 'MD, Dermatology', 6, 180.00, 'Specializes in medical and cosmetic dermatology', 'Mon,Tue,Thu,Fri');

-- Insert specializations
INSERT INTO specializations (specialization_name, description) VALUES
('Internal Medicine', 'Diagnosis and treatment of adult diseases'),
('Interventional Cardiology', 'Catheter-based treatment of heart diseases'),
('Sports Medicine', 'Treatment of sports and exercise-related injuries'),
('Pediatric Development', 'Child growth and development monitoring'),
('Cosmetic Dermatology', 'Aesthetic skin treatments'),
('Joint Replacement', 'Surgical replacement of joints'),
('Preventive Medicine', 'Disease prevention and health promotion');

-- Insert doctor_specializations
INSERT INTO doctor_specializations (doctor_id, specialization_id) VALUES
(4, 1), (4, 7),  -- Dr. Johnson: Internal Medicine, Preventive Medicine
(5, 2),          -- Dr. Chen: Interventional Cardiology
(6, 3), (6, 6),  -- Dr. Davis: Sports Medicine, Joint Replacement
(7, 4),          -- Dr. Martinez: Pediatric Development
(8, 5);          -- Dr. Anderson: Cosmetic Dermatology

-- Insert time_slots (for next 7 days, 4 slots per day for each doctor)
INSERT INTO time_slots (doctor_id, slot_date, start_time, end_time, is_available) VALUES
-- Dr. Johnson (doctor_id: 4) - Today and next 6 days
(4, CURDATE(), '09:00:00', '09:30:00', TRUE),
(4, CURDATE(), '09:30:00', '10:00:00', FALSE), -- Booked
(4, CURDATE(), '10:00:00', '10:30:00', TRUE),
(4, CURDATE(), '10:30:00', '11:00:00', TRUE),
(4, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:00:00', '09:30:00', TRUE),
(4, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:30:00', '10:00:00', TRUE),
(4, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:00:00', '10:30:00', FALSE), -- Booked
(4, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:30:00', '11:00:00', TRUE),
-- Dr. Chen (doctor_id: 5)
(5, CURDATE(), '14:00:00', '14:30:00', TRUE),
(5, CURDATE(), '14:30:00', '15:00:00', TRUE),
(5, CURDATE(), '15:00:00', '15:30:00', FALSE), -- Booked
(5, CURDATE(), '15:30:00', '16:00:00', TRUE),
(5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00:00', '14:30:00', TRUE),
(5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:30:00', '15:00:00', TRUE),
(5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '15:00:00', '15:30:00', TRUE),
(5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '15:30:00', '16:00:00', TRUE);

-- Insert appointments
INSERT INTO appointments (patient_id, doctor_id, slot_id, appointment_date, appointment_time, status, reason_for_visit) VALUES
(1, 4, 2, CURDATE(), '09:30:00', 'completed', 'Regular checkup'),
(2, 4, 7, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:00:00', 'scheduled', 'Follow-up visit'),
(3, 5, 11, CURDATE(), '15:00:00', 'completed', 'Chest pain evaluation');

-- Insert prescriptions
INSERT INTO prescriptions (appointment_id, diagnosis, instructions, follow_up_date) VALUES
(1, 'Mild hypertension', 'Monitor blood pressure daily. Low sodium diet recommended.', DATE_ADD(CURDATE(), INTERVAL 30 DAY)),
(3, 'Stable angina', 'Avoid strenuous activities. Take medications as prescribed.', DATE_ADD(CURDATE(), INTERVAL 14 DAY));

-- Insert medicines
INSERT INTO medicines (medicine_name, generic_name, manufacturer, medicine_type) VALUES
('Lisinopril 10mg', 'Lisinopril', 'PharmaCorp', 'tablet'),
('Aspirin 81mg', 'Aspirin', 'HealthMed', 'tablet'),
('Metformin 500mg', 'Metformin', 'DiabetesCare', 'tablet'),
('Atorvastatin 20mg', 'Atorvastatin', 'CardioHealth', 'tablet'),
('Nitroglycerin 0.4mg', 'Nitroglycerin', 'HeartCare', 'sublingual tablet');

-- Insert prescription_medicines
INSERT INTO prescription_medicines (prescription_id, medicine_id, dosage, frequency, duration, quantity, instructions) VALUES
(1, 1, '10mg', 'Once daily', '30 days', 30, 'Take in the morning'),
(1, 2, '81mg', 'Once daily', '30 days', 30, 'Take with food'),
(2, 4, '20mg', 'Once daily', 'Ongoing', 30, 'Take at bedtime'),
(2, 5, '0.4mg', 'As needed', 'Ongoing', 20, 'Place under tongue during chest pain');

-- Insert medical_records
INSERT INTO medical_records (patient_id, appointment_id, record_type, record_date, description, uploaded_by) VALUES
(1, 1, 'lab_result', CURDATE(), 'Blood pressure reading: 140/90', 4),
(3, 3, 'imaging', CURDATE(), 'ECG results - minor ST changes', 5);

-- Insert reviews
INSERT INTO reviews (patient_id, doctor_id, appointment_id, rating, review_text) VALUES
(1, 4, 1, 5, 'Dr. Johnson is very thorough and caring. Highly recommend!'),
(3, 5, 3, 4, 'Good doctor, but wait time was a bit long.');