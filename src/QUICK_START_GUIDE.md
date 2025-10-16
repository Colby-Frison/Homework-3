# Quick Start Guide - CS 4513 Homework 3

## Get Started in 5 Steps

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

3. **Replace placeholders** with YOUR credentials:
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

**Windows (PowerShell or Command Prompt):**
```cmd
cd "C:\Users\colby\OneDrive\Documents\notes\200 School\205 Fall 2025\CS 4513 - DBMS\Assignments\Homework 3\src"

javac Problem1.java
```

**Mac/Linux:**
```bash
cd "/path/to/Homework 3/src"

javac Problem1.java
```

**If you get errors**, you might need to specify the JDBC driver:
```bash
javac -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1.java
```

**Success:** You should see `Problem1.class` file created

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

**Follow the test sequence:**
1. Choose option 3 (Display) - take screenshot
2. Choose option 1 - enter: 1001, "John Smith" - take screenshot
3. Choose option 3 (Display) - verify 1001 added - take screenshot
4. Repeat steps 2-3 two more times with different IDs
5. Choose option 2 - enter: 2001, "Alice Johnson", "Gold" - take screenshot
6. Choose option 3 (Display) - take screenshot
7. Repeat steps 5-6 two more times with different IDs and tiers
8. Choose option 4 (Quit) - take screenshot

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
1. Double-check credentials in lines 13-16
2. Go to Azure portal → SQL Server → Firewalls and virtual networks → Add your IP
3. Verify database name matches your Azure database

### Issue: "Stored procedure 'InsertPilotAvgFlightTime' not found"

**Cause:** Stored procedures not created in Azure

**Solution:**
1. Open Azure Query Editor
2. Run `Problem1_StoredProcedures.sql`
3. Verify: `SELECT name FROM sys.procedures;`

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
- Or restart with fresh database: rerun `Database_Setup.sql`

---

## Screenshot Checklist

### For Problem 1 PDF:

**Page 1: Cover Page**
- [ ] Group number
- [ ] All group member names
- [ ] Assignment info
- [ ] Course info

**Page 2: Compilation**
- [ ] Screenshot of `javac Problem1.java` command
- [ ] Show no errors

**Page 3: Initial State**
- [ ] Program menu displayed
- [ ] Option 3 executed
- [ ] Shows initial pilots in database

**Pages 4-9: Option 1 Testing (3 tests)**
For each test:
- [ ] Menu and option selection (1)
- [ ] Input prompts and values entered
- [ ] Success message
- [ ] Option 3 showing new pilot added

**Pages 10-15: Option 2 Testing (3 tests)**
For each test:
- [ ] Menu and option selection (2)
- [ ] Input prompts and values entered (including tier)
- [ ] Success message
- [ ] Option 3 showing new pilot added

**Page 16: Program Exit**
- [ ] Option 4 selected
- [ ] Goodbye message displayed

---

## Quick Test Values

### Option 1 Tests (Average Flight Time):
1. pIid: `301`, pIname: `John Smith`
2. pIid: `302`, pIname: `Jane Doe`
3. pIid: `303`, pIname: `Bob Wilson`

### Option 2 Tests (By Passenger Tier):
1. pIid: `401`, pIname: `Alice Brown`, tier: `Gold`
2. pIid: `402`, pIname: `Charlie Davis`, tier: `Silver`
3. pIid: `403`, pIname: `Eve Martinez`, tier: `Bronze`

**Note:** Existing pilots in HW2 dataset are IDs 201-204 (Smith, Chen, Garcia, Patel), so use 300+ and 400+ for new test pilots to avoid conflicts.

---

## One-Line Quick Commands

### Windows PowerShell (from project root):
```powershell
cd src; javac Problem1.java; java -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1
```

### Mac/Linux (from project root):
```bash
cd src && javac Problem1.java && java -cp ".:mssql-jdbc-12.4.0.jre11.jar" Problem1
```

---

## Complete Testing Script

Copy-paste this sequence into your program when testing:

```
3                    # Display initial state
1                    # Option 1
301                  # Pilot ID
John Smith           # Pilot name
3                    # Display (verify 301 added)
1                    # Option 1 again
302                  # Pilot ID
Jane Doe             # Pilot name
3                    # Display (verify 302 added)
1                    # Option 1 again
303                  # Pilot ID
Bob Wilson           # Pilot name
3                    # Display (verify 303 added)
2                    # Option 2
401                  # Pilot ID
Alice Brown          # Pilot name
Gold                 # Tier
3                    # Display (verify 401 added)
2                    # Option 2 again
402                  # Pilot ID
Charlie Davis        # Pilot name
Silver               # Tier
3                    # Display (verify 402 added)
2                    # Option 2 again
403                  # Pilot ID
Eve Martinez         # Pilot name
Bronze               # Tier
3                    # Display (verify 403 added)
4                    # Quit
```

---

## After Successful Testing

### Create PDF for Problem 1:

1. **Organize screenshots**
   - Add cover page
   - Insert screenshots in order
   - Add captions explaining each screenshot

2. **Add source code** (optional but recommended)
   - Appendix A: Problem1.java
   - Appendix B: Problem1_StoredProcedures.sql

3. **Export to PDF**
   - Name: `HW3_Problem1_Group_X.pdf`
   - Replace X with your group number

### Complete Problem 2:

1. **Run index creation**
   - Open `Problem2_Indexing.sql` in Azure Query Editor
   - Execute index creation section
   - Take screenshot

2. **Run test queries**
   - Execute each of the 5 queries
   - Take screenshot of each result

3. **Create PDF for Problem 2**
   - Screenshots of index creation
   - Screenshots of all query results
   - Name: `HW3_Problem2_Group_X.pdf`

### Complete Problem 3:

1. **Review solution**
   - Open `Problem3_Solution.md`
   - Verify all parts are correct
   - Make any necessary corrections

2. **Convert to PDF**
   - Use Markdown to PDF converter
   - Or copy into Word and export
   - Add cover page
   - Name: `HW3_Problem3_Group_X.pdf`

### Submit to Canvas:

Upload these 6 files:
1. `HW3_Problem1_Group_X.java`
2. `HW3_Problem1_Group_X.sql`
3. `HW3_Problem1_Group_X.pdf`
4. `HW3_Problem2_Group_X.sql`
5. `HW3_Problem2_Group_X.pdf`
6. `HW3_Problem3_Group_X.pdf`

**Deadline: October 18, 2025 at 11:59 PM**

---

## Need More Help?

### Documentation Files:
- **README.md** - Full project overview
- **TODO.md** - Detailed task checklist
- **IMPORTANT_TOPICS.md** - Study guide for concepts
- **IndividualQuestion_Template.md** - Prepare for quiz

### External Resources:
- **JDBC Tutorial**: https://docs.oracle.com/javase/tutorial/jdbc/
- **T-SQL Reference**: https://learn.microsoft.com/en-us/sql/t-sql/
- **Azure SQL Docs**: https://learn.microsoft.com/en-us/azure/azure-sql/

### Course Resources:
- **Instructor Office Hours** - See Canvas
- **TA Office Hours** - See Canvas
- **Canvas Discussions** - Post questions

---

## Final Checklist

Before submission:
- [ ] All Java code compiles without errors
- [ ] Program runs successfully
- [ ] All 6 tests completed (3 for Option 1, 3 for Option 2)
- [ ] All screenshots captured
- [ ] PDFs created with cover pages
- [ ] Files renamed with correct group number
- [ ] All 6 files ready for upload
- [ ] Submission before deadline (10/18/2025 11:59 PM)

---

**Good luck! You've got this!**

If you follow this guide step-by-step, you'll complete the assignment successfully!

