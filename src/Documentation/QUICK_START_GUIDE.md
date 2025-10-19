# Quick Start Guide - CS 4513 Homework 3

## 5 main Steps

### Step 1: Set Up Azure SQL Database (15 minutes)

1. **Log in to Azure SQL Database**
   - Go to your Azure portal
   - Navigate to your SQL Database
   - Open Query Editor

2. **Run Database Setup Script**
   - Open `Database_Setup.sql`
   - Copy the entire file contents
   - Paste into Azure Query Editor
   - Click "Run"
   - Wait for "DATABASE SETUP COMPLETE!" message
   - Verify: Should see 12 passengers, 4 pilots, 8 flights, 16 bookings
   - **This uses your actual HW2 dataset!**

3. **Create Stored Procedures**
   - Open `Problem1_StoredProcedures.sql`
   - Copy the entire file contents
   - Paste into Azure Query Editor
   - Click "Run"
   - Verify procedures exist:
     ```sql
     SELECT name FROM sys.procedures;
     ```
   - Should see: `InsertPilotAvgFlightTime` and `InsertPilotByPassengerTier`

### Step 2: Configure Java Program (5 minutes)

1. **Open `Problem1.java`**

2. **Find lines 13-16** (near the top):
   ```java
   final static String HOSTNAME = "<your4x4>-sql-server.database.windows.net";
   final static String DBNAME = "cs-dsa-4513-sql-db";
   final static String USERNAME = "<your4x4>";
   final static String PASSWORD = "<your_password>";
   ```

3. **Replace placeholders** with credentials:
   ```java
   final static String HOSTNAME = "abc1-sql-server.database.windows.net";
   final static String DBNAME = "cs-dsa-4513-sql-db";
   final static String USERNAME = "abc1";
   final static String PASSWORD = "MySecurePassword123!";
   ```

4. **Save the file**

### Step 3: Download JDBC Driver (10 minutes)

1. **Download Microsoft JDBC Driver**
   - Go to: https://aka.ms/mssql-jdbc-download
   - Or search: "Microsoft JDBC Driver for SQL Server download"
   - Download the latest version (e.g., 12.4 or newer)

2. **Extract the ZIP file**
   - Find the `.jar` file: `mssql-jdbc-12.4.0.jre11.jar` (version may vary)
   - Note the full path to this file

3. **Copy JAR to your project** (recommended)
   - Copy the JAR file to the `src` directory
   - This makes compilation easier

### Step 4: Compile Java Program (2 minutes)

Should be in src directory

**Windows (PowerShell or Command Prompt):**
```cmd
javac Problem1.java
```

**Mac/Linux:**
```
javac Problem1.java
```

**If you get errors**, you might need to specify the JDBC driver:
```bash
javac -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1.java
```

You should see `Problem1.class` file created

### Step 5: Run and Test (20 minutes)

**Windows:**
```cmd
java Problem1
```

**If "driver not found" error:**
```cmd
java -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1
```

**Mac/Linux:**
```bash
java Problem1
```

**If "driver not found" error:**
```bash
java -cp ".:mssql-jdbc-12.4.0.jre11.jar" Problem1
```

command may be a little different I used :
```cmd
java -cp ".;sqljdbc_13.2.1.0_enu\sqljdbc_13.2\enu\jars\mssql-jdbc-13.2.1.jre11.jar" Problem1
```

Do required testing

---

## Troubleshooting Common Issues

### Issue: "Cannot find symbol" error during compilation

**Cause:** Java can't find JDBC classes

**Solution:**
```bash
javac -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1.java
```
(Use `:` instead of `;` on Mac/Linux)

### Issue: "No suitable driver found" error

**Cause:** JDBC driver not in classpath at runtime

**Solution:**
```bash
java -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1
```
(Use `:` instead of `;` on Mac/Linux)

### Issue: "Login failed for user"

**Causes:**
1. Wrong username/password in code
2. Azure firewall blocking your IP
3. Wrong database name

**Solutions:**
1. Double-check credentials in lines in .env or in hardcoded location towards the top of the file
2. Go to Azure portal → SQL Server → Firewalls and virtual networks → Add your IP
3. Verify database name matches your Azure database

### Issue: "Stored procedure 'InsertPilotAvgFlightTime' not found"

**Cause:** Stored procedures not created in Azure

**Solution:**
   Make sure stored procedures are created in Azure, by running the sql in Azure

### Issue: "Invalid object name 'Pilot'" or similar

**Cause:** Tables not created in Azure

**Solution:**
1. Run `Database_Setup.sql` first
2. Verify: `SELECT * FROM Pilot;`

### Issue: Scanner skips input after entering number

**This is already handled in the code** with `sc.nextLine()` after each `nextInt()`

If you still have issues, make sure you're pressing Enter after each input.

### Issue: "Primary key violation" when inserting pilot

**Cause:** Trying to insert pilot with ID that already exists

**Solution:**
- Use different pilot IDs for each test
- Or delete existing pilot: `DELETE FROM Pilot WHERE pIid = 1001;`
- Or restart with fresh database: rerun creation files

---

## Need More Help?

### Documentation Files:
- **README.md** - Full project overview
- **IMPORTANT_TOPICS.md** - Guide for concepts

### External Resources:
- **JDBC Tutorial**: https://docs.oracle.com/javase/tutorial/jdbc/
- **T-SQL Reference**: https://learn.microsoft.com/en-us/sql/t-sql/
- **Azure SQL Docs**: https://learn.microsoft.com/en-us/azure/azure-sql/


