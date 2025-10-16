-- ============================================================================
-- CS 4513 - Homework 3
-- Database Setup Script for Azure SQL Database
-- 
-- This script creates and populates the required tables for the assignment:
-- - Passenger
-- - Pilot  
-- - Flight
-- - Booking
--
-- Instructions:
-- 1. Connect to your Azure SQL Database
-- 2. Run this entire script
-- 3. Verify tables are created and populated
--
-- Author: [Your Name/Group Number]
-- ============================================================================

-- ============================================================================
-- STEP 1: Drop existing tables (if they exist)
-- ============================================================================
-- Drop tables in reverse order of creation to avoid foreign key violations

PRINT 'Step 1: Dropping existing tables...';
GO

IF OBJECT_ID('Booking', 'U') IS NOT NULL
    DROP TABLE Booking;
IF OBJECT_ID('Flight', 'U') IS NOT NULL
    DROP TABLE Flight;
IF OBJECT_ID('Pilot', 'U') IS NOT NULL
    DROP TABLE Pilot;
IF OBJECT_ID('Passenger', 'U') IS NOT NULL
    DROP TABLE Passenger;
GO

PRINT 'Existing tables dropped (if they existed).';
GO

-- ============================================================================
-- STEP 2: Create tables
-- ============================================================================

PRINT 'Step 2: Creating tables...';
GO

-- ----------------------------------------------------------------------------
-- Passenger table
-- ----------------------------------------------------------------------------
CREATE TABLE Passenger (
    pid INT PRIMARY KEY,
    pname VARCHAR(100) NOT NULL,
    tier VARCHAR(20) NOT NULL,
    age INT NOT NULL,
    CONSTRAINT CHK_tier CHECK (tier IN ('Gold', 'Silver', 'Bronze')),
    CONSTRAINT CHK_age CHECK (age > 0 AND age < 120)
);
PRINT 'Passenger table created.';
GO

-- ----------------------------------------------------------------------------
-- Pilot table
-- ----------------------------------------------------------------------------
CREATE TABLE Pilot (
    pIid INT PRIMARY KEY,
    pIname VARCHAR(100) NOT NULL,
    hours REAL NOT NULL,
    CONSTRAINT CHK_hours CHECK (hours >= 0)
);
PRINT 'Pilot table created.';
GO

-- ----------------------------------------------------------------------------
-- Flight table
-- ----------------------------------------------------------------------------
CREATE TABLE Flight (
    fnum VARCHAR(10) PRIMARY KEY,
    origin VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    dep_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    pIid INT NOT NULL,
    CONSTRAINT FK_Flight_Pilot FOREIGN KEY (pIid) REFERENCES Pilot(pIid),
    CONSTRAINT CHK_times CHECK (arrival_time > dep_time)
);
PRINT 'Flight table created.';
GO

-- ----------------------------------------------------------------------------
-- Booking table
-- ----------------------------------------------------------------------------
CREATE TABLE Booking (
    pid INT NOT NULL,
    fnum VARCHAR(10) NOT NULL,
    PRIMARY KEY (pid, fnum),
    CONSTRAINT FK_Booking_Passenger FOREIGN KEY (pid) REFERENCES Passenger(pid),
    CONSTRAINT FK_Booking_Flight FOREIGN KEY (fnum) REFERENCES Flight(fnum)
);
PRINT 'Booking table created.';
GO

PRINT 'All tables created successfully!';
GO

-- ============================================================================
-- STEP 3: Insert sample data
-- ============================================================================

PRINT 'Step 3: Inserting sample data...';
GO

-- ----------------------------------------------------------------------------
-- Insert Passengers (from HW2 dataset)
-- ----------------------------------------------------------------------------
PRINT 'Inserting passengers...';

INSERT INTO Passenger (pid, pname, tier, age) VALUES
(1, 'Alice', 'Gold', 28),
(2, 'Bob', 'Silver', 35),
(3, 'Carol', 'Gold', 22),
(4, 'Dan', 'Bronze', 41),
(5, 'Eva', 'Silver', 30),
(6, 'Frank', 'Gold', 26),
(7, 'Grace', 'Bronze', 19),
(8, 'Henry', 'Silver', 45),
(9, 'Irene', 'Gold', 33),
(10, 'Jack', 'Bronze', 20),
(11, 'Kim', 'Silver', 27),
(12, 'Leo', 'Gold', 52);

PRINT 'Passengers inserted: 12 rows';
GO

-- ----------------------------------------------------------------------------
-- Insert Pilots (from HW2 dataset)
-- ----------------------------------------------------------------------------
PRINT 'Inserting pilots...';

INSERT INTO Pilot (pIid, pIname, hours) VALUES
(201, 'Smith', 12000.0),
(202, 'Chen', 9500.0),
(203, 'Garcia', 8000.0),
(204, 'Patel', 7000.0);

PRINT 'Pilots inserted: 4 rows';
GO

-- ----------------------------------------------------------------------------
-- Insert Flights (from HW2 dataset)
-- ----------------------------------------------------------------------------
PRINT 'Inserting flights...';

-- Note: Times are in 24-hour format (HH:MM:SS)
-- Original data had day prefixes (M/W/F for Monday/Wednesday/Friday)
-- Flight duration calculation: arrival_time - dep_time
-- Examples:
--   F100: 17:20:00 - 09:00:00 = 8.33 hours (LAX to JFK)
--   F101: 15:30:00 - 09:00:00 = 6.5 hours (SFO to ORD)
--   F102: 15:50:00 - 13:30:00 = 2.33 hours (LAX to SEA)

INSERT INTO Flight (fnum, origin, destination, dep_time, arrival_time, pIid) VALUES
('F100', 'LAX', 'JFK', '09:00:00', '17:20:00', 201),  -- 8.33 hours, Smith
('F101', 'SFO', 'ORD', '09:00:00', '15:30:00', 202),  -- 6.5 hours, Chen
('F102', 'LAX', 'SEA', '13:30:00', '15:50:00', 201),  -- 2.33 hours, Smith
('F103', 'DFW', 'ORD', '12:00:00', '14:25:00', 203),  -- 2.42 hours, Garcia
('F104', 'ATL', 'SEA', '12:00:00', '15:00:00', 204),  -- 3 hours, Patel
('F105', 'ORD', 'DFW', '15:30:00', '17:45:00', 201),  -- 2.25 hours, Smith
('F106', 'LAX', 'ATL', '09:00:00', '16:35:00', 201),  -- 7.58 hours, Smith
('F107', 'BOS', 'ORD', '10:00:00', '12:30:00', 201);  -- 2.5 hours, Smith

PRINT 'Flights inserted: 8 rows';
GO

-- ----------------------------------------------------------------------------
-- Insert Bookings (from HW2 dataset)
-- ----------------------------------------------------------------------------
PRINT 'Inserting bookings...';

-- Bookings connecting passengers to flights
-- Note: Each booking represents a passenger booking a specific flight
-- Key relationships:
-- - F100 (LAX->JFK, Smith): 6 passengers (Alice, Carol, Eva, Frank, Henry, Irene)
-- - F101 (SFO->ORD, Chen): 4 passengers (Alice, Carol, Bob, Dan)
-- - F102 (LAX->SEA, Smith): 1 passenger (Alice)
-- - F103 (DFW->ORD, Garcia): 1 passenger (Kim)
-- - F104 (ATL->SEA, Patel): 1 passenger (Jack)
-- - F105 (ORD->DFW, Smith): 2 passengers (Bob, Leo)
-- - F106 (LAX->ATL, Smith): 1 passenger (Grace)

INSERT INTO Booking (pid, fnum) VALUES
(1, 'F100'),   -- Alice -> LAX->JFK, Smith
(3, 'F100'),   -- Carol -> LAX->JFK, Smith
(5, 'F100'),   -- Eva -> LAX->JFK, Smith
(6, 'F100'),   -- Frank -> LAX->JFK, Smith
(8, 'F100'),   -- Henry -> LAX->JFK, Smith
(9, 'F100'),   -- Irene -> LAX->JFK, Smith
(1, 'F101'),   -- Alice -> SFO->ORD, Chen
(3, 'F101'),   -- Carol -> SFO->ORD, Chen
(2, 'F101'),   -- Bob -> SFO->ORD, Chen
(4, 'F101'),   -- Dan -> SFO->ORD, Chen
(1, 'F102'),   -- Alice -> LAX->SEA, Smith
(12, 'F105'),  -- Leo -> ORD->DFW, Smith
(2, 'F105'),   -- Bob -> ORD->DFW, Smith
(7, 'F106'),   -- Grace -> LAX->ATL, Smith
(10, 'F104'),  -- Jack -> ATL->SEA, Patel
(11, 'F103');  -- Kim -> DFW->ORD, Garcia

PRINT 'Bookings inserted: 16 rows';
GO

-- ============================================================================
-- STEP 4: Verify data insertion
-- ============================================================================

PRINT 'Step 4: Verifying data...';
GO

PRINT 'Passenger count:';
SELECT COUNT(*) AS PassengerCount FROM Passenger;
GO

PRINT 'Pilot count:';
SELECT COUNT(*) AS PilotCount FROM Pilot;
GO

PRINT 'Flight count:';
SELECT COUNT(*) AS FlightCount FROM Flight;
GO

PRINT 'Booking count:';
SELECT COUNT(*) AS BookingCount FROM Booking;
GO

-- ============================================================================
-- STEP 5: Display sample data
-- ============================================================================

PRINT 'Step 5: Displaying sample data...';
GO

PRINT '--- All Passengers ---';
SELECT * FROM Passenger ORDER BY pid;
GO

PRINT '--- All Pilots ---';
SELECT * FROM Pilot ORDER BY pIid;
GO

PRINT '--- All Flights (showing first 10) ---';
SELECT TOP 10 * FROM Flight ORDER BY fnum;
GO

PRINT '--- All Bookings (showing first 10) ---';
SELECT TOP 10 * FROM Booking ORDER BY pid, fnum;
GO

-- ============================================================================
-- STEP 6: Test queries for assignment
-- ============================================================================

PRINT 'Step 6: Testing sample queries...';
GO

-- Test 1: Calculate average flight time (for stored procedure 1)
PRINT '--- Test 1: Average flight time in hours ---';
SELECT 
    AVG(DATEDIFF(MINUTE, CAST(dep_time AS TIME), CAST(arrival_time AS TIME)) / 60.0) AS AvgFlightHours
FROM Flight;
GO

-- Test 2: Find flights piloted by pilots with Gold passengers (for stored procedure 2)
PRINT '--- Test 2: Flights with Gold-tier passengers ---';
SELECT DISTINCT F.fnum, F.origin, F.destination, Pi.pIname
FROM Flight F
JOIN Booking B ON F.fnum = B.fnum
JOIN Passenger Pa ON B.pid = Pa.pid
JOIN Pilot Pi ON F.pIid = Pi.pIid
WHERE Pa.tier = 'Gold'
ORDER BY F.fnum;
GO

-- Test 2b: Calculate average flight time for flights with Gold passengers
PRINT '--- Test 2b: Average flight time for flights with Gold passengers ---';
SELECT 
    AVG(DATEDIFF(MINUTE, CAST(F.dep_time AS TIME), CAST(F.arrival_time AS TIME)) / 60.0) AS AvgFlightHours
FROM Flight F
WHERE F.pIid IN (
    SELECT DISTINCT F2.pIid
    FROM Flight F2
    JOIN Booking B ON F2.fnum = B.fnum
    JOIN Passenger P ON B.pid = P.pid
    WHERE P.tier = 'Gold'
);
GO

-- Test 3: Find flights piloted by Smith (for IQ1)
PRINT '--- Test 3: Flights piloted by Smith ---';
SELECT * FROM Flight F
JOIN Pilot Pi ON F.pIid = Pi.pIid
WHERE Pi.pIname = 'Smith'
ORDER BY F.fnum;
GO

-- Test 4: Find flights from LAX (for IQ2 and Problem 2)
PRINT '--- Test 4: Flights from LAX ---';
SELECT * FROM Flight
WHERE origin = 'LAX'
ORDER BY fnum;
GO

-- Test 5: Find passengers booked on multiple flights
PRINT '--- Test 5: Passengers with multiple bookings ---';
SELECT Pa.pname, Pa.tier, COUNT(B.fnum) AS FlightCount
FROM Passenger Pa
JOIN Booking B ON Pa.pid = B.pid
GROUP BY Pa.pid, Pa.pname, Pa.tier
HAVING COUNT(B.fnum) > 1
ORDER BY FlightCount DESC;
GO

-- ============================================================================
-- STEP 7: Summary and next steps
-- ============================================================================

PRINT '============================================================';
PRINT 'DATABASE SETUP COMPLETE!';
PRINT '============================================================';
PRINT '';
PRINT 'Tables created: Passenger, Pilot, Flight, Booking';
PRINT 'HW2 dataset inserted successfully.';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Run Problem1_StoredProcedures.sql to create stored procedures';
PRINT '2. Update Problem1.java with your Azure credentials';
PRINT '3. Compile and run Problem1.java';
PRINT '4. Run Problem2_Indexing.sql for index creation and testing';
PRINT '';
PRINT 'Data Summary (from HW2):';
PRINT '- 12 Passengers (mixed tiers: Gold, Silver, Bronze)';
PRINT '- 4 Pilots (Smith, Chen, Garcia, Patel)';
PRINT '- 8 Flights (F100-F107, various origins including LAX)';
PRINT '- 16 Bookings (connecting passengers to flights)';
PRINT '';
PRINT 'Key Test Cases:';
PRINT '- Pilot Smith (pIid=201) has 5 flights (F100, F102, F105, F106, F107)';
PRINT '- Multiple flights depart from LAX: F100, F102, F106 (good for indexing)';
PRINT '- Passengers with Gold, Silver, and Bronze tiers (for stored proc 2)';
PRINT '- F100 (LAX->JFK) has 6 passengers booked (most popular flight)';
PRINT '- Average flight time is approximately 4.4 hours';
PRINT '';
PRINT 'Verify everything looks correct before proceeding!';
PRINT '============================================================';
GO

-- ============================================================================
-- OPTIONAL: Additional test data for more comprehensive testing
-- ============================================================================

-- Uncomment the following section if you want more test data

/*
PRINT 'Adding additional test data...';

-- More passengers
INSERT INTO Passenger (pid, pname, tier, age) VALUES
(11, 'Ian Martinez', 'Silver', 27),
(12, 'Julia Garcia', 'Bronze', 34),
(13, 'Kevin Rodriguez', 'Gold', 41),
(14, 'Laura Martinez', 'Silver', 36),
(15, 'Michael Lee', 'Bronze', 44);

-- More bookings
INSERT INTO Booking (pid, fnum) VALUES
(11, 'SW400'),
(11, 'SW401'),
(12, 'JB500'),
(13, 'AA100'),
(14, 'UA200'),
(15, 'DL300');

PRINT 'Additional test data added.';
GO
*/

-- ============================================================================
-- END OF SETUP SCRIPT
-- ============================================================================

