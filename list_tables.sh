#!/bin/bash

# Get the list of .meta files (tables) in the current directory
shopt -s nullglob
table_files=(*.meta)
shopt -u nullglob

# Check if no tables exist
if [ ${#table_files[@]} -eq 0 ]; then
    zenity --info \
        --title="No Tables Found" \
        --text="No tables exist in the database." \
        --width=300
    exit 0
fi

# Remove the .meta extension from filenames
tables=()
for file in "${table_files[@]}"; do
    tables+=("${file%.meta}")
done

# Display tables in a Zenity list dialog
zenity --list \
    --title="Database Tables" \
    --text="List of tables in the database:" \
    --column="Table Name" "${tables[@]}" \
    --width=400 \
    --height=300