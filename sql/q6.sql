-- q6.sql: Most prescribed medicines and patient demographics
-- Concepts: CTEs, Aggregates, Demographic insights
WITH prescription_stats AS (
    SELECT 
        m.medicine_id,
        m.medicine_name,
        m.generic_name,
        COUNT(DISTINCT pm.prescription_id) AS prescription_count,
        COUNT(DISTINCT p.patient_id) AS patient_count,
        SUM(pm.quantity) AS total_quantity_prescribed
    FROM medicines m
    INNER JOIN prescription_medicines pm ON m.medicine_id = pm.medicine_id
    INNER JOIN prescriptions pr ON pm.prescription_id = pr.prescription_id
    INNER JOIN appointments a ON pr.appointment_id = a.appointment_id
    INNER JOIN patients p ON a.patient_id = p.patient_id
    GROUP BY m.medicine_id, m.medicine_name, m.generic_name
),
patient_demographics AS (
    SELECT 
        m.medicine_id,
        AVG(YEAR(CURDATE()) - YEAR(p.date_of_birth)) AS avg_patient_age,
        SUM(CASE WHEN p.gender = 'M' THEN 1 ELSE 0 END) AS male_patients,
        SUM(CASE WHEN p.gender = 'F' THEN 1 ELSE 0 END) AS female_patients,
        GROUP_CONCAT(DISTINCT p.blood_group ORDER BY p.blood_group) AS blood_groups
    FROM medicines m
    INNER JOIN prescription_medicines pm ON m.medicine_id = pm.medicine_id
    INNER JOIN prescriptions pr ON pm.prescription_id = pr.prescription_id
    INNER JOIN appointments a ON pr.appointment_id = a.appointment_id
    INNER JOIN patients p ON a.patient_id = p.patient_id
    GROUP BY m.medicine_id
)
SELECT 
    ps.medicine_name,
    ps.generic_name,
    ps.prescription_count,
    ps.patient_count,
    ps.total_quantity_prescribed,
    ROUND(pd.avg_patient_age, 1) AS avg_patient_age,
    pd.male_patients,
    pd.female_patients,
    pd.blood_groups,
    ROUND(ps.total_quantity_prescribed / ps.prescription_count, 2) AS avg_quantity_per_prescription
FROM prescription_stats ps
INNER JOIN patient_demographics pd ON ps.medicine_id = pd.medicine_id
WHERE ps.prescription_count >= 2
ORDER BY ps.prescription_count DESC, ps.total_quantity_prescribed DESC
LIMIT 20;