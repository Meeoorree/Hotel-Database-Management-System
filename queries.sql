-- 1. Selection: Find all available rooms on a specific floor
SELECT room_number, room_type_id, max_occupancy 
FROM Room 
WHERE floor = 3 AND status = 'available';

-- 2. Projection: List all guest names and emails
SELECT DISTINCT first_name, last_name, email 
FROM Guest;

-- 3. Update: Change room status after cleaning
UPDATE Room 
SET status = 'available', last_cleaned = NOW() 
WHERE room_id = 101;

-- 4. Alter: Add a new column for guest preferences
ALTER TABLE Guest 
ADD COLUMN preferences TEXT;

-- 5. Rename: Change column name for clarity
ALTER TABLE Employee 
CHANGE COLUMN salary annual_salary DECIMAL(10,2);

-- 6. Delete: Remove cancelled reservations older than 1 year
DELETE FROM Reservation 
WHERE status = 'cancelled' 
AND booking_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 7. Order By: List employees by department and hire date
SELECT e.first_name, e.last_name, d.department_name, e.hire_date 
FROM Employee e 
JOIN Department d ON e.department_id = d.department_id 
ORDER BY d.department_name, e.hire_date DESC;

-- 8. Group By with Aggregation: Revenue by room type
SELECT rt.type_name, COUNT(*) as bookings, SUM(rr.rate) as total_revenue
FROM RoomType rt
JOIN Room r ON rt.room_type_id = r.room_type_id
JOIN RoomReservation rr ON r.room_id = rr.room_id
JOIN Reservation res ON rr.reservation_id = res.reservation_id
WHERE res.status = 'completed'
GROUP BY rt.room_type_id, rt.type_name
HAVING total_revenue > 10000;

-- 9. Complex Join: Guest stay history with room details
SELECT g.first_name, g.last_name, res.check_in_date, res.check_out_date,
       r.room_number, rt.type_name, rr.rate
FROM Guest g
INNER JOIN Reservation res ON g.guest_id = res.guest_id
INNER JOIN RoomReservation rr ON res.reservation_id = rr.reservation_id
INNER JOIN Room r ON rr.room_id = r.room_id
INNER JOIN RoomType rt ON r.room_type_id = rt.room_type_id
WHERE g.email = 'john.doe@email.com'
ORDER BY res.check_in_date DESC;

-- 10. Subquery with IN: Rooms never reserved
SELECT room_number, floor, status
FROM Room
WHERE room_id NOT IN (
    SELECT DISTINCT room_id 
    FROM RoomReservation
);

-- 11. Subquery with EXISTS: Guests with unpaid bills
SELECT DISTINCT g.first_name, g.last_name, g.email
FROM Guest g
WHERE EXISTS (
    SELECT 1 
    FROM Reservation res
    JOIN Bill b ON res.reservation_id = b.reservation_id
    WHERE res.guest_id = g.guest_id 
    AND b.payment_status != 'paid'
);

-- 12. Subquery with ANY: Rooms priced above any suite
SELECT r.room_number, rt.type_name, rt.base_rate
FROM Room r
JOIN RoomType rt ON r.room_type_id = rt.room_type_id
WHERE rt.base_rate > ANY (
    SELECT base_rate 
    FROM RoomType 
    WHERE type_name LIKE '%Suite%'
);

-- 13. Subquery with ALL: Most expensive room type
SELECT type_name, base_rate
FROM RoomType
WHERE base_rate >= ALL (
    SELECT base_rate 
    FROM RoomType
);
-- 14. UNION: All people in the hotel (guests and employees)
SELECT first_name, last_name, email, 'Guest' as person_type
FROM Guest
UNION
SELECT first_name, last_name, email, 'Employee' as person_type
FROM Employee
ORDER BY last_name, first_name;

-- 15. INTERSECTION (using JOIN): Employees who are also guests
SELECT e.first_name, e.last_name, e.email
FROM Employee e
INNER JOIN Guest g ON e.email = g.email;

-- 16. EXCEPT (using NOT EXISTS): Departments without services
SELECT d.department_name
FROM Department d
WHERE NOT EXISTS (
    SELECT 1 
    FROM Service s 
    WHERE s.department_id = d.department_id
);

-- 17. NULL handling: Find rooms without maintenance records
SELECT r.room_number, r.floor, 
       COALESCE(ml.issue_description, 'No maintenance issues') as status
FROM Room r
LEFT JOIN MaintenanceLog ml ON r.room_id = ml.room_id
WHERE ml.log_id IS NULL OR ml.status = 'resolved';
-- 18. View: Current occupancy status
CREATE VIEW CurrentOccupancy AS
SELECT r.room_number, r.floor, rt.type_name,
       CASE 
           WHEN res.check_in_date <= CURDATE() 
                AND res.check_out_date > CURDATE() 
                AND res.status = 'confirmed'
           THEN 'Occupied'
           ELSE 'Available'
       END as occupancy_status,
       g.first_name, g.last_name
FROM Room r
JOIN RoomType rt ON r.room_type_id = rt.room_type_id
LEFT JOIN RoomReservation rr ON r.room_id = rr.room_id
LEFT JOIN Reservation res ON rr.reservation_id = res.reservation_id
LEFT JOIN Guest g ON res.guest_id = g.guest_id
WHERE res.reservation_id IS NULL 
   OR (res.check_in_date <= CURDATE() AND res.check_out_date >= CURDATE());

-- 19. View: Revenue summary by month
CREATE VIEW MonthlyRevenueSummary AS
SELECT YEAR(p.payment_date) as year,
       MONTH(p.payment_date) as month,
       COUNT(DISTINCT b.bill_id) as total_bills,
       SUM(p.amount) as total_revenue,
       AVG(p.amount) as average_payment
FROM Payment p
JOIN Bill b ON p.bill_id = b.bill_id
GROUP BY YEAR(p.payment_date), MONTH(p.payment_date);
-- 20. Check constraint: Ensure positive rates
ALTER TABLE RoomType
ADD CONSTRAINT chk_positive_rate CHECK (base_rate > 0);

-- 21. Unique constraint: Prevent duplicate bookings
ALTER TABLE RoomReservation
ADD CONSTRAINT unique_room_dates 
UNIQUE (room_id, reservation_id);

-- 22. Foreign key with cascade: Auto-update related records
ALTER TABLE Charge
ADD CONSTRAINT fk_charge_bill
FOREIGN KEY (bill_id) REFERENCES Bill(bill_id)
ON DELETE CASCADE ON UPDATE CASCADE;
-- 23. Trigger: Auto-generate bill on reservation
DELIMITER //
CREATE TRIGGER CreateBillOnReservation
AFTER INSERT ON Reservation
FOR EACH ROW
BEGIN
    IF NEW.status = 'confirmed' THEN
        INSERT INTO Bill (reservation_id, total_amount, payment_status)
        VALUES (NEW.reservation_id, NEW.total_amount, 'pending');
    END IF;
END//
DELIMITER ;

-- 24. Trigger: Update bill total when charges added
DELIMITER //
CREATE TRIGGER UpdateBillTotal
AFTER INSERT ON Charge
FOR EACH ROW
BEGIN
    UPDATE Bill 
    SET total_amount = (
        SELECT SUM(amount * quantity) 
        FROM Charge 
        WHERE bill_id = NEW.bill_id
    )
    WHERE bill_id = NEW.bill_id;
END//
DELIMITER ;

-- 25. Trigger: Prevent double booking
DELIMITER //
CREATE TRIGGER PreventDoubleBooking
BEFORE INSERT ON RoomReservation
FOR EACH ROW
BEGIN
    DECLARE room_count INT;
    
    SELECT COUNT(*) INTO room_count
    FROM RoomReservation rr
    JOIN Reservation r1 ON rr.reservation_id = r1.reservation_id
    JOIN Reservation r2 ON r2.reservation_id = NEW.reservation_id
    WHERE rr.room_id = NEW.room_id
    AND r1.status = 'confirmed'
    AND (
        (r2.check_in_date BETWEEN r1.check_in_date AND r1.check_out_date - INTERVAL 1 DAY)
        OR (r2.check_out_date - INTERVAL 1 DAY BETWEEN r1.check_in_date AND r1.check_out_date - INTERVAL 1 DAY)
        OR (r1.check_in_date BETWEEN r2.check_in_date AND r2.check_out_date - INTERVAL 1 DAY)
    );
    
    IF room_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Room is already booked for these dates';
    END IF;
END//
DELIMITER ;
