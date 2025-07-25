#!/bin/bash

source list_tables.sh
source drop_table.sh
source insert_table.sh
source list_tables_radio.sh
source select_table.sh
source create_table.sh
source update_table.sh
source delete_row.sh

database_menu() {
    local db_name="$1"
    while true; do
        choice=$(zenity --list --title="Database: $db_name" \
            --column="Action" --width=500 --height=400 \
            "Create Table" \
            "List Tables" \
            "Drop Table" \
            "Insert Table" \
            "Select Table" \
            "Update Table" \
            "Delete Row" \
            "Back to Main Menu")
        
        [[ $? -ne 0 ]] && break

        case "$choice" in
            "Create Table") 
                (
                    cd "$DB_DIR/$db_name" || exit
                    create_table
                )
                ;;
            "List Tables") 
                (
                    cd "$DB_DIR/$db_name" || exit
                    list_tables
                )
                ;;
            "Drop Table") 
                (
                    cd "$DB_DIR/$db_name" || exit
                    drop_table
                )
                ;;
            "Insert Table") 
                (
                    cd "$DB_DIR/$db_name" || exit
                    insert_table
                )
                ;;
            "Select Table") 
                (
                    cd "$DB_DIR/$db_name" || exit
                    select_table 
                )
                ;;
            "Update Table") (
                    cd "$DB_DIR/$db_name" || exit
                    update_table
            ) ;;
            "Delete Row") 
                (
                    cd "$DB_DIR/$db_name" || exit
                    delete_row
                )
                ;;
            "Back to Main Menu") break ;;
            *) zenity --error --text="Invalid option" ;;
        esac
    done
}