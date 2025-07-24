#!/bin/bash


list_tables() {
# Get existing .meta files using a loop
table_files=()
for file in *.meta; do
    if [ -f "$file" ]; then
        table_files+=("$file")
    fi
done

# Check if no tables exist
if [ ${#table_files[@]} -eq 0 ]; then
    zenity --info \
        --title="No Tables Found" \
        --text="No tables exist in the database." \
        --width=300
    exit 0
fi

# Remove the .meta extension
tables=()
for file in "${table_files[@]}"; do
    tables+=("${file%.meta}")
done

# Display in Zenity
zenity --list \
    --title="Database Tables" \
    --text="List of tables in the database:" \
    --column="Table Name" "${tables[@]}" \
    --width=400 \
    --height=300
}