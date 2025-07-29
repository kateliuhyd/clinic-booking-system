<<<<<<< HEAD
# clinic-booking-system
**Team Members:** Jaspreet Aujla, Arav, Kate  
**Course:** CS157A - Database Management Systems

## Project Overview

This is a web-based appointment booking system designed for clinics, allowing patients to book appointments with doctors, view prescriptions, and manage their medical appointments online. The project emphasizes database design, SQL implementation, and full-stack integration.

## Features

### For Patients:
- Register and login with secure authentication
- Search doctors by name, department, or specialization
- Book, reschedule, and cancel appointments
- View appointment history
- Access and download prescriptions
- View medical records

### For Doctors (via direct DB access):
- Manage time slots
- Upload prescriptions after appointments
- View patient appointments

## Technology Stack

- **Backend:** Python Flask with MySQL (using Blueprints and CORS)
- **Frontend:** React with React Router
- **Database:** MySQL 8.0 (BCNF normalized with 13 tables)
- **Authentication:** Session-based with bcrypt password hashing
- **API:** RESTful JSON API

## Prerequisites

- Python 3.8+
- Node.js 14+ and npm
- MySQL 8.0+
- Git

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-repo/clinic-booking-system.git
cd clinic-booking-system
```

### 2. Set Up Environment Variables

1. Copy the environment sample file:
```bash
cp backend/.env.sample backend/.env
```

2. Edit `backend/.env` with your MySQL credentials:
```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=clinic_booking_system

# Application Configuration
SECRET_KEY=your-secret-key-here-change-in-production
DEBUG=True
PORT=5000

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

### 3. Set Up MySQL Database

1. Start MySQL server:
```bash
mysql -u root -p
```

2. Create the database and tables:
```bash
source sql/createdb.sql
```

3. Verify the setup by running sample queries:
```bash
source sql/q1.sql
source sql/q2.sql
# ... etc
```

### 4. Set Up Backend

1. Create a virtual environment (recommended):
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Run the Flask server:
```bash
python app.py
```

The Flask server will start on `http://localhost:5000`

### 5. Set Up Frontend

1. Open a new terminal and navigate to frontend:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create frontend environment file:
```bash
cp .env.sample .env
```

4. Start the React development server:
```bash
npm start
```

The React app will open at `http://localhost:3000`

## Default Login Credentials

### Patients:
- Email: `john.doe@email.com`, Password: `patient123`
- Email: `jane.smith@email.com`, Password: `patient123`
- Email: `bob.wilson@email.com`, Password: `patient123`

### Doctors (for testing via API):
- Email: `dr.sarah.johnson@clinic.com`, Password: `doctor123`
- Email: `dr.michael.chen@clinic.com`, Password: `doctor123`

### Admin:
- Email: `admin@clinic.com`, Password: `admin123`

## Project Structure

```
/clinic-booking-system/
├── frontend/                  # React frontend application
│   ├── public/
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── contexts/         # React contexts (Auth)
│   │   ├── services/         # API service
│   │   ├── App.js
│   │   └── index.js
│   ├── package.json
│   └── .env.sample
├── backend/                   # Flask backend application
│   ├── routes/               # Blueprint routes
│   │   ├── auth.py
│   │   ├── doctors.py
│   │   ├── appointments.py
│   │   └── prescriptions.py
│   ├── db/                   # Database connection
│   │   └── connection.py
│   ├── app.py
│   ├── config.py
│   ├── requirements.txt
│   └── .env.sample
├── sql/                      # Database scripts
│   ├── createdb.sql         # Schema creation with sample data
│   ├── dropdb.sql           # Cleanup script
│   └── q1-q6.sql           # Complex queries with comments
├── docs/                     # Documentation
│   ├── ER_diagram.txt
│   ├── architecture.txt
│   └── api_documentation.md
├── README.md
└── .gitignore
```

## Database Schema

### Main Tables (13 total, BCNF normalized):
1. **users** - Base authentication table with timestamps
2. **patients** - Patient-specific information
3. **doctors** - Doctor information with qualifications
4. **departments** - Medical departments
5. **specializations** - Medical specializations
6. **doctor_specializations** - M:N relationship
7. **time_slots** - Available appointment slots
8. **appointments** - Bookings with timestamps
9. **prescriptions** - Medical prescriptions with timestamps
10. **medicines** - Medicine catalog
11. **prescription_medicines** - M:N relationship
12. **medical_records** - Patient medical history
13. **reviews** - Patient reviews for doctors

All tables include appropriate indexes and foreign key constraints.

## Complex SQL Queries

The project includes 6 complex queries demonstrating:
- **q1.sql**: Popular doctors analysis (JOINs, GROUP BY, aggregates)
- **q2.sql**: Next 7 days appointments (Multiple JOINs, date filtering)
- **q3.sql**: Revenue analysis with ROLLUP (Hierarchical totals)
- **q4.sql**: Chronic patients identification (Subqueries, HAVING)
- **q5.sql**: Doctor availability analysis (Derived tables, percentages)
- **q6.sql**: Prescription patterns with CTEs (WITH clause, demographics)

Each query includes detailed comments explaining the concepts demonstrated.

## API Documentation

See `docs/api_documentation.md` for complete API documentation with request/response examples for all endpoints.

## Security Features

1. **Password Security**: All passwords hashed with bcrypt
2. **SQL Injection Prevention**: Parameterized queries throughout
3. **Session Management**: Secure session handling with expiration
4. **CORS Configuration**: Properly configured for React frontend
5. **Input Validation**: Both client and server-side validation
6. **Environment Variables**: Sensitive data in .env files

## Testing the Application

### 1. User Registration Flow
1. Navigate to http://localhost:3000
2. Click "Register"
3. Fill in all required fields
4. Submit and verify success message

### 2. Appointment Booking Flow
1. Login as a patient
2. Navigate to "Find Doctors"
3. Search/filter doctors
4. Click "View Available Slots"
5. Select a time slot
6. Enter reason for visit
7. Confirm booking

### 3. API Testing with Postman/curl

See the API documentation for detailed examples. Quick test:
```bash
# Login
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{"email":"john.doe@email.com","password":"patient123"}'

# Get doctors
curl http://localhost:5000/api/doctors -b cookies.txt
```

## Troubleshooting

### Common Issues:

1. **Database Connection Error:**
   - Verify MySQL is running: `sudo service mysql status`
   - Check credentials in `.env` file
   - Ensure database exists: `SHOW DATABASES;`

2. **CORS Error:**
   - Ensure backend is running on port 5000
   - Check frontend is on port 3000
   - Verify CORS configuration in `app.py`

3. **Module Import Errors:**
   - Activate virtual environment
   - Run `pip install -r requirements.txt`
   - Check Python version (3.8+)

4. **React Not Loading:**
   - Clear npm cache: `npm cache clean --force`
   - Delete node_modules and reinstall: `rm -rf node_modules && npm install`
   - Check Node version (14+)

## Future Enhancements

1. Email notifications for appointments
2. Payment gateway integration
3. Doctor dashboard for schedule management
4. Mobile application
5. Real-time notifications with WebSockets
6. Video consultation feature
7. Advanced analytics dashboard
8. Multi-language support

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add your feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit a Pull Request

## Testing Checklist

- [ ] User registration with validation
- [ ] Login/logout functionality
- [ ] Doctor search and filtering
- [ ] Time slot availability
- [ ] Appointment booking
- [ ] Appointment cancellation
- [ ] View appointment history
- [ ] View prescriptions
- [ ] Responsive design
- [ ] Error handling
- [ ] Session management

## License

This project is created for educational purposes as part of CS157A coursework.

## Contact

For questions or issues, please contact the team members:
- Jaspreet Aujla
- Arav
- Kate

---

**Note:** This is a database-focused project for academic purposes. The emphasis is on proper database design, normalization, complex SQL queries, and secure full-stack integration.
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@email.com","password":"patient123"}'
```

**Get Doctors:**
```bash
curl http://localhost:5000/api/doctors
```

**Book Appointment:**
```bash
curl -X POST http://localhost:5000/api/appointments \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{
    "doctor_id": 4,
    "slot_id": 1,
    "reason_for_visit": "Regular checkup"
  }'
```

## Database Schema

### Main Tables:
1. **users** - Base authentication table
2. **patients** - Patient-specific information
3. **doctors** - Doctor information
4. **departments** - Medical departments
5. **appointments** - Appointment bookings
6. **prescriptions** - Medical prescriptions
7. **time_slots** - Available appointment slots
8. **medicines** - Medicine catalog
9. **medical_records** - Patient medical history
10. **reviews** - Patient reviews for doctors

See `sql/createdb.sql` for complete schema details.

## Complex Queries

The project includes 6 complex SQL queries demonstrating:
- JOINs across multiple tables
- GROUP BY with aggregates
- Subqueries
- Date filtering
- ROLLUP for hierarchical totals
- Common Table Expressions (CTEs)

## Project Structure

```
/clinic-booking-system/
├── frontend/          # Frontend HTML/CSS/JS files
├── backend/           # Flask backend application
├── sql/              # Database scripts and queries
├── docs/             # Documentation
└── README.md         # This file
```

## Known Issues & Limitations

1. PDF download for prescriptions is not implemented (shows placeholder)
2. Email notifications are not implemented
3. Payment processing is not included
4. Doctor's schedule management requires direct database access

## Security Considerations

- Passwords are hashed using bcrypt
- Session-based authentication
- Input validation on both frontend and backend
- SQL injection protection through parameterized queries
- CORS enabled for development (configure for production)

## Future Enhancements

1. Implement email notifications
2. Add payment gateway integration
3. Doctor dashboard for managing schedules
4. Mobile application
5. Real-time appointment notifications
6. Video consultation feature
7. Multi-language support

## Troubleshooting

### Common Issues:

1. **MySQL Connection Error:**
   - Ensure MySQL is running
   - Check credentials in `config.py`
   - Verify database exists

2. **CORS Error:**
   - Ensure backend is running on port 5000
   - Check CORS configuration in `app.py`

3. **Login Issues:**
   - Clear browser cookies
   - Check if session secret key is set
   - Verify user exists in database

4. **Frontend Not Loading:**
   - Check if static server is running
   - Verify correct port (8000)
   - Clear browser cache

## Testing Checklist

- [ ] User registration
- [ ] User login/logout
- [ ] Doctor search and filtering
- [ ] Appointment booking
- [ ] Appointment cancellation
- [ ] View appointment history
- [ ] View prescriptions
- [ ] Responsive design on mobile

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is created for educational purposes as part of CS157A coursework.

## Contact

For questions or issues, please contact the team members:
- Jaspreet Aujla
- Arav
- Kate

---

**Note:** This is a database-focused project for academic purposes. The emphasis is on proper database design, normalization, and SQL implementation rather than production-ready features.
>>>>>>> 80faadf1 (Initial commit)
