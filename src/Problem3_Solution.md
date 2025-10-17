# CS 4513 - Homework 3, Problem 3 (GQ3)
## File Organization and Indexing

**Author:** [Your Name/Group Number]  
**Date:** [Date]

---

## Problem Statement

Given the **VeterinaryClinic** table with schema:
- **VeterinaryClinic (vet_name, license_no, clinic_city, fee_per_visit)**

The following records are inserted in order:
1. <Smith, 12, Tulsa, $30>
2. <Brown, 45, OKC, $25>
3. <Wilson, 23, Norman, $20>
4. <Taylor, 78, OKC, $25>
5. <Davis, 34, Edmond, $30>
6. <Clark, 67, Enid, $35>
7. <Lewis, 89, OKC, $25>
8. <Walker, 56, Yukon, $30>
9. <Harris, 90, Tulsa, $35>

**Assumptions:**
- Each block can store up to **3 veterinarian records**
- VeterinaryClinic is organized as a **sequential file** with **vet_name** as the ordering field

---

## Part 1: Sequential File Contents After Last Insertion

### Sorted Records (by vet_name)
When organizing as a sequential file ordered by vet_name, we first sort all records alphabetically:

1. Brown (45, OKC, $25)
2. Clark (67, Enid, $35)
3. Davis (34, Edmond, $30)
4. Harris (90, Tulsa, $35)
5. Lewis (89, OKC, $25)
6. Smith (12, Tulsa, $30)
7. Taylor (78, OKC, $25)
8. Walker (56, Yukon, $30)
9. Wilson (23, Norman, $20)

### Block Organization (3 records per block)

```
┌─────────────────────────────────────────────────────────┐
│ BLOCK 0 (Address: 0x000)                                │
├─────────────────────────────────────────────────────────┤
│ Record 0: <Brown, 45, OKC, $25>                         │
│ Record 1: <Clark, 67, Enid, $35>                        │
│ Record 2: <Davis, 34, Edmond, $30>                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ BLOCK 1 (Address: 0x001)                                │
├─────────────────────────────────────────────────────────┤
│ Record 0: <Harris, 90, Tulsa, $35>                      │
│ Record 1: <Lewis, 89, OKC, $25>                         │
│ Record 2: <Smith, 12, Tulsa, $30>                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ BLOCK 2 (Address: 0x002)                                │
├─────────────────────────────────────────────────────────┤
│ Record 0: <Taylor, 78, OKC, $25>                        │
│ Record 1: <Walker, 56, Yukon, $30>                      │
│ Record 2: <Wilson, 23, Norman, $20>                     │
└─────────────────────────────────────────────────────────┘
```

### Detailed Address Mapping

| Record Address | Block | Position | Data |
|---------------|-------|----------|------|
| 0x000.0 | Block 0 | Pos 0 | <Brown, 45, OKC, $25> |
| 0x000.1 | Block 0 | Pos 1 | <Clark, 67, Enid, $35> |
| 0x000.2 | Block 0 | Pos 2 | <Davis, 34, Edmond, $30> |
| 0x001.0 | Block 1 | Pos 0 | <Harris, 90, Tulsa, $35> |
| 0x001.1 | Block 1 | Pos 1 | <Lewis, 89, OKC, $25> |
| 0x001.2 | Block 1 | Pos 2 | <Smith, 12, Tulsa, $30> |
| 0x002.0 | Block 2 | Pos 0 | <Taylor, 78, OKC, $25> |
| 0x002.1 | Block 2 | Pos 1 | <Walker, 56, Yukon, $30> |
| 0x002.2 | Block 2 | Pos 2 | <Wilson, 23, Norman, $20> |

---

## Part 2: Index-Sequential File with Indexes

### 2.1 Dense Primary Index on vet_name

A **dense primary index** has one index entry for **every search key value** in the data file.

```
┌─────────────────────────────────────┐
│   DENSE PRIMARY INDEX (vet_name)    │
├──────────────────┬──────────────────┤
│   Search Key     │   Block Pointer  │
│   (vet_name)     │   (Address)      │
├──────────────────┼──────────────────┤
│   Brown          │   0x000.0        │
│   Clark          │   0x000.1        │
│   Davis          │   0x000.2        │
│   Harris         │   0x001.0        │
│   Lewis          │   0x001.1        │
│   Smith          │   0x001.2        │
│   Taylor         │   0x002.0        │
│   Walker         │   0x002.1        │
│   Wilson         │   0x002.2        │
└──────────────────┴──────────────────┘
```

**Explanation:**
- Each veterinarian name has an entry pointing to its exact record location
- Total entries: 9 (one for each record)
- This is a **primary index** because vet_name is the ordering field
- This is **dense** because every search key value has an index entry

### 2.2 Secondary Index on fee_per_visit

A **secondary index** is built on a non-ordering field. For fee_per_visit, multiple records may have the same value, so we use a **multi-level structure** or **inverted index**.

**Approach 1: Secondary Index with Record Lists**

```
┌───────────────────────────────────────────────────────────┐
│      SECONDARY INDEX (fee_per_visit)                      │
├──────────────────┬────────────────────────────────────────┤
│  Search Key      │   Record Pointers (Addresses)          │
│  (fee_per_visit) │                                        │
├──────────────────┼────────────────────────────────────────┤
│   $20            │   0x002.2 (Wilson)                     │
├──────────────────┼────────────────────────────────────────┤
│   $25            │   0x000.0 (Brown)                      │
│                  │   0x001.1 (Lewis)                      │
│                  │   0x002.0 (Taylor)                     │
├──────────────────┼────────────────────────────────────────┤
│   $30            │   0x000.2 (Davis)                      │
│                  │   0x001.2 (Smith)                      │
│                  │   0x002.1 (Walker)                     │
├──────────────────┼────────────────────────────────────────┤
│   $35            │   0x000.1 (Clark)                      │
│                  │   0x001.0 (Harris)                     │
└──────────────────┴────────────────────────────────────────┘
```

**Explanation:**
- This is a **secondary index** because fee_per_visit is NOT the ordering field
- Each unique fee value points to ALL records with that fee
- The index is sorted by fee_per_visit for efficient searching
- Total unique entries: 4 ($20, $25, $30, $35)

**Approach 2: Secondary Index with Indirection (Buckets)**

Alternative representation using bucket addresses:

```
┌─────────────────────────────────────┐
│  SECONDARY INDEX (fee_per_visit)    │
├──────────────┬──────────────────────┤
│  Search Key  │   Bucket Pointer     │
├──────────────┼──────────────────────┤
│   $20        │   Bucket_A           │
│   $25        │   Bucket_B           │
│   $30        │   Bucket_C           │
│   $35        │   Bucket_D           │
└──────────────┴──────────────────────┘

Bucket_A: [0x002.2]  → Wilson
Bucket_B: [0x000.0, 0x001.1, 0x002.0]  → Brown, Lewis, Taylor
Bucket_C: [0x000.2, 0x001.2, 0x002.1]  → Davis, Smith, Walker
Bucket_D: [0x000.1, 0x001.0]  → Clark, Harris
```

---

## Part 3: B+-Tree Index on license_no (Order 3)

### B+-Tree Properties (Order 3)
- **Order (n) = 3**
- **Maximum keys per node:** n - 1 = 2 keys
- **Minimum keys per internal node:** ⌈n/2⌉ - 1 = ⌈1.5⌉ - 1 = 1 key
- **Minimum keys per leaf node:** ⌈n/2⌉ - 1 = 1 key
- **Maximum children per internal node:** n = 3
- **Minimum children per internal node:** ⌈n/2⌉ = 2

### Insertion Sequence

**Sorted by license_no:** 12, 23, 34, 45, 56, 67, 78, 89, 90

### Step-by-Step Construction

**After inserting 12:**
```
[12]
```

**After inserting 23:**
```
[12, 23]
```

**After inserting 34:**
```
[12, 23, 34]  → Node is full (3 keys, max is 2 in B+-tree)
Need to split!
```

**After split (promoting 23):**
```
         [23]
        /    \
    [12]      [23, 34]
```

**After inserting 45:**
```
         [23]
        /    \
    [12]      [23, 34, 45]  → Leaf is full, split!
```

**After split (promoting 34):**
```
         [23, 34]
        /    |    \
    [12]   [23]   [34, 45]
```

**After inserting 56:**
```
         [23, 34]
        /    |    \
    [12]   [23]   [34, 45, 56]  → Leaf is full, split!
```

**After split (promoting 45):**
```
            [23, 34]
           /    |    \
       [12]   [23]   [34, 45, 56]  → Need to split and promote 45
       
Root is full (3 keys), need to split root!
```

**After root split:**
```
              [34]
            /      \
        [23]        [45]
       /    \      /    \
    [12]   [23]  [34]  [45, 56]
```

**After inserting 67:**
```
              [34]
            /      \
        [23]        [45]
       /    \      /    \
    [12]   [23]  [34]  [45, 56, 67]  → Split!
```

**After split (promoting 56):**
```
              [34]
            /      \
        [23]        [45, 56]
       /    \      /    |    \
    [12]   [23]  [34]  [45]  [56, 67]
```

**After inserting 78:**
```
              [34]
            /      \
        [23]        [45, 56]
       /    \      /    |    \
    [12]   [23]  [34]  [45]  [56, 67, 78]  → Split!
```

**After split (promoting 67):**
```
                    [34]
                  /      \
              [23]        [45, 56, 67]  → Internal node full!
             /    \      /    |    |    \
         [12]   [23]  [34]  [45]  [56]  [67, 78]
         
Need to split internal node and promote to root!
```

**After internal split:**
```
                  [34, 56]
               /     |      \
           [23]    [45]    [67]
          /   \    /  \    /   \
      [12] [23] [34] [45] [56] [67, 78]
```

**After inserting 89:**
```
                  [34, 56]
               /     |      \
           [23]    [45]    [67]
          /   \    /  \    /   \
      [12] [23] [34] [45] [56] [67, 78, 89]  → Split!
```

**After split (promoting 78):**
```
                    [34, 56]
                 /     |      \
             [23]    [45]    [67, 78]
            /   \    /  \    /   |   \
        [12] [23] [34] [45] [56] [67] [78, 89]
```

**After inserting 90:**
```
                    [34, 56]
                 /     |      \
             [23]    [45]    [67, 78]
            /   \    /  \    /   |   \
        [12] [23] [34] [45] [56] [67] [78, 89, 90]  → Split!
```

### Final B+-Tree Structure

```
                    [34, 56]
                 /     |      \
             [23]    [45]    [67, 78]
            /   \    /  \    /   |   \
        [12] [23] [34] [45] [56] [67] [78, 89, 90]  → Need to split!
```

**After final split (promoting 89):**

```
                      [34, 56]
                   /     |      \
               [23]    [45]    [67, 78, 89]  → Internal node full! Split!
              /   \    /  \    /   |   |   \
          [12] [23] [34] [45] [56] [67] [78] [89, 90]
```

**Split internal node and promote:**

```
                         [56]
                     /          \
                 [34]            [78]
               /     \         /      \
           [23]     [45]    [67]     [89]
          /   \     /  \    /  \     /   \
      [12] [23] [34] [45] [56] [67] [78] [89, 90]
```

### Final B+-Tree (Complete Structure with Leaf Links)

```
                           [56]
                     /             \
                 [34]               [78]
               /     \            /      \
           [23]     [45]       [67]     [89]
          /   \     /  \       /  \     /   \
        [12] [23] [34] [45] [56] [67] [78] [89, 90]
         ↓    ↓    ↓    ↓     ↓    ↓    ↓    ↓   ↓
         S    B    W    B     W    C    T    L   H
```

**Legend for Leaf Node Data (license_no → vet_name):**
- 12 → Smith (S)
- 23 → Wilson (W)
- 34 → Davis (D)
- 45 → Brown (B)
- 56 → Walker (W)
- 67 → Clark (C)
- 78 → Taylor (T)
- 89 → Lewis (L)
- 90 → Harris (H)

### Detailed Leaf Node Contents (with horizontal pointers)

```
Leaf Nodes (left to right with pointers):
┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐
│ [12] │───→│ [23] │───→│ [34] │───→│ [45] │
│Smith │    │Wilson│    │Davis │    │Brown │
└──────┘    └──────┘    └──────┘    └──────┘
    ┌───────────────────────────────────┘
    ↓                            
┌──────┐    ┌──────┐    ┌──────┐    ┌─────────────┐
│ [56] │───→│ [67] │───→│ [78] │───→│   [89, 90]  │
│Walker│    │Clark │    │Taylor│    │Lewis, Harris│
└──────┘    └──────┘    └──────┘    └─────────────┘
```

### Tree Properties Verification

- **Root has between 2 and 3 children:** Root [56] has 2 children  
- **Internal nodes have between 2 and 3 children:** All internal nodes comply  
- **All leaves are at the same level:** Yes (depth = 3)  
- **Leaf nodes have between 1 and 2 keys:** All leaves comply (except last has 2)  
- **Keys are in ascending order:** Yes  
- **No duplicate license_no:** Correct (unique constraint)  

---

## Summary

This problem demonstrates three important file organization and indexing concepts:

1. **Sequential File Organization:** Data stored in sorted order by a key field, with fixed block sizes
2. **Index-Sequential Access:** 
   - Dense primary index on ordering field (vet_name)
   - Secondary index on non-ordering field (fee_per_visit)
3. **B+-Tree Indexing:** Dynamic, balanced tree structure that maintains order and supports efficient searches, insertions, and deletions

Each approach has different trade-offs in terms of storage overhead, search efficiency, and maintenance costs.

