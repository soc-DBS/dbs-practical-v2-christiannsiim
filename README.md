# DBS Practical - Stored Procedures Implementation

A Node.js university management system implementing PostgreSQL stored procedures and database functions for module management, student records, and GPA calculations.

## Features Implemented

### 📚 Module Management with Stored Procedures
- **Create Module**: Uses `create_module()` stored procedure with duplicate checking
- **Update Module**: Uses `update_module()` stored procedure with existence validation
- **Delete Module**: Uses `delete_module()` stored procedure with existence validation

### 📊 Reporting with Database Functions
- **Module Performance**: `get_modules_performance()` function generates grade distribution reports
- **Grade Point Conversion**: `get_grade_point()` function maps grades (A, B+, C, etc.) to GPA points

### 🎓 Student GPA System
- **Automatic GPA Calculation**: `calculate_students_gpa()` stored procedure computes weighted GPA
- **GPA Display**: Student listing shows calculated GPA and last updated timestamp
- **Database Schema**: Extended student table with `gpa` and `gpa_last_updated` columns

## Database Schema

The application uses the `highgarden_university` database with the following key stored procedures and functions:

```sql
-- Stored Procedures
create_module(code, name, credit)
update_module(code, credit)  
delete_module(code)
calculate_students_gpa()

-- Functions
get_modules_performance() RETURNS TABLE
get_grade_point(grade) RETURNS NUMERIC
```

## Setup

1. **Clone this repository**

2. **Database Setup**
   - Create database `highgarden_university`
   - Restore from `completed database schema stored procedures practical.sql`

3. **Create a .env file** with the following content:

    ```
    DB_USER=
    DB_PASSWORD=
    DB_HOST=localhost
    DB_DATABASE=highgarden_university
    DB_CONNECTION_LIMIT=1
    PORT=3000
    
    JWT_SECRET_KEY=your-secret-key
    JWT_EXPIRES_IN=1d
    JWT_ALGORITHM=HS256
    ```

4. **Update the .env** content with your database credentials accordingly.

5. **Install dependencies** by running `npm install`

6. **Start the app** by running `npm start`. Alternatively to use hot reload, start the app by running `npm run dev`.

7. You should see `App listening on port 3000`

8. **(Optional)** Install the plugins recommended in `.vscode/extensions.json`

## Usage

1. Open the page: `http://localhost:3000` (replace port if different)

2. **Login** as admin using the credentials shown on the page

3. **Navigate through features**:
   - **Module Tab**: Create, update, delete modules using stored procedures
   - **Reports Tab**: 
     - Generate module performance reports
     - Calculate student GPAs using stored procedures
   - **Students Tab**: View student list with calculated GPAs

## Technical Implementation

### Models Integration
- **models/modules.js**: Uses `CALL` statements for stored procedure execution
- **models/reports.js**: Uses `SELECT FROM` for database function calls
- **models/students.js**: Retrieves GPA data from extended student table

### Error Handling
- Stored procedures include built-in validation and error messages
- Database constraints prevent invalid operations
- Application catches and displays meaningful error messages

### GPA Calculation Formula
```
GPA = (Sum of Grade Points × Credit Units) / Total Credit Units
```

## Database Functions vs Stored Procedures

- **Functions**: Used for calculations and data retrieval (e.g., `get_grade_point()`)
- **Stored Procedures**: Used for data manipulation and complex operations (e.g., `create_module()`)

## Files Modified

- `models/modules.js`: Module CRUD operations with stored procedures
- `models/reports.js`: Module performance reporting functionality  
- `models/students.js`: Student listing with GPA display
- Database: Complete schema with stored procedures and functions

---

*This practical demonstrates the integration of PostgreSQL stored procedures and functions with a Node.js application, showcasing database-driven business logic implementation.*