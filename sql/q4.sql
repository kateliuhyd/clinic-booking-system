- q4.sql: Find patients with chronic conditions (multiple appointments and prescriptions)
-- Concepts demonstrated:
-- 1. Complex subquery in FROM clause
-- 2. Multiple aggregate functions in subquery
-- 3. HAVING clause with multiple conditions
-- 4. LEFT JOINs to handle nullable relationships
-- 5. Business logic to identify high-care patients
-- This helps identify patients who may need special care programs
SELECT 
    p.patient_id,
    CONCAT(u.first_name, ' ', u.last_name) AS patient_name,
    u.phone,
    p.blood_group,
    appointment_stats.appointment_count,
    appointment_stats.prescription_count,
    appointment_stats.unique_doctors_seen,
    appointment_stats.total_medicines_prescribed,
    appointment_stats.last_appointment_date
FROM patients p
INNER JOIN users u ON p.patient_id = u.user_id
INNER JOIN (
    -- Subquery to calculate patient statistics
    SELECT 
        a.patient_id,
        COUNT(DISTINCT a.appointment_id) AS appointment_count,
        COUNT(DISTINCT pr.prescription_id) AS prescription_count,
        COUNT(DISTINCT a.doctor_id) AS unique_doctors_seen,
        COUNT(DISTINCT pm.medicine_id) AS total_medicines_prescribed,
        MAX(a.appointment_date) AS last_appointment_date
    FROM appointments a
    LEFT JOIN prescriptions pr ON a.appointment_id = pr.appointment_id
    LEFT JOIN prescription_medicines pm ON pr.prescription_id = pm.prescription_id
    WHERE a.status = 'completed'
    GROUP BY a.patient_id
    HAVING COUNT(DISTINCT a.appointment_id) >= 2  -- At least 2 appointments
        AND COUNT(DISTINCT pr.prescription_id) >= 1  -- At least 1 prescription
) AS appointment_stats ON p.patient_id = appointment_stats.patient_id
ORDER BY appointment_stats.appointment_count DESC, appointment_stats.prescription_count DESC;
