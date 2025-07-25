#!/bin/bash
source create_table.sh
source database_menu.sh
source validate.sh

# Global Variables
DB_DIR="./dbms"  # Main database directory
TABLE_DATA_EXT=".data"
TABLE_META_EXT=".meta"

# Create main DB directory if not exists
initialize_db_dir() {
    if [[ ! -d "$DB_DIR" ]]; then
        mkdir -p "$DB_DIR"
    fi
}

# Validate identifier (db/table names)
validate_identifier() {
    [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]{0,63}$ ]] && return 0 || return 1
}

# Database Operations
create_database() {
    local db_name
    db_name=$(zenity --entry --title="Create Database" --text="Enter database name:")
    
    [[ $? -ne 0 ]] && return  # User canceled
    
    if ! validate_create_db "$db_name"; then
        create_database
        return
    fi
    
    local db_path="$DB_DIR/$db_name"
    if [[ -d "$db_path" ]]; then
        zenity --error --text="Database '$db_name' already exists!"
    else
        mkdir -p "$db_path"
        zenity --info --text="Database '$db_name' created successfully"
    fi
}

list_databases() {
    if [[ -z "$(ls -A "$DB_DIR")" ]]; then
        zenity --info --text="No databases found"
        return
    fi
    
    local dbs
    dbs=$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)
    
    zenity --list --title="Databases" --column="Database Name" $dbs
}

connect_database() {
    if [[ -z "$(ls -A "$DB_DIR")" ]]; then
        zenity --error --text="No databases available"
        return
    fi
    
    local db_name
    db_name=$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | \
              sort | zenity --list --title="Connect to Database" --column="Database Name")
    
    [[ -z "$db_name" ]] && return  # User canceled
    
    database_menu "$db_name"
}

drop_database() {
    if [[ -z "$(ls -A "$DB_DIR")" ]]; then
        zenity --error --text="No databases available"
        return
    fi
    
    local db_name
    db_name=$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | \
              sort | zenity --list --title="Drop Database" --column="Database Name")
    
    [[ -z "$db_name" ]] && return
    
    if zenity --question --text="Permanently delete '$db_name' and all its tables?"; then
        rm -rf "${DB_DIR:?}/${db_name:?}"  # Safe delete
        zenity --info --text="Database '$db_name' dropped successfully"
    fi
}



# Main Menu
main_menu() {
    while true; do
        choice=$(zenity --list --title="DBMS Main Menu" \
            --column="Option" \
            --width=700 --height=500 \
            "Create Database" \
            "List Databases" \
            "Connect to Database" \
            "Drop Database" \
            "Exit")
        
        [[ $? -ne 0 ]] && break  # Exit on cancel/close
        
        case "$choice" in
            "Create Database") create_database ;;
            "List Databases") list_databases ;;
            "Connect to Database") connect_database ;;
            "Drop Database") drop_database ;;
            "Exit") break ;;
            *) zenity --error --text="Invalid option" ;;
        esac
    done
}

# Initialize and start
initialize_db_dir
main_menu