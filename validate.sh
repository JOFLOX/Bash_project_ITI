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
    if [ -d "$DB_DIR/$db_lower" ]; then
        zenity --error --text="Database '$db_name' already exists!"
        return 1
    fi

    return 0
}

available_dbs() {
       if [[ -z "$(ls -A "$DB_DIR")" ]]; then
        zenity --info --text="No databases found"
        return
    fi
    
    local dbs
    dbs=$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)
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