local resevred_keywords=("select" "drop" "insert" "delete" "update" "table" "create" "int" "string" "from" "where" "null" "pk" "system" "default") 


is_valid_name() {
    [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]{0,63}$ ]]
}

is_reserved_keyword() {
    local name_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    for word in "${resevred_keywords[@]}"; do
        if [[ "$name_lower" == "$word" ]]; then return 0; fi
    done
    return 1
}




validate_table_name() {
    local name="$1"

    if [[ -z "$name" ]]; then
        zenity --error --text="Table name cannot be empty."
        return 1
    elif ! is_valid_name "$name"; then
        zenity --error --text="Invalid table name.\nMust start with a letter or underscore and use only letters, numbers, or underscores."
        return 1
    elif is_reserved_keyword "$name"; then
        zenity --error --text="Table name '$name' is a reserved keyword."
        return 1
    elif [[ -e "$name.meta" ]]; then
        zenity --error --text="Table '$name' already exists."
        return 1
    fi

    return 0
}

validate_column_name() {
    local name="$1"
    local table_name="$2"
    local existing_cols=("${@:3}")

    if [[ -z "$name" ]]; then
        zenity --error --text="Column name cannot be empty."
        return 1
    elif ! is_valid_name "$name"; then
        zenity --error --text="Invalid column name. Must start with a letter/underscore and contain only letters, numbers, or underscores."
        return 1
    elif is_reserved_keyword "$name"; then
        zenity --error --text="Column name '$name' is a reserved keyword."
        return 1
    elif [[ "$name" == "$table_name" ]]; then
        zenity --error --text="Column name cannot be the same as the table name."
        return 1
    elif [[ " ${existing_cols[*]} " =~ " $name " ]]; then
        zenity --error --text="Duplicate column name '$name'."
        return 1
    fi

    return 0
}

validate_column_count() {
    local count="$1"
    [[ "$count" =~ ^[1-9][0-9]*$ && "$count" -le 15 ]]
}


validate_primary_key_type() {
    local pk="$1"
    local col_names=("${!2}")
    local col_types=("${!3}")

    for i in "${!col_names[@]}"; do
        if [[ "${col_names[i]}" == "$pk" && "${col_types[i]}" != "int" ]]; then
            zenity --error --text="Primary key '$pk' must be of type 'int'."
            return 1
        fi
    done
    return 0
}

create_table() {
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
            col_name=$(zenity --entry --title="Column $i" --text="Enter column $i name:")
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
    pk=$(zenity --list --radiolist --title="Primary Key" \
        --column "Select" --column "Column" \
        $(for i in "${!col_names[@]}"; do
            if [[ $i -eq 0 ]]; then echo "TRUE" "${col_names[i]}"; else echo "FALSE" "${col_names[i]}"; fi
        done))
    [[ $? -ne 0 || -z "$pk" ]] && return

    validate_primary_key_type "$pk" col_names[@] col_types[@] || return

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