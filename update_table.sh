source validate.sh

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

        # Unescape each field
        for i in "${!fields[@]}"; do
            fields[$i]="${fields[$i]//%3A/:}"
        done

        entries+=("$row_num" "${fields[@]}")
        ((row_num++))
    done < "$data_file"

    # Show Zenity list
    selected_row=$(zenity --title="Select Row to Update" --list \
        --column="Row #" $(for name in "${col_names[@]}"; do echo --column="$name"; done) \
        "${entries[@]}" \
        --width=700 --height=400)
    [[ $? -ne 0 ]] && return
    
    if [[ -z "$selected_row" ]]; then
        zenity --error --text="Select a valid table from the listed options."
        update_table
        return 
    fi

    # Extract original row content
    local orig_data
    orig_data=$(sed -n "${selected_row}p" "$data_file")
    IFS=':' read -ra orig_values <<< "$orig_data"

    # Unescape each field
    for i in "${!orig_values[@]}"; do
        orig_values[$i]="${orig_values[$i]//%3A/:}"
    done

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

            
            if [[ "${pk_fields[$i]}" == "PK" && "$input" != "$original" ]]; then
                ! check_pk_not_empty "$field_name" "$input" && continue
                ! check_duplicate_pk "$input" "$i" "$selected_row" "$data_file" && continue
            fi

            if [[ "$field_type" == "INT" ]]; then
                ! validate_int "$field_name" "$input" && continue
            fi
           
            new_values+=("$input")
            break
        done
    done

    # Update data
    local new_line
    # Escape new values
    for i in "${!new_values[@]}"; do
        new_values[$i]="${new_values[$i]//:/%3A}"
    done

    # Join with colon and update
    new_line=$(IFS=:; echo "${new_values[*]}")
    awk -v ln="$selected_row" -v new="$new_line" 'NR==ln {$0=new} 1' "$data_file" > temp && mv temp "$data_file"
    zenity --info --text="Row updated successfully!"
}
