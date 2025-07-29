-- q3.sql: Calculate revenue by department and doctor for completed appointments
-- Concepts demonstrated:
-- 1. GROUP BY with ROLLUP for hierarchical totals
-- 2. Aggregate functions (COUNT, SUM, AVG, MIN, MAX)
-- 3. COALESCE for handling NULL values from ROLLUP
-- 4. CASE statement for conditional logic
-- 5. Financial reporting with subtotals and grand totals
-- This query provides revenue insights for management decision-making
SELECT 
    COALESCE(dept.department_name, 'TOTAL') AS department,
    COALESCE(CONCAT(u.first_name, ' ', u.last_name), 
             CASE WHEN dept.department_name IS NOT NULL THEN 'Department Total' ELSE '' END) AS doctor_name,
    COUNT(a.appointment_id) AS completed_appointments,
    SUM(d.consultation_fee) AS total_revenue,
    AVG(d.consultation_fee) AS avg_consultation_fee,
    MIN(a.appointment_date) AS first_appointment,
    MAX(a.appointment_date) AS last_appointment
FROM appointments a
INNER JOIN doctors d ON a.doctor_id = d.doctor_id
INNER JOIN users u ON d.doctor_id = u.user_id
INNER JOIN departments dept ON d.department_id = dept.department_id
WHERE a.status = 'completed'  -- Only count revenue from completed appointments
GROUP BY dept.department_name, u.first_name, u.last_name WITH ROLLUP
HAVING department IS NOT NULL  -- Remove the grand total NULL row if not needed
ORDER BY department, total_revenue DESC;