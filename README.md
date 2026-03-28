# 🏨 Hotel Database Management System (HDBMS)

![Database](https://img.shields.io/badge/Database-MySQL%20%2F%20MariaDB-blue)
![Normalization](https://img.shields.io/badge/Normalization-BCNF-success)
![Project](https://img.shields.io/badge/Project-Academic-orange)

---

## 📌 Overview
The **Hotel Database Management System (HDBMS)** is a comprehensive relational database project designed to manage the full operational lifecycle of a hotel property. It centralizes data for reservations, guests, rooms, employees, services, and financial transactions.

Following the principles outlined in *Database Management Systems* (Ramakrishnan & Gehrke) and *Fundamentals of Database Systems* (Elmasri & Navathe), this project ensures data integrity, consistency, and efficient query processing through rigorous conceptual, logical, and physical design phases.

---

## 🚀 System Features

- **Reservation Management**  
  Handles bookings, modifications, and cancellations with real-time availability checking.

- **Guest Management**  
  Maintains comprehensive guest profiles, preferences, and stay history.

- **Room Inventory Control**  
  Tracks room status (available, occupied, maintenance, cleaning), types, rates, and occupancy limits.

- **Billing & Payments**  
  Manages charges, automatic bill generation, and payment processing.

- **Housekeeping Operations**  
  Coordinates room cleaning schedules and maintenance task logging.

- **Employee Management**  
  Handles staff scheduling, department assignments, and hierarchical supervisory tracking.

- **Service Management**  
  Tracks auxiliary hotel services (spa, restaurant, laundry, etc.) and links them to guest bills.

- **Reporting & Analytics**  
  Generates operational reports, occupancy views, and revenue summaries.

---

## 👥 End Users & Access Roles

- **Front Desk** → Check-in/check-out, reservations, guest services  
- **Housekeeping & Maintenance** → Cleaning schedules, room status, repair logs  
- **Accounting & Management** → Billing, financial reporting, planning  
- **Guests (Future)** → Self-service booking and billing  

---

## 🧱 Database Design & Normalization

The database is fully normalized to **Boyce-Codd Normal Form (BCNF)** to eliminate redundancy and prevent anomalies.

### 📊 Main Entities & Relationships

- Guest **(1:N)** Reservation  
- Reservation **(1:N)** RoomReservation  
- RoomType **(1:N)** Room  
- Reservation **(1:1)** Bill  
- Bill **(1:N)** Charge & Service **(1:N)** Charge  
- Department **(1:N)** Employee  

---

## ⏳ Data Lifecycle & Obsolescence Handling

- **Active Data** → Current reservations and stays remain in primary tables  
- **Archival** → Completed stays (>1 year) moved to archive tables via batch jobs  
- **Retention Policy**
  - Guest & Financial Data: 7 years  
  - Operational Logs: 2 years  

---

## 🔥 Advanced Database Engineering

### ⚡ Triggers & Constraints

- **Auto-Billing (CreateBillOnReservation)**  
  Automatically generates a bill when a reservation is confirmed  

- **Dynamic Totals (UpdateBillTotal)**  
  Updates bill totals when new charges are added  

- **Constraint Enforcement**
  - CHECK constraints (valid dates, positive pricing)
  - UNIQUE constraints (prevent duplicate bookings)

---

### 🔄 ACID Transactions & Isolation Levels

- **Deadlock-Safe Room Transfers**  
  Uses ordered locking to prevent deadlocks  

- **Group Booking with Savepoints**  
  Handles partial failures without aborting full transactions  

- **Night Audit Processing**  
  Applies daily charges using cursors and loops  

- **Isolation Levels Implemented**
  - READ COMMITTED  
  - REPEATABLE READ  
  - SERIALIZABLE  

---

## 📈 Indexing & Performance

- **Composite Indexes** → Optimized date and reservation queries  
- **Full-Text Search** → Special requests search  
- **Monitoring View** → `IndexUsageStats` for performance tracking  

---

## 🛠️ Technical Challenges & Solutions

- **Circular Foreign Keys**  
  Solved using deferred constraint creation (`ALTER TABLE`)

- **Double Booking Prevention**  
  Implemented using date overlap logic (`BETWEEN` + conditions)

- **Transaction Safety**  
  Used `SIGNAL SQLSTATE '45000'` for controlled failure handling  

- **Atomic Checkout Process**  
  Wrapped in transactions with rollback on failure  

- **Missing Data in Views**  
  Fixed using `LEFT JOIN` + `COALESCE`  

---

## 💻 Installation & Setup

Run SQL scripts
-- 1. Create schema and tables
SOURCE schema.sql;

-- 2. Create views, triggers, indexes
SOURCE triggers_and_views.sql;

-- 3. Create stored procedures
SOURCE procedures.sql;

-- 4. Insert sample data
SOURCE sample_data.sql;

📊 Example Queries
1. Available rooms on a floor
SELECT room_number, room_type_id, max_occupancy 
FROM Room
WHERE floor = 3 AND status = 'available';

2. Revenue by room type
SELECT rt.type_name, COUNT(*) as bookings, SUM(rr.rate) as total_revenue 
FROM RoomType rt
JOIN Room r ON rt.room_type_id = r.room_type_id 
JOIN RoomReservation rr ON r.room_id = rr.room_id
JOIN Reservation res ON rr.reservation_id = res.reservation_id 
WHERE res.status = 'completed'
GROUP BY rt.room_type_id, rt.type_name 
HAVING total_revenue > 10000;

3. Guest stay history
 SELECT g.first_name, g.last_name, res.check_in_date, res.check_out_date, 
       r.room_number, rt.type_name, rr.rate
FROM Guest g
INNER JOIN Reservation res ON g.guest_id = res.guest_id
INNER JOIN RoomReservation rr ON res.reservation_id = rr.reservation_id 
INNER JOIN Room r ON rr.room_id = r.room_id
INNER JOIN RoomType rt ON r.room_type_id = rt.room_type_id 
WHERE g.email = 'john.doe@email.com'
ORDER BY res.check_in_date DESC;

👤 Author

Matvei Prikhozhdenko (ID: 2023380149)
Computer Science Student
Northwestern Polytechnical University (西北工业大学)

📚 References
Database Management Systems – Ramakrishnan & Gehrke
Fundamentals of Database Systems – Elmasri & Navathe

📌 Future Improvements
Web frontend (Spring Boot / React)
Authentication & role-based access
API integration
Real-time analytics dashboard
