update_table() {
    local tb=""
    local selected_row=""

    # Select table
    tb=$(list_tables_radio)
    [[ $? -ne 0 || -z "$tb" ]] && return

    local meta_file="$tb.meta"
    local data_file="$tb.data"

    # Read metadata
    local col_names=()
    local col_types=()
    local pk_fields=()
    while IFS=':' read -r name type flags; do
        col_names+=("$name")
        col_types+=("$type")
        pk_fields+=("$flags")
    done < "$meta_file"

    # Prepare entries
    local entries=()
    local row_num=1
    while IFS= read -r line; do
        IFS=':' read -ra fields <<< "$line"
        entries+=("$row_num" "${fields[@]}")
        ((row_num++))
    done < "$data_file"

    # Show Zenity list
    selected_row=$(zenity --title="Select Row to Update" --list \
        --column="Row #" $(for name in "${col_names[@]}"; do echo --column="$name"; done) \
        "${entries[@]}" \
        --width=700 --height=400)
    [[ $? -ne 0 || -z "$selected_row" ]] && return

    # Extract original row content
    local orig_data
    orig_data=$(sed -n "${selected_row}p" "$data_file")
    IFS=':' read -ra orig_values <<< "$orig_data"

    # Collect new values
    local new_values=()
    for i in "${!col_names[@]}"; do
        while true; do
            local field_name="${col_names[$i]}"
            local field_type="${col_types[$i]^^}"
            local original="${orig_values[$i]}"
            local prompt="${field_name}"
            [[ "${pk_fields[$i]}" == "PK" ]] && prompt+=" (PK)"

            local input
            input=$(zenity --entry \
                --title="Update $field_name" \
                --text="$prompt [${field_type}]:" \
                --entry-text="$original")

            # Cancel was pressed
            if [[ $? -ne 0 ]]; then
                zenity --info --text="Update cancelled."
                return
            fi

            # Treat cancel (which may return empty) the same
            if [[ -z "$input" && "$input" != "$original" ]]; then
                zenity --info --text="Update cancelled."
                return
            fi

            # PK check
            if [[ "${pk_fields[$i]}" == "PK" && -z "$input" ]]; then
                zenity --error --text="Primary key cannot be empty"
                continue
            fi

            # INT validation
            if [[ "$field_type" == "INT" && ! "$input" =~ ^-?[0-9]+$ ]]; then
                zenity --error --text="$field_name must be an integer"
                continue
            fi

            # Duplicate PK check
            if [[ "${pk_fields[$i]}" == "PK" && "$input" != "$original" ]]; then
                local duplicate_found=0
                local line_num=1
                while IFS= read -r line; do
                    if [[ $line_num -ne $selected_row ]]; then
                        IFS=':' read -ra fields <<< "$line"
                        if [[ "${fields[$i]}" == "$input" ]]; then
                            duplicate_found=1
                            break
                        fi
                    fi
                    ((line_num++))
                done < "$data_file"
                if [[ $duplicate_found -eq 1 ]]; then
                    zenity --error --text="Primary key value '$input' already exists in another row."
                    continue
                fi
            fi

            new_values+=("$input")
            break
        done
    done

    # Update data
    local new_line
    new_line=$(IFS=:; echo "${new_values[*]}")
    awk -v ln="$selected_row" -v new="$new_line" 'NR==ln {$0=new} 1' "$data_file" > temp && mv temp "$data_file"
    zenity --info --text="Row updated successfully!"
}
