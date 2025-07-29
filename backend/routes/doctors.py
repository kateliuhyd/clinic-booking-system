from flask import Blueprint, request, jsonify, session
from db.connection import execute_query

doctors_bp = Blueprint('doctors', __name__)

@doctors_bp.route('/doctors', methods=['GET'])
def get_doctors():
    """Get all doctors with optional filters"""
    # Get query parameters
    specialization = request.args.get('specialization')
    department = request.args.get('department')
    name = request.args.get('name')
    
    # Build query
    query = """
        SELECT DISTINCT
            d.doctor_id,
            CONCAT(u.first_name, ' ', u.last_name) AS doctor_name,
            u.email,
            u.phone,
            dept.department_name,
            d.qualification,
            d.experience_years,
            d.consultation_fee,
            d.bio,
            d.available_days,
            GROUP_CONCAT(DISTINCT s.specialization_name) AS specializations,
            COALESCE(AVG(r.rating), 0) AS average_rating,
            COUNT(DISTINCT r.review_id) AS review_count
        FROM doctors d
        INNER JOIN users u ON d.doctor_id = u.user_id
        INNER JOIN departments dept ON d.department_id = dept.department_id
        LEFT JOIN doctor_specializations ds ON d.doctor_id = ds.doctor_id
        LEFT JOIN specializations s ON ds.specialization_id = s.specialization_id
        LEFT JOIN reviews r ON d.doctor_id = r.doctor_id
        WHERE 1=1
    """
    
    params = []
    
    if specialization:
        query += " AND s.specialization_name LIKE %s"
        params.append(f"%{specialization}%")
    
    if department:
        query += " AND dept.department_name LIKE %s"
        params.append(f"%{department}%")
    
    if name:
        query += " AND (u.first_name LIKE %s OR u.last_name LIKE %s)"
        params.extend([f"%{name}%", f"%{name}%"])
    
    query += " GROUP BY d.doctor_id ORDER BY average_rating DESC"
    
    doctors = execute_query(query, tuple(params), fetch_all=True)
    
    return jsonify({"doctors": doctors or []}), 200

@doctors_bp.route('/doctors/<int:doctor_id>', methods=['GET'])
def get_doctor_details(doctor_id):
    """Get detailed information about a specific doctor"""
    doctor = execute_query(
        """SELECT 
            d.doctor_id,
            CONCAT(u.first_name, ' ', u.last_name) AS doctor_name,
            u.email,
            u.phone,
            dept.department_name,
            dept.location AS department_location,
            d.license_number,
            d.qualification,
            d.experience_years,
            d.consultation_fee,
            d.bio,
            d.available_days
        FROM doctors d
        INNER JOIN users u ON d.doctor_id = u.user_id
        INNER JOIN departments dept ON d.department_id = dept.department_id
        WHERE d.doctor_id = %s""",
        (doctor_id,),
        fetch_one=True
    )
    
    if not doctor:
        return jsonify({"error": "Doctor not found"}), 404
    
    # Get specializations
    specializations = execute_query(
        """SELECT s.specialization_name, s.description
           FROM doctor_specializations ds
           INNER JOIN specializations s ON ds.specialization_id = s.specialization_id
           WHERE ds.doctor_id = %s""",
        (doctor_id,),
        fetch_all=True
    )
    
    doctor['specializations'] = specializations or []
    
    # Get reviews summary
    reviews = execute_query(
        """SELECT 
            AVG(rating) AS average_rating,
            COUNT(*) AS total_reviews,
            SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) AS five_star,
            SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) AS four_star,
            SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) AS three_star,
            SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) AS two_star,
            SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) AS one_star
        FROM reviews
        WHERE doctor_id = %s""",
        (doctor_id,),
        fetch_one=True
    )
    
    doctor['reviews'] = reviews
    
    return jsonify({"doctor": doctor}), 200

@doctors_bp.route('/doctors/<int:doctor_id>/timeslots', methods=['GET'])
def get_doctor_timeslots(doctor_id):
    """Get available time slots for a doctor"""
    date = request.args.get('date')
    days = int(request.args.get('days', 7))  # Default to next 7 days
    
    if date:
        start_date = date
        end_date = date
    else:
        start_date = 'CURDATE()'
        end_date = f'DATE_ADD(CURDATE(), INTERVAL {days} DAY)'
    
    slots = execute_query(
        f"""SELECT 
            slot_id,
            slot_date,
            start_time,
            end_time,
            is_available
        FROM time_slots
        WHERE doctor_id = %s
        AND slot_date BETWEEN {start_date} AND {end_date}
        AND is_available = TRUE
        ORDER BY slot_date, start_time""",
        (doctor_id,),
        fetch_all=True
    )
    
    # Group slots by date
    slots_by_date = {}
    for slot in (slots or []):
        date_str = str(slot['slot_date'])
        if date_str not in slots_by_date:
            slots_by_date[date_str] = []
        slots_by_date[date_str].append({
            'slot_id': slot['slot_id'],
            'start_time': str(slot['start_time']),
            'end_time': str(slot['end_time'])
        })
    
    return jsonify({"slots": slots_by_date}), 200