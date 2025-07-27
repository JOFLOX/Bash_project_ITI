resevred_keywords=("select" "drop" "insert" "delete" "update" "table" "create" "int" "string" "from" "where" "null" "pk" "system" "default") 

is_valid_name() {
    [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]{0,63}$ ]]
}

check_pk_not_empty() {
    local field_name="$1"
    local value="$2"

    if [[ -z "$value" ]]; then
        zenity --error --text="Primary key '$field_name' cannot be empty."
        return 1
    fi
    return 0
}

validate_int() {
    local field_name="$1"
    local value="$2"

    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        zenity --error --text="$field_name must be an integer."
        return 1
    fi
    return 0
}

check_duplicate_pk() {
    local value="$1"
    local column_index="$2"
    local skip_row="$3"
    local data_file="$4"

    local line_num=1
    while IFS= read -r line; do
        if [[ $line_num -ne $skip_row ]]; then
            IFS=':' read -ra fields <<< "$line"
            if [[ "${fields[$column_index]}" == "$value" ]]; then
                zenity --error --text="Primary key value '$value' already exists in another row."
                return 1
            fi
        fi
        ((line_num++))
    done < "$data_file"
    return 0
}


is_reserved_keyword() {
    local name_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    for word in "${resevred_keywords[@]}"; do
        if [[ "$name_lower" == "$word" ]]; then return 0; fi
    done
    return 1
}
resevred_keywords=("select" "drop" "insert" "delete" "update" "table" "create" "int" "string" "from" "where" "null" "pk" "system" "default") 


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


validate_create_db() {
    local db_name="$1"
    local db_lower
    # local reserved_names=("create" "drop" "select" "insert" "delete" "system" "null" "default")

    # 1. Check if name is empty
    if [[ -z "$db_name" ]]; then
        zenity --error --text="Database name cannot be empty!"
        return 1
    fi

    # 2. Check for valid name pattern (start with letter/_ + letters/numbers/_ only, up to 64 chars)
    if ! is_valid_name "$db_name" ; then
        zenity --error --text="Invalid database name!\n\nAllowed:\n- Start with letter/underscore\n- Only letters, numbers, underscores\n- Max 64 characters"
        return 1
    fi

    # # 3. Check for forbidden filesystem or shell characters
    #  I THINK WE DONT NEED THIS
    # if [[ "$db_name" == *[/.~]* || "$db_name" == .* ]]; then
    #     zenity --error --text="Database name cannot contain / . ~ or start with a dot."
    #     return 1
    # fi

    # 4. Normalize and check reserved keywords
    # db_lower=$(echo "$db_name" | tr '[:upper:]' '[:lower:]')
    # for keyword in "${reserved_names[@]}"; do
    #     if [[ "$db_lower" == "$keyword" ]]; then
    #         zenity --error --text="Database name '$db_name' is a reserved keyword!"
    #         return 1
    #     fi
    # done


    if is_reserved_keyword "$db_name"; then
        zenity --error --text="Database name '$db_name' is a reserved keyword!"
        return 1
    fi



    # 5. Check if database already exists
    # db_lower=$(echo "$db_name" | tr '[:upper:]' '[:lower:]')

    # if [ -d "$DB_DIR/$db_name" ]; then
    #     zenity --error --text="Database '$db_name' already exists! as '$db_name'"
    #     return 1
    # fi

    # Convert input to lowercase
    db_lower=$(echo "$db_name" | tr '[:upper:]' '[:lower:]')

    # Loop over all existing databases
    for existing_db in "$DB_DIR"/*; do
        [ -d "$existing_db" ] || continue  # Skip non-directories
        existing_name=$(basename "$existing_db")
        existing_lower=$(echo "$existing_name" | tr '[:upper:]' '[:lower:]')

        if [ "$db_lower" = "$existing_lower" ]; then
            zenity --error --text="Database '$db_name' already exists as '$existing_name'"
            return 1
        fi
    done



    return 0
}

available_dbs() {
       if [[ -z "$(ls -A "$DB_DIR")" ]]; then
        zenity --info --text="No databases found"
        return 
    fi
    
    local dbs
    dbs="$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)"
    echo "$dbs"
}

valid_db_selection() {
    local db_name="$1"
    if [[ -z "$db_name" ]]; then
        zenity --error --text="Select a valid database from the listed options."
        return 1
    fi
    return 0
}