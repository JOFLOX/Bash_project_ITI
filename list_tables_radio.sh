#!/bin/bash
source form.sh

list_tables_radio() {
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
# Transform tables array into radio list format (first table selected by default)

# Display radiolist dialog
local tb=""

    while [[ -z "$tb" ]]; do
        tb=$(zenity --list --radiolist --title="Primary Key" \
            --column "Select" --column "Column" \
            $(for i in "${!tables[@]}"; do
                if [[ $i -eq 0 ]]; then
                    echo "TRUE" "${tables[i]}"
                else
                    echo "FALSE" "${tables[i]}"
                fi
            done))
    done

zenity --info --text="You selected: $tb"
create_zenity_form "$tb.meta" "$tb.data"
}