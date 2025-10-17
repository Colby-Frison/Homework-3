-- CS 4513 - Database Management Systems
-- Homework 2 - SQL Queries
-- GQ5: Implement the SQL queries for the following nine queries

-- ==============================================
-- Query 1: Display all the data you store in the database to verify that you have populated the relations correctly.
-- ==============================================
PRINT 'Query 1: Display all data in the database'
PRINT '=========================================='

PRINT 'PASSENGER TABLE:'
SELECT * FROM Passenger ORDER BY pid;

PRINT 'PILOT TABLE:'
SELECT * FROM Pilot ORDER BY plid;

PRINT 'FLIGHT TABLE:'
SELECT * FROM Flight ORDER BY fnum;

PRINT 'BOOKING TABLE:'
SELECT * FROM Booking ORDER BY pid, fnum;

-- ==============================================
-- Query 2: Find the names of all Gold-tier passengers who are booked on a flight piloted by Smith.
-- ==============================================
PRINT 'Query 2: Gold-tier passengers booked on flights piloted by Smith'
PRINT '================================================================'

SELECT DISTINCT p.pname
FROM Passenger p
JOIN Booking b ON p.pid = b.pid
JOIN Flight f ON b.fnum = f.fnum
JOIN Pilot pl ON f.plid = pl.plid
WHERE p.tier = 'Gold' AND pl.plname = 'Smith';

-- ==============================================
-- Query 3: Find the age of the oldest passenger who is either a Silver-tier member or is booked on a flight piloted by Smith.
-- ==============================================
PRINT 'Query 3: Age of oldest passenger who is Silver-tier OR booked on Smith''s flight'
PRINT '=============================================================================='

SELECT MAX(p.age) AS oldest_age
FROM Passenger p
WHERE p.tier = 'Silver' 
   OR p.pid IN (
       SELECT DISTINCT b.pid
       FROM Booking b
       JOIN Flight f ON b.fnum = f.fnum
       JOIN Pilot pl ON f.plid = pl.plid
       WHERE pl.plname = 'Smith'
   );

-- ==============================================
-- Query 4: Find the flight numbers of all flights that either depart from LAX or have five or more passengers booked.
-- ==============================================
PRINT 'Query 4: Flights departing from LAX OR having 5+ passengers'
PRINT '==========================================================='

SELECT DISTINCT f.fnum
FROM Flight f
WHERE f.origin = 'LAX'
   OR f.fnum IN (
       SELECT b.fnum
       FROM Booking b
       GROUP BY b.fnum
       HAVING COUNT(b.pid) >= 5
   );

-- ==============================================
-- Query 5: Find the names of all passengers who are booked on two flights that depart at the same time.
-- ==============================================
PRINT 'Query 5: Passengers booked on two flights with same departure time'
PRINT '=================================================================='

SELECT DISTINCT p.pname
FROM Passenger p
WHERE p.pid IN (
    SELECT b1.pid
    FROM Booking b1
    JOIN Flight f1 ON b1.fnum = f1.fnum
    JOIN Booking b2 ON b1.pid = b2.pid
    JOIN Flight f2 ON b2.fnum = f2.fnum
    WHERE b1.fnum != b2.fnum 
      AND f1.dep_time = f2.dep_time
);

-- ==============================================
-- Query 6: Find the names of all pilots who have piloted a flight to every destination to which some flight flies.
-- ==============================================
PRINT 'Query 6: Pilots who have flown to every destination'
PRINT '=================================================='

SELECT pl.plname
FROM Pilot pl
WHERE NOT EXISTS (
    SELECT f1.destination
    FROM Flight f1
    WHERE f1.destination NOT IN (
        SELECT f2.destination
        FROM Flight f2
        WHERE f2.plid = pl.plid
    )
);

-- ==============================================
-- Query 7: Find the names of the pilots who have flown to "SEA" and have not flown to any other destination.
-- ==============================================
PRINT 'Query 7: Pilots who have flown only to SEA'
PRINT '=========================================='

SELECT pl.plname
FROM Pilot pl
WHERE pl.plid IN (
    SELECT f1.plid
    FROM Flight f1
    WHERE f1.destination = 'SEA'
)
AND pl.plid NOT IN (
    SELECT f2.plid
    FROM Flight f2
    WHERE f2.destination != 'SEA'
);

-- ==============================================
-- Query 8: For each tier, display the tier and the average age of passengers for that tier.
-- ==============================================
PRINT 'Query 8: Average age by passenger tier'
PRINT '======================================'

SELECT tier, AVG(CAST(age AS FLOAT)) AS average_age
FROM Passenger
GROUP BY tier
ORDER BY tier;

-- ==============================================
-- Query 9: Delete all Bronze-tier passengers (tier = 'Bronze').
-- ==============================================
PRINT 'Query 9: Delete all Bronze-tier passengers'
PRINT '=========================================='

-- First, show what will be deleted
PRINT 'Bronze-tier passengers to be deleted:'
SELECT * FROM Passenger WHERE tier = 'Bronze';

-- Delete from Booking table first (due to foreign key constraint)
DELETE FROM Booking 
WHERE pid IN (SELECT pid FROM Passenger WHERE tier = 'Bronze');

-- Delete from Passenger table
DELETE FROM Passenger WHERE tier = 'Bronze';

-- Verify deletion
PRINT 'Remaining passengers after deletion:'
SELECT * FROM Passenger ORDER BY pid;

