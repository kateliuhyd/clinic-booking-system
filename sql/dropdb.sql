-- dropdb.sql
-- Drop all tables in correct order (respecting foreign key constraints)
-- Team: Jaspreet Aujla, Arav, Kate

USE clinic_booking_system;

-- Drop tables with foreign key dependencies first
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS medical_records;
DROP TABLE IF EXISTS prescription_medicines;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS prescriptions;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS time_slots;
DROP TABLE IF EXISTS doctor_specializations;
DROP TABLE IF EXISTS specializations;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS users;

-- Optional: Drop the entire database
-- DROP DATABASE IF EXISTS clinic_booking_system;