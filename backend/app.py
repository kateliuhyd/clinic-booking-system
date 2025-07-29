# Team: Kate, Jaspreet, Arav
from flask import Flask, jsonify
from flask_cors import CORS
from datetime import timedelta
import os
from flask_session import Session
from dotenv import load_dotenv


# Load environment variables
load_dotenv()

# Import blueprints
from routes.auth import auth_bp
from routes.doctors import doctors_bp
from routes.appointments import appointments_bp
from routes.prescriptions import prescriptions_bp

def create_app():
    print("✅ Flask is running with create_app() correctly")
    """Application factory pattern"""
    app = Flask(__name__)
    
    # Configuration
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    app.config['SESSION_TYPE'] = 'filesystem'
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=24)
    app.config['SESSION_COOKIE_SAMESITE'] = 'None'
    app.config['SESSION_COOKIE_SECURE'] = False
    Session(app)

    
    # Enable CORS with credentials support
    CORS(app, resources={r"/api/*": {"origins": "http://localhost:3000"}}, supports_credentials=True)
    
    # Register blueprints with /api prefix
    print("❌ Flask CORS Config: /api/* → http://localhost:3000")
    app.register_blueprint(auth_bp, url_prefix='/api')
    print("✅ Flask CORS Config: /api/* → http://localhost:3000")
    app.register_blueprint(doctors_bp, url_prefix='/api')
    print("✅ Flask CORS Config: /api/* → http://localhost:3000")
    app.register_blueprint(appointments_bp, url_prefix='/api')
    print("✅ Flask CORS Config: /api/* → http://localhost:3000")
    app.register_blueprint(prescriptions_bp, url_prefix='/api')
    
    @app.route('/api/test')
    def test_cors():
        return jsonify({"message": "CORS is working!"})
    
    # Root endpoint
    @app.route('/')
    def home():
        return jsonify({
            "message": "Clinic Booking System API",
            "version": "1.0",
            "status": "running"
        })
    
    # Health check endpoint
    @app.route('/health')
    def health_check():
        return jsonify({"status": "healthy"}), 200
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({"error": "Resource not found"}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({"error": "Internal server error"}), 500
    
    @app.errorhandler(400)
    def bad_request(error):
        return jsonify({"error": "Bad request"}), 400
    
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host="0.0.0.0", port=5050)
