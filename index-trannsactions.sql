-- Composite index for reservation date searches 
CREATE INDEX idx_reservation_date_range  
ON Reservation(check_in_date, check_out_date, status); 

-- Covering index for guest search by name 
CREATE INDEX idx_guest_search  
ON Guest(last_name, first_name, email, phone); 
-- 3. Index for room availability queries 
CREATE INDEX idx_room_availability  
ON Room(status, room_type_id, floor); 

-- 4. Composite index for bill payment tracking 
CREATE INDEX idx_bill_payment_tracking  
ON Bill(payment_status, reservation_id, total_amount); 
-- 5. Index for maintenance scheduling 
CREATE INDEX idx_maintenance_schedule  
ON MaintenanceLog(status, assigned_to, room_id, reported_date); 

-- Index for employee department queries 
CREATE INDEX idx_employee_dept_position  
ON Employee(department_id, position, hire_date); 
-- Index for charge date range queries 
CREATE INDEX idx_charge_daterange  
ON Charge(charge_date, bill_id, service_id); 

-- Index for payment method analysis 
CREATE INDEX idx_payment_method_date  
ON Payment(payment_method, payment_date, amount); 

-- Full-text index for special requests 
CREATE FULLTEXT INDEX idx_special_requests  
ON Reservation(special_requests); 

-- Index for room cleaning schedule 
CREATE INDEX idx_room_cleaning  
ON Room(last_cleaned, status, floor); 

-- Additional foreign key indexes for better join performance 
CREATE INDEX idx_room_reservation_dates  
ON RoomReservation(reservation_id, room_id, rate); 
CREATE INDEX idx_charge_service  
ON Charge(service_id, bill_id, charge_date);
CREATE INDEX idx_payment_bill_date  
ON Payment(bill_id, payment_date, payment_method); 

-- View to monitor index usage 
CREATE VIEW IndexUsageStats AS 
SELECT  
    t.TABLE_NAME, 
    i.INDEX_NAME, 
    i.COLUMN_NAME, 
    i.SEQ_IN_INDEX, 
    i.CARDINALITY, 
    t.TABLE_ROWS 
FROM INFORMATION_SCHEMA.STATISTICS i 
JOIN INFORMATION_SCHEMA.TABLES t  
    ON i.TABLE_SCHEMA = t.TABLE_SCHEMA  
    AND i.TABLE_NAME = t.TABLE_NAME 
WHERE i.TABLE_SCHEMA = DATABASE() 
ORDER BY t.TABLE_NAME, i.INDEX_NAME, i.SEQ_IN_INDEX; 

-- This would be run periodically to identify needed indexes 
SELECT  
    'CREATE INDEX idx_' || table_name || '_' || column_name ||  
    ' ON ' || table_name || '(' || column_name || ');' as suggested_index 
FROM ( 
    -- This is a placeholder for actual slow query analysis 
    SELECT 'Reservation' as table_name, 'guest_id' as column_name 
    UNION ALL 
    SELECT 'Bill' as table_name, 'payment_status' as column_name 
) AS missing_indexes; 

-- Guest Check-In Transaction 
START TRANSACTION; 
-- Update room status 
UPDATE Room  
SET status = 'occupied'  
WHERE room_id = 101; 
-- Update reservation status 
UPDATE Reservation  
SET status = 'confirmed'  
WHERE reservation_id = 1001; 
-- Add room service charge 
INSERT INTO Charge (bill_id, service_id, amount, quantity, description) 
VALUES (2001, 1, 0, 1, 'Room charge for night 1'); 

-- Verify all updates succeeded 
IF (SELECT status FROM Room WHERE room_id = 101) = 'occupied'  
   AND (SELECT status FROM Reservation WHERE reservation_id = 1001) = 'confirmed' THEN 
    COMMIT; 
ELSE 
    ROLLBACK; 
END IF; 

-- Complete Checkout Process with Payment 
DELIMITER // 
CREATE PROCEDURE CheckoutGuest( 
    IN p_reservation_id INT, 
    IN p_payment_amount DECIMAL(10,2), 
    IN p_payment_method VARCHAR(20) 
) 

BEGIN 
    DECLARE v_bill_id INT; 
    DECLARE v_total_amount DECIMAL(10,2); 
    DECLARE v_room_id INT; 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SELECT 'Transaction failed. All changes rolled back.' as Error; 
    END; 
    START TRANSACTION; 
    -- Get bill information 
    SELECT bill_id, total_amount  
    INTO v_bill_id, v_total_amount 
    FROM Bill  
    WHERE reservation_id = p_reservation_id; 
    -- Process payment 
    INSERT INTO Payment (bill_id, amount, payment_method) 
    VALUES (v_bill_id, p_payment_amount, p_payment_method); 
    -- Update bill status 
    UPDATE Bill 
    SET paid_amount = paid_amount + p_payment_amount, 
        payment_status = CASE  
            WHEN (paid_amount + p_payment_amount) >= total_amount THEN 'paid' 
            ELSE 'partial' 
        END 
    WHERE bill_id = v_bill_id; 
    -- Update reservation status 
    UPDATE Reservation  
    SET status = 'completed'  
    WHERE reservation_id = p_reservation_id; 
    -- Free up the room(s) 
    UPDATE Room r 
    INNER JOIN RoomReservation rr ON r.room_id = rr.room_id 
    SET r.status = 'cleaning' 
    WHERE rr.reservation_id = p_reservation_id; 
    COMMIT; 
    SELECT 'Checkout completed successfully' as Result; 
END// 
DELIMITER ; 

-- Read Committed Example - Preventing Dirty Reads 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
START TRANSACTION;
 
-- Check room availability 
SELECT room_id, room_number, status  
FROM Room  
WHERE status = 'available'  
AND room_type_id = 2 
FOR UPDATE; 

-- Make reservation (other transactions wait) 
INSERT INTO Reservation (guest_id, check_in_date, check_out_date, status) 
VALUES (123, '2024-07-01', '2024-07-05', 'confirmed'); 
COMMIT; 

-- Repeatable Read Example - Preventing Phantom Reads 
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; 
START TRANSACTION; 

-- Count available rooms (locked for reading) 
SELECT COUNT(*) as available_count  
FROM Room  
WHERE status = 'available'; 

-- Perform business logic based on count 
-- Other transactions cannot change room status 
COMMIT; 

-- Serializable Example - Maximum Isolation 
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; 
START TRANSACTION; 

-- Critical financial reconciliation 
SELECT SUM(amount) as total_payments  
FROM Payment  
WHERE DATE(payment_date) = CURDATE(); 
SELECT SUM(total_amount) as total_charges  
FROM Bill  
WHERE DATE(bill_date) = CURDATE(); 

-- Ensure consistency during audit 
COMMIT; 

-- Deadlock-Safe Room Transfer Transaction 
DELIMITER // 
CREATE PROCEDURE TransferGuestRoom( 
    IN p_reservation_id INT, 
    IN p_from_room_id INT, 
    IN p_to_room_id INT 
) 

BEGIN 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SELECT 'Transfer failed' as Error; 
    END; 
    START TRANSACTION; 

-- Always lock rooms in consistent order (by ID) to prevent deadlock 
    IF p_from_room_id < p_to_room_id THEN 
        SELECT room_id FROM Room WHERE room_id = p_from_room_id FOR UPDATE; 
        SELECT room_id FROM Room WHERE room_id = p_to_room_id FOR UPDATE; 
    ELSE 
        SELECT room_id FROM Room WHERE room_id = p_to_room_id FOR UPDATE; 
        SELECT room_id FROM Room WHERE room_id = p_from_room_id FOR UPDATE; 
    END IF; 
    
    -- Update room assignments 
    UPDATE RoomReservation  
    SET room_id = p_to_room_id  
    WHERE reservation_id = p_reservation_id AND room_id = p_from_room_id; 
    
    -- Update room statuses 
    UPDATE Room SET status = 'available' WHERE room_id = p_from_room_id; 
    UPDATE Room SET status = 'occupied' WHERE room_id = p_to_room_id; 
    COMMIT; 
    SELECT 'Room transfer successful' as Result; 
END// 
DELIMITER ; 

-- Batch Night Audit Process 
DELIMITER // 
CREATE PROCEDURE NightAudit() 
BEGIN 
    DECLARE v_done INT DEFAULT FALSE; 
    DECLARE v_res_id INT; 
    DECLARE v_room_rate DECIMAL(10,2); 
    DECLARE v_bill_id INT; 
    DECLARE res_cursor CURSOR FOR 
        SELECT r.reservation_id, rr.rate, b.bill_id 
        FROM Reservation r 
        JOIN RoomReservation rr ON r.reservation_id = rr.reservation_id 
        JOIN Bill b ON r.reservation_id = b.reservation_id 
        WHERE r.status = 'confirmed' 
        AND CURDATE() BETWEEN r.check_in_date AND r.check_out_date; 
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE; 

    START TRANSACTION; 
    OPEN res_cursor; 
    read_loop: LOOP 
        FETCH res_cursor INTO v_res_id, v_room_rate, v_bill_id; 
        IF v_done THEN 
            LEAVE read_loop; 
        END IF; 
        
        -- Add nightly room charge 
        INSERT INTO Charge (bill_id, service_id, amount, charge_date, description) 
        VALUES (v_bill_id, 1, v_room_rate, NOW(), 'Nightly room charge'); 
        
        -- Update bill total 
        UPDATE Bill  
        SET total_amount = total_amount + v_room_rate  
        WHERE bill_id = v_bill_id; 
    END LOOP; 
    CLOSE res_cursor; 
    
    -- Log audit completion 
    INSERT INTO AuditLog (audit_type, completed_date, status) 
    VALUES ('Night Audit', NOW(), 'Completed'); 
    COMMIT; 
END// 
DELIMITER ; 

-- 8. Complex Reservation with Savepoints 
DELIMITER // 
CREATE PROCEDURE CreateGroupReservation( 
    IN p_guest_id INT, 
    IN p_checkin DATE, 
    IN p_checkout DATE, 
    IN p_room_count INT 
) 
BEGIN 
    DECLARE v_reservation_id INT; 
    DECLARE v_room_id INT; 
    DECLARE v_rooms_assigned INT DEFAULT 0; 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SELECT 'Reservation failed' as Error; 
    END; 

    START TRANSACTION; 
    
    -- Create main reservation 
    INSERT INTO Reservation (guest_id, check_in_date, check_out_date, status) 
    VALUES (p_guest_id, p_checkin, p_checkout, 'confirmed'); 
    SET v_reservation_id = LAST_INSERT_ID(); 
    SAVEPOINT reservation_created; 
    
    -- Try to assign requested number of rooms 
    WHILE v_rooms_assigned < p_room_count DO 
        -- Find available room 
        SELECT room_id INTO v_room_id 
        FROM Room 
        WHERE status = 'available' 
        AND room_id NOT IN ( 
            SELECT room_id FROM RoomReservation  
            WHERE reservation_id = v_reservation_id 
        ) 
        LIMIT 1; 
        IF v_room_id IS NULL THEN 
            -- Not enough rooms available 
            ROLLBACK TO SAVEPOINT reservation_created; 
            -- Keep reservation but mark as partial 
            UPDATE Reservation  
            SET status = 'partial',  
                special_requests = CONCAT('Only ', v_rooms_assigned, ' of ', p_room_count, ' rooms assigned') 
            WHERE reservation_id = v_reservation_id; 
            COMMIT; 
            SELECT 'Partial reservation created' as Result; 
            LEAVE; 
        END IF; 
        
        -- Assign room 
        INSERT INTO RoomReservation (reservation_id, room_id, rate) 
        SELECT v_reservation_id, v_room_id, rt.base_rate 
        FROM Room r 
        JOIN RoomType rt ON r.room_type_id = rt.room_type_id 
        WHERE r.room_id = v_room_id; 
        SET v_rooms_assigned = v_rooms_assigned + 1; 
        SAVEPOINT room_assigned; 
    END WHILE; 
    
    -- Create bill
    INSERT INTO Bill (reservation_id, total_amount) 
    SELECT v_reservation_id, SUM(rate * DATEDIFF(p_checkout, p_checkin)) 
    FROM RoomReservation 
    WHERE reservation_id = v_reservation_id; 
    COMMIT; 
    SELECT 'Group reservation completed' as Result; 
END// 
DELIMITER ; 

-- Transaction Performance Monitoring View 
CREATE VIEW TransactionPerformance AS 
SELECT  
    trx_id, 
    trx_state, 
    trx_started, 
    trx_wait_started, 
    trx_mysql_thread_id, 
    TIMESTAMPDIFF(SECOND, trx_started, NOW()) as duration_seconds 
FROM information_schema.innodb_trx 
ORDER BY trx_started; 

-- Lock Monitoring Query 
SELECT  
    r.trx_id AS blocking_trx_id, 
    r.trx_mysql_thread_id AS blocking_thread, 
    TIMESTAMPDIFF(SECOND, r.trx_started, NOW()) AS blocking_duration, 
    b.trx_id AS blocked_trx_id, 
    b.trx_mysql_thread_id AS blocked_thread, 
    TIMESTAMPDIFF(SECOND, b.trx_wait_started, NOW()) AS wait_duration 
FROM information_schema.innodb_lock_waits w 
JOIN information_schema.innodb_trx b ON b.trx_id = w.requesting_trx_id 
JOIN information_schema.innodb_trx r ON r.trx_id = w.blocking_trx_id; 