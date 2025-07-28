source validate.sh
create_table () {
    local table_name

    # ─── 1. Table Name ─────────────────────────
    while true; do
        table_name=$(zenity --entry --title="Create Table" --text="Enter table name:")
        [[ $? -ne 0 ]] && return
        validate_table_name "$table_name" && break
    done

    # ─── 2. Column Count ───────────────────────
    local col_count=""
    while true; do
        col_count=$(zenity --entry --title="Columns" --text="Enter number of columns (1–15):")
        [[ $? -ne 0 ]] && return
        validate_column_count "$col_count" && break
        zenity --error --text="Invalid column count. Please enter a number between 1 and 15."
    done

        # ─── 3. Column Names and Types ─────────────
    local col_names=()
    local col_types=()

    for ((i=1; i<=col_count; i++)); do
        local col_name=""
        while true; do
            col_name=$(zenity --entry --title="Column $i of $col_count" --text="Enter column $i name:")
            [[ $? -ne 0 ]] && return
            validate_column_name "$col_name" "$table_name" "${col_names[@]}" && break
        done

        local col_type=""
        col_type=$(zenity --list --radiolist \
            --title="Column $i Type" \
            --column "Select" --column "Type" \
            TRUE "string" FALSE "int")
        [[ $? -ne 0 || -z "$col_type" ]] && return

        col_names+=("$col_name")
        col_types+=("$col_type")
    done


 # ─── 4. Primary Key ────────────────────────
    local pk=""
    # pk=$(zenity --list --radiolist --title="Primary Key" \
    #     --column "Select" --column "Column" \
    #     $(for i in "${!col_names[@]}"; do
    #         if [[ $i -eq 0 ]]; then echo "TRUE" "${col_names[i]}"; else echo "FALSE" "${col_names[i]}"; fi
    #     done))
    # [[ $? -ne 0 || -z "$pk" ]] && return

    pk=$(zenity --list --radiolist --title="Primary Key" \
        --column "Select" --column "Column" --column "Type" \
        $(for i in "${!col_names[@]}"; do
            if [[ $i -eq 0 ]]; then echo "TRUE" "${col_names[i]}" "${col_types[i]}"; else echo "FALSE" "${col_names[i]}" "${col_types[i]}"; fi
        done))
    [[ $? -ne 0 || -z "$pk" ]] && return



    # validate_primary_key_type "$pk" col_names[@] col_types[@] || return

    # ─── 5. Create Metadata and Data Files ─────
    > "$table_name.meta" || { zenity --error --text="Failed to create metadata file."; return; }
    for i in "${!col_names[@]}"; do
        if [[ "${col_names[i]}" == "$pk" ]]; then
            echo "${col_names[i]}:${col_types[i]}:PK" >> "$table_name.meta"
        else
            echo "${col_names[i]}:${col_types[i]}:" >> "$table_name.meta"
        fi
    done

    touch "$table_name.data"
    zenity --info --text="Table '$table_name' created successfully!"
    
}