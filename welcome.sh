#!/bin/bash

# Global Variables
DB_DIR="$HOME/dbms"  # Main database directory
TABLE_DATA_EXT=".data"
TABLE_META_EXT=".meta"
DEVELOPERS=("John Smith" "Alex Johnson")  # Replace with actual names

# Create main DB directory if not exists
initialize_db_dir() {
    if [[ ! -d "$DB_DIR" ]]; then
        mkdir -p "$DB_DIR"
    fi
}

# Show welcome screen
show_welcome() {
    local welcome_text="
╔═════════════════════════════════════════════╗
║          DATABASE MANAGEMENT SYSTEM         ║
╟─────────────────────────────────────────────╢
║  Project: Bash DBMS with Zenity Interface   ║
║  Version: 1.0.0                             ║
║  Release Date: July 2024                    ║
╟─────────────────────────────────────────────╢
║  Developed By:                              ║
║  • ${DEVELOPERS[0]}                         ║
║  • ${DEVELOPERS[1]}                         ║
╟─────────────────────────────────────────────╢
║  Features:                                  ║
║  • Create/List/Drop Databases               ║
║  • Table-based Data Storage                 ║
║  • Metadata Management                      ║
║  • Comprehensive Validations                ║
╚═════════════════════════════════════════════╝
"

    zenity --info \
        --title="Database Management System" \
        --text="$welcome_text" \
        --width=500 \
        --height=300
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
    
    if ! validate_identifier "$db_name"; then
        zenity --error --text="Invalid name!\n\nAllowed:\n- Start with letter/underscore\n- Contain letters/numbers/underscores\n- Max 64 characters"
        return
    fi
    
    local db_path="$DB_DIR/$db_name"
    if [[ -d "$db_path" ]]; then
        zenity --error --text="Database '$db_name' already exists!"
    else
        mkdir -p "$db_path"
        zenity --info --text="Database '$db_name' created successfully at:\n$db_path"
    fi
}

list_databases() {
    if [[ -z "$(ls -A "$DB_DIR")" ]]; then
        zenity --info --text="No databases found"
        return
    fi
    
    local dbs
    dbs=$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)
    
    zenity --list \
        --title="Available Databases" \
        --column="Database Name" \
        --width=300 --height=400 \
        $dbs
}

connect_database() {
    if [[ -z "$(ls -A "$DB_DIR")" ]]; then
        zenity --error --text="No databases available"
        return
    fi
    
    local db_name
    db_name=$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | \
              sort | zenity --list \
                --title="Connect to Database" \
                --column="Database Name" \
                --width=300 --height=400)
    
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
              sort | zenity --list \
                --title="Drop Database" \
                --column="Database Name" \
                --width=300 --height=400)
    
    [[ -z "$db_name" ]] && return
    
    if zenity --question \
        --title="Confirm Deletion" \
        --text="Permanently delete database '$db_name'?\n\nThis will destroy ALL tables and data!" \
        --ok-label="Delete Database" \
        --cancel-label="Cancel"; then
        
        rm -rf "${DB_DIR:?}/${db_name:?}"  # Safe delete
        zenity --info --text="Database '$db_name' dropped successfully"
    fi
}

# Database Menu (Placeholder)
database_menu() {
    local db_name="$1"
    zenity --info --title="Connected to '$db_name'" \
        --text="Database operations will be implemented in next phase\n\nSelected database: $db_name" \
        --width=400
}

# Main Menu
main_menu() {
    while true; do
        choice=$(zenity --list \ 
            --center \
            --title="DBMS Main Menu" \
            --column="Options" \
            --width=500 --height=350 \
            "Create Database" \
            "List Databases" \
            "Connect to Database" \
            "Drop Database" \
            "Exit System")
        
        [[ $? -ne 0 ]] && break  # Exit on cancel/close
        
        case "$choice" in
            "Create Database") create_database ;;
            "List Databases") list_databases ;;
            "Connect to Database") connect_database ;;
            "Drop Database") drop_database ;;
            "Exit System") 
                zenity --info --title="Goodbye" --text="Thank you for using DBMS!" --width=300
                break 
                ;;
            *) zenity --error --text="Invalid option" ;;
        esac
    done
}

# Main execution flow
initialize_db_dir
show_welcome
main_menu