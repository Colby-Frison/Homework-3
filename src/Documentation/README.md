# CS 4513 - Homework 3: JDBC, Stored Procedures, and Database Indexing

## Project Overview

This homework focuses on practical database programming using Java JDBC, Transact-SQL stored procedures, and database performance optimization through indexing. It also covers theoretical aspects of file organization and B+-tree indexes.

**Course:** CS/DSA-4513 - Database Management Systems  
**Section:** 002  
**Semester:** Fall 2025  
**Instructor:** Egawati Panjei

**Due Dates:**
- Group Portion: 10/18/2025 at 11:59 PM
- Individual Portion: 10/20/2025 at 11:59 PM

---

## Project Structure

```
Homework 3/
├── src/
│   ├── Problem1.java                    # Main Java program with JDBC
│   ├── Problem1_StoredProcedures.sql    # T-SQL stored procedures
│   ├── Problem2_Indexing.sql            # Index creation and queries
│   ├── Problem3_Solution.md             # Theoretical solutions
│   ├── IMPORTANT_TOPICS.md              # Key concepts and study guide
│   ├── TODO.md                          # Task checklist and how-to guide
│   └── README.md                        # This file
└── Instructions/
    ├── Graded Homework 3 - CS4513 F25.pdf
    ├── Homework 3.md
    ├── Transact SQL Stored Procedures CS4513 F25.pdf
    ├── Using Java and JDBC for Azure SQL Connection CS4513 F25.pdf
    └── Sample code/
        ├── sample.java
        └── sample.sql
```

---

## Problems Summary

### Problem 1: Java JDBC Application with Stored Procedures

**Objective:** Create a menu-driven Java application that manages a Pilot database using JDBC and Azure SQL Database.

**Database Schema:**
- **Passenger** (pid: integer, pname: string, tier: string, age: integer)
- **Pilot** (pIid: integer, pIname: string, hours: real)
- **Flight** (fnum: string, origin: string, destination: string, dep_time: string, arrival_time: string, pIid: integer)
- **Booking** (pid: integer, fnum: string)

**Features:**
1. Insert pilot with hours calculated from average flight time
2. Insert pilot with hours based on passenger tier
3. Display all pilots sorted by pIid
4. Exit program

**Technologies:**
- Java with JDBC
- Azure SQL Database
- Transact-SQL Stored Procedures
- CallableStatement for stored procedure execution

**Files:**
- `Problem1.java` - Main application
- `Problem1_StoredProcedures.sql` - Two stored procedures

---

### Problem 2: Database Indexing

**Objective:** Analyze query patterns and create appropriate indexes to improve database performance.

**Tasks:**
1. Choose a table and column for indexing
2. Justify the choice with detailed reasoning
3. Determine if the index is primary or secondary
4. Create the index using SQL
5. Identify queries that benefit from the index
6. Execute queries and document performance improvement

**Group Question (GQ2):** General indexing strategy  
**Individual Question (IQ):** Indexing for specific high-frequency queries (IQ1-IQ4)

**Technologies:**
- Azure SQL Database
- T-SQL Index creation
- Query execution plans
- Performance analysis

**Files:**
- `Problem2_Indexing.sql` - Index creation and test queries

---

### Problem 3: File Organization and B+-Trees

**Objective:** Demonstrate understanding of file organization, indexes, and B+-tree data structures through manual construction.

**Tasks:**
1. Show sequential file organization with block addresses
2. Construct dense primary index on ordering field
3. Construct secondary index on non-ordering field
4. Build B+-tree index (order 3) step-by-step

**Topics Covered:**
- Sequential file organization
- Primary vs. secondary indexes
- Dense vs. sparse indexes
- B+-tree construction and properties

**Files:**
- `Problem3_Solution.md` - Complete theoretical solution

---

## Quick start guide

See QUICK_START_GUIDE.md in src/Documentation

---

## Key Features

### Problem1.java


**User Interface:**
```
========================================
     PILOT MANAGEMENT SYSTEM
========================================
Please select one of the options below:
1) Insert Pilot (Hours Based on Average Flight Time)
2) Insert Pilot (Hours Based on Passenger Tier)
3) Display All Pilots
4) Quit
========================================
Enter your choice:
```

### Stored Procedures

**InsertPilotAvgFlightTime:**
- Calculates average flight duration across ALL flights
- Uses DATEDIFF to compute time difference
- Handles NULL case (no flights exist)
- Ensures hours >= 0

**InsertPilotByPassengerTier:**
- Finds flights with passengers of specified tier
- Calculates average duration of those flights
- Uses subquery to filter relevant flights
- Handles NULL case (no matching flights)

### Indexing Strategy

**Chosen Index:** Flight(origin)  
**Type:** Secondary (non-clustered)

**Reasoning:**
- High query frequency on origin-based searches
- Moderate cardinality
- Benefits join operations
- No disruption to primary key index

**Queries Optimized:**
1. Equality searches on origin
2. IN clause with multiple origins
3. Aggregation by origin
4. Joins filtered by origin
5. Pilots flying from specific origins

---

## Database Schema

### Tables Required

```sql
-- Passenger table
CREATE TABLE Passenger (
    pid INT PRIMARY KEY,
    pname VARCHAR(100) NOT NULL,
    tier VARCHAR(20) CHECK (tier IN ('Gold', 'Silver', 'Bronze')),
    age INT CHECK (age > 0)
);

-- Pilot table
CREATE TABLE Pilot (
    pIid INT PRIMARY KEY,
    pIname VARCHAR(100) NOT NULL,
    hours REAL CHECK (hours >= 0)
);

-- Flight table
CREATE TABLE Flight (
    fnum VARCHAR(10) PRIMARY KEY,
    origin VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    dep_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    pIid INT,
    FOREIGN KEY (pIid) REFERENCES Pilot(pIid)
);

-- Booking table
CREATE TABLE Booking (
    pid INT,
    fnum VARCHAR(10),
    PRIMARY KEY (pid, fnum),
    FOREIGN KEY (pid) REFERENCES Passenger(pid),
    FOREIGN KEY (fnum) REFERENCES Flight(fnum)
);
```

---

## Common Issues and Solutions

### "Cannot find mssql-jdbc driver"
Download the Microsoft JDBC Driver and add to classpath:
```bash
java -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1
```

### "Login failed for user"
- Verify credentials in code
- Check Azure firewall rules
- Ensure database name is correct

### "Stored procedure not found"
Execute the SQL script on Azure first:
```sql
SELECT name FROM sys.procedures;
```

### Scanner skipping input
Add `sc.nextLine()` after `sc.nextInt()`:
```java
final int id = sc.nextInt();
sc.nextLine(); // Consume newline
```

### Time format errors
Ensure Flight table uses TIME or DATETIME type:
```sql
dep_time TIME NOT NULL,
arrival_time TIME NOT NULL
```

---

## Additional Resources

### Documentation
- [JDBC API Documentation](https://docs.oracle.com/javase/8/docs/api/java/sql/package-summary.html)
- [T-SQL Reference](https://learn.microsoft.com/en-us/sql/t-sql/)
- [Azure SQL Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/)

### Testing Tools
- Azure SQL Query Editor (online)
- SQL Server Management Studio (SSMS)
- Azure Data Studio

---
