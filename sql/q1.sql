-- q1.sql: Find the most popular doctors based on appointment count and average rating
-- Concepts demonstrated: 
-- 1. Multiple JOINs (INNER and LEFT)
-- 2. GROUP BY with multiple columns
-- 3. Aggregate functions (COUNT, AVG)
-- 4. HAVING clause for filtering grouped results
-- 5. Complex ORDER BY with multiple criteria
-- This query helps identify the most sought-after doctors for business insights
SELECT 
    d.doctor_id,
    CONCAT(u.first_name, ' ', u.last_name) AS doctor_name,
    dept.department_name,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    AVG(r.rating) AS average_rating,
    COUNT(DISTINCT r.review_id) AS review_count,
    d.consultation_fee
FROM doctors d
INNER JOIN users u ON d.doctor_id = u.user_id
INNER JOIN departments dept ON d.department_id = dept.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN reviews r ON d.doctor_id = r.doctor_id
WHERE a.status IN ('completed', 'scheduled')
GROUP BY d.doctor_id, u.first_name, u.last_name, dept.department_name, d.consultation_fee
HAVING COUNT(DISTINCT a.appointment_id) > 0
ORDER BY total_appointments DESC, average_rating DESC
LIMIT 10;