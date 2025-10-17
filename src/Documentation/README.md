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

### Problem 1: Java JDBC Application with Stored Procedures (22.5 points)

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

### Problem 2: Database Indexing (15 points + 35 points individual)

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

### Problem 3: File Organization and B+-Trees (15 points)

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

## Quick Start Guide

### Prerequisites

1. **Java Development Kit (JDK)**
   - JDK 11 or higher
   - Verify: `java -version`

2. **Microsoft JDBC Driver for SQL Server**
   - Download from: https://learn.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server
   - Extract and note the path to `.jar` file

3. **Azure SQL Database Access**
   - Server hostname
   - Database name
   - Username and password
   - Firewall configured to allow your IP

4. **Azure SQL Database Tables**
   - Passenger, Pilot, Flight, Booking tables created
   - Tables populated with test data

### Setup Steps

#### 1. Configure Database Connection

Edit `Problem1.java` lines 13-16:
```java
final static String HOSTNAME = "your-server.database.windows.net";
final static String DBNAME = "cs-dsa-4513-sql-db";
final static String USERNAME = "your-username";
final static String PASSWORD = "your-password";
```

#### 2. Deploy Stored Procedures

1. Open Azure SQL Query Editor
2. Copy contents of `Problem1_StoredProcedures.sql`
3. Execute the script
4. Verify: `SELECT name FROM sys.procedures;`

#### 3. Compile Java Program

**Windows:**
```cmd
cd "path\to\Homework 3\src"
javac Problem1.java
```

**Mac/Linux:**
```bash
cd "path/to/Homework 3/src"
javac Problem1.java
```

#### 4. Run Java Program

**Without external JAR:**
```bash
java Problem1
```

**With JDBC driver JAR:**
```bash
java -cp ".;path/to/mssql-jdbc.jar" Problem1
```

### Testing

Follow the test plan in `TODO.md`:
1. Display initial pilots (Option 3)
2. Test Option 1 three times with different values
3. Test Option 2 three times with different tiers
4. Display pilots after each insertion
5. Test program exit (Option 4)

---

## Key Features

### Problem1.java

**Design Patterns:**
- Menu-driven interface
- Try-with-resources for connection management
- Prepared statements for security
- CallableStatement for stored procedures
- Comprehensive error handling
- Formatted output display

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

## Documentation Files

### IMPORTANT_TOPICS.md
Comprehensive study guide covering:
- JDBC concepts and API
- Transact-SQL stored procedures
- Database indexing theory
- B+-tree data structures
- File organization
- Individual quiz preparation

### TODO.md
Detailed checklist including:
- Completed tasks
- Critical tasks to finish
- Step-by-step how-to guides
- Testing procedures
- Submission requirements
- Troubleshooting common issues

### Problem3_Solution.md
Complete theoretical solutions for:
- Sequential file organization
- Primary and secondary indexes
- B+-tree construction
- Detailed explanations and diagrams

---

## Submission Requirements

### Group Portion Files (Due 10/18/2025)

**Problem 1 (3 files):**
1. `HW3_Problem1_Group_X.java` - Java source code
2. `HW3_Problem1_Group_X.sql` - Stored procedures
3. `HW3_Problem1_Group_X.pdf` - Execution screenshots with cover page

**Problem 2 (2 files):**
1. `HW3_Problem2_Group_X.sql` - Index creation and queries
2. `HW3_Problem2_Group_X.pdf` - Azure execution screenshots

**Problem 3 (1 file):**
1. `HW3_Problem3_Group_X.pdf` - Typed solution

**Note:** Replace X with your group number

### Cover Page Format

```
GROUP NUMBER: <your group number>
GROUP MEMBERS: <list all member names>
GRADED HOMEWORK NUMBER: 3
COURSE: CS/DSA-4513 - DATABASE MANAGEMENT
SECTION: 002
SEMESTER: FALL 2025
INSTRUCTOR: EGAWATI PANJEI
SCORE: <<Grader fills this>>
```

### Individual Portion (Due 10/20/2025)

- Canvas quiz with one of IQ1-IQ4
- 60-minute time limit
- Submit one PDF document
- Provide peer evaluation scores

---

## Grading Breakdown

- **Problem 1 (GQ1):** 22.5 points
- **Problem 2 (GQ2):** 15 points
- **Problem 3 (GQ3):** 15 points
- **Individual Question:** 35 points

**Total:** 87.5 points (scaled to appropriate weight)

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

### Sample Data
See `TODO.md` for sample INSERT statements to populate your database.

### Testing Tools
- Azure SQL Query Editor (online)
- SQL Server Management Studio (SSMS)
- Azure Data Studio

---

## Tips for Success

1. **Start Early:** Don't wait until the deadline
2. **Test Incrementally:** Test each component as you build
3. **Document Everything:** Take screenshots during testing
4. **Handle Errors:** Test error cases (duplicate IDs, invalid tier)
5. **Review Requirements:** Use TODO.md as a checklist
6. **Prepare for Individual Quiz:** Study all four IQ scenarios

---

## Contact and Support

- **Instructor:** Egawati Panjei
- **TAs:** See Canvas for office hours and contact info
- **Canvas:** Submit questions and check announcements

---

## License and Academic Integrity

This is academic coursework for CS 4513. Follow your institution's academic integrity policies. All work should be your own (or your group's). Cite any external resources used.

---

## Changelog

- **2025-10-13:** Initial project structure created
- **2025-10-13:** All source files and documentation completed
- **Next:** Student to configure, test, and submit

---

**Good luck with your homework!**

For detailed instructions, see `TODO.md`.  
For conceptual review, see `IMPORTANT_TOPICS.md`.  
For solutions, see individual problem files.

