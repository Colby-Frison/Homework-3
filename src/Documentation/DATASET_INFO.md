# HW2 Dataset Integration - Summary


## Dataset Overview (From Your HW2)

### Passengers (12 total)
| ID | Name | Tier | Age |
|----|------|------|-----|
| 1 | Alice | Gold | 28 |
| 2 | Bob | Silver | 35 |
| 3 | Carol | Gold | 22 |
| 4 | Dan | Bronze | 41 |
| 5 | Eva | Silver | 30 |
| 6 | Frank | Gold | 26 |
| 7 | Grace | Bronze | 19 |
| 8 | Henry | Silver | 45 |
| 9 | Irene | Gold | 33 |
| 10 | Jack | Bronze | 20 |
| 11 | Kim | Silver | 27 |
| 12 | Leo | Gold | 52 |

**Tier Distribution:**
- Gold: 6 passengers (Alice, Carol, Frank, Irene, Leo, and one more)
- Silver: 4 passengers (Bob, Eva, Henry, Kim)
- Bronze: 3 passengers (Dan, Grace, Jack)

### Pilots (4 total)
| ID | Name | Hours |
|----|------|-------|
| 201 | Smith | 12000.0 |
| 202 | Chen | 9500.0 |
| 203 | Garcia | 8000.0 |
| 204 | Patel | 7000.0 |

**Key Point:** Smith (pIid=201) has the most experience and flies the most routes

### Flights (8 total)
| Flight | Origin | Destination | Departure | Arrival | Duration | Pilot |
|--------|--------|-------------|-----------|---------|----------|-------|
| F100 | LAX | JFK | 09:00 | 17:20 | 8h 20m | Smith |
| F101 | SFO | ORD | 09:00 | 15:30 | 6h 30m | Chen |
| F102 | LAX | SEA | 13:30 | 15:50 | 2h 20m | Smith |
| F103 | DFW | ORD | 12:00 | 14:25 | 2h 25m | Garcia |
| F104 | ATL | SEA | 12:00 | 15:00 | 3h 00m | Patel |
| F105 | ORD | DFW | 15:30 | 17:45 | 2h 15m | Smith |
| F106 | LAX | ATL | 09:00 | 16:35 | 7h 35m | Smith |
| F107 | BOS | ORD | 10:00 | 12:30 | 2h 30m | Smith |

**Key Points:**
- Smith pilots 5 out of 8 flights (most active pilot)
- 3 flights depart from LAX (F100, F102, F106) - perfect for Problem 2 indexing
- Average flight duration: ~4.4 hours
- Flight F100 (LAX→JFK) is the most popular with 6 passengers booked

### Bookings (16 total)
| Passenger | Flight(s) | Tier | Pilot(s) |
|-----------|-----------|------|----------|
| Alice (1) | F100, F101, F102 | Gold | Smith, Chen, Smith |
| Bob (2) | F101, F105 | Silver | Chen, Smith |
| Carol (3) | F100, F101 | Gold | Smith, Chen |
| Dan (4) | F101 | Bronze | Chen |
| Eva (5) | F100 | Silver | Smith |
| Frank (6) | F100 | Gold | Smith |
| Grace (7) | F106 | Bronze | Smith |
| Henry (8) | F100 | Silver | Smith |
| Irene (9) | F100 | Gold | Smith |
| Jack (10) | F104 | Bronze | Patel |
| Kim (11) | F103 | Silver | Garcia |
| Leo (12) | F105 | Gold | Smith |

**Key Points:**
- F100 (LAX→JFK, Smith) has 6 passengers: Alice, Carol, Eva, Frank, Henry, Irene
- Alice is the most frequent flyer with 3 bookings
- Smith serves passengers of all tiers (Gold, Silver, Bronze)

---

## Why This Dataset Works Perfectly for HW3

### For Problem 1 (Stored Procedures):

**Stored Procedure 1: InsertPilotAvgFlightTime**
- Will calculate average across 8 flights
- Average duration: ~4.4 hours
- Good range of flight times (2h 15m to 8h 20m)

**Stored Procedure 2: InsertPilotByPassengerTier**
- **Gold tier:** Smith and Chen both have Gold passengers
  - Smith flies: Alice, Carol, Frank, Irene, Leo
  - Chen flies: Alice, Carol
  - Average of their flights will be calculated
  
- **Silver tier:** Smith and Chen both have Silver passengers
  - Smith flies: Bob, Eva, Henry
  - Chen flies: Bob
  - Average of their flights will be calculated
  
- **Bronze tier:** Smith, Chen, and Patel have Bronze passengers
  - Smith flies: Grace
  - Chen flies: Dan
  - Patel flies: Jack
  - Average of their flights will be calculated

### For Problem 2 (Indexing):

**Index on Flight(origin) is perfect because:**
- 3 flights from LAX (F100, F102, F106) - good test case
- 2 flights from ORD (F103, F105)
- Other origins: SFO, DFW, ATL, BOS (1 each)
- Good distribution for demonstrating index benefits

**Queries that will work great:**
1. `WHERE origin = 'LAX'` - Will find 3 flights
2. `WHERE origin IN ('LAX', 'ORD')` - Will find 5 flights
3. `GROUP BY origin` - Will show distribution
4. Joins on origin with passenger data
5. Pilot analysis by origin airport

### For Individual Questions (IQ1-IQ4):

**IQ1: Silver tier OR Smith pilot**
- Silver passengers: Bob, Eva, Henry, Kim (4 passengers)
- Smith pilots: F100, F102, F105, F106, F107 (5 flights)
- Many passengers on Smith's flights
- Good test case for OR conditions

**IQ2: LAX flights OR 5+ passengers**
- LAX flights: F100, F102, F106 (3 flights)
- F100 has 6 passengers (only one with 5+)
- OR condition will be interesting to optimize

**IQ3: Same departure time**
- F103 and F104 both depart at 12:00
- No passengers booked on both (Jack on F104, Kim on F103)
- Interesting edge case!

**IQ4: Delete Bronze passengers**
- 3 Bronze passengers: Dan, Grace, Jack
- Tests DELETE performance with indexing

---

## Changes Made to Files

### 1. `src/Database_Setup.sql`
**Updated sections:**
- Passenger INSERT statements (12 passengers from CSV)
- Pilot INSERT statements (4 pilots from CSV)
- Flight INSERT statements (8 flights from CSV, time format converted)
- Booking INSERT statements (16 bookings from CSV)
- Data verification counts updated
- Summary section updated with correct counts
- Test queries updated to reference actual data

**Key conversions:**
- Time format: "M 09:00" → "09:00:00" (removed day prefix)
- Column names aligned with schema (pid → pIid for pilots)

### 2. `src/QUICK_START_GUIDE.md`
**Updated sections:**
- Test values updated to use pilot IDs 301-303 and 401-403
  - Avoids conflict with existing pilots 201-204
- Expected data counts: 12 passengers, 4 pilots, 8 flights, 16 bookings
- Test script updated with correct pilot IDs
- Note added about using HW2 dataset

### 3. `START_HERE.md`
**Updated sections:**
- Data summary mentions "YOUR HW2 dataset"
- Correct counts: 12, 4, 8, 16

### 4. `src/DATASET_INFO.md`
**Created this file** to document the dataset integration!

---

## Test Values to Use

### When Testing Option 1 (InsertPilotAvgFlightTime):
Use pilot IDs 301-399 to avoid conflicts:
- Test 1: pIid = 301, pIname = "John Smith"
- Test 2: pIid = 302, pIname = "Jane Doe"
- Test 3: pIid = 303, pIname = "Bob Wilson"

**Expected hours:** ~4.4 (average of all 8 flights)

### When Testing Option 2 (InsertPilotByPassengerTier):
Use pilot IDs 401-499 to avoid conflicts:

**Test 1: Gold tier**
- pIid = 401, pIname = "Alice Brown", tier = "Gold"
- Expected: Average of flights by Smith and Chen who have Gold passengers
- Flights: F100, F101, F102, F105, F106, F107
- Expected hours: ~5.3

**Test 2: Silver tier**
- pIid = 402, pIname = "Charlie Davis", tier = "Silver"
- Expected: Average of flights by Smith and Chen who have Silver passengers
- Flights: F100, F101, F102, F105, F106, F107
- Expected hours: ~5.3

**Test 3: Bronze tier**
- pIid = 403, pIname = "Eve Martinez", tier = "Bronze"
- Expected: Average of flights by Smith, Chen, and Patel who have Bronze passengers
- Flights: F100, F101, F104, F106
- Expected hours: ~6.4

---

## Verification Checklist

Before running the Java program:
- [ ] `Database_Setup.sql` executed successfully
- [ ] 12 passengers in Passenger table
- [ ] 4 pilots in Pilot table (201-204)
- [ ] 8 flights in Flight table (F100-F107)
- [ ] 16 bookings in Booking table
- [ ] Pilot "Smith" exists with pIid = 201
- [ ] Multiple flights from LAX exist (F100, F102, F106)
- [ ] All three tiers represented (Gold, Silver, Bronze)

Run this query to verify:
```sql
SELECT 'Passengers' AS TableName, COUNT(*) AS Count FROM Passenger
UNION ALL
SELECT 'Pilots', COUNT(*) FROM Pilot
UNION ALL
SELECT 'Flights', COUNT(*) FROM Flight
UNION ALL
SELECT 'Bookings', COUNT(*) FROM Booking;

-- Should show: 12, 4, 8, 16
```

---

## Integration Complete

The HW2 dataset is now fully integrated and ready for testing. The data includes:
- Real passengers from your HW2
- Real pilots (including Smith for IQ1)
- Real flights (including multiple from LAX for Problem 2)
- Real bookings (connecting passengers to flights)

All documentation has been updated to reflect the actual data counts and test values.

**Next Steps:**
1. Run `Database_Setup.sql` on Azure
2. Run `Problem1_StoredProcedures.sql` on Azure
3. Update credentials in `Problem1.java`
4. Compile and test!

Good luck!

