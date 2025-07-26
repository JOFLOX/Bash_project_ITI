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
