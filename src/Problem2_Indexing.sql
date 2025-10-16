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
 * CHOSEN TABLE FOR INDEXING: Flight
 *
 * REASONING:
 * The Flight table is chosen for indexing because:
 * 
 * 1. HIGH QUERY FREQUENCY: Many queries from HW2 involve searching, filtering,
 *    or joining on the Flight table. This makes it a prime candidate for 
 *    performance improvement through indexing.
 *
 * 2. JOIN OPERATIONS: The Flight table is frequently joined with other tables
 *    (Booking, Pilot, Passenger) in complex queries. An index can significantly
 *    speed up these join operations.
 *
 * 3. SEARCH PATTERNS: Multiple queries search for flights based on origin,
 *    destination, or flight number (fnum). These are common access patterns
 *    that benefit from indexing.
 *
 * CHOSEN SEARCH KEY: origin
 *
 * REASONING FOR SEARCH KEY SELECTION:
 * 
 * 1. SELECTIVE QUERIES: Many queries filter flights by origin airport
 *    (e.g., "Find all flights departing from LAX"). This is a common
 *    search pattern in airline database systems.
 *
 * 2. MODERATE CARDINALITY: The origin field has moderate cardinality
 *    (multiple flights from each airport, but not too many unique origins).
 *    This makes it effective for indexing - not too selective (like fnum)
 *    and not too general (like a boolean field).
 *
 * 3. RANGE QUERIES: While origin is primarily used for equality searches,
 *    it can also be used in IN clauses or for alphabetical sorting,
 *    which B-tree indexes handle efficiently.
 *
 * INDEX TYPE: SECONDARY INDEX (Non-Clustered)
 *
 * REASONING:
 * 
 * 1. PRIMARY KEY EXISTS: The Flight table already has a primary key (fnum),
 *    which is automatically indexed as a primary (clustered) index.
 *
 * 2. NON-ORDERING FIELD: The origin field is not the ordering field of
 *    the Flight table. The table is likely ordered by fnum (primary key).
 *
 * 3. MULTIPLE INDEX SUPPORT: A secondary index allows us to have multiple
 *    indexes on the same table (fnum and origin), supporting different
 *    query patterns without reorganizing the physical data layout.
 *
 * 4. FLEXIBILITY: Secondary indexes don't affect the physical ordering
 *    of data, making them easier to create and maintain without disrupting
 *    existing applications.
 */

-- ============================================================================
-- PART 2: INDEX CREATION
-- ============================================================================

-- Drop the index if it already exists (useful for testing and rerunning)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_flight_origin')
BEGIN
    DROP INDEX idx_flight_origin ON Flight;
    PRINT 'Existing index idx_flight_origin dropped.';
END
GO

-- Create a non-clustered (secondary) index on the origin column of Flight table
CREATE NONCLUSTERED INDEX idx_flight_origin
ON Flight (origin);
GO

PRINT 'Secondary index idx_flight_origin created successfully on Flight(origin).';
GO

-- ============================================================================
-- PART 3: QUERIES TO RERUN (From HW2 that benefit from this index)
-- ============================================================================

/*
 * The following queries are selected to demonstrate the performance benefit
 * of the index on Flight(origin). These queries all involve searching or
 * filtering flights based on the origin airport.
 */

-- ----------------------------------------------------------------------------
-- Query 1: Find all flights departing from LAX
-- ----------------------------------------------------------------------------
/*
 * WHY THIS QUERY BENEFITS FROM THE INDEX:
 * This query performs an equality search on the origin field. Without an index,
 * the database would need to perform a full table scan. With the index on origin,
 * the database can quickly locate all flights from LAX using the B-tree structure,
 * significantly reducing I/O operations.
 *
 * EXPECTED PERFORMANCE IMPROVEMENT:
 * - Without index: O(n) - must scan all flight records
 * - With index: O(log n + k) - log n to find first match, k to retrieve matching rows
 */

-- Query 1 Execution
SELECT fnum, origin, destination, dep_time, arrival_time
FROM Flight
WHERE origin = 'LAX'
ORDER BY dep_time;
GO

-- ----------------------------------------------------------------------------
-- Query 2: Find flight numbers that depart from LAX or ORD
-- ----------------------------------------------------------------------------
/*
 * WHY THIS QUERY BENEFITS FROM THE INDEX:
 * This query uses an IN clause (or OR condition) on the origin field. The index
 * allows the database to efficiently locate all flights from both LAX and ORD
 * without scanning the entire table. The database can perform two index seeks
 * (one for each origin) and combine the results.
 *
 * EXPECTED PERFORMANCE IMPROVEMENT:
 * - Without index: O(n) - full table scan
 * - With index: O(2 * log n + k) - two index seeks plus retrieval of matching rows
 */

-- Query 2 Execution
SELECT fnum, origin, destination
FROM Flight
WHERE origin IN ('LAX', 'ORD')
ORDER BY origin, fnum;
GO

-- ----------------------------------------------------------------------------
-- Query 3: Count flights from each origin airport
-- ----------------------------------------------------------------------------
/*
 * WHY THIS QUERY BENEFITS FROM THE INDEX:
 * This query groups flights by origin and counts them. The index on origin
 * allows the database to efficiently group and aggregate the data. The database
 * can scan the index (which is sorted by origin) rather than the entire table,
 * making the grouping operation much faster.
 *
 * EXPECTED PERFORMANCE IMPROVEMENT:
 * - Without index: O(n log n) - sort entire table, then group
 * - With index: O(n) - index is already sorted, just scan and count
 */

-- Query 3 Execution
SELECT origin, COUNT(*) AS num_flights
FROM Flight
GROUP BY origin
ORDER BY num_flights DESC;
GO

-- ----------------------------------------------------------------------------
-- Query 4: Find passengers booked on flights from LAX
-- ----------------------------------------------------------------------------
/*
 * WHY THIS QUERY BENEFITS FROM THE INDEX:
 * This query joins Flight with Booking and Passenger, filtering by origin = 'LAX'.
 * The index allows the database to quickly filter the Flight table before performing
 * the joins, reducing the number of rows that need to be joined and significantly
 * improving performance.
 *
 * EXPECTED PERFORMANCE IMPROVEMENT:
 * - Without index: Must scan entire Flight table, then join with Booking/Passenger
 * - With index: Quickly filter Flight to LAX flights, then join smaller result set
 */

-- Query 4 Execution
SELECT DISTINCT P.pid, P.pname, F.fnum, F.destination
FROM Passenger P
JOIN Booking B ON P.pid = B.pid
JOIN Flight F ON B.fnum = F.fnum
WHERE F.origin = 'LAX'
ORDER BY P.pname;
GO

-- ----------------------------------------------------------------------------
-- Query 5: Find pilots who fly flights departing from specific origins
-- ----------------------------------------------------------------------------
/*
 * WHY THIS QUERY BENEFITS FROM THE INDEX:
 * This query filters flights by origin before joining with Pilot. The index
 * enables efficient filtering, reducing the size of the intermediate result
 * before the join operation, thus improving overall query performance.
 *
 * EXPECTED PERFORMANCE IMPROVEMENT:
 * - Without index: Full table scan on Flight, then join with Pilot
 * - With index: Index seek on origin, then join only matching flights with Pilot
 */

-- Query 5 Execution
SELECT DISTINCT Pi.pIid, Pi.pIname, F.origin, COUNT(F.fnum) AS num_flights
FROM Pilot Pi
JOIN Flight F ON Pi.pIid = F.pIid
WHERE F.origin IN ('LAX', 'JFK', 'ORD')
GROUP BY Pi.pIid, Pi.pIname, F.origin
ORDER BY Pi.pIname, F.origin;
GO

-- ============================================================================
-- PART 4: VERIFICATION AND ANALYSIS
-- ============================================================================

/*
 * To verify that the index is being used, you can:
 * 
 * 1. Check that the index exists:
 */
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Flight') AND i.name = 'idx_flight_origin';
GO

/*
 * 2. View execution plans (in Azure SQL Query Editor):
 *    - Click "Include Actual Execution Plan" before running queries
 *    - Look for "Index Seek" operations on idx_flight_origin
 *    - Compare with execution plan before index creation (should show "Table Scan")
 *
 * 3. Check index usage statistics:
 */
SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScans,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECT_NAME(s.object_id) = 'Flight' AND i.name = 'idx_flight_origin';
GO

-- ============================================================================
-- PART 5: ADDITIONAL CONSIDERATIONS
-- ============================================================================

/*
 * TRADE-OFFS OF THIS INDEX:
 *
 * BENEFITS:
 * 1. Faster query performance for origin-based searches
 * 2. Improved join performance when filtering by origin
 * 3. Efficient grouping and aggregation by origin
 * 4. No disruption to existing primary key index
 *
 * COSTS:
 * 1. Additional storage space required for the index structure
 * 2. Slower INSERT/UPDATE/DELETE operations (index must be maintained)
 * 3. Index maintenance overhead during bulk operations
 *
 * WHEN THIS INDEX IS MOST BENEFICIAL:
 * - Read-heavy workloads (more SELECT queries than INSERT/UPDATE/DELETE)
 * - Queries frequently filter or join on origin
 * - Large Flight tables (more rows = greater benefit from indexing)
 * - Reporting and analytics queries that aggregate by origin
 *
 * WHEN THIS INDEX MAY NOT BE BENEFICIAL:
 * - Very small Flight tables (overhead may exceed benefits)
 * - Write-heavy workloads (index maintenance cost)
 * - If most queries use fnum instead of origin for filtering
 *
 * ALTERNATIVE INDEXING STRATEGIES TO CONSIDER:
 * 
 * 1. Composite Index on (origin, destination):
 *    - CREATE INDEX idx_flight_origin_dest ON Flight(origin, destination);
 *    - Benefits queries that filter by both origin AND destination
 *
 * 2. Covering Index including additional columns:
 *    - CREATE INDEX idx_flight_origin_covering 
 *      ON Flight(origin) INCLUDE (fnum, destination, dep_time);
 *    - Eliminates need to access base table for included columns
 *
 * 3. Index on destination:
 *    - CREATE INDEX idx_flight_destination ON Flight(destination);
 *    - Benefits queries that filter by arrival airport
 */

-- ============================================================================
-- END OF FILE
-- ============================================================================

