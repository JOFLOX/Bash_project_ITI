#!/bin/bash
source list_tables_radio.sh

select_table() {
    local tb=""
    
    tb=$(list_tables_radio)
    [[ $? -ne 0 || -z "$tb" ]] && return
local meta_file="$tb.meta"
local data_file="$tb.data"

# Verify files exist
# if [ ! -f "$data_file" ]; then
#     zenity --error --text="Data file not found: $data_file"
#     exit 1
# fi

# if [ ! -f "$meta_file" ]; then
#     zenity --error --text="Metadata file not found: $meta_file"
#     exit 1
# fi



# Extract column names from metadata
columns=()
while IFS= read -r line; do
    col_name="${line%%:*}"        # Extract first field before colon
    columns+=("$col_name")
done < "$meta_file"

# Create tab-separated table
(
    # Print header
    printf "%s\n" "$(IFS=$'\t'; printf '%s' "${columns[*]}")"

    # Process data lines
    while IFS= read -r line; do
        # Split line into fields first
        IFS=':' read -ra fields <<< "$line"

        # Unescape each field
        for i in "${!fields[@]}"; do
            fields[$i]="${fields[$i]//%3A/:}"
        done

        # Ensure correct number of fields
        for ((i = ${#fields[@]}; i < ${#columns[@]}; i++)); do
            fields+=("")
        done

        # Print fields tab-separated
        printf "%s\n" "$(IFS=$'\t'; echo "${fields[*]}")"
    done < "$data_file"
) | {
    # Format with column if available, otherwise raw output
    if command -v column >/dev/null; then
        column -t -s $'\t'
    else
        cat
    fi
} | zenity --text-info \
           --title="Viewing: ${base}.data" \
           --width=800 \
           --height=600 \
           --font="monospace"
}
