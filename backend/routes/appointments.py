from flask import Blueprint, request, jsonify, session
from datetime import datetime
from db.connection import execute_query, get_db_connection

appointments_bp = Blueprint('appointments', __name__)

def require_auth(f):
    """Decorator to require authentication"""
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return jsonify({"error": "Authentication required"}), 401
        return f(*args, **kwargs)
    decorated_function.__name__ = f.__name__
    return decorated_function

@appointments_bp.route('/appointments', methods=['POST'])
@require_auth
def book_appointment():
    """Book a new appointment"""
    if session['user_type'] != 'patient':
        return jsonify({"error": "Only patients can book appointments"}), 403
    
    data = request.get_json()
    required_fields = ['doctor_id', 'slot_id', 'reason_for_visit']
    
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing field: {field}"}), 400
    
    # Get slot details
    slot = execute_query(
        """SELECT slot_id, slot_date, start_time, is_available
           FROM time_slots
           WHERE slot_id = %s AND doctor_id = %s""",
        (data['slot_id'], data['doctor_id']),
        fetch_one=True
    )
    
    if not slot:
        return jsonify({"error": "Invalid slot"}), 400
    
    if not slot['is_available']:
        return jsonify({"error": "Slot not available"}), 400
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # Check if prescription already exists
        cursor.execute(
            "SELECT prescription_id FROM prescriptions WHERE appointment_id = %s",
            (data['appointment_id'],)
        )
        if cursor.fetchone():
            return jsonify({"error": "Prescription already exists for this appointment"}), 400
        
        # Create prescription
        cursor.execute(
            """INSERT INTO prescriptions (appointment_id, diagnosis, instructions, follow_up_date)
               VALUES (%s, %s, %s, %s)""",
            (data['appointment_id'], data['diagnosis'], 
             data.get('instructions'), data.get('follow_up_date'))
        )
        prescription_id = cursor.lastrowid
        
        # Add medicines
        for medicine in data['medicines']:
            cursor.execute(
                """INSERT INTO prescription_medicines 
                   (prescription_id, medicine_id, dosage, frequency, duration, quantity, instructions)
                   VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                (prescription_id, medicine['medicine_id'], medicine['dosage'],
                 medicine['frequency'], medicine['duration'], medicine['quantity'],
                 medicine.get('instructions'))
            )
        
        connection.commit()
        
        return jsonify({
            "message": "Prescription uploaded successfully",
            "prescription_id": prescription_id
        }), 201
        
    except Exception as e:
        connection.rollback()
        return jsonify({"error": f"Failed to upload prescription: {str(e)}"}), 500
    finally:
        cursor.close()
        connection.close()

@appointments_bp.route('/prescriptions/<int:prescription_id>', methods=['GET'])
@require_auth
def get_prescription(prescription_id):
    """Get prescription details"""
    # Get prescription with verification
    prescription = execute_query(
        """SELECT 
            p.prescription_id,
            p.diagnosis,
            p.instructions,
            p.follow_up_date,
            p.created_at,
            a.appointment_date,
            a.patient_id,
            a.doctor_id,
            CONCAT(doc_user.first_name, ' ', doc_user.last_name) AS doctor_name,
            doc.qualification,
            dept.department_name,
            CONCAT(pat_user.first_name, ' ', pat_user.last_name) AS patient_name,
            pat.date_of_birth,
            pat.gender
        FROM prescriptions p
        INNER JOIN appointments a ON p.appointment_id = a.appointment_id
        INNER JOIN doctors doc ON a.doctor_id = doc.doctor_id
        INNER JOIN users doc_user ON doc.doctor_id = doc_user.user_id
        INNER JOIN departments dept ON doc.department_id = dept.department_id
        INNER JOIN patients pat ON a.patient_id = pat.patient_id
        INNER JOIN users pat_user ON pat.patient_id = pat_user.user_id
        WHERE p.prescription_id = %s""",
        (prescription_id,),
        fetch_one=True
    )
    
    if not prescription:
        return jsonify({"error": "Prescription not found"}), 404
    
    # Verify access
    if session['user_type'] == 'patient' and prescription['patient_id'] != session['user_id']:
        return jsonify({"error": "Access denied"}), 403
    elif session['user_type'] == 'doctor' and prescription['doctor_id'] != session['user_id']:
        return jsonify({"error": "Access denied"}), 403
    
    # Get medicines
    medicines = execute_query(
        """SELECT 
            m.medicine_name,
            m.generic_name,
            m.medicine_type,
            pm.dosage,
            pm.frequency,
            pm.duration,
            pm.quantity,
            pm.instructions
        FROM prescription_medicines pm
        INNER JOIN medicines m ON pm.medicine_id = m.medicine_id
        WHERE pm.prescription_id = %s""",
        (prescription_id,),
        fetch_all=True
    )
    
    prescription['medicines'] = medicines or []
    
    return jsonify({"prescription": prescription}), 200