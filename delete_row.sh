delete_row() {
    local tb=""
    local selected_row=""

    # Select table
    tb=$(list_tables_radio)
    [[ $? -ne 0 || -z "$tb" ]] && return

    local meta_file="$tb.meta"
    local data_file="$tb.data"

    # Read metadata
    local col_names=()
    while IFS=':' read -r name _; do
        col_names+=("$name")
    done < "$meta_file"

    # Prepare entries
    local entries=()
    local row_num=1
    while IFS= read -r line; do
        IFS=':' read -ra fields <<< "$line"
        # Unescape %3A → :
        for i in "${!fields[@]}"; do
            fields[$i]="${fields[$i]//%3A/:}"
        done

        entries+=("$row_num" "${fields[@]}")
        ((row_num++))
    done < "$data_file"

    # Show Zenity list
    selected_row=$(zenity --title="Select Row to Delete" --list \
        --column="Row #" $(for name in "${col_names[@]}"; do echo --column="$name"; done) \
        "${entries[@]}" \
        --width=700 --height=400)
    [[ $? -ne 0 ]] && return

    if [[ -z "$selected_row" ]]; then
        zenity --error --text="Select a valid table from the listed options."
        delete_row
        return
    fi

    # Confirm deletion
    zenity --question --text="Are you sure you want to delete row #$selected_row?"
    [[ $? -ne 0 ]] && return

    # Delete the row
    awk -v ln="$selected_row" 'NR != ln' "$data_file" > temp && mv temp "$data_file"

    zenity --info --text="Row deleted successfully!"
}
