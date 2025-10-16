# CS 4513 Homework 3 - Important Topics and Concepts

## Overview
This document outlines the key concepts, technologies, and topics covered in Homework 3. Understanding these topics is essential for successfully completing the assignment and for the individual portion quiz.

---

## 1. JDBC (Java Database Connectivity)

### What is JDBC?
- **Java API** for connecting to and executing queries on relational databases
- Provides a standard interface for Java applications to interact with SQL databases
- Platform-independent database access layer

### Key JDBC Components

#### 1.1 Connection Management
```java
DriverManager.getConnection(URL)
```
- Establishes connection to Azure SQL Database
- Connection string format includes:
  - Hostname (Azure SQL server address)
  - Database name
  - Username and password
  - Security settings (encryption, SSL)
  - Timeout settings

#### 1.2 Statement Types

**Statement**
- Basic SQL execution
- Used for simple queries without parameters
- Example: `SELECT * FROM Pilot`

**PreparedStatement**
- Precompiled SQL statements
- Supports parameterized queries (using `?`)
- Better performance for repeated queries
- Prevents SQL injection
- Example: `INSERT INTO Pilot VALUES (?, ?, ?)`

**CallableStatement**
- Used to execute stored procedures
- Syntax: `{CALL procedure_name(?, ?, ?)}`
- Can have IN, OUT, and INOUT parameters

#### 1.3 ResultSet
- Object that contains results of SQL query
- Cursor that moves through query results
- Methods to retrieve data by column name or index
  - `getInt()`, `getString()`, `getDouble()`, etc.
- Use `next()` to iterate through rows

### JDBC Best Practices
1. **Use try-with-resources** for automatic resource cleanup
2. **Close connections** properly to avoid memory leaks
3. **Handle exceptions** appropriately (SQLException)
4. **Use PreparedStatement/CallableStatement** instead of String concatenation
5. **Validate user input** before executing queries

---

## 2. Transact-SQL (T-SQL) Stored Procedures

### What are Stored Procedures?
- Precompiled SQL code stored in the database
- Can accept parameters and return results
- Executed on the database server (not client side)

### Benefits of Stored Procedures
1. **Performance:** Precompiled and optimized by database
2. **Security:** Users can execute procedures without direct table access
3. **Maintainability:** Business logic centralized in database
4. **Network efficiency:** Reduces data transfer between client and server
5. **Reusability:** Can be called from multiple applications

### T-SQL Syntax Used in This Assignment

#### Variable Declaration
```sql
DECLARE @variable_name data_type;
```

#### Setting Variables
```sql
SET @variable_name = value;
SELECT @variable_name = column FROM table;
```

#### Control Flow
```sql
IF condition
    statement
ELSE
    statement
```

#### Date/Time Functions
- **DATEDIFF(unit, start_date, end_date):** Calculate difference between two dates/times
  - Units: YEAR, MONTH, DAY, HOUR, MINUTE, SECOND
- **CAST(expression AS data_type):** Convert data types
  - Example: `CAST(dep_time AS TIME)`

#### Aggregate Functions
- **AVG():** Calculate average value
- **COUNT():** Count rows
- **SUM():** Calculate sum
- **MIN()/MAX():** Find minimum/maximum

#### NULL Handling
- **ISNULL(expression, replacement):** Replace NULL with a value
- **COALESCE():** Return first non-NULL value

### Stored Procedure Structure
```sql
CREATE PROCEDURE procedure_name
    @param1 data_type,
    @param2 data_type
AS
BEGIN
    -- SQL statements
    -- Variable declarations
    -- Control flow logic
    -- Data manipulation
END;
GO
```

---

## 3. Database Indexing

### What is an Index?
- Data structure that improves speed of data retrieval operations
- Similar to a book's index: helps find information quickly
- Trade-off: Faster queries vs. slower writes and more storage

### Types of Indexes

#### 3.1 Primary Index
- Built on the **ordering field** (primary key)
- Data file is physically sorted by this field
- Typically clustered index
- Each table can have only ONE clustered index

**Dense Primary Index:**
- One index entry for EVERY record in the data file
- Points directly to each record

**Sparse Primary Index:**
- One index entry per BLOCK (not per record)
- Smaller index size, but requires sequential scan within block

#### 3.2 Secondary Index
- Built on **non-ordering field**
- Data file is NOT sorted by this field
- Can have multiple secondary indexes per table
- Typically non-clustered index

**Characteristics:**
- Must be **dense** (entry for each value)
- May point to multiple records (if field is non-unique)
- Requires indirection or bucket structure for duplicate values

#### 3.3 Clustered vs. Non-Clustered

**Clustered Index:**
- Determines physical order of data in table
- Leaf nodes contain actual data rows
- Only ONE per table
- Faster for range queries on indexed column

**Non-Clustered Index:**
- Separate structure from data
- Leaf nodes contain pointers to data rows
- Can have multiple per table
- Extra I/O to retrieve actual data

### Index Performance Considerations

**When Indexes Help:**
- SELECT queries with WHERE clauses on indexed columns
- JOIN operations on indexed columns
- ORDER BY on indexed columns
- GROUP BY on indexed columns
- Finding MIN/MAX values

**When Indexes Hurt:**
- INSERT operations (index must be updated)
- UPDATE operations on indexed columns
- DELETE operations (index must be maintained)
- Small tables (overhead exceeds benefit)
- Columns with low selectivity (e.g., boolean fields)

### SQL Syntax for Indexes

**Create Index:**
```sql
CREATE INDEX index_name ON table_name (column_name);
CREATE NONCLUSTERED INDEX index_name ON table_name (column_name);
CREATE CLUSTERED INDEX index_name ON table_name (column_name);
```

**Drop Index:**
```sql
DROP INDEX index_name ON table_name;
```

**Create Composite Index:**
```sql
CREATE INDEX index_name ON table_name (col1, col2);
```

**Create Covering Index:**
```sql
CREATE INDEX index_name ON table_name (col1) INCLUDE (col2, col3);
```

---

## 4. B+-Tree Data Structure

### What is a B+-Tree?
- Self-balancing tree data structure
- Maintains sorted data for efficient search, insertion, deletion
- Optimized for systems that read/write large blocks of data
- Commonly used in databases and file systems

### B+-Tree Properties (Order n)

**Node Constraints:**
- Each internal node has at most **n** children
- Each internal node (except root) has at least **⌈n/2⌉** children
- Root has at least 2 children (if not a leaf)
- Each node contains at most **n-1** keys
- All leaves are at the same level

**Key Properties:**
- Keys in internal nodes act as separators/routers
- All actual data is stored in leaf nodes
- Leaf nodes are linked (horizontal pointers)
- Keys are in sorted order

### B+-Tree Operations

**Search:** O(log n)
- Start at root, follow pointers based on key comparisons
- Continue until reaching leaf node
- Search within leaf node

**Insertion:**
1. Search for appropriate leaf node
2. Insert key in sorted position
3. If leaf overflows (>n-1 keys), split:
   - Create new leaf node
   - Distribute keys evenly
   - Promote middle key to parent
4. If parent overflows, recursively split upward
5. If root splits, create new root (tree height increases)

**Deletion:**
1. Find and remove key from leaf
2. If leaf underflows (<⌈n/2⌉-1 keys):
   - Try to borrow from sibling
   - If can't borrow, merge with sibling
3. Update parent nodes as needed

### Why B+-Trees for Databases?
1. **Minimizes I/O operations:** Height is small (logarithmic)
2. **Efficient range queries:** Leaf nodes are linked
3. **Good space utilization:** Nodes are at least half full
4. **Self-balancing:** Maintains performance over time
5. **Cache-friendly:** Nodes can fit in memory blocks

---

## 5. File Organization

### Sequential File Organization
- Records stored in sorted order by a key field
- Records grouped into blocks/pages
- Good for: Sequential access, range queries
- Bad for: Random access, frequent insertions

**Advantages:**
- Efficient for reading entire file
- Simple structure
- Good locality of reference

**Disadvantages:**
- Insertions require maintaining order (expensive)
- Deletions leave gaps
- Random access requires scanning

### Index-Sequential Organization
- Sequential file + index structure
- Combines benefits of sequential and indexed access
- Primary index for ordering field
- Secondary indexes for other fields

**Components:**
1. **Data file:** Sorted by primary key
2. **Primary index:** Points to data blocks
3. **Secondary indexes:** Point to data records or primary keys
4. **Overflow area:** Handles insertions without reorganizing

---

## 6. Azure SQL Database

### What is Azure SQL?
- Microsoft's cloud-based relational database service
- Fully managed SQL Server database
- Platform as a Service (PaaS)

### Connection Requirements
- Server hostname: `<your4x4>-sql-server.database.windows.net`
- Port: 1433
- Database name
- Authentication credentials
- SSL/TLS encryption required

### Azure SQL Features Used
- Transact-SQL stored procedures
- Index creation and management
- Query execution and result retrieval
- Transaction management

---

## 7. Key SQL Concepts

### Joins
- **INNER JOIN:** Return matching rows from both tables
- **LEFT/RIGHT JOIN:** Include all rows from one table
- **CROSS JOIN:** Cartesian product

### Subqueries
- Query nested inside another query
- Can be in SELECT, FROM, WHERE clauses
- Correlated vs. non-correlated

### Aggregation
- GROUP BY: Group rows with same values
- HAVING: Filter groups (like WHERE for groups)
- Aggregate functions: COUNT, SUM, AVG, MIN, MAX

### Set Operations
- UNION: Combine results (remove duplicates)
- INTERSECT: Common rows
- EXCEPT: Rows in first query but not second

---

## 8. Individual Question Preparation

### Topics to Study

**Query Optimization:**
- Understand which indexes help which queries
- Analyze query execution plans
- Consider selectivity and cardinality

**Index Selection Criteria:**
1. **Frequency:** How often is the query executed?
2. **Selectivity:** How many rows match the condition?
3. **Query type:** Search, join, aggregate, update, delete?
4. **Trade-offs:** Query speed vs. update cost

**For Each Individual Query (IQ1-IQ4):**

**IQ1: Age of oldest passenger (Silver OR piloted by Smith)**
- Consider indexes on: Passenger.tier, Pilot.pIname
- Join optimization: Flight ⋈ Pilot ⋈ Booking ⋈ Passenger
- Selectivity analysis

**IQ2: Flights from LAX OR with 5+ passengers**
- Consider indexes on: Flight.origin, Booking.fnum
- Aggregation on Booking
- OR condition optimization

**IQ3: Passengers on two flights with same departure time**
- Consider indexes on: Flight.dep_time, Booking.pid
- Self-join on Flight
- GROUP BY with HAVING COUNT > 1

**IQ4: Delete Bronze-tier passengers**
- Consider indexes on: Passenger.tier
- DELETE operation (indexes slow it down!)
- Cascade effects on Booking (foreign key)

---

## 9. Testing and Validation

### Testing Checklist for Problem 1
- [ ] Java program compiles without errors
- [ ] Successfully connects to Azure SQL Database
- [ ] Menu displays correctly and accepts input
- [ ] Option 1 executes InsertPilotAvgFlightTime
- [ ] Option 2 executes InsertPilotByPassengerTier
- [ ] Option 3 displays all pilots sorted by pIid
- [ ] Option 4 exits program gracefully
- [ ] Test each option 3+ times with different values
- [ ] Display pilots before and after each insertion
- [ ] Handle errors gracefully (duplicate IDs, invalid tier, etc.)

### Testing Checklist for Problem 2
- [ ] Index creation SQL executes successfully
- [ ] Queries execute before and after index creation
- [ ] Compare execution plans
- [ ] Document performance improvements
- [ ] Explain index choice with detailed reasoning

### Documentation Requirements
- [ ] Java code has comprehensive comments
- [ ] Stored procedures have detailed comments
- [ ] SQL files have explanatory comments
- [ ] PDF shows successful compilation and execution
- [ ] Screenshots include all required test cases
- [ ] Cover page with group information

---

## 10. Common Pitfalls to Avoid

### Programming Pitfalls
1. **Not closing resources:** Use try-with-resources
2. **SQL injection:** Use parameterized queries
3. **Hardcoded values:** Use constants or configuration
4. **Poor error handling:** Catch and log exceptions
5. **Scanner issues:** Remember to call `nextLine()` after `nextInt()`

### SQL Pitfalls
1. **Time arithmetic errors:** Ensure proper type casting
2. **NULL handling:** Use ISNULL or COALESCE
3. **Aggregation without GROUP BY:** Results in error
4. **Missing GO statements:** In stored procedures
5. **Circular dependencies:** In foreign keys

### Index Pitfalls
1. **Over-indexing:** Too many indexes hurt performance
2. **Wrong column choice:** Index rarely-used columns
3. **Ignoring cardinality:** Index low-selectivity columns
4. **Forgetting clustered limit:** Only one per table
5. **Not considering writes:** Indexes slow INSERT/UPDATE/DELETE

---

## Conclusion

Master these topics to successfully complete Homework 3 and prepare for the individual quiz. Focus on understanding the **why** behind each decision, not just the **how**.

Key takeaways:
- JDBC connects Java applications to databases
- Stored procedures improve performance and security
- Indexes trade write speed for read speed
- Index choice depends on query patterns and frequency
- B+-trees provide efficient, balanced access to data
- File organization affects query performance

Good luck!

