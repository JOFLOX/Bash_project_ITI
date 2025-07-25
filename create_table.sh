#!/bin/bash

create_table() {
    local table_name
    while true; do
        table_name=$(zenity --entry --title="Create Table" --text="Enter table name:")
        [[ $? -ne 0 ]] && return  

        if [[ -z "$table_name" ]]; then
            zenity --error --text="Table name cannot be empty."
        elif ! [[ "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            zenity --error --text="Invalid table name. Use only letters, digits, and underscores, starting with a letter or underscore."
        elif [[ -e "$table_name.meta" ]]; then
            zenity --error --text="Table '$table_name' already exists!"
        else
            break
        fi
    done

    local col_count=""
    while true; do
        col_count=$(zenity --entry --title="Columns" --text="Enter number of columns:")
        [[ $? -ne 0 ]] && return  

        if [[ "$col_count" =~ ^[1-9][0-9]*$ && "$col_count" -le 15 ]]; then
            break
        else
            zenity --error --text="Invalid column count. Please enter a number between 1 and 15."
        fi
    done

    local col_names=()
    local col_types=()

    for ((i=1; i<=col_count; i++)); do
        local col_name
        while true; do
            col_name=$(zenity --entry --title="Column $i" --text="Enter column $i name:")
            [[ $? -ne 0 ]] && return  # Cancel

            if [[ -z "$col_name" ]]; then
                zenity --error --text="Column name cannot be empty."
            elif ! [[ "$col_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                zenity --error --text="Invalid column name. Use only letters, digits, and underscores, starting with a letter or underscore."
            elif [[ " ${col_names[*]} " =~ " $col_name " ]]; then
                zenity --error --text="Duplicate column name '$col_name'."
            else
                break
            fi
        done

        local col_type
        col_type=$(zenity --list --radiolist \
            --title="Column $i Type" \
            --column "Select" --column "Type" \
            TRUE "string" FALSE "int")
        [[ $? -ne 0 || -z "$col_type" ]] && return

        col_names+=("$col_name")
        col_types+=("$col_type")
    done

    local pk=""
    pk=$(zenity --list --radiolist --title="Primary Key" \
        --column "Select" --column "Column" \
        $(for i in "${!col_names[@]}"; do
            if [[ $i -eq 0 ]]; then
                echo "TRUE" "${col_names[i]}"
            else
                echo "FALSE" "${col_names[i]}"
            fi
        done))
    [[ $? -ne 0 || -z "$pk" ]] && return

    > "$table_name.meta"
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