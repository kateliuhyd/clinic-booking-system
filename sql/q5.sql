-- q5.sql: Doctor availability analysis - find doctors with most available slots in next 30 days
-- Concepts demonstrated:
-- 1. Derived table (subquery in FROM)
-- 2. Complex aggregation with GROUP_CONCAT
-- 3. Conditional aggregation with CASE statements
-- 4. Percentage calculations
-- 5. Multiple JOIN types (INNER, LEFT)
-- This helps with load balancing and identifying doctors who may be underutilized
SELECT 
    doctor_availability.*,
    ROUND((doctor_availability.available_slots / doctor_availability.total_slots) * 100, 2) AS availability_percentage
FROM (
    SELECT 
        d.doctor_id,
        CONCAT(u.first_name, ' ', u.last_name) AS doctor_name,
        dept.department_name,
        -- Concatenate all specializations for each doctor
        GROUP_CONCAT(DISTINCT s.specialization_name ORDER BY s.specialization_name SEPARATOR ', ') AS specializations,
        COUNT(ts.slot_id) AS total_slots,
        SUM(CASE WHEN ts.is_available = TRUE THEN 1 ELSE 0 END) AS available_slots,
        SUM(CASE WHEN ts.is_available = FALSE THEN 1 ELSE 0 END) AS booked_slots,
        -- Find next available date
        MIN(CASE WHEN ts.is_available = TRUE THEN ts.slot_date ELSE NULL END) AS next_available_date,
        d.consultation_fee
    FROM doctors d
    INNER JOIN users u ON d.doctor_id = u.user_id
    INNER JOIN departments dept ON d.department_id = dept.department_id
    LEFT JOIN doctor_specializations ds ON d.doctor_id = ds.doctor_id
    LEFT JOIN specializations s ON ds.specialization_id = s.specialization_id
    LEFT JOIN time_slots ts ON d.doctor_id = ts.doctor_id
    WHERE ts.slot_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
    GROUP BY d.doctor_id, u.first_name, u.last_name, dept.department_name, d.consultation_fee
) AS doctor_availability
WHERE doctor_availability.available_slots > 0  -- Only show doctors with available slots
ORDER BY availability_percentage DESC, doctor_availability.consultation_fee ASC;
