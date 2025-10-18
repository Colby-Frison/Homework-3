# CS 4513 Homework 3 - START HERE

## Overview


### Core Assignment Files 

**Problem 1 - Java JDBC Application**
- `Problem1.java` - Complete menu-driven program with JDBC
- `Problem1_StoredProcedures.sql` - Both stored procedures implemented
- All 4 menu options fully functional
- Comprehensive comments throughout

**Problem 2 - Database Indexing**
- `Problem2_Indexing.sql` - Complete indexing solution
- Table chosen: Flight, Search key: origin
- Detailed reasoning and explanations
- 5 test queries included

**Problem 3 - File Organization Theory**
- `Problem3_Solution.md` - Complete theoretical solution
- Sequential file organization (Part 1)
- Primary and secondary indexes (Part 2)
- B+-tree construction (Part 3)

**Database Setup**
- `Database_Setup.sql` - Complete schema with YOUR HW2 dataset
- 12 Passengers, 4 Pilots, 8 Flights, 16 Bookings
- Ready to run on Azure SQL

### Documentation Files 

**Step-by-Step Guides**
- `QUICK_START_GUIDE.md` - 5-step setup (fastest path)
- `TODO.md` - Detailed checklist with how-to instructions
- `README.md` - Complete project overview

**Study Materials**
- `IMPORTANT_TOPICS.md` - Comprehensive concept guide
- `IndividualQuestion_Template.md` - Quiz preparation with sample answers
- `FILE_SUMMARY.md` - Overview of all files

---

## Need to Do 

### Phase 1: Setup 

1. **Set up Azure Database** 
   - Log in to Azure SQL Database
   - Run database setup
   - Run stored procedures creator script

2. **Configure Java** 
   - Open `Problem1.java`
   - Update with credentials in .env or hardcoded location towards the top of the file
   - Save file

3. **Get JDBC Driver** 
   - Download Microsoft JDBC Driver for SQL Server
   - Extract JAR file to `src` directory

### Phase 2: Testing (60 minutes)

4. **Compile and Test Java** 
   - Compile: `javac Problem1.java`
   - Run: `java -cp ".;mssql-jdbc-XXX.jar" Problem1`
   - Test all 4 options

5. **Test Problem 2 SQL** 
   - Run indexing script on Azure
   - Execute all 5 queries
   - Take screenshots


## Quick File Reference

### Start With These Files

| File | Purpose | Read This If... |
|------|---------|-----------------|
| **QUICK_START_GUIDE.md** | Fastest setup | You want to get running ASAP |
| **README.md** | Project overview | You want to understand everything |
| **TODO.md** | Detailed checklist | You want step-by-step instructions |

### Code Files

| File | Type | What It Does |
|------|------|--------------|
| **Problem1.java** | Java | Main program with JDBC |
| **Problem1_StoredProcedures.sql** | SQL | Stored procedures for Problem 1 |
| **Problem2_Indexing.sql** | SQL | Indexing solution for Problem 2 |
| **Problem3_Solution.md** | Markdown | Theoretical solution for Problem 3 |
| **Database_Setup.sql** | SQL | Creates all tables and test data |

### Documentation Files

| File | Purpose |
|------|---------|
| **IMPORTANT_TOPICS.md** | Study guide for concepts |
| **IndividualQuestion_Template.md** | Prepare for individual quiz |
| **FILE_SUMMARY.md** | Overview of all files |
| **START_HERE.md** | This file - your starting point |

---

## Quick Start

**5-step quick start:**

### Step 1: Azure Setup
```
1. Open Azure SQL Query Editor
2. Database_Setup.sql → Run
3. Problem1_StoredProcedures.sql → Run
```

### Step 2: Configure Java
```
1. Open Problem1.java
2. Create credentials in .env or replace hardcoded location towards the top of the file
3. Save
```

### Step 3: Download JDBC Driver
```
1. Google: "Microsoft JDBC Driver for SQL Server download"
2. Download → Extract → Copy .jar to src folder
```

### Step 4: Compile & Run
```
cd src
javac Problem1.java
java -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1
```
(Adjust JAR filename to match your version)

### Step 5: Test & Screenshot
```
Follow the prompts, test all options, take screenshots!
See QUICK_START_GUIDE.md for exact test sequence
```

---

## Need Help?

### File to Check First:
- Quick questions → `QUICK_START_GUIDE.md`
- Detailed help → `TODO.md`
- Concept help → `IMPORTANT_TOPICS.md`
- File info → `FILE_SUMMARY.md`

---

## Getting Started

**More help in guides:**
Open `QUICK_START_GUIDE.md` and start with Step 1

---


