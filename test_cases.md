# DBMS Bash Project - Comprehensive Test Cases

**Entry Point:** `/home/youssef/Desktop/DBMS_IN_BASH/menu.sh`

---

## Table of Contents

1. [Initialization & Setup Tests](#1-initialization--setup-tests)
2. [Main Menu Tests](#2-main-menu-tests)
3. [Database Creation Tests](#3-database-creation-tests)
4. [Database Listing Tests](#4-database-listing-tests)
5. [Database Connection Tests](#5-database-connection-tests)
6. [Database Dropping Tests](#6-database-dropping-tests)
7. [Table Creation Tests](#7-table-creation-tests)
8. [Table Listing Tests](#8-table-listing-tests)
9. [Table Dropping Tests](#9-table-dropping-tests)
10. [Data Insertion Tests](#10-data-insertion-tests)
11. [Data Selection/Viewing Tests](#11-data-selectionviewing-tests)
12. [Data Update Tests](#12-data-update-tests)
13. [Data Deletion Tests](#13-data-deletion-tests)
14. [Edge Cases & Security Tests](#14-edge-cases--security-tests)
15. [Navigation & Flow Tests](#15-navigation--flow-tests)
16. [Validation Function Tests](#16-validation-function-tests)
17. [Stress Tests](#17-stress-tests)
18. [Cleanup Tests](#18-cleanup-tests)
19. [Testing Methodology](#testing-methodology)

---

## 1. Initialization & Setup Tests

### 1.1 Directory Creation Test
- **Steps:** Run `./menu.sh` when `./dbms` directory doesn't exist
- **Expected:** Directory should be created automatically
- **Edge Case:** Test with no write permissions in current directory

### 1.2 GUI Availability Test
- **Steps:** Run `./menu.sh` without zenity installed
- **Expected:** Should show error or graceful fallback
- **Verification:** `which zenity` (should return path)

---

## 2. Main Menu Tests

### 2.1 Main Menu Display
- **Steps:** Run `./menu.sh`
- **Expected:** Main menu with 5 options appears
- **Verify:** Options include "Create Database", "List Databases", "Connect to Database", "Drop Database", "Exit"

### 2.2 Menu Navigation
- **Steps:** Select each option and verify correct function calls
- **Test:** Cancel/Close button behavior
- **Test:** Invalid selections

---

## 3. Database Creation Tests

### 3.1 Valid Database Names
**Steps:** Create Database → Enter valid names

**Test Cases:**
- `testdb` (lowercase)
- `TestDB` (mixed case)
- `test_db` (underscore)
- `_private` (starts with underscore)
- `db123` (with numbers)
- `a` (single character)
- 64 character name (maximum length)

### 3.2 Invalid Database Names
**Steps:** Create Database → Enter invalid names

**Test Cases:**
- Empty string `""`
- `123db` (starts with number)
- `test-db` (hyphen)
- `test.db` (dot)
- `test db` (space)
- `test/db` (slash)
- 65+ character name
- Special chars: `test@db`, `test#db`

### 3.3 Reserved Keywords
**Steps:** Create Database → Enter reserved words

**Test Cases:** `select`, `drop`, `insert`, `delete`, `update`, `table`, `create`, `int`, `string`, `from`, `where`, `null`, `pk`, `system`, `default`

**Expected:** Error message for each

### 3.4 Case Sensitivity & Duplicates
**Steps:**
1. Create `TestDB`
2. Try to create `testdb`, `TESTDB`, `TestDb`

**Expected:** All should be rejected as duplicates

### 3.5 Cancel Operations
**Steps:** Create Database → Click Cancel
**Expected:** Return to main menu without error

---

## 4. Database Listing Tests

### 4.1 Empty Database List
- **Steps:** List Databases when no databases exist
- **Expected:** "No databases found" message

### 4.2 Single Database
- **Steps:** Create one database → List Databases
- **Expected:** Show single database in list

### 4.3 Multiple Databases
- **Steps:** Create 5+ databases → List Databases
- **Expected:** All databases shown, sorted alphabetically

### 4.4 List After Operations
- **Steps:** Create, drop, create again → List
- **Expected:** Current state reflected accurately

---

## 5. Database Connection Tests

### 5.1 Connect to Non-existent Database
- **Steps:** Connect when no databases exist
- **Expected:** Error message, no infinite loop

### 5.2 Connect and Cancel
- **Steps:** Connect → Select database → Cancel
- **Expected:** Return to main menu

### 5.3 Valid Connection
- **Steps:** Create database → Connect → Select it
- **Expected:** Database menu opens with correct title

### 5.4 Connection Menu Navigation
- **Steps:** Connect to database → Test all menu options
- **Expected:** All 8 options work (Create Table, List Tables, etc.)

---

## 6. Database Dropping Tests

### 6.1 Drop Non-existent
- **Steps:** Drop Database when none exist
- **Expected:** Error message, no crash

### 6.2 Drop Confirmation
- **Steps:** Drop Database → Select → Click "No"
- **Expected:** Database preserved, return to menu

### 6.3 Drop Execution
- **Steps:** Drop Database → Select → Click "Yes"
- **Expected:** Database and all contents deleted

### 6.4 Drop with Tables
- **Steps:** Create database → Create tables → Drop database
- **Expected:** All tables and data removed

---

## 7. Table Creation Tests

### 7.1 Valid Table Names
- **Steps:** Connect to DB → Create Table
- **Test:** Same naming rules as databases
- **Additional:** Verify table doesn't already exist

### 7.2 Column Count Validation
**Steps:** Create Table → Enter column count

**Test Cases:**
- `0` columns (invalid)
- `1` column (valid)
- `15` columns (valid)
- `16+` columns (invalid)
- Non-numeric input
- Negative numbers

### 7.3 Column Name Validation
**Steps:** Create Table → Enter column names

**Test Cases:**
- **Valid:** `id`, `user_name`, `_private`
- **Invalid:** `123col`, `col-name`, `col name`
- Reserved keywords
- Duplicate column names
- Empty column names

### 7.4 Column Type Validation
**Steps:** Create Table → Select column types

**Test Cases:**
- `int` type selection
- `string` type selection
- Verify dropdown works correctly

### 7.5 Primary Key Selection
**Steps:** Create Table → Select primary key

**Test Cases:**
- Select each column as PK
- Verify only one can be selected
- Cancel PK selection

### 7.6 File Creation Verification
**Steps:** After successful table creation

**Verify:**
- `.meta` and `.data` files created
- `.meta` file format: `name:type:PK`

---

## 8. Table Listing Tests

### 8.1 Empty Table List
- **Steps:** Connect to DB → List Tables (no tables)
- **Expected:** "No tables exist" message

### 8.2 Multiple Tables
- **Steps:** Create 3+ tables → List Tables
- **Expected:** All tables shown without `.meta` extension

---

## 9. Table Dropping Tests

### 9.1 Drop Table Selection
- **Steps:** Drop Table → Select from list
- **Expected:** Confirmation dialog appears

### 9.2 Drop Confirmation
- **Steps:** Drop Table → Select → Cancel confirmation
- **Expected:** Table preserved

### 9.3 Drop Execution
- **Steps:** Drop Table → Select → Confirm
- **Expected:** Both `.meta` and `.data` files deleted

---

## 10. Data Insertion Tests

### 10.1 Table Selection for Insert
- **Steps:** Insert Table → Select table
- **Expected:** Form appears with correct fields

### 10.2 Primary Key Validation
- **Steps:** Insert data with empty PK field
- **Expected:** Error message, form redisplays

### 10.3 Integer Field Validation
**Steps:** Insert non-integer in INT field

**Test Cases:** `abc`, `12.5`, `12a`, `""` (empty)

**Expected:** Error for invalid, accept valid integers

### 10.4 Duplicate Primary Key
- **Steps:** Insert row → Insert another with same PK
- **Expected:** Error message about duplicate PK

### 10.5 Successful Insertion
- **Steps:** Insert valid data
- **Expected:** Success message, data saved to `.data` file

### 10.6 Data File Format
- **Steps:** After insertion, check `.data` file
- **Expected:** Colon-separated values

---

## 11. Data Selection/Viewing Tests

### 11.1 View Empty Table
- **Steps:** Select Table on empty table
- **Expected:** Headers shown, no data rows

### 11.2 View Table with Data
- **Steps:** Insert data → Select Table
- **Expected:** Formatted table display

### 11.3 Column Alignment
- **Steps:** View table with varying data lengths
- **Expected:** Proper column alignment

---

## 12. Data Update Tests

### 12.1 Update Table Selection
- **Steps:** Update Table → Select table
- **Expected:** Update interface appears

### 12.2 Update Primary Key Validation
- **Steps:** Try to update PK to existing value
- **Expected:** Error about duplicate PK

### 12.3 Update Field Validation
- **Steps:** Update INT field with invalid data
- **Expected:** Validation error

---

## 13. Data Deletion Tests

### 13.1 Delete Row Selection
- **Steps:** Delete Row → Select table → Select row
- **Expected:** Confirmation dialog

### 13.2 Delete Confirmation
- **Steps:** Delete Row → Cancel confirmation
- **Expected:** Row preserved

### 13.3 Delete Execution
- **Steps:** Delete Row → Confirm
- **Expected:** Row removed from `.data` file

---

## 14. Edge Cases & Security Tests

### 14.1 File System Injection
**Test Cases:**
- Database name: `../etc/passwd`
- Table name: `/tmp/malicious`
- Field values: `'; rm -rf / #`

### 14.2 Large Data Tests
- **Steps:** Insert very long strings (1000+ chars)
- **Expected:** Proper handling or reasonable limits

### 14.3 Special Characters in Data
**Test Cases:**
- Colons in data (conflicts with delimiter)
- Newlines in data
- Unicode characters
- Null bytes

### 14.4 Concurrent Access
- **Steps:** Run multiple instances simultaneously
- **Expected:** No data corruption

### 14.5 Permission Tests
- **Steps:** Remove write permissions on dbms directory
- **Expected:** Graceful error handling

### 14.6 Disk Space Tests
- **Steps:** Fill disk space, try operations
- **Expected:** Proper error messages

---

## 15. Navigation & Flow Tests

### 15.1 Back Navigation
- **Steps:** Navigate deep into menus → Use "Back" options
- **Expected:** Proper return to previous menus

### 15.2 Menu State Consistency
- **Steps:** Perform operations → Check menu states
- **Expected:** Menus reflect current database state

### 15.3 Error Recovery
- **Steps:** Cause errors → Continue using application
- **Expected:** Application remains stable

---

## 16. Validation Function Tests

### 16.1 validate.sh Functions
Test each function in `validate.sh` independently:

- `is_valid_name()`
- `is_reserved_keyword()`
- `validate_table_name()`
- `validate_create_db()`
- `available_dbs()`
- `valid_db_selection()`
- `check_pk_not_empty()`
- `validate_int()`
- `check_duplicate_pk()`

---

## 17. Stress Tests

### 17.1 Many Databases
- **Steps:** Create 50+ databases
- **Expected:** Performance remains acceptable

### 17.2 Many Tables
- **Steps:** Create 20+ tables in one database
- **Expected:** All operations work correctly

### 17.3 Large Tables
- **Steps:** Insert 100+ rows in one table
- **Expected:** View/update/delete still functional

---

## 18. Cleanup Tests

### 18.1 Proper File Cleanup
- **Steps:** Create and drop databases/tables
- **Expected:** No orphaned files remain

### 18.2 Directory Structure
- **Steps:** Verify dbms directory structure
- **Expected:** Only valid database directories exist

---

## Testing Methodology

### For Each Test:
1. **Record** the exact steps taken
2. **Note** expected vs actual behavior
3. **Check** file system state after operations
4. **Verify** no error messages in terminal
5. **Test** both GUI interactions and underlying file operations
6. **Document** any crashes or unexpected behavior

### Critical Areas to Focus On:
- **Input validation** (most vulnerable area)
- **File operations** (data integrity)
- **Navigation flow** (user experience)
- **Error handling** (application stability)

### Test Results Template:
```
Test Case: [Test Name]
Status: [PASS/FAIL/PARTIAL]
Steps Taken: [Actual steps]
Expected Result: [What should happen]
Actual Result: [What actually happened]
Notes: [Any additional observations]
```

---

## Priority Testing Order

1. **High Priority:** Sections 1-6 (Basic functionality)
2. **Medium Priority:** Sections 7-13 (Table operations)
3. **Low Priority:** Sections 14-18 (Edge cases and stress tests)

Start with basic functionality tests before moving to complex table operations and edge cases.