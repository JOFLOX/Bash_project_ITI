#!/bin/bash

create_table() {
    local table_name
    table_name=$(zenity --entry --title="Create Table" --text="Enter table name:")
    [[ $? -ne 0 || -z "$table_name" ]] && return

    if ! [[ "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        zenity --error --text="Invalid table name."
        return
    fi

    if [[ -e "$table_name.meta" ]]; then
        zenity --error --text="Table '$table_name' already exists!"
        return
    fi

    local col_count=""
    while true; do
        col_count=$(zenity --entry --title="Columns" --text="Enter number of columns:")
        [[ $? -ne 0 ]] && return  # User pressed cancel

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
        col_name=$(zenity --entry --title="Column $i" --text="Enter column $i name:")
        [[ $? -ne 0 || -z "$col_name" ]] && return

        local col_type
        col_type=$(zenity --list --radiolist \
            --title="Column $i Type" \
            --column "Select" --column "Type" \
            TRUE "string" FALSE "int")

        [[ -z "$col_type" ]] && return

        col_names+=("$col_name")
        col_types+=("$col_type")
    done

    local pk=""
    while [[ -z "$pk" ]]; do
        pk=$(zenity --list --radiolist --title="Primary Key" \
            --column "Select" --column "Column" \
            $(for i in "${!col_names[@]}"; do
                if [[ $i -eq 0 ]]; then
                    echo "TRUE" "${col_names[i]}"
                else
                    echo "FALSE" "${col_names[i]}"
                fi
            done))
    done

    {
        for i in "${!col_names[@]}"; do
            if [[ "${col_names[i]}" == "$pk" ]]; then
                echo "${col_names[i]}:${col_types[i]}:PK"
            else
                echo "${col_names[i]}:${col_types[i]}"
            fi
        done
    } > "$table_name.meta"

    touch "$table_name.data"
    zenity --info --text="Table '$table_name' created successfully!"
}
