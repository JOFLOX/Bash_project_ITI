#!/bin/bash

drop_table() {
    # List .meta files and strip the extension to get table names
    local tables=($(ls *.meta 2>/dev/null | sed 's/\.meta$//'))

    if [[ ${#tables[@]} -eq 0 ]]; then
        zenity --info --text="No tables found in the current database."
        return
    fi

    # Display tables for selection
    local table_to_delete
    table_to_delete=$(zenity --list \
        --title="Drop Table" \
        --text="Select a table to drop:" \
        --column="Tables" \
        --height=400 --width=300 \
        "${tables[@]}")

    [[ -z "$table_to_delete" ]] && return  # Cancelled

    # Confirm deletion
    zenity --question --text="Are you sure you want to drop table '$table_to_delete'?"
    [[ $? -ne 0 ]] && return  # User clicked "No"

    # Delete table files
    rm -f "$table_to_delete.meta" "$table_to_delete.data"

    zenity --info --text="Table '$table_to_delete' dropped successfully."
}
