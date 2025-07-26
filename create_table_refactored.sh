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
    elif has_forbidden_chars "$name"; then
        zenity --error --text="Table name contains forbidden characters."
        return 1
    elif [[ -e "$name.meta" ]]; then
        zenity --error --text="Table '$name' already exists."
        return 1
    fi

    return 0
}
