-- q2.sql: Get appointment details for the next 7 days with patient and doctor information
-- Concepts demonstrated:
-- 1. Multiple INNER JOINs across 6+ tables
-- 2. Date filtering with BETWEEN and DATE_ADD
-- 3. Complex WHERE clause with multiple conditions
-- 4. Joining through foreign key relationships
-- 5. Practical business query for daily operations
-- This query is essential for front desk staff to prepare for upcoming appointments
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    CONCAT(p_user.first_name, ' ', p_user.last_name) AS patient_name,
    p_user.phone AS patient_phone,
    CONCAT(d_user.first_name, ' ', d_user.last_name) AS doctor_name,
    dept.department_name,
    a.reason_for_visit,
    a.status,
    ts.start_time,
    ts.end_time
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.patient_id
INNER JOIN users p_user ON p.patient_id = p_user.user_id
INNER JOIN doctors d ON a.doctor_id = d.doctor_id
INNER JOIN users d_user ON d.doctor_id = d_user.user_id
INNER JOIN departments dept ON d.department_id = dept.department_id
INNER JOIN time_slots ts ON a.slot_id = ts.slot_id
WHERE a.appointment_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    AND a.status = 'scheduled'  -- Only show upcoming scheduled appointments
ORDER BY a.appointment_date, a.appointment_time;