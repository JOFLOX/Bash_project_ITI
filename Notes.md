# yad vs zenity: Core Experience

## yad (🚫 Problematic)
- Snap install → Library conflicts (`symbol lookup error`)
- VSCode terminal fails 
- Inconsistent behavior (terminal vs VSCode)

## zenity (✅ Good)
- No snap install needed
- Consistent behavior (terminal vs VSCode)
- No library conflicts

# files

## `insert_table.sh` 
- used `list_tables_radio.sh` to select table
- then use `form.sh` to insert data

## UPDATE: files in normal flow


## `validate.sh` 

### validate_create_db()
- check if db name is empty
- check if db name is valid (start with letter/underscore + letters/numbers/underscores only, up to 64 chars)
- check if db name is a reserved keyword
- check if db already exists
- the check of dbname is not case sensitive and always check with the lower case of the db name 

### available_dbs() used for list db and connect 
- list all databases
- check if no databases exist

### valid_db_selection() used for connect and drop
- check if user selected a database from search 
-

## `create_table_refactored.sh` used as a temp for `create_table.sh` 
- validate table name
- validate column count
- validate column name
- validate primary key type
- create metadata file
- create data file
- show success message


## `database_menu.sh` 
- database menu
- call create table
- call list tables
- call drop table
- call insert table
- call select table
- call update table
- call delete row
- call back to main menu

## `welcome.sh` 
- welcome screen


# fixed
## `menu.sh` 
- the list db function print the zenity list EVEN if no databases exist 
- the create db show any new db created as exist if the dbms folder was empty
- connect db function print the zenity list EVEN if no databases exist AND if user cancel the selection, the function is called again
- drop db same as connect goes in infinite loop if no databases exist
- create db checking if exist was wrong and only check in lower case and not case-insensitive

# Issues
- enter column length message is not clear
- select if table empty dont show any data and show an info 
- insert: if pk string show error message "cant be empty" but in int show just must be int change to cant be empty
- insert: doesnt check pk string exist 
- update: from search bar just return to menu without any message, must show error message

