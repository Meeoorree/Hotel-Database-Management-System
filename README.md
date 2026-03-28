🏨 Hotel Database Management System (HDBMS)
![alt text](https://img.shields.io/badge/Database-MySQL%20%2F%20MariaDB-blue)

![alt text](https://img.shields.io/badge/Normalization-BCNF-success)

![alt text](https://img.shields.io/badge/Project-Academic-orange)
📌 Overview
The Hotel Database Management System (HDBMS) is a comprehensive relational database project designed to manage the full operational lifecycle of a hotel property. It centralizes data for reservations, guests, rooms, employees, services, and financial transactions.
Following the principles outlined in Ramakrishnan & Gehrke's Database Management Systems and Elmasri & Navathe's Fundamentals of Database Systems, this project ensures data integrity, consistency, and efficient query processing through rigorous conceptual, logical, and physical design phases.
🚀 System Features
Reservation Management: Handles bookings, modifications, and cancellations with real-time availability checking.
Guest Management: Maintains comprehensive guest profiles, preferences, and stay history.
Room Inventory Control: Tracks room status (available, occupied, maintenance, cleaning), types, rates, and occupancy limits.
Billing & Payments: Manages charges, automatic bill generation, and payment processing.
Housekeeping Operations: Coordinates room cleaning schedules and maintenance task logging.
Employee Management: Handles staff scheduling, department assignments, and hierarchical supervisory tracking.
Service Management: Tracks auxiliary hotel services (spa, restaurant, laundry, etc.) and links them to guest bills.
Reporting & Analytics: Generates operational reports, occupancy views, and revenue summaries.
👥 End Users & Access Roles
Front Desk: Check-in/check-out, reservations, and guest services.
Housekeeping & Maintenance: Cleaning schedules, room statuses, and repair logs.
Accounting & Management: Billing, financial reporting, and strategic planning.
Guests: Self-service access for bookings and bills (future enhancement).
🧱 Database Design & Normalization
The database is fully normalized to Boyce-Codd Normal Form (BCNF) to eliminate data redundancy and update anomalies.
📊 Main Entities & Relationships
Guest (1:N) Reservation: Enforces customer history tracking.
Reservation (1:N) RoomReservation: Enables group/multi-room bookings.
RoomType (1:N) Room: Standardizes room categories and pricing.
Reservation (1:1) Bill: Ensures financial accountability per booking.
Bill (1:N) Charge & Service (1:N) Charge: Itemizes all guest expenses and links them to hotel services.
Department (1:N) Employee: Organizes staff by function.
⏳ Data Lifecycle & Obsolescence Handling
Implements a strict data retention and archival strategy:
Active Data: Current reservations and stays remain in primary tables.
Archival: Completed stays older than 1 year are moved to archive tables via monthly batch jobs.
Retention: Guest & Financial records (7 years for legal/tax compliance); Operational logs (2 years).
🔥 Advanced Database Engineering
This project goes beyond basic CRUD operations by implementing robust, enterprise-level database mechanisms:
⚡ Triggers & Constraints
Auto-Billing (CreateBillOnReservation): Automatically generates a pending bill when a reservation is confirmed.
Dynamic Totals (UpdateBillTotal): Updates the total amount on a parent Bill table in real-time whenever a new charge is inserted.
Constraint Enforcement: Uses CHECK constraints (positive pricing, valid checkout dates) and UNIQUE constraints (preventing duplicate bookings).
🔄 ACID Transactions & Isolation Levels
Deadlock-Safe Room Transfers: Utilizes ordered primary key locking (IF p_from_room_id < p_to_room_id) to prevent deadlocks during room swaps.
Complex Group Bookings with Savepoints: Uses SAVEPOINT in stored procedures to handle partial failures (e.g., if a guest requests 5 rooms but only 3 are available, it books the 3 instead of failing the entire transaction).
Night Audit Batch Processing: Cursors and loops to systematically apply nightly room charges across all active reservations.
Isolation Demonstrations: Implementations of READ COMMITTED (preventing dirty reads), REPEATABLE READ (preventing phantom reads), and SERIALIZABLE for critical financial reconciliations.
📈 Indexing & Performance
Composite & Covering Indexes: Optimized queries using composite indexes on date ranges (check_in_date, check_out_date) and bill tracking.
Full-Text Search: FULLTEXT indexing on guest special requests.
Performance Monitoring View: A custom IndexUsageStats view to monitor sequence operations and cardinality via INFORMATION_SCHEMA.
🛠️ Technical Challenges & Solutions
Circular Foreign Key Dependency: Encountered when Employee requires department_id and Department requires manager_id. Solution: Created tables without the constraint first, then injected the relationship using ALTER TABLE ADD FOREIGN KEY.
Date Overlap Logic for Double Bookings: Basic equality checks failed for overlapping dates. Solution: Implemented BETWEEN and logical OR operators in a BEFORE INSERT trigger to catch nested and overlapping date ranges.
Aborting Invalid Transactions within the DB: Needed a way to stop an INSERT if an overlap was detected. Solution: Utilized SIGNAL SQLSTATE '45000' to throw custom exceptions and alert the application layer.
Transaction Atomicity during Checkout: If payment fails, the room status shouldn't change to 'cleaning'. Solution: Encapsulated checkout in a START TRANSACTION block with a DECLARE EXIT HANDLER FOR SQLEXCEPTION to trigger an automatic ROLLBACK on failure.
Missing Data in Occupancy Views: An INNER JOIN caused empty rooms to vanish from reporting. Solution: Rewrote the view using a LEFT JOIN starting from the Room table, utilizing COALESCE and CASE statements to show "Available" when reservation data is NULL.
💻 Installation & Setup
Clone the repository:
code
Bash
git clone https://github.com/your-username/hotel-dbms.git
cd hotel-dbms
Run the SQL scripts in your MySQL/MariaDB environment:
code
SQL
-- 1. Create schema and tables
SOURCE schema.sql;

-- 2. Create views, indexes, and triggers
SOURCE triggers_and_views.sql;

-- 3. Create stored procedures (transactions)
SOURCE procedures.sql;

-- 4. Insert mock data
SOURCE sample_data.sql;
📊 Example Queries
1. Find all available rooms on a specific floor:
code
SQL
SELECT room_number, room_type_id, max_occupancy 
FROM Room
WHERE floor = 3 AND status = 'available';
2. Revenue by Room Type (Aggregation & Joins):
code
SQL
SELECT rt.type_name, COUNT(*) as bookings, SUM(rr.rate) as total_revenue 
FROM RoomType rt
JOIN Room r ON rt.room_type_id = r.room_type_id 
JOIN RoomReservation rr ON r.room_id = rr.room_id
JOIN Reservation res ON rr.reservation_id = res.reservation_id 
WHERE res.status = 'completed'
GROUP BY rt.room_type_id, rt.type_name 
HAVING total_revenue > 10000;
3. Complex Join: Guest stay history with room details:
code
SQL
SELECT g.first_name, g.last_name, res.check_in_date, res.check_out_date, 
       r.room_number, rt.type_name, rr.rate
FROM Guest g
INNER JOIN Reservation res ON g.guest_id = res.guest_id
INNER JOIN RoomReservation rr ON res.reservation_id = rr.reservation_id 
INNER JOIN Room r ON rr.room_id = r.room_id
INNER JOIN RoomType rt ON r.room_type_id = rt.room_type_id 
WHERE g.email = 'john.doe@email.com'
ORDER BY res.check_in_date DESC;
📂 Project Structure
code
Text
/hotel-dbms
│── schema.sql              # DDL for Tables & Constraints
│── sample_data.sql         # Base population data (RoomTypes, Guests, etc.)
│── triggers_and_views.sql  # Database Triggers, Indexing, and Analytics Views
│── procedures.sql          # Stored Procedures, ACID Transactions, and Error Handling
│── queries.sql             # Comprehensive list of test queries (Aggregations, Subqueries)
│── README.md               # Project documentation
👤 Author
Matvei Prikhozhdenko (ID: 2023380149)
Computer Science Student
Northwestern Polytechnical University (西北工业大学)
📚 References
Database Management Systems (4th Edition, 2024) – Ramakrishnan & Gehrke
Fundamentals of Database Systems (8th Edition, 2024) – Elmasri & Navathe
📌 Future Improvements
Web-based frontend (Spring Boot / React)
Authentication & role-based access
API integration
Real-time analytics dashboard
