-- ============================================================================
-- CS 4513 - Homework 3, Problem 2 (GQ2)
-- SQL Indexing for Database Performance Optimization
-- 
-- This file contains:
-- 1. Explanation of table chosen for indexing
-- 2. Explanation of search key chosen
-- 3. SQL statement(s) to create the index
-- 4. Queries to rerun that benefit from the index
-- 5. Explanation of why these queries were chosen
--
-- Author: [Your Name/Group Number]
-- ============================================================================

-- ============================================================================
-- PART 1: TABLE AND SEARCH KEY SELECTION
-- ============================================================================

/*
 * CHOSEN TABLE FOR INDEXING: Passenger
 *
 * WHY PASSENGER TABLE?
 * Multiple queries from HW2 filter passengers by their tier (Gold, Silver, Bronze).
 * This makes tier a good candidate for indexing.
 *
 * CHOSEN SEARCH KEY: tier
 *
 * WHY TIER?
 * Three different HW2 queries filter by passenger tier:
 * - Query 2: Finds Gold-tier passengers (tier = 'Gold')
 * - Query 3: Finds Silver-tier passengers (tier = 'Silver')
 * - Query 9: Deletes Bronze-tier passengers (tier = 'Bronze')
 *
 * Since multiple queries use the same column for filtering, a single index on
 * tier benefits all three queries. This is simpler and more efficient than
 * creating multiple indexes on different tables.
 *
 * INDEX TYPE: SECONDARY INDEX (Non-Clustered)
 *
 * WHY SECONDARY?
 * - Passenger already has a primary key (pid) which creates the clustered index
 * - The tier column is not the primary key
 * - This is a secondary index on a non-ordering field
 */

-- ============================================================================
-- PART 2: INDEX CREATION
-- ============================================================================

-- Drop the index if it already exists (useful for testing and rerunning)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_passenger_tier')
    DROP INDEX idx_passenger_tier ON Passenger;
GO

PRINT 'Creating index on Passenger table...';
GO

-- Create a non-clustered (secondary) index on the tier column
-- This helps all queries that filter passengers by their membership tier
CREATE NONCLUSTERED INDEX idx_passenger_tier
ON Passenger (tier);
GO

PRINT 'Index created: idx_passenger_tier on Passenger(tier)';
GO

-- ============================================================================
-- PART 3: QUERIES TO RERUN (From HW2 Problem 2 GQ5)
-- ============================================================================

/*
 * The following queries from HW2 Problem 2 (GQ5) filter passengers by tier.
 * All three queries benefit from the same index on Passenger(tier):
 * 
 * - Query 2: Filters for Gold-tier passengers
 * - Query 3: Filters for Silver-tier passengers
 * - Query 9: Filters for Bronze-tier passengers (then deletes them)
 */

-- ----------------------------------------------------------------------------
-- HW2 Query 2: Find the names of all Gold-tier passengers who are booked 
--              on a flight piloted by Smith.
-- ----------------------------------------------------------------------------
/*
 * USES INDEX: idx_passenger_tier
 * 
 * This query filters passengers by tier = 'Gold'. The tier index allows the
 * database to quickly find all Gold passengers instead of scanning every
 * passenger record.
 */

PRINT 'HW2 Query 2: Gold-tier passengers booked on flights piloted by Smith'
PRINT '================================================================'

SELECT DISTINCT p.pname
FROM Passenger p
JOIN Booking b ON p.pid = b.pid
JOIN Flight f ON b.fnum = f.fnum
JOIN Pilot pl ON f.pIid = pl.pIid
WHERE p.tier = 'Gold' AND pl.pIname = 'Smith';
GO

-- ----------------------------------------------------------------------------
-- HW2 Query 3: Find the age of the oldest passenger who is either a 
--              Silver-tier member or is booked on a flight piloted by Smith.
-- ----------------------------------------------------------------------------
/*
 * USES INDEX: idx_passenger_tier
 * 
 * This query filters passengers by tier = 'Silver'. The tier index helps the
 * database quickly find all Silver passengers without scanning the entire table.
 */

PRINT 'HW2 Query 3: Age of oldest passenger who is Silver-tier OR booked on Smith flight'
PRINT '================================================================================='

SELECT MAX(p.age) AS oldest_age
FROM Passenger p
WHERE p.tier = 'Silver'
   OR p.pid IN (
       SELECT DISTINCT b.pid
       FROM Booking b
       JOIN Flight f ON b.fnum = f.fnum
       JOIN Pilot pl ON f.pIid = pl.pIid
       WHERE pl.pIname = 'Smith'
   );
GO

-- ----------------------------------------------------------------------------
-- HW2 Query 9: Delete all Bronze-tier passengers (tier = 'Bronze').
-- ----------------------------------------------------------------------------
/*
 * USES INDEX: idx_passenger_tier
 * 
 * This query filters passengers by tier = 'Bronze' to find which passengers to delete.
 * The tier index helps quickly locate all Bronze passengers.
 * 
 * NOTE: For DELETE operations, indexes have a trade-off - they speed up finding
 * the rows to delete, but they also need to be maintained after deletion. For
 * occasional deletes on a read-heavy database, the benefit of fast lookup
 * outweighs the maintenance cost.
 */

PRINT 'HW2 Query 9: Delete all Bronze-tier passengers'
PRINT '=============================================='

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
GO


-- ============================================================================
-- PART 4: VERIFICATION AND ANALYSIS
-- ============================================================================

/*
 * To verify that the indexes exist and are being used:
 */

-- Check that the index was created successfully
PRINT 'Verifying index on Passenger table:'
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Passenger') 
  AND i.name = 'idx_passenger_tier';
GO

/*
 * To see if the index is being used:
 * - In Azure SQL Query Editor, click "Include Actual Execution Plan" before running queries
 * - Look for "Index Seek" operations on idx_passenger_tier instead of "Table Scan"
 * - All three queries (2, 3, and 9) should use this same index
 */

-- ============================================================================
-- PART 5: ADDITIONAL CONSIDERATIONS
-- ============================================================================

/*
 * SUMMARY:
 *
 * WHY INDEX ON TIER?
 * Multiple HW2 queries filter passengers by tier. A single index on the tier
 * column benefits all these queries, making it a simple and effective choice.
 *
 * BENEFITS:
 * - Queries 2, 3, and 9 all run faster
 * - One index helps multiple queries (efficient and simple)
 * - Tier has low cardinality (only 3 values: Gold, Silver, Bronze) but is
 *   still selective enough to be useful
 *
 * COSTS:
 * - Uses storage space for the index
 * - INSERT, UPDATE, and DELETE operations on Passenger table are slightly slower
 *   because the index needs to be maintained
 *
 * TRADE-OFF DECISION:
 * This is a good trade-off because:
 * - Passenger tier is frequently used in queries (read-heavy)
 * - Passenger data doesn't change very often (fewer writes)
 * - One simple index benefits multiple queries
 */

-- ============================================================================
-- END OF FILE
-- ============================================================================

