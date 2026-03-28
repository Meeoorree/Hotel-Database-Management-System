
SET FOREIGN_KEY_CHECKS = 0;

-- 1. RoomType (Base table - no dependencies)
INSERT INTO RoomType (type_name, base_rate, description, size_sqft) VALUES
('Standard Single', 89.99, 'Cozy room with single bed', 200),
('Standard Double', 109.99, 'Comfortable room with double bed', 250),
('Deluxe Suite', 189.99, 'Spacious suite with living area', 450),
('Executive Suite', 299.99, 'Luxury suite with premium amenities', 600),
('Penthouse', 499.99, 'Top floor luxury accommodation', 1200),
('Ocean View', 159.99, 'Standard room with ocean view', 300),
('Family Suite', 229.99, 'Two connecting rooms for families', 700),
('Accessible Room', 119.99, 'ADA compliant room', 280),
('Business Class', 179.99, 'Work desk and meeting area', 350),
('Honeymoon Suite', 349.99, 'Romantic package with champagne', 500);

-- 2. Department (Base table)
INSERT INTO Department (department_name) VALUES
('Front Desk'),
('Housekeeping'),
('Maintenance'),
('Food & Beverage'),
('Spa & Wellness'),
('Management'),
('Security'),
('Events'),
('Concierge'),
('Accounting');

-- 3. Guest (Base table)
INSERT INTO Guest (first_name, last_name, email, phone, address, city, country, id_type, id_number) VALUES
('James', 'Smith', 'james.smith@email.com', '+1-555-1234', '123 Main St', 'New York', 'USA', 'Passport', 'P12345678'),
('Maria', 'Garcia', 'maria.g@mail.com', '+34-912-3456', 'Calle Sol 45', 'Madrid', 'Spain', 'ID Card', 'Y54321234'),
('Robert', 'Johnson', 'rob.j@web.com', '+44-7700-1234', '10 Downing St', 'London', 'UK', 'Driver License', 'DL78906543'),
('Li', 'Wei', 'li.wei@cn.com', '+86-138-0013', '798 Art District', 'Beijing', 'China', 'Passport', 'G87654321'),
('Sarah', 'Williams', 'sarahw@company.com', '+1-555-5678', '456 Park Ave', 'Chicago', 'USA', 'Passport', 'P98765432'),
('Mohammed', 'Khan', 'mkhan@email.ae', '+971-50-1234', 'Sheikh Zayed Rd', 'Dubai', 'UAE', 'Emirates ID', '784-1985-1234567-1'),
('Emma', 'Brown', 'emma.b@mail.uk', '+44-7911-1234', '32 Baker Street', 'London', 'UK', 'Passport', 'P11223344'),
('Carlos', 'Santos', 'c.santos@br.com', '+55-11-98765', 'Avenida Paulista 1000', 'São Paulo', 'Brazil', 'CPF', '123.456.789-09'),
('Yuki', 'Tanaka', 'y.tanaka@jp.co', '+81-3-1234', 'Shibuya Crossing 2', 'Tokyo', 'Japan', 'My Number', '123456789012'),
('Olivia', 'Davis', 'olivia.d@mail.com', '+1-555-9101', '789 Sunset Blvd', 'Los Angeles', 'USA', 'Driver License', 'DL44556677');

-- 4. Employee (Depends on Department)
INSERT INTO Employee (first_name, last_name, email, phone, hire_date, department_id, position, salary) VALUES
('Michael', 'Scott', 'm.scott@hotel.com', '555-1001', '2020-01-15', 1, 'Front Desk Manager', 55000.00),
('Janet', 'Wilson', 'j.wilson@hotel.com', '555-1002', '2021-03-22', 2, 'Head Housekeeper', 48000.00),
('Thomas', 'Reed', 't.reed@hotel.com', '555-1003', '2019-11-10', 3, 'Maintenance Supervisor', 52000.00),
('Sophie', 'Martin', 's.martin@hotel.com', '555-1004', '2022-05-14', 4, 'Restaurant Manager', 51000.00),
('David', 'Kim', 'd.kim@hotel.com', '555-1005', '2020-08-30', 5, 'Spa Director', 58000.00),
('Jennifer', 'Lee', 'j.lee@hotel.com', '555-1006', '2021-02-18', 6, 'General Manager', 85000.00),
('Robert', 'Taylor', 'r.taylor@hotel.com', '555-1007', '2022-01-05', 7, 'Security Chief', 46000.00),
('Emily', 'Clark', 'e.clark@hotel.com', '555-1008', '2021-07-12', 8, 'Events Coordinator', 49000.00),
('Daniel', 'White', 'd.white@hotel.com', '555-1009', '2020-04-25', 9, 'Chief Concierge', 53000.00),
('Lisa', 'Moore', 'l.moore@hotel.com', '555-1010', '2019-09-15', 10, 'Chief Accountant', 67000.00);

-- Update Department managers
UPDATE Department SET manager_id = 1 WHERE department_id = 1;
UPDATE Department SET manager_id = 2 WHERE department_id = 2;
UPDATE Department SET manager_id = 3 WHERE department_id = 3;
UPDATE Department SET manager_id = 4 WHERE department_id = 4;
UPDATE Department SET manager_id = 5 WHERE department_id = 5;
UPDATE Department SET manager_id = 6 WHERE department_id = 6;
UPDATE Department SET manager_id = 7 WHERE department_id = 7;
UPDATE Department SET manager_id = 8 WHERE department_id = 8;
UPDATE Department SET manager_id = 9 WHERE department_id = 9;
UPDATE Department SET manager_id = 10 WHERE department_id = 10;

-- Update Employee managers
UPDATE Employee SET manager_id = 6 WHERE employee_id IN (1,2,3,4,5,7,8,9,10);
UPDATE Employee SET manager_id = 1 WHERE employee_id = 1;  -- Self-reference for GM

-- 5. Room (Depends on RoomType)
INSERT INTO Room (room_number, floor, room_type_id, status, max_occupancy) VALUES
('101', 1, 1, 'available', 1),
('102', 1, 1, 'occupied', 1),
('103', 1, 2, 'available', 2),
('201', 2, 2, 'maintenance', 2),
('202', 2, 3, 'cleaning', 2),
('203', 2, 3, 'available', 3),
('301', 3, 4, 'occupied', 2),
('302', 3, 5, 'available', 4),
('303', 3, 6, 'occupied', 2),
('401', 4, 7, 'available', 5),
('402', 4, 8, 'available', 2),
('501', 5, 9, 'occupied', 2),
('502', 5, 10, 'available', 2);

-- 6. Reservation (Depends on Guest)
INSERT INTO Reservation (guest_id, check_in_date, check_out_date, booking_date, status, total_amount, deposit_amount) VALUES
(1, '2025-07-01', '2025-07-05', '2025-06-01 10:00:00', 'confirmed', 439.96, 100.00),
(3, '2025-07-10', '2025-07-15', '2025-05-15 14:30:00', 'confirmed', 899.95, 200.00),
(5, '2025-06-28', '2025-07-02', '2025-06-10 09:15:00', 'completed', 479.96, 120.00),
(2, '2025-08-01', '2025-08-10', '2025-06-20 16:45:00', 'confirmed', 1439.91, 300.00),
(4, '2025-07-20', '2025-07-25', '2025-06-15 11:20:00', 'confirmed', 1249.95, 250.00),
(7, '2025-06-25', '2025-06-30', '2025-05-30 13:10:00', 'cancelled', 599.95, 150.00),
(9, '2025-07-05', '2025-07-12', '2025-06-18 17:30:00', 'confirmed', 1749.93, 400.00),
(6, '2025-07-15', '2025-07-20', '2025-06-22 10:45:00', 'no-show', 999.95, 200.00),
(10, '2025-08-05', '2025-08-15', '2025-07-01 08:00:00', 'confirmed', 1799.90, 450.00),
(8, '2025-06-20', '2025-06-25', '2025-06-01 12:00:00', 'completed', 649.95, 150.00);

-- 7. RoomReservation (Depends on Reservation and Room)
INSERT INTO RoomReservation (reservation_id, room_id, rate) VALUES
(1, 1, 89.99),
(2, 8, 499.99),
(3, 3, 109.99),
(4, 10, 159.99),
(5, 6, 249.99),
(6, 11, 119.99),
(7, 4, 249.99),
(8, 12, 199.99),
(9, 13, 179.99),
(10, 5, 129.99);

-- 8. Service (Depends on Department)
INSERT INTO Service (service_name, department_id, base_price, description) VALUES
('Breakfast Buffet', 4, 19.99, 'Continental breakfast buffet'),
('Spa Massage', 5, 89.99, '60-minute therapeutic massage'),
('Laundry Service', 2, 12.99, 'Next-day laundry service'),
('Airport Transfer', 1, 49.99, 'Round-trip airport shuttle'),
('Room Service', 4, 7.99, '24-hour room service fee'),
('Meeting Room Rental', 8, 149.99, 'Per 4-hour block'),
('Dry Cleaning', 2, 9.99, 'Express dry cleaning'),
('Swim Lesson', 5, 39.99, 'Private 30-minute lesson'),
('Wine Tasting', 4, 59.99, 'Sommelier-led tasting session'),
('Late Checkout', 1, 29.99, 'Extended checkout until 4 PM');

-- 9. Bill (Depends on Reservation)
INSERT INTO Bill (reservation_id, total_amount, paid_amount, bill_date, payment_status) VALUES
(1, 439.96, 439.96, '2025-07-05 10:00:00', 'paid'),
(2, 899.95, 450.00, '2025-07-15 09:30:00', 'partial'),
(3, 479.96, 479.96, '2025-07-02 11:15:00', 'paid'),
(4, 1439.91, 500.00, '2025-08-01 14:00:00', 'partial'),
(5, 1249.95, 0.00, '2025-07-20 08:45:00', 'pending'),
(7, 1749.93, 1749.93, '2025-07-05 12:30:00', 'paid'),
(9, 1799.90, 900.00, '2025-08-05 16:20:00', 'partial'),
(10, 649.95, 649.95, '2025-06-25 10:10:00', 'paid');

-- 10. Charge (Depends on Bill and Service)
INSERT INTO Charge (bill_id, service_id, amount, quantity, description) VALUES
(1, 1, 19.99, 4, 'Daily breakfast'),
(1, 4, 49.99, 1, 'Airport transfer'),
(2, 2, 89.99, 2, 'Couples massage'),
(3, 5, 7.99, 5, 'Room service charges'),
(4, 6, 149.99, 1, 'Business meeting'),
(5, 10, 29.99, 1, 'Late checkout fee'),
(7, 8, 39.99, 3, 'Swim lessons'),
(8, 3, 12.99, 5, 'Laundry service'),
(3, 7, 9.99, 2, 'Dry cleaning'),
(2, 9, 59.99, 1, 'Wine tasting event');

-- 11. Payment (Depends on Bill)
INSERT INTO Payment (bill_id, payment_date, amount, payment_method, reference_number) VALUES
(1, '2025-07-05 10:05:00', 439.96, 'credit_card', 'CC-20250705-1001'),
(2, '2025-07-10 11:20:00', 450.00, 'cash', 'CASH-20250710-1120'),
(3, '2025-07-02 11:20:00', 479.96, 'online', 'ONL-20250702-1120'),
(4, '2025-08-01 14:05:00', 500.00, 'debit_card', 'DC-20250801-1405'),
(7, '2025-07-05 12:35:00', 1749.93, 'credit_card', 'CC-20250705-1235'),
(8, '2025-06-25 10:15:00', 649.95, 'online', 'ONL-20250625-1015'),
(9, '2025-08-05 16:25:00', 900.00, 'check', 'CHK-87654321'),
(2, '2025-07-12 09:45:00', 200.00, 'credit_card', 'CC-20250712-0945'),
(4, '2025-08-05 10:30:00', 300.00, 'cash', 'CASH-20250805-1030');

-- 12. MaintenanceLog (Depends on Room and Employee)
INSERT INTO MaintenanceLog (room_id, reported_by, assigned_to, issue_description, reported_date, resolved_date, status) VALUES
(4, 1, 3, 'AC not cooling', '2025-06-27 09:00:00', '2025-06-27 11:30:00', 'resolved'),
(2, 2, 3, 'Leaky faucet', '2025-06-28 08:15:00', NULL, 'in_progress'),
(5, 2, 7, 'TV not working', '2025-06-25 14:20:00', '2025-06-26 10:00:00', 'resolved'),
(9, 1, 3, 'Safe malfunction', '2025-06-26 16:45:00', NULL, 'reported'),
(7, 2, 7, 'Balcony door stuck', '2025-06-24 10:30:00', '2025-06-24 15:00:00', 'resolved'),
(11, 1, 3, 'Toilet running', '2025-06-28 07:30:00', NULL, 'reported'),
(3, 2, 7, 'Minibar not cooling', '2025-06-27 13:15:00', '2025-06-27 16:45:00', 'resolved');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;