-- ============================================================================
-- CS 4513 - Homework 3, Problem 1
-- Transact-SQL Stored Procedures for Pilot Management System
-- 
-- This file contains stored procedures for:
-- 1. InsertPilotAvgFlightTime: Insert pilot with hours based on avg flight time
-- 2. InsertPilotByPassengerTier: Insert pilot with hours based on passenger tier
--
-- Author: [Your Name/Group Number]
-- ============================================================================

-- Drop existing stored procedures if they exist (useful for testing)
IF OBJECT_ID('InsertPilotAvgFlightTime', 'P') IS NOT NULL
    DROP PROCEDURE InsertPilotAvgFlightTime;
GO

IF OBJECT_ID('InsertPilotByPassengerTier', 'P') IS NOT NULL
    DROP PROCEDURE InsertPilotByPassengerTier;
GO

-- ============================================================================
-- Stored Procedure 1: InsertPilotAvgFlightTime
-- ============================================================================
-- Purpose: Insert a new pilot with hours calculated based on the average 
--          flight time of ALL flights in the Flight table
--
-- Parameters:
--   @pIid   - Pilot ID (integer)
--   @pIname - Pilot Name (string)
--
-- Logic:
--   1. Calculate the average flight time by subtracting dep_time from arrival_time
--   2. Convert the time difference to hours
--   3. If no flights exist, set hours to 0
--   4. Ensure hours value is at least 0
--   5. Insert the new pilot record with calculated hours
-- ============================================================================

CREATE PROCEDURE InsertPilotAvgFlightTime
    @pIid INT,
    @pIname VARCHAR(100)
AS
BEGIN
    -- Declare variable to store calculated hours
    DECLARE @hours REAL;
    
    -- Calculate average flight time in hours
    -- DATEDIFF with MINUTE gives us the difference in minutes
    -- We divide by 60.0 to convert to hours (using 60.0 for real division)
    -- ISNULL handles the case when no flights exist (returns 0)
    -- The CAST ensures dep_time and arrival_time are treated as TIME data type
    SELECT @hours = ISNULL(
        AVG(
            DATEDIFF(MINUTE, 
                CAST(dep_time AS TIME), 
                CAST(arrival_time AS TIME)
            ) / 60.0
        ), 0)
    FROM Flight;
    
    -- Ensure hours is not negative (minimum value is 0)
    IF @hours < 0
        SET @hours = 0;
    
    -- Insert the new pilot record with calculated hours
    INSERT INTO Pilot (pIid, pIname, hours)
    VALUES (@pIid, @pIname, @hours);
    
    -- Return success message
    PRINT 'Pilot inserted successfully with hours: ' + CAST(@hours AS VARCHAR(10));
END;
GO

-- ============================================================================
-- Stored Procedure 2: InsertPilotByPassengerTier
-- ============================================================================
-- Purpose: Insert a new pilot with hours calculated based on the average 
--          flight time of flights piloted by pilots who have at least one
--          passenger of the specified tier
--
-- Parameters:
--   @pIid   - Pilot ID (integer)
--   @pIname - Pilot Name (string)
--   @tier   - Passenger tier to filter by (string: 'Gold', 'Silver', 'Bronze')
--
-- Logic:
--   1. Find all flights piloted by pilots who have passengers of the specified tier
--   2. Calculate average flight time of those flights
--   3. Convert the time difference to hours
--   4. If no matching flights exist, set hours to 0
--   5. Ensure hours value is at least 0
--   6. Insert the new pilot record with calculated hours
-- ============================================================================

CREATE PROCEDURE InsertPilotByPassengerTier
    @pIid INT,
    @pIname VARCHAR(100),
    @tier VARCHAR(20)
AS
BEGIN
    -- Declare variable to store calculated hours
    DECLARE @hours REAL;
    
    -- Calculate average flight time for flights piloted by pilots who have
    -- at least one passenger of the specified tier
    --
    -- Query breakdown:
    -- 1. Join Flight with Booking to get passenger-flight relationships
    -- 2. Join with Passenger to get passenger tier information
    -- 3. Filter for the specified tier
    -- 4. Calculate average flight duration in hours
    -- 5. Handle NULL case (no matching flights) with ISNULL
    SELECT @hours = ISNULL(
        AVG(
            DATEDIFF(MINUTE,
                CAST(F.dep_time AS TIME),
                CAST(F.arrival_time AS TIME)
            ) / 60.0
        ), 0)
    FROM Flight F
    WHERE F.pIid IN (
        -- Subquery to find pilots who have passengers of the specified tier
        SELECT DISTINCT F2.pIid
        FROM Flight F2
        JOIN Booking B ON F2.fnum = B.fnum
        JOIN Passenger P ON B.pid = P.pid
        WHERE P.tier = @tier
    );
    
    -- Ensure hours is not negative (minimum value is 0)
    IF @hours < 0
        SET @hours = 0;
    
    -- Insert the new pilot record with calculated hours
    INSERT INTO Pilot (pIid, pIname, hours)
    VALUES (@pIid, @pIname, @hours);
    
    -- Return success message with details
    PRINT 'Pilot inserted successfully with hours: ' + CAST(@hours AS VARCHAR(10)) + 
          ' (based on ' + @tier + ' tier passengers)';
END;
GO

-- ============================================================================
-- Test the stored procedures (Optional - Comment out before submission)
-- ============================================================================

-- Example Test 1: Insert pilot based on average flight time
-- EXEC InsertPilotAvgFlightTime @pIid = 1001, @pIname = 'John Smith';

-- Example Test 2: Insert pilot based on Gold tier passengers
-- EXEC InsertPilotByPassengerTier @pIid = 1002, @pIname = 'Jane Doe', @tier = 'Gold';

-- Example Test 3: Insert pilot based on Silver tier passengers
-- EXEC InsertPilotByPassengerTier @pIid = 1003, @pIname = 'Bob Johnson', @tier = 'Silver';

-- Display all pilots to verify insertions
-- SELECT * FROM Pilot ORDER BY pIid;

-- ============================================================================
-- Notes:
-- ============================================================================
-- 1. Time Format Assumptions:
--    - dep_time and arrival_time are stored in a format that can be converted
--      to TIME type (e.g., 'HH:MM' or 'HH:MM:SS')
--    - DATEDIFF calculates the difference in the specified unit (MINUTE)
--
-- 2. Edge Cases Handled:
--    - No flights exist: hours set to 0
--    - No flights match tier criteria: hours set to 0
--    - Negative time differences: hours set to 0
--
-- 3. Assumptions:
--    - All flights in the database are valid (arrival_time >= dep_time)
--    - The Pilot table exists with columns: pIid (INT), pIname (VARCHAR), hours (REAL)
--    - The Flight table exists with columns: fnum, origin, destination, 
--      dep_time, arrival_time, pIid
--    - The Booking table exists with columns: pid, fnum
--    - The Passenger table exists with columns: pid, pname, tier, age
--
-- 4. Error Handling:
--    - The stored procedures will fail if:
--      * A pilot with the same pIid already exists (primary key violation)
--      * Required parameters are NULL
--      * Table schema doesn't match assumptions
-- ============================================================================

