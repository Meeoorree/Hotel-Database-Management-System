-- 1. Guest Table
CREATE TABLE Guest (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    country VARCHAR(50),
    id_type VARCHAR(20),
    id_number VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_guest_name (last_name, first_name),
    INDEX idx_guest_email (email)
);

-- 2. RoomType Table
CREATE TABLE RoomType (
    room_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL,
    base_rate DECIMAL(10,2) NOT NULL,
    description TEXT,
    size_sqft INT
);

-- 3. Room Table
CREATE TABLE Room (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    floor INT NOT NULL,
    room_type_id INT NOT NULL,
    status ENUM('available', 'occupied', 'maintenance', 'cleaning') DEFAULT 'available',
    last_cleaned TIMESTAMP,
    max_occupancy INT NOT NULL,
    FOREIGN KEY (room_type_id) REFERENCES RoomType(room_type_id),
    INDEX idx_room_status (status),
    INDEX idx_room_type (room_type_id)
);

-- 4. Department Table
CREATE TABLE Department (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(50) NOT NULL,
    manager_id INT,
    INDEX idx_dept_manager (manager_id)
);

-- 5. Employee Table
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    position VARCHAR(50),
    salary DECIMAL(10,2),
    manager_id INT,
    FOREIGN KEY (department_id) REFERENCES Department(department_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(employee_id),
    INDEX idx_emp_dept (department_id),
    INDEX idx_emp_name (last_name, first_name)
);

-- Add foreign key for department manager after Employee table exists
ALTER TABLE Department 
ADD FOREIGN KEY (manager_id) REFERENCES Employee(employee_id);

-- 6. Reservation Table
CREATE TABLE Reservation (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('confirmed', 'cancelled', 'completed', 'no-show') DEFAULT 'confirmed',
    total_amount DECIMAL(10,2),
    deposit_amount DECIMAL(10,2) DEFAULT 0,
    special_requests TEXT,
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    INDEX idx_res_dates (check_in_date, check_out_date),
    INDEX idx_res_guest (guest_id),
    INDEX idx_res_status (status),
    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
);

-- 7. RoomReservation Table (Junction)
CREATE TABLE RoomReservation (
    room_reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_id INT NOT NULL,
    room_id INT NOT NULL,
    rate DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    UNIQUE KEY unique_reservation_room (reservation_id, room_id),
    INDEX idx_room_res (room_id)
);

-- 8. Service Table
CREATE TABLE Service (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    description TEXT,
    FOREIGN KEY (department_id) REFERENCES Department(department_id),
    INDEX idx_service_dept (department_id)
);

-- 9. Bill Table
CREATE TABLE Bill (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_id INT NOT NULL UNIQUE,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    paid_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    bill_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('pending', 'partial', 'paid') DEFAULT 'pending',
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    INDEX idx_bill_status (payment_status)
);

-- 10. Charge Table
CREATE TABLE Charge (
    charge_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT NOT NULL,
    service_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 1,
    charge_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(200),
    FOREIGN KEY (bill_id) REFERENCES Bill(bill_id),
    FOREIGN KEY (service_id) REFERENCES Service(service_id),
    INDEX idx_charge_bill (bill_id),
    INDEX idx_charge_date (charge_date)
);

-- 11. Payment Table
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'credit_card', 'debit_card', 'check', 'online') NOT NULL,
    reference_number VARCHAR(100),
    FOREIGN KEY (bill_id) REFERENCES Bill(bill_id),
    INDEX idx_payment_bill (bill_id),
    INDEX idx_payment_date (payment_date)
);

-- 12. MaintenanceLog Table
CREATE TABLE MaintenanceLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    reported_by INT NOT NULL,
    assigned_to INT,
    issue_description TEXT NOT NULL,
    reported_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_date TIMESTAMP NULL,
    status ENUM('reported', 'in_progress', 'resolved') DEFAULT 'reported',
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    FOREIGN KEY (reported_by) REFERENCES Employee(employee_id),
    FOREIGN KEY (assigned_to) REFERENCES Employee(employee_id),
    INDEX idx_maint_room (room_id),
    INDEX idx_maint_status (status)
);
