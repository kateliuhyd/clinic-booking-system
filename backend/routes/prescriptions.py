from flask import Blueprint, request, jsonify, session
from db.connection import execute_query, get_db_connection
from functools import wraps
from datetime import datetime

prescriptions_bp = Blueprint('prescriptions', __name__)

# Authentication decorator
def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return jsonify({"error": "Authentication required"}), 401
        return f(*args, **kwargs)
    return decorated_function

@prescriptions_bp.route('/prescriptions', methods=['POST'])
@require_auth
def upload_prescription():
    """Upload a new prescription (accessible to doctors only)"""
    if session['user_type'] != 'doctor':
        return jsonify({"error": "Only doctors can upload prescriptions"}), 403

    data = request.get_json()
    required_fields = ['appointment_id', 'diagnosis', 'medicines']

    # Basic field validation
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing field: {field}"}), 400

    # Validate follow-up date format if provided
    follow_up_date = data.get('follow_up_date')
    if follow_up_date:
        try:
            follow_up_date = datetime.strptime(follow_up_date, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({"error": "Invalid follow-up date format. Expected YYYY-MM-DD"}), 400

    # Validate medicines array and inner fields
    if not isinstance(data['medicines'], list) or not data['medicines']:
        return jsonify({"error": "Medicines must be a non-empty list"}), 400

    for med in data['medicines']:
        for key in ['medicine_id', 'dosage', 'frequency', 'duration', 'quantity']:
            if key not in med:
                return jsonify({"error": f"Missing field in medicine: {key}"}), 400

    # Verify that the appointment exists and belongs to this doctor
    appointment = execute_query(
        """SELECT appointment_id FROM appointments 
           WHERE appointment_id = %s AND doctor_id = %s AND status = 'completed'""",
        (data['appointment_id'], session['user_id']),
        fetch_one=True
    )

    if not appointment:
        return jsonify({"error": "Invalid or unauthorized appointment"}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True, prepared=True)

        # Prevent duplicate prescription uploads
        cursor.execute(
            "SELECT prescription_id FROM prescriptions WHERE appointment_id = %s",
            (data['appointment_id'],)
        )
        if cursor.fetchone():
            return jsonify({"error": "Prescription already exists for this appointment"}), 400

        # Insert prescription record
        cursor.execute(
            """INSERT INTO prescriptions (appointment_id, diagnosis, instructions, follow_up_date)
               VALUES (%s, %s, %s, %s)""",
            (
                data['appointment_id'],
                data['diagnosis'],
                data.get('instructions'),
                follow_up_date  # already parsed to date object
            )
        )
        prescription_id = cursor.lastrowid

        # Insert each prescribed medicine
        for medicine in data['medicines']:
            cursor.execute(
                """INSERT INTO prescription_medicines 
                   (prescription_id, medicine_id, dosage, frequency, duration, quantity, instructions)
                   VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                (
                    prescription_id,
                    medicine['medicine_id'],
                    medicine['dosage'],
                    medicine['frequency'],
                    medicine['duration'],
                    medicine['quantity'],
                    medicine.get('instructions')  # optional
                )
            )

        connection.commit()

        return jsonify({
            "message": "Prescription uploaded successfully",
            "prescription_id": prescription_id
        }), 201

    except Exception as e:
        connection.rollback()
        print(f"❌ Error uploading prescription: {e}")  # For backend logs
        return jsonify({"error": "Server error while uploading prescription"}), 500

    finally:
        cursor.close()
        connection.close()