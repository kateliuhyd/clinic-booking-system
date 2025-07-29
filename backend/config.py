import os
from dotenv import load_dotenv

load_dotenv()

# Database configuration from environment variables
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'ROOTROOT'),
    'database': os.getenv('DB_NAME', 'clinic_booking_system'),
    'autocommit': False,  # Explicit transaction control
    'pool_name': 'clinic_pool',
    'pool_size': 5
}

# Application configuration
APP_CONFIG = {
    'SECRET_KEY': os.getenv('SECRET_KEY', 'dev-secret-key'),
    'DEBUG': os.getenv('DEBUG', 'True').lower() == 'true',
    'PORT': int(os.getenv('PORT', 5000))
}