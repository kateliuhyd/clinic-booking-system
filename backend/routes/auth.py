from flask import Blueprint, request, jsonify, session
import bcrypt
from db.connection import execute_query

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user (patient only via API)"""
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 
                      'date_of_birth', 'gender']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing field: {field}"}), 400
    
    # Hash password
    password_hash = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    # Check if email exists
    existing_user = execute_query(
        "SELECT user_id FROM users WHERE email = %s",
        (data['email'],),
        fetch_one=True
    )
    
    if existing_user:
        return jsonify({"error": "Email already registered"}), 400
    
    # Insert user
    user_id = execute_query(
        """INSERT INTO users (email, password_hash, user_type, first_name, last_name, phone)
           VALUES (%s, %s, 'patient', %s, %s, %s)""",
        (data['email'], password_hash, data['first_name'], data['last_name'], data['phone'])
    )
    
    if not user_id:
        return jsonify({"error": "Failed to create user"}), 500
    
    # Insert patient details
    patient_result = execute_query(
        """INSERT INTO patients (patient_id, date_of_birth, gender, blood_group, 
           emergency_contact, address, medical_history)
           VALUES (%s, %s, %s, %s, %s, %s, %s)""",
        (user_id, data['date_of_birth'], data['gender'], 
         data.get('blood_group'), data.get('emergency_contact'),
         data.get('address'), data.get('medical_history'))
    )
    
    if patient_result is None:
        return jsonify({"error": "Failed to create patient record"}), 500
    
    return jsonify({"message": "Registration successful", "user_id": user_id}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    """User login"""
    data = request.get_json()
    
    if not data.get('email') or not data.get('password'):
        return jsonify({"error": "Email and password required"}), 400
    
    # Get user
    user = execute_query(
        """SELECT user_id, email, password_hash, user_type, first_name, last_name
           FROM users WHERE email = %s""",
        (data['email'],),
        fetch_one=True
    )
    
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401
    
    # Verify password
    if not bcrypt.checkpw(data['password'].encode('utf-8'), user['password_hash'].encode('utf-8')):
        return jsonify({"error": "Invalid credentials"}), 401
    
    # Set session
    session['user_id'] = user['user_id']
    session['user_type'] = user['user_type']
    session['email'] = user['email']
    
    # Remove password hash from response
    user.pop('password_hash')
    
    return jsonify({"message": "Login successful", "user": user}), 200

@auth_bp.route('/logout', methods=['POST'])
def logout():
    """User logout"""
    session.clear()
    return jsonify({"message": "Logout successful"}), 200

@auth_bp.route('/me', methods=['GET'])
def get_current_user():
    """Get current logged-in user info"""
    if 'user_id' not in session:
        return jsonify({"error": "Not authenticated"}), 401
    
    user = execute_query(
        """SELECT user_id, email, user_type, first_name, last_name, phone
           FROM users WHERE user_id = %s""",
        (session['user_id'],),
        fetch_one=True
    )
    
    return jsonify({"user": user}), 200